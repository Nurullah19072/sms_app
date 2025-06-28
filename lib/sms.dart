import 'package:flutter/material.dart';
import 'message.dart';
import 'sms_service.dart';
import 'permission.dart';
import 'messages.dart';
import 'spamsms.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:another_telephony/telephony.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'huggingface_service.dart';
import 'SettingsScreen.dart';
import 'settings_manager.dart'; // ✅ SettingsManager'ı import et
import 'package:flutter/services.dart'; // başa ekle



class SmsScreen extends StatefulWidget {
  @override
  _SmsScreenState createState() => _SmsScreenState();
}

class _SmsScreenState extends State<SmsScreen> {
  final SmsService _smsService = SmsService();
  Map<String, String> _contactNames = {};
  List<Message> _messages = [];
  List<Message> _spamMessages = [];
  List<Message> _normalMessages = [];
  bool _isLoading = true;
  int _selectedIndex = 0;
  final Telephony telephony = Telephony.instance;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await SettingsManager.loadSettings(); // ✅ Kullanıcı ayarlarını yükle
      await _requestPermissions(); // ⬅️ hem SMS hem rehber iznini sırayla iste
      _startListeningToIncomingSms();
      _loadContacts();             // ⬅️ izinden sonra çağır
    });

  }

  Future<void> _requestPermissions() async {
    bool smsGranted = await PermissionService.checkAndRequestSmsPermission();
    bool contactGranted = await PermissionService.checkAndRequestContactsPermission();

    if (!smsGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("SMS izni gerekli!")),
      );
    }

    if (!contactGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Rehber erişim izni gerekli!")),
      );
    }
  }


  void _startListeningToIncomingSms() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) async {
        if (message.body == null) return;

        String body = message.body!;
        String sender = message.address ?? "Bilinmeyen";

        // Tarihi güvenli şekilde al
        DateTime timestamp = (message.date != null && message.date is int)
            ? DateTime.fromMillisecondsSinceEpoch(message.date as int)
            : DateTime.now();

        // Mesaj modelini oluştur
        Message newMessage = Message(
          sender: sender,
          recipient: "Ben",
          body: body,
          date: timestamp,
        );

        // Spam kontrolü
        bool isSpam = await HuggingFaceService.isSpam(body);

        // Caching işlemleri
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> spamList = prefs.getStringList("spamMessages") ?? [];
        List<String> processedList = prefs.getStringList("processedMessages") ?? [];

        if (!processedList.contains(body)) {
          processedList.add(body);
          if (isSpam) {
            spamList.add(body);
          }
          await prefs.setStringList("spamMessages", spamList.toSet().toList());
          await prefs.setStringList("processedMessages", processedList.toSet().toList());
        }

        setState(() {
          if (isSpam) {
            _spamMessages.add(newMessage);
          } else {
            _normalMessages.add(newMessage);

            String contact = newMessage.sender == "Ben" ? newMessage.recipient : newMessage.sender;

            // 🔁 Eski varsa güncelle, yoksa ekle
            int index = _messages.indexWhere((m) {
              final mContact = m.sender == "Ben" ? m.recipient : m.sender;
              return mContact == contact;
            });

            if (index >= 0) {
              // Varsa: güncelle (son mesajı göster)
              _messages[index] = newMessage;
            } else {
              // Yoksa: ekle
              _messages.add(newMessage);
            }
          }
        });


        print("📩 Yeni SMS işlendi: $sender - $body");
      },
      onBackgroundMessage: backgroundMessageHandler, // 🆕 Arka plan işlemleri için yeni fonksiyon
      listenInBackground: true, // 🆙 artık arka planda da dinleyecek
    );
  }


// Arka planda mesaj alınırsa (şu an kullanılmasa da dursun)
  Future<void> _handleIncomingMessage(SmsMessage message) async {
    if (message.body == null) return;

    String body = message.body!;
    String sender = message.address ?? "Bilinmeyen";

    DateTime timestamp = (message.date != null && message.date is int)
        ? DateTime.fromMillisecondsSinceEpoch(message.date as int)
        : DateTime.now();

    Message newMessage = Message(
      sender: sender,
      recipient: "Ben",
      body: body,
      date: timestamp,
    );

    bool isSpam = await HuggingFaceService.isSpam(body);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> spamList = prefs.getStringList("spamMessages") ?? [];
    List<String> processedList = prefs.getStringList("processedMessages") ?? [];

    if (!processedList.contains(body)) {
      processedList.add(body);
      if (isSpam) {
        spamList.add(body);
      }
      await prefs.setStringList("spamMessages", spamList.toSet().toList());
      await prefs.setStringList("processedMessages", processedList.toSet().toList());
    }

    // Eğer uygulama açıkken gelirse ekranda da gösterelim
    if (mounted) {
      setState(() {
        if (isSpam) {
          _spamMessages.add(newMessage);
        } else {
          _normalMessages.add(newMessage);

          String contact = newMessage.sender == "Ben" ? newMessage.recipient : newMessage.sender;

          int index = _messages.indexWhere((m) {
            final mContact = m.sender == "Ben" ? m.recipient : m.sender;
            return mContact == contact;
          });

          if (index >= 0) {
            _messages[index] = newMessage;
          } else {
            _messages.add(newMessage);
          }
        }
      });
    }

    print("📩 Mesaj işlendi: $sender - $body");
  }




  Future<void> _loadContacts() async {
    bool hasPermission = await PermissionService.checkAndRequestContactsPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rehber erişim izni gerekli!')),
      );
      return;
    }

    Iterable<Contact> contacts = await ContactsService.getContacts();
    Map<String, String> contactMap = {};
    for (var contact in contacts) {
      if (contact.phones != null) {
        for (var phone in contact.phones!) {
          String formattedNumber = phone.value!.replaceAll(RegExp(r'\s+|-'), '');
          contactMap[formattedNumber] = contact.displayName ?? "Bilinmeyen";
        }
      }
    }

    setState(() {
      _contactNames = contactMap;
    });

    _loadMessages();
  }

  Future<void> _loadMessages() async {
    bool hasPermission = await PermissionService.checkAndRequestSmsPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SMS okuma izni gerekli!')),
      );
      return;
    }

    List<Message> messages = await _smsService.getMessages();
    messages = messages.where((msg) => msg.sender != "Ben").toList();

    await _classifyMessages(messages);
  }

  Future<void> _classifyMessages(List<Message> messages) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> cachedSpamMessages = prefs.getStringList("spamMessages") ?? [];
    List<String> processedMessages = prefs.getStringList("processedMessages") ?? [];

    Set<String> spamBodies = cachedSpamMessages.toSet();
    Set<String> processedBodies = processedMessages.toSet();

    List<Message> spamMessages = [];
    List<Message> normalMessages = [];
    List<Message> unprocessedMessages = [];

    for (var message in messages) {
      if (processedBodies.contains(message.body)) {
        if (spamBodies.contains(message.body)) {
          spamMessages.add(message);
        } else {
          normalMessages.add(message);
        }
      } else {
        unprocessedMessages.add(message);
      }
    }

    for (var message in unprocessedMessages) {
      bool isSpam = await HuggingFaceService.isSpam(message.body);
      if (isSpam) {
        spamMessages.add(message);
        spamBodies.add(message.body);
      } else {
        normalMessages.add(message);
      }
      processedBodies.add(message.body);
    }

    // ✅ Hem gelen hem giden normal mesajlardan kişi listesi oluştur
    Map<String, Message> lastMessages = {};

    for (var msg in normalMessages) {
      String contact;

      if (msg.sender == "Ben") {
        contact = msg.recipient;
      } else {
        contact = msg.sender;
      }

      // 👇 Eğer contact boşsa bu mesajı atla
      if (contact.isEmpty || contact.trim().isEmpty) continue;

      if (!lastMessages.containsKey(contact) ||
          lastMessages[contact]!.date.isBefore(msg.date)) {
        lastMessages[contact] = msg;
      }
    }

    await prefs.setStringList("spamMessages", spamBodies.toList());
    await prefs.setStringList("processedMessages", processedBodies.toList());

    setState(() {
      _spamMessages = spamMessages;
      _normalMessages = normalMessages;
      _messages = lastMessages.values.toList();
      _isLoading = false;
    });

    // DEBUG: tüm mesajları yaz
    print("✅ Son sohbet listesi:");
    for (var msg in _messages) {
      String kisi = msg.sender == "Ben" ? msg.recipient : msg.sender;
      print("📨 Kişi: $kisi, Mesaj: ${msg.body}");
    }
  }







  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tema değiştirilince system bar renklerini de güncelle
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: SettingsManager.isDarkTheme ? Colors.black : Colors.white, // Alt bar
      systemNavigationBarIconBrightness: SettingsManager.isDarkTheme ? Brightness.light : Brightness.dark, // Iconlar
      statusBarColor: Colors.transparent, // Üst bar şeffaf olsun
      statusBarIconBrightness: SettingsManager.isDarkTheme ? Brightness.light : Brightness.dark, // Üst iconlar
    ));
    return ValueListenableBuilder(
      valueListenable: SettingsManager.settingsChanged,
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: SettingsManager.isDarkTheme ? Colors.black : Colors.white,
          appBar: AppBar(
            backgroundColor: SettingsManager.isDarkTheme ? Colors.grey[900] : null,
            title: Text('SMS Uygulaması',
                style: TextStyle(
                  fontFamily: SettingsManager.fontFamily,
                  color: SettingsManager.isDarkTheme ? Colors.white : Colors.black, // ✅ Yazı rengi temaya göre
                )),
            actions: [
              Theme(
                data: Theme.of(context).copyWith(
                  popupMenuTheme: PopupMenuThemeData(
                    color: SettingsManager.isDarkTheme ? Colors.grey[800] : Colors.white, // Menü arka planı
                    textStyle: TextStyle(
                      color: SettingsManager.isDarkTheme ? Colors.white : Colors.black, // Menü yazı rengi
                      fontFamily: SettingsManager.fontFamily,
                      fontSize: SettingsManager.fontSize,
                    ),
                  ),
                ),
                child: PopupMenuButton<String>(
                  icon: Icon( // 👈 Şimdi ikonu kendimiz veriyoruz!
                    Icons.more_vert,
                    color: SettingsManager.isDarkTheme ? Colors.white : Colors.black, // ✅ Tema uyumlu 3 nokta rengi
                  ),
                  onSelected: (String value) async {
                    if (value == 'ayarlar') {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsScreen()),
                      );
                      if (result == true) {
                        setState(() {});
                      }
                    } else if (value == 'version') {
                      showDialog(
                        context: context,
                        builder: (context) {
                          final bool isDark = SettingsManager.isDarkTheme;
                          return AlertDialog(
                            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
                            title: Text(
                              'SMS Uygulaması',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontFamily: SettingsManager.fontFamily,
                                fontSize: SettingsManager.fontSize + 2,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Created by Yıldırım Studios',
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : Colors.black87,
                                    fontFamily: SettingsManager.fontFamily,
                                    fontSize: SettingsManager.fontSize,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Version 1.0.0',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontFamily: SettingsManager.fontFamily,
                                    fontSize: SettingsManager.fontSize - 2,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Tamam',
                                  style: TextStyle(
                                    color: isDark ? Colors.blue[200] : Colors.blue,
                                    fontFamily: SettingsManager.fontFamily,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'ayarlar',
                        child: Text(
                          'Ayarlar',
                          style: TextStyle(
                            color: SettingsManager.isDarkTheme ? Colors.white : Colors.black, // ✅ Tema uyumlu renk
                            fontFamily: SettingsManager.fontFamily,
                            fontSize: SettingsManager.fontSize,
                          ),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'version',
                        child: Text(
                          'Versiyon',
                          style: TextStyle(
                            color: SettingsManager.isDarkTheme ? Colors.white : Colors.black, // ✅ Tema uyumlu renk
                            fontFamily: SettingsManager.fontFamily,
                            fontSize: SettingsManager.fontSize,
                          ),
                        ),
                      ),
                    ],
                ),
              ),
            ],


          ),
          body: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _selectedIndex == 0
              ? ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final displayName = _contactNames[message.sender] ?? message.sender;
              return ListTile(
                leading: Icon(
                  Icons.person,
                  color: SettingsManager.isDarkTheme ? Colors.white : Colors.black, // ✅ Tema uyumlu renk
                ),

                title: Text(
                  displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: SettingsManager.fontFamily,
                    fontSize: SettingsManager.fontSize,
                    color: SettingsManager.isDarkTheme ? Colors.white : Colors.black, // ✅ Tema uyumu
                  ),
                ),
                subtitle: Text(
                  message.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: SettingsManager.fontFamily,
                    fontSize: SettingsManager.fontSize - 2,
                    color: SettingsManager.isDarkTheme ? Colors.white : Colors.black, // ✅ Tema uyumlu renk
                  ),
                ),

                trailing: Text(
                  '${message.date.hour}:${message.date.minute}',
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessagesScreen(
                        sender: message.sender,
                        senderName: displayName,
                        messages: _normalMessages.where((msg) => msg.sender == message.sender).toList(),
                      ),
                    ),
                  );
                },
              );
            },
          )
              : SpamSmsScreen(
            spamMessages: _spamMessages,
            normalMessages: _normalMessages,
            contactNames: _contactNames,
          ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onTabTapped,
              backgroundColor: SettingsManager.isDarkTheme ? Colors.black : Colors.white, // ✅ Tema bağlı renk
              selectedItemColor: Colors.blue, // ✅ Seçili ikon rengi
              unselectedItemColor: SettingsManager.isDarkTheme ? Colors.white70 : Colors.grey, // ✅ Seçili olmayan ikon rengi
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.message), label: "Mesajlar"),
                BottomNavigationBarItem(icon: Icon(Icons.warning), label: "Spam Mesajlar"),
              ],
            ),
        );
      },
    );
  }

}




/// 📩 Arka planda yeni SMS geldiğinde çalışacak handler
Future<void> backgroundMessageHandler(SmsMessage message) async {
  if (message.body == null) return;

  String body = message.body!;

  bool isSpam = await HuggingFaceService.isSpam(body);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> spamList = prefs.getStringList("spamMessages") ?? [];
  List<String> processedList = prefs.getStringList("processedMessages") ?? [];

  if (!processedList.contains(body)) {
    processedList.add(body);
    if (isSpam) {
      spamList.add(body);
    }
    await prefs.setStringList("spamMessages", spamList.toSet().toList());
    await prefs.setStringList("processedMessages", processedList.toSet().toList());
  }

  print("📩 [Arka Plan] Mesaj işlendi: $body");
}

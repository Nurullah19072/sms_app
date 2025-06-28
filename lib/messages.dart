import 'package:flutter/material.dart';
import 'message.dart';
import 'sms_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_manager.dart'; // ✅ SettingsManager import


class MessagesScreen extends StatefulWidget {
  final String sender;
  final String? senderName;
  final List<Message> messages;

  MessagesScreen({required this.sender, this.senderName, required this.messages});

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final SmsService _smsService = SmsService();
  bool _isLoading = true;
  List<Message> _messages = [];
  Set<String> _spamBodies = {};
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    _loadSpamMessages();
  }

  Future<void> _loadSpamMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cachedSpamMessages = prefs.getStringList("spamMessages") ?? [];
    setState(() {
      _spamBodies = cachedSpamMessages.toSet();
    });
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    List<Message> allMessages = await _smsService.getMessages();
    List<Message> conversation = allMessages
        .where((msg) => (msg.sender == widget.sender || msg.recipient == widget.sender) && !_spamBodies.contains(msg.body))
        .toList();
    conversation.sort((a, b) => a.date.compareTo(b.date));

    setState(() {
      _messages = conversation;
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsManager.isDarkTheme ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: SettingsManager.isDarkTheme ? Colors.grey[900] : null,
        iconTheme: IconThemeData(
          color: SettingsManager.isDarkTheme ? Colors.white : Colors.black, // ✅ Geri butonu rengi
        ),
        title: Text(
          widget.senderName ?? widget.sender,
          style: TextStyle(
            fontFamily: SettingsManager.fontFamily,
            fontSize: SettingsManager.fontSize + 2,
            color: SettingsManager.isDarkTheme ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        controller: _scrollController,
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          final bool isMe = message.sender == "Ben" || message.recipient == widget.sender;

          return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: isMe ? SettingsManager.myMessageColor : SettingsManager.otherMessageColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.body,
                    style: TextStyle(
                      fontFamily: SettingsManager.fontFamily,
                      fontSize: SettingsManager.fontSize,
                      color: SettingsManager.textColor,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Gönderim Zamanı: ${message.date}",
                    style: TextStyle(
                      fontFamily: SettingsManager.fontFamily,
                      fontSize: SettingsManager.fontSize - 2,
                      color: SettingsManager.isDarkTheme ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

  }
}

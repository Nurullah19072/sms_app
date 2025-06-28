import 'package:flutter/material.dart';
import 'message.dart';
import 'spammessage.dart';
import 'settings_manager.dart'; // ✅ SettingsManager import


class SpamSmsScreen extends StatelessWidget {
  final List<Message> spamMessages;
  final List<Message> normalMessages;
  final Map<String, String> contactNames;
  SpamSmsScreen({required this.spamMessages, required this.normalMessages,required this.contactNames,});

  @override
  Widget build(BuildContext context) {
    // Sadece spam mesajları içeren göndericileri alıyoruz
    Map<String, List<Message>> groupedSpamMessages = {};
    for (var message in spamMessages) {
      if (!groupedSpamMessages.containsKey(message.sender)) {
        groupedSpamMessages[message.sender] = [];
      }
      groupedSpamMessages[message.sender]!.add(message);
    }

    return Scaffold(
      backgroundColor: SettingsManager.isDarkTheme ? Colors.black : Colors.white,

      body: groupedSpamMessages.isEmpty
          ? Center(child: Text("Spam mesaj bulunamadı."))
          : ListView.builder(
        itemCount: groupedSpamMessages.keys.length,
        itemBuilder: (context, index) {
          String sender = groupedSpamMessages.keys.elementAt(index);
          List<Message> spamMsgs = groupedSpamMessages[sender]!;
          String displayName = contactNames[sender] ?? sender;

          return ListTile(
            leading: Icon(Icons.warning, color: Colors.red),
            title: Text(
              displayName,
              style: TextStyle(
                fontFamily: SettingsManager.fontFamily,
                fontSize: SettingsManager.fontSize + 2,
                fontWeight: FontWeight.bold,
                color: SettingsManager.isDarkTheme ? Colors.white : Colors.black,
              ),
            ),
            subtitle: Text(
              spamMsgs.first.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: SettingsManager.fontFamily,
                fontSize: SettingsManager.fontSize - 2, // Başlıktan biraz küçük olsun
                color: SettingsManager.isDarkTheme ? Colors.white : Colors.black, // ✅ Tema uyumlu renk
              ),
            ),

            trailing: Text(
              '${spamMsgs.last.date.hour}:${spamMsgs.last.date.minute}',
              style: TextStyle(
                fontFamily: SettingsManager.fontFamily,
                fontSize: SettingsManager.fontSize - 2,
                color: SettingsManager.isDarkTheme ? Colors.white70 : Colors.grey,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SpamMessagesScreen(
                    sender: displayName,
                    messages: spamMsgs,
                  ),
                ),
              );
            },
          );
        },
      ),
    );

  }
}
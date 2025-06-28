import 'package:flutter/material.dart';
import 'message.dart';
import 'settings_manager.dart'; // ✅ SettingsManager import


class SpamMessagesScreen extends StatefulWidget {
  final String sender;
  final List<Message> messages;

  SpamMessagesScreen({required this.sender, required this.messages});

  @override
  _SpamMessagesScreenState createState() => _SpamMessagesScreenState();
}

class _SpamMessagesScreenState extends State<SpamMessagesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Mesajlar yüklendikten sonra otomatik scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.messages.sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      backgroundColor: SettingsManager.isDarkTheme ? Colors.black : Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: SettingsManager.isDarkTheme ? Colors.white : Colors.black, // ✅ Geri butonu rengi
        ),
        backgroundColor: SettingsManager.isDarkTheme ? Colors.grey[900] : null,
        title: Text(
          "Spam Mesajlar - ${widget.sender}",
          style: TextStyle(
            fontFamily: SettingsManager.fontFamily,
            fontSize: SettingsManager.fontSize + 2,
            color: SettingsManager.isDarkTheme ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: widget.messages.isEmpty
          ? Center(
        child: Text(
          "Bu numaradan spam mesaj bulunamadı.",
          style: TextStyle(
            fontFamily: SettingsManager.fontFamily,
            fontSize: SettingsManager.fontSize,
            color: SettingsManager.isDarkTheme ? Colors.white : Colors.black,
          ),
        ),
      )
          : ListView.builder(
        controller: _scrollController,
        itemCount: widget.messages.length,
        itemBuilder: (context, index) {
          final message = widget.messages[index];
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: SettingsManager.otherMessageColor,
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

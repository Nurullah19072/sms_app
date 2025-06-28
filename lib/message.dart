import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class Message {
  final String sender;
  final String recipient;
  final String body;
  final DateTime date;

  Message({
    required this.sender,
    required this.recipient,
    required this.body,
    required this.date,
  });

  factory Message.fromSms(SmsMessage sms) {
    bool isSent = sms.kind == SmsMessageKind.sent;
    final address = sms.address ?? "Bilinmeyen";

    return Message(
      sender: isSent ? address : address,
      recipient: isSent ? address : "",
      body: sms.body ?? "",
      date: sms.date ?? DateTime.now(),
    );
  }


}

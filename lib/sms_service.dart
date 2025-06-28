import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'message.dart';

class SmsService {
  final SmsQuery _query = SmsQuery();

  Future<List<Message>> getMessages() async {
    List<SmsMessage> smsList = await _query.querySms(
      kinds: [SmsQueryKind.inbox, SmsQueryKind.sent], // Gelen ve giden mesajları al
    );

    // `SmsMessage` listesini `Message` modeline dönüştür
    List<Message> messages = smsList.map((sms) => Message.fromSms(sms)).toList();
    return messages;
  }
}

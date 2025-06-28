import 'package:flutter/material.dart';
import 'sms.dart';

void main() {
  runApp(SMSApp());
}

class SMSApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SmsScreen(),
    );
  }
}

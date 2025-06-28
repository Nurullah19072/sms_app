import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // SMS okuma iznini kontrol et ve gerekiyorsa iste
  static Future<bool> checkAndRequestSmsPermission() async {
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      status = await Permission.sms.request();
    }
    return status.isGranted;
  }

  // Rehber okuma iznini kontrol et ve gerekiyorsa iste
  static Future<bool> checkAndRequestContactsPermission() async {
    var status = await Permission.contacts.status;
    if (!status.isGranted) {
      status = await Permission.contacts.request();
    }
    return status.isGranted;
  }
}

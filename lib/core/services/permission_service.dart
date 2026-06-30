import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> requestAll() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.location,
      Permission.contacts,
    ].request();
  }
}

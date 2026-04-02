import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionService {
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // Basic permissions
      await [
        Permission.location,
        Permission.nearbyWifiDevices,
      ].request();

      // Media permissions for Android 13+
      if (await Permission.photos.isDenied || await Permission.photos.isRestricted) {
        await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();
      }

      // Legacy storage for older Android
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
    } else if (Platform.isIOS) {
      await [
        Permission.photos,
        Permission.camera,
        Permission.location,
      ].request();
    }

    // Check if essential permissions are granted
    bool cameraGranted = await Permission.camera.isGranted;
    bool photosGranted = await Permission.photos.isGranted;
    
    return photosGranted && cameraGranted;
  }

  static Future<bool> checkPermission(Permission permission) async {
    return await permission.isGranted;
  }
}

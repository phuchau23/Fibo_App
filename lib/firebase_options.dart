import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// TODO: Thay thế các giá trị bên dưới bằng cấu hình thực tế sau khi chạy
/// `flutterfire configure`. Các giá trị hiện tại chỉ mang tính chất placeholder
/// để giúp dự án build được.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return web;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'FILL_ME',
    appId: 'FILL_ME',
    messagingSenderId: 'FILL_ME',
    projectId: 'FILL_ME',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'FILL_ME',
    appId: 'FILL_ME',
    messagingSenderId: 'FILL_ME',
    projectId: 'FILL_ME',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'FILL_ME',
    appId: 'FILL_ME',
    messagingSenderId: 'FILL_ME',
    projectId: 'FILL_ME',
    iosBundleId: 'com.example.swpApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'FILL_ME',
    appId: 'FILL_ME',
    messagingSenderId: 'FILL_ME',
    projectId: 'FILL_ME',
    iosBundleId: 'com.example.swpApp',
  );
}

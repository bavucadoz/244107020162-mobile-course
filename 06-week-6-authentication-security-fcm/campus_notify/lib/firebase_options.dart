// File konfigurasi Firebase otomatis berdasarkan google-services.json Anda
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB0mQ0qUuT5Rj6B_NZXp1oIkpw4oiAl8dA',
    appId: '1:980294908789:android:05cf175455b3fb9f9f13c',
    messagingSenderId: '980294908789',
    projectId: 'campus-notify-244107020162',
    storageBucket: 'campus-notify-244107020162.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB0mQ0qUuT5Rj6B_NZXp1oIkpw4oiAl8dA',
    appId: '1:980294908789:ios:05cf175455b3fb9f9f13c', 
    messagingSenderId: '980294908789',
    projectId: 'campus-notify-244107020162',
    storageBucket: 'campus-notify-244107020162.firebasestorage.app',
    iosBundleId: 'com.example.campus_notify',
  );
}
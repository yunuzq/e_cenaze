// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      // Eğer iOS, Web, macOS için de manuel ekleme yapıyorsanız buraya ekleyin
      // case TargetPlatform.iOS:
      //   return ios;
      // case TargetPlatform.web:
      //   return web;
      default:
        throw UnsupportedError(
          'Bu platform desteklenmiyor: $defaultTargetPlatform',
        );
    }
  }

  // --- SADECE ANDROID İÇİN GEREKLİ BİLGİLER ---
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBqEg37UNTqwPGt0ohpfAX-0gshkVBuLiU',
    appId: '1:773615199206:android:3cb1ab70ebb283604f2c27',
    messagingSenderId: '773615199206',
    projectId: 'e-cenaze',
    storageBucket: 'e-cenaze.firebasestorage.app',
  );

  // Eğer iOS için de manuel ekleme yapıyorsanız bu kısmı kullanın
  // static const FirebaseOptions ios = FirebaseOptions(
  //   apiKey: 'BURAYA_IOS_API_KEY_GELECEK',
  //   appId: 'BURAYA_IOS_APP_ID_GELECEK',
  //   messagingSenderId: 'BURAYA_MESSAGING_SENDER_ID_GELECEK',
  //   projectId: 'BURAYA_PROJECT_ID_GELECEK',
  //   storageBucket: 'BURAYA_STORAGE_BUCKET_GELECEK',
  //   iosClientId: 'BURAYA_IOS_CLIENT_ID_GELECEK',
  // );
}
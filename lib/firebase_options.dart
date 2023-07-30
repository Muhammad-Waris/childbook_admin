// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyArOsob5Sb9z4pZ6OIEuk7lmaQ3D85XM7c',
    appId: '1:716591238520:web:073736193c0fbaf8898c8d',
    messagingSenderId: '716591238520',
    projectId: 'childbook-d46a9',
    authDomain: 'childbook-d46a9.firebaseapp.com',
    storageBucket: 'childbook-d46a9.appspot.com',
    measurementId: 'G-Y1GB9CL16B',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCyEGu9VE_TuEQnw0baaVXMWlMhpPVOrao',
    appId: '1:716591238520:android:91771f328d2ac465898c8d',
    messagingSenderId: '716591238520',
    projectId: 'childbook-d46a9',
    storageBucket: 'childbook-d46a9.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBW337eALibTO7nah9tQiT6jb04ZhF-i6s',
    appId: '1:716591238520:ios:0efd5c633879ed77898c8d',
    messagingSenderId: '716591238520',
    projectId: 'childbook-d46a9',
    storageBucket: 'childbook-d46a9.appspot.com',
    iosBundleId: 'com.example.childbook',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBW337eALibTO7nah9tQiT6jb04ZhF-i6s',
    appId: '1:716591238520:ios:0efd5c633879ed77898c8d',
    messagingSenderId: '716591238520',
    projectId: 'childbook-d46a9',
    storageBucket: 'childbook-d46a9.appspot.com',
    iosBundleId: 'com.example.childbook',
  );
}

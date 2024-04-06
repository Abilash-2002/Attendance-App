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
    apiKey: 'AIzaSyASOHHqSl33W9hScXfCRPHXPvou537Y4Vo',
    appId: '1:305165643136:web:4bd795e01f2ec00a24a565',
    messagingSenderId: '305165643136',
    projectId: 'attendanceapp-74960',
    authDomain: 'attendanceapp-74960.firebaseapp.com',
    storageBucket: 'attendanceapp-74960.appspot.com',
    measurementId: 'G-T3RFKT3QY9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAS9jt6E_PisGsCWmGg5Pl9Idi40d3uLXQ',
    appId: '1:305165643136:android:ef8a23a39a3d989224a565',
    messagingSenderId: '305165643136',
    projectId: 'attendanceapp-74960',
    storageBucket: 'attendanceapp-74960.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBl0ODkbqlEWsQAeVK-Ee3F16ywPd7pmaA',
    appId: '1:305165643136:ios:03287aae19646c2424a565',
    messagingSenderId: '305165643136',
    projectId: 'attendanceapp-74960',
    storageBucket: 'attendanceapp-74960.appspot.com',
    iosBundleId: 'com.example.test',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBl0ODkbqlEWsQAeVK-Ee3F16ywPd7pmaA',
    appId: '1:305165643136:ios:c9a5600ef09515f824a565',
    messagingSenderId: '305165643136',
    projectId: 'attendanceapp-74960',
    storageBucket: 'attendanceapp-74960.appspot.com',
    iosBundleId: 'com.example.test.RunnerTests',
  );
}

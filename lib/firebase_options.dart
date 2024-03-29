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
      // throw UnsupportedError(
      //   'DefaultFirebaseOptions have not been configured for web - '
      //   'you can reconfigure this by running the FlutterFire CLI again.',
      // );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCZnN4Xx8wsokmuPaCLSf2u4H9YsGrk0Xw',
    appId: '1:943476532853:android:a3eaefa71940d5cac77a3c',
    messagingSenderId: '943476532853',
    projectId: 'picorix-67546',
    storageBucket: 'picorix-67546.appspot.com',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCZnN4Xx8wsokmuPaCLSf2u4H9YsGrk0Xw',
    appId: '1:943476532853:android:a3eaefa71940d5cac77a3c',
    messagingSenderId: '943476532853',
    projectId: 'picorix-67546',
    storageBucket: 'picorix-67546.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBbVWwHMGFwycw2Cw1P0LQNuYuEAic0vQM',
    appId: '1:943476532853:ios:0e95db1b8f5ab339c77a3c',
    messagingSenderId: '943476532853',
    projectId: 'picorix-67546',
    storageBucket: 'picorix-67546.appspot.com',
    androidClientId:
        '943476532853-ehket8m89dpgdhijfk8hpecbt7q96c2q.apps.googleusercontent.com',
    iosClientId:
        '943476532853-4ghqeiqotk9fbn97obcv9edpsvoiv14l.apps.googleusercontent.com',
    iosBundleId: 'com.example.picorix',
  );
}

// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyCKlhMnCMrsA8NcjR8ao4s0t5h6_EQChYA',
    appId: '1:960807885850:web:c569809eb87aca049b85a3',
    messagingSenderId: '960807885850',
    projectId: 'absensi-ce8e2',
    authDomain: 'absensi-ce8e2.firebaseapp.com',
    storageBucket: 'absensi-ce8e2.firebasestorage.app',
    measurementId: 'G-HTF7SHLD58',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD5OD4lqmJX_xh_PIzq9PbBXtTJ3dSXvnc',
    appId: '1:960807885850:android:e40b54514930c22c9b85a3',
    messagingSenderId: '960807885850',
    projectId: 'absensi-ce8e2',
    storageBucket: 'absensi-ce8e2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyADo1WQByDDkrffFidheC7tfPzUOikArtk',
    appId: '1:960807885850:ios:1e5bf3458067750e9b85a3',
    messagingSenderId: '960807885850',
    projectId: 'absensi-ce8e2',
    storageBucket: 'absensi-ce8e2.firebasestorage.app',
    iosBundleId: 'com.example.absensiApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyADo1WQByDDkrffFidheC7tfPzUOikArtk',
    appId: '1:960807885850:ios:1e5bf3458067750e9b85a3',
    messagingSenderId: '960807885850',
    projectId: 'absensi-ce8e2',
    storageBucket: 'absensi-ce8e2.firebasestorage.app',
    iosBundleId: 'com.example.absensiApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCKlhMnCMrsA8NcjR8ao4s0t5h6_EQChYA',
    appId: '1:960807885850:web:ed16c4294e898cec9b85a3',
    messagingSenderId: '960807885850',
    projectId: 'absensi-ce8e2',
    authDomain: 'absensi-ce8e2.firebaseapp.com',
    storageBucket: 'absensi-ce8e2.firebasestorage.app',
    measurementId: 'G-129HPYPHZ2',
  );
}

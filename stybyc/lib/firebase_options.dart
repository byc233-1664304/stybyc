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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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
    apiKey: 'AIzaSyANh1bjSlVKOiepzGj28QJSm0_Bb-junFw',
    appId: '1:770967406718:android:e98c1ec4d454f429e5702f',
    messagingSenderId: '770967406718',
    projectId: 'stybyc-71621',
    databaseURL: 'https://stybyc-71621-default-rtdb.firebaseio.com',
    storageBucket: 'stybyc-71621.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDZcj7HsRC0880ToP-3vcDETp5D4JfjMnQ',
    appId: '1:770967406718:ios:564465af560f423ce5702f',
    messagingSenderId: '770967406718',
    projectId: 'stybyc-71621',
    databaseURL: 'https://stybyc-71621-default-rtdb.firebaseio.com',
    storageBucket: 'stybyc-71621.appspot.com',
    iosClientId: '770967406718-6ut44f0s4gefs0sev9tvtsi47eque5n1.apps.googleusercontent.com',
    iosBundleId: 'com.example.stybyc',
  );
}
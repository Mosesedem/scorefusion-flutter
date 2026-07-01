import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Score Fusion does not support web.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_3AbZynGxLNHVQpO5zNFSNoHZW_Zfc48',
    appId: '1:728262705424:android:89945baac012856f41e595',
    messagingSenderId: '728262705424',
    projectId: 'score-fusion',
    storageBucket: 'score-fusion.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAQZAhkf559nRrS5y5kAvjMZGT87TGbTBw',
    appId: '1:728262705424:ios:29504013cf6e46a941e595',
    messagingSenderId: '728262705424',
    projectId: 'score-fusion',
    storageBucket: 'score-fusion.firebasestorage.app',
    iosBundleId: 'com.scorefusion.app',
  );
}
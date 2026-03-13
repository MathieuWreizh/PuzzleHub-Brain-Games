// ⚠️  CE FICHIER EST UN PLACEHOLDER — À REMPLACER
//
// Pour générer le vrai fichier :
//   1. Installe la CLI Firebase :   npm install -g firebase-tools
//   2. Installe FlutterFire CLI :   dart pub global activate flutterfire_cli
//   3. Connecte-toi :               firebase login
//   4. Génère la config :           flutterfire configure
//
// Cette commande créera automatiquement ce fichier avec les vraies clés
// pour Android et iOS depuis ton projet Firebase Console.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web non supporté dans cette app.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions non configuré pour : $defaultTargetPlatform',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAiI4av0GBL6I08xrVne7HBSpDs-rmpOA0',
    appId: '1:879210257795:android:9d602474bd524d23a02ab6',
    messagingSenderId: '879210257795',
    projectId: 'mon-blindtest-app',
    storageBucket: 'mon-blindtest-app.firebasestorage.app',
  );

  // ⬇️  Remplace ces valeurs par celles de ta Firebase Console

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBT8DLVbHZu3HqoAB9jT_5zLr6E_7Tu-fg',
    appId: '1:879210257795:ios:2dda1cbb76490d62a02ab6',
    messagingSenderId: '879210257795',
    projectId: 'mon-blindtest-app',
    storageBucket: 'mon-blindtest-app.firebasestorage.app',
    iosBundleId: 'com.blindtest.blindTest',
  );

}
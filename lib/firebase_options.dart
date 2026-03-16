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
    apiKey: 'AIzaSyC-N2j7Ljs2BrGRqvVb4hL7ET6JfWAOTcw',
    appId: '1:429347705603:android:b4ca408a0b012ec54a4f36',
    messagingSenderId: '429347705603',
    projectId: 'puzzlehub-brain-games',
    storageBucket: 'puzzlehub-brain-games.firebasestorage.app',
  );

  // ⬇️  Remplace ces valeurs par celles de ta Firebase Console

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBXBngrjMdhOVA3GMHUkm3b0nfYr7c3FLk',
    appId: '1:429347705603:ios:975309d540d96fdd4a4f36',
    messagingSenderId: '429347705603',
    projectId: 'puzzlehub-brain-games',
    storageBucket: 'puzzlehub-brain-games.firebasestorage.app',
    androidClientId: '429347705603-5bjbap3ii8i8brm9loeb8ifh6l8enqbm.apps.googleusercontent.com',
    iosClientId: '429347705603-uct3drutdablt3bqemo5e2lburt4v6ul.apps.googleusercontent.com',
    iosBundleId: 'com.puzzlehub.braingames',
  );

}
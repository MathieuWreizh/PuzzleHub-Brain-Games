import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'providers/locale_provider.dart';
import 'providers/settings_provider.dart';
import 'services/auth_preference_service.dart';
import 'services/consent_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  // Consentement GDPR (UMP) + ATT iOS — obligatoire avant l'init des pubs
  await ConsentService.requestConsent();

  await MobileAds.instance.initialize();

  await AuthPreferenceService.initialize();

  final savedVolume = await loadSavedVolume();
  final savedLocale = await loadSavedLocale();

  runApp(
    ProviderScope(
      overrides: [
        volumeProvider.overrideWith((ref) => VolumeNotifier(savedVolume)),
        localeProvider.overrideWith((ref) => LocaleNotifier(savedLocale)),
      ],
      child: const BlindTestApp(),
    ),
  );
}

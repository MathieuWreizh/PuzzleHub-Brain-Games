import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'providers/locale_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/sound_provider.dart';
import 'providers/visual_theme_provider.dart';
import 'services/auth_preference_service.dart';
import 'services/consent_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase : obligatoire avant tout
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  // Préférences locales : rapides, nécessaires avant runApp
  await AuthPreferenceService.initialize();
  final savedVolume = await loadSavedVolume();
  final savedLocale = await loadSavedLocale();
  final savedTheme = await loadSavedVisualTheme();
  final savedAmbiance = await loadSavedAmbiance();

  // Lance l'app immédiatement — pas de blocage sur le réseau
  runApp(
    ProviderScope(
      overrides: [
        volumeProvider.overrideWith((ref) => VolumeNotifier(savedVolume)),
        localeProvider.overrideWith((ref) => LocaleNotifier(savedLocale)),
        visualThemeProvider.overrideWith((ref) => VisualThemeNotifier(savedTheme)),
        soundAmbianceProvider.overrideWith((ref) => SoundAmbianceNotifier(savedAmbiance, ref)),
      ],
      child: const BlindTestApp(),
    ),
  );

  // Consent GDPR + ATT + init ads en arrière-plan (non bloquant)
  await ConsentService.requestConsent();
  await MobileAds.instance.initialize();
}

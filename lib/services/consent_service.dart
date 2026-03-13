import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Gère le consentement publicitaire GDPR (UMP) pour Android et iOS.
/// Le SDK UMP de google_mobile_ads gère aussi l'ATT iOS automatiquement.
class ConsentService {
  static Future<void> requestConsent() async {
    try {
      await _requestUmpConsent();
    } catch (e) {
      debugPrint('ConsentService UMP error: $e');
    }
  }

  static Future<void> _requestUmpConsent() async {
    final completer = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        // Succès : afficher le formulaire de consentement si requis
        final formCompleter = Completer<void>();
        ConsentForm.loadAndShowConsentFormIfRequired((FormError? formError) {
          if (formError != null) {
            debugPrint('Consent form error: ${formError.message}');
          }
          formCompleter.complete();
        });
        await formCompleter.future;
        completer.complete();
      },
      (FormError error) {
        // Erreur non bloquante : l'app continue sans consentement
        debugPrint('Consent info update failed: ${error.message}');
        completer.complete();
      },
    );

    return completer.future;
  }
}

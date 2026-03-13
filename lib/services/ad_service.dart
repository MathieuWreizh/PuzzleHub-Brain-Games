import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService {
  static const _kGamesCountKey = 'ad_games_count';
  static const _adFrequency = 3;

  static String get _adUnitId {
    // En debug : IDs de test Google (obligatoire pour tester localement).
    // En release : vrais IDs AdMob.
    if (kDebugMode) {
      return Platform.isIOS
          ? 'ca-app-pub-3940256099942544/4411468910'
          : 'ca-app-pub-3940256099942544/1033173712';
    }
    return Platform.isIOS
        ? 'ca-app-pub-8573525280237264/7858642128'
        : 'ca-app-pub-8573525280237264/7603491259';
  }

  // ── Pub récompensée ──────────────────────────────────────────────────────

  static String get _rewardedAdUnitId {
    if (kDebugMode) {
      return Platform.isIOS
          ? 'ca-app-pub-3940256099942544/1712485313'
          : 'ca-app-pub-3940256099942544/5224354917';
    }
    // ⚠️ IMPORTANT : remplace ces IDs par tes vrais ad units "Rewarded"
    // créés dans la console AdMob → https://apps.admob.com
    return Platform.isIOS
        ? 'ca-app-pub-8573525280237264/1050566906'
        : 'ca-app-pub-8573525280237264/9020556268';
  }

  RewardedAd? _rewardedAd;

  Future<void> loadRewardedAd() async {
    if (_rewardedAd != null) return;
    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  /// Affiche la pub récompensée. Appelle [onRewarded] si l'utilisateur a regardé,
  /// puis [onComplete] dans tous les cas.
  void showRewardedAd({
    required VoidCallback onRewarded,
    required VoidCallback onComplete,
  }) {
    if (_rewardedAd == null) {
      onComplete();
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onComplete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        onComplete();
      },
    );
    _rewardedAd!.show(onUserEarnedReward: (_, _) => onRewarded());
  }

  bool get isRewardedAdReady => _rewardedAd != null;

  // ── Interstitielle ───────────────────────────────────────────────────────

  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;

  /// Incrémente le compteur et retourne true si une pub doit être montrée.
  Future<bool> incrementAndCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_kGamesCountKey) ?? 0) + 1;
    await prefs.setInt(_kGamesCountKey, count);
    return count % _adFrequency == 0;
  }

  /// Pré-charge une interstitielle en arrière-plan.
  Future<void> loadAd() async {
    if (_isAdReady) return;
    await InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdReady = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdMob load failed: $error');
          _isAdReady = false;
        },
      ),
    );
  }

  /// Affiche la pub si prête, puis appelle [onComplete].
  /// Si la pub n'est pas prête, appelle [onComplete] immédiatement.
  void showAdIfReady({required VoidCallback onComplete}) {
    if (_isAdReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _isAdReady = false;
          onComplete();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          _isAdReady = false;
          onComplete();
        },
      );
      _interstitialAd!.show();
    } else {
      onComplete();
    }
  }
}

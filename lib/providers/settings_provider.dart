import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kVolumeKey = 'music_volume';
const _kNotifDailyKey = 'notif_daily';

/// Charge le volume sauvegardé depuis SharedPreferences.
/// À appeler dans main() avant runApp().
Future<double> loadSavedVolume() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getDouble(_kVolumeKey) ?? 1.0;
}

class VolumeNotifier extends StateNotifier<double> {
  VolumeNotifier(super.initialVolume);

  Future<void> setVolume(double v) async {
    state = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kVolumeKey, v);
  }
}

final volumeProvider = StateNotifierProvider<VolumeNotifier, double>(
  (ref) => VolumeNotifier(1.0), // sera overridé dans main()
);

// ─── Notifications ────────────────────────────────────────────────────────────

Future<bool> loadSavedNotifSettings() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kNotifDailyKey) ?? false;
}

class _BoolNotifier extends StateNotifier<bool> {
  final String key;
  _BoolNotifier(super.initial, this.key);

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, state);
  }

  Future<void> set(bool v) async {
    state = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, v);
  }
}

final notifDailyProvider = StateNotifierProvider<_BoolNotifier, bool>(
  (ref) => _BoolNotifier(false, _kNotifDailyKey),
);

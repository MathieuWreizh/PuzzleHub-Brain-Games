import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sound_ambiance.dart';
import 'settings_provider.dart';

const _kAmbianceKey = 'sound_ambiance';

Future<SoundAmbiance> loadSavedAmbiance() async {
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString(_kAmbianceKey) ?? SoundAmbianceId.none.name;
  return SoundAmbiance.byName(name);
}

class SoundAmbianceNotifier extends StateNotifier<SoundAmbiance> {
  final AudioPlayer _player = AudioPlayer();
  final Ref _ref;

  SoundAmbianceNotifier(super.initial, this._ref) {
    _ref.listen<double>(volumeProvider, (_, vol) {
      _player.setVolume(vol);
    });
    _play(initial);
  }

  Future<void> setAmbiance(SoundAmbiance ambiance) async {
    state = ambiance;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAmbianceKey, ambiance.id.name);
    await _play(ambiance);
  }

  Future<void> _play(SoundAmbiance ambiance) async {
    await _player.stop();
    if (ambiance.assetPath == null) return;
    try {
      await _player.setAsset(ambiance.assetPath!);
      await _player.setLoopMode(LoopMode.one);
      final vol = _ref.read(volumeProvider);
      await _player.setVolume(vol);
      await _player.play();
    } catch (_) {
      // fichier audio absent — silencieux
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final soundAmbianceProvider =
    StateNotifierProvider<SoundAmbianceNotifier, SoundAmbiance>(
  (ref) => SoundAmbianceNotifier(SoundAmbiance.none, ref),
);

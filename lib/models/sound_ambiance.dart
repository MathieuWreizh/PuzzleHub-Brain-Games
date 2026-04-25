enum SoundAmbianceId { none, forest, desert, beach, canyon, space }

class SoundAmbiance {
  final SoundAmbianceId id;
  final String label;
  final String emoji;
  final String? assetPath;

  const SoundAmbiance({
    required this.id,
    required this.label,
    required this.emoji,
    this.assetPath,
  });

  static const SoundAmbiance none = SoundAmbiance(
    id: SoundAmbianceId.none,
    label: 'Silence',
    emoji: '🔇',
  );

  static const SoundAmbiance forest = SoundAmbiance(
    id: SoundAmbianceId.forest,
    label: 'Forêt',
    emoji: '🌿',
    assetPath: 'assets/sounds/ambiance_forest.mp3',
  );

  static const SoundAmbiance desert = SoundAmbiance(
    id: SoundAmbianceId.desert,
    label: 'Désert',
    emoji: '🏜️',
    assetPath: 'assets/sounds/ambiance_desert.mp3',
  );

  static const SoundAmbiance beach = SoundAmbiance(
    id: SoundAmbianceId.beach,
    label: 'Plage',
    emoji: '🏖️',
    assetPath: 'assets/sounds/ambiance_beach.mp3',
  );

  static const SoundAmbiance canyon = SoundAmbiance(
    id: SoundAmbianceId.canyon,
    label: 'Canyon',
    emoji: '🏔️',
    assetPath: 'assets/sounds/ambiance_canyon.mp3',
  );

  static const SoundAmbiance space = SoundAmbiance(
    id: SoundAmbianceId.space,
    label: 'Espace',
    emoji: '🚀',
    assetPath: 'assets/sounds/ambiance_space.mp3',
  );

  static const List<SoundAmbiance> all = [
    none,
    forest,
    desert,
    beach,
    canyon,
    space,
  ];

  static SoundAmbiance byName(String name) => all.firstWhere(
        (a) => a.id.name == name,
        orElse: () => none,
      );
}

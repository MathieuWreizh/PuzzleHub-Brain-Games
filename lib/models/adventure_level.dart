/// Définit la configuration de chaque niveau en mode Aventure.
///
/// Niveaux 1–10  : Facile
/// Niveaux 11–25 : Moyen
/// Niveaux 26–40 : Difficile
/// Niveaux 41–50 : Expert
class AdventureLevel {
  final int number;       // 1–50
  final String difficulty; // 'easy' | 'medium' | 'hard' | 'expert'

  const AdventureLevel({required this.number, required this.difficulty});

  static const int total = 50;

  static AdventureLevel forNumber(int n) {
    assert(n >= 1 && n <= total);
    final diff = n <= 10
        ? 'easy'
        : n <= 25
            ? 'medium'
            : n <= 40
                ? 'hard'
                : 'expert';
    return AdventureLevel(number: n, difficulty: diff);
  }

  static List<AdventureLevel> get all =>
      List.generate(total, (i) => forNumber(i + 1));

  /// Couleur associée à la difficulté (index pour kFlowColors, ou simple code).
  static const Map<String, int> _difficultyColorCode = {
    'easy': 0xFF43A047,
    'medium': 0xFF1E88E5,
    'hard': 0xFFFB8C00,
    'expert': 0xFFE53935,
  };

  int get colorValue => _difficultyColorCode[difficulty]!;

  String get label => switch (difficulty) {
        'easy' => 'Facile',
        'medium' => 'Moyen',
        'hard' => 'Difficile',
        _ => 'Expert',
      };

  bool isNextAfter(int completedMax) => number == completedMax + 1;
}

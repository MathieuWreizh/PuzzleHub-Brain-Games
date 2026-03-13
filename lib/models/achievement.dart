/// Définition statique d'un succès (immuable).
class AchievementDef {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String category;
  final int target;

  /// Clé dans le map de stats Firestore.
  /// Valeurs possibles : 'gamesPlayed' | 'gamesWon' | 'perfectGames' | 'game_{type}'
  final String statKey;

  const AchievementDef({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.category,
    required this.target,
    required this.statKey,
  });
}

/// État d'un succès pour un joueur donné (définition + progression).
class Achievement {
  final AchievementDef def;
  final int progress;
  final bool isUnlocked;

  const Achievement({
    required this.def,
    required this.progress,
    required this.isUnlocked,
  });

  double get progressPercent =>
      (progress / def.target).clamp(0.0, 1.0).toDouble();
}

// ─── Catalogue complet des succès ────────────────────────────────────────────

class AchievementCatalog {
  static const _parties = [
    AchievementDef(
      id: 'games_10', title: 'Débutant',
      description: 'Jouer 10 parties',
      emoji: '🎯', category: 'Parties jouées', target: 10, statKey: 'gamesPlayed',
    ),
    AchievementDef(
      id: 'games_20', title: 'Habitué',
      description: 'Jouer 20 parties',
      emoji: '🧩', category: 'Parties jouées', target: 20, statKey: 'gamesPlayed',
    ),
    AchievementDef(
      id: 'games_50', title: 'Passionné',
      description: 'Jouer 50 parties',
      emoji: '🧠', category: 'Parties jouées', target: 50, statKey: 'gamesPlayed',
    ),
    AchievementDef(
      id: 'games_100', title: 'Expert',
      description: 'Jouer 100 parties',
      emoji: '🏆', category: 'Parties jouées', target: 100, statKey: 'gamesPlayed',
    ),
  ];

  static const _victoires = [
    AchievementDef(
      id: 'wins_1', title: 'Première victoire',
      description: 'Gagner 1 partie',
      emoji: '⭐', category: 'Victoires', target: 1, statKey: 'gamesWon',
    ),
    AchievementDef(
      id: 'wins_10', title: 'En forme',
      description: 'Gagner 10 parties',
      emoji: '🌟', category: 'Victoires', target: 10, statKey: 'gamesWon',
    ),
    AchievementDef(
      id: 'wins_25', title: 'Champion',
      description: 'Gagner 25 parties',
      emoji: '🥈', category: 'Victoires', target: 25, statKey: 'gamesWon',
    ),
    AchievementDef(
      id: 'wins_50', title: 'Imbattable',
      description: 'Gagner 50 parties',
      emoji: '🥇', category: 'Victoires', target: 50, statKey: 'gamesWon',
    ),
  ];

  static const _perfection = [
    AchievementDef(
      id: 'perfect_1', title: 'Parfait !',
      description: 'Terminer une partie sans la moindre erreur',
      emoji: '💎', category: 'Perfection', target: 1, statKey: 'perfectGames',
    ),
    AchievementDef(
      id: 'perfect_5', title: 'Maître des puzzles',
      description: 'Réussir 5 parties parfaites',
      emoji: '👑', category: 'Perfection', target: 5, statKey: 'perfectGames',
    ),
  ];

  static const _sudoku = [
    AchievementDef(
      id: 'sudoku_5', title: 'Chiffres en tête',
      description: 'Jouer 5 parties de Sudoku',
      emoji: '🔢', category: 'Sudoku', target: 5, statKey: 'game_sudoku',
    ),
    AchievementDef(
      id: 'sudoku_20', title: 'Sudokiste',
      description: 'Jouer 20 parties de Sudoku',
      emoji: '🧮', category: 'Sudoku', target: 20, statKey: 'game_sudoku',
    ),
    AchievementDef(
      id: 'sudoku_50', title: 'Grand Sudokiste',
      description: 'Jouer 50 parties de Sudoku',
      emoji: '🏅', category: 'Sudoku', target: 50, statKey: 'game_sudoku',
    ),
  ];

  static const _motsMeles = [
    AchievementDef(
      id: 'wordsearch_5', title: 'Chercheur de mots',
      description: 'Jouer 5 parties de Mots Mêlés',
      emoji: '🔤', category: 'Mots Mêlés', target: 5, statKey: 'game_wordsearch',
    ),
    AchievementDef(
      id: 'wordsearch_20', title: 'Chasseur de mots',
      description: 'Jouer 20 parties de Mots Mêlés',
      emoji: '🔍', category: 'Mots Mêlés', target: 20, statKey: 'game_wordsearch',
    ),
    AchievementDef(
      id: 'wordsearch_50', title: 'Détective des mots',
      description: 'Jouer 50 parties de Mots Mêlés',
      emoji: '🕵️', category: 'Mots Mêlés', target: 50, statKey: 'game_wordsearch',
    ),
  ];

  static const _flow = [
    AchievementDef(
      id: 'flow_5', title: 'Premiers pas',
      description: 'Jouer 5 parties de Flow',
      emoji: '🌊', category: 'Flow', target: 5, statKey: 'game_flow',
    ),
    AchievementDef(
      id: 'flow_20', title: 'En Flow',
      description: 'Jouer 20 parties de Flow',
      emoji: '💫', category: 'Flow', target: 20, statKey: 'game_flow',
    ),
    AchievementDef(
      id: 'flow_50', title: 'Maître du Flow',
      description: 'Jouer 50 parties de Flow',
      emoji: '🌀', category: 'Flow', target: 50, statKey: 'game_flow',
    ),
  ];

  static List<AchievementDef> get all =>
      [..._parties, ..._victoires, ..._perfection, ..._sudoku, ..._motsMeles, ..._flow];

  static final Map<String, AchievementDef> _byId = {
    for (final d in all) d.id: d,
  };

  static AchievementDef? byId(String id) => _byId[id];
}

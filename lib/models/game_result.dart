/// Résultat générique d'une partie (valable pour tous les mini-jeux).
class GameResult {
  final int totalScore;
  final int correctAnswers;
  final int totalRounds;
  final String gameMode; // ex: "Sudoku", "Facile"
  final List<bool> outcomes; // séquence vrai/faux pour calcul des bonus

  const GameResult({
    required this.totalScore,
    required this.correctAnswers,
    required this.totalRounds,
    required this.gameMode,
    this.outcomes = const [],
  });

  double get accuracy =>
      totalRounds == 0 ? 0 : correctAnswers / totalRounds;
}

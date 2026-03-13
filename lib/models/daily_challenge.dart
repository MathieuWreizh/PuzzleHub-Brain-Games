import 'dart:math';
import '../models/game_result.dart';

enum ChallengeType { playGame, accuracy, correctStreak, score }

class DailyChallenge {
  final String id;
  final ChallengeType type;

  /// Interprétation selon le type :
  ///  - playGame      : inutilisé (toujours vrai)
  ///  - accuracy      : pourcentage minimum (ex. 80 = 80 %)
  ///  - correctStreak : consécutives minimum (ex. 5)
  ///  - score         : score minimum (ex. 1000)
  ///  - playGenre     : genreId (ex. 132 = Pop)
  final int target;

  /// Récompense en crédits.
  final int creditReward;

  const DailyChallenge({
    required this.id,
    required this.type,
    required this.target,
    required this.creditReward,
  });

  // ─── Vérification ──────────────────────────────────────────────────────────

  bool isCompleted(GameResult result, int? genreId) {
    switch (type) {
      case ChallengeType.playGame:
        return true;
      case ChallengeType.accuracy:
        return (result.accuracy * 100).round() >= target;
      case ChallengeType.correctStreak:
        return _maxConsecutive(result) >= target;
      case ChallengeType.score:
        return result.totalScore >= target;
    }
  }

  static int _maxConsecutive(GameResult result) {
    int best = 0, current = 0;
    for (final correct in result.outcomes) {
      if (correct) {
        current++;
        if (current > best) best = current;
      } else {
        current = 0;
      }
    }
    return best;
  }

  // ─── Génération déterministe ───────────────────────────────────────────────

  /// 12 templates disponibles (shufflés selon le seed du jour).
  static const _templates = [
    (ChallengeType.playGame, 1, 30),
    (ChallengeType.accuracy, 70, 50),
    (ChallengeType.accuracy, 80, 80),
    (ChallengeType.accuracy, 90, 120),
    (ChallengeType.accuracy, 100, 200),
    (ChallengeType.correctStreak, 3, 50),
    (ChallengeType.correctStreak, 5, 80),
    (ChallengeType.correctStreak, 8, 120),
    (ChallengeType.score, 500, 60),
    (ChallengeType.score, 1000, 100),
    (ChallengeType.score, 2000, 150),
    (ChallengeType.score, 4000, 200),
  ];

  static List<DailyChallenge> generateForDate(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final rng = Random(seed);
    final shuffled = List.of(_templates)..shuffle(rng);
    return List.generate(3, (i) {
      final t = shuffled[i];
      return DailyChallenge(
        id: 'challenge_$i',
        type: t.$1,
        target: t.$2,
        creditReward: t.$3,
      );
    });
  }

  static List<DailyChallenge> generateForToday() =>
      generateForDate(DateTime.now());
}

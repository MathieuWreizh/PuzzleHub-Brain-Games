import 'dart:math';

/// Statistiques XP/niveau d'un joueur.
///
/// Formule de niveau :
///   XP nécessaire pour passer du niveau N au niveau N+1 = 200 * N
///   XP total cumulé pour atteindre le niveau N = 100 * N * (N−1)
///
/// Exemples :
///   L1 → L2 : 200 XP   (total 200)
///   L2 → L3 : 400 XP   (total 600)
///   L3 → L4 : 600 XP   (total 1 200)
///   L5       : total 2 000 XP  (~17 parties)
class UserStats {
  final int totalXp;
  final int level;

  /// XP accumulé depuis le début du niveau courant.
  final int currentLevelXp;

  /// XP total nécessaire pour passer au niveau suivant.
  final int xpForNextLevel;

  const UserStats({
    required this.totalXp,
    required this.level,
    required this.currentLevelXp,
    required this.xpForNextLevel,
  });

  factory UserStats.fromTotalXp(int totalXp) {
    final xp = totalXp.clamp(0, 9999999);
    final level = _levelFromXp(xp).clamp(1, 9999);
    final xpStart = _totalXpForLevel(level);
    final xpEnd = _totalXpForLevel(level + 1);
    return UserStats(
      totalXp: xp,
      level: level,
      currentLevelXp: xp - xpStart,
      xpForNextLevel: xpEnd - xpStart,
    );
  }

  /// XP cumulé nécessaire pour *atteindre* le niveau [n] (depuis 0).
  static int _totalXpForLevel(int n) {
    if (n <= 1) return 0;
    return 100 * n * (n - 1);
  }

  /// Niveau correspondant à [totalXp].
  static int _levelFromXp(int totalXp) {
    // Solve 100*N*(N-1) <= totalXp  →  N = floor((1 + sqrt(1 + 4*totalXp/100)) / 2)
    return ((1 + sqrt(1 + 4 * totalXp / 100)) / 2).floor();
  }

  /// Progression dans le niveau courant (0.0 → 1.0).
  double get progressPercent =>
      xpForNextLevel == 0 ? 1.0 : (currentLevelXp / xpForNextLevel).clamp(0.0, 1.0);
}

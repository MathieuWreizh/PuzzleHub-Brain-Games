import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/achievement.dart';
import '../models/game_result.dart';

class AchievementService {
  final FirebaseFirestore _db;

  AchievementService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  DocumentReference _userDoc(String uid) => _db.collection('users').doc(uid);

  /// Enregistre une partie, débloque les nouveaux succès et retourne leurs IDs.
  Future<List<String>> recordGame({
    required String uid,
    required GameResult result,
    String? gameType, // 'sudoku' | 'wordsearch' | 'flow'
  }) async {
    final isWin = result.accuracy >= 0.7;
    final isPerfect = result.accuracy == 1.0;

    // ── 1. Incrémenter les stats avec une map imbriquée ────────────────────
    final gameStatsUpdate = <String, dynamic>{
      'gamesPlayed': FieldValue.increment(1),
      if (isWin) 'gamesWon': FieldValue.increment(1),
      if (isPerfect) 'perfectGames': FieldValue.increment(1),
      if (gameType != null) 'games': {gameType: FieldValue.increment(1)},
    };
    await _userDoc(uid).set(
      {'gameStats': gameStatsUpdate},
      SetOptions(merge: true),
    );

    // ── 2. Lire les stats mises à jour et les succès déjà débloqués ───────
    final snap = await _userDoc(uid).get();
    final data = _toStringMap(snap.data());
    final stats = _toStringMap(data['gameStats']);
    final gameStats = _toStringMap(stats['games']);
    final unlockedSet = Set<String>.from(
      (data['achievements'] as List<dynamic>? ?? []).map((e) => e.toString()),
    );

    // ── 3. Identifier les nouveaux succès débloqués ────────────────────────
    final newlyUnlocked = <String>[];
    for (final def in AchievementCatalog.all) {
      if (unlockedSet.contains(def.id)) continue;
      if (_statFor(def.statKey, stats, gameStats) >= def.target) {
        newlyUnlocked.add(def.id);
      }
    }

    // ── 4. Sauvegarder les nouveaux succès ─────────────────────────────────
    if (newlyUnlocked.isNotEmpty) {
      await _userDoc(uid).set(
        {'achievements': FieldValue.arrayUnion(newlyUnlocked)},
        SetOptions(merge: true),
      );
    }

    return newlyUnlocked;
  }

  /// Stream temps-réel de tous les succès avec leur progression.
  Stream<List<Achievement>> watchAchievements(String uid) {
    return _userDoc(uid).snapshots().map((snap) {
      final data = _toStringMap(snap.data());
      final stats = _toStringMap(data['gameStats']);
      final gameStats = _toStringMap(stats['games']);
      final unlockedSet = Set<String>.from(
        (data['achievements'] as List<dynamic>? ?? []).map((e) => e.toString()),
      );

      return AchievementCatalog.all.map((def) {
        final progress = _statFor(def.statKey, stats, gameStats);
        return Achievement(
          def: def,
          progress: progress,
          isUnlocked: unlockedSet.contains(def.id),
        );
      }).toList();
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static Map<String, dynamic> _toStringMap(Object? value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    return Map<String, dynamic>.from(value as Map);
  }

  static int _statFor(
    String statKey,
    Map<String, dynamic> stats,
    Map<String, dynamic> gameStats,
  ) {
    if (statKey == 'gamesPlayed') {
      return (stats['gamesPlayed'] as num?)?.toInt() ?? 0;
    }
    if (statKey == 'gamesWon') {
      return (stats['gamesWon'] as num?)?.toInt() ?? 0;
    }
    if (statKey == 'perfectGames') {
      return (stats['perfectGames'] as num?)?.toInt() ?? 0;
    }
    if (statKey.startsWith('game_')) {
      final type = statKey.substring(5); // e.g. 'game_sudoku' → 'sudoku'
      return (gameStats[type] as num?)?.toInt() ?? 0;
    }
    return 0;
  }
}

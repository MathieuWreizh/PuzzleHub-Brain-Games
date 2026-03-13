import 'package:cloud_firestore/cloud_firestore.dart';

/// Coûts pour débloquer chaque difficulté (en crédits).
/// Basé sur ~15 crédits/partie en moyenne :
///   Moyen  = ~30  parties → 500 crédits
///   Difficile = ~75  parties → 1 500 crédits
///   Expert    = ~150 parties → 3 500 crédits
const Map<String, int> kDifficultyUnlockCosts = {
  'medium': 500,
  'hard': 1500,
  'expert': 3500,
};

class UnlockService {
  final FirebaseFirestore _db;
  UnlockService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  DocumentReference _userDoc(String uid) => _db.collection('users').doc(uid);

  // ── Read ──────────────────────────────────────────────────────────────────

  Stream<Set<String>> watchUnlocked(String uid, String gameId) =>
      _userDoc(uid).snapshots().map((s) {
        final d = s.data() as Map<String, dynamic>?;
        final map = d?['unlockedDifficulties'] as Map<String, dynamic>? ?? {};
        final list = (map[gameId] as List<dynamic>?)?.cast<String>() ?? [];
        return {'easy', ...list};
      });

  Future<Set<String>> getUnlocked(String uid, String gameId) async {
    final s = await _userDoc(uid).get();
    final d = s.data() as Map<String, dynamic>?;
    final map = d?['unlockedDifficulties'] as Map<String, dynamic>? ?? {};
    final list = (map[gameId] as List<dynamic>?)?.cast<String>() ?? [];
    return {'easy', ...list};
  }

  // ── Unlock ────────────────────────────────────────────────────────────────

  /// Tente de débloquer [difficulty] pour [gameId].
  /// Renvoie false si crédits insuffisants, true si succès (ou déjà débloqué).
  Future<bool> unlock(String uid, String gameId, String difficulty) async {
    final cost = kDifficultyUnlockCosts[difficulty];
    if (cost == null) return true; // 'easy' = gratuit

    bool ok = false;
    await _db.runTransaction((tx) async {
      final snap = await tx.get(_userDoc(uid));
      final d = snap.data() as Map<String, dynamic>?;

      // Check credits
      final credits = d?['totalCredits'] as int? ?? 0;
      if (credits < cost) return;

      // Check already unlocked
      final map = Map<String, dynamic>.from(
          d?['unlockedDifficulties'] as Map<String, dynamic>? ?? {});
      final list = List<String>.from(
          (map[gameId] as List<dynamic>?)?.cast<String>() ?? []);
      if (list.contains(difficulty)) {
        ok = true;
        return;
      }
      list.add(difficulty);
      map[gameId] = list;

      tx.update(_userDoc(uid), {
        'totalCredits': credits - cost,
        'unlockedDifficulties': map,
      });
      ok = true;
    });
    return ok;
  }
}

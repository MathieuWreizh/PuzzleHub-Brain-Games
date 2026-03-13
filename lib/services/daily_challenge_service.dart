import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/daily_challenge.dart';
import '../models/game_result.dart';
import 'credit_service.dart';

class DailyChallengeService {
  final FirebaseFirestore _db;

  DailyChallengeService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference _challengesCol(String uid) =>
      _db.collection('users').doc(uid).collection('dailyChallenges');

  static String _todayKey() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  // ─── Watch ────────────────────────────────────────────────────────────────

  Stream<Set<String>> watchCompletedToday(String uid) {
    return _challengesCol(uid)
        .doc(_todayKey())
        .snapshots()
        .map((snap) {
      if (!snap.exists) return <String>{};
      final d = snap.data() as Map<String, dynamic>;
      return (d['completed'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toSet();
    });
  }

  // ─── Vérification après une partie ────────────────────────────────────────

  /// Vérifie les défis et récompense les nouveaux complétés.
  /// Renvoie la liste des défis nouvellement complétés avec leur récompense.
  Future<List<(DailyChallenge, int)>> checkAndAward(
    String uid,
    GameResult result,
    int? genreId,
    CreditService creditService,
  ) async {
    final challenges = DailyChallenge.generateForToday();
    final snap = await _challengesCol(uid).doc(_todayKey()).get();
    final alreadyDone = snap.exists
        ? ((snap.data() as Map<String, dynamic>)['completed'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toSet()
        : <String>{};

    final newlyCompleted = <(DailyChallenge, int)>[];

    for (final challenge in challenges) {
      if (alreadyDone.contains(challenge.id)) continue;
      if (challenge.isCompleted(result, genreId)) {
        newlyCompleted.add((challenge, challenge.creditReward));
      }
    }

    if (newlyCompleted.isNotEmpty) {
      final ids = {...alreadyDone, ...newlyCompleted.map((p) => p.$1.id)};
      await _challengesCol(uid).doc(_todayKey()).set({'completed': ids.toList()});

      final total = newlyCompleted.fold(0, (s, p) => s + p.$2);
      await creditService.addCredits(uid, total);
    }

    return newlyCompleted;
  }
}

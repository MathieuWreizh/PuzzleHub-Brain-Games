import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_result.dart';
import '../models/user_stats.dart';

class XpService {
  final FirebaseFirestore _db;

  XpService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  DocumentReference _userDoc(String uid) => _db.collection('users').doc(uid);

  /// Calcule l'XP gagnée pour une partie.
  ///
  ///   correctAnswers × 10  +  floor(accuracy × 50)  +  floor(totalRounds/5) × 5
  static int calculateXp(GameResult result) {
    final perCorrect = result.correctAnswers * 10;
    final accuracyBonus = (result.accuracy * 50).floor();
    final roundsBonus = (result.totalRounds ~/ 5) * 5;
    return perCorrect + accuracyBonus + roundsBonus;
  }

  /// Récupère les stats actuelles depuis Firestore.
  Future<UserStats> getStats(String uid) async {
    final snap = await _userDoc(uid).get();
    if (!snap.exists) return UserStats.fromTotalXp(0);
    final data = snap.data() as Map<String, dynamic>?;
    return UserStats.fromTotalXp(data?['totalXp'] as int? ?? 0);
  }

  /// Ajoute [xp] points à l'utilisateur (opération atomique Firestore).
  Future<void> addXp(String uid, int xp) async {
    await _userDoc(uid).set(
      {'totalXp': FieldValue.increment(xp)},
      SetOptions(merge: true),
    );
  }

  /// Stream temps-réel des stats.
  Stream<UserStats> watchStats(String uid) {
    return _userDoc(uid).snapshots().map((snap) {
      if (!snap.exists) return UserStats.fromTotalXp(0);
      final data = snap.data() as Map<String, dynamic>?;
      return UserStats.fromTotalXp(data?['totalXp'] as int? ?? 0);
    });
  }
}

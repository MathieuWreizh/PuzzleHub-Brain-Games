import 'package:cloud_firestore/cloud_firestore.dart';

class AdventureService {
  final FirebaseFirestore _db;
  AdventureService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  DocumentReference _userDoc(String uid) => _db.collection('users').doc(uid);

  /// Nombre de niveaux complétés (0 = aucun, peut jouer niveau 1).
  Stream<int> watchProgress(String uid, String gameId) =>
      _userDoc(uid).snapshots().map((s) {
        final d = s.data() as Map<String, dynamic>?;
        final map = d?['adventureProgress'] as Map<String, dynamic>? ?? {};
        return map[gameId] as int? ?? 0;
      });

  Future<int> getProgress(String uid, String gameId) async {
    final s = await _userDoc(uid).get();
    final d = s.data() as Map<String, dynamic>?;
    final map = d?['adventureProgress'] as Map<String, dynamic>? ?? {};
    return map[gameId] as int? ?? 0;
  }

  /// Enregistre la complétion du niveau [levelNumber] si c'est un nouveau record.
  Future<void> completeLevel(String uid, String gameId, int levelNumber) async {
    await _db.runTransaction((tx) async {
      final snap = await tx.get(_userDoc(uid));
      final d = snap.data() as Map<String, dynamic>?;
      final map = Map<String, dynamic>.from(
          d?['adventureProgress'] as Map<String, dynamic>? ?? {});
      final current = map[gameId] as int? ?? 0;
      if (levelNumber > current) {
        map[gameId] = levelNumber;
        tx.set(_userDoc(uid), {'adventureProgress': map}, SetOptions(merge: true));
      }
    });
  }
}

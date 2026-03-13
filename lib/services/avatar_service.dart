import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/avatar.dart';

class AvatarService {
  final FirebaseFirestore _db;

  AvatarService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  DocumentReference _userDoc(String uid) => _db.collection('users').doc(uid);

  /// Lit l'avatar depuis Firestore. Retourne un avatar par défaut si absent.
  Future<Avatar> getAvatar(String uid) async {
    final snap = await _userDoc(uid).get();
    if (!snap.exists) return const Avatar();
    final data = snap.data() as Map<String, dynamic>?;
    return Avatar.fromFirestore(data?['avatar'] as Map<String, dynamic>?);
  }

  /// Sauvegarde l'avatar dans Firestore (merge pour ne pas écraser les autres champs).
  Future<void> saveAvatar(String uid, Avatar avatar) async {
    await _userDoc(uid).set(
      {'avatar': avatar.toFirestore()},
      SetOptions(merge: true),
    );
  }

  /// Stream de l'avatar — se met à jour en temps réel.
  Stream<Avatar> watchAvatar(String uid) {
    return _userDoc(uid).snapshots().map((snap) {
      if (!snap.exists) return const Avatar();
      final data = snap.data() as Map<String, dynamic>?;
      return Avatar.fromFirestore(data?['avatar'] as Map<String, dynamic>?);
    });
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/unlock_service.dart';
import 'auth_provider.dart';

final unlockServiceProvider = Provider((_) => UnlockService());

/// Retourne l'ensemble des difficultés débloquées pour un jeu donné.
/// Param : gameId ('sudoku', 'flow', 'wordsearch')
final unlockedDifficultiesProvider =
    StreamProvider.family<Set<String>, String>((ref, gameId) {
  final uid = ref.watch(currentUidProvider).valueOrNull;
  if (uid == null) return Stream.value({'easy'});
  return ref.read(unlockServiceProvider).watchUnlocked(uid, gameId);
});

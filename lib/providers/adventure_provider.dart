import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/adventure_service.dart';
import 'auth_provider.dart';

final adventureServiceProvider = Provider((_) => AdventureService());

/// Progression aventure : nombre de niveaux complétés pour un jeu donné.
/// Param : gameId ('sudoku', 'flow', 'wordsearch')
final adventureProgressProvider =
    StreamProvider.family<int, String>((ref, gameId) {
  final uid = ref.watch(currentUidProvider).valueOrNull;
  if (uid == null) return Stream.value(0);
  return ref.read(adventureServiceProvider).watchProgress(uid, gameId);
});

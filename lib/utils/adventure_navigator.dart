import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/adventure_level.dart';
import '../providers/adventure_provider.dart';
import '../providers/auth_provider.dart';

/// Sauvegarde la progression et construit le callback onReplay pour le mode aventure.
Future<Map<String, dynamic>> buildAdventureExtras({
  required WidgetRef ref,
  required GoRouter router,
  required String gameId,
  required int adventureLevel,
  required Object result,
}) async {
  // Sauvegarder la progression
  final uid = ref.read(currentUidProvider).valueOrNull;
  if (uid != null) {
    await ref
        .read(adventureServiceProvider)
        .completeLevel(uid, gameId, adventureLevel);
  }

  VoidCallback onReplay;
  if (adventureLevel < AdventureLevel.total) {
    final next = AdventureLevel.forNumber(adventureLevel + 1);
    onReplay = () => router.go(
          '/$gameId/${next.difficulty}',
          extra: {
            'adventureLevel': next.number,
            'adventureGameId': gameId,
          },
        );
  } else {
    // Dernier niveau : retour à la carte
    onReplay = () => router.go('/adventure/$gameId');
  }

  return {
    'result': result,
    'onReplay': onReplay,
    'adventureLevel': adventureLevel,
    'adventureTotal': AdventureLevel.total,
  };
}

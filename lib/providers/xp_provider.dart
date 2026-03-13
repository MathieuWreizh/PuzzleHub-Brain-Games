import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_stats.dart';
import '../services/xp_service.dart';
import 'auth_provider.dart';

final xpServiceProvider = Provider<XpService>((ref) => XpService());

/// Stream des stats XP de l'utilisateur courant (mis à jour en temps réel).
final userStatsProvider = StreamProvider<UserStats>((ref) {
  final uid = ref.watch(authStateProvider).maybeWhen(
        data: (user) => user?.uid,
        orElse: () => null,
      );
  if (uid == null) return Stream.value(UserStats.fromTotalXp(0));
  return ref.watch(xpServiceProvider).watchStats(uid);
});

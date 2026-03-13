import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';
import 'auth_provider.dart';

final achievementServiceProvider =
    Provider<AchievementService>((ref) => AchievementService());

final achievementsProvider = StreamProvider<List<Achievement>>((ref) {
  final uid = ref.watch(authStateProvider).maybeWhen(
        data: (user) => user?.uid,
        orElse: () => null,
      );
  if (uid == null) return Stream.value([]);
  return ref.watch(achievementServiceProvider).watchAchievements(uid);
});

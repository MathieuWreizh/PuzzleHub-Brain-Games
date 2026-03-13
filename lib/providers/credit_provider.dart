import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../models/daily_challenge.dart';
import '../providers/auth_provider.dart';
import '../services/credit_service.dart';
import '../services/daily_challenge_service.dart';

final creditServiceProvider =
    Provider<CreditService>((ref) => CreditService());

final dailyChallengeServiceProvider =
    Provider<DailyChallengeService>((ref) => DailyChallengeService());

/// Solde de crédits en temps réel.
final creditsProvider = StreamProvider<int>((ref) {
  final asyncUid = ref.watch(currentUidProvider);
  return asyncUid.when(
    data: (uid) => ref.read(creditServiceProvider).watchCredits(uid),
    loading: () => const Stream.empty(),
    error: (_, _) => Stream.value(0),
  );
});

/// Genres déverrouillés (free + achetés) en temps réel.
final unlockedGenresProvider = StreamProvider<Set<int>>((ref) {
  final asyncUid = ref.watch(currentUidProvider);
  return asyncUid.when(
    data: (uid) => ref.read(creditServiceProvider).watchUnlockedGenres(uid),
    loading: () => Stream.value(AppConstants.freeGenreIds.toSet()),
    error: (_, _) => Stream.value(AppConstants.freeGenreIds.toSet()),
  );
});

/// Streak quotidien en temps réel.
final streakProvider = StreamProvider<int>((ref) {
  final asyncUid = ref.watch(currentUidProvider);
  return asyncUid.when(
    data: (uid) => ref.read(creditServiceProvider).watchStreak(uid),
    loading: () => const Stream.empty(),
    error: (_, _) => Stream.value(0),
  );
});

/// Défis complétés aujourd'hui (IDs) en temps réel.
final completedChallengesTodayProvider = StreamProvider<Set<String>>((ref) {
  final asyncUid = ref.watch(currentUidProvider);
  return asyncUid.when(
    data: (uid) =>
        ref.read(dailyChallengeServiceProvider).watchCompletedToday(uid),
    loading: () => Stream.value(<String>{}),
    error: (_, _) => Stream.value(<String>{}),
  );
});

/// Défis du jour (statiques, générés une seule fois).
final dailyChallengesProvider = Provider<List<DailyChallenge>>(
  (ref) => DailyChallenge.generateForToday(),
);

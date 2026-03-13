import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../models/daily_challenge.dart';
import '../providers/credit_provider.dart';
import '../theme/app_theme.dart';

class DailyChallengesScreen extends ConsumerWidget {
  const DailyChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final challenges = ref.watch(dailyChallengesProvider);
    final completedAsync = ref.watch(completedChallengesTodayProvider);
    final creditsAsync = ref.watch(creditsProvider);
    final streakAsync = ref.watch(streakProvider);

    final completed = completedAsync.maybeWhen(data: (s) => s, orElse: () => <String>{});
    final credits = creditsAsync.maybeWhen(data: (c) => c, orElse: () => 0);
    final streak = streakAsync.maybeWhen(data: (s) => s, orElse: () => 0);
    final doneCount = challenges.where((c) => completed.contains(c.id)).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dailyChallengesTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(children: [
              const Text('💰', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text('$credits',
                  style: const TextStyle(
                      color: Color(0xFFFFB800),
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ]),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Streak ───────────────────────────────────────────────────
            if (streak > 0) _StreakBanner(streak: streak, l10n: l10n),
            if (streak > 0) const SizedBox(height: 16),

            // ── Progression ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.dailyChallengesDone(doneCount, challenges.length),
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
                Row(children: List.generate(
                  challenges.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      completed.contains(challenges[i].id)
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: completed.contains(challenges[i].id)
                          ? AppTheme.correct
                          : AppTheme.textSecondary,
                      size: 18,
                    ),
                  ),
                )),
              ],
            ),
            const SizedBox(height: 16),

            // ── Cartes défis ─────────────────────────────────────────────
            ...challenges.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ChallengeCard(
                    challenge: c,
                    isDone: completed.contains(c.id),
                    l10n: l10n,
                  ),
                )),

            const Spacer(),

            // ── Rappel horaire ───────────────────────────────────────────
            Center(
              child: Text(
                l10n.dailyChallengesEmpty,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Streak banner ────────────────────────────────────────────────────────────

class _StreakBanner extends StatelessWidget {
  final int streak;
  final AppLocalizations l10n;
  const _StreakBanner({required this.streak, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFFB800)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        const Text('🔥', style: TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.streakDays(streak),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          Text(
            streak >= 7
                ? '+60 ${l10n.creditBalance}'
                : streak >= 3
                    ? '+45 ${l10n.creditBalance}'
                    : '+30 ${l10n.creditBalance}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ]),
      ]),
    );
  }
}

// ─── Carte défi ───────────────────────────────────────────────────────────────

class _ChallengeCard extends StatelessWidget {
  final DailyChallenge challenge;
  final bool isDone;
  final AppLocalizations l10n;
  const _ChallengeCard(
      {required this.challenge, required this.isDone, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDone
            ? AppTheme.correct.withValues(alpha: 0.1)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: isDone
            ? Border.all(
                color: AppTheme.correct.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Row(children: [
        // Icône
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDone
                ? AppTheme.correct.withValues(alpha: 0.15)
                : AppTheme.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDone ? Icons.check_rounded : _typeIcon(challenge.type),
            color: isDone ? AppTheme.correct : AppTheme.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        // Description
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              _label(context),
              style: TextStyle(
                  color: isDone
                      ? AppTheme.textSecondary
                      : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  decoration: isDone ? TextDecoration.lineThrough : null),
            ),
            const SizedBox(height: 4),
            Row(children: [
              const Text('💰', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 3),
              Text('+${challenge.creditReward}',
                  style: const TextStyle(
                      color: Color(0xFFFFB800),
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ]),
          ]),
        ),
        if (isDone)
          const Icon(Icons.verified_rounded,
              color: AppTheme.correct, size: 22),
      ]),
    );
  }

  IconData _typeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.playGame:
        return Icons.play_circle_outline_rounded;
      case ChallengeType.accuracy:
        return Icons.track_changes_rounded;
      case ChallengeType.correctStreak:
        return Icons.bolt_rounded;
      case ChallengeType.score:
        return Icons.emoji_events_rounded;
    }
  }

  String _label(BuildContext context) {
    switch (challenge.type) {
      case ChallengeType.playGame:
        return l10n.challengePlayGame;
      case ChallengeType.accuracy:
        return l10n.challengeAccuracy(challenge.target);
      case ChallengeType.correctStreak:
        return l10n.challengeStreak(challenge.target);
      case ChallengeType.score:
        return l10n.challengeScore(challenge.target);
    }
  }
}

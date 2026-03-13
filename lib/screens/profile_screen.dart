import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../models/achievement.dart';
import '../models/avatar.dart';
import '../providers/achievement_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/avatar_provider.dart';
import '../providers/credit_provider.dart';
import '../providers/xp_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/xp_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(userStatsProvider).valueOrNull;
    final avatar = ref.watch(myAvatarProvider).valueOrNull;
    final displayName = ref.watch(displayNameProvider);
    final achievements = ref.watch(achievementsProvider).valueOrNull ?? [];
    final credits = ref.watch(creditsProvider).valueOrNull ?? 0;
    final streak = ref.watch(streakProvider).valueOrNull ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Carte identité ───────────────────────────────────────────
            _IdentityCard(
              avatar: avatar,
              displayName: displayName,
              stats: stats,
              credits: credits,
            ),

            const SizedBox(height: 16),

            // ── Barre XP ─────────────────────────────────────────────────
            if (stats != null) ...[
              _SectionTitle(l10n.resultXpTitle),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: XpBar(stats: stats),
              ),
              const SizedBox(height: 16),
            ],

            // ── Stats de jeu ─────────────────────────────────────────────
            _SectionTitle(l10n.profileGamesPlayed),
            const SizedBox(height: 8),
            _StatsGrid(achievements: achievements, streak: streak),

            const SizedBox(height: 16),

            // ── Succès ───────────────────────────────────────────────────
            _SectionTitle(l10n.profileAchievements),
            const SizedBox(height: 8),
            _AchievementsGrid(achievements: achievements),
          ],
        ),
      ),
    );
  }
}

// ─── Carte identité ───────────────────────────────────────────────────────────

class _IdentityCard extends StatelessWidget {
  final Avatar? avatar;
  final String displayName;
  final dynamic stats;
  final int credits;

  const _IdentityCard({
    required this.avatar,
    required this.displayName,
    required this.stats,
    required this.credits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          avatar != null
              ? AvatarWidget(avatar: avatar!, size: 64)
              : Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: Colors.white, size: 32),
                ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (stats != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Niveau ${stats.level}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('💰', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 2),
              Text(
                '$credits',
                style: const TextStyle(
                  color: Color(0xFFFFB800),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Grille de stats ──────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final List<Achievement> achievements;
  final int streak;

  const _StatsGrid({required this.achievements, required this.streak});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    int gamesPlayed = 0;
    int wins = 0;
    int perfect = 0;

    for (final a in achievements) {
      if (a.def.statKey == 'gamesPlayed') {
        gamesPlayed = a.progress.clamp(0, 999999);
        break;
      }
    }
    for (final a in achievements) {
      if (a.def.statKey == 'gamesWon') {
        wins = a.progress.clamp(0, 999999);
        break;
      }
    }
    for (final a in achievements) {
      if (a.def.statKey == 'perfectGames') {
        perfect = a.progress.clamp(0, 999999);
        break;
      }
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _StatTile(label: l10n.profileGamesPlayed, value: '$gamesPlayed', icon: Icons.sports_esports_rounded),
        _StatTile(label: l10n.profileWins, value: '$wins', icon: Icons.emoji_events_rounded),
        _StatTile(label: l10n.profilePerfect, value: '$perfect', icon: Icons.star_rounded),
        _StatTile(label: l10n.profileStreak, value: '🔥 $streak', icon: null),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const _StatTile({required this.label, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    )),
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Grille succès ────────────────────────────────────────────────────────────

class _AchievementsGrid extends StatelessWidget {
  final List<Achievement> achievements;
  const _AchievementsGrid({required this.achievements});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievements.where((a) => a.isUnlocked).toList();
    final locked = achievements.where((a) => !a.isUnlocked).toList();
    final sorted = [...unlocked, ...locked];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final a = sorted[index];
        return Tooltip(
          message: '${a.def.title}\n${a.def.description}',
          child: Container(
            decoration: BoxDecoration(
              color: a.isUnlocked
                  ? AppTheme.primary.withValues(alpha: 0.15)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: a.isUnlocked
                  ? Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.4))
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  a.def.emoji,
                  style: TextStyle(
                    fontSize: 24,
                    color: a.isUnlocked ? null : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  a.def.title,
                  style: TextStyle(
                    color: a.isUnlocked
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Titre de section ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

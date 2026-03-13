import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../models/achievement.dart';
import '../providers/achievement_provider.dart';
import '../theme/app_theme.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).achievementsTitle)),
      body: achievementsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) =>
            Center(child: Text(AppLocalizations.of(context).achievementsError(e), style: const TextStyle(color: AppTheme.textSecondary))),
        data: (achievements) => _AchievementList(achievements: achievements),
      ),
    );
  }
}

class _AchievementList extends StatelessWidget {
  final List<Achievement> achievements;
  const _AchievementList({required this.achievements});

  String _categoryName(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'Parties jouées': return l10n.catGamesPlayed;
      case 'Victoires': return l10n.catVictories;
      case 'Perfection': return l10n.catPerfection;
      case 'Genres': return l10n.catGenres;
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Grouper par catégorie en conservant l'ordre
    final Map<String, List<Achievement>> grouped = {};
    for (final a in achievements) {
      grouped.putIfAbsent(a.def.category, () => []).add(a);
    }

    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Résumé ─────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$unlockedCount / ${achievements.length}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context).achievementsUnlocked,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: achievements.isEmpty
                        ? 0
                        : unlockedCount / achievements.length,
                    minHeight: 8,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                    valueColor:
                        const AlwaysStoppedAnimation(AppTheme.primary),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Catégories ────────────────────────────────────────────────────
        for (final entry in grouped.entries) ...[
          Text(
            _categoryName(context, entry.key),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          for (final achievement in entry.value)
            _AchievementTile(achievement: achievement),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  const _AchievementTile({required this.achievement});

  String _title(BuildContext context, AchievementDef def) {
    final l10n = AppLocalizations.of(context);
    if (def.id.startsWith('genre_')) {
      final genreId = int.tryParse(def.id.split('_')[1]);
      return l10n.achTitleGenre(AppConstants.genres[genreId] ?? def.id);
    }
    switch (def.id) {
      case 'games_10': return l10n.achTitleGames10;
      case 'games_20': return l10n.achTitleGames20;
      case 'games_50': return l10n.achTitleGames50;
      case 'games_100': return l10n.achTitleGames100;
      case 'wins_1': return l10n.achTitleWins1;
      case 'wins_10': return l10n.achTitleWins10;
      case 'wins_25': return l10n.achTitleWins25;
      case 'wins_50': return l10n.achTitleWins50;
      case 'perfect_1': return l10n.achTitlePerfect1;
      case 'perfect_5': return l10n.achTitlePerfect5;
      default: return def.title;
    }
  }

  String _description(BuildContext context, AchievementDef def) {
    final l10n = AppLocalizations.of(context);
    if (def.id.startsWith('genre_')) {
      final genreId = int.tryParse(def.id.split('_')[1]);
      return l10n.achDescGenre(AppConstants.genres[genreId] ?? def.id);
    }
    switch (def.id) {
      case 'games_10': return l10n.achDescGames10;
      case 'games_20': return l10n.achDescGames20;
      case 'games_50': return l10n.achDescGames50;
      case 'games_100': return l10n.achDescGames100;
      case 'wins_1': return l10n.achDescWins1;
      case 'wins_10': return l10n.achDescWins10;
      case 'wins_25': return l10n.achDescWins25;
      case 'wins_50': return l10n.achDescWins50;
      case 'perfect_1': return l10n.achDescPerfect1;
      case 'perfect_5': return l10n.achDescPerfect5;
      default: return def.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final def = achievement.def;
    final unlocked = achievement.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked
            ? AppTheme.primary.withValues(alpha: 0.08)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: unlocked
            ? Border.all(
                color: AppTheme.primary.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Row(
        children: [
          // Emoji avec opacité si verrouillé
          Text(
            unlocked ? def.emoji : '🔒',
            style: TextStyle(
              fontSize: 26,
              color: unlocked ? null : Colors.white.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(width: 14),

          // Titre + description + barre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(context, def),
                  style: TextStyle(
                    color: unlocked
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _description(context, def),
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
                if (!unlocked) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: achievement.progressPercent,
                            minHeight: 4,
                            backgroundColor:
                                AppTheme.primary.withValues(alpha: 0.15),
                            valueColor: const AlwaysStoppedAnimation(
                                AppTheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${achievement.progress}/${def.target}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          if (unlocked)
            const Icon(Icons.check_circle_rounded,
                color: AppTheme.primary, size: 20),
        ],
      ),
    );
  }
}

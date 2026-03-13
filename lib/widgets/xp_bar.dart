import 'package:flutter/material.dart';
import '../models/user_stats.dart';
import '../theme/app_theme.dart';

/// Barre XP animée avec niveau affiché.
class XpBar extends StatelessWidget {
  final UserStats stats;

  /// Si non-null, anime depuis [fromProgress] vers [stats.progressPercent].
  final double? fromProgress;

  const XpBar({super.key, required this.stats, this.fromProgress});

  @override
  Widget build(BuildContext context) {
    final begin = fromProgress ?? stats.progressPercent;
    final end = stats.progressPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LevelBadge(level: stats.level),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: begin, end: end),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    builder: (_, progress, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                        valueColor:
                            const AlwaysStoppedAnimation(AppTheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${stats.currentLevelXp} / ${stats.xpForNextLevel} XP',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Badge "Nv. X" réutilisable (drawer, résultats…).
class _LevelBadge extends StatelessWidget {
  final int level;
  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.secondary],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Nv. $level',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Version compacte utilisée dans le drawer (juste le badge + xp total).
class LevelChip extends StatelessWidget {
  final UserStats stats;
  const LevelChip({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.secondary],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Nv. ${stats.level}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stats.progressPercent,
              minHeight: 6,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}

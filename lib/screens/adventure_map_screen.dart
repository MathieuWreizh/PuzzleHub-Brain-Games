import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/adventure_level.dart';
import '../providers/adventure_provider.dart';
import '../theme/app_theme.dart';

class AdventureMapScreen extends ConsumerWidget {
  final String gameId;
  final String gameTitle;
  final String gameEmoji;
  final Color gameColor;

  const AdventureMapScreen({
    super.key,
    required this.gameId,
    required this.gameTitle,
    required this.gameEmoji,
    required this.gameColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(adventureProgressProvider(gameId));
    final completed = progressAsync.maybeWhen(data: (p) => p, orElse: () => 0);
    final levels = AdventureLevel.all;

    // 5 niveaux par ligne, 10 lignes → snake path
    const cols = 5;
    final rows = (AdventureLevel.total / cols).ceil();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(gameEmoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              'Aventure · $gameTitle',
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$completed / ${AdventureLevel.total} niveaux',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
                _DifficultyLegend(),
              ],
            ),
          ),
          // Level map
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: rows,
              itemBuilder: (context, rowIdx) {
                final start = rowIdx * cols;
                final end = (start + cols).clamp(0, AdventureLevel.total);
                final rowLevels = levels.sublist(start, end);
                // Alternate row direction (snake)
                final isReversed = rowIdx % 2 == 1;
                final displayedLevels =
                    isReversed ? rowLevels.reversed.toList() : rowLevels;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _LevelRow(
                    levels: displayedLevels,
                    completed: completed,
                    isReversed: isReversed,
                    onTap: (level) =>
                        _playLevel(context, level, completed),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _playLevel(
      BuildContext context, AdventureLevel level, int completed) {
    if (level.number > completed + 1) return; // verrouillé
    context.push('/$gameId/${level.difficulty}',
        extra: {'adventureLevel': level.number, 'adventureGameId': gameId});
  }
}

// ── Ligne de 5 niveaux ────────────────────────────────────────────────────────

class _LevelRow extends StatelessWidget {
  final List<AdventureLevel> levels;
  final int completed;
  final bool isReversed;
  final void Function(AdventureLevel) onTap;

  const _LevelRow({
    required this.levels,
    required this.completed,
    required this.isReversed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < levels.length; i++) ...[
            _LevelNode(
              level: levels[i],
              completed: completed,
              onTap: onTap,
            ),
            if (i < levels.length - 1)
              _Connector(
                active: levels[i].number <= completed + 1 &&
                    levels[i + 1].number <= completed + 1,
                reversed: isReversed,
              ),
          ],
          // Fill empty slots if row isn't full
          for (int j = levels.length; j < 5; j++) ...[
            const SizedBox(width: 52),
            if (j < 4) const SizedBox(width: 20),
          ],
        ],
      ),
    );
  }
}

// ── Nœud de niveau ───────────────────────────────────────────────────────────

class _LevelNode extends StatelessWidget {
  final AdventureLevel level;
  final int completed;
  final void Function(AdventureLevel) onTap;

  const _LevelNode({
    required this.level,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = level.number <= completed;
    final isCurrent = level.number == completed + 1;
    final isLocked = level.number > completed + 1;

    final color = Color(level.colorValue);

    return GestureDetector(
      onTap: isLocked ? null : () => onTap(level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isLocked
              ? AppTheme.surface
              : isDone
                  ? color
                  : color.withValues(alpha: 0.2),
          border: Border.all(
            color: isLocked
                ? AppTheme.textSecondary.withValues(alpha: 0.3)
                : color,
            width: isCurrent ? 3 : 2,
          ),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Center(
          child: isLocked
              ? Icon(Icons.lock_rounded,
                  color: AppTheme.textSecondary.withValues(alpha: 0.5),
                  size: 20)
              : isDone
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 22)
                  : Text(
                      '${level.number}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
        ),
      ),
    );
  }
}

// ── Connecteur entre nœuds ───────────────────────────────────────────────────

class _Connector extends StatelessWidget {
  final bool active;
  final bool reversed;
  const _Connector({required this.active, required this.reversed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: active
              ? AppTheme.primary.withValues(alpha: 0.5)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ── Légende ───────────────────────────────────────────────────────────────────

class _DifficultyLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      (0xFF43A047, '1–10'),
      (0xFF1E88E5, '11–25'),
      (0xFFFB8C00, '26–40'),
      (0xFFE53935, '41–50'),
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: items
          .map((e) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color(e.$1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(e.$2,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 10)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

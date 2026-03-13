import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/sudoku.dart';
import '../providers/unlock_provider.dart';
import '../services/unlock_service.dart';
import '../theme/app_theme.dart';
import '../widgets/unlock_difficulty_dialog.dart';

class SudokuDifficultyScreen extends ConsumerWidget {
  const SudokuDifficultyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref
        .watch(unlockedDifficultiesProvider('sudoku'))
        .maybeWhen(data: (s) => s, orElse: () => {'easy'});

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Sudoku',
            style: TextStyle(
                color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  children: [
                    Text('🧩', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 12),
                    Text('Sudoku',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Remplis la grille 9×9',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Choisir une difficulté',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ...SudokuDifficulty.values.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DifficultyButton(
                      difficulty: d,
                      isUnlocked: unlocked.contains(d.name),
                      ref: ref,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final SudokuDifficulty difficulty;
  final bool isUnlocked;
  final WidgetRef ref;

  const _DifficultyButton({
    required this.difficulty,
    required this.isUnlocked,
    required this.ref,
  });

  Color get _color => switch (difficulty) {
        SudokuDifficulty.easy => AppTheme.correct,
        SudokuDifficulty.medium => Colors.orange,
        SudokuDifficulty.hard => Colors.deepOrange,
        SudokuDifficulty.expert => AppTheme.wrong,
      };

  Future<void> _onTap(BuildContext context) async {
    if (isUnlocked) {
      context.push('/sudoku/${difficulty.name}');
      return;
    }
    await showUnlockDialog(
      context,
      ref,
      gameId: 'sudoku',
      difficultyName: difficulty.name,
      difficultyLabel: difficulty.label,
      color: _color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final locked = !isUnlocked;
    final cost = kDifficultyUnlockCosts[difficulty.name];

    return GestureDetector(
      onTap: () => _onTap(context),
      child: Opacity(
        opacity: locked ? 0.7 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.25), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              locked
                  ? Icon(Icons.lock_rounded, color: color, size: 22)
                  : Text(
                      switch (difficulty) {
                        SudokuDifficulty.easy => '🟢',
                        SudokuDifficulty.medium => '🟡',
                        SudokuDifficulty.hard => '🟠',
                        SudokuDifficulty.expert => '🔴',
                      },
                      style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(difficulty.label,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w600)),
                    if (locked && cost != null)
                      Text('🔒 $cost crédits pour débloquer',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              locked
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Débloquer',
                          style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('+${difficulty.baseScore} pts',
                            style: TextStyle(
                                color: color,
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppTheme.textSecondary),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

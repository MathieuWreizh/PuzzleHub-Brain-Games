import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/visual_theme.dart';
import '../models/word_search.dart';
import '../providers/unlock_provider.dart';
import '../providers/visual_theme_provider.dart';
import '../services/unlock_service.dart';
import '../theme/app_theme.dart';
import '../widgets/unlock_difficulty_dialog.dart';

class WordSearchDifficultyScreen extends ConsumerWidget {
  const WordSearchDifficultyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref
        .watch(unlockedDifficultiesProvider('wordsearch'))
        .maybeWhen(data: (s) => s, orElse: () => {'easy'});
    final vt = ref.watch(visualThemeProvider);

    return Scaffold(
      backgroundColor: vt.backgroundGradient.colors.first,
      appBar: AppBar(
        backgroundColor: vt.backgroundGradient.colors.first,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: vt.textPrimary),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text('Mots Mêlés',
            style: TextStyle(color: vt.textPrimary, fontWeight: FontWeight.bold)),
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
                  gradient: vt.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  children: [
                    Text('🔤', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 12),
                    Text('Mots Mêlés',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Trouve tous les mots cachés',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Choisir une difficulté',
                style: TextStyle(
                    color: vt.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ...WordSearchDifficulty.values.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DifficultyButton(
                      difficulty: d,
                      isUnlocked: unlocked.contains(d.name),
                      ref: ref,
                      vt: vt,
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
  final WordSearchDifficulty difficulty;
  final bool isUnlocked;
  final WidgetRef ref;
  final VisualTheme vt;

  const _DifficultyButton({
    required this.difficulty,
    required this.isUnlocked,
    required this.ref,
    required this.vt,
  });

  Color get _color => switch (difficulty) {
        WordSearchDifficulty.easy => AppTheme.correct,
        WordSearchDifficulty.medium => Colors.orange,
        WordSearchDifficulty.hard => Colors.deepOrange,
        WordSearchDifficulty.expert => AppTheme.wrong,
      };

  Future<void> _onTap(BuildContext context) async {
    if (isUnlocked) {
      context.push('/wordsearch/${difficulty.name}');
      return;
    }
    await showUnlockDialog(
      context,
      ref,
      gameId: 'wordsearch',
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
                        WordSearchDifficulty.easy => '🟢',
                        WordSearchDifficulty.medium => '🟡',
                        WordSearchDifficulty.hard => '🟠',
                        WordSearchDifficulty.expert => '🔴',
                      },
                      style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(difficulty.label,
                        style: TextStyle(
                            color: vt.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w600)),
                    Text(
                      locked && cost != null
                          ? '🔒 $cost crédits pour débloquer'
                          : 'Grille ${difficulty.gridSize}×${difficulty.gridSize}',
                      style: TextStyle(
                          color: vt.textSecondary, fontSize: 12),
                    ),
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
                        Icon(Icons.chevron_right_rounded,
                            color: vt.textSecondary),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

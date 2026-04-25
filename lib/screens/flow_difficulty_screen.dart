import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/flow_puzzle.dart';
import '../models/visual_theme.dart';
import '../providers/unlock_provider.dart';
import '../providers/visual_theme_provider.dart';
import '../services/unlock_service.dart';
import '../widgets/unlock_difficulty_dialog.dart';

class FlowDifficultyScreen extends ConsumerWidget {
  const FlowDifficultyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref
        .watch(unlockedDifficultiesProvider('flow'))
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
        title: Text('Flow Puzzle',
            style: TextStyle(color: vt.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                'Relie les points de même couleur\nsans croiser les chemins.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: vt.textSecondary, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Toutes les cases doivent être remplies !',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: vt.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 40),
              ...FlowDifficulty.values.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _DifficultyCard(
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

class _DifficultyCard extends StatelessWidget {
  final FlowDifficulty difficulty;
  final bool isUnlocked;
  final WidgetRef ref;
  final VisualTheme vt;

  const _DifficultyCard({
    required this.difficulty,
    required this.isUnlocked,
    required this.ref,
    required this.vt,
  });

  static const _colors = {
    FlowDifficulty.easy: Color(0xFF43A047),
    FlowDifficulty.medium: Color(0xFF1E88E5),
    FlowDifficulty.hard: Color(0xFFFB8C00),
    FlowDifficulty.expert: Color(0xFFE53935),
  };

  Future<void> _onTap(BuildContext context) async {
    if (isUnlocked) {
      context.push('/flow/${difficulty.name}');
      return;
    }
    final cost = kDifficultyUnlockCosts[difficulty.name];
    if (cost == null) return;
    await showUnlockDialog(
      context,
      ref,
      gameId: 'flow',
      difficultyName: difficulty.name,
      difficultyLabel: difficulty.label,
      color: _colors[difficulty]!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _colors[difficulty]!;
    final size = difficulty.gridSize;
    final colors = difficulty.numColors;
    final locked = !isUnlocked;
    final cost = kDifficultyUnlockCosts[difficulty.name];

    return GestureDetector(
      onTap: () => _onTap(context),
      child: Opacity(
        opacity: locked ? 0.7 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: locked
                      ? Icon(Icons.lock_rounded, color: color, size: 22)
                      : Text(
                          '$size×$size',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(difficulty.label,
                        style: TextStyle(
                            color: vt.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 2),
                    locked
                        ? Text('$colors couleurs · 🔒 $cost crédits',
                            style: TextStyle(
                                color: vt.textSecondary, fontSize: 13))
                        : Text('$colors couleurs · ${difficulty.baseScore} pts',
                            style: TextStyle(
                                color: vt.textSecondary, fontSize: 13)),
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
                  : Icon(Icons.arrow_forward_ios_rounded,
                      color: vt.textSecondary, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

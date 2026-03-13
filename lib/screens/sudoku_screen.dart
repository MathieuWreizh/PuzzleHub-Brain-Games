import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/sudoku.dart';
import '../models/adventure_level.dart';
import '../providers/sudoku_provider.dart';
import '../providers/adventure_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class SudokuScreen extends ConsumerStatefulWidget {
  final SudokuDifficulty difficulty;
  final int? adventureLevel;
  final String? adventureGameId;
  const SudokuScreen({
    super.key,
    required this.difficulty,
    this.adventureLevel,
    this.adventureGameId,
  });

  @override
  ConsumerState<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends ConsumerState<SudokuScreen> {
  Timer? _timer;
  bool _resultNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sudokuProvider.notifier).startGame(widget.difficulty);
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(sudokuProvider.notifier).tick();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sudokuProvider);

    ref.listen(sudokuProvider, (prev, next) {
      if (prev?.status != SudokuStatus.won &&
          next.status == SudokuStatus.won &&
          next.gameResult != null &&
          !_resultNavigated) {
        _resultNavigated = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final router = GoRouter.of(context);
          final notifier = ref.read(sudokuProvider.notifier);
          final diffName = widget.difficulty.name;
          final advLevel = widget.adventureLevel;
          final gameId = widget.adventureGameId ?? 'sudoku';

          if (advLevel != null) {
            final uid = ref.read(currentUidProvider).valueOrNull;
            if (uid != null) {
              await ref
                  .read(adventureServiceProvider)
                  .completeLevel(uid, gameId, advLevel);
            }
          }

          final replayExtra = advLevel != null
              ? {'adventureLevel': advLevel, 'adventureGameId': gameId}
              : null;
          void onReplay() {
            notifier.reset();
            router.go('/sudoku/$diffName', extra: replayExtra);
          }

          VoidCallback? onNext;
          if (advLevel != null) {
            if (advLevel < AdventureLevel.total) {
              final next = AdventureLevel.forNumber(advLevel + 1);
              onNext = () {
                notifier.reset();
                router.go('/sudoku/${next.difficulty}',
                    extra: {'adventureLevel': next.number, 'adventureGameId': gameId});
              };
            } else {
              onNext = () => router.go('/adventure/$gameId');
            }
          }

          router.go('/result', extra: {
            'result': next.gameResult!,
            'onReplay': onReplay,
            'onNext': onNext,
          });
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else if (widget.adventureGameId != null) {
            context.go('/adventure/${widget.adventureGameId}');
          } else {
            context.go('/sudoku');
          }
        }),
        title: Text(
          'Sudoku · ${widget.difficulty.label}',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          if (state.status == SudokuStatus.playing) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(children: [
                const Icon(Icons.timer_outlined, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  _formatTime(state.elapsed),
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(children: [
                const Icon(Icons.close_rounded, size: 16, color: AppTheme.wrong),
                const SizedBox(width: 4),
                Text(
                  '${state.mistakes}',
                  style: const TextStyle(color: AppTheme.wrong, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ]),
            ),
          ],
        ],
      ),
      body: state.status == SudokuStatus.loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : state.status == SudokuStatus.idle
              ? const SizedBox.shrink()
              : SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _SudokuGrid(state: state),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        flex: 3,
                        child: _NumberPad(state: state),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

// ─── Grid ────────────────────────────────────────────────────────────────────

class _SudokuGrid extends ConsumerWidget {
  final SudokuState state;
  const _SudokuGrid({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.textPrimary, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: List.generate(9, (row) => Expanded(
            child: Row(
              children: List.generate(9, (col) => Expanded(
                child: _SudokuCell(
                  row: row,
                  col: col,
                  state: state,
                  onTap: () => ref.read(sudokuProvider.notifier).selectCell(row, col),
                ),
              )),
            ),
          )),
        ),
      ),
    );
  }
}

class _SudokuCell extends StatelessWidget {
  final int row, col;
  final SudokuState state;
  final VoidCallback onTap;

  const _SudokuCell({
    required this.row,
    required this.col,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final puzzle = state.puzzle!;
    final value = state.board[row][col];
    final isGiven = puzzle.isGiven(row, col);
    final isSelected = state.selectedRow == row && state.selectedCol == col;
    final selVal = state.selectedRow >= 0 && state.selectedCol >= 0
        ? state.board[state.selectedRow][state.selectedCol]
        : 0;
    final isRelated = state.selectedRow == row ||
        state.selectedCol == col ||
        ((row ~/ 3) == (state.selectedRow ~/ 3) &&
            (col ~/ 3) == (state.selectedCol ~/ 3));
    final isSameNumber = value != 0 && value == selVal;
    final cellNotes = state.notes[row][col];

    Color bgColor = AppTheme.background;
    if (isSelected) {
      bgColor = AppTheme.primary.withValues(alpha: 0.35);
    } else if (isSameNumber) {
      bgColor = AppTheme.primary.withValues(alpha: 0.20);
    } else if (isRelated && state.selectedRow >= 0) {
      bgColor = AppTheme.primary.withValues(alpha: 0.08);
    }

    Color textColor = isGiven ? AppTheme.textPrimary : AppTheme.primary;

    // Border: thick on box edges
    final borderLeft = col % 3 == 0 ? 1.5 : 0.3;
    final borderTop = row % 3 == 0 ? 1.5 : 0.3;
    final borderRight = col == 8 ? 0.0 : (col % 3 == 2 ? 1.5 : 0.3);
    final borderBottom = row == 8 ? 0.0 : (row % 3 == 2 ? 1.5 : 0.3);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            left: BorderSide(color: AppTheme.textSecondary.withValues(alpha: 0.4), width: borderLeft),
            top: BorderSide(color: AppTheme.textSecondary.withValues(alpha: 0.4), width: borderTop),
            right: BorderSide(color: AppTheme.textSecondary.withValues(alpha: 0.4), width: borderRight),
            bottom: BorderSide(color: AppTheme.textSecondary.withValues(alpha: 0.4), width: borderBottom),
          ),
        ),
        child: value != 0
            ? Center(
                child: Text(
                  '$value',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: isGiven ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              )
            : cellNotes.isEmpty
                ? null
                : _NotesGrid(notes: cellNotes),
      ),
    );
  }
}

class _NotesGrid extends StatelessWidget {
  final Set<int> notes;
  const _NotesGrid({required this.notes});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: List.generate(9, (i) {
        final n = i + 1;
        return Center(
          child: notes.contains(n)
              ? Text(
                  '$n',
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppTheme.textSecondary,
                  ),
                )
              : const SizedBox.shrink(),
        );
      }),
    );
  }
}

// ─── Number Pad ───────────────────────────────────────────────────────────────

class _NumberPad extends ConsumerWidget {
  final SudokuState state;
  const _NumberPad({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(sudokuProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          // Numbers 1-9
          Expanded(
            child: Row(
              children: List.generate(9, (i) {
                final n = i + 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: GestureDetector(
                      onTap: () => notifier.enterNumber(n),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '$n',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          // Controls row
          Row(
            children: [
              // Erase
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: GestureDetector(
                    onTap: notifier.eraseCell,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.backspace_outlined, size: 18, color: AppTheme.textSecondary),
                          SizedBox(width: 6),
                          Text('Effacer', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Notes toggle
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: GestureDetector(
                    onTap: notifier.toggleNoteMode,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: state.noteMode
                            ? AppTheme.primary.withValues(alpha: 0.2)
                            : AppTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: state.noteMode
                            ? Border.all(color: AppTheme.primary, width: 1.5)
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_outlined, size: 18,
                              color: state.noteMode ? AppTheme.primary : AppTheme.textSecondary),
                          const SizedBox(width: 6),
                          Text('Notes',
                              style: TextStyle(
                                  color: state.noteMode ? AppTheme.primary : AppTheme.textSecondary,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

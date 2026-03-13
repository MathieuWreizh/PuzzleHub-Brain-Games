import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/word_search.dart';
import '../models/adventure_level.dart';
import '../providers/word_search_provider.dart';
import '../providers/adventure_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class WordSearchScreen extends ConsumerStatefulWidget {
  final WordSearchDifficulty difficulty;
  final int? adventureLevel;
  final String? adventureGameId;
  const WordSearchScreen({
    super.key,
    required this.difficulty,
    this.adventureLevel,
    this.adventureGameId,
  });

  @override
  ConsumerState<WordSearchScreen> createState() => _WordSearchScreenState();
}

class _WordSearchScreenState extends ConsumerState<WordSearchScreen> {
  Timer? _timer;
  bool _resultNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wordSearchProvider.notifier).startGame(widget.difficulty);
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(wordSearchProvider.notifier).tick();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wordSearchProvider);

    ref.listen(wordSearchProvider, (prev, next) {
      if (prev?.status != WordSearchStatus.won &&
          next.status == WordSearchStatus.won &&
          next.gameResult != null &&
          !_resultNavigated) {
        _resultNavigated = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final router = GoRouter.of(context);
          final notifier = ref.read(wordSearchProvider.notifier);
          final diffName = widget.difficulty.name;
          final advLevel = widget.adventureLevel;
          final gameId = widget.adventureGameId ?? 'wordsearch';

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
            router.go('/wordsearch/$diffName', extra: replayExtra);
          }

          VoidCallback? onNext;
          if (advLevel != null) {
            if (advLevel < AdventureLevel.total) {
              final next = AdventureLevel.forNumber(advLevel + 1);
              onNext = () {
                notifier.reset();
                router.go('/wordsearch/${next.difficulty}',
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

    final puzzle = state.puzzle;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else if (widget.adventureGameId != null) {
            context.go('/adventure/${widget.adventureGameId}');
          } else {
            context.go('/wordsearch');
          }
        }),
        title: Text(
          puzzle != null
              ? 'Mots Mêlés · ${puzzle.theme}'
              : 'Mots Mêlés · ${widget.difficulty.label}',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          if (state.status == WordSearchStatus.playing && puzzle != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(children: [
                const Icon(Icons.check_circle_outline,
                    size: 15, color: AppTheme.correct),
                const SizedBox(width: 3),
                Text(
                  '${state.foundWords.length}/${puzzle.placedWords.length}',
                  style: const TextStyle(
                      color: AppTheme.correct,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(children: [
                const Icon(Icons.timer_outlined,
                    size: 15, color: AppTheme.textSecondary),
                const SizedBox(width: 3),
                Text(
                  _fmt(state.elapsed),
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
              ]),
            ),
          ],
        ],
      ),
      body: switch (state.status) {
        WordSearchStatus.loading || WordSearchStatus.idle => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
        _ => SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wordListH = (constraints.maxHeight * 0.25).clamp(90.0, 140.0);
                return Column(
                  children: [
                    // ── Grid ──────────────────────────────────────────────
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: _WordSearchGrid(state: state),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // ── Word list ─────────────────────────────────────────
                    SizedBox(
                      height: wordListH,
                      child: _WordList(state: state),
                    ),
                    const SizedBox(height: 4),
                  ],
                );
              },
            ),
          ),
      },
    );
  }
}

// ─── Grid ────────────────────────────────────────────────────────────────────

class _WordSearchGrid extends ConsumerStatefulWidget {
  final WordSearchState state;
  const _WordSearchGrid({required this.state});

  @override
  ConsumerState<_WordSearchGrid> createState() => _WordSearchGridState();
}

class _WordSearchGridState extends ConsumerState<_WordSearchGrid> {
  (int, int)? _startCell;
  List<(int, int)> _selection = [];
  double _gridSize = 0;

  WordSearchPuzzle get puzzle => widget.state.puzzle!;

  (int, int)? _cellAt(Offset local) {
    if (_gridSize <= 0) return null;
    final cellSize = _gridSize / puzzle.size;
    final row = (local.dy / cellSize).floor();
    final col = (local.dx / cellSize).floor();
    if (row < 0 || row >= puzzle.size || col < 0 || col >= puzzle.size) {
      return null;
    }
    return (row, col);
  }

  List<(int, int)> _line(int r1, int c1, int r2, int c2) {
    final dr = r2 - r1, dc = c2 - c1;
    if (dr == 0 && dc == 0) return [(r1, c1)];

    // Snap to nearest of 8 directions
    int stepR, stepC;
    if (dr.abs() > dc.abs() * 2) {
      stepR = dr.sign;
      stepC = 0;
    } else if (dc.abs() > dr.abs() * 2) {
      stepR = 0;
      stepC = dc.sign;
    } else {
      stepR = dr.sign;
      stepC = dc.sign;
    }

    // Steps: project vector onto snapped direction
    int steps;
    if (stepR == 0) {
      steps = (dc * stepC).clamp(0, puzzle.size - 1);
    } else if (stepC == 0) {
      steps = (dr * stepR).clamp(0, puzzle.size - 1);
    } else {
      // Diagonal: min of extents in each axis
      steps = min(
        (dr * stepR).clamp(0, puzzle.size - 1),
        (dc * stepC).clamp(0, puzzle.size - 1),
      );
    }

    final cells = <(int, int)>[];
    for (int i = 0; i <= steps; i++) {
      final r = r1 + stepR * i;
      final c = c1 + stepC * i;
      if (r < 0 || r >= puzzle.size || c < 0 || c >= puzzle.size) break;
      cells.add((r, c));
    }
    return cells;
  }

  void _onPanStart(DragStartDetails d) {
    final cell = _cellAt(d.localPosition);
    if (cell == null) return;
    setState(() {
      _startCell = cell;
      _selection = [cell];
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final start = _startCell;
    if (start == null) return;
    final cell = _cellAt(d.localPosition);
    if (cell == null) return;
    setState(() {
      _selection = _line(start.$1, start.$2, cell.$1, cell.$2);
    });
  }

  void _onPanEnd(DragEndDetails _) {
    ref.read(wordSearchProvider.notifier).submitSelection(_selection);
    setState(() {
      _startCell = null;
      _selection = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            _gridSize = constraints.maxWidth;
            final foundCells = widget.state.foundCells;
            final selSet = _selection.toSet();

            return GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppTheme.textSecondary.withValues(alpha: 0.3),
                      width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: List.generate(
                    puzzle.size,
                    (row) => Expanded(
                      child: Row(
                        children: List.generate(
                          puzzle.size,
                          (col) {
                            final isSel = selSet.contains((row, col));
                            final isFound = foundCells.contains((row, col));
                            return Expanded(
                              child: _GridCell(
                                letter: puzzle.grid[row][col],
                                isSelected: isSel,
                                isFound: isFound,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GridCell extends StatelessWidget {
  final String letter;
  final bool isSelected;
  final bool isFound;

  const _GridCell({
    required this.letter,
    required this.isSelected,
    required this.isFound,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    if (isSelected) {
      bg = AppTheme.primary.withValues(alpha: 0.45);
      fg = Colors.white;
    } else if (isFound) {
      bg = AppTheme.correct.withValues(alpha: 0.25);
      fg = AppTheme.correct;
    } else {
      bg = Colors.transparent;
      fg = AppTheme.textPrimary;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(
          color: AppTheme.textSecondary.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: Text(
              letter,
              style: TextStyle(
                color: fg,
                fontSize: 16,
                fontWeight: isFound ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Word list ────────────────────────────────────────────────────────────────

class _WordList extends StatelessWidget {
  final WordSearchState state;
  const _WordList({required this.state});

  @override
  Widget build(BuildContext context) {
    final puzzle = state.puzzle;
    if (puzzle == null) return const SizedBox.shrink();
    final words = puzzle.placedWords.map((p) => p.word).toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'MOTS À TROUVER',
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: words.map((w) {
                final found = state.foundWords.contains(w);
                return _WordChip(word: w, found: found);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final bool found;

  const _WordChip({required this.word, required this.found});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: found
            ? AppTheme.correct.withValues(alpha: 0.15)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: found
              ? AppTheme.correct.withValues(alpha: 0.5)
              : AppTheme.textSecondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        word,
        style: TextStyle(
          color: found ? AppTheme.correct : AppTheme.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          decoration: found ? TextDecoration.lineThrough : null,
          decorationColor: AppTheme.correct,
        ),
      ),
    );
  }
}

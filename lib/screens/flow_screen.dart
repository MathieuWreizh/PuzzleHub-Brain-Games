import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/flow_puzzle.dart';
import '../models/adventure_level.dart';
import '../providers/flow_provider.dart';
import '../providers/adventure_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class FlowScreen extends ConsumerStatefulWidget {
  final FlowDifficulty difficulty;
  final int? adventureLevel;
  final String? adventureGameId;
  const FlowScreen({
    super.key,
    required this.difficulty,
    this.adventureLevel,
    this.adventureGameId,
  });

  @override
  ConsumerState<FlowScreen> createState() => _FlowScreenState();
}

class _FlowScreenState extends ConsumerState<FlowScreen> {
  Timer? _timer;
  bool _resultNavigated = false;

  // ── Local drag state ──────────────────────────────────────────────────────
  int _activeColor = -1;
  List<(int, int)> _activePath = [];
  (int, int)? _lastDragCell;
  double _cellSize = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(flowProvider.notifier).startGame(widget.difficulty);
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(flowProvider.notifier).tick();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Coordinate helpers ────────────────────────────────────────────────────

  (int, int)? _cellAt(Offset local) {
    if (_cellSize <= 0) return null;
    final r = (local.dy / _cellSize).floor();
    final c = (local.dx / _cellSize).floor();
    final size = ref.read(flowProvider).puzzle?.size ?? 0;
    if (r < 0 || r >= size || c < 0 || c >= size) return null;
    return (r, c);
  }

  bool _isAdjacent((int, int) a, (int, int) b) =>
      (a.$1 - b.$1).abs() + (a.$2 - b.$2).abs() == 1;

  // ── Gesture handlers ──────────────────────────────────────────────────────

  void _onPanStart(DragStartDetails d) {
    final state = ref.read(flowProvider);
    if (state.status != FlowStatus.playing || state.puzzle == null) return;

    final cell = _cellAt(d.localPosition);
    if (cell == null) return;

    final (r, c) = cell;
    final k = state.board[r][c];
    if (k == -1) return; // must start on a colored cell (endpoint or path)

    // Capture existing path BEFORE clearing
    final existingPath = List<(int, int)>.from(state.committedPaths[k]);
    final idx = existingPath.indexWhere((p) => p.$1 == r && p.$2 == c);

    List<(int, int)> startPath;
    if (idx >= 0) {
      startPath = existingPath.sublist(0, idx + 1);
    } else {
      startPath = [(r, c)]; // fresh start from endpoint
    }

    ref.read(flowProvider.notifier).clearColorPath(k, state.puzzle!);

    setState(() {
      _activeColor = k;
      _activePath = startPath;
      _lastDragCell = cell;
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_activeColor < 0) return;

    final cell = _cellAt(d.localPosition);
    if (cell == null || cell == _lastDragCell) return;

    final (nr, nc) = cell;

    // Going backwards → truncate
    final idx = _activePath.indexWhere((p) => p.$1 == nr && p.$2 == nc);
    if (idx >= 0) {
      setState(() {
        _activePath = _activePath.sublist(0, idx + 1);
        _lastDragCell = cell;
      });
      return;
    }

    // Must be adjacent to last cell
    if (!_isAdjacent(_activePath.last, cell)) return;

    // Check board: blocked by other colors
    final board = ref.read(flowProvider).board;
    final cellColor = board[nr][nc];
    if (cellColor != -1 && cellColor != _activeColor) return;

    setState(() {
      _activePath.add(cell);
      _lastDragCell = cell;
    });
  }

  void _onPanEnd(DragEndDetails _) {
    if (_activeColor >= 0 && _activePath.isNotEmpty) {
      final state = ref.read(flowProvider);
      if (state.puzzle != null) {
        ref
            .read(flowProvider.notifier)
            .commitPath(_activeColor, _activePath, state.puzzle!);
      }
    }
    setState(() {
      _activeColor = -1;
      _activePath = [];
      _lastDragCell = null;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(flowProvider);

    ref.listen(flowProvider, (prev, next) {
      if (prev?.status != FlowStatus.won &&
          next.status == FlowStatus.won &&
          next.gameResult != null &&
          !_resultNavigated) {
        _resultNavigated = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final router = GoRouter.of(context);
          final notifier = ref.read(flowProvider.notifier);
          final diffName = widget.difficulty.name;
          final advLevel = widget.adventureLevel;
          final gameId = widget.adventureGameId ?? 'flow';

          // Sauvegarder la progression aventure
          if (advLevel != null) {
            final uid = ref.read(currentUidProvider).valueOrNull;
            if (uid != null) {
              await ref
                  .read(adventureServiceProvider)
                  .completeLevel(uid, gameId, advLevel);
            }
          }

          // onReplay = rejouer le MÊME niveau
          final replayExtra = advLevel != null
              ? {'adventureLevel': advLevel, 'adventureGameId': gameId}
              : null;
          void onReplay() {
            notifier.reset();
            router.go('/flow/$diffName', extra: replayExtra);
          }

          // onNext = niveau suivant (aventure uniquement)
          VoidCallback? onNext;
          if (advLevel != null) {
            if (advLevel < AdventureLevel.total) {
              final next = AdventureLevel.forNumber(advLevel + 1);
              onNext = () {
                notifier.reset();
                router.go('/flow/${next.difficulty}',
                    extra: {'adventureLevel': next.number, 'adventureGameId': gameId});
              };
            } else {
              // Dernier niveau : "suivant" retourne à la carte
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else if (widget.adventureGameId != null) {
              context.go('/adventure/${widget.adventureGameId}');
            } else {
              context.go('/flow');
            }
          },
        ),
        title: Text(
          state.puzzle == null
              ? 'Flow Puzzle'
              : 'Flow · ${widget.difficulty.label}',
          style: const TextStyle(
              color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _Timer(elapsed: state.elapsed),
          ),
        ],
      ),
      body: SafeArea(
        child: state.status == FlowStatus.loading || state.puzzle == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _ProgressBar(
                    solved: state.solvedColors,
                    total: state.puzzle!.numColors,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              _cellSize = constraints.maxWidth /
                                  state.puzzle!.size;
                              return GestureDetector(
                                onPanStart: _onPanStart,
                                onPanUpdate: _onPanUpdate,
                                onPanEnd: _onPanEnd,
                                child: CustomPaint(
                                  size: Size(constraints.maxWidth,
                                      constraints.maxHeight),
                                  painter: _FlowPainter(
                                    puzzle: state.puzzle!,
                                    committedPaths: state.committedPaths,
                                    activeColor: _activeColor,
                                    activePath: _activePath,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
      ),
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _FlowPainter extends CustomPainter {
  final FlowPuzzle puzzle;
  final List<List<(int, int)>> committedPaths;
  final int activeColor;
  final List<(int, int)> activePath;

  const _FlowPainter({
    required this.puzzle,
    required this.committedPaths,
    required this.activeColor,
    required this.activePath,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / puzzle.size;

    // 1. Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Offset.zero & size, const Radius.circular(12)),
      Paint()..color = AppTheme.surface,
    );

    // 2. Grid lines
    final gridPaint = Paint()
      ..color = AppTheme.border
      ..strokeWidth = 1.5;

    for (int i = 1; i < puzzle.size; i++) {
      canvas.drawLine(
          Offset(i * cellSize, 0), Offset(i * cellSize, size.height), gridPaint);
      canvas.drawLine(
          Offset(0, i * cellSize), Offset(size.width, i * cellSize), gridPaint);
    }

    // 3. Committed paths (skip activeColor — shown by activePath instead)
    for (int k = 0; k < puzzle.numColors; k++) {
      if (k == activeColor) continue;
      final path = committedPaths[k];
      if (path.length >= 2) {
        _drawPath(canvas, path, kFlowColors[k], cellSize);
      }
    }

    // 4. Active path
    if (activeColor >= 0 && activePath.length >= 2) {
      _drawPath(canvas, activePath, kFlowColors[activeColor], cellSize);
    }

    // 5. Endpoints (drawn last so they sit on top of paths)
    for (final ep in puzzle.endpoints) {
      final isSolved = activeColor != ep.colorIndex &&
          committedPaths[ep.colorIndex].isNotEmpty &&
          _isColorSolved(ep.colorIndex);
      _drawEndpoint(canvas, ep, kFlowColors[ep.colorIndex], cellSize, isSolved);
    }

    // 6. Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Offset.zero & size, const Radius.circular(12)),
      Paint()
        ..color = AppTheme.textSecondary.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  bool _isColorSolved(int k) =>
      FlowState.isColorSolved(puzzle, committedPaths, k);

  void _drawPath(Canvas canvas, List<(int, int)> path, Color color,
      double cellSize) {
    if (path.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = cellSize * 0.52
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final p = Path();
    final first = _center(path[0], cellSize);
    p.moveTo(first.dx, first.dy);
    for (int i = 1; i < path.length; i++) {
      final pt = _center(path[i], cellSize);
      p.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(p, paint);
  }

  void _drawEndpoint(Canvas canvas, FlowEndpoint ep, Color color,
      double cellSize, bool solved) {
    final center = _center((ep.row, ep.col), cellSize);
    final outerR = cellSize * 0.38;
    final innerR = cellSize * 0.16;

    // Outer filled circle
    canvas.drawCircle(center, outerR, Paint()..color = color);

    // Inner hole (shows surface underneath)
    canvas.drawCircle(
        center, innerR, Paint()..color = solved ? color : AppTheme.surface);
  }

  Offset _center((int, int) cell, double cellSize) =>
      Offset(cell.$2 * cellSize + cellSize / 2,
          cell.$1 * cellSize + cellSize / 2);

  @override
  bool shouldRepaint(_FlowPainter old) =>
      old.committedPaths != committedPaths ||
      old.activeColor != activeColor ||
      old.activePath != activePath;
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _Timer extends StatelessWidget {
  final int elapsed;
  const _Timer({required this.elapsed});

  @override
  Widget build(BuildContext context) {
    final m = elapsed ~/ 60;
    final s = elapsed % 60;
    return Text(
      '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
      style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 15,
          fontFeatures: [FontFeature.tabularFigures()]),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int solved, total;
  const _ProgressBar({required this.solved, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$solved / $total couleurs',
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13),
          ),
          if (solved == total)
            const Text('Complété !',
                style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

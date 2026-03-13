import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flow_puzzle.dart';
import '../models/game_result.dart';
import '../services/flow_generator.dart';

enum FlowStatus { idle, loading, playing, won }

// ── State ────────────────────────────────────────────────────────────────────

class FlowState {
  final FlowStatus status;
  final FlowPuzzle? puzzle;
  /// board[r][c] = colorIndex, or -1 if empty.
  /// Endpoint cells are always set to their colorIndex.
  final List<List<int>> board;
  /// Ordered path per color (empty = not drawn yet).
  final List<List<(int, int)>> committedPaths;
  final int elapsed;
  final FlowDifficulty difficulty;
  final GameResult? gameResult;

  const FlowState({
    this.status = FlowStatus.idle,
    this.puzzle,
    required this.board,
    required this.committedPaths,
    this.elapsed = 0,
    this.difficulty = FlowDifficulty.easy,
    this.gameResult,
  });

  factory FlowState.initial() => FlowState(
        board: [],
        committedPaths: [],
      );

  FlowState copyWith({
    FlowStatus? status,
    FlowPuzzle? puzzle,
    List<List<int>>? board,
    List<List<(int, int)>>? committedPaths,
    int? elapsed,
    FlowDifficulty? difficulty,
    GameResult? gameResult,
  }) =>
      FlowState(
        status: status ?? this.status,
        puzzle: puzzle ?? this.puzzle,
        board: board ?? this.board,
        committedPaths: committedPaths ?? this.committedPaths,
        elapsed: elapsed ?? this.elapsed,
        difficulty: difficulty ?? this.difficulty,
        gameResult: gameResult ?? this.gameResult,
      );

  /// Number of completed colors (both endpoints connected).
  int get solvedColors {
    final p = puzzle;
    if (p == null) return 0;
    int count = 0;
    for (int k = 0; k < p.numColors; k++) {
      if (isColorSolved(p, committedPaths, k)) count++;
    }
    return count;
  }

  static bool isColorSolved(
      FlowPuzzle puzzle, List<List<(int, int)>> paths, int k) {
    final path = paths[k];
    if (path.length < 2) return false;
    final eps = puzzle.endpointsForColor(k);
    final ep0 = (eps[0].row, eps[0].col);
    final ep1 = (eps[1].row, eps[1].col);
    return (path.first == ep0 && path.last == ep1) ||
        (path.first == ep1 && path.last == ep0);
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class FlowNotifier extends StateNotifier<FlowState> {
  FlowNotifier() : super(FlowState.initial());

  void reset() {
    state = FlowState.initial();
  }

  Future<void> startGame(FlowDifficulty difficulty) async {
    state = state.copyWith(status: FlowStatus.loading, difficulty: difficulty);
    final puzzle = await compute(generateFlowIsolate, difficulty);

    // Init board: all -1, except endpoints
    final board = List.generate(puzzle.size, (_) => List.filled(puzzle.size, -1));
    for (final ep in puzzle.endpoints) {
      board[ep.row][ep.col] = ep.colorIndex;
    }
    final paths = List.generate(puzzle.numColors, (_) => <(int, int)>[]);

    state = FlowState(
      status: FlowStatus.playing,
      puzzle: puzzle,
      board: board,
      committedPaths: paths,
      difficulty: difficulty,
    );
  }

  void tick() {
    if (state.status == FlowStatus.playing) {
      state = state.copyWith(elapsed: state.elapsed + 1);
    }
  }

  /// Called when the player starts drawing color [k].
  /// Clears all non-endpoint cells of that color from the board.
  void clearColorPath(int k, FlowPuzzle puzzle) {
    final newBoard = state.board.map((r) => List<int>.from(r)).toList();
    final epCells =
        puzzle.endpointsForColor(k).map((e) => (e.row, e.col)).toSet();

    for (int r = 0; r < puzzle.size; r++) {
      for (int c = 0; c < puzzle.size; c++) {
        if (newBoard[r][c] == k && !epCells.contains((r, c))) {
          newBoard[r][c] = -1;
        }
      }
    }

    final newPaths = state.committedPaths
        .asMap()
        .map((i, p) => MapEntry(i, i == k ? <(int, int)>[] : List<(int, int)>.from(p)))
        .values
        .toList();

    state = state.copyWith(board: newBoard, committedPaths: newPaths);
  }

  /// Called when the player lifts their finger. Commits the drawn path.
  void commitPath(int k, List<(int, int)> path, FlowPuzzle puzzle) {
    if (path.isEmpty) return;

    // Rebuild board from scratch using existing committed paths + new path
    final newBoard = List.generate(puzzle.size, (_) => List.filled(puzzle.size, -1));

    // Restore endpoints
    for (final ep in puzzle.endpoints) {
      newBoard[ep.row][ep.col] = ep.colorIndex;
    }

    // Restore all other committed paths (except k, which we're replacing)
    final newPaths = <List<(int, int)>>[];
    for (int i = 0; i < puzzle.numColors; i++) {
      if (i == k) {
        newPaths.add(List<(int, int)>.from(path));
        for (final (r, c) in path) {
          newBoard[r][c] = k;
        }
      } else {
        final existing = state.committedPaths[i];
        newPaths.add(List<(int, int)>.from(existing));
        for (final (r, c) in existing) {
          newBoard[r][c] = i;
        }
      }
    }

    // Check win
    if (_checkWin(puzzle, newBoard, newPaths)) {
      final result = _buildResult(puzzle, state.elapsed, state.difficulty);
      state = state.copyWith(
        board: newBoard,
        committedPaths: newPaths,
        status: FlowStatus.won,
        gameResult: result,
      );
    } else {
      state = state.copyWith(board: newBoard, committedPaths: newPaths);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static bool _checkWin(
    FlowPuzzle puzzle,
    List<List<int>> board,
    List<List<(int, int)>> paths,
  ) {
    for (int r = 0; r < puzzle.size; r++) {
      for (int c = 0; c < puzzle.size; c++) {
        if (board[r][c] == -1) return false;
      }
    }
    for (int k = 0; k < puzzle.numColors; k++) {
      if (!FlowState.isColorSolved(puzzle, paths, k)) return false;
    }
    return true;
  }

  static GameResult _buildResult(
      FlowPuzzle puzzle, int elapsed, FlowDifficulty difficulty) {
    final base = difficulty.baseScore;
    final timeBonus = max(0, difficulty.maxTimeBonus - elapsed * 2);
    return GameResult(
      totalScore: base + timeBonus,
      correctAnswers: puzzle.numColors,
      totalRounds: puzzle.numColors,
      gameMode: 'Flow Puzzle · ${difficulty.label}',
      outcomes: List.filled(puzzle.numColors, true),
    );
  }
}

final flowProvider =
    StateNotifierProvider<FlowNotifier, FlowState>((_) => FlowNotifier());

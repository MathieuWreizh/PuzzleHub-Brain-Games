import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_result.dart';
import '../models/word_search.dart';
import '../services/word_search_generator.dart';

enum WordSearchStatus { idle, loading, playing, won }

class WordSearchState {
  final WordSearchStatus status;
  final WordSearchPuzzle? puzzle;
  final Set<String> foundWords;
  final int elapsed;
  final WordSearchDifficulty difficulty;
  final GameResult? gameResult;

  const WordSearchState({
    this.status = WordSearchStatus.idle,
    this.puzzle,
    this.foundWords = const {},
    this.elapsed = 0,
    this.difficulty = WordSearchDifficulty.easy,
    this.gameResult,
  });

  WordSearchState copyWith({
    WordSearchStatus? status,
    WordSearchPuzzle? puzzle,
    Set<String>? foundWords,
    int? elapsed,
    WordSearchDifficulty? difficulty,
    GameResult? gameResult,
  }) =>
      WordSearchState(
        status: status ?? this.status,
        puzzle: puzzle ?? this.puzzle,
        foundWords: foundWords ?? this.foundWords,
        elapsed: elapsed ?? this.elapsed,
        difficulty: difficulty ?? this.difficulty,
        gameResult: gameResult ?? this.gameResult,
      );

  // All cells that belong to found words
  Set<(int, int)> get foundCells {
    final cells = <(int, int)>{};
    final p = puzzle;
    if (p == null) return cells;
    for (final placed in p.placedWords) {
      if (foundWords.contains(placed.word)) {
        cells.addAll(placed.cells);
      }
    }
    return cells;
  }
}

class WordSearchNotifier extends StateNotifier<WordSearchState> {
  WordSearchNotifier() : super(const WordSearchState());

  void reset() => state = const WordSearchState();

  Future<void> startGame(WordSearchDifficulty difficulty) async {
    state = state.copyWith(status: WordSearchStatus.loading, difficulty: difficulty);
    final puzzle = await compute(generateWordSearchIsolate, difficulty);
    state = WordSearchState(
      status: WordSearchStatus.playing,
      puzzle: puzzle,
      difficulty: difficulty,
    );
  }

  void tick() {
    if (state.status == WordSearchStatus.playing) {
      state = state.copyWith(elapsed: state.elapsed + 1);
    }
  }

  /// Called when user lifts finger. [cells] is the selected cell path.
  void submitSelection(List<(int, int)> cells) {
    final puzzle = state.puzzle;
    if (puzzle == null || state.status != WordSearchStatus.playing) return;
    if (cells.length < 2) return;

    for (final placed in puzzle.placedWords) {
      if (state.foundWords.contains(placed.word)) continue;

      final placedCells = placed.cells;
      if (cells.length != placedCells.length) continue;

      if (_cellsMatch(cells, placedCells) ||
          _cellsMatch(cells, placedCells.reversed.toList())) {
        _markFound(placed.word);
        return;
      }
    }
  }

  static bool _cellsMatch(List<(int, int)> a, List<(int, int)> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].$1 != b[i].$1 || a[i].$2 != b[i].$2) return false;
    }
    return true;
  }

  void _markFound(String word) {
    final newFound = Set<String>.from(state.foundWords)..add(word);
    final puzzle = state.puzzle!;
    if (newFound.length == puzzle.placedWords.length) {
      state = state.copyWith(
        foundWords: newFound,
        status: WordSearchStatus.won,
        gameResult: _buildResult(puzzle, state.elapsed, state.difficulty),
      );
    } else {
      state = state.copyWith(foundWords: newFound);
    }
  }

  static GameResult _buildResult(
    WordSearchPuzzle puzzle,
    int elapsed,
    WordSearchDifficulty difficulty,
  ) {
    final total = puzzle.placedWords.length;
    final base = difficulty.baseScore;
    final timeBonus = max(0, difficulty.maxTimeBonus - elapsed * 2);
    return GameResult(
      totalScore: base + timeBonus,
      correctAnswers: total,
      totalRounds: total,
      gameMode: 'Mots Mêlés · ${difficulty.label}',
      outcomes: List.filled(total, true),
    );
  }
}

final wordSearchProvider =
    StateNotifierProvider<WordSearchNotifier, WordSearchState>(
  (_) => WordSearchNotifier(),
);

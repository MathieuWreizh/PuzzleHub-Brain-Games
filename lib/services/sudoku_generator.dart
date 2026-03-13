import 'dart:math';
import '../models/sudoku.dart';

class SudokuGenerator {
  static final Random _rng = Random();

  static bool _isValid(List<List<int>> board, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == num || board[i][col] == num) return false;
    }
    final sr = (row ~/ 3) * 3, sc = (col ~/ 3) * 3;
    for (int r = sr; r < sr + 3; r++) {
      for (int c = sc; c < sc + 3; c++) {
        if (board[r][c] == num) return false;
      }
    }
    return true;
  }

  static bool _solve(List<List<int>> board, {bool shuffle = false}) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          final candidates = List.generate(9, (i) => i + 1);
          if (shuffle) candidates.shuffle(_rng);
          for (final num in candidates) {
            if (_isValid(board, row, col, num)) {
              board[row][col] = num;
              if (_solve(board, shuffle: shuffle)) return true;
              board[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  /// Compte les solutions jusqu'à [limit] (pour vérifier l'unicité).
  static int _countSolutions(List<List<int>> board, {int limit = 2}) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          int count = 0;
          for (int num = 1; num <= 9; num++) {
            if (_isValid(board, row, col, num)) {
              board[row][col] = num;
              count += _countSolutions(board, limit: limit - count);
              board[row][col] = 0;
              if (count >= limit) return count;
            }
          }
          return count;
        }
      }
    }
    return 1;
  }

  /// Génère un puzzle Sudoku valide avec solution unique.
  static SudokuPuzzle generate(SudokuDifficulty difficulty) {
    // 1. Grille complète via backtracking aléatoire
    final solution = List.generate(9, (_) => List.filled(9, 0));
    _solve(solution, shuffle: true);

    // 2. Copie puzzle et retrait de cases avec vérification unicité
    final puzzle = solution.map((r) => List<int>.from(r)).toList();
    final positions = List.generate(81, (i) => i)..shuffle(_rng);
    int removed = 0;

    for (final pos in positions) {
      if (removed >= difficulty.cellsToRemove) break;
      final row = pos ~/ 9, col = pos % 9;
      final backup = puzzle[row][col];
      puzzle[row][col] = 0;
      final test = puzzle.map((r) => List<int>.from(r)).toList();
      if (_countSolutions(test) == 1) {
        removed++;
      } else {
        puzzle[row][col] = backup;
      }
    }

    return SudokuPuzzle(
      solution: solution,
      givens: puzzle,
      difficulty: difficulty,
    );
  }
}

/// Top-level function pour `compute()` (isolat).
SudokuPuzzle generatePuzzleIsolate(SudokuDifficulty difficulty) =>
    SudokuGenerator.generate(difficulty);

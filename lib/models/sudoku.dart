enum SudokuDifficulty { easy, medium, hard, expert }

extension SudokuDifficultyX on SudokuDifficulty {
  String get label => switch (this) {
        SudokuDifficulty.easy => 'Facile',
        SudokuDifficulty.medium => 'Moyen',
        SudokuDifficulty.hard => 'Difficile',
        SudokuDifficulty.expert => 'Expert',
      };

  int get cellsToRemove => switch (this) {
        SudokuDifficulty.easy => 36,
        SudokuDifficulty.medium => 46,
        SudokuDifficulty.hard => 52,
        SudokuDifficulty.expert => 58,
      };

  int get baseScore => switch (this) {
        SudokuDifficulty.easy => 500,
        SudokuDifficulty.medium => 1000,
        SudokuDifficulty.hard => 2000,
        SudokuDifficulty.expert => 4000,
      };

  int get maxTimeBonus => switch (this) {
        SudokuDifficulty.easy => 500,
        SudokuDifficulty.medium => 1000,
        SudokuDifficulty.hard => 2000,
        SudokuDifficulty.expert => 4000,
      };
}

class SudokuPuzzle {
  final List<List<int>> solution;
  final List<List<int>> givens; // 0 = cell to fill
  final SudokuDifficulty difficulty;

  const SudokuPuzzle({
    required this.solution,
    required this.givens,
    required this.difficulty,
  });

  bool isGiven(int row, int col) => givens[row][col] != 0;
  int get totalEmpty => givens.fold(0, (s, row) => s + row.where((v) => v == 0).length);
}

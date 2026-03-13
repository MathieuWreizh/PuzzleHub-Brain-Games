enum WordSearchDifficulty { easy, medium, hard, expert }

extension WordSearchDifficultyX on WordSearchDifficulty {
  String get label => switch (this) {
        WordSearchDifficulty.easy => 'Facile',
        WordSearchDifficulty.medium => 'Moyen',
        WordSearchDifficulty.hard => 'Difficile',
        WordSearchDifficulty.expert => 'Expert',
      };

  int get gridSize => switch (this) {
        WordSearchDifficulty.easy => 10,
        WordSearchDifficulty.medium => 12,
        WordSearchDifficulty.hard => 14,
        WordSearchDifficulty.expert => 16,
      };

  int get baseScore => switch (this) {
        WordSearchDifficulty.easy => 500,
        WordSearchDifficulty.medium => 1000,
        WordSearchDifficulty.hard => 2000,
        WordSearchDifficulty.expert => 4000,
      };

  int get maxTimeBonus => switch (this) {
        WordSearchDifficulty.easy => 300,
        WordSearchDifficulty.medium => 600,
        WordSearchDifficulty.hard => 900,
        WordSearchDifficulty.expert => 1200,
      };
}

class PlacedWord {
  final String word;
  final int row, col;
  final int dirRow, dirCol;

  const PlacedWord({
    required this.word,
    required this.row,
    required this.col,
    required this.dirRow,
    required this.dirCol,
  });

  List<(int, int)> get cells => List.generate(
        word.length,
        (i) => (row + dirRow * i, col + dirCol * i),
      );
}

class WordSearchPuzzle {
  final List<List<String>> grid;
  final List<PlacedWord> placedWords;
  final WordSearchDifficulty difficulty;
  final String theme;

  const WordSearchPuzzle({
    required this.grid,
    required this.placedWords,
    required this.difficulty,
    required this.theme,
  });

  int get size => grid.length;
  List<String> get words => placedWords.map((w) => w.word).toList();
}

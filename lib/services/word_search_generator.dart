import 'dart:math';
import '../models/word_search.dart';

// ── Word banks ──────────────────────────────────────────────────────────────

const _themes = {
  WordSearchDifficulty.easy: [
    ('Animaux', ['CHAT', 'CHIEN', 'LAPIN', 'TIGRE', 'LION', 'AIGLE', 'LOUP', 'OURS']),
    ('Fruits', ['POMME', 'POIRE', 'RAISIN', 'CERISE', 'PECHE', 'FRAISE', 'MELON', 'CITRON']),
  ],
  WordSearchDifficulty.medium: [
    ('Sports', ['FOOTBALL', 'TENNIS', 'NATATION', 'BOXE', 'RUGBY', 'GOLF', 'SKI', 'JUDO', 'SURF', 'SPRINT']),
    ('Pays', ['FRANCE', 'ESPAGNE', 'ITALIE', 'ALLEMAGNE', 'JAPON', 'CHINE', 'BRESIL', 'MAROC', 'CANADA', 'RUSSIE']),
  ],
  WordSearchDifficulty.hard: [
    ('Métiers', ['DOCTEUR', 'PILOTE', 'POMPIER', 'AVOCAT', 'CHIMISTE', 'ARTISTE', 'SOLDAT', 'CUISINIER', 'JARDINIER', 'COIFFEUR']),
    ('Instruments', ['GUITARE', 'VIOLON', 'PIANO', 'TROMPETTE', 'BATTERIE', 'CLARINETTE', 'HARPE', 'FLUTE', 'ACCORDEON', 'SAXOPHONE']),
  ],
  WordSearchDifficulty.expert: [
    ('Sciences', ['ELECTRON', 'PROTON', 'NEUTRON', 'PLASMA', 'ENERGIE', 'PHYSIQUE', 'CHIMIE', 'BIOLOGIE', 'GALAXIE', 'COMETE', 'GRAVITE', 'ORBITE']),
    ('Philosophie', ['LOGIQUE', 'ETHIQUE', 'AXIOME', 'DIALECTIQUE', 'ONTOLOGIE', 'EMPIRISME', 'STOICISME', 'EPICURISME', 'RATIONALISME', 'POSITIVISME', 'NIHILISME', 'EXISTENTIEL']),
  ],
};

const _directions = [
  (0, 1), (0, -1), (1, 0), (-1, 0),
  (1, 1), (1, -1), (-1, 1), (-1, -1),
];

const _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

// ── Generator ──────────────────────────────────────────────────────────────

class WordSearchGenerator {
  static WordSearchPuzzle generate(WordSearchDifficulty difficulty) {
    final rng = Random();
    final size = difficulty.gridSize;
    final themeList = _themes[difficulty]!;
    final (theme, words) = themeList[rng.nextInt(themeList.length)];
    final shuffled = List<String>.from(words)..shuffle(rng);

    final grid = List.generate(size, (_) => List.filled(size, ''));
    final placedWords = <PlacedWord>[];

    for (final word in shuffled) {
      final placed = _tryPlace(grid, word, size, rng);
      if (placed != null) placedWords.add(placed);
    }

    // Fill remaining cells with random letters
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c].isEmpty) {
          grid[r][c] = _letters[rng.nextInt(_letters.length)];
        }
      }
    }

    return WordSearchPuzzle(
      grid: grid,
      placedWords: placedWords,
      difficulty: difficulty,
      theme: theme,
    );
  }

  static PlacedWord? _tryPlace(
    List<List<String>> grid,
    String word,
    int size,
    Random rng,
  ) {
    final dirs = List.of(_directions)..shuffle(rng);
    for (final (dr, dc) in dirs) {
      for (int attempt = 0; attempt < 60; attempt++) {
        final row = rng.nextInt(size);
        final col = rng.nextInt(size);
        if (_canPlace(grid, word, row, col, dr, dc, size)) {
          for (int i = 0; i < word.length; i++) {
            grid[row + dr * i][col + dc * i] = word[i];
          }
          return PlacedWord(word: word, row: row, col: col, dirRow: dr, dirCol: dc);
        }
      }
    }
    return null;
  }

  static bool _canPlace(
    List<List<String>> grid,
    String word,
    int row, int col,
    int dr, int dc,
    int size,
  ) {
    for (int i = 0; i < word.length; i++) {
      final r = row + dr * i;
      final c = col + dc * i;
      if (r < 0 || r >= size || c < 0 || c >= size) return false;
      final existing = grid[r][c];
      if (existing.isNotEmpty && existing != word[i]) return false;
    }
    return true;
  }
}

// Top-level for compute()
WordSearchPuzzle generateWordSearchIsolate(WordSearchDifficulty difficulty) =>
    WordSearchGenerator.generate(difficulty);

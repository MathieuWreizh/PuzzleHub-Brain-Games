import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_result.dart';
import '../models/sudoku.dart';
import '../services/sudoku_generator.dart';

enum SudokuStatus { idle, loading, playing, won }

class SudokuState {
  final SudokuStatus status;
  final SudokuPuzzle? puzzle;
  final List<List<int>> board;       // valeurs joueur (0 = vide)
  final List<List<bool>> errors;     // cases erronées
  final List<List<Set<int>>> notes;  // mode crayon
  final int selectedRow;
  final int selectedCol;
  final int mistakes;
  final int elapsed;   // secondes
  final bool noteMode;
  final SudokuDifficulty difficulty;
  final GameResult? gameResult;

  SudokuState({
    this.status = SudokuStatus.idle,
    this.puzzle = null,
    List<List<int>>? board,
    List<List<bool>>? errors,
    List<List<Set<int>>>? notes,
    this.selectedRow = -1,
    this.selectedCol = -1,
    this.mistakes = 0,
    this.elapsed = 0,
    this.noteMode = false,
    this.difficulty = SudokuDifficulty.easy,
    this.gameResult,
  })  : board = board ?? List.generate(9, (_) => List.filled(9, 0)),
        errors = errors ?? List.generate(9, (_) => List.filled(9, false)),
        notes = notes ??
            List.generate(9, (_) => List.generate(9, (_) => <int>{}));

  SudokuState copyWith({
    SudokuStatus? status,
    SudokuPuzzle? puzzle,
    List<List<int>>? board,
    List<List<bool>>? errors,
    List<List<Set<int>>>? notes,
    int? selectedRow,
    int? selectedCol,
    int? mistakes,
    int? elapsed,
    bool? noteMode,
    SudokuDifficulty? difficulty,
    GameResult? gameResult,
  }) =>
      SudokuState(
        status: status ?? this.status,
        puzzle: puzzle ?? this.puzzle,
        board: board ?? this.board,
        errors: errors ?? this.errors,
        notes: notes ?? this.notes,
        selectedRow: selectedRow ?? this.selectedRow,
        selectedCol: selectedCol ?? this.selectedCol,
        mistakes: mistakes ?? this.mistakes,
        elapsed: elapsed ?? this.elapsed,
        noteMode: noteMode ?? this.noteMode,
        difficulty: difficulty ?? this.difficulty,
        gameResult: gameResult ?? this.gameResult,
      );
}

class SudokuNotifier extends StateNotifier<SudokuState> {
  SudokuNotifier() : super(SudokuState());

  void reset() => state = SudokuState();

  Future<void> startGame(SudokuDifficulty difficulty) async {
    state = state.copyWith(
      status: SudokuStatus.loading,
      difficulty: difficulty,
    );
    final puzzle = await compute(generatePuzzleIsolate, difficulty);
    final board = puzzle.givens.map((r) => List<int>.from(r)).toList();
    state = SudokuState(
      status: SudokuStatus.playing,
      puzzle: puzzle,
      board: board,
      difficulty: difficulty,
    );
  }

  void selectCell(int row, int col) {
    if (state.status != SudokuStatus.playing) return;
    state = state.copyWith(selectedRow: row, selectedCol: col);
  }

  void toggleNoteMode() {
    state = state.copyWith(noteMode: !state.noteMode);
  }

  void tick() {
    if (state.status == SudokuStatus.playing) {
      state = state.copyWith(elapsed: state.elapsed + 1);
    }
  }

  void enterNumber(int num) {
    final puzzle = state.puzzle;
    if (puzzle == null || state.status != SudokuStatus.playing) return;
    final r = state.selectedRow, c = state.selectedCol;
    if (r < 0 || c < 0) return;
    if (puzzle.isGiven(r, c)) return;

    if (state.noteMode) {
      final newNotes = state.notes.map((row) => row.map((s) => Set<int>.from(s)).toList()).toList();
      if (newNotes[r][c].contains(num)) {
        newNotes[r][c].remove(num);
      } else {
        newNotes[r][c].add(num);
      }
      state = state.copyWith(notes: newNotes);
      return;
    }

    final newBoard = state.board.map((row) => List<int>.from(row)).toList();
    final newErrors = state.errors.map((row) => List<bool>.from(row)).toList();
    final newNotes = state.notes.map((row) => row.map((s) => Set<int>.from(s)).toList()).toList();

    newBoard[r][c] = num;
    newNotes[r][c].clear();
    final isCorrect = puzzle.solution[r][c] == num;
    newErrors[r][c] = !isCorrect;

    int newMistakes = state.mistakes;
    if (!isCorrect) newMistakes++;

    // Vérifier victoire
    bool won = _checkWin(newBoard, puzzle);

    if (won) {
      final result = _buildResult(puzzle, state.elapsed, state.mistakes, state.difficulty);
      state = state.copyWith(
        board: newBoard,
        errors: newErrors,
        notes: newNotes,
        mistakes: newMistakes,
        status: SudokuStatus.won,
        gameResult: result,
      );
    } else {
      state = state.copyWith(
        board: newBoard,
        errors: newErrors,
        notes: newNotes,
        mistakes: newMistakes,
      );
    }
  }

  void eraseCell() {
    final puzzle = state.puzzle;
    if (puzzle == null || state.status != SudokuStatus.playing) return;
    final r = state.selectedRow, c = state.selectedCol;
    if (r < 0 || c < 0 || puzzle.isGiven(r, c)) return;

    final newBoard = state.board.map((row) => List<int>.from(row)).toList();
    final newErrors = state.errors.map((row) => List<bool>.from(row)).toList();
    final newNotes = state.notes.map((row) => row.map((s) => Set<int>.from(s)).toList()).toList();
    newBoard[r][c] = 0;
    newErrors[r][c] = false;
    newNotes[r][c].clear();
    state = state.copyWith(board: newBoard, errors: newErrors, notes: newNotes);
  }

  static bool _checkWin(List<List<int>> board, SudokuPuzzle puzzle) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] != puzzle.solution[r][c]) return false;
      }
    }
    return true;
  }

  static GameResult _buildResult(
    SudokuPuzzle puzzle,
    int elapsed,
    int mistakes,
    SudokuDifficulty difficulty,
  ) {
    final base = difficulty.baseScore;
    final timeBonus = max(0, difficulty.maxTimeBonus - elapsed * 2);
    final perfectBonus = mistakes == 0 ? (base ~/ 2) : 0;
    final totalScore = base + timeBonus + perfectBonus;
    final totalCells = puzzle.totalEmpty;

    return GameResult(
      totalScore: totalScore,
      correctAnswers: totalCells - mistakes,
      totalRounds: totalCells,
      gameMode: 'Sudoku · ${difficulty.label}',
    );
  }
}

final sudokuProvider =
    StateNotifierProvider<SudokuNotifier, SudokuState>((_) => SudokuNotifier());

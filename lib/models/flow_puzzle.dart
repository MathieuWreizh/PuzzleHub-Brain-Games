import 'package:flutter/material.dart';

// ── Color palette (up to 9 colors) ──────────────────────────────────────────

const kFlowColors = [
  Color(0xFFE53935), // 0 Red
  Color(0xFF1E88E5), // 1 Blue
  Color(0xFF43A047), // 2 Green
  Color(0xFFFDD835), // 3 Yellow
  Color(0xFFFB8C00), // 4 Orange
  Color(0xFF8E24AA), // 5 Purple
  Color(0xFF00ACC1), // 6 Teal
  Color(0xFFE91E63), // 7 Pink
  Color(0xFF795548), // 8 Brown
];

// ── Difficulty ───────────────────────────────────────────────────────────────

enum FlowDifficulty { easy, medium, hard, expert }

extension FlowDifficultyX on FlowDifficulty {
  String get label => switch (this) {
        FlowDifficulty.easy => 'Facile',
        FlowDifficulty.medium => 'Moyen',
        FlowDifficulty.hard => 'Difficile',
        FlowDifficulty.expert => 'Expert',
      };

  int get gridSize => switch (this) {
        FlowDifficulty.easy => 5,
        FlowDifficulty.medium => 6,
        FlowDifficulty.hard => 8,
        FlowDifficulty.expert => 9,
      };

  int get numColors => switch (this) {
        FlowDifficulty.easy => 4,
        FlowDifficulty.medium => 5,
        FlowDifficulty.hard => 7,
        FlowDifficulty.expert => 9,
      };

  int get baseScore => switch (this) {
        FlowDifficulty.easy => 500,
        FlowDifficulty.medium => 1000,
        FlowDifficulty.hard => 2000,
        FlowDifficulty.expert => 4000,
      };

  int get maxTimeBonus => switch (this) {
        FlowDifficulty.easy => 300,
        FlowDifficulty.medium => 600,
        FlowDifficulty.hard => 900,
        FlowDifficulty.expert => 1200,
      };
}

// ── Model ────────────────────────────────────────────────────────────────────

class FlowEndpoint {
  final int row, col, colorIndex;
  const FlowEndpoint({
    required this.row,
    required this.col,
    required this.colorIndex,
  });
}

class FlowPuzzle {
  final int size;
  final int numColors;
  final List<FlowEndpoint> endpoints; // exactly 2 per color
  final FlowDifficulty difficulty;

  const FlowPuzzle({
    required this.size,
    required this.numColors,
    required this.endpoints,
    required this.difficulty,
  });

  bool isEndpoint(int r, int c) =>
      endpoints.any((e) => e.row == r && e.col == c);

  int endpointColor(int r, int c) {
    for (final e in endpoints) {
      if (e.row == r && e.col == c) return e.colorIndex;
    }
    return -1;
  }

  List<FlowEndpoint> endpointsForColor(int k) =>
      endpoints.where((e) => e.colorIndex == k).toList();
}

import 'dart:math';
import '../models/flow_puzzle.dart';

// ── Generator ────────────────────────────────────────────────────────────────

class FlowGenerator {
  /// Generates a solvable Flow puzzle using Warnsdorff Hamiltonian path + split.
  static FlowPuzzle generate(FlowDifficulty difficulty) {
    final rng = Random();
    for (int attempt = 0; attempt < 30; attempt++) {
      final puzzle = _tryGenerate(difficulty, rng);
      if (puzzle != null) return puzzle;
    }
    throw StateError('FlowGenerator: failed after 30 attempts');
  }

  static FlowPuzzle? _tryGenerate(FlowDifficulty difficulty, Random rng) {
    final size = difficulty.gridSize;
    final K = difficulty.numColors;

    // 1. Build a Hamiltonian path through all cells (Warnsdorff heuristic)
    final path = _hamiltonianPath(size, rng);
    if (path == null || path.length < size * size) return null;

    // 2. Split path into K segments of roughly equal length
    final segments = _split(path, K, rng);
    if (segments == null) return null;

    // 3. Build endpoint list
    final endpoints = <FlowEndpoint>[];
    for (int k = 0; k < K; k++) {
      final seg = segments[k];
      endpoints.add(FlowEndpoint(row: seg.first.$1, col: seg.first.$2, colorIndex: k));
      endpoints.add(FlowEndpoint(row: seg.last.$1, col: seg.last.$2, colorIndex: k));
    }

    return FlowPuzzle(
      size: size,
      numColors: K,
      endpoints: endpoints,
      difficulty: difficulty,
    );
  }

  // ── Warnsdorff Hamiltonian path ───────────────────────────────────────────

  static List<(int, int)>? _hamiltonianPath(int size, Random rng) {
    final n = size * size;
    final visited = List.generate(size, (_) => List.filled(size, false));
    final path = <(int, int)>[];

    int r = rng.nextInt(size), c = rng.nextInt(size);
    visited[r][c] = true;
    path.add((r, c));

    for (int step = 1; step < n; step++) {
      final neighbors = _freeNeighbors(r, c, size, visited)..shuffle(rng);
      if (neighbors.isEmpty) return null;

      // Warnsdorff: move to neighbor with fewest onward options
      neighbors.sort((a, b) {
        final da = _freeNeighbors(a.$1, a.$2, size, visited).length;
        final db = _freeNeighbors(b.$1, b.$2, size, visited).length;
        return da.compareTo(db);
      });

      final next = neighbors.first;
      r = next.$1;
      c = next.$2;
      visited[r][c] = true;
      path.add((r, c));
    }

    return path;
  }

  static List<(int, int)> _freeNeighbors(
      int r, int c, int size, List<List<bool>> visited) {
    final res = <(int, int)>[];
    if (r > 0 && !visited[r - 1][c]) res.add((r - 1, c));
    if (r < size - 1 && !visited[r + 1][c]) res.add((r + 1, c));
    if (c > 0 && !visited[r][c - 1]) res.add((r, c - 1));
    if (c < size - 1 && !visited[r][c + 1]) res.add((r, c + 1));
    return res;
  }

  // ── Path splitting ────────────────────────────────────────────────────────

  static List<List<(int, int)>>? _split(
      List<(int, int)> path, int K, Random rng) {
    final n = path.length;
    if (n < K * 2) return null; // each segment needs at least 2 cells

    for (int attempt = 0; attempt < 50; attempt++) {
      final splits = <int>[];
      bool ok = true;

      for (int i = 1; i < K; i++) {
        final ideal = (n * i / K).round();
        final jitter = rng.nextInt(7) - 3; // ±3
        final minSplit = splits.isEmpty ? 2 : splits.last + 2;
        final maxSplit = n - 2 * (K - splits.length);
        final sp = (ideal + jitter).clamp(minSplit, maxSplit);

        if (sp <= (splits.isEmpty ? 0 : splits.last)) {
          ok = false;
          break;
        }
        splits.add(sp);
      }

      if (!ok) continue;
      if (splits.isNotEmpty && n - splits.last < 2) continue;

      // Build segments
      final segs = <List<(int, int)>>[];
      int start = 0;
      for (final sp in splits) {
        segs.add(path.sublist(start, sp));
        start = sp;
      }
      segs.add(path.sublist(start));

      if (segs.any((s) => s.length < 2)) continue;
      return segs;
    }

    return null;
  }
}

/// Top-level for compute()
FlowPuzzle generateFlowIsolate(FlowDifficulty difficulty) =>
    FlowGenerator.generate(difficulty);

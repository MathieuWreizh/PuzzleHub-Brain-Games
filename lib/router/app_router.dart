import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/game_result.dart';
import '../services/auth_preference_service.dart';
import '../models/sudoku.dart';
import '../screens/auth_screen.dart';
import '../screens/home_screen.dart';
import '../screens/result_screen.dart';
import '../screens/sudoku_screen.dart';
import '../screens/sudoku_difficulty_screen.dart';
import '../screens/word_search_difficulty_screen.dart';
import '../screens/word_search_screen.dart';
import '../models/word_search.dart';
import '../screens/avatar_editor_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/achievements_screen.dart';
import '../screens/daily_challenges_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/flow_difficulty_screen.dart';
import '../screens/flow_screen.dart';
import '../models/flow_puzzle.dart';
import '../screens/adventure_map_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final hasChosen = AuthPreferenceService.instance.hasChosen;
    if (!hasChosen && state.matchedLocation != '/auth') return '/auth';
    return null;
  },
  routes: [
    // --- Home ---
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),

    // --- Word Search ---
    GoRoute(
      path: '/wordsearch',
      builder: (context, state) => const WordSearchDifficultyScreen(),
    ),
    GoRoute(
      path: '/wordsearch/:difficulty',
      builder: (context, state) {
        final diffName = state.pathParameters['difficulty']!;
        final difficulty = WordSearchDifficulty.values.firstWhere(
          (d) => d.name == diffName,
          orElse: () => WordSearchDifficulty.easy,
        );
        final extra = state.extra as Map?;
        return PopScope(canPop: false, child: WordSearchScreen(
          difficulty: difficulty,
          adventureLevel: extra?['adventureLevel'] as int?,
          adventureGameId: extra?['adventureGameId'] as String?,
        ));
      },
    ),

    // --- Sudoku ---
    GoRoute(
      path: '/sudoku',
      builder: (context, state) => const SudokuDifficultyScreen(),
    ),
    GoRoute(
      path: '/sudoku/:difficulty',
      builder: (context, state) {
        final diffName = state.pathParameters['difficulty']!;
        final difficulty = SudokuDifficulty.values.firstWhere(
          (d) => d.name == diffName,
          orElse: () => SudokuDifficulty.easy,
        );
        final extra = state.extra as Map?;
        return PopScope(canPop: false, child: SudokuScreen(
          difficulty: difficulty,
          adventureLevel: extra?['adventureLevel'] as int?,
          adventureGameId: extra?['adventureGameId'] as String?,
        ));
      },
    ),

    // --- Flow Puzzle ---
    GoRoute(
      path: '/flow',
      builder: (context, state) => const FlowDifficultyScreen(),
    ),
    GoRoute(
      path: '/flow/:difficulty',
      builder: (context, state) {
        final diffName = state.pathParameters['difficulty']!;
        final difficulty = FlowDifficulty.values.firstWhere(
          (d) => d.name == diffName,
          orElse: () => FlowDifficulty.easy,
        );
        final extra = state.extra as Map?;
        return PopScope(canPop: false, child: FlowScreen(
          difficulty: difficulty,
          adventureLevel: extra?['adventureLevel'] as int?,
          adventureGameId: extra?['adventureGameId'] as String?,
        ));
      },
    ),

    // --- Adventure Mode ---
    GoRoute(
      path: '/adventure/:gameId',
      builder: (context, state) {
        final gameId = state.pathParameters['gameId']!;
        final (title, emoji, color) = switch (gameId) {
          'sudoku' => ('Sudoku', '🧩', const Color(0xFF6C63FF)),
          'wordsearch' => ('Mots Mêlés', '🔤', const Color(0xFF11998E)),
          _ => ('Flow Puzzle', '🌊', const Color(0xFF1E88E5)),
        };
        return AdventureMapScreen(
          gameId: gameId,
          gameTitle: title,
          gameEmoji: emoji,
          gameColor: color,
        );
      },
    ),

    // --- Result ---
    GoRoute(
      path: '/result',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ResultScreen(
          result: extra['result'] as GameResult,
          onReplay: extra['onReplay'] as VoidCallback?,
          onNext: extra['onNext'] as VoidCallback?,
        );
      },
    ),

    // --- Avatar ---
    GoRoute(
      path: '/avatar',
      builder: (context, state) => const AvatarEditorScreen(),
    ),

    // --- Settings ---
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),

    // --- Achievements ---
    GoRoute(
      path: '/achievements',
      builder: (context, state) => const AchievementsScreen(),
    ),

    // --- Daily Challenges ---
    GoRoute(
      path: '/challenges',
      builder: (context, state) => const DailyChallengesScreen(),
    ),

    // --- Profile ---
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),

    // --- Auth ---
    GoRoute(
      path: '/auth',
      builder: (context, state) {
        final redirect = state.uri.queryParameters['redirect'];
        return AuthScreen(redirectPath: redirect);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Page introuvable: ${state.error}')),
  ),
);

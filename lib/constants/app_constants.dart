class AppConstants {
  // Deezer API
  static const String deezerBaseUrl = 'https://api.deezer.com';
  static const int previewDurationSeconds = 30;

  // Game settings
  static const int defaultRoundCount = 10;
  static const int defaultTimerSeconds = 30;
  static const int defaultAnswerChoices = 4;
  static const int pointsPerCorrectAnswer = 100;
  static const int maxSpeedBonus = 100; // bonus max si réponse instantanée

  // Multijoueur
  static const int matchmakingTimeoutSeconds = 30;
  static const int countdownSeconds = 3;
  static const int roundResultDisplaySeconds = 3;
  static const int maxPlayersPerRoom = 8;
  static const int minPlayersToStart = 2;

  // ── Système de crédits ───────────────────────────────────────────────────
  /// 4 genres gratuits dès le départ.
  static const Set<int> freeGenreIds = {132, 116, 152, 113};

  /// Coût pour débloquer chaque genre verrouillé.
  static const Map<int, int> genreCreditCosts = {
    106:  50,   // Electro
    165:  50,   // R&B
    197: 100,   // Latino
    85:  100,   // Variété française
    98:  150,   // Classique
    95:  150,   // Jazz
    144: 150,   // Metal
    169: 200,   // Reggae
    75:  200,   // Soul & Funk
    1001: 300,  // Disney
    1002: 300,  // Jeux Vidéo
    1003: 300,  // Films
    1004: 300,  // Séries
  };

  static const int hintCreditCost = 10;
  static const int rewardedAdCredits = 50;

  // Genre IDs Deezer
  static const Map<int, String> genres = {
    132:  'Pop',
    116:  'Rap/Hip Hop',
    152:  'Rock',
    113:  'Dance',
    106:  'Electro',
    165:  'R&B',
    197:  'Latino',
    85:   'Variété française',
    98:   'Classique',
    95:   'Jazz',
    144:  'Metal',
    169:  'Reggae',
    75:   'Soul & Funk',
    // IDs fictifs → toujours résolus via genreSearchOverrides
    1001: 'Disney',
    1002: 'Jeux Vidéo',
    1003: 'Films',
    1004: 'Séries',
  };

  /// Remplace la requête de recherche textuelle (fallback) pour certains genres.
  /// Les IDs fictifs (>= 1000) passent toujours par cette recherche.
  static const Map<int, String> genreSearchOverrides = {
    85:   'chanson française',
    1001: 'disney soundtrack',
    1002: 'video game soundtrack',
    1003: 'film soundtrack bande originale',
    1004: 'serie tv soundtrack',
  };
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appSubtitle => 'Test your musical knowledge';

  @override
  String get btnSolo => 'Solo';

  @override
  String get btnMultiplayer => 'Multiplayer';

  @override
  String get btnBack => 'Back';

  @override
  String get btnContinue => 'Continue';

  @override
  String get btnQuit => 'Quit';

  @override
  String get btnReplay => 'Play again';

  @override
  String get btnHome => 'Home';

  @override
  String get drawerMyAvatar => 'My avatar';

  @override
  String get drawerAchievements => 'Achievements';

  @override
  String get drawerSettings => 'Settings';

  @override
  String get drawerGuest => 'Guest';

  @override
  String get drawerConnected => 'Connected';

  @override
  String get drawerNotConnected => 'Not connected';

  @override
  String get genreTitle => 'Choose a genre';

  @override
  String get roundCount => 'Number of tracks';

  @override
  String btnPlayWithCount(int count) {
    return 'Play · $count tracks';
  }

  @override
  String get gameLoading => 'Loading tracks...';

  @override
  String get gameUnknownError => 'Unknown error';

  @override
  String get quitTitle => 'Quit game?';

  @override
  String get quitMessage => 'Your progress will be lost.';

  @override
  String get btnResults => 'See results';

  @override
  String get btnNext => 'Next';

  @override
  String get questionFindTitle => 'What is the title?';

  @override
  String get questionFindArtist => 'Who is the artist?';

  @override
  String get questionFindAlbum => 'What is the album?';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAudio => 'Audio';

  @override
  String get settingsMusicVolume => 'Music volume';

  @override
  String get settingsVolume => 'Volume';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get resultTotalScore => 'Total score';

  @override
  String get resultCorrectAnswers => 'Correct answers';

  @override
  String get resultAccuracy => 'Accuracy';

  @override
  String get resultXpTitle => 'Experience';

  @override
  String resultLevelUp(int level) {
    return 'Level $level reached!';
  }

  @override
  String get resultMaestro => 'Maestro!';

  @override
  String get resultExcellent => 'Excellent!';

  @override
  String get resultGood => 'Well done!';

  @override
  String get resultNotBad => 'Not bad...';

  @override
  String get resultKeepListening => 'Keep listening!';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get achievementsUnlocked => 'achievements unlocked';

  @override
  String achievementsError(Object error) {
    return 'Error: $error';
  }

  @override
  String get drawerPlaylists => 'My playlists';

  @override
  String get drawerDailyChallenges => 'Daily challenges';

  @override
  String get drawerLeague => 'Leagues';

  @override
  String get drawerChests => 'Chests';

  @override
  String get leagueTitle => 'Leagues';

  @override
  String leagueTierName(String tier) {
    return '$tier';
  }

  @override
  String leagueWeeklyPoints(int points) {
    return '$points pts this week';
  }

  @override
  String leagueNextTier(int pts, String tier) {
    return '$pts more pts for $tier';
  }

  @override
  String get leagueMaxTier => 'Maximum rank reached!';

  @override
  String leaguePointsEarned(int pts) {
    return '+$pts League pts';
  }

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get leaderboardYou => 'You';

  @override
  String get leaderboardEmpty => 'Be the first in your league!';

  @override
  String get leaderboardIndexHint =>
      'Leaderboard will be available after your first game.';

  @override
  String get chestTitle => 'Chests';

  @override
  String get chestBronze => 'Bronze';

  @override
  String get chestSilver => 'Silver';

  @override
  String get chestGold => 'Gold';

  @override
  String get chestReady => 'Open!';

  @override
  String get chestOpen => 'Open';

  @override
  String get chestEmpty => 'Empty slot';

  @override
  String get chestWatchAd => '📺 Open now';

  @override
  String get chestMaxReached => 'Chests full (4/4)';

  @override
  String chestEarned(String type) {
    return '$type chest earned!';
  }

  @override
  String chestCreditsWon(int credits) {
    return '+$credits credits!';
  }

  @override
  String get chestOpenIn => 'Opens in';

  @override
  String get creditBalance => 'Credits earned';

  @override
  String get creditBase => 'Game completed';

  @override
  String get creditStreakBonus => 'Answer streak';

  @override
  String get creditRecordBonus => 'New record!';

  @override
  String get creditDailyBonus => 'Daily bonus';

  @override
  String get creditChallengeBonus => 'Challenges completed';

  @override
  String get challengesCompleted => 'Challenges completed!';

  @override
  String get challengePlayGame => 'Play a game';

  @override
  String challengeAccuracy(int target) {
    return '$target%+ accuracy';
  }

  @override
  String challengeStreak(int target) {
    return 'Chain $target correct answers';
  }

  @override
  String challengeScore(int target) {
    return 'Score $target points';
  }

  @override
  String get challengeGenre => 'Play in this genre';

  @override
  String rewardedAdBtn(int credits) {
    return 'Watch an ad → +$credits credits';
  }

  @override
  String get hintBtn => 'Hint (10 credits)';

  @override
  String hintDecade(String decade) {
    return '${decade}s';
  }

  @override
  String get hintNoInfo => 'No info available';

  @override
  String get hintInsufficientCredits => 'Insufficient credits';

  @override
  String genreLockedCost(int cost) {
    return '$cost credits';
  }

  @override
  String genreUnlockTitle(String genre) {
    return 'Unlock $genre';
  }

  @override
  String genreUnlockConfirm(int cost, String genre) {
    return 'Spend $cost credits to unlock $genre?';
  }

  @override
  String get genreUnlockBtn => 'Unlock';

  @override
  String genreInsufficientCredits(int current) {
    return 'Not enough credits ($current)';
  }

  @override
  String get genreUnlockSuccess => 'Unlocked!';

  @override
  String get dailyChallengesTitle => 'Daily challenges';

  @override
  String dailyChallengesDone(int done, int total) {
    return '$done/$total completed';
  }

  @override
  String get dailyChallengesEmpty => 'Come back tomorrow for new challenges!';

  @override
  String streakDays(int days) {
    return '$days day(s) in a row';
  }

  @override
  String get playlistsTitle => 'My playlists';

  @override
  String get playlistNew => 'New playlist';

  @override
  String get playlistNameHint => 'Playlist name';

  @override
  String get playlistCreate => 'Create';

  @override
  String get playlistEmpty => 'No playlists yet';

  @override
  String get playlistEmptyTip => 'Create your first custom playlist!';

  @override
  String playlistTrackCount(int count) {
    return '$count track(s)';
  }

  @override
  String playlistMinTracks(int min) {
    return 'Add at least $min tracks to play';
  }

  @override
  String get playlistPlay => 'Play';

  @override
  String get playlistDelete => 'Delete';

  @override
  String get playlistDeleteConfirm => 'Delete this playlist?';

  @override
  String get playlistDeleteMessage => 'This action cannot be undone.';

  @override
  String get playlistSearchHint => 'Search for a title or artist...';

  @override
  String get playlistSearchEmpty => 'No results';

  @override
  String get playlistInPlaylist => 'In playlist';

  @override
  String get playlistAdd => 'Add';

  @override
  String get playlistRemove => 'Remove';

  @override
  String get playlistNoPreview => 'No preview available';

  @override
  String get catGamesPlayed => 'Games played';

  @override
  String get catVictories => 'Victories';

  @override
  String get catPerfection => 'Perfection';

  @override
  String get catGenres => 'Genres';

  @override
  String get achTitleGames10 => 'Novice';

  @override
  String get achDescGames10 => 'Play 10 games';

  @override
  String get achTitleGames20 => 'Amateur';

  @override
  String get achDescGames20 => 'Play 20 games';

  @override
  String get achTitleGames50 => 'Enthusiast';

  @override
  String get achDescGames50 => 'Play 50 games';

  @override
  String get achTitleGames100 => 'Music Lover';

  @override
  String get achDescGames100 => 'Play 100 games';

  @override
  String get achTitleWins1 => 'First Victory';

  @override
  String get achDescWins1 => 'Win 1 game (≥ 70% accuracy)';

  @override
  String get achTitleWins10 => 'On a Roll';

  @override
  String get achDescWins10 => 'Win 10 games';

  @override
  String get achTitleWins25 => 'Champion';

  @override
  String get achDescWins25 => 'Win 25 games';

  @override
  String get achTitleWins50 => 'Unbeatable';

  @override
  String get achDescWins50 => 'Win 50 games';

  @override
  String get achTitlePerfect1 => 'Perfect!';

  @override
  String get achDescPerfect1 => 'Finish a game without any mistakes';

  @override
  String get achTitlePerfect5 => 'Blind Test Master';

  @override
  String get achDescPerfect5 => 'Complete 5 perfect games';

  @override
  String achTitleGenre(String genre) {
    return '$genre Fan';
  }

  @override
  String achDescGenre(String genre) {
    return 'Play 10 games in $genre';
  }

  @override
  String get drawerSeason => 'Season Pass';

  @override
  String get drawerProfile => 'My Profile';

  @override
  String get seasonTitle => 'Season Pass';

  @override
  String seasonLevel(int level) {
    return 'Level $level';
  }

  @override
  String seasonXpProgress(int current, int max) {
    return '$current/$max XP';
  }

  @override
  String seasonEnds(int days) {
    return 'Ends in ${days}d';
  }

  @override
  String get seasonMaxLevel => 'Maximum level reached!';

  @override
  String get seasonFreeTrack => 'Free';

  @override
  String get seasonPremium => 'Premium 🔒';

  @override
  String seasonClaimAll(int count) {
    return 'Claim $count reward(s)';
  }

  @override
  String seasonRewardsClaimed(int count) {
    return '$count reward(s) claimed!';
  }

  @override
  String seasonLevelUp(int level) {
    return 'Season level $level reached!';
  }

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileBestScore => 'Best score';

  @override
  String get profileGamesPlayed => 'Games played';

  @override
  String get profileWins => 'Victories';

  @override
  String get profilePerfect => 'Perfect games';

  @override
  String get profileAccuracy => 'Avg. accuracy';

  @override
  String get profileStreak => 'Current streak';

  @override
  String get profileAchievements => 'Achievements';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotifChest => 'Chests ready to open';

  @override
  String get settingsNotifDaily => 'Daily challenge reminder';

  @override
  String get settingsNotifPermission => 'Enable notifications';

  @override
  String get sudokuTitle => 'Sudoku';

  @override
  String get sudokuSubtitle => 'Fill the 9×9 grid';

  @override
  String get sudokuChooseDifficulty => 'Choose a difficulty';

  @override
  String get sudokuEasy => 'Easy';

  @override
  String get sudokuMedium => 'Medium';

  @override
  String get sudokuHard => 'Hard';

  @override
  String get sudokuExpert => 'Expert';

  @override
  String get puzzleGamesTitle => 'Puzzle Games';

  @override
  String get puzzleGamesSubtitle => 'Brain training puzzles';

  @override
  String get comingSoon => 'More games coming soon...';
}

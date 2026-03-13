// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appSubtitle => 'Testez votre culture musicale';

  @override
  String get btnSolo => 'Solo';

  @override
  String get btnMultiplayer => 'Multijoueur';

  @override
  String get btnBack => 'Retour';

  @override
  String get btnContinue => 'Continuer';

  @override
  String get btnQuit => 'Quitter';

  @override
  String get btnReplay => 'Rejouer';

  @override
  String get btnHome => 'Accueil';

  @override
  String get drawerMyAvatar => 'Mon avatar';

  @override
  String get drawerAchievements => 'Succès';

  @override
  String get drawerSettings => 'Paramètres';

  @override
  String get drawerGuest => 'Invité';

  @override
  String get drawerConnected => 'Connecté';

  @override
  String get drawerNotConnected => 'Non connecté';

  @override
  String get genreTitle => 'Choisir un genre';

  @override
  String get roundCount => 'Nombre de musiques';

  @override
  String btnPlayWithCount(int count) {
    return 'Jouer · $count musiques';
  }

  @override
  String get gameLoading => 'Chargement des musiques...';

  @override
  String get gameUnknownError => 'Erreur inconnue';

  @override
  String get quitTitle => 'Quitter la partie ?';

  @override
  String get quitMessage => 'Votre progression sera perdue.';

  @override
  String get btnResults => 'Voir les résultats';

  @override
  String get btnNext => 'Suivant';

  @override
  String get questionFindTitle => 'Quel est le titre ?';

  @override
  String get questionFindArtist => 'Quel est l\'artiste ?';

  @override
  String get questionFindAlbum => 'Quel est l\'album ?';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsAudio => 'Audio';

  @override
  String get settingsMusicVolume => 'Volume de la musique';

  @override
  String get settingsVolume => 'Volume';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get resultTotalScore => 'Score total';

  @override
  String get resultCorrectAnswers => 'Bonnes réponses';

  @override
  String get resultAccuracy => 'Précision';

  @override
  String get resultXpTitle => 'Expérience';

  @override
  String resultLevelUp(int level) {
    return 'Niveau $level atteint !';
  }

  @override
  String get resultMaestro => 'Maestro !';

  @override
  String get resultExcellent => 'Excellent !';

  @override
  String get resultGood => 'Bien joué !';

  @override
  String get resultNotBad => 'Pas mal...';

  @override
  String get resultKeepListening => 'Continuez à écouter !';

  @override
  String get achievementsTitle => 'Succès';

  @override
  String get achievementsUnlocked => 'succès débloqués';

  @override
  String achievementsError(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get drawerPlaylists => 'Mes playlists';

  @override
  String get drawerDailyChallenges => 'Défis du jour';

  @override
  String get drawerLeague => 'Ligues';

  @override
  String get drawerChests => 'Coffres';

  @override
  String get leagueTitle => 'Ligues';

  @override
  String leagueTierName(String tier) {
    return '$tier';
  }

  @override
  String leagueWeeklyPoints(int points) {
    return '$points pts cette semaine';
  }

  @override
  String leagueNextTier(int pts, String tier) {
    return 'Encore $pts pts pour $tier';
  }

  @override
  String get leagueMaxTier => 'Rang maximum atteint !';

  @override
  String leaguePointsEarned(int pts) {
    return '+$pts pts Ligue';
  }

  @override
  String get leaderboardTitle => 'Classement';

  @override
  String get leaderboardYou => 'Vous';

  @override
  String get leaderboardEmpty => 'Soyez le premier de votre ligue !';

  @override
  String get leaderboardIndexHint =>
      'Le classement sera disponible après votre première partie.';

  @override
  String get chestTitle => 'Coffres';

  @override
  String get chestBronze => 'Bronze';

  @override
  String get chestSilver => 'Argent';

  @override
  String get chestGold => 'Or';

  @override
  String get chestReady => 'Ouvrir !';

  @override
  String get chestOpen => 'Ouvrir';

  @override
  String get chestEmpty => 'Slot vide';

  @override
  String get chestWatchAd => '📺 Ouvrir maintenant';

  @override
  String get chestMaxReached => 'Coffres pleins (4/4)';

  @override
  String chestEarned(String type) {
    return 'Coffre $type gagné !';
  }

  @override
  String chestCreditsWon(int credits) {
    return '+$credits crédits !';
  }

  @override
  String get chestOpenIn => 'Ouverture dans';

  @override
  String get creditBalance => 'Crédits gagnés';

  @override
  String get creditBase => 'Partie terminée';

  @override
  String get creditStreakBonus => 'Série de bonnes réponses';

  @override
  String get creditRecordBonus => 'Nouveau record !';

  @override
  String get creditDailyBonus => 'Bonus quotidien';

  @override
  String get creditChallengeBonus => 'Défis complétés';

  @override
  String get challengesCompleted => 'Défis complétés !';

  @override
  String get challengePlayGame => 'Jouer une partie';

  @override
  String challengeAccuracy(int target) {
    return 'Précision $target%+';
  }

  @override
  String challengeStreak(int target) {
    return 'Enchaîner $target bonnes réponses';
  }

  @override
  String challengeScore(int target) {
    return 'Marquer $target points';
  }

  @override
  String get challengeGenre => 'Jouer dans ce genre';

  @override
  String rewardedAdBtn(int credits) {
    return 'Regarder une pub → +$credits crédits';
  }

  @override
  String get hintBtn => 'Indice (10 crédits)';

  @override
  String hintDecade(String decade) {
    return 'Années $decade';
  }

  @override
  String get hintNoInfo => 'Info indisponible';

  @override
  String get hintInsufficientCredits => 'Crédits insuffisants';

  @override
  String genreLockedCost(int cost) {
    return '$cost crédits';
  }

  @override
  String genreUnlockTitle(String genre) {
    return 'Débloquer $genre';
  }

  @override
  String genreUnlockConfirm(int cost, String genre) {
    return 'Dépenser $cost crédits pour débloquer $genre ?';
  }

  @override
  String get genreUnlockBtn => 'Débloquer';

  @override
  String genreInsufficientCredits(int current) {
    return 'Solde insuffisant ($current crédits)';
  }

  @override
  String get genreUnlockSuccess => 'Débloqué !';

  @override
  String get dailyChallengesTitle => 'Défis du jour';

  @override
  String dailyChallengesDone(int done, int total) {
    return '$done/$total complétés';
  }

  @override
  String get dailyChallengesEmpty => 'Revenez demain pour de nouveaux défis !';

  @override
  String streakDays(int days) {
    return '$days jour(s) consécutif(s)';
  }

  @override
  String get playlistsTitle => 'Mes playlists';

  @override
  String get playlistNew => 'Nouvelle playlist';

  @override
  String get playlistNameHint => 'Nom de la playlist';

  @override
  String get playlistCreate => 'Créer';

  @override
  String get playlistEmpty => 'Aucune playlist pour l\'instant';

  @override
  String get playlistEmptyTip =>
      'Créez votre première playlist personnalisée !';

  @override
  String playlistTrackCount(int count) {
    return '$count musique(s)';
  }

  @override
  String playlistMinTracks(int min) {
    return 'Ajoutez au moins $min musiques pour jouer';
  }

  @override
  String get playlistPlay => 'Jouer';

  @override
  String get playlistDelete => 'Supprimer';

  @override
  String get playlistDeleteConfirm => 'Supprimer cette playlist ?';

  @override
  String get playlistDeleteMessage => 'Cette action est irréversible.';

  @override
  String get playlistSearchHint => 'Rechercher un titre ou un artiste...';

  @override
  String get playlistSearchEmpty => 'Aucun résultat';

  @override
  String get playlistInPlaylist => 'Dans la playlist';

  @override
  String get playlistAdd => 'Ajouter';

  @override
  String get playlistRemove => 'Retirer';

  @override
  String get playlistNoPreview => 'Pas d\'extrait disponible';

  @override
  String get catGamesPlayed => 'Parties jouées';

  @override
  String get catVictories => 'Victoires';

  @override
  String get catPerfection => 'Perfection';

  @override
  String get catGenres => 'Genres';

  @override
  String get achTitleGames10 => 'Novice';

  @override
  String get achDescGames10 => 'Jouer 10 parties';

  @override
  String get achTitleGames20 => 'Amateur';

  @override
  String get achDescGames20 => 'Jouer 20 parties';

  @override
  String get achTitleGames50 => 'Passionné';

  @override
  String get achDescGames50 => 'Jouer 50 parties';

  @override
  String get achTitleGames100 => 'Mélomane';

  @override
  String get achDescGames100 => 'Jouer 100 parties';

  @override
  String get achTitleWins1 => 'Première victoire';

  @override
  String get achDescWins1 => 'Gagner 1 partie (≥ 70 % de précision)';

  @override
  String get achTitleWins10 => 'En forme';

  @override
  String get achDescWins10 => 'Gagner 10 parties';

  @override
  String get achTitleWins25 => 'Champion';

  @override
  String get achDescWins25 => 'Gagner 25 parties';

  @override
  String get achTitleWins50 => 'Imbattable';

  @override
  String get achDescWins50 => 'Gagner 50 parties';

  @override
  String get achTitlePerfect1 => 'Parfait !';

  @override
  String get achDescPerfect1 => 'Terminer une partie sans la moindre erreur';

  @override
  String get achTitlePerfect5 => 'Maître du blind test';

  @override
  String get achDescPerfect5 => 'Réussir 5 parties parfaites';

  @override
  String achTitleGenre(String genre) {
    return 'Fan de $genre';
  }

  @override
  String achDescGenre(String genre) {
    return 'Jouer 10 parties en $genre';
  }

  @override
  String get drawerSeason => 'Passe de Saison';

  @override
  String get drawerProfile => 'Mon Profil';

  @override
  String get seasonTitle => 'Passe de Saison';

  @override
  String seasonLevel(int level) {
    return 'Niveau $level';
  }

  @override
  String seasonXpProgress(int current, int max) {
    return '$current/$max XP';
  }

  @override
  String seasonEnds(int days) {
    return 'Fin dans $days j';
  }

  @override
  String get seasonMaxLevel => 'Niveau maximum atteint !';

  @override
  String get seasonFreeTrack => 'Gratuit';

  @override
  String get seasonPremium => 'Premium 🔒';

  @override
  String seasonClaimAll(int count) {
    return 'Récupérer $count récompense(s)';
  }

  @override
  String seasonRewardsClaimed(int count) {
    return '$count récompense(s) récupérée(s) !';
  }

  @override
  String seasonLevelUp(int level) {
    return 'Niveau de saison $level atteint !';
  }

  @override
  String get profileTitle => 'Mon Profil';

  @override
  String get profileBestScore => 'Meilleur score';

  @override
  String get profileGamesPlayed => 'Parties jouées';

  @override
  String get profileWins => 'Victoires';

  @override
  String get profilePerfect => 'Parfaites';

  @override
  String get profileAccuracy => 'Précision moy.';

  @override
  String get profileStreak => 'Série actuelle';

  @override
  String get profileAchievements => 'Succès';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotifChest => 'Coffres prêts à ouvrir';

  @override
  String get settingsNotifDaily => 'Rappel défis quotidiens';

  @override
  String get settingsNotifPermission => 'Activer les notifications';

  @override
  String get sudokuTitle => 'Sudoku';

  @override
  String get sudokuSubtitle => 'Remplis la grille 9×9';

  @override
  String get sudokuChooseDifficulty => 'Choisir une difficulté';

  @override
  String get sudokuEasy => 'Facile';

  @override
  String get sudokuMedium => 'Moyen';

  @override
  String get sudokuHard => 'Difficile';

  @override
  String get sudokuExpert => 'Expert';

  @override
  String get puzzleGamesTitle => 'Puzzle Games';

  @override
  String get puzzleGamesSubtitle => 'Jeux de réflexion';

  @override
  String get comingSoon => 'Plus de jeux à venir...';
}

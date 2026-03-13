import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Testez votre culture musicale'**
  String get appSubtitle;

  /// No description provided for @btnSolo.
  ///
  /// In fr, this message translates to:
  /// **'Solo'**
  String get btnSolo;

  /// No description provided for @btnMultiplayer.
  ///
  /// In fr, this message translates to:
  /// **'Multijoueur'**
  String get btnMultiplayer;

  /// No description provided for @btnBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get btnBack;

  /// No description provided for @btnContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get btnContinue;

  /// No description provided for @btnQuit.
  ///
  /// In fr, this message translates to:
  /// **'Quitter'**
  String get btnQuit;

  /// No description provided for @btnReplay.
  ///
  /// In fr, this message translates to:
  /// **'Rejouer'**
  String get btnReplay;

  /// No description provided for @btnHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get btnHome;

  /// No description provided for @drawerMyAvatar.
  ///
  /// In fr, this message translates to:
  /// **'Mon avatar'**
  String get drawerMyAvatar;

  /// No description provided for @drawerAchievements.
  ///
  /// In fr, this message translates to:
  /// **'Succès'**
  String get drawerAchievements;

  /// No description provided for @drawerSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get drawerSettings;

  /// No description provided for @drawerGuest.
  ///
  /// In fr, this message translates to:
  /// **'Invité'**
  String get drawerGuest;

  /// No description provided for @drawerConnected.
  ///
  /// In fr, this message translates to:
  /// **'Connecté'**
  String get drawerConnected;

  /// No description provided for @drawerNotConnected.
  ///
  /// In fr, this message translates to:
  /// **'Non connecté'**
  String get drawerNotConnected;

  /// No description provided for @genreTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un genre'**
  String get genreTitle;

  /// No description provided for @roundCount.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de musiques'**
  String get roundCount;

  /// No description provided for @btnPlayWithCount.
  ///
  /// In fr, this message translates to:
  /// **'Jouer · {count} musiques'**
  String btnPlayWithCount(int count);

  /// No description provided for @gameLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des musiques...'**
  String get gameLoading;

  /// No description provided for @gameUnknownError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur inconnue'**
  String get gameUnknownError;

  /// No description provided for @quitTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quitter la partie ?'**
  String get quitTitle;

  /// No description provided for @quitMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre progression sera perdue.'**
  String get quitMessage;

  /// No description provided for @btnResults.
  ///
  /// In fr, this message translates to:
  /// **'Voir les résultats'**
  String get btnResults;

  /// No description provided for @btnNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get btnNext;

  /// No description provided for @questionFindTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quel est le titre ?'**
  String get questionFindTitle;

  /// No description provided for @questionFindArtist.
  ///
  /// In fr, this message translates to:
  /// **'Quel est l\'artiste ?'**
  String get questionFindArtist;

  /// No description provided for @questionFindAlbum.
  ///
  /// In fr, this message translates to:
  /// **'Quel est l\'album ?'**
  String get questionFindAlbum;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @settingsAudio.
  ///
  /// In fr, this message translates to:
  /// **'Audio'**
  String get settingsAudio;

  /// No description provided for @settingsMusicVolume.
  ///
  /// In fr, this message translates to:
  /// **'Volume de la musique'**
  String get settingsMusicVolume;

  /// No description provided for @settingsVolume.
  ///
  /// In fr, this message translates to:
  /// **'Volume'**
  String get settingsVolume;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @resultTotalScore.
  ///
  /// In fr, this message translates to:
  /// **'Score total'**
  String get resultTotalScore;

  /// No description provided for @resultCorrectAnswers.
  ///
  /// In fr, this message translates to:
  /// **'Bonnes réponses'**
  String get resultCorrectAnswers;

  /// No description provided for @resultAccuracy.
  ///
  /// In fr, this message translates to:
  /// **'Précision'**
  String get resultAccuracy;

  /// No description provided for @resultXpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Expérience'**
  String get resultXpTitle;

  /// No description provided for @resultLevelUp.
  ///
  /// In fr, this message translates to:
  /// **'Niveau {level} atteint !'**
  String resultLevelUp(int level);

  /// No description provided for @resultMaestro.
  ///
  /// In fr, this message translates to:
  /// **'Maestro !'**
  String get resultMaestro;

  /// No description provided for @resultExcellent.
  ///
  /// In fr, this message translates to:
  /// **'Excellent !'**
  String get resultExcellent;

  /// No description provided for @resultGood.
  ///
  /// In fr, this message translates to:
  /// **'Bien joué !'**
  String get resultGood;

  /// No description provided for @resultNotBad.
  ///
  /// In fr, this message translates to:
  /// **'Pas mal...'**
  String get resultNotBad;

  /// No description provided for @resultKeepListening.
  ///
  /// In fr, this message translates to:
  /// **'Continuez à écouter !'**
  String get resultKeepListening;

  /// No description provided for @achievementsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Succès'**
  String get achievementsTitle;

  /// No description provided for @achievementsUnlocked.
  ///
  /// In fr, this message translates to:
  /// **'succès débloqués'**
  String get achievementsUnlocked;

  /// No description provided for @achievementsError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {error}'**
  String achievementsError(Object error);

  /// No description provided for @drawerPlaylists.
  ///
  /// In fr, this message translates to:
  /// **'Mes playlists'**
  String get drawerPlaylists;

  /// No description provided for @drawerDailyChallenges.
  ///
  /// In fr, this message translates to:
  /// **'Défis du jour'**
  String get drawerDailyChallenges;

  /// No description provided for @drawerLeague.
  ///
  /// In fr, this message translates to:
  /// **'Ligues'**
  String get drawerLeague;

  /// No description provided for @drawerChests.
  ///
  /// In fr, this message translates to:
  /// **'Coffres'**
  String get drawerChests;

  /// No description provided for @leagueTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ligues'**
  String get leagueTitle;

  /// No description provided for @leagueTierName.
  ///
  /// In fr, this message translates to:
  /// **'{tier}'**
  String leagueTierName(String tier);

  /// No description provided for @leagueWeeklyPoints.
  ///
  /// In fr, this message translates to:
  /// **'{points} pts cette semaine'**
  String leagueWeeklyPoints(int points);

  /// No description provided for @leagueNextTier.
  ///
  /// In fr, this message translates to:
  /// **'Encore {pts} pts pour {tier}'**
  String leagueNextTier(int pts, String tier);

  /// No description provided for @leagueMaxTier.
  ///
  /// In fr, this message translates to:
  /// **'Rang maximum atteint !'**
  String get leagueMaxTier;

  /// No description provided for @leaguePointsEarned.
  ///
  /// In fr, this message translates to:
  /// **'+{pts} pts Ligue'**
  String leaguePointsEarned(int pts);

  /// No description provided for @leaderboardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Classement'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardYou.
  ///
  /// In fr, this message translates to:
  /// **'Vous'**
  String get leaderboardYou;

  /// No description provided for @leaderboardEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Soyez le premier de votre ligue !'**
  String get leaderboardEmpty;

  /// No description provided for @leaderboardIndexHint.
  ///
  /// In fr, this message translates to:
  /// **'Le classement sera disponible après votre première partie.'**
  String get leaderboardIndexHint;

  /// No description provided for @chestTitle.
  ///
  /// In fr, this message translates to:
  /// **'Coffres'**
  String get chestTitle;

  /// No description provided for @chestBronze.
  ///
  /// In fr, this message translates to:
  /// **'Bronze'**
  String get chestBronze;

  /// No description provided for @chestSilver.
  ///
  /// In fr, this message translates to:
  /// **'Argent'**
  String get chestSilver;

  /// No description provided for @chestGold.
  ///
  /// In fr, this message translates to:
  /// **'Or'**
  String get chestGold;

  /// No description provided for @chestReady.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir !'**
  String get chestReady;

  /// No description provided for @chestOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir'**
  String get chestOpen;

  /// No description provided for @chestEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Slot vide'**
  String get chestEmpty;

  /// No description provided for @chestWatchAd.
  ///
  /// In fr, this message translates to:
  /// **'📺 Ouvrir maintenant'**
  String get chestWatchAd;

  /// No description provided for @chestMaxReached.
  ///
  /// In fr, this message translates to:
  /// **'Coffres pleins (4/4)'**
  String get chestMaxReached;

  /// No description provided for @chestEarned.
  ///
  /// In fr, this message translates to:
  /// **'Coffre {type} gagné !'**
  String chestEarned(String type);

  /// No description provided for @chestCreditsWon.
  ///
  /// In fr, this message translates to:
  /// **'+{credits} crédits !'**
  String chestCreditsWon(int credits);

  /// No description provided for @chestOpenIn.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture dans'**
  String get chestOpenIn;

  /// No description provided for @creditBalance.
  ///
  /// In fr, this message translates to:
  /// **'Crédits gagnés'**
  String get creditBalance;

  /// No description provided for @creditBase.
  ///
  /// In fr, this message translates to:
  /// **'Partie terminée'**
  String get creditBase;

  /// No description provided for @creditStreakBonus.
  ///
  /// In fr, this message translates to:
  /// **'Série de bonnes réponses'**
  String get creditStreakBonus;

  /// No description provided for @creditRecordBonus.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau record !'**
  String get creditRecordBonus;

  /// No description provided for @creditDailyBonus.
  ///
  /// In fr, this message translates to:
  /// **'Bonus quotidien'**
  String get creditDailyBonus;

  /// No description provided for @creditChallengeBonus.
  ///
  /// In fr, this message translates to:
  /// **'Défis complétés'**
  String get creditChallengeBonus;

  /// No description provided for @challengesCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Défis complétés !'**
  String get challengesCompleted;

  /// No description provided for @challengePlayGame.
  ///
  /// In fr, this message translates to:
  /// **'Jouer une partie'**
  String get challengePlayGame;

  /// No description provided for @challengeAccuracy.
  ///
  /// In fr, this message translates to:
  /// **'Précision {target}%+'**
  String challengeAccuracy(int target);

  /// No description provided for @challengeStreak.
  ///
  /// In fr, this message translates to:
  /// **'Enchaîner {target} bonnes réponses'**
  String challengeStreak(int target);

  /// No description provided for @challengeScore.
  ///
  /// In fr, this message translates to:
  /// **'Marquer {target} points'**
  String challengeScore(int target);

  /// No description provided for @challengeGenre.
  ///
  /// In fr, this message translates to:
  /// **'Jouer dans ce genre'**
  String get challengeGenre;

  /// No description provided for @rewardedAdBtn.
  ///
  /// In fr, this message translates to:
  /// **'Regarder une pub → +{credits} crédits'**
  String rewardedAdBtn(int credits);

  /// No description provided for @hintBtn.
  ///
  /// In fr, this message translates to:
  /// **'Indice (10 crédits)'**
  String get hintBtn;

  /// No description provided for @hintDecade.
  ///
  /// In fr, this message translates to:
  /// **'Années {decade}'**
  String hintDecade(String decade);

  /// No description provided for @hintNoInfo.
  ///
  /// In fr, this message translates to:
  /// **'Info indisponible'**
  String get hintNoInfo;

  /// No description provided for @hintInsufficientCredits.
  ///
  /// In fr, this message translates to:
  /// **'Crédits insuffisants'**
  String get hintInsufficientCredits;

  /// No description provided for @genreLockedCost.
  ///
  /// In fr, this message translates to:
  /// **'{cost} crédits'**
  String genreLockedCost(int cost);

  /// No description provided for @genreUnlockTitle.
  ///
  /// In fr, this message translates to:
  /// **'Débloquer {genre}'**
  String genreUnlockTitle(String genre);

  /// No description provided for @genreUnlockConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Dépenser {cost} crédits pour débloquer {genre} ?'**
  String genreUnlockConfirm(int cost, String genre);

  /// No description provided for @genreUnlockBtn.
  ///
  /// In fr, this message translates to:
  /// **'Débloquer'**
  String get genreUnlockBtn;

  /// No description provided for @genreInsufficientCredits.
  ///
  /// In fr, this message translates to:
  /// **'Solde insuffisant ({current} crédits)'**
  String genreInsufficientCredits(int current);

  /// No description provided for @genreUnlockSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Débloqué !'**
  String get genreUnlockSuccess;

  /// No description provided for @dailyChallengesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Défis du jour'**
  String get dailyChallengesTitle;

  /// No description provided for @dailyChallengesDone.
  ///
  /// In fr, this message translates to:
  /// **'{done}/{total} complétés'**
  String dailyChallengesDone(int done, int total);

  /// No description provided for @dailyChallengesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Revenez demain pour de nouveaux défis !'**
  String get dailyChallengesEmpty;

  /// No description provided for @streakDays.
  ///
  /// In fr, this message translates to:
  /// **'{days} jour(s) consécutif(s)'**
  String streakDays(int days);

  /// No description provided for @playlistsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes playlists'**
  String get playlistsTitle;

  /// No description provided for @playlistNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle playlist'**
  String get playlistNew;

  /// No description provided for @playlistNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la playlist'**
  String get playlistNameHint;

  /// No description provided for @playlistCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get playlistCreate;

  /// No description provided for @playlistEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune playlist pour l\'instant'**
  String get playlistEmpty;

  /// No description provided for @playlistEmptyTip.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre première playlist personnalisée !'**
  String get playlistEmptyTip;

  /// No description provided for @playlistTrackCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} musique(s)'**
  String playlistTrackCount(int count);

  /// No description provided for @playlistMinTracks.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez au moins {min} musiques pour jouer'**
  String playlistMinTracks(int min);

  /// No description provided for @playlistPlay.
  ///
  /// In fr, this message translates to:
  /// **'Jouer'**
  String get playlistPlay;

  /// No description provided for @playlistDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get playlistDelete;

  /// No description provided for @playlistDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette playlist ?'**
  String get playlistDeleteConfirm;

  /// No description provided for @playlistDeleteMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible.'**
  String get playlistDeleteMessage;

  /// No description provided for @playlistSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un titre ou un artiste...'**
  String get playlistSearchHint;

  /// No description provided for @playlistSearchEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get playlistSearchEmpty;

  /// No description provided for @playlistInPlaylist.
  ///
  /// In fr, this message translates to:
  /// **'Dans la playlist'**
  String get playlistInPlaylist;

  /// No description provided for @playlistAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get playlistAdd;

  /// No description provided for @playlistRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get playlistRemove;

  /// No description provided for @playlistNoPreview.
  ///
  /// In fr, this message translates to:
  /// **'Pas d\'extrait disponible'**
  String get playlistNoPreview;

  /// No description provided for @catGamesPlayed.
  ///
  /// In fr, this message translates to:
  /// **'Parties jouées'**
  String get catGamesPlayed;

  /// No description provided for @catVictories.
  ///
  /// In fr, this message translates to:
  /// **'Victoires'**
  String get catVictories;

  /// No description provided for @catPerfection.
  ///
  /// In fr, this message translates to:
  /// **'Perfection'**
  String get catPerfection;

  /// No description provided for @catGenres.
  ///
  /// In fr, this message translates to:
  /// **'Genres'**
  String get catGenres;

  /// No description provided for @achTitleGames10.
  ///
  /// In fr, this message translates to:
  /// **'Novice'**
  String get achTitleGames10;

  /// No description provided for @achDescGames10.
  ///
  /// In fr, this message translates to:
  /// **'Jouer 10 parties'**
  String get achDescGames10;

  /// No description provided for @achTitleGames20.
  ///
  /// In fr, this message translates to:
  /// **'Amateur'**
  String get achTitleGames20;

  /// No description provided for @achDescGames20.
  ///
  /// In fr, this message translates to:
  /// **'Jouer 20 parties'**
  String get achDescGames20;

  /// No description provided for @achTitleGames50.
  ///
  /// In fr, this message translates to:
  /// **'Passionné'**
  String get achTitleGames50;

  /// No description provided for @achDescGames50.
  ///
  /// In fr, this message translates to:
  /// **'Jouer 50 parties'**
  String get achDescGames50;

  /// No description provided for @achTitleGames100.
  ///
  /// In fr, this message translates to:
  /// **'Mélomane'**
  String get achTitleGames100;

  /// No description provided for @achDescGames100.
  ///
  /// In fr, this message translates to:
  /// **'Jouer 100 parties'**
  String get achDescGames100;

  /// No description provided for @achTitleWins1.
  ///
  /// In fr, this message translates to:
  /// **'Première victoire'**
  String get achTitleWins1;

  /// No description provided for @achDescWins1.
  ///
  /// In fr, this message translates to:
  /// **'Gagner 1 partie (≥ 70 % de précision)'**
  String get achDescWins1;

  /// No description provided for @achTitleWins10.
  ///
  /// In fr, this message translates to:
  /// **'En forme'**
  String get achTitleWins10;

  /// No description provided for @achDescWins10.
  ///
  /// In fr, this message translates to:
  /// **'Gagner 10 parties'**
  String get achDescWins10;

  /// No description provided for @achTitleWins25.
  ///
  /// In fr, this message translates to:
  /// **'Champion'**
  String get achTitleWins25;

  /// No description provided for @achDescWins25.
  ///
  /// In fr, this message translates to:
  /// **'Gagner 25 parties'**
  String get achDescWins25;

  /// No description provided for @achTitleWins50.
  ///
  /// In fr, this message translates to:
  /// **'Imbattable'**
  String get achTitleWins50;

  /// No description provided for @achDescWins50.
  ///
  /// In fr, this message translates to:
  /// **'Gagner 50 parties'**
  String get achDescWins50;

  /// No description provided for @achTitlePerfect1.
  ///
  /// In fr, this message translates to:
  /// **'Parfait !'**
  String get achTitlePerfect1;

  /// No description provided for @achDescPerfect1.
  ///
  /// In fr, this message translates to:
  /// **'Terminer une partie sans la moindre erreur'**
  String get achDescPerfect1;

  /// No description provided for @achTitlePerfect5.
  ///
  /// In fr, this message translates to:
  /// **'Maître du blind test'**
  String get achTitlePerfect5;

  /// No description provided for @achDescPerfect5.
  ///
  /// In fr, this message translates to:
  /// **'Réussir 5 parties parfaites'**
  String get achDescPerfect5;

  /// No description provided for @achTitleGenre.
  ///
  /// In fr, this message translates to:
  /// **'Fan de {genre}'**
  String achTitleGenre(String genre);

  /// No description provided for @achDescGenre.
  ///
  /// In fr, this message translates to:
  /// **'Jouer 10 parties en {genre}'**
  String achDescGenre(String genre);

  /// No description provided for @drawerSeason.
  ///
  /// In fr, this message translates to:
  /// **'Passe de Saison'**
  String get drawerSeason;

  /// No description provided for @drawerProfile.
  ///
  /// In fr, this message translates to:
  /// **'Mon Profil'**
  String get drawerProfile;

  /// No description provided for @seasonTitle.
  ///
  /// In fr, this message translates to:
  /// **'Passe de Saison'**
  String get seasonTitle;

  /// No description provided for @seasonLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau {level}'**
  String seasonLevel(int level);

  /// No description provided for @seasonXpProgress.
  ///
  /// In fr, this message translates to:
  /// **'{current}/{max} XP'**
  String seasonXpProgress(int current, int max);

  /// No description provided for @seasonEnds.
  ///
  /// In fr, this message translates to:
  /// **'Fin dans {days} j'**
  String seasonEnds(int days);

  /// No description provided for @seasonMaxLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau maximum atteint !'**
  String get seasonMaxLevel;

  /// No description provided for @seasonFreeTrack.
  ///
  /// In fr, this message translates to:
  /// **'Gratuit'**
  String get seasonFreeTrack;

  /// No description provided for @seasonPremium.
  ///
  /// In fr, this message translates to:
  /// **'Premium 🔒'**
  String get seasonPremium;

  /// No description provided for @seasonClaimAll.
  ///
  /// In fr, this message translates to:
  /// **'Récupérer {count} récompense(s)'**
  String seasonClaimAll(int count);

  /// No description provided for @seasonRewardsClaimed.
  ///
  /// In fr, this message translates to:
  /// **'{count} récompense(s) récupérée(s) !'**
  String seasonRewardsClaimed(int count);

  /// No description provided for @seasonLevelUp.
  ///
  /// In fr, this message translates to:
  /// **'Niveau de saison {level} atteint !'**
  String seasonLevelUp(int level);

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon Profil'**
  String get profileTitle;

  /// No description provided for @profileBestScore.
  ///
  /// In fr, this message translates to:
  /// **'Meilleur score'**
  String get profileBestScore;

  /// No description provided for @profileGamesPlayed.
  ///
  /// In fr, this message translates to:
  /// **'Parties jouées'**
  String get profileGamesPlayed;

  /// No description provided for @profileWins.
  ///
  /// In fr, this message translates to:
  /// **'Victoires'**
  String get profileWins;

  /// No description provided for @profilePerfect.
  ///
  /// In fr, this message translates to:
  /// **'Parfaites'**
  String get profilePerfect;

  /// No description provided for @profileAccuracy.
  ///
  /// In fr, this message translates to:
  /// **'Précision moy.'**
  String get profileAccuracy;

  /// No description provided for @profileStreak.
  ///
  /// In fr, this message translates to:
  /// **'Série actuelle'**
  String get profileStreak;

  /// No description provided for @profileAchievements.
  ///
  /// In fr, this message translates to:
  /// **'Succès'**
  String get profileAchievements;

  /// No description provided for @settingsNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotifChest.
  ///
  /// In fr, this message translates to:
  /// **'Coffres prêts à ouvrir'**
  String get settingsNotifChest;

  /// No description provided for @settingsNotifDaily.
  ///
  /// In fr, this message translates to:
  /// **'Rappel défis quotidiens'**
  String get settingsNotifDaily;

  /// No description provided for @settingsNotifPermission.
  ///
  /// In fr, this message translates to:
  /// **'Activer les notifications'**
  String get settingsNotifPermission;

  /// No description provided for @sudokuTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sudoku'**
  String get sudokuTitle;

  /// No description provided for @sudokuSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Remplis la grille 9×9'**
  String get sudokuSubtitle;

  /// No description provided for @sudokuChooseDifficulty.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une difficulté'**
  String get sudokuChooseDifficulty;

  /// No description provided for @sudokuEasy.
  ///
  /// In fr, this message translates to:
  /// **'Facile'**
  String get sudokuEasy;

  /// No description provided for @sudokuMedium.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get sudokuMedium;

  /// No description provided for @sudokuHard.
  ///
  /// In fr, this message translates to:
  /// **'Difficile'**
  String get sudokuHard;

  /// No description provided for @sudokuExpert.
  ///
  /// In fr, this message translates to:
  /// **'Expert'**
  String get sudokuExpert;

  /// No description provided for @puzzleGamesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Puzzle Games'**
  String get puzzleGamesTitle;

  /// No description provided for @puzzleGamesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Jeux de réflexion'**
  String get puzzleGamesSubtitle;

  /// No description provided for @comingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Plus de jeux à venir...'**
  String get comingSoon;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

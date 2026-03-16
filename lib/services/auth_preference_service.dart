import 'package:shared_preferences/shared_preferences.dart';

/// Retient si l'utilisateur a déjà fait son choix d'authentification
/// (invité, connexion ou inscription) lors du premier lancement.
class AuthPreferenceService {
  static late AuthPreferenceService instance;
  static const _key = 'auth_choice_made';

  final SharedPreferences _prefs;
  AuthPreferenceService._(this._prefs);

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    instance = AuthPreferenceService._(prefs);
  }

  bool get hasChosen => _prefs.getBool(_key) ?? false;

  Future<void> markChosen() => _prefs.setBool(_key, true);

  /// Appelé lors de la déconnexion pour revoir l'écran d'auth au prochain lancement.
  Future<void> reset() => _prefs.setBool(_key, false);
}

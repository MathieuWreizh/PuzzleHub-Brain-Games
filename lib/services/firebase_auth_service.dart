import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  User? get currentUser => _auth.currentUser;
  String? get currentUid => _auth.currentUser?.uid;
  bool get isSignedIn => _auth.currentUser != null;
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  String get displayName {
    final user = _auth.currentUser;
    if (user == null) return 'Joueur';
    return user.displayName?.isNotEmpty == true
        ? user.displayName!
        : user.email?.split('@').first ?? 'Joueur';
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ---------------------------------------------------------------------------
  // Anonymous (solo / fallback)
  // ---------------------------------------------------------------------------

  Future<String> signInAnonymously() async {
    if (_auth.currentUser != null) return _auth.currentUser!.uid;
    final credential = await _auth.signInAnonymously();
    return credential.user!.uid;
  }

  // ---------------------------------------------------------------------------
  // Email / Password
  // ---------------------------------------------------------------------------

  Future<UserCredential> signInWithEmail(
      String email, String password) async {
    return _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
  }

  Future<UserCredential> registerWithEmail(
      String email, String password, String name) async {
    if (_auth.currentUser?.isAnonymous == true) await _auth.signOut();
    final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    await credential.user?.updateDisplayName(name.trim());
    return credential;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ---------------------------------------------------------------------------
  // Google Sign-In
  // ---------------------------------------------------------------------------

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw AuthException('Connexion Google annulée.');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    if (_auth.currentUser?.isAnonymous == true) await _auth.signOut();
    return _auth.signInWithCredential(credential);
  }

  // ---------------------------------------------------------------------------
  // Sign out
  // ---------------------------------------------------------------------------

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ---------------------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------------------

  Future<void> setDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name.trim());
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;

  static String fromFirebase(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => 'Aucun compte trouvé avec cet email.',
      'wrong-password' => 'Mot de passe incorrect.',
      'email-already-in-use' => 'Cet email est déjà utilisé.',
      'weak-password' => 'Mot de passe trop faible (6 caractères min).',
      'invalid-email' => 'Adresse email invalide.',
      'network-request-failed' => 'Erreur réseau. Vérifiez votre connexion.',
      'too-many-requests' => 'Trop de tentatives. Réessayez plus tard.',
      'invalid-credential' => 'Email ou mot de passe incorrect.',
      _ => e.message ?? 'Erreur d\'authentification.',
    };
  }
}

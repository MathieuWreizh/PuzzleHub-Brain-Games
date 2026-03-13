import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_auth_service.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>(
  (ref) => FirebaseAuthService(),
);

/// Stream de l'état d'authentification Firebase
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthServiceProvider).authStateChanges;
});

/// true si connecté avec un vrai compte (Google ou email, pas anonyme)
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).maybeWhen(
    data: (user) => user != null && user.isAnonymous == false,
    orElse: () => false,
  );
});

/// UID courant — initialise une session anonyme si besoin (pour le solo)
final currentUidProvider = FutureProvider<String>((ref) async {
  // Si déjà connecté (Google/email/anonyme), retourne l'uid existant
  final service = ref.watch(firebaseAuthServiceProvider);
  if (service.currentUid != null) return service.currentUid!;
  return service.signInAnonymously();
});

/// Nom d'affichage courant
final displayNameProvider = Provider<String>((ref) {
  // Dépend du stream pour se rafraîchir à chaque changement d'auth
  ref.watch(authStateProvider);
  return ref.read(firebaseAuthServiceProvider).displayName;
});

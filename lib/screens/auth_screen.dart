import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../services/auth_preference_service.dart';
import '../services/firebase_auth_service.dart';
import '../theme/app_theme.dart';

enum _View { main, login, register }

class AuthScreen extends ConsumerStatefulWidget {
  final String? redirectPath;
  const AuthScreen({super.key, this.redirectPath});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  _View _view = _View.main;

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailRegCtrl = TextEditingController();
  final _passwordRegCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _loading = false;
  bool _obscureLogin = true;
  bool _obscureReg = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _emailRegCtrl.dispose();
    _passwordRegCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSuccess() async {
    await AuthPreferenceService.instance.markChosen();
    if (mounted) context.go(widget.redirectPath ?? '/');
  }

  Future<void> _continueAsGuest() async {
    setState(() => _loading = true);
    try {
      await ref.read(firebaseAuthServiceProvider).signInAnonymously();
      await _onSuccess();
    } catch (_) {
      await AuthPreferenceService.instance.markChosen();
      if (mounted) context.go('/');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(firebaseAuthServiceProvider)
          .signInWithEmail(_emailCtrl.text, _passwordCtrl.text);
      await _onSuccess();
    } on FirebaseAuthException catch (e) {
      setState(() => _error = AuthException.fromFirebase(e));
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    if (!_registerFormKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(firebaseAuthServiceProvider).registerWithEmail(
        _emailRegCtrl.text, _passwordRegCtrl.text, _nameCtrl.text,
      );
      await _onSuccess();
    } on FirebaseAuthException catch (e) {
      setState(() => _error = AuthException.fromFirebase(e));
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(firebaseAuthServiceProvider).signInWithGoogle();
      await _onSuccess();
    } on FirebaseAuthException catch (e) {
      setState(() => _error = AuthException.fromFirebase(e));
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Entrez votre email d\'abord.');
      return;
    }
    try {
      await ref.read(firebaseAuthServiceProvider).sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email de réinitialisation envoyé !')),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = AuthException.fromFirebase(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: switch (_view) {
              _View.main     => _MainView(key: const ValueKey('main'),    onLogin: () => setState(() { _error = null; _view = _View.login; }),    onRegister: () => setState(() { _error = null; _view = _View.register; }), onGuest: _continueAsGuest, loading: _loading),
              _View.login    => _FormView(key: const ValueKey('login'),    title: 'Connexion',       onBack: () => setState(() { _error = null; _view = _View.main; }), child: _loginForm()),
              _View.register => _FormView(key: const ValueKey('register'), title: 'Créer un compte', onBack: () => setState(() { _error = null; _view = _View.main; }), child: _registerForm()),
            },
          ),
        ),
      ),
    );
  }

  // ── Login form ─────────────────────────────────────────────────────────────

  Widget _loginForm() {
    return Column(
      children: [
        if (_error != null) _ErrorBanner(message: _error!),
        if (_error != null) const SizedBox(height: 16),
        Form(
          key: _loginFormKey,
          child: Column(
            children: [
              _AuthField(controller: _emailCtrl, label: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress,
                validator: (v) { if (v == null || v.trim().isEmpty) return 'Email requis'; if (!v.contains('@')) return 'Email invalide'; return null; }),
              const SizedBox(height: 14),
              _AuthField(controller: _passwordCtrl, label: 'Mot de passe', icon: Icons.lock_outline_rounded, obscure: _obscureLogin,
                onToggleObscure: () => setState(() => _obscureLogin = !_obscureLogin),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _resetPassword,
                  child: const Text('Mot de passe oublié ?', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ),
              ),
              const SizedBox(height: 4),
              _GradientButton(label: 'Se connecter', loading: _loading, onPressed: _login),
              const SizedBox(height: 20),
              _Divider(),
              const SizedBox(height: 16),
              _GoogleButton(loading: _loading, onPressed: _googleSignIn),
            ],
          ),
        ),
      ],
    );
  }

  // ── Register form ──────────────────────────────────────────────────────────

  Widget _registerForm() {
    return Column(
      children: [
        if (_error != null) _ErrorBanner(message: _error!),
        if (_error != null) const SizedBox(height: 16),
        Form(
          key: _registerFormKey,
          child: Column(
            children: [
              _AuthField(controller: _nameCtrl, label: 'Pseudo', icon: Icons.person_outline_rounded,
                validator: (v) => v == null || v.trim().isEmpty ? 'Pseudo requis' : null),
              const SizedBox(height: 14),
              _AuthField(controller: _emailRegCtrl, label: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress,
                validator: (v) { if (v == null || v.trim().isEmpty) return 'Email requis'; if (!v.contains('@')) return 'Email invalide'; return null; }),
              const SizedBox(height: 14),
              _AuthField(controller: _passwordRegCtrl, label: 'Mot de passe', icon: Icons.lock_outline_rounded, obscure: _obscureReg,
                onToggleObscure: () => setState(() => _obscureReg = !_obscureReg),
                validator: (v) => v == null || v.length < 6 ? 'Minimum 6 caractères' : null),
              const SizedBox(height: 14),
              _AuthField(controller: _confirmPassCtrl, label: 'Confirmer le mot de passe', icon: Icons.lock_outline_rounded, obscure: _obscureReg,
                onToggleObscure: () => setState(() => _obscureReg = !_obscureReg),
                validator: (v) => v != _passwordRegCtrl.text ? 'Les mots de passe ne correspondent pas' : null),
              const SizedBox(height: 20),
              _GradientButton(label: 'Créer le compte', loading: _loading, onPressed: _register),
              const SizedBox(height: 20),
              _Divider(),
              const SizedBox(height: 16),
              _GoogleButton(loading: _loading, onPressed: _googleSignIn),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Vue principale ───────────────────────────────────────────────────────────

class _MainView extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onGuest;
  final bool loading;

  const _MainView({super.key, required this.onLogin, required this.onRegister, required this.onGuest, required this.loading});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 64),

          // ── Icône ──────────────────────────────────────────────────────────
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.4),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(Icons.grid_view_rounded, size: 52, color: Colors.white),
          ),

          const SizedBox(height: 24),

          // ── Titre ──────────────────────────────────────────────────────────
          const Text(
            'Puzzle-Games',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sudoku • Flow • Mots Mêlés',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
          ),

          const SizedBox(height: 56),

          // ── Bouton Se connecter ────────────────────────────────────────────
          _GradientButton(label: 'Se connecter', loading: false, onPressed: onLogin),
          const SizedBox(height: 14),

          // ── Bouton S'inscrire ──────────────────────────────────────────────
          _OutlinedAuthButton(label: 'Créer un compte', onPressed: onRegister),
          const SizedBox(height: 28),

          // ── Séparateur ────────────────────────────────────────────────────
          _Divider(),
          const SizedBox(height: 24),

          // ── Continuer en invité ────────────────────────────────────────────
          loading
              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.textSecondary))
              : GestureDetector(
                  onTap: onGuest,
                  child: const Text(
                    'Continuer en mode invité',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.underline, decorationColor: AppTheme.textSecondary),
                  ),
                ),

          const SizedBox(height: 12),
          const Text(
            'La progression en mode invité\nne sera pas sauvegardée.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── Vue formulaire (login / register) ───────────────────────────────────────

class _FormView extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final Widget child;

  const _FormView({super.key, required this.title, required this.onBack, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 28),
          child,
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── Widgets partagés ─────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const _GradientButton({required this.label, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Center(
          child: loading
              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _OutlinedAuthButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _OutlinedAuthButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Center(
          child: Text(label, style: const TextStyle(color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;

  const _GoogleButton({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network('https://www.google.com/favicon.ico', height: 20, width: 20,
              errorBuilder: (_, _, _) => const Icon(Icons.g_mobiledata, size: 24, color: AppTheme.textPrimary)),
            const SizedBox(width: 12),
            const Text('Continuer avec Google', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.onToggleObscure,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppTheme.textSecondary, size: 20),
                onPressed: onToggleObscure,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
        errorStyle: const TextStyle(color: AppTheme.wrong, fontSize: 11),
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.wrong.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.wrong.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.wrong, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(color: AppTheme.wrong, fontSize: 13))),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('ou', style: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.6), fontSize: 13)),
        ),
        const Expanded(child: Divider(color: AppTheme.border)),
      ],
    );
  }
}

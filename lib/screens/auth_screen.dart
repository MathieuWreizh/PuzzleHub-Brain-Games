import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_auth_service.dart';
import '../theme/app_theme.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final String? redirectPath;

  const AuthScreen({super.key, this.redirectPath});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
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
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() => _error = null));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _emailRegCtrl.dispose();
    _passwordRegCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _onSuccess() {
    final redirect = widget.redirectPath ?? '/';
    if (mounted) context.go(redirect);
  }

  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(firebaseAuthServiceProvider)
          .signInWithEmail(_emailCtrl.text, _passwordCtrl.text);
      _onSuccess();
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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(firebaseAuthServiceProvider).registerWithEmail(
            _emailRegCtrl.text,
            _passwordRegCtrl.text,
            _nameCtrl.text,
          );
      _onSuccess();
    } on FirebaseAuthException catch (e) {
      setState(() => _error = AuthException.fromFirebase(e));
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(firebaseAuthServiceProvider).signInWithGoogle();
      _onSuccess();
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
      await ref
          .read(firebaseAuthServiceProvider)
          .sendPasswordResetEmail(email);
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.music_note_rounded,
                    size: 44, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Blind Test',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Connectez-vous pour jouer en ligne',
                style:
                    TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 32),

              // Tabs
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppTheme.textSecondary,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Se connecter'),
                    Tab(text: 'S\'inscrire'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Error banner
              if (_error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.wrong.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.wrong.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppTheme.wrong, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                              color: AppTheme.wrong, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Tab views
              SizedBox(
                height: 360,
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildLoginForm(), _buildRegisterForm()],
                ),
              ),

              const SizedBox(height: 8),
              _buildDivider(),
              const SizedBox(height: 16),
              _buildGoogleButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          _EmailField(controller: _emailCtrl),
          const SizedBox(height: 16),
          _PasswordField(
            controller: _passwordCtrl,
            label: 'Mot de passe',
            obscure: _obscureLogin,
            onToggle: () => setState(() => _obscureLogin = !_obscureLogin),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _resetPassword,
              child: const Text(
                'Mot de passe oublié ?',
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _SubmitButton(
            label: 'Se connecter',
            loading: _loading,
            onPressed: _login,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: [
          _TextField(
            controller: _nameCtrl,
            label: 'Pseudo',
            icon: Icons.person_outline_rounded,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Pseudo requis' : null,
          ),
          const SizedBox(height: 14),
          _EmailField(controller: _emailRegCtrl),
          const SizedBox(height: 14),
          _PasswordField(
            controller: _passwordRegCtrl,
            label: 'Mot de passe',
            obscure: _obscureReg,
            onToggle: () => setState(() => _obscureReg = !_obscureReg),
            validator: (v) => v == null || v.length < 6
                ? 'Minimum 6 caractères'
                : null,
          ),
          const SizedBox(height: 14),
          _PasswordField(
            controller: _confirmPassCtrl,
            label: 'Confirmer le mot de passe',
            obscure: _obscureReg,
            onToggle: () => setState(() => _obscureReg = !_obscureReg),
            validator: (v) => v != _passwordRegCtrl.text
                ? 'Les mots de passe ne correspondent pas'
                : null,
          ),
          const SizedBox(height: 20),
          _SubmitButton(
            label: 'Créer le compte',
            loading: _loading,
            onPressed: _register,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ou',
            style: TextStyle(
                color: AppTheme.textSecondary.withValues(alpha: 0.6),
                fontSize: 13),
          ),
        ),
        const Expanded(child: Divider(color: AppTheme.border)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return OutlinedButton(
      onPressed: _loading ? null : _googleSignIn,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),
        foregroundColor: AppTheme.textPrimary,
        side: const BorderSide(color: AppTheme.border, width: 1.5),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://www.google.com/favicon.ico',
            height: 20,
            width: 20,
            errorBuilder: (_, _, _) => const Icon(Icons.g_mobiledata,
                size: 24, color: AppTheme.textPrimary),
          ),
          const SizedBox(width: 12),
          const Text('Continuer avec Google',
              style:
                  TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared form widgets
// ---------------------------------------------------------------------------

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const _TextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorStyle: const TextStyle(color: AppTheme.wrong, fontSize: 11),
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _TextField(
      controller: controller,
      label: 'Email',
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Email requis';
        if (!v.contains('@')) return 'Email invalide';
        return null;
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            color: AppTheme.textSecondary, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppTheme.textSecondary,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorStyle: const TextStyle(color: AppTheme.wrong, fontSize: 11),
      ),
      validator: validator ??
          (v) => v == null || v.isEmpty ? 'Champ requis' : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const _SubmitButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),
      ),
      child: loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : Text(label,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }
}

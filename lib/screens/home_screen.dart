import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/avatar.dart';
import '../models/user_stats.dart';
import '../providers/auth_provider.dart';
import '../providers/avatar_provider.dart';
import '../providers/xp_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/xp_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatar = ref.watch(myAvatarProvider).maybeWhen(
          data: (a) => a,
          orElse: () => null,
        );
    final displayName = ref.watch(displayNameProvider);
    final isLoggedIn = ref.watch(isLoggedInProvider);

    return Scaffold(
      endDrawer: _AppDrawer(
        avatar: avatar,
        displayName: displayName,
        isLoggedIn: isLoggedIn,
      ),
      body: Builder(
        builder: (ctx) => Container(
          decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
          child: SafeArea(
            child: Stack(
              children: [
                // ── Cercles décoratifs flous en arrière-plan ────────────────
                Positioned(
                  top: -80, right: -60,
                  child: _BlurCircle(size: 260, color: AppTheme.primary.withValues(alpha: 0.12)),
                ),
                Positioned(
                  bottom: 80, left: -80,
                  child: _BlurCircle(size: 220, color: AppTheme.secondary.withValues(alpha: 0.10)),
                ),
                Positioned(
                  top: 180, left: -40,
                  child: _BlurCircle(size: 160, color: const Color(0xFF06B6D4).withValues(alpha: 0.08)),
                ),

                // ── Avatar / menu button (top-right) ────────────────────────
                Positioned(
                  top: 8, right: 12,
                  child: GestureDetector(
                    onTap: () => Scaffold.of(ctx).openEndDrawer(),
                    child: avatar != null
                        ? AvatarWidget(avatar: avatar, size: 44)
                        : _GlassIconButton(
                            icon: Icons.menu_rounded,
                            color: AppTheme.primary,
                          ),
                  ),
                ),

                // ── Main content ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // Logo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.extension_rounded,
                            size: 52, color: Colors.white),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Puzzle Games',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context).appSubtitle,
                        style: const TextStyle(
                            fontSize: 15, color: AppTheme.textSecondary),
                      ),

                      const Spacer(),

                      _GameRow(
                        emoji: '🧩',
                        title: 'Sudoku',
                        subtitle: 'Remplis la grille 9×9',
                        color: AppTheme.primary,
                        gameId: 'sudoku',
                      ),
                      const SizedBox(height: 12),
                      _GameRow(
                        emoji: '🔤',
                        title: 'Mots Mêlés',
                        subtitle: 'Trouve les mots cachés',
                        color: const Color(0xFF0891B2),
                        gameId: 'wordsearch',
                      ),
                      const SizedBox(height: 12),
                      _GameRow(
                        emoji: '🌊',
                        title: 'Flow Puzzle',
                        subtitle: 'Relie les points de couleur',
                        color: const Color(0xFF7C3AED),
                        gameId: 'flow',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Plus de jeux à venir...',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Cercle flou décoratif ─────────────────────────────────────────────────────

class _BlurCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _BlurCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

// ── Glass icon button ─────────────────────────────────────────────────────────

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _GlassIconButton({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.20), width: 1),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

// ── Game Row ──────────────────────────────────────────────────────────────────

class _GameRow extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final String gameId;

  const _GameRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.gameId,
  });

  String get _freePlayRoute => '/$gameId';
  String get _adventureRoute => '/adventure/$gameId';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GameCard(
            emoji: emoji,
            title: title,
            subtitle: subtitle,
            color: color,
            onTap: () => context.push(_freePlayRoute),
          ),
        ),
        const SizedBox(width: 10),
        // Bouton Aventure (glass)
        Tooltip(
          message: 'Mode Aventure',
          child: GestureDetector(
            onTap: () => context.push(_adventureRoute),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  width: 56,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: color.withValues(alpha: 0.30), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppTheme.accentGradient(color).createShader(bounds),
                        child: Icon(Icons.map_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(height: 4),
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppTheme.accentGradient(color).createShader(bounds),
                        child: const Text(
                          'Aventure',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Game Card ─────────────────────────────────────────────────────────────────

class _GameCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.80),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: color.withValues(alpha: 0.18), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Emoji dans un fond dégradé teinté
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient(
                        color.withValues(alpha: 0.12)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(emoji,
                        style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient(color),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chevron_right_rounded,
                      color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Drawer ────────────────────────────────────────────────────────────────────

class _AppDrawer extends ConsumerWidget {
  final Avatar? avatar;
  final String displayName;
  final bool isLoggedIn;

  const _AppDrawer({
    required this.avatar,
    required this.displayName,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(userStatsProvider).valueOrNull;
    return Drawer(
      backgroundColor: AppTheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DrawerHeader(
                avatar: avatar,
                displayName: displayName,
                isLoggedIn: isLoggedIn,
                stats: stats),
            const SizedBox(height: 8),

            _DrawerItem(
              icon: Icons.person_outline_rounded,
              label: AppLocalizations.of(context).drawerProfile,
              onTap: () { Navigator.pop(context); context.push('/profile'); },
            ),
            if (isLoggedIn)
              _DrawerItem(
                icon: Icons.face_rounded,
                label: AppLocalizations.of(context).drawerMyAvatar,
                onTap: () { Navigator.pop(context); context.push('/avatar'); },
              ),
            _DrawerItem(
              icon: Icons.wb_sunny_outlined,
              label: AppLocalizations.of(context).drawerDailyChallenges,
              onTap: () { Navigator.pop(context); context.push('/challenges'); },
            ),
            _DrawerItem(
              icon: Icons.emoji_events_outlined,
              label: AppLocalizations.of(context).drawerAchievements,
              onTap: () { Navigator.pop(context); context.push('/achievements'); },
            ),
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: AppLocalizations.of(context).drawerSettings,
              onTap: () { Navigator.pop(context); context.push('/settings'); },
            ),
            const Spacer(),

            const Divider(color: AppTheme.border, height: 1),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Puzzle Games v1.0',
                style: TextStyle(
                  color: AppTheme.textSecondary.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final Avatar? avatar;
  final String displayName;
  final bool isLoggedIn;
  final UserStats? stats;

  const _DrawerHeader({
    required this.avatar,
    required this.displayName,
    required this.isLoggedIn,
    this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient,
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          avatar != null
              ? AvatarWidget(avatar: avatar!, size: 56)
              : Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline_rounded,
                      color: Colors.white, size: 28),
                ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn
                      ? displayName
                      : AppLocalizations.of(context).drawerGuest,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (stats != null)
                  LevelChip(stats: stats!)
                else
                  Text(
                    isLoggedIn
                        ? AppLocalizations.of(context).drawerConnected
                        : AppLocalizations.of(context).drawerNotConnected,
                    style: TextStyle(
                      color: isLoggedIn
                          ? AppTheme.correct
                          : AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.primaryGradient.createShader(bounds),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

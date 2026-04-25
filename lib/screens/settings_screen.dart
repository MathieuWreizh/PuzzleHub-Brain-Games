import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../models/sound_ambiance.dart';
import '../models/visual_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/sound_provider.dart';
import '../providers/visual_theme_provider.dart';
import '../services/auth_preference_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

const _kPrivacyPolicyUrl = 'https://mathieuwreizh.github.io/privacy-policy/';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final volume = ref.watch(volumeProvider);
    final locale = ref.watch(localeProvider);
    final currentTheme = ref.watch(visualThemeProvider);
    final currentAmbiance = ref.watch(soundAmbianceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Thème visuel ───────────────────────────────────────────
              const Text(
                'Thème visuel',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _ThemeSelector(current: currentTheme),
              const SizedBox(height: 24),

              // ── Ambiance sonore ────────────────────────────────────────
              const Text(
                'Ambiance sonore',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _AmbianceSelector(current: currentAmbiance),
              const SizedBox(height: 24),

              // ── Audio ──────────────────────────────────────────────────
              Text(
                l10n.settingsAudio,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          volume == 0
                              ? Icons.volume_off_rounded
                              : volume < 0.5
                                  ? Icons.volume_down_rounded
                                  : Icons.volume_up_rounded,
                          color: AppTheme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.settingsMusicVolume,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(volume * 100).round()}%',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppTheme.primary,
                        inactiveTrackColor:
                            AppTheme.primary.withValues(alpha: 0.2),
                        thumbColor: AppTheme.primary,
                        overlayColor: AppTheme.primary.withValues(alpha: 0.1),
                      ),
                      child: Slider(
                        value: volume,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (v) {
                          ref.read(volumeProvider.notifier).setVolume(v);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Langue ─────────────────────────────────────────────────
              Text(
                l10n.settingsLanguage,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _LangButton(
                      label: '🇫🇷  Français',
                      selected: locale.languageCode == 'fr',
                      onTap: () => ref
                          .read(localeProvider.notifier)
                          .setLocale(const Locale('fr')),
                    ),
                    const SizedBox(width: 12),
                    _LangButton(
                      label: '🇬🇧  English',
                      selected: locale.languageCode == 'en',
                      onTap: () => ref
                          .read(localeProvider.notifier)
                          .setLocale(const Locale('en')),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Notifications ───────────────────────────────────────────
              Text(
                l10n.settingsNotifications,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _NotifTile(
                  label: l10n.settingsNotifDaily,
                  provider: notifDailyProvider,
                  onEnable: (isFr) => NotificationService()
                      .scheduleDailyChallenge(isFr: isFr),
                  onDisable: () => NotificationService().cancelDailyChallenge(),
                ),
              ),

              const SizedBox(height: 24),

              // ── Légal ───────────────────────────────────────────────────
              const Text(
                'Légal',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _LegalTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Politique de confidentialité',
                onTap: () => launchUrl(
                  Uri.parse(_kPrivacyPolicyUrl),
                  mode: LaunchMode.externalApplication,
                ),
              ),

              const SizedBox(height: 24),

              // ── Compte ─────────────────────────────────────────────────
              const Text(
                'Compte',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const _LogoutButton(),
              const SizedBox(height: 12),
              const _DeleteAccountButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);

    return GestureDetector(
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Se déconnecter',
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
            content: const Text(
              'Es-tu sûr de vouloir te déconnecter ?',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Annuler',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.wrong),
                child: const Text('Déconnecter'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await ref.read(firebaseAuthServiceProvider).signOut();
          await AuthPreferenceService.instance.reset();
          if (context.mounted) context.go('/auth');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.wrong.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(
              isLoggedIn ? Icons.logout_rounded : Icons.person_off_rounded,
              color: AppTheme.wrong,
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              isLoggedIn ? 'Se déconnecter' : 'Quitter la session',
              style: const TextStyle(
                color: AppTheme.wrong,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.wrong, size: 20),
          ],
        ),
      ),
    );
  }
}

class _DeleteAccountButton extends ConsumerWidget {
  const _DeleteAccountButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'Supprimer le compte',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Cette action est irréversible. Toutes tes données seront définitivement supprimées.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Annuler', style: TextStyle(color: AppTheme.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.wrong),
                child: const Text('Supprimer définitivement'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          try {
            await ref.read(firebaseAuthServiceProvider).deleteAccount();
            await AuthPreferenceService.instance.reset();
            if (context.mounted) context.go('/auth');
          } on Exception catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.wrong.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.delete_forever_rounded, color: AppTheme.wrong, size: 22),
            const SizedBox(width: 16),
            const Text(
              'Supprimer mon compte',
              style: TextStyle(
                color: AppTheme.wrong,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.wrong, size: 20),
          ],
        ),
      ),
    );
  }
}

class _NotifTile extends ConsumerWidget {
  final String label;
  final StateNotifierProvider<dynamic, bool> provider;
  final Future<void> Function(bool isFr) onEnable;
  final Future<void> Function() onDisable;

  const _NotifTile({
    required this.label,
    required this.provider,
    required this.onEnable,
    required this.onDisable,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(provider);
    final isFr = Localizations.localeOf(context).languageCode == 'fr';

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
      value: enabled,
      activeThumbColor: AppTheme.primary,
      onChanged: (v) async {
        await NotificationService().init();
        await NotificationService().requestPermissions();
        if (v) {
          await ref.read(provider.notifier).set(true);
          await onEnable(isFr);
        } else {
          await ref.read(provider.notifier).set(false);
          await onDisable();
        }
      },
    );
  }
}

class _LegalTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LegalTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.open_in_new_rounded,
                color: AppTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primary
                : AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : AppTheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Theme Selector ────────────────────────────────────────────────────────────

class _ThemeSelector extends ConsumerWidget {
  final VisualTheme current;
  const _ThemeSelector({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: VisualTheme.all.map((t) {
        final selected = t.id == current.id;
        return GestureDetector(
          onTap: () => ref.read(visualThemeProvider.notifier).setTheme(t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: selected ? t.primaryGradient : null,
              color: selected ? null : AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? t.primary : AppTheme.border,
                width: selected ? 2 : 1,
              ),
              boxShadow: selected
                  ? [BoxShadow(color: t.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(t.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  t.label,
                  style: TextStyle(
                    color: selected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Ambiance Selector ─────────────────────────────────────────────────────────

class _AmbianceSelector extends ConsumerWidget {
  final SoundAmbiance current;
  const _AmbianceSelector({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: SoundAmbiance.all.map((a) {
        final selected = a.id == current.id;
        return GestureDetector(
          onTap: () => ref.read(soundAmbianceProvider.notifier).setAmbiance(a),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppTheme.primary : AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppTheme.primary : AppTheme.border,
                width: selected ? 2 : 1,
              ),
              boxShadow: selected
                  ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(a.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  a.label,
                  style: TextStyle(
                    color: selected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Bottom sheet léger pour régler le volume sans quitter la partie.
class VolumeBottomSheet extends ConsumerWidget {
  const VolumeBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final volume = ref.watch(volumeProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.settingsTitle,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded,
                      color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  volume == 0
                      ? Icons.volume_off_rounded
                      : volume < 0.5
                          ? Icons.volume_down_rounded
                          : Icons.volume_up_rounded,
                  color: AppTheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.settingsVolume,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(volume * 100).round()}%',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppTheme.primary,
                inactiveTrackColor: AppTheme.primary.withValues(alpha: 0.2),
                thumbColor: AppTheme.primary,
                overlayColor: AppTheme.primary.withValues(alpha: 0.1),
              ),
              child: Slider(
                value: volume,
                min: 0.0,
                max: 1.0,
                onChanged: (v) {
                  ref.read(volumeProvider.notifier).setVolume(v);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

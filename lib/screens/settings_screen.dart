import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final volume = ref.watch(volumeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

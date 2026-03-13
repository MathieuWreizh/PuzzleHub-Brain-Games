import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/avatar.dart';
import '../providers/auth_provider.dart';
import '../providers/avatar_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar_widget.dart';

class AvatarEditorScreen extends ConsumerStatefulWidget {
  const AvatarEditorScreen({super.key});

  @override
  ConsumerState<AvatarEditorScreen> createState() => _AvatarEditorScreenState();
}

class _AvatarEditorScreenState extends ConsumerState<AvatarEditorScreen> {
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final saved = ref.read(myAvatarProvider).maybeWhen(
            data: (a) => a,
            orElse: () => const Avatar(),
          );
      ref.read(avatarEditorProvider.notifier).init(saved);
    });
  }

  Future<void> _save() async {
    final uid = ref.read(authStateProvider).maybeWhen(
          data: (u) => u?.uid,
          orElse: () => null,
        );
    if (uid == null) return;
    setState(() => _saving = true);
    await ref.read(avatarEditorProvider.notifier).save(uid);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar sauvegardé !')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatar = ref.watch(avatarEditorProvider);
    final notifier = ref.read(avatarEditorProvider.notifier);
    final isBald = avatar.hairStyleIndex == 6;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon avatar'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                  )
                : TextButton(
                    onPressed: _save,
                    child: const Text('Sauvegarder', style: TextStyle(color: AppTheme.primary)),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Aperçu ────────────────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    AvatarWidget(avatar: avatar, size: 130),
                    const SizedBox(height: 10),
                    const Text('Aperçu', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ══ VISAGE ════════════════════════════════════════════════════
              _GroupHeader('Visage'),
              const SizedBox(height: 16),

              _Section(
                title: 'Teinte de peau',
                child: _ColorPicker(
                  colors: Avatar.skinTones,
                  selected: avatar.skinIndex,
                  onTap: notifier.setSkin,
                  size: 40,
                ),
              ),
              _Section(
                title: 'Forme des yeux',
                child: _LabelPicker(
                  labels: Avatar.eyeShapeNames,
                  selected: avatar.eyeShapeIndex,
                  onTap: notifier.setEyeShape,
                ),
              ),
              _Section(
                title: 'Couleur des yeux',
                child: _ColorPicker(
                  colors: Avatar.eyeColors,
                  selected: avatar.eyeColorIndex,
                  onTap: notifier.setEyeColor,
                  size: 36,
                ),
              ),
              _Section(
                title: 'Taille du nez',
                child: _LabelPicker(
                  labels: Avatar.noseSizeNames,
                  selected: avatar.noseSizeIndex,
                  onTap: notifier.setNoseSize,
                ),
              ),
              _Section(
                title: 'Bouche',
                child: _LabelPicker(
                  labels: Avatar.mouthStyleNames,
                  selected: avatar.mouthStyleIndex,
                  onTap: notifier.setMouthStyle,
                ),
              ),

              const SizedBox(height: 8),
              // ══ CHEVEUX ═══════════════════════════════════════════════════
              _GroupHeader('Cheveux'),
              const SizedBox(height: 16),

              _Section(
                title: 'Coiffure',
                child: _LabelPicker(
                  labels: Avatar.hairStyleNames,
                  selected: avatar.hairStyleIndex,
                  onTap: notifier.setHairStyle,
                ),
              ),
              if (!isBald)
                _Section(
                  title: 'Couleur des cheveux',
                  child: _ColorPicker(
                    colors: Avatar.hairColors,
                    selected: avatar.hairColorIndex,
                    onTap: notifier.setHairColor,
                    size: 36,
                  ),
                ),

              const SizedBox(height: 8),
              // ══ VÊTEMENTS ═════════════════════════════════════════════════
              _GroupHeader('Vêtements'),
              const SizedBox(height: 16),

              _Section(
                title: 'Style',
                child: _LabelPicker(
                  labels: Avatar.clothingStyleNames,
                  selected: avatar.clothingStyleIndex,
                  onTap: notifier.setClothingStyle,
                ),
              ),
              _Section(
                title: 'Couleur',
                child: _ColorPicker(
                  colors: Avatar.clothingColors,
                  selected: avatar.clothingColorIndex,
                  onTap: notifier.setClothingColor,
                  size: 36,
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Sauvegarder'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets internes ─────────────────────────────────────────────────────────

class _GroupHeader extends StatelessWidget {
  final String title;
  const _GroupHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final List<Color> colors;
  final int selected;
  final void Function(int) onTap;
  final double size;

  const _ColorPicker({
    required this.colors,
    required this.selected,
    required this.onTap,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(colors.length, (i) {
        final isSelected = selected == i;
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: colors[i],
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: colors[i].withValues(alpha: 0.65), blurRadius: 8, spreadRadius: 1)]
                  : [],
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : null,
          ),
        );
      }),
    );
  }
}

class _LabelPicker extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final void Function(int) onTap;

  const _LabelPicker({
    required this.labels,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(labels.length, (i) {
          final isSelected = selected == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withValues(alpha: 0.18)
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

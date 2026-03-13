import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/unlock_provider.dart';
import '../services/unlock_service.dart';
import '../theme/app_theme.dart';

/// Dialogue de déverrouillage d'une difficulté.
/// Retourne `true` si l'achat a réussi.
Future<bool> showUnlockDialog(
  BuildContext context,
  WidgetRef ref, {
  required String gameId,
  required String difficultyName,
  required String difficultyLabel,
  required Color color,
}) async {
  final cost = kDifficultyUnlockCosts[difficultyName]!;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => _UnlockDialog(
      gameId: gameId,
      difficultyName: difficultyName,
      difficultyLabel: difficultyLabel,
      color: color,
      cost: cost,
      ref: ref,
    ),
  );
  return result ?? false;
}

class _UnlockDialog extends StatefulWidget {
  final String gameId, difficultyName, difficultyLabel;
  final Color color;
  final int cost;
  final WidgetRef ref;

  const _UnlockDialog({
    required this.gameId,
    required this.difficultyName,
    required this.difficultyLabel,
    required this.color,
    required this.cost,
    required this.ref,
  });

  @override
  State<_UnlockDialog> createState() => _UnlockDialogState();
}

class _UnlockDialogState extends State<_UnlockDialog> {
  bool _loading = false;
  String? _error;

  Future<void> _unlock() async {
    setState(() { _loading = true; _error = null; });

    final uid = widget.ref.read(currentUidProvider).valueOrNull;
    if (uid == null) {
      setState(() { _loading = false; _error = 'Connecte-toi pour débloquer.'; });
      return;
    }

    final ok = await widget.ref
        .read(unlockServiceProvider)
        .unlock(uid, widget.gameId, widget.difficultyName);

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _loading = false;
        _error = 'Crédits insuffisants.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.lock_open_rounded, color: widget.color),
          const SizedBox(width: 10),
          Text('Débloquer ${widget.difficultyLabel}',
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Débloque ce niveau de difficulté définitivement pour tous tes futurs jeux.',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.color.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💰', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(
                  '${widget.cost} crédits',
                  style: TextStyle(
                      color: widget.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!,
                style: const TextStyle(color: AppTheme.wrong, fontSize: 13)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Annuler',
              style: TextStyle(color: AppTheme.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _unlock,
          style: ElevatedButton.styleFrom(backgroundColor: widget.color),
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Débloquer'),
        ),
      ],
    );
  }
}

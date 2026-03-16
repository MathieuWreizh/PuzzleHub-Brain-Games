import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../models/daily_challenge.dart';
import '../models/game_result.dart';
import '../models/user_stats.dart';
import '../models/achievement.dart';
import '../providers/achievement_provider.dart';
import '../providers/ad_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/credit_provider.dart';
import '../providers/xp_provider.dart';
import '../services/credit_service.dart';
import '../services/xp_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/achievement_toast.dart';
import '../widgets/xp_bar.dart';

// ─── Données de récompense ────────────────────────────────────────────────────

class _RewardData {
  final int xpGained;
  final CreditReward credits;
  final UserStats before;
  final UserStats after;
  final List<(DailyChallenge, int)> newChallenges;

  _RewardData({
    required this.xpGained,
    required this.credits,
    required this.before,
    required this.after,
    required this.newChallenges,
  });

  bool get leveledUp => after.level > before.level;
}

// ─── Écran ────────────────────────────────────────────────────────────────────

class ResultScreen extends ConsumerStatefulWidget {
  final GameResult result;
  final VoidCallback? onReplay; // rejouer le même niveau
  final VoidCallback? onNext;   // niveau suivant (aventure uniquement)

  const ResultScreen({super.key, required this.result, this.onReplay, this.onNext});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  _RewardData? _rewardData;
  List<AchievementDef> _newAchievements = [];
  bool _shouldShowAd = false;
  bool _rewardedAdWatched = false;

  static String? _gameTypeFromMode(String gameMode) {
    if (gameMode.startsWith('Sudoku')) return 'sudoku';
    if (gameMode.startsWith('Mots')) return 'wordsearch';
    if (gameMode.startsWith('Flow')) return 'flow';
    return null;
  }

  @override
  void initState() {
    super.initState();
    _applyRewards();
  }

  Future<void> _applyRewards() async {
    // Pub (best-effort)
    try {
      final adService = ref.read(adServiceProvider);
      _shouldShowAd = await adService.incrementAndCheck();
      if (_shouldShowAd) unawaited(adService.loadAd());
      unawaited(adService.loadRewardedAd());
    } catch (_) {}

    // UID (requis pour tout le reste)
    String? uid;
    try {
      uid = await ref.read(currentUidProvider.future);
    } catch (_) {}

    // XP — calculé depuis le résultat (toujours non-nul)
    final xpGained = XpService.calculateXp(widget.result);
    UserStats before = UserStats.fromTotalXp(0);
    UserStats after = UserStats.fromTotalXp(xpGained);
    if (uid != null) {
      try {
        final xpService = ref.read(xpServiceProvider);
        before = await xpService.getStats(uid);
        await xpService.addXp(uid, xpGained);
        after = UserStats.fromTotalXp(before.totalXp + xpGained);
      } catch (_) {}
    }

    // Crédits — récompense de base toujours calculée depuis le résultat
    CreditReward reward = CreditService.calculateReward(
      result: widget.result,
      isNewRecord: false,
      isFirstOfDay: false,
      streakLength: 0,
    );
    List<(DailyChallenge, int)> newChallenges = [];
    if (uid != null) {
      final creditService = ref.read(creditServiceProvider);

      // Bonus conditionnels (optionnels — n'empêchent pas l'ajout de crédits)
      bool isRecord = false;
      bool isFirstOfDay = false;
      int streak = 0;
      try {
        isRecord = await creditService.checkAndUpdateBestScore(
            uid, widget.result.totalScore);
      } catch (e) { debugPrint('⚠️ checkBestScore: $e'); }
      try {
        (isFirstOfDay, streak) = await creditService.checkAndUpdateStreak(uid);
      } catch (e) { debugPrint('⚠️ checkStreak: $e'); }

      reward = CreditService.calculateReward(
        result: widget.result,
        isNewRecord: isRecord,
        isFirstOfDay: isFirstOfDay,
        streakLength: streak,
      );

      try {
        newChallenges = await ref.read(dailyChallengeServiceProvider).checkAndAward(
          uid, widget.result, null, creditService,
        );
        for (final (_, amount) in newChallenges) {
          reward.addChallengeBonus(amount);
        }
      } catch (e) { debugPrint('⚠️ checkAndAward: $e'); }

      // Ajout des crédits — bloc isolé pour ne jamais être bloqué
      try {
        await creditService.addCredits(uid, reward.total);
        debugPrint('✅ Crédits ajoutés : ${reward.total}');
      } catch (e) {
        debugPrint('⚠️ addCredits ERREUR : $e');
      }
    }

    // Succès (optionnel)
    List<AchievementDef> newDefs = [];
    if (uid != null) {
      try {
        final newIds = await ref.read(achievementServiceProvider).recordGame(
              uid: uid,
              result: widget.result,
              gameType: _gameTypeFromMode(widget.result.gameMode),
            );
        newDefs = newIds
            .map(AchievementCatalog.byId)
            .whereType<AchievementDef>()
            .toList();
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _rewardData = _RewardData(
          xpGained: xpGained,
          credits: reward,
          before: before,
          after: after,
          newChallenges: newChallenges,
        );
        _newAchievements = newDefs;
      });
    }
  }

  void _navigateWithAd(VoidCallback navigate) {
    if (_shouldShowAd) {
      ref.read(adServiceProvider).showAdIfReady(onComplete: navigate);
    } else {
      navigate();
    }
  }

  void _watchRewardedAd() {
    final adService = ref.read(adServiceProvider);
    adService.showRewardedAd(
      onRewarded: () async {
        final uid = await ref.read(currentUidProvider.future);
        await ref
            .read(creditServiceProvider)
            .addCredits(uid, AppConstants.rewardedAdCredits);
        if (mounted) setState(() => _rewardedAdWatched = true);
      },
      onComplete: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.result.accuracy * 100).round();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                _getTrophyEmoji(percentage),
                style: const TextStyle(fontSize: 72),
              ),
              const SizedBox(height: 16),
              Text(
                _getTitle(context, percentage),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.result.gameMode,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 24),

              // ── Score ───────────────────────────────────────────────────
              _StatCard(children: [
                _StatRow(
                  label: l10n.resultTotalScore,
                  value: widget.result.totalScore.toString(),
                  valueColor: AppTheme.secondary,
                ),
                const Divider(color: AppTheme.border),
                _StatRow(
                  label: l10n.resultCorrectAnswers,
                  value:
                      '${widget.result.correctAnswers} / ${widget.result.totalRounds}',
                ),
                const Divider(color: AppTheme.border),
                _StatRow(
                  label: l10n.resultAccuracy,
                  value: '$percentage%',
                  valueColor: _getAccuracyColor(percentage),
                ),
              ]),

              const SizedBox(height: 16),

              // ── XP ──────────────────────────────────────────────────────
              _XpCard(rewardData: _rewardData),

              const SizedBox(height: 16),

              // ── Crédits ─────────────────────────────────────────────────
              _CreditsCard(rewardData: _rewardData),

              // ── Défis complétés ─────────────────────────────────────────
              if (_rewardData != null &&
                  _rewardData!.newChallenges.isNotEmpty) ...[
                const SizedBox(height: 16),
                _ChallengesCard(challenges: _rewardData!.newChallenges),
              ],

              // ── Succès débloqués ────────────────────────────────────────
              if (_newAchievements.isNotEmpty) ...[
                const SizedBox(height: 16),
                AchievementToasts(achievements: _newAchievements),
              ],

              const SizedBox(height: 32),

              // ── Pub récompensée ─────────────────────────────────────────
              if (!_rewardedAdWatched) ...[
                _RewardedAdButton(onTap: _watchRewardedAd),
                const SizedBox(height: 12),
              ],

              // ── Boutons navigation ──────────────────────────────────────
              // Niveau suivant (aventure) — dégradé
              if (widget.onNext != null) ...[
                _GradientButton(
                  label: 'Niveau suivant',
                  icon: Icons.skip_next_rounded,
                  onPressed: () => _navigateWithAd(() => widget.onNext!()),
                ),
                const SizedBox(height: 12),
              ],
              // Rejouer + Accueil (glass)
              Row(
                children: [
                  Expanded(
                    child: _GlassButton(
                      label: l10n.btnReplay,
                      icon: Icons.replay_rounded,
                      color: AppTheme.primary,
                      onPressed: widget.onReplay == null
                          ? null
                          : () => _navigateWithAd(() => widget.onReplay!()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GlassButton(
                      label: l10n.btnHome,
                      icon: Icons.home_rounded,
                      color: AppTheme.textSecondary,
                      onPressed: () => _navigateWithAd(() => context.go('/')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTrophyEmoji(int p) {
    if (p >= 90) return '🏆';
    if (p >= 70) return '🥇';
    if (p >= 50) return '🥈';
    if (p >= 30) return '🥉';
    return '🎯';
  }

  String _getTitle(BuildContext context, int p) {
    final l10n = AppLocalizations.of(context);
    if (p >= 90) return l10n.resultMaestro;
    if (p >= 70) return l10n.resultExcellent;
    if (p >= 50) return l10n.resultGood;
    if (p >= 30) return l10n.resultNotBad;
    return l10n.resultKeepListening;
  }

  Color _getAccuracyColor(int p) {
    if (p >= 70) return AppTheme.correct;
    if (p >= 40) return Colors.orange;
    return AppTheme.wrong;
  }
}

// ─── XP Card ─────────────────────────────────────────────────────────────────

class _XpCard extends StatelessWidget {
  final _RewardData? rewardData;
  const _XpCard({required this.rewardData});

  @override
  Widget build(BuildContext context) {
    return _StatCard(children: [
      Row(children: [
        Text(AppLocalizations.of(context).resultXpTitle,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
        const Spacer(),
        if (rewardData != null)
          _Badge('+${rewardData!.xpGained} XP', AppTheme.primary)
        else
          const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppTheme.primary)),
      ]),
      if (rewardData?.leveledUp == true) ...[
        const SizedBox(height: 10),
        _LevelUpBanner(level: rewardData!.after.level),
      ],
      if (rewardData != null) ...[
        const SizedBox(height: 14),
        XpBar(
          stats: rewardData!.after,
          fromProgress:
              rewardData!.leveledUp ? 0.0 : rewardData!.before.progressPercent,
        ),
      ],
    ]);
  }
}

// ─── Credits Card ─────────────────────────────────────────────────────────────

class _CreditsCard extends StatelessWidget {
  final _RewardData? rewardData;
  const _CreditsCard({required this.rewardData});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reward = rewardData?.credits;

    return _StatCard(children: [
      Row(children: [
        const Text('💰',
            style: TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(l10n.creditBalance,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
        const Spacer(),
        if (reward != null)
          _Badge('+${reward.total}', const Color(0xFFFFB800))
        else
          const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Color(0xFFFFB800))),
      ]),
      if (reward != null) ...[
        const SizedBox(height: 12),
        _CreditRow(label: l10n.creditBase, amount: reward.base),
        if (reward.streakBonus > 0)
          _CreditRow(label: l10n.creditStreakBonus, amount: reward.streakBonus),
        if (reward.recordBonus > 0)
          _CreditRow(label: l10n.creditRecordBonus, amount: reward.recordBonus),
        if (reward.dailyBonus > 0)
          _CreditRow(label: l10n.creditDailyBonus, amount: reward.dailyBonus),
        if (reward.challengeBonus > 0)
          _CreditRow(
              label: l10n.creditChallengeBonus,
              amount: reward.challengeBonus,
              color: AppTheme.primary),
      ],
    ]);
  }
}

class _CreditRow extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  const _CreditRow(
      {required this.label,
      required this.amount,
      this.color = AppTheme.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        Text('+$amount',
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ─── Challenges Card ──────────────────────────────────────────────────────────

class _ChallengesCard extends StatelessWidget {
  final List<(DailyChallenge, int)> challenges;
  const _ChallengesCard({required this.challenges});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.task_alt_rounded,
                color: AppTheme.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).challengesCompleted,
              style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ]),
          const SizedBox(height: 8),
          ...challenges.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_challengeLabel(context, p.$1),
                          style: const TextStyle(
                              color: AppTheme.textPrimary, fontSize: 13)),
                      Text('+${p.$2}',
                          style: const TextStyle(
                              color: Color(0xFFFFB800),
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ]),
              )),
        ],
      ),
    );
  }

  String _challengeLabel(BuildContext context, DailyChallenge c) {
    final l10n = AppLocalizations.of(context);
    switch (c.type) {
      case ChallengeType.playGame:
        return l10n.challengePlayGame;
      case ChallengeType.accuracy:
        return l10n.challengeAccuracy(c.target);
      case ChallengeType.correctStreak:
        return l10n.challengeStreak(c.target);
      case ChallengeType.score:
        return l10n.challengeScore(c.target);
    }
  }
}

// ─── Rewarded Ad Button ───────────────────────────────────────────────────────

class _RewardedAdButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RewardedAdButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.play_circle_outline_rounded,
          color: Color(0xFFFFB800)),
      label: Text(
        AppLocalizations.of(context).rewardedAdBtn(AppConstants.rewardedAdCredits),
        style: const TextStyle(color: Color(0xFFFFB800)),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        side: const BorderSide(color: Color(0xFFFFB800)),
      ),
    );
  }
}

// ─── Widgets utilitaires ──────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}

class _LevelUpBanner extends StatelessWidget {
  final int level;
  const _LevelUpBanner({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Text(AppLocalizations.of(context).resultLevelUp(level),
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        const SizedBox(width: 8),
        const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final List<Widget> children;
  const _StatCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration.copyWith(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(children: children),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _StatRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 16)),
        Text(value,
            style: TextStyle(
                color: valueColor ?? AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

// ─── Bouton dégradé ───────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const _GradientButton({required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─── Bouton glass ─────────────────────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  const _GlassButton({required this.label, required this.icon, required this.color, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.30), width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../models/game_result.dart';

/// Gestion des crédits, du streak quotidien et des genres déverrouillés.
class CreditService {
  final FirebaseFirestore _db;

  CreditService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  DocumentReference _userDoc(String uid) => _db.collection('users').doc(uid);

  // ─── Calcul des crédits gagnés ────────────────────────────────────────────

  /// Formule complète de récompense.
  ///
  ///  +10   terminer une partie
  ///  +5×N  pour chaque série de 3 bonnes réponses consécutives
  ///  +20   battre son record personnel
  ///  +30/45/60  bonus quotidien (selon le streak)
  static CreditReward calculateReward({
    required GameResult result,
    required bool isNewRecord,
    required bool isFirstOfDay,
    required int streakLength,
  }) {
    const base = 10;

    final streakBonus = _streakBonuses(result) * 5;

    final recordBonus = isNewRecord ? 20 : 0;

    final dailyBonus = isFirstOfDay
        ? (streakLength >= 7 ? 60 : streakLength >= 3 ? 45 : 30)
        : 0;

    return CreditReward(
      base: base,
      streakBonus: streakBonus,
      recordBonus: recordBonus,
      dailyBonus: dailyBonus,
    );
  }

  static int _streakBonuses(GameResult result) {
    int bonuses = 0, consecutive = 0;
    for (final correct in result.outcomes) {
      if (correct) {
        consecutive++;
        if (consecutive % 3 == 0) bonuses++;
      } else {
        consecutive = 0;
      }
    }
    return bonuses;
  }

  // ─── Firestore : crédits ──────────────────────────────────────────────────

  Stream<int> watchCredits(String uid) => _userDoc(uid).snapshots().map((s) {
        final d = s.data() as Map<String, dynamic>?;
        return d?['totalCredits'] as int? ?? 0;
      });

  Future<int> getCredits(String uid) async {
    final s = await _userDoc(uid).get();
    final d = s.data() as Map<String, dynamic>?;
    return d?['totalCredits'] as int? ?? 0;
  }

  Future<void> addCredits(String uid, int amount) => _userDoc(uid).set(
        {'totalCredits': FieldValue.increment(amount)},
        SetOptions(merge: true),
      );

  /// Dépense [amount] crédits. Renvoie false si solde insuffisant.
  Future<bool> spendCredits(String uid, int amount) async {
    bool ok = false;
    await _db.runTransaction((tx) async {
      final snap = await tx.get(_userDoc(uid));
      final d = snap.data() as Map<String, dynamic>?;
      final current = d?['totalCredits'] as int? ?? 0;
      if (current < amount) return;
      tx.update(_userDoc(uid), {'totalCredits': current - amount});
      ok = true;
    });
    return ok;
  }

  // ─── Firestore : genres déverrouillés ─────────────────────────────────────

  Stream<Set<int>> watchUnlockedGenres(String uid) =>
      _userDoc(uid).snapshots().map((s) {
        final d = s.data() as Map<String, dynamic>?;
        final stored = (d?['unlockedGenres'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toSet() ??
            {};
        return {...AppConstants.freeGenreIds, ...stored};
      });

  /// Déverrouille un genre. Renvoie false si crédits insuffisants.
  Future<bool> unlockGenre(String uid, int genreId) async {
    final cost = AppConstants.genreCreditCosts[genreId];
    if (cost == null) return true; // gratuit

    bool ok = false;
    await _db.runTransaction((tx) async {
      final snap = await tx.get(_userDoc(uid));
      final d = snap.data() as Map<String, dynamic>?;
      final current = d?['totalCredits'] as int? ?? 0;
      if (current < cost) return;

      final unlocked = (d?['unlockedGenres'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [];
      if (!unlocked.contains(genreId)) unlocked.add(genreId);

      tx.update(_userDoc(uid), {
        'totalCredits': current - cost,
        'unlockedGenres': unlocked,
      });
      ok = true;
    });
    return ok;
  }

  // ─── Firestore : streak & bonus quotidien ─────────────────────────────────

  Stream<int> watchStreak(String uid) => _userDoc(uid).snapshots().map((s) {
        final d = s.data() as Map<String, dynamic>?;
        return d?['currentStreak'] as int? ?? 0;
      });

  /// Met à jour le streak, renvoie (isFirstOfDay, nouveauStreak).
  Future<(bool, int)> checkAndUpdateStreak(String uid) async {
    final today = _dateStr(DateTime.now());
    final yesterday = _dateStr(DateTime.now().subtract(const Duration(days: 1)));

    final snap = await _userDoc(uid).get();
    final d = snap.data() as Map<String, dynamic>?;
    final lastPlayed = d?['lastPlayedDate'] as String?;
    final streak = d?['currentStreak'] as int? ?? 0;

    if (lastPlayed == today) return (false, streak); // déjà joué aujourd'hui

    final newStreak = (lastPlayed == yesterday) ? streak + 1 : 1;
    final longest = max(newStreak, d?['longestStreak'] as int? ?? 0);

    await _userDoc(uid).set({
      'lastPlayedDate': today,
      'currentStreak': newStreak,
      'longestStreak': longest,
    }, SetOptions(merge: true));

    return (true, newStreak);
  }

  // ─── Firestore : record personnel ─────────────────────────────────────────

  /// Renvoie true si [score] est un nouveau record.
  Future<bool> checkAndUpdateBestScore(String uid, int score) async {
    bool isRecord = false;
    await _db.runTransaction((tx) async {
      final snap = await tx.get(_userDoc(uid));
      final d = snap.data() as Map<String, dynamic>?;
      final best = d?['bestScore'] as int? ?? 0;
      if (score > best) {
        tx.set(_userDoc(uid), {'bestScore': score}, SetOptions(merge: true));
        isRecord = true;
      }
    });
    return isRecord;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

// ─── Détail de la récompense ──────────────────────────────────────────────────

class CreditReward {
  final int base;
  final int streakBonus;
  final int recordBonus;
  final int dailyBonus;
  int get challengeBonus => _challengeBonus;
  int _challengeBonus = 0;

  CreditReward({
    required this.base,
    required this.streakBonus,
    required this.recordBonus,
    required this.dailyBonus,
  });

  void addChallengeBonus(int amount) => _challengeBonus += amount;

  int get total => base + streakBonus + recordBonus + dailyBonus + _challengeBonus;
}

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_progress.dart';

// ── Riverpod Providers ────────────────────────────────────────────────

/// StateProvider for tracking progress updates and triggering UI rebuilds.
final progressVersionProvider = StateProvider<int>((ref) => 0);

/// SharedPreferences instance provider.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main');
});

/// ProgressRepository provider.
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProgressRepository(prefs, ref);
});

/// Repository for persisting user learning progress and practice statistics
/// using [SharedPreferences].
class ProgressRepository {
  ProgressRepository(this._prefs, this._ref);

  final SharedPreferences _prefs;
  final Ref _ref;

  static const String _progressKeyPrefix = 'kana_progress_';
  static const String _streakKey = 'user_streak_days';
  static const String _lastPracticeKey = 'user_last_practice_date';

  void _notifyListeners() {
    _ref.read(progressVersionProvider.notifier).state++;
  }

  /// Get progress map for a single character key (e.g. "hiragana_あ").
  LearningProgress getProgress(String characterKey) {
    final rawJson = _prefs.getString('$_progressKeyPrefix$characterKey');
    if (rawJson == null) {
      return LearningProgress(character: characterKey);
    }
    try {
      final Map<String, dynamic> map = json.decode(rawJson) as Map<String, dynamic>;
      return LearningProgress.fromJson(map);
    } catch (_) {
      return LearningProgress(character: characterKey);
    }
  }

  /// Save progress for a character key.
  Future<void> saveProgress(LearningProgress progress) async {
    final rawJson = json.encode(progress.toJson());
    await _prefs.setString('$_progressKeyPrefix${progress.character}', rawJson);
    _notifyListeners();
  }

  /// Mark a character as learned.
  Future<void> markAsLearned(String characterKey) async {
    final current = getProgress(characterKey);
    if (current.isLearned) return; // Already learned
    final updated = current.copyWith(isLearned: true);
    await saveProgress(updated);
    await recordPracticeActivity();
  }

  /// Record a practice result (correct / incorrect).
  Future<void> recordPracticeResult({
    required String characterKey,
    required bool isCorrect,
  }) async {
    final current = getProgress(characterKey);
    final updated = current.copyWith(
      isLearned: true,
      correctCount: isCorrect ? current.correctCount + 1 : current.correctCount,
      incorrectCount: !isCorrect ? current.incorrectCount + 1 : current.incorrectCount,
      lastPracticedAt: DateTime.now(),
    );
    await saveProgress(updated);
    await recordPracticeActivity();
  }

  /// Record practice activity to update streak.
  Future<void> recordPracticeActivity() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastDateStr = _prefs.getString(_lastPracticeKey);
    if (lastDateStr == null) {
      await _prefs.setInt(_streakKey, 1);
      await _prefs.setString(_lastPracticeKey, today.toIso8601String());
      _notifyListeners();
      return;
    }

    final lastDate = DateTime.parse(lastDateStr);
    final difference = today.difference(lastDate).inDays;

    if (difference == 1) {
      final currentStreak = _prefs.getInt(_streakKey) ?? 0;
      await _prefs.setInt(_streakKey, currentStreak + 1);
      await _prefs.setString(_lastPracticeKey, today.toIso8601String());
      _notifyListeners();
    } else if (difference > 1) {
      await _prefs.setInt(_streakKey, 1);
      await _prefs.setString(_lastPracticeKey, today.toIso8601String());
      _notifyListeners();
    }
  }

  /// Current streak in days.
  int get streakDays => _prefs.getInt(_streakKey) ?? 0;

  /// Total count of characters marked as learned.
  int getLearnedCount(List<String> characterKeys) {
    int count = 0;
    for (final key in characterKeys) {
      if (getProgress(key).isLearned) {
        count++;
      }
    }
    return count;
  }

  /// Reset all progress data.
  Future<void> resetAll() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_progressKeyPrefix)).toList();
    for (final key in keys) {
      await _prefs.remove(key);
    }
    await _prefs.remove(_streakKey);
    await _prefs.remove(_lastPracticeKey);
    _notifyListeners();
  }
}

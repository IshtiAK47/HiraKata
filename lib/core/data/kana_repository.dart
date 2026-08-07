import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kana.dart';
import '../models/kana_category.dart';
import '../models/kana_type.dart';

/// Repository for loading and accessing kana character data.
///
/// Loads kana data from bundled JSON assets and provides methods
/// to query characters by type, category, and index.
class KanaRepository {
  KanaRepository._();

  List<Kana> _hiragana = [];
  List<Kana> _katakana = [];
  bool _isLoaded = false;

  /// Load all kana data from JSON assets.
  Future<void> load() async {
    if (_isLoaded) return;

    _hiragana = await _loadFromAsset('assets/data/hiragana.json', KanaType.hiragana);
    _katakana = await _loadFromAsset('assets/data/katakana.json', KanaType.katakana);
    _isLoaded = true;
  }

  Future<List<Kana>> _loadFromAsset(String path, KanaType type) async {
    final jsonString = await rootBundle.loadString(path);
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((item) => Kana.fromJson(item as Map<String, dynamic>, type))
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  /// All hiragana characters, sorted by order index.
  List<Kana> get hiragana => List.unmodifiable(_hiragana);

  /// All katakana characters, sorted by order index.
  List<Kana> get katakana => List.unmodifiable(_katakana);

  /// Get all characters of a specific [type].
  List<Kana> getByType(KanaType type) {
    return type == KanaType.hiragana ? hiragana : katakana;
  }

  /// Get characters filtered by [type] and [category].
  List<Kana> getByCategory(KanaType type, KanaCategory category) {
    return getByType(type).where((k) => k.category == category).toList();
  }

  /// Get a single kana by [type] and [orderIndex].
  Kana? getByIndex(KanaType type, int orderIndex) {
    final list = getByType(type);
    try {
      return list.firstWhere((k) => k.orderIndex == orderIndex);
    } catch (_) {
      return null;
    }
  }

  /// Total number of characters for a given [type].
  int countByType(KanaType type) => getByType(type).length;

  /// Total number of all characters.
  int get totalCount => _hiragana.length + _katakana.length;
}

// ── Riverpod Providers ────────────────────────────────────────────────

/// Provider for the singleton [KanaRepository] instance.
final kanaRepositoryProvider = Provider<KanaRepository>((ref) {
  return KanaRepository._();
});

/// FutureProvider that ensures kana data is loaded before use.
final kanaDataProvider = FutureProvider<KanaRepository>((ref) async {
  final repo = ref.read(kanaRepositoryProvider);
  await repo.load();
  return repo;
});

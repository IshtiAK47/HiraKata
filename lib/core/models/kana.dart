import 'kana_category.dart';
import 'kana_type.dart';

/// A single kana character with all associated learning data.
///
/// Contains the character, its pronunciation, example word, mnemonic,
/// learning tips, and metadata for categorization and ordering.
class Kana {
  const Kana({
    required this.character,
    required this.romaji,
    required this.type,
    required this.category,
    required this.orderIndex,
    required this.strokeOrder,
    required this.exampleWord,
    required this.exampleRomaji,
    required this.exampleMeaning,
    required this.mnemonic,
    required this.learningTip,
    this.commonConfusion,
  });

  /// The kana character (e.g., "あ" or "ア").
  final String character;

  /// Romaji pronunciation (e.g., "a", "ka", "shi").
  final String romaji;

  /// Whether this is hiragana or katakana.
  final KanaType type;

  /// The category grouping (basic, dakuten, handakuten, yōon).
  final KanaCategory category;

  /// The order in which this character should be learned.
  final int orderIndex;

  /// Stroke order steps as a list of descriptions.
  final List<String> strokeOrder;

  /// Example Japanese word using this character.
  final String exampleWord;

  /// Romaji reading of the example word.
  final String exampleRomaji;

  /// English meaning of the example word.
  final String exampleMeaning;

  /// Memory aid to help remember this character.
  final String mnemonic;

  /// Helpful tip for learning this character.
  final String learningTip;

  /// Common characters this might be confused with.
  final String? commonConfusion;

  /// Create a [Kana] from a JSON map.
  factory Kana.fromJson(Map<String, dynamic> json, KanaType type) {
    return Kana(
      character: json['character'] as String,
      romaji: json['romaji'] as String,
      type: type,
      category: KanaCategory.values.firstWhere(
        (c) => c.name == json['category'],
      ),
      orderIndex: json['orderIndex'] as int,
      strokeOrder: List<String>.from(json['strokeOrder'] as List),
      exampleWord: json['exampleWord'] as String,
      exampleRomaji: json['exampleRomaji'] as String,
      exampleMeaning: json['exampleMeaning'] as String,
      mnemonic: json['mnemonic'] as String,
      learningTip: json['learningTip'] as String,
      commonConfusion: json['commonConfusion'] as String?,
    );
  }

  /// Convert this [Kana] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'character': character,
      'romaji': romaji,
      'category': category.name,
      'orderIndex': orderIndex,
      'strokeOrder': strokeOrder,
      'exampleWord': exampleWord,
      'exampleRomaji': exampleRomaji,
      'exampleMeaning': exampleMeaning,
      'mnemonic': mnemonic,
      'learningTip': learningTip,
      'commonConfusion': commonConfusion,
    };
  }

  @override
  String toString() => 'Kana($character, $romaji)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Kana &&
          character == other.character &&
          type == other.type;

  @override
  int get hashCode => character.hashCode ^ type.hashCode;
}

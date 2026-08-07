/// The category grouping for a kana character.
enum KanaCategory {
  /// Basic vowels and consonant-vowel pairs (e.g., あ, か, さ)
  basic,

  /// Dakuten (voiced) variants (e.g., が, ざ, だ)
  dakuten,

  /// Handakuten (semi-voiced) variants (e.g., ぱ, ぴ, ぷ)
  handakuten,

  /// Combination characters / Yōon (e.g., きゃ, しゅ, ちょ)
  yoon;

  /// Human-readable display name.
  String get displayName {
    switch (this) {
      case KanaCategory.basic:
        return 'Basic';
      case KanaCategory.dakuten:
        return 'Dakuten';
      case KanaCategory.handakuten:
        return 'Handakuten';
      case KanaCategory.yoon:
        return 'Yōon';
    }
  }

  /// Short description of this category.
  String get description {
    switch (this) {
      case KanaCategory.basic:
        return 'Vowels and basic consonant pairs';
      case KanaCategory.dakuten:
        return 'Voiced consonant variants';
      case KanaCategory.handakuten:
        return 'Semi-voiced consonant variants';
      case KanaCategory.yoon:
        return 'Combination characters';
    }
  }
}

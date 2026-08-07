/// The writing system type for a kana character.
enum KanaType {
  /// Japanese Hiragana (ひらがな)
  hiragana,

  /// Japanese Katakana (カタカナ)
  katakana;

  /// Human-readable display name.
  String get displayName {
    switch (this) {
      case KanaType.hiragana:
        return 'Hiragana';
      case KanaType.katakana:
        return 'Katakana';
    }
  }
}

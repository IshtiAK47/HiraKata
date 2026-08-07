/// Tracks learning progress for a single kana character.
class LearningProgress {
  const LearningProgress({
    required this.character,
    this.isLearned = false,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.lastPracticedAt,
  });

  /// The kana character this progress tracks.
  final String character;

  /// Whether the user has completed the lesson for this character.
  final bool isLearned;

  /// Number of correct practice answers.
  final int correctCount;

  /// Number of incorrect practice answers.
  final int incorrectCount;

  /// When this character was last practiced.
  final DateTime? lastPracticedAt;

  /// Accuracy as a percentage (0.0 – 1.0).
  double get accuracy {
    final total = correctCount + incorrectCount;
    if (total == 0) return 0.0;
    return correctCount / total;
  }

  /// Total number of practice attempts.
  int get totalAttempts => correctCount + incorrectCount;

  /// Create a copy with updated fields.
  LearningProgress copyWith({
    bool? isLearned,
    int? correctCount,
    int? incorrectCount,
    DateTime? lastPracticedAt,
  }) {
    return LearningProgress(
      character: character,
      isLearned: isLearned ?? this.isLearned,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      lastPracticedAt: lastPracticedAt ?? this.lastPracticedAt,
    );
  }

  /// Create from JSON.
  factory LearningProgress.fromJson(Map<String, dynamic> json) {
    return LearningProgress(
      character: json['character'] as String,
      isLearned: json['isLearned'] as bool? ?? false,
      correctCount: json['correctCount'] as int? ?? 0,
      incorrectCount: json['incorrectCount'] as int? ?? 0,
      lastPracticedAt: json['lastPracticedAt'] != null
          ? DateTime.parse(json['lastPracticedAt'] as String)
          : null,
    );
  }

  /// Convert to JSON.
  Map<String, dynamic> toJson() {
    return {
      'character': character,
      'isLearned': isLearned,
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'lastPracticedAt': lastPracticedAt?.toIso8601String(),
    };
  }
}

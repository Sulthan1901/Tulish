class History {
  final int? id;
  final int? wordId;
  final String wordText;
  final DateTime searchedAt;

  const History({
    this.id,
    this.wordId,
    required this.wordText,
    required this.searchedAt,
  });

  factory History.fromMap(Map<String, dynamic> map) {
    return History(
      id: map['id'] as int?,
      wordId: map['word_id'] as int?,
      wordText: map['word_text'] as String,
      searchedAt: DateTime.parse(map['searched_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word_id': wordId,
      'word_text': wordText,
      'searched_at': searchedAt.toIso8601String(),
    };
  }
}

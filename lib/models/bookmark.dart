class Bookmark {
  final int? id;
  final int? wordId;
  final String wordText;
  final String? definition;
  final String? partOfSpeech;
  final DateTime addedAt;

  const Bookmark({
    this.id,
    this.wordId,
    required this.wordText,
    this.definition,
    this.partOfSpeech,
    required this.addedAt,
  });

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as int?,
      wordId: map['word_id'] as int?,
      wordText: map['word_text'] as String,
      definition: map['definition'] as String?,
      partOfSpeech: map['part_of_speech'] as String?,
      addedAt: DateTime.parse(map['added_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word_id': wordId,
      'word_text': wordText,
      'definition': definition,
      'part_of_speech': partOfSpeech,
      'added_at': addedAt.toIso8601String(),
    };
  }
}

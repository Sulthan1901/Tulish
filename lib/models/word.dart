class Word {
  final int? id;
  final String word;
  final String? partOfSpeech;
  final String definition;
  final String? example;
  final String? synonyms;
  final String? antonyms;
  final String? etymology;

  const Word({
    this.id,
    required this.word,
    this.partOfSpeech,
    required this.definition,
    this.example,
    this.synonyms,
    this.antonyms,
    this.etymology,
  });

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'] as int?,
      word: map['word'] as String,
      partOfSpeech: map['part_of_speech'] as String?,
      definition: map['definition'] as String,
      example: map['example'] as String?,
      synonyms: map['synonyms'] as String?,
      antonyms: map['antonyms'] as String?,
      etymology: map['etymology'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'part_of_speech': partOfSpeech,
      'definition': definition,
      'example': example,
      'synonyms': synonyms,
      'antonyms': antonyms,
      'etymology': etymology,
    };
  }

  List<String> get synonymsList {
    if (synonyms == null || synonyms!.isEmpty) return [];
    return synonyms!.split(',').map((e) => e.trim()).toList();
  }

  List<String> get antonymsList {
    if (antonyms == null || antonyms!.isEmpty) return [];
    return antonyms!.split(',').map((e) => e.trim()).toList();
  }
}

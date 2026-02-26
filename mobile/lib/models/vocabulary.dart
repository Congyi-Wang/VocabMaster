class VocabularyEntry {
  final String word;
  final String pronunciation;
  final String meaning;
  final String exampleSentence;

  VocabularyEntry({
    required this.word,
    this.pronunciation = '',
    this.meaning = '',
    this.exampleSentence = '',
  });

  factory VocabularyEntry.fromJson(Map<String, dynamic> json) {
    return VocabularyEntry(
      word: json['word'] ?? '',
      pronunciation: json['pronunciation'] ?? '',
      meaning: json['meaning'] ?? '',
      exampleSentence: json['example_sentence'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'word': word,
        'pronunciation': pronunciation,
        'meaning': meaning,
        'example_sentence': exampleSentence,
      };
}

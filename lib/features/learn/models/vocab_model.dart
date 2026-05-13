class VocabModel {
  final String id;
  final String word;
  final String meaning;
  final String pronunciation;
  final String type;
  final String exampleSentence;
  final String audioUrl;
  bool isFavorite;

  VocabModel({
    required this.id,
    required this.word,
    required this.meaning,
    required this.pronunciation,
    required this.type,
    this.exampleSentence = '',
    this.audioUrl = '',
    this.isFavorite = false,
  });

  factory VocabModel.fromJson(Map<String, dynamic> json) {
    return VocabModel(
      id: json['id']?.toString() ?? '',
      word: json['word'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      pronunciation: json['pronunciation'] as String? ?? '',
      type: json['type'] as String? ?? '',
      exampleSentence: json['example_sentence'] as String? ?? '',
      audioUrl: json['audio_url'] as String? ?? '',
    );
  }
}

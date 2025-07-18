class Letter {
  final int id;
  final String character;
  final String pronunciation;
  final String example;
  final String translation;
  final String? audioUrl;

  Letter({
    required this.id,
    required this.character,
    required this.pronunciation,
    required this.example,
    required this.translation,
    this.audioUrl,
  });

  factory Letter.fromJson(Map<String, dynamic> json) {
    return Letter(
      id: json['id'],
      character: json['character'],
      pronunciation: json['pronunciation'],
      example: json['example'],
      translation: json['translation'],
      audioUrl: json['audio_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'character': character,
      'pronunciation': pronunciation,
      'example': example,
      'translation': translation,
      'audio_url': audioUrl,
    };
  }

  factory Letter.fromMap(Map<String, dynamic> map) {
    return Letter(
      id: map['id'],
      character: map['character'],
      pronunciation: map['pronunciation'],
      example: map['example'],
      translation: map['translation'],
      audioUrl: map['audio_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'character': character,
      'pronunciation': pronunciation,
      'example': example,
      'translation': translation,
      'audio_url': audioUrl,
    };
  }
}

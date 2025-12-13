class TextToMp3AudioFile {
  final String id;
  final String text;
  final String filePath;
  final DateTime createdAt;
  final int sizeBytes;

  TextToMp3AudioFile({
    required this.id,
    required this.text,
    required this.filePath,
    required this.createdAt,
    required this.sizeBytes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'sizeBytes': sizeBytes,
    };
  }

  factory TextToMp3AudioFile.fromJson(Map<String, dynamic> json) {
    return TextToMp3AudioFile(
      id: json['id'],
      text: json['text'],
      filePath: json['filePath'],
      createdAt: DateTime.parse(json['createdAt']),
      sizeBytes: json['sizeBytes'] ?? 0,
    );
  }

  String get sizeFormatted {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

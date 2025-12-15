// lib/models/audio_segment.dart
class AudioSegment {
  final double startPosition;
  final double endPosition;
  final double silenceDuration;
  final String title; // ← required

  AudioSegment({
    required this.startPosition,
    required this.endPosition,
    this.silenceDuration = 0.0,
    required this.title, // ← required
  });

  double get duration => endPosition - startPosition;

  AudioSegment copyWith({
    double? startPosition,
    double? endPosition,
    double? silenceDuration,
    String? title,
  }) {
    return AudioSegment(
      startPosition: startPosition ?? this.startPosition,
      endPosition: endPosition ?? this.endPosition,
      silenceDuration: silenceDuration ?? this.silenceDuration,
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toMap() => {
        'startPosition': startPosition,
        'endPosition': endPosition,
        'silenceDuration': silenceDuration,
        'title': title,
      };

  factory AudioSegment.fromMap(Map<String, dynamic> map) {
    return AudioSegment(
      startPosition: (map['startPosition'] as num).toDouble(),
      endPosition: (map['endPosition'] as num).toDouble(),
      silenceDuration: (map['silenceDuration'] as num?)?.toDouble() ?? 0.0,
      title: (map['title'] as String?)?.trim().isNotEmpty == true
          ? (map['title'] as String).trim()
          : 'Untitled segment', // hard fallback to keep non-null
    );
  }
}

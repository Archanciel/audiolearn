// lib/models/audio_segment.dart
class AudioSegment {
  final double startPosition;
  final double endPosition;
  final double silenceDuration;
  final double soundReductionPosition;
  final double soundReductionDuration;
  final String title;

  AudioSegment({
    required this.startPosition,
    required this.endPosition,
    this.silenceDuration = 0.0,
    this.soundReductionPosition = 0.0,
    this.soundReductionDuration = 0.0,
    required this.title,
  });

  double get duration => endPosition - startPosition;

  AudioSegment copyWith({
    double? startPosition,
    double? endPosition,
    double? silenceDuration,
    double? soundReductionPosition,
    double? soundReductionDuration,
    String? title,
  }) {
    return AudioSegment(
      startPosition: startPosition ?? this.startPosition,
      endPosition: endPosition ?? this.endPosition,
      silenceDuration: silenceDuration ?? this.silenceDuration,
      soundReductionPosition: soundReductionPosition ?? this.soundReductionPosition,
      soundReductionDuration: soundReductionDuration ?? this.soundReductionDuration,
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toMap() => {
        'startPosition': startPosition,
        'endPosition': endPosition,
        'silenceDuration': silenceDuration,
        'soundReductionPosition': soundReductionPosition,
        'soundReductionDuration': soundReductionDuration,
        'title': title,
      };

  factory AudioSegment.fromMap(Map<String, dynamic> map) {
    return AudioSegment(
      startPosition: (map['startPosition'] as num).toDouble(),
      endPosition: (map['endPosition'] as num).toDouble(),
      silenceDuration: (map['silenceDuration'] as num?)?.toDouble() ?? 0.0,
      soundReductionPosition: (map['soundReductionPosition'] as num?)?.toDouble() ?? 0.0,
      soundReductionDuration: (map['soundReductionDuration'] as num?)?.toDouble() ?? 0.0,
      title: (map['title'] as String?)?.trim().isNotEmpty == true
          ? (map['title'] as String).trim()
          : 'Untitled segment', // hard fallback to keep non-null
    );
  }
}

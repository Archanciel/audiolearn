// lib/models/audio_segment.dart
class AudioSegment {
  final double startPosition;
  final double endPosition;
  final double silenceDuration;
  final double fadeInDuration; // NEW: Fade-in at segment start (volume 0→100%)
  final double soundReductionPosition;
  final double soundReductionDuration;
  final String title;
  bool deleted; // NEW: Mark segment as deleted

  AudioSegment({
    required this.startPosition,
    required this.endPosition,
    this.silenceDuration = 0.0,
    this.fadeInDuration = 0.0, // NEW: Default no fade-in
    this.soundReductionPosition = 0.0,
    this.soundReductionDuration = 0.0,
    required this.title,
    this.deleted = false, // NEW: Default not deleted
  });

  double get duration => endPosition - startPosition;

  AudioSegment copyWith({
    double? startPosition,
    double? endPosition,
    double? silenceDuration,
    double? fadeInDuration, // NEW
    double? soundReductionPosition,
    double? soundReductionDuration,
    String? title,
    bool? deleted, // NEW
  }) {
    return AudioSegment(
      startPosition: startPosition ?? this.startPosition,
      endPosition: endPosition ?? this.endPosition,
      silenceDuration: silenceDuration ?? this.silenceDuration,
      fadeInDuration: fadeInDuration ?? this.fadeInDuration, // NEW
      soundReductionPosition:
          soundReductionPosition ?? this.soundReductionPosition,
      soundReductionDuration:
          soundReductionDuration ?? this.soundReductionDuration,
      title: title ?? this.title,
      deleted: deleted ?? this.deleted, // NEW
    );
  }

  Map<String, dynamic> toMap() => {
        'startPosition': startPosition,
        'endPosition': endPosition,
        'silenceDuration': silenceDuration,
        'fadeInDuration': fadeInDuration, // NEW
        'soundReductionPosition': soundReductionPosition,
        'soundReductionDuration': soundReductionDuration,
        'title': title,
        'deleted': deleted, // NEW
      };

  factory AudioSegment.fromMap(Map<String, dynamic> map) {
    return AudioSegment(
      startPosition: (map['startPosition'] as num).toDouble(),
      endPosition: (map['endPosition'] as num).toDouble(),
      silenceDuration: (map['silenceDuration'] as num?)?.toDouble() ?? 0.0,
      fadeInDuration: (map['fadeInDuration'] as num?)?.toDouble() ?? 0.0, // NEW
      soundReductionPosition:
          (map['soundReductionPosition'] as num?)?.toDouble() ?? 0.0,
      soundReductionDuration:
          (map['soundReductionDuration'] as num?)?.toDouble() ?? 0.0,
      title: (map['title'] as String?)?.trim().isNotEmpty == true
          ? (map['title'] as String).trim()
          : 'Untitled segment',
      deleted: (map['deleted'] as bool?) ?? false, // NEW
    );
  }
}

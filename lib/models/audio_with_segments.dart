// lib/models/audio_with_segments.dart
import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/models/audio_segment.dart';

/// Groups an Audio with its segments for multi-audio extraction
class AudioWithSegments {
  final Audio audio;
  final List<AudioSegment> segments;
  final double gainDb; // Optional volume adjustment for this audio

  AudioWithSegments({
    required this.audio,
    required this.segments,
    this.gainDb = 0.0,
  });

  /// Get total duration of all segments in this audio (including silence)
  double get totalDuration {
    return segments.where((s) => !s.deleted).fold(
          0.0,
          (sum, s) =>
              sum +
              (s.endPosition - s.startPosition) / s.playSpeed +
              s.silenceDuration,
        );
  }

  /// Get count of non-deleted segments
  int get activeSegmentCount => segments.where((s) => !s.deleted).length;

  AudioWithSegments copyWith({
    Audio? audio,
    List<AudioSegment>? segments,
    double? gainDb,
  }) {
    return AudioWithSegments(
      audio: audio ?? this.audio,
      segments: segments ?? this.segments,
      gainDb: gainDb ?? this.gainDb,
    );
  }
}
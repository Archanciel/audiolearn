// lib/viewmodels/audio_extractor_vm.dart
import 'package:flutter/foundation.dart';

import '../models/extract_mp3_audio_file.dart';
import '../models/audio_segment.dart';
import '../models/extraction_result.dart';
import '../services/audio_extractor_service.dart';
import '../utils/time_format_util.dart';

class AudioExtractorVM extends ChangeNotifier {
  // ── Single-file mode (unchanged) ────────────────────────────────────────────
  ExtractMp3AudioFile _audioFile = ExtractMp3AudioFile();
  final List<AudioSegment> _segments = [];
  ExtractionResult _extractionResult = ExtractionResult.initial();

  ExtractMp3AudioFile get audioFile => _audioFile;
  List<AudioSegment> get segments => List.unmodifiable(_segments);
  ExtractionResult get extractionResult => _extractionResult;

  double get totalDuration {
    return _segments.fold(
      0.0,
      (sum, s) =>
          sum +
          TimeFormatUtil.normalizeToTenths(s.duration) +
          TimeFormatUtil.normalizeToTenths(s.silenceDuration),
    );
  }

  int get segmentCount => _segments.length;

  void setAudioFile({
    required String path,
    required String name,
    required double duration,
  }) {
    _audioFile = ExtractMp3AudioFile(
      path: path,
      name: name,
      duration: duration,
    );
    _segments.clear();
    _extractionResult = ExtractionResult(
      status: ExtractionStatus.none,
      message: 'File selected: $name',
    );
    notifyListeners();
  }

  void addSegment(AudioSegment segment) {
    final normalized = AudioSegment(
      startPosition: TimeFormatUtil.normalizeToTenths(
        segment.startPosition,
      ),
      endPosition: TimeFormatUtil.normalizeToTenths(
        segment.endPosition,
      ),
      silenceDuration: TimeFormatUtil.normalizeToTenths(
        segment.silenceDuration,
      ),
      title: segment.title,
    );
    _segments.add(normalized);
    notifyListeners();
  }

  void updateSegment(int index, AudioSegment segment) {
    if (index >= 0 && index < _segments.length) {
      final normalized = AudioSegment(
        startPosition: TimeFormatUtil.normalizeToTenths(
          segment.startPosition,
        ),
        endPosition: TimeFormatUtil.normalizeToTenths(
          segment.endPosition,
        ),
        silenceDuration: TimeFormatUtil.normalizeToTenths(
          segment.silenceDuration,
        ),
        title: segment.title,
      );
      _segments[index] = normalized;
      notifyListeners();
    }
  }

  void removeSegment(int index) {
    if (index >= 0 && index < _segments.length) {
      _segments.removeAt(index);
      notifyListeners();
    }
  }

  void clearSegments() {
    _segments.clear();
    notifyListeners();
  }

  void setError(String errorMessage) {
    _extractionResult = ExtractionResult.error(errorMessage);
    notifyListeners();
  }

  void startProcessing() {
    _extractionResult = ExtractionResult.processing();
    notifyListeners();
  }

  Future<void> extractMP3({
    required bool inMusicQuality,
    required String outputPath,
  }) async {
    if (_audioFile.path == null) {
      _extractionResult = ExtractionResult.error(
        'Please select an MP3 file first',
      );
      notifyListeners();
      return;
    }

    if (_segments.isEmpty) {
      _extractionResult = ExtractionResult.error(
        'Please add at least one segment to extract',
      );
      notifyListeners();
      return;
    }

    try {
      startProcessing();

      final result = await AudioExtractorService.extractAudioSegments(
        inputPath: _audioFile.path!,
        outputPath: outputPath,
        segments: _segments,
        inMusicQuality: inMusicQuality,
      );

      if (result['success'] == true) {
        _extractionResult = ExtractionResult.success(
          result['outputPath']!,
        );
      } else {
        _extractionResult = ExtractionResult.error(result['message']);
      }
      notifyListeners();
    } catch (e) {
      _extractionResult = ExtractionResult.error(
        'Error during extraction: $e',
      );
      notifyListeners();
    }
  }

  void resetExtractionResult() {
    _extractionResult = ExtractionResult.initial();
    notifyListeners();
  }

  // ── Multi-input mode (with per-input gain) ─────────────────────────────────
  final List<InputSegments> _multiInputs = [];
  List<InputSegments> get multiInputs => List.unmodifiable(_multiInputs);
  bool get hasMultipleSources => _multiInputs.length > 1;

  void clearMultiInputs() {
    _multiInputs.clear();
    notifyListeners();
  }

  void addMultiInput({
    required String inputPath,
    required List<AudioSegment> segments,
    double gainDb = 0.0,
  }) {
    final normalized = segments
        .map(
          (s) => AudioSegment(
            startPosition: TimeFormatUtil.normalizeToTenths(
              s.startPosition,
            ),
            endPosition: TimeFormatUtil.normalizeToTenths(
              s.endPosition,
            ),
            silenceDuration: TimeFormatUtil.normalizeToTenths(
              s.silenceDuration,
            ),
            title: s.title,
          ),
        )
        .toList();

    _multiInputs.add(
      InputSegments(
        inputPath: inputPath,
        segments: normalized,
        gainDb: gainDb,
      ),
    );
    notifyListeners();
  }

  void updateMultiInput(
    int index, {
    String? inputPath,
    List<AudioSegment>? segments,
    double? gainDb,
  }) {
    if (index < 0 || index >= _multiInputs.length) return;
    final cur = _multiInputs[index];
    _multiInputs[index] = InputSegments(
      inputPath: inputPath ?? cur.inputPath,
      segments: segments ?? cur.segments,
      gainDb: gainDb ?? cur.gainDb,
    );
    notifyListeners();
  }

  void updateMultiInputGain(int index, double gainDb) {
    if (index < 0 || index >= _multiInputs.length) return;
    final cur = _multiInputs[index];
    _multiInputs[index] = cur.copyWith(gainDb: gainDb);
    notifyListeners();
  }

  void updateMultiInputSegments(
    int index,
    List<AudioSegment> segments,
  ) {
    if (index < 0 || index >= _multiInputs.length) return;
    final normalized = segments
        .map(
          (s) => AudioSegment(
            startPosition: TimeFormatUtil.normalizeToTenths(
              s.startPosition,
            ),
            endPosition: TimeFormatUtil.normalizeToTenths(
              s.endPosition,
            ),
            silenceDuration: TimeFormatUtil.normalizeToTenths(
              s.silenceDuration,
            ),
            title: s.title,
          ),
        )
        .toList();
    final cur = _multiInputs[index];
    _multiInputs[index] = cur.copyWith(segments: normalized);
    notifyListeners();
  }

  void removeMultiInput(int index) {
    if (index < 0 || index >= _multiInputs.length) return;
    _multiInputs.removeAt(index);
    notifyListeners();
  }

  double get totalDurationMulti {
    double sum = 0.0;
    for (final inp in _multiInputs) {
      for (final s in inp.segments) {
        sum += TimeFormatUtil.normalizeToTenths(s.duration) +
            TimeFormatUtil.normalizeToTenths(s.silenceDuration);
      }
    }
    return sum;
  }

  Future<void> extractMP3Multi(String outputPath) async {
    if (_multiInputs.isEmpty) {
      _extractionResult = ExtractionResult.error(
        'Please add at least one source',
      );
      notifyListeners();
      return;
    }
    try {
      startProcessing();
      final result = await AudioExtractorService.extractFromMultipleInputs(
        inputs: _multiInputs,
        outputPath: outputPath,
      );
      if (result['success'] == true) {
        _extractionResult = ExtractionResult.success(
          result['outputPath']!,
        );
      } else {
        _extractionResult = ExtractionResult.error(result['message']);
      }
      notifyListeners();
    } catch (e) {
      _extractionResult = ExtractionResult.error(
        'Error during multi extraction: $e',
      );
      notifyListeners();
    }
  }
}

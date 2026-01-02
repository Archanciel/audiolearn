// lib/viewmodels/audio_extractor_vm.dart
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/audio.dart';
import '../models/comment.dart';
import '../models/extract_mp3_audio_file.dart';
import '../models/audio_segment.dart';
import '../models/extraction_result.dart';
import '../models/playlist.dart';
import '../services/audio_extractor_service.dart';
import '../utils/time_format_util.dart';
import 'audio_download_vm.dart';
import 'comment_vm.dart';

class AudioExtractorVM extends ChangeNotifier {
  // ── Single-file mode (unchanged) ────────────────────────────────────────────
  ExtractMp3AudioFile _audioFile = ExtractMp3AudioFile();
  ExtractMp3AudioFile get audioFile => _audioFile;

  final List<AudioSegment> _segments = [];
  List<AudioSegment> get segments => List.unmodifiable(_segments);

  ExtractionResult _extractionResult = ExtractionResult.initial();
  ExtractionResult get extractionResult => _extractionResult;

  late Audio _currentAudio;
  set currentAudio(Audio audio) {
    _currentAudio = audio;
  }

  late CommentVM _commentVMlistenTrue;
  set commentVMlistenTrue(CommentVM commentVMlistenTrue) {
    _commentVMlistenTrue = commentVMlistenTrue;
  }

  late List<Comment> _commentsLst;
  set commentsLst(List<Comment> commentsLst) {
    _commentsLst = commentsLst;
  }

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
      fadeInDuration: TimeFormatUtil.normalizeToTenths(
        // NEW
        segment.fadeInDuration,
      ),
      soundReductionPosition: TimeFormatUtil.normalizeToTenths(
        segment.soundReductionPosition,
      ),
      soundReductionDuration: TimeFormatUtil.normalizeToTenths(
        segment.soundReductionDuration,
      ),
      commentId: segment.commentId,
      commentTitle: segment.commentTitle,
      deleted: segment.deleted,
    );
    _segments.add(normalized);

    notifyListeners();
  }

  void updateSegment({
    required int index,
    required AudioSegment segment,
  }) {
    if (index >= 0 && index < _segments.length) {
      final AudioSegment normalizedSegment = AudioSegment(
        startPosition: TimeFormatUtil.normalizeToTenths(
          segment.startPosition,
        ),
        endPosition: TimeFormatUtil.normalizeToTenths(
          segment.endPosition,
        ),
        silenceDuration: TimeFormatUtil.normalizeToTenths(
          segment.silenceDuration,
        ),
        fadeInDuration: TimeFormatUtil.normalizeToTenths(
          // NEW
          segment.fadeInDuration,
        ),
        soundReductionPosition: TimeFormatUtil.normalizeToTenths(
          segment.soundReductionPosition,
        ),
        soundReductionDuration: TimeFormatUtil.normalizeToTenths(
          segment.soundReductionDuration,
        ),
        commentId: segment.commentId,
        commentTitle: segment.commentTitle,
        deleted: segment.deleted,
      );

      _segments[index] = normalizedSegment;

      // Updating the corresponding comment

      Comment comment = _commentsLst.firstWhere(
        (c) => c.id == normalizedSegment.commentId,
      );
      comment.lastUpdateDateTime = DateTime.now();
      comment.title = normalizedSegment.commentTitle;
      comment.commentStartPositionInTenthOfSeconds =
          (normalizedSegment.startPosition * 10).toInt();
      comment.commentEndPositionInTenthOfSeconds =
          (normalizedSegment.endPosition * 10).toInt();
      comment.silenceDuration = normalizedSegment.silenceDuration;
      comment.fadeInDuration = normalizedSegment.fadeInDuration;
      comment.soundReductionPosition = normalizedSegment.soundReductionPosition;
      comment.soundReductionDuration = normalizedSegment.soundReductionDuration;
      comment.deleted = normalizedSegment.deleted;

      _commentVMlistenTrue.updateAudioComments(
        commentedAudio: _currentAudio,
        updateCommentsLst: _commentsLst,
      );

      notifyListeners();
    }
  }

  void removeSegment({
    required int segmentToRemoveIndex,
  }) {
    if (segmentToRemoveIndex >= 0 && segmentToRemoveIndex < _segments.length) {
      AudioSegment removedSegment = _segments[segmentToRemoveIndex];
      removedSegment.deleted = true;

      // Updating the corresponding comment
      updateSegment(
        index: segmentToRemoveIndex,
        segment: removedSegment,
      );

      _segments.removeAt(segmentToRemoveIndex);

      notifyListeners();
    }
  }

  void clearAllSegments() {
    int index = 0;

    for (final segment in _segments) {
      segment.deleted = true;
      updateSegment(
        index: index,
        segment: segment,
      );
      index++;
    }

    _segments.clear();

    notifyListeners();
  }

  void setError(String errorMessage) {
    _extractionResult = ExtractionResult.error(errorMessage);
    notifyListeners();
  }

  Future<void> extractMP3ToDirectory({
    required bool inMusicQuality,
    required String outputPath,
  }) async {
    try {
      // Necessary so that the CircularProgressIndicator is displayed
      // in the audio extractor dialog
      startProcessing();

      final Map<String, dynamic> result =
          await AudioExtractorService.extractAudioSegments(
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

  /// True is returned when the extracted audio file is added to the
  /// target playlist, false otherwise. False is returned if the audio
  /// file to add already exists in the target playlist directory.
  Future<bool> extractMP3ToPlaylist({
    required AudioDownloadVM audioDownloadVMlistenFalse,
    required Audio currentAudio,
    required Playlist targetPlaylist,
    required String extractedMp3FileName,
    required bool inMusicQuality,
    required double totalDuration,
  }) async {
    try {
      // Necessary so that the CircularProgressIndicator is displayed
      // in the audio extractor dialog
      startProcessing();

      final String outputPath =
          '${targetPlaylist.downloadPath}${Platform.pathSeparator}$extractedMp3FileName';
      final File outputFile = File(outputPath);

      if (outputFile.existsSync()) {
        // the case if the audio file to add already exist in the target
        // playlist directory
        return false;
      }

      final Map<String, dynamic> result =
          await AudioExtractorService.extractAudioSegments(
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

    await audioDownloadVMlistenFalse.addExtractedAudioFileToPlaylist(
      currentAudio: currentAudio,
      targetPlaylist: targetPlaylist,
      filePathNameToAdd:
          '${targetPlaylist.downloadPath}${Platform.pathSeparator}$extractedMp3FileName',
      inMusicQuality: inMusicQuality,
      totalDuration: totalDuration,
    );

    return true;
  }

  /// Enables to display the CircularProgressIndicator in the audio extractor dialog.
  void startProcessing() {
    _extractionResult = ExtractionResult.processing();
    notifyListeners();
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
            fadeInDuration: TimeFormatUtil.normalizeToTenths(
              // NEW
              s.fadeInDuration,
            ),
            soundReductionPosition: TimeFormatUtil.normalizeToTenths(
              s.soundReductionPosition,
            ),
            soundReductionDuration: TimeFormatUtil.normalizeToTenths(
              s.soundReductionDuration,
            ),
            commentId: s.commentId,
            commentTitle: s.commentTitle,
            deleted: s.deleted,
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
            fadeInDuration: TimeFormatUtil.normalizeToTenths(
              // NEW
              s.fadeInDuration,
            ),
            soundReductionPosition: TimeFormatUtil.normalizeToTenths(
              s.soundReductionPosition,
            ),
            soundReductionDuration: TimeFormatUtil.normalizeToTenths(
              s.soundReductionDuration,
            ),
            commentId: s.commentId,
            commentTitle: s.commentTitle,
            deleted: s.deleted,
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
      // Necessary so that the CircularProgressIndicator is displayed
      // in the audio extractor dialog
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

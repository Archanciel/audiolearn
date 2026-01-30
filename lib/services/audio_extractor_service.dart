// lib/services/audio_extractor_service.dart
import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_session.dart';
import 'package:logger/logger.dart';

// Android/iOS via plugin
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

import '../models/audio_segment.dart';
import '../constants.dart'; // for kDefaultSilenceDurationBetweenMp3

/// Represents one input file with its segments and an optional gain (in dB).
class InputSegments {
  final String inputPath;
  final List<AudioSegment> segments;
  final double gainDb; // 0.0 means no change

  const InputSegments({
    required this.inputPath,
    required this.segments,
    this.gainDb = 0.0,
  });

  InputSegments copyWith({
    String? inputPath,
    List<AudioSegment>? segments,
    double? gainDb,
  }) {
    return InputSegments(
      inputPath: inputPath ?? this.inputPath,
      segments: segments ?? this.segments,
      gainDb: gainDb ?? this.gainDb,
    );
  }
}

class AudioExtractorService {
  static final Logger logger = Logger();

  /// Default silence (seconds) appended between segments when user did not
  /// specify any. Can be zero to have no silence by default.
  static const double defaultSilenceDuration = 0.0;

  // ────────────────────────────────────────────────────────────────────────────
  // Helper: Build audio filter for fade-out
  // ────────────────────────────────────────────────────────────────────────────

  /// Builds an audio filter string for FFmpeg (fade and volume only).
  ///
  /// Parameters:
  /// - segment: The audio segment with fade parameters
  /// - gainDb: Optional volume gain in dB (0.0 = no change)
  ///
  /// Returns a filter string like "volume=3dB,afade=t=out:st=50:d=10"
  /// or empty string if no filters needed.
  ///
  /// NOTE: Timestamp reset (asetpts) is handled separately in the main filter chain
  /// when using atrim, so we don't include it here.
  static String _buildAudioFilter({
    required AudioSegment segment,
    double gainDb = 0.0,
  }) {
    final List<String> filters = [];

    // Add volume filter if gain is specified
    if (gainDb.abs() > 1e-6) {
      filters.add('volume=${gainDb}dB');
    }

    // Add fade-out filter if BOTH position AND duration are meaningfully set
    const double threshold = 0.05;

    if (segment.soundReductionDuration > threshold &&
        segment.soundReductionPosition > threshold) {
      // Calculate relative position of fade start within the segment
      final segmentDuration = segment.endPosition - segment.startPosition;
      final fadeStartRelative =
          segment.soundReductionPosition - segment.startPosition;

      // Validate fade parameters
      if (fadeStartRelative >= -threshold &&
          fadeStartRelative < segmentDuration) {
        final fadeDuration = segment.soundReductionDuration;

        // Ensure fade doesn't extend beyond segment end
        final maxFadeDuration = segmentDuration - fadeStartRelative;
        final actualFadeDuration =
            fadeDuration > maxFadeDuration ? maxFadeDuration : fadeDuration;

        if (actualFadeDuration > threshold) {
          // Ensure fadeStartRelative is not negative (clamp to 0)
          final safeStartRelative =
              fadeStartRelative < 0 ? 0.0 : fadeStartRelative;

          // Format with precision to avoid rounding issues
          final stStr = safeStartRelative.toStringAsFixed(3);
          final dStr = actualFadeDuration.toStringAsFixed(3);
          filters.add('afade=t=out:st=$stStr:d=$dStr');

          logger.i(
            'Fade-out: st=$stStr d=$dStr (segment ${segment.startPosition}-${segment.endPosition})',
          );
        }
      } else {
        logger.w(
          'Invalid fade: fadeStart=$fadeStartRelative segDur=$segmentDuration',
        );
      }
    }

    return filters.isEmpty ? '' : filters.join(',');
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Duration
  // ────────────────────────────────────────────────────────────────────────────

  /// Returns media duration in seconds.
  static Future<double> getAudioDuration({
    required String filePath,
  }) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final session = await FFprobeKit.getMediaInformation(
          filePath,
        );
        final info = session.getMediaInformation();
        final durationStr = info?.getDuration();
        if (durationStr != null) {
          final d = double.tryParse(durationStr);
          if (d != null && d > 0) return d;
        }
        logger.w(
          'FFprobeKit no duration for "$filePath", fallback to 60s',
        );
        return 60.0;
      } else {
        return await _probeDurationDesktop(filePath: filePath);
      }
    } catch (e, st) {
      logger.w('Duration probe failed for "$filePath": $e\n$st');
      return 60.0;
    }
  }

  static Future<double> _probeDurationDesktop({
    required String filePath,
  }) async {
    final args = [
      '-i',
      filePath,
      '-v',
      'quiet',
      '-show_entries',
      'format=duration',
      '-of',
      'default=noprint_wrappers=1:nokey=1',
    ];
    final r = await Process.run('ffprobe', args);
    if (r.exitCode == 0) {
      final out = (r.stdout as String).trim();
      final d = double.tryParse(out);
      if (d != null && d > 0) return d;
    }
    return 60.0;
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Single segment extract
  // ────────────────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> extractAudio({
    required String inputPath,
    required String outputPath,
    required double startTime,
    required double endTime,
    String? encoderBitrate,
  }) async {
    if (endTime <= startTime) {
      return {
        'success': false,
        'message': 'Invalid time range: end <= start',
        'outputPath': null,
      };
    }

    final bitrate = encoderBitrate ?? '128k';

    if (Platform.isAndroid || Platform.isIOS) {
      return _extractOneMobile(
        inputPath: inputPath,
        outputPath: outputPath,
        startTime: startTime,
        endTime: endTime,
        encoderBitrate: bitrate,
      );
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return _extractOneDesktop(
        inputPath: inputPath,
        outputPath: outputPath,
        startTime: startTime,
        endTime: endTime,
        encoderBitrate: bitrate,
      );
    } else {
      return {
        'success': false,
        'message': 'Platform not supported',
        'outputPath': null,
      };
    }
  }

  static Future<Map<String, dynamic>> _extractOneMobile({
    required String inputPath,
    required String outputPath,
    required double startTime,
    required double endTime,
    required String encoderBitrate,
  }) async {
    final dur = endTime - startTime;
    final cmd = [
      '-ss',
      startTime.toString(),
      '-t',
      dur.toString(),
      '-i',
      _q(inputPath),
      '-c:a',
      'libmp3lame',
      '-b:a',
      encoderBitrate,
      _q(outputPath),
      '-y',
    ].join(' ');

    final sess = await FFmpegKit.execute(cmd);
    final rc = await sess.getReturnCode();
    if (ReturnCode.isSuccess(rc)) {
      return {
        'success': true,
        'message': 'OK',
        'outputPath': outputPath,
      };
    } else {
      final logs = await sess.getAllLogsAsString();
      return {
        'success': false,
        'message': 'FFmpeg error (mobile one-shot):\n$logs',
        'outputPath': null,
      };
    }
  }

  static Future<Map<String, dynamic>> _extractOneDesktop({
    required String inputPath,
    required String outputPath,
    required double startTime,
    required double endTime,
    required String encoderBitrate,
  }) async {
    final args = [
      '-i',
      inputPath,
      '-ss',
      startTime.toString(),
      '-to',
      endTime.toString(),
      '-c:a',
      'libmp3lame',
      '-b:a',
      encoderBitrate,
      outputPath,
      '-y',
    ];
    final r = await Process.run('ffmpeg', args);
    if (r.exitCode == 0) {
      return {
        'success': true,
        'message': 'OK',
        'outputPath': outputPath,
      };
    } else {
      return {
        'success': false,
        'message': 'FFmpeg error: ${r.stderr}',
        'outputPath': null,
      };
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Multi segments (single input)
  // ────────────────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> extractAudioSegments({
    required String inputPath,
    required String outputPathFileName,
    required List<AudioSegment> segments,
    required bool inMusicQuality,
    String? encoderBitrate,
  }) async {
    if (segments.isEmpty) {
      return {
        'success': false,
        'message': 'No segments to extract',
        'outputPath': null,
      };
    }

    // Only the not deleted segments are extracted
    segments = segments.where((s) => !s.deleted).toList();

    final bitrate = (inMusicQuality) ? '192k' : '64k';

    if (Platform.isAndroid || Platform.isIOS) {
      return _extractSegmentsMobile(
        inputPath: inputPath,
        outputPath: outputPathFileName,
        segments: segments,
        encoderBitrate: bitrate,
      );
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return _extractSegmentsDesktop(
        inputPath: inputPath,
        outputPath: outputPathFileName,
        segments: segments,
        encoderBitrate: bitrate,
      );
    } else {
      return {
        'success': false,
        'message': 'Platform not supported',
        'outputPath': null,
      };
    }
  }

  static Future<Map<String, dynamic>> _extractSegmentsMobile({
    required String inputPath,
    required String outputPath,
    required List<AudioSegment> segments,
    required String encoderBitrate,
  }) async {
    try {
      final tmp = await _tempDir();
      final parts = <String>[];

      for (int i = 0; i < segments.length; i++) {
        final AudioSegment s = segments[i];

        // Step 1: Extract segment without any filters
        // This ensures we get a clean file with timestamps starting at 0
        final String tempSegPath = '${tmp.path}/temp_seg_$i.mp3';

        final extractCmd = [
          '-ss',
          s.startPosition.toString(),
          '-t',
          (s.endPosition - s.startPosition).toString(),
          '-i',
          _q(inputPath),
          '-c:a',
          'libmp3lame', // Re-encode instead of copy to ensure valid MP3
          '-b:a',
          encoderBitrate,
          _q(tempSegPath),
          '-y',
        ].join(' ');

        logger.i('Step 1: Extracting segment $i');

        final extractSess = await FFmpegKit.execute(extractCmd);
        if (!ReturnCode.isSuccess(
          await extractSess.getReturnCode(),
        )) {
          return {
            'success': false,
            'message':
                'FFmpeg extract failed @segment ${i + 1}:\n${await extractSess.getAllLogsAsString()}',
            'outputPath': null,
          };
        }

        // Step 2: Apply filters to the extracted segment (which now starts at 0)
        final segPath = '${tmp.path}/segment_$i.mp3';

        // Build audio filter for this segment (fade-out uses segment-relative time)
        final fadeFilter = _buildFadeFilterForExtractedSegment(
          segment: s,
        );

        if (fadeFilter.isEmpty) {
          // No filters needed, just re-encode
          final reencodeCmd = [
            '-i',
            _q(tempSegPath),
            '-c:a',
            'libmp3lame',
            '-b:a',
            encoderBitrate,
            _q(segPath),
            '-y',
          ].join(' ');

          final FFmpegSession reencodeSess =
              await FFmpegKit.execute(reencodeCmd);
          if (!ReturnCode.isSuccess(
            await reencodeSess.getReturnCode(),
          )) {
            return {
              'success': false,
              'message':
                  'FFmpeg re-encode failed @segment ${i + 1}:\n${await reencodeSess.getAllLogsAsString()}',
              'outputPath': null,
            };
          }
        } else {
          // Apply filters and re-encode
          logger.i(
            'Step 2: Applying filter to segment $i: $fadeFilter',
          );

          final filterCmd = [
            '-i',
            _q(tempSegPath),
            '-af',
            fadeFilter,
            '-c:a',
            'libmp3lame',
            '-b:a',
            encoderBitrate,
            _q(segPath),
            '-y',
          ].join(' ');

          final filterSess = await FFmpegKit.execute(filterCmd);
          if (!ReturnCode.isSuccess(
            await filterSess.getReturnCode(),
          )) {
            return {
              'success': false,
              'message':
                  'FFmpeg filter failed @segment ${i + 1}:\n${await filterSess.getAllLogsAsString()}',
              'outputPath': null,
            };
          }
        }

        parts.add(segPath);

        final silUser = s.silenceDuration;
        final needDefault = silUser <= 0 && i < segments.length - 1;
        final silDur = silUser > 0
            ? silUser
            : (needDefault ? defaultSilenceDuration : 0.0);
        if (silDur > 0) {
          final silPath = '${tmp.path}/silence_$i.mp3';
          final silCmd = [
            '-f',
            'lavfi',
            '-i',
            '"anullsrc=r=44100:cl=mono"',
            '-t',
            silDur.toString(),
            '-c:a',
            'libmp3lame',
            '-b:a',
            encoderBitrate,
            _q(silPath),
            '-y',
          ].join(' ');
          final silSess = await FFmpegKit.execute(silCmd);
          if (!ReturnCode.isSuccess(await silSess.getReturnCode())) {
            return {
              'success': false,
              'message':
                  'FFmpeg silence failed:\n${await silSess.getAllLogsAsString()}',
              'outputPath': null,
            };
          }
          parts.add(silPath);
        }
      }

      final listFile = File('${tmp.path}/concat.txt')
        ..writeAsStringSync(
          parts.map((p) => "file '${p.replaceAll("'", "'\\''")}'").join('\n'),
        );

      final concatCmd = [
        '-f',
        'concat',
        '-safe',
        '0',
        '-i',
        _q(listFile.path),
        '-c:a',
        'libmp3lame',
        '-b:a',
        encoderBitrate,
        _q(outputPath),
        '-y',
      ].join(' ');

      final concatSess = await FFmpegKit.execute(concatCmd);
      if (ReturnCode.isSuccess(await concatSess.getReturnCode())) {
        return {
          'success': true,
          'message': 'Extraction successful',
          'outputPath': outputPath,
        };
      } else {
        return {
          'success': false,
          'message':
              'FFmpeg concat failed:\n${await concatSess.getAllLogsAsString()}',
          'outputPath': null,
        };
      }
    } catch (e, st) {
      logger.e('Mobile multi-extract failed: $e\n$st');
      return {
        'success': false,
        'message': 'Plugin error: $e',
        'outputPath': null,
      };
    }
  }

  /// Builds an atempo filter chain for a given speed.
  /// FFmpeg's atempo filter accepts values between 0.5 and 2.0.
  /// For speeds outside this range, we chain multiple atempo filters.
  static String _buildAtempoFilterChain(double speed) {
    if (speed <= 0) {
      logger.w('Invalid play speed: $speed, using 1.0');
      return '';
    }

    // If speed is 1.0, no filter needed
    if ((speed - 1.0).abs() < 0.01) {
      return '';
    }

    final List<String> atempoFilters = [];
    double remainingSpeed = speed;

    // atempo filter supports 0.5 to 2.0 range
    // For speeds outside this range, we chain multiple atempo filters
    while (remainingSpeed < 0.5) {
      atempoFilters.add('atempo=0.5');
      remainingSpeed /= 0.5;
    }

    while (remainingSpeed > 2.0) {
      atempoFilters.add('atempo=2.0');
      remainingSpeed /= 2.0;
    }

    // Add the final atempo filter for the remaining speed
    if ((remainingSpeed - 1.0).abs() > 0.01) {
      atempoFilters.add('atempo=${remainingSpeed.toStringAsFixed(2)}');
    }

    return atempoFilters.join(',');
  }

  /// Builds audio filter for an already-extracted segment (timestamps start at 0)
  /// Filter order: volume → fade-in → fade-out → atempo (play speed)
  static String _buildFadeFilterForExtractedSegment({
    required AudioSegment segment,
    double gainDb = 0.0,
  }) {
    final List<String> filters = [];

    // 1. Add volume filter if gain is specified
    if (gainDb.abs() > 1e-6) {
      filters.add('volume=${gainDb}dB');
    }

    const double threshold = 0.05;
    final segmentDuration = segment.endPosition - segment.startPosition;

    // 2. Add fade-IN filter if configured (volume 0% → 100% at start)
    if (segment.fadeInDuration > threshold) {
      final fadeInDur = segment.fadeInDuration;

      // Ensure fade-in doesn't exceed segment duration
      final actualFadeInDur =
          fadeInDur > segmentDuration ? segmentDuration : fadeInDur;

      if (actualFadeInDur > threshold) {
        final dStr = actualFadeInDur.toStringAsFixed(3);
        filters.add('afade=t=in:st=0:d=$dStr');

        logger.i('Fade-in filter: afade=t=in:st=0:d=$dStr');
      }
    }

    // 3. Add fade-OUT filter if configured (volume 100% → 0% at end)
    if (segment.soundReductionDuration > threshold &&
        segment.soundReductionPosition > threshold) {
      // For an extracted segment, calculate fade start relative to segment start
      final fadeStartRelative =
          segment.soundReductionPosition - segment.startPosition;

      if (fadeStartRelative >= -threshold &&
          fadeStartRelative < segmentDuration) {
        final fadeDuration = segment.soundReductionDuration;

        // Ensure fade doesn't extend beyond segment end
        final maxFadeDuration = segmentDuration - fadeStartRelative;
        final actualFadeDuration =
            fadeDuration > maxFadeDuration ? maxFadeDuration : fadeDuration;

        if (actualFadeDuration > threshold) {
          final safeStartRelative =
              fadeStartRelative < 0 ? 0.0 : fadeStartRelative;

          final stStr = safeStartRelative.toStringAsFixed(3);
          final dStr = actualFadeDuration.toStringAsFixed(3);
          filters.add('afade=t=out:st=$stStr:d=$dStr');

          logger.i('Fade-out filter: afade=t=out:st=$stStr:d=$dStr');
        }
      } else {
        logger.w(
          'Invalid fade: fadeStart=$fadeStartRelative > segmentDuration=$segmentDuration',
        );
      }
    }

    // 4. Add atempo filter for play speed if different from 1.0
    // This should come AFTER fades so that fade timings are based on original duration
    if ((segment.playSpeed - 1.0).abs() > 0.01) {
      final atempoFilters = _buildAtempoFilterChain(segment.playSpeed);
      if (atempoFilters.isNotEmpty) {
        filters.add(atempoFilters);
        logger.i(
            'Atempo filter: $atempoFilters for playSpeed=${segment.playSpeed}');
      }
    }

    return filters.join(',');
  }

  static Future<Map<String, dynamic>> _extractSegmentsDesktop({
    required String inputPath,
    required String outputPath,
    required List<AudioSegment> segments,
    required String encoderBitrate,
  }) async {
    try {
      final tempDir = Directory.systemTemp.createTempSync(
        'mp3_extract_',
      );
      final partFiles = <String>[];

      try {
        for (int i = 0; i < segments.length; i++) {
          final s = segments[i];

          // Step 1: Extract segment without filters (ensures timestamps start at 0)
          final tempSegPath =
              '${tempDir.path}${Platform.pathSeparator}temp_seg_$i.mp3';

          final extractArgs = [
            '-ss',
            s.startPosition.toString(),
            '-t',
            (s.endPosition - s.startPosition).toString(),
            '-i',
            inputPath,
            '-c:a',
            'libmp3lame', // Re-encode instead of copy to ensure valid MP3
            '-b:a',
            encoderBitrate,
            tempSegPath,
            '-y',
            '-v',
            'error',
          ];

          final extractResult = await Process.run(
            'ffmpeg',
            extractArgs,
          );
          if (extractResult.exitCode != 0) {
            return {
              'success': false,
              'message':
                  'Failed to extract segment ${i + 1}: ${extractResult.stderr}',
              'outputPath': null,
            };
          }

          // Step 2: Apply filters to extracted segment
          final segPath =
              '${tempDir.path}${Platform.pathSeparator}segment_$i.mp3';

          final fadeFilter = _buildFadeFilterForExtractedSegment(
            segment: s,
            gainDb: 0.0,
          );

          if (fadeFilter.isEmpty) {
            // No filters, just re-encode
            final reencodeArgs = [
              '-i',
              tempSegPath,
              '-c:a',
              'libmp3lame',
              '-b:a',
              encoderBitrate,
              segPath,
              '-y',
              '-v',
              'error',
            ];

            final reencodeResult = await Process.run(
              'ffmpeg',
              reencodeArgs,
            );
            if (reencodeResult.exitCode != 0) {
              return {
                'success': false,
                'message':
                    'Failed to re-encode segment ${i + 1}: ${reencodeResult.stderr}',
                'outputPath': null,
              };
            }
          } else {
            // Apply filters
            logger.i(
              'Desktop: Applying filter to segment $i: $fadeFilter',
            );

            final filterArgs = [
              '-i',
              tempSegPath,
              '-af',
              fadeFilter,
              '-c:a',
              'libmp3lame',
              '-b:a',
              encoderBitrate,
              segPath,
              '-y',
              '-v',
              'error',
            ];

            final filterResult = await Process.run(
              'ffmpeg',
              filterArgs,
            );
            if (filterResult.exitCode != 0) {
              return {
                'success': false,
                'message':
                    'Failed to apply filter to segment ${i + 1}: ${filterResult.stderr}',
                'outputPath': null,
              };
            }
          }

          partFiles.add(segPath);

          final silUser = s.silenceDuration;
          final needDefault = silUser <= 0 && i < segments.length - 1;
          final silDur = silUser > 0
              ? silUser
              : (needDefault ? defaultSilenceDuration : 0.0);
          if (silDur > 0) {
            final silPath =
                '${tempDir.path}${Platform.pathSeparator}silence_$i.mp3';
            final silArgs = [
              '-f',
              'lavfi',
              '-i',
              'anullsrc=r=44100:cl=mono',
              '-t',
              silDur.toString(),
              '-c:a',
              'libmp3lame',
              '-b:a',
              encoderBitrate,
              silPath,
              '-y',
              '-v',
              'error',
            ];
            final rs = await Process.run('ffmpeg', silArgs);
            if (rs.exitCode != 0) {
              return {
                'success': false,
                'message':
                    'Failed to create silence for segment ${i + 1}: ${rs.stderr}',
                'outputPath': null,
              };
            }
            partFiles.add(silPath);
          }
        }

        final concatList = File(
          '${tempDir.path}${Platform.pathSeparator}concat.txt',
        );
        concatList.writeAsStringSync(
          partFiles.map((f) {
            String p = f.replaceAll('\\', '/').replaceAll("'", "'\\''");
            return "file '$p'";
          }).join('\n'),
        );

        final concatArgs = [
          '-f',
          'concat',
          '-safe',
          '0',
          '-i',
          concatList.path.replaceAll('\\', '/'),
          '-c:a',
          'libmp3lame',
          '-b:a',
          encoderBitrate,
          outputPath.replaceAll('\\', '/'),
          '-y',
          '-v',
          'error',
        ];

        final concatResult = await Process.run('ffmpeg', concatArgs);
        if (concatResult.exitCode == 0 && File(outputPath).existsSync()) {
          return {
            'success': true,
            'message': 'Extraction successful',
            'outputPath': outputPath,
          };
        } else {
          final stderr = concatResult.stderr?.toString() ?? 'Unknown error';
          return {
            'success': false,
            'message': 'Concat failed: $stderr',
            'outputPath': null,
          };
        }
      } finally {
        try {
          tempDir.deleteSync(recursive: true);
        } catch (_) {}
      }
    } catch (e, st) {
      logger.e('Desktop multi-extract failed: $e\n$st');
      return {
        'success': false,
        'message': 'FFmpeg error: $e',
        'outputPath': null,
      };
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Multi inputs (with per-input gain in dB)
  // ────────────────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> extractFromMultipleInputs({
    required List<InputSegments> inputs,
    required String outputPath,
    String encoderBitrate = '128k',
  }) async {
    if (inputs.isEmpty) {
      return {
        'success': false,
        'message': 'No inputs provided',
        'outputPath': null,
      };
    }

    if (Platform.isAndroid || Platform.isIOS) {
      return _extractMultipleMobile(
        inputs: inputs,
        outputPath: outputPath,
        encoderBitrate: encoderBitrate,
      );
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return _extractMultipleDesktop(
        inputs: inputs,
        outputPath: outputPath,
        encoderBitrate: encoderBitrate,
      );
    } else {
      return {
        'success': false,
        'message': 'Platform not supported',
        'outputPath': null,
      };
    }
  }

  static Future<Map<String, dynamic>> _extractMultipleMobile({
    required List<InputSegments> inputs,
    required String outputPath,
    required String encoderBitrate,
  }) async {
    try {
      final tmp = await _tempDir();
      final parts = <String>[];
      int partIndex = 0;

      for (int i = 0; i < inputs.length; i++) {
        final inp = inputs[i];

        for (int j = 0; j < inp.segments.length; j++) {
          final s = inp.segments[j];

          // Two-step extraction for multi-input too
          final tempCutPath = '${tmp.path}/m_temp_$partIndex.mp3';
          final cutPath = '${tmp.path}/m_cut_${partIndex++}.mp3';

          // Step 1: Extract segment without filters
          final extractCmd = [
            '-ss',
            s.startPosition.toString(),
            '-t',
            (s.endPosition - s.startPosition).toString(),
            '-i',
            _q(inp.inputPath),
            '-c:a',
            'libmp3lame',
            '-b:a',
            encoderBitrate,
            _q(tempCutPath),
            '-y',
          ].join(' ');

          final extractSess = await FFmpegKit.execute(extractCmd);
          if (!ReturnCode.isSuccess(
            await extractSess.getReturnCode(),
          )) {
            return {
              'success': false,
              'message':
                  'FFmpeg extract failed @input ${i + 1}, segment ${j + 1}:\n${await extractSess.getAllLogsAsString()}',
              'outputPath': null,
            };
          }

          // Step 2: Apply filters (gain + fade)
          final audioFilter = _buildFadeFilterForExtractedSegment(
            segment: s,
            gainDb: inp.gainDb,
          );

          if (audioFilter.isEmpty) {
            // No filters, just rename temp file
            final tempFile = File(tempCutPath);
            await tempFile.copy(cutPath);
            await tempFile.delete();
          } else {
            // Apply filters
            final filterCmd = [
              '-i',
              _q(tempCutPath),
              '-af',
              audioFilter,
              '-c:a',
              'libmp3lame',
              '-b:a',
              encoderBitrate,
              _q(cutPath),
              '-y',
            ].join(' ');

            final filterSess = await FFmpegKit.execute(filterCmd);
            if (!ReturnCode.isSuccess(
              await filterSess.getReturnCode(),
            )) {
              return {
                'success': false,
                'message':
                    'FFmpeg filter failed @input ${i + 1}, segment ${j + 1}:\n${await filterSess.getAllLogsAsString()}',
                'outputPath': null,
              };
            }
          }

          parts.add(cutPath);

          // Silence between segments of the same input
          final silUser = s.silenceDuration;
          final isNotLastSegOfInput = j < inp.segments.length - 1;
          final needDefaultBetweenSegments =
              (silUser <= 0) && isNotLastSegOfInput;
          final silDur = silUser > 0
              ? silUser
              : (needDefaultBetweenSegments ? defaultSilenceDuration : 0.0);

          if (silDur > 0) {
            final silPath = '${tmp.path}/m_sil_${partIndex++}.mp3';
            final silCmd = [
              '-f',
              'lavfi',
              '-i',
              '"anullsrc=r=44100:cl=mono"',
              '-t',
              silDur.toString(),
              '-c:a',
              'libmp3lame',
              '-b:a',
              encoderBitrate,
              _q(silPath),
              '-y',
            ].join(' ');
            final silSess = await FFmpegKit.execute(silCmd);
            if (!ReturnCode.isSuccess(
              await silSess.getReturnCode(),
            )) {
              return {
                'success': false,
                'message':
                    'FFmpeg silence failed:\n${await silSess.getAllLogsAsString()}',
                'outputPath': null,
              };
            }
            parts.add(silPath);
          }
        }

        // Inter-file silence using your constant
        if (i < inputs.length - 1 && kDefaultSilenceDurationBetweenMp3 > 0) {
          final interPath = '${tmp.path}/m_inter_${partIndex++}.mp3';
          final interCmd = [
            '-f',
            'lavfi',
            '-i',
            '"anullsrc=r=44100:cl=mono"',
            '-t',
            kDefaultSilenceDurationBetweenMp3.toString(),
            '-c:a',
            'libmp3lame',
            '-b:a',
            encoderBitrate,
            _q(interPath),
            '-y',
          ].join(' ');
          final interSess = await FFmpegKit.execute(interCmd);
          if (!ReturnCode.isSuccess(
            await interSess.getReturnCode(),
          )) {
            return {
              'success': false,
              'message':
                  'FFmpeg inter-file silence failed:\n${await interSess.getAllLogsAsString()}',
              'outputPath': null,
            };
          }
          parts.add(interPath);
        }
      }

      final listFile = File('${tmp.path}/m_concat.txt')
        ..writeAsStringSync(
          parts.map((p) => "file '${p.replaceAll("'", "'\\''")}'").join('\n'),
        );

      final concatCmd = [
        '-f',
        'concat',
        '-safe',
        '0',
        '-i',
        _q(listFile.path),
        '-c:a',
        'libmp3lame',
        '-b:a',
        encoderBitrate,
        _q(outputPath),
        '-y',
      ].join(' ');

      final concatSess = await FFmpegKit.execute(concatCmd);
      if (ReturnCode.isSuccess(await concatSess.getReturnCode())) {
        return {
          'success': true,
          'message': 'Extraction successful',
          'outputPath': outputPath,
        };
      } else {
        return {
          'success': false,
          'message':
              'FFmpeg concat failed:\n${await concatSess.getAllLogsAsString()}',
          'outputPath': null,
        };
      }
    } catch (e, st) {
      logger.e('Mobile multi-input failed: $e\n$st');
      return {
        'success': false,
        'message': 'Plugin error: $e',
        'outputPath': null,
      };
    }
  }

  static Future<Map<String, dynamic>> _extractMultipleDesktop({
    required List<InputSegments> inputs,
    required String outputPath,
    required String encoderBitrate,
  }) async {
    final tempDir = Directory.systemTemp.createTempSync('mp3_multi_');
    final partFiles = <String>[];
    int idx = 0;

    try {
      for (int i = 0; i < inputs.length; i++) {
        final inp = inputs[i];

        for (int j = 0; j < inp.segments.length; j++) {
          final s = inp.segments[j];

          // Two-step extraction for multi-input
          final tempCutPath =
              '${tempDir.path}${Platform.pathSeparator}m_temp_$idx.mp3';
          final cutPath =
              '${tempDir.path}${Platform.pathSeparator}m_cut_${idx++}.mp3';

          // Step 1: Extract segment without filters
          final extractArgs = [
            '-ss',
            s.startPosition.toString(),
            '-t',
            (s.endPosition - s.startPosition).toString(),
            '-i',
            inp.inputPath,
            '-c:a',
            'libmp3lame',
            '-b:a',
            encoderBitrate,
            tempCutPath,
            '-y',
            '-v',
            'error',
          ];

          final extractResult = await Process.run(
            'ffmpeg',
            extractArgs,
          );
          if (extractResult.exitCode != 0) {
            return {
              'success': false,
              'message': 'Extract failed: ${extractResult.stderr}',
              'outputPath': null,
            };
          }

          // Step 2: Apply filters (gain + fade)
          final audioFilter = _buildFadeFilterForExtractedSegment(
            segment: s,
            gainDb: inp.gainDb,
          );

          if (audioFilter.isEmpty) {
            // No filters, just rename
            File(tempCutPath).renameSync(cutPath);
          } else {
            // Apply filters
            final filterArgs = [
              '-i',
              tempCutPath,
              '-af',
              audioFilter,
              '-c:a',
              'libmp3lame',
              '-b:a',
              encoderBitrate,
              cutPath,
              '-y',
              '-v',
              'error',
            ];

            final filterResult = await Process.run(
              'ffmpeg',
              filterArgs,
            );
            if (filterResult.exitCode != 0) {
              return {
                'success': false,
                'message': 'Filter failed: ${filterResult.stderr}',
                'outputPath': null,
              };
            }
          }

          partFiles.add(cutPath);

          final silUser = s.silenceDuration;
          final isNotLastSegOfInput = j < inp.segments.length - 1;
          final needDefault = (silUser <= 0) && isNotLastSegOfInput;
          final silDur = silUser > 0
              ? silUser
              : (needDefault ? defaultSilenceDuration : 0.0);
          if (silDur > 0) {
            final silPath =
                '${tempDir.path}${Platform.pathSeparator}m_sil_${idx++}.mp3';
            final silArgs = [
              '-f',
              'lavfi',
              '-i',
              'anullsrc=r=44100:cl=mono',
              '-t',
              silDur.toString(),
              '-c:a',
              'libmp3lame',
              '-b:a',
              encoderBitrate,
              silPath,
              '-y',
              '-v',
              'error',
            ];
            final rs = await Process.run('ffmpeg', silArgs);
            if (rs.exitCode != 0) {
              return {
                'success': false,
                'message': 'Silence failed: ${rs.stderr}',
                'outputPath': null,
              };
            }
            partFiles.add(silPath);
          }
        }

        if (i < inputs.length - 1 && kDefaultSilenceDurationBetweenMp3 > 0) {
          final interPath =
              '${tempDir.path}${Platform.pathSeparator}m_inter_${idx++}.mp3';
          final interArgs = [
            '-f',
            'lavfi',
            '-i',
            'anullsrc=r=44100:cl=mono',
            '-t',
            kDefaultSilenceDurationBetweenMp3.toString(),
            '-c:a',
            'libmp3lame',
            '-b:a',
            encoderBitrate,
            interPath,
            '-y',
            '-v',
            'error',
          ];
          final ri = await Process.run('ffmpeg', interArgs);
          if (ri.exitCode != 0) {
            return {
              'success': false,
              'message': 'Inter-file silence failed: ${ri.stderr}',
              'outputPath': null,
            };
          }
          partFiles.add(interPath);
        }
      }

      final concatList = File(
        '${tempDir.path}${Platform.pathSeparator}m_concat.txt',
      );
      concatList.writeAsStringSync(
        partFiles.map((f) {
          final p = f.replaceAll('\\', '/').replaceAll("'", "'\\''");
          return "file '$p'";
        }).join('\n'),
      );

      final concatArgs = [
        '-f',
        'concat',
        '-safe',
        '0',
        '-i',
        concatList.path.replaceAll('\\', '/'),
        '-c:a',
        'libmp3lame',
        '-b:a',
        encoderBitrate,
        outputPath.replaceAll('\\', '/'),
        '-y',
        '-v',
        'error',
      ];
      final res = await Process.run('ffmpeg', concatArgs);
      if (res.exitCode == 0 && File(outputPath).existsSync()) {
        return {
          'success': true,
          'message': 'Extraction successful',
          'outputPath': outputPath,
        };
      } else {
        return {
          'success': false,
          'message': 'Concat failed: ${res.stderr}',
          'outputPath': null,
        };
      }
    } catch (e, st) {
      logger.e('Desktop multi-input failed: $e\n$st');
      return {
        'success': false,
        'message': 'FFmpeg error: $e',
        'outputPath': null,
      };
    } finally {
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────────────────────────

  static String _q(String path) => '"${path.replaceAll('\\', '/')}"';

  static Future<Directory> _tempDir() async {
    return Directory.systemTemp;
  }
}

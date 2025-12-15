// lib/services/audio_extractor_service.dart
import 'dart:io';
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

  /// Default silence (seconds) appended between segments when user did not specify any.
  static const double defaultSilenceDuration = 1.0;

  // ────────────────────────────────────────────────────────────────────────────
  // Duration
  // ────────────────────────────────────────────────────────────────────────────

  /// Returns media duration in seconds.
  static Future<double> getAudioDuration({required String filePath}) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final session = await FFprobeKit.getMediaInformation(filePath);
        final info = session.getMediaInformation();
        final durationStr = info?.getDuration();
        if (durationStr != null) {
          final d = double.tryParse(durationStr);
          if (d != null && d > 0) return d;
        }
        logger.w('FFprobeKit no duration for "$filePath", fallback to 60s');
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
      return {'success': true, 'message': 'OK', 'outputPath': outputPath};
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
      return {'success': true, 'message': 'OK', 'outputPath': outputPath};
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
    required String outputPath,
    required List<AudioSegment> segments,
    String? encoderBitrate,
  }) async {
    if (segments.isEmpty) {
      return {
        'success': false,
        'message': 'No segments to extract',
        'outputPath': null,
      };
    }
    final bitrate = encoderBitrate ?? '128k';

    if (Platform.isAndroid || Platform.isIOS) {
      return _extractSegmentsMobile(
        inputPath: inputPath,
        outputPath: outputPath,
        segments: segments,
        encoderBitrate: bitrate,
      );
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return _extractSegmentsDesktop(
        inputPath: inputPath,
        outputPath: outputPath,
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
        final s = segments[i];
        final segPath = '${tmp.path}/segment_$i.mp3';

        final cut = [
          '-ss',
          s.startPosition.toString(),
          '-to',
          s.endPosition.toString(),
          '-i',
          _q(inputPath),
          '-c:a',
          'libmp3lame',
          '-b:a',
          encoderBitrate,
          _q(segPath),
          '-y',
        ].join(' ');
        final cutSess = await FFmpegKit.execute(cut);
        if (!ReturnCode.isSuccess(await cutSess.getReturnCode())) {
          return {
            'success': false,
            'message':
                'FFmpeg cut failed @segment ${i + 1}:\n${await cutSess.getAllLogsAsString()}',
            'outputPath': null,
          };
        }
        parts.add(segPath);

        final silUser = s.silenceDuration;
        final needDefault = silUser <= 0 && i < segments.length - 1;
        final silDur =
            silUser > 0
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

      final listFile = File('${tmp.path}/concat.txt')..writeAsStringSync(
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

  static Future<Map<String, dynamic>> _extractSegmentsDesktop({
    required String inputPath,
    required String outputPath,
    required List<AudioSegment> segments,
    required String encoderBitrate,
  }) async {
    try {
      final tempDir = Directory.systemTemp.createTempSync('mp3_extract_');
      final partFiles = <String>[];

      try {
        for (int i = 0; i < segments.length; i++) {
          final s = segments[i];
          final segPath =
              '${tempDir.path}${Platform.pathSeparator}segment_$i.mp3';

          final args = [
            '-i',
            inputPath,
            '-ss',
            s.startPosition.toString(),
            '-to',
            s.endPosition.toString(),
            '-c:a',
            'libmp3lame',
            '-b:a',
            encoderBitrate,
            segPath,
            '-y',
            '-v',
            'error',
          ];
          final r = await Process.run('ffmpeg', args);
          if (r.exitCode != 0) {
            return {
              'success': false,
              'message': 'Failed to extract segment ${i + 1}: ${r.stderr}',
              'outputPath': null,
            };
          }
          partFiles.add(segPath);

          final silUser = s.silenceDuration;
          final needDefault = silUser <= 0 && i < segments.length - 1;
          final silDur =
              silUser > 0
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
          partFiles
              .map((f) {
                String p = f.replaceAll('\\', '/').replaceAll("'", "'\\''");
                return "file '$p'";
              })
              .join('\n'),
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

          final cutPath = '${tmp.path}/m_cut_${partIndex++}.mp3';
          final hasGain = inp.gainDb.abs() > 1e-6;

          // Apply per-input volume if gainDb != 0.0
          final cutCmd = [
            '-ss',
            s.startPosition.toString(),
            '-to',
            s.endPosition.toString(),
            '-i',
            _q(inp.inputPath),
            if (hasGain) '-filter:a',
            if (hasGain) '"volume=${inp.gainDb}dB"',
            '-c:a',
            'libmp3lame',
            '-b:a',
            encoderBitrate,
            _q(cutPath),
            '-y',
          ].join(' ');

          final cutSess = await FFmpegKit.execute(cutCmd);
          if (!ReturnCode.isSuccess(await cutSess.getReturnCode())) {
            return {
              'success': false,
              'message':
                  'FFmpeg cut failed @input ${i + 1}, segment ${j + 1}:\n${await cutSess.getAllLogsAsString()}',
              'outputPath': null,
            };
          }
          parts.add(cutPath);

          // Silence between segments of the same input
          final silUser = s.silenceDuration;
          final isNotLastSegOfInput = j < inp.segments.length - 1;
          final needDefaultBetweenSegments =
              (silUser <= 0) && isNotLastSegOfInput;
          final silDur =
              silUser > 0
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
          if (!ReturnCode.isSuccess(await interSess.getReturnCode())) {
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

      final listFile = File('${tmp.path}/m_concat.txt')..writeAsStringSync(
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
        final hasGain = inp.gainDb.abs() > 1e-6;

        for (int j = 0; j < inp.segments.length; j++) {
          final s = inp.segments[j];

          final cutPath =
              '${tempDir.path}${Platform.pathSeparator}m_cut_${idx++}.mp3';
          final cutArgs = <String>[
            '-i',
            inp.inputPath,
            '-ss',
            s.startPosition.toString(),
            '-to',
            s.endPosition.toString(),
            if (hasGain) '-filter:a',
            if (hasGain) 'volume=${inp.gainDb}dB',
            '-c:a',
            'libmp3lame',
            '-b:a',
            encoderBitrate,
            cutPath,
            '-y',
            '-v',
            'error',
          ];
          final r = await Process.run('ffmpeg', cutArgs);
          if (r.exitCode != 0) {
            return {
              'success': false,
              'message': 'Cut failed: ${r.stderr}',
              'outputPath': null,
            };
          }
          partFiles.add(cutPath);

          final silUser = s.silenceDuration;
          final isNotLastSegOfInput = j < inp.segments.length - 1;
          final needDefault = (silUser <= 0) && isNotLastSegOfInput;
          final silDur =
              silUser > 0
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
        partFiles
            .map((f) {
              final p = f.replaceAll('\\', '/').replaceAll("'", "'\\''");
              return "file '$p'";
            })
            .join('\n'),
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

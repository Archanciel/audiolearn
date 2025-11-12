import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final yt = YoutubeExplode();
  final logger = Logger();

  const String videoId = 'fRh_vgS2dFE';

  try {
    final video = await yt.videos.get(videoId);
    logger.i('Video: ${video.title}');

    final manifest = await yt.videos.streams.getManifest(
      videoId,
      ytClients: [YoutubeApiClient.ios, YoutubeApiClient.androidVr],
    );

    final audioOnly = manifest.audioOnly;
    final streamInfo = audioOnly.withHighestBitrate();

    final Directory outputDirWindows =
        Directory(r'C:\development\flutter\audiolearn\test\data\audio');
    final Directory outputDirAndroid =
        Directory(r'/storage/emulated/0/Documents/test');

    final Directory outputDir =
        Platform.isAndroid ? outputDirAndroid : outputDirWindows;

    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    final String tmpExt = streamInfo.container.name; // "webm" ou "m4a"
    final File tempFile =
        File(path.join(outputDir.path, '${video.id}.$tmpExt'));
    final File outputFile =
        File(path.join(outputDir.path, '${video.id}.mp3'));

    logger.i('Downloading audio ($tmpExt) to: ${tempFile.path}');
    final stream = yt.videos.streams.get(streamInfo);
    final fileStream = tempFile.openWrite();
    await stream.pipe(fileStream);
    await fileStream.flush();
    await fileStream.close();
    logger.i('Download completed: ${tempFile.path}');

    logger.i('Converting to MP3...');
    final ok = Platform.isAndroid || Platform.isIOS
        ? await _convertToMp3WithFfmpegKit(
            inputPath: tempFile.path,
            outputPath: outputFile.path,
            logger: logger,
          )
        : await _convertToMp3WithSystemFfmpeg(
            inputPath: tempFile.path,
            outputPath: outputFile.path,
            logger: logger,
          );

    if (ok) {
      logger.i('Conversion completed: ${outputFile.path}');
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } else {
      logger.e('Conversion failed. Temp kept at: ${tempFile.path}');
    }
  } catch (e, st) {
    logger.e('Unhandled error: $e', stackTrace: st);
  } finally {
    yt.close();
  }
}

Future<bool> _convertToMp3WithFfmpegKit({
  required String inputPath,
  required String outputPath,
  required Logger logger,
}) async {
  final String cmd = [
    '-y',
    '-i', _q(inputPath),
    '-vn',
    '-ar', '44100',
    '-ac', '2',
    '-c:a', 'libmp3lame',
    '-b:a', '128k',
    _q(outputPath),
  ].join(' ');

  logger.i('FFmpegKit command: $cmd');

  final session = await FFmpegKit.execute(cmd);
  final rc = await session.getReturnCode();

  if (ReturnCode.isSuccess(rc)) return true;

  final logs = await session.getAllLogsAsString();
  logger.e('FFmpegKit failed (code=$rc)\n$logs');
  return false;
}

Future<bool> _convertToMp3WithSystemFfmpeg({
  required String inputPath,
  required String outputPath,
  required Logger logger,
}) async {
  try {
    final result = await Process.run('ffmpeg', [
      '-y',
      '-i', inputPath,
      '-vn',
      '-ar', '44100',
      '-ac', '2',
      '-c:a', 'libmp3lame',
      '-b:a', '192k',
      outputPath,
    ]);
    if (result.exitCode == 0) return true;
    logger.e('System ffmpeg failed: ${result.stderr}');
  } catch (e) {
    logger.e('Failed to start system ffmpeg: $e');
  }
  return false;
}

String _q(String s) {
  if (s.contains(' ')) return '"$s"';
  return s;
}

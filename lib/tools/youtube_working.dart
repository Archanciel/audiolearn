import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<void> main() async {
  final yt = YoutubeExplode();
  Logger logger = Logger();

  // Get the video metadata.
  final video = await yt.videos.get('fRh_vgS2dFE');
  logger.i(video.title);

  final manifest =
      await yt.videos.streams.getManifest('fRh_vgS2dFE', ytClients: [
    YoutubeApiClient.ios,
    YoutubeApiClient.androidVr,
  ]);

  // Get the audio streams.
  final audio = manifest.audioOnly;

  // Get the stream with the highest bitrate (or use .first, .last, etc.)
  final streamInfo = audio.withHighestBitrate();

  // Set up the output directory and file
  final Directory outputDirWindows =
      Directory(r'C:\development\flutter\audiolearn\test\data\audio');
  final Directory outputDirAndroid =
      Directory(r'/storage/emulated/0/Documents/test');

  final Directory outputDir = outputDirAndroid;

  // Create the directory if it doesn't exist
  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }

  // Download to temporary file first
  final tempFile =
      File('${outputDir.path}${path.separator}${video.id}.${streamInfo.container.name}');
  final outputFile = File('${outputDir.path}/${video.id}.mp3');

  // Download the audio
  final stream = yt.videos.streams.get(streamInfo);
  final fileStream = tempFile.openWrite();
  await stream.pipe(fileStream);
  await fileStream.flush();
  await fileStream.close();

  logger.i('Download completed: ${tempFile.path}');
  logger.i('Converting to MP3...');

  // Convert to MP3 using FFmpeg
  final result = await Process.run('ffmpeg', [
    '-i', tempFile.path,
    '-vn', // No video
    '-ar', '44100', // Audio sampling rate
    '-ac', '2', // Audio channels
    '-b:a', '192k', // Audio bitrate
    outputFile.path,
    '-y', // Overwrite output file if it exists
  ]);

  if (result.exitCode == 0) {
    logger.i('Conversion completed: ${outputFile.path}');
    // Delete temporary file
    await tempFile.delete();
  } else {
    logger.i('Conversion failed: ${result.stderr}');
  }

  // Close the YoutubeExplode's http client.
  yt.close();
}

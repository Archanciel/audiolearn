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

  // Create the output file with proper extension
  final file =
      File('${outputDir.path}${path.separator}${video.id}.${streamInfo.container.name}');

  // Get the stream
  final stream = yt.videos.streams.get(streamInfo);

  // Open file for writing
  final fileStream = file.openWrite();

  // Pipe the stream to the file
  await stream.pipe(fileStream);

  // Close the file stream
  await fileStream.flush();
  await fileStream.close();

  logger.i('Download completed: ${file.path}');

  // Close the YoutubeExplode's http client.
  yt.close();
}

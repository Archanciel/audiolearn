import 'dart:io';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<void> main() async {
  final yt = YoutubeExplode();

  try {
    // Get the video metadata
    final video = await yt.videos.get('fRh_vgS2dFE');
    print('Downloading: ${video.title}');

    // Get the stream manifest
    final manifest = await yt.videos.streams.getManifest('fRh_vgS2dFE');

    // Get the best audio stream
    final audioStream = manifest.audioOnly.withHighestBitrate();
    print('Bitrate: ${audioStream.bitrate}');

    // Set up the output directory and file
    final outputDir =
        Directory(r'C:\development\flutter\audiolearn\test\data\audio');

    // Create directory if it doesn't exist
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    // Clean the filename (remove invalid characters)
    final cleanTitle = video.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    final fileName = '$cleanTitle.${audioStream.container.name}';
    final filePath = '${outputDir.path}\\$fileName';

    final file = File(filePath);
    final output = file.openWrite();

    // Download the stream
    final stream = yt.videos.streams.get(audioStream);

    var len = audioStream.size.totalBytes;
    var count = 0;

    await for (final data in stream) {
      count += data.length;
      output.add(data);

      var progress = ((count / len) * 100).toStringAsFixed(1);
      stdout.write('\rDownloading: $progress%');
    }

    stdout.write('\n');
    await output.flush();
    await output.close();

    print('Downloaded to: $filePath');
  } catch (e) {
    print('EXCEPTION $e');
    yt.close();
    return;
  }
}

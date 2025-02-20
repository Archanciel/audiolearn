import 'package:flutter/foundation.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart' as ffmpegKit;
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter_audio/ffmpeg_kit.dart';

class AudioExtractorVM extends ChangeNotifier {
  /// Extracts a part of an MP3 file and saves it to another MP3 file.
  ///
  /// Parameters:
  /// - `sourceMp3FilePathName`: The path of the source MP3 file.
  /// - `extractMp3FilePathName`: The path where the extracted MP3 file should be saved.
  /// - `startTime`: The start time in seconds from where the extraction should begin.
  /// - `duration`: The duration in seconds for how long the extracted part should be.
  ///
  /// Returns `true` if the operation is successful, otherwise `false`.
  Future<bool> extractMp3FilePartToMp3File({
    required String sourceMp3FilePathName,
    required String extractMp3FilePathName,
    required double startTime,
    required double duration,
  }) async {
    try {
      final command =
          '-i "$sourceMp3FilePathName" -ss $startTime -t $duration -c copy "$extractMp3FilePathName"';

      final session = await ffmpegKit.FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (returnCode != null && ReturnCode.isSuccess(returnCode)) {
        notifyListeners();
        return true;
      } else {
        debugPrint('FFmpeg execution failed with code: ${returnCode?.getValue()}');
        return false;
      }
    } catch (e) {
      debugPrint('Error extracting MP3 part: $e');
      return false;
    }
  }
}

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/services/audio_extractor_service.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

void main() {
  // Ensure Flutter bindings are initialized before any tests run
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AudioExtractorService', () {
    late AudioExtractorService audioExtractorService;

    setUp(() {
      String sourceRootPath =
          "$kDownloadAppTestSavedDataDir${path.separator}audio_extractor_service_test";

      audioExtractorService = AudioExtractorService(
        audioExtractorRepository: sourceRootPath,
      );
      // Ensure the test repository directory is clean or set up
      DirUtil.createDirIfNotExistsSync(pathStr: 'test_repo');
    });

    tearDown(() {
      // Clean up the directory or any files created during the test
    });

    test('should extract the correct audio segment', () async {
      final sourceFilePath =
          "$kDownloadAppTestSavedDataDir${path.separator}audio_extractor_service_test";

      final startTenthSec = 10;
      final endTenthSec = 50;

      await audioExtractorService.extractSegment(
        sourceAudioFilePathName: sourceFilePath,
        startTenthSec: startTenthSec,
        endTenthSec: endTenthSec,
      );

      // Verify the output file exists and is as expected
      // Implement file verification logic as needed
    });
  });
}

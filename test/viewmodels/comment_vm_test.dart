import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import 'package:audiolearn/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const String testSettingsDir =
      '$kPlaylistDownloadRootPathWindowsTest\\audiolearn_test_settings';

  group('Settings', () {
    test('Test add comment', () async {
      final Directory directory = Directory(testSettingsDir);

      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }

      // Cleanup the test data directory
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });
  });
}

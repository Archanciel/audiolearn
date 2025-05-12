import 'dart:io';

import 'package:audiolearn/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'integration_test_util.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Set up test files on emulator
    await setupTestFiles();

    // Your existing setup code...
  });

  testWidgets('Restore zip existing playlist selected test',
      (WidgetTester tester) async {
    print(
        '***** After executing copy_test_files.ps1, running integr test *****');
        
    await IntegrationTestUtil.initializeAndroidApplicationAndSelectPlaylist(
      tester: tester,
      tapOnPlaylistToggleButton: false,
    );
  });
}

Future<void> setupTestFiles() async {
  print('***** Setting up test files on emulator...');

  // Define paths for your test
  final String sourcePath =
      'C:\\development\\flutter\\audiolearn\\test\\data\\saved\\restore_zip_existing_playlist_selected_test_android';
  final String destPath = '/storage/emulated/0/Documents/test/audiolearn';

  // Run PowerShell script
  final result = await Process.run('powershell', [
    '-ExecutionPolicy',
    'Bypass',
    '-File',
    '$kDownloadAppTestSavedDataDir\\ps1_directory\\copy_test_files.ps1',
    '-SourcePath',
    sourcePath,
    '-DestPath',
    destPath,
    '-BaseDir',
    'restore_zip_existing_playlist_selected_test_android'
  ]);

  print('***** stdout: ${result.stdout}');

  if (result.exitCode != 0) {
    print('***** Error setting up test files: ${result.stderr}');
    throw Exception('Failed to set up test files on emulator');
  }

  print('***** Test files setup completed');
}

import 'dart:convert';
import 'dart:io';

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/models/picture.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/services/json_data_service.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/utils/date_time_util.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/picture_vm.dart';
import 'package:audiolearn/viewmodels/warning_message_vm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late PictureVM pictureVM;
  late SettingsDataService settingsDataService;
  late SharedPreferences sharedPreferences;

  // Test data
  final String testAppSettingsPathFileName =
      '$kApplicationPathWindowsTest${path.separator}$kSettingsFileName';

  final String applicationPicturePath =
      '$kApplicationPathWindowsTest${path.separator}$kPictureDirName';
  final String appPictureAudioMapFilePathName =
      '$applicationPicturePath${path.separator}pictureAudioMap.json';
  final String availableTestPicturePath =
      '$kApplicationPathWindowsTest${path.separator}availableTestPictures';

  final String testPictureOneFileName = 'Seigneur.jpg';
  final String testAvailablePictureOneFilePathName =
      '$availableTestPicturePath${path.separator}$testPictureOneFileName';
  final String testPictureOneFilePathName =
      '$applicationPicturePath${path.separator}$testPictureOneFileName';

  final String testPlaylistOneTitle = 'local';
  final String testPlaylistOnePath =
      '$kApplicationPathWindowsTest${path.separator}playlists${path.separator}$testPlaylistOneTitle';
  final String testPlaylistOnePicturePath =
      '${testPlaylistOnePath}${path.separator}$kPictureDirName';

  final String testPlaylistTwoTitle = 'local_two';
  final String testPlaylistTwoPath =
      '$kApplicationPathWindowsTest${path.separator}playlists${path.separator}$testPlaylistTwoTitle';
  final String testPlaylistTwoPicturePath =
      '${testPlaylistTwoPath}${path.separator}$kPictureDirName';

  final String playlistOneAudioOneFileName =
      "250412-125202-Chapitre 0 préface de l'auteur Chemin Saint Josémaria 25-02-09.mp3";
  final String playlistOneAudioOnePictureJsonFilePathName =
      "$testPlaylistOnePicturePath${path.separator}250412-125202-Chapitre 0 préface de l'auteur Chemin Saint Josémaria 25-02-09.json";

  // Create test objects
  late Playlist playlistOne;
  late Audio playlistOneAudioOne;
  late Audio playlistOneAudioTwo;

  setUp(() async {
    // Copy the test initial data to the app dir
    DirUtil.copyFilesFromDirAndSubDirsToDirectory(
      sourceRootPath:
          "$kDownloadAppTestSavedDataDir${path.separator}picture_vm_unit_test_data",
      destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
    );

    // Setup shared preferences
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();

    // Initialize services and view model
    settingsDataService = SettingsDataService(
      sharedPreferences: sharedPreferences,
      isTest: true,
    );
    settingsDataService.loadSettingsFromFile(
      settingsJsonPathFileName: testAppSettingsPathFileName,
    );

    WarningMessageVM warningMessageVM = WarningMessageVM();

    AudioDownloadVM audioDownloadVM = AudioDownloadVM(
      settingsDataService: settingsDataService,
      warningMessageVM: warningMessageVM,
    );
    audioDownloadVM.loadExistingPlaylists();

    // Initialize test data
    playlistOne = audioDownloadVM.listOfPlaylist[0];
    playlistOneAudioOne = playlistOne.downloadedAudioLst[0];
    playlistOneAudioTwo = playlistOne.downloadedAudioLst[1];

    pictureVM = PictureVM(
      settingsDataService: settingsDataService,
    );
  });

  tearDown(() {
    // Clean up any files created during tests
    DirUtil.deleteFilesInDirAndSubDirs(
      rootPath: kPlaylistDownloadRootPathWindowsTest,
    );
  });

  // Helper method to create a test picture JSON file
  void createTestPictureJsonFile(String jsonPath, List<Picture> pictures) {
    final dir = Directory(path.dirname(jsonPath));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final file = File(jsonPath);
    final jsonContent = jsonEncode(pictures.map((p) => p.toJson()).toList());
    file.writeAsStringSync(jsonContent);
  }

  // Helper method to create a test pictureAudio.json file
  void createTestPictureAudioMapFile(
      Map<String, List<String>> pictureAudioMap) {
    final file = File(appPictureAudioMapFilePathName);
    final jsonContent = jsonEncode(pictureAudioMap);
    file.writeAsStringSync(jsonContent);
  }

  group('Add picture to audio', () {
    test('''Add picture which not already exists. Then re-add the same picture
           and verify that nothing was changed.''', () {
      final pictureAudioMapFile = File(appPictureAudioMapFilePathName);

      // Ensure the picture-audio map file does not exist before
      // the test
      expect(pictureAudioMapFile.existsSync(), false);

      pictureVM.addPictureToAudio(
        audio: playlistOneAudioOne,
        pictureFilePathName: testAvailablePictureOneFilePathName,
      );

      DateTime nowLimitedToSeconds =
          DateTimeUtil.getDateTimeLimitedToSeconds(DateTime.now());

      // Verify picture JSON file creation and content

      expect(File(playlistOneAudioOnePictureJsonFilePathName).existsSync(), true);

      final List<Picture> pictureLstAfterAdd = JsonDataService.loadListFromFile(
        jsonPathFileName: playlistOneAudioOnePictureJsonFilePathName,
        type: Picture,
      );

      expect(pictureLstAfterAdd.length, 1);

      Picture firstPictureAfterAdd = pictureLstAfterAdd.first;

      expect(firstPictureAfterAdd.fileName, testPictureOneFileName);
      expect(firstPictureAfterAdd.isDisplayable, true);
      expect(
          DateTimeUtil.getDateTimeLimitedToSeconds(
              firstPictureAfterAdd.additionToAudioDateTime),
          nowLimitedToSeconds);
      expect(
          DateTimeUtil.getDateTimeLimitedToSeconds(
              firstPictureAfterAdd.lastDisplayDateTime),
          nowLimitedToSeconds);

      // Verify picture-audio map

      expect(pictureAudioMapFile.existsSync(), true);

      final Map<String, dynamic> pictureAudioMap =
          jsonDecode(pictureAudioMapFile.readAsStringSync());
      expect(pictureAudioMap.length, 1);
      expect(pictureAudioMap.containsKey(testPictureOneFileName), true);
      expect(
          (pictureAudioMap[testPictureOneFileName] as List).contains(
              '$testPlaylistOneTitle|${playlistOneAudioOne.audioFileName.replaceAll('.mp3', '')}'),
          true);

      // Re-add the same picture and verify that nothing was changed

      pictureVM.addPictureToAudio(
        audio: playlistOneAudioOne,
        pictureFilePathName: testPictureOneFilePathName,
      );

      // Verify picture JSON file content remains unchanged
      final List<Picture> pictureLstAfterReAdd =
          JsonDataService.loadListFromFile(
        jsonPathFileName: playlistOneAudioOnePictureJsonFilePathName,
        type: Picture,
      );
      expect(pictureLstAfterReAdd, pictureLstAfterAdd);
      Picture firstPictureAfterReAdd = pictureLstAfterReAdd.first;
      expect(firstPictureAfterReAdd, firstPictureAfterAdd);

      // Verify picture-audio map after re-add remains unchanged
      final Map<String, dynamic> pictureAudioMapAfterReAdd =
          jsonDecode(pictureAudioMapFile.readAsStringSync());
      expect(pictureAudioMapAfterReAdd, pictureAudioMap);
      expect(
          (pictureAudioMapAfterReAdd[testPictureOneFileName] as List).contains(
              '$testPlaylistOneTitle|${playlistOneAudioOne.audioFileName.replaceAll('.mp3', '')}'),
          true);
    });
    test('''Add same picture to a second audio.''', () {
      final pictureAudioMapFile = File(appPictureAudioMapFilePathName);

      // Ensure the picture-audio map file does not exist before
      // the test
      expect(pictureAudioMapFile.existsSync(), false);

      pictureVM.addPictureToAudio(
        audio: playlistOneAudioOne,
        pictureFilePathName: testAvailablePictureOneFilePathName,
      );

      DateTime nowLimitedToSeconds =
          DateTimeUtil.getDateTimeLimitedToSeconds(DateTime.now());

      // Verify picture JSON file creation and content

      expect(File(playlistOneAudioOnePictureJsonFilePathName).existsSync(), true);

      final List<Picture> pictureLstAfterAdd = JsonDataService.loadListFromFile(
        jsonPathFileName: playlistOneAudioOnePictureJsonFilePathName,
        type: Picture,
      );

      expect(pictureLstAfterAdd.length, 1);

      Picture firstPictureAfterAdd = pictureLstAfterAdd.first;

      expect(firstPictureAfterAdd.fileName, testPictureOneFileName);
      expect(firstPictureAfterAdd.isDisplayable, true);
      expect(
          DateTimeUtil.getDateTimeLimitedToSeconds(
              firstPictureAfterAdd.additionToAudioDateTime),
          nowLimitedToSeconds);
      expect(
          DateTimeUtil.getDateTimeLimitedToSeconds(
              firstPictureAfterAdd.lastDisplayDateTime),
          nowLimitedToSeconds);

      // Verify picture-audio map

      expect(pictureAudioMapFile.existsSync(), true);

      final Map<String, dynamic> pictureAudioMap =
          jsonDecode(pictureAudioMapFile.readAsStringSync());
      expect(pictureAudioMap.length, 1);
      expect(pictureAudioMap.containsKey(testPictureOneFileName), true);
      expect(
          (pictureAudioMap[testPictureOneFileName] as List).contains(
              '$testPlaylistOneTitle|${playlistOneAudioOne.audioFileName.replaceAll('.mp3', '')}'),
          true);

      // Re-add the same picture and verify that nothing was changed

      pictureVM.addPictureToAudio(
        audio: playlistOneAudioOne,
        pictureFilePathName: testPictureOneFilePathName,
      );

      // Verify picture JSON file content remains unchanged
      final List<Picture> pictureLstAfterReAdd =
          JsonDataService.loadListFromFile(
        jsonPathFileName: playlistOneAudioOnePictureJsonFilePathName,
        type: Picture,
      );
      expect(pictureLstAfterReAdd, pictureLstAfterAdd);
      Picture firstPictureAfterReAdd = pictureLstAfterReAdd.first;
      expect(firstPictureAfterReAdd, firstPictureAfterAdd);

      // Verify picture-audio map after re-add remains unchanged
      final Map<String, dynamic> pictureAudioMapAfterReAdd =
          jsonDecode(pictureAudioMapFile.readAsStringSync());
      expect(pictureAudioMapAfterReAdd, pictureAudioMap);
      expect(
          (pictureAudioMapAfterReAdd[testPictureOneFileName] as List).contains(
              '$testPlaylistOneTitle|${playlistOneAudioOne.audioFileName.replaceAll('.mp3', '')}'),
          true);
    });
  });
  group('Next picture tests', () {
    test('getAudioPicturesNumber - returns correct count', () {
      // Arrange
      final pictureJsonPath =
          '$testPlaylistOnePicturePath${path.separator}${playlistOneAudioOneFileName.replaceAll('.mp3', '.json')}';
      createTestPictureJsonFile(pictureJsonPath,
          [Picture(fileName: 'pic1.jpg'), Picture(fileName: 'pic2.jpg')]);

      // Act
      final count = pictureVM.getAudioPicturesNumber(audio: playlistOneAudioOne);

      // Assert
      expect(count, 2);
    });

    test('getAudioPicturesNumber - returns 0 when no pictures', () {
      // Act
      final count = pictureVM.getAudioPicturesNumber(audio: playlistOneAudioOne);

      // Assert
      expect(count, 0);
    });

    test('removeAudioPicture - removes the last picture', () {
      // Arrange
      final pictureJsonPath =
          '$testPlaylistOnePicturePath${path.separator}${playlistOneAudioOneFileName.replaceAll('.mp3', '.json')}';
      createTestPictureJsonFile(pictureJsonPath,
          [Picture(fileName: 'pic1.jpg'), Picture(fileName: 'pic2.jpg')]);

      // Create picture-audio map
      createTestPictureAudioMapFile({
        'pic1.jpg': ['$testPlaylistOneTitle|test_audio'],
        'pic2.jpg': ['$testPlaylistOneTitle|test_audio'],
      });

      // Act
      pictureVM.removeAudioPicture(audio: playlistOneAudioOne);

      // Assert
      final pictures = JsonDataService.loadListFromFile(
        jsonPathFileName: pictureJsonPath,
        type: Picture,
      );

      expect(pictures.length, 1);
      expect(pictures.first.fileName, 'pic1.jpg');

      // Verify picture-audio map
      final pictureAudioMapFile = File(appPictureAudioMapFilePathName);
      final Map<String, dynamic> pictureAudioMap =
          jsonDecode(pictureAudioMapFile.readAsStringSync());
      expect(pictureAudioMap.containsKey('pic2.jpg'), false);
    });

    test('removeAudioPicture - deletes file when removing last picture', () {
      // Arrange
      final pictureJsonPath =
          '$testPlaylistOnePicturePath${path.separator}${playlistOneAudioOneFileName.replaceAll('.mp3', '.json')}';
      createTestPictureJsonFile(
          pictureJsonPath, [Picture(fileName: testPictureOneFileName)]);

      // Create picture-audio map
      createTestPictureAudioMapFile({
        testPictureOneFileName: ['$testPlaylistOneTitle|test_audio'],
      });

      // Act
      pictureVM.removeAudioPicture(audio: playlistOneAudioOne);

      // Assert
      final file = File(pictureJsonPath);
      expect(file.existsSync(), false);

      // Verify picture-audio map
      final pictureAudioMapFile = File(appPictureAudioMapFilePathName);
      final Map<String, dynamic> pictureAudioMap =
          jsonDecode(pictureAudioMapFile.readAsStringSync());
      expect(pictureAudioMap.containsKey(testPictureOneFileName), false);
    });

    test('getAudioPictureFile - returns file when picture exists', () {
      // Arrange
      final pictureJsonPath =
          '$testPlaylistOnePicturePath${path.separator}${playlistOneAudioOneFileName.replaceAll('.mp3', '.json')}';
      createTestPictureJsonFile(
          pictureJsonPath, [Picture(fileName: testPictureOneFileName)]);

      // Create the actual picture file in the application picture path
      File(appPictureAudioMapFilePathName)
          .writeAsBytesSync([0, 1, 2, 3]); // Simple dummy content

      // Act
      final result = pictureVM.getAudioPictureFile(audio: playlistOneAudioOne);

      // Assert
      expect(result, isNotNull);
      expect(result!.path, testPictureOneFilePathName);

      // Clean up the additional file
      if (File(playlistOneAudioOnePictureJsonFilePathName).existsSync()) {
        File(playlistOneAudioOnePictureJsonFilePathName).deleteSync();
      }
    });

    test('getAudioPictureFile - returns null when no pictures', () {
      // Act
      final result = pictureVM.getAudioPictureFile(audio: playlistOneAudioOne);

      // Assert
      expect(result, isNull);
    });

    test('getAudioPictureFile - returns null when file does not exist', () {
      // Arrange
      final pictureJsonPath =
          '$testPlaylistOnePicturePath${path.separator}${playlistOneAudioOneFileName.replaceAll('.mp3', '.json')}';
      createTestPictureJsonFile(
          pictureJsonPath, [Picture(fileName: 'nonexistent.jpg')]);

      // Act
      final result = pictureVM.getAudioPictureFile(audio: playlistOneAudioOne);

      // Assert
      expect(result, isNull);
    });

    test('getPlaylistAudioPicturedFileNamesNoExtLst - returns correct list',
        () {
      // Arrange
      final picture1JsonPath =
          '$testPlaylistOnePicturePath${path.separator}audio1.json';
      final picture2JsonPath =
          '$testPlaylistOnePicturePath${path.separator}audio2.json';

      // Create picture JSON files
      createTestPictureJsonFile(
          picture1JsonPath, [Picture(fileName: 'pic1.jpg')]);
      createTestPictureJsonFile(
          picture2JsonPath, [Picture(fileName: 'pic2.jpg')]);

      // Act
      final result = pictureVM.getPlaylistAudioPicturedFileNamesNoExtLst(
        playlist: playlistOne,
      );

      // Assert
      expect(result.length, 2);
      expect(result.contains('audio1'), true);
      expect(result.contains('audio2'), true);

      // Clean up
      File(picture1JsonPath).deleteSync();
      File(picture2JsonPath).deleteSync();
    });

    test(
        'getPlaylistAudioPicturedFileNamesNoExtLst - returns empty list when directory does not exist',
        () {
      // Arrange - Delete the picture directory
      if (Directory(testPlaylistOnePicturePath).existsSync()) {
        Directory(testPlaylistOnePicturePath).deleteSync(recursive: true);
      }

      // Act
      final result = pictureVM.getPlaylistAudioPicturedFileNamesNoExtLst(
        playlist: playlistOne,
      );

      // Assert
      expect(result.length, 0);

      // Recreate directory for other tests
      Directory(testPlaylistOnePicturePath).createSync(recursive: true);
    });

    test('deleteAudioPictureIfExist - deletes picture and associations', () {
      // Arrange
      final pictureJsonPath =
          '$testPlaylistOnePicturePath${path.separator}${playlistOneAudioOneFileName.replaceAll('.mp3', '.json')}';
      createTestPictureJsonFile(
          pictureJsonPath, [Picture(fileName: testPictureOneFileName)]);

      // Create picture-audio map
      createTestPictureAudioMapFile({
        testPictureOneFileName: ['$testPlaylistOneTitle|test_audio'],
      });

      // Act
      pictureVM.deleteAudioPictureJsonFileIfExist(audio: playlistOneAudioOne);

      // Assert
      final file = File(pictureJsonPath);
      expect(file.existsSync(), false);

      // Verify picture-audio map
      final pictureAudioMapFile = File(appPictureAudioMapFilePathName);
      final Map<String, dynamic> pictureAudioMap =
          jsonDecode(pictureAudioMapFile.readAsStringSync());
      expect(pictureAudioMap.containsKey(testPictureOneFileName), false);
    });

    test(
        'moveAudioPictureJsonFileToTargetPlaylist - moves file and updates associations',
        () {
      // Arrange
      final sourcePictureJsonPath =
          '$testPlaylistOnePicturePath${path.separator}${playlistOneAudioOneFileName.replaceAll('.mp3', '.json')}';
      createTestPictureJsonFile(
          sourcePictureJsonPath, [Picture(fileName: testPictureOneFileName)]);

      final targetPlaylistPath = 'test_target_playlist_path';
      final targetPicturePath =
          '$targetPlaylistPath${path.separator}$kPictureDirName';

      // Create target directory
      Directory(targetPicturePath).createSync(recursive: true);

      final targetPlaylist = Playlist(
        title: 'TargetPlaylist',
        playlistType: PlaylistType.local,
        playlistQuality: PlaylistQuality.voice,
      );

      playlistOne.downloadPath = targetPlaylistPath;

      // Create picture-audio map
      createTestPictureAudioMapFile({
        testPictureOneFileName: ['$testPlaylistOneTitle|test_audio'],
      });

      // Act
      pictureVM.moveAudioPictureJsonFileToTargetPlaylist(
        audio: playlistOneAudioOne,
        sourcePlaylist: playlistOne,
        targetPlaylist: targetPlaylist,
      );

      // Assert
      final sourceFile = File(sourcePictureJsonPath);
      expect(sourceFile.existsSync(), false);

      final targetFile = File(
          '$targetPicturePath${path.separator}${playlistOneAudioOneFileName.replaceAll('.mp3', '.json')}');
      expect(targetFile.existsSync(), true);

      // Verify picture-audio map
      final pictureAudioMapFile = File(appPictureAudioMapFilePathName);
      final Map<String, dynamic> pictureAudioMap =
          jsonDecode(pictureAudioMapFile.readAsStringSync());

      // Check that the old association has been removed
      bool hasOldAssociation = false;
      if (pictureAudioMap.containsKey(testPictureOneFileName)) {
        hasOldAssociation = (pictureAudioMap[testPictureOneFileName] as List)
            .contains('$testPlaylistOneTitle|test_audio');
      }
      expect(hasOldAssociation, false);

      // Check that the new association has been added
      expect(
          (pictureAudioMap[testPictureOneFileName] as List)
              .contains('TargetPlaylist|test_audio'),
          true);

      // Clean up
      if (Directory(targetPlaylistPath).existsSync()) {
        Directory(targetPlaylistPath).deleteSync(recursive: true);
      }
    });

    test(
        'copyAudioPictureJsonFileToTargetPlaylist - copies file and adds associations',
        () {
      // Arrange
      final sourcePictureJsonPath =
          '$testPlaylistOnePicturePath${path.separator}${playlistOneAudioOneFileName.replaceAll('.mp3', '.json')}';
      createTestPictureJsonFile(
          sourcePictureJsonPath, [Picture(fileName: testPictureOneFileName)]);

      final targetPlaylistPath = 'test_target_playlist_path';
      final targetPicturePath =
          '$targetPlaylistPath${path.separator}$kPictureDirName';

      // Create target directory
      Directory(targetPicturePath).createSync(recursive: true);

      final targetPlaylist = Playlist(
        title: 'TargetPlaylist',
        playlistType: PlaylistType.local,
        playlistQuality: PlaylistQuality.voice,
      );

      playlistOne.downloadPath = targetPlaylistPath;

      // Create picture-audio map
      createTestPictureAudioMapFile({
        testPictureOneFileName: ['$testPlaylistOneTitle|test_audio'],
      });

      // Act
      pictureVM.copyAudioPictureJsonFileToTargetPlaylist(
        audio: playlistOneAudioOne,
        targetPlaylist: targetPlaylist,
      );

      // Assert
      final sourceFile = File(sourcePictureJsonPath);
      expect(sourceFile.existsSync(), true);

      final targetFile = File(
          '$targetPicturePath${path.separator}${playlistOneAudioOneFileName.replaceAll('.mp3', '.json')}');
      expect(targetFile.existsSync(), true);

      // Verify picture-audio map
      final pictureAudioMapFile = File(appPictureAudioMapFilePathName);
      final Map<String, dynamic> pictureAudioMap =
          jsonDecode(pictureAudioMapFile.readAsStringSync());

      // Check that the original association is preserved
      expect(
          (pictureAudioMap[testPictureOneFileName] as List)
              .contains('$testPlaylistOneTitle|test_audio'),
          true);

      // Check that the new association has been added
      expect(
          (pictureAudioMap[testPictureOneFileName] as List)
              .contains('TargetPlaylist|test_audio'),
          true);

      // Clean up
      if (Directory(targetPlaylistPath).existsSync()) {
        Directory(targetPlaylistPath).deleteSync(recursive: true);
      }
    });
  });
}

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

  final String testPictureTwoFileName = "Dieu je T'adore.jpg";
  final String testAvailablePictureTwoFilePathName =
      '$availableTestPicturePath${path.separator}$testPictureTwoFileName';

  final String testPlaylistOneTitle = 'local';
  final String testPlaylistOnePath =
      '$kApplicationPathWindowsTest${path.separator}playlists${path.separator}$testPlaylistOneTitle';
  final String testPlaylistOnePicturePath =
      '$testPlaylistOnePath${path.separator}$kPictureDirName';

  final String testPlaylistTwoTitle = 'local_two';
  final String testPlaylistTwoPath =
      '$kApplicationPathWindowsTest${path.separator}playlists${path.separator}$testPlaylistTwoTitle';
  final String testPlaylistTwoPicturePath =
      '$testPlaylistTwoPath${path.separator}$kPictureDirName';

  final String playlistOneAudioOneFileName =
      "250412-125202-Chapitre 0 préface de l'auteur Chemin Saint Josémaria 25-02-09.mp3";
  final String playlistOneAudioOnePictureJsonFilePathName =
      "$testPlaylistOnePicturePath${path.separator}250412-125202-Chapitre 0 préface de l'auteur Chemin Saint Josémaria 25-02-09.json";
  final String playlistOneAudioTwoPictureJsonFilePathName =
      "$testPlaylistOnePicturePath${path.separator}250417-152110-German Shepherd's Heartwarming Reaction When First Meeting Abandoned Kitten 25-04-09.json";

  final String playlistTwoAudioOnePictureJsonFilePathName =
      "$testPlaylistTwoPicturePath${path.separator}250412-125202-Chapitre 0 préface de l'auteur Chemin Saint Josémaria 25-02-09.json";
  final String playlistTwoAudioTwoPictureJsonFilePathName =
      "$testPlaylistTwoPicturePath${path.separator}231117-002828-morning _ cinematic video 23-07-01.json";

  // Create test objects
  late Playlist playlistOne;
  late Audio playlistOneAudioOne;
  late Audio playlistOneAudioTwo;
  late Playlist playlistTwo;
  late Audio playlistTwoAudioOne;
  late Audio playlistTwoAudioTwo;

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

    playlistTwo = audioDownloadVM.listOfPlaylist[1];
    playlistTwoAudioOne = playlistTwo.downloadedAudioLst[0];
    playlistTwoAudioTwo = playlistTwo.downloadedAudioLst[1];

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

  group('Add picture to audio', () {
    test('''Add picture which not already exists. Then re-add the same picture
           and verify that nothing was changed.''', () {
      final File pictureAudioMapFile = File(appPictureAudioMapFilePathName);

      // Ensure the picture-audio map file does not exist before
      // the test
      expect(pictureAudioMapFile.existsSync(), false);

      pictureVM.addPictureToAudio(
        audio: playlistOneAudioOne,
        pictureFilePathName: testAvailablePictureOneFilePathName,
      );

      DateTime nowLimitedToSeconds =
          DateTimeUtil.getDateTimeLimitedToSeconds(DateTime.now());

      // Verify audio picture JSON file creation and content

      expect(
          File(playlistOneAudioOnePictureJsonFilePathName).existsSync(), true);

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

      // Verify application picture-audio map

      expect(pictureAudioMapFile.existsSync(), true);

      final Map<String, dynamic> pictureAudioMap =
          jsonDecode(pictureAudioMapFile.readAsStringSync());
      expect(pictureAudioMap.length, 1);
      List pictureAudioMapLst =
          (pictureAudioMap[testPictureOneFileName] as List);
      expect(pictureAudioMapLst.length, 1);
      expect(
        pictureAudioMapLst[0],
        '$testPlaylistOneTitle|${playlistOneAudioOne.audioFileName.replaceAll('.mp3', '')}',
      );

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

      // Verify application picture-audio map after re-add remains unchanged
      final Map<String, dynamic> pictureAudioMapAfterReAdd =
          jsonDecode(pictureAudioMapFile.readAsStringSync());
      pictureAudioMapLst =
          (pictureAudioMapAfterReAdd[testPictureOneFileName] as List);
      expect(pictureAudioMapLst.length, 1);
      expect(
        pictureAudioMapLst[0],
        '$testPlaylistOneTitle|${playlistOneAudioOne.audioFileName.replaceAll('.mp3', '')}',
      );
    });
    test('''Add same picture to a second audio in same playlist.''', () {
      final File pictureAudioMapFile = File(appPictureAudioMapFilePathName);

      // Ensure the picture-audio map file does not exist before
      // the test
      expect(pictureAudioMapFile.existsSync(), false);

      // Add picture to the playlist one first audio
      pictureVM.addPictureToAudio(
        audio: playlistOneAudioOne,
        pictureFilePathName: testAvailablePictureOneFilePathName,
      );

      // Add same picture to the playlist one second audio
      pictureVM.addPictureToAudio(
        audio: playlistOneAudioTwo,
        pictureFilePathName: testAvailablePictureOneFilePathName,
      );

      DateTime nowLimitedToSeconds =
          DateTimeUtil.getDateTimeLimitedToSeconds(DateTime.now());

      // Verify audio picture JSON file creation and content

      expect(
          File(playlistOneAudioOnePictureJsonFilePathName).existsSync(), true);
      expect(
          File(playlistOneAudioTwoPictureJsonFilePathName).existsSync(), true);

      final List<Picture> pictureLstOneAfterAdd =
          JsonDataService.loadListFromFile(
        jsonPathFileName: playlistOneAudioOnePictureJsonFilePathName,
        type: Picture,
      );

      expect(pictureLstOneAfterAdd.length, 1);

      Picture firstPictureAfterAdd = pictureLstOneAfterAdd.first;

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

      final List<Picture> pictureLstTwoAfterAdd =
          JsonDataService.loadListFromFile(
        jsonPathFileName: playlistOneAudioTwoPictureJsonFilePathName,
        type: Picture,
      );

      expect(pictureLstTwoAfterAdd.length, 1);

      firstPictureAfterAdd = pictureLstTwoAfterAdd.first;

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

      // Verify application picture-audio map

      expect(pictureAudioMapFile.existsSync(), true);

      final Map<String, dynamic> pictureAudioMap =
          jsonDecode(pictureAudioMapFile.readAsStringSync());
      expect(pictureAudioMap.length, 1);
      expect(pictureAudioMap.containsKey(testPictureOneFileName), true);
      List pictureAudioMapLst =
          (pictureAudioMap[testPictureOneFileName] as List);
      expect(pictureAudioMapLst.length, 2);
      expect(
        pictureAudioMapLst[0],
        '$testPlaylistOneTitle|${playlistOneAudioOne.audioFileName.replaceAll('.mp3', '')}',
      );
      expect(
        pictureAudioMapLst[1],
        '$testPlaylistOneTitle|${playlistOneAudioTwo.audioFileName.replaceAll('.mp3', '')}',
      );
    });
    test(
        '''Add picture+getAudioPictureNumber to an audio in an other playlist. Then add a
            new picture to the same audio.''', () {
      final File pictureAudioMapFile = File(appPictureAudioMapFilePathName);

      // Ensure the picture-audio map file does not exist before
      // the test
      expect(pictureAudioMapFile.existsSync(), false);

      // Add picture to the playlist one first audio
      pictureVM.addPictureToAudio(
        audio: playlistOneAudioOne,
        pictureFilePathName: testAvailablePictureOneFilePathName,
      );

      // Add same picture to the playlist one second audio
      pictureVM.addPictureToAudio(
        audio: playlistOneAudioTwo,
        pictureFilePathName: testAvailablePictureOneFilePathName,
      );

      // Add same picture to the playlist two first audio
      pictureVM.addPictureToAudio(
        audio: playlistTwoAudioOne,
        pictureFilePathName: testAvailablePictureOneFilePathName,
      );

      // Verify that the playlist two second audio picture number

      expect(pictureVM.getAudioPicturesNumber(audio: playlistTwoAudioTwo), 0);

      // Add same picture to the playlist two second audio
      pictureVM.addPictureToAudio(
        audio: playlistTwoAudioTwo,
        pictureFilePathName: testAvailablePictureOneFilePathName,
      );

      expect(pictureVM.getAudioPicturesNumber(audio: playlistTwoAudioTwo), 1);

      // Add new picture to the playlist two second audio
      pictureVM.addPictureToAudio(
        audio: playlistTwoAudioTwo,
        pictureFilePathName: testAvailablePictureTwoFilePathName,
      );

      expect(pictureVM.getAudioPicturesNumber(audio: playlistTwoAudioTwo), 2);

      DateTime nowLimitedToSeconds =
          DateTimeUtil.getDateTimeLimitedToSeconds(DateTime.now());

      // Verify playlist two first audio picture JSON file creation and content

      expect(
          File(playlistTwoAudioOnePictureJsonFilePathName).existsSync(), true);

      final List<Picture> pictureLstOneAfterAdd =
          JsonDataService.loadListFromFile(
        jsonPathFileName: playlistTwoAudioOnePictureJsonFilePathName,
        type: Picture,
      );

      expect(pictureLstOneAfterAdd.length, 1);

      Picture firstPictureAfterAdd = pictureLstOneAfterAdd.first;

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

      // Verify playlist two second picture JSON files creation and content

      expect(
          File(playlistTwoAudioTwoPictureJsonFilePathName).existsSync(), true);

      final List<Picture> pictureLstTwoAfterAdd =
          JsonDataService.loadListFromFile(
        jsonPathFileName: playlistTwoAudioTwoPictureJsonFilePathName,
        type: Picture,
      );

      expect(pictureLstTwoAfterAdd.length, 2);

      firstPictureAfterAdd = pictureLstTwoAfterAdd.first;

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

      Picture secondPictureAfterAdd = pictureLstTwoAfterAdd[1];

      expect(secondPictureAfterAdd.fileName, testPictureTwoFileName);
      expect(secondPictureAfterAdd.isDisplayable, true);
      expect(
          DateTimeUtil.getDateTimeLimitedToSeconds(
              secondPictureAfterAdd.additionToAudioDateTime),
          nowLimitedToSeconds);
      expect(
          DateTimeUtil.getDateTimeLimitedToSeconds(
              secondPictureAfterAdd.lastDisplayDateTime),
          nowLimitedToSeconds);

      // Verify application picture-audio map

      expect(pictureAudioMapFile.existsSync(), true);

      final Map<String, dynamic> pictureAudioMap =
          jsonDecode(pictureAudioMapFile.readAsStringSync());
      expect(pictureAudioMap.length, 2);
      expect(pictureAudioMap.containsKey(testPictureOneFileName), true);
      expect(pictureAudioMap.containsKey(testPictureTwoFileName), true);

      List pictureAudioMapLst =
          (pictureAudioMap[testPictureOneFileName] as List);
      expect(pictureAudioMapLst.length, 4);
      expect(
        pictureAudioMapLst[0],
        '$testPlaylistOneTitle|${playlistOneAudioOne.audioFileName.replaceAll('.mp3', '')}',
      );
      expect(
        pictureAudioMapLst[1],
        '$testPlaylistOneTitle|${playlistOneAudioTwo.audioFileName.replaceAll('.mp3', '')}',
      );
      expect(
        pictureAudioMapLst[2],
        '$testPlaylistTwoTitle|${playlistTwoAudioOne.audioFileName.replaceAll('.mp3', '')}',
      );
      expect(
        pictureAudioMapLst[3],
        '$testPlaylistTwoTitle|${playlistTwoAudioTwo.audioFileName.replaceAll('.mp3', '')}',
      );

      pictureAudioMapLst = (pictureAudioMap[testPictureTwoFileName] as List);
      expect(pictureAudioMapLst.length, 1);
      expect(
        pictureAudioMapLst[0],
        '$testPlaylistTwoTitle|${playlistTwoAudioTwo.audioFileName.replaceAll('.mp3', '')}',
      );

      // Ensure the added picture files are present in the application
      // picture directory
      List<String> appPictureJpgFileLst = DirUtil.listFileNamesInDir(
        directoryPath: applicationPicturePath,
        fileExtension: 'jpg',
      );

      expect(appPictureJpgFileLst.length, 2);
      expect(appPictureJpgFileLst.contains(testPictureOneFileName), true);
      expect(appPictureJpgFileLst.contains(testPictureTwoFileName), true);
    });
  });
  group('Remove picture from audio', () {
    test(
        '''Removes the second picture added to an audio. Then remove the remaining picture
            of this audio. Check the audio json picture content as well as the application
            picture-audio map content. Finally, verify that after removing the last audio
            picture the playlist picture dir was deleted since no other audio has a picture.''',
        () {
      // Add a first picture to the playlist two second audio
      pictureVM.addPictureToAudio(
        audio: playlistTwoAudioTwo,
        pictureFilePathName: testAvailablePictureOneFilePathName,
      );

      expect(pictureVM.getAudioPicturesNumber(audio: playlistTwoAudioTwo), 1);

      // Add a new picture to the playlist two second audio
      pictureVM.addPictureToAudio(
        audio: playlistTwoAudioTwo,
        pictureFilePathName: testAvailablePictureTwoFilePathName,
      );

      expect(pictureVM.getAudioPicturesNumber(audio: playlistTwoAudioTwo), 2);

      // Verify playlist two second picture JSON files creation and content

      expect(
          File(playlistTwoAudioTwoPictureJsonFilePathName).existsSync(), true);

      final List<Picture> pictureLstTwoAfterAdd =
          JsonDataService.loadListFromFile(
        jsonPathFileName: playlistTwoAudioTwoPictureJsonFilePathName,
        type: Picture,
      );

      // Verify that the playlist two audio two JSON file contains
      // two pictures
      expect(pictureLstTwoAfterAdd.length, 2);

      Picture firstPictureAfterAdd = pictureLstTwoAfterAdd.first;
      expect(firstPictureAfterAdd.fileName, testPictureOneFileName);

      Picture secondPictureAfterAdd = pictureLstTwoAfterAdd[1];
      expect(secondPictureAfterAdd.fileName, testPictureTwoFileName);

      // Verify application picture-audio map

      File pictureAudioMapFile = File(appPictureAudioMapFilePathName);

      Map<String, dynamic> pictureAudioMap =
          jsonDecode(pictureAudioMapFile.readAsStringSync());
      expect(pictureAudioMap.length, 2);
      expect(pictureAudioMap.containsKey(testPictureOneFileName), true);
      expect(pictureAudioMap.containsKey(testPictureTwoFileName), true);

      List firstAddedPictureAudioMapLst =
          (pictureAudioMap[testPictureOneFileName] as List);
      expect(firstAddedPictureAudioMapLst.length, 1);
      expect(
        firstAddedPictureAudioMapLst[0],
        '$testPlaylistTwoTitle|${playlistTwoAudioTwo.audioFileName.replaceAll('.mp3', '')}',
      );

      List secondAddedPictureAudioMapLst =
          (pictureAudioMap[testPictureTwoFileName] as List);
      expect(secondAddedPictureAudioMapLst.length, 1);
      expect(
        secondAddedPictureAudioMapLst[0],
        '$testPlaylistTwoTitle|${playlistTwoAudioTwo.audioFileName.replaceAll('.mp3', '')}',
      );

      // Ensure the added picture files are present in the application
      // picture directory
      List<String> appPictureJpgFileLst = DirUtil.listFileNamesInDir(
        directoryPath: applicationPicturePath,
        fileExtension: 'jpg',
      );

      expect(appPictureJpgFileLst.length, 2);
      expect(appPictureJpgFileLst.contains(testPictureOneFileName), true);
      expect(appPictureJpgFileLst.contains(testPictureTwoFileName), true);

      // Now, remove the last added picture from the playlist two
      // second audio
      pictureVM.removeLastAddedAudioPicture(audio: playlistTwoAudioTwo);

      // Verify that the playlist two audio two JSON file contains
      // now one picture
      expect(pictureVM.getAudioPicturesNumber(audio: playlistTwoAudioTwo), 1);

      // Verify playlist two audio two picture JSON file content
      final List<Picture> audioTwoPictureLstAfterRemove =
          JsonDataService.loadListFromFile(
        jsonPathFileName: playlistTwoAudioTwoPictureJsonFilePathName,
        type: Picture,
      );

      expect(audioTwoPictureLstAfterRemove.length, 1);

      Picture remainingPicture = audioTwoPictureLstAfterRemove.last;

      expect(remainingPicture.fileName, testPictureOneFileName);

      // Verify now the application picture-audio map content

      pictureAudioMapFile = File(appPictureAudioMapFilePathName);

      pictureAudioMap = jsonDecode(pictureAudioMapFile.readAsStringSync());
      expect(pictureAudioMap.length, 1);
      expect(pictureAudioMap.containsKey(testPictureOneFileName), true);
      expect(pictureAudioMap.containsKey(testPictureTwoFileName),
          false); // The second picture was removed

      firstAddedPictureAudioMapLst =
          (pictureAudioMap[testPictureOneFileName] as List);
      expect(firstAddedPictureAudioMapLst.length, 1);
      expect(
        firstAddedPictureAudioMapLst[0],
        '$testPlaylistTwoTitle|${playlistTwoAudioTwo.audioFileName.replaceAll('.mp3', '')}',
      );

      // Now, remove the remaining picture from the playlist two
      // second audio
      pictureVM.removeLastAddedAudioPicture(audio: playlistTwoAudioTwo);

      // Verify that the playlist two audio two has no more pictures
      expect(pictureVM.getAudioPicturesNumber(audio: playlistTwoAudioTwo), 0);

      // Verify that the playlist two audio picture dir was deleted
      expect(Directory(testPlaylistTwoPicturePath).existsSync(), false);

      // Verify now the application picture-audio map content

      pictureAudioMapFile = File(appPictureAudioMapFilePathName);

      pictureAudioMap = jsonDecode(pictureAudioMapFile.readAsStringSync());
      expect(pictureAudioMap.length, 0);
      expect(pictureAudioMap.containsKey(testPictureOneFileName), false);
      expect(pictureAudioMap.containsKey(testPictureTwoFileName),
          false); // The second picture was removed

      // Ensure the removed picture files are still present in the
      // application picture directory and so were not deleted by
      // the remove operation.
      appPictureJpgFileLst = DirUtil.listFileNamesInDir(
        directoryPath: applicationPicturePath,
        fileExtension: 'jpg',
      );

      expect(appPictureJpgFileLst.length, 2);
      expect(appPictureJpgFileLst.contains(testPictureOneFileName), true);
      expect(appPictureJpgFileLst.contains(testPictureTwoFileName), true);

      // Verify that the removed picture jpg file was not deleted
      appPictureJpgFileLst = DirUtil.listFileNamesInDir(
        directoryPath: applicationPicturePath,
        fileExtension: 'jpg',
      );

      expect(appPictureJpgFileLst.length, 2);
      expect(appPictureJpgFileLst.contains(testPictureOneFileName), true);
      expect(appPictureJpgFileLst.contains(testPictureTwoFileName), true);
    });
    test(
        '''Remove all pictures of the second audio after adding picture to a first audio as
            well as to the second audio. Finally, verify that after removing the last audio
            picture of the second audio, the playlist picture dir was not deleted since the
            first audio has a picture.''', () {
      // Add a first picture to the playlist two first audio
      pictureVM.addPictureToAudio(
        audio: playlistTwoAudioOne,
        pictureFilePathName: testAvailablePictureOneFilePathName,
      );

      // Add a first picture to the playlist two second audio
      pictureVM.addPictureToAudio(
        audio: playlistTwoAudioTwo,
        pictureFilePathName: testAvailablePictureOneFilePathName,
      );

      // Add a new picture to the playlist two second audio
      pictureVM.addPictureToAudio(
        audio: playlistTwoAudioTwo,
        pictureFilePathName: testAvailablePictureTwoFilePathName,
      );

      // Now, remove the last added picture from the playlist two
      // second audio
      pictureVM.removeLastAddedAudioPicture(audio: playlistTwoAudioTwo);

      // Verify that the playlist two audio two JSON file contains
      // now one picture
      expect(pictureVM.getAudioPicturesNumber(audio: playlistTwoAudioTwo), 1);

      // Now, remove the remaining picture from the playlist two
      // second audio
      pictureVM.removeLastAddedAudioPicture(audio: playlistTwoAudioTwo);

      // Verify that the playlist two audio picture dir was not
      // deleted since the first audio has a picture
      expect(Directory(testPlaylistTwoPicturePath).existsSync(), true);
    });
    test(
        '''Remove pictures from several audio's. Before, pictures were added to those audio's
           located in two different playlists. Check the audio json picture content as well as
           the application picture-audio map content.''', () {
      final File pictureAudioMapFile = File(appPictureAudioMapFilePathName);

      // Add picture to the playlist one first audio
      pictureVM.addPictureToAudio(
        audio: playlistOneAudioOne,
        pictureFilePathName: testAvailablePictureOneFilePathName,
      );

      // Add same picture to the playlist one second audio
      pictureVM.addPictureToAudio(
        audio: playlistOneAudioTwo,
        pictureFilePathName: testAvailablePictureOneFilePathName,
      );

      // Add same picture to the playlist two first audio
      pictureVM.addPictureToAudio(
        audio: playlistTwoAudioOne,
        pictureFilePathName: testAvailablePictureOneFilePathName,
      );

      // Add same picture to the playlist two second audio
      pictureVM.addPictureToAudio(
        audio: playlistTwoAudioTwo,
        pictureFilePathName: testAvailablePictureOneFilePathName,
      );

      // Add new picture to the playlist two second audio
      pictureVM.addPictureToAudio(
        audio: playlistTwoAudioTwo,
        pictureFilePathName: testAvailablePictureTwoFilePathName,
      );

      // Verify that the playlist two audio two JSON file contains
      // two pictures
      expect(pictureVM.getAudioPicturesNumber(audio: playlistTwoAudioTwo), 2);

      // Verify playlist two first audio picture JSON file

      final List<Picture> playlistTwoAudioOnePictureLst =
          JsonDataService.loadListFromFile(
        jsonPathFileName: playlistTwoAudioOnePictureJsonFilePathName,
        type: Picture,
      );

      expect(playlistTwoAudioOnePictureLst.length, 1);

      Picture playlistTwoAudioOneFirstPicture =
          playlistTwoAudioOnePictureLst.first;
      expect(playlistTwoAudioOneFirstPicture.fileName, testPictureOneFileName);

      // Verify playlist two second audio picture JSON file

      final List<Picture> playlistTwoAudioTwoPictureLst =
          JsonDataService.loadListFromFile(
        jsonPathFileName: playlistTwoAudioTwoPictureJsonFilePathName,
        type: Picture,
      );

      expect(playlistTwoAudioTwoPictureLst.length, 2);

      Picture playlistTwoAudioTwoFirstPicture =
          playlistTwoAudioTwoPictureLst.first;
      expect(playlistTwoAudioTwoFirstPicture.fileName, testPictureOneFileName);

      Picture playlistTwoAudioTwoSecondPicture =
          playlistTwoAudioTwoPictureLst[1];
      expect(playlistTwoAudioTwoSecondPicture.fileName, testPictureTwoFileName);

      // Verify the application picture-audio map content

      expect(pictureAudioMapFile.existsSync(), true);

      Map<String, dynamic> pictureAudioMap =
          jsonDecode(pictureAudioMapFile.readAsStringSync());
      expect(pictureAudioMap.length, 2);
      expect(pictureAudioMap.containsKey(testPictureOneFileName), true);
      expect(pictureAudioMap.containsKey(testPictureTwoFileName), true);

      List pictureAudioMapLst =
          (pictureAudioMap[testPictureOneFileName] as List);
      expect(pictureAudioMapLst.length, 4);
      expect(
        pictureAudioMapLst[0],
        '$testPlaylistOneTitle|${playlistOneAudioOne.audioFileName.replaceAll('.mp3', '')}',
      );
      expect(
        pictureAudioMapLst[1],
        '$testPlaylistOneTitle|${playlistOneAudioTwo.audioFileName.replaceAll('.mp3', '')}',
      );
      expect(
        pictureAudioMapLst[2],
        '$testPlaylistTwoTitle|${playlistTwoAudioOne.audioFileName.replaceAll('.mp3', '')}',
      );
      expect(
        pictureAudioMapLst[3],
        '$testPlaylistTwoTitle|${playlistTwoAudioTwo.audioFileName.replaceAll('.mp3', '')}',
      );

      pictureAudioMapLst = (pictureAudioMap[testPictureTwoFileName] as List);
      expect(pictureAudioMapLst.length, 1);
      expect(
        pictureAudioMapLst[0],
        '$testPlaylistTwoTitle|${playlistTwoAudioTwo.audioFileName.replaceAll('.mp3', '')}',
      );

      // Ensure the added picture files are present in the application
      // picture directory

      List<String> appJpgFilesLst = DirUtil.listFileNamesInDir(
        directoryPath: applicationPicturePath,
        fileExtension: 'jpg',
      );

      expect(appJpgFilesLst.length, 2);
      expect(appJpgFilesLst.contains(testPictureOneFileName), true);
      expect(appJpgFilesLst.contains(testPictureTwoFileName), true);

      // Now, remove the last added picture from the playlist two
      // second audio
      pictureVM.removeLastAddedAudioPicture(audio: playlistTwoAudioTwo);

      // Verify the application picture-audio map content

      expect(pictureAudioMapFile.existsSync(), true);

      pictureAudioMap = jsonDecode(pictureAudioMapFile.readAsStringSync());
      expect(pictureAudioMap.length, 1);
      expect(pictureAudioMap.containsKey(testPictureOneFileName), true);
      expect(pictureAudioMap.containsKey(testPictureTwoFileName), false);

      pictureAudioMapLst = (pictureAudioMap[testPictureOneFileName] as List);
      expect(pictureAudioMapLst.length, 4);
      expect(
        pictureAudioMapLst[0],
        '$testPlaylistOneTitle|${playlistOneAudioOne.audioFileName.replaceAll('.mp3', '')}',
      );
      expect(
        pictureAudioMapLst[1],
        '$testPlaylistOneTitle|${playlistOneAudioTwo.audioFileName.replaceAll('.mp3', '')}',
      );
      expect(
        pictureAudioMapLst[2],
        '$testPlaylistTwoTitle|${playlistTwoAudioOne.audioFileName.replaceAll('.mp3', '')}',
      );
      expect(
        pictureAudioMapLst[3],
        '$testPlaylistTwoTitle|${playlistTwoAudioTwo.audioFileName.replaceAll('.mp3', '')}',
      );

      // Now, remove the remaining picture from the playlist two
      // second audio
      pictureVM.removeLastAddedAudioPicture(audio: playlistTwoAudioTwo);

      // Verify the application picture-audio map content

      expect(pictureAudioMapFile.existsSync(), true);

      pictureAudioMap = jsonDecode(pictureAudioMapFile.readAsStringSync());
      expect(pictureAudioMap.length, 1);
      expect(pictureAudioMap.containsKey(testPictureOneFileName), true);
      expect(pictureAudioMap.containsKey(testPictureTwoFileName), false);

      pictureAudioMapLst = (pictureAudioMap[testPictureOneFileName] as List);
      expect(pictureAudioMapLst.length, 3);
      expect(
        pictureAudioMapLst[0],
        '$testPlaylistOneTitle|${playlistOneAudioOne.audioFileName.replaceAll('.mp3', '')}',
      );
      expect(
        pictureAudioMapLst[1],
        '$testPlaylistOneTitle|${playlistOneAudioTwo.audioFileName.replaceAll('.mp3', '')}',
      );
      expect(
        pictureAudioMapLst[2],
        '$testPlaylistTwoTitle|${playlistTwoAudioOne.audioFileName.replaceAll('.mp3', '')}',
      );

      // Verify that the removed picture jpg file was not deleted
      List<String> appPictureJpgFileLst = DirUtil.listFileNamesInDir(
        directoryPath: applicationPicturePath,
        fileExtension: 'jpg',
      );

      expect(appPictureJpgFileLst.length, 2);
      expect(appPictureJpgFileLst.contains(testPictureOneFileName), true);
      expect(appPictureJpgFileLst.contains(testPictureTwoFileName), true);
    });
    test('removeAudioPicture - deletes file when removing last picture',
        () async {
      // Arrange
      final pictureJsonPath =
          '$testPlaylistOnePicturePath${path.separator}${playlistOneAudioOneFileName.replaceAll('.mp3', '.json')}';
      _createTestPictureJsonFile(
        jsonPath: pictureJsonPath,
        pictures: [Picture(fileName: testPictureOneFileName)],
      );

      // Create picture-audio map
      Map<String, List<String>> createdPictureAudioMap = {
        testPictureOneFileName: [
          "$testPlaylistOneTitle|250412-125202-Chapitre 0 préface de l'auteur Chemin Saint Josémaria 25-02-09",
        ]
      };
      await _createTestAppPictureAudioMapFile(
        applicationPicturePath: applicationPicturePath,
        pictureAudioMap: createdPictureAudioMap,
      );

      File file = File(pictureJsonPath);
      expect(file.existsSync(), true);

      // Verify application picture-audio map
      File pictureAudioMapFile = File(appPictureAudioMapFilePathName);
      Map<String, dynamic> pictureAudioMap =
          jsonDecode(pictureAudioMapFile.readAsStringSync());
      expect(pictureAudioMap.containsKey(testPictureOneFileName), true);

      // Act
      pictureVM.removeLastAddedAudioPicture(audio: playlistOneAudioOne);

      // Verify that the playlist one audio picture dir was deleted
      expect(Directory(testPlaylistOnePicturePath).existsSync(), false);

      // Verify application picture-audio map
      pictureAudioMapFile = File(appPictureAudioMapFilePathName);
      pictureAudioMap = jsonDecode(pictureAudioMapFile.readAsStringSync());
      expect(pictureAudioMap.containsKey(testPictureOneFileName), false);
    });
  });
  group('getPlaylistAudioPicturedFileNamesNoExtLst', () {
    test('Returns correct list', () {
      // Arrange
      final String picture1JsonPath =
          '$testPlaylistOnePicturePath${path.separator}audio1.json';
      final String picture2JsonPath =
          '$testPlaylistOnePicturePath${path.separator}audio2.json';

      // Create picture JSON files
      _createTestPictureJsonFile(
        jsonPath: picture1JsonPath,
        pictures: [Picture(fileName: 'pic1.jpg')],
      );
      _createTestPictureJsonFile(
        jsonPath: picture2JsonPath,
        pictures: [Picture(fileName: 'pic2.jpg')],
      );

      // Act
      final List<String> result =
          pictureVM.getPlaylistAudioPicturedFileNamesNoExtLst(
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

    test('Returns empty list when directory does not exist', () {
      // Arrange - Delete the picture directory
      if (Directory(testPlaylistOnePicturePath).existsSync()) {
        Directory(testPlaylistOnePicturePath).deleteSync(recursive: true);
      }

      // Act
      final List<String> result =
          pictureVM.getPlaylistAudioPicturedFileNamesNoExtLst(
        playlist: playlistOne,
      );

      // Assert
      expect(result.length, 0);

      // Recreate directory for other tests
      Directory(testPlaylistOnePicturePath).createSync(recursive: true);
    });
    test(
        '''When directory exists returns empty list if the directory contains no JSON
           files.''', () {
      // Arrange - Delete the picture directory
      if (Directory(testPlaylistOnePicturePath).existsSync()) {
        Directory(testPlaylistOnePicturePath).deleteSync(recursive: true);
      }

      // Create the picture directory
      Directory(testPlaylistOnePicturePath).createSync(recursive: true);

      // Act
      final result = pictureVM.getPlaylistAudioPicturedFileNamesNoExtLst(
        playlist: playlistOne,
      );

      // Assert
      expect(result.length, 0);

      // Recreate directory for other tests
      Directory(testPlaylistOnePicturePath).createSync(recursive: true);
    });
    test('''After adding to one audio then removing pictures ...''', () {
      // Add a first picture to the playlist two second audio
      pictureVM.addPictureToAudio(
        audio: playlistTwoAudioTwo,
        pictureFilePathName: testAvailablePictureOneFilePathName,
      );

      List<String> audioPictureFileNamesNoExtLst =
          pictureVM.getPlaylistAudioPicturedFileNamesNoExtLst(
        playlist: playlistTwoAudioTwo.enclosingPlaylist!,
      );

      // Assert
      expect(audioPictureFileNamesNoExtLst.length, 1);
      expect(
          audioPictureFileNamesNoExtLst.contains(
              playlistTwoAudioTwo.audioFileName.replaceAll('.mp3', '')),
          true);

      // Add a new picture to the playlist two second audio
      pictureVM.addPictureToAudio(
        audio: playlistTwoAudioTwo,
        pictureFilePathName: testAvailablePictureTwoFilePathName,
      );

      audioPictureFileNamesNoExtLst =
          pictureVM.getPlaylistAudioPicturedFileNamesNoExtLst(
        playlist: playlistTwoAudioTwo.enclosingPlaylist!,
      );

      // Assert
      expect(audioPictureFileNamesNoExtLst.length, 1);
      expect(
          audioPictureFileNamesNoExtLst.contains(
              playlistTwoAudioTwo.audioFileName.replaceAll('.mp3', '')),
          true);

      // Now, remove the last added picture from the playlist two
      // second audio
      pictureVM.removeLastAddedAudioPicture(audio: playlistTwoAudioTwo);

      audioPictureFileNamesNoExtLst =
          pictureVM.getPlaylistAudioPicturedFileNamesNoExtLst(
        playlist: playlistTwoAudioTwo.enclosingPlaylist!,
      );

      // Assert
      expect(audioPictureFileNamesNoExtLst.length, 1);
      expect(
          audioPictureFileNamesNoExtLst.contains(
              playlistTwoAudioTwo.audioFileName.replaceAll('.mp3', '')),
          true);

      // Now, remove the remaining picture from the playlist two
      // second audio
      pictureVM.removeLastAddedAudioPicture(audio: playlistTwoAudioTwo);

      audioPictureFileNamesNoExtLst =
          pictureVM.getPlaylistAudioPicturedFileNamesNoExtLst(
        playlist: playlistTwoAudioTwo.enclosingPlaylist!,
      );

      // Assert
      expect(audioPictureFileNamesNoExtLst.length, 0);
    });
    test(
        '''After adding to two audio's in same playlist then removing pictures ...''',
        () {
      // Add a first picture to the playlist two second audio
      pictureVM.addPictureToAudio(
        audio: playlistTwoAudioOne,
        pictureFilePathName: testAvailablePictureOneFilePathName,
      );

      List<String> audioPictureFileNamesNoExtLst =
          pictureVM.getPlaylistAudioPicturedFileNamesNoExtLst(
        playlist: playlistTwoAudioOne.enclosingPlaylist!,
      );

      // Assert
      expect(audioPictureFileNamesNoExtLst.length, 1);
      expect(
        audioPictureFileNamesNoExtLst
            .contains(playlistTwoAudioOne.audioFileName.replaceAll('.mp3', '')),
        true,
      );

      // Add a new picture to the playlist two second audio
      pictureVM.addPictureToAudio(
        audio: playlistTwoAudioTwo,
        pictureFilePathName: testAvailablePictureTwoFilePathName,
      );

      audioPictureFileNamesNoExtLst =
          pictureVM.getPlaylistAudioPicturedFileNamesNoExtLst(
        playlist: playlistTwoAudioTwo.enclosingPlaylist!,
      );

      // Assert
      expect(audioPictureFileNamesNoExtLst.length, 2);
      expect(
        audioPictureFileNamesNoExtLst
            .contains(playlistTwoAudioOne.audioFileName.replaceAll('.mp3', '')),
        true,
      );
      expect(
        audioPictureFileNamesNoExtLst
            .contains(playlistTwoAudioTwo.audioFileName.replaceAll('.mp3', '')),
        true,
      );

      // Now, remove the added picture from the playlist two second
      // audio
      pictureVM.removeLastAddedAudioPicture(audio: playlistTwoAudioTwo);

      audioPictureFileNamesNoExtLst =
          pictureVM.getPlaylistAudioPicturedFileNamesNoExtLst(
        playlist: playlistTwoAudioTwo.enclosingPlaylist!,
      );

      // Assert
      expect(audioPictureFileNamesNoExtLst.length, 1);
      expect(
        audioPictureFileNamesNoExtLst
            .contains(playlistTwoAudioOne.audioFileName.replaceAll('.mp3', '')),
        true,
      );

      // Now, remove the picture from the playlist two first audio
      pictureVM.removeLastAddedAudioPicture(audio: playlistTwoAudioOne);

      audioPictureFileNamesNoExtLst =
          pictureVM.getPlaylistAudioPicturedFileNamesNoExtLst(
        playlist: playlistTwoAudioTwo.enclosingPlaylist!,
      );

      // Assert
      expect(audioPictureFileNamesNoExtLst.length, 0);
    });
  });
  group('''getLastAddedAudioPictureFile''', () {
    test('Returns file when picture exists', () async {
      // Arrange
      final pictureJsonPath =
          '$testPlaylistOnePicturePath${path.separator}${playlistOneAudioOneFileName.replaceAll('.mp3', '.json')}';
      _createTestPictureJsonFile(
        jsonPath: pictureJsonPath,
        pictures: [Picture(fileName: testPictureOneFileName)],
      );

      await DirUtil.createDirIfNotExist(pathStr: applicationPicturePath);

      // Create the actual picture file in the application picture path
      File("$applicationPicturePath${path.separator}Seigneur.jpg")
          .writeAsBytesSync(
        [0, 1, 2, 3],
        flush: true,
      ); // Simple dummy content

      // Act
      final File? result =
          pictureVM.getLastAddedAudioPictureFile(audio: playlistOneAudioOne);

      // Assert
      expect(result, isNotNull);
      expect(result!.path, testPictureOneFilePathName);

      // Clean up the additional file
      if (File(playlistOneAudioOnePictureJsonFilePathName).existsSync()) {
        File(playlistOneAudioOnePictureJsonFilePathName).deleteSync();
      }
    });
    test('Returns null when no pictures', () {
      // Act
      final File? result =
          pictureVM.getLastAddedAudioPictureFile(audio: playlistOneAudioOne);

      // Assert
      expect(result, isNull);
    });

    test('Returns null when file does not exist', () {
      // Arrange
      final String pictureJsonPath =
          '$testPlaylistOnePicturePath${path.separator}${playlistOneAudioOneFileName.replaceAll('.mp3', '.json')}';
      _createTestPictureJsonFile(
        jsonPath: pictureJsonPath,
        pictures: [Picture(fileName: 'nonexistent.jpg')],
      );

      // Act
      final File? result =
          pictureVM.getLastAddedAudioPictureFile(audio: playlistOneAudioOne);

      // Assert
      expect(result, isNull);
    });
  });

  group('Move picture tests', () {
    test(
        'moveAudioPictureJsonFileToTargetPlaylist - moves file and updates associations',
        () async {
      // Arrange
      final String sourcePictureJsonPath =
          '$testPlaylistOnePicturePath${path.separator}${playlistOneAudioOneFileName.replaceAll('.mp3', '.json')}';
      _createTestPictureJsonFile(
        jsonPath: sourcePictureJsonPath,
        pictures: [Picture(fileName: testPictureOneFileName)],
      );

      // Create target directory
      // Directory(testPlaylistTwoPicturePath).createSync(recursive: true);

      // Create picture-audio map
      Map<String, List<String>> createdPictureAudioMap = {
        testPictureOneFileName: [
          '$testPlaylistOneTitle|${playlistOneAudioOneFileName.replaceAll('.mp3', '')}'
        ]
      };
      await _createTestAppPictureAudioMapFile(
        applicationPicturePath: applicationPicturePath,
        pictureAudioMap: createdPictureAudioMap,
      );

      // Act
      pictureVM.moveAudioPictureJsonFileToTargetPlaylist(
        audio: playlistOneAudioOne,
        targetPlaylist: playlistTwo,
      );

      // Assert
      final sourceFile = File(sourcePictureJsonPath);
      expect(sourceFile.existsSync(), false);

      final targetFile = File(
          '$testPlaylistTwoPicturePath${path.separator}${playlistOneAudioOneFileName.replaceAll('.mp3', '.json')}');
      expect(targetFile.existsSync(), true);

      // Verify application picture-audio map
      final File pictureAudioMapFile = File(appPictureAudioMapFilePathName);
      final Map<String, dynamic> pictureAudioMap =
          jsonDecode(pictureAudioMapFile.readAsStringSync());

      // Check that the old association has been removed
      bool hasOldAssociation = false;
      if (pictureAudioMap.containsKey(testPictureOneFileName)) {
        hasOldAssociation = (pictureAudioMap[testPictureOneFileName] as List)
            .contains(
                '$testPlaylistOneTitle|${playlistOneAudioOneFileName.replaceAll('.mp3', '')}');
      }
      expect(hasOldAssociation, false);

      // Check that the new association has been added
      expect(
          (pictureAudioMap[testPictureOneFileName] as List).contains(
              '$testPlaylistTwoTitle|${playlistOneAudioOneFileName.replaceAll('.mp3', '')}'),
          true);

      // Clean up
      if (Directory(testPlaylistTwoPicturePath).existsSync()) {
        Directory(testPlaylistTwoPicturePath).deleteSync(recursive: true);
      }
    });
    test('move empty picture for audio - move empty picture list not happens.',
        () async {
      // Arrange
      final String sourcePictureJsonPath =
          '$testPlaylistOnePicturePath${path.separator}${playlistOneAudioOneFileName.replaceAll('.mp3', '.json')}';

      // Create picture JSON file for an empty picture list. Result: no
      // json file created.
      _createTestPictureJsonFile(
        jsonPath: sourcePictureJsonPath,
        pictures: [],
      );

      // Act
      pictureVM.moveAudioPictureJsonFileToTargetPlaylist(
        audio: playlistOneAudioOne,
        targetPlaylist: playlistTwo,
      );

      // Assert
      final sourceFile = File(sourcePictureJsonPath);
      expect(sourceFile.existsSync(), false);

      final targetFile = File(
          '$testPlaylistTwoPicturePath${path.separator}${playlistOneAudioOneFileName.replaceAll('.mp3', '.json')}');
      expect(targetFile.existsSync(), false);

      // Verify application picture-audio map
      final File pictureAudioMapFile = File(appPictureAudioMapFilePathName);

      expect(pictureAudioMapFile.existsSync(), false);

      // Clean up
      if (Directory(testPlaylistTwoPicturePath).existsSync()) {
        Directory(testPlaylistTwoPicturePath).deleteSync(recursive: true);
      }
    });
  });
  group('Copy picture tests', () {
    test(
        'copyAudioPictureJsonFileToTargetPlaylist - copies file and adds associations',
        () async {
      // Arrange
      final String playlistOneAudioOnePictureJsonFileName =
          playlistOneAudioOneFileName.replaceAll('.mp3', '.json');
      final String playlistOneAudioOneTitle =
          playlistOneAudioOneFileName.replaceAll('.mp3', '');
      final String sourcePictureJsonPath =
          '$testPlaylistOnePicturePath${path.separator}$playlistOneAudioOnePictureJsonFileName';
      _createTestPictureJsonFile(
        jsonPath: sourcePictureJsonPath,
        pictures: [Picture(fileName: testPictureOneFileName)],
      );

      // Create picture-audio map
      Map<String, List<String>> createdPictureAudioMap = {
        testPictureOneFileName: [
          '$testPlaylistOneTitle|$playlistOneAudioOneTitle'
        ]
      };
      await _createTestAppPictureAudioMapFile(
        applicationPicturePath: applicationPicturePath,
        pictureAudioMap: createdPictureAudioMap,
      );

      // Act
      pictureVM.copyAudioPictureJsonFileToTargetPlaylist(
        audio: playlistOneAudioOne,
        targetPlaylist: playlistTwo,
      );

      // Assert
      final File sourceFile = File(sourcePictureJsonPath);
      expect(sourceFile.existsSync(), true);

      final File targetFile = File(
          '$testPlaylistTwoPicturePath${path.separator}$playlistOneAudioOnePictureJsonFileName');
      expect(targetFile.existsSync(), true);

      // Verify application picture-audio map
      final File pictureAudioMapFile = File(appPictureAudioMapFilePathName);
      final Map<String, dynamic> pictureAudioMap =
          jsonDecode(pictureAudioMapFile.readAsStringSync());

      // Check that the original association is preserved
      expect(
          (pictureAudioMap[testPictureOneFileName] as List)
              .contains('$testPlaylistOneTitle|$playlistOneAudioOneTitle'),
          true);

      // Check that the new association has been added
      expect(
          (pictureAudioMap[testPictureOneFileName] as List)
              .contains('$testPlaylistTwoTitle|$playlistOneAudioOneTitle'),
          true);

      // Clean up
      if (Directory(testPlaylistTwoPicturePath).existsSync()) {
        Directory(testPlaylistTwoPicturePath).deleteSync(recursive: true);
      }
    });
    test('copy empty picture for audio - copy empty picture list not happens.',
        () async {
      // Arrange
      final String sourcePictureJsonPath =
          '$testPlaylistOnePicturePath${path.separator}${playlistOneAudioOneFileName.replaceAll('.mp3', '.json')}';

      // Create picture JSON file for an empty picture list. Result: no
      // json file created.
      _createTestPictureJsonFile(
        jsonPath: sourcePictureJsonPath,
        pictures: [],
      );

      // Act
      pictureVM.copyAudioPictureJsonFileToTargetPlaylist(
        audio: playlistOneAudioOne,
        targetPlaylist: playlistTwo,
      );

      // Assert
      final sourceFile = File(sourcePictureJsonPath);
      expect(sourceFile.existsSync(), false);

      final targetFile = File(
          '$testPlaylistTwoPicturePath${path.separator}${playlistOneAudioOneFileName.replaceAll('.mp3', '.json')}');
      expect(targetFile.existsSync(), false);

      // Verify application picture-audio map
      final File pictureAudioMapFile = File(appPictureAudioMapFilePathName);

      expect(pictureAudioMapFile.existsSync(), false);

      // Clean up
      if (Directory(testPlaylistTwoPicturePath).existsSync()) {
        Directory(testPlaylistTwoPicturePath).deleteSync(recursive: true);
      }
    });
  });
  group('Delete picture tests', () {
    test('deleteAudioPictureJsonFileIfExist - deletes picture and associations',
        () async {
      // Arrange
      final pictureJsonPath =
          '$testPlaylistOnePicturePath${path.separator}${playlistOneAudioOneFileName.replaceAll('.mp3', '.json')}';

      _createTestPictureJsonFile(
        jsonPath: pictureJsonPath,
        pictures: [Picture(fileName: testPictureOneFileName)],
      );

      // Create picture-audio map
      final String playlistOneAudioOneAssociation =
          '$testPlaylistOneTitle|${playlistOneAudioOneFileName.replaceAll('.mp3', '')}';
      Map<String, List<String>> createdPictureAudioMap = {
        testPictureOneFileName: [playlistOneAudioOneAssociation]
      };
      await _createTestAppPictureAudioMapFile(
        applicationPicturePath: applicationPicturePath,
        pictureAudioMap: createdPictureAudioMap,
      );

      // Verify application picture-audio map before the audio
      // picture deletion
      File pictureAudioMapFile = File(appPictureAudioMapFilePathName);
      Map<String, dynamic> pictureAudioMap =
          jsonDecode(pictureAudioMapFile.readAsStringSync());
      expect(pictureAudioMap.length, 1);
      expect(pictureAudioMap.containsKey(testPictureOneFileName), true);
      expect(
        pictureAudioMap[testPictureOneFileName],
        [playlistOneAudioOneAssociation],
      );

      // Act
      pictureVM.deleteAudioPictureJsonFileIfExist(
        audio: playlistOneAudioOne,
      );

      // Verify that the audio picture JSON file was deleted
      final file = File(pictureJsonPath);
      expect(file.existsSync(), false);

      // Verify application picture-audio map after the audio
      // picture deletion
      pictureAudioMapFile = File(appPictureAudioMapFilePathName);
      pictureAudioMap = jsonDecode(pictureAudioMapFile.readAsStringSync());
      expect(pictureAudioMap.containsKey(testPictureOneFileName), false);
      expect(pictureAudioMap.length, 0);
    });
  });
  // Helper method to create a test picture JSON file
  group('Restore picture JPG tests', () {
    test('''restorePictureJpgFilesFromSourceDirectory - restore picture JPG files from source directory to
        app pictures directory''', () async {
      pictureVM.restorePictureJpgFilesFromSourceDirectory(
        sourceDirectoryPath: availableTestPicturePath,
      );

      // Verify that the audio picture JPG files was restored
      File file = File(testAvailablePictureOneFilePathName);
      expect(file.existsSync(), true);

      file = File(testAvailablePictureTwoFilePathName);
      expect(file.existsSync(), true);
    });
  });
}

void _createTestPictureJsonFile({
  required String jsonPath,
  required List<Picture> pictures,
}) {
  if (pictures.isEmpty) {
    return;
  }

  final Directory dir = Directory(path.dirname(jsonPath));

  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final File file = File(jsonPath);
  final String jsonContent =
      jsonEncode(pictures.map((p) => p.toJson()).toList());
  file.writeAsStringSync(jsonContent);
}

// Helper method to create a test pictureAudio.json file
Future<void> _createTestAppPictureAudioMapFile({
  required String applicationPicturePath,
  required Map<String, List<String>> pictureAudioMap,
}) async {
  await DirUtil.createDirIfNotExist(
    pathStr: applicationPicturePath,
  );

  String appPictureAudioMapFilePathName =
      '$applicationPicturePath${path.separator}pictureAudioMap.json';

  final file = File(appPictureAudioMapFilePathName);
  final jsonContent = jsonEncode(pictureAudioMap);
  file.writeAsStringSync(jsonContent);
}

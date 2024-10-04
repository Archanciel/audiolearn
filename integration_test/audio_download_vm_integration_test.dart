import 'dart:io';
import 'package:audiolearn/services/json_data_service.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/utils/date_time_parser.dart';
import 'package:audiolearn/views/screen_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/warning_message_vm.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int secondsDelay = 15; // 7 works, but 10 is safer and 15 solves
//                              the problems of running the integr tests
const String existingAudioDateOnlyFileNamePrefix = '230610';
final String todayDownloadDateOnlyFileNamePrefix =
    Audio.downloadDatePrefixFormatter.format(DateTime.now());
const String globalTestPlaylistId = 'PLzwWSJNcZTMRB9ILve6fEIS_OHGrV5R2o';
const String globalTestPlaylistUrl =
    'https://youtube.com/playlist?list=PLzwWSJNcZTMRB9ILve6fEIS_OHGrV5R2o';
const String globalTestPlaylistTitle =
    'audio_learn_test_download_2_small_videos';
final String globalTestPlaylistDir =
    '$kPlaylistDownloadRootPathWindowsTest${path.separator}$globalTestPlaylistTitle';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Download 1 playlist with short audio', () {
    test('Check initial values', () async {
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      final WarningMessageVM warningMessageVM = WarningMessageVM();

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: "temp\\wrong.json");

      final AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      expect(audioDownloadVM.listOfPlaylist, []);

      // this check fails if the secondsDelay value is too small
      expect(audioDownloadVM.isDownloading, false);

      expect(audioDownloadVM.downloadProgress, 0.0);
      expect(audioDownloadVM.lastSecondDownloadSpeed, 0);
      expect(audioDownloadVM.isHighQuality, false);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });

    testWidgets('Playlist 2 short audio: playlist dir not exist',
        (WidgetTester tester) async {
      late AudioDownloadVM audioDownloadVM;
      final Directory directory = Directory(globalTestPlaylistDir);

      // necessary in case the previous test failed and so did not
      // delete the its playlist dir
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: "temp\\wrong.json");

      // Building and displaying the DownloadPlaylistPage integration test
      // application.
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (BuildContext context) {
          final WarningMessageVM warningMessageVM = WarningMessageVM();
          audioDownloadVM = AudioDownloadVM(
            warningMessageVM: warningMessageVM,
            settingsDataService: settingsDataService,
            isTest: true,
          );
          return audioDownloadVM;
        },
        child: MaterialApp(
          // forcing dark theme
          theme: ScreenMixin.themeDataDark,
          home: const DownloadPlaylistPage(
            // integration test opened application
            playlistUrl: globalTestPlaylistUrl,
          ),
        ),
      ));

      // tapping on the downl playlist button in the app which calls the
      // AudioDownloadVM.downloadPlaylistAudios(playlistUrl) method
      await tester.tap(find.byKey(const Key('downloadPlaylistAudiosButton')));
      await tester.pumpAndSettle();

      // Add a delay to allow the download to finish. 5 seconds is ok
      // when running the audio_download_vm_test only.
      // Waiting 5 seconds only causes MissingPluginException
      // 'No implementation found for method $method on channel $name'
      // when all tsts are run. 7 seconds solve the problem.
      await Future.delayed(const Duration(seconds: secondsDelay));
      await tester.pumpAndSettle();

      expect(directory.existsSync(), true);

      Playlist downloadedPlaylist = audioDownloadVM.listOfPlaylist[0];

      checkDownloadedPlaylist(
        downloadedPlaylist: downloadedPlaylist,
        playlistId: globalTestPlaylistId,
        playlistTitle: globalTestPlaylistTitle,
        playlistUrl: globalTestPlaylistUrl,
        playlistDir: globalTestPlaylistDir,
      );

      // this check fails if the secondsDelay value is too small
      expect(audioDownloadVM.isDownloading, false);

      expect(audioDownloadVM.downloadProgress, 1.0);
      expect(audioDownloadVM.lastSecondDownloadSpeed, 0);
      expect(audioDownloadVM.isHighQuality, false);

      // Checking the data of the audio contained in the downloaded
      // audio list which contains 2 downloaded Audio's
      checkPlaylistDownloadedAudios(
        downloadedAudioOne: downloadedPlaylist.downloadedAudioLst[0],
        downloadedAudioTwo: downloadedPlaylist.downloadedAudioLst[1],
        audioOneFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
        audioTwoFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
        downloadedFileSizeOne: 378444,
        downloadedFileSizeTwo: 160000,
        audioDurationMillisecondsOne: 23336,
        audioDurationMillisecondsTwo: 9845,
      );

      // Checking the data of the audio contained in the playable
      // audio list;
      //
      // playableAudioLst contains Audio's inserted at list start
      checkPlaylistDownloadedAudios(
        downloadedAudioOne: downloadedPlaylist.playableAudioLst[1],
        downloadedAudioTwo: downloadedPlaylist.playableAudioLst[0],
        audioOneFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
        audioTwoFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
        downloadedFileSizeOne: 378444,
        downloadedFileSizeTwo: 160000,
        audioDurationMillisecondsOne: 23336,
        audioDurationMillisecondsTwo: 9845,
      );

      // Checking if there are 3 files in the directory (2 mp3 and 1 json)
      final List<FileSystemEntity> files =
          directory.listSync(recursive: false, followLinks: false);

      expect(files.length, 3);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Playlist 2 short audio: playlist 2nd audio was already downloaded and 
           was deleted''', (WidgetTester tester) async {
      late AudioDownloadVM audioDownloadVM;
      final Directory directory = Directory(globalTestPlaylistDir);

      // necessary in case the previous test failed and so did not
      // delete the its playlist dir
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      await DirUtil.createDirIfNotExist(pathStr: globalTestPlaylistDir);

      // Copying to the playlist dir the playlist json file which contains
      // one audio which was already downloaded and was deleted. The video
      // title of the already downloaded audio is 'audio learn test short
      // video two'.
      await DirUtil.copyFileToDirectory(
        sourceFilePathName:
            "$kDownloadAppTestSavedDataDir${path.separator}$globalTestPlaylistTitle${path.separator}${globalTestPlaylistTitle}_1_audio.json",
        targetDirectoryPath: globalTestPlaylistDir,
        targetFileName: '$globalTestPlaylistTitle.json',
      );

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: "temp\\wrong.json");

      final WarningMessageVM warningMessageVM = WarningMessageVM();
      final AudioDownloadVM audioDownloadVMbeforeDownload = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );
      Playlist existingPlaylistBeforeNewDownload =
          audioDownloadVMbeforeDownload.listOfPlaylist[0];

      // Verifying the data of the copied playlist before downloading
      // the playlist

      checkDownloadedPlaylist(
        downloadedPlaylist: existingPlaylistBeforeNewDownload,
        playlistId: globalTestPlaylistId,
        playlistTitle: globalTestPlaylistTitle,
        playlistUrl: globalTestPlaylistUrl,
        playlistDir: globalTestPlaylistDir,
      );

      List<Audio> downloadedAudioLstBeforeDownload =
          existingPlaylistBeforeNewDownload.downloadedAudioLst;
      List<Audio> playableAudioLstBeforeDownload =
          existingPlaylistBeforeNewDownload.playableAudioLst;

      expect(downloadedAudioLstBeforeDownload.length, 1);
      expect(playableAudioLstBeforeDownload.length, 1);

      // Checking the data of the audio contained in the downloaded
      // audio list
      checkDownloadedAudioShortVideoTwo(
        downloadedAudioTwo: downloadedAudioLstBeforeDownload[0],
        audioTwoFileNamePrefix: existingAudioDateOnlyFileNamePrefix,
        downloadedFileSize: 61425,
        audioDurationMilliseconds: 10000,
      );

      // Checking the data of the audio contained in the playable
      // audio list
      checkDownloadedAudioShortVideoTwo(
        downloadedAudioTwo: playableAudioLstBeforeDownload[0],
        audioTwoFileNamePrefix: existingAudioDateOnlyFileNamePrefix,
        downloadedFileSize: 61425,
        audioDurationMilliseconds: 10000,
      );

      // Building and displaying the DownloadPlaylistPage integration test
      // application.
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (BuildContext context) {
          final WarningMessageVM warningMessageVM = WarningMessageVM();
          audioDownloadVM = AudioDownloadVM(
            warningMessageVM: warningMessageVM,
            settingsDataService: settingsDataService,
            isTest: true,
          );
          return audioDownloadVM;
        },
        child: MaterialApp(
          // forcing dark theme
          theme: ScreenMixin.themeDataDark,
          home: const DownloadPlaylistPage(
            // integration test opened application
            playlistUrl: globalTestPlaylistUrl,
          ),
        ),
      ));

      // tapping on the downl playlist button in the app which calls the
      // AudioDownloadVM.downloadPlaylistAudios(playlistUrl) method
      await tester.tap(find.byKey(const Key('downloadPlaylistAudiosButton')));
      await tester.pumpAndSettle();

      // Add a delay to allow the download to finish. 5 seconds is ok
      // when running the audio_download_vm_test only.
      // Waiting 5 seconds only causes MissingPluginException
      // 'No implementation found for method $method on channel $name'
      // when all tsts are run. 7 seconds solve the problem.
      await Future.delayed(const Duration(seconds: secondsDelay));
      await tester.pumpAndSettle();

      expect(directory.existsSync(), true);

      // Verifying the data of the playlist after downloading it

      Playlist downloadedPlaylist = audioDownloadVM.listOfPlaylist[0];

      checkDownloadedPlaylist(
        downloadedPlaylist: downloadedPlaylist,
        playlistId: globalTestPlaylistId,
        playlistTitle: globalTestPlaylistTitle,
        playlistUrl: globalTestPlaylistUrl,
        playlistDir: globalTestPlaylistDir,
      );

      // this check fails if the secondsDelay value is too small
      expect(audioDownloadVM.isDownloading, false);

      expect(audioDownloadVM.downloadProgress, 1.0);
      expect(audioDownloadVM.lastSecondDownloadSpeed, 0);
      expect(audioDownloadVM.isHighQuality, false);

      // downloadedAudioLst contains added Audio's
      checkPlaylistDownloadedAudios(
        downloadedAudioOne: downloadedPlaylist.downloadedAudioLst[1],
        downloadedAudioTwo: downloadedPlaylist.downloadedAudioLst[0],
        audioOneFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
        audioTwoFileNamePrefix: existingAudioDateOnlyFileNamePrefix,
        downloadedFileSizeOne: 378444,
        downloadedFileSizeTwo: 61425,
        audioDurationMillisecondsOne: 23336,
        audioDurationMillisecondsTwo: 10000,
      );

      // playableAudioLst contains Audio's inserted at list start
      checkPlaylistDownloadedAudios(
        downloadedAudioOne: downloadedPlaylist.playableAudioLst[0],
        downloadedAudioTwo: downloadedPlaylist.playableAudioLst[1],
        audioOneFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
        audioTwoFileNamePrefix: existingAudioDateOnlyFileNamePrefix,
        downloadedFileSizeOne: 378444,
        downloadedFileSizeTwo: 61425,
        audioDurationMillisecondsOne: 23336,
        audioDurationMillisecondsTwo: 10000,
      );

      // Checking if there are 3 files in the directory (1 mp3 and 1 json)
      final List<FileSystemEntity> files =
          directory.listSync(recursive: false, followLinks: false);

      expect(files.length, 2);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('Download short audio of 1 single video', () {
    testWidgets('Local playlist containing no audio',
        (WidgetTester tester) async {
      late AudioDownloadVM audioDownloadVM;
      String localTestPlaylistTitle =
          'audio_learn_download_single_video_to_empty_local_playlist_test';
      String localTestPlaylistDir =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$localTestPlaylistTitle";
      String savedTestPlaylistDir =
          "$kDownloadAppTestSavedDataDir${path.separator}$localTestPlaylistTitle";

      final Directory directory = Directory(localTestPlaylistDir);

      // necessary in case the previous test failed and so did not
      // delete the its playlist dir
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      await DirUtil.createDirIfNotExist(pathStr: localTestPlaylistDir);

      // Copying the initial local playlist json file with no audio
      await DirUtil.copyFileToDirectory(
        sourceFilePathName:
            "$savedTestPlaylistDir${path.separator}$localTestPlaylistTitle.json",
        targetDirectoryPath: localTestPlaylistDir,
      );

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: "temp\\wrong.json");

      // Building and displaying the DownloadPlaylistPage integration test
      // application.
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (BuildContext context) {
          final WarningMessageVM warningMessageVM = WarningMessageVM();
          audioDownloadVM = AudioDownloadVM(
            warningMessageVM: warningMessageVM,
            settingsDataService: settingsDataService,
            isTest: true,
          );
          return audioDownloadVM;
        },
        child: MaterialApp(
          // forcing dark theme
          theme: ScreenMixin.themeDataDark,
          home: const DownloadPlaylistPage(
            // integration test opened application
            playlistUrl: globalTestPlaylistUrl,
          ),
        ),
      ));

      String singleVideoUrl = 'https://youtu.be/uv3VQoWSjBE';

      // Entering the single video URL in the playlist URL text field of the
      // app
      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        singleVideoUrl,
      );
      await tester.pumpAndSettle();

      // tapping on the downl single video button in the app which
      // calls the AudioDownloadVM.downloadPlaylistAudios() method
      await tester.tap(find.byKey(const Key('downloadSingleVideoAudioButton')));
      await tester.pumpAndSettle();

      // Add a delay to allow the download to finish. 5 seconds is ok
      // when running the audio_download_vm_test only.
      // Waiting 5 seconds only causes MissingPluginException
      // 'No implementation found for method $method on channel $name'
      // when all tsts are run. 7 seconds solve the problem.
      await Future.delayed(const Duration(seconds: secondsDelay));
      await tester.pumpAndSettle();

      Playlist singleVideoDownloadedPlaylist =
          audioDownloadVM.listOfPlaylist[0];

      checkDownloadedPlaylist(
        downloadedPlaylist: singleVideoDownloadedPlaylist,
        playlistId: localTestPlaylistTitle,
        playlistTitle: localTestPlaylistTitle,
        playlistUrl: '',
        playlistDir: localTestPlaylistDir,
      );

      // this check fails if the secondsDelay value is too small
      expect(audioDownloadVM.isDownloading, false);

      expect(audioDownloadVM.downloadProgress, 1.0);
      expect(audioDownloadVM.lastSecondDownloadSpeed, 0);
      expect(audioDownloadVM.isHighQuality, false);

      // Checking the data of the audio contained in the downloaded
      // audio list
      checkDownloadedAudioShortVideoTwo(
        downloadedAudioTwo: singleVideoDownloadedPlaylist.downloadedAudioLst[0],
        audioTwoFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
        downloadedFileSize: 160000,
        audioDurationMilliseconds: 9845,
      );

      // Checking if there are 2 files in the directory (1 mp3 and 1 json)
      final List<FileSystemEntity> files =
          directory.listSync(recursive: false, followLinks: false);

      expect(files.length, 2);

      // Checking if the playlist json file has been updated with the
      // downloaded audio data

      String playlistPathFileName =
          '$localTestPlaylistDir${path.separator}$localTestPlaylistTitle.json';

      Playlist loadedPlaylist = JsonDataService.loadFromFile(
          jsonPathFileName: playlistPathFileName, type: Playlist);

      compareDeserializedWithOriginalPlaylist(
        deserializedPlaylist: loadedPlaylist,
        originalPlaylist: singleVideoDownloadedPlaylist,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Download single video in audio (speak) quality to a target local
                   playlist containing no audio''',
        (WidgetTester tester) async {
      late AudioDownloadVM audioDownloadVM;
      String localTargetPlaylistTitle =
          'audio_learn_download_single_video_to_empty_local_playlist_test';
      String localTestPlaylistDir =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$localTargetPlaylistTitle";
      String savedTestPlaylistDir =
          "$kDownloadAppTestSavedDataDir${path.separator}$localTargetPlaylistTitle";

      final Directory directory = Directory(localTestPlaylistDir);

      // necessary in case the previous test failed and so did not
      // delete the its playlist dir
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      await DirUtil.createDirIfNotExist(pathStr: localTestPlaylistDir);

      // Copying the initial local playlist json file with no audio
      await DirUtil.copyFileToDirectory(
        sourceFilePathName:
            "$savedTestPlaylistDir${path.separator}$localTargetPlaylistTitle.json",
        targetDirectoryPath: localTestPlaylistDir,
      );

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: "temp\\wrong.json");

      // Building and displaying the DownloadPlaylistPage integration test
      // application.
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (BuildContext context) {
          final WarningMessageVM warningMessageVM = WarningMessageVM();
          audioDownloadVM = AudioDownloadVM(
            warningMessageVM: warningMessageVM,
            settingsDataService: settingsDataService,
            isTest: true,
          );
          return audioDownloadVM;
        },
        child: MaterialApp(
          // forcing dark theme
          theme: ScreenMixin.themeDataDark,
          home: const DownloadPlaylistPage(
            // integration test opened application
            playlistUrl: globalTestPlaylistUrl,
          ),
        ),
      ));

      String singleVideoUrl = 'https://youtu.be/uv3VQoWSjBE';

      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        singleVideoUrl,
      );
      await tester.pumpAndSettle();

      // tapping on the downl single video button in the app which
      // calls the AudioDownloadVM.downloadSingleVideoAudio(videoUrl,
      // singleVideoTargetPlaylist, downloadAtMusicQuality) method.
      //
      // In this case, the downloadAtMusicQuality is set to true.
      await tester.tap(find
          .byKey(const Key('downloadSingleVideoAudioInAudioQualityButton')));
      await tester.pumpAndSettle();

      // Add a delay to allow the download to finish. 5 seconds is ok
      // when running the audio_download_vm_test only.
      // Waiting 5 seconds only causes MissingPluginException
      // 'No implementation found for method $method on channel $name'
      // when all tsts are run. 7 seconds solve the problem.
      await Future.delayed(const Duration(seconds: secondsDelay));
      await tester.pumpAndSettle();

      Playlist singleVideoDownloadedPlaylist =
          audioDownloadVM.listOfPlaylist[0];

      checkDownloadedPlaylist(
        downloadedPlaylist: singleVideoDownloadedPlaylist,
        playlistId: localTargetPlaylistTitle,
        playlistTitle: localTargetPlaylistTitle,
        playlistUrl: '',
        playlistDir: localTestPlaylistDir,
      );

      // this check fails if the secondsDelay value is too small
      expect(audioDownloadVM.isDownloading, false);

      expect(audioDownloadVM.downloadProgress, 1.0);
      expect(audioDownloadVM.lastSecondDownloadSpeed, 0);
      expect(audioDownloadVM.isHighQuality, false);

      // Checking the data of the single video audio contained in the
      // target playlist in which the audio was downloaded
      checkDownloadedAudioShortVideoTwo(
        downloadedAudioTwo: singleVideoDownloadedPlaylist.downloadedAudioLst[0],
        audioTwoFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
        downloadedAtMusicQuality: false,
        downloadedFileSize: 160000,
        audioDurationMilliseconds: 9845,
      );

      // Checking if there are 2 files in the directory (1 mp3 and 1 json)
      final List<FileSystemEntity> files =
          directory.listSync(recursive: false, followLinks: false);

      expect(files.length, 2);

      // Checking if the playlist json file has been updated with the
      // downloaded audio data

      String playlistPathFileName =
          '$localTestPlaylistDir${path.separator}$localTargetPlaylistTitle.json';

      Playlist loadedPlaylist = JsonDataService.loadFromFile(
          jsonPathFileName: playlistPathFileName, type: Playlist);

      compareDeserializedWithOriginalPlaylist(
        deserializedPlaylist: loadedPlaylist,
        originalPlaylist: singleVideoDownloadedPlaylist,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('''Download single video in musical quality to a target local
                   playlist containing no audio''',
        (WidgetTester tester) async {
      late AudioDownloadVM audioDownloadVM;
      String localTargetPlaylistTitle =
          'audio_learn_download_single_video_to_empty_local_playlist_test';
      String localTestPlaylistDir =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$localTargetPlaylistTitle";
      String savedTestPlaylistDir =
          "$kDownloadAppTestSavedDataDir${path.separator}$localTargetPlaylistTitle";

      final Directory directory = Directory(localTestPlaylistDir);

      // necessary in case the previous test failed and so did not
      // delete the its playlist dir
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      await DirUtil.createDirIfNotExist(pathStr: localTestPlaylistDir);

      // Copying the initial local playlist json file with no audio
      await DirUtil.copyFileToDirectory(
        sourceFilePathName:
            "$savedTestPlaylistDir${path.separator}$localTargetPlaylistTitle.json",
        targetDirectoryPath: localTestPlaylistDir,
      );

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: "temp\\wrong.json");

      // Building and displaying the DownloadPlaylistPage integration test
      // application.
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (BuildContext context) {
          final WarningMessageVM warningMessageVM = WarningMessageVM();
          audioDownloadVM = AudioDownloadVM(
            warningMessageVM: warningMessageVM,
            settingsDataService: settingsDataService,
            isTest: true,
          );
          return audioDownloadVM;
        },
        child: MaterialApp(
          // forcing dark theme
          theme: ScreenMixin.themeDataDark,
          home: const DownloadPlaylistPage(
            // integration test opened application
            playlistUrl: globalTestPlaylistUrl,
          ),
        ),
      ));

      String singleVideoUrl = 'https://youtu.be/uv3VQoWSjBE';

      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        singleVideoUrl,
      );
      await tester.pumpAndSettle();

      // tapping on the downl single video button in the app which
      // calls the AudioDownloadVM.downloadSingleVideoAudio(videoUrl,
      // singleVideoTargetPlaylist, downloadAtMusicQuality) method.
      //
      // In this case, the downloadAtMusicQuality is set to true.
      await tester.tap(find
          .byKey(const Key('downloadSingleVideoAudioInMusicQualityButton')));
      await tester.pumpAndSettle();

      // Add a delay to allow the download to finish. 5 seconds is ok
      // when running the audio_download_vm_test only.
      // Waiting 5 seconds only causes MissingPluginException
      // 'No implementation found for method $method on channel $name'
      // when all tsts are run. 7 seconds solve the problem.
      await Future.delayed(const Duration(seconds: secondsDelay));
      await tester.pumpAndSettle();

      Playlist singleVideoDownloadedPlaylist =
          audioDownloadVM.listOfPlaylist[0];

      checkDownloadedPlaylist(
        downloadedPlaylist: singleVideoDownloadedPlaylist,
        playlistId: localTargetPlaylistTitle,
        playlistTitle: localTargetPlaylistTitle,
        playlistUrl: '',
        playlistDir: localTestPlaylistDir,
      );

      // this check fails if the secondsDelay value is too small
      expect(audioDownloadVM.isDownloading, false);

      expect(audioDownloadVM.downloadProgress, 1.0);
      expect(audioDownloadVM.lastSecondDownloadSpeed, 0);
      expect(audioDownloadVM.isHighQuality, true);

      // Checking the data of the single video audio contained in the
      // target playlist in which the audio was downloaded
      checkDownloadedAudioShortVideoTwo(
        downloadedAudioTwo: singleVideoDownloadedPlaylist.downloadedAudioLst[0],
        audioTwoFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
        downloadedAtMusicQuality: true,
        downloadedFileSize: 160000,
        audioDurationMilliseconds: 9845,
      );

      // Checking if there are 2 files in the directory (1 mp3 and 1 json)
      final List<FileSystemEntity> files =
          directory.listSync(recursive: false, followLinks: false);

      expect(files.length, 2);

      // Checking if the playlist json file has been updated with the
      // downloaded audio data

      String playlistPathFileName =
          '$localTestPlaylistDir${path.separator}$localTargetPlaylistTitle.json';

      Playlist loadedPlaylist = JsonDataService.loadFromFile(
          jsonPathFileName: playlistPathFileName, type: Playlist);

      compareDeserializedWithOriginalPlaylist(
        deserializedPlaylist: loadedPlaylist,
        originalPlaylist: singleVideoDownloadedPlaylist,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('Local playlist containing one audio',
        (WidgetTester tester) async {
      late AudioDownloadVM audioDownloadVM;
      String localTestPlaylistTitle =
          'audio_learn_download_single_video_to_not_empty_local_playlist_test';
      String localTestPlaylistDir =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$localTestPlaylistTitle";
      String savedTestPlaylistDir =
          "$kDownloadAppTestSavedDataDir${path.separator}$localTestPlaylistTitle";

      final Directory directory = Directory(localTestPlaylistDir);

      // necessary in case the previous test failed and so did not
      // delete the its playlist dir
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      await DirUtil.createDirIfNotExist(pathStr: localTestPlaylistDir);

      // Copying the initial local playlist json file with no audio
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath: savedTestPlaylistDir,
        destinationRootPath: localTestPlaylistDir,
      );

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: "temp\\wrong.json");

      // Building and displaying the DownloadPlaylistPage integration test
      // application.
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (BuildContext context) {
          final WarningMessageVM warningMessageVM = WarningMessageVM();
          audioDownloadVM = AudioDownloadVM(
            warningMessageVM: warningMessageVM,
            settingsDataService: settingsDataService,
            isTest: true,
          );
          return audioDownloadVM;
        },
        child: MaterialApp(
          // forcing dark theme
          theme: ScreenMixin.themeDataDark,
          home: const DownloadPlaylistPage(
            // integration test opened application
            playlistUrl: globalTestPlaylistUrl,
          ),
        ),
      ));

      String singleVideoUrl = 'https://youtu.be/uv3VQoWSjBE';

      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        singleVideoUrl,
      );
      await tester.pumpAndSettle();

      // tapping on the downl single video button in the app which
      // calls the AudioDownloadVM.downloadPlaylistAudios() method
      await tester.tap(find.byKey(const Key('downloadSingleVideoAudioButton')));
      await tester.pumpAndSettle();

      // Add a delay to allow the download to finish. 5 seconds is ok
      // when running the audio_download_vm_test only.
      // Waiting 5 seconds only causes MissingPluginException
      // 'No implementation found for method $method on channel $name'
      // when all tsts are run. 7 seconds solve the problem.
      await Future.delayed(const Duration(seconds: secondsDelay));
      await tester.pumpAndSettle();

      Playlist singleVideoDownloadedPlaylist =
          audioDownloadVM.listOfPlaylist[0];

      checkDownloadedPlaylist(
        downloadedPlaylist: singleVideoDownloadedPlaylist,
        playlistId: localTestPlaylistTitle,
        playlistTitle: localTestPlaylistTitle,
        playlistUrl: '',
        playlistDir: localTestPlaylistDir,
      );

      // this check fails if the secondsDelay value is too small
      expect(audioDownloadVM.isDownloading, false);

      expect(audioDownloadVM.downloadProgress, 1.0);
      expect(audioDownloadVM.lastSecondDownloadSpeed, 0);
      expect(audioDownloadVM.isHighQuality, false);

      // downloadedAudioLst contains added Audio's. Checking the
      // values of the 1st and 2nd audio still in the playlist json
      // file and deleted from the playlist dir ...
      checkPlaylistDownloadedAudios(
        downloadedAudioOne: singleVideoDownloadedPlaylist.downloadedAudioLst[0],
        downloadedAudioTwo: singleVideoDownloadedPlaylist.downloadedAudioLst[1],
        audioOneFileNamePrefix: existingAudioDateOnlyFileNamePrefix,
        audioTwoFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
        downloadedFileSizeOne: 143679,
        downloadedFileSizeTwo: 160000,
        audioDurationMillisecondsOne: 24000,
        audioDurationMillisecondsTwo: 9845,
      );

      // ... and the values of the 3rd and 4th audio newly downloaded
      // and added to the playlist downloaded audio lst ...

      // playableAudioLst contains Audio's inserted at list start.
      // Checking the values of the 1st and 2nd audio still in the
      // playlist json file and deleted from the playlist dir ...

      checkPlaylistDownloadedAudios(
        downloadedAudioOne: singleVideoDownloadedPlaylist.playableAudioLst[1],
        downloadedAudioTwo: singleVideoDownloadedPlaylist.playableAudioLst[0],
        audioOneFileNamePrefix: existingAudioDateOnlyFileNamePrefix,
        audioTwoFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
        downloadedFileSizeOne: 143679,
        downloadedFileSizeTwo: 160000,
        audioDurationMillisecondsOne: 24000,
        audioDurationMillisecondsTwo: 9845,
      );

      // Checking if there are 3 files in the directory (2 mp3 and 1 json)
      final List<FileSystemEntity> files =
          directory.listSync(recursive: false, followLinks: false);

      expect(files.length, 3);

      // Checking if the playlist json file has been updated with the
      // downloaded audio data

      String playlistPathFileName =
          '$localTestPlaylistDir${path.separator}$localTestPlaylistTitle.json';

      Playlist loadedPlaylist = JsonDataService.loadFromFile(
          jsonPathFileName: playlistPathFileName, type: Playlist);

      compareDeserializedWithOriginalPlaylist(
        deserializedPlaylist: loadedPlaylist,
        originalPlaylist: singleVideoDownloadedPlaylist,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('Download recreated playlist with short audio', () {
    testWidgets(
        '''Recreated playlist with 2 new short audio: initial playlist 1st and
           2nd audio already downloaded and deleted. This test is used to test
           recreating the playlist with the same name. Recreating a playlist
           with an identical name avoids to loose time removing from the original
           playlist the referenced videos. The recreated playlist audio are
           downloaded in the same dir than the original playlist, The original
           playlist json file is updated with the recreated playlist id and url
           as well as with the newly downloaded audio.''',
        (WidgetTester tester) async {
      late AudioDownloadVM audioDownloadVM;
      final Directory directory = Directory(globalTestPlaylistDir);

      // necessary in case the previous test failed and so did not
      // delete the its playlist dir
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      await DirUtil.createDirIfNotExist(pathStr: globalTestPlaylistDir);

      // Copying the initial playlist json file with the 1st and 2nd
      // audio whose mp3 were deleted from the playlist dir. A
      // replacing new Youtube playlist with the same title was created
      // with 2 new audio referenced in it. The new playlist id and url
      // are of course different from the initial playlist id and url.
      await DirUtil.copyFileToDirectory(
        sourceFilePathName:
            "$kDownloadAppTestSavedDataDir${path.separator}$globalTestPlaylistTitle${path.separator}$globalTestPlaylistTitle.json",
        targetDirectoryPath: globalTestPlaylistDir,
      );

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: "temp\\wrong.json");

      final WarningMessageVM warningMessageVM = WarningMessageVM();
      final AudioDownloadVM audioDownloadVMbeforeDownload = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );
      Playlist existingPlaylistBeforeDownloadingRecreatedPlaylistWithSameTitle =
          audioDownloadVMbeforeDownload.listOfPlaylist[0];

      checkDownloadedPlaylist(
        downloadedPlaylist:
            existingPlaylistBeforeDownloadingRecreatedPlaylistWithSameTitle,
        playlistId: globalTestPlaylistId,
        playlistTitle: globalTestPlaylistTitle,
        playlistUrl: globalTestPlaylistUrl,
        playlistDir: globalTestPlaylistDir,
      );

      List<Audio> downloadedAudioLstBeforeDownload =
          existingPlaylistBeforeDownloadingRecreatedPlaylistWithSameTitle
              .downloadedAudioLst;
      List<Audio> playableAudioLstBeforeDownload =
          existingPlaylistBeforeDownloadingRecreatedPlaylistWithSameTitle
              .playableAudioLst;

      // Checking the data of the audio contained in the already
      // downloaded audio list
      //
      // downloadedAudioLst contains Audio's added at list end
      checkPlaylistDownloadedAudios(
        downloadedAudioOne: downloadedAudioLstBeforeDownload[0],
        downloadedAudioTwo: downloadedAudioLstBeforeDownload[1],
        audioOneFileNamePrefix: existingAudioDateOnlyFileNamePrefix,
        audioTwoFileNamePrefix: existingAudioDateOnlyFileNamePrefix,
        downloadedFileSizeOne: 143679,
        downloadedFileSizeTwo: 61425,
        audioDurationMillisecondsOne: 24000,
        audioDurationMillisecondsTwo: 10000,
      );

      // Checking the data of the  already downloaded audio contained
      // in the playable audio list;
      //
      // playableAudioLst contains Audio's inserted at list start
      checkPlaylistDownloadedAudios(
        downloadedAudioOne: playableAudioLstBeforeDownload[1],
        downloadedAudioTwo: playableAudioLstBeforeDownload[0],
        audioOneFileNamePrefix: existingAudioDateOnlyFileNamePrefix,
        audioTwoFileNamePrefix: existingAudioDateOnlyFileNamePrefix,
        downloadedFileSizeOne: 143679,
        downloadedFileSizeTwo: 61425,
        audioDurationMillisecondsOne: 24000,
        audioDurationMillisecondsTwo: 10000,
      );

      // Building and displaying the DownloadPlaylistPage integration test
      // application.
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (BuildContext context) {
          final WarningMessageVM warningMessageVM = WarningMessageVM();
          audioDownloadVM = AudioDownloadVM(
            warningMessageVM: warningMessageVM,
            settingsDataService: settingsDataService,
            isTest: true,
          );
          return audioDownloadVM;
        },
        child: MaterialApp(
          // forcing dark theme
          theme: ScreenMixin.themeDataDark,
          home: const DownloadPlaylistPage(
            // integration test opened application
            playlistUrl: globalTestPlaylistUrl,
          ),
        ),
      ));

      const String recreatedPlaylistId = 'PLzwWSJNcZTMSwrDOAZEPf0u6YvrKGNnvC';
      const String recreatedPlaylistWithSameTitleUrl =
          'https://youtube.com/playlist?list=PLzwWSJNcZTMSwrDOAZEPf0u6YvrKGNnvC';

      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        recreatedPlaylistWithSameTitleUrl,
      );
      await tester.pumpAndSettle();

      // tapping on the downl playlist button in the app which calls the
      // AudioDownloadVM.downloadPlaylistAudios(playlistUrl) method
      await tester.tap(find.byKey(const Key('downloadPlaylistAudiosButton')));
      await tester.pumpAndSettle();

      // Add a delay to allow the download to finish. 5 seconds is ok
      // when running the audio_download_vm_test only.
      // Waiting 5 seconds only causes MissingPluginException
      // 'No implementation found for method $method on channel $name'
      // when all tsts are run. 7 seconds solve the problem.
      await Future.delayed(const Duration(seconds: secondsDelay));
      await tester.pumpAndSettle();

      Playlist addedPlaylistAfterDownloadingRecreatedPlaylistWithSameTitle =
          audioDownloadVM.listOfPlaylist[0];

      // The initial playlist json file was updated with the recreated
      // playlist id and url as well as with the newly downloaded audio
      compareNewRecreatedPlaylistToPreviouslyExistingPlaylist(
        newRecreatedPlaylistWithSameTitle:
            addedPlaylistAfterDownloadingRecreatedPlaylistWithSameTitle,
        previouslyExistingPlaylist:
            existingPlaylistBeforeDownloadingRecreatedPlaylistWithSameTitle,
        newRecreatedPlaylistWithSameTitleId: recreatedPlaylistId,
        newRecreatedPlaylistWithSameTitleUrl: recreatedPlaylistWithSameTitleUrl,
      );

      // this check fails if the secondsDelay value is too small
      expect(audioDownloadVM.isDownloading, false);

      expect(audioDownloadVM.downloadProgress, 1.0);
      expect(audioDownloadVM.lastSecondDownloadSpeed, 0);
      expect(audioDownloadVM.isHighQuality, false);

      // downloadedAudioLst contains added Audio's. Checking the
      // values of the 1st and 2nd audio still in the playlist json
      // file and deleted from the playlist dir ...
      checkPlaylistDownloadedAudios(
        downloadedAudioOne:
            addedPlaylistAfterDownloadingRecreatedPlaylistWithSameTitle
                .downloadedAudioLst[0],
        downloadedAudioTwo:
            addedPlaylistAfterDownloadingRecreatedPlaylistWithSameTitle
                .downloadedAudioLst[1],
        audioOneFileNamePrefix: existingAudioDateOnlyFileNamePrefix,
        audioTwoFileNamePrefix: existingAudioDateOnlyFileNamePrefix,
        downloadedFileSizeOne: 143679,
        downloadedFileSizeTwo: 61425,
        audioDurationMillisecondsOne: 24000,
        audioDurationMillisecondsTwo: 10000,
      );

      // ... and the values of the 3rd and 4th audio newly downloaded
      // and added to the playlist downloaded audio lst ...

      checkPlaylistNewDownloadedAudios(
        downloadedAudioOne:
            addedPlaylistAfterDownloadingRecreatedPlaylistWithSameTitle
                .downloadedAudioLst[2],
        downloadedAudioTwo:
            addedPlaylistAfterDownloadingRecreatedPlaylistWithSameTitle
                .downloadedAudioLst[3],
      );

      // playableAudioLst contains Audio's inserted at list start.
      // Checking the values of the 1st and 2nd audio still in the
      // playlist json file and deleted from the playlist dir ...

      checkPlaylistDownloadedAudios(
        downloadedAudioOne:
            addedPlaylistAfterDownloadingRecreatedPlaylistWithSameTitle
                .playableAudioLst[3],
        downloadedAudioTwo:
            addedPlaylistAfterDownloadingRecreatedPlaylistWithSameTitle
                .playableAudioLst[2],
        audioOneFileNamePrefix: existingAudioDateOnlyFileNamePrefix,
        audioTwoFileNamePrefix: existingAudioDateOnlyFileNamePrefix,
        downloadedFileSizeOne: 143679,
        downloadedFileSizeTwo: 61425,
        audioDurationMillisecondsOne: 24000,
        audioDurationMillisecondsTwo: 10000,
      );

      // ... and the values of the 3rd and 4th audio newly downloaded
      // and inserted at start of to the playlist playable audio list
      // ...

      // Checking the data of the audio contained in the playable
      // audio list;
      //
      // playableAudioLst contains Audio's inserted at list start
      checkPlaylistNewDownloadedAudios(
        downloadedAudioOne:
            addedPlaylistAfterDownloadingRecreatedPlaylistWithSameTitle
                .playableAudioLst[1],
        downloadedAudioTwo:
            addedPlaylistAfterDownloadingRecreatedPlaylistWithSameTitle
                .playableAudioLst[0],
      );

      // Checking if there are 3 files in the directory (2 mp3 and 1 json)
      final List<FileSystemEntity> files =
          directory.listSync(recursive: false, followLinks: false);

      expect(files.length, 3);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
}

void checkDownloadedPlaylist({
  required Playlist downloadedPlaylist,
  required String playlistId,
  required String playlistTitle,
  required String playlistUrl,
  required String playlistDir,
}) {
  expect(downloadedPlaylist.id, playlistId);
  expect(downloadedPlaylist.title, playlistTitle);
  expect(downloadedPlaylist.url, playlistUrl);
  expect(downloadedPlaylist.downloadPath, playlistDir);
  expect(downloadedPlaylist.playlistQuality, PlaylistQuality.voice);
  expect(downloadedPlaylist.playlistType,
      (playlistUrl.isNotEmpty) ? PlaylistType.youtube : PlaylistType.local);
  expect(downloadedPlaylist.isSelected, false);
}

// Verify the values of the Audio's extracted from a playlist
void checkPlaylistDownloadedAudios({
  required Audio downloadedAudioOne,
  required Audio downloadedAudioTwo,
  required String audioOneFileNamePrefix,
  required String audioTwoFileNamePrefix,
  required int downloadedFileSizeOne,
  required int downloadedFileSizeTwo,
  required int audioDurationMillisecondsOne,
  required int audioDurationMillisecondsTwo,
}) {
  checkDownloadedAudioShortVideoOne(
    downloadedAudioOne: downloadedAudioOne,
    audioOneFileNamePrefix: audioOneFileNamePrefix,
    downloadedFileSize: downloadedFileSizeOne,
    audioDurationMilliseconds: audioDurationMillisecondsOne,
  );

  checkDownloadedAudioShortVideoTwo(
    downloadedAudioTwo: downloadedAudioTwo,
    audioTwoFileNamePrefix: audioTwoFileNamePrefix,
    downloadedFileSize: downloadedFileSizeTwo,
    audioDurationMilliseconds: audioDurationMillisecondsTwo,
  );
}

// Verify the values of the Audio's extracted from a playlist
void compareNewRecreatedPlaylistToPreviouslyExistingPlaylist({
  required Playlist newRecreatedPlaylistWithSameTitle,
  required Playlist previouslyExistingPlaylist,
  required String newRecreatedPlaylistWithSameTitleId,
  required String newRecreatedPlaylistWithSameTitleUrl,
}) {
  expect(newRecreatedPlaylistWithSameTitle.id,
      newRecreatedPlaylistWithSameTitleId);
  expect(newRecreatedPlaylistWithSameTitle.title,
      previouslyExistingPlaylist.title);
  expect(newRecreatedPlaylistWithSameTitle.url,
      newRecreatedPlaylistWithSameTitleUrl);
  expect(newRecreatedPlaylistWithSameTitle.downloadPath,
      previouslyExistingPlaylist.downloadPath);
  expect(newRecreatedPlaylistWithSameTitle.playlistQuality,
      previouslyExistingPlaylist.playlistQuality);
  expect(newRecreatedPlaylistWithSameTitle.audioPlaySpeed,
      previouslyExistingPlaylist.audioPlaySpeed);
  expect(newRecreatedPlaylistWithSameTitle.playlistType,
      previouslyExistingPlaylist.playlistType);
  expect(newRecreatedPlaylistWithSameTitle.isSelected,
      previouslyExistingPlaylist.isSelected);

  expect(newRecreatedPlaylistWithSameTitle.downloadedAudioLst.length,
      previouslyExistingPlaylist.downloadedAudioLst.length + 2);
  expect(newRecreatedPlaylistWithSameTitle.playableAudioLst.length,
      previouslyExistingPlaylist.playableAudioLst.length + 2);
  expect(
      newRecreatedPlaylistWithSameTitle
          .audioSortFilterParmsNameForPlaylistDownloadView,
      previouslyExistingPlaylist
          .audioSortFilterParmsNameForPlaylistDownloadView);
  expect(
      newRecreatedPlaylistWithSameTitle
          .audioSortFilterParmsNameForAudioPlayerView,
      previouslyExistingPlaylist.audioSortFilterParmsNameForAudioPlayerView);
}

/// Verify the values of the "audio learn test short video one" downloaded
/// audio.
void checkDownloadedAudioShortVideoOne({
  required Audio downloadedAudioOne,
  required String audioOneFileNamePrefix,
  required int downloadedFileSize,
  required int audioDurationMilliseconds,
  bool downloadedAtMusicQuality = false,
}) {
  expect(downloadedAudioOne.youtubeVideoChannel, "Jean-Pierre Schnyder");
  expect(downloadedAudioOne.originalVideoTitle,
      "audio learn test short video one");
  expect(
      downloadedAudioOne.validVideoTitle, "audio learn test short video one");
  expect(downloadedAudioOne.videoUrl,
      "https://www.youtube.com/watch?v=v7PWb7f_P8M");
  expect(downloadedAudioOne.compactVideoDescription,
      "Jean-Pierre Schnyder\n\nCette vidéo me sert à tester AudioLearn, l'app Android que je développe et dont le code est disponible sur GitHub. ...");
  expect(
      DateTimeParser.truncateDateTimeToDateOnly(
          downloadedAudioOne.videoUploadDate),
      DateTime.parse("2023-06-10"));
  expect(
    downloadedAudioOne.audioDuration,
    Duration(milliseconds: audioDurationMilliseconds),
  );
  expect(downloadedAudioOne.audioPlaySpeed, 1.0);
  expect(downloadedAudioOne.isAudioMusicQuality, downloadedAtMusicQuality);

  String firstAudioFileName = downloadedAudioOne.audioFileName;
  expect(
      firstAudioFileName.contains(audioOneFileNamePrefix) &&
          firstAudioFileName
              .contains('audio learn test short video one 23-06-10.mp3'),
      true);

  expect(downloadedAudioOne.audioFileSize, downloadedFileSize);
}

/// Verify the values of the "audio learn test short video two" downloaded
/// audio.
void checkDownloadedAudioShortVideoTwo({
  required Audio downloadedAudioTwo,
  required String audioTwoFileNamePrefix,
  required int downloadedFileSize,
  required int audioDurationMilliseconds,
  bool downloadedAtMusicQuality = false,
}) {
  expect(downloadedAudioTwo.youtubeVideoChannel, "Jean-Pierre Schnyder");
  expect(downloadedAudioTwo.originalVideoTitle,
      "audio learn test short video two");
  expect(
      downloadedAudioTwo.validVideoTitle, "audio learn test short video two");
  expect(downloadedAudioTwo.compactVideoDescription,
      "Jean-Pierre Schnyder\n\nCette vidéo me sert à tester AudioLearn, l'app Android que je développe. ...");
  expect(downloadedAudioTwo.videoUrl,
      "https://www.youtube.com/watch?v=uv3VQoWSjBE");
  expect(
      DateTimeParser.truncateDateTimeToDateOnly(
          downloadedAudioTwo.videoUploadDate),
      DateTime.parse("2023-06-10"));
  expect(
      downloadedAudioTwo.audioDuration,
      Duration(
        milliseconds: audioDurationMilliseconds,
      ));
  expect(downloadedAudioTwo.audioPlaySpeed, 1.0);
  expect(downloadedAudioTwo.isAudioMusicQuality, downloadedAtMusicQuality);

  String secondAudioFileName = downloadedAudioTwo.audioFileName;
  expect(
      secondAudioFileName.contains(audioTwoFileNamePrefix) &&
          secondAudioFileName
              .contains('audio learn test short video two 23-06-10.mp3'),
      true);
  expect(downloadedAudioTwo.audioFileSize, downloadedFileSize);
}

// Verify the values of the Audio's extracted from a playlist
void checkPlaylistNewDownloadedAudios({
  required Audio downloadedAudioOne,
  required Audio downloadedAudioTwo,
}) {
  checkPlaylistNewAudioOne(
    downloadedAudioOne: downloadedAudioOne,
  );

  checkPlaylistNewAudioTwo(
    downloadedAudioTwo: downloadedAudioTwo,
  );
}

// Verify the values of the second Audio extracted from a playlist
void checkPlaylistNewAudioOne({
  required Audio downloadedAudioOne,
}) {
  expect(downloadedAudioOne.youtubeVideoChannel, "Jean-Pierre Schnyder");
  expect(downloadedAudioOne.originalVideoTitle, "Really short video");
  expect(downloadedAudioOne.validVideoTitle, "Really short video");
  expect(downloadedAudioOne.compactVideoDescription,
      "Jean-Pierre Schnyder\n\nCette vidéo me sert à tester AudioLearn, l'app Android que je développe. ...");
  expect(downloadedAudioOne.videoUrl,
      "https://www.youtube.com/watch?v=ADt0BYlh1Yo");
  expect(downloadedAudioOne.audioDuration, const Duration(milliseconds: 9845));
  expect(downloadedAudioOne.audioPlaySpeed, 1.0);

  String firstNewAudioFileName = downloadedAudioOne.audioFileName;
  expect(
      firstNewAudioFileName.contains(todayDownloadDateOnlyFileNamePrefix) &&
          firstNewAudioFileName.contains('Really short video 23-07-01.mp3'),
      true);

  expect(downloadedAudioOne.audioFileSize, 160000);
  expect(
      DateTimeParser.truncateDateTimeToDateOnly(
          downloadedAudioOne.videoUploadDate),
      DateTime.parse("2023-07-01"));
}

// Verify the values of the first Audio extracted from a playlist
void checkPlaylistNewAudioTwo({
  required Audio downloadedAudioTwo,
}) {
  expect(downloadedAudioTwo.youtubeVideoChannel, "Jean-Pierre Schnyder");
  expect(downloadedAudioTwo.originalVideoTitle, "morning | cinematic video");
  expect(downloadedAudioTwo.validVideoTitle, "morning _ cinematic video");
  expect(downloadedAudioTwo.videoUrl,
      "https://www.youtube.com/watch?v=nDqolLTOzYk");
  expect(downloadedAudioTwo.compactVideoDescription,
      "Jean-Pierre Schnyder\n\nCette vidéo me sert à tester AudioLearn, l'app Android que je développe. ...");
  expect(downloadedAudioTwo.audioDuration, const Duration(milliseconds: 58932));
  expect(downloadedAudioTwo.audioPlaySpeed, 1.0);

  String secondNewAudioFileName = downloadedAudioTwo.audioFileName;
  expect(
      secondNewAudioFileName.contains(todayDownloadDateOnlyFileNamePrefix) &&
          secondNewAudioFileName
              .contains('morning _ cinematic video 23-07-01.mp3'),
      true);

  expect(downloadedAudioTwo.audioFileSize, 954427);
  expect(
      DateTimeParser.truncateDateTimeToDateOnly(
          downloadedAudioTwo.videoUploadDate),
      DateTime.parse("2023-07-01"));
  // DateTime.parse("2023-07-01 18:48:13.000Z")); this
  // uncomprehensible error happened several times when
  // running the test on 04-10-2023 !
}

class DownloadPlaylistPage extends StatefulWidget {
  final String playlistUrl;

  const DownloadPlaylistPage({
    super.key,
    required this.playlistUrl,
  });

  @override
  State<DownloadPlaylistPage> createState() => _DownloadPlaylistPageState();
}

class _DownloadPlaylistPageState extends State<DownloadPlaylistPage> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urlController.text = widget.playlistUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Download Playlist Audio')),
      body: Center(
        child: Column(
          children: [
            TextField(
              key: const Key('playlistUrlTextField'),
              controller: _urlController,
            ),
            ElevatedButton(
              key: const Key('downloadPlaylistAudiosButton'),
              onPressed: () {
                Provider.of<AudioDownloadVM>(context, listen: false)
                    .downloadPlaylistAudios(
                  playlistUrl: _urlController.text,
                );
              },
              child: const Text('Download Playlist Audio'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              key: const Key('downloadSingleVideoAudioButton'),
              onPressed: () {
                AudioDownloadVM audioDownloadVM =
                    Provider.of<AudioDownloadVM>(context, listen: false);

                // the downloaded audio will be added to the unique playlist
                // located in the test audio directory
                audioDownloadVM.downloadSingleVideoAudio(
                  videoUrl: _urlController.text,
                  singleVideoTargetPlaylist: audioDownloadVM.listOfPlaylist[0],
                );
              },
              child: const Text('Download Single Video Audio'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              key: const Key('downloadSingleVideoAudioInAudioQualityButton'),
              onPressed: () {
                AudioDownloadVM audioDownloadVM =
                    Provider.of<AudioDownloadVM>(context, listen: false);

                // the downloaded audio will be added to the unique playlist
                // located in the test audio directory
                audioDownloadVM.downloadSingleVideoAudio(
                  videoUrl: _urlController.text,
                  singleVideoTargetPlaylist: audioDownloadVM.listOfPlaylist[0],
                );
              },
              child: const Text(
                  'Download Single Video Audio In Spoken Audio Quality'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              key: const Key('downloadSingleVideoAudioInMusicQualityButton'),
              onPressed: () {
                AudioDownloadVM audioDownloadVM =
                    Provider.of<AudioDownloadVM>(context, listen: false);

                // the downloaded audio will be added to the unique playlist
                // located in the test audio directory
                audioDownloadVM.downloadSingleVideoAudio(
                  videoUrl: _urlController.text,
                  singleVideoTargetPlaylist: audioDownloadVM.listOfPlaylist[0],
                  downloadAtMusicQuality: true,
                );
              },
              child: const Text('Download Single Video Audio In Music Quality'),
            ),
          ],
        ),
      ),
    );
  }
}

void compareDeserializedWithOriginalPlaylist({
  required Playlist deserializedPlaylist,
  required Playlist originalPlaylist,
}) {
  expect(deserializedPlaylist.id, originalPlaylist.id);
  expect(deserializedPlaylist.title, originalPlaylist.title);
  expect(deserializedPlaylist.url, originalPlaylist.url);
  expect(deserializedPlaylist.playlistType, originalPlaylist.playlistType);
  expect(
      deserializedPlaylist.playlistQuality, originalPlaylist.playlistQuality);
  expect(deserializedPlaylist.downloadPath, originalPlaylist.downloadPath);
  expect(deserializedPlaylist.isSelected, originalPlaylist.isSelected);

  // Compare Audio instances in original and loaded Playlist
  expect(deserializedPlaylist.downloadedAudioLst.length,
      originalPlaylist.downloadedAudioLst.length);
  expect(deserializedPlaylist.playableAudioLst.length,
      originalPlaylist.playableAudioLst.length);

  for (int i = 0; i < deserializedPlaylist.downloadedAudioLst.length; i++) {
    Audio originalAudio = originalPlaylist.downloadedAudioLst[i];
    Audio loadedAudio = deserializedPlaylist.downloadedAudioLst[i];

    compareDeserializedWithOriginalAudio(
      deserializedAudio: loadedAudio,
      originalAudio: originalAudio,
    );
  }

  for (int i = 0; i < deserializedPlaylist.playableAudioLst.length; i++) {
    Audio originalAudio = originalPlaylist.playableAudioLst[i];
    Audio loadedAudio = deserializedPlaylist.playableAudioLst[i];

    compareDeserializedWithOriginalAudio(
      deserializedAudio: loadedAudio,
      originalAudio: originalAudio,
    );
  }
}

void compareDeserializedWithOriginalAudio({
  required Audio deserializedAudio,
  required Audio originalAudio,
}) {
  (deserializedAudio.enclosingPlaylist != null)
      ? expect(deserializedAudio.enclosingPlaylist!.title,
          originalAudio.enclosingPlaylist!.title)
      : expect(
          deserializedAudio.enclosingPlaylist, originalAudio.enclosingPlaylist);
  expect(
      deserializedAudio.originalVideoTitle, originalAudio.originalVideoTitle);
  expect(deserializedAudio.validVideoTitle, originalAudio.validVideoTitle);
  expect(deserializedAudio.compactVideoDescription,
      originalAudio.compactVideoDescription);
  expect(deserializedAudio.videoUrl, originalAudio.videoUrl);
  expect(deserializedAudio.audioDownloadDateTime.toIso8601String(),
      originalAudio.audioDownloadDateTime.toIso8601String());

  // inMilliseconds is used because the duration is not exactly the same
  // when it is serialized and deserialized since it is stored in the json
  // file as a number of milliseconds
  expect(deserializedAudio.audioDownloadDuration!.inMilliseconds,
      originalAudio.audioDownloadDuration!.inMilliseconds);

  expect(
      deserializedAudio.audioDownloadSpeed, originalAudio.audioDownloadSpeed);
  expect(deserializedAudio.videoUploadDate.toIso8601String(),
      originalAudio.videoUploadDate.toIso8601String());
  expect(deserializedAudio.audioDuration, originalAudio.audioDuration);
  expect(
      deserializedAudio.isAudioMusicQuality, originalAudio.isAudioMusicQuality);
  expect(deserializedAudio.audioPlaySpeed, originalAudio.audioPlaySpeed);
  expect(deserializedAudio.audioFileName, originalAudio.audioFileName);
  expect(deserializedAudio.audioFileSize, originalAudio.audioFileSize);
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

import 'package:audiolearn/services/json_data_service.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/utils/date_time_parser.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:audiolearn/constants.dart';
import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/warning_message_vm.dart';

import 'integration_test_util.dart';

const int secondsDelay = 7; // 7 works, but 10 is safer and 15 solves
//                              the problems of running the integr tests
const String existingAudioDateOnlyFileNamePrefix = '230610';
final String todayDownloadDateOnlyFileNamePrefix =
    Audio.downloadDatePrefixFormatter.format(DateTime.now());
const String globalTestPlaylistId = 'PLzwWSJNcZTMRB9ILve6fEIS_OHGrV5R2o';
const String globalTestPlaylistOneAudioId =
    'PLzwWSJNcZTMRB9ILve6fEIS_OHGrV5R2o';
const String globalTestPlaylistUrl =
    'https://youtube.com/playlist?list=PLzwWSJNcZTMRB9ILve6fEIS_OHGrV5R2o';
const String globalTestPlaylistTitle =
    'audio_learn_test_download_2_small_videos';
const String globalTestPlaylistOneAudioTitle =
    'audio_learn_test_download_2_small_vid_1a';
final String globalTestPlaylistDir =
    '$kApplicationPathWindowsTest${path.separator}playlists${path.separator}$globalTestPlaylistTitle';
final String globalTestPlaylistOneAudioDir =
    '$kApplicationPathWindowsTest${path.separator}playlists${path.separator}$globalTestPlaylistOneAudioTitle';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Download 1 playlist with short audio', () {
    test('Check initial values', () async {
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      final WarningMessageVM warningMessageVM = WarningMessageVM();

      final SettingsDataService settingsDataService = SettingsDataService(
        isTest: true,
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: "temp\\wrong.json");

      final AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
      );

      expect(audioDownloadVM.listOfPlaylist, []);

      // this check fails if the secondsDelay value is too small
      expect(audioDownloadVM.isAudioDownloading, false);

      expect(audioDownloadVM.audioDownloadProgress, 0.0);
      expect(audioDownloadVM.lastSecondAudioDownloadSpeed, 0);
      expect(audioDownloadVM.isHighQuality, false);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });

    testWidgets(
        'Playlist 2 short audio in spoken quality: playlist dir not exist',
        (WidgetTester tester) async {
      // necessary in case the previous test failed and so did not
      // delete the its playlist dir
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      // Copying the initial local playlist json file with no audio
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_download_2_small_videos_empty_dir_test",
        destinationRootPath: kApplicationPathWindowsTest,
      );

      AudioDownloadVM audioDownloadVM =
          await IntegrationTestUtil.launchIntegrTestAppEnablingInternetAccess(
        tester: tester,
        forcedLocale: const Locale('en'),
      );

      // Entering the created playlist URL in the Youtube URL or search
      // text field of the app
      await tester.enterText(
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        globalTestPlaylistUrl,
      );
      await tester.pumpAndSettle();

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Check the value of the AlertDialog dialog title
      Text alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Youtube Playlist');

      // Check the value of the AlertDialog url Text
      Text confirmUrlText =
          tester.widget(find.byKey(const Key('playlistUrlConfirmDialogText')));
      expect(confirmUrlText.data, globalTestPlaylistUrl);

      // Confirm the addition by tapping the 'Add' button in
      // the AlertDialog and then on the 'OK' button of the
      // confirm dialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Add a delay to allow the update playlist URL to finish. 1
      // second is ok
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify the displayed warning dialog
      await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "Youtube playlist \"$globalTestPlaylistTitle\" of spoken quality added at the end of the playlist list.",
        isWarningConfirming: true,
      );

      // Now tap on the delete button to empty the search text
      // field. The reason is due to using debounce in the
      // YoutubeUrlOrSearchTextField widget. If the text field is not
      // emptied, it avoids that the Youtube playlist addition warning
      // dialog is shown twice when the 'Add playlist button' button is
      // tapped.
      await tester.tap(
        find.byKey(
          const Key('clearPlaylistUrlOrSearchButtonKey'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<TextField>(find.byKey(
              const Key('youtubeUrlOrSearchTextField'),
            ))
            .controller!
            .text,
        '', // 'Youtube Link or Search' displayed in the TextField
        //     is a hint text and not the actual text !
      );

      // Now selecting the created playlist by tapping on the
      // playlist checkbox
      await IntegrationTestUtil.selectPlaylist(
        tester: tester,
        playlistToSelectTitle: globalTestPlaylistTitle,
      );

      // Now typing on the download playlist button to download the
      // 2 video audios present the created playlist.
      await tester.tap(find.byKey(const Key('download_sel_playlist_button')));
      await tester.pumpAndSettle();

      // Add a delay to allow the download to finish.
      for (int i = 0; i < 6; i++) {
        await Future.delayed(const Duration(seconds: 2));
        await tester.pumpAndSettle();
      }

      Playlist downloadedPlaylist = audioDownloadVM.listOfPlaylist[0];

      _checkDownloadedPlaylist(
        downloadedPlaylist: downloadedPlaylist,
        playlistId: globalTestPlaylistId,
        playlistTitle: globalTestPlaylistTitle,
        playlistUrl: globalTestPlaylistUrl,
        playlistDir: globalTestPlaylistDir,
        isPlaylistSelected: true,
      );

      // this check fails if the secondsDelay value is too small
      expect(audioDownloadVM.isAudioDownloading, false);

      expect(audioDownloadVM.audioDownloadProgress, 1.0);
      expect(audioDownloadVM.lastSecondAudioDownloadSpeed, 0);
      expect(audioDownloadVM.isHighQuality, false);

      // Checking the data of the audio contained in the downloaded
      // audio list which contains 2 downloaded Audio's
      _checkPlaylistDownloadedAudios(
        downloadedAudioOne: downloadedPlaylist.downloadedAudioLst[0],
        downloadedAudioTwo: downloadedPlaylist.downloadedAudioLst[1],
        audioOneFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
        audioTwoFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
      );

      // Checking the data of the audio contained in the playable
      // audio list;
      //
      // playableAudioLst contains Audio's inserted at list start
      _checkPlaylistDownloadedAudios(
        downloadedAudioOne: downloadedPlaylist.playableAudioLst[1],
        downloadedAudioTwo: downloadedPlaylist.playableAudioLst[0],
        audioOneFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
        audioTwoFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
      );

      // Checking if there are 3 files in the directory (2 mp3 and 1 json)
      final List<FileSystemEntity> files =
          Directory(globalTestPlaylistDir).listSync(
        recursive: false,
        followLinks: false,
      );

      expect(files.length, 3);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        'Playlist 2 short audio in music quality: playlist dir not exist',
        (WidgetTester tester) async {
      // necessary in case the previous test failed and so did not
      // delete the its playlist dir
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      // Copying the initial local playlist json file with no audio
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_download_2_small_videos_empty_dir_test",
        destinationRootPath: kApplicationPathWindowsTest,
      );

      AudioDownloadVM audioDownloadVM =
          await IntegrationTestUtil.launchIntegrTestAppEnablingInternetAccess(
        tester: tester,
        forcedLocale: const Locale('en'),
      );

      // Entering the created playlist URL in the Youtube URL or search
      // text field of the app
      await tester.enterText(
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        globalTestPlaylistUrl,
      );
      await tester.pumpAndSettle();

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Check the value of the AlertDialog dialog title
      Text alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Youtube Playlist');

      // Check the value of the AlertDialog url Text
      Text confirmUrlText =
          tester.widget(find.byKey(const Key('playlistUrlConfirmDialogText')));
      expect(confirmUrlText.data, globalTestPlaylistUrl);

      // Set the music quality checkbox to true
      await tester
          .tap(find.byKey(const Key('playlistQualityConfirmDialogCheckBox')));
      await tester.pumpAndSettle();

      // Confirm the addition by tapping the 'Add' button in
      // the AlertDialog and then on the 'OK' button of the
      // confirm dialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Add a delay to allow the update playlist URL to finish. 1
      // second is ok
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify the displayed warning dialog
      await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "Youtube playlist \"$globalTestPlaylistTitle\" of musical quality added at the end of the playlist list.",
        isWarningConfirming: true,
      );

      // Now tap on the delete button to empty the search text
      // field. The reason is due to using debounce in the
      // YoutubeUrlOrSearchTextField widget. If the text field is not
      // emptied, it avoids that the Youtube playlist addition warning
      // dialog is shown twice when the 'Add playlist button' button is
      // tapped.
      await tester.tap(
        find.byKey(
          const Key('clearPlaylistUrlOrSearchButtonKey'),
        ),
      );

      expect(
        tester
            .widget<TextField>(find.byKey(
              const Key('youtubeUrlOrSearchTextField'),
            ))
            .controller!
            .text,
        '', // 'Youtube Link or Search' displayed in the TextField
        //     is a hint text and not the actual text !
      );

      // Now selecting the created playlist by tapping on the
      // playlist checkbox
      await IntegrationTestUtil.selectPlaylist(
        tester: tester,
        playlistToSelectTitle: globalTestPlaylistTitle,
      );

      // Now typing on the download playlist button to download the
      // 2 video audios present the created playlist.
      await tester.tap(find.byKey(const Key('download_sel_playlist_button')));
      await tester.pumpAndSettle();

      // Add a delay to allow the download to finish.
      for (int i = 0; i < 6; i++) {
        await Future.delayed(const Duration(seconds: 2));
        await tester.pumpAndSettle();
      }

      Playlist downloadedPlaylist = audioDownloadVM.listOfPlaylist[0];

      _checkDownloadedPlaylist(
        downloadedPlaylist: downloadedPlaylist,
        playlistId: globalTestPlaylistId,
        playlistTitle: globalTestPlaylistTitle,
        playlistUrl: globalTestPlaylistUrl,
        playlistDir: globalTestPlaylistDir,
        isPlaylistSelected: true,
        isPlaylistAtVoiceQuality: false,
      );

      // this check fails if the secondsDelay value is too small
      expect(audioDownloadVM.isAudioDownloading, false);

      expect(audioDownloadVM.audioDownloadProgress, 1.0);
      expect(audioDownloadVM.lastSecondAudioDownloadSpeed, 0);
      expect(audioDownloadVM.isHighQuality, true);

      // Checking the data of the audio contained in the downloaded
      // audio list which contains 2 downloaded Audio's
      _checkPlaylistDownloadedAudios(
        downloadedAudioOne: downloadedPlaylist.downloadedAudioLst[0],
        downloadedAudioTwo: downloadedPlaylist.downloadedAudioLst[1],
        audioOneFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
        audioTwoFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
        downloadedAtMusicQuality: true,
      );

      // Checking the data of the audio contained in the playable
      // audio list;
      //
      // playableAudioLst contains Audio's inserted at list start
      _checkPlaylistDownloadedAudios(
        downloadedAudioOne: downloadedPlaylist.playableAudioLst[1],
        downloadedAudioTwo: downloadedPlaylist.playableAudioLst[0],
        audioOneFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
        audioTwoFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
        downloadedAtMusicQuality: true,
      );

      // Checking if there are 3 files in the directory (2 mp3 and 1 json)
      final List<FileSystemEntity> files =
          Directory(globalTestPlaylistDir).listSync(
        recursive: false,
        followLinks: false,
      );

      expect(files.length, 3);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Playlist 2 short audio: playlist 2nd audio was already downloaded and 
           was deleted''', (WidgetTester tester) async {
      // necessary in case the previous test failed and so did not
      // delete the its playlist dir
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      // Copying the initial local playlist json file with no audio
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_download_2_small_videos_test",
        destinationRootPath: kApplicationPathWindowsTest,
      );

      AudioDownloadVM audioDownloadVM =
          await IntegrationTestUtil.launchIntegrTestAppEnablingInternetAccess(
        tester: tester,
        forcedLocale: const Locale('en'),
      );

      Playlist existingPlaylistBeforeNewDownload =
          audioDownloadVM.listOfPlaylist[0];

      // Verifying the data of the copied playlist before downloading
      // the playlist

      _checkDownloadedPlaylist(
        downloadedPlaylist: existingPlaylistBeforeNewDownload,
        playlistId: globalTestPlaylistOneAudioId,
        playlistTitle: globalTestPlaylistOneAudioTitle,
        playlistUrl: globalTestPlaylistUrl,
        playlistDir: globalTestPlaylistOneAudioDir,
        isPlaylistSelected: false,
      );

      List<Audio> downloadedAudioLstBeforeDownload =
          existingPlaylistBeforeNewDownload.downloadedAudioLst;
      List<Audio> playableAudioLstBeforeDownload =
          existingPlaylistBeforeNewDownload.playableAudioLst;

      expect(downloadedAudioLstBeforeDownload.length, 1);
      expect(playableAudioLstBeforeDownload.length, 1);

      // Checking the data of the audio contained in the downloaded
      // audio list
      _checkDownloadedAudioShortVideoTwo(
        downloadedAudioTwo: downloadedAudioLstBeforeDownload[0],
        audioTwoFileNamePrefix: existingAudioDateOnlyFileNamePrefix,
      );

      // Checking the data of the audio contained in the playable
      // audio list
      _checkDownloadedAudioShortVideoTwo(
        downloadedAudioTwo: playableAudioLstBeforeDownload[0],
        audioTwoFileNamePrefix: existingAudioDateOnlyFileNamePrefix,
      );

      // Now selecting the existing playlist by tapping on the
      // playlist checkbox
      await IntegrationTestUtil.selectPlaylist(
        tester: tester,
        playlistToSelectTitle: globalTestPlaylistOneAudioTitle,
      );

      // Now typing on the download playlist button to download the
      // new video audios present the recreated playlist.
      await tester.tap(find.byKey(const Key('download_sel_playlist_button')));
      await tester.pumpAndSettle();

      // Add a delay to allow the download to finish.
      for (int i = 0; i < 8; i++) {
        await Future.delayed(const Duration(seconds: 1));
        await tester.pumpAndSettle();
      }

      // expect(directory.existsSync(), true);

      // Verifying the data of the playlist after downloading it

      Playlist downloadedPlaylist = audioDownloadVM.listOfPlaylist[0];

      _checkDownloadedPlaylist(
        downloadedPlaylist: existingPlaylistBeforeNewDownload,
        playlistId: globalTestPlaylistOneAudioId,
        playlistTitle: globalTestPlaylistOneAudioTitle,
        playlistUrl: globalTestPlaylistUrl,
        playlistDir: globalTestPlaylistOneAudioDir,
        isPlaylistSelected: true,
      );

      // this check fails if the secondsDelay value is too small
      expect(audioDownloadVM.isAudioDownloading, false);

      expect(audioDownloadVM.audioDownloadProgress, 1.0);
      expect(audioDownloadVM.lastSecondAudioDownloadSpeed, 0);
      expect(audioDownloadVM.isHighQuality, false);

      // downloadedAudioLst contains added Audio's
      _checkPlaylistDownloadedAudios(
        downloadedAudioOne: downloadedPlaylist.downloadedAudioLst[1],
        downloadedAudioTwo: downloadedPlaylist.downloadedAudioLst[0],
        audioOneFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
        audioTwoFileNamePrefix: existingAudioDateOnlyFileNamePrefix,
      );

      // playableAudioLst contains Audio's inserted at list start
      _checkPlaylistDownloadedAudios(
        downloadedAudioOne: downloadedPlaylist.playableAudioLst[0],
        downloadedAudioTwo: downloadedPlaylist.playableAudioLst[1],
        audioOneFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
        audioTwoFileNamePrefix: existingAudioDateOnlyFileNamePrefix,
      );

      // Checking if there are 3 files in the directory (1 mp3 and 1 json)
      // final List<FileSystemEntity> files =
      //     directory.listSync(recursive: false, followLinks: false);

      // expect(files.length, 2);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group('Download short audio of 1 single video', () {
    testWidgets(
        '''Download single audio in spoken quality in local playlist containing no audio.
           Using integr test application.''', (WidgetTester tester) async {
      String emptyLocalTestPlaylistTitle = 'audio_learn_download_single_video';
      String localTestPlaylistDir =
          "$kApplicationPathWindowsTest${path.separator}$emptyLocalTestPlaylistTitle";

      final Directory directory = Directory(localTestPlaylistDir);

      // necessary in case the previous test failed and so did not
      // delete the its playlist dir
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      // Copying the initial local playlist json file with no audio
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_download_single_video_to_empty_local_playlist_test",
        destinationRootPath: kApplicationPathWindowsTest,
      );

      AudioDownloadVM audioDownloadVM =
          await IntegrationTestUtil.launchIntegrTestAppEnablingInternetAccess(
        tester: tester,
        forcedLocale: const Locale('en'),
      );

      String singleVideoUrl = 'https://youtu.be/uv3VQoWSjBE';

      // Entering the single video URL in the Youtube URL or search text field
      // of the app
      await tester.enterText(
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        singleVideoUrl,
      );
      await tester.pumpAndSettle();

      // Ensure the url text field contains the entered url
      TextField urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
      expect(urlTextField.controller!.text, singleVideoUrl);

      // Open the target playlist selection dialog by tapping the
      // download single video button
      await tester.tap(find.byKey(const Key('downloadSingleVideoButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check the value of the select one playlist AlertDialog
      // dialog title
      Text alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Select a Playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be downloaded

      Finder radioListTile = find
          .ancestor(
            of: find.text(emptyLocalTestPlaylistTitle),
            matching: find.byType(ListTile),
          )
          .last;

      // Tap the target playlist RadioListTile to select it
      await tester.tap(radioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Verify the displayed alert dialog
      await IntegrationTestUtil.verifyAlertDisplayAndCloseIt(
        tester: tester,
        alertDialogMessage:
            "Confirm target playlist \"$emptyLocalTestPlaylistTitle\" for downloading single video audio in spoken quality.",
      );

      // Add a delay to allow the download to finish.
      await Future.delayed(const Duration(seconds: secondsDelay));
      await tester.pumpAndSettle();

      Playlist singleVideoDownloadedPlaylist =
          audioDownloadVM.listOfPlaylist[0];

      _checkDownloadedPlaylist(
        downloadedPlaylist: singleVideoDownloadedPlaylist,
        playlistId: emptyLocalTestPlaylistTitle,
        playlistTitle: emptyLocalTestPlaylistTitle,
        playlistUrl: '',
        playlistDir: localTestPlaylistDir,
        isPlaylistSelected: true,
      );

      // this check fails if the secondsDelay value is too small
      expect(audioDownloadVM.isAudioDownloading, false);

      expect(audioDownloadVM.audioDownloadProgress, 1.0);
      expect(audioDownloadVM.lastSecondAudioDownloadSpeed, 0);
      expect(audioDownloadVM.isHighQuality, false);

      // Checking the data of the audio contained in the downloaded
      // audio list
      _checkDownloadedAudioShortVideoTwo(
        downloadedAudioTwo: singleVideoDownloadedPlaylist.downloadedAudioLst[0],
        audioTwoFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
      );

      // Checking if there are 2 files in the directory (1 mp3 and 1 json)
      final List<FileSystemEntity> files =
          directory.listSync(recursive: false, followLinks: false);

      expect(files.length, 2);

      // Checking if the playlist json file has been updated with the
      // downloaded audio data

      String playlistPathFileName =
          '$localTestPlaylistDir${path.separator}$emptyLocalTestPlaylistTitle.json';

      Playlist loadedPlaylist = JsonDataService.loadFromFile(
          jsonPathFileName: playlistPathFileName, type: Playlist);

      compareDeserializedWithOriginalPlaylist(
        deserializedPlaylist: loadedPlaylist,
        originalPlaylist: singleVideoDownloadedPlaylist,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Download single audio in music quality in local playlist containing no audio.
           Using integr test application.''', (WidgetTester tester) async {
      String emptyLocalTestPlaylistTitle = 'audio_learn_download_single_video';
      String localTestPlaylistDir =
          "$kApplicationPathWindowsTest${path.separator}$emptyLocalTestPlaylistTitle";

      final Directory directory = Directory(localTestPlaylistDir);

      // necessary in case the previous test failed and so did not
      // delete the its playlist dir
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      // Copying the initial local playlist json file with no audio
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_download_single_video_to_empty_local_playlist_test",
        destinationRootPath: kApplicationPathWindowsTest,
      );

      AudioDownloadVM audioDownloadVM =
          await IntegrationTestUtil.launchIntegrTestAppEnablingInternetAccess(
        tester: tester,
        forcedLocale: const Locale('en'),
      );

      String singleVideoUrl = 'https://youtu.be/uv3VQoWSjBE';

      // Entering the single video URL in the Youtube URL or search text field
      // of the app
      await tester.enterText(
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        singleVideoUrl,
      );
      await tester.pumpAndSettle();

      // Ensure the url text field contains the entered url
      TextField urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
      expect(urlTextField.controller!.text, singleVideoUrl);

      // Open the target playlist selection dialog by tapping the
      // download single video button
      await tester.tap(find.byKey(const Key('downloadSingleVideoButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check the value of the select one playlist AlertDialog
      // dialog title
      Text alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Select a Playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be downloaded

      Finder radioListTile = find
          .ancestor(
            of: find.text(emptyLocalTestPlaylistTitle),
            matching: find.byType(ListTile),
          )
          .last;

      // Tap the target playlist RadioListTile to select it
      await tester.tap(radioListTile);
      await tester.pumpAndSettle();

      // Tap the music quality checkbox to select it
      await tester.tap(find.byKey(
          const Key('downloadSingleVideoAudioAtMusicQualityCheckboxKey')));
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Verify the displayed alert dialog
      await IntegrationTestUtil.verifyAlertDisplayAndCloseIt(
        tester: tester,
        alertDialogMessage:
            "Confirm target playlist \"$emptyLocalTestPlaylistTitle\" for downloading single video audio in high-quality music format.",
      );

      // Add a delay to allow the download to finish.
      await Future.delayed(const Duration(seconds: secondsDelay));
      await tester.pumpAndSettle();

      Playlist singleVideoDownloadedPlaylist =
          audioDownloadVM.listOfPlaylist[0];

      _checkDownloadedPlaylist(
        downloadedPlaylist: singleVideoDownloadedPlaylist,
        playlistId: emptyLocalTestPlaylistTitle,
        playlistTitle: emptyLocalTestPlaylistTitle,
        playlistUrl: '',
        playlistDir: localTestPlaylistDir,
        isPlaylistSelected: true,
      );

      // this check fails if the secondsDelay value is too small
      expect(audioDownloadVM.isAudioDownloading, false);

      expect(audioDownloadVM.audioDownloadProgress, 1.0);
      expect(audioDownloadVM.lastSecondAudioDownloadSpeed, 0);
      expect(audioDownloadVM.isHighQuality, true);

      // Checking the data of the audio contained in the downloaded
      // audio list
      _checkDownloadedAudioShortVideoTwo(
        downloadedAudioTwo: singleVideoDownloadedPlaylist.downloadedAudioLst[0],
        audioTwoFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
        downloadedAtMusicQuality: true,
      );

      // Checking if there are 2 files in the directory (1 mp3 and 1 json)
      final List<FileSystemEntity> files =
          directory.listSync(recursive: false, followLinks: false);

      expect(files.length, 2);

      // Checking if the playlist json file has been updated with the
      // downloaded audio data

      String playlistPathFileName =
          '$localTestPlaylistDir${path.separator}$emptyLocalTestPlaylistTitle.json';

      Playlist loadedPlaylist = JsonDataService.loadFromFile(
          jsonPathFileName: playlistPathFileName, type: Playlist);

      compareDeserializedWithOriginalPlaylist(
        deserializedPlaylist: loadedPlaylist,
        originalPlaylist: singleVideoDownloadedPlaylist,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Download single audio in spoken quality in local playlist containing one audio.
           Using integr test application.''', (WidgetTester tester) async {
      String localTestPlaylistTitle =
          'audio_learn_download_single_video_to_not_empty_local_playlist_test';
      String localTestPlaylistsPlaylistDir =
          "$kApplicationPathWindowsTest${path.separator}playlists${path.separator}$localTestPlaylistTitle";

      final Directory directory = Directory(localTestPlaylistsPlaylistDir);

      // necessary in case the previous test failed and so did not
      // delete the its playlist dir
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      // Copying the initial local playlist json file with no audio
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_download_single_video_to_not_empty_local_pl_test",
        destinationRootPath: kApplicationPathWindowsTest,
      );

      AudioDownloadVM audioDownloadVM =
          await IntegrationTestUtil.launchIntegrTestAppEnablingInternetAccess(
        tester: tester,
        forcedLocale: const Locale('en'),
      );

      String singleVideoUrl = 'https://youtu.be/uv3VQoWSjBE';

      // Entering the single video URL in the Youtube URL or search text field
      // of the app
      await tester.enterText(
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        singleVideoUrl,
      );
      await tester.pumpAndSettle();

      // Ensure the url text field contains the entered url
      TextField urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
      expect(urlTextField.controller!.text, singleVideoUrl);

      // Open the target playlist selection dialog by tapping the
      // download single video button
      await tester.tap(find.byKey(const Key('downloadSingleVideoButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check the value of the select one playlist AlertDialog
      // dialog title
      Text alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Select a Playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be downloaded

      Finder radioListTile = find
          .ancestor(
            of: find.text(localTestPlaylistTitle),
            matching: find.byType(ListTile),
          )
          .last;

      // Tap the target playlist RadioListTile to select it
      await tester.tap(radioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now find the ok button of the confirm warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('okButtonKey')));
      await tester.pumpAndSettle();

      // Add a delay to allow the download to finish.
      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(seconds: 1));
        await tester.pumpAndSettle();
      }

      Playlist singleVideoDownloadedPlaylist =
          audioDownloadVM.listOfPlaylist[0];

      _checkDownloadedPlaylist(
        downloadedPlaylist: singleVideoDownloadedPlaylist,
        playlistId: localTestPlaylistTitle,
        playlistTitle: localTestPlaylistTitle,
        playlistUrl: '',
        playlistDir: localTestPlaylistsPlaylistDir,
        isPlaylistSelected: false,
      );

      // this check fails if the secondsDelay value is too small
      expect(audioDownloadVM.isAudioDownloading, false);

      expect(audioDownloadVM.audioDownloadProgress, 1.0);
      expect(audioDownloadVM.lastSecondAudioDownloadSpeed, 0);
      expect(audioDownloadVM.isHighQuality, false);

      // Checking the data of the audio contained in the downloaded
      // audio list
      _checkDownloadedAudioShortVideoTwo(
        downloadedAudioTwo: singleVideoDownloadedPlaylist.downloadedAudioLst[1],
        audioTwoFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
      );

      // Checking the data of the audio contained in the playable
      // audio list
      _checkDownloadedAudioShortVideoTwo(
        downloadedAudioTwo: singleVideoDownloadedPlaylist.playableAudioLst[0],
        audioTwoFileNamePrefix: todayDownloadDateOnlyFileNamePrefix,
      );

      // Checking if there are 3 files in the directory (2 mp3 and 1 json)
      final List<FileSystemEntity> files =
          directory.listSync(recursive: false, followLinks: false);
      expect(files.length, 3);

      // Checking if the playlist json file has been updated with the
      // downloaded audio data

      String playlistPathFileName =
          '$localTestPlaylistsPlaylistDir${path.separator}$localTestPlaylistTitle.json';

      Playlist loadedPlaylist = JsonDataService.loadFromFile(
          jsonPathFileName: playlistPathFileName, type: Playlist);

      compareDeserializedWithOriginalPlaylist(
        deserializedPlaylist: loadedPlaylist,
        originalPlaylist: singleVideoDownloadedPlaylist,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group('''Download recreated playlist with short audio. Those tests are used to
           test recreating the playlist with the same name. Recreating a playlist
           with an identical name avoids to loose time removing from the original
           playlist the referenced videos. The recreated playlist audios are
           downloaded in the same dir than the original playlist. The original
           playlist json file is updated with the recreated playlist id and url
           as well as with the newly downloaded audio.''', () {
    testWidgets(
        '''Adding recreated playlist with 2 new short audio: the initial playlist
           has 1st and 2nd audios already downloaded.''',
        (WidgetTester tester) async {
      // Necessary in case the previous test failed and so did not
      // delete the its playlist dir
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_download_recreate_test",
        destinationRootPath: kApplicationPathWindowsTest,
      );

      AudioDownloadVM audioDownloadVM =
          await IntegrationTestUtil.launchIntegrTestAppEnablingInternetAccess(
        tester: tester,
        forcedLocale: const Locale('en'),
      );

      const String recreatedPlaylistUrl =
          'https://youtube.com/playlist?list=PLzwWSJNcZTMSwrDOAZEPf0u6YvrKGNnvC';
      const String recreatedPlaylistId = 'PLzwWSJNcZTMSwrDOAZEPf0u6YvrKGNnvC';

      // Playlist must be copied since recreating the playlist modifies
      // the original playlist.
      Playlist playlistBeforeRecreatedCopy =
          audioDownloadVM.listOfPlaylist[0].copy();

      // Entering the recreated playlist URL in the Youtube URL or search
      // text field of the app
      await tester.enterText(
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        recreatedPlaylistUrl,
      );
      await tester.pumpAndSettle();

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Confirm the addition by tapping the 'Add' button in
      // the AlertDialog and then on the 'OK' button of the
      // confirm dialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "Youtube playlist \"${playlistBeforeRecreatedCopy.title}\" URL was updated. The playlist can be downloaded with its new URL.",
      );

      Playlist recreatedPlaylist = audioDownloadVM.listOfPlaylist[0];

      // Now tap on the delete button to empty the search text
      // field. The reason is due to using debounce in the
      // YoutubeUrlOrSearchTextField widget. If the text field is not
      // emptied, it avoids that the Youtube playlist addition warning
      // dialog is shown twice when the 'Add playlist button' button is
      // tapped.
      await tester.tap(
        find.byKey(
          const Key('clearPlaylistUrlOrSearchButtonKey'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<TextField>(find.byKey(
              const Key('youtubeUrlOrSearchTextField'),
            ))
            .controller!
            .text,
        '', // 'Youtube Link or Search' displayed in the TextField
        //     is a hint text and not the actual text !
      );

      // Now typing on the download playlist button to download the
      // new video audios present the recreated playlist.
      await tester.tap(find.byKey(const Key('download_sel_playlist_button')));
      await tester.pumpAndSettle();

      // Add a delay to allow the download to finish.
      for (int i = 0; i < 7; i++) {
        await Future.delayed(const Duration(seconds: 2));
        await tester.pumpAndSettle();
      }

      List<String>
          audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
        "morning _ cinematic video",
        "Really short video",
        "audio learn test short video two",
        "audio learn test short video one",
      ];

      IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
        tester: tester,
        audioOrPlaylistTitlesOrderedLst:
            audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        firstAudioListTileIndex: 1,
      );

      _compareNewRecreatedPlaylistToPreviouslyExistingPlaylist(
        newRecreatedPlaylistWithSameTitle: recreatedPlaylist,
        previouslyExistingPlaylist: playlistBeforeRecreatedCopy,
        newRecreatedPlaylistWithSameTitleId: recreatedPlaylistId,
        newRecreatedPlaylistWithSameTitleUrl: recreatedPlaylistUrl,
        newDownloadedAudioNumber: 2,
      );

      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Adding recreated playlist with 2 new short audio. In the initial playlist,
           the 1st audio was deleted from playlist as well, the 2nd audio was simply
           deleted. None of the deleted audios will be redownloadable since they are
           not in the recreated playlist.''', (WidgetTester tester) async {
      // Necessary in case the previous test failed and so did not
      // delete the its playlist dir
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_download_recreate_audio_deleted_test",
        destinationRootPath: kApplicationPathWindowsTest,
      );

      AudioDownloadVM audioDownloadVM =
          await IntegrationTestUtil.launchIntegrTestAppEnablingInternetAccess(
        tester: tester,
        forcedLocale: const Locale('en'),
      );

      const String recreatedPlaylistUrl =
          'https://youtube.com/playlist?list=PLzwWSJNcZTMSwrDOAZEPf0u6YvrKGNnvC';
      const String recreatedPlaylistId = 'PLzwWSJNcZTMSwrDOAZEPf0u6YvrKGNnvC';

      // Playlist must be copied since recreating the playlist modifies
      // the original playlist.
      Playlist playlistBeforeRecreatedCopy =
          audioDownloadVM.listOfPlaylist[0].copy();

      // Entering the recreated playlist URL in the Youtube URL or search
      // text field of the app
      await tester.enterText(
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        recreatedPlaylistUrl,
      );
      await tester.pumpAndSettle();

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Confirm the addition by tapping the 'Add' button in
      // the AlertDialog and then on the 'OK' button of the
      // confirm dialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "Youtube playlist \"${playlistBeforeRecreatedCopy.title}\" URL was updated. The playlist can be downloaded with its new URL.",
      );

      // Now tap on the delete button to empty the search text
      // field. The reason is due to using debounce in the
      // YoutubeUrlOrSearchTextField widget. If the text field is not
      // emptied, it avoids that the Youtube playlist addition warning
      // dialog is shown twice when the 'Add playlist button' button is
      // tapped.
      await tester.tap(
        find.byKey(
          const Key('clearPlaylistUrlOrSearchButtonKey'),
        ),
      );
      await tester.pumpAndSettle();

      Playlist recreatedPlaylist = audioDownloadVM.listOfPlaylist[0];

      expect(
        tester
            .widget<TextField>(find.byKey(
              const Key('youtubeUrlOrSearchTextField'),
            ))
            .controller!
            .text,
        '', // 'Youtube Link or Search' displayed in the TextField
        //     is a hint text and not the actual text !
      );

      // Now typing on the download playlist button to download the
      // new video audios present the recreated playlist.
      await tester.tap(find.byKey(const Key('download_sel_playlist_button')));
      await tester.pumpAndSettle();

      // Add a delay to allow the download to finish.
      for (int i = 0; i < 7; i++) {
        await Future.delayed(const Duration(seconds: 2));
        await tester.pumpAndSettle();
      }

      List<String>
          audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
        "morning _ cinematic video",
        "Really short video",
      ];

      IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
        tester: tester,
        audioOrPlaylistTitlesOrderedLst:
            audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        firstAudioListTileIndex: 1,
      );

      _compareNewRecreatedPlaylistToPreviouslyExistingPlaylist(
        newRecreatedPlaylistWithSameTitle: recreatedPlaylist,
        previouslyExistingPlaylist: playlistBeforeRecreatedCopy,
        newRecreatedPlaylistWithSameTitleId: recreatedPlaylistId,
        newRecreatedPlaylistWithSameTitleUrl: recreatedPlaylistUrl,
        newDownloadedAudioNumber: 2,
      );

      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group(
      '''Add Youtube playlist with corrected title. If the added playlist contains
        invalid characters like '/' or ':' or '\\', the playlist is added to the application with a
        corrected title.''', () {
    testWidgets('''Adding playlist in spoken quality with '/' invalid title.''',
        (WidgetTester tester) async {
      // necessary in case the previous test failed and so did not
      // delete the its playlist dir
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      // Copying the initial local playlist json file with no audio
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_newly_downloaded_playlist_test",
        destinationRootPath: kApplicationPathWindowsTest,
      );

      await IntegrationTestUtil.launchIntegrTestAppEnablingInternetAccess(
        tester: tester,
        forcedLocale: const Locale('en'),
      );

      // Entering the created playlist URL in the Youtube URL or search
      // text field of the app
      var incorrectlyTitledPlaylistUrl =
          'https://youtube.com/playlist?list=PL0bW68uqNc07LhkwdJAbF0AyIGnD2Aeq5&si=f_VccuyNuNLvE-ot';

      await tester.enterText(
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        incorrectlyTitledPlaylistUrl,
      );
      await tester.pumpAndSettle();

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Check the value of the AlertDialog dialog title
      Text alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Youtube Playlist');

      // Check the value of the AlertDialog url Text
      Text confirmUrlText =
          tester.widget(find.byKey(const Key('playlistUrlConfirmDialogText')));
      expect(confirmUrlText.data, incorrectlyTitledPlaylistUrl);

      // Confirm the addition by tapping the 'Add' button in
      // the AlertDialog and then on the 'OK' button of the
      // confirm dialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Add a delay to allow the update playlist URL to finish. 1
      // second is ok
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify the displayed warning dialog
      await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "Youtube playlist \"le meilleur chant de canari/chant canari male\" of spoken quality added with corrected title \"le meilleur chant de canari-chant canari male\" at the end of the playlist list.",
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('''Adding playlist in music quality with '/' invalid title.''',
        (WidgetTester tester) async {
      // necessary in case the previous test failed and so did not
      // delete the its playlist dir
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      // Copying the initial local playlist json file with no audio
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_newly_downloaded_playlist_test",
        destinationRootPath: kApplicationPathWindowsTest,
      );

      await IntegrationTestUtil.launchIntegrTestAppEnablingInternetAccess(
        tester: tester,
        forcedLocale: const Locale('en'),
      );

      // Entering the created playlist URL in the Youtube URL or search
      // text field of the app
      var incorrectlyTitledPlaylistUrl =
          'https://youtube.com/playlist?list=PL0bW68uqNc07LhkwdJAbF0AyIGnD2Aeq5&si=f_VccuyNuNLvE-ot';

      await tester.enterText(
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        incorrectlyTitledPlaylistUrl,
      );
      await tester.pumpAndSettle();

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Check the value of the AlertDialog dialog title
      Text alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Youtube Playlist');

      // Check the value of the AlertDialog url Text
      Text confirmUrlText =
          tester.widget(find.byKey(const Key('playlistUrlConfirmDialogText')));
      expect(confirmUrlText.data, incorrectlyTitledPlaylistUrl);

      // Set the music quality checkbox to true
      await tester
          .tap(find.byKey(const Key('playlistQualityConfirmDialogCheckBox')));
      await tester.pumpAndSettle();

      // Confirm the addition by tapping the 'Add' button in
      // the AlertDialog and then on the 'OK' button of the
      // confirm dialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Add a delay to allow the update playlist URL to finish. 1
      // second is ok
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify the displayed warning dialog
      await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "Youtube playlist \"le meilleur chant de canari/chant canari male\" of musical quality added with corrected title \"le meilleur chant de canari-chant canari male\" at the end of the playlist list.",
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('''Adding playlist in spoken quality with ':' invalid title.''',
        (WidgetTester tester) async {
      // necessary in case the previous test failed and so did not
      // delete the its playlist dir
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      // Copying the initial local playlist json file with no audio
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_newly_downloaded_playlist_test",
        destinationRootPath: kApplicationPathWindowsTest,
      );

      await IntegrationTestUtil.launchIntegrTestAppEnablingInternetAccess(
        tester: tester,
        forcedLocale: const Locale('en'),
      );

      // Entering the created playlist URL in the Youtube URL or search
      // text field of the app
      var incorrectlyTitledPlaylistUrl =
          'https://youtube.com/playlist?list=PLzwWSJNcZTMQy36Kt_F4-PBLZwe2mW5q6&si=2rdAEukq4v9fln7_';

      await tester.enterText(
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        incorrectlyTitledPlaylistUrl,
      );
      await tester.pumpAndSettle();

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Check the value of the AlertDialog dialog title
      Text alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Youtube Playlist');

      // Check the value of the AlertDialog url Text
      Text confirmUrlText =
          tester.widget(find.byKey(const Key('playlistUrlConfirmDialogText')));
      expect(confirmUrlText.data, incorrectlyTitledPlaylistUrl);

      // Confirm the addition by tapping the 'Add' button in
      // the AlertDialog and then on the 'OK' button of the
      // confirm dialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Add a delay to allow the update playlist URL to finish. 1
      // second is ok
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify the displayed warning dialog
      await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "Youtube playlist \"testing : invalid playlist title with double point\" of spoken quality added with corrected title \"testing - invalid playlist title with double point\" at the end of the playlist list.",
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Adding playlist in spoken quality with backward invalid char.''',
        (WidgetTester tester) async {
      // necessary in case the previous test failed and so did not
      // delete the its playlist dir
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      // Copying the initial local playlist json file with no audio
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_newly_downloaded_playlist_test",
        destinationRootPath: kApplicationPathWindowsTest,
      );

      await IntegrationTestUtil.launchIntegrTestAppEnablingInternetAccess(
        tester: tester,
        forcedLocale: const Locale('en'),
      );

      // Entering the created playlist URL in the Youtube URL or search
      // text field of the app
      var incorrectlyTitledPlaylistUrl =
          'https://youtube.com/playlist?list=PLzwWSJNcZTMQmmmdj-ia-TTk0OynuRFXL&si=-UJfTojBi0HbYkbC';

      await tester.enterText(
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        incorrectlyTitledPlaylistUrl,
      );
      await tester.pumpAndSettle();

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Check the value of the AlertDialog dialog title
      Text alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Youtube Playlist');

      // Check the value of the AlertDialog url Text
      Text confirmUrlText =
          tester.widget(find.byKey(const Key('playlistUrlConfirmDialogText')));
      expect(confirmUrlText.data, incorrectlyTitledPlaylistUrl);

      // Confirm the addition by tapping the 'Add' button in
      // the AlertDialog and then on the 'OK' button of the
      // confirm dialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Add a delay to allow the update playlist URL to finish. 1
      // second is ok
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify the displayed warning dialog
      await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "Youtube playlist \"testing invalid \\ playlist title with backward invalid character\" of spoken quality added with corrected title \"testing invalid - playlist title with backward invalid character\" at the end of the playlist list.",
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Adding playlist in spoken quality with three invalid chars ':', '/' and "\\".''',
        (WidgetTester tester) async {
      // necessary in case the previous test failed and so did not
      // delete the its playlist dir
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      // Copying the initial local playlist json file with no audio
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_newly_downloaded_playlist_test",
        destinationRootPath: kApplicationPathWindowsTest,
      );

      await IntegrationTestUtil.launchIntegrTestAppEnablingInternetAccess(
        tester: tester,
        forcedLocale: const Locale('en'),
      );

      // Entering the created playlist URL in the Youtube URL or search
      // text field of the app
      var incorrectlyTitledPlaylistUrl =
          'https://youtube.com/playlist?list=PLzwWSJNcZTMT8bvRagR7WnfAWejWEvYkJ&si=wKpVonHg_PJKJWyY';

      await tester.enterText(
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        incorrectlyTitledPlaylistUrl,
      );
      await tester.pumpAndSettle();

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Check the value of the AlertDialog dialog title
      Text alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Youtube Playlist');

      // Check the value of the AlertDialog url Text
      Text confirmUrlText =
          tester.widget(find.byKey(const Key('playlistUrlConfirmDialogText')));
      expect(confirmUrlText.data, incorrectlyTitledPlaylistUrl);

      // Confirm the addition by tapping the 'Add' button in
      // the AlertDialog and then on the 'OK' button of the
      // confirm dialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Add a delay to allow the update playlist URL to finish. 1
      // second is ok
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify the displayed warning dialog
      await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "Youtube playlist \"Restore: short / test \\ playlist\" of spoken quality added with corrected title \"Restore- short - test - playlist\" at the end of the playlist list.",
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
}

void _checkDownloadedPlaylist({
  required Playlist downloadedPlaylist,
  required String playlistId,
  required String playlistTitle,
  required String playlistUrl,
  required String playlistDir,
  required isPlaylistSelected,
  bool isPlaylistAtVoiceQuality = true,
}) {
  expect(downloadedPlaylist.id, playlistId);
  expect(downloadedPlaylist.title, playlistTitle);
  expect(downloadedPlaylist.url, playlistUrl);
  expect(downloadedPlaylist.downloadPath, playlistDir);
  expect(
      downloadedPlaylist.playlistQuality,
      (isPlaylistAtVoiceQuality)
          ? PlaylistQuality.voice
          : PlaylistQuality.music);
  expect(downloadedPlaylist.playlistType,
      (playlistUrl.isNotEmpty) ? PlaylistType.youtube : PlaylistType.local);
  expect(downloadedPlaylist.isSelected, isPlaylistSelected);
}

// Verify the values of the Audio's extracted from a playlist
void _checkPlaylistDownloadedAudios({
  required Audio downloadedAudioOne,
  required Audio downloadedAudioTwo,
  required String audioOneFileNamePrefix,
  required String audioTwoFileNamePrefix,
  bool downloadedAtMusicQuality = false,
}) {
  _checkDownloadedAudioShortVideoOne(
    downloadedAudioOne: downloadedAudioOne,
    audioOneFileNamePrefix: audioOneFileNamePrefix,
    downloadedAtMusicQuality: downloadedAtMusicQuality,
  );

  _checkDownloadedAudioShortVideoTwo(
    downloadedAudioTwo: downloadedAudioTwo,
    audioTwoFileNamePrefix: audioTwoFileNamePrefix,
    downloadedAtMusicQuality: downloadedAtMusicQuality,
  );
}

void _compareNewRecreatedPlaylistToPreviouslyExistingPlaylist({
  required Playlist newRecreatedPlaylistWithSameTitle,
  required Playlist previouslyExistingPlaylist,
  required String newRecreatedPlaylistWithSameTitleId,
  required String newRecreatedPlaylistWithSameTitleUrl,
  required int newDownloadedAudioNumber,
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
  expect(newRecreatedPlaylistWithSameTitle.playlistQuality,
      previouslyExistingPlaylist.playlistQuality);
  expect(newRecreatedPlaylistWithSameTitle.isSelected,
      previouslyExistingPlaylist.isSelected);

  expect(
      newRecreatedPlaylistWithSameTitle.downloadedAudioLst.length,
      previouslyExistingPlaylist.downloadedAudioLst.length +
          newDownloadedAudioNumber);
  expect(
      newRecreatedPlaylistWithSameTitle.playableAudioLst.length,
      previouslyExistingPlaylist.playableAudioLst.length +
          newDownloadedAudioNumber);
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
void _checkDownloadedAudioShortVideoOne({
  required Audio downloadedAudioOne,
  required String audioOneFileNamePrefix,
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
  expect(downloadedAudioOne.audioPlaySpeed, 1.0);
  expect(downloadedAudioOne.isAudioMusicQuality, downloadedAtMusicQuality);

  String firstAudioFileName = downloadedAudioOne.audioFileName;
  expect(
      firstAudioFileName.contains(audioOneFileNamePrefix) &&
          firstAudioFileName
              .contains('audio learn test short video one 23-06-10.mp3'),
      true);
}

/// Verify the values of the "audio learn test short video two" downloaded
/// audio.
void _checkDownloadedAudioShortVideoTwo({
  required Audio downloadedAudioTwo,
  required String audioTwoFileNamePrefix,
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
  expect(downloadedAudioTwo.audioPlaySpeed, 1.0);
  expect(downloadedAudioTwo.isAudioMusicQuality, downloadedAtMusicQuality);

  String secondAudioFileName = downloadedAudioTwo.audioFileName;
  expect(
      secondAudioFileName.contains(audioTwoFileNamePrefix) &&
          secondAudioFileName
              .contains('audio learn test short video two 23-06-10.mp3'),
      true);
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
  expect(downloadedAudioOne.audioDuration, const Duration(milliseconds: 9891));
  expect(downloadedAudioOne.audioPlaySpeed, 1.0);

  String firstNewAudioFileName = downloadedAudioOne.audioFileName;
  expect(
      firstNewAudioFileName.contains(todayDownloadDateOnlyFileNamePrefix) &&
          firstNewAudioFileName.contains('Really short video 23-07-01.mp3'),
      true);

  expect(downloadedAudioOne.audioFileSize, 61288);
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
  expect(downloadedAudioTwo.audioDuration, const Duration(milliseconds: 58978));
  expect(downloadedAudioTwo.audioPlaySpeed, 1.0);

  String secondNewAudioFileName = downloadedAudioTwo.audioFileName;
  expect(
      secondNewAudioFileName.contains(todayDownloadDateOnlyFileNamePrefix) &&
          secondNewAudioFileName
              .contains('morning _ cinematic video 23-07-01.mp3'),
      true);

  expect(downloadedAudioTwo.audioFileSize, 360849);
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
              onPressed: () async {
                await Provider.of<AudioDownloadVM>(context, listen: false)
                    .downloadPlaylistAudio(
                  playlistUrl: _urlController.text,
                );
              },
              child: const Text('Download Playlist Audio'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              key: const Key('downloadSingleVideoAudioButton'),
              onPressed: () async {
                AudioDownloadVM audioDownloadVM =
                    Provider.of<AudioDownloadVM>(context, listen: false);

                // the downloaded audio will be added to the unique playlist
                // located in the test audio directory
                await audioDownloadVM.downloadSingleVideoAudio(
                  videoUrl: _urlController.text,
                  singleVideoTargetPlaylist: audioDownloadVM.listOfPlaylist[0],
                );
              },
              child: const Text('Download Single Video Audio'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              key: const Key('downloadSingleVideoAudioInAudioQualityButton'),
              onPressed: () async {
                AudioDownloadVM audioDownloadVM =
                    Provider.of<AudioDownloadVM>(context, listen: false);

                // the downloaded audio will be added to the unique playlist
                // located in the test audio directory
                await audioDownloadVM.downloadSingleVideoAudio(
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
              onPressed: () async {
                AudioDownloadVM audioDownloadVM =
                    Provider.of<AudioDownloadVM>(context, listen: false);

                // the downloaded audio will be added to the unique playlist
                // located in the test audio directory
                await audioDownloadVM.downloadSingleVideoAudio(
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

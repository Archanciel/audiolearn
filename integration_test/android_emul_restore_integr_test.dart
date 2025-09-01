import 'dart:convert';
import 'dart:io';

import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/audio_player_vm.dart';
import 'package:audiolearn/viewmodels/comment_vm.dart';
import 'package:audiolearn/viewmodels/date_format_vm.dart';
import 'package:audiolearn/viewmodels/picture_vm.dart';
import 'package:audiolearn/viewmodels/playlist_list_vm.dart';
import 'package:audiolearn/viewmodels/warning_message_vm.dart';
import 'package:audiolearn/views/widgets/confirm_action_dialog.dart';
import 'package:audiolearn/views/widgets/playlist_comment_list_dialog.dart';
import 'package:audiolearn/views/widgets/set_value_to_target_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/services/json_data_service.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/viewmodels/mock_audio_download_vm.dart';
import 'integration_test_util.dart';
import 'mock_file_picker.dart';

void main() {
  // Necessary to avoid FatalFailureException (FatalFailureException: Failed
  // to perform an HTTP request to YouTube due to a fatal failure. In most
  // cases, this error indicates that YouTube most likely changed something,
  // which broke the library.
  // If this issue persists, please report it on the project's GitHub page.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const String androidPathSeparator = '/';

  group(
      '''ONLY WORKS ON FLUTTER EMULATOR, NOT ON START MEDIUM PHONE EMULATOR. REASON: EMULATOR SIZE !
          RUN setup_test.bat IN ORDER TO COPY THE CONTENT OF restore_existing_playlists_with_new_
          audios_android_emulator.zip to kApplicationPathAndroidTest = "/storage/emulated/0/Documents
          /test/audiolearn".

          On not empty app dir where a playlist is selected, restore Windows zip in which playlist(s)
          corresponding to existing playlist(s) contain additional audio's to which comments and pictures
          are associated. This situation happens if the AudioLearn application exists on two different
          engines and the user wants to restore the playlists, comments and pictures from one computer
          to another in order to add to the target pc or smartphone the audio's downloaded on the source
          engine. The audio mp3 files are not added since they are not in the zip file. But the Audio
          objects are added to the existing playlist and so can be redownloaded if needed.''',
      () {
    group('''From Windows zip.''', () {
      testWidgets(
          '''Unique playlist restore, not replace existing playlist. Restore unique playlist Windows zip
            containing 'S8 audio' playlist to Android application which contains 'S8 audio' and 'local'
            playlists. The restored 'S8 audio' playlist contains additional audio's to which comments and
            pictures are associated.''', (tester) async {
        await IntegrationTestUtil.initializeAndroidApplicationAndSelectPlaylist(
          tester: tester,
          tapOnPlaylistToggleButton: false,
        );

        // Now initializing the application on the Android emulator using
        // zip restoration.

        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        String restorableZipFileName = 'audioLearn_app_initialization.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 5802),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            'urgent_actus_17-12-2023',
          ],
        );

        Finder okButtonFinder = find.byKey(const Key('warningDialogOkButton'));

        if (okButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(okButtonFinder.last);
          await tester.pumpAndSettle();
        }

        restorableZipFileName = 'Windows S8 audio.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 162667),
        ]);

        // Now, test execution.
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
        );

        // Must be used on Android emulator, otherwise the confirmation
        // dialog is not displayed and can not be verifyed !
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        String restorableZipFilePathName =
            '/storage/emulated/0/Documents/test/audiolearn/$restorableZipFileName';

        // Verify the displayed warning confirmation dialog
        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              'Restored 0 playlist saved individually, 2 comment and 2 picture JSON files as well as 2 audio reference(s) and 0 added plus 0 modified comment(s) from "$restorableZipFilePathName".\n\nRestored also 2 picture JPG file(s) in the application pictures directory.',
          isWarningConfirming: true,
          warningTitle: 'CONFIRMATION',
        );

        // Verifying the existing restored playlist
        // list as well as the selected playlist 'Prières du
        // Maître' displayed audio titles and subtitles.

        List<String> playlistsTitles = [
          "S8 audio",
          "local",
        ];

        List<String> audioTitles = [
          "Quand Aurélien Barrau va dans une école de management",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        List<String> audioSubTitles = [
          "0:17:59.0 6.58 MB at 1.37 MB/sec on 23/06/2025 at 06:55",
          "0:06:29.0 2.37 MB at 1.69 MB/sec on 01/07/2024 at 16:35",
          "0:07:38.0 2.79 MB at 2.73 MB/sec on 07/01/2024 at 16:36",
        ];

        _verifyRestoredPlaylistAndAudio(
          tester: tester,
          selectedPlaylistTitle: 'S8 audio',
          playlistsTitles: playlistsTitles,
          audioTitles: audioTitles,
          audioSubTitles: audioSubTitles,
        );

        // Verify the content of the 'S8 audio' playlist dir
        // + comments + pictures dir after restoration.
        IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
          playlistTitle: 'S8 audio',
          expectedAudioFiles: [], // empty since all playlists were deleted by
          // the first IntegrationTestUtil.executeRestorePlaylists executio
          expectedCommentFiles: [
            "240701-163607-La surpopulation mondiale par Jancovici et Barrau 23-12-03.json",
            "250623-065532-Quand Aurélien Barrau va dans une école de management 23-09-10.json",
            "Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'.json",
          ],
          expectedPictureFiles: [
            "250623-065532-Quand Aurélien Barrau va dans une école de management 23-09-10.json",
            "Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'.json"
          ],
          doesPictureAudioMapFileNameExist: true,
          pictureFileNameOne: 'Barrau.jpg',
          audioForPictureTitleOneLst: [
            "S8 audio|250623-065532-Quand Aurélien Barrau va dans une école de management 23-09-10"
          ],
          pictureFileNameTwo: 'Jésus, mon amour.jpg',
          audioForPictureTitleTwoLst: [
            "S8 audio|Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'"
          ],
        );
      });
      testWidgets(
          '''Multiple playlist restore, not replace existing playlists. Restore multiple playlists Windows
             zip containing 'S8 audio' and 'local' playlists to Android application which contain 'S8 audio'
             and 'local' playlists. The restored 'S8 audio' and 'local' playlists contains additional audio's
             to which comments and pictures are associated.''', (tester) async {
        await IntegrationTestUtil.initializeAndroidApplicationAndSelectPlaylist(
          tester: tester,
          tapOnPlaylistToggleButton: false,
        );

        // Now initializing the application on the Android emulator using
        // zip restoration.

        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        String restorableZipFileName = 'audioLearn_app_initialization.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 5802),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            'urgent_actus_17-12-2023',
          ],
        );

        Finder okButtonFinder = find.byKey(const Key('warningDialogOkButton'));

        if (okButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(okButtonFinder.last);
          await tester.pumpAndSettle();
        }

        restorableZipFileName =
            'Windows 2 existing playlists with new audios.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 162667),
        ]);

        // Now, test execution.
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
        );

        // Must be used on Android emulator, otherwise the confirmation
        // dialog is not displayed and can not be verifyed !
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        String restorableZipFilePathName =
            '/storage/emulated/0/Documents/test/audiolearn/$restorableZipFileName';

        // Verify the displayed warning confirmation dialog
        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              'Restored 0 playlist, 3 comment and 3 picture JSON files as well as 4 audio reference(s) and 0 added plus 0 modified comment(s) and the application settings from "$restorableZipFilePathName".',
          isWarningConfirming: true,
          warningTitle: 'CONFIRMATION',
        );

        // Verifying the existing restored playlist
        // list as well as the selected playlist 'Prières du
        // Maître' displayed audio titles and subtitles.

        List<String> playlistsTitles = [
          "S8 audio",
          "local",
        ];

        List<String> audioTitles = [
          "Quand Aurélien Barrau va dans une école de management",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        List<String> audioSubTitles = [
          "0:17:59.0 6.58 MB at 1.37 MB/sec on 23/06/2025 at 06:55",
          "0:06:29.0 2.37 MB at 1.69 MB/sec on 01/07/2024 at 16:35",
          "0:07:38.0 2.79 MB at 2.73 MB/sec on 07/01/2024 at 16:36",
        ];

        _verifyRestoredPlaylistAndAudio(
          tester: tester,
          selectedPlaylistTitle: 'S8 audio',
          playlistsTitles: playlistsTitles,
          audioTitles: audioTitles,
          audioSubTitles: audioSubTitles,
        );

        // Verify the content of the 'S8 audio' playlist dir
        // + comments + pictures dir after restoration.
        IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
          playlistTitle: 'local',
          expectedAudioFiles: [], // empty since all playlists were deleted by
          // the first IntegrationTestUtil.executeRestorePlaylists execution
          expectedCommentFiles: [
            "Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!.json",
          ],
          expectedPictureFiles: [
            "Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!.json",
          ],
          doesPictureAudioMapFileNameExist: true,
          pictureFileNameOne: 'Barrau.jpg',
          audioForPictureTitleOneLst: [
            "S8 audio|250623-065532-Quand Aurélien Barrau va dans une école de management 23-09-10"
          ],
          pictureFileNameTwo: 'Jésus, mon amour.jpg',
          audioForPictureTitleTwoLst: [
            "S8 audio|Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'"
          ],
          pictureFileNameThree: "Dieu je T'adore.jpg",
          audioForPictureTitleThreeLst: [
            "local|Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          ],
        );
      });
      testWidgets(
          '''Unique playlist restore, not replace existing playlist. Restore unique playlist Windows zip
            containing 'Les plus belles chansons chrétiennes' playlist to Android application which contains
            'S8 audio' and 'local' playlists. All audio's of the restored playlist 'Les plus belles chansons
            chrétiennes' are then deleted. Afterward, the playlist 'Les plus belles chansons chrétiennes'
            is restored again so that the deleted audio's will be re-added.''',
          (tester) async {
        await IntegrationTestUtil.initializeAndroidApplicationAndSelectPlaylist(
          tester: tester,
          tapOnPlaylistToggleButton: false,
        );

        // Now initializing the application on the Android emulator using
        // zip restoration.

        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        String restorableZipFileName = 'audioLearn_app_initialization.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 5802),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            'urgent_actus_17-12-2023',
          ],
        );

        Finder okButtonFinder = find.byKey(const Key('warningDialogOkButton'));

        if (okButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(okButtonFinder.last);
          await tester.pumpAndSettle();
        }

        restorableZipFileName =
            'Windows Les plus belles chansons chrétiennes.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 198041),
        ]);

        // Now, test execution.
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
        );

        // Must be used on Android emulator, otherwise the confirmation
        // dialog is not displayed and can not be verifyed !
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        String restorableZipFilePathName =
            '/storage/emulated/0/Documents/test/audiolearn/$restorableZipFileName';

        // Verify the displayed warning confirmation dialog
        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              'Restored 1 playlist saved individually, 3 comment and 1 picture JSON files as well as 22 audio reference(s) and 0 added plus 0 modified comment(s) from "$restorableZipFilePathName".\n\nRestored also 1 picture JPG file(s) in the application pictures directory.',
          isWarningConfirming: true,
          warningTitle: 'CONFIRMATION',
        );

        // Verifying the existing restored playlist
        // list as well as the selected playlist 'Prières du
        // Maître' displayed audio titles and subtitles.

        List<String> playlistsTitles = [
          "S8 audio",
          "local",
          'Les plus belles chansons chrétiennes',
        ];

        List<String> audioTitles = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        List<String> audioSubTitles = [
          "0:06:29.0 2.37 MB at 1.69 MB/sec on 01/07/2024 at 16:35",
          "0:07:38.0 2.79 MB at 2.73 MB/sec on 07/01/2024 at 16:36",
        ];

        _verifyRestoredPlaylistAndAudio(
          tester: tester,
          selectedPlaylistTitle: 'S8 audio',
          playlistsTitles: playlistsTitles,
          audioTitles: audioTitles,
          audioSubTitles: audioSubTitles,
        );

        // Verify the content of the 'S8 audio' playlist dir
        // + comments + pictures dir after restoration.
        IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
          playlistTitle: 'S8 audio',
          expectedAudioFiles: [], // empty since all playlists were deleted by
          // the first IntegrationTestUtil.executeRestorePlaylists executio
          expectedCommentFiles: [
            "240701-163607-La surpopulation mondiale par Jancovici et Barrau 23-12-03.json",
          ],
          expectedPictureFiles: [],
          doesPictureAudioMapFileNameExist: true,
          pictureFileNameOne: 'Jésus merveilleux.jpg',
          audioForPictureTitleOneLst: [
            "Les plus belles chansons chrétiennes|250320-105102-Glorious - Je n'ai que ma prière #louange 23-07-18"
          ],
        );
      });
    });
    group('''From Android zip.''', () {
      testWidgets(
          '''Unique playlist restore, not replace existing playlist. Restore unique playlist Android zip
            containing 'S8 audio' playlist to Android application which contains 'S8 audio' and 'local'
            playlists. The restored 'S8 audio' playlist contains additional audio's to which comments and
            pictures are associated.''', (tester) async {
        await IntegrationTestUtil.initializeAndroidApplicationAndSelectPlaylist(
          tester: tester,
          tapOnPlaylistToggleButton: false,
        );

        // Now initializing the application on the Android emulator using
        // zip restoration.

        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        String restorableZipFileName = 'audioLearn_app_initialization.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 5802),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            'urgent_actus_17-12-2023',
          ],
        );

        Finder okButtonFinder = find.byKey(const Key('warningDialogOkButton'));

        if (okButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(okButtonFinder.last);
          await tester.pumpAndSettle();
        }

        restorableZipFileName = 'Android S8 audio.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 162667),
        ]);

        // Now, test execution.
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
        );

        // Must be used on Android emulator, otherwise the confirmation
        // dialog is not displayed and can not be verifyed !
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        String restorableZipFilePathName =
            '/storage/emulated/0/Documents/test/audiolearn/$restorableZipFileName';

        // Verify the displayed warning confirmation dialog
        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              'Restored 0 playlist saved individually, 2 comment and 2 picture JSON files as well as 2 audio reference(s) and 0 added plus 0 modified comment(s) from "$restorableZipFilePathName".\n\nRestored also 2 picture JPG file(s) in the application pictures directory.',
          isWarningConfirming: true,
          warningTitle: 'CONFIRMATION',
        );

        // Verifying the existing restored playlist
        // list as well as the selected playlist 'Prières du
        // Maître' displayed audio titles and subtitles.

        List<String> playlistsTitles = [
          "S8 audio",
          "local",
        ];

        List<String> audioTitles = [
          "Quand Aurélien Barrau va dans une école de management",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        List<String> audioSubTitles = [
          "0:17:59.0 6.58 MB at 1.37 MB/sec on 23/06/2025 at 06:55",
          "0:06:29.0 2.37 MB at 1.69 MB/sec on 01/07/2024 at 16:35",
          "0:07:38.0 2.79 MB at 2.73 MB/sec on 07/01/2024 at 16:36",
        ];

        _verifyRestoredPlaylistAndAudio(
          tester: tester,
          selectedPlaylistTitle: 'S8 audio',
          playlistsTitles: playlistsTitles,
          audioTitles: audioTitles,
          audioSubTitles: audioSubTitles,
        );

        // Verify the content of the 'S8 audio' playlist dir
        // + comments + pictures dir after restoration.
        IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
          playlistTitle: 'S8 audio',
          expectedAudioFiles: [], // empty since all playlists were deleted by
          // the first IntegrationTestUtil.executeRestorePlaylists executio
          expectedCommentFiles: [
            "240701-163607-La surpopulation mondiale par Jancovici et Barrau 23-12-03.json",
            "250623-065532-Quand Aurélien Barrau va dans une école de management 23-09-10.json",
            "Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'.json",
          ],
          expectedPictureFiles: [
            "250623-065532-Quand Aurélien Barrau va dans une école de management 23-09-10.json",
            "Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'.json"
          ],
          doesPictureAudioMapFileNameExist: true,
          pictureFileNameOne: 'Barrau.jpg',
          audioForPictureTitleOneLst: [
            "S8 audio|250623-065532-Quand Aurélien Barrau va dans une école de management 23-09-10"
          ],
          pictureFileNameTwo: 'Jésus, mon amour.jpg',
          audioForPictureTitleTwoLst: [
            "S8 audio|Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'"
          ],
        );
      });
      testWidgets(
          '''Multiple playlist restore, not replace existing playlists. Restore multiple playlists Android
             zip containing 'S8 audio' and 'local' playlists to Android application which contain 'S8 audio'
             and 'local' playlists. The restored 'S8 audio' and 'local' playlists contains additional audio's
             to which comments and pictures are associated.''', (tester) async {
        await IntegrationTestUtil.initializeAndroidApplicationAndSelectPlaylist(
          tester: tester,
          tapOnPlaylistToggleButton: false,
        );

        // Now initializing the application on the Android emulator using
        // zip restoration.

        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        String restorableZipFileName = 'audioLearn_app_initialization.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 5802),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            'urgent_actus_17-12-2023',
          ],
        );

        Finder okButtonFinder = find.byKey(const Key('warningDialogOkButton'));

        if (okButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(okButtonFinder.last);
          await tester.pumpAndSettle();
        }

        restorableZipFileName =
            'Android 2 existing playlists with new audios.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 162667),
        ]);

        // Now, test execution.
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
        );

        // Must be used on Android emulator, otherwise the confirmation
        // dialog is not displayed and can not be verifyed !
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        String restorableZipFilePathName =
            '/storage/emulated/0/Documents/test/audiolearn/$restorableZipFileName';

        // Verify the displayed warning confirmation dialog
        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              'Restored 0 playlist, 3 comment and 3 picture JSON files as well as 4 audio reference(s) and 0 added plus 0 modified comment(s) and the application settings from "$restorableZipFilePathName".',
          isWarningConfirming: true,
          warningTitle: 'CONFIRMATION',
        );

        // Verifying the existing restored playlist
        // list as well as the selected playlist 'Prières du
        // Maître' displayed audio titles and subtitles.

        List<String> playlistsTitles = [
          "S8 audio",
          "local",
        ];

        List<String> audioTitles = [
          "Quand Aurélien Barrau va dans une école de management",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        List<String> audioSubTitles = [
          "0:17:59.0 6.58 MB at 1.37 MB/sec on 23/06/2025 at 06:55",
          "0:06:29.0 2.37 MB at 1.69 MB/sec on 01/07/2024 at 16:35",
          "0:07:38.0 2.79 MB at 2.73 MB/sec on 07/01/2024 at 16:36",
        ];

        _verifyRestoredPlaylistAndAudio(
          tester: tester,
          selectedPlaylistTitle: 'S8 audio',
          playlistsTitles: playlistsTitles,
          audioTitles: audioTitles,
          audioSubTitles: audioSubTitles,
        );

        // Verify the content of the 'S8 audio' playlist dir
        // + comments + pictures dir after restoration.
        IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
          playlistTitle: 'local',
          expectedAudioFiles: [], // empty since all playlists were deleted by
          // the first IntegrationTestUtil.executeRestorePlaylists execution
          expectedCommentFiles: [
            "Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!.json",
          ],
          expectedPictureFiles: [
            "Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!.json",
          ],
          doesPictureAudioMapFileNameExist: true,
          pictureFileNameOne: 'Barrau.jpg',
          audioForPictureTitleOneLst: [
            "S8 audio|250623-065532-Quand Aurélien Barrau va dans une école de management 23-09-10"
          ],
          pictureFileNameTwo: 'Jésus, mon amour.jpg',
          audioForPictureTitleTwoLst: [
            "S8 audio|Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'"
          ],
          pictureFileNameThree: "Dieu je T'adore.jpg",
          audioForPictureTitleThreeLst: [
            "local|Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          ],
        );
      });
    });
    group(
        r'''From Android data. Before running the test, execute C:\development\flutter\audiolearn\test\
       data\saved\Android_emulator_bat\copy_sauvegarde.bat "C:\development\flutter\audiolearn\test\data\
       saved\test_on_Android_emulator_inkwell_button"''', () {
      testWidgets(
          '''Test on the playlist download view the correct audio item inkwell play/pause button change
            when the current playing audio reaches its end and the next audio starts playing. DDue to
            the main branch audioplayer version which does not support the integration test action,
            the test is not executable4 on the main branch.''', (tester) async {
        await IntegrationTestUtil.initializeAndroidApplicationAndSelectPlaylist(
          tester: tester,
          tapOnPlaylistToggleButton: false,
        );

        // Now initializing the application on the Android emulator using
        // zip restoration.

        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        const String restorableZipFileName = 'urgent_actus_17-12-2023.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 2655),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        const String urgentActusPlaylistTitle = 'urgent_actus_17-12-2023';
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            urgentActusPlaylistTitle,
          ],
        );

        // Tap on the 'OK' button of the confirmation dialog
        await tester.tap(find.byKey(const Key('warningDialogOkButton')).last);
        await tester.pumpAndSettle();

        const String restorableMp3ZipFileName =
            'urgent_actus_17-12-2023_mp3_from_2025-08-12_16_29_25_on_2025-08-15_11_23_41.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableMp3ZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableMp3ZipFileName',
              size: 15366672),
        ]);

        await IntegrationTestUtil.typeOnPlaylistMenuItem(
          tester: tester,
          playlistTitle: urgentActusPlaylistTitle,
          playlistMenuKeyStr:
              'popup_menu_restore_playlist_audio_mp3_files_from_zip',
          dragToBottom: true, // necessary if Flutter emulator is used
        );

        // Now verifying the confirm dialog message

        expect(
          tester
              .widget<Text>(find.byKey(
                const Key('setValueToTargetDialogTitleKey'),
              ))
              .data,
          'MP3 Restoration',
        );

        expect(
          tester
              .widget<Text>(find.byKey(
                const Key('setValueToTargetDialogKey'),
              ))
              .data,
          "Only the MP3 relative to the audio's listed in the playlist which are not already present in the playlist are restorable.",
        );

        // Now find the 'Ok' button of the SetValueToTarget dialog
        // and tap on it
        await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
        await tester.pumpAndSettle();

        const String thirdAudioTitle =
            "NOUVEAU CHAPITRE POUR ETHEREUM - L'IDÉE GÉNIALE DE VITALIK! ACTUS CRYPTOMONNAIES 13_12";

        // Find the audio list widget using its key
        final listFinder = find.byKey(const Key('audio_list'));
        // Perform the scroll action
        await tester.drag(listFinder, const Offset(0, -300));
        await tester.pumpAndSettle();

        Finder thirdAudioListTileInkWellFinder =
            IntegrationTestUtil.findAudioItemInkWellWidget(
          audioTitle: thirdAudioTitle,
        );

        await tester.tap(thirdAudioListTileInkWellFinder);
        await tester.pumpAndSettle();

        // Tapping three times on the 10 seconds forward icon button
        // and go back to the playlist download view screen.

        Finder forward10sButtonFinder =
            find.byKey(const Key('audioPlayerViewForward10sButton'));
        await tester.tap(forward10sButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(forward10sButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(forward10sButtonFinder);
        await tester.pumpAndSettle();

        // Go back to the playlist download view.
        Finder appScreenNavigationButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        IntegrationTestUtil.validateInkWellButton(
          tester: tester,
          audioTitle: thirdAudioTitle,
          expectedIcon: Icons.pause,
          expectedIconColor: Colors.white,
          expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
        );

        // Add a delay to allow the audio to reach its end and the next audio
        // to start playing.
        for (int i = 0; i < 16; i++) {
          await Future.delayed(const Duration(seconds: 1));
          await tester.pumpAndSettle();
        }

        IntegrationTestUtil.validateInkWellButton(
          tester: tester,
          audioTitle: thirdAudioTitle,
          expectedIcon: Icons.play_arrow,
          expectedIconColor:
              kSliderThumbColorInDarkMode, // Fully played audio item play icon color
          expectedIconBackgroundColor: Colors.black,
        );

        const String secondAudioTitle = "L’uniforme arrive en France en 2024";

        final Finder secondAudioListTileTextWidgetFinder =
            find.text(secondAudioTitle);

        await tester.tap(secondAudioListTileTextWidgetFinder);
        await tester.pumpAndSettle();

        // Tapping three time on the 10 seconds forward icon button

        forward10sButtonFinder =
            find.byKey(const Key('audioPlayerViewForward10sButton'));
        await tester.tap(forward10sButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(forward10sButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(forward10sButtonFinder);
        await tester.pumpAndSettle();

        // Now go back to the playlist download view screen

        appScreenNavigationButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        IntegrationTestUtil.validateInkWellButton(
          tester: tester,
          audioTitle: secondAudioTitle,
          expectedIcon: Icons.pause,
          expectedIconColor: Colors.white,
          expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
        );

        // Add a delay to allow the audio to reach its end and the next audio
        // to start playing.
        for (int i = 0; i < 16; i++) {
          await Future.delayed(const Duration(seconds: 1));
          await tester.pumpAndSettle();
        }

        IntegrationTestUtil.validateInkWellButton(
          tester: tester,
          audioTitle: secondAudioTitle,
          expectedIcon: Icons.play_arrow,
          expectedIconColor:
              kSliderThumbColorInDarkMode, // Fully played audio item play icon color
          expectedIconBackgroundColor: Colors.black,
        );

        const String firstAudioTitle =
            "DETTE PUBLIQUE  - LA RÉALITÉ DERRIÈRE LES DISCOURS CATASTROPHISTES";

        // Perform the scroll action
        await tester.drag(
            listFinder, const Offset(0, 300)); // Scroll back to the top
        await tester.pumpAndSettle();

        IntegrationTestUtil.validateInkWellButton(
          tester: tester,
          audioTitle: firstAudioTitle,
          expectedIcon: Icons.pause,
          expectedIconColor: Colors.white,
          expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
        );
      });
    });
  });
  group(
      'Save audio mp3 files to zip files for all playlists or unique playlist test',
      () {
    group('Save playlists audio mp3 files to zip file menu test', () {
      testWidgets(
          '''Keep download date to the oldest one. The oldest value is 13/07/2025 14:31. The integration
          test verifies the confirmation displayed warning.''',
          (WidgetTester tester) async {
        await IntegrationTestUtil.initializeAndroidApplicationAndSelectPlaylist(
          tester: tester,
          tapOnPlaylistToggleButton: false,
        );

        // Now initializing the application on the Android emulator using
        // zip restoration.

        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        // First, set the application language to english
        await IntegrationTestUtil.setApplicationLanguage(
          tester: tester,
          language: Language.english,
        );

        // Setting the path value returned by the FilePicker mock.
        mockFilePicker.setPathToSelect(
          pathToSelectStr: kApplicationPathWindowsTest,
        );

        // Tap the appbar leading popup menu button
        await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
        await tester.pumpAndSettle();

        // Now tap on the 'Save Playlists Audio's MP3 to ZIP File' menu
        await tester.tap(
            find.byKey(const Key('appBarMenuSavePlaylistsAudioMp3FilesToZip')));
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<Text>(find.byKey(
                const Key('setValueToTargetDialogTitleKey'),
              ))
              .data,
          'Set the download date',
        );

        expect(
          tester
              .widget<Text>(find.byKey(
                const Key('setValueToTargetDialogKey'),
              ))
              .data,
          'The default specified download date corresponds to the oldest audio download date from all playlists. Modify this value by specifying the download date from which the audio MP3 files will be included in the ZIP.',
        );

        expect(find.text('Date/time dd/MM/yyyy hh:mm'), findsOneWidget);

        const String oldestAudioDownloadDateTime = '13/07/2025 14:31';

        expect(find.text(oldestAudioDownloadDateTime), findsOneWidget);

        // Tap on the Ok button to set download date time.
        await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
        await tester.pumpAndSettle();

        // Now check the confirm dialog which indicates the estimated
        // save audio mp3 to zip duration and accept save execution.

        Finder confirmActionDialogFinder = find.byType(ConfirmActionDialog);

        // Check the value of the confirm dialog title
        Finder confirmActionDialogTitleText = find.descendant(
            of: confirmActionDialogFinder,
            matching: find.byKey(const Key("confirmDialogTitleOneKey")));

        expect(
          tester.widget<Text>(confirmActionDialogTitleText).data!,
          "Prevision of the save duration",
        );

        // Check the value of the confirm dialog message
        Finder confirmActionDialogMessageText = find.descendant(
            of: confirmActionDialogFinder,
            matching: find.byKey(const Key("confirmationDialogMessageKey")));

        expect(
          tester.widget<Text>(confirmActionDialogMessageText).data!,
          anyOf([
            equals(
              "Saving the audio MP3 files will take this estimated duration (hh:mm:ss): 0:00:01.",
            ),
            equals(
              "Saving the audio MP3 files will take this estimated duration (hh:mm:ss): 0:00:02.",
            ),
          ]),
        );

        // Confirm the saving of the audio mp3 files and close the
        // confirm dialog by tapping on the Confirm button.
        await tester.tap(find.byKey(const Key('confirmButton')));
        await tester.pump(); // Process the tap immediately

        // Only works if tester.pump() is used instead of
        // tester.pumpAndSettle()
        expect(
          find.text("Saving multiple playlists audio files to ZIP ..."),
          findsOneWidget,
        );
        expect(
          tester
              .widget<Text>(find.byKey(const Key('saving_please_wait')).last)
              .data!,
          contains(
            "Please wait, this should approximately take ",
          ),
        );

        // Wait for completion
        await tester.pumpAndSettle();

        Text warningDialogTitle =
            tester.widget(find.byKey(const Key('warningDialogTitle')).last);

        expect(warningDialogTitle.data, 'CONFIRMATION');

        String actualMessage = tester
            .widget<Text>(find.byKey(const Key('warningDialogMessage')).last)
            .data!;

        expect(
            actualMessage,
            contains(
                "Saved to ZIP all playlists audio MP3 files downloaded from $oldestAudioDownloadDateTime.\n\nTotal saved audio number: 5, total size: 64.47 MB and total duration: 2:40:27.2."));
        expect(
            actualMessage, contains("Save operation real duration: 0:00:01"));
        expect(actualMessage, contains("number of bytes saved per second: 3"));
        expect(
            actualMessage,
            contains(
                "ZIP file path name: \"$kApplicationPathWindowsTest${path.separator}audioLearn_mp3_from_2025-07-13_14_31_25_on_"));

        List<String> zipLst = DirUtil.listFileNamesInDir(
          directoryPath: kApplicationPathWindowsTest,
          fileExtension: 'zip',
        );

        List<String> expectedZipContentLst = [
          "playlists\\Saint François d'Assise\\250714-171854-How to talk to animals The teaching of Saint Francis of Assisi 22-05-28.mp3",
          "playlists\\Saint François d'Assise\\250713-143130-Saint François d'Assise, le jongleur de Dieu 20-10-03.mp3",
          "playlists\\Saint François d'Assise\\250713-143125-4 octobre  - Saint François, le Saint qui a Transformé l'Église et le Monde 24-10-03.mp3",
          "playlists\\Exo chants chrétiens\\250713-144410-EXO - Ta bienveillance [avec paroles] 13-01-29.mp3",
          "playlists\\Exo chants chrétiens\\250713-144321-SI TU VEUX LE LOUER - EXO 17-05-31.mp3",
        ];

        List<String> zipContentLst = await DirUtil.listPathFileNamesInZip(
          zipFilePathName:
              "$kApplicationPathWindowsTest${path.separator}${zipLst[0]}",
        );

        expect(
          zipContentLst,
          expectedZipContentLst,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets(
          '''Set download date to more recent one. The less old value is 13/07/2025 14:41. The integration
          test verifies the confirmation displayed warning.''',
          (WidgetTester tester) async {
        await IntegrationTestUtil.initializeAndroidApplicationAndSelectPlaylist(
          tester: tester,
          tapOnPlaylistToggleButton: false,
        );

        // Now initializing the application on the Android emulator using
        // zip restoration.

        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        // First, set the application language to english
        await IntegrationTestUtil.setApplicationLanguage(
          tester: tester,
          language: Language.english,
        );

        // Setting the path value returned by the FilePicker mock.
        mockFilePicker.setPathToSelect(
          pathToSelectStr: kApplicationPathWindowsTest,
        );

        // Tap the appbar leading popup menu button
        await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
        await tester.pumpAndSettle();

        // Now tap on the 'Save Playlists Audio's MP3 to ZIP File' menu
        await tester.tap(
            find.byKey(const Key('appBarMenuSavePlaylistsAudioMp3FilesToZip')));
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<Text>(find.byKey(
                const Key('setValueToTargetDialogTitleKey'),
              ))
              .data,
          'Set the download date',
        );

        expect(
          tester
              .widget<Text>(find.byKey(
                const Key('setValueToTargetDialogKey'),
              ))
              .data,
          'The default specified download date corresponds to the oldest audio download date from all playlists. Modify this value by specifying the download date from which the audio MP3 files will be included in the ZIP.',
        );

        expect(find.text('Date/time dd/MM/yyyy hh:mm'), findsOneWidget);

        const String oldestAudioDownloadDateTime = '13/07/2025 14:31';

        expect(find.text(oldestAudioDownloadDateTime), findsOneWidget);

        Finder setValueToTargetDialogFinder =
            find.byType(SetValueToTargetDialog);

        // This finder obtained as descendant of its enclosing dialog does
        // enable to change the value of the TextField
        Finder setValueToTargetDialogEditTextFinder = find.descendant(
          of: setValueToTargetDialogFinder,
          matching: find.byType(TextField),
        );

        // Verify that the TextField is focused using its focus node
        TextField textField =
            tester.widget<TextField>(setValueToTargetDialogEditTextFinder);
        expect(textField.focusNode?.hasFocus, isTrue,
            reason: 'TextField should be focused when dialog opens');

        // Now change the download date in the dialog
        String audioOldestDownloadDateTime = '13/07/2025 14:41';
        textField.controller!.text = audioOldestDownloadDateTime;
        await tester.pumpAndSettle();

        // Tap on the Ok button to set download date time.
        await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
        await tester.pumpAndSettle();

        // Now check the confirm dialog which indicates the estimated
        // save audio mp3 to zip duration and accept save execution.

        Finder confirmActionDialogFinder = find.byType(ConfirmActionDialog);

        // Check the value of the confirm dialog title
        Finder confirmActionDialogTitleText = find.descendant(
            of: confirmActionDialogFinder,
            matching: find.byKey(const Key("confirmDialogTitleOneKey")));

        expect(
          tester.widget<Text>(confirmActionDialogTitleText).data!,
          "Prevision of the save duration",
        );

        // Check the value of the confirm dialog message
        Finder confirmActionDialogMessageText = find.descendant(
            of: confirmActionDialogFinder,
            matching: find.byKey(const Key("confirmationDialogMessageKey")));

        expect(
          tester.widget<Text>(confirmActionDialogMessageText).data!,
          anyOf([
            equals(
              "Saving the audio MP3 files will take this estimated duration (hh:mm:ss): 0:00:01.",
            ),
            equals(
              "Saving the audio MP3 files will take this estimated duration (hh:mm:ss): 0:00:02.",
            ),
          ]),
        );

        // Confirm the saving of the audio mp3 files and close the
        // confirm dialog by tapping on the Confirm button.
        await tester.tap(find.byKey(const Key('confirmButton')));
        await tester.pump(); // Process the tap immediately

        // Only works if tester.pump() is used instead of
        // tester.pumpAndSettle()
        expect(
          find.text("Saving multiple playlists audio files to ZIP ..."),
          findsOneWidget,
        );
        expect(
          tester
              .widget<Text>(find.byKey(const Key('saving_please_wait')).last)
              .data!,
          contains(
            "Please wait, this should approximately take ",
          ),
        );

        // Wait for completion
        await tester.pumpAndSettle();

        Text warningDialogTitle =
            tester.widget(find.byKey(const Key('warningDialogTitle')).last);

        expect(warningDialogTitle.data, 'CONFIRMATION');

        String actualMessage = tester
            .widget<Text>(find.byKey(const Key('warningDialogMessage')).last)
            .data!;
        expect(
            actualMessage,
            contains(
                "Saved to ZIP all playlists audio MP3 files downloaded from $audioOldestDownloadDateTime.\n\nTotal saved audio number: 3, total size: 15.49 MB and total duration: 0:22:38.0."));
        expect(
            actualMessage, contains("Save operation real duration: 0:00:00"));
        expect(actualMessage, contains("number of bytes saved per second: "));
        expect(
            actualMessage,
            contains(
                "ZIP file path name: \"$kApplicationPathWindowsTest${path.separator}audioLearn_mp3_from_2025-07-13_14_43_21_on_${yearMonthDayDateTimeFormatForFileName.format(DateTime.now().subtract(Duration(seconds: 1)))}.zip\"."));

        List<String> zipLst = DirUtil.listFileNamesInDir(
          directoryPath: kApplicationPathWindowsTest,
          fileExtension: 'zip',
        );

        List<String> expectedZipContentLst = [
          "playlists\\Saint François d'Assise\\250714-171854-How to talk to animals The teaching of Saint Francis of Assisi 22-05-28.mp3",
          "playlists\\Exo chants chrétiens\\250713-144410-EXO - Ta bienveillance [avec paroles] 13-01-29.mp3",
          "playlists\\Exo chants chrétiens\\250713-144321-SI TU VEUX LE LOUER - EXO 17-05-31.mp3",
        ];

        List<String> zipContentLst = await DirUtil.listPathFileNamesInZip(
          zipFilePathName:
              "$kApplicationPathWindowsTest${path.separator}${zipLst[0]}",
        );

        expect(
          zipContentLst,
          expectedZipContentLst,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets(
          '''Set download date after the last download date. The set value is 14/07/2025 18:31. The integration
          test verifies the displayed warning indicating that no audio mp3 was saved to ZIP.''',
          (WidgetTester tester) async {
        await IntegrationTestUtil.initializeAndroidApplicationAndSelectPlaylist(
          tester: tester,
          tapOnPlaylistToggleButton: false,
        );

        // Now initializing the application on the Android emulator using
        // zip restoration.

        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        // First, set the application language to english
        await IntegrationTestUtil.setApplicationLanguage(
          tester: tester,
          language: Language.english,
        );

        // Setting the path value returned by the FilePicker mock.
        mockFilePicker.setPathToSelect(
          pathToSelectStr: kApplicationPathWindowsTest,
        );

        // Tap the appbar leading popup menu button
        await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
        await tester.pumpAndSettle();

        // Now tap on the 'Save Playlists Audio's MP3 to ZIP File' menu
        await tester.tap(
            find.byKey(const Key('appBarMenuSavePlaylistsAudioMp3FilesToZip')));
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<Text>(find.byKey(
                const Key('setValueToTargetDialogTitleKey'),
              ))
              .data,
          'Set the download date',
        );

        expect(
          tester
              .widget<Text>(find.byKey(
                const Key('setValueToTargetDialogKey'),
              ))
              .data,
          'The default specified download date corresponds to the oldest audio download date from all playlists. Modify this value by specifying the download date from which the audio MP3 files will be included in the ZIP.',
        );

        expect(find.text('Date/time dd/MM/yyyy hh:mm'), findsOneWidget);

        const String oldestAudioDownloadDateTime = '13/07/2025 14:31';

        expect(find.text(oldestAudioDownloadDateTime), findsOneWidget);

        Finder setValueToTargetDialogFinder =
            find.byType(SetValueToTargetDialog);

        // This finder obtained as descendant of its enclosing dialog does
        // enable to change the value of the TextField
        Finder setValueToTargetDialogEditTextFinder = find.descendant(
          of: setValueToTargetDialogFinder,
          matching: find.byType(TextField),
        );

        // Verify that the TextField is focused using its focus node
        TextField textField =
            tester.widget<TextField>(setValueToTargetDialogEditTextFinder);
        expect(textField.focusNode?.hasFocus, isTrue,
            reason: 'TextField should be focused when dialog opens');

        // Now change the download date in the dialog
        const String tooRecentAudioDownloadDateTime = '15/07/2025 14:31';
        String audioOldestDownloadDateTime = tooRecentAudioDownloadDateTime;
        textField.controller!.text = audioOldestDownloadDateTime;
        await tester.pumpAndSettle();

        // Tap on the Ok button to set download date time.
        await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
        await tester.pumpAndSettle();

        // Now check the confirm dialog which indicates the estimated
        // save audio mp3 to zip duration and accept save execution.

        Finder confirmActionDialogFinder = find.byType(ConfirmActionDialog);

        // Check the value of the confirm dialog title
        Finder confirmActionDialogTitleText = find.descendant(
            of: confirmActionDialogFinder,
            matching: find.byKey(const Key("confirmDialogTitleOneKey")));

        expect(
          tester.widget<Text>(confirmActionDialogTitleText).data!,
          "Prevision of the save duration",
        );

        // Check the value of the confirm dialog message
        Finder confirmActionDialogMessageText = find.descendant(
            of: confirmActionDialogFinder,
            matching: find.byKey(const Key("confirmationDialogMessageKey")));

        expect(
          tester.widget<Text>(confirmActionDialogMessageText).data!,
          "Saving the audio MP3 files will take this estimated duration (hh:mm:ss): 0:00:00.",
        );

        // Confirm the saving of the audio mp3 files and close the
        // confirm dialog by tapping on the Confirm button.
        await tester.tap(find.byKey(const Key('confirmButton')));
        await tester.pumpAndSettle();

        // Verify the displayed warning dialog
        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              "No audio MP3 file was saved to ZIP since no audio was downloaded on or after $tooRecentAudioDownloadDateTime.",
        );

        List<String> zipLst = DirUtil.listFileNamesInDir(
          directoryPath: kApplicationPathWindowsTest,
          fileExtension: 'zip',
        );

        expect(
          zipLst.length,
          0,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
    });
    group('Save unique playlist audio mp3 files to zip file menu test', () {
      testWidgets(
          '''Keep download date to the oldest one. The oldest value in the 'Saint François d'Assise'
          playlist is 13/07/2025 14:31. The integration test verifies the confirmation displayed
          warning.''', (WidgetTester tester) async {
        await IntegrationTestUtil.initializeAndroidApplicationAndSelectPlaylist(
          tester: tester,
          tapOnPlaylistToggleButton: false,
        );

        // Now initializing the application on the Android emulator using
        // zip restoration.

        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        // First, set the application language to english
        await IntegrationTestUtil.setApplicationLanguage(
          tester: tester,
          language: Language.english,
        );

        // Setting the path value returned by the FilePicker mock.
        mockFilePicker.setPathToSelect(
          pathToSelectStr: kApplicationPathWindowsTest,
        );

        const String playlistToSaveTitle = "Saint François d'Assise";

        await IntegrationTestUtil.typeOnPlaylistMenuItem(
          tester: tester,
          playlistTitle: playlistToSaveTitle,
          playlistMenuKeyStr: 'popup_menu_save_playlist_audio_mp3_files_to_zip',
        );

        expect(
          tester
              .widget<Text>(find.byKey(
                const Key('setValueToTargetDialogTitleKey'),
              ))
              .data,
          'Set the download date',
        );

        expect(
          tester
              .widget<Text>(find.byKey(
                const Key('setValueToTargetDialogKey'),
              ))
              .data,
          'The default specified download date corresponds to the oldest audio download date from the playlist. Modify this value by specifying the download date from which the audio MP3 files will be included in the ZIP.',
        );

        expect(find.text('Date/time dd/MM/yyyy hh:mm'), findsOneWidget);

        const String oldestAudioDownloadDateTime = '13/07/2025 14:31';

        expect(find.text(oldestAudioDownloadDateTime), findsOneWidget);

        // Tap on the Ok button to set download date time.
        await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
        await tester.pumpAndSettle();

        // Now check the confirm dialog which indicates the estimated
        // save audio mp3 to zip duration and accept save execution.

        Finder confirmActionDialogFinder = find.byType(ConfirmActionDialog);

        // Check the value of the confirm dialog title
        Finder confirmActionDialogTitleText = find.descendant(
            of: confirmActionDialogFinder,
            matching: find.byKey(const Key("confirmDialogTitleOneKey")));

        expect(
          tester.widget<Text>(confirmActionDialogTitleText).data!,
          "Prevision of the save duration",
        );

        // Check the value of the confirm dialog message
        Finder confirmActionDialogMessageText = find.descendant(
            of: confirmActionDialogFinder,
            matching: find.byKey(const Key("confirmationDialogMessageKey")));

        expect(
          tester.widget<Text>(confirmActionDialogMessageText).data!,
          anyOf([
            equals(
              "Saving the audio MP3 files will take this estimated duration (hh:mm:ss): 0:00:01.",
            ),
            equals(
              "Saving the audio MP3 files will take this estimated duration (hh:mm:ss): 0:00:02.",
            ),
          ]),
        );

        // Confirm the saving of the audio mp3 files and close the
        // confirm dialog by tapping on the Confirm button.
        await tester.tap(find.byKey(const Key('confirmButton')));
        await tester.pump(); // Process the tap immediately

        // Only works if tester.pump() is used instead of
        // tester.pumpAndSettle()
        expect(
          find.text("Saving $playlistToSaveTitle audio files to ZIP ..."),
          findsOneWidget,
        );
        expect(
          tester
              .widget<Text>(find.byKey(const Key('saving_please_wait')).last)
              .data!,
          contains(
            "Please wait, this should approximately take ",
          ),
        );

        // Wait for completion
        await tester.pumpAndSettle();

        Text warningDialogTitle =
            tester.widget(find.byKey(const Key('warningDialogTitle')).last);

        expect(warningDialogTitle.data, 'CONFIRMATION');

        String actualMessage = tester
            .widget<Text>(find.byKey(const Key('warningDialogMessage')).last)
            .data!;

        expect(
            actualMessage,
            contains(
                "Saved to ZIP unique playlist audio MP3 files downloaded from $oldestAudioDownloadDateTime.\n\nTotal saved audio number: 3, total size: 53.12 MB and total duration: 2:29:08.4."));
        expect(
            actualMessage, contains("Save operation real duration: 0:00:01"));
        expect(actualMessage, contains("number of bytes saved per second: 3"));
        expect(
            actualMessage,
            contains(
                "ZIP file path name: \"$kApplicationPathWindowsTest${path.separator}Saint François d'Assise_mp3_from_2025-07-13_14_31_25_on_"));

        List<String> zipLst = DirUtil.listFileNamesInDir(
          directoryPath: kApplicationPathWindowsTest,
          fileExtension: 'zip',
        );

        List<String> expectedZipContentLst = [
          "playlists\\Saint François d'Assise\\250714-171854-How to talk to animals The teaching of Saint Francis of Assisi 22-05-28.mp3",
          "playlists\\Saint François d'Assise\\250713-143130-Saint François d'Assise, le jongleur de Dieu 20-10-03.mp3",
          "playlists\\Saint François d'Assise\\250713-143125-4 octobre  - Saint François, le Saint qui a Transformé l'Église et le Monde 24-10-03.mp3",
        ];

        List<String> zipContentLst = await DirUtil.listPathFileNamesInZip(
          zipFilePathName:
              "$kApplicationPathWindowsTest${path.separator}${zipLst[0]}",
        );

        expect(
          zipContentLst,
          expectedZipContentLst,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets(
          '''Set download date to more recent one. A less old value will be 14/07/2025 14:31. The integration
          test verifies the confirmation displayed warning.''',
          (WidgetTester tester) async {
        await IntegrationTestUtil.initializeAndroidApplicationAndSelectPlaylist(
          tester: tester,
          tapOnPlaylistToggleButton: false,
        );

        // Now initializing the application on the Android emulator using
        // zip restoration.

        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        // First, set the application language to english
        await IntegrationTestUtil.setApplicationLanguage(
          tester: tester,
          language: Language.english,
        );

        // Setting the path value returned by the FilePicker mock.
        mockFilePicker.setPathToSelect(
          pathToSelectStr: kApplicationPathWindowsTest,
        );

        const String playlistToSaveTitle = "Saint François d'Assise";

        await IntegrationTestUtil.typeOnPlaylistMenuItem(
          tester: tester,
          playlistTitle: playlistToSaveTitle,
          playlistMenuKeyStr: 'popup_menu_save_playlist_audio_mp3_files_to_zip',
        );

        expect(
          tester
              .widget<Text>(find.byKey(
                const Key('setValueToTargetDialogTitleKey'),
              ))
              .data,
          'Set the download date',
        );

        expect(
          tester
              .widget<Text>(find.byKey(
                const Key('setValueToTargetDialogKey'),
              ))
              .data,
          'The default specified download date corresponds to the oldest audio download date from the playlist. Modify this value by specifying the download date from which the audio MP3 files will be included in the ZIP.',
        );

        expect(find.text('Date/time dd/MM/yyyy hh:mm'), findsOneWidget);

        const String oldestAudioDownloadDateTime = '13/07/2025 14:31';

        expect(find.text(oldestAudioDownloadDateTime), findsOneWidget);

        Finder setValueToTargetDialogFinder =
            find.byType(SetValueToTargetDialog);

        // This finder obtained as descendant of its enclosing dialog does
        // enable to change the value of the TextField
        Finder setValueToTargetDialogEditTextFinder = find.descendant(
          of: setValueToTargetDialogFinder,
          matching: find.byType(TextField),
        );

        // Verify that the TextField is focused using its focus node
        TextField textField =
            tester.widget<TextField>(setValueToTargetDialogEditTextFinder);
        expect(textField.focusNode?.hasFocus, isTrue,
            reason: 'TextField should be focused when dialog opens');

        // Now change the download date in the dialog. This date is
        // before the last download date of the playlist
        String audioOldestDownloadDateTime = '14/07/2025 14:31';
        textField.controller!.text = audioOldestDownloadDateTime;
        await tester.pumpAndSettle();

        // Tap on the Ok button to set download date time.
        await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
        await tester.pumpAndSettle();

        // Now check the confirm dialog which indicates the estimated
        // save audio mp3 to zip duration and accept save execution.

        Finder confirmActionDialogFinder = find.byType(ConfirmActionDialog);

        // Check the value of the confirm dialog title
        Finder confirmActionDialogTitleText = find.descendant(
            of: confirmActionDialogFinder,
            matching: find.byKey(const Key("confirmDialogTitleOneKey")));

        expect(
          tester.widget<Text>(confirmActionDialogTitleText).data!,
          "Prevision of the save duration",
        );

        // Check the value of the confirm dialog message
        Finder confirmActionDialogMessageText = find.descendant(
            of: confirmActionDialogFinder,
            matching: find.byKey(const Key("confirmationDialogMessageKey")));

        expect(
          tester.widget<Text>(confirmActionDialogMessageText).data!,
          anyOf([
            equals(
              "Saving the audio MP3 files will take this estimated duration (hh:mm:ss): 0:00:01.",
            ),
            equals(
              "Saving the audio MP3 files will take this estimated duration (hh:mm:ss): 0:00:02.",
            ),
          ]),
        );

        // Confirm the saving of the audio mp3 files and close the
        // confirm dialog by tapping on the Confirm button.
        await tester.tap(find.byKey(const Key('confirmButton')));
        await tester.pumpAndSettle();

        Text warningDialogTitle =
            tester.widget(find.byKey(const Key('warningDialogTitle')).last);

        expect(warningDialogTitle.data, 'CONFIRMATION');

        String actualMessage = tester
            .widget<Text>(find.byKey(const Key('warningDialogMessage')).last)
            .data!;
        expect(
            actualMessage,
            contains(
                "Saved to ZIP unique playlist audio MP3 files downloaded from $audioOldestDownloadDateTime.\n\nTotal saved audio number: 1, total size: 4.14 MB and total duration: 0:11:19.3."));
        expect(
            actualMessage, contains("Save operation real duration: 0:00:00"));
        expect(actualMessage, contains("number of bytes saved per second: "));
        expect(
            actualMessage,
            contains(
                "ZIP file path name: \"$kApplicationPathWindowsTest${path.separator}Saint François d'Assise_mp3_from_2025-07-14_17_18_54_on_"));

        List<String> zipLst = DirUtil.listFileNamesInDir(
          directoryPath: kApplicationPathWindowsTest,
          fileExtension: 'zip',
        );

        List<String> expectedZipContentLst = [
          "playlists\\Saint François d'Assise\\250714-171854-How to talk to animals The teaching of Saint Francis of Assisi 22-05-28.mp3",
        ];

        List<String> zipContentLst = await DirUtil.listPathFileNamesInZip(
          zipFilePathName:
              "$kApplicationPathWindowsTest${path.separator}${zipLst[0]}",
        );

        expect(
          zipContentLst,
          expectedZipContentLst,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets(
          '''Set download date after the last download date. The set value is 14/07/2025 18:31. The integration
          test verifies the displayed warning indicating that no audio mp3 was saved to ZIP.''',
          (WidgetTester tester) async {
        await IntegrationTestUtil.initializeAndroidApplicationAndSelectPlaylist(
          tester: tester,
          tapOnPlaylistToggleButton: false,
        );

        // Now initializing the application on the Android emulator using
        // zip restoration.

        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        // First, set the application language to english
        await IntegrationTestUtil.setApplicationLanguage(
          tester: tester,
          language: Language.english,
        );

        // Setting the path value returned by the FilePicker mock.
        mockFilePicker.setPathToSelect(
          pathToSelectStr: kApplicationPathWindowsTest,
        );

        const String playlistToSaveTitle = "Saint François d'Assise";

        await IntegrationTestUtil.typeOnPlaylistMenuItem(
          tester: tester,
          playlistTitle: playlistToSaveTitle,
          playlistMenuKeyStr: 'popup_menu_save_playlist_audio_mp3_files_to_zip',
        );

        expect(
          tester
              .widget<Text>(find.byKey(
                const Key('setValueToTargetDialogTitleKey'),
              ))
              .data,
          'Set the download date',
        );

        expect(
          tester
              .widget<Text>(find.byKey(
                const Key('setValueToTargetDialogKey'),
              ))
              .data,
          'The default specified download date corresponds to the oldest audio download date from the playlist. Modify this value by specifying the download date from which the audio MP3 files will be included in the ZIP.',
        );

        expect(find.text('Date/time dd/MM/yyyy hh:mm'), findsOneWidget);

        const String oldestAudioDownloadDateTime = '13/07/2025 14:31';

        expect(find.text(oldestAudioDownloadDateTime), findsOneWidget);

        Finder setValueToTargetDialogFinder =
            find.byType(SetValueToTargetDialog);

        // This finder obtained as descendant of its enclosing dialog does
        // enable to change the value of the TextField
        Finder setValueToTargetDialogEditTextFinder = find.descendant(
          of: setValueToTargetDialogFinder,
          matching: find.byType(TextField),
        );

        // Verify that the TextField is focused using its focus node
        TextField textField =
            tester.widget<TextField>(setValueToTargetDialogEditTextFinder);
        expect(textField.focusNode?.hasFocus, isTrue,
            reason: 'TextField should be focused when dialog opens');

        // Now change the download date in the dialog
        const String tooRecentAudioDownloadDateTime = '15/07/2025 14:31';
        String audioOldestDownloadDateTime = tooRecentAudioDownloadDateTime;
        textField.controller!.text = audioOldestDownloadDateTime;
        await tester.pumpAndSettle();

        // Tap on the Ok button to set download date time.
        await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
        await tester.pumpAndSettle();

        // Now check the confirm dialog which indicates the estimated
        // save audio mp3 to zip duration and accept save execution.

        Finder confirmActionDialogFinder = find.byType(ConfirmActionDialog);

        // Check the value of the confirm dialog title
        Finder confirmActionDialogTitleText = find.descendant(
            of: confirmActionDialogFinder,
            matching: find.byKey(const Key("confirmDialogTitleOneKey")));

        expect(
          tester.widget<Text>(confirmActionDialogTitleText).data!,
          "Prevision of the save duration",
        );

        // Check the value of the confirm dialog message
        Finder confirmActionDialogMessageText = find.descendant(
            of: confirmActionDialogFinder,
            matching: find.byKey(const Key("confirmationDialogMessageKey")));

        expect(
          tester.widget<Text>(confirmActionDialogMessageText).data!,
          "Saving the audio MP3 files will take this estimated duration (hh:mm:ss): 0:00:00.",
        );

        // Confirm the saving of the audio mp3 files and close the
        // confirm dialog by tapping on the Confirm button.
        await tester.tap(find.byKey(const Key('confirmButton')));
        await tester.pumpAndSettle();

        // Verify the displayed warning dialog
        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              "No audio MP3 file was saved to ZIP since no audio was downloaded on or after $tooRecentAudioDownloadDateTime.",
        );

        List<String> zipLst = DirUtil.listFileNamesInDir(
          directoryPath: kApplicationPathWindowsTest,
          fileExtension: 'zip',
        );

        expect(
          zipLst.length,
          0,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
    });
  });
  group(
      'Restore playlist, comments, pictures and settings from zip file menu test',
      () {
    group('On not empty app dir, restore Windows zip.', () {
      group(
          'Restored selected playlist is identical to the before restoration selected playlist.',
          () {
        testWidgets(
            '''Replace existing playlist. Restore Windows zip to Windows application in which
           an existing playlist is selected. Then, select a SF parm and redownload the
           filtered audio. Finally, redownload an individual not playable audio.
           
           Before running the integration test, C:\\development\\flutter\\audiolearn\\test\\
           data\\saved\\Android_emulator_bat\\setup_test.bat must be executed !''',
            (tester) async {
          await IntegrationTestUtil
              .initializeAndroidApplicationAndSelectPlaylist(
            tester: tester,
            tapOnPlaylistToggleButton: false,
          );

          // Replace the platform instance with your mock
          MockFilePicker mockFilePicker = MockFilePicker();
          FilePicker.platform = mockFilePicker;

          String restorableZipFileName = 'toCopyOnAndroidEmulator.zip';

          mockFilePicker.setSelectedFiles([
            PlatformFile(
                name: restorableZipFileName,
                path:
                    '$kApplicationPathAndroidTest${path.separator}$restorableZipFileName',
                size: 8770),
          ]);

          // Execute the 'Restore Playlists, Comments and Settings from Zip
          // File ...' menu without replacing the existing playlists.
          await IntegrationTestUtil.executeRestorePlaylists(
            tester: tester,
            doReplaceExistingPlaylists: false,
          );

          await Future.delayed(const Duration(milliseconds: 500));
          await tester.pumpAndSettle(); // must be used on Android emulator !

          // Verify the displayed warning confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                'Restored 2 playlist, 5 comment and 4 picture JSON files as well as the application settings from "$kApplicationPathAndroidTest/$restorableZipFileName".',
            isWarningConfirming: true,
            warningTitle: 'CONFIRMATION',
          );

          // Verify the content of the 'A restaurer' playlist dir
          // and comments and pictures dir before restoring.
          IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
            playlistTitle: 'A restaurer',
            expectedAudioFiles: [
              // Since the 'A restaurer' as well as the 'local' playlists
              // were not copied in the Android emulator but were restored
              // from the toCopyOnAndroidEmulator.zip file, the mp3 files
              // aren't available.
            ],
            expectedCommentFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.json",
              "250213-104308-Le 21 juillet 1913 _ Prières et méditations, La Mère 25-02-13.json",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.json",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json",
            ],
            expectedPictureFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.json",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.json",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json",
            ],
            doesPictureAudioMapFileNameExist: true,
            pictureFileNameOne: "Sam Altman.jpg",
            audioForPictureTitleOneLst: [
              "A restaurer|250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12",
              "A restaurer|250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12"
            ],
            pictureFileNameTwo: "Jésus mon Amour.jpg",
            audioForPictureTitleTwoLst: [
              "A restaurer|250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
            pictureFileNameThree: "Jésus je T'adore.jpg",
            audioForPictureTitleThreeLst: [
              "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
          );

          // Verify the content of the 'local' playlist dir
          // and comments and pictures dir before restoring.
          IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
            playlistTitle: 'local',
            expectedAudioFiles: [
              // Since the 'A restaurer' as well as the 'local' playlists
              // were not copied in the Android emulator but were restored
              // from the toCopyOnAndroidEmulator.zip file, the mp3 files
              // aren't available.
            ],
            expectedCommentFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json"
            ],
            expectedPictureFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json"
            ],
            doesPictureAudioMapFileNameExist: true,
            pictureFileNameOne: "Jésus je T'adore.jpg",
            audioForPictureTitleOneLst: [
              "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
          );

          restorableZipFileName = 'Windows audioLearn_2025-05-11_13_16.zip';

          mockFilePicker.setSelectedFiles([
            PlatformFile(
                name: restorableZipFileName,
                path:
                    '$kApplicationPathAndroidTest${path.separator}$restorableZipFileName',
                size: 12828),
          ]);

          // Execute the 'Restore Playlists, Comments and Settings from Zip
          // File ...' menu with the 'Replace existing playlists' option
          // selected.
          await IntegrationTestUtil.executeRestorePlaylists(
            tester: tester,
            doReplaceExistingPlaylists: true,
          );

          // Must be used on Android emulator, otherwise the confirmation
          // dialog is not displayed and can not be verifyed !
          await Future.delayed(const Duration(milliseconds: 500));
          await tester.pumpAndSettle();

          // Verify the displayed warning confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                'Restored 2 playlist, 0 comment and 4 picture JSON files as well as the application settings from "$kApplicationPathAndroidTest/$restorableZipFileName".',
            isWarningConfirming: true,
            warningTitle: 'CONFIRMATION',
          );

          // Verifying the existing and the restored playlists
          // list as well as the selected playlist 'A restaurer'
          // displayed audio titles and subtitles.

          List<String> playlistsTitles = [
            "A restaurer",
            "local",
          ];

          List<String> audioTitles = [
            "Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage!",
            "L'histoire secrète derrière la progression de l'IA",
            "Le 21 juillet 1913 _ Prières et méditations, La Mère",
            "Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...)",
          ];

          List<String> audioSubTitles = [
            "0:24:21.7 9.84 MB at 510 KB/sec on 24/02/2025 at 13:27",
            "0:22:57.8 8.72 MB at 203 KB/sec on 24/02/2025 at 13:16",
            "0:00:58.7 359 KB at 89 KB/sec on 13/02/2025 at 10:43",
            "0:22:57.8 8.72 MB at 2.14 MB/sec on 13/02/2025 at 08:30",
          ];

          _verifyRestoredPlaylistAndAudio(
            tester: tester,
            selectedPlaylistTitle: 'A restaurer',
            playlistsTitles: playlistsTitles,
            audioTitles: audioTitles,
            audioSubTitles: audioSubTitles,
          );

          // Now verify local playlist as well !

          audioTitles = [
            "Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage!",
          ];

          audioSubTitles = [
            "0:24:21.8 8.92 MB at 1.62 MB/sec on 13/02/2025 at 08:30",
          ];

          await IntegrationTestUtil.selectPlaylist(
            tester: tester,
            playlistToSelectTitle: 'local',
          );

          _verifyRestoredPlaylistAndAudio(
            tester: tester,
            selectedPlaylistTitle: 'local',
            playlistsTitles: playlistsTitles,
            audioTitles: audioTitles,
            audioSubTitles: audioSubTitles,
          );

          // Now verify 'S8 audio' playlist as well !

          // audioTitles = [
          //   "Quand Aurélien Barrau va dans une école de management",
          //   "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...",
          //   "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          //   "La surpopulation mondiale par Jancovici et Barrau",
          // ];

          // audioSubTitles = [
          //   "0:17:59.0. 6.58 MB at 1.80 MB/sec on 22/07/2024 at 08:11.",
          //   "1:17:53.6. 28.50 MB at 1.63 MB/sec on 28/05/2024 at 13:06.",
          //   "0:06:29.0. 2.37 MB at 1.69 MB/sec on 08/01/2024 at 16:35.",
          //   "0:07:38.0 2.79 MB at 2.73 MB/sec on 07/01/2024 at 16:36",
          // ];

          // const String youtubePlaylistTitle = 'S8 audio';
          // await IntegrationTestUtil.selectPlaylist(
          //   tester: tester,
          //   playlistToSelectTitle: youtubePlaylistTitle,
          // );

          // _verifyRestoredPlaylistAndAudio(
          //   tester: tester,
          //   selectedPlaylistTitle: youtubePlaylistTitle,
          //   playlistsTitles: playlistsTitles,
          //   audioTitles: audioTitles,
          //   audioSubTitles: audioSubTitles,
          // );

          // Verify the content of the 'A restaurer' playlist dir
          // and comments and pictures dir after restoration.
          IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
            playlistTitle: 'A restaurer',
            expectedAudioFiles: [
              // Since the 'A restaurer' as well as the 'local' playlists
              // were not copied in the Android emulator but were restored
              // from the toCopyOnAndroidEmulator.zip file, the mp3 files
              // aren't available.
            ],
            expectedCommentFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.json",
              "250213-104308-Le 21 juillet 1913 _ Prières et méditations, La Mère 25-02-13.json",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.json",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json",
            ],
            expectedPictureFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.json",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.json",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json",
            ],
            doesPictureAudioMapFileNameExist: true,
            pictureFileNameOne: "Sam Altman.jpg",
            audioForPictureTitleOneLst: [
              "A restaurer|250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12",
              "A restaurer|250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12"
            ],
            pictureFileNameTwo: "Jésus mon Amour.jpg",
            audioForPictureTitleTwoLst: [
              "A restaurer|250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
            pictureFileNameThree: "Jésus je T'adore.jpg",
            audioForPictureTitleThreeLst: [
              "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
          );

          // Verify the content of the 'local' playlist dir
          // and comments and pictures dir after restoration.
          IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
            playlistTitle: 'local',
            expectedAudioFiles: [
              // Since the 'A restaurer' as well as the 'local' playlists
              // were not copied in the Android emulator but were restored
              // from the toCopyOnAndroidEmulator.zip file, the mp3 files
              // aren't available.
            ],
            expectedCommentFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json"
            ],
            expectedPictureFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json"
            ],
            doesPictureAudioMapFileNameExist: true,
            pictureFileNameOne: "Jésus je T'adore.jpg",
            audioForPictureTitleOneLst: [
              "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
          );

          // Verify the content of the 'S8 audio' playlist dir
          // and comments and pictures dir after restoration.
          // IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
          //   playlistTitle: youtubePlaylistTitle,
          //   expectedAudioFiles: [],
          //   expectedCommentFiles: [
          //     "New file name.json",
          //     "240722-081104-Quand Aurélien Barrau va dans une école de management 23-09-10.json",
          //     "240528-130636-Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité... 24-01-12.json",
          //   ],
          //   expectedPictureFiles: [],
          //   playlistRootDir: playlistRootDirName,
          // );

          // // Now, select a filter parms using the drop down button.

          // // First, tap the 'Toggle List' button to hide the playlist list.
          // await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          // await tester.pumpAndSettle();

          // // Now tap on the current dropdown button item to open the dropdown
          // // button items list

          // Finder dropDownButtonFinder =
          //     find.byKey(const Key('sort_filter_parms_dropdown_button'));

          // Finder dropDownButtonTextFinder = find.descendant(
          //   of: dropDownButtonFinder,
          //   matching: find.byType(Text),
          // );

          // await tester.tap(dropDownButtonTextFinder);
          // await tester.pumpAndSettle();

          // // And find the 'commented_7MB' sort/filter item
          // Finder commentedMinus7MbDropDownTextFinder = find.text('commented_7MB').last;
          // await tester.tap(commentedMinus7MbDropDownTextFinder);
          // await tester.pumpAndSettle();

          // // Re-tap the 'Toggle List' button to display the playlist list.
          // await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          // await tester.pumpAndSettle();

          // // Execute the redownload filtered audio menu by clicking first on
          // // the 'Filtered Audio Actions ...' playlist menu item and then
          // // on the 'Redownload Filtered Audio ...' sub-menu item.
          // await IntegrationTestUtil.typeOnPlaylistSubMenuItem(
          //   tester: tester,
          //   playlistTitle: youtubePlaylistTitle,
          //   playlistSubMenuKeyStr: 'popup_menu_redownload_filtered_audio',
          // );

          // // Add a delay to allow the download to finish.
          // for (int i = 0; i < 5; i++) {
          //   await Future.delayed(const Duration(seconds: 2));
          //   await tester.pumpAndSettle();
          // }

          // // Verifying and closing the confirm dialog

          // // await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
          // //   tester: tester,
          // //   confirmDialogTitleOne:
          // //       "Delete audio's filtered by \"\" parms from playlist \"\"",
          // //   confirmDialogMessage:
          // //       "Audio's to delete number: 2,\nCorresponding total file size: 7.37 MB,\nCorresponding total duration: 00:20:08.",
          // //   confirmOrCancelAction: true, // Confirm button is tapped
          // // );

          // // Tap the 'Toggle List' button to hide the playlist list.
          // await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          // await tester.pumpAndSettle();

          // // Now, select the 'default' filter parms using the drop down button.

          // // Now tap on the current dropdown button item to open the dropdown
          // // button items list

          // dropDownButtonFinder =
          //     find.byKey(const Key('sort_filter_parms_dropdown_button'));

          // dropDownButtonTextFinder = find.descendant(
          //   of: dropDownButtonFinder,
          //   matching: find.byType(Text),
          // );

          // await tester.tap(dropDownButtonTextFinder);
          // await tester.pumpAndSettle();

          // // And find the 'default' sort/filter item
          // Finder defaultDropDownTextFinder = find.text('default').last;
          // await tester.tap(defaultDropDownTextFinder);
          // await tester.pumpAndSettle();

          // // Now we want to tap the popup menu of the Audio ListTile
          // // "audio learn test short video one"

          // // First, find the Audio sublist ListTile Text widget
          // const String audioTitle =
          //     'Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...';
          // final Finder targetAudioListTileTextWidgetFinder = find.text(audioTitle);

          // // Then obtain the Audio ListTile widget enclosing the Text widget by
          // // finding its ancestor
          // final Finder targetAudioListTileWidgetFinder = find.ancestor(
          //   of: targetAudioListTileTextWidgetFinder,
          //   matching: find.byType(ListTile),
          // );

          // // Now find the leading menu icon button of the Audio ListTile and tap
          // // on it
          // final Finder targetAudioListTileLeadingMenuIconButton = find.descendant(
          //   of: targetAudioListTileWidgetFinder,
          //   matching: find.byIcon(Icons.menu),
          // );

          // // Tap the leading menu icon button to open the popup menu
          // await tester.tap(targetAudioListTileLeadingMenuIconButton);
          // await tester.pumpAndSettle();

          // // Now find the popup menu item and tap on it
          // final Finder popupDisplayAudioInfoMenuItemFinder =
          //     find.byKey(const Key("popup_menu_redownload_delete_audio"));

          // await tester.tap(popupDisplayAudioInfoMenuItemFinder);
          // await tester.pumpAndSettle();

          // await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          //   tester: tester,
          //   warningDialogMessage:
          //       "The audio \"$audioTitle\" was redownloaded in the playlist \"$youtubePlaylistTitle\".",
          //   isWarningConfirming: true,
          // );

          // // Verify the content of the 'S8 audio' playlist dir
          // // and comments and pictures dir after redownloading
          // // filtered audio's by 'commented_7MB' SF parms as well
          // // as redownloading single audio 'Interview de Chat GPT
          // // - IA, intelligence, philosophie, géopolitique,
          // // post-vérité...'.
          // IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
          //   playlistTitle: 'S8 audio',
          //   expectedAudioFiles: [
          //     "240528-130636-Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité... 24-01-12.mp3",
          //     "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
          //     "240722-081104-Quand Aurélien Barrau va dans une école de management 23-09-10.mp3",
          //   ],
          //   expectedCommentFiles: [
          //     "240528-130636-Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité... 24-01-12.json",
          //     "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.json",
          //     "240722-081104-Quand Aurélien Barrau va dans une école de management 23-09-10.json",
          //     "New file name.json",
          //   ],
          //   expectedPictureFiles: [],
          //   playlistRootDir: playlistRootDirName,
          // );
        });
        testWidgets(
            '''Not replace existing playlist. Restore Windows zip to Windows application in which
           an existing playlist is selected. Then, select a SF parm and redownload
           the filtered audio. Finally, redownload an individual not playable
           audio.''', (tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String restorableZipFileName =
              'Windows audioLearn_2025-05-11_13_16.zip';

          // Copy the integration test data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}restore_zip_existing_playlist_selected_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          // Since we have to use a mock AudioDownloadVM to add the
          // youtube playlist, we can not use app.main() to start the
          // app because app.main() uses the real AudioDownloadVM
          // and we don't want to make the main.dart file dependent
          // of a mock class. So we have to start the app by hand,
          // what IntegrationTestUtil.launchExpandablePlaylistListView
          // does.

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
            isTest: true,
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          WarningMessageVM warningMessageVM = WarningMessageVM();

          // The mockAudioDownloadVM will be later used to simulate
          // redownloading not playable files after having restored
          // the playlists, comments and settings from the zip file.
          MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
            warningMessageVM: warningMessageVM,
            settingsDataService: settingsDataService,
          );

          AudioDownloadVM audioDownloadVM = AudioDownloadVM(
            warningMessageVM: warningMessageVM,
            settingsDataService: settingsDataService,
          );

          PlaylistListVM playlistListVM = PlaylistListVM(
            warningMessageVM: warningMessageVM,
            audioDownloadVM: mockAudioDownloadVM,
            commentVM: CommentVM(),
            pictureVM: PictureVM(
              settingsDataService: settingsDataService,
            ),
            settingsDataService: settingsDataService,
          );

          // calling getUpToDateSelectablePlaylists() loads all the
          // playlist json files from the app dir and so enables
          // playlistListVM to know which playlists are
          // selected and which are not
          playlistListVM.getUpToDateSelectablePlaylists();

          AudioPlayerVM audioPlayerVM = AudioPlayerVM(
            settingsDataService: settingsDataService,
            playlistListVM: playlistListVM,
            commentVM: CommentVM(),
          );

          DateFormatVM dateFormatVM = DateFormatVM(
            settingsDataService: settingsDataService,
          );

          await IntegrationTestUtil
              .launchIntegrTestAppEnablingInternetAccessWithMock(
            tester: tester,
            audioDownloadVM: audioDownloadVM,
            settingsDataService: settingsDataService,
            playlistListVM: playlistListVM,
            warningMessageVM: warningMessageVM,
            audioPlayerVM: audioPlayerVM,
            dateFormatVM: dateFormatVM,
          );

          // Verify the content of the 'A restaurer' playlist dir
          // and comments and pictures dir before restoring.
          IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
            playlistTitle: 'A restaurer',
            expectedAudioFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.mp3",
              "250213-104308-Le 21 juillet 1913 _ Prières et méditations, La Mère 25-02-13.mp3",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.mp3",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.mp3",
            ],
            expectedCommentFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.json",
              "250213-104308-Le 21 juillet 1913 _ Prières et méditations, La Mère 25-02-13.json",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.json",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json",
            ],
            expectedPictureFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.json",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.json",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json",
            ],
            doesPictureAudioMapFileNameExist: true,
            pictureFileNameOne: "Sam Altman.jpg",
            audioForPictureTitleOneLst: [
              "A restaurer|250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12",
              "A restaurer|250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12"
            ],
            pictureFileNameTwo: "Jésus mon Amour.jpg",
            audioForPictureTitleTwoLst: [
              "A restaurer|250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
            pictureFileNameThree: "Jésus je T'adore.jpg",
            audioForPictureTitleThreeLst: [
              "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
          );

          // Verify the content of the 'local' playlist dir
          // and comments and pictures dir before restoring.
          IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
            playlistTitle: 'local',
            expectedAudioFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.mp3"
            ],
            expectedCommentFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json"
            ],
            expectedPictureFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json"
            ],
            doesPictureAudioMapFileNameExist: true,
            pictureFileNameOne: "Jésus je T'adore.jpg",
            audioForPictureTitleOneLst: [
              "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
          );

          // Replace the platform instance with your mock
          MockFilePicker mockFilePicker = MockFilePicker();
          FilePicker.platform = mockFilePicker;

          mockFilePicker.setSelectedFiles([
            PlatformFile(
                name: restorableZipFileName,
                path:
                    '$kApplicationPathWindowsTest${path.separator}$restorableZipFileName',
                size: 12828),
          ]);

          // Execute the 'Restore Playlists, Comments and Settings from Zip
          // File ...' menu without replacing the existing playlists.
          await IntegrationTestUtil.executeRestorePlaylists(
            tester: tester,
            doReplaceExistingPlaylists: false,
          );

          // Verify the displayed warning confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                'Restored 0 playlist, 0 comment and 0 picture JSON files as well as the application settings from "C:\\development\\flutter\\audiolearn\\test\\data\\audio\\$restorableZipFileName".',
            isWarningConfirming: true,
            warningTitle: 'CONFIRMATION',
          );

          // Verifying the existing and the restored playlists
          // list as well as the selected playlist 'A restaurer'
          // displayed audio titles and subtitles.

          List<String> playlistsTitles = [
            "A restaurer",
            "local",
          ];

          List<String> audioTitles = [
            "Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage!",
            "L'histoire secrète derrière la progression de l'IA",
            "Le 21 juillet 1913 _ Prières et méditations, La Mère",
            "Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...)",
          ];

          List<String> audioSubTitles = [
            "0:24:21.7 9.84 MB at 510 KB/sec on 24/02/2025 at 13:27",
            "0:22:57.8 8.72 MB at 203 KB/sec on 24/02/2025 at 13:16",
            "0:00:58.7 359 KB at 89 KB/sec on 13/02/2025 at 10:43",
            "0:22:57.8 8.72 MB at 2.14 MB/sec on 13/02/2025 at 08:30",
          ];

          _verifyRestoredPlaylistAndAudio(
            tester: tester,
            selectedPlaylistTitle: 'A restaurer',
            playlistsTitles: playlistsTitles,
            audioTitles: audioTitles,
            audioSubTitles: audioSubTitles,
          );

          // Now verify local playlist as well !

          audioTitles = [
            "Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage!",
          ];

          audioSubTitles = [
            "0:24:21.8 8.92 MB at 1.62 MB/sec on 13/02/2025 at 08:30",
          ];

          await IntegrationTestUtil.selectPlaylist(
            tester: tester,
            playlistToSelectTitle: 'local',
          );

          _verifyRestoredPlaylistAndAudio(
            tester: tester,
            selectedPlaylistTitle: 'local',
            playlistsTitles: playlistsTitles,
            audioTitles: audioTitles,
            audioSubTitles: audioSubTitles,
          );

          // Now verify 'S8 audio' playlist as well !

          // audioTitles = [
          //   "Quand Aurélien Barrau va dans une école de management",
          //   "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...",
          //   "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          //   "La surpopulation mondiale par Jancovici et Barrau",
          // ];

          // audioSubTitles = [
          //   "0:17:59.0. 6.58 MB at 1.80 MB/sec on 22/07/2024 at 08:11.",
          //   "1:17:53.6. 28.50 MB at 1.63 MB/sec on 28/05/2024 at 13:06.",
          //   "0:06:29.0. 2.37 MB at 1.69 MB/sec on 08/01/2024 at 16:35.",
          //   "0:07:38.0 2.79 MB at 2.73 MB/sec on 07/01/2024 at 16:36",
          // ];

          // const String youtubePlaylistTitle = 'S8 audio';
          // await IntegrationTestUtil.selectPlaylist(
          //   tester: tester,
          //   playlistToSelectTitle: youtubePlaylistTitle,
          // );

          // _verifyRestoredPlaylistAndAudio(
          //   tester: tester,
          //   selectedPlaylistTitle: youtubePlaylistTitle,
          //   playlistsTitles: playlistsTitles,
          //   audioTitles: audioTitles,
          //   audioSubTitles: audioSubTitles,
          // );

          // Verify the content of the 'A restaurer' playlist dir
          // and comments and pictures dir after restoration.
          IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
            playlistTitle: 'A restaurer',
            expectedAudioFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.mp3",
              "250213-104308-Le 21 juillet 1913 _ Prières et méditations, La Mère 25-02-13.mp3",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.mp3",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.mp3",
            ],
            expectedCommentFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.json",
              "250213-104308-Le 21 juillet 1913 _ Prières et méditations, La Mère 25-02-13.json",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.json",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json",
            ],
            expectedPictureFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.json",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.json",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json",
            ],
            doesPictureAudioMapFileNameExist: true,
            pictureFileNameOne: "Sam Altman.jpg",
            audioForPictureTitleOneLst: [
              "A restaurer|250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12",
              "A restaurer|250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12"
            ],
            pictureFileNameTwo: "Jésus mon Amour.jpg",
            audioForPictureTitleTwoLst: [
              "A restaurer|250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
            pictureFileNameThree: "Jésus je T'adore.jpg",
            audioForPictureTitleThreeLst: [
              "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
          );

          // Verify the content of the 'local' playlist dir
          // and comments and pictures dir after restoration.
          IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
            playlistTitle: 'local',
            expectedAudioFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.mp3"
            ],
            expectedCommentFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json"
            ],
            expectedPictureFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json"
            ],
            doesPictureAudioMapFileNameExist: true,
            pictureFileNameOne: "Jésus je T'adore.jpg",
            audioForPictureTitleOneLst: [
              "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
          );

          // Verify the content of the 'S8 audio' playlist dir
          // and comments and pictures dir after restoration.
          // IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
          //   playlistTitle: youtubePlaylistTitle,
          //   expectedAudioFiles: [],
          //   expectedCommentFiles: [
          //     "New file name.json",
          //     "240722-081104-Quand Aurélien Barrau va dans une école de management 23-09-10.json",
          //     "240528-130636-Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité... 24-01-12.json",
          //   ],
          //   expectedPictureFiles: [],
          //   playlistRootDir: playlistRootDirName,
          // );

          // Now, select a filter parms using the drop down button.

          // First, tap the 'Toggle List' button to hide the playlist list.
          // await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          // await tester.pumpAndSettle();

          // // Now tap on the current dropdown button item to open the dropdown
          // // button items list

          // Finder dropDownButtonFinder =
          //     find.byKey(const Key('sort_filter_parms_dropdown_button'));

          // Finder dropDownButtonTextFinder = find.descendant(
          //   of: dropDownButtonFinder,
          //   matching: find.byType(Text),
          // );

          // await tester.tap(dropDownButtonTextFinder);
          // await tester.pumpAndSettle();

          // // And find the 'commented_7MB' sort/filter item
          // Finder commentedMinus7MbDropDownTextFinder = find.text('commented_7MB').last;
          // await tester.tap(commentedMinus7MbDropDownTextFinder);
          // await tester.pumpAndSettle();

          // // Re-tap the 'Toggle List' button to display the playlist list.
          // await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          // await tester.pumpAndSettle();

          // // Execute the redownload filtered audio menu by clicking first on
          // // the 'Filtered Audio Actions ...' playlist menu item and then
          // // on the 'Redownload Filtered Audio ...' sub-menu item.
          // await IntegrationTestUtil.typeOnPlaylistSubMenuItem(
          //   tester: tester,
          //   playlistTitle: youtubePlaylistTitle,
          //   playlistSubMenuKeyStr: 'popup_menu_redownload_filtered_audio',
          // );

          // // Add a delay to allow the download to finish.
          // for (int i = 0; i < 5; i++) {
          //   await Future.delayed(const Duration(seconds: 2));
          //   await tester.pumpAndSettle();
          // }

          // // Verifying and closing the confirm dialog

          // // await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
          // //   tester: tester,
          // //   confirmDialogTitleOne:
          // //       "Delete audio's filtered by \"\" parms from playlist \"\"",
          // //   confirmDialogMessage:
          // //       "Audio's to delete number: 2,\nCorresponding total file size: 7.37 MB,\nCorresponding total duration: 00:20:08.",
          // //   confirmOrCancelAction: true, // Confirm button is tapped
          // // );

          // // Tap the 'Toggle List' button to hide the playlist list.
          // await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          // await tester.pumpAndSettle();

          // // Now, select the 'default' filter parms using the drop down button.

          // // Now tap on the current dropdown button item to open the dropdown
          // // button items list

          // dropDownButtonFinder =
          //     find.byKey(const Key('sort_filter_parms_dropdown_button'));

          // dropDownButtonTextFinder = find.descendant(
          //   of: dropDownButtonFinder,
          //   matching: find.byType(Text),
          // );

          // await tester.tap(dropDownButtonTextFinder);
          // await tester.pumpAndSettle();

          // // And find the 'default' sort/filter item
          // Finder defaultDropDownTextFinder = find.text('default').last;
          // await tester.tap(defaultDropDownTextFinder);
          // await tester.pumpAndSettle();

          // // Now we want to tap the popup menu of the Audio ListTile
          // // "audio learn test short video one"

          // // First, find the Audio sublist ListTile Text widget
          // const String audioTitle =
          //     'Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...';
          // final Finder targetAudioListTileTextWidgetFinder = find.text(audioTitle);

          // // Then obtain the Audio ListTile widget enclosing the Text widget by
          // // finding its ancestor
          // final Finder targetAudioListTileWidgetFinder = find.ancestor(
          //   of: targetAudioListTileTextWidgetFinder,
          //   matching: find.byType(ListTile),
          // );

          // // Now find the leading menu icon button of the Audio ListTile and tap
          // // on it
          // final Finder targetAudioListTileLeadingMenuIconButton = find.descendant(
          //   of: targetAudioListTileWidgetFinder,
          //   matching: find.byIcon(Icons.menu),
          // );

          // // Tap the leading menu icon button to open the popup menu
          // await tester.tap(targetAudioListTileLeadingMenuIconButton);
          // await tester.pumpAndSettle();

          // // Now find the popup menu item and tap on it
          // final Finder popupDisplayAudioInfoMenuItemFinder =
          //     find.byKey(const Key("popup_menu_redownload_delete_audio"));

          // await tester.tap(popupDisplayAudioInfoMenuItemFinder);
          // await tester.pumpAndSettle();

          // await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          //   tester: tester,
          //   warningDialogMessage:
          //       "The audio \"$audioTitle\" was redownloaded in the playlist \"$youtubePlaylistTitle\".",
          //   isWarningConfirming: true,
          // );

          // // Verify the content of the 'S8 audio' playlist dir
          // // and comments and pictures dir after redownloading
          // // filtered audio's by 'commented_7MB' SF parms as well
          // // as redownloading single audio 'Interview de Chat GPT
          // // - IA, intelligence, philosophie, géopolitique,
          // // post-vérité...'.
          // IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
          //   playlistTitle: 'S8 audio',
          //   expectedAudioFiles: [
          //     "240528-130636-Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité... 24-01-12.mp3",
          //     "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
          //     "240722-081104-Quand Aurélien Barrau va dans une école de management 23-09-10.mp3",
          //   ],
          //   expectedCommentFiles: [
          //     "240528-130636-Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité... 24-01-12.json",
          //     "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.json",
          //     "240722-081104-Quand Aurélien Barrau va dans une école de management 23-09-10.json",
          //     "New file name.json",
          //   ],
          //   expectedPictureFiles: [],
          //   playlistRootDir: playlistRootDirName,
          // );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
      });
      group(
          'Restored selected playlist is different from the before restoration selected playlist.',
          () {
        testWidgets(
            '''Replace existing playlist. Restore Windows zip to Windows application in which
           an existing playlist is selected. Then, select a SF parm and redownload the
           filtered audio. Finally, redownload an individual not playable audio.''',
            (tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String restorableZipFileName =
              'Windows audioLearn_2025-05-11_13_16.zip';

          // Copy the integration test data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}restore_zip_existing_playlist_selected_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          // Since we have to use a mock AudioDownloadVM to add the
          // youtube playlist, we can not use app.main() to start the
          // app because app.main() uses the real AudioDownloadVM
          // and we don't want to make the main.dart file dependent
          // of a mock class. So we have to start the app by hand,
          // what IntegrationTestUtil.launchExpandablePlaylistListView
          // does.

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
            isTest: true,
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          WarningMessageVM warningMessageVM = WarningMessageVM();

          // The mockAudioDownloadVM will be later used to simulate
          // redownloading not playable files after having restored
          // the playlists, comments and settings from the zip file.
          MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
            warningMessageVM: warningMessageVM,
            settingsDataService: settingsDataService,
          );

          AudioDownloadVM audioDownloadVM = AudioDownloadVM(
            warningMessageVM: warningMessageVM,
            settingsDataService: settingsDataService,
          );

          PlaylistListVM playlistListVM = PlaylistListVM(
            warningMessageVM: warningMessageVM,
            audioDownloadVM: mockAudioDownloadVM,
            commentVM: CommentVM(),
            pictureVM: PictureVM(
              settingsDataService: settingsDataService,
            ),
            settingsDataService: settingsDataService,
          );

          // calling getUpToDateSelectablePlaylists() loads all the
          // playlist json files from the app dir and so enables
          // playlistListVM to know which playlists are
          // selected and which are not
          playlistListVM.getUpToDateSelectablePlaylists();

          AudioPlayerVM audioPlayerVM = AudioPlayerVM(
            settingsDataService: settingsDataService,
            playlistListVM: playlistListVM,
            commentVM: CommentVM(),
          );

          DateFormatVM dateFormatVM = DateFormatVM(
            settingsDataService: settingsDataService,
          );

          await IntegrationTestUtil
              .launchIntegrTestAppEnablingInternetAccessWithMock(
            tester: tester,
            audioDownloadVM: audioDownloadVM,
            settingsDataService: settingsDataService,
            playlistListVM: playlistListVM,
            warningMessageVM: warningMessageVM,
            audioPlayerVM: audioPlayerVM,
            dateFormatVM: dateFormatVM,
          );

          // Select the 'local' playlist which be restored from a zip
          // in which the 'A restaurer' playlist is selected.
          await IntegrationTestUtil.selectPlaylist(
            tester: tester,
            playlistToSelectTitle: 'local',
          );

          // Verify the content of the 'A restaurer' playlist dir
          // and comments and pictures dir before restoring.
          IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
            playlistTitle: 'A restaurer',
            expectedAudioFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.mp3",
              "250213-104308-Le 21 juillet 1913 _ Prières et méditations, La Mère 25-02-13.mp3",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.mp3",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.mp3",
            ],
            expectedCommentFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.json",
              "250213-104308-Le 21 juillet 1913 _ Prières et méditations, La Mère 25-02-13.json",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.json",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json",
            ],
            expectedPictureFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.json",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.json",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json",
            ],
            doesPictureAudioMapFileNameExist: true,
            pictureFileNameOne: "Sam Altman.jpg",
            audioForPictureTitleOneLst: [
              "A restaurer|250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12",
              "A restaurer|250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12"
            ],
            pictureFileNameTwo: "Jésus mon Amour.jpg",
            audioForPictureTitleTwoLst: [
              "A restaurer|250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
            pictureFileNameThree: "Jésus je T'adore.jpg",
            audioForPictureTitleThreeLst: [
              "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
          );

          // Verify the content of the 'local' playlist dir
          // and comments and pictures dir before restoring.
          IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
            playlistTitle: 'local',
            expectedAudioFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.mp3"
            ],
            expectedCommentFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json"
            ],
            expectedPictureFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json"
            ],
            doesPictureAudioMapFileNameExist: true,
            pictureFileNameOne: "Jésus je T'adore.jpg",
            audioForPictureTitleOneLst: [
              "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
          );

          // Replace the platform instance with your mock
          MockFilePicker mockFilePicker = MockFilePicker();
          FilePicker.platform = mockFilePicker;

          mockFilePicker.setSelectedFiles([
            PlatformFile(
                name: restorableZipFileName,
                path:
                    '$kApplicationPathWindowsTest${path.separator}$restorableZipFileName',
                size: 12828),
          ]);

          // Verify that the before restoration selected playlist is 'local'.
          IntegrationTestUtil.verifyPlaylistSelection(
            tester: tester,
            playlistTitle: 'local',
            isSelected: true,
          );

          // Execute the 'Restore Playlists, Comments and Settings from Zip
          // File ...' menu with the 'Replace existing playlists' option
          // selected.
          await IntegrationTestUtil.executeRestorePlaylists(
            tester: tester,
            doReplaceExistingPlaylists: true,
          );

          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Verify the displayed warning confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                'Restored 2 playlist, 0 comment and 4 picture JSON files as well as the application settings from "C:\\development\\flutter\\audiolearn\\test\\data\\audio\\$restorableZipFileName".',
            isWarningConfirming: true,
            warningTitle: 'CONFIRMATION',
          );

          // Verify that the after restoration selected playlist is still
          // 'local'.
          IntegrationTestUtil.verifyPlaylistSelection(
            tester: tester,
            playlistTitle: 'local',
            isSelected: true,
          );

          // Verify that the after restoration selected playlist is not
          // 'A restaurer'. The 'A restaurer' playlist was selected in the
          // restoration zip file.
          IntegrationTestUtil.verifyPlaylistSelection(
            tester: tester,
            playlistTitle: 'A restaurer',
            isSelected: false,
          );

          List<String> playlistsTitles = [
            "A restaurer",
            "local",
          ];
          // Now verify local playlist as well !

          List<String> audioTitles = [
            "Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage!",
          ];

          List<String> audioSubTitles = [
            "0:24:21.8 8.92 MB at 1.62 MB/sec on 13/02/2025 at 08:30",
          ];

          _verifyRestoredPlaylistAndAudio(
            tester: tester,
            selectedPlaylistTitle: 'local',
            playlistsTitles: playlistsTitles,
            audioTitles: audioTitles,
            audioSubTitles: audioSubTitles,
          );

          // Verifying the existing and the restored playlists
          // list as well as the selected playlist 'local'
          // displayed audio titles and subtitles.

          audioTitles = [
            "Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage!",
            "L'histoire secrète derrière la progression de l'IA",
            "Le 21 juillet 1913 _ Prières et méditations, La Mère",
            "Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...)",
          ];

          audioSubTitles = [
            "0:24:21.7 9.84 MB at 510 KB/sec on 24/02/2025 at 13:27",
            "0:22:57.8 8.72 MB at 203 KB/sec on 24/02/2025 at 13:16",
            "0:00:58.7 359 KB at 89 KB/sec on 13/02/2025 at 10:43",
            "0:22:57.8 8.72 MB at 2.14 MB/sec on 13/02/2025 at 08:30",
          ];

          await IntegrationTestUtil.selectPlaylist(
            tester: tester,
            playlistToSelectTitle: 'A restaurer',
          );

          _verifyRestoredPlaylistAndAudio(
            tester: tester,
            selectedPlaylistTitle: 'A restaurer',
            playlistsTitles: playlistsTitles,
            audioTitles: audioTitles,
            audioSubTitles: audioSubTitles,
          );

          // Now verify 'S8 audio' playlist as well !

          // audioTitles = [
          //   "Quand Aurélien Barrau va dans une école de management",
          //   "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...",
          //   "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          //   "La surpopulation mondiale par Jancovici et Barrau",
          // ];

          // audioSubTitles = [
          //   "0:17:59.0. 6.58 MB at 1.80 MB/sec on 22/07/2024 at 08:11.",
          //   "1:17:53.6. 28.50 MB at 1.63 MB/sec on 28/05/2024 at 13:06.",
          //   "0:06:29.0. 2.37 MB at 1.69 MB/sec on 08/01/2024 at 16:35.",
          //   "0:07:38.0 2.79 MB at 2.73 MB/sec on 07/01/2024 at 16:36",
          // ];

          // const String youtubePlaylistTitle = 'S8 audio';
          // await IntegrationTestUtil.selectPlaylist(
          //   tester: tester,
          //   playlistToSelectTitle: youtubePlaylistTitle,
          // );

          // _verifyRestoredPlaylistAndAudio(
          //   tester: tester,
          //   selectedPlaylistTitle: youtubePlaylistTitle,
          //   playlistsTitles: playlistsTitles,
          //   audioTitles: audioTitles,
          //   audioSubTitles: audioSubTitles,
          // );

          // Verify the content of the 'A restaurer' playlist dir
          // and comments and pictures dir after restoration.
          IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
            playlistTitle: 'A restaurer',
            expectedAudioFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.mp3",
              "250213-104308-Le 21 juillet 1913 _ Prières et méditations, La Mère 25-02-13.mp3",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.mp3",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.mp3",
            ],
            expectedCommentFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.json",
              "250213-104308-Le 21 juillet 1913 _ Prières et méditations, La Mère 25-02-13.json",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.json",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json",
            ],
            expectedPictureFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.json",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.json",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json",
            ],
            doesPictureAudioMapFileNameExist: true,
            pictureFileNameOne: "Sam Altman.jpg",
            audioForPictureTitleOneLst: [
              "A restaurer|250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12",
              "A restaurer|250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12"
            ],
            pictureFileNameTwo: "Jésus mon Amour.jpg",
            audioForPictureTitleTwoLst: [
              "A restaurer|250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
            pictureFileNameThree: "Jésus je T'adore.jpg",
            audioForPictureTitleThreeLst: [
              "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
          );

          // Verify the content of the 'local' playlist dir
          // and comments and pictures dir after restoration.
          IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
            playlistTitle: 'local',
            expectedAudioFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.mp3"
            ],
            expectedCommentFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json"
            ],
            expectedPictureFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json"
            ],
            doesPictureAudioMapFileNameExist: true,
            pictureFileNameOne: "Jésus je T'adore.jpg",
            audioForPictureTitleOneLst: [
              "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
          );

          // Verify the content of the 'S8 audio' playlist dir
          // and comments and pictures dir after restoration.
          // IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
          //   playlistTitle: youtubePlaylistTitle,
          //   expectedAudioFiles: [],
          //   expectedCommentFiles: [
          //     "New file name.json",
          //     "240722-081104-Quand Aurélien Barrau va dans une école de management 23-09-10.json",
          //     "240528-130636-Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité... 24-01-12.json",
          //   ],
          //   expectedPictureFiles: [],
          //   playlistRootDir: playlistRootDirName,
          // );

          // // Now, select a filter parms using the drop down button.

          // // First, tap the 'Toggle List' button to hide the playlist list.
          // await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          // await tester.pumpAndSettle();

          // // Now tap on the current dropdown button item to open the dropdown
          // // button items list

          // Finder dropDownButtonFinder =
          //     find.byKey(const Key('sort_filter_parms_dropdown_button'));

          // Finder dropDownButtonTextFinder = find.descendant(
          //   of: dropDownButtonFinder,
          //   matching: find.byType(Text),
          // );

          // await tester.tap(dropDownButtonTextFinder);
          // await tester.pumpAndSettle();

          // // And find the 'commented_7MB' sort/filter item
          // Finder commentedMinus7MbDropDownTextFinder = find.text('commented_7MB').last;
          // await tester.tap(commentedMinus7MbDropDownTextFinder);
          // await tester.pumpAndSettle();

          // // Re-tap the 'Toggle List' button to display the playlist list.
          // await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          // await tester.pumpAndSettle();

          // // Execute the redownload filtered audio menu by clicking first on
          // // the 'Filtered Audio Actions ...' playlist menu item and then
          // // on the 'Redownload Filtered Audio ...' sub-menu item.
          // await IntegrationTestUtil.typeOnPlaylistSubMenuItem(
          //   tester: tester,
          //   playlistTitle: youtubePlaylistTitle,
          //   playlistSubMenuKeyStr: 'popup_menu_redownload_filtered_audio',
          // );

          // // Add a delay to allow the download to finish.
          // for (int i = 0; i < 5; i++) {
          //   await Future.delayed(const Duration(seconds: 2));
          //   await tester.pumpAndSettle();
          // }

          // // Verifying and closing the confirm dialog

          // // await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
          // //   tester: tester,
          // //   confirmDialogTitleOne:
          // //       "Delete audio's filtered by \"\" parms from playlist \"\"",
          // //   confirmDialogMessage:
          // //       "Audio's to delete number: 2,\nCorresponding total file size: 7.37 MB,\nCorresponding total duration: 00:20:08.",
          // //   confirmOrCancelAction: true, // Confirm button is tapped
          // // );

          // // Tap the 'Toggle List' button to hide the playlist list.
          // await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          // await tester.pumpAndSettle();

          // // Now, select the 'default' filter parms using the drop down button.

          // // Now tap on the current dropdown button item to open the dropdown
          // // button items list

          // dropDownButtonFinder =
          //     find.byKey(const Key('sort_filter_parms_dropdown_button'));

          // dropDownButtonTextFinder = find.descendant(
          //   of: dropDownButtonFinder,
          //   matching: find.byType(Text),
          // );

          // await tester.tap(dropDownButtonTextFinder);
          // await tester.pumpAndSettle();

          // // And find the 'default' sort/filter item
          // Finder defaultDropDownTextFinder = find.text('default').last;
          // await tester.tap(defaultDropDownTextFinder);
          // await tester.pumpAndSettle();

          // // Now we want to tap the popup menu of the Audio ListTile
          // // "audio learn test short video one"

          // // First, find the Audio sublist ListTile Text widget
          // const String audioTitle =
          //     'Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...';
          // final Finder targetAudioListTileTextWidgetFinder = find.text(audioTitle);

          // // Then obtain the Audio ListTile widget enclosing the Text widget by
          // // finding its ancestor
          // final Finder targetAudioListTileWidgetFinder = find.ancestor(
          //   of: targetAudioListTileTextWidgetFinder,
          //   matching: find.byType(ListTile),
          // );

          // // Now find the leading menu icon button of the Audio ListTile and tap
          // // on it
          // final Finder targetAudioListTileLeadingMenuIconButton = find.descendant(
          //   of: targetAudioListTileWidgetFinder,
          //   matching: find.byIcon(Icons.menu),
          // );

          // // Tap the leading menu icon button to open the popup menu
          // await tester.tap(targetAudioListTileLeadingMenuIconButton);
          // await tester.pumpAndSettle();

          // // Now find the popup menu item and tap on it
          // final Finder popupDisplayAudioInfoMenuItemFinder =
          //     find.byKey(const Key("popup_menu_redownload_delete_audio"));

          // await tester.tap(popupDisplayAudioInfoMenuItemFinder);
          // await tester.pumpAndSettle();

          // await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          //   tester: tester,
          //   warningDialogMessage:
          //       "The audio \"$audioTitle\" was redownloaded in the playlist \"$youtubePlaylistTitle\".",
          //   isWarningConfirming: true,
          // );

          // // Verify the content of the 'S8 audio' playlist dir
          // // and comments and pictures dir after redownloading
          // // filtered audio's by 'commented_7MB' SF parms as well
          // // as redownloading single audio 'Interview de Chat GPT
          // // - IA, intelligence, philosophie, géopolitique,
          // // post-vérité...'.
          // IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
          //   playlistTitle: 'S8 audio',
          //   expectedAudioFiles: [
          //     "240528-130636-Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité... 24-01-12.mp3",
          //     "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
          //     "240722-081104-Quand Aurélien Barrau va dans une école de management 23-09-10.mp3",
          //   ],
          //   expectedCommentFiles: [
          //     "240528-130636-Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité... 24-01-12.json",
          //     "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.json",
          //     "240722-081104-Quand Aurélien Barrau va dans une école de management 23-09-10.json",
          //     "New file name.json",
          //   ],
          //   expectedPictureFiles: [],
          //   playlistRootDir: playlistRootDirName,
          // );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Not replace existing playlist. Restore Windows zip to Windows application in which
           an existing playlist is selected. Then, select a SF parm and redownload
           the filtered audio. Finally, redownload an individual not playable
           audio.''', (tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String restorableZipFileName =
              'Windows audioLearn_2025-05-11_13_16.zip';

          // Copy the integration test data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}restore_zip_existing_playlist_selected_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          // Since we have to use a mock AudioDownloadVM to add the
          // youtube playlist, we can not use app.main() to start the
          // app because app.main() uses the real AudioDownloadVM
          // and we don't want to make the main.dart file dependent
          // of a mock class. So we have to start the app by hand,
          // what IntegrationTestUtil.launchExpandablePlaylistListView
          // does.

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
            isTest: true,
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          WarningMessageVM warningMessageVM = WarningMessageVM();

          // The mockAudioDownloadVM will be later used to simulate
          // redownloading not playable files after having restored
          // the playlists, comments and settings from the zip file.
          MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
            warningMessageVM: warningMessageVM,
            settingsDataService: settingsDataService,
          );

          AudioDownloadVM audioDownloadVM = AudioDownloadVM(
            warningMessageVM: warningMessageVM,
            settingsDataService: settingsDataService,
          );

          PlaylistListVM playlistListVM = PlaylistListVM(
            warningMessageVM: warningMessageVM,
            audioDownloadVM: mockAudioDownloadVM,
            commentVM: CommentVM(),
            pictureVM: PictureVM(
              settingsDataService: settingsDataService,
            ),
            settingsDataService: settingsDataService,
          );

          // calling getUpToDateSelectablePlaylists() loads all the
          // playlist json files from the app dir and so enables
          // playlistListVM to know which playlists are
          // selected and which are not
          playlistListVM.getUpToDateSelectablePlaylists();

          AudioPlayerVM audioPlayerVM = AudioPlayerVM(
            settingsDataService: settingsDataService,
            playlistListVM: playlistListVM,
            commentVM: CommentVM(),
          );

          DateFormatVM dateFormatVM = DateFormatVM(
            settingsDataService: settingsDataService,
          );

          await IntegrationTestUtil
              .launchIntegrTestAppEnablingInternetAccessWithMock(
            tester: tester,
            audioDownloadVM: audioDownloadVM,
            settingsDataService: settingsDataService,
            playlistListVM: playlistListVM,
            warningMessageVM: warningMessageVM,
            audioPlayerVM: audioPlayerVM,
            dateFormatVM: dateFormatVM,
          );

          // Select the 'local' playlist which be restored from a zip
          // in which the 'A restaurer' playlist is selected.
          await IntegrationTestUtil.selectPlaylist(
            tester: tester,
            playlistToSelectTitle: 'local',
          );

          // Verify the content of the 'A restaurer' playlist dir
          // and comments and pictures dir before restoring.
          IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
            playlistTitle: 'A restaurer',
            expectedAudioFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.mp3",
              "250213-104308-Le 21 juillet 1913 _ Prières et méditations, La Mère 25-02-13.mp3",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.mp3",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.mp3",
            ],
            expectedCommentFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.json",
              "250213-104308-Le 21 juillet 1913 _ Prières et méditations, La Mère 25-02-13.json",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.json",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json",
            ],
            expectedPictureFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.json",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.json",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json",
            ],
            doesPictureAudioMapFileNameExist: true,
            pictureFileNameOne: "Sam Altman.jpg",
            audioForPictureTitleOneLst: [
              "A restaurer|250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12",
              "A restaurer|250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12"
            ],
            pictureFileNameTwo: "Jésus mon Amour.jpg",
            audioForPictureTitleTwoLst: [
              "A restaurer|250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
            pictureFileNameThree: "Jésus je T'adore.jpg",
            audioForPictureTitleThreeLst: [
              "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
          );

          // Verify the content of the 'local' playlist dir
          // and comments and pictures dir before restoring.
          IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
            playlistTitle: 'local',
            expectedAudioFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.mp3"
            ],
            expectedCommentFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json"
            ],
            expectedPictureFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json"
            ],
            doesPictureAudioMapFileNameExist: true,
            pictureFileNameOne: "Jésus je T'adore.jpg",
            audioForPictureTitleOneLst: [
              "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
          );

          // Replace the platform instance with your mock
          MockFilePicker mockFilePicker = MockFilePicker();
          FilePicker.platform = mockFilePicker;

          mockFilePicker.setSelectedFiles([
            PlatformFile(
                name: restorableZipFileName,
                path:
                    '$kApplicationPathWindowsTest${path.separator}$restorableZipFileName',
                size: 12828),
          ]);

          // Verify that the before restoration selected playlist is 'local'.
          IntegrationTestUtil.verifyPlaylistSelection(
            tester: tester,
            playlistTitle: 'local',
            isSelected: true,
          );

          // Execute the 'Restore Playlists, Comments and Settings from Zip
          // File ...' menu without replacing the existing playlists.
          await IntegrationTestUtil.executeRestorePlaylists(
            tester: tester,
            doReplaceExistingPlaylists: false,
          );

          // Verify the displayed warning confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                'Restored 0 playlist, 0 comment and 0 picture JSON files as well as the application settings from "C:\\development\\flutter\\audiolearn\\test\\data\\audio\\$restorableZipFileName".',
            isWarningConfirming: true,
            warningTitle: 'CONFIRMATION',
          );

          // Verify that the after restoration selected playlist is still
          // 'local'.
          IntegrationTestUtil.verifyPlaylistSelection(
            tester: tester,
            playlistTitle: 'local',
            isSelected: true,
          );

          // Verify that the after restoration selected playlist is not
          // 'A restaurer'. The 'A restaurer' playlist was selected in the
          // restoration zip file.
          IntegrationTestUtil.verifyPlaylistSelection(
            tester: tester,
            playlistTitle: 'A restaurer',
            isSelected: false,
          );

          // Verifying the existing and the restored playlists
          // list as well as the selected playlist 'A restaurer'
          // displayed audio titles and subtitles.

          List<String> playlistsTitles = [
            "A restaurer",
            "local",
          ];
          // Now verify local playlist as well !

          List<String> audioTitles = [
            "Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage!",
          ];

          List<String> audioSubTitles = [
            "0:24:21.8 8.92 MB at 1.62 MB/sec on 13/02/2025 at 08:30",
          ];

          _verifyRestoredPlaylistAndAudio(
            tester: tester,
            selectedPlaylistTitle: 'local',
            playlistsTitles: playlistsTitles,
            audioTitles: audioTitles,
            audioSubTitles: audioSubTitles,
          );

          // Now verify 'S8 audio' playlist as well !

          // audioTitles = [
          //   "Quand Aurélien Barrau va dans une école de management",
          //   "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...",
          //   "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          //   "La surpopulation mondiale par Jancovici et Barrau",
          // ];

          // audioSubTitles = [
          //   "0:17:59.0. 6.58 MB at 1.80 MB/sec on 22/07/2024 at 08:11.",
          //   "1:17:53.6. 28.50 MB at 1.63 MB/sec on 28/05/2024 at 13:06.",
          //   "0:06:29.0. 2.37 MB at 1.69 MB/sec on 08/01/2024 at 16:35.",
          //   "0:07:38.0 2.79 MB at 2.73 MB/sec on 07/01/2024 at 16:36",
          // ];

          // const String youtubePlaylistTitle = 'S8 audio';
          // await IntegrationTestUtil.selectPlaylist(
          //   tester: tester,
          //   playlistToSelectTitle: youtubePlaylistTitle,
          // );

          // _verifyRestoredPlaylistAndAudio(
          //   tester: tester,
          //   selectedPlaylistTitle: youtubePlaylistTitle,
          //   playlistsTitles: playlistsTitles,
          //   audioTitles: audioTitles,
          //   audioSubTitles: audioSubTitles,
          // );

          // Verify the content of the 'A restaurer' playlist dir
          // and comments and pictures dir after restoration.
          IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
            playlistTitle: 'A restaurer',
            expectedAudioFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.mp3",
              "250213-104308-Le 21 juillet 1913 _ Prières et méditations, La Mère 25-02-13.mp3",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.mp3",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.mp3",
            ],
            expectedCommentFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.json",
              "250213-104308-Le 21 juillet 1913 _ Prières et méditations, La Mère 25-02-13.json",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.json",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json",
            ],
            expectedPictureFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.json",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.json",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json",
            ],
            doesPictureAudioMapFileNameExist: true,
            pictureFileNameOne: "Sam Altman.jpg",
            audioForPictureTitleOneLst: [
              "A restaurer|250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12",
              "A restaurer|250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12"
            ],
            pictureFileNameTwo: "Jésus mon Amour.jpg",
            audioForPictureTitleTwoLst: [
              "A restaurer|250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
            pictureFileNameThree: "Jésus je T'adore.jpg",
            audioForPictureTitleThreeLst: [
              "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
          );

          // Verify the content of the 'local' playlist dir
          // and comments and pictures dir after restoration.
          IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
            playlistTitle: 'local',
            expectedAudioFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.mp3"
            ],
            expectedCommentFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json"
            ],
            expectedPictureFiles: [
              "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json"
            ],
            doesPictureAudioMapFileNameExist: true,
            pictureFileNameOne: "Jésus je T'adore.jpg",
            audioForPictureTitleOneLst: [
              "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
          );

          // Verify the content of the 'S8 audio' playlist dir
          // and comments and pictures dir after restoration.
          // IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
          //   playlistTitle: youtubePlaylistTitle,
          //   expectedAudioFiles: [],
          //   expectedCommentFiles: [
          //     "New file name.json",
          //     "240722-081104-Quand Aurélien Barrau va dans une école de management 23-09-10.json",
          //     "240528-130636-Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité... 24-01-12.json",
          //   ],
          //   expectedPictureFiles: [],
          //   playlistRootDir: playlistRootDirName,
          // );

          // Now, select a filter parms using the drop down button.

          // First, tap the 'Toggle List' button to hide the playlist list.
          // await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          // await tester.pumpAndSettle();

          // // Now tap on the current dropdown button item to open the dropdown
          // // button items list

          // Finder dropDownButtonFinder =
          //     find.byKey(const Key('sort_filter_parms_dropdown_button'));

          // Finder dropDownButtonTextFinder = find.descendant(
          //   of: dropDownButtonFinder,
          //   matching: find.byType(Text),
          // );

          // await tester.tap(dropDownButtonTextFinder);
          // await tester.pumpAndSettle();

          // // And find the 'commented_7MB' sort/filter item
          // Finder commentedMinus7MbDropDownTextFinder = find.text('commented_7MB').last;
          // await tester.tap(commentedMinus7MbDropDownTextFinder);
          // await tester.pumpAndSettle();

          // // Re-tap the 'Toggle List' button to display the playlist list.
          // await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          // await tester.pumpAndSettle();

          // // Execute the redownload filtered audio menu by clicking first on
          // // the 'Filtered Audio Actions ...' playlist menu item and then
          // // on the 'Redownload Filtered Audio ...' sub-menu item.
          // await IntegrationTestUtil.typeOnPlaylistSubMenuItem(
          //   tester: tester,
          //   playlistTitle: youtubePlaylistTitle,
          //   playlistSubMenuKeyStr: 'popup_menu_redownload_filtered_audio',
          // );

          // // Add a delay to allow the download to finish.
          // for (int i = 0; i < 5; i++) {
          //   await Future.delayed(const Duration(seconds: 2));
          //   await tester.pumpAndSettle();
          // }

          // // Verifying and closing the confirm dialog

          // // await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
          // //   tester: tester,
          // //   confirmDialogTitleOne:
          // //       "Delete audio's filtered by \"\" parms from playlist \"\"",
          // //   confirmDialogMessage:
          // //       "Audio's to delete number: 2,\nCorresponding total file size: 7.37 MB,\nCorresponding total duration: 00:20:08.",
          // //   confirmOrCancelAction: true, // Confirm button is tapped
          // // );

          // // Tap the 'Toggle List' button to hide the playlist list.
          // await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          // await tester.pumpAndSettle();

          // // Now, select the 'default' filter parms using the drop down button.

          // // Now tap on the current dropdown button item to open the dropdown
          // // button items list

          // dropDownButtonFinder =
          //     find.byKey(const Key('sort_filter_parms_dropdown_button'));

          // dropDownButtonTextFinder = find.descendant(
          //   of: dropDownButtonFinder,
          //   matching: find.byType(Text),
          // );

          // await tester.tap(dropDownButtonTextFinder);
          // await tester.pumpAndSettle();

          // // And find the 'default' sort/filter item
          // Finder defaultDropDownTextFinder = find.text('default').last;
          // await tester.tap(defaultDropDownTextFinder);
          // await tester.pumpAndSettle();

          // // Now we want to tap the popup menu of the Audio ListTile
          // // "audio learn test short video one"

          // // First, find the Audio sublist ListTile Text widget
          // const String audioTitle =
          //     'Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...';
          // final Finder targetAudioListTileTextWidgetFinder = find.text(audioTitle);

          // // Then obtain the Audio ListTile widget enclosing the Text widget by
          // // finding its ancestor
          // final Finder targetAudioListTileWidgetFinder = find.ancestor(
          //   of: targetAudioListTileTextWidgetFinder,
          //   matching: find.byType(ListTile),
          // );

          // // Now find the leading menu icon button of the Audio ListTile and tap
          // // on it
          // final Finder targetAudioListTileLeadingMenuIconButton = find.descendant(
          //   of: targetAudioListTileWidgetFinder,
          //   matching: find.byIcon(Icons.menu),
          // );

          // // Tap the leading menu icon button to open the popup menu
          // await tester.tap(targetAudioListTileLeadingMenuIconButton);
          // await tester.pumpAndSettle();

          // // Now find the popup menu item and tap on it
          // final Finder popupDisplayAudioInfoMenuItemFinder =
          //     find.byKey(const Key("popup_menu_redownload_delete_audio"));

          // await tester.tap(popupDisplayAudioInfoMenuItemFinder);
          // await tester.pumpAndSettle();

          // await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          //   tester: tester,
          //   warningDialogMessage:
          //       "The audio \"$audioTitle\" was redownloaded in the playlist \"$youtubePlaylistTitle\".",
          //   isWarningConfirming: true,
          // );

          // // Verify the content of the 'S8 audio' playlist dir
          // // and comments and pictures dir after redownloading
          // // filtered audio's by 'commented_7MB' SF parms as well
          // // as redownloading single audio 'Interview de Chat GPT
          // // - IA, intelligence, philosophie, géopolitique,
          // // post-vérité...'.
          // IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
          //   playlistTitle: 'S8 audio',
          //   expectedAudioFiles: [
          //     "240528-130636-Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité... 24-01-12.mp3",
          //     "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
          //     "240722-081104-Quand Aurélien Barrau va dans une école de management 23-09-10.mp3",
          //   ],
          //   expectedCommentFiles: [
          //     "240528-130636-Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité... 24-01-12.json",
          //     "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.json",
          //     "240722-081104-Quand Aurélien Barrau va dans une école de management 23-09-10.json",
          //     "New file name.json",
          //   ],
          //   expectedPictureFiles: [],
          //   playlistRootDir: playlistRootDirName,
          // );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Not replace existing playlist. After first restoration where a playlist
           was selected, restore Windows zip in which a playlist is also selected. The
           result will be that the first restored selected playlist will remain being
           selected.''', (tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Since we have to use a mock AudioDownloadVM to add the
          // youtube playlist, we can not use app.main() to start the
          // app because app.main() uses the real AudioDownloadVM
          // and we don't want to make the main.dart file dependent
          // of a mock class. So we have to start the app by hand,
          // what IntegrationTestUtil.launchExpandablePlaylistListView
          // does.

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
            isTest: true,
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          WarningMessageVM warningMessageVM = WarningMessageVM();

          // The mockAudioDownloadVM will be later used to simulate
          // redownloading not playable files after having restored
          // the playlists, comments and settings from the zip file.
          MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
            warningMessageVM: warningMessageVM,
            settingsDataService: settingsDataService,
          );

          AudioDownloadVM audioDownloadVM = AudioDownloadVM(
            warningMessageVM: warningMessageVM,
            settingsDataService: settingsDataService,
          );

          PlaylistListVM playlistListVM = PlaylistListVM(
            warningMessageVM: warningMessageVM,
            audioDownloadVM: mockAudioDownloadVM,
            commentVM: CommentVM(),
            pictureVM: PictureVM(
              settingsDataService: settingsDataService,
            ),
            settingsDataService: settingsDataService,
          );

          // calling getUpToDateSelectablePlaylists() loads all the
          // playlist json files from the app dir and so enables
          // playlistListVM to know which playlists are
          // selected and which are not
          playlistListVM.getUpToDateSelectablePlaylists();

          AudioPlayerVM audioPlayerVM = AudioPlayerVM(
            settingsDataService: settingsDataService,
            playlistListVM: playlistListVM,
            commentVM: CommentVM(),
          );

          DateFormatVM dateFormatVM = DateFormatVM(
            settingsDataService: settingsDataService,
          );

          await IntegrationTestUtil
              .launchIntegrTestAppEnablingInternetAccessWithMock(
            tester: tester,
            audioDownloadVM: audioDownloadVM,
            settingsDataService: settingsDataService,
            playlistListVM: playlistListVM,
            warningMessageVM: warningMessageVM,
            audioPlayerVM: audioPlayerVM,
            dateFormatVM: dateFormatVM,
          );

          // Replace the platform instance with your mock
          MockFilePicker mockFilePicker = MockFilePicker();
          FilePicker.platform = mockFilePicker;

          const String firstRestorableZipFileName =
              'Windows Prières du Maître.zip';
          final String zipTestDirectory =
              '$kDownloadAppTestSavedDataDir${path.separator}zip_files_for_restore_tests${path.separator}';
          final String firstRestorableZipFilePathName =
              '$zipTestDirectory${path.separator}$firstRestorableZipFileName';

          mockFilePicker.setSelectedFiles([
            PlatformFile(
                name: firstRestorableZipFileName,
                path: firstRestorableZipFilePathName,
                size: 7460),
          ]);

          // Execute the 'Restore Playlists, Comments and Settings from Zip
          // File ...' menu without replacing the existing playlists.
          await IntegrationTestUtil.executeRestorePlaylists(
            tester: tester,
            doReplaceExistingPlaylists: false,
          );

          // Verify the displayed warning confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                'Restored 1 playlist, 1 comment and 1 picture JSON files as well as the application settings from "$firstRestorableZipFilePathName".',
            isWarningConfirming: true,
            warningTitle: 'CONFIRMATION',
          );

          // Verify that after the first restoration the selected
          // playlist is 'Prières du Maître'.
          IntegrationTestUtil.verifyPlaylistSelection(
            tester: tester,
            playlistTitle: 'Prières du Maître',
            isSelected: true,
          );

          const String secondRestorableZipFileName =
              'Windows audioLearn_2025-05-11_13_16.zip';
          final String secondRestorableZipFilePathName =
              '$zipTestDirectory$secondRestorableZipFileName';

          mockFilePicker.setSelectedFiles([
            PlatformFile(
                name: secondRestorableZipFileName,
                path: secondRestorableZipFilePathName,
                size: 12288),
          ]);

          // Execute the 'Restore Playlists, Comments and Settings from Zip
          // File ...' menu without replacing the existing playlists.
          await IntegrationTestUtil.executeRestorePlaylists(
            tester: tester,
            doReplaceExistingPlaylists: false,
          );

          // Verify the displayed warning confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                'Restored 2 playlist, 5 comment and 4 picture JSON files as well as the application settings from "$secondRestorableZipFilePathName".',
            isWarningConfirming: true,
            warningTitle: 'CONFIRMATION',
          );

          // Verify that after the second restoration the selected
          // playlist is still 'Prières du Maître'.
          IntegrationTestUtil.verifyPlaylistSelection(
            tester: tester,
            playlistTitle: 'Prières du Maître',
            isSelected: true,
          );

          // Verify that the after the second restoration the selected
          // is not 'A restaurer'. The 'A restaurer' playlist was selected
          // in the restoration zip file.
          IntegrationTestUtil.verifyPlaylistSelection(
            tester: tester,
            playlistTitle: 'A restaurer',
            isSelected: false,
          );

          // Verifying the restored playlists list as well as their
          // displayed audio titles and subtitles.

          List<String> playlistsTitles = [
            "Prières du Maître",
            "A restaurer",
            "local",
          ];

          // Verify 'Prières du Maître' playlist

          List<String> audioTitles = [
            "Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          ];

          List<String> audioSubTitles = [
            "0:02:39.6 2.59 MB at 502 KB/sec on 11/02/2025 at 09:00",
          ];

          _verifyRestoredPlaylistAndAudio(
            tester: tester,
            selectedPlaylistTitle: 'Prières du Maître',
            playlistsTitles: playlistsTitles,
            audioTitles: audioTitles,
            audioSubTitles: audioSubTitles,
          );

          // Now verify 'local' playlist

          // Select the 'local' playlist which was restored.
          await IntegrationTestUtil.selectPlaylist(
            tester: tester,
            playlistToSelectTitle: 'local',
          );

          audioTitles = [
            "Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage!",
          ];

          audioSubTitles = [
            "0:24:21.8 8.92 MB at 1.62 MB/sec on 13/02/2025 at 08:30",
          ];

          _verifyRestoredPlaylistAndAudio(
            tester: tester,
            selectedPlaylistTitle: 'local',
            playlistsTitles: playlistsTitles,
            audioTitles: audioTitles,
            audioSubTitles: audioSubTitles,
          );

          // And verify the 'A restaurer' playlist

          // Select the 'A restaurer' playlist
          await IntegrationTestUtil.selectPlaylist(
            tester: tester,
            playlistToSelectTitle: 'A restaurer',
          );

          IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
            playlistTitle: 'A restaurer',
            expectedAudioFiles: [],
            expectedCommentFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.json",
              "250213-104308-Le 21 juillet 1913 _ Prières et méditations, La Mère 25-02-13.json",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.json",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json",
            ],
            expectedPictureFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.json",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.json",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json",
            ],
            doesPictureAudioMapFileNameExist: true,
            pictureFileNameOne: 'Jésus le Dieu vivant.jpg',
            audioForPictureTitleOneLst: [
              "Prières du Maître|Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
              "A restaurer|250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09",
              "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09",
            ],
            pictureFileNameTwo: "Sam Altman.jpg",
            audioForPictureTitleTwoLst: [
              "A restaurer|250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12",
              "A restaurer|250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12"
            ],
            pictureFileNameThree: "Jésus mon Amour.jpg",
            audioForPictureTitleThreeLst: [
              "A restaurer|250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
            pictureFileNameFour: "Jésus je T'adore.jpg",
            audioForPictureTitleFourLst: [
              "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Replace existing playlist. After first restoration where a playlist
           was selected, restore Windows zip in which a playlist is also selected. The
           result will be that the first restored selected playlist will remain being
           selected.''', (tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Since we have to use a mock AudioDownloadVM to add the
          // youtube playlist, we can not use app.main() to start the
          // app because app.main() uses the real AudioDownloadVM
          // and we don't want to make the main.dart file dependent
          // of a mock class. So we have to start the app by hand,
          // what IntegrationTestUtil.launchExpandablePlaylistListView
          // does.

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
            isTest: true,
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          WarningMessageVM warningMessageVM = WarningMessageVM();

          // The mockAudioDownloadVM will be later used to simulate
          // redownloading not playable files after having restored
          // the playlists, comments and settings from the zip file.
          MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
            warningMessageVM: warningMessageVM,
            settingsDataService: settingsDataService,
          );

          AudioDownloadVM audioDownloadVM = AudioDownloadVM(
            warningMessageVM: warningMessageVM,
            settingsDataService: settingsDataService,
          );

          PlaylistListVM playlistListVM = PlaylistListVM(
            warningMessageVM: warningMessageVM,
            audioDownloadVM: mockAudioDownloadVM,
            commentVM: CommentVM(),
            pictureVM: PictureVM(
              settingsDataService: settingsDataService,
            ),
            settingsDataService: settingsDataService,
          );

          // calling getUpToDateSelectablePlaylists() loads all the
          // playlist json files from the app dir and so enables
          // playlistListVM to know which playlists are
          // selected and which are not
          playlistListVM.getUpToDateSelectablePlaylists();

          AudioPlayerVM audioPlayerVM = AudioPlayerVM(
            settingsDataService: settingsDataService,
            playlistListVM: playlistListVM,
            commentVM: CommentVM(),
          );

          DateFormatVM dateFormatVM = DateFormatVM(
            settingsDataService: settingsDataService,
          );

          await IntegrationTestUtil
              .launchIntegrTestAppEnablingInternetAccessWithMock(
            tester: tester,
            audioDownloadVM: audioDownloadVM,
            settingsDataService: settingsDataService,
            playlistListVM: playlistListVM,
            warningMessageVM: warningMessageVM,
            audioPlayerVM: audioPlayerVM,
            dateFormatVM: dateFormatVM,
          );

          // Replace the platform instance with your mock
          MockFilePicker mockFilePicker = MockFilePicker();
          FilePicker.platform = mockFilePicker;

          const String firstRestorableZipFileName =
              'Windows Prières du Maître.zip';
          final String zipTestDirectory =
              '$kDownloadAppTestSavedDataDir${path.separator}zip_files_for_restore_tests${path.separator}';
          final String firstRestorableZipFilePathName =
              '$zipTestDirectory${path.separator}$firstRestorableZipFileName';

          mockFilePicker.setSelectedFiles([
            PlatformFile(
                name: firstRestorableZipFileName,
                path: firstRestorableZipFilePathName,
                size: 7460),
          ]);

          // Execute the 'Restore Playlists, Comments and Settings from Zip
          // File ...' menu without replacing the existing playlists.
          await IntegrationTestUtil.executeRestorePlaylists(
            tester: tester,
            doReplaceExistingPlaylists: false,
          );

          // Verify the displayed warning confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                'Restored 1 playlist, 1 comment and 1 picture JSON files as well as the application settings from "$firstRestorableZipFilePathName".',
            isWarningConfirming: true,
            warningTitle: 'CONFIRMATION',
          );

          // Verify that after the first restoration the selected
          // playlist is 'Prières du Maître'.
          IntegrationTestUtil.verifyPlaylistSelection(
            tester: tester,
            playlistTitle: 'Prières du Maître',
            isSelected: true,
          );

          const String secondRestorableZipFileName =
              'Windows audioLearn_2025-05-11_13_16.zip';
          final String secondRestorableZipFilePathName =
              '$zipTestDirectory$secondRestorableZipFileName';

          mockFilePicker.setSelectedFiles([
            PlatformFile(
                name: secondRestorableZipFileName,
                path: secondRestorableZipFilePathName,
                size: 12288),
          ]);

          // Execute the 'Restore Playlists, Comments and Settings from Zip
          // File ...' menu withoreplacing the existing playlists.
          await IntegrationTestUtil.executeRestorePlaylists(
            tester: tester,
            doReplaceExistingPlaylists: true,
          );

          // Verify the displayed warning confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                'Restored 2 playlist, 5 comment and 4 picture JSON files as well as the application settings from "$secondRestorableZipFilePathName".',
            isWarningConfirming: true,
            warningTitle: 'CONFIRMATION',
          );

          // Verify that after the second restoration the selected
          // playlist is still 'Prières du Maître'.
          IntegrationTestUtil.verifyPlaylistSelection(
            tester: tester,
            playlistTitle: 'Prières du Maître',
            isSelected: true,
          );

          // Verify that the after the second restoration the selected
          // is not 'A restaurer'. The 'A restaurer' playlist was selected
          // in the restoration zip file.
          IntegrationTestUtil.verifyPlaylistSelection(
            tester: tester,
            playlistTitle: 'A restaurer',
            isSelected: false,
          );

          // Verifying the restored playlists list as well as their
          // displayed audio titles and subtitles.

          List<String> playlistsTitles = [
            "Prières du Maître",
            "A restaurer",
            "local",
          ];

          // Verify 'Prières du Maître' playlist

          List<String> audioTitles = [
            "Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          ];

          List<String> audioSubTitles = [
            "0:02:39.6 2.59 MB at 502 KB/sec on 11/02/2025 at 09:00",
          ];

          _verifyRestoredPlaylistAndAudio(
            tester: tester,
            selectedPlaylistTitle: 'Prières du Maître',
            playlistsTitles: playlistsTitles,
            audioTitles: audioTitles,
            audioSubTitles: audioSubTitles,
          );

          // Now verify 'local' playlist

          // Select the 'local' playlist which was restored.
          await IntegrationTestUtil.selectPlaylist(
            tester: tester,
            playlistToSelectTitle: 'local',
          );

          audioTitles = [
            "Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage!",
          ];

          audioSubTitles = [
            "0:24:21.8 8.92 MB at 1.62 MB/sec on 13/02/2025 at 08:30",
          ];

          _verifyRestoredPlaylistAndAudio(
            tester: tester,
            selectedPlaylistTitle: 'local',
            playlistsTitles: playlistsTitles,
            audioTitles: audioTitles,
            audioSubTitles: audioSubTitles,
          );

          // And verify the 'A restaurer' playlist

          // Select the 'A restaurer' playlist
          await IntegrationTestUtil.selectPlaylist(
            tester: tester,
            playlistToSelectTitle: 'A restaurer',
          );

          IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
            playlistTitle: 'A restaurer',
            expectedAudioFiles: [],
            expectedCommentFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.json",
              "250213-104308-Le 21 juillet 1913 _ Prières et méditations, La Mère 25-02-13.json",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.json",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json",
            ],
            expectedPictureFiles: [
              "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.json",
              "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.json",
              "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json",
            ],
            doesPictureAudioMapFileNameExist: true,
            pictureFileNameOne: 'Jésus le Dieu vivant.jpg',
            audioForPictureTitleOneLst: [
              "Prières du Maître|Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
              "A restaurer|250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09",
              "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09",
            ],
            pictureFileNameTwo: "Sam Altman.jpg",
            audioForPictureTitleTwoLst: [
              "A restaurer|250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12",
              "A restaurer|250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12"
            ],
            pictureFileNameThree: "Jésus mon Amour.jpg",
            audioForPictureTitleThreeLst: [
              "A restaurer|250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
            pictureFileNameFour: "Jésus je T'adore.jpg",
            audioForPictureTitleFourLst: [
              "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09"
            ],
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
      });
    });
    group('On empty app dir, restore Windows zip.', () {
      testWidgets(
          '''Not replace existing playlist. Restore multiple playlists Windows zip to empty Windows
           application''', (tester) async {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        String restorableZipFilePathName =
            '$kDownloadAppTestSavedDataDir${path.separator}zip_files_for_restore_tests${path.separator}Windows sort_and_filter_audio_dialog_widget_test_playlists.zip';

        // Since we have to use a mock AudioDownloadVM to add the
        // youtube playlist, we can not use app.main() to start the
        // app because app.main() uses the real AudioDownloadVM
        // and we don't want to make the main.dart file dependent
        // of a mock class. So we have to start the app by hand,
        // what IntegrationTestUtil.launchExpandablePlaylistListView
        // does.

        final SettingsDataService settingsDataService = SettingsDataService(
          sharedPreferences: await SharedPreferences.getInstance(),
          isTest: true,
        );

        // Load the settings from the json file. This is necessary
        // otherwise the ordered playlist titles will remain empty
        // and the playlist list will not be filled with the
        // playlists available in the download app test dir
        await settingsDataService.loadSettingsFromFile(
            settingsJsonPathFileName:
                "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

        WarningMessageVM warningMessageVM = WarningMessageVM();

        // The mockAudioDownloadVM will be later used to simulate
        // redownloading not playable files after having restored
        // the playlists, comments and settings from the zip file.
        MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
          warningMessageVM: warningMessageVM,
          settingsDataService: settingsDataService,
        );

        AudioDownloadVM audioDownloadVM = AudioDownloadVM(
          warningMessageVM: warningMessageVM,
          settingsDataService: settingsDataService,
        );

        PlaylistListVM playlistListVM = PlaylistListVM(
          warningMessageVM: warningMessageVM,
          audioDownloadVM: mockAudioDownloadVM,
          commentVM: CommentVM(),
          pictureVM: PictureVM(
            settingsDataService: settingsDataService,
          ),
          settingsDataService: settingsDataService,
        );

        // calling getUpToDateSelectablePlaylists() loads all the
        // playlist json files from the app dir and so enables
        // playlistListVM to know which playlists are
        // selected and which are not
        playlistListVM.getUpToDateSelectablePlaylists();

        AudioPlayerVM audioPlayerVM = AudioPlayerVM(
          settingsDataService: settingsDataService,
          playlistListVM: playlistListVM,
          commentVM: CommentVM(),
        );

        DateFormatVM dateFormatVM = DateFormatVM(
          settingsDataService: settingsDataService,
        );

        await IntegrationTestUtil
            .launchIntegrTestAppEnablingInternetAccessWithMock(
          tester: tester,
          audioDownloadVM: audioDownloadVM,
          settingsDataService: settingsDataService,
          playlistListVM: playlistListVM,
          warningMessageVM: warningMessageVM,
          audioPlayerVM: audioPlayerVM,
          dateFormatVM: dateFormatVM,
        );

        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFilePathName,
              path: restorableZipFilePathName,
              size: 7460),
        ]);

        // Execute the 'Restore Playlists, Comments and Settings from Zip
        // File ...' menu
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
        );

        // Verify the displayed warning confirmation dialog
        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              'Restored 2 playlist, 1 comment and 1 picture JSON files as well as the application settings from "$restorableZipFilePathName".',
          isWarningConfirming: true,
          warningTitle: 'CONFIRMATION',
        );

        // Verifying the existing and the restored playlists
        // list as well as the selected playlist 'S8 audio'
        // displayed audio titles and subtitles.

        List<String> playlistsTitles = [
          "local",
          "S8 audio",
        ];

        List<String> audioTitles = [
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        List<String> audioSubTitles = [
          '0:13:39.0 4.99 MB at 2.55 MB/sec on 07/01/2024 at 08:16',
          "0:19:05.0 6.98 MB at 2.28 MB/sec on 07/01/2024 at 08:16",
          "0:20:32.0 7.51 MB at 2.44 MB/sec on 26/12/2023 at 09:45",
          "0:06:29.0 2.37 MB at 1.36 MB/sec on 26/12/2023 at 09:45",
        ];

        _verifyRestoredPlaylistAndAudio(
          tester: tester,
          selectedPlaylistTitle: 'S8 audio',
          playlistsTitles: playlistsTitles,
          audioTitles: audioTitles,
          audioSubTitles: audioSubTitles,
        );

        // Verify the content of the 'S8 audio' playlist dir
        // + comments + pictures dir after restoration.
        IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
          playlistTitle: 'S8 audio',
          expectedAudioFiles: [],
          expectedCommentFiles: [
            "231226-094534-3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01.json"
          ],
          expectedPictureFiles: [
            "231226-094534-3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01.json"
          ],
          doesPictureAudioMapFileNameExist: true,
          pictureFileNameOne: 'wallpaper.jpg',
          audioForPictureTitleOneLst: [
            'S8 audio|231226-094534-3 fois où un économiste m\'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01',
          ],
          pictureFileNameTwo:
              'Liguria_Italy_Coast_Houses_Riomaggiore_Crag_513222_3840x2400.jpg',
          audioForPictureTitleTwoLst: [
            'S8 audio|231226-094534-3 fois où un économiste m\'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01',
          ],
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets(
          '''Replace existing playlist. Restore multiple playlists Windows zip to empty Windows
           application''', (tester) async {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        String restorableZipFilePathName =
            '$kDownloadAppTestSavedDataDir${path.separator}zip_files_for_restore_tests${path.separator}Windows sort_and_filter_audio_dialog_widget_test_playlists.zip';

        // Since we have to use a mock AudioDownloadVM to add the
        // youtube playlist, we can not use app.main() to start the
        // app because app.main() uses the real AudioDownloadVM
        // and we don't want to make the main.dart file dependent
        // of a mock class. So we have to start the app by hand,
        // what IntegrationTestUtil.launchExpandablePlaylistListView
        // does.

        final SettingsDataService settingsDataService = SettingsDataService(
          sharedPreferences: await SharedPreferences.getInstance(),
          isTest: true,
        );

        // Load the settings from the json file. This is necessary
        // otherwise the ordered playlist titles will remain empty
        // and the playlist list will not be filled with the
        // playlists available in the download app test dir
        await settingsDataService.loadSettingsFromFile(
            settingsJsonPathFileName:
                "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

        WarningMessageVM warningMessageVM = WarningMessageVM();

        // The mockAudioDownloadVM will be later used to simulate
        // redownloading not playable files after having restored
        // the playlists, comments and settings from the zip file.
        MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
          warningMessageVM: warningMessageVM,
          settingsDataService: settingsDataService,
        );

        AudioDownloadVM audioDownloadVM = AudioDownloadVM(
          warningMessageVM: warningMessageVM,
          settingsDataService: settingsDataService,
        );

        PlaylistListVM playlistListVM = PlaylistListVM(
          warningMessageVM: warningMessageVM,
          audioDownloadVM: mockAudioDownloadVM,
          commentVM: CommentVM(),
          pictureVM: PictureVM(
            settingsDataService: settingsDataService,
          ),
          settingsDataService: settingsDataService,
        );

        // calling getUpToDateSelectablePlaylists() loads all the
        // playlist json files from the app dir and so enables
        // playlistListVM to know which playlists are
        // selected and which are not
        playlistListVM.getUpToDateSelectablePlaylists();

        AudioPlayerVM audioPlayerVM = AudioPlayerVM(
          settingsDataService: settingsDataService,
          playlistListVM: playlistListVM,
          commentVM: CommentVM(),
        );

        DateFormatVM dateFormatVM = DateFormatVM(
          settingsDataService: settingsDataService,
        );

        await IntegrationTestUtil
            .launchIntegrTestAppEnablingInternetAccessWithMock(
          tester: tester,
          audioDownloadVM: audioDownloadVM,
          settingsDataService: settingsDataService,
          playlistListVM: playlistListVM,
          warningMessageVM: warningMessageVM,
          audioPlayerVM: audioPlayerVM,
          dateFormatVM: dateFormatVM,
        );

        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFilePathName,
              path: restorableZipFilePathName,
              size: 7460),
        ]);

        // Execute the 'Restore Playlists, Comments and Settings from Zip
        // File ...' menu
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: true,
        );

        // Verify the displayed warning confirmation dialog
        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              'Restored 2 playlist, 1 comment and 1 picture JSON files as well as the application settings from "$restorableZipFilePathName".',
          isWarningConfirming: true,
          warningTitle: 'CONFIRMATION',
        );

        // Verifying the existing and the restored playlists
        // list as well as the selected playlist 'S8 audio'
        // displayed audio titles and subtitles.

        List<String> playlistsTitles = [
          "local",
          "S8 audio",
        ];

        List<String> audioTitles = [
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        List<String> audioSubTitles = [
          '0:13:39.0 4.99 MB at 2.55 MB/sec on 07/01/2024 at 08:16',
          "0:19:05.0 6.98 MB at 2.28 MB/sec on 07/01/2024 at 08:16",
          "0:20:32.0 7.51 MB at 2.44 MB/sec on 26/12/2023 at 09:45",
          "0:06:29.0 2.37 MB at 1.36 MB/sec on 26/12/2023 at 09:45",
        ];

        _verifyRestoredPlaylistAndAudio(
          tester: tester,
          selectedPlaylistTitle: 'S8 audio',
          playlistsTitles: playlistsTitles,
          audioTitles: audioTitles,
          audioSubTitles: audioSubTitles,
        );

        // Verify the content of the 'S8 audio' playlist dir
        // + comments + pictures dir after restoration.
        IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
          playlistTitle: 'S8 audio',
          expectedAudioFiles: [],
          expectedCommentFiles: [
            "231226-094534-3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01.json"
          ],
          expectedPictureFiles: [
            "231226-094534-3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01.json"
          ],
          doesPictureAudioMapFileNameExist: true,
          pictureFileNameOne: 'wallpaper.jpg',
          audioForPictureTitleOneLst: [
            'S8 audio|231226-094534-3 fois où un économiste m\'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01',
          ],
          pictureFileNameTwo:
              'Liguria_Italy_Coast_Houses_Riomaggiore_Crag_513222_3840x2400.jpg',
          audioForPictureTitleTwoLst: [
            'S8 audio|231226-094534-3 fois où un économiste m\'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01',
          ],
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets(
          '''Unique playlist restore, not replace existing playlist. Restore unique playlist Windows zip to empty Windows
             application''', (tester) async {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        String restorableZipFilePathName =
            '$kDownloadAppTestSavedDataDir${path.separator}zip_files_for_restore_tests${path.separator}Windows Prières du Maître.zip';

        // Since we have to use a mock AudioDownloadVM to add the
        // youtube playlist, we can not use app.main() to start the
        // app because app.main() uses the real AudioDownloadVM
        // and we don't want to make the main.dart file dependent
        // of a mock class. So we have to start the app by hand,
        // what IntegrationTestUtil.launchExpandablePlaylistListView
        // does.

        final SettingsDataService settingsDataService = SettingsDataService(
          sharedPreferences: await SharedPreferences.getInstance(),
          isTest: true,
        );

        // Load the settings from the json file. This is necessary
        // otherwise the ordered playlist titles will remain empty
        // and the playlist list will not be filled with the
        // playlists available in the download app test dir
        await settingsDataService.loadSettingsFromFile(
            settingsJsonPathFileName:
                "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

        WarningMessageVM warningMessageVM = WarningMessageVM();

        // The mockAudioDownloadVM will be later used to simulate
        // redownloading not playable files after having restored
        // the playlists, comments and settings from the zip file.
        MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
          warningMessageVM: warningMessageVM,
          settingsDataService: settingsDataService,
        );

        AudioDownloadVM audioDownloadVM = AudioDownloadVM(
          warningMessageVM: warningMessageVM,
          settingsDataService: settingsDataService,
        );

        PlaylistListVM playlistListVM = PlaylistListVM(
          warningMessageVM: warningMessageVM,
          audioDownloadVM: mockAudioDownloadVM,
          commentVM: CommentVM(),
          pictureVM: PictureVM(
            settingsDataService: settingsDataService,
          ),
          settingsDataService: settingsDataService,
        );

        // calling getUpToDateSelectablePlaylists() loads all the
        // playlist json files from the app dir and so enables
        // playlistListVM to know which playlists are
        // selected and which are not
        playlistListVM.getUpToDateSelectablePlaylists();

        AudioPlayerVM audioPlayerVM = AudioPlayerVM(
          settingsDataService: settingsDataService,
          playlistListVM: playlistListVM,
          commentVM: CommentVM(),
        );

        DateFormatVM dateFormatVM = DateFormatVM(
          settingsDataService: settingsDataService,
        );

        await IntegrationTestUtil
            .launchIntegrTestAppEnablingInternetAccessWithMock(
          tester: tester,
          audioDownloadVM: audioDownloadVM,
          settingsDataService: settingsDataService,
          playlistListVM: playlistListVM,
          warningMessageVM: warningMessageVM,
          audioPlayerVM: audioPlayerVM,
          dateFormatVM: dateFormatVM,
        );

        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFilePathName,
              path: restorableZipFilePathName,
              size: 7460),
        ]);

        // Execute the 'Restore Playlists, Comments and Settings from Zip
        // File ...' menu
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: true,
        );

        // Verify the displayed warning confirmation dialog
        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              'Restored 1 playlist, 1 comment and 1 picture JSON files as well as the application settings from "$restorableZipFilePathName".',
          isWarningConfirming: true,
          warningTitle: 'CONFIRMATION',
        );

        // Verifying the existing and the restored playlists
        // list as well as the selected playlist 'Prières du
        // Maître' displayed audio titles and subtitles.

        List<String> playlistsTitles = [
          "Prières du Maître",
        ];

        List<String> audioTitles = [
          "Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
        ];

        List<String> audioSubTitles = [
          '0:02:39.6 2.59 MB at 502 KB/sec on 11/02/2025 at 09:00',
        ];

        _verifyRestoredPlaylistAndAudio(
          tester: tester,
          selectedPlaylistTitle: 'Prières du Maître',
          playlistsTitles: playlistsTitles,
          audioTitles: audioTitles,
          audioSubTitles: audioSubTitles,
        );

        // Verify the content of the 'Prières du Maître' playlist dir
        // + comments + pictures dir after restoration.
        IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
          playlistTitle: 'Prières du Maître',
          expectedAudioFiles: [],
          expectedCommentFiles: [
            "Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'.json"
          ],
          expectedPictureFiles: [
            "Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'.json"
          ],
          doesPictureAudioMapFileNameExist: true,
          pictureFileNameOne: 'Jésus le Dieu vivant.jpg',
          audioForPictureTitleOneLst: [
            "Prières du Maître|Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'"
          ],
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets(
          '''Unique playlist restore, replace existing playlist. Restore unique playlist Windows zip to empty Windows
             application''', (tester) async {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        String restorableZipFilePathName =
            '$kDownloadAppTestSavedDataDir${path.separator}zip_files_for_restore_tests${path.separator}Windows Prières du Maître.zip';

        // Since we have to use a mock AudioDownloadVM to add the
        // youtube playlist, we can not use app.main() to start the
        // app because app.main() uses the real AudioDownloadVM
        // and we don't want to make the main.dart file dependent
        // of a mock class. So we have to start the app by hand,
        // what IntegrationTestUtil.launchExpandablePlaylistListView
        // does.

        final SettingsDataService settingsDataService = SettingsDataService(
          sharedPreferences: await SharedPreferences.getInstance(),
          isTest: true,
        );

        // Load the settings from the json file. This is necessary
        // otherwise the ordered playlist titles will remain empty
        // and the playlist list will not be filled with the
        // playlists available in the download app test dir
        await settingsDataService.loadSettingsFromFile(
            settingsJsonPathFileName:
                "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

        WarningMessageVM warningMessageVM = WarningMessageVM();

        // The mockAudioDownloadVM will be later used to simulate
        // redownloading not playable files after having restored
        // the playlists, comments and settings from the zip file.
        MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
          warningMessageVM: warningMessageVM,
          settingsDataService: settingsDataService,
        );

        AudioDownloadVM audioDownloadVM = AudioDownloadVM(
          warningMessageVM: warningMessageVM,
          settingsDataService: settingsDataService,
        );

        PlaylistListVM playlistListVM = PlaylistListVM(
          warningMessageVM: warningMessageVM,
          audioDownloadVM: mockAudioDownloadVM,
          commentVM: CommentVM(),
          pictureVM: PictureVM(
            settingsDataService: settingsDataService,
          ),
          settingsDataService: settingsDataService,
        );

        // calling getUpToDateSelectablePlaylists() loads all the
        // playlist json files from the app dir and so enables
        // playlistListVM to know which playlists are
        // selected and which are not
        playlistListVM.getUpToDateSelectablePlaylists();

        AudioPlayerVM audioPlayerVM = AudioPlayerVM(
          settingsDataService: settingsDataService,
          playlistListVM: playlistListVM,
          commentVM: CommentVM(),
        );

        DateFormatVM dateFormatVM = DateFormatVM(
          settingsDataService: settingsDataService,
        );

        await IntegrationTestUtil
            .launchIntegrTestAppEnablingInternetAccessWithMock(
          tester: tester,
          audioDownloadVM: audioDownloadVM,
          settingsDataService: settingsDataService,
          playlistListVM: playlistListVM,
          warningMessageVM: warningMessageVM,
          audioPlayerVM: audioPlayerVM,
          dateFormatVM: dateFormatVM,
        );

        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFilePathName,
              path: restorableZipFilePathName,
              size: 7460),
        ]);

        // Execute the 'Restore Playlists, Comments and Settings from Zip
        // File ...' menu
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
        );

        // Verify the displayed warning confirmation dialog
        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              'Restored 1 playlist, 1 comment and 1 picture JSON files as well as the application settings from "$restorableZipFilePathName".',
          isWarningConfirming: true,
          warningTitle: 'CONFIRMATION',
        );

        // Verifying the existing and the restored playlists
        // list as well as the selected playlist 'Prières du
        // Maître' displayed audio titles and subtitles.

        List<String> playlistsTitles = [
          "Prières du Maître",
        ];

        List<String> audioTitles = [
          "Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
        ];

        List<String> audioSubTitles = [
          '0:02:39.6 2.59 MB at 502 KB/sec on 11/02/2025 at 09:00',
        ];

        _verifyRestoredPlaylistAndAudio(
          tester: tester,
          selectedPlaylistTitle: 'Prières du Maître',
          playlistsTitles: playlistsTitles,
          audioTitles: audioTitles,
          audioSubTitles: audioSubTitles,
        );

        // Verify the content of the 'Prières du Maître' playlist dir
        // + comments + pictures dir after restoration.
        IntegrationTestUtil.verifyPlaylistDirectoryContentsOnAndroid(
          playlistTitle: 'Prières du Maître',
          expectedAudioFiles: [],
          expectedCommentFiles: [
            "Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'.json"
          ],
          expectedPictureFiles: [
            "Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'.json"
          ],
          doesPictureAudioMapFileNameExist: true,
          pictureFileNameOne: 'Jésus le Dieu vivant.jpg',
          audioForPictureTitleOneLst: [
            "Prières du Maître|Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'"
          ],
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
    });
  });
}

void _verifyRestoredPlaylistAndAudio({
  required WidgetTester tester,
  required String selectedPlaylistTitle,
  required List<String> playlistsTitles,
  required List<String> audioTitles,
  required List<String> audioSubTitles,
}) {
  // Verify the selected playlist
  IntegrationTestUtil.verifyPlaylistSelection(
    tester: tester,
    playlistTitle: selectedPlaylistTitle,
  );

  IntegrationTestUtil.checkPlaylistAndAudioTitlesOrderInListTile(
    tester: tester,
    playlistTitlesOrderedLst: playlistsTitles,
    audioTitlesOrderedLst: audioTitles,
  );

  IntegrationTestUtil.checkAudioSubTitlesOrderInListTile(
    tester: tester,
    audioSubTitlesOrderLst: audioSubTitles,
    firstAudioListTileIndex: playlistsTitles.length,
  );
}

Playlist loadPlaylist(String playListOneName) {
  return JsonDataService.loadFromFile(
      jsonPathFileName:
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$playListOneName${path.separator}$playListOneName.json",
      type: Playlist);
}

Future<List<String>> enteringFirstAndSecondLetterOfYoutubePlaylistSearchWord({
  required WidgetTester tester,
}) async {
  // Now enter the first letter of the search word
  await tester.tap(
    find.byKey(
      const Key('youtubeUrlOrSearchTextField'),
    ),
  );
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(
      const Key('youtubeUrlOrSearchTextField'),
    ),
    'S',
  );
  await tester.pumpAndSettle(const Duration(milliseconds: 200));

  // Verify that the search icon button is now enabled but inactive
  IntegrationTestUtil.validateSearchIconButton(
    tester: tester,
    searchIconButtonState: SearchIconButtonState.enabledInactive,
  );

  // Ensure that since the search icon button was not yet pressed,
  // the displayed playlist list is the same as the one before entering
  // the first letter of the search word.

  List<String> playlistsTitles = [
    "S8 audio",
    "local",
    "local_2",
  ];

  List<String> audioTitles = [
    "Really short video",
    "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
    "La résilience insulaire par Fiona Roche",
    "Les besoins artificiels par R.Keucheyan",
  ];

  IntegrationTestUtil.checkPlaylistAndAudioTitlesOrderInListTile(
    tester: tester,
    playlistTitlesOrderedLst: playlistsTitles,
    audioTitlesOrderedLst: audioTitles,
  );

  // Enter the second letter of the 'al' search word. The crazy integration
  // test does not always update the test field. To fix this bug, first
  // select the text field and then enter the text.

  // Select the text field
  await tester.tap(
    find.byKey(
      const Key('youtubeUrlOrSearchTextField'),
    ),
  );
  await tester.pumpAndSettle();

  // Enter the second letter of the 'al' search word
  await tester.enterText(
    find.byKey(
      const Key('youtubeUrlOrSearchTextField'),
    ),
    'S8',
  );
  await tester.pumpAndSettle(const Duration(milliseconds: 200));

  // Verify that the search icon button is now enabled but inactive
  IntegrationTestUtil.validateSearchIconButton(
    tester: tester,
    searchIconButtonState: SearchIconButtonState.enabledInactive,
  );

  // Ensure that since the search icon button was not yet pressed,
  // the displayed playlist list is the same as the one before entering
  // the first letter of the search word.
  IntegrationTestUtil.checkPlaylistAndAudioTitlesOrderInListTile(
    tester: tester,
    playlistTitlesOrderedLst: playlistsTitles,
    audioTitlesOrderedLst: audioTitles,
  );

  // Now tap on the search icon button
  await tester.tap(find.byKey(const Key('search_icon_button')));
  await tester.pumpAndSettle();

  // Verify that the search icon button is now enabled and active
  IntegrationTestUtil.validateSearchIconButton(
    tester: tester,
    searchIconButtonState: SearchIconButtonState.enabledActive,
  );

  // Now verify the order of the reduced playlist titles

  playlistsTitles = [
    "S8 audio",
  ];

  IntegrationTestUtil.checkPlaylistAndAudioTitlesOrderInListTile(
    tester: tester,
    playlistTitlesOrderedLst: playlistsTitles,
    audioTitlesOrderedLst: audioTitles,
  );

  return playlistsTitles;
}

Map loadSettingsMap() {
  final String settingsJsonStr = File(
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName")
      .readAsStringSync();

  Map settingsMap = jsonDecode(settingsJsonStr);

  return settingsMap;
}

void modifySelectedPlaylistBeforeStartingApplication({
  required String playlistToUnselectTitle,
  required String playlistToSelectTitle,
}) {
  final initiallySelectedPlaylistPath = path.join(
    kPlaylistDownloadRootPathWindowsTest,
    playlistToUnselectTitle,
  );

  final initiallySelectedPlaylistFilePathName = path.join(
    initiallySelectedPlaylistPath,
    '$playlistToUnselectTitle.json',
  );

  // Load playlist from the json file
  Playlist initiallySelectedPlaylist = JsonDataService.loadFromFile(
    jsonPathFileName: initiallySelectedPlaylistFilePathName,
    type: Playlist,
  );

  initiallySelectedPlaylist.isSelected = false;

  JsonDataService.saveToFile(
    model: initiallySelectedPlaylist,
    path: initiallySelectedPlaylistFilePathName,
  );

  final nowSelectedPlaylistPath = path.join(
    kPlaylistDownloadRootPathWindowsTest,
    playlistToSelectTitle,
  );

  final nowSelectedPlaylistFilePathName = path.join(
    nowSelectedPlaylistPath,
    '$playlistToSelectTitle.json',
  );

  // Load playlist from the json file
  Playlist nowSelectedPlaylist = JsonDataService.loadFromFile(
    jsonPathFileName: nowSelectedPlaylistFilePathName,
    type: Playlist,
  );

  nowSelectedPlaylist.isSelected = true;

  JsonDataService.saveToFile(
    model: nowSelectedPlaylist,
    path: nowSelectedPlaylistFilePathName,
  );
}

Future<void> verifyYoutubeSelectedPlaylistButtonsAndCheckbox({
  required WidgetTester tester,
  required bool isPlaylistListDisplayed,
}) async {
  // Verify that the search icon button is now disabled
  IntegrationTestUtil.validateSearchIconButton(
    tester: tester,
    searchIconButtonState: SearchIconButtonState.disabled,
  );

  if (isPlaylistListDisplayed) {
    IntegrationTestUtil.verifyWidgetIsEnabled(
      tester: tester,
      widgetKeyStr: 'move_up_playlist_button',
    );

    IntegrationTestUtil.verifyWidgetIsEnabled(
      tester: tester,
      widgetKeyStr: 'move_down_playlist_button',
    );
  } else {
    // Verify that the dropdown button is set to the playlist download
    // view 'Title asc' sort/filter parms
    IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
      tester: tester,
      dropdownButtonSelectedTitle: 'Title asc',
    );
  }

  IntegrationTestUtil.verifyWidgetIsEnabled(
    tester: tester,
    widgetKeyStr: 'download_sel_playlists_button',
  );

  IntegrationTestUtil.verifyWidgetIsEnabled(
    tester: tester,
    widgetKeyStr: 'audio_quality_checkbox',
  );

  IntegrationTestUtil.verifyWidgetIsEnabled(
    tester: tester,
    widgetKeyStr: 'audio_popup_menu_button',
  );
}

Future<void> verifyLocalSelectedPlaylistButtonsAndCheckbox({
  required WidgetTester tester,
  required bool isPlaylistListDisplayed,
}) async {
  // Verify that the search icon button is now disabled
  IntegrationTestUtil.validateSearchIconButton(
    tester: tester,
    searchIconButtonState: SearchIconButtonState.disabled,
  );

  if (isPlaylistListDisplayed) {
    IntegrationTestUtil.verifyWidgetIsEnabled(
      tester: tester,
      widgetKeyStr: 'move_up_playlist_button',
    );

    IntegrationTestUtil.verifyWidgetIsEnabled(
      tester: tester,
      widgetKeyStr: 'move_down_playlist_button',
    );
  } else {
    // Verify that the dropdown button is set to the playlist download
    // view 'Title asc' sort/filter parms
    IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
      tester: tester,
      dropdownButtonSelectedTitle: 'Title asc',
    );
  }

  await IntegrationTestUtil.verifyWidgetIsDisabled(
    tester: tester,
    widgetKeyStr: 'download_sel_playlists_button',
  );

  await IntegrationTestUtil.verifyWidgetIsDisabled(
    tester: tester,
    widgetKeyStr: 'audio_quality_checkbox',
  );

  IntegrationTestUtil.verifyWidgetIsEnabled(
    tester: tester,
    widgetKeyStr: 'audio_popup_menu_button',
  );
}

Future<void> verifyUndoneListenedAudioPosition({
  required WidgetTester tester,
  required String playlistTitle,
  required String playedCommentAudioTitle,
  required int playableAudioLstAudioIndex,
  required String audioPositionStr,
  required int audioPositionSeconds,
  required String audioRemainingDurationStr,
  required bool isPlayingOrPausedWithPositionBetweenAudioStartAndEnd,
  required DateTime? audioPausedDateTime,
}) async {
  // Now we want to tap on the previously played commented audio of
  // the playlist in order to open the AudioPlayerView displaying
  // the currently not playing audio

  // First, get the Audio ListTile Text widget finder and tap on it
  final Finder playedCommentAudioListTileTextWidgetFinder =
      find.text(playedCommentAudioTitle);

  await tester.tap(playedCommentAudioListTileTextWidgetFinder);
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  // Now verify if the displayed audio position and remaining
  // duration are correct

  Text audioPositionText = tester
      .widget<Text>(find.byKey(const Key('audioPlayerViewAudioPosition')));
  expect(audioPositionText.data, audioPositionStr);

  Text audioRemainingDurationText = tester.widget<Text>(
      find.byKey(const Key('audioPlayerViewAudioRemainingDuration')));
  expect(audioRemainingDurationText.data, audioRemainingDurationStr);

  IntegrationTestUtil.verifyAudioDataElementsUpdatedInPlaylistJsonFile(
    audioPlayerSelectedPlaylistTitle: playlistTitle,
    playableAudioLstAudioIndex: playableAudioLstAudioIndex,
    audioTitle: playedCommentAudioTitle,
    audioPositionSeconds: audioPositionSeconds,
    isPaused: true,
    isPlayingOrPausedWithPositionBetweenAudioStartAndEnd:
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd,
    audioPausedDateTime: audioPausedDateTime, // "2024-09-08T14:38:43.283816"
  );
}

Future<Finder> openPlaylistCommentDialog({
  required WidgetTester tester,
  required String playlistTitle,
}) async {
  // First, find the 'S8 audio' playlist sublist ListTile Text widget
  Finder youtubePlaylistListTileTextWidgetFinder = find.text(playlistTitle);

  // Then obtain the playlist ListTile widget enclosing the Text widget
  // by finding its ancestor
  Finder youtubePlaylistListTileWidgetFinder = find.ancestor(
    of: youtubePlaylistListTileTextWidgetFinder,
    matching: find.byType(ListTile),
  );

  // Now we want to tap the popup menu of the 'S8 audio' playlist ListTile

  // Find the leading menu icon button of the playlist ListTile
  // and tap on it
  Finder youtubePlaylistListTileLeadingMenuIconButton = find.descendant(
    of: youtubePlaylistListTileWidgetFinder,
    matching: find.byIcon(Icons.menu),
  );

  // Tap the leading menu icon button to open the popup menu
  await tester.tap(youtubePlaylistListTileLeadingMenuIconButton);
  await tester.pumpAndSettle();

  // Now find the List comments of playlist audio popup menu
  // item and tap on it
  final Finder popupPlaylistAudioCommentsMenuItem =
      find.byKey(const Key("popup_menu_display_playlist_audio_comments"));

  await tester.tap(popupPlaylistAudioCommentsMenuItem);
  await tester.pumpAndSettle();

  final Finder playlistCommentListDialogFinder =
      find.byType(PlaylistCommentListDialog);
  return playlistCommentListDialogFinder;
}

Future<void> verifyAudioTitlesColorInPlaylistCommentDialog({
  required WidgetTester tester,
  required Finder playlistCommentListDialogFinder,
}) async {
  await IntegrationTestUtil.checkAudioTextColor(
    tester: tester,
    enclosingWidgetFinder: playlistCommentListDialogFinder,
    audioTitleOrSubTitle:
        "Quand Aurélien Barrau va dans une école de management",
    expectedTitleTextColor:
        IntegrationTestUtil.currentlyPlayingAudioTitleTextColor,
    expectedTitleTextBackgroundColor:
        IntegrationTestUtil.currentlyPlayingAudioTitleTextBackgroundColor,
  );

  await IntegrationTestUtil.checkAudioTextColor(
    tester: tester,
    enclosingWidgetFinder: playlistCommentListDialogFinder,
    audioTitleOrSubTitle:
        "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...",
    expectedTitleTextColor: IntegrationTestUtil.fullyPlayedAudioTitleColor,
    expectedTitleTextBackgroundColor: null,
  );

  await IntegrationTestUtil.checkAudioTextColor(
    tester: tester,
    enclosingWidgetFinder: playlistCommentListDialogFinder,
    audioTitleOrSubTitle:
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
    expectedTitleTextColor:
        IntegrationTestUtil.partiallyPlayedAudioTitleTextdColor,
    expectedTitleTextBackgroundColor: null,
  );

  await IntegrationTestUtil.checkAudioTextColor(
    tester: tester,
    enclosingWidgetFinder: playlistCommentListDialogFinder,
    audioTitleOrSubTitle: "La surpopulation mondiale par Jancovici et Barrau",
    expectedTitleTextColor: IntegrationTestUtil.unplayedAudioTitleTextColor,
    expectedTitleTextBackgroundColor: null,
  );
}

Future<Finder> verifyAudioInfoDialog({
  required WidgetTester tester,
  required String audioEnclosingPlaylistTitle,
  required String movedOrCopiedAudioTitle,
  required String movedFromPlaylistTitle,
  required String movedToPlaylistTitle,
  required String copiedFromPlaylistTitle,
  required String copiedToPlaylistTitle,
  required String audioDuration,
}) async {
  // Now we want to tap the popup menu of the Audio ListTile
  // "audio learn test short video one" in order to display
  // the audio info dialog

  // First, find the Audio sublist ListTile Text widget
  final Finder targetAudioListTileTextWidgetFinder =
      find.text(movedOrCopiedAudioTitle);

  // Then obtain the Audio ListTile widget enclosing the Text widget by
  // finding its ancestor
  final Finder targetAudioListTileWidgetFinder = find.ancestor(
    of: targetAudioListTileTextWidgetFinder,
    matching: find.byType(ListTile),
  );

  // Now find the leading menu icon button of the Audio ListTile and tap
  // on it
  final Finder targetAudioListTileLeadingMenuIconButton = find.descendant(
    of: targetAudioListTileWidgetFinder,
    matching: find.byIcon(Icons.menu),
  );

  // Tap the leading menu icon button to open the popup menu
  await tester.tap(targetAudioListTileLeadingMenuIconButton);
  await tester.pumpAndSettle();

  // Now find the audio info popup menu item and tap on it
  final Finder popupDisplayAudioInfoMenuItemFinder =
      find.byKey(const Key("popup_menu_display_audio_info"));

  await tester.tap(popupDisplayAudioInfoMenuItemFinder);
  await tester.pumpAndSettle();

  // Now verifying the display audio info audio moved dialog
  // elements

  // Verify the audio channel name

  Text youtubeChannelTextWidget =
      tester.widget<Text>(find.byKey(const Key('youtubeChannelKey')));

  expect(youtubeChannelTextWidget.data, "Jean-Pierre Schnyder");

  // Verify the enclosing playlist title of the moved audio

  final Text enclosingPlaylistTitleTextWidget =
      tester.widget<Text>(find.byKey(const Key('enclosingPlaylistTitleKey')));

  expect(
    enclosingPlaylistTitleTextWidget.data,
    audioEnclosingPlaylistTitle,
  );

  // Verify the 'Moved from playlist' title of the moved audio

  final Text movedFromPlaylistTitleTextWidget =
      tester.widget<Text>(find.byKey(const Key('movedFromPlaylistTitleKey')));

  expect(movedFromPlaylistTitleTextWidget.data, movedFromPlaylistTitle);

  // Verify the 'Moved to playlist title' of the moved audio

  final Text movedToPlaylistTitleTextWidget =
      tester.widget<Text>(find.byKey(const Key('movedToPlaylistTitleKey')));

  expect(movedToPlaylistTitleTextWidget.data, movedToPlaylistTitle);

  // Verify the 'Copied from playlist' title of the moved audio

  final Text copiedFromPlaylistTitleTextWidget =
      tester.widget<Text>(find.byKey(const Key('copiedFromPlaylistTitleKey')));

  expect(copiedFromPlaylistTitleTextWidget.data, copiedFromPlaylistTitle);

  // Verify the 'Copied to playlist title' of the moved audio

  final Text copiedToPlaylistTitleTextWidget =
      tester.widget<Text>(find.byKey(const Key('copiedToPlaylistTitleKey')));

  expect(copiedToPlaylistTitleTextWidget.data, copiedToPlaylistTitle);

  // Verify the 'Audio duration' of the moved audio

  final Text audioDurationTextWidget =
      tester.widget<Text>(find.byKey(const Key('audioDurationKey')));

  expect(audioDurationTextWidget.data, audioDuration);

  // Now find the close button of the audio info dialog
  // and tap on it to close the dialog
  await tester.tap(find.byKey(const Key('audio_info_close_button_key')));
  await tester.pumpAndSettle();

  return targetAudioListTileWidgetFinder;
}

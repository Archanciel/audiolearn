import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/audio_player_vm.dart';
import 'package:audiolearn/viewmodels/comment_vm.dart';
import 'package:audiolearn/viewmodels/date_format_vm.dart';
import 'package:audiolearn/viewmodels/picture_vm.dart';
import 'package:audiolearn/viewmodels/playlist_list_vm.dart';
import 'package:audiolearn/viewmodels/warning_message_vm.dart';
import 'package:audiolearn/views/widgets/convert_text_to_audio_dialog.dart';
import 'package:audiolearn/views/widgets/set_value_to_target_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/utils/dir_util.dart';

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
      '''ONLY WORKS ON Medium Phone EMULATOR, NOT ON FLUTTER EMULATOR. REASON: EMULATOR SIZE !
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
          doDeleteExistingPlaylists: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            'urgent_actus_17-12-2023',
          ],
          onAndroid: true,
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
          doDeleteExistingPlaylists: false,
          verifySetValueToTargetDialog: true,
          onAndroid: true,
        );

        // Must be used on Android emulator, otherwise the confirmation
        // dialog is not displayed and can not be verifyed !
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Verify the displayed warning confirmation dialog
        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              'Restored 0 playlist saved individually, 2 comment and 2 picture JSON files as well as 2 picture JPG file(s) in the application pictures directory and 2 audio reference(s) and 0 added plus 0 modified comment(s) in existing audio comment file(s) from "/storage/emulated/0/Documents/test/audiolearn/Windows S8 audio.zip".',
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
          "Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          "Quand Aurélien Barrau va dans une école de management",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        List<String> audioSubTitles = [
          "0:02:39.6 2.59 MB imported on 23/06/2025 at 06:56",
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
          '''Multiple playlists restore, not replace existing playlists. Restore multiple playlists Windows
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
          doDeleteExistingPlaylists: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            'urgent_actus_17-12-2023',
          ],
          onAndroid: true,
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
          doDeleteExistingPlaylists: false,
          verifySetValueToTargetDialog: true,
          onAndroid: true,
        );

        // Must be used on Android emulator, otherwise the confirmation
        // dialog is not displayed and can not be verifyed !
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Verify the displayed warning confirmation dialog
        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              'Restored 0 playlist, 3 comment and 3 picture JSON files as well as 0 picture JPG file(s) in the application pictures directory and 4 audio reference(s) and 0 added plus 0 modified comment(s) in existing audio comment file(s) and the application settings from "/storage/emulated/0/Documents/test/audiolearn/Windows 2 existing playlists with new audios.zip".',
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
          "Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          "Quand Aurélien Barrau va dans une école de management",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        List<String> audioSubTitles = [
          "0:02:39.6 2.59 MB imported on 23/06/2025 at 06:56",
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
          doDeleteExistingPlaylists: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            'urgent_actus_17-12-2023',
          ],
          onAndroid: true,
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
          doDeleteExistingPlaylists: false,
          onAndroid: true,
        );

        // Must be used on Android emulator, otherwise the confirmation
        // dialog is not displayed and can not be verifyed !
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Verify the displayed warning confirmation dialog
        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              'Restored 1 playlist saved individually, 3 comment and 1 picture JSON files as well as 1 picture JPG file(s) in the application pictures directory and 22 audio reference(s) and 0 added plus 0 modified comment(s) in existing audio comment file(s) from "/storage/emulated/0/Documents/test/audiolearn/Windows Les plus belles chansons chrétiennes.zip".\n\nSince the playlist\n  "Les plus belles chansons chrétiennes"\nwas created, it is positioned at the end of the playlist list.',
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
          doDeleteExistingPlaylists: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            'urgent_actus_17-12-2023',
          ],
          onAndroid: true,
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
          doDeleteExistingPlaylists: false,
          verifySetValueToTargetDialog: true,
          onAndroid: true,
        );

        // Must be used on Android emulator, otherwise the confirmation
        // dialog is not displayed and can not be verifyed !
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Verify the displayed warning confirmation dialog
        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              'Restored 0 playlist saved individually, 2 comment and 2 picture JSON files as well as 0 picture JPG file(s) in the application pictures directory and 2 audio reference(s) and 0 added plus 0 modified comment(s) in existing audio comment file(s) from "/storage/emulated/0/Documents/test/audiolearn/Android S8 audio.zip".',
          warningDialogMessageAlternative:
              'Restored 0 playlist saved individually, 2 comment and 2 picture JSON files as well as 2 picture JPG file(s) in the application pictures directory and 2 audio reference(s) and 0 added plus 0 modified comment(s) in existing audio comment file(s) from "/storage/emulated/0/Documents/test/audiolearn/Android S8 audio.zip".',
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
          "Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          "Quand Aurélien Barrau va dans une école de management",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        List<String> audioSubTitles = [
          "0:02:39.6 2.59 MB imported on 23/06/2025 at 06:56",
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
          '''Multiple playlists restore, not replace existing playlists. Restore multiple playlists Android
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
          doDeleteExistingPlaylists: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            'urgent_actus_17-12-2023',
          ],
          onAndroid: true,
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
          doDeleteExistingPlaylists: false,
          verifySetValueToTargetDialog: true,
          onAndroid: true,
        );

        // Must be used on Android emulator, otherwise the confirmation
        // dialog is not displayed and can not be verifyed !
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Verify the displayed warning confirmation dialog
        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              'Restored 0 playlist, 3 comment and 3 picture JSON files as well as 0 picture JPG file(s) in the application pictures directory and 4 audio reference(s) and 0 added plus 0 modified comment(s) in existing audio comment file(s) and the application settings from "/storage/emulated/0/Documents/test/audiolearn/Android 2 existing playlists with new audios.zip".',
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
          "Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          "Quand Aurélien Barrau va dans une école de management",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        List<String> audioSubTitles = [
          "0:02:39.6 2.59 MB imported on 23/06/2025 at 06:56",
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
        r'''Test playing audio on the playlist download view. From Android data. Before running the test,
         execute C:\development\flutter\audiolearn\test\data\saved\Android_emulator_bat\setup_test.bat''',
        () {
      testWidgets(
          '''Play audio on the playlist download view. Verify the correct audio item inkwell play/pause
            button change when the current playing audio reaches its end and the next audio starts playing.
            Due to the main branch audioplayer version which does not support the integration test action,
            the test is not executable on the main branch.''', (tester) async {
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
          doDeleteExistingPlaylists: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            urgentActusPlaylistTitle,
          ],
          onAndroid: true,
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

        await IntegrationTestUtil.verifySetValueToTargetDialog(
          tester: tester,
          dialogTitle: 'MP3 Restoration',
          isHelpIconPresent: true,
          dialogMessage:
              "Only the MP3 relative to the audio's listed in the playlist which are not already present in the playlist are restorable.",
          closeDialog: true,
        );

        // Now tap on the 'A Single ZIP File' button
        await tester.tap(find.byKey(const Key('selectFileButton')));
        await tester.pumpAndSettle();

        // Tap on the Ok button to close the warning confirmation dialog
        await tester.tap(find.byKey(const Key('warningDialogOkButton')));
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
        for (int i = 0; i < 21; i++) {
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
        for (int i = 0; i < 22; i++) {
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
      testWidgets(
          '''Play audio on the audio player view with comment displayed. Verify that the displayed
             comment is updated when the next audio starts playing.''',
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
          doDeleteExistingPlaylists: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            urgentActusPlaylistTitle,
          ],
          onAndroid: true,
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

        // Tap on the Ok button to close the warning confirmation dialog
        await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
        await tester.pumpAndSettle();

        // Now tap on the 'A Single ZIP File' button
        await tester.tap(find.byKey(const Key('selectFileButton')));
        await tester.pumpAndSettle();

        // Tap on the Ok button to close the warning confirmation dialog
        await tester.tap(find.byKey(const Key('warningDialogOkButton')));
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

        // Click on the comment icon button to display the comment
        Finder commentIconButtonFinder =
            find.byKey(const Key('commentsInkWellButton'));
        await tester.tap(commentIconButtonFinder);
        await tester.pumpAndSettle();

        // Verify the first audio displayed comment

        // Find the list body containing the comments
        Finder commentListDialogFinder =
            find.byKey(const Key('audioCommentsListKey'));

        expect(
            find.descendant(
                of: commentListDialogFinder,
                matching: find.text("New chapter title")),
            findsOneWidget);
        expect(
            find.descendant(
                of: commentListDialogFinder,
                matching: find.text("New chapter comment")),
            findsOneWidget);

        // Add a delay to allow the audio to reach its end and the next audio
        // to start playing.
        for (int i = 0; i < 16; i++) {
          await Future.delayed(const Duration(seconds: 1));
          await tester.pumpAndSettle();
        }

        // Verify the second audio displayed comment

        // Find the list body containing the comments
        commentListDialogFinder = find.byKey(const Key('audioCommentsListKey'));

        expect(
            find.descendant(
                of: commentListDialogFinder,
                matching: find.text("L’uniforme title")),
            findsOneWidget);
        expect(
            find.descendant(
                of: commentListDialogFinder,
                matching: find.text("L’uniforme comment")),
            findsOneWidget);
      });
    });
    group('''Import audio's functionality.''', () {
      testWidgets(
          '''Importing one audio test. Verify conversion warning. Then reimporting it and verify
          the not imported warning. Normally, the imported audio's are not located in a playlist
          directory !''', (WidgetTester tester) async {
        await IntegrationTestUtil.initializeAndroidApplicationAndSelectPlaylist(
          tester: tester,
          tapOnPlaylistToggleButton: false,
        );

        // Now initializing the application on the Android emulator using
        // zip restoration.

        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        String restorableZipFileName = 'audioLearn_2025-09-07_07_45_02.zip';

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
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylists: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            'urgent_actus_17-12-2023',
          ],
          onAndroid: true,
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

        const String urgentActusPlaylistTitle = 'urgent_actus_17-12-2023';

        await IntegrationTestUtil.typeOnPlaylistMenuItem(
          tester: tester,
          playlistTitle: urgentActusPlaylistTitle,
          playlistMenuKeyStr:
              'popup_menu_restore_playlist_audio_mp3_files_from_zip',
          dragToBottom: true, // necessary if Flutter emulator is used
        );

        // Now find the 'Ok' button of the SetValueToTarget dialog
        // and tap on it
        await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
        await tester.pumpAndSettle();

        // Now tap on the 'A Single ZIP File' button
        await tester.tap(find.byKey(const Key('selectFileButton')));
        await tester.pumpAndSettle();

        // Tap on the Ok button to close the warning confirmation dialog
        await tester.tap(find.byKey(const Key('warningDialogOkButton')));
        await tester.pumpAndSettle();

        const String fileNameExt =
            "250812-162929-L’uniforme arrive en France en 2024 23-12-11.mp3";
        const String fileNameNoExt =
            "250812-162929-L’uniforme arrive en France en 2024 23-12-11";

        // Setting one selected mp3 file.
        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: fileNameExt,
              path:
                  "$kPlaylistDownloadRootPathAndroidTest${path.separator}$urgentActusPlaylistTitle${path.separator}$fileNameExt",
              size: 155136),
        ]);

        const String localPlaylistTitle = 'local';
        DateTime now = DateTime.now();

        await IntegrationTestUtil.typeOnPlaylistMenuItem(
          tester: tester,
          playlistTitle: localPlaylistTitle,
          playlistMenuKeyStr: 'popup_menu_import_audio_in_playlist',
        );

        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              "Audio(s)\n\n\"$fileNameExt\"\n\nimported to local playlist \"$localPlaylistTitle\".",
          isWarningConfirming: true,
        );

        // Re-import the same audio to verify the not imported warning
        await IntegrationTestUtil.typeOnPlaylistMenuItem(
          tester: tester,
          playlistTitle: localPlaylistTitle,
          playlistMenuKeyStr: 'popup_menu_import_audio_in_playlist',
        );

        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              "Audio(s)\n\n\"$fileNameExt\"\n\nNOT imported to local playlist \"$localPlaylistTitle\" since the playlist directory already contains the audio(s).",
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verifying all audio info dialog fields related of the imported audio
        // type
        await IntegrationTestUtil.verifyAudioInfoDialog(
          tester: tester,
          audioType: AudioType.imported,
          validVideoTitleOrAudioTitle: fileNameNoExt,
          audioDownloadDateTime:
              "${DateFormat('dd/MM/yyyy').format(now)} ${DateFormat('HH:mm').format(now)}", // this is the imported date time
          isAudioPlayable: true,
          audioEnclosingPlaylistTitle: localPlaylistTitle,
          audioDuration: '0:10:51.9',
          audioPosition: '0:00:00',
          audioState: 'Not listened',
          lastListenDateTime: '',
          audioFileName: fileNameExt,
          audioFileSize: '3.98 MB',
          isMusicQuality: false, // Is spoken quality
          audioPlaySpeed: '1.0',
          audioVolume: '50.0 %',
          audioCommentNumber: 0,
        );

        // Verify the imported audio sub title in the selected Youtube
        // playlist audio list
        IntegrationTestUtil.checkAudioSubTitlesOrderInListTile(
          tester: tester,
          audioSubTitlesAcceptableLst: [
            "0:10:51.9 3.98 MB imported on ${DateFormat('dd/MM/yyyy').format(now)} at ${DateFormat('HH:mm').format(now)}",
          ],
          firstAudioListTileIndex: 0,
        );

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
      });
      testWidgets(
          '''2 audio's present in the source playlist exist in the playlist which will import
          all audio's of the source playlist. This situation will display 2 warnings, one
          audio import confirmation and one already existing audio's not imported warning.
          Normally, the imported audio's are not located in a playlist !''',
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

        String restorableZipFileName = 'audioLearn_2025-09-07_07_45_02.zip';

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
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylists: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            'urgent_actus_17-12-2023',
          ],
          onAndroid: true,
        );

        // Tap on the 'OK' button of the confirmation dialog
        await tester.tap(find.byKey(const Key('warningDialogOkButton')).last);
        await tester.pumpAndSettle();

        const String restorableMp3ZipFileName =
            'audioLearn_mp3_from_2025-08-12_16_29_25_on_2025-09-07_07_46_29.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableMp3ZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableMp3ZipFileName',
              size: 15366672),
        ]);

        // Tap on the appbar menu item 'Restore Playlists Audio Mp3 Files
        // from Zip ...'
        await IntegrationTestUtil.typeOnAppbarMenuItem(
          tester: tester,
          appbarMenuKeyStr: 'appBarMenuRestorePlaylistsAudioMp3FilesFromZip',
        );

        // Now find the 'Ok' button of the SetValueToTarget dialog
        // and tap on it
        await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
        await tester.pumpAndSettle();

        // Now tap on the 'A Single ZIP File' button
        await tester.tap(find.byKey(const Key('selectFileButton')));
        await tester.pumpAndSettle();

        // Tap on the Ok button to close the warning confirmation dialog
        await tester.tap(find.byKey(const Key('warningDialogOkButton')));
        await tester.pumpAndSettle();

        const String selectedPlaylistTitle = 'urgent_actus_17-12-2023';
        const String localPlaylistTitle = 'local';

        const String fileName_1 =
            "250812-162925-NOUVEAU CHAPITRE POUR ETHEREUM - L'IDÉE GÉNIALE DE VITALIK! ACTUS CRYPTOMONNAIES 13_12 23-12-13.mp3";
        const String fileName_2 =
            "250812-162929-L’uniforme arrive en France en 2024 23-12-11.mp3";
        const String fileName_3 =
            "250812-162933-DETTE PUBLIQUE  - LA RÉALITÉ DERRIÈRE LES DISCOURS CATASTROPHISTES 23-11-07.mp3";
        const String fileName_4 = "aaa.mp3";
        const String fileName_5 = "bbb.mp3";

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: fileName_1,
              path:
                  "$kPlaylistDownloadRootPathAndroidTest${path.separator}$selectedPlaylistTitle${path.separator}$fileName_1",
              size: 176640),
          PlatformFile(
              name: fileName_2,
              path:
                  "$kPlaylistDownloadRootPathAndroidTest${path.separator}$selectedPlaylistTitle${path.separator}$fileName_2",
              size: 183552),
          PlatformFile(
              name: fileName_3,
              path:
                  "$kPlaylistDownloadRootPathAndroidTest${path.separator}$selectedPlaylistTitle${path.separator}$fileName_3",
              size: 176640),
          PlatformFile(
              name: fileName_4,
              path:
                  "$kPlaylistDownloadRootPathAndroidTest${path.separator}$selectedPlaylistTitle${path.separator}$fileName_4",
              size: 15000),
          PlatformFile(
              name: fileName_5,
              path:
                  "$kPlaylistDownloadRootPathAndroidTest${path.separator}$selectedPlaylistTitle${path.separator}$fileName_5",
              size: 15000),
        ]);

        await IntegrationTestUtil.typeOnPlaylistMenuItem(
          tester: tester,
          playlistTitle: localPlaylistTitle,
          playlistMenuKeyStr: 'popup_menu_import_audio_in_playlist',
        );

        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              "Audio(s)\n\n\"$fileName_1\",\n\"$fileName_2\",\n\"$fileName_3\",\n\"$fileName_5\"\n\nimported to local playlist \"$localPlaylistTitle\".",
          isWarningConfirming: true,
        );

        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              "Audio(s)\n\n\"$fileName_4\"\n\nNOT imported to local playlist \"$localPlaylistTitle\" since the playlist directory already contains the audio(s).",
        );

        // Re-import the same audio's to verify the not imported warning\

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: fileName_1,
              path:
                  "$kPlaylistDownloadRootPathAndroidTest${path.separator}$selectedPlaylistTitle${path.separator}$fileName_1",
              size: 176640),
          PlatformFile(
              name: fileName_2,
              path:
                  "$kPlaylistDownloadRootPathAndroidTest${path.separator}$selectedPlaylistTitle${path.separator}$fileName_2",
              size: 183552),
          PlatformFile(
              name: fileName_3,
              path:
                  "$kPlaylistDownloadRootPathAndroidTest${path.separator}$selectedPlaylistTitle${path.separator}$fileName_3",
              size: 176640),
          PlatformFile(
              name: fileName_4,
              path:
                  "$kPlaylistDownloadRootPathAndroidTest${path.separator}$selectedPlaylistTitle${path.separator}$fileName_4",
              size: 175296),
          PlatformFile(
              name: fileName_5,
              path:
                  "$kPlaylistDownloadRootPathAndroidTest${path.separator}$selectedPlaylistTitle${path.separator}$fileName_5",
              size: 155136),
        ]);

        await IntegrationTestUtil.typeOnPlaylistMenuItem(
          tester: tester,
          playlistTitle: localPlaylistTitle,
          playlistMenuKeyStr: 'popup_menu_import_audio_in_playlist',
        );

        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              "Audio(s)\n\n\"$fileName_1\",\n\"$fileName_2\",\n\"$fileName_3\",\n\"$fileName_4\",\n\"$fileName_5\"\n\nNOT imported to local playlist \"$localPlaylistTitle\" since the playlist directory already contains the audio(s).",
        );
      });
    });
    group('''Convert text to audio.''', () {
      testWidgets(
          '''On selected playlist, add a text to speech audio. Verify the text to speech dialog appearance.
          Then enter a text with case ( { ) characters. Verify the Listen Create MP3 button state. Listen
          and Stop the text. Then listen the full text and verify the listen duration after which the Stop
          button is reset to the Listen button. Then, create the MP3 audio and verify its presence in the
          playlist audio list. Verify also the audio info dialog content of the converted audio. Then, verify
          the added comment in relation with the text to audio conversion.

          Finally, redo a text to speech conversion with a different text and save it to the same MP3 file
          name. Do the same verifications as previously.''',
          (WidgetTester tester) async {
        await IntegrationTestUtil.initializeAndroidApplicationAndSelectPlaylist(
          tester: tester,
          tapOnPlaylistToggleButton: false,
        );

        const String selectedYoutubePlaylistTitle = 'urgent_actus_17-12-2023';

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
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylists: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            selectedYoutubePlaylistTitle,
          ],
          onAndroid: true,
        );

        // Tap on the 'OK' button of the confirmation dialog
        await tester.tap(find.byKey(const Key('warningDialogOkButton')).last);
        await tester.pumpAndSettle();

        // Open the convert text to audio dialog
        await IntegrationTestUtil.typeOnPlaylistMenuItem(
          tester: tester,
          playlistTitle: selectedYoutubePlaylistTitle,
          playlistMenuKeyStr: 'popup_menu_convert_text_to_audio_in_playlist',
        );

        // Verify the convert text to audio dialog title
        final Text convertTextToAudioDialogTitle = tester.widget<Text>(
            find.byKey(const Key('convertTextToAudioDialogTitleKey')));
        expect(
          convertTextToAudioDialogTitle.data,
          'Convert Text to Audio',
        );

        // Verify the presence of the help icon button
        expect(find.byIcon(Icons.help_outline), findsOneWidget);

        // Verify the text to convert title
        final Text textToConvert =
            tester.widget<Text>(find.byKey(const Key('textToConvertTitleKey')));
        expect(
          textToConvert.data,
          'Text to convert, { = silence',
        );

        // Verify the voice selection title
        final Text conversionVoiceSelection = tester
            .widget<Text>(find.byKey(const Key('voiceSelectionTitleKey')));
        expect(
          conversionVoiceSelection.data,
          'Voice selection:',
        );

        // Verify the voice selection checkboxes

        final Finder masculineCheckbox =
            find.byKey(const Key('masculineVoiceCheckbox'));
        Finder feminineCheckbox = find.byKey(const Key('femineVoiceCheckbox'));

        // Initially masculine should be selected
        expect(
          (tester.widget(masculineCheckbox) as Checkbox).value,
          true,
        );
        expect(
          (tester.widget(feminineCheckbox) as Checkbox).value,
          false,
        );

        // Scroll down to make the feminine checkbox visible
        await tester.drag(
          find.byType(ConvertTextToAudioDialog),
          const Offset(
              0, -100), // Negative value for vertical drag to scroll down
        );
        await tester.pumpAndSettle();

        // Tap the feminine checkbox
        await tester.tap(feminineCheckbox);
        await tester.pumpAndSettle();

        // Verify state changed to feminine
        expect(
          (tester.widget(masculineCheckbox) as Checkbox).value,
          false,
        );
        expect(
          (tester.widget(feminineCheckbox) as Checkbox).value,
          true,
        );

        // Tap masculine checkbox back
        await tester.tap(masculineCheckbox);
        await tester.pumpAndSettle();

        // Verify state changed back to masculine
        expect(
          (tester.widget(masculineCheckbox) as Checkbox).value,
          true,
        );
        expect(
          (tester.widget(feminineCheckbox) as Checkbox).value,
          false,
        );

        // Enter and then delete a text to convert

        // Verify the presence of the hint text in the TextField
        expect(find.text('Enter your text here ...'), findsOneWidget);

        // Find the text field and delete button
        final Finder textFieldFinder =
            find.byKey(const Key('textToConvertTextField'));
        final Finder textFieldDeleteButtonFFinder =
            find.byKey(const Key('deleteTextToConvertIconButton'));

        // Verify the disabled state of the Listen and Create MP3 buttons
        await _verifyListenAndCreateMp3ButtonsState(
          tester: tester,
          areEnabled: false,
        );

        // Enter text in the TextField
        const testText = 'Ceci est un texte à supprimer.';
        await tester.enterText(textFieldFinder, testText);
        await tester.pumpAndSettle();

        // Verify the text was entered
        expect(find.text(testText), findsOneWidget);

        // Verify the TextField controller has the text
        final textFieldWidget = tester.widget<TextField>(textFieldFinder);
        expect(textFieldWidget.controller!.text, testText);

        // Verify the enabled state of the Listen and Create MP3 buttons
        await _verifyListenAndCreateMp3ButtonsState(
          tester: tester,
          areEnabled: true,
        );

        // Scroll up to make the text field fully visible
        await tester.drag(
          find.byType(ConvertTextToAudioDialog),
          const Offset(
              0, 100), // Negative value for vertical drag to scroll down
        );
        await tester.pumpAndSettle();

        // Tap the delete button
        await tester.tap(textFieldDeleteButtonFFinder);
        await tester.pumpAndSettle();

        // Verify the text field is now empty
        expect(textFieldWidget.controller!.text, isEmpty);
        expect(find.text(testText), findsNothing);

        // Verify the TextField is focused after clearing (as per your implementation)
        expect(tester.binding.focusManager.primaryFocus,
            textFieldWidget.focusNode);

        // Verify the presence of the hint text in the TextField
        await tester.pumpAndSettle();
        expect(find.text('Enter your text here ...'), findsOneWidget);

        // Verify the again disabled state of the Listen and Create MP3 buttons
        await _verifyListenAndCreateMp3ButtonsState(
          tester: tester,
          areEnabled: false,
        );

        // Now enter a text to convert and listen it, verifying its
        // between 8 and 9 second duration

        const String initialTextToConvertStr = "{{ un {{{ deux { trois.";
        await tester.enterText(textFieldFinder, initialTextToConvertStr);
        await tester.pump();

        // Tap on the listen button
        final Finder listenButton = find.byKey(const Key('listen_text_button'));
        await tester.tap(listenButton);
        await tester.pumpAndSettle();

        // Verify button changed to Stop button
        TextButton stopButtonWidget = tester.widget(listenButton);
        Row stopButtonRow = stopButtonWidget.child as Row;
        Icon stopIcon = (stopButtonRow.children[0] as Icon);
        expect(stopIcon.icon, Icons.stop); // Stop icon

        // Now, tap on the Stop button after 1 seconds
        await Future.delayed(const Duration(seconds: 1));
        await tester.tap(listenButton);
        await tester.pumpAndSettle();

        // Verify the Stop button changed back to Listen button
        TextButton listenButtonWidget = tester.widget(listenButton);
        Row listenButtonRow = listenButtonWidget.child as Row;
        Icon listenIcon = (listenButtonRow.children[0] as Icon);
        expect(listenIcon.icon, Icons.volume_up); // Back to Listen icon

        // Now, tap again on the Listen button and let the audio
        // play to its end
        await tester.tap(listenButton);
        await tester.pumpAndSettle();

        // Add a delay to allow the audio to reach its end and the next audio
        // to start playing.
        for (int i = 0; i < 11; i++) {
          await Future.delayed(const Duration(seconds: 1));
          await tester.pumpAndSettle();
        }

        // Final verification - the Stop button changed to Listen button
        TextButton finalButtonWidget = tester.widget(listenButton);
        Row finalButtonRow = finalButtonWidget.child as Row;
        Icon finalIcon = (finalButtonRow.children[0] as Icon);
        expect(finalIcon.icon, Icons.volume_up); // Back to Listen icon

        // Now click on Create MP3 button to create the audio
        Finder createMP3ButtonFinder =
            find.byKey(const Key('create_audio_file_button'));
        expect(createMP3ButtonFinder, findsOneWidget);
        await tester.tap(createMP3ButtonFinder);
        await tester.pumpAndSettle();

        // Verify the convert text to audio dialog title
        expect(
          find.text('MP3 File Name'),
          findsOneWidget,
        );

        // Verify the text to convert title
        expect(
          find.text('Enter the MP3 file name'),
          findsOneWidget,
        );

        // Verify the presence of the hint text in the MP3 file name
        // TextField
        expect(find.text('file name'), findsOneWidget);
        expect(find.text('.mp3'), findsOneWidget);

        const String enteredFileNameNoExt = 'convertedAudio';
        Finder mp3FileNameTextFieldFinder =
            find.byKey(const Key('textToConvertTextField'));

        await tester.enterText(
            mp3FileNameTextFieldFinder, enteredFileNameNoExt);
        await tester.pump();

        // Verify the text was entered
        expect(find.text(enteredFileNameNoExt), findsOneWidget);

        // Tap on the create mp3 button
        Finder saveMP3FileButton =
            find.byKey(const Key('create_mp3_button_key'));
        await tester.tap(saveMP3FileButton);
        await Future.delayed(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              "The audio created by the text to MP3 conversion\n\n\"$enteredFileNameNoExt.mp3\"\n\nwas added to Youtube playlist \"$selectedYoutubePlaylistTitle\".",
          isWarningConfirming: true,
        );

        // Now close the convert text to audio dialog by tapping
        // the Cancel button
        Finder cancelButtonFinder =
            find.byKey(const Key('convertTextToAudioCloseButton'));
        await tester.tap(cancelButtonFinder);
        await tester.pumpAndSettle();

        // Tap the 'Toggle List' button to close the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        DateTime now = DateTime.now();

        // Verify the converted audio sub title in the selected Youtube
        // playlist audio list
        IntegrationTestUtil.checkAudioSubTitlesOrderInListTile(
          tester: tester,
          audioSubTitlesAcceptableLst: [
            '0:00:07.0 56 KB converted on ${DateFormat('dd/MM/yyyy').format(now)} at ${DateFormat('HH:mm').format(now)}',
          ],
          firstAudioListTileIndex: 0,
        );

        // Verifying all audio info dialog fields related of the
        // converted audio type
        await IntegrationTestUtil.verifyAudioInfoDialog(
          tester: tester,
          audioType: AudioType.textToSpeech,
          validVideoTitleOrAudioTitle: enteredFileNameNoExt,
          audioDownloadDateTime:
              '${DateFormat('dd/MM/yyyy').format(now)} ${DateFormat('HH:mm').format(now)}', // this is the imported date time
          isAudioPlayable: true,
          audioEnclosingPlaylistTitle: selectedYoutubePlaylistTitle,
          audioDuration: '0:00:07.0',
          audioPosition: '0:00:00',
          audioState: 'Not listened',
          lastListenDateTime: '',
          audioFileName: '$enteredFileNameNoExt.mp3',
          audioFileSize: '56 KB',
          isMusicQuality: false, // Is spoken quality
          audioPlaySpeed: '1.25',
          audioVolume: '50.0 %',
          audioCommentNumber: 1,
        );

        // Now, we verify the created comment showing the converted
        // audio text

        // First, find the Youtube playlist audio ListTile Text widget
        Finder audioTitleTileTextWidgetFinder = find.text(enteredFileNameNoExt);

        // Then obtain the audio ListTile widget enclosing the Text widget
        // by finding its ancestor
        Finder audioTitleTileWidgetFinder = find.ancestor(
          of: audioTitleTileTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now we want to tap the popup menu of the audioTitle ListTile

        // Find the leading menu icon button of the audioTitle ListTile
        // and tap on it
        Finder audioTitleTileLeadingMenuIconButton = find.descendant(
          of: audioTitleTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioTitleTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the 'Audio Comments ...' popup menu item and
        // tap on it
        Finder audioCommentsPopupMenuItem =
            find.byKey(const Key("popup_menu_audio_comment"));

        await tester.tap(audioCommentsPopupMenuItem);
        await tester.pumpAndSettle();

        // Verify that the audio comments list of the dialog has 1 comment
        // item

        Finder audioCommentsLstFinder = find.byKey(const Key(
          'audioCommentsListKey',
        ));

        // Ensure the list has one child widgets
        expect(
          tester.widget<ListBody>(audioCommentsLstFinder).children.length,
          1,
        );

        List<String> expectedTitles = [
          'Text',
        ];

        List<String> expectedContents = [
          initialTextToConvertStr,
        ];

        List<String> expectedStartPositions = [
          '0:00',
        ];

        List<String> expectedEndPositions = [
          '0:07',
        ];

        List<String> expectedCreationDates = [
          frenchDateFormatYy.format(DateTime.now()), // created comment
          '04/09/25',
        ];

        List<String> expectedUpdateDates = [
          '',
        ];

        // Verify content of each list item
        IntegrationTestUtil.verifyCommentsInCommentListDialog(
            tester: tester,
            commentListDialogFinder: audioCommentsLstFinder,
            commentsNumber: 1,
            expectedTitlesLst: expectedTitles,
            expectedContentsLst: expectedContents,
            expectedStartPositionsLst: expectedStartPositions,
            expectedEndPositionsLst: expectedEndPositions,
            expectedCreationDatesLst: expectedCreationDates,
            expectedUpdateDatesLst: expectedUpdateDates);

        // Now close the comment list dialog
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Now, reopen the convert text to audio dialog
        await IntegrationTestUtil.typeOnPlaylistMenuItem(
          tester: tester,
          playlistTitle: selectedYoutubePlaylistTitle,
          playlistMenuKeyStr: 'popup_menu_convert_text_to_audio_in_playlist',
        );

        // Now enter a new text to convert
        const String nextTextToConvertStr = "un deux trois.";
        await tester.enterText(textFieldFinder, nextTextToConvertStr);
        await tester.pump();

        // Tap the feminine checkbox to change the voice
        await tester.tap(feminineCheckbox);
        await tester.pump();

        // Now click on Create MP3 button to create the audio
        createMP3ButtonFinder =
            find.byKey(const Key('create_audio_file_button'));
        await tester.tap(createMP3ButtonFinder);
        await tester.pumpAndSettle();

        // Enter the same mp3 file name as before
        mp3FileNameTextFieldFinder =
            find.byKey(const Key('textToConvertTextField'));

        await tester.enterText(
            mp3FileNameTextFieldFinder, enteredFileNameNoExt);
        await tester.pump();

        // Tap on the create mp3 button
        saveMP3FileButton = find.byKey(const Key('create_mp3_button_key'));
        await tester.tap(saveMP3FileButton);
        await Future.delayed(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        // Now check the confirm dialog which indicates that the saved
        // file name already exist and ask to confirm or cancel the
        // save operation.
        await IntegrationTestUtil.verifyConfirmActionDialog(
          tester: tester,
          confirmActionDialogTitle:
              "The file \"$enteredFileNameNoExt.mp3\" already exists in the playlist \"$selectedYoutubePlaylistTitle\". If you want to replace it with the new version, click on the \"Confirm\" button. Otherwise, click on the \"Cancel\" button and you will be able to define a different file name.",
          confirmActionDialogMessagePossibleLst: [
            "",
          ],
          closeDialogWithConfirmButton: true,
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              "The audio created by the text to MP3 conversion\n\n\"$enteredFileNameNoExt.mp3\"\n\nwas replaced in Youtube playlist \"$selectedYoutubePlaylistTitle\".",
          isWarningConfirming: true,
        );

        // Now close the convert text to audio dialog by tapping
        // the Cancel button
        cancelButtonFinder =
            find.byKey(const Key('convertTextToAudioCloseButton'));
        await tester.tap(cancelButtonFinder);
        await tester.pumpAndSettle();

        // Tap the 'Toggle List' button to close the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the converted audio sub title in the selected Youtube
        // playlist audio list
        IntegrationTestUtil.checkAudioSubTitlesOrderInListTile(
          tester: tester,
          audioSubTitlesAcceptableLst: [
            '0:00:00.8 6 KB converted on ${DateFormat('dd/MM/yyyy').format(now)} at ${DateFormat('HH:mm').format(now)}',
          ],
          firstAudioListTileIndex: 0,
        );

        // Verifying all audio info dialog fields related of the
        // converted audio type
        await IntegrationTestUtil.verifyAudioInfoDialog(
          tester: tester,
          audioType: AudioType.textToSpeech,
          validVideoTitleOrAudioTitle: enteredFileNameNoExt,
          audioDownloadDateTime:
              '${DateFormat('dd/MM/yyyy').format(now)} ${DateFormat('HH:mm').format(now)}', // this is the imported date time
          isAudioPlayable: true,
          audioEnclosingPlaylistTitle: selectedYoutubePlaylistTitle,
          audioDuration: '0:00:00.8',
          audioPosition: '0:00:00',
          audioState: 'Not listened',
          lastListenDateTime: '',
          audioFileName: '$enteredFileNameNoExt.mp3',
          audioFileSize: '6 KB',
          isMusicQuality: false, // Is spoken quality
          audioPlaySpeed: '1.25',
          audioVolume: '50.0 %',
          audioCommentNumber: 2,
        );

        // Now, we verify the second created comment showing the new
        // converted audio text

        // First, find the Youtube playlist audio ListTile Text widget
        audioTitleTileTextWidgetFinder = find.text(enteredFileNameNoExt);

        // Then obtain the audio ListTile widget enclosing the Text widget
        // by finding its ancestor
        audioTitleTileWidgetFinder = find.ancestor(
          of: audioTitleTileTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now we want to tap the popup menu of the audioTitle ListTile

        // Find the leading menu icon button of the audioTitle ListTile
        // and tap on it
        audioTitleTileLeadingMenuIconButton = find.descendant(
          of: audioTitleTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioTitleTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the 'Audio Comments ...' popup menu item and
        // tap on it
        audioCommentsPopupMenuItem =
            find.byKey(const Key("popup_menu_audio_comment"));

        await tester.tap(audioCommentsPopupMenuItem);
        await tester.pumpAndSettle();

        // Verify that the audio comments list of the dialog has 1 comment
        // item

        audioCommentsLstFinder = find.byKey(const Key(
          'audioCommentsListKey',
        ));

        // Ensure the list has one child widgets
        expect(
          tester.widget<ListBody>(audioCommentsLstFinder).children.length,
          2,
        );

        expectedTitles = [
          'Text',
          'Text',
        ];

        expectedContents = [
          initialTextToConvertStr,
          nextTextToConvertStr,
        ];

        expectedStartPositions = [
          '0:00',
          '0:00',
        ];

        expectedEndPositions = [
          '0:07',
          '0:01',
        ];

        expectedCreationDates = [
          frenchDateFormatYy.format(DateTime.now()), // created comment
          frenchDateFormatYy.format(DateTime.now()), // created comment
        ];

        expectedUpdateDates = [
          '',
          '',
        ];

        // Verify content of each list item
        IntegrationTestUtil.verifyCommentsInCommentListDialog(
            tester: tester,
            commentListDialogFinder: audioCommentsLstFinder,
            commentsNumber: 2,
            expectedTitlesLst: expectedTitles,
            expectedContentsLst: expectedContents,
            expectedStartPositionsLst: expectedStartPositions,
            expectedEndPositionsLst: expectedEndPositions,
            expectedCreationDatesLst: expectedCreationDates,
            expectedUpdateDatesLst: expectedUpdateDates);

        // Now close the comment list dialog
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
      });
      testWidgets(
          '''On unselected playlist, add a text to speech audio. Verify the text to speech dialog appearance.
          Then enter a text with case ( { ) characters. Verify the Listen Create MP3 button state. Listen and
          Stop the text. Then listen the full text and verify the listen duration after which the Stop
          button is reset to the Listen button. Then, create the MP3 audio and verify its presence in the
          playlist audio list. Verify also the audio info dialog content of the converted audio. Then, verify
          the added comment in relation with the text to audio conversion.

          Finally, redo a text to speech conversion with a different text and save it to the same MP3 file
          name. Do the same verifications as previously.''',
          (WidgetTester tester) async {
        await IntegrationTestUtil.initializeAndroidApplicationAndSelectPlaylist(
          tester: tester,
          tapOnPlaylistToggleButton: false,
        );

        const String unselectedLocalPlaylistTitle = 'local';
        // Now initializing the application on the Android emulator using
        // zip restoration.

        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        const String restorableZipFileName = 'Android local.zip';

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
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylists: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            'urgent_actus_17-12-2023',
          ],
          onAndroid: true,
        );

        // Tap on the 'OK' button of the confirmation dialog
        await tester.tap(find.byKey(const Key('warningDialogOkButton')).last);
        await tester.pumpAndSettle();

        // Now unselect the 'local' playlist if it is selected
        if (await IntegrationTestUtil.isPlaylistSelected(
            tester: tester,
            playlistToCheckTitle: unselectedLocalPlaylistTitle)) {
          await IntegrationTestUtil.selectPlaylist(
            tester: tester,
            playlistToSelectTitle: unselectedLocalPlaylistTitle,
          );
        }

        // Open the convert text to audio dialog
        await IntegrationTestUtil.typeOnPlaylistMenuItem(
          tester: tester,
          playlistTitle: unselectedLocalPlaylistTitle,
          playlistMenuKeyStr: 'popup_menu_convert_text_to_audio_in_playlist',
        );

        // Verify the convert text to audio dialog title
        final Text convertTextToAudioDialogTitle = tester.widget<Text>(
            find.byKey(const Key('convertTextToAudioDialogTitleKey')));
        expect(
          convertTextToAudioDialogTitle.data,
          'Convert Text to Audio',
        );

        // Now enter a text to convert and listen it, verifying its
        // between 8 and 9 second duration

        // Find the text field finder
        final Finder textFieldFinder =
            find.byKey(const Key('textToConvertTextField'));

        const String initialTextToConvertStr = "{{ un {{{ deux { trois.";
        await tester.enterText(textFieldFinder, initialTextToConvertStr);
        await tester.pump();

        // Tap on the listen button
        final Finder listenButton = find.byKey(const Key('listen_text_button'));
        await tester.tap(listenButton);
        await tester.pumpAndSettle();

        // Verify button changed to Stop button
        TextButton stopButtonWidget = tester.widget(listenButton);
        Row stopButtonRow = stopButtonWidget.child as Row;
        Icon stopIcon = (stopButtonRow.children[0] as Icon);
        expect(stopIcon.icon, Icons.stop); // Stop icon

        // Now, tap on the Stop button after 1 seconds
        await Future.delayed(const Duration(seconds: 1));
        await tester.tap(listenButton);
        await tester.pumpAndSettle();

        // Verify the Stop button changed back to Listen button
        TextButton listenButtonWidget = tester.widget(listenButton);
        Row listenButtonRow = listenButtonWidget.child as Row;
        Icon listenIcon = (listenButtonRow.children[0] as Icon);
        expect(listenIcon.icon, Icons.volume_up); // Back to Listen icon

        // Now click on Create MP3 button to create the audio
        Finder createMP3ButtonFinder =
            find.byKey(const Key('create_audio_file_button'));
        expect(createMP3ButtonFinder, findsOneWidget);
        await tester.tap(createMP3ButtonFinder);
        await tester.pumpAndSettle();

        // Verify the convert text to audio dialog title
        expect(
          find.text('MP3 File Name'),
          findsOneWidget,
        );

        // Verify the text to convert title
        expect(
          find.text('Enter the MP3 file name'),
          findsOneWidget,
        );

        // Verify the presence of the hint text in the MP3 file name
        // TextField
        expect(find.text('file name'), findsOneWidget);
        expect(find.text('.mp3'), findsOneWidget);

        const String enteredFileNameNoExt = 'convertedAudio';
        Finder mp3FileNameTextFieldFinder =
            find.byKey(const Key('textToConvertTextField'));

        await tester.enterText(
            mp3FileNameTextFieldFinder, enteredFileNameNoExt);
        await tester.pump();

        // Verify the text was entered
        expect(find.text(enteredFileNameNoExt), findsOneWidget);

        DateTime now = DateTime.now();

        // Tap on the create mp3 button
        Finder saveMP3FileButton =
            find.byKey(const Key('create_mp3_button_key'));
        await tester.tap(saveMP3FileButton);
        await Future.delayed(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              "The audio created by the text to MP3 conversion\n\n\"$enteredFileNameNoExt.mp3\"\n\nwas added to local playlist \"$unselectedLocalPlaylistTitle\".",
          isWarningConfirming: true,
        );

        // Now close the convert text to audio dialog by tapping
        // the Cancel button
        Finder cancelButtonFinder =
            find.byKey(const Key('convertTextToAudioCloseButton'));
        await tester.tap(cancelButtonFinder);
        await tester.pumpAndSettle();

        // Now select the 'local' playlist
        await IntegrationTestUtil.selectPlaylist(
          tester: tester,
          playlistToSelectTitle: unselectedLocalPlaylistTitle,
        );

        // Tap the 'Toggle List' button to close the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the converted audio sub title in the selected Youtube
        // playlist audio list
        IntegrationTestUtil.checkAudioSubTitlesOrderInListTile(
          tester: tester,
          audioSubTitlesAcceptableLst: [
            '0:00:07.0 56 KB converted on ${DateFormat('dd/MM/yyyy').format(now)} at ${DateFormat('HH:mm').format(now)}',
          ],
          firstAudioListTileIndex: 0,
        );

        // Verifying all audio info dialog fields related of the
        // converted audio type
        await IntegrationTestUtil.verifyAudioInfoDialog(
          tester: tester,
          audioType: AudioType.textToSpeech,
          validVideoTitleOrAudioTitle: enteredFileNameNoExt,
          audioDownloadDateTime:
              '${DateFormat('dd/MM/yyyy').format(now)} ${DateFormat('HH:mm').format(now)}', // this is the imported date time
          isAudioPlayable: true,
          audioEnclosingPlaylistTitle: unselectedLocalPlaylistTitle,
          audioDuration: '0:00:07.0',
          audioPosition: '0:00:00',
          audioState: 'Not listened',
          lastListenDateTime: '',
          audioFileName: '$enteredFileNameNoExt.mp3',
          audioFileSize: '56 KB',
          isMusicQuality: false, // Is spoken quality
          audioPlaySpeed: '1.0',
          audioVolume: '50.0 %',
          audioCommentNumber: 1,
          doDropDown: true,
        );

        // Now, we verify the created comment showing the converted
        // audio text

        // First, find the Youtube playlist audio ListTile Text widget
        Finder audioTitleTileTextWidgetFinder = find.text(enteredFileNameNoExt);

        // Then obtain the audio ListTile widget enclosing the Text widget
        // by finding its ancestor
        Finder audioTitleTileWidgetFinder = find.ancestor(
          of: audioTitleTileTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now we want to tap the popup menu of the audioTitle ListTile

        // Find the leading menu icon button of the audioTitle ListTile
        // and tap on it
        Finder audioTitleTileLeadingMenuIconButton = find.descendant(
          of: audioTitleTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioTitleTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the 'Audio Comments ...' popup menu item and
        // tap on it
        Finder audioCommentsPopupMenuItem =
            find.byKey(const Key("popup_menu_audio_comment"));

        await tester.tap(audioCommentsPopupMenuItem);
        await tester.pumpAndSettle();

        // Verify that the audio comments list of the dialog has 1 comment
        // item

        Finder audioCommentsLstFinder = find.byKey(const Key(
          'audioCommentsListKey',
        ));

        // Ensure the list has one child widgets
        expect(
          tester.widget<ListBody>(audioCommentsLstFinder).children.length,
          1,
        );

        List<String> expectedTitles = [
          'Text',
        ];

        List<String> expectedContents = [
          initialTextToConvertStr,
        ];

        List<String> expectedStartPositions = [
          '0:00',
        ];

        List<String> expectedEndPositions = [
          '0:07',
        ];

        List<String> expectedCreationDates = [
          frenchDateFormatYy.format(DateTime.now()), // created comment
          '04/09/25',
        ];

        List<String> expectedUpdateDates = [
          '',
        ];

        // Verify content of each list item
        IntegrationTestUtil.verifyCommentsInCommentListDialog(
            tester: tester,
            commentListDialogFinder: audioCommentsLstFinder,
            commentsNumber: 1,
            expectedTitlesLst: expectedTitles,
            expectedContentsLst: expectedContents,
            expectedStartPositionsLst: expectedStartPositions,
            expectedEndPositionsLst: expectedEndPositions,
            expectedCreationDatesLst: expectedCreationDates,
            expectedUpdateDatesLst: expectedUpdateDates);

        // Now close the comment list dialog
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Now unselect the 'local' playlist
        await IntegrationTestUtil.selectPlaylist(
          tester: tester,
          playlistToSelectTitle: unselectedLocalPlaylistTitle,
        );

        // Now, reopen the convert text to audio dialog
        await IntegrationTestUtil.typeOnPlaylistMenuItem(
          tester: tester,
          playlistTitle: unselectedLocalPlaylistTitle,
          playlistMenuKeyStr: 'popup_menu_convert_text_to_audio_in_playlist',
        );

        // Now enter a new text to convert
        const String nextTextToConvertStr = "un deux trois.";
        await tester.enterText(textFieldFinder, nextTextToConvertStr);
        await tester.pump();

        // Tap the feminine checkbox to change the voice
        Finder feminineCheckbox = find.byKey(const Key('femineVoiceCheckbox'));
        await tester.tap(feminineCheckbox);
        await tester.pump();

        // Now click on Create MP3 button to create the audio
        createMP3ButtonFinder =
            find.byKey(const Key('create_audio_file_button'));
        await tester.tap(createMP3ButtonFinder);
        await tester.pumpAndSettle();

        // Enter the same mp3 file name as before
        mp3FileNameTextFieldFinder =
            find.byKey(const Key('textToConvertTextField'));

        await tester.enterText(
            mp3FileNameTextFieldFinder, enteredFileNameNoExt);
        await tester.pump();

        // Tap on the create mp3 button
        saveMP3FileButton = find.byKey(const Key('create_mp3_button_key'));
        await tester.tap(saveMP3FileButton);
        await Future.delayed(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // Now check the confirm dialog which indicates that the saved
        // file name already exist and ask to confirm or cancel the
        // save operation.
        await IntegrationTestUtil.verifyConfirmActionDialog(
          tester: tester,
          confirmActionDialogTitle:
              "The file \"$enteredFileNameNoExt.mp3\" already exists in the playlist \"$unselectedLocalPlaylistTitle\". If you want to replace it with the new version, click on the \"Confirm\" button. Otherwise, click on the \"Cancel\" button and you will be able to define a different file name.",
          confirmActionDialogMessagePossibleLst: [
            "",
          ],
          closeDialogWithConfirmButton: true,
        );

        await Future.delayed(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
          tester: tester,
          warningDialogMessage:
              "The audio created by the text to MP3 conversion\n\n\"$enteredFileNameNoExt.mp3\"\n\nwas replaced in local playlist \"$unselectedLocalPlaylistTitle\".",
          isWarningConfirming: true,
        );

        // Now close the convert text to audio dialog by tapping
        // the Cancel button
        cancelButtonFinder =
            find.byKey(const Key('convertTextToAudioCloseButton'));
        await tester.tap(cancelButtonFinder);
        await tester.pumpAndSettle();

        // Now select the 'local' playlist
        await IntegrationTestUtil.selectPlaylist(
          tester: tester,
          playlistToSelectTitle: unselectedLocalPlaylistTitle,
        );

        // Tap the 'Toggle List' button to close the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the converted audio sub title in the selected Youtube
        // playlist audio list
        IntegrationTestUtil.checkAudioSubTitlesOrderInListTile(
          tester: tester,
          audioSubTitlesAcceptableLst: [
            '0:00:00.8 6 KB converted on ${DateFormat('dd/MM/yyyy').format(now)} at ${DateFormat('HH:mm').format(now)}',
          ],
          firstAudioListTileIndex: 0,
        );

        // Verifying all audio info dialog fields related of the
        // converted audio type
        await IntegrationTestUtil.verifyAudioInfoDialog(
          tester: tester,
          audioType: AudioType.textToSpeech,
          validVideoTitleOrAudioTitle: enteredFileNameNoExt,
          audioDownloadDateTime:
              '${DateFormat('dd/MM/yyyy').format(now)} ${DateFormat('HH:mm').format(now)}', // this is the imported date time
          isAudioPlayable: true,
          audioEnclosingPlaylistTitle: unselectedLocalPlaylistTitle,
          audioDuration: '0:00:00.8',
          audioPosition: '0:00:00',
          audioState: 'Not listened',
          lastListenDateTime: '',
          audioFileName: '$enteredFileNameNoExt.mp3',
          audioFileSize: '6 KB',
          isMusicQuality: false, // Is spoken quality
          audioPlaySpeed: '1.0',
          audioVolume: '50.0 %',
          audioCommentNumber: 2,
        );

        // Now, we verify the second created comment showing the new
        // converted audio text

        // First, find the Youtube playlist audio ListTile Text widget
        audioTitleTileTextWidgetFinder = find.text(enteredFileNameNoExt);

        // Then obtain the audio ListTile widget enclosing the Text widget
        // by finding its ancestor
        audioTitleTileWidgetFinder = find.ancestor(
          of: audioTitleTileTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now we want to tap the popup menu of the audioTitle ListTile

        // Find the leading menu icon button of the audioTitle ListTile
        // and tap on it
        audioTitleTileLeadingMenuIconButton = find.descendant(
          of: audioTitleTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioTitleTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the 'Audio Comments ...' popup menu item and
        // tap on it
        audioCommentsPopupMenuItem =
            find.byKey(const Key("popup_menu_audio_comment"));

        await tester.tap(audioCommentsPopupMenuItem);
        await tester.pumpAndSettle();

        // Verify that the audio comments list of the dialog has 1 comment
        // item

        audioCommentsLstFinder = find.byKey(const Key(
          'audioCommentsListKey',
        ));

        // Ensure the list has one child widgets
        expect(
          tester.widget<ListBody>(audioCommentsLstFinder).children.length,
          2,
        );

        expectedTitles = [
          'Text',
          'Text',
        ];

        expectedContents = [
          initialTextToConvertStr,
          nextTextToConvertStr,
        ];

        expectedStartPositions = [
          '0:00',
          '0:00',
        ];

        expectedEndPositions = [
          '0:07',
          '0:01',
        ];

        expectedCreationDates = [
          frenchDateFormatYy.format(DateTime.now()), // created comment
          frenchDateFormatYy.format(DateTime.now()), // created comment
        ];

        expectedUpdateDates = [
          '',
          '',
        ];

        // Verify content of each list item
        IntegrationTestUtil.verifyCommentsInCommentListDialog(
            tester: tester,
            commentListDialogFinder: audioCommentsLstFinder,
            commentsNumber: 2,
            expectedTitlesLst: expectedTitles,
            expectedContentsLst: expectedContents,
            expectedStartPositionsLst: expectedStartPositions,
            expectedEndPositionsLst: expectedEndPositions,
            expectedCreationDatesLst: expectedCreationDates,
            expectedUpdateDatesLst: expectedUpdateDates);

        // Now close the comment list dialog
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
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

        // Tap on the appbar menu item 'Save Playlists Audio MP3 Files
        // to Zip ...'
        await IntegrationTestUtil.typeOnAppbarMenuItem(
          tester: tester,
          appbarMenuKeyStr: 'appBarMenuSavePlaylistsAudioMp3FilesToZip',
        );

        await IntegrationTestUtil.verifySetValueToTargetDialog(
          tester: tester,
          dialogTitle: 'Set the Download Date',
          dialogMessage:
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
        await IntegrationTestUtil.verifyConfirmActionDialog(
          tester: tester,
          confirmActionDialogTitle: "Prevision of the save duration",
          confirmActionDialogMessagePossibleLst: [
            "Saving the audio MP3 files will take this estimated duration (hh:mm:ss): 0:00:01.",
            "Saving the audio MP3 files will take this estimated duration (hh:mm:ss): 0:00:02.",
          ],
          closeDialogWithConfirmButton: true,
        );

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

        // Tap on the appbar menu item 'Save Playlists Audio's MP3 to ZIP File'
        // menu
        await IntegrationTestUtil.typeOnAppbarMenuItem(
          tester: tester,
          appbarMenuKeyStr: 'appBarMenuSavePlaylistsAudioMp3FilesToZip',
        );

        await IntegrationTestUtil.verifySetValueToTargetDialog(
          tester: tester,
          dialogTitle: 'Set the Download Date',
          dialogMessage:
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
        await IntegrationTestUtil.verifyConfirmActionDialog(
          tester: tester,
          confirmActionDialogTitle: "Prevision of the save duration",
          confirmActionDialogMessagePossibleLst: [
            "Saving the audio MP3 files will take this estimated duration (hh:mm:ss): 0:00:01.",
            "Saving the audio MP3 files will take this estimated duration (hh:mm:ss): 0:00:02.",
          ],
          closeDialogWithConfirmButton: true,
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

        // Tap on the appbar menu item 'Save Playlists Audio's MP3 to ZIP File'
        // menu
        await IntegrationTestUtil.typeOnAppbarMenuItem(
          tester: tester,
          appbarMenuKeyStr: 'appBarMenuSavePlaylistsAudioMp3FilesToZip',
        );

        await IntegrationTestUtil.verifySetValueToTargetDialog(
          tester: tester,
          dialogTitle: 'Set the Download Date',
          dialogMessage:
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
        await IntegrationTestUtil.verifyConfirmActionDialog(
          tester: tester,
          confirmActionDialogTitle: "Prevision of the save duration",
          confirmActionDialogMessagePossibleLst: [
            "Saving the audio MP3 files will take this estimated duration (hh:mm:ss): 0:00:00.",
          ],
          closeDialogWithConfirmButton: true,
        );

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

        await IntegrationTestUtil.verifySetValueToTargetDialog(
          tester: tester,
          dialogTitle: 'Set the Download Date',
          dialogMessage:
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
        await IntegrationTestUtil.verifyConfirmActionDialog(
          tester: tester,
          confirmActionDialogTitle: "Prevision of the save duration",
          confirmActionDialogMessagePossibleLst: [
            "Saving the audio MP3 files will take this estimated duration (hh:mm:ss): 0:00:01.",
            "Saving the audio MP3 files will take this estimated duration (hh:mm:ss): 0:00:02.",
          ],
          closeDialogWithConfirmButton: true,
        );

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

        await IntegrationTestUtil.verifySetValueToTargetDialog(
          tester: tester,
          dialogTitle: 'Set the Download Date',
          dialogMessage:
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
        await IntegrationTestUtil.verifyConfirmActionDialog(
          tester: tester,
          confirmActionDialogTitle: "Prevision of the save duration",
          confirmActionDialogMessagePossibleLst: [
            "Saving the audio MP3 files will take this estimated duration (hh:mm:ss): 0:00:01.",
            "Saving the audio MP3 files will take this estimated duration (hh:mm:ss): 0:00:02.",
          ],
          closeDialogWithConfirmButton: true,
        );

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

        await IntegrationTestUtil.verifySetValueToTargetDialog(
          tester: tester,
          dialogTitle: 'Set the Download Date',
          dialogMessage:
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
        await IntegrationTestUtil.verifyConfirmActionDialog(
          tester: tester,
          confirmActionDialogTitle: "Prevision of the save duration",
          confirmActionDialogMessagePossibleLst: [
            "Saving the audio MP3 files will take this estimated duration (hh:mm:ss): 0:00:00.",
          ],
          closeDialogWithConfirmButton: true,
        );

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
            doDeleteExistingPlaylists: false,
            onAndroid: true,
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
            doDeleteExistingPlaylists: false,
            onAndroid: true,
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
            doDeleteExistingPlaylists: false,
            onAndroid: true,
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
            doDeleteExistingPlaylists: false,
            onAndroid: true,
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
            doDeleteExistingPlaylists: false,
            onAndroid: true,
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
            doDeleteExistingPlaylists: false,
            onAndroid: true,
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
            doDeleteExistingPlaylists: false,
            onAndroid: true,
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
            doDeleteExistingPlaylists: false,
            onAndroid: true,
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
            doDeleteExistingPlaylists: false,
            onAndroid: true,
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
          doDeleteExistingPlaylists: false,
          onAndroid: true,
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
          doDeleteExistingPlaylists: false,
          onAndroid: true,
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
          doDeleteExistingPlaylists: false,
          onAndroid: true,
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
          doDeleteExistingPlaylists: false,
          onAndroid: true,
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
    audioSubTitlesAcceptableLst: audioSubTitles,
    firstAudioListTileIndex: playlistsTitles.length,
  );
}

Future<void> _verifyListenAndCreateMp3ButtonsState({
  required WidgetTester tester,
  required bool areEnabled,
}) async {
  if (areEnabled) {
    IntegrationTestUtil.verifyWidgetIsEnabled(
      tester: tester,
      widgetKeyStr: 'listen_text_button',
    );
    IntegrationTestUtil.verifyWidgetIsEnabled(
      tester: tester,
      widgetKeyStr: 'create_audio_file_button',
    );
  } else {
    IntegrationTestUtil.verifyWidgetIsDisabled(
      tester: tester,
      widgetKeyStr: 'listen_text_button',
    );
    IntegrationTestUtil.verifyWidgetIsDisabled(
      tester: tester,
      widgetKeyStr: 'create_audio_file_button',
    );
  }
}

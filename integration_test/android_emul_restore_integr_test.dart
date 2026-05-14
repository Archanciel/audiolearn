import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/views/widgets/convert_text_to_audio_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import 'package:audiolearn/constants.dart';

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
          corresponding to existing playlist(s) contain additional audios to which comments and pictures
          are associated. This situation happens if the AudioLearn application exists on two different
          engines and the user wants to restore the playlists, comments and pictures from one computer
          to another in order to add to the target pc or smartphone the audios downloaded on the source
          engine. The audio mp3 files are not added since they are not in the zip file. But the Audio
          objects are added to the existing playlist and so can be redownloaded if needed.''',
      () {
    group('''From Windows zip.''', () {
      testWidgets(
          '''Unique playlist restore + save, not replace existing playlist. Restore unique playlist Windows zip
            containing 'S8 audio' playlist to Android application which contains 'S8 audio' and 'local'
            playlists. The restored 'S8 audio' playlist contains additional audios to which comments and
            pictures are associated. After restoring the playlist, the playlist is saved. First as individual
            playlist saving and then as multiple playlists saving.''',
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
          doDeleteExistingPlaylistsNotContainedInZip: false,
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
          doDeleteExistingPlaylistsNotContainedInZip: false,
          verifySetValueToTargetDialog: true,
          onAndroid: true,
        );

        // Must be used on Android emulator, otherwise the confirmation
        // dialog is not displayed and can not be verifyed !
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Verify the displayed warning confirmation dialog
        await IntegrationTestUtil.verifyAndCloseWarningDialog(
          tester: tester,
          warningDialogMessage:
              'Restored 0 playlist saved individually, 2 comment and 2 picture JSON files as well as 2 picture JPG file(s) in the application pictures directory and 2 audio reference(s) and 0 added plus 0 deleted plus 0 modified comment(s) in existing audio comment file(s) from "/storage/emulated/0/Documents/test/audiolearn/Windows S8 audio.zip".',
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

        await IntegrationTestUtil.typeOnPlaylistMenuItem(
          tester: tester,
          playlistTitle: 'S8 audio',
          playlistMenuKeyStr:
              'popup_menu_save_playlist_comments_pictures_to_zip',
        );

        // Verify the displayed warning confirmation dialog
        await IntegrationTestUtil.verifyAndCloseWarningDialog(
          tester: tester,
          warningDialogMessage:
              "Saved playlist, comment and picture JSON files to \"$kApplicationPathAndroidTest${path.separator}$kSavedPlaylistsDirName${path.separator}S8 audio.zip\".\n\nSaved also 2 picture JPG file(s) in the ZIP file.",
          isWarningConfirming: true,
        );

        // Tap the appbar leading popup menu button Then, the 'Save
        // Playlists and Comments to zip File' menu is selected.
        await IntegrationTestUtil.typeOnAppbarMenuItem(
          tester: tester,
          appbarMenuKeyStr: 'appBarMenuSavePlaylistsAndCommentsToZip',
        );

        // Does not check the "Add all JPG pictures to ZIP" checkbox
        await IntegrationTestUtil.verifySetValueToTargetDialog(
          tester: tester,
          dialogTitle: 'Playlists Backup to ZIP',
          dialogMessage:
              "Checking the \"Add all JPG pictures to ZIP\" checkbox will add all the application audio pictures to the created ZIP. This is only useful if the ZIP file will be used to restore another application.",
          checkboxLabel: "Add all JPG pictures to ZIP",
          closeDialog: true,
        );

        String saveZipFilePath =
            '$kApplicationPathAndroidTest${path.separator}$kSavedPlaylistsDirName';

        String actualMessage = tester
            .widget<Text>(find.byKey(const Key('warningDialogMessage')).last)
            .data!;

        expect(
          actualMessage,
          contains(
            "Saved playlist, comment and picture JSON files as well as application settings to \"$saveZipFilePath${path.separator}audioLearn_",
          ),
        );

        expect(
          actualMessage,
          contains(
            "Saved also 2 picture JPG file(s) in same directory / pictures.",
          ),
        );
      });
      testWidgets(
          '''Multiple playlists restore + save, not replace existing playlists. Restore multiple playlists Windows
             zip containing 'S8 audio' and 'local' playlists to Android application which contain 'S8 audio' and
             'local' playlists. The restored 'S8 audio' and 'local' playlists contains additional audios to which
             comments and pictures are associated. After restoring the playlists, the playlists are saved.''',
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
          doDeleteExistingPlaylistsNotContainedInZip: false,
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
          doDeleteExistingPlaylistsNotContainedInZip: false,
          verifySetValueToTargetDialog: true,
          onAndroid: true,
        );

        // Must be used on Android emulator, otherwise the confirmation
        // dialog is not displayed and can not be verifyed !
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Verify the displayed warning confirmation dialog
        await IntegrationTestUtil.verifyAndCloseWarningDialog(
          tester: tester,
          warningDialogMessage:
              'Restored 0 playlist, 3 comment and 3 picture JSON files as well as 0 picture JPG file(s) in the application pictures directory and 4 audio reference(s) and 0 added plus 0 deleted plus 0 modified comment(s) in existing audio comment file(s) and the application settings from "/storage/emulated/0/Documents/test/audiolearn/Windows 2 existing playlists with new audios.zip".',
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

        // Tap the appbar leading popup menu button Then, the 'Save
        // Playlists and Comments to zip File' menu is selected.
        await IntegrationTestUtil.typeOnAppbarMenuItem(
          tester: tester,
          appbarMenuKeyStr: 'appBarMenuSavePlaylistsAndCommentsToZip',
        );

        // Does not check the "Add all JPG pictures to ZIP" checkbox
        await IntegrationTestUtil.verifySetValueToTargetDialog(
          tester: tester,
          dialogTitle: 'Playlists Backup to ZIP',
          dialogMessage:
              "Checking the \"Add all JPG pictures to ZIP\" checkbox will add all the application audio pictures to the created ZIP. This is only useful if the ZIP file will be used to restore another application.",
          checkboxLabel: "Add all JPG pictures to ZIP",
          closeDialog: true,
        );

        String saveZipFilePath =
            '$kApplicationPathAndroidTest${path.separator}$kSavedPlaylistsDirName';

        String actualMessage = tester
            .widget<Text>(find.byKey(const Key('warningDialogMessage')).last)
            .data!;

        expect(
          actualMessage,
          contains(
            "Saved playlist, comment and picture JSON files as well as application settings to \"$saveZipFilePath${path.separator}audioLearn_",
          ),
        );
      });
      testWidgets(
          '''Unique playlist restore, not replace existing playlist. Restore unique playlist Windows zip
            containing 'Les plus belles chansons chrétiennes' playlist to Android application which contains
            'S8 audio' and 'local' playlists. All audios of the restored playlist 'Les plus belles chansons
            chrétiennes' are then deleted. Afterward, the playlist 'Les plus belles chansons chrétiennes'
            is restored again so that the deleted audios will be re-added.''',
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
          doDeleteExistingPlaylistsNotContainedInZip: false,
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
          doDeleteExistingPlaylistsNotContainedInZip: false,
          onAndroid: true,
        );

        // Must be used on Android emulator, otherwise the confirmation
        // dialog is not displayed and can not be verifyed !
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Verify the displayed warning confirmation dialog
        await IntegrationTestUtil.verifyAndCloseWarningDialog(
          tester: tester,
          warningDialogMessage:
              'Restored 1 playlist saved individually, 3 comment and 1 picture JSON files as well as 1 picture JPG file(s) in the application pictures directory and 22 audio reference(s) and 0 added plus 0 deleted plus 0 modified comment(s) in existing audio comment file(s) from "/storage/emulated/0/Documents/test/audiolearn/Windows Les plus belles chansons chrétiennes.zip".\n\nSince the playlist\n  "Les plus belles chansons chrétiennes"\nwas created, it is positioned at the end of the playlist list at position 3.',
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
          "0:05:11.2 2.37 MB at 1.69 MB/sec on 01/07/2024 at 16:35",
          "0:06:06.4 2.79 MB at 2.73 MB/sec on 07/01/2024 at 16:36",
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
            playlists. The restored 'S8 audio' playlist contains additional audios to which comments and
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
          doDeleteExistingPlaylistsNotContainedInZip: false,
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
          doDeleteExistingPlaylistsNotContainedInZip: false,
          verifySetValueToTargetDialog: true,
          onAndroid: true,
        );

        // Must be used on Android emulator, otherwise the confirmation
        // dialog is not displayed and can not be verifyed !
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Verify the displayed warning confirmation dialog
        await IntegrationTestUtil.verifyAndCloseWarningDialog(
          tester: tester,
          warningDialogMessage:
              'Restored 0 playlist saved individually, 2 comment and 2 picture JSON files as well as 0 picture JPG file(s) in the application pictures directory and 2 audio reference(s) and 0 added plus 0 deleted plus 0 modified comment(s) in existing audio comment file(s) from "/storage/emulated/0/Documents/test/audiolearn/Android S8 audio.zip".',
          warningDialogMessageAlternative:
              'Restored 0 playlist saved individually, 2 comment and 2 picture JSON files as well as 2 picture JPG file(s) in the application pictures directory and 2 audio reference(s) and 0 added plus 0 deleted plus 0 modified comment(s) in existing audio comment file(s) from "/storage/emulated/0/Documents/test/audiolearn/Android S8 audio.zip".',
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
             and 'local' playlists. The restored 'S8 audio' and 'local' playlists contains additional audios
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
          doDeleteExistingPlaylistsNotContainedInZip: false,
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
          doDeleteExistingPlaylistsNotContainedInZip: false,
          verifySetValueToTargetDialog: true,
          onAndroid: true,
        );

        // Must be used on Android emulator, otherwise the confirmation
        // dialog is not displayed and can not be verifyed !
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Verify the displayed warning confirmation dialog
        await IntegrationTestUtil.verifyAndCloseWarningDialog(
          tester: tester,
          warningDialogMessage:
              'Restored 0 playlist, 3 comment and 3 picture JSON files as well as 0 picture JPG file(s) in the application pictures directory and 4 audio reference(s) and 0 added plus 0 deleted plus 0 modified comment(s) in existing audio comment file(s) and the application settings from "/storage/emulated/0/Documents/test/audiolearn/Android 2 existing playlists with new audios.zip".',
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
          doDeleteExistingPlaylistsNotContainedInZip: false,
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
              "Only the MP3 relative to the audios listed in the playlist which are not already present in the playlist are restorable.",
          closeDialog: true,
        );

        // Now tap on the 'A single ZIP File' button
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
          doDeleteExistingPlaylistsNotContainedInZip: false,
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

        // Now tap on the 'A single ZIP File' button
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
    group('''Import audios functionality.''', () {
      testWidgets(
          '''Importing one audio test. Verify conversion warning. Then reimporting it and verify
          the not imported warning. Normally, the imported audios are not located in a playlist
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
          doDeleteExistingPlaylistsNotContainedInZip: false,
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

        // Now tap on the 'A single ZIP File' button
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

        await IntegrationTestUtil.verifyAndCloseWarningDialog(
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

        await IntegrationTestUtil.verifyAndCloseWarningDialog(
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
          audioDownloadDateTimeOne:
              "${DateFormat('dd/MM/yyyy').format(now)} ${DateFormat('HH:mm').format(now)}", // this is the imported date time
          isAudioPlayable: true,
          audioEnclosingPlaylistTitle: localPlaylistTitle,
          audioDuration: '0:10:51.9',
          audioPosition: '0:00:00.0',
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
          '''2 audios present in the source playlist exist in the playlist which will import
          all audios of the source playlist. This situation will display 2 warnings, one
          audio import confirmation and one already existing audios not imported warning.
          Normally, the imported audios are not located in a playlist !''',
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
          doDeleteExistingPlaylistsNotContainedInZip: false,
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

        // Now tap on the 'A single ZIP File' button
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

        await IntegrationTestUtil.verifyAndCloseWarningDialog(
          tester: tester,
          warningDialogMessage:
              "Audio(s)\n\n\"$fileName_1\",\n\"$fileName_2\",\n\"$fileName_3\",\n\"$fileName_5\"\n\nimported to local playlist \"$localPlaylistTitle\".",
          isWarningConfirming: true,
        );

        await IntegrationTestUtil.verifyAndCloseWarningDialog(
          tester: tester,
          warningDialogMessage:
              "Audio(s)\n\n\"$fileName_4\"\n\nNOT imported to local playlist \"$localPlaylistTitle\" since the playlist directory already contains the audio(s).",
        );

        // Re-import the same audios to verify the not imported warning\

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

        await IntegrationTestUtil.verifyAndCloseWarningDialog(
          tester: tester,
          warningDialogMessage:
              "Audio(s)\n\n\"$fileName_1\",\n\"$fileName_2\",\n\"$fileName_3\",\n\"$fileName_4\",\n\"$fileName_5\"\n\nNOT imported to local playlist \"$localPlaylistTitle\" since the playlist directory already contains the audio(s).",
        );
      });
    });
    group(
        '''Convert text to audio. IF THE GROUP CAN NOT RUN DUE TO MISSING PERMISSIONS, RUN THE
             APP ON THE EMULATOR AND THEN, WITHOUT UNRUNNING THE APP, RUN THIS GROUP.''',
        () {
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
          doDeleteExistingPlaylistsNotContainedInZip: false,
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

        // First, set the application language to french
        await IntegrationTestUtil.setApplicationLanguage(
          tester: tester,
          language: Language.french,
        );

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
          'Convertir le texte en audio',
        );

        // Verify the presence of the help icon button
        expect(find.byIcon(Icons.help_outline), findsOneWidget);

        // Verify the text to convert title
        final Text textToConvert =
            tester.widget<Text>(find.byKey(const Key('textToConvertTitleKey')));
        expect(
          textToConvert.data,
          'Texte à convertir, { = silence',
        );

        // Verify the voice selection title
        final Text conversionVoiceSelection = tester
            .widget<Text>(find.byKey(const Key('voiceSelectionTitleKey')));
        expect(
          conversionVoiceSelection.data,
          'Sélection de la voix:',
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
        expect(find.text('Entrez votre texte ici ...'), findsOneWidget);

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
        expect(find.text('Entrez votre texte ici ...'), findsOneWidget);

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
          find.text('Nom du fichier MP3'),
          findsOneWidget,
        );

        // Verify the text to convert title
        expect(
          find.text('Entrer le nom du fichier MP3'),
          findsOneWidget,
        );

        // Verify the presence of the hint text in the MP3 file name
        // TextField
        expect(find.text('nom de fichier'), findsOneWidget);
        expect(find.text('.mp3'), findsOneWidget);

        const String enteredFileNameNoExt = 'convertedAudio';
        Finder mp3FileNameTextFieldFinder =
            find.byKey(const Key('mp3FileNameTextFieldKey'));

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

        await IntegrationTestUtil.verifyAndCloseWarningDialog(
          tester: tester,
          warningDialogMessage:
              "L'audio créé par la conversion de texte en MP3\n\n\"$enteredFileNameNoExt.mp3\"\n\na été ajouté à la playlist Youtube \"$selectedYoutubePlaylistTitle\".",
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
            '0:00:05.6 56.4 Ko converti le ${DateFormat('dd/MM/yyyy').format(now)} à ${DateFormat('HH:mm').format(now)}',
          ],
          firstAudioListTileIndex: 0,
        );

        // Verifying all audio info dialog fields related of the
        // converted audio type
        await IntegrationTestUtil.verifyAudioInfoDialog(
          tester: tester,
          audioType: AudioType.textToSpeech,
          validVideoTitleOrAudioTitle: enteredFileNameNoExt,
          audioDownloadDateTimeOne:
              '${DateFormat('dd/MM/yyyy').format(now)} ${DateFormat('HH:mm').format(now)}', // this is the imported date time
          isAudioPlayable: true,
          audioEnclosingPlaylistTitle: selectedYoutubePlaylistTitle,
          audioDuration: '0:00:05.6',
          audioPosition: '0:00:00.0',
          audioState: 'Non écouté',
          lastListenDateTime: '',
          audioFileName: '$enteredFileNameNoExt.mp3',
          audioFileSize: '56.4 Ko',
          isMusicQuality: false, // Is spoken quality
          audioPlaySpeed: '1.25',
          audioVolume: '50.0 %',
          audioCommentNumber: 1,
          language: Language.french,
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
          'Paroles',
        ];

        List<String> expectedContents = [
          initialTextToConvertStr,
        ];

        List<String> expectedStartPositions = [
          '0:00',
        ];

        List<String> expectedEndPositions = [
          '0:06',
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
            find.byKey(const Key('mp3FileNameTextFieldKey'));

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
          confirmActionDialogTitle: "Remplacement du fichier MP3",
          confirmActionDialogMessagePossibleLst: [
            "Le fichier \"$enteredFileNameNoExt.mp3\" existe déjà dans la playlist \"$selectedYoutubePlaylistTitle\". Si vous voulez le remplacer par la nouvelle version, cliquez sur le bouton \"Confirmer\". Sinon, cliquez sur le bouton \"Annuler\" et vous pourrez définir un nom de fichier différent.",
          ],
          closeDialogWithConfirmButton: true,
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        await IntegrationTestUtil.verifyAndCloseWarningDialog(
          tester: tester,
          warningDialogMessage:
              "L'audio créé par la conversion de texte en MP3\n\n\"$enteredFileNameNoExt.mp3\"\n\na été remplacé dans la playlist Youtube \"$selectedYoutubePlaylistTitle\".",
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
            '0:00:00.7 6.9 Ko converti le ${DateFormat('dd/MM/yyyy').format(now)} à ${DateFormat('HH:mm').format(now)}',
          ],
          firstAudioListTileIndex: 0,
        );

        // Verifying all audio info dialog fields related of the
        // converted audio type
        await IntegrationTestUtil.verifyAudioInfoDialog(
          tester: tester,
          audioType: AudioType.textToSpeech,
          validVideoTitleOrAudioTitle: enteredFileNameNoExt,
          audioDownloadDateTimeOne:
              '${DateFormat('dd/MM/yyyy').format(now)} ${DateFormat('HH:mm').format(now)}', // this is the imported date time
          isAudioPlayable: true,
          audioEnclosingPlaylistTitle: selectedYoutubePlaylistTitle,
          audioDuration: '0:00:00.7',
          audioPosition: '0:00:00.0',
          audioState: 'Non écouté',
          lastListenDateTime: '',
          audioFileName: '$enteredFileNameNoExt.mp3',
          audioFileSize: '6.9 Ko',
          isMusicQuality: false, // Is spoken quality
          audioPlaySpeed: '1.25',
          audioVolume: '50.0 %',
          audioCommentNumber: 2,
          language: Language.french,
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
          'Paroles',
          'Paroles',
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
          '0:06',
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
          doDeleteExistingPlaylistsNotContainedInZip: false,
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

        // First, set the application language to french
        await IntegrationTestUtil.setApplicationLanguage(
          tester: tester,
          language: Language.french,
        );

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
          'Convertir le texte en audio',
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
          find.text('Nom du fichier MP3'),
          findsOneWidget,
        );

        // Verify the text to convert title
        expect(
          find.text('Entrer le nom du fichier MP3'),
          findsOneWidget,
        );

        // Verify the presence of the hint text in the MP3 file name
        // TextField
        expect(find.text('nom de fichier'), findsOneWidget);
        expect(find.text('.mp3'), findsOneWidget);

        const String enteredFileNameNoExt = 'convertedAudio';
        Finder mp3FileNameTextFieldFinder =
            find.byKey(const Key('mp3FileNameTextFieldKey'));

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

        await IntegrationTestUtil.verifyAndCloseWarningDialog(
          tester: tester,
          warningDialogMessage:
              "L'audio créé par la conversion de texte en MP3\n\n\"$enteredFileNameNoExt.mp3\"\n\na été ajouté à la playlist locale \"$unselectedLocalPlaylistTitle\".",
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
            '0:00:07.1 56.4 Ko converti le ${DateFormat('dd/MM/yyyy').format(now)} à ${DateFormat('HH:mm').format(now)}',
          ],
          firstAudioListTileIndex: 0,
        );

        // Verifying all audio info dialog fields related of the
        // converted audio type
        await IntegrationTestUtil.verifyAudioInfoDialog(
          tester: tester,
          audioType: AudioType.textToSpeech,
          validVideoTitleOrAudioTitle: enteredFileNameNoExt,
          audioDownloadDateTimeOne:
              '${DateFormat('dd/MM/yyyy').format(now)} ${DateFormat('HH:mm').format(now)}', // this is the imported date time
          isAudioPlayable: true,
          audioEnclosingPlaylistTitle: unselectedLocalPlaylistTitle,
          audioDuration: '0:00:07.1',
          audioPosition: '0:00:00.0',
          audioState: 'Non écouté',
          lastListenDateTime: '',
          audioFileName: '$enteredFileNameNoExt.mp3',
          audioFileSize: '56.4 Ko',
          isMusicQuality: false, // Is spoken quality
          audioPlaySpeed: '1.0',
          audioVolume: '50.0 %',
          audioCommentNumber: 1,
          doDropDown: true,
          language: Language.french,
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
          'Paroles',
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

        // Tap on the 'Select existing file' button
        final Finder replaceFileButtonFinder =
            find.byKey(const Key('select_mp3_file_to_replace_button_key'));
        await tester.tap(replaceFileButtonFinder);
        await tester.pumpAndSettle();

        // The 'convertedAudio.mp3' checkbox is selected

        // Now, tap on the 'Confirm' button to confirm the file selection
        Finder confirmSelectFileButtonFinder =
            find.byKey(const Key('confirm_selection_button_key'));
        await tester.tap(confirmSelectFileButtonFinder);
        await tester.pumpAndSettle();

        // Verify that the 'convertedAudio' file name text was entered in the
        // MP3 file name TextField
        mp3FileNameTextFieldFinder =
            find.byKey(const Key('mp3FileNameTextFieldKey'));
        expect(
          (tester.widget(mp3FileNameTextFieldFinder) as TextField)
              .controller!
              .text,
          enteredFileNameNoExt,
        );

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
          confirmActionDialogTitle: "Remplacement du fichier MP3",
          confirmActionDialogMessagePossibleLst: [
            "Le fichier \"$enteredFileNameNoExt.mp3\" existe déjà dans la playlist \"$unselectedLocalPlaylistTitle\". Si vous voulez le remplacer par la nouvelle version, cliquez sur le bouton \"Confirmer\". Sinon, cliquez sur le bouton \"Annuler\" et vous pourrez définir un nom de fichier différent.",
          ],
          closeDialogWithConfirmButton: true,
        );

        await Future.delayed(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        await IntegrationTestUtil.verifyAndCloseWarningDialog(
          tester: tester,
          warningDialogMessage:
              "L\'audio créé par la conversion de texte en MP3\n\n\"$enteredFileNameNoExt.mp3\"\n\na été remplacé dans la playlist locale \"$unselectedLocalPlaylistTitle\".",
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
            '0:00:00.9 6.9 Ko converti le ${DateFormat('dd/MM/yyyy').format(now)} à ${DateFormat('HH:mm').format(now)}',
          ],
          firstAudioListTileIndex: 0,
        );

        // Verifying all audio info dialog fields related of the
        // converted audio type
        await IntegrationTestUtil.verifyAudioInfoDialog(
          tester: tester,
          audioType: AudioType.textToSpeech,
          validVideoTitleOrAudioTitle: enteredFileNameNoExt,
          audioDownloadDateTimeOne:
              '${DateFormat('dd/MM/yyyy').format(now)} ${DateFormat('HH:mm').format(now)}', // this is the imported date time
          isAudioPlayable: true,
          audioEnclosingPlaylistTitle: unselectedLocalPlaylistTitle,
          audioDuration: '0:00:00.9',
          audioPosition: '0:00:00.0',
          audioState: 'Non écouté',
          lastListenDateTime: '',
          audioFileName: '$enteredFileNameNoExt.mp3',
          audioFileSize: '6.9 Ko',
          isMusicQuality: false, // Is spoken quality
          audioPlaySpeed: '1.0',
          audioVolume: '50.0 %',
          audioCommentNumber: 2,
          language: Language.french,
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
          'Paroles',
          'Paroles',
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
    group('''Audio item menu "Move Audio to Position" tests'.''', () {
      testWidgets(
          '''Chap desc, to 4. For not yet positioned audio Audio item menu "Move Audio to Position" test.
           The not yet positioned audio is "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus".
           It is moved to position 4 and the sort filter parameter is 'Chap desc'.''',
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

        const String restorableZipFileName =
            'audioLearn_move audio to position.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 6529),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        const String priereOnePlaylistTitle =
            'Prières 1';
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylistsNotContainedInZip: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            priereOnePlaylistTitle,
          ],
          onAndroid: true,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester
            .pumpAndSettle(); // Enter the not yet positioned audio position

        // Verify the the initial ordered audio titles

        List<String> audioPositionedTitles = [
          "7_Prière pour Dieu",
          "6_Prière au Seigneur",
          "5_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "4_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
        ];

        // Find the audio list widget using its key
        Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -300));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
            firstAudioListTileIndex: 1);

        // Upload the audio list

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll up action
        await tester.drag(listFinder, const Offset(0, 3000));
        await tester.pumpAndSettle();

        // Now we want to tap the popup menu of the Audio ListTile
        // "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus"

        const String audioToPositionTitle =
            "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus";

        // First, find the Audio sublist ListTile Text widget
        final Finder audioToPositionTitleTextWidgetFinder =
            find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        final Finder audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        final Finder audioToPositionListTileLeadingMenuIconButton =
            find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        final Finder popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Verify the dialog title
        expect(find.text('Move Audio to Int Position'), findsOneWidget);

        // Find the TextField using the Key
        final Finder textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Retrieve the TextField widget
        final TextField textField = tester.widget<TextField>(textFieldFinder);

        // Verify the initial value of the TextField

        expect(textField.controller!.text, "");

        // Enter the Audio position

        const String audioPosition = '4';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "6_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "5_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "4_Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus",
          "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -300));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
            firstAudioListTileIndex: 2);

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
      });
      testWidgets(
          '''Chap desc, to 1. For not yet positioned audio Audio item menu "Move Audio to Position" test.
           The not yet positioned audio is "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus".
           It is moved to position 1 and the sort filter parameter is 'Chap desc'.''',
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

        const String restorableZipFileName =
            'audioLearn_move audio to position.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 6529),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        const String priereOnePlaylistTitle =
            'Prières 1';
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylistsNotContainedInZip: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            priereOnePlaylistTitle,
          ],
          onAndroid: true,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester
            .pumpAndSettle(); // Enter the not yet positioned audio position

        // Verify the the initial ordered audio titles

        List<String> audioPositionedTitles = [
          "7_Prière pour Dieu",
          "6_Prière au Seigneur",
          "5_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "4_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
        ];

        // Find the audio list widget using its key
        Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -300));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
            firstAudioListTileIndex: 1);

        // Upload the audio list

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll up action
        await tester.drag(listFinder, const Offset(0, 3000));
        await tester.pumpAndSettle();

        // Now we want to tap the popup menu of the Audio ListTile
        // "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus"

        const String audioToPositionTitle =
            "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus";

        // First, find the Audio sublist ListTile Text widget
        final Finder audioToPositionTitleTextWidgetFinder =
            find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        final Finder audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        final Finder audioToPositionListTileLeadingMenuIconButton =
            find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        final Finder popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        final Finder textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        const String audioPosition = '1';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "6_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "5_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "4_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "3_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "2_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          "1_Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -300));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
            firstAudioListTileIndex: 2);

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
      });
      testWidgets(
          '''Chap desc, to 26. For not yet positioned audio Audio item menu "Move Audio to Position" test.
           The not yet positioned audio is "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus".
           It is moved to position 26 and the sort filter parameter is 'Chap desc'.''',
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

        const String restorableZipFileName =
            'audioLearn_move audio to position.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 6529),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        const String priereOnePlaylistTitle =
            'Prières 1';
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylistsNotContainedInZip: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            priereOnePlaylistTitle,
          ],
          onAndroid: true,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester
            .pumpAndSettle(); // Enter the not yet positioned audio position

        // Verify the the initial ordered audio titles

        List<String> audioPositionedTitles = [
          "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus",
          "26_Les jours se termineront",
          "25_Seigneur, merci pour Tes promesses",
          "24_Seigneur, une nouvelle journée commence",
          "23_Dieu dit",
          "22_Prière de Padre Pio",
          "21_L'amour doit remplacer la peur",
          "20_Dieu dit - Je marche maintenant au milieu de Mon peuple",
        ];

        // Find the audio list widget using its key
        Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll up action
        await tester.drag(listFinder, const Offset(0, 3000));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Now we want to tap the popup menu of the Audio ListTile
        // "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus"

        const String audioToPositionTitle =
            "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus";

        // First, find the Audio sublist ListTile Text widget
        final Finder audioToPositionTitleTextWidgetFinder =
            find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        final Finder audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        final Finder audioToPositionListTileLeadingMenuIconButton =
            find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        final Finder popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        final Finder textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        const String audioPosition = '26';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "27_Les jours se termineront",
          "26_Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus",
          "25_Seigneur, merci pour Tes promesses",
          "24_Seigneur, une nouvelle journée commence",
          "23_Dieu dit",
          "22_Prière de Padre Pio",
          "21_L'amour doit remplacer la peur",
          "20_Dieu dit - Je marche maintenant au milieu de Mon peuple",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll up action
        await tester.drag(listFinder, const Offset(0, 3000));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
      });
      testWidgets(
          '''Chap desc, to 27. For not yet positioned audio Audio item menu "Move Audio to Position" test.
           The not yet positioned audio is "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus".
           It is moved to position 27 and the sort filter parameter is 'Chap desc'.''',
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

        const String restorableZipFileName =
            'audioLearn_move audio to position.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 6529),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        const String priereOnePlaylistTitle =
            'Prières 1';
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylistsNotContainedInZip: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            priereOnePlaylistTitle,
          ],
          onAndroid: true,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester
            .pumpAndSettle(); // Enter the not yet positioned audio position

        // Verify the the initial ordered audio titles

        List<String> audioPositionedTitles = [
          "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus",
          "26_Les jours se termineront",
          "25_Seigneur, merci pour Tes promesses",
          "24_Seigneur, une nouvelle journée commence",
          "23_Dieu dit",
          "22_Prière de Padre Pio",
          "21_L'amour doit remplacer la peur",
          "20_Dieu dit - Je marche maintenant au milieu de Mon peuple",
        ];

        // Find the audio list widget using its key
        Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll up action
        await tester.drag(listFinder, const Offset(0, 3000));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Now we want to tap the popup menu of the Audio ListTile
        // "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus"

        const String audioToPositionTitle =
            "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus";

        // First, find the Audio sublist ListTile Text widget
        final Finder audioToPositionTitleTextWidgetFinder =
            find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        final Finder audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        final Finder audioToPositionListTileLeadingMenuIconButton =
            find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        final Finder popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        final Finder textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        const String audioPosition = '27';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "27_Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus",
          "26_Les jours se termineront",
          "25_Seigneur, merci pour Tes promesses",
          "24_Seigneur, une nouvelle journée commence",
          "23_Dieu dit",
          "22_Prière de Padre Pio",
          "21_L'amour doit remplacer la peur",
          "20_Dieu dit - Je marche maintenant au milieu de Mon peuple",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, 3000));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
      });
      testWidgets(
          '''Chap desc, to 28. For not yet positioned audio Audio item menu "Move Audio to Position" test.
           The not yet positioned audio is "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus".
           Also that the position is set to 28, the audio is moved to position 27 which is the maximum
           possible position and the sort filter parameter is 'Chap desc'.''',
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

        const String restorableZipFileName =
            'audioLearn_move audio to position.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 6529),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        const String priereOnePlaylistTitle =
            'Prières 1';
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylistsNotContainedInZip: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            priereOnePlaylistTitle,
          ],
          onAndroid: true,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester
            .pumpAndSettle(); // Enter the not yet positioned audio position

        // Verify the the initial ordered audio titles

        List<String> audioPositionedTitles = [
          "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus",
          "26_Les jours se termineront",
          "25_Seigneur, merci pour Tes promesses",
          "24_Seigneur, une nouvelle journée commence",
          "23_Dieu dit",
          "22_Prière de Padre Pio",
          "21_L'amour doit remplacer la peur",
          "20_Dieu dit - Je marche maintenant au milieu de Mon peuple",
        ];

        // Find the audio list widget using its key
        Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll up action
        await tester.drag(listFinder, const Offset(0, 3000));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Now we want to tap the popup menu of the Audio ListTile
        // "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus"

        const String audioToPositionTitle =
            "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus";

        // First, find the Audio sublist ListTile Text widget
        final Finder audioToPositionTitleTextWidgetFinder =
            find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        final Finder audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        final Finder audioToPositionListTileLeadingMenuIconButton =
            find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        final Finder popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        final Finder textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        const String audioPosition = '28';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "27_Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus",
          "26_Les jours se termineront",
          "25_Seigneur, merci pour Tes promesses",
          "24_Seigneur, une nouvelle journée commence",
          "23_Dieu dit",
          "22_Prière de Padre Pio",
          "21_L'amour doit remplacer la peur",
          "20_Dieu dit - Je marche maintenant au milieu de Mon peuple",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, 3000));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
      });
      testWidgets(
          '''Chap asc, to 4. For not yet positioned audio Audio item menu "Move Audio to Position" test.
           The not yet positioned audio is "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus".
           It is moved to position 4 and the sort filter parameter is 'Chap asc'.''',
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

        const String restorableZipFileName =
            'audioLearn_move audio to position.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 6529),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        const String priereOnePlaylistTitle =
            'Prières 1';
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylistsNotContainedInZip: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            priereOnePlaylistTitle,
          ],
          onAndroid: true,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester
            .pumpAndSettle(); // Enter the not yet positioned audio position

        // Verify the the initial ordered audio titles

        List<String> audioPositionedTitles = [
          "7_Prière pour Dieu",
          "6_Prière au Seigneur",
          "5_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "4_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
        ];

        // Find the audio list widget using its key
        Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -300));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 1,
        );

        // Select 'Chap asc' sort filter parameter

        await IntegrationTestUtil.selectSortFilterParmsInDropDownButton(
          tester: tester,
          sortFilterParmsName: 'Chap asc',
        );

        // Upload the audio list

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -3000));
        await tester.pumpAndSettle();

        // Now we want to tap the popup menu of the Audio ListTile
        // "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus"

        const String audioToPositionTitle =
            "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus";

        // First, find the Audio sublist ListTile Text widget
        final Finder audioToPositionTitleTextWidgetFinder =
            find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        final Finder audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        final Finder audioToPositionListTileLeadingMenuIconButton =
            find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        final Finder popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        final Finder textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        const String audioPosition = '4';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "4_Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus",
          "5_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "6_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll up action
        await tester.drag(listFinder, const Offset(0, 500));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
      });
      testWidgets(
          '''Chap asc, to 1. For not yet positioned audio Audio item menu "Move Audio to Position" test.
           The not yet positioned audio is "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus".
           It is moved to position 1 and the sort filter parameter is 'Chap asc'.''',
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

        const String restorableZipFileName =
            'audioLearn_move audio to position.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 6529),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        const String priereOnePlaylistTitle =
            'Prières 1';
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylistsNotContainedInZip: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            priereOnePlaylistTitle,
          ],
          onAndroid: true,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester
            .pumpAndSettle(); // Enter the not yet positioned audio position

        // Select 'Chap asc' sort filter parameter

        await IntegrationTestUtil.selectSortFilterParmsInDropDownButton(
          tester: tester,
          sortFilterParmsName: 'Chap asc',
        );

        // Verify the the initial ordered audio titles

        List<String> audioPositionedTitles = [
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "4_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "5_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "6_Prière au Seigneur",
          "7_Prière pour Dieu",
        ];

        // Find the audio list widget using its key
        Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll up action
        await tester.drag(listFinder, const Offset(0, 300));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Upload the audio list

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -3000));
        await tester.pumpAndSettle();

        // Now we want to tap the popup menu of the Audio ListTile
        // "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus"

        const String audioToPositionTitle =
            "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus";

        // First, find the Audio sublist ListTile Text widget
        final Finder audioToPositionTitleTextWidgetFinder =
            find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        final Finder audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        final Finder audioToPositionListTileLeadingMenuIconButton =
            find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        final Finder popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        final Finder textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        const String audioPosition = '1';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "1_Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus",
          "2_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          "3_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "4_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "5_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "6_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "7_Prière au Seigneur",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll up action
        await tester.drag(listFinder, const Offset(0, 3000));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
      });
      testWidgets(
          '''Chap asc, to 26. For not yet positioned audio Audio item menu "Move Audio to Position" test.
           The not yet positioned audio is "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus".
           It is moved to position 26 and the sort filter parameter is 'Chap asc'.''',
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

        const String restorableZipFileName =
            'audioLearn_move audio to position.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 6529),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        const String priereOnePlaylistTitle =
            'Prières 1';
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylistsNotContainedInZip: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            priereOnePlaylistTitle,
          ],
          onAndroid: true,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester
            .pumpAndSettle(); // Enter the not yet positioned audio position

        // Select 'Chap asc' sort filter parameter

        await IntegrationTestUtil.selectSortFilterParmsInDropDownButton(
          tester: tester,
          sortFilterParmsName: 'Chap asc',
        );

        // Verify the the initial ordered audio titles

        List<String> audioPositionedTitles = [
          "21_L'amour doit remplacer la peur",
          "22_Prière de Padre Pio",
          "23_Dieu dit",
          "24_Seigneur, une nouvelle journée commence",
          "25_Seigneur, merci pour Tes promesses",
          "26_Les jours se termineront",
          "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus",
        ];

        // Find the audio list widget using its key
        Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -3000));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 1,
        );

        // Upload the audio list

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Now we want to tap the popup menu of the Audio ListTile
        // "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus"

        const String audioToPositionTitle =
            "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus";

        // First, find the Audio sublist ListTile Text widget
        final Finder audioToPositionTitleTextWidgetFinder =
            find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        final Finder audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        final Finder audioToPositionListTileLeadingMenuIconButton =
            find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        final Finder popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        final Finder textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        const String audioPosition = '26';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "21_L'amour doit remplacer la peur",
          "22_Prière de Padre Pio",
          "23_Dieu dit",
          "24_Seigneur, une nouvelle journée commence",
          "25_Seigneur, merci pour Tes promesses",
          "26_Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus",
          "27_Les jours se termineront",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -3000));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 1,
        );

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
      });
      testWidgets(
          '''Chap asc, to 27. For not yet positioned audio Audio item menu "Move Audio to Position" test.
           The not yet positioned audio is "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus".
           It is moved to position 27 and the sort filter parameter is 'Chap asc'.''',
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

        const String restorableZipFileName =
            'audioLearn_move audio to position.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 6529),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        const String priereOnePlaylistTitle =
            'Prières 1';
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylistsNotContainedInZip: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            priereOnePlaylistTitle,
          ],
          onAndroid: true,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester
            .pumpAndSettle(); // Enter the not yet positioned audio position

        // Select 'Chap asc' sort filter parameter

        await IntegrationTestUtil.selectSortFilterParmsInDropDownButton(
          tester: tester,
          sortFilterParmsName: 'Chap asc',
        );

        // Verify the the initial ordered audio titles

        List<String> audioPositionedTitles = [
          "21_L'amour doit remplacer la peur",
          "22_Prière de Padre Pio",
          "23_Dieu dit",
          "24_Seigneur, une nouvelle journée commence",
          "25_Seigneur, merci pour Tes promesses",
          "26_Les jours se termineront",
          "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus",
        ];

        // Find the audio list widget using its key
        Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -3000));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 1,
        );

        // Upload the audio list

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Now we want to tap the popup menu of the Audio ListTile
        // "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus"

        const String audioToPositionTitle =
            "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus";

        // First, find the Audio sublist ListTile Text widget
        final Finder audioToPositionTitleTextWidgetFinder =
            find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        final Finder audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        final Finder audioToPositionListTileLeadingMenuIconButton =
            find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        final Finder popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        final Finder textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        const String audioPosition = '27';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "21_L'amour doit remplacer la peur",
          "22_Prière de Padre Pio",
          "23_Dieu dit",
          "24_Seigneur, une nouvelle journée commence",
          "25_Seigneur, merci pour Tes promesses",
          "26_Les jours se termineront",
          "27_Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -3000));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 1,
        );

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
      });
      testWidgets(
          '''Chap asc, to 28. For not yet positioned audio Audio item menu "Move Audio to Position" test.
           The not yet positioned audio is "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus".
           Also that the position is set to 28, the audio is moved to position 27 which is the maximum
           possible position and the sort filter parameter is 'Chap asc'.''',
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

        const String restorableZipFileName =
            'audioLearn_move audio to position.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 6529),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        const String priereOnePlaylistTitle =
            'Prières 1';
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylistsNotContainedInZip: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            priereOnePlaylistTitle,
          ],
          onAndroid: true,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester
            .pumpAndSettle(); // Enter the not yet positioned audio position

        // Select 'Chap asc' sort filter parameter

        await IntegrationTestUtil.selectSortFilterParmsInDropDownButton(
          tester: tester,
          sortFilterParmsName: 'Chap asc',
        );

        // Verify the the initial ordered audio titles

        List<String> audioPositionedTitles = [
          "21_L'amour doit remplacer la peur",
          "22_Prière de Padre Pio",
          "23_Dieu dit",
          "24_Seigneur, une nouvelle journée commence",
          "25_Seigneur, merci pour Tes promesses",
          "26_Les jours se termineront",
          "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus",
        ];

        // Find the audio list widget using its key
        Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -3000));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 1,
        );

        // Upload the audio list

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Now we want to tap the popup menu of the Audio ListTile
        // "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus"

        const String audioToPositionTitle =
            "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus";

        // First, find the Audio sublist ListTile Text widget
        final Finder audioToPositionTitleTextWidgetFinder =
            find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        final Finder audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        final Finder audioToPositionListTileLeadingMenuIconButton =
            find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        final Finder popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        final Finder textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        const String audioPosition = '28';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "21_L'amour doit remplacer la peur",
          "22_Prière de Padre Pio",
          "23_Dieu dit",
          "24_Seigneur, une nouvelle journée commence",
          "25_Seigneur, merci pour Tes promesses",
          "26_Les jours se termineront",
          "27_Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -3000));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 1,
        );

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
      });
      testWidgets(
          '''applied. For not yet positioned audio Audio item menu "Move Audio to Position" test.''',
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

        const String restorableZipFileName =
            'audioLearn_move audio to position.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 6529),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        const String priereOnePlaylistTitle =
            'Prières 1';
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylistsNotContainedInZip: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            priereOnePlaylistTitle,
          ],
          onAndroid: true,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester
            .pumpAndSettle(); // Enter the not yet positioned audio position

        // Verify the the initial ordered audio titles

        List<String> audioPositionedTitles = [
          "7_Prière pour Dieu",
          "6_Prière au Seigneur",
          "5_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "4_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
        ];

        // Find the audio list widget using its key
        Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -300));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Select 'applied' sort filter parameter

        await IntegrationTestUtil.selectSortFilterParmsInDropDownButton(
          tester: tester,
          sortFilterParmsName: 'applied',
        );

        // Upload the audio list

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll up action
        await tester.drag(listFinder, const Offset(0, 500));
        await tester.pumpAndSettle();

        // Now we want to tap the popup menu of the Audio ListTile
        // "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus"

        const String audioToPositionTitle =
            "Laissez tomber les 'pourquoi'...  #mariavaltorta #jesus";

        // First, find the Audio sublist ListTile Text widget
        final Finder audioToPositionTitleTextWidgetFinder =
            find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        final Finder audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        final Finder audioToPositionListTileLeadingMenuIconButton =
            find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        final Finder popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        final Finder textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        const String audioPosition = '4';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the displayed warning

        // Verify the displayed warning  dialog
        await IntegrationTestUtil.verifyAndCloseWarningDialog(
          tester: tester,
          warningDialogMessage:
              "Changing the audio position is only possible if the playlist sort filter order is \"Audio chapter\".",
        );

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
      });
      testWidgets(
          '''Chap desc, moving down for already positioned audios, execute a first time the Audio item
           menu "Move Audio to Position". Then on another positioned audio, execute the same item menu.''',
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

        const String restorableZipFileName =
            'audioLearn_move audio to position.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 6529),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        const String priereOnePlaylistTitle =
            'Prières 1';
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylistsNotContainedInZip: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            priereOnePlaylistTitle,
          ],
          onAndroid: true,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester
            .pumpAndSettle(); // Enter the not yet positioned audio position

        // Verify the the initial ordered audio titles

        List<String> audioPositionedTitles = [
          "7_Prière pour Dieu",
          "6_Prière au Seigneur",
          "5_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "4_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
        ];

        // Find the audio list widget using its key
        Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -300));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Now we want to tap the popup menu of the Audio ListTile
        // "6_Prière au Seigneur"

        String audioToPositionTitle = "6_Prière au Seigneur";

        // First, find the Audio sublist ListTile Text widget
        Finder audioToPositionTitleTextWidgetFinder =
            find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        Finder audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        Finder audioToPositionListTileLeadingMenuIconButton = find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        Finder popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        Finder textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        String audioPosition = '3';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "7_Prière pour Dieu",
          "6_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "5_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "4_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "3_Prière au Seigneur",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -300));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Now we want to move another already positioned audio

        audioToPositionTitle =
            "4_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!";

        // First, find the Audio sublist ListTile Text widget
        audioToPositionTitleTextWidgetFinder = find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        audioToPositionListTileLeadingMenuIconButton = find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        audioPosition = '1';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "7_Prière pour Dieu",
          "6_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "5_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "4_Prière au Seigneur",
          "3_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "2_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          "1_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -300));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
      });
      testWidgets(
          '''Chap desc, moving down 1 position only for already positioned audios, execute a first time the Audio
           item menu "Move Audio to Position".''', (WidgetTester tester) async {
        await IntegrationTestUtil.initializeAndroidApplicationAndSelectPlaylist(
          tester: tester,
          tapOnPlaylistToggleButton: false,
        );

        // Now initializing the application on the Android emulator using
        // zip restoration.

        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        const String restorableZipFileName =
            'audioLearn_move audio to position.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 6529),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        const String priereOnePlaylistTitle =
            'Prières 1';
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylistsNotContainedInZip: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            priereOnePlaylistTitle,
          ],
          onAndroid: true,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester
            .pumpAndSettle(); // Enter the not yet positioned audio position

        // Verify the the initial ordered audio titles

        List<String> audioPositionedTitles = [
          "7_Prière pour Dieu",
          "6_Prière au Seigneur",
          "5_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "4_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
        ];

        // Find the audio list widget using its key
        Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -300));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Now we want to tap the popup menu of the Audio ListTile
        // "6_Prière au Seigneur"

        String audioToPositionTitle = "6_Prière au Seigneur";

        // First, find the Audio sublist ListTile Text widget
        Finder audioToPositionTitleTextWidgetFinder =
            find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        Finder audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        Finder audioToPositionListTileLeadingMenuIconButton = find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        Finder popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        Finder textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        String audioPosition = '5';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "7_Prière pour Dieu",
          "6_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "5_Prière au Seigneur",
          "4_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -300));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
      });
      testWidgets(
          '''Chap desc, moving up for already positioned audios, execute a first time the Audio item
           menu "Move Audio to Position". Then on another positioned audio, execute the same item menu.''',
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

        const String restorableZipFileName =
            'audioLearn_move audio to position.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 6529),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        const String priereOnePlaylistTitle =
            'Prières 1';
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylistsNotContainedInZip: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            priereOnePlaylistTitle,
          ],
          onAndroid: true,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester
            .pumpAndSettle(); // Enter the not yet positioned audio position

        // Verify the the initial ordered audio titles

        List<String> audioPositionedTitles = [
          "7_Prière pour Dieu",
          "6_Prière au Seigneur",
          "5_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "4_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
        ];

        // Find the audio list widget using its key
        Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -300));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Now we want to tap the popup menu of the Audio ListTile
        // "6_Prière au Seigneur"

        String audioToPositionTitle =
            "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!";

        // First, find the Audio sublist ListTile Text widget
        Finder audioToPositionTitleTextWidgetFinder =
            find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        Finder audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        Finder audioToPositionListTileLeadingMenuIconButton = find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        Finder popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        Finder textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        String audioPosition = '6';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "7_Prière pour Dieu",
          "6_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "5_Prière au Seigneur",
          "4_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "3_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -300));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Now we want to move another already positioned audio

        audioToPositionTitle =
            "4_Père céleste, merci pour cette nouvelle journée que Tu me donnes.";
        // First, find the Audio sublist ListTile Text widget
        audioToPositionTitleTextWidgetFinder = find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        audioToPositionListTileLeadingMenuIconButton = find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        audioPosition = '7';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "7_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "6_Prière pour Dieu",
          "5_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "4_Prière au Seigneur",
          "3_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -300));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
      });
      testWidgets(
          '''Chap desc, moving up 1 position only for already positioned audios, execute a first time the
           Audio item menu "Move Audio to Position".''',
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

        const String restorableZipFileName =
            'audioLearn_move audio to position.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 6529),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        const String priereOnePlaylistTitle =
            'Prières 1';
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylistsNotContainedInZip: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            priereOnePlaylistTitle,
          ],
          onAndroid: true,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester
            .pumpAndSettle(); // Enter the not yet positioned audio position

        // Verify the the initial ordered audio titles

        List<String> audioPositionedTitles = [
          "7_Prière pour Dieu",
          "6_Prière au Seigneur",
          "5_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "4_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
        ];

        // Find the audio list widget using its key
        Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -300));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Now we want to tap the popup menu of the Audio ListTile
        // "6_Prière au Seigneur"

        String audioToPositionTitle =
            "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!";

        // First, find the Audio sublist ListTile Text widget
        Finder audioToPositionTitleTextWidgetFinder =
            find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        Finder audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        Finder audioToPositionListTileLeadingMenuIconButton = find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        Finder popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        Finder textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        String audioPosition = '4';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "7_Prière pour Dieu",
          "6_Prière au Seigneur",
          "5_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "4_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "3_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -300));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
      });
      testWidgets(
          '''Chap asc, moving up for already positioned audios, execute a first time the Audio
           item menu "Move Audio to Position". Then on another positioned audio, execute the same
           item menu.''', (WidgetTester tester) async {
        await IntegrationTestUtil.initializeAndroidApplicationAndSelectPlaylist(
          tester: tester,
          tapOnPlaylistToggleButton: false,
        );

        // Now initializing the application on the Android emulator using
        // zip restoration.

        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        const String restorableZipFileName =
            'audioLearn_move audio to position.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 6529),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        const String priereOnePlaylistTitle =
            'Prières 1';
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylistsNotContainedInZip: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            priereOnePlaylistTitle,
          ],
          onAndroid: true,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester
            .pumpAndSettle(); // Enter the not yet positioned audio position

        // Select 'Chap asc' sort filter parameter

        await IntegrationTestUtil.selectSortFilterParmsInDropDownButton(
          tester: tester,
          sortFilterParmsName: 'Chap asc',
        );

        // Verify the the initial ordered audio titles

        List<String> audioPositionedTitles = [
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "4_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "5_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "6_Prière au Seigneur",
          "7_Prière pour Dieu",
        ];

        // Find the audio list widget using its key
        Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll up action
        await tester.drag(listFinder, const Offset(0, 100));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Now we want to tap the popup menu of the Audio ListTile
        // "6_Prière au Seigneur"

        String audioToPositionTitle = "6_Prière au Seigneur";

        // First, find the Audio sublist ListTile Text widget
        Finder audioToPositionTitleTextWidgetFinder =
            find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        Finder audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        Finder audioToPositionListTileLeadingMenuIconButton = find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        Finder popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        Finder textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        String audioPosition = '3';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "3_Prière au Seigneur",
          "4_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "5_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "6_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "7_Prière pour Dieu",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Now we want to move another already positioned audio

        audioToPositionTitle =
            "4_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!";

        // First, find the Audio sublist ListTile Text widget
        audioToPositionTitleTextWidgetFinder = find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        audioToPositionListTileLeadingMenuIconButton = find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        audioPosition = '1';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "1_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "2_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          "3_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "4_Prière au Seigneur",
          "5_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "6_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "7_Prière pour Dieu",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll up action
        await tester.drag(listFinder, const Offset(0, 3000));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
      });
      testWidgets(
          '''Chap asc, moving up 1 position only for already positioned audios, execute a first time
           the Audio item menu "Move Audio to Position".''',
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

        const String restorableZipFileName =
            'audioLearn_move audio to position.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 6529),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        const String priereOnePlaylistTitle =
            'Prières 1';
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylistsNotContainedInZip: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            priereOnePlaylistTitle,
          ],
          onAndroid: true,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester
            .pumpAndSettle(); // Enter the not yet positioned audio position

        // Select 'Chap asc' sort filter parameter

        await IntegrationTestUtil.selectSortFilterParmsInDropDownButton(
          tester: tester,
          sortFilterParmsName: 'Chap asc',
        );

        // Verify the the initial ordered audio titles

        List<String> audioPositionedTitles = [
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "4_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "5_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "6_Prière au Seigneur",
          "7_Prière pour Dieu",
        ];

        // Find the audio list widget using its key
        Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll up action
        await tester.drag(listFinder, const Offset(0, 100));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Now we want to tap the popup menu of the Audio ListTile
        // "6_Prière au Seigneur"

        String audioToPositionTitle = "6_Prière au Seigneur";

        // First, find the Audio sublist ListTile Text widget
        Finder audioToPositionTitleTextWidgetFinder =
            find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        Finder audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        Finder audioToPositionListTileLeadingMenuIconButton = find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        Finder popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        Finder textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        String audioPosition = '5';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "4_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "5_Prière au Seigneur",
          "6_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "7_Prière pour Dieu",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
      });
      testWidgets(
          '''Chap asc, moving down for already positioned audios, execute a first time the Audio
           item menu "Move Audio to Position". Then on another positioned audio, execute the same
           item menu.''', (WidgetTester tester) async {
        await IntegrationTestUtil.initializeAndroidApplicationAndSelectPlaylist(
          tester: tester,
          tapOnPlaylistToggleButton: false,
        );

        // Now initializing the application on the Android emulator using
        // zip restoration.

        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        const String restorableZipFileName =
            'audioLearn_move audio to position.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 6529),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        const String priereOnePlaylistTitle =
            'Prières 1';
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylistsNotContainedInZip: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            priereOnePlaylistTitle,
          ],
          onAndroid: true,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester
            .pumpAndSettle(); // Enter the not yet positioned audio position

        // Select 'Chap asc' sort filter parameter

        await IntegrationTestUtil.selectSortFilterParmsInDropDownButton(
          tester: tester,
          sortFilterParmsName: 'Chap asc',
        );

        // Verify the the initial ordered audio titles

        List<String> audioPositionedTitles = [
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "4_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "5_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "6_Prière au Seigneur",
          "7_Prière pour Dieu",
        ];

        // Find the audio list widget using its key
        Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll up action
        await tester.drag(listFinder, const Offset(0, 100));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Now we want to tap the popup menu of the Audio ListTile
        // "6_Prière au Seigneur"

        String audioToPositionTitle =
            "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!";

        // First, find the Audio sublist ListTile Text widget
        Finder audioToPositionTitleTextWidgetFinder =
            find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        Finder audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        Finder audioToPositionListTileLeadingMenuIconButton = find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        Finder popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        Finder textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        String audioPosition = '5';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "3_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "4_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "5_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "6_Prière au Seigneur",
          "7_Prière pour Dieu",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Now we want to move another already positioned audio

        audioToPositionTitle =
            "4_Père céleste, merci pour cette nouvelle journée que Tu me donnes.";

        // First, find the Audio sublist ListTile Text widget
        audioToPositionTitleTextWidgetFinder = find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        audioToPositionListTileLeadingMenuIconButton = find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        audioPosition = '7';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "3_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "4_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "5_Prière au Seigneur",
          "6_Prière pour Dieu",
          "7_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll up action
        await tester.drag(listFinder, const Offset(0, 3000));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
      });
      testWidgets(
          '''Chap asc, moving down 1 position only for already positioned audios, execute a first
           time the Audio item menu "Move Audio to Position".''',
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

        const String restorableZipFileName =
            'audioLearn_move audio to position.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 6529),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        const String priereOnePlaylistTitle =
            'Prières 1';
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylistsNotContainedInZip: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            priereOnePlaylistTitle,
          ],
          onAndroid: true,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester
            .pumpAndSettle(); // Enter the not yet positioned audio position

        // Select 'Chap asc' sort filter parameter

        await IntegrationTestUtil.selectSortFilterParmsInDropDownButton(
          tester: tester,
          sortFilterParmsName: 'Chap asc',
        );

        // Verify the the initial ordered audio titles

        List<String> audioPositionedTitles = [
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "4_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "5_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "6_Prière au Seigneur",
          "7_Prière pour Dieu",
        ];

        // Find the audio list widget using its key
        Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll up action
        await tester.drag(listFinder, const Offset(0, 100));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Now we want to tap the popup menu of the Audio ListTile
        // "6_Prière au Seigneur"

        String audioToPositionTitle =
            "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!";

        // First, find the Audio sublist ListTile Text widget
        Finder audioToPositionTitleTextWidgetFinder =
            find.text(audioToPositionTitle);

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        Finder audioToPositionListTileWidgetFinder = find.ancestor(
          of: audioToPositionTitleTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the Audio ListTile
        // and tap on it
        Finder audioToPositionListTileLeadingMenuIconButton = find.descendant(
          of: audioToPositionListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(audioToPositionListTileLeadingMenuIconButton);
        await tester.pumpAndSettle();

        // Now find the move audio popup menu item and tap on it
        Finder popupMoveAudioMenuItem =
            find.byKey(const Key("popup_menu_move_audio_to_position"));

        await tester.tap(popupMoveAudioMenuItem);
        await tester.pumpAndSettle();

        // Find the TextField using the Key
        Finder textFieldFinder =
            find.byKey(const Key('audioPositionModificationTextField'));

        // Enter the Audio position

        String audioPosition = '4';

        await tester.enterText(
          textFieldFinder,
          audioPosition,
        );
        await tester.pumpAndSettle();

        // Now tap the 'Move'' button
        await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
        await tester.pumpAndSettle();

        // Verify the the modified ordered audio titles

        audioPositionedTitles = [
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "3_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "4_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "5_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "6_Prière au Seigneur",
          "7_Prière pour Dieu",
        ];

        // Find the audio list widget using its key
        listFinder = find.byKey(const Key('audio_list'));

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Tap the 'Toggle List' button to redisplay the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();
      });
      testWidgets('''Moving Audio to position < actual audio position tests.''',
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

        const String restorableZipFileName =
            'audioLearn_move audio to position.zip';

        mockFilePicker.setSelectedFiles([
          PlatformFile(
              name: restorableZipFileName,
              path:
                  '$kApplicationPathAndroidTest$androidPathSeparator$restorableZipFileName',
              size: 6529),
        ]);

        // In order to create the Android emulator application, execute the
        // 'Restore Playlists, Comments and Settings from Zip File ...' menu
        // without replacing the existing playlists.
        const String priereOnePlaylistTitle =
            'Prières 1';
        await IntegrationTestUtil.executeRestorePlaylists(
          tester: tester,
          doReplaceExistingPlaylists: false,
          doDeleteExistingPlaylistsNotContainedInZip: false,
          playlistTitlesToDelete: [
            'Les plus belles chansons chrétiennes',
            'S8 audio',
            'local',
            priereOnePlaylistTitle,
          ],
          onAndroid: true,
        );

        const String playlistToPositionAudioTitles =
            'Prières 1';

        await IntegrationTestUtil.typeOnPlaylistMenuItem(
          tester: tester,
          playlistTitle: playlistToPositionAudioTitles,
          playlistMenuKeyStr: 'popup_menu_add_audio_position_to_its_title',
        );

        // Verify the presence of the positioned audio in the in the
        // playlist audio list

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester
            .pumpAndSettle(); // Enter the not yet positioned audio position

        // Verify the the initial ordered audio titles

        List<String> audioPositionedTitles = [
          "7_Prière pour Dieu",
          "6_Prière au Seigneur",
          "5_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "4_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
        ];

        // Find the audio list widget using its key
        Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll down action
        await tester.drag(listFinder, const Offset(0, -300));
        await tester.pumpAndSettle();

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioPositionedTitles,
          firstAudioListTileIndex: 0,
        );

        // Now we want to tap the popup menu of the Audio ListTile
        // "6_Prière au Seigneur"

        audioPositionedTitles = [
          "7_Prière pour Dieu",
          "6_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "5_Prière au Seigneur",
          "4_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
        ];

        await _movePositionedAudioAndVerifyResult(
          tester: tester,
          audioToPositionTitle: "6_Prière au Seigneur",
          audioNewPosition: '5',
          expectedAudioPositionedTitles: audioPositionedTitles,
        );

        audioPositionedTitles = [
          "7_Prière pour Dieu",
          "6_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "5_Prière au Seigneur",
          "4_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "2_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          "1_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
        ];

        await _movePositionedAudioAndVerifyResult(
          tester: tester,
          audioToPositionTitle:
              "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          audioNewPosition: '1',
          expectedAudioPositionedTitles: audioPositionedTitles,
        );

        audioPositionedTitles = [
          "7_Prière pour Dieu",
          "6_Père céleste, merci pour cette nouvelle journée que Tu me donnes.",
          "5_Prière au Seigneur",
          "4_JÉSUS, C'EST LE PLUS BEAU NOM _ Louange acoustique",
          "3_Omraam Mikhaël Aïvanhov - Prière - MonDieu je Te donne mon coeur!",
          "2_Seigneur, je T'en prie, mets-moi dans le feu de Ton Amour!",
          "1_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
        ];

        await _movePositionedAudioAndVerifyResult(
          tester: tester,
          audioToPositionTitle:
              "2_Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'",
          audioNewPosition: '0',
          expectedAudioPositionedTitles: audioPositionedTitles,
        );
      });
    });
  });
}

Future<void> _movePositionedAudioAndVerifyResult({
  required WidgetTester tester,
  required String audioToPositionTitle,
  required String audioNewPosition,
  required List<String> expectedAudioPositionedTitles,
}) async {
  // First, find the Audio sublist ListTile Text widget
  Finder audioToPositionTitleTextWidgetFinder = find.text(audioToPositionTitle);

  // Then obtain the Audio ListTile widget enclosing the Text widget by
  // finding its ancestor
  Finder audioToPositionListTileWidgetFinder = find.ancestor(
    of: audioToPositionTitleTextWidgetFinder,
    matching: find.byType(ListTile),
  );

  // Now find the leading menu icon button of the Audio ListTile
  // and tap on it
  Finder audioToPositionListTileLeadingMenuIconButton = find.descendant(
    of: audioToPositionListTileWidgetFinder,
    matching: find.byIcon(Icons.menu),
  );

  // Tap the leading menu icon button to open the popup menu
  await tester.tap(audioToPositionListTileLeadingMenuIconButton);
  await tester.pumpAndSettle();

  // Now find the move audio popup menu item and tap on it
  Finder popupMoveAudioMenuItem =
      find.byKey(const Key("popup_menu_move_audio_to_position"));

  await tester.tap(popupMoveAudioMenuItem);
  await tester.pumpAndSettle();

  // Find the TextField using the Key
  Finder textFieldFinder =
      find.byKey(const Key('audioPositionModificationTextField'));

  // Enter the Audio position

  await tester.enterText(
    textFieldFinder,
    audioNewPosition,
  );
  await tester.pumpAndSettle();

  // Now tap the 'Move'' button
  await tester.tap(find.byKey(const Key('moveAudioToPositionButton')));
  await tester.pumpAndSettle();

  // Verify the the modified ordered audio titles

  // Find the audio list widget using its key
  final Finder listFinder = find.byKey(const Key('audio_list'));

  // Perform the scroll down action
  await tester.drag(listFinder, const Offset(0, -300));
  await tester.pumpAndSettle();

  IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
    tester: tester,
    audioOrPlaylistTitlesOrderedLst: expectedAudioPositionedTitles,
    firstAudioListTileIndex: 0,
  );
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

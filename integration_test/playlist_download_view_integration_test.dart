import 'dart:io';

import 'package:audiolearn/viewmodels/comment_vm.dart';
import 'package:audiolearn/views/widgets/audio_modification_dialog_widget.dart';
import 'package:audiolearn/views/widgets/comment_add_edit_dialog_widget.dart';
import 'package:audiolearn/views/widgets/comment_list_add_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

import 'package:audiolearn/viewmodels/audio_player_vm.dart';
import 'package:audiolearn/views/screen_mixin.dart';
import 'package:audiolearn/constants.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/services/json_data_service.dart';
import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/playlist_list_vm.dart';
import 'package:audiolearn/viewmodels/language_provider_vm.dart';
import 'package:audiolearn/viewmodels/theme_provider_vm.dart';
import 'package:audiolearn/viewmodels/warning_message_vm.dart';
import 'package:audiolearn/views/playlist_download_view.dart';
import 'package:audiolearn/views/widgets/warning_message_display_widget.dart';
import 'package:audiolearn/views/widgets/playlist_list_item_widget.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:audiolearn/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

import '../test/util/test_utility.dart';
import '../test/viewmodels/custom_mock_youtube_explode.dart';
import '../test/viewmodels/mock_audio_download_vm.dart';
import 'integration_test_util.dart';

void main() {
  const String youtubePlaylistId = 'PLzwWSJNcZTMTSAE8iabVB6BCAfFGHHfah';
  const String youtubePlaylistUrl =
      'https://youtube.com/playlist?list=$youtubePlaylistId';
// url used in integration_test/audio_download_vm_integration_test.dart
// which works:
// 'https://youtube.com/playlist?list=PLzwWSJNcZTMRB9ILve6fEIS_OHGrV5R2o';
  const String youtubeNewPlaylistTitle =
      'audio_learn_new_youtube_playlist_test';

  const String testPlaylistDir =
      '$kPlaylistDownloadRootPathWindowsTest\\audio_learn_new_youtube_playlist_test';

  // Necessary to avoid FatalFailureException (FatalFailureException: Failed
  // to perform an HTTP request to YouTube due to a fatal failure. In most
  // cases, this error indicates that YouTube most likely changed something,
  // which broke the library.
  // If this issue persists, please report it on the project's GitHub page.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Playlist Download View test', () {
    testWidgets('Add and then delete Youtube playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
        isTest: true,
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: "temp\\wrong.json");

      WarningMessageVM warningMessageVM = WarningMessageVM();
      MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );
      mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      // using the mockAudioDownloadVM to add the playlist
      // because YoutubeExplode can not access to internet
      // in integration tests in order to download the playlist
      // and so obtain the playlist title
      PlaylistListVM expandablePlaylistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      expandablePlaylistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: expandablePlaylistListVM,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
      );

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list and audio list should exist now but be
      // empty (no ListTile widgets)
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);

      // Enter the new Youtube playlist URL into the url text field
      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        youtubePlaylistUrl,
      );

      // Ensure the url text field contains the entered url
      TextField urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, youtubePlaylistUrl);

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check the value of the AlertDialog dialog title
      Text alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Youtube Playlist');

      // Check the value of the AlertDialog url Text
      Text confirmUrlText =
          tester.widget(find.byKey(const Key('playlistUrlConfirmDialogText')));
      expect(confirmUrlText.data, youtubePlaylistUrl);

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      await checkWarningDialog(
          tester: tester,
          playlistTitle: youtubeNewPlaylistTitle,
          isMusicQuality: false);

      // Ensure the URL TextField was emptied
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, '');

      // The list of Playlist's should have one item now
      expect(find.byType(ListTile), findsOneWidget);

      // Check if the added item is displayed correctly
      final PlaylistListItemWidget playlistListItemWidget =
          tester.widget(find.byType(PlaylistListItemWidget).first);
      expect(playlistListItemWidget.playlist.title, youtubeNewPlaylistTitle);

      // Find the ListTile representing the added playlist

      final Finder firstListTileFinder = find.byType(ListTile).first;

      // Retrieve the ListTile widget
      final ListTile firstPlaylistListTile =
          tester.widget<ListTile>(firstListTileFinder);

      // Ensure that the title is a Text widget and check its data
      expect(firstPlaylistListTile.title, isA<Text>());
      expect(
          (firstPlaylistListTile.title as Text).data, youtubeNewPlaylistTitle);

      // Alternatively, find the ListTile by its title
      expect(
          find.descendant(
              of: firstListTileFinder,
              matching: find.text(
                youtubeNewPlaylistTitle,
              )),
          findsOneWidget);

      // Check the saved local playlist values in the json file

      final String newPlaylistPath = path.join(
        kPlaylistDownloadRootPathWindowsTest,
        youtubeNewPlaylistTitle,
      );

      final newPlaylistFilePathName = path.join(
        newPlaylistPath,
        '$youtubeNewPlaylistTitle.json',
      );

      // Load playlist from the json file
      Playlist loadedNewPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: newPlaylistFilePathName,
        type: Playlist,
      );

      expect(loadedNewPlaylist.title, youtubeNewPlaylistTitle);
      expect(loadedNewPlaylist.id, youtubePlaylistId);
      expect(loadedNewPlaylist.url, youtubePlaylistUrl);
      expect(loadedNewPlaylist.playlistType, PlaylistType.youtube);
      expect(loadedNewPlaylist.playlistQuality, PlaylistQuality.voice);
      expect(loadedNewPlaylist.downloadedAudioLst.length, 0);
      expect(loadedNewPlaylist.playableAudioLst.length, 0);
      expect(loadedNewPlaylist.isSelected, false);
      expect(loadedNewPlaylist.downloadPath, newPlaylistPath);

      // Check that the ordered playlist titles list in the settings
      // data service contains the added playlist title
      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          [youtubeNewPlaylistTitle]);

      // Now test deleting the playlist

      // Open the delete playlist dialog by clicking on the 'Delete
      // playlist ...' playlist menu item

      // Now find the leading menu icon button of the Playlist ListTile
      // and tap on it
      final Finder firstPlaylistListTileLeadingMenuIconButton = find.descendant(
        of: firstListTileFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(firstPlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget =
          tester.widget<Text>(find.byKey(const Key('confirmDialogTitleKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Delete Youtube Playlist "$youtubeNewPlaylistTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('confirmButtonKey')));
      await tester.pumpAndSettle();

      // Check that the ordered playlist titles list in the settings
      // data service is now empty
      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          []);

      // Check that the deleted playlist directory no longer exist
      expect(Directory(newPlaylistPath).existsSync(), false);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets('Add with comma titled Youtube playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
        isTest: true,
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: "temp\\wrong.json");

      WarningMessageVM warningMessageVM = WarningMessageVM();
      MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      const String invalidYoutubePlaylistTitle = 'Johnny Hallyday, songs';

      mockAudioDownloadVM.youtubePlaylistTitle = invalidYoutubePlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      // using the mockAudioDownloadVM to add the playlist
      // because YoutubeExplode can not access to internet
      // in integration tests in order to download the playlist
      // and so obtain the playlist title
      PlaylistListVM expandablePlaylistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      expandablePlaylistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: expandablePlaylistListVM,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
      );

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list and audio list should exist now but be
      // empty (no ListTile widgets)
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);

      // Enter the new Youtube playlist URL into the url text field
      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        youtubePlaylistUrl,
      );
      await tester.pumpAndSettle();

      // Ensure the url text field contains the entered url
      TextField urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, youtubePlaylistUrl);

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
      expect(confirmUrlText.data, youtubePlaylistUrl);

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is shown
      expect(find.byType(WarningMessageDisplayWidget), findsOneWidget);

      // Check the value of the warning dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'WARNING');

      // Check the value of the warning dialog message
      Text warningDialogMessage =
          tester.widget(find.byKey(const Key('warningDialogMessage')));
      expect(warningDialogMessage.data,
          'The Youtube playlist title "$invalidYoutubePlaylistTitle" can not contain any comma. Please correct the title and retry ...');

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Ensure the URL TextField was not emptied
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, '$youtubePlaylistUrl');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets('Add Youtube playlist and then add it again with same URL',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
        isTest: true,
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: "temp\\wrong.json");
      WarningMessageVM warningMessageVM = WarningMessageVM();
      MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );
      mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      // using the mockAudioDownloadVM to add the playlist
      // because YoutubeExplode can not access to internet
      // in integration tests in order to download the playlist
      // and so obtain the playlist title
      PlaylistListVM expandablePlaylistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      expandablePlaylistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: expandablePlaylistListVM,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
      );

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list and audio list should exist now but be
      // empty (no ListTile widgets)
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);

      // Enter the new Youtube playlist URL into the url text field
      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        youtubePlaylistUrl,
      );

      // Ensure the url text field contains the entered url
      TextField urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, youtubePlaylistUrl);

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check the value of the AlertDialog dialog title
      Text alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Youtube Playlist');

      // Check the value of the AlertDialog url Text
      Text confirmUrlText =
          tester.widget(find.byKey(const Key('playlistUrlConfirmDialogText')));
      expect(confirmUrlText.data, youtubePlaylistUrl);

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      await checkWarningDialog(
          tester: tester,
          playlistTitle: youtubeNewPlaylistTitle,
          isMusicQuality: false);

      // Ensure the URL TextField was emptied
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, '');

      // Check the saved local playlist values in the json file

      final String newPlaylistPath = path.join(
        kPlaylistDownloadRootPathWindowsTest,
        youtubeNewPlaylistTitle,
      );

      final newPlaylistFilePathName = path.join(
        newPlaylistPath,
        '$youtubeNewPlaylistTitle.json',
      );

      // Load playlist from the json file
      Playlist loadedNewPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: newPlaylistFilePathName,
        type: Playlist,
      );

      expect(loadedNewPlaylist.title, youtubeNewPlaylistTitle);
      expect(loadedNewPlaylist.id, youtubePlaylistId);
      expect(loadedNewPlaylist.url, youtubePlaylistUrl);
      expect(loadedNewPlaylist.playlistType, PlaylistType.youtube);
      expect(loadedNewPlaylist.playlistQuality, PlaylistQuality.voice);
      expect(loadedNewPlaylist.downloadedAudioLst.length, 0);
      expect(loadedNewPlaylist.playableAudioLst.length, 0);
      expect(loadedNewPlaylist.isSelected, false);
      expect(loadedNewPlaylist.downloadPath, newPlaylistPath);

      // Check that the ordered playlist titles list in the settings
      // data service contains the added playlist title
      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          [youtubeNewPlaylistTitle]);

      // Now test adding the same playlist again

      // Enter the new Youtube playlist URL into the url text field.
      // I don't know why, but the next commented code does not work.

      // await tester.enterText(
      //   find.byKey(const Key('playlistUrlTextField')),
      //   youtubePlaylistUrl,
      // );

      // Solving this putain de problem
      tester
          .widget<TextField>(find.byKey(const Key('playlistUrlTextField')))
          .controller!
          .text = youtubePlaylistUrl;

      await tester.pumpAndSettle();

      // Ensure the url text field contains the entered url
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, youtubePlaylistUrl);

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check the value of the AlertDialog dialog title
      alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Youtube Playlist');

      // Check the value of the AlertDialog url Text
      confirmUrlText =
          tester.widget(find.byKey(const Key('playlistUrlConfirmDialogText')));
      expect(confirmUrlText.data, youtubePlaylistUrl);

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is shown
      expect(find.byType(WarningMessageDisplayWidget), findsOneWidget);

      // Check the value of the warning dialog title
      Text warningDialogTitleText =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitleText.data, 'WARNING');

      // Check the value of the warning dialog message
      Text warningDialogMessage =
          tester.widget(find.byKey(const Key('warningDialogMessage')));
      expect(warningDialogMessage.data,
          'Playlist "$youtubeNewPlaylistTitle" with this URL "$youtubePlaylistUrl" is already in the list of playlists and so won\'t be recreated.');

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Ensure the URL TextField was not emptied
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, youtubePlaylistUrl);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });

    /// The objective of this integration test is to ensure that
    /// the url text field will not be emptied after clicking on
    /// the Cancel button of the add playlist dialog.
    testWidgets(
        'Open the add playlist dialog to add a Youtube playlist and then click on Cancel button',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
        isTest: true,
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: "temp\\wrong.json");
      WarningMessageVM warningMessageVM = WarningMessageVM();
      MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );
      mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      // using the mockAudioDownloadVM to add the playlist
      // because YoutubeExplode can not access to internet
      // in integration tests in order to download the playlist
      // and so obtain the playlist title
      PlaylistListVM expandablePlaylistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      expandablePlaylistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: expandablePlaylistListVM,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
      );

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list and audio list should exist now but be
      // empty (no ListTile widgets)
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);

      // Enter the new Youtube playlist URL into the url text field
      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        youtubePlaylistUrl,
      );

      // Ensure the url text field contains the entered url
      TextField urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, youtubePlaylistUrl);

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check the value of the AlertDialog dialog title
      Text alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Youtube Playlist');

      // Check the value of the AlertDialog url Text
      Text confirmUrlText =
          tester.widget(find.byKey(const Key('playlistUrlConfirmDialogText')));
      expect(confirmUrlText.data, youtubePlaylistUrl);

      // Cancel the addition by tapping the Cancel button in the
      // AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogCancelButton')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is not shown
      expect(find.text('WARNING'), findsNothing);

      // Ensure the URL TextField was not emptied
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, youtubePlaylistUrl);

      // The list of Playlist's should have 0 item
      expect(find.byType(ListTile), findsNothing);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets('Add and then delete local playlist with empty playlist URL',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      const String localPlaylistTitle = 'audio_learn_local_playlist_test';

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list and audio list should exist now but be
      // empty (no ListTile widgets)
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check the value of the AlertDialog dialog title
      Text alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Local Playlist');

      // Check that the AlertDialog url Text is not displayed since
      // a local playlist is added with the playlist URL text field
      // empty
      expect(
        find.byKey(const Key('playlistUrlConfirmDialogText')),
        findsNothing,
      );

      // Enter the title of the local playlist
      await tester.enterText(
        find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')),
        localPlaylistTitle,
      );

      // Check the value of the AlertDialog local playlist title
      // TextField
      TextField localPlaylistTitleTextField = tester.widget(
          find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')));
      expect(
        localPlaylistTitleTextField.controller!.text,
        localPlaylistTitle,
      );

      // Set the quality to music
      await tester
          .tap(find.byKey(const Key('playlistQualityConfirmDialogCheckBox')));
      await tester.pumpAndSettle();

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is shown
      await checkWarningDialog(
        tester: tester,
        playlistTitle: localPlaylistTitle,
        isMusicQuality: true,
      );

      // The list of Playlist's should have one item now
      expect(find.byType(ListTile), findsOneWidget);

      // Check if the added item is displayed correctly
      final PlaylistListItemWidget playlistListItemWidget =
          tester.widget(find.byType(PlaylistListItemWidget).first);
      expect(playlistListItemWidget.playlist.title, localPlaylistTitle);

      // Find the ListTile representing the added playlist

      final Finder firstListTileFinder = find.byType(ListTile).first;

      // Retrieve the ListTile widget
      final ListTile firstPlaylistListTile =
          tester.widget<ListTile>(firstListTileFinder);

      // Ensure that the title is a Text widget and check its data
      expect(firstPlaylistListTile.title, isA<Text>());
      expect((firstPlaylistListTile.title as Text).data, localPlaylistTitle);

      // Alternatively, find the ListTile by its title
      expect(
          find.descendant(
              of: firstListTileFinder,
              matching: find.text(
                localPlaylistTitle,
              )),
          findsOneWidget);

      // Check the saved local playlist values in the json file

      final String newPlaylistPath = path.join(
        kPlaylistDownloadRootPathWindowsTest,
        localPlaylistTitle,
      );

      final newPlaylistFilePathName = path.join(
        newPlaylistPath,
        '$localPlaylistTitle.json',
      );

      // Load playlist from the json file
      Playlist loadedNewPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: newPlaylistFilePathName,
        type: Playlist,
      );

      expect(loadedNewPlaylist.title, localPlaylistTitle);
      expect(loadedNewPlaylist.id, localPlaylistTitle);
      expect(loadedNewPlaylist.url, '');
      expect(loadedNewPlaylist.playlistType, PlaylistType.local);
      expect(loadedNewPlaylist.playlistQuality, PlaylistQuality.music);
      expect(loadedNewPlaylist.downloadedAudioLst.length, 0);
      expect(loadedNewPlaylist.playableAudioLst.length, 0);
      expect(loadedNewPlaylist.isSelected, false);
      expect(loadedNewPlaylist.downloadPath, newPlaylistPath);

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
        isTest: true,
      );

      final settingsPathFileName = path.join(
        kPlaylistDownloadRootPathWindowsTest,
        'settings.json',
      );

      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: settingsPathFileName);

      // Check that the ordered playlist titles list in the settings
      // data service contains the added playlist title
      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          [localPlaylistTitle]);

      // Now test deleting the playlist

      // Open the delete playlist dialog by clicking on the 'Delete
      // playlist ...' playlist menu item

      // Now find the leading menu icon button of the Playlist ListTile
      // and tap on it
      final Finder firstPlaylistListTileLeadingMenuIconButton = find.descendant(
        of: firstListTileFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(firstPlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget =
          tester.widget<Text>(find.byKey(const Key('confirmDialogTitleKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Delete Local Playlist "$localPlaylistTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('confirmButtonKey')));
      await tester.pumpAndSettle();

      // Check that the ordered playlist titles list in the settings
      // data service is now empty

      // Reload the settings data service from the settings json file
      await settingsDataService.loadSettingsFromFile(
        settingsJsonPathFileName: settingsPathFileName,
      );

      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          ['']); // if loading from the settings json file,
      //            the ordered playlist titles list is never
      //            empty. I don't know why, but it is the same
      //            if loading settings from file in add and delete
      //            Youtube playlist !

      // Check that the deleted playlist directory no longer exist
      expect(Directory(newPlaylistPath).existsSync(), false);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets(
        'Add local playlist with title equal to previously created local playlist',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      const String localPlaylistTitle = 'audio_learn_local_playlist_test';

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list and audio list should exist now but be
      // empty (no ListTile widgets)
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Enter the title of the local playlist
      await tester.enterText(
        find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')),
        localPlaylistTitle,
      );

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // The list of Playlist's should have one item now
      expect(find.byType(ListTile), findsOneWidget);

      // Check if the added item is displayed correctly
      final PlaylistListItemWidget playlistListItemWidget =
          tester.widget(find.byType(PlaylistListItemWidget).first);
      expect(playlistListItemWidget.playlist.title, localPlaylistTitle);

      // Add a new local playlist with the same title of the first
      // added Youtube playlist

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Enter the same title of the previously created local playlist
      await tester.enterText(
        find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')),
        localPlaylistTitle,
      );

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is shown
      expect(find.byType(WarningMessageDisplayWidget), findsOneWidget);

      // Check the value of the warning dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'WARNING');

      // Check the value of the warning dialog message
      Text warningDialogMessage =
          tester.widget(find.byKey(const Key('warningDialogMessage')));
      expect(warningDialogMessage.data,
          "Local playlist \"$localPlaylistTitle\" already exists in the list of playlists. Therefore, the local playlist with this title won't be created.");

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets('Add local playlist with invalid title containing a comma',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      const String invalidLocalPlaylistTitle = 'local, with comma';

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list and audio list should exist now but be
      // empty (no ListTile widgets)
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Enter the title of the local playlist
      await tester.enterText(
        find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')),
        invalidLocalPlaylistTitle,
      );

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is shown
      expect(find.byType(WarningMessageDisplayWidget), findsOneWidget);

      // Check the value of the warning dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'WARNING');

      // Check the value of the warning dialog message
      Text warningDialogMessage =
          tester.widget(find.byKey(const Key('warningDialogMessage')));
      expect(warningDialogMessage.data,
          "The local playlist title \"$invalidLocalPlaylistTitle\" can not contain any comma. Please correct the title and retry ...");

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Correct the invalid title removing the comma
      String correctedLocalPlaylistTitle =
          invalidLocalPlaylistTitle.replaceAll(',', '');
      await tester.enterText(
        find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')),
        correctedLocalPlaylistTitle,
      );

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is shown
      await checkWarningDialog(
        tester: tester,
        playlistTitle: correctedLocalPlaylistTitle,
        isMusicQuality: false,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets(
        'Add local playlist with title equal to previously created Youtube playlist',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
        isTest: true,
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: "temp\\wrong.json");
      WarningMessageVM warningMessageVM = WarningMessageVM();
      MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );
      mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      // using the mockAudioDownloadVM to add the playlist
      // because YoutubeExplode can not access to internet
      // in integration tests in order to download the playlist
      // and so obtain the playlist title
      PlaylistListVM expandablePlaylistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      expandablePlaylistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: expandablePlaylistListVM,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
      );

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list and audio list should exist now but be
      // empty (no ListTile widgets)
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);

      // Enter the new Youtube playlist URL into the url text field
      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        youtubePlaylistUrl,
      );

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Add a new local playlist with the same title of the first
      // added local playlist

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      const String localPlaylistTitle = 'audio_learn_new_youtube_playlist_test';

      // Enter the same title of the previously created local playlist
      await tester.enterText(
        find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')),
        localPlaylistTitle,
      );

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is shown
      expect(find.byType(WarningMessageDisplayWidget), findsOneWidget);

      // Check the value of the warning dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'WARNING');

      // Check the value of the warning dialog message
      Text warningDialogMessage =
          tester.widget(find.byKey(const Key('warningDialogMessage')));
      expect(warningDialogMessage.data,
          "Youtube playlist \"$localPlaylistTitle\" already exists in the list of playlists. Therefore, the local playlist with this title won't be created.");

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets(
        'Open the add playlist dialog to add a local playlist and then click on Cancel button',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      const String localPlaylistTitle = 'audio_learn_local_playlist_test';

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list and audio list should exist now but be
      // empty (no ListTile widgets)
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check the value of the AlertDialog dialog title
      Text alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Local Playlist');

      // Check that the AlertDialog url Text is not displayed since
      // a local playlist is added with the playlist URL text field
      // empty
      expect(
        find.byKey(const Key('playlistUrlConfirmDialogText')),
        findsNothing,
      );

      // Enter the title of the local playlist
      await tester.enterText(
        find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')),
        localPlaylistTitle,
      );

      // Check the value of the AlertDialog local playlist title
      // TextField
      TextField localPlaylistTitleTextField = tester.widget(
          find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')));
      expect(
        localPlaylistTitleTextField.controller!.text,
        localPlaylistTitle,
      );

      // Set the quality to music
      await tester
          .tap(find.byKey(const Key('playlistQualityConfirmDialogCheckBox')));
      await tester.pumpAndSettle();

      // Cancel the addition by tapping the Cancel button in the
      // AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogCancelButton')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is not shown
      expect(find.text('WARNING'), findsNothing);

      // The list of Playlist's should have 0 item
      expect(find.byType(ListTile), findsNothing);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });

    /// The objective of this integration test is to ensure that
    /// the url text field will not be emptied after adding a
    /// local playlist, in contrary of what happens after adding
    /// a Youtube playlist.
    testWidgets(
        'Entered a Youtube playlist URL. Then switch to AudioPlayerView and then back to PlaylistView',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list and audio list should exist now but be
      // empty (no ListTile widgets)
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);

      // Enter the new Youtube playlist URL into the url text field.
      // The objective is to test that the url text field will not
      // be emptied after adding a local playlist
      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        youtubePlaylistUrl,
      );

      await tester.pumpAndSettle();

      // Ensure the url text field contains the entered url
      TextField urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, youtubePlaylistUrl);

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen

      final audioPlayerNavButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(audioPlayerNavButton);
      await tester.pumpAndSettle();

      // Now we tap on the PlaylistDownloadView icon button to go
      // back to the PlaylistDownloadView screen

      final playlistDownloadNavButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(playlistDownloadNavButton);
      await tester.pumpAndSettle();

      // Ensure the URL TextField was emptied
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, '');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets('Select then unselect local playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      const String localPlaylistTitle = 'audio_learn_local_playlist_test';

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Enter the title of the local playlist
      await tester.enterText(
        find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')),
        localPlaylistTitle,
      );

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // The list of Playlist's should have one item now
      expect(find.byType(ListTile), findsOneWidget);

      // Verify that the first ListTile checkbox is not
      // selected
      Checkbox firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isFalse);

      // Verify that the selected playlist TextField is empty
      TextField selectedPlaylistTextField =
          tester.widget(find.byKey(const Key('selectedPlaylistTextField')));
      expect(selectedPlaylistTextField.controller!.text, '');

      // Check the saved local playlist values in the json file,
      // before the playlist will be selected

      final String newPlaylistPath = path.join(
        kPlaylistDownloadRootPathWindowsTest,
        localPlaylistTitle,
      );

      final newPlaylistFilePathName = path.join(
        newPlaylistPath,
        '$localPlaylistTitle.json',
      );

      // Load playlist from the json file
      Playlist loadedNewPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: newPlaylistFilePathName,
        type: Playlist,
      );

      expect(loadedNewPlaylist.title, localPlaylistTitle);
      expect(loadedNewPlaylist.id, localPlaylistTitle);
      expect(loadedNewPlaylist.url, '');
      expect(loadedNewPlaylist.playlistType, PlaylistType.local);
      expect(loadedNewPlaylist.playlistQuality, PlaylistQuality.voice);
      expect(loadedNewPlaylist.downloadedAudioLst.length, 0);
      expect(loadedNewPlaylist.playableAudioLst.length, 0);
      expect(loadedNewPlaylist.isSelected, false);
      expect(loadedNewPlaylist.downloadPath, newPlaylistPath);

      // Tap the first ListTile checkbox to select it
      await tester.tap(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      await tester.pumpAndSettle();

      // Verify that the selected playlist TextField contains the
      // title of the selected playlist
      selectedPlaylistTextField =
          tester.widget(find.byKey(const Key('selectedPlaylistTextField')));
      expect(selectedPlaylistTextField.controller!.text, localPlaylistTitle);

      // Check the saved local playlist values in the json file

      // Load playlist from the json file
      Playlist reloadedNewPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: newPlaylistFilePathName,
        type: Playlist,
      );

      expect(reloadedNewPlaylist.title, localPlaylistTitle);
      expect(reloadedNewPlaylist.id, localPlaylistTitle);
      expect(reloadedNewPlaylist.url, '');
      expect(reloadedNewPlaylist.playlistType, PlaylistType.local);
      expect(reloadedNewPlaylist.playlistQuality, PlaylistQuality.voice);
      expect(reloadedNewPlaylist.downloadedAudioLst.length, 0);
      expect(reloadedNewPlaylist.playableAudioLst.length, 0);
      expect(reloadedNewPlaylist.isSelected, true);
      expect(reloadedNewPlaylist.downloadPath, newPlaylistPath);

      // Now tap the first ListTile checkbox to unselect it
      await tester.tap(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      await tester.pumpAndSettle();

      // Verify that the selected playlist TextField is empty
      selectedPlaylistTextField =
          tester.widget(find.byKey(const Key('selectedPlaylistTextField')));
      expect(selectedPlaylistTextField.controller!.text, '');

      // Check the saved local playlist values in the json file

      // Load playlist from the json file
      Playlist rereloadedNewPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: newPlaylistFilePathName,
        type: Playlist,
      );

      expect(rereloadedNewPlaylist.title, localPlaylistTitle);
      expect(rereloadedNewPlaylist.id, localPlaylistTitle);
      expect(rereloadedNewPlaylist.url, '');
      expect(rereloadedNewPlaylist.playlistType, PlaylistType.local);
      expect(rereloadedNewPlaylist.playlistQuality, PlaylistQuality.voice);
      expect(rereloadedNewPlaylist.downloadedAudioLst.length, 0);
      expect(rereloadedNewPlaylist.playableAudioLst.length, 0);
      expect(rereloadedNewPlaylist.isSelected, false);
      expect(rereloadedNewPlaylist.downloadPath, newPlaylistPath);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });

    testWidgets(
        'Add Youtube and local playlist, download the Youtube playlist and restart the app',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      // Adding the Youtube playlist

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
        isTest: true,
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: "temp\\wrong.json");
      WarningMessageVM warningMessageVM = WarningMessageVM();
      MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );
      mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      // using the mockAudioDownloadVM to add the playlist
      // because YoutubeExplode can not access to internet
      // in integration tests in order to download the playlist
      // and so obtain the playlist title
      PlaylistListVM expandablePlaylistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      expandablePlaylistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: expandablePlaylistListVM,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
      );

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list and audio list should exist now but be
      // empty (no ListTile widgets)
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);

      // Enter the new Youtube playlist URL into the url text field
      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        youtubePlaylistUrl,
      );

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Close the warning dialog by tapping on the Ok button.
      // If the warning dialog is not closed, tapping on the
      // 'Add playlist button' button will fail
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Adding the local playlist

      const String localPlaylistTitle = 'audio_learn_local_playlist_test';

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Enter the title of the local playlist
      await tester.enterText(
        find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')),
        localPlaylistTitle,
      );

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Tap the first ListTile checkbox to select it
      await tester.tap(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      await tester.pumpAndSettle();

      // Tap the 'Download All' button to download the selected playlist.
      // This download fails because YoutubeExplode can not access to
      // internet in integration tests in order to download the
      // audio's.
      await tester.tap(find.byKey(const Key('download_sel_playlists_button')));
      await tester.pumpAndSettle();

      // Downloading the Youtube playlist audio can not be done in
      // integration tests because YoutubeExplode can not access to
      // internet. Instead, the audio file and the playlist json file
      // including the audio are copied from the test save directory
      // to the download directory

      String newYoutubePlaylistTitle = 'audio_learn_new_youtube_playlist_test';
      DirUtil.copyFileToDirectorySync(
          sourceFilePathName:
              "$kDownloadAppTestSavedDataDir${path.separator}$newYoutubePlaylistTitle${path.separator}$newYoutubePlaylistTitle.json",
          targetDirectoryPath: testPlaylistDir,
          overwriteFileIfExist: true);
      DirUtil.copyFileToDirectorySync(
        sourceFilePathName:
            "$kDownloadAppTestSavedDataDir${path.separator}$newYoutubePlaylistTitle${path.separator}230701-224750-audio learn test short video two 23-06-10.mp3",
        targetDirectoryPath: testPlaylistDir,
      );

      // now close the app and then restart it in order to load the
      // copied youtube playlist

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets('Add Youtube playlist with invalid URL containing list=',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
        isTest: true,
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: "temp\\wrong.json");
      WarningMessageVM warningMessageVM = WarningMessageVM();
      MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );
      mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      // using the mockAudioDownloadVM to add the playlist
      // because YoutubeExplode can not access to internet
      // in integration tests in order to download the playlist
      // and so obtain the playlist title
      PlaylistListVM expandablePlaylistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      expandablePlaylistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: expandablePlaylistListVM,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
      );

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list and audio list should exist now but be
      // empty (no ListTile widgets)
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);

      const String invalidYoutubePlaylistUrl = 'list=invalid';
      // Enter the invalid Youtube playlist URL into the url text
      // field
      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        invalidYoutubePlaylistUrl,
      );

      // Ensure the url text field contains the entered url
      TextField urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, invalidYoutubePlaylistUrl);

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check the value of the AlertDialog dialog title
      Text alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Youtube Playlist');

      // Check the value of the AlertDialog url Text
      Text confirmUrlText =
          tester.widget(find.byKey(const Key('playlistUrlConfirmDialogText')));
      expect(confirmUrlText.data, invalidYoutubePlaylistUrl);

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is shown
      expect(find.byType(WarningMessageDisplayWidget), findsOneWidget);

      // Check the value of the warning dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'WARNING');

      // Check the value of the warning dialog message
      Text warningDialogMessage =
          tester.widget(find.byKey(const Key('warningDialogMessage')));
      expect(warningDialogMessage.data,
          'Playlist with invalid URL "$invalidYoutubePlaylistUrl" neither added nor modified.');

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Ensure the URL TextField was not emptied
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, invalidYoutubePlaylistUrl);

      // The list of Playlist's should have zero item now
      expect(find.byType(ListTile), findsNothing);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets('Add Youtube playlist with invalid URL', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
        isTest: true,
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: "temp\\wrong.json");
      WarningMessageVM warningMessageVM = WarningMessageVM();
      MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );
      mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      // using the mockAudioDownloadVM to add the playlist
      // because YoutubeExplode can not access to internet
      // in integration tests in order to download the playlist
      // and so obtain the playlist title
      PlaylistListVM expandablePlaylistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      expandablePlaylistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: expandablePlaylistListVM,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
      );

      const String invalidYoutubePlaylistUrl = 'invalid';

      // Enter the invalid Youtube playlist URL into the url text
      // field
      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        invalidYoutubePlaylistUrl,
      );

      // Ensure the url text field contains the entered url
      TextField urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, invalidYoutubePlaylistUrl);

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check the value of the AlertDialog dialog title
      Text alertDialogTitle =
          tester.widget(find.byKey(const Key('playlistConfirmDialogTitleKey')));
      expect(alertDialogTitle.data, 'Add Youtube Playlist');

      // Check the value of the AlertDialog url Text
      Text confirmUrlText =
          tester.widget(find.byKey(const Key('playlistUrlConfirmDialogText')));
      expect(confirmUrlText.data, invalidYoutubePlaylistUrl);

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is shown
      expect(find.byType(WarningMessageDisplayWidget), findsOneWidget);

      // Check the value of the warning dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'WARNING');

      // Check the value of the warning dialog message
      Text warningDialogMessage =
          tester.widget(find.byKey(const Key('warningDialogMessage')));
      expect(warningDialogMessage.data,
          'Playlist with invalid URL "$invalidYoutubePlaylistUrl" neither added nor modified.');

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Ensure the URL TextField was not emptied
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, invalidYoutubePlaylistUrl);

      // The list of Playlist's should have zero item now
      expect(find.byType(ListTile), findsNothing);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets('Download single video audio with invalid URL', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String localAudioPlaylistTitle = 'local_audio_playlist_2';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      WarningMessageVM warningMessageVM = WarningMessageVM();
      MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );
      mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      // using the mockAudioDownloadVM to add the playlist
      // because YoutubeExplode can not access to internet
      // in integration tests in order to download the playlist
      // and so obtain the playlist title
      PlaylistListVM expandablePlaylistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      expandablePlaylistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: expandablePlaylistListVM,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
      );

      const String invalidSingleVideoUrl = 'invalid';

      // Enter the invalid single video URL into the url text
      // field
      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        invalidSingleVideoUrl,
      );

      // Ensure the url text field contains the entered url
      TextField urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, invalidSingleVideoUrl);

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
      expect(alertDialogTitle.data, 'Select a playlist');

      // Find the RadioListTile target playlist in which the audio
      // will be downloaded

      final Finder radioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioPlaylistTitle,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(radioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now verifying the confirm warning dialog message

      // Check the value of the select one playlist
      // confirmation dialog title
      Text confirmationDialogTitle =
          tester.widget(find.byKey(const Key('confirmationDialogTitleKey')));
      expect(confirmationDialogTitle.data, 'CONFIRMATION');

      final Text confirmationDialogMessageTextWidget = tester
          .widget<Text>(find.byKey(const Key('confirmationDialogMessageKey')));

      expect(confirmationDialogMessageTextWidget.data,
          'Confirm target playlist "$localAudioPlaylistTitle" for downloading single video audio.');

      // Now find the ok button of the confirm warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('okButtonKey')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is shown
      expect(find.byType(WarningMessageDisplayWidget), findsOneWidget);

      // Check the value of the warning dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'WARNING');

      // Check the value of the warning dialog message
      Text warningDialogMessage =
          tester.widget(find.byKey(const Key('warningDialogMessage')));
      expect(warningDialogMessage.data,
          'The URL "$invalidSingleVideoUrl" supposed to point to a unique video is invalid. Therefore, no video has been downloaded.');

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Ensure the URL TextField containing the invalid single
      // video URL was not emptied
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, invalidSingleVideoUrl);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
  });
  group('AudioDownloadVM using CustomMockYoutubeExplode Tests', () {
    late CustomMockYoutubeExplode mockYoutubeExplode;

    setUp(() async {
      mockYoutubeExplode = CustomMockYoutubeExplode();
    });

    testWidgets(
        'Download single video audio in playlist already containing the audio',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      WarningMessageVM warningMessageVM = WarningMessageVM();
      // MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
      //   warningMessageVM: warningMessageVM,
      //   isTest: true,
      // );
      // mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      audioDownloadVM.youtubeExplode = mockYoutubeExplode;

      PlaylistListVM expandablePlaylistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      expandablePlaylistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: expandablePlaylistListVM,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        expandablePlaylistListVM: expandablePlaylistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
      );

      const String youtubeAudioSourceAndTargetPlaylistTitle =
          'audio_learn_test_download_2_small_videos';
      const String downloadedSingleVideoAudioTitle =
          'audio learn test short video one';

      // Copy the URL of source playlist audio file which wiil
      // be downloaded to the same (source) playlist, causing a
      // warning error to be displayed ...

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the audio to move to
      // the source Youtube playlist

      // First, find the Playlist ListTile Text widget
      final Finder sourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioSourceAndTargetPlaylistTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder sourcePlaylistListTileWidgetFinder = find.ancestor(
        of: sourcePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder sourcePlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: sourcePlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(sourcePlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder sourceAudioListTileTextWidgetFinder =
          find.text(downloadedSingleVideoAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile and tap
      // on it
      final Finder sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the copy video URL popup menu item and tap on it
      final Finder popupCopyVideoUrlMenuItem =
          find.byKey(const Key("popup_copy_youtube_video_url"));

      await tester.tap(popupCopyVideoUrlMenuItem);
      await tester.pumpAndSettle();

      ClipboardData? clipboardData =
          await Clipboard.getData(Clipboard.kTextPlain);
      String singleVideoToDownloadUrl = clipboardData?.text ?? '';

      // Enter the single video URL to download into the url text
      // field
      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        singleVideoToDownloadUrl,
      );

      // Ensure the url text field contains the entered url
      TextField urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, singleVideoToDownloadUrl);

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
      expect(alertDialogTitle.data, 'Select a playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be downloaded

      final Finder radioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data ==
                youtubeAudioSourceAndTargetPlaylistTitle,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(radioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now verifying the confirm warning dialog message

      // Check the value of the select one playlist
      // confirmation dialog title
      Text confirmationDialogTitle =
          tester.widget(find.byKey(const Key('confirmationDialogTitleKey')));
      expect(confirmationDialogTitle.data, 'CONFIRMATION');

      final Text confirmationDialogMessageTextWidget = tester
          .widget<Text>(find.byKey(const Key('confirmationDialogMessageKey')));

      expect(confirmationDialogMessageTextWidget.data,
          'Confirm target playlist "$youtubeAudioSourceAndTargetPlaylistTitle" for downloading single video audio.');

      // Now find the ok button of the confirm warning dialog
      // and tap on it\
      await tester.tap(find.byKey(const Key('okButtonKey')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is shown
      expect(find.byType(WarningMessageDisplayWidget), findsOneWidget);

      // Check the value of the warning dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'WARNING');

      // Check the value of the warning dialog message
      Text warningDialogMessage =
          tester.widget(find.byKey(const Key('warningDialogMessage')));
      String expectedWarningDialogMessageStr =
          'Audio "$downloadedSingleVideoAudioTitle" is contained in file "230628-033811-audio learn test short video one 23-06-10.mp3" present in the target playlist "$youtubeAudioSourceAndTargetPlaylistTitle" directory and so won\'t be redownloaded.';
      expect(
        warningDialogMessage.data,
        expectedWarningDialogMessageStr,
      );

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Ensure the URL TextField containing the invalid single
      // video URL was not emptied
      urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, singleVideoToDownloadUrl);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
  });
  group('Settings update test', () {
    testWidgets('After moving down a playlist item', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}settings_update_test_initial_audio_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          ['local_music', 'audio_learn_new_youtube_playlist_test']);

      const String localMusicPlaylistTitle = 'local_music';
      const String localAudioPlaylistTitle = 'local_audio';

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list displays two items, but the audio
      // list is empty
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNWidgets(2));

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Enter the title of the local playlist to add
      await tester.enterText(
        find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')),
        localAudioPlaylistTitle,
      );

      // Check the value of the AlertDialog local playlist title
      // TextField
      TextField localPlaylistTitleTextField = tester.widget(
          find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')));
      expect(
        localPlaylistTitleTextField.controller!.text,
        localAudioPlaylistTitle,
      );

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is shown
      expect(find.byType(WarningMessageDisplayWidget), findsOneWidget);

      // Check the value of the warning dialog message
      Text warningDialogMessage =
          tester.widget(find.byKey(const Key('warningDialogMessage')));
      expect(warningDialogMessage.data,
          'Playlist "$localAudioPlaylistTitle" of audio quality added at end of list of playlists.');

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // The list of Playlist's should have three items now
      expect(find.byType(ListTile), findsNWidgets(3));

      // Check if the added item is displayed correctly
      final PlaylistListItemWidget playlistListItemWidget =
          tester.widget(find.byType(PlaylistListItemWidget).first);
      expect(playlistListItemWidget.playlist.title, localMusicPlaylistTitle);

      // Check the saved local playlist values in the json file

      final String newPlaylistPath = path.join(
        kPlaylistDownloadRootPathWindowsTest,
        localAudioPlaylistTitle,
      );

      final newPlaylistFilePathName = path.join(
        newPlaylistPath,
        '$localAudioPlaylistTitle.json',
      );

      // Load playlist from the json file
      Playlist loadedNewPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: newPlaylistFilePathName,
        type: Playlist,
      );

      expect(loadedNewPlaylist.title, localAudioPlaylistTitle);
      expect(loadedNewPlaylist.id, localAudioPlaylistTitle);
      expect(loadedNewPlaylist.url, '');
      expect(loadedNewPlaylist.playlistType, PlaylistType.local);
      expect(loadedNewPlaylist.playlistQuality, PlaylistQuality.voice);
      expect(loadedNewPlaylist.downloadedAudioLst.length, 0);
      expect(loadedNewPlaylist.playableAudioLst.length, 0);
      expect(loadedNewPlaylist.isSelected, false);
      expect(loadedNewPlaylist.downloadPath, newPlaylistPath);

      // reload the settings from the json file to verify it was
      // updated correctly

      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          [
            'local_music',
            'audio_learn_new_youtube_playlist_test',
            'local_audio',
          ]);

      // now move down the added playlist to the second position
      // in the list

      // Find and select the ListTile to move'
      const String playlistToMoveDownTitle = 'local_audio';

      await findThenSelectAndTestListTileCheckbox(
        tester: tester,
        itemTextStr: playlistToMoveDownTitle,
      );

      Finder downButtonFinder =
          find.widgetWithIcon(IconButton, Icons.arrow_drop_down);
      IconButton downButton = tester.widget<IconButton>(downButtonFinder);
      expect(downButton.onPressed, isNotNull);

      // Tap the move down button twice
      await tester.tap(downButtonFinder);
      await tester.pump();
      await tester.tap(downButtonFinder);
      await tester.pump();

      // reload the settings from the json file to verify it was
      // updated correctly

      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          [
            'local_music',
            'local_audio',
            'audio_learn_new_youtube_playlist_test',
          ]);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
  });
  group('Copy or move audio test', () {
    testWidgets(
        'Copy (+ check comment) audio twice. Second copy is refused with warning. Then 3rd time copy and click on cancel button',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String youtubeAudioSourcePlaylistTitle =
          'audio_learn_test_download_2_small_videos';
      const String localAudioTargetPlaylistTitleTwo = 'local_audio_playlist_2';
      const String localAudioTargetPlaylistTitleThree = 'local_3';
      const String copiedAudioTitle = 'audio learn test short video one';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the audio to copy to
      // the target local playlist

      // First, find the source Playlist ListTile Text widget
      Finder sourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioSourcePlaylistTitle);

      // Then obtain the source Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      Finder sourcePlaylistListTileWidgetFinder = find.ancestor(
        of: sourcePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      Finder sourcePlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: sourcePlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(sourcePlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      Finder sourceAudioListTileTextWidgetFinder = find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      Finder sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      Finder sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the copy audio popup menu item and tap on it
      Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_copy_audio_to_playlist"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Check the value of the select one playlist AlertDialog
      // dialog title
      Text alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Sélectionnez une playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be copied

      Finder targetPlaylistRadioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioTargetPlaylistTitleTwo,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(targetPlaylistRadioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Check the value of the Confirm dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'CONFIRMATION');

      // Now verifying the confirm dialog message

      Text warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

      expect(warningDialogMessageTextWidget.data,
          'Audio "audio learn test short video one" copié de la playlist Youtube "audio_learn_test_download_2_small_videos" vers la playlist locale "local_audio_playlist_2".');

      // Now find the ok button of the confirm dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now verifying the selected playlist TextField still
      // contains the title of the source playlist

      TextField selectedPlaylistTextField = tester.widget<TextField>(
          find.byKey(const Key('selectedPlaylistTextField')));

      expect(selectedPlaylistTextField.controller!.text,
          youtubeAudioSourcePlaylistTitle);

      // Now verifying that the source audio still access to its
      // comments

      // First, tap on the source audio ListTile to open the
      // audio player view
      await tester.tap(sourceAudioListTileWidgetFinder);
      await tester.pumpAndSettle();

      // Verify that the comment icon button is highlighted. This indiquates
      // that a comment exist for the audio
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        inkWellButtonKey: 'commentsInkWellButton',
        expectedIcon: Icons.bookmark_outline_outlined,
        expectedIconColor: Colors.white,
        expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
      );

      // Return to the Playlist Download View
      final playlistDownloadViewNavButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(playlistDownloadViewNavButton);
      await tester.pumpAndSettle();

      // Now verifying that the source playlist directory still
      // contains the audio file copied to the target playlist
      List<String> sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle',
        extension: 'mp3',
      );

      expect(sourcePlaylistMp3Lst, [
        "230628-033811-audio learn test short video one 23-06-10.mp3",
        "230628-033813-audio learn test short video two 23-06-10.mp3",
      ]);

      // And verify that the target playlist directory now
      // contains the audio file copied from the source playlist
      List<String> targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetPlaylistTitleTwo',
        extension: 'mp3',
      );

      expect(targetPlaylistMp3Lst,
          ["230628-033811-audio learn test short video one 23-06-10.mp3"]);

      // Find the target ListTile Playlist containing the audio copied
      // from the source playlist

      // First, find the Playlist ListTile Text widget
      final Finder targetPlaylistListTileTextWidgetFinder =
          find.text(localAudioTargetPlaylistTitleTwo);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder targetPlaylistListTileWidgetFinder = find.ancestor(
        of: targetPlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder targetPlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: targetPlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(targetPlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder targetAudioListTileTextWidgetFinder =
          find.text(copiedAudioTitle);

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
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the popup menu item and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_display_audio_info"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Now verifying the display audio info audio copied dialog
      // elements

      // Verify the enclosing playlist title of the copied audio

      final Text enclosingPlaylistTitleTextWidget = tester
          .widget<Text>(find.byKey(const Key('enclosingPlaylistTitleKey')));

      expect(enclosingPlaylistTitleTextWidget.data,
          localAudioTargetPlaylistTitleTwo);

      // Verify the copied from playlist title of the copied audio

      final Text copiedFromPlaylistTitleTextWidget = tester
          .widget<Text>(find.byKey(const Key('copiedFromPlaylistTitleKey')));

      expect(copiedFromPlaylistTitleTextWidget.data,
          youtubeAudioSourcePlaylistTitle);

      // Verify the copied to playlist title of the copied audio

      final Text copiedToPlaylistTitleTextWidget = tester
          .widget<Text>(find.byKey(const Key('copiedToPlaylistTitleKey')));

      expect(copiedToPlaylistTitleTextWidget.data, '');

      // Now find the ok button of the audio info dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('audioInfoOkButtonKey')));
      await tester.pumpAndSettle();

      // Now verifying that the target audio can access to its copied
      // comments

      // First, tap on the source audio ListTile to open the
      // audio player view
      await tester.tap(targetAudioListTileWidgetFinder);
      await tester.pumpAndSettle();

      // Verify that the comment icon button is highlighted. This indiquates
      // that a comment exist for the audio
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        inkWellButtonKey: 'commentsInkWellButton',
        expectedIcon: Icons.bookmark_outline_outlined,
        expectedIconColor: Colors.white,
        expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
      );

      // Return to the Playlist Download View
      await tester.tap(playlistDownloadViewNavButton);
      await tester.pumpAndSettle();

      // Then, we try to copy a second time the audio already copied
      // to the target playlist in order to verify that a warning is
      // displayed informing that the audio was not copied because it
      // is already present in the target playlist

      // Find the ListTile Playlist containing the audio to copy to
      // the target local playlist

      // First, find the source Playlist ListTile Text widget
      sourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioSourcePlaylistTitle);

      // Then obtain the source Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      sourcePlaylistListTileWidgetFinder = find.ancestor(
        of: sourcePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      sourcePlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: sourcePlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(sourcePlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      sourceAudioListTileTextWidgetFinder = find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the copy audio popup menu item and tap on it
      popupCopyMenuItem =
          find.byKey(const Key("popup_menu_copy_audio_to_playlist"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Check the value of the select one playlist AlertDialog
      // dialog title
      alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Sélectionnez une playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be copied

      targetPlaylistRadioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioTargetPlaylistTitleTwo,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(targetPlaylistRadioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Check the value of the Warning dialog title
      warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'AVERTISSEMENT');

      // Now verifying the warning dialog message

      warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

      expect(warningDialogMessageTextWidget.data,
          "L'audio \"audio learn test short video one\" n'a pas été copié de la playlist Youtube \"audio_learn_test_download_2_small_videos\" vers la playlist locale \"local_audio_playlist_2\" car il est déjà présent dans cette playlist.");

      // Now find the ok button of the warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Finally redo copying the audio to the other local (local_3)
      // playlist, but finally click on Cancel button.

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      sourceAudioListTileTextWidgetFinder = find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the copy audio popup menu item and tap on it
      popupCopyMenuItem =
          find.byKey(const Key("popup_menu_copy_audio_to_playlist"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Check the value of the select one playlist AlertDialog
      // dialog title
      alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Sélectionnez une playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be copied

      targetPlaylistRadioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioTargetPlaylistTitleThree,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(targetPlaylistRadioListTile);
      await tester.pumpAndSettle();

      // Now find the cancel button and tap on it
      await tester.tap(find.byKey(const Key('cancelButton')));
      await tester.pumpAndSettle();

      // Now verifying the selected playlist TextField still
      // contains the title of the source playlist

      selectedPlaylistTextField = tester.widget<TextField>(
          find.byKey(const Key('selectedPlaylistTextField')));

      expect(selectedPlaylistTextField.controller!.text,
          youtubeAudioSourcePlaylistTitle);

      // Now verifying that the source playlist directory still
      // contains the audio file copied to the target playlist
      sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle',
        extension: 'mp3',
      );

      expect(sourcePlaylistMp3Lst, [
        "230628-033811-audio learn test short video one 23-06-10.mp3",
        "230628-033813-audio learn test short video two 23-06-10.mp3",
      ]);

      // And verify that the target playlist directory does not
      // contains the audio file copied from the source playlist
      targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetPlaylistTitleThree',
        extension: 'mp3',
      );

      expect(targetPlaylistMp3Lst, []);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets(
        'Copy audio and then move it to same target playlist: the move is refused with warning. Then 3rd time move to another playlist and click on cancel button',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String youtubeAudioSourcePlaylistTitle =
          'audio_learn_test_download_2_small_videos';
      const String localAudioTargetPlaylistTitleTwo = 'local_audio_playlist_2';
      const String localAudioTargetPlaylistTitleThree = 'local_3';
      const String copiedAudioTitle = 'audio learn test short video one';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the audio to copy to
      // the target local playlist

      // First, find the source Playlist ListTile Text widget
      Finder sourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioSourcePlaylistTitle);

      // Then obtain the source Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      Finder sourcePlaylistListTileWidgetFinder = find.ancestor(
        of: sourcePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      Finder sourcePlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: sourcePlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(sourcePlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      Finder sourceAudioListTileTextWidgetFinder = find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      Finder sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      Finder sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the copy audio popup menu item and tap on it
      Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_copy_audio_to_playlist"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Check the value of the select one playlist AlertDialog
      // dialog title
      Text alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Sélectionnez une playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be copied

      Finder targetPlaylistRadioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioTargetPlaylistTitleTwo,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(targetPlaylistRadioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Check the value of the Confirm dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'CONFIRMATION');

      // Now verifying the confirm dialog message

      Text warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

      expect(warningDialogMessageTextWidget.data,
          'Audio "audio learn test short video one" copié de la playlist Youtube "audio_learn_test_download_2_small_videos" vers la playlist locale "local_audio_playlist_2".');

      // Now find the ok button of the confirm dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now verifying the selected playlist TextField still
      // contains the title of the source playlist

      TextField selectedPlaylistTextField = tester.widget<TextField>(
          find.byKey(const Key('selectedPlaylistTextField')));

      expect(selectedPlaylistTextField.controller!.text,
          youtubeAudioSourcePlaylistTitle);

      // Now verifying that the source playlist directory still
      // contains the audio file copied to the target playlist
      List<String> sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle',
        extension: 'mp3',
      );

      expect(sourcePlaylistMp3Lst, [
        "230628-033811-audio learn test short video one 23-06-10.mp3",
        "230628-033813-audio learn test short video two 23-06-10.mp3",
      ]);

      // And verify that the target playlist directory now
      // contains the audio file copied from the source playlist
      List<String> targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetPlaylistTitleTwo',
        extension: 'mp3',
      );

      expect(targetPlaylistMp3Lst,
          ["230628-033811-audio learn test short video one 23-06-10.mp3"]);

      // Find the target ListTile Playlist containing the audio copied
      // from the source playlist

      // First, find the Playlist ListTile Text widget
      final Finder targetPlaylistListTileTextWidgetFinder =
          find.text(localAudioTargetPlaylistTitleTwo);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder targetPlaylistListTileWidgetFinder = find.ancestor(
        of: targetPlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder targetPlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: targetPlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(targetPlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder targetAudioListTileTextWidgetFinder =
          find.text(copiedAudioTitle);

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
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the popup menu item and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_display_audio_info"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Now verifying the display audio info audio copied dialog
      // elements

      // Verify the enclosing playlist title of the copied audio

      final Text enclosingPlaylistTitleTextWidget = tester
          .widget<Text>(find.byKey(const Key('enclosingPlaylistTitleKey')));

      expect(enclosingPlaylistTitleTextWidget.data,
          localAudioTargetPlaylistTitleTwo);

      // Verify the copied from playlist title of the copied audio

      final Text copiedFromPlaylistTitleTextWidget = tester
          .widget<Text>(find.byKey(const Key('copiedFromPlaylistTitleKey')));

      expect(copiedFromPlaylistTitleTextWidget.data,
          youtubeAudioSourcePlaylistTitle);

      // Verify the copied to playlist title of the copied audio

      final Text copiedToPlaylistTitleTextWidget = tester
          .widget<Text>(find.byKey(const Key('copiedToPlaylistTitleKey')));

      expect(copiedToPlaylistTitleTextWidget.data, '');

      // Now find the ok button of the audio info dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('audioInfoOkButtonKey')));
      await tester.pumpAndSettle();

      // Then, we try to move the audio already copied to the same
      // target playlist in order to verify that a warning is
      // displayed informing that the audio was not moved because it
      // is already present in the target playlist

      // Find the ListTile Playlist containing the audio to copy to
      // the target local playlist

      // First, find the source Playlist ListTile Text widget
      sourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioSourcePlaylistTitle);

      // Then obtain the source Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      sourcePlaylistListTileWidgetFinder = find.ancestor(
        of: sourcePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      sourcePlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: sourcePlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(sourcePlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      sourceAudioListTileTextWidgetFinder = find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the copy audio popup menu item and tap on it
      popupCopyMenuItem =
          find.byKey(const Key("popup_menu_move_audio_to_playlist"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Check the value of the select one playlist AlertDialog
      // dialog title
      alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Sélectionnez une playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be copied

      targetPlaylistRadioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioTargetPlaylistTitleTwo,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(targetPlaylistRadioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Check the value of the Warning dialog title
      warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'AVERTISSEMENT');

      // Now verifying the warning dialog message

      warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

      expect(warningDialogMessageTextWidget.data,
          "L'audio \"audio learn test short video one\" n'a pas été déplacé de la playlist Youtube \"audio_learn_test_download_2_small_videos\" vers la playlist locale \"local_audio_playlist_2\" car il est déjà présent dans cette playlist.");

      // Now find the ok button of the warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Finally redo moving the audio to the other local (local_3)
      // playlist, but finally click on Cancel button.

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      sourceAudioListTileTextWidgetFinder = find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the copy audio popup menu item and tap on it
      popupCopyMenuItem =
          find.byKey(const Key("popup_menu_move_audio_to_playlist"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Check the value of the select one playlist AlertDialog
      // dialog title
      alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Sélectionnez une playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be copied

      targetPlaylistRadioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioTargetPlaylistTitleThree,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(targetPlaylistRadioListTile);
      await tester.pumpAndSettle();

      // Now find the cancel button and tap on it
      await tester.tap(find.byKey(const Key('cancelButton')));
      await tester.pumpAndSettle();

      // Now verifying the selected playlist TextField still
      // contains the title of the source playlist

      selectedPlaylistTextField = tester.widget<TextField>(
          find.byKey(const Key('selectedPlaylistTextField')));

      expect(selectedPlaylistTextField.controller!.text,
          youtubeAudioSourcePlaylistTitle);

      // Now verifying that the source playlist directory still
      // contains the audio file moved but canceled to the target
      // playlist
      sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle',
        extension: 'mp3',
      );

      expect(sourcePlaylistMp3Lst, [
        "230628-033811-audio learn test short video one 23-06-10.mp3",
        "230628-033813-audio learn test short video two 23-06-10.mp3",
      ]);

      // And verify that the target playlist directory does not
      // contains the audio file copied from the source playlist
      targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetPlaylistTitleThree',
        extension: 'mp3',
      );

      expect(targetPlaylistMp3Lst, []);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets(
        'Copy audio to target playlist and then delete it from target playlist. Then move it to same target playlist.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String youtubeAudioSourcePlaylistTitle =
          'audio_learn_test_download_2_small_videos';
      const String localAudioTargetPlaylistTitleTwo = 'local_audio_playlist_2';
      const String copiedAudioTitle = 'audio learn test short video one';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the audio to copy to
      // the target local playlist

      // First, find the source Playlist ListTile Text widget
      Finder sourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioSourcePlaylistTitle);

      // Then obtain the source Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      Finder sourcePlaylistListTileWidgetFinder = find.ancestor(
        of: sourcePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      Finder sourcePlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: sourcePlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(sourcePlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      Finder sourceAudioListTileTextWidgetFinder = find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      Finder sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      Finder sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the copy audio popup menu item and tap on it
      Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_copy_audio_to_playlist"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Check the value of the select one playlist AlertDialog
      // dialog title
      Text alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Sélectionnez une playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be copied

      Finder targetPlaylistRadioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioTargetPlaylistTitleTwo,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(targetPlaylistRadioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Check the value of the Confirm dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'CONFIRMATION');

      // Now verifying the confirm dialog message

      Text warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

      expect(warningDialogMessageTextWidget.data,
          'Audio "audio learn test short video one" copié de la playlist Youtube "audio_learn_test_download_2_small_videos" vers la playlist locale "local_audio_playlist_2".');

      // Now find the ok button of the confirm dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now verifying the selected playlist TextField still
      // contains the title of the source playlist

      TextField selectedPlaylistTextField = tester.widget<TextField>(
          find.byKey(const Key('selectedPlaylistTextField')));

      expect(selectedPlaylistTextField.controller!.text,
          youtubeAudioSourcePlaylistTitle);

      // Now verifying that the source playlist directory still
      // contains the audio file copied to the target playlist
      List<String> sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle',
        extension: 'mp3',
      );

      expect(sourcePlaylistMp3Lst, [
        "230628-033811-audio learn test short video one 23-06-10.mp3",
        "230628-033813-audio learn test short video two 23-06-10.mp3",
      ]);

      // And verify that the target playlist directory now
      // contains the audio file copied from the source playlist
      List<String> targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetPlaylistTitleTwo',
        extension: 'mp3',
      );

      expect(targetPlaylistMp3Lst,
          ["230628-033811-audio learn test short video one 23-06-10.mp3"]);

      // Find the target ListTile Playlist containing the audio copied
      // from the source playlist

      // First, find the Playlist ListTile Text widget
      final Finder targetPlaylistListTileTextWidgetFinder =
          find.text(localAudioTargetPlaylistTitleTwo);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder targetPlaylistListTileWidgetFinder = find.ancestor(
        of: targetPlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder targetPlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: targetPlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(targetPlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder targetAudioListTileTextWidgetFinder =
          find.text(copiedAudioTitle);

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
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the popup menu delete audio item and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_delete_audio"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Now verify that the target playlist directory no longer
      // contains the audio file copied from the source playlist
      targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetPlaylistTitleTwo',
        extension: 'mp3',
      );

      expect(targetPlaylistMp3Lst, []);

      // Then, we move the audio already copied and deletedto to the
      // same target playlist in ensure it is moved with no warning

      // Find the ListTile Playlist containing the audio to move to
      // the target local playlist

      // First, find the source Playlist ListTile Text widget
      sourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioSourcePlaylistTitle);

      // Then obtain the source Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      sourcePlaylistListTileWidgetFinder = find.ancestor(
        of: sourcePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      sourcePlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: sourcePlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(sourcePlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      sourceAudioListTileTextWidgetFinder = find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the copy audio popup menu item and tap on it
      popupCopyMenuItem =
          find.byKey(const Key("popup_menu_move_audio_to_playlist"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Check the value of the select one playlist AlertDialog
      // dialog title
      alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Sélectionnez une playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be copied

      targetPlaylistRadioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioTargetPlaylistTitleTwo,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(targetPlaylistRadioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Check the value of the Confirm dialog title
      warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'CONFIRMATION');

      // Now verifying the confirm dialog message

      warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

      expect(warningDialogMessageTextWidget.data,
          'Audio "audio learn test short video one" déplacé de la playlist Youtube "audio_learn_test_download_2_small_videos" vers la playlist locale "local_audio_playlist_2".');

      // Now find the ok button of the confirm dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now verifying the selected playlist TextField still
      // contains the title of the source playlist

      selectedPlaylistTextField = tester.widget<TextField>(
          find.byKey(const Key('selectedPlaylistTextField')));

      expect(selectedPlaylistTextField.controller!.text,
          youtubeAudioSourcePlaylistTitle);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets(
        'Copy audio to target playlist and then delete it from target playlist. Then copy it again to same target playlist.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String youtubeAudioSourcePlaylistTitle =
          'audio_learn_test_download_2_small_videos';
      const String localAudioTargetPlaylistTitleTwo = 'local_audio_playlist_2';
      const String copiedAudioTitle = 'audio learn test short video one';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the audio to copy to
      // the target local playlist

      // First, find the source Playlist ListTile Text widget
      Finder sourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioSourcePlaylistTitle);

      // Then obtain the source Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      Finder sourcePlaylistListTileWidgetFinder = find.ancestor(
        of: sourcePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      Finder sourcePlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: sourcePlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(sourcePlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      Finder sourceAudioListTileTextWidgetFinder = find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      Finder sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      Finder sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the copy audio popup menu item and tap on it
      Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_copy_audio_to_playlist"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Check the value of the select one playlist AlertDialog
      // dialog title
      Text alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Sélectionnez une playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be copied

      Finder targetPlaylistRadioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioTargetPlaylistTitleTwo,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(targetPlaylistRadioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Check the value of the Confirm dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'CONFIRMATION');

      // Now verifying the confirm dialog message

      Text warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

      expect(warningDialogMessageTextWidget.data,
          'Audio "audio learn test short video one" copié de la playlist Youtube "audio_learn_test_download_2_small_videos" vers la playlist locale "local_audio_playlist_2".');

      // Now find the ok button of the confirm dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now verifying the selected playlist TextField still
      // contains the title of the source playlist

      TextField selectedPlaylistTextField = tester.widget<TextField>(
          find.byKey(const Key('selectedPlaylistTextField')));

      expect(selectedPlaylistTextField.controller!.text,
          youtubeAudioSourcePlaylistTitle);

      // Now verifying that the source playlist directory still
      // contains the audio file copied to the target playlist
      List<String> sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle',
        extension: 'mp3',
      );

      expect(sourcePlaylistMp3Lst, [
        "230628-033811-audio learn test short video one 23-06-10.mp3",
        "230628-033813-audio learn test short video two 23-06-10.mp3",
      ]);

      // And verify that the target playlist directory now
      // contains the audio file copied from the source playlist
      List<String> targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetPlaylistTitleTwo',
        extension: 'mp3',
      );

      expect(targetPlaylistMp3Lst,
          ["230628-033811-audio learn test short video one 23-06-10.mp3"]);

      // Find the target ListTile Playlist containing the audio copied
      // from the source playlist

      // First, find the Playlist ListTile Text widget
      final Finder targetPlaylistListTileTextWidgetFinder =
          find.text(localAudioTargetPlaylistTitleTwo);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder targetPlaylistListTileWidgetFinder = find.ancestor(
        of: targetPlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder targetPlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: targetPlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(targetPlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder targetAudioListTileTextWidgetFinder =
          find.text(copiedAudioTitle);

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
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the popup menu delete audio item and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_delete_audio"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Now verify that the target playlist directory no longer
      // contains the audio file copied from the source playlist
      targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetPlaylistTitleTwo',
        extension: 'mp3',
      );

      expect(targetPlaylistMp3Lst, []);

      // Then, we move the audio already copied and deletedto to the
      // same target playlist in ensure it is moved with no warning

      // Find the ListTile Playlist containing the audio to move to
      // the target local playlist

      // First, find the source Playlist ListTile Text widget
      sourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioSourcePlaylistTitle);

      // Then obtain the source Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      sourcePlaylistListTileWidgetFinder = find.ancestor(
        of: sourcePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      sourcePlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: sourcePlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(sourcePlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      sourceAudioListTileTextWidgetFinder = find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the copy audio popup menu item and tap on it
      popupCopyMenuItem =
          find.byKey(const Key("popup_menu_copy_audio_to_playlist"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Check the value of the select one playlist AlertDialog
      // dialog title
      alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Sélectionnez une playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be copied

      targetPlaylistRadioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioTargetPlaylistTitleTwo,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(targetPlaylistRadioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Check the value of the Confirm dialog title
      warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'CONFIRMATION');

      // Now verifying the confirm dialog message

      warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

      expect(warningDialogMessageTextWidget.data,
          'Audio "audio learn test short video one" copié de la playlist Youtube "audio_learn_test_download_2_small_videos" vers la playlist locale "local_audio_playlist_2".');

      // Now find the ok button of the confirm dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now verifying the selected playlist TextField still
      // contains the title of the source playlist

      selectedPlaylistTextField = tester.widget<TextField>(
          find.byKey(const Key('selectedPlaylistTextField')));

      expect(selectedPlaylistTextField.controller!.text,
          youtubeAudioSourcePlaylistTitle);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets(
        'Move (+ check comment) audio from Youtube to local playlist, then move it back, then remove it, then remove it back',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String youtubeAudioSourcePlaylistTitle =
          'audio_learn_test_download_2_small_videos';
      const String localAudioPlaylistTitle = 'local_audio_playlist_2';
      const String movedAudioTitle = 'audio learn test short video one';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the audio to move to
      // the source Youtube playlist

      // First, find the Playlist ListTile Text widget
      final Finder sourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioSourcePlaylistTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder sourcePlaylistListTileWidgetFinder = find.ancestor(
        of: sourcePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder sourcePlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: sourcePlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(sourcePlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder sourceAudioListTileTextWidgetFinder =
          find.text(movedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile and tap
      // on it
      final Finder sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the move audio popup menu item and tap on it
      final Finder popupMoveMenuItem =
          find.byKey(const Key("popup_menu_move_audio_to_playlist"));

      await tester.tap(popupMoveMenuItem);
      await tester.pumpAndSettle();

      // Check the value of the select one playlist AlertDialog
      // dialog title
      Text alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Sélectionnez une playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be moved

      final Finder radioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioPlaylistTitle,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(radioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now verifying the confirm warning dialog message

      final Text warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

      expect(warningDialogMessageTextWidget.data,
          'Audio "audio learn test short video one" déplacé de la playlist Youtube "audio_learn_test_download_2_small_videos" vers la playlist locale "local_audio_playlist_2".');

      // Now find the ok button of the confirm warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now verifying the selected playlist TextField still
      // contains the title of the source playlist

      final TextField selectedPlaylistTextField = tester.widget<TextField>(
          find.byKey(const Key('selectedPlaylistTextField')));

      expect(selectedPlaylistTextField.controller!.text,
          youtubeAudioSourcePlaylistTitle);

      // TODO: Verify that the audio was moved to the target playlist
      // and verify the source and target playlist json file content.
      //
      // Then move back and remove and remove back ...
      //
      // Then test moving moved audio to a different playlist

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub

      // Testing that the audio was moved from the source to the target
      // playlist directory

      List<String> sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle',
        extension: 'mp3',
      );

      List<String> targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioPlaylistTitle',
        extension: 'mp3',
      );

      expect(sourcePlaylistMp3Lst,
          ["230628-033813-audio learn test short video two 23-06-10.mp3"]);
      expect(targetPlaylistMp3Lst,
          ["230628-033811-audio learn test short video one 23-06-10.mp3"]);

      // Find the target ListTile Playlist containing the audio moved
      // from the source playlist

      // First, find the Playlist ListTile Text widget
      final Finder targetPlaylistListTileTextWidgetFinder =
          find.text(localAudioPlaylistTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder targetPlaylistListTileWidgetFinder = find.ancestor(
        of: targetPlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder targetPlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: targetPlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(targetPlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder targetAudioListTileTextWidgetFinder =
          find.text(movedAudioTitle);

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
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the popup menu item and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_display_audio_info"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Now verifying the display audio info audio moved dialog
      // elements

      // Verify the enclosing playlist title of the moved audio

      final Text enclosingPlaylistTitleTextWidget = tester
          .widget<Text>(find.byKey(const Key('enclosingPlaylistTitleKey')));

      expect(enclosingPlaylistTitleTextWidget.data, localAudioPlaylistTitle);

      // Verify the moved from playlist title of the moved audio

      final Text movedFromPlaylistTitleTextWidget = tester
          .widget<Text>(find.byKey(const Key('movedFromPlaylistTitleKey')));

      expect(movedFromPlaylistTitleTextWidget.data,
          youtubeAudioSourcePlaylistTitle);

      // Verify the moved to playlist title of the moved audio

      final Text movedToPlaylistTitleTextWidget =
          tester.widget<Text>(find.byKey(const Key('movedToPlaylistTitleKey')));

      expect(movedToPlaylistTitleTextWidget.data, '');

      // Now find the ok button of the audio info dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('audioInfoOkButtonKey')));
      await tester.pumpAndSettle();

      // Now verifying that the target audio can access to its copied
      // comments

      // First, tap on the source audio ListTile to open the
      // audio player view
      await tester.tap(targetAudioListTileWidgetFinder);
      await tester.pumpAndSettle();

      // Verify that the comment icon button is highlighted. This indiquates
      // that a comment exist for the audio
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        inkWellButtonKey: 'commentsInkWellButton',
        expectedIcon: Icons.bookmark_outline_outlined,
        expectedIconColor: Colors.white,
        expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets(
        'Move audio from Youtube to local playlist unchecking keep audio in source playlist checkbox. This displays a warning',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String youtubeAudioSourcePlaylistTitle =
          'audio_learn_test_download_2_small_videos';
      const String localAudioPlaylistTitle = 'local_audio_playlist_2';
      const String movedAudioTitle = 'audio learn test short video one';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the audio to move to
      // the source Youtube playlist

      // First, find the Playlist ListTile Text widget
      final Finder sourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioSourcePlaylistTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder sourcePlaylistListTileWidgetFinder = find.ancestor(
        of: sourcePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder sourcePlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: sourcePlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(sourcePlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder sourceAudioListTileTextWidgetFinder =
          find.text(movedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile and tap
      // on it
      final Finder sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the move audio popup menu item and tap on it
      final Finder popupMoveMenuItem =
          find.byKey(const Key("popup_menu_move_audio_to_playlist"));

      await tester.tap(popupMoveMenuItem);
      await tester.pumpAndSettle();

      // Check the value of the select one playlist AlertDialog
      // dialog title
      Text alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Sélectionnez une playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be moved

      final Finder radioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioPlaylistTitle,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(radioListTile);
      await tester.pumpAndSettle();

      // Now uncheck the keep audio in source playlist checkbox
      await tester.tap(
          find.byKey(const Key('keepAudioDataInSourcePlaylistCheckboxKey')));
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now verifying the confirm warning dialog message

      final Text warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

      expect(warningDialogMessageTextWidget.data,
          "Audio \"audio learn test short video one\" déplacé de la playlist Youtube \"audio_learn_test_download_2_small_videos\" vers la playlist locale \"local_audio_playlist_2\".\n\nSUPPRIMEZ L'AUDIO \"audio learn test short video one\" DE LA PLAYLIST YOUTUBE \"audio_learn_test_download_2_small_videos\", SINON L'AUDIO SERA TÉLÉCHARGÉ À NOUVEAU LORS DU PROCHAIN TÉLÉCHARGEMENT DE LA PLAYLIST.");

      // Now find the ok button of the confirm warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
  });
  group('Delete copied or moved audio test', () {
    testWidgets(
        'Delete audio first copied from Youtube to local playlist, then copied from local to other Youtube playlist. The audio is then deleted from the other Youtube playlist with no warning being displayed.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}2_youtube_2_local_playlists_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String youtubeAudioSourcePlaylistTitle =
          'audio_learn_test_download_2_small_videos';
      const String localAudioTargetSourcePlaylistTitle =
          'local_audio_playlist_2';
      const String copiedAudioTitle = 'audio learn test short video one';
      const String youtubeAudioTargetPlaylistTitle =
          'audio_player_view_2_shorts_test';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // First, set the application language to French
      // Tap the appbar leading popup menu button
      await tester.tap(find.byKey(const Key('appBarRightPopupMenu')));
      await tester.pumpAndSettle();

      // Select French
      await tester.tap(find.byKey(const Key('appBarMenuFrench')));
      await tester.pumpAndSettle();

      // *** First test part: Copy audio from Youtube to local
      // playlist

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the audio to copy to
      // the target local playlist

      // First, find the Youtube source playlist ListTile Text widget
      final Finder youtubeAudioSourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioSourcePlaylistTitle);

      // Then obtain the Youtube source playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder youtubeAudioSourcePlaylistListTileWidgetFinder =
          find.ancestor(
        of: youtubeAudioSourcePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the playlist ListTile
      // and tap on it to select the playlist
      final Finder sourcePlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: youtubeAudioSourcePlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile playlist checkbox to select it
      await tester.tap(sourcePlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder sourceAudioListTileTextWidgetFinder =
          find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      final Finder sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the copy audio popup menu item and tap on it
      final Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_copy_audio_to_playlist"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Check the value of the select one playlist AlertDialog
      // dialog title
      Text alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Sélectionnez une playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be copied

      final Finder radioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioTargetSourcePlaylistTitle,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(radioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now verifying the confirm warning dialog message

      Text warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

      expect(warningDialogMessageTextWidget.data,
          'Audio "$copiedAudioTitle" copié de la playlist Youtube "$youtubeAudioSourcePlaylistTitle" vers la playlist locale "$localAudioTargetSourcePlaylistTitle".');

      // Now find the ok button of the confirm warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now verifying the selected playlist TextField still
      // contains the title of the source playlist

      TextField selectedPlaylistTextField = tester.widget<TextField>(
          find.byKey(const Key('selectedPlaylistTextField')));

      expect(selectedPlaylistTextField.controller!.text,
          youtubeAudioSourcePlaylistTitle);

      // Now verifying the audio was physically copied to the target
      // playlist directory.

      List<String> sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle',
        extension: 'mp3',
      );

      List<String> targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetSourcePlaylistTitle',
        extension: 'mp3',
      );

      // Verify the Youtube source playlist directory content
      expect(sourcePlaylistMp3Lst, [
        "230628-033811-audio learn test short video one 23-06-10.mp3",
        "230628-033813-audio learn test short video two 23-06-10.mp3",
      ]);

      // Verify the local target playlist directory content
      expect(targetPlaylistMp3Lst,
          ["230628-033811-audio learn test short video one 23-06-10.mp3"]);

      // Now verifying the copied audio informations in the source
      // playlist

      await verifyAudioInfoDialogElements(
        tester: tester,
        audioTitle: copiedAudioTitle,
        playlistEnclosingAudioTitle: youtubeAudioSourcePlaylistTitle,
        copiedAudioSourcePlaylistTitle: '',
        copiedAudioTargetPlaylistTitle: localAudioTargetSourcePlaylistTitle,
        movedAudioSourcePlaylistTitle: '',
        movedAudioTargetPlaylistTitle: '',
      );

      // And verifying the copied audio informations in the target
      // playlist

      await verifyAudioInfoDialogElements(
        tester: tester,
        audioTitle: copiedAudioTitle,
        playlistEnclosingAudioTitle: localAudioTargetSourcePlaylistTitle,
        copiedAudioSourcePlaylistTitle: youtubeAudioSourcePlaylistTitle,
        copiedAudioTargetPlaylistTitle: '',
        movedAudioSourcePlaylistTitle: '',
        movedAudioTargetPlaylistTitle: '',
      );

      // """ Second test part: Copy audio from local playlist to
      // other Youtube playlist

      // Currently, the local audio target source playlist is selected

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder localSourceAudioListTileTextWidgetFinder =
          find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder localSourceAudioListTileWidgetFinder = find.ancestor(
        of: localSourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      final Finder localSourceAudioListTileLeadingMenuIconButton =
          find.descendant(
        of: localSourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(localSourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the copy audio popup menu item and tap on it
      final Finder localSourceAudioPopupCopyMenuItem =
          find.byKey(const Key("popup_menu_copy_audio_to_playlist"));

      await tester.tap(localSourceAudioPopupCopyMenuItem);
      await tester.pumpAndSettle();

      // Find the RadioListTile target playlist to which the audio
      // will be copied

      final Finder secondYoutubeTargetRadioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == youtubeAudioTargetPlaylistTitle,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(secondYoutubeTargetRadioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now verifying the confirm warning dialog message

      warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

      expect(warningDialogMessageTextWidget.data,
          'Audio "$copiedAudioTitle" copié de la playlist locale "$localAudioTargetSourcePlaylistTitle" vers la playlist Youtube "$youtubeAudioTargetPlaylistTitle".');

      // Now find the ok button of the confirm warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now verifying the selected playlist TextField still
      // contains the title of the source playlist

      selectedPlaylistTextField = tester.widget<TextField>(
          find.byKey(const Key('selectedPlaylistTextField')));

      expect(selectedPlaylistTextField.controller!.text,
          localAudioTargetSourcePlaylistTitle);

      // Now verifying the audio was physically copied to the target
      // playlist directory.

      sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetSourcePlaylistTitle',
        extension: 'mp3',
      );

      targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioTargetPlaylistTitle',
        extension: 'mp3',
      );

      // Verify the local source playlist directory content
      expect(sourcePlaylistMp3Lst,
          ["230628-033811-audio learn test short video one 23-06-10.mp3"]);

      // Verify the Youtube target playlist directory content
      expect(targetPlaylistMp3Lst, [
        "230628-033811-audio learn test short video one 23-06-10.mp3",
        "231117-002826-Really short video 23-07-01.mp3",
        "231117-002828-morning _ cinematic video 23-07-01.mp3",
      ]);

      // Now verifying the copied audio informations in the source
      // playlist

      await verifyAudioInfoDialogElements(
        tester: tester,
        audioTitle: copiedAudioTitle,
        playlistEnclosingAudioTitle: localAudioTargetSourcePlaylistTitle,
        copiedAudioSourcePlaylistTitle: youtubeAudioSourcePlaylistTitle,
        copiedAudioTargetPlaylistTitle: youtubeAudioTargetPlaylistTitle,
        movedAudioSourcePlaylistTitle: '',
        movedAudioTargetPlaylistTitle: '',
      );

      // And verifying the copied audio informations in the target
      // playlist

      await verifyAudioInfoDialogElements(
        tester: tester,
        audioTitle: copiedAudioTitle,
        playlistEnclosingAudioTitle: youtubeAudioTargetPlaylistTitle,
        copiedAudioSourcePlaylistTitle: localAudioTargetSourcePlaylistTitle,
        copiedAudioTargetPlaylistTitle: '',
        movedAudioSourcePlaylistTitle: '',
        movedAudioTargetPlaylistTitle: '',
      );

      // """ Third test part: Delete audio from target Youtube
      // playlist verifying that no warning is displayed since the
      // deleted audio was copied and not downloaded, which ensures
      // that the deleted audio video is not referenced in the
      // Youtube playlist.

      // Now we want to tap again on the popup menu of the Audio
      // ListTile "audio learn test short video one" in order to
      // delete it from playlist aswell

      // First, find the Audio sublist ListTile Text widget
      final Finder youtubeTargetAudioListTileTextWidgetFinder =
          find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder youtubeTargetAudioListTileWidgetFinder = find.ancestor(
        of: youtubeTargetAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      final Finder youtubeTargetAudioListTileLeadingMenuIconButtonFinder =
          find.descendant(
        of: youtubeTargetAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(youtubeTargetAudioListTileLeadingMenuIconButtonFinder);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the popup menu item and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_delete_audio_from_playlist_aswell"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Now verifying the deleted audio was physically deleted from
      // the playlist directory. No warning was displayed.

      targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioTargetPlaylistTitle',
        extension: 'mp3',
      );

      // Verify the Youtube target playlist directory content
      expect(targetPlaylistMp3Lst, [
        "231117-002826-Really short video 23-07-01.mp3",
        "231117-002828-morning _ cinematic video 23-07-01.mp3",
      ]);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets(
        'Delete audio first moved from Youtube to local playlist, then moved from local to other Youtube playlist. The audio is then deleted from the other Youtube playlist with no warning being displayed.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}2_youtube_2_local_playlists_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String youtubeAudioSourcePlaylistTitle =
          'audio_learn_test_download_2_small_videos';
      const String localAudioTargetSourcePlaylistTitle =
          'local_audio_playlist_2';
      const String copiedAudioTitle = 'audio learn test short video one';
      const String youtubeAudioTargetPlaylistTitle =
          'audio_player_view_2_shorts_test';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // First, set the application language to French
      // Tap the appbar leading popup menu button
      await tester.tap(find.byKey(const Key('appBarRightPopupMenu')));
      await tester.pumpAndSettle();

      // Select French
      await tester.tap(find.byKey(const Key('appBarMenuFrench')));
      await tester.pumpAndSettle();

      // *** First test part: Copy audio from Youtube to local
      // playlist

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the audio to copy to
      // the target local playlist

      // First, find the Youtube source playlist ListTile Text widget
      final Finder youtubeAudioSourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioSourcePlaylistTitle);

      // Then obtain the Youtube source playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder youtubeAudioSourcePlaylistListTileWidgetFinder =
          find.ancestor(
        of: youtubeAudioSourcePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the playlist ListTile
      // and tap on it to select the playlist
      final Finder sourcePlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: youtubeAudioSourcePlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile playlist checkbox to select it
      await tester.tap(sourcePlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder sourceAudioListTileTextWidgetFinder =
          find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      final Finder sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the move audio popup menu item and tap on it
      final Finder popupMoveMenuItem =
          find.byKey(const Key("popup_menu_move_audio_to_playlist"));

      await tester.tap(popupMoveMenuItem);
      await tester.pumpAndSettle();

      // Check the value of the select one playlist AlertDialog
      // dialog title
      Text alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Sélectionnez une playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be moved

      final Finder radioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioTargetSourcePlaylistTitle,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(radioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now verifying the confirm warning dialog message

      Text warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

      expect(warningDialogMessageTextWidget.data,
          'Audio "$copiedAudioTitle" déplacé de la playlist Youtube "$youtubeAudioSourcePlaylistTitle" vers la playlist locale "$localAudioTargetSourcePlaylistTitle".');

      // Now find the ok button of the confirm warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now verifying the selected playlist TextField still
      // contains the title of the source playlist

      TextField selectedPlaylistTextField = tester.widget<TextField>(
          find.byKey(const Key('selectedPlaylistTextField')));

      expect(selectedPlaylistTextField.controller!.text,
          youtubeAudioSourcePlaylistTitle);

      // Now verifying the audio was physically moved to the target
      // playlist directory.

      List<String> sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle',
        extension: 'mp3',
      );

      List<String> targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetSourcePlaylistTitle',
        extension: 'mp3',
      );

      // Verify the Youtube source playlist directory content
      expect(sourcePlaylistMp3Lst, [
        "230628-033813-audio learn test short video two 23-06-10.mp3",
      ]);

      // Verify the local target playlist directory content
      expect(targetPlaylistMp3Lst,
          ["230628-033811-audio learn test short video one 23-06-10.mp3"]);

      // Now verifying the moved audio informations in the target
      // playlist. In the source playlist, the audio is no longer
      // displayed since it was moved to the target playlist.

      await verifyAudioInfoDialogElements(
        tester: tester,
        audioTitle: copiedAudioTitle,
        playlistEnclosingAudioTitle: localAudioTargetSourcePlaylistTitle,
        copiedAudioSourcePlaylistTitle: '',
        copiedAudioTargetPlaylistTitle: '',
        movedAudioSourcePlaylistTitle: youtubeAudioSourcePlaylistTitle,
        movedAudioTargetPlaylistTitle: '',
      );

      // """ Second test part: Move audio from local playlist to
      // other Youtube playlist

      // Currently, the local audio target source playlist is selected

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder localSourceAudioListTileTextWidgetFinder =
          find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder localSourceAudioListTileWidgetFinder = find.ancestor(
        of: localSourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      final Finder localSourceAudioListTileLeadingMenuIconButton =
          find.descendant(
        of: localSourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(localSourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the move audio popup menu item and tap on it
      final Finder localSourceAudioPopupMoveMenuItem =
          find.byKey(const Key("popup_menu_move_audio_to_playlist"));

      await tester.tap(localSourceAudioPopupMoveMenuItem);
      await tester.pumpAndSettle();

      // Find the RadioListTile target playlist to which the audio
      // will be moved

      final Finder secondYoutubeTargetRadioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == youtubeAudioTargetPlaylistTitle,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(secondYoutubeTargetRadioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now verifying the confirm warning dialog message

      warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

      expect(warningDialogMessageTextWidget.data,
          'Audio "$copiedAudioTitle" déplacé de la playlist locale "$localAudioTargetSourcePlaylistTitle" vers la playlist Youtube "$youtubeAudioTargetPlaylistTitle".');

      // Now find the ok button of the confirm warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now verifying the selected playlist TextField still
      // contains the title of the source playlist

      selectedPlaylistTextField = tester.widget<TextField>(
          find.byKey(const Key('selectedPlaylistTextField')));

      expect(selectedPlaylistTextField.controller!.text,
          localAudioTargetSourcePlaylistTitle);

      // Now verifying the audio was physically moved to the target
      // playlist directory.

      sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetSourcePlaylistTitle',
        extension: 'mp3',
      );

      targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioTargetPlaylistTitle',
        extension: 'mp3',
      );

      // Verify the local source playlist directory content
      expect(sourcePlaylistMp3Lst, []);

      // Verify the Youtube target playlist directory content
      expect(targetPlaylistMp3Lst, [
        "230628-033811-audio learn test short video one 23-06-10.mp3",
        "231117-002826-Really short video 23-07-01.mp3",
        "231117-002828-morning _ cinematic video 23-07-01.mp3",
      ]);

      // Now verifying the moved audio informations in the target
      // playlist. In the source playlist, the audio is no longer
      // displayed since it was moved to the target playlist.

      await verifyAudioInfoDialogElements(
        tester: tester,
        audioTitle: copiedAudioTitle,
        playlistEnclosingAudioTitle: youtubeAudioTargetPlaylistTitle,
        copiedAudioSourcePlaylistTitle: '',
        copiedAudioTargetPlaylistTitle: '',
        movedAudioSourcePlaylistTitle: localAudioTargetSourcePlaylistTitle,
        movedAudioTargetPlaylistTitle: '',
      );

      // """ Third test part: Delete audio from target Youtube
      // playlist verifying that no warning is displayed since the
      // deleted audio was copied and not downloaded, which ensures
      // that the deleted audio video is not referenced in the
      // Youtube playlist.

      // Now we want to tap again on the popup menu of the Audio
      // ListTile "audio learn test short video one" in order to
      // delete it from playlist aswell

      // First, find the Audio sublist ListTile Text widget
      final Finder youtubeTargetAudioListTileTextWidgetFinder =
          find.text(copiedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder youtubeTargetAudioListTileWidgetFinder = find.ancestor(
        of: youtubeTargetAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      final Finder youtubeTargetAudioListTileLeadingMenuIconButtonFinder =
          find.descendant(
        of: youtubeTargetAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(youtubeTargetAudioListTileLeadingMenuIconButtonFinder);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the popup menu item and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_delete_audio_from_playlist_aswell"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Now verifying the deleted audio was physically deleted from
      // the playlist directory. No warning was displayed.

      targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioTargetPlaylistTitle',
        extension: 'mp3',
      );

      // Verify the Youtube target playlist directory content
      expect(targetPlaylistMp3Lst, [
        "231117-002826-Really short video 23-07-01.mp3",
        "231117-002828-morning _ cinematic video 23-07-01.mp3",
      ]);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
  });
  group(
      'Executing update playable audio list after manually deleting audio files test',
      () {
    testWidgets('Manually delete audios in Youtube playlist directory.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}manually_deleting_audios_and_updating_playlists",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String youtubePlaylistTitle = 'S8 audio';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      String youtubePlaylistPath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubePlaylistTitle';

      List<String> youtubePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path: youtubePlaylistPath,
        extension: 'mp3',
      );

      // *** Manually deleting audio files from Youtube
      // playlist directory

      DirUtil.deleteMp3FilesInDir(
        youtubePlaylistPath,
      );

      // *** Updating the Youtube playlist

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the audios
      // which were manually deleted from the Youtube playlist
      // directory

      // First, find the Youtube playlist ListTile Text widget
      final Finder youtubePlaylistListTileTextWidgetFinder =
          find.text(youtubePlaylistTitle);

      // Then obtain the Youtube source playlist ListTile widget
      // enclosing the Text widget by finding its ancestor
      final Finder youtubePlaylistListTileWidgetFinder = find.ancestor(
        of: youtubePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the playlist ListTile
      // and tap on it to select the playlist

      await tapPlaylistCheckboxIfNotAlreadyChecked(
        playlistListTileWidgetFinder: youtubePlaylistListTileWidgetFinder,
        widgetTester: tester,
      );

      // Test that the Youtube playlist is still showing the
      // deleted audios

      for (String audioTitle in youtubePlaylistMp3Lst) {
        audioTitle = audioTitle
            .replaceAll(RegExp(r'[\d\-]'), '')
            .replaceFirst(' .mp', '')
            .replaceFirst(' fois', '3 fois')
            .replaceFirst('antinuke', 'anti-nuke');
        final Finder audioListTileTextWidgetFinder = find.text(audioTitle);

        expect(audioListTileTextWidgetFinder, findsOneWidget);
      }

      // Now update the playable audio list of the Youtube
      // playlist

      // Now find the leading menu icon button of the Playlist ListTile
      // and tap on it
      final Finder youtubePlaylistListTileLeadingMenuIconButton =
          find.descendant(
        of: youtubePlaylistListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(youtubePlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the update playlist popup menu item and tap on it
      final Finder popupUpdatePlayableAudioListPlaylistMenuItem =
          find.byKey(const Key("popup_menu_update_playable_audio_list"));

      await tester.tap(popupUpdatePlayableAudioListPlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now verifying the warning dialog

      // Check the value of the warning dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'WARNING');

      // Check the value of the warning dialog message
      Text warningDialogMessage =
          tester.widget(find.byKey(const Key('warningDialogMessage')));
      expect(warningDialogMessage.data,
          'Playable audio list for playlist "$youtubePlaylistTitle" was updated. 4 audio(s) were removed.');

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Test that the youtube playlist is no longer showing the
      // deleted audios

      for (String audioTitle in youtubePlaylistMp3Lst) {
        audioTitle = audioTitle
            .replaceAll(RegExp(r'[\d\-]'), '')
            .replaceFirst(' .mp', '')
            .replaceFirst(' fois', '3 fois')
            .replaceFirst('antinuke', 'anti-nuke');
        final Finder audioListTileTextWidgetFinder = find.text(audioTitle);

        expect(audioListTileTextWidgetFinder, findsNothing);
      }

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets('Manually delete audios in local playlist directory.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}manually_deleting_audios_and_updating_playlists",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String localPlaylistTitle = 'Local_2_audios';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      String localPlaylistPath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localPlaylistTitle';

      List<String> localPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path: localPlaylistPath,
        extension: 'mp3',
      );

      // *** Manually deleting audio files from local
      // playlist directory

      DirUtil.deleteMp3FilesInDir(
        localPlaylistPath,
      );

      // *** Updating the local playlist

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the audios
      // which were manually deleted from the local playlist
      // directory

      // First, find the local playlist ListTile Text widget
      final Finder localPlaylistListTileTextWidgetFinder =
          find.text(localPlaylistTitle);

      // Then obtain the local source playlist ListTile widget
      // enclosing the Text widget by finding its ancestor
      final Finder localPlaylistListTileWidgetFinder = find.ancestor(
        of: localPlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the playlist ListTile
      // and tap on it to select the playlist

      await tapPlaylistCheckboxIfNotAlreadyChecked(
        playlistListTileWidgetFinder: localPlaylistListTileWidgetFinder,
        widgetTester: tester,
      );

      // Test that the local playlist is still showing the
      // deleted audios

      for (String audioTitle in localPlaylistMp3Lst) {
        audioTitle = audioTitle
            .replaceAll(RegExp(r'[\d\-]'), '')
            .replaceFirst(' .mp', '')
            .replaceFirst(' fois', '3 fois')
            .replaceFirst('antinuke', 'anti-nuke');
        final Finder audioListTileTextWidgetFinder = find.text(audioTitle);

        expect(audioListTileTextWidgetFinder, findsOneWidget);
      }

      // Now update the playable audio list of the local
      // playlist

      // Now find the leading menu icon button of the Playlist ListTile
      // and tap on it
      final Finder localPlaylistListTileLeadingMenuIconButton = find.descendant(
        of: localPlaylistListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(localPlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the update playlist popup menu item and tap on it
      final Finder popupUpdatePlayableAudioListPlaylistMenuItem =
          find.byKey(const Key("popup_menu_update_playable_audio_list"));

      await tester.tap(popupUpdatePlayableAudioListPlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now verifying the warning dialog

      // Check the value of the warning dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'WARNING');

      // Check the value of the warning dialog message
      Text warningDialogMessage =
          tester.widget(find.byKey(const Key('warningDialogMessage')));
      expect(warningDialogMessage.data,
          'Playable audio list for playlist "$localPlaylistTitle" was updated. 2 audio(s) were removed.');

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Test that the local playlist is no longer showing the
      // deleted audios

      for (String audioTitle in localPlaylistMp3Lst) {
        audioTitle = audioTitle
            .replaceAll(RegExp(r'[\d\-]'), '')
            .replaceFirst(' .mp', '')
            .replaceFirst(' fois', '3 fois')
            .replaceFirst('antinuke', 'anti-nuke');
        final Finder audioListTileTextWidgetFinder = find.text(audioTitle);

        expect(audioListTileTextWidgetFinder, findsNothing);
      }

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
  });
  group(
      'Executing update playlist JSON files after manually adding or deleting playlist directory and deleting audio files in other playlists test',
      () {
    testWidgets(
        'Manually add Youtube playlist directory and manually delete audio files in other playlist.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}manually_deleting_audios_and_updating_playlists",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String s8AudioYoutubePlaylistTitle = 'S8 audio';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      String s8AudioYoutubePlaylistPath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}$s8AudioYoutubePlaylistTitle';

      List<String> s8AudioYoutubePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path: s8AudioYoutubePlaylistPath,
        extension: 'mp3',
      );

      // *** Manually deleting audio files from S8 Audio Youtube
      // playlist directory

      DirUtil.deleteMp3FilesInDir(
        s8AudioYoutubePlaylistPath,
      );

      // Test that the S8 Audio Youtube playlist is still showing the
      // deleted audios

      for (String audioTitle in s8AudioYoutubePlaylistMp3Lst) {
        audioTitle = audioTitle
            .replaceAll(RegExp(r'[\d\-]'), '')
            .replaceFirst(' .mp', '')
            .replaceFirst(' fois', '3 fois')
            .replaceFirst('antinuke', 'anti-nuke');
        final Finder audioListTileTextWidgetFinder = find.text(audioTitle);

        expect(audioListTileTextWidgetFinder, findsOneWidget);
      }

      // *** Now, manually add the urgent_actus Youtube playlist directory
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}manually_added_playlist_dir",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // *** Execute Updating playlist JSON file menu item

      // open the popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // Test that the S8 Audio Youtube playlist is no longer showing the
      // deleted audios

      for (String audioTitle in s8AudioYoutubePlaylistMp3Lst) {
        audioTitle = audioTitle
            .replaceAll(RegExp(r'[\d\-]'), '')
            .replaceFirst(' .mp', '')
            .replaceFirst(' fois', '3 fois')
            .replaceFirst('antinuke', 'anti-nuke');
        final Finder audioListTileTextWidgetFinder = find.text(audioTitle);

        expect(audioListTileTextWidgetFinder, findsNothing);
      }

      // Now test that the manually added urgent_actus Youtube playlist is
      // displayed

      // Tap the 'Toggle List' button to show the list of playlists. If the
      // list is not opened, checking that a ListTile with the title of
      // the manually added playlist was added to the ListView will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the manually added Youtube
      // playlist

      const String urgentActusyoutubeplaylisttitle = 'urgent_actus';

      // First, find the urgent_actus Youtube playlist ListTile Text widget
      final Finder addedYoutubePlaylistListTileTextWidgetFinder =
          find.text(urgentActusyoutubeplaylisttitle);

      // Then obtain the Youtube source playlist ListTile widget
      // enclosing the Text widget by finding its ancestor
      final Finder addedYoutubePlaylistListTileWidgetFinder = find.ancestor(
        of: addedYoutubePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the playlist ListTile
      // and tap on it to select the playlist

      await tapPlaylistCheckboxIfNotAlreadyChecked(
        playlistListTileWidgetFinder: addedYoutubePlaylistListTileWidgetFinder,
        widgetTester: tester,
      );

      // Test that the audios of the added urgent_actus Youtube playlist
      // are listed

      String urgentActusyoutubeplaylistpath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}$urgentActusyoutubeplaylisttitle';

      List<String> urgentActusyoutubeplaylistmp3lst =
          DirUtil.listFileNamesInDir(
        path: urgentActusyoutubeplaylistpath,
        extension: 'mp3',
      );

      for (String audioTitle in urgentActusyoutubeplaylistmp3lst) {
        audioTitle = audioTitle
            .replaceAll(RegExp(r'[\d\-]'), '')
            .replaceFirst(' .mp', '')
            .replaceFirst(' fois', '3 fois');
        final Finder audioListTileTextWidgetFinder = find.text(audioTitle);

        expect(audioListTileTextWidgetFinder, findsOneWidget);
      }

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets(
        'Manually delete Youtube playlist directory after adding it manually.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}manually_deleting_audios_and_updating_playlists",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // *** Manually add the urgent_actus Youtube playlist directory
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}manually_added_playlist_dir",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // *** Execute Updating playlist JSON file menu item

      // open the popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // Now test that the manually added urgent_actus Youtube playlist is
      // displayed

      // Tap the 'Toggle List' button to show the list of playlists. If the
      // list is not opened, checking that a ListTile with the title of
      // the manually added playlist was added to the ListView will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the manually added Youtube
      // playlist

      const String urgentActusyoutubeplaylisttitle = 'urgent_actus';

      // First, find the urgent_actus Youtube playlist ListTile Text widget
      final Finder addedYoutubePlaylistListTileTextWidgetFinder =
          find.text(urgentActusyoutubeplaylisttitle);

      // Then obtain the Youtube source playlist ListTile widget
      // enclosing the Text widget by finding its ancestor
      final Finder addedYoutubePlaylistListTileWidgetFinder = find.ancestor(
        of: addedYoutubePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the playlist ListTile
      // and tap on it to select the playlist

      await tapPlaylistCheckboxIfNotAlreadyChecked(
        playlistListTileWidgetFinder: addedYoutubePlaylistListTileWidgetFinder,
        widgetTester: tester,
      );

      // Test that the audios of the added urgent_actus Youtube playlist
      // are listed

      String urgentActusyoutubeplaylistpath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}$urgentActusyoutubeplaylisttitle';

      List<String> urgentActusyoutubeplaylistmp3lst =
          DirUtil.listFileNamesInDir(
        path: urgentActusyoutubeplaylistpath,
        extension: 'mp3',
      );

      for (String audioTitle in urgentActusyoutubeplaylistmp3lst) {
        audioTitle = audioTitle
            .replaceAll(RegExp(r'[\d\-]'), '')
            .replaceFirst(' .mp', '')
            .replaceFirst(' fois', '3 fois');
        final Finder audioListTileTextWidgetFinder = find.text(audioTitle);

        expect(audioListTileTextWidgetFinder, findsOneWidget);
      }

      // Now manually delete the urgent_actus playlist directory
      DirUtil.deleteDirAndSubDirsIfExist(
        rootPath: urgentActusyoutubeplaylistpath,
      );

      // *** Execute Updating playlist JSON file menu item

      // open the popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // Now test that the manually deleted urgent_actus Youtube playlist is
      // no longer displayed
      expect(find.text(urgentActusyoutubeplaylisttitle), findsNothing);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets(
        'Manually delete Youtube playlist directory with playlist expanded list closed after adding it manually.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}manually_deleting_audios_and_updating_playlists",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // *** Manually add the urgent_actus Youtube playlist directory
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}manually_added_playlist_dir",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // *** Execute Updating playlist JSON file menu item

      // open the popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // Now test that the manually added urgent_actus Youtube playlist is
      // displayed

      // Tap the 'Toggle List' button to show the list of playlists. If the
      // list is not opened, checking that a ListTile with the title of
      // the manually added playlist was added to the ListView will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the manually added Youtube
      // playlist

      const String urgentActusyoutubeplaylisttitle = 'urgent_actus';

      // First, find the urgent_actus Youtube playlist ListTile Text widget
      final Finder addedYoutubePlaylistListTileTextWidgetFinder =
          find.text(urgentActusyoutubeplaylisttitle);

      // Then obtain the Youtube source playlist ListTile widget
      // enclosing the Text widget by finding its ancestor
      final Finder addedYoutubePlaylistListTileWidgetFinder = find.ancestor(
        of: addedYoutubePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the playlist ListTile
      // and tap on it to select the playlist

      await tapPlaylistCheckboxIfNotAlreadyChecked(
        playlistListTileWidgetFinder: addedYoutubePlaylistListTileWidgetFinder,
        widgetTester: tester,
      );

      // Test that the audios of the added urgent_actus Youtube playlist
      // are listed

      String urgentActusyoutubeplaylistpath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}$urgentActusyoutubeplaylisttitle';

      List<String> urgentActusyoutubeplaylistmp3lst =
          DirUtil.listFileNamesInDir(
        path: urgentActusyoutubeplaylistpath,
        extension: 'mp3',
      );

      for (String audioTitle in urgentActusyoutubeplaylistmp3lst) {
        audioTitle = audioTitle
            .replaceAll(RegExp(r'[\d\-]'), '')
            .replaceFirst(' .mp', '')
            .replaceFirst(' fois', '3 fois');
        final Finder audioListTileTextWidgetFinder = find.text(audioTitle);

        expect(audioListTileTextWidgetFinder, findsOneWidget);
      }

      // Tap the 'Toggle List' button to hide the list of playlists.
      // Since the urgent_actus Youtube playlist is selected, the
      // urgent_actus playlist audio list is be displayed in the
      // AudioPlayerView screen and then right popup menu is active.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Verify that the urgent_actus Youtube playlist audio list is
      // still displayed in the AudioPlayerView screen.
      for (String audioTitle in urgentActusyoutubeplaylistmp3lst) {
        audioTitle = audioTitle
            .replaceAll(RegExp(r'[\d\-]'), '')
            .replaceFirst(' .mp', '')
            .replaceFirst(' fois', '3 fois');
        final Finder audioListTileTextWidgetFinder = find.text(audioTitle);

        expect(audioListTileTextWidgetFinder, findsOneWidget);
      }

      // Now manually delete the urgent_actus playlist directory
      DirUtil.deleteDirAndSubDirsIfExist(
        rootPath: urgentActusyoutubeplaylistpath,
      );

      // *** Execute Updating playlist JSON file menu item

      // open the popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // Now test that no audio list is displayed in the AudioPlayerView
      // screen since the selected urgent_actus Youtube playlist directory was
      // deleted.
      expect(find.text('Jancovici'), findsNothing);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets(
        'With Playlist list displayed, execute update playlist json file after deleting all files in app audio dir and verify audio menu state. Do same after re-adding app audio dir files.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String s8AudioYoutubePlaylistTitle = 'S8 audio';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlists.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the S8 audio Youtube
      // playlist

      // First, find the S8 audio Youtube playlist ListTile Text widget
      final Finder youtubePlaylistListTileTextWidgetFinder =
          find.text(s8AudioYoutubePlaylistTitle);

      // Then obtain the Youtube source playlist ListTile widget
      // enclosing the Text widget by finding its ancestor
      final Finder youtubePlaylistListTileWidgetFinder = find.ancestor(
        of: youtubePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the playlist ListTile
      // and tap on it to select the playlist
      await tapPlaylistCheckboxIfNotAlreadyChecked(
        playlistListTileWidgetFinder: youtubePlaylistListTileWidgetFinder,
        widgetTester: tester,
      );

      // Now tap on the audio menu button to open the audio menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are enabled
      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: false,
      );

      // Now delete all the files in the app audio directory
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);

      // Here, the audio menu is still displayed ...

      // *** Execute Updating playlist JSON file menu item

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // After executing the update playlist json file, the audio popup
      // menu is closed

      // Now tap on the audio menu button to re-open the audio menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are now disabled
      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
      );

      // Now restore the app data in the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // *** Execute again Updating playlist JSON file menu item

      // Here, the audio menu is still displayed ...

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // After executing the update playlist json file, the audio popup
      // menu is closed

      // open the popup menu again
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are now enabled
      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: false,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets(
        'With Playlist list not displayed, execute update playlist json file after deleting all files in app audio dir and verify audio menu state. Do same after re-adding app audio dir files.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String s8AudioYoutubePlaylistTitle = 'S8 audio';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlists.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the S8 audio Youtube
      // playlist

      // First, find the S8 audio Youtube playlist ListTile Text widget
      final Finder youtubePlaylistListTileTextWidgetFinder =
          find.text(s8AudioYoutubePlaylistTitle);

      // Then obtain the Youtube source playlist ListTile widget
      // enclosing the Text widget by finding its ancestor
      final Finder youtubePlaylistListTileWidgetFinder = find.ancestor(
        of: youtubePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the playlist ListTile
      // and tap on it to select the playlist
      await tapPlaylistCheckboxIfNotAlreadyChecked(
        playlistListTileWidgetFinder: youtubePlaylistListTileWidgetFinder,
        widgetTester: tester,
      );

      // Now tap the 'Toggle List' button to hide the list of playlists so
      // that only the S8 audio Youtube playlist audio list is displayed
      // in the AudioPlayerView screen FAILS TEST
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Now tap on the audio menu button to open the audio menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are enabled
      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: false,
      );

      // Now delete all the files in the app audio directory
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);

      // Here, the audio menu is still displayed ...

      // *** Execute Updating playlist JSON file menu item

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // After executing the update playlist json file, the audio popup
      // menu is closed

      // Now tap on the audio menu button to re-open the audio menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are now disabled
      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
      );

      // Now restore the app data in the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // *** Execute again Updating playlist JSON file menu item

      // Here, the audio menu is still displayed ...

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // After executing the update playlist json file, the audio popup
      // menu is closed

      // open the popup menu again
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are now enabled
      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: false,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets(
        'With Playlist list displayed and selected playlist empty, execute update playlist json file after deleting all files in app audio dir and verify audio menu state. Do same after re-adding app audio dir files.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_empty_selected_playlist_widget_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String s8AudioYoutubeEmptyPlaylistTitle = 'S8 audio';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlists.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the S8 audio Youtube
      // playlist

      // First, find the S8 audio Youtube playlist ListTile Text widget
      final Finder youtubePlaylistListTileTextWidgetFinder =
          find.text(s8AudioYoutubeEmptyPlaylistTitle);

      // Then obtain the Youtube source playlist ListTile widget
      // enclosing the Text widget by finding its ancestor
      final Finder youtubePlaylistListTileWidgetFinder = find.ancestor(
        of: youtubePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the playlist ListTile
      // and tap on it to select the playlist
      await tapPlaylistCheckboxIfNotAlreadyChecked(
        playlistListTileWidgetFinder: youtubePlaylistListTileWidgetFinder,
        widgetTester: tester,
      );

      // Now tap on the audio menu button to open the audio menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are disabled
      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
      );

      // Now delete all the files in the app audio directory
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);

      // Here, the audio menu is still displayed ...

      // *** Execute Updating playlist JSON file menu item

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // After executing the update playlist json file, the audio popup
      // menu is closed

      // Now tap on the audio menu button to re-open the audio menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are now disabled
      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
      );

      // Now restore the app data in the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_empty_selected_playlist_widget_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // *** Execute again Updating playlist JSON file menu item

      // Here, the audio menu is still displayed ...

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // After executing the update playlist json file, the audio popup
      // menu is closed

      // open the popup menu again
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are now enabled
      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets(
        'With Playlist list not displayed and selected playlist empty, execute update playlist json file after deleting all files in app audio dir and verify audio menu state. Do same after re-adding app audio dir files.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_empty_selected_playlist_widget_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String s8AudioYoutubeEmptyPlaylistTitle = 'S8 audio';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlists.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the S8 audio Youtube
      // playlist

      // First, find the S8 audio Youtube playlist ListTile Text widget
      final Finder youtubePlaylistListTileTextWidgetFinder =
          find.text(s8AudioYoutubeEmptyPlaylistTitle);

      // Then obtain the Youtube source playlist ListTile widget
      // enclosing the Text widget by finding its ancestor
      final Finder youtubePlaylistListTileWidgetFinder = find.ancestor(
        of: youtubePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the playlist ListTile
      // and tap on it to select the playlist
      await tapPlaylistCheckboxIfNotAlreadyChecked(
        playlistListTileWidgetFinder: youtubePlaylistListTileWidgetFinder,
        widgetTester: tester,
      );

      // Now tap the 'Toggle List' button to hide the list of playlists so
      // that only the S8 audio Youtube playlist audio list is displayed
      // in the AudioPlayerView screen FAILS TEST
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Now tap on the audio menu button to open the audio menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are disabled
      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
      );

      // Now delete all the files in the app audio directory
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);

      // Here, the audio menu is still displayed ...

      // *** Execute Updating playlist JSON file menu item

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // After executing the update playlist json file, the audio popup
      // menu is closed

      // Now tap on the audio menu button to re-open the audio menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are now disabled
      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
      );

      // Now restore the app data in the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_empty_selected_playlist_widget_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // *** Execute again Updating playlist JSON file menu item

      // Here, the audio menu is still displayed ...

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // After executing the update playlist json file, the audio popup
      // menu is closed

      // open the popup menu again
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are disabled
      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
  });
  group('Delete unique audio test', () {
    testWidgets(
        'Delete unique audio mp3 only and then switch to AudioPlayerView screen.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}one_local_playlist_with_one_audio",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String localAudioPlaylistTitle = 'local_audio_playlist_2';
      const String uniqueAudioTitle = 'audio learn test short video one';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the unique audio to
      // delete to

      // First, find the local unique audio playlist ListTile
      // Text widget
      final Finder localAudioPlaylistListTileTextWidgetFinder =
          find.text(localAudioPlaylistTitle);

      // Then obtain the local unique audio playlist ListTile
      // widget enclosing the Text widget by finding its ancestor
      final Finder localAudioPlaylistListTileWidgetFinder = find.ancestor(
        of: localAudioPlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the playlist ListTile
      // and tap on it to select the playlist
      final Finder localAudioPlaylistListTileCheckboxWidgetFinder =
          find.descendant(
        of: localAudioPlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile playlist checkbox to select it
      await tester.tap(localAudioPlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the unique Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder uniqueAudioListTileTextWidgetFinder =
          find.text(uniqueAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder uniqueAudioListTileWidgetFinder = find.ancestor(
        of: uniqueAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      final Finder uniqueAudioListTileLeadingMenuIconButton = find.descendant(
        of: uniqueAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(uniqueAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the delete audio popup menu item and tap on it
      final Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_delete_audio"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Now verifying the selected playlist TextField still
      // contains the title of the source playlist

      TextField selectedPlaylistTextField = tester.widget<TextField>(
          find.byKey(const Key('selectedPlaylistTextField')));

      expect(
          selectedPlaylistTextField.controller!.text, localAudioPlaylistTitle);

      // Now verifying that the audio was physically deleted from the
      // local playlist directory.

      List<String> localPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioPlaylistTitle',
        extension: 'mp3',
      );

      // Verify the local target playlist directory content
      expect(localPlaylistMp3Lst, []);

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen

      final audioPlayerNavButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(audioPlayerNavButton);
      await tester.pumpAndSettle();

      // Now verifying that 'No audio selected' is displayed in the
      // AudioPlayerView screen

      final Finder noAudioSelectedTextWidgetFinder =
          find.text('No audio selected');
      expect(noAudioSelectedTextWidgetFinder, findsOneWidget);

      // Now verifying that the audio player view audio position
      // is 0:00

      final Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));
      final Text audioPlayerViewAudioPositionTextWidget =
          tester.widget<Text>(audioPlayerViewAudioPositionFinder);
      expect(audioPlayerViewAudioPositionTextWidget.data, '0:00');

      // Now verifying that the audio player view audio remaining
      // duration 0:00

      final Finder audioPlayerViewAudioRemainingDurationFinder =
          find.byKey(const Key('audioPlayerViewAudioRemainingDuration'));
      final Text audioPlayerViewAudioRemainingDurationTextWidget =
          tester.widget<Text>(audioPlayerViewAudioRemainingDurationFinder);
      expect(audioPlayerViewAudioRemainingDurationTextWidget.data, '0:00');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets(
        'Delete unique audio from playlist as well and then switch to AudioPlayerView screen.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}one_local_playlist_with_one_audio",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String localAudioPlaylistTitle = 'local_audio_playlist_2';
      const String uniqueAudioTitle = 'audio learn test short video one';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the unique audio to
      // delete to

      // First, find the local unique audio playlist ListTile
      // Text widget
      final Finder localAudioPlaylistListTileTextWidgetFinder =
          find.text(localAudioPlaylistTitle);

      // Then obtain the local unique audio playlist ListTile
      // widget enclosing the Text widget by finding its ancestor
      final Finder localAudioPlaylistListTileWidgetFinder = find.ancestor(
        of: localAudioPlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the playlist ListTile
      // and tap on it to select the playlist
      final Finder localAudioPlaylistListTileCheckboxWidgetFinder =
          find.descendant(
        of: localAudioPlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile playlist checkbox to select it
      await tester.tap(localAudioPlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the unique Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder uniqueAudioListTileTextWidgetFinder =
          find.text(uniqueAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder uniqueAudioListTileWidgetFinder = find.ancestor(
        of: uniqueAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      final Finder uniqueAudioListTileLeadingMenuIconButton = find.descendant(
        of: uniqueAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(uniqueAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the delete audio from playlist as well popup menu
      // item and tap on it
      final Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_delete_audio_from_playlist_aswell"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Now verifying the selected playlist TextField still
      // contains the title of the source playlist

      TextField selectedPlaylistTextField = tester.widget<TextField>(
          find.byKey(const Key('selectedPlaylistTextField')));

      expect(
          selectedPlaylistTextField.controller!.text, localAudioPlaylistTitle);

      // Now verifying that the audio was physically deleted from the
      // local playlist directory.

      List<String> localPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        path:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioPlaylistTitle',
        extension: 'mp3',
      );

      // Verify the local target playlist directory content
      expect(localPlaylistMp3Lst, []);

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen

      final audioPlayerNavButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(audioPlayerNavButton);
      await tester.pumpAndSettle();

      // Now verifying that 'No audio selected' is displayed in the
      // AudioPlayerView screen

      final Finder noAudioSelectedTextWidgetFinder =
          find.text('No audio selected');
      expect(noAudioSelectedTextWidgetFinder, findsOneWidget);

      // Now verifying that the audio player view audio position
      // is 0:00

      final Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));
      final Text audioPlayerViewAudioPositionTextWidget =
          tester.widget<Text>(audioPlayerViewAudioPositionFinder);
      expect(audioPlayerViewAudioPositionTextWidget.data, '0:00');

      // Now verifying that the audio player view audio remaining
      // duration 0:00

      final Finder audioPlayerViewAudioRemainingDurationFinder =
          find.byKey(const Key('audioPlayerViewAudioRemainingDuration'));
      final Text audioPlayerViewAudioRemainingDurationTextWidget =
          tester.widget<Text>(audioPlayerViewAudioRemainingDurationFinder);
      expect(audioPlayerViewAudioRemainingDurationTextWidget.data, '0:00');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
  });
  group('Bug fix tests', () {
    testWidgets('Verifying with partial download of single video audio',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      String singleVideoUrl = 'https://youtu.be/uv3VQoWSjBE';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Enter the single video URL into the url text field
      await tester.enterText(
        find.byKey(const Key('playlistUrlTextField')),
        singleVideoUrl,
      );
      await tester.pumpAndSettle();

      // Ensure the url text field contains the entered url
      TextField urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, singleVideoUrl);

      // Tap the 'Download single video button' button. Before fixing
      // the bug, this caused an exception to be thrown
      await tester.tap(find.byKey(const Key('downloadSingleVideoButton')));
      await tester.pumpAndSettle();

      // Now find the cancel button and tap on it since the audio
      // download can not be done in the test environment
      await tester.tap(find.byKey(const Key('cancelButton')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets(
        'Verifying execution of "Delete audio from playlist as well" playlist menu item',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}delete_audio_from_audio_learn_short_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String youtubeAudioPlaylistTitle = 'audio_learn_short';
      const String audioToDeleteTitle =
          '15 minutes de Janco pour retourner un climatosceptique';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the audio to move to
      // the target local playlist

      // First, find the Playlist ListTile Text widget
      final Finder sourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioPlaylistTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder sourcePlaylistListTileWidgetFinder = find.ancestor(
        of: sourcePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder sourcePlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: sourcePlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(sourcePlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      final Finder sourceAudioListTileTextWidgetFinder =
          find.text(audioToDeleteTitle).first;

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile and tap
      // on it
      final Finder sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the popup menu item and tap on it
      final Finder popupDeleteAudioFromPlaylistAsWellMenuItem =
          find.byKey(const Key("popup_menu_delete_audio_from_playlist_aswell"));

      await tester.tap(popupDeleteAudioFromPlaylistAsWellMenuItem);
      await tester.pumpAndSettle();

      // Ensure the warning dialog is shown
      expect(find.byType(WarningMessageDisplayWidget), findsOneWidget);

      // Check the value of the warning dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'WARNING');

      // Check the value of the warning dialog message
      Text warningDialogMessage =
          tester.widget(find.byKey(const Key('warningDialogMessage')));
      expect(warningDialogMessage.data,
          'If the deleted audio video "$audioToDeleteTitle" remains in the "$youtubeAudioPlaylistTitle" Youtube playlist, it will be downloaded again the next time you download the playlist !');

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Check the saved youtube audio playlist values in the json file

      final youtubeAudioPlaylistPath = path.join(
        kPlaylistDownloadRootPathWindowsTest,
        youtubeAudioPlaylistTitle,
      );

      final youtubeAudioPlaylistFilePathName = path.join(
        youtubeAudioPlaylistPath,
        '$youtubeAudioPlaylistTitle.json',
      );

      // Load playlist from the json file
      Playlist loadedYoutubeAudioPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: youtubeAudioPlaylistFilePathName,
        type: Playlist,
      );

      final expectedAudioPlaylistFilePathName = path.join(
        youtubeAudioPlaylistPath,
        '${youtubeAudioPlaylistTitle}_expected.json',
      );

      // Load playlist from the json file
      Playlist loadedExpectedAudioPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: expectedAudioPlaylistFilePathName,
        type: Playlist,
      );

      int loadedDownloadedAudioLastItemIndex =
          loadedYoutubeAudioPlaylist.downloadedAudioLst.length - 1;
      expect(
        loadedYoutubeAudioPlaylist
            .downloadedAudioLst[loadedDownloadedAudioLastItemIndex]
            .audioFileName,
        loadedYoutubeAudioPlaylist.playableAudioLst[0].audioFileName,
      );

      expect(
          loadedYoutubeAudioPlaylist
              .downloadedAudioLst[loadedDownloadedAudioLastItemIndex]
              .audioFileName,
          loadedExpectedAudioPlaylist
              .downloadedAudioLst[loadedDownloadedAudioLastItemIndex]
              .audioFileName);
      expect(loadedYoutubeAudioPlaylist.playableAudioLst[0].audioFileName,
          loadedExpectedAudioPlaylist.playableAudioLst[0].audioFileName);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets('Click on download at musical quality checkbox bug fix',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}playlist_download_view_button_state_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of no selected playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the Youtube playlist to select

      // First, find the Playlist ListTile Text widget
      final Finder youtubePlaylistToSelectListTileTextWidgetFinder =
          find.text('audio_player_view_2_shorts_test');

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder youtubePlaylistToSelectListTileWidgetFinder = find.ancestor(
        of: youtubePlaylistToSelectListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder youtubePlaylistToSelectListTileCheckboxWidgetFinder =
          find.descendant(
        of: youtubePlaylistToSelectListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(youtubePlaylistToSelectListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now tap the download at musical quality checkbox
      await tester.tap(find.byKey(const Key('audio_quality_checkbox')));
      await tester.pumpAndSettle();

      // Verify that the download at musical quality checkbox is
      // checked
      Finder downloadAtMusicalQualityCheckBoxFinder =
          find.byKey(const Key('audio_quality_checkbox'));
      Checkbox downloadAtMusicalQualityCheckBoxWidget =
          tester.widget<Checkbox>(downloadAtMusicalQualityCheckBoxFinder);
      expect(downloadAtMusicalQualityCheckBoxWidget.value, true);

      Finder snackBarMessageFinder = find.text("Download at music quality");
      expect(snackBarMessageFinder, findsOneWidget);

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Now retap the download at musical quality checkbox
      await tester.tap(find.byKey(const Key('audio_quality_checkbox')));
      await tester.pumpAndSettle();

      // Verify that the download at musical quality checkbox is
      // unchecked
      downloadAtMusicalQualityCheckBoxFinder =
          find.byKey(const Key('audio_quality_checkbox'));
      downloadAtMusicalQualityCheckBoxWidget =
          tester.widget<Checkbox>(downloadAtMusicalQualityCheckBoxFinder);
      expect(downloadAtMusicalQualityCheckBoxWidget.value, false);

      snackBarMessageFinder = find.text("Download at audio quality");
      expect(snackBarMessageFinder, findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
  });
  group('Delete existing playlist test', () {
    testWidgets('Delete selected Youtube playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}2_youtube_2_local_playlists_delete_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String youtubePlaylistToDeleteTitle =
          'audio_learn_test_download_2_small_videos';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the playlist to delete ListTile

      // First, find the Playlist ListTile Text widget
      final Finder youtubePlaylistToDeleteListTileTextWidgetFinder =
          find.text(youtubePlaylistToDeleteTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder youtubePlaylistToDeleteListTileWidgetFinder = find.ancestor(
        of: youtubePlaylistToDeleteListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder youtubePlaylistToDeleteListTileCheckboxWidgetFinder =
          find.descendant(
        of: youtubePlaylistToDeleteListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(youtubePlaylistToDeleteListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now test deleting the playlist

      // Open the delete playlist dialog by clicking on the 'Delete
      // playlist ...' playlist menu item

      // Now find the leading menu icon button of the Playlist to
      // delete ListTile and tap on it
      final Finder firstPlaylistListTileLeadingMenuIconButton = find.descendant(
        of: youtubePlaylistToDeleteListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(firstPlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget =
          tester.widget<Text>(find.byKey(const Key('confirmDialogTitleKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Supprimer la playlist Youtube "$youtubePlaylistToDeleteTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('confirmButtonKey')));
      await tester.pumpAndSettle();

      // Reload the settings from the json file.
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      // Check that the deleted playlist title is no longer in the
      // playlist titles list of the settings data service
      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          [
            'audio_player_view_2_shorts_test',
            'local_audio_playlist_2',
            'local_3'
          ]);

      final String youtubePlaylistToDeletePath = path.join(
        kPlaylistDownloadRootPathWindowsTest,
        youtubePlaylistToDeleteTitle,
      );

      // Check that the deleted playlist directory no longer exist
      expect(Directory(youtubePlaylistToDeletePath).existsSync(), false);

      // Since the deleted playlist was selected, there is no longer
      // a selected playlist. So, the selected playlist widgets
      // are disabled. Checking this now:

      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
      );

      // Verifying that the selected playlist text field is empty
      expect(
          reason: 'Selected playlist text field is not empty',
          tester
              .widget<TextField>(
                  find.byKey(const Key('selectedPlaylistTextField')))
              .controller!
              .text,
          '');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets('Cancel delete selected Youtube playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}2_youtube_2_local_playlists_delete_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String youtubePlaylistToDeleteTitle =
          'audio_learn_test_download_2_small_videos';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the playlist to delete ListTile

      // First, find the Playlist ListTile Text widget
      final Finder youtubePlaylistToDeleteListTileTextWidgetFinder =
          find.text(youtubePlaylistToDeleteTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder youtubePlaylistToDeleteListTileWidgetFinder = find.ancestor(
        of: youtubePlaylistToDeleteListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder youtubePlaylistToDeleteListTileCheckboxWidgetFinder =
          find.descendant(
        of: youtubePlaylistToDeleteListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(youtubePlaylistToDeleteListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now test cancelling deleting the playlist

      // Open the delete playlist dialog by clicking on the 'Delete
      // playlist ...' playlist menu item

      // Now find the leading menu icon button of the Playlist to
      // delete ListTile and tap on it
      final Finder firstPlaylistListTileLeadingMenuIconButton = find.descendant(
        of: youtubePlaylistToDeleteListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(firstPlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now find the cancel button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('cancelButtonKey')));
      await tester.pumpAndSettle();

      // Reload the settings from the json file.
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      // Check that the deleted playlist title is still in the
      // playlist titles list of the settings data service
      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          [
            'audio_player_view_2_shorts_test',
            youtubePlaylistToDeleteTitle,
            'local_audio_playlist_2',
            'local_3'
          ]);

      final String youtubePlaylistToDeletePath = path.join(
        kPlaylistDownloadRootPathWindowsTest,
        youtubePlaylistToDeleteTitle,
      );

      // Check that the deleted playlist directory still exist
      expect(Directory(youtubePlaylistToDeletePath).existsSync(), true);

      // Since the playlist deletion was cancelled and the playlist was
      // selected, the selected playlist widgets are enabled. Checking
      // this now:

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: false,
      );

      // Verifying that the selected playlist text field is empty
      expect(
          reason: 'Selected playlist text field is empty',
          tester
              .widget<TextField>(
                  find.byKey(const Key('selectedPlaylistTextField')))
              .controller!
              .text,
          youtubePlaylistToDeleteTitle);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets('Delete selected local playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}2_youtube_2_local_playlists_delete_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String localPlaylistToDeleteTitle = 'local_audio_playlist_2';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the playlist to delete ListTile

      // First, find the Playlist ListTile Text widget
      final Finder localPlaylistToDeleteListTileTextWidgetFinder =
          find.text(localPlaylistToDeleteTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder localPlaylistToDeleteListTileWidgetFinder = find.ancestor(
        of: localPlaylistToDeleteListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder localPlaylistToDeleteListTileCheckboxWidgetFinder =
          find.descendant(
        of: localPlaylistToDeleteListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(localPlaylistToDeleteListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now test deleting the playlist

      // Open the delete playlist dialog by clicking on the 'Delete
      // playlist ...' playlist menu item

      // Now find the leading menu icon button of the Playlist to
      // delete ListTile and tap on it
      final Finder firstPlaylistListTileLeadingMenuIconButton = find.descendant(
        of: localPlaylistToDeleteListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(firstPlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget =
          tester.widget<Text>(find.byKey(const Key('confirmDialogTitleKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Supprimer la playlist locale "$localPlaylistToDeleteTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('confirmButtonKey')));
      await tester.pumpAndSettle();

      // Reload the settings from the json file.
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      // Check that the deleted playlist title is no longer in the
      // playlist titles list of the settings data service
      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          [
            'audio_player_view_2_shorts_test',
            'audio_learn_test_download_2_small_videos',
            'local_3'
          ]);

      final String localPlaylistToDeletePath = path.join(
        kPlaylistDownloadRootPathWindowsTest,
        localPlaylistToDeleteTitle,
      );

      // Check that the deleted playlist directory no longer exist
      expect(Directory(localPlaylistToDeletePath).existsSync(), false);

      // Since the deleted playlist was selected, there is no longer
      // a selected playlist. So, the selected playlist widgets
      // are disabled. Checking this now:

      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
      );

      // Verifying that the selected playlist text field is empty
      expect(
          reason: 'Selected playlist text field is not empty',
          tester
              .widget<TextField>(
                  find.byKey(const Key('selectedPlaylistTextField')))
              .controller!
              .text,
          '');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets('Cancel delete selected local playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}2_youtube_2_local_playlists_delete_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String localPlaylistToDeleteTitle = 'local_audio_playlist_2';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the playlist to delete ListTile

      // First, find the Playlist ListTile Text widget
      final Finder localPlaylistToDeleteListTileTextWidgetFinder =
          find.text(localPlaylistToDeleteTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder localPlaylistToDeleteListTileWidgetFinder = find.ancestor(
        of: localPlaylistToDeleteListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder localPlaylistToDeleteListTileCheckboxWidgetFinder =
          find.descendant(
        of: localPlaylistToDeleteListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(localPlaylistToDeleteListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now test cancelling deleting the playlist

      // Open the delete playlist dialog by clicking on the 'Delete
      // playlist ...' playlist menu item

      // Now find the leading menu icon button of the Playlist to
      // delete ListTile and tap on it
      final Finder firstPlaylistListTileLeadingMenuIconButton = find.descendant(
        of: localPlaylistToDeleteListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(firstPlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now find the cancel button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('cancelButtonKey')));
      await tester.pumpAndSettle();

      // Reload the settings from the json file.
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      // Check that the cancelled deleting playlist title is still in the
      // playlist titles list of the settings data service
      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          [
            'audio_player_view_2_shorts_test',
            'audio_learn_test_download_2_small_videos',
            localPlaylistToDeleteTitle,
            'local_3'
          ]);

      final String localPlaylistToDeletePath = path.join(
        kPlaylistDownloadRootPathWindowsTest,
        localPlaylistToDeleteTitle,
      );

      // Check that the deleted playlist directory still exist
      expect(Directory(localPlaylistToDeletePath).existsSync(), true);

      // Since the deletion of the selected playlist was cancelled,
      // there is still a selected playlist. So, the selected playlist
      // widgets are enabled. Checking this now:

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: false,
      );

      // Verifying that the selected playlist text field is not empty
      expect(
          reason: 'Selected playlist text field is not empty',
          tester
              .widget<TextField>(
                  find.byKey(const Key('selectedPlaylistTextField')))
              .controller!
              .text,
          localPlaylistToDeleteTitle);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets(
        'Delete non selected Youtube playlist while another Youtube playlist is selected',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}2_youtube_2_local_playlists_delete_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String youtubePlaylistToDeleteTitle =
          'audio_learn_test_download_2_small_videos';

      const String youtubePlaylistToSelectTitle =
          'audio_player_view_2_shorts_test';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the playlist to select ListTile

      // First, find the Playlist ListTile Text widget
      final Finder youtubePlaylistToSelectListTileTextWidgetFinder =
          find.text(youtubePlaylistToSelectTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder youtubePlaylistToSelectListTileWidgetFinder = find.ancestor(
        of: youtubePlaylistToSelectListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder youtubePlaylistToSelectListTileCheckboxWidgetFinder =
          find.descendant(
        of: youtubePlaylistToSelectListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(youtubePlaylistToSelectListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Find the playlist to delete ListTile

      // First, find the Playlist ListTile Text widget
      final Finder playlistToDeleteListTileTextWidgetFinder =
          find.text(youtubePlaylistToDeleteTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder playlistToDeleteListTileWidgetFinder = find.ancestor(
        of: playlistToDeleteListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now test deleting the playlist

      // Open the delete playlist dialog by clicking on the 'Delete
      // playlist ...' playlist menu item

      // Now find the leading menu icon button of the Playlist to
      // delete ListTile and tap on it
      final Finder firstPlaylistListTileLeadingMenuIconButton = find.descendant(
        of: playlistToDeleteListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(firstPlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget =
          tester.widget<Text>(find.byKey(const Key('confirmDialogTitleKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Supprimer la playlist Youtube "$youtubePlaylistToDeleteTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('confirmButtonKey')));
      await tester.pumpAndSettle();

      // Reload the settings from the json file.
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      // Check that the deleted playlist title is no longer in the
      // playlist titles list of the settings data service
      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          [
            'audio_player_view_2_shorts_test',
            'local_audio_playlist_2',
            'local_3'
          ]);

      final String newPlaylistPath = path.join(
        kPlaylistDownloadRootPathWindowsTest,
        youtubeNewPlaylistTitle,
      );

      // Check that the deleted playlist directory no longer exist
      expect(Directory(newPlaylistPath).existsSync(), false);

      // Since the deleted playlist was not selected and that another
      // Youtube playlist was selected, the selected playlist widgets
      // remain enabled. Checking this now:

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets(
        'Delete non selected Youtube playlist while a local playlist is selected',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}2_youtube_2_local_playlists_delete_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String youtubePlaylistToDeleteTitle =
          'audio_learn_test_download_2_small_videos';

      const String localPlaylistToSelectTitle = 'local_audio_playlist_2';

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the playlist to select ListTile

      // First, find the Playlist ListTile Text widget
      final Finder localPlaylistToSelectListTileTextWidgetFinder =
          find.text(localPlaylistToSelectTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder localPlaylistToSelectListTileWidgetFinder = find.ancestor(
        of: localPlaylistToSelectListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder localPlaylistToSelectListTileCheckboxWidgetFinder =
          find.descendant(
        of: localPlaylistToSelectListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(localPlaylistToSelectListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Find the playlist to delete ListTile

      // First, find the Playlist ListTile Text widget
      final Finder playlistToDeleteListTileTextWidgetFinder =
          find.text(youtubePlaylistToDeleteTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder playlistToDeleteListTileWidgetFinder = find.ancestor(
        of: playlistToDeleteListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now test deleting the playlist

      // Open the delete playlist dialog by clicking on the 'Delete
      // playlist ...' playlist menu item

      // Now find the leading menu icon button of the Playlist to
      // delete ListTile and tap on it
      final Finder firstPlaylistListTileLeadingMenuIconButton = find.descendant(
        of: playlistToDeleteListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(firstPlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget =
          tester.widget<Text>(find.byKey(const Key('confirmDialogTitleKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Supprimer la playlist Youtube "$youtubePlaylistToDeleteTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('confirmButtonKey')));
      await tester.pumpAndSettle();

      // Reload the settings from the json file.
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      // Check that the deleted playlist title is no longer in the
      // playlist titles list of the settings data service
      expect(
          settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.orderedTitleLst,
          ),
          [
            'audio_player_view_2_shorts_test',
            'local_audio_playlist_2',
            'local_3'
          ]);

      final String newPlaylistPath = path.join(
        kPlaylistDownloadRootPathWindowsTest,
        youtubeNewPlaylistTitle,
      );

      // Check that the deleted playlist directory no longer exist
      expect(Directory(newPlaylistPath).existsSync(), false);

      // Since the deleted playlist was not selected and that a local
      // playlist was selected, the selected playlist widgets remain
      // enabled, except the download selected playlist button.
      // Checking this now:

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      // since a local playlist is selected, the download
      // audios of selected playlist button is disabled
      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // since the selected local playlist has no audios, the
      // audio menu item is disabled
      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
  });
  group('PlaylistDownloadView buttons state test', () {
    testWidgets('PlaylistDownloadView displayed with no selected playlist',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}playlist_download_view_button_state_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // since no playlist is selected, verify that no button is
      // enabled
      await ensureNoButtonIsEnabledSinceNoPlaylistIsSelected(tester);

      // Tap the 'Toggle List' button to show the list of no selected playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // since no playlist is selected, verify that no button is
      // enabled
      await ensureNoButtonIsEnabledSinceNoPlaylistIsSelected(tester);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets('Select a local playlist with no audio', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}playlist_download_view_button_state_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of no selected playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the local playlist to select

      // First, find the Playlist ListTile Text widget
      final Finder localPlaylistToSelectListTileTextWidgetFinder =
          find.text('local_audio_playlist_2');

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder localPlaylistToSelectListTileWidgetFinder = find.ancestor(
        of: localPlaylistToSelectListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder localPlaylistToSelectListTileCheckboxWidgetFinder =
          find.descendant(
        of: localPlaylistToSelectListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(localPlaylistToSelectListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // since a local playlist is selected, verify that
      // some buttons are enabled and some are disabled
      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'audio_quality_checkbox',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // since the selected local playlist has no audios, the
      // audio menu item is disabled
      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets('Select a Youtube playlist with no audio', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}playlist_download_view_button_state_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of no selected playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the Youtube playlist to select

      // First, find the Playlist ListTile Text widget
      final Finder youtubePlaylistToSelectListTileTextWidgetFinder =
          find.text('audio_player_view_2_shorts_test');

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder youtubePlaylistToSelectListTileWidgetFinder = find.ancestor(
        of: youtubePlaylistToSelectListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder youtubePlaylistToSelectListTileCheckboxWidgetFinder =
          find.descendant(
        of: youtubePlaylistToSelectListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(youtubePlaylistToSelectListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // since a Youtube playlist is selected, verify that all
      // buttons are enabled
      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_quality_checkbox',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // since the selected local playlist has no audios, the
      // audio menu item is disabled
      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets('Select a local playlist with audio', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}playlist_download_view_button_state_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of no selected playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the local playlist to select

      // First, find the Playlist ListTile Text widget
      final Finder localPlaylistToSelectListTileTextWidgetFinder =
          find.text('local_3');

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder localPlaylistToSelectListTileWidgetFinder = find.ancestor(
        of: localPlaylistToSelectListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder localPlaylistToSelectListTileCheckboxWidgetFinder =
          find.descendant(
        of: localPlaylistToSelectListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(localPlaylistToSelectListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // since a local playlist is selected, verify that
      // some buttons are enabled and some are disabled
      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'audio_quality_checkbox',
      );

      // since the playlist has audios, the audio popup menu
      // button is enabled
      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets('Select a Youtube playlist with audio', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}playlist_download_view_button_state_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of no selected playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the Youtube playlist to select

      // First, find the Playlist ListTile Text widget
      final Finder youtubePlaylistToSelectListTileTextWidgetFinder =
          find.text('audio_learn_test_download_2_small_videos');

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder youtubePlaylistToSelectListTileWidgetFinder = find.ancestor(
        of: youtubePlaylistToSelectListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder youtubePlaylistToSelectListTileCheckboxWidgetFinder =
          find.descendant(
        of: youtubePlaylistToSelectListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(youtubePlaylistToSelectListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // since a Youtube playlist is selected, verify that all
      // buttons are enabled
      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_quality_checkbox',
      );

      // since the playlist has audios, the audio popup menu
      // button is enabled
      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets('Delete a Youtube playlist with audios', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}playlist_download_view_button_state_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of no selected playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the Youtube playlist to select

      // First, find the Playlist ListTile Text widget
      const String youtubePlaylistToSelectTitle =
          'audio_learn_test_download_2_small_videos';

      final Finder youtubePlaylistToSelectListTileTextWidgetFinder =
          find.text(youtubePlaylistToSelectTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder youtubePlaylistToSelectListTileWidgetFinder = find.ancestor(
        of: youtubePlaylistToSelectListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder youtubePlaylistToSelectListTileCheckboxWidgetFinder =
          find.descendant(
        of: youtubePlaylistToSelectListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(youtubePlaylistToSelectListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // now delete the selected playlist

      // find the leading menu icon button of the Playlist to
      // delete ListTile and tap on it
      final Finder youtubePlaylistToDeleteListTileLeadingMenuIconButton =
          find.descendant(
        of: youtubePlaylistToSelectListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(youtubePlaylistToDeleteListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget =
          tester.widget<Text>(find.byKey(const Key('confirmDialogTitleKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Delete Youtube Playlist "$youtubePlaylistToSelectTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('confirmButtonKey')));
      await tester.pumpAndSettle();

      // since the Youtube playlist was deleted, verify that all
      // buttons are disabled
      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'audio_quality_checkbox',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // since the selected local playlist has no audios, the
      // audio menu item is disabled
      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets('Delete a local playlist with 1 audio', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}playlist_download_view_button_state_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of no selected playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the local playlist to select

      // First, find the Playlist ListTile Text widget
      const String localPlaylistTitle = 'local_3';
      final Finder localPlaylistToSelectListTileTextWidgetFinder =
          find.text(localPlaylistTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder localPlaylistToSelectListTileWidgetFinder = find.ancestor(
        of: localPlaylistToSelectListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder localPlaylistToSelectListTileCheckboxWidgetFinder =
          find.descendant(
        of: localPlaylistToSelectListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(localPlaylistToSelectListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // now delete the selected playlist

      // find the leading menu icon button of the Playlist to
      // delete ListTile and tap on it
      final Finder localPlaylistToDeleteListTileLeadingMenuIconButton =
          find.descendant(
        of: localPlaylistToSelectListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(localPlaylistToDeleteListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget =
          tester.widget<Text>(find.byKey(const Key('confirmDialogTitleKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Delete Local Playlist "$localPlaylistTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('confirmButtonKey')));
      await tester.pumpAndSettle();

      // since the local playlist was deleted, verify that all
      // buttons are disabled
      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'audio_quality_checkbox',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // since the selected local playlist has no audios, the
      // audio menu item is disabled
      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets('Delete a unique audio in a local playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}playlist_download_view_button_state_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of no selected playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the local playlist to select

      // First, find the Playlist ListTile Text widget
      const String localPlaylistTitle = 'local_3';
      final Finder localPlaylistToSelectListTileTextWidgetFinder =
          find.text(localPlaylistTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder localPlaylistToSelectListTileWidgetFinder = find.ancestor(
        of: localPlaylistToSelectListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder localPlaylistToSelectListTileCheckboxWidgetFinder =
          find.descendant(
        of: localPlaylistToSelectListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(localPlaylistToSelectListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // now delete the unique audio of the playlist

      // Now we want to tap the popup menu of the unique Audio ListTile
      // "audio learn test short video two"

      // First, find the Audio sublist ListTile Text widget
      final Finder uniqueAudioListTileTextWidgetFinder =
          find.text('audio learn test short video two');

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder uniqueAudioListTileWidgetFinder = find.ancestor(
        of: uniqueAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      final Finder uniqueAudioListTileLeadingMenuIconButton = find.descendant(
        of: uniqueAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(uniqueAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the delete audio popup menu item and tap on it
      final Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_delete_audio"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'audio_quality_checkbox',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // since the selected local playlist has no audios, the
      // audio menu item is disabled
      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets('Delete a unique audio in a Youtube playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}playlist_download_view_button_state_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of no selected playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the Youtube playlist to select

      // First, find the Playlist ListTile Text widget
      const String youtubePlaylistToSelectTitle =
          'audio_learn_new_youtube_playlist_test';

      final Finder youtubePlaylistToSelectListTileTextWidgetFinder =
          find.text(youtubePlaylistToSelectTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder youtubePlaylistToSelectListTileWidgetFinder = find.ancestor(
        of: youtubePlaylistToSelectListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder youtubePlaylistToSelectListTileCheckboxWidgetFinder =
          find.descendant(
        of: youtubePlaylistToSelectListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(youtubePlaylistToSelectListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // now delete the unique audio of the playlist

      // Now we want to tap the popup menu of the unique Audio ListTile
      // "audio learn test short video two"

      // First, find the Audio sublist ListTile Text widget
      final Finder uniqueAudioListTileTextWidgetFinder =
          find.text('audio learn test short video two');

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      final Finder uniqueAudioListTileWidgetFinder = find.ancestor(
        of: uniqueAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile
      // and tap on it
      final Finder uniqueAudioListTileLeadingMenuIconButton = find.descendant(
        of: uniqueAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(uniqueAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the delete audio popup menu item and tap on it
      final Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_delete_audio"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_quality_checkbox',
      );

      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // since the selected local playlist has no audios, the
      // audio menu item is disabled
      verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
  });
  group('Sort/filter test', () {
    testWidgets(
        'Menu Clear sort/filter parameters history execution verifying that the confirm dialog is displayed in the playlist download  view.',
        (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_filter_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio titles
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Now open the popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // find the clear sort/filter audio history menu item and tap on it
      await tester.tap(find.byKey(
          const Key('clear_sort_and_filter_audio_options_history_menu_item')));
      await tester.pumpAndSettle();

      // Verify that the confirm action dialog is displayed
      // with the expected text
      expect(find.text('Clear sort/filter parameters history'), findsOneWidget);
      expect(find.text('Deleting all historical sort/filter parameters.'),
          findsOneWidget);

      // Click on the cancel button to cancel deletion
      await tester.tap(find.byKey(const Key('cancelButtonKey')));
      await tester.pumpAndSettle();

      // Open again the popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // find the clear sort/filter audio history menu item and tap on it
      await tester.tap(find.byKey(
          const Key('clear_sort_and_filter_audio_options_history_menu_item')));
      await tester.pumpAndSettle();

      // Click on the confirm button to cancel deletion
      await tester.tap(find.byKey(const Key('confirmButtonKey')));
      await tester.pumpAndSettle();

      // Verify that the clear sort/filter audio history menu item is
      // now disabled
      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: "clear_sort_and_filter_audio_options_history_menu_item",
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets(
        'Sort filter audio dialog button clear sort/filter parameters history typing verifying that bthe warning is displayed in the play audio view.',
        (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio titles
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Now open the popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // find the sort/filter audios menu item and tap on it
      await tester
          .tap(find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
      await tester.pumpAndSettle();

      // Verify that the left sort history icon button is disabled
      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: "search_history_arrow_left_button",
      );

      // Verify that the right sort history icon button is disabled
      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: "search_history_arrow_right_button",
      );

      // Verify that the clear sort history icon button is disabled
      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: "search_history_delete_all_button",
      );

      // Type "janco" in the audio title search sentence TextField
      await tester.enterText(
          find.byKey(const Key('audioTitleSearchSentenceTextField')), 'janco');
      await tester.pumpAndSettle();

      // Click on the "+" icon button
      await tester.tap(find.byKey(const Key('addSentenceIconButton')));
      await tester.pumpAndSettle();

      // Verify that the left sort history icon button is still disabled
      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: "search_history_arrow_left_button",
      );

      // Verify that the right sort history icon button is still disabled
      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: "search_history_arrow_right_button",
      );

      // Verify that the clear sort history icon button is still disabled
      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: "search_history_delete_all_button",
      );

      // Click on the "apply" button. This closes the sort/filter dialog.
      await tester
          .tap(find.byKey(const Key('applySortFilterOptionsTextButton')));
      await tester.pumpAndSettle();

      // Now re-open the popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // find the sort/filter audios menu item and tap on it
      await tester
          .tap(find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
      await tester.pumpAndSettle();

      // Verify that the left sort history icon button is now enabled
      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: "search_history_arrow_left_button",
      );

      // Verify that the right sort history icon button is still disabled
      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: "search_history_arrow_right_button",
      );

      // Verify that the clear sort history icon button is now enabled
      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: "search_history_delete_all_button",
      );

      // Now click on the clear sort history icon button
      await tester
          .tap(find.byKey(const Key('search_history_delete_all_button')));
      await tester.pumpAndSettle();

      // Verify that the confirm action dialog is displayed
      // with the expected text
      expect(find.text('Clear sort/filter parameters history'), findsOneWidget);
      expect(find.text('Deleting all historical sort/filter parameters.'),
          findsOneWidget);

      // Click on the cancel button to cancel deletion
      await tester.tap(find.byKey(const Key('cancelButtonKey')));
      await tester.pumpAndSettle();

      // Verify that the left sort history icon button is still enabled
      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: "search_history_arrow_left_button",
      );

      // Verify that the right sort history icon button is still disabled
      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: "search_history_arrow_right_button",
      );

      // Verify that the clear sort history icon button is still enabled
      TestUtility.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: "search_history_delete_all_button",
      );

      // Click again on the clear sort history icon button
      await tester
          .tap(find.byKey(const Key('search_history_delete_all_button')));
      await tester.pumpAndSettle();

      // Verify that the confirm action dialog is displayed
      // with the expected text
      expect(find.text('Clear sort/filter parameters history'), findsOneWidget);
      expect(find.text('Deleting all historical sort/filter parameters.'),
          findsOneWidget);

      // Click on the confirm button to execute deletion
      await tester.tap(find.byKey(const Key('confirmButtonKey')));
      await tester.pumpAndSettle();

      // Verify that the left sort history icon button is now disabled
      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: "search_history_arrow_left_button",
      );

      // Verify that the right sort history icon button is still disabled
      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: "search_history_arrow_right_button",
      );

      // Verify that the clear sort history icon button is now disabled
      TestUtility.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: "search_history_delete_all_button",
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
  });
  group('App settings test', () {
    testWidgets(
        'Bug fix: open app settings dialog and save it without modification.',
        (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}app_settings_set_play_speed",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      final String initialSettingsJsonStr = File(
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName")
          .readAsStringSync();

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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the appbar leading popup menu button
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // Now open the app settings dialog
      await tester.tap(find.byKey(const Key('appBarMenuOpenSettingsDialog')));
      await tester.pumpAndSettle();

      // And tap on save button
      await tester.tap(find.byKey(const Key('saveButton')));
      await tester.pumpAndSettle();

      // Ensure settings json file has not been modified
      expect(
        initialSettingsJsonStr,
        File("$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName")
            .readAsStringSync(),
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
  });
  group('App settings set speed test', () {});
  group('Rename audio file test and verify comment access', () {
    testWidgets('Not existing new name', (WidgetTester tester) async {
      const String youtubePlaylistTitle =
          'audio_player_view_2_shorts_test'; // Youtube playlist
      const String audioTitle = "morning _ cinematic video";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: '2_youtube_2_local_playlists_integr_test_data',
        selectedPlaylistTitle: youtubePlaylistTitle,
      );

      // Before renaming the audio file, we verify that the audio has
      // a comment

      // First, find the audio sublist ListTile Text widget

      Finder audioListTileTextWidgetFinder = find.text(audioTitle);

      // Then obtain the audio ListTile widget enclosing the Text widget
      // by finding its ancestor
      Finder audioListTileWidgetFinder = find.ancestor(
        of: audioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // The audio file we will rename has a comment linked to this
      // file name. Once this file is renamed, the comment will no
      // longer be accessible. Before renaming the file, verify
      // the comment exist ...
      await checkAudioCommentUsingAudioItemMenu(
        tester: tester,
        audioListTileWidgetFinder: audioListTileWidgetFinder,
        expectedCommentTitle: 'Not accessible later',
      );

      // Now we want to tap the popup menu of the audio ListTile
      // "morning _ cinematic video"

      // Find the leading menu icon button of the audio ListTile
      // and tap on it
      final Finder audioListTileLeadingMenuIconButton = find.descendant(
        of: audioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(audioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the rename audio file popup menu item and tap on it
      final Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_rename_audio_file"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Verify that the rename audio file dialog is displayed
      expect(find.byType(AudioModificationDialogWidget), findsOneWidget);

      // Verify the dialog comment
      expect(
          find.text(
              'Renaming audio file in order to improve their playing order.'),
          findsOneWidget);

      // Verify the button text
      final Finder audioModificationButtonFinder =
          find.byKey(const Key('audioModificationButton'));
      TextButton audioModificationTextButton =
          tester.widget<TextButton>(audioModificationButtonFinder);
      expect((audioModificationTextButton.child! as Text).data, 'Rename');

      // Verify the dialog title
      expect(find.text('Rename Audio File'), findsOneWidget);

      // Now enter the new file name

      // Find the TextField using the Key
      final Finder textFieldFinder =
          find.byKey(const Key('audioModificationTextField'));

      // Retrieve the TextField widget
      final TextField textField = tester.widget<TextField>(textFieldFinder);

      // Verify the initial value of the TextField
      expect(textField.controller!.text,
          '231117-002828-morning _ cinematic video 23-07-01.mp3');

      const String newFileName = '240610-Renamed video 23-07-01.mp3';
      await tester.enterText(
        textFieldFinder,
        newFileName,
      );

      await tester.pumpAndSettle();

      // Now tap the rename button
      await tester.tap(find.byKey(const Key('audioModificationButton')));
      await tester.pumpAndSettle();

      // Verify that the renamed file exists
      final String renamedAudioFilePath =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubePlaylistTitle${path.separator}$newFileName";
      expect(File(renamedAudioFilePath).existsSync(), true);

      // Check the new file name in the audio info dialog

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(audioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the popup menu item and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_display_audio_info"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Verify the audio new file name

      final Text audioFileNameTitleTextWidget =
          tester.widget<Text>(find.byKey(const Key('audioFileNameKey')));

      expect(audioFileNameTitleTextWidget.data, newFileName);

      // Tap the Ok button to close the audio info dialog
      await tester.tap(find.byKey(const Key('audioInfoOkButtonKey')));
      await tester.pumpAndSettle();

      // The renamed audio can now access to a comment defined for the
      // new audio file name (this is a test situation !). Now we verify
      // that this comment is accessible as well as that the old comment
      // is no longer accessible
      await checkAudioCommentInAudioPlayerView(
        tester: tester,
        audioListTileWidgetFinder: audioListTileWidgetFinder,
        expectedCommentTitle: 'Comment for the renamed audio file',
        notAccessibleCommentTitle: 'Not accessible later',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
    testWidgets(
        'Existing new name. The new file name is the name of an existing file in the same directory',
        (WidgetTester tester) async {
      const String youtubePlaylistTitle =
          'audio_player_view_2_shorts_test'; // Youtube playlist
      const String audioTitle = "morning _ cinematic video";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: '2_youtube_2_local_playlists_integr_test_data',
        selectedPlaylistTitle: youtubePlaylistTitle,
      );

      // Before renaming the audio file, we verify that the audio has
      // a comment

      // First, find the audio sublist ListTile Text widget

      Finder audioListTileTextWidgetFinder = find.text(audioTitle);

      // Then obtain the audio ListTile widget enclosing the Text widget
      // by finding its ancestor
      Finder audioListTileWidgetFinder = find.ancestor(
        of: audioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now we want to tap the popup menu of the audio ListTile
      // "morning _ cinematic video"

      // Find the leading menu icon button of the audio ListTile
      // and tap on it
      final Finder audioListTileLeadingMenuIconButton = find.descendant(
        of: audioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(audioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the rename audio file popup menu item and tap on it
      final Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_rename_audio_file"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Verify that the rename audio file dialog is displayed
      expect(find.byType(AudioModificationDialogWidget), findsOneWidget);

      // Verify the dialog title
      expect(find.text('Rename Audio File'), findsOneWidget);

      // Now enter the new file name

      // Find the TextField using the Key
      final Finder textFieldFinder =
          find.byKey(const Key('audioModificationTextField'));

      // Retrieve the TextField widget
      final TextField textField = tester.widget<TextField>(textFieldFinder);

      // Verify the initial value of the TextField
      const String initialFileName =
          '231117-002828-morning _ cinematic video 23-07-01.mp3';
      expect(textField.controller!.text, initialFileName);

      const String fileNameOfExistingFile =
          '231117-002826-Really short video 23-07-01.mp3';
      await tester.enterText(
        textFieldFinder,
        fileNameOfExistingFile,
      );

      await tester.pumpAndSettle();

      // Now tap the rename button
      await tester.tap(find.byKey(const Key('audioModificationButton')));
      await tester.pumpAndSettle();

      // Since file name is the name of an existing file in the audio
      // directory, a warning will be displayed ...

      // Ensure the warning dialog is shown
      final Finder warningMessageDisplayDialogFinder =
          find.byType(WarningMessageDisplayWidget);
      expect(warningMessageDisplayDialogFinder, findsOneWidget);

      // Check the value of the warning dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'WARNING');

      // Check the value of the warning dialog message
      expect(
          tester
              .widget<Text>(find.byKey(const Key('warningDialogMessage')))
              .data,
          "The file name \"$fileNameOfExistingFile\" already exists in the same directory and cannot be used.");

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Verify that the old name file exists
      final String renamedAudioFilePath =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubePlaylistTitle${path.separator}$initialFileName";
      expect(File(renamedAudioFilePath).existsSync(), true);

      // Check the old file name in the audio info dialog

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(audioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the popup menu item and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_display_audio_info"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Verify the audio new file name

      final Text audioFileNameTitleTextWidget =
          tester.widget<Text>(find.byKey(const Key('audioFileNameKey')));

      expect(audioFileNameTitleTextWidget.data, initialFileName);

      // Tap the Ok button to close the audio info dialog
      await tester.tap(find.byKey(const Key('audioInfoOkButtonKey')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
  });
  group('Modify audio title test and verify comment display change', () {
    testWidgets('Change audio title', (WidgetTester tester) async {
      const String youtubePlaylistTitle =
          'audio_player_view_2_shorts_test'; // Youtube playlist
      const String audioTitle = "morning _ cinematic video";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: '2_youtube_2_local_playlists_integr_test_data',
        selectedPlaylistTitle: youtubePlaylistTitle,
      );

      // First, find the audio sublist ListTile Text widget
      Finder audioListTileTextWidgetFinder = find.text(audioTitle);

      // Then obtain the audio ListTile widget enclosing the Text widget
      // by finding its ancestor
      Finder audioListTileWidgetFinder = find.ancestor(
        of: audioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now we want to tap the popup menu of the audio ListTile
      // "morning _ cinematic video"

      // Find the leading menu icon button of the audio ListTile
      // and tap on it
      Finder audioListTileLeadingMenuIconButton = find.descendant(
        of: audioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(audioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the modify audio title popup menu item and tap on
      // it
      final Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_modify_audio_title"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Verify that the rename audio file dialog is displayed
      expect(find.byType(AudioModificationDialogWidget), findsOneWidget);

      // Verify the dialog title
      expect(find.text('Modify Audio Title'), findsOneWidget);

      // Verify the dialog comment
      expect(
          find.text(
              'Modify the audio title to identify it more easily during listening.'),
          findsOneWidget);

      // Verify the button text

      final Finder audioModificationButtonFinder =
          find.byKey(const Key('audioModificationButton'));
      TextButton audioModificationTextButton =
          tester.widget<TextButton>(audioModificationButtonFinder);
      expect((audioModificationTextButton.child! as Text).data, 'Modify');

      // Now enter the new title

      // Find the TextField using the Key
      final Finder textFieldFinder =
          find.byKey(const Key('audioModificationTextField'));

      // Retrieve the TextField widget
      final TextField textField = tester.widget<TextField>(textFieldFinder);

      // Verify the initial value of the TextField
      expect(textField.controller!.text, 'morning _ cinematic video');

      const String newTitle = 'Morning cinematic video';
      await tester.enterText(
        textFieldFinder,
        newTitle,
      );

      await tester.pumpAndSettle();

      // Now tap the Modify button
      await tester.tap(audioModificationButtonFinder);
      await tester.pumpAndSettle();

      // Check the modified audio title in the audio info dialog

      // First, find the audio sublist ListTile Text widget
      // using the new title
      audioListTileTextWidgetFinder = find.text(newTitle);

      // Then obtain the audio ListTile widget enclosing the Text widget
      // by finding its ancestor
      audioListTileWidgetFinder = find.ancestor(
        of: audioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Find the leading menu icon button of the audio ListTile
      // and tap on it

      audioListTileLeadingMenuIconButton = find.descendant(
        of: audioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );
      await tester.tap(audioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle(); // Wait for popup menu to appear

      // Now find the popup menu item and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_display_audio_info"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Verify the audio new title

      final Text audioTitleTextWidget =
          tester.widget<Text>(find.byKey(const Key('validVideoTitleKey')));

      expect(audioTitleTextWidget.data, newTitle);

      // Tap the Ok button to close the audio info dialog
      await tester.tap(find.byKey(const Key('audioInfoOkButtonKey')));
      await tester.pumpAndSettle();

      // Verifying that the comment of the audio displays the modified audio title
      await checkAudioCommentUsingAudioItemMenu(
        tester: tester,
        audioListTileWidgetFinder: audioListTileWidgetFinder,
        expectedCommentTitle: 'Not accessible later',
        audioTitleToVerifyInCommentAddEditDialog: newTitle,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true);
    });
  });
}

Future<void> checkWarningDialog({
  required WidgetTester tester,
  required String playlistTitle,
  required bool isMusicQuality,
}) async {
  // Ensure the warning dialog is shown
  expect(find.byType(WarningMessageDisplayWidget), findsOneWidget);

  // Check the value of the warning dialog title
  Text warningDialogTitle =
      tester.widget(find.byKey(const Key('warningDialogTitle')));
  expect(warningDialogTitle.data, 'WARNING');

  // Check the value of the warning dialog message
  Text warningDialogMessage =
      tester.widget(find.byKey(const Key('warningDialogMessage')));

  expect(warningDialogMessage.data,
      'Playlist "$playlistTitle" of ${isMusicQuality ? 'music' : 'audio'} quality added at end of list of playlists.');

  // Close the warning dialog by tapping on the Ok button
  await tester.tap(find.byKey(const Key('warningDialogOkButton')));
  await tester.pumpAndSettle();
}

Future<void> checkAudioCommentInAudioPlayerView({
  required WidgetTester tester,
  required Finder audioListTileWidgetFinder,
  required String expectedCommentTitle,
  String? notAccessibleCommentTitle,
}) async {
  // Tap on the ListTile to open the audio player view on the
  // passed audio finder
  await tester.tap(audioListTileWidgetFinder);
  await tester.pumpAndSettle();

  // Tap on the comment icon button to open the comment add list
  // dialog
  final Finder commentInkWellButtonFinder = find.byKey(
    const Key('commentsInkWellButton'),
  );

  await tester.tap(commentInkWellButtonFinder);
  await tester.pumpAndSettle();

  // Verify that the expectedCommentTitle is listed

  Finder commentListDialogFinder = find.byType(CommentListAddDialogWidget);

  expect(
      find.descendant(
          of: commentListDialogFinder,
          matching: find.text(expectedCommentTitle)),
      findsOneWidget);

  // If the notAccessibleCommentTitle is not null, verify that it is
  // not listed
  if (notAccessibleCommentTitle != null) {
    expect(
        find.descendant(
            of: commentListDialogFinder,
            matching: find.text(notAccessibleCommentTitle)),
        findsNothing);
  }

  // Close the comment list dialog
  await tester.tap(find.byKey(const Key('closeDialogTextButton')));
  await tester.pumpAndSettle();

  // Tap on the playlist download view button to return to the
  // playlist download view
  final playlistDownloadViewNavButton =
      find.byKey(const ValueKey('playlistDownloadViewIconButton'));
  await tester.tap(playlistDownloadViewNavButton);
  await tester.pumpAndSettle();
}

Future<void> checkAudioCommentUsingAudioItemMenu({
  required WidgetTester tester,
  required Finder audioListTileWidgetFinder,
  required String expectedCommentTitle,
  String? notAccessibleCommentTitle,
  String? audioTitleToVerifyInCommentAddEditDialog,
}) async {
  // Find the leading menu icon button of the audio ListTile
  // and tap on it
  final Finder audioListTileLeadingMenuIconButton = find.descendant(
    of: audioListTileWidgetFinder,
    matching: find.byIcon(Icons.menu),
  );

  // Tap the leading menu icon button to open the popup menu
  await tester.tap(audioListTileLeadingMenuIconButton);
  await tester.pumpAndSettle(); // Wait for popup menu to appear

  // Now find the audio comments popup menu item and tap on it
  final Finder popupCopyMenuItem =
      find.byKey(const Key("popup_menu_audio_comment"));

  await tester.tap(popupCopyMenuItem);
  await tester.pumpAndSettle();

  // Verify that the comment list is displayed
  expect(find.byType(CommentListAddDialogWidget), findsOneWidget);

  // Verify that the expectedCommentTitle is listed

  Finder commentListDialogFinder = find.byType(CommentListAddDialogWidget);

  expect(
      find.descendant(
          of: commentListDialogFinder,
          matching: find.text(expectedCommentTitle)),
      findsOneWidget);

  // If the notAccessibleCommentTitle is not null, verify that it is
  // not listed
  if (notAccessibleCommentTitle != null) {
    expect(
        find.descendant(
            of: commentListDialogFinder,
            matching: find.text(notAccessibleCommentTitle)),
        findsNothing);
  }

  if (audioTitleToVerifyInCommentAddEditDialog != null) {
    // Tap on the comment title to open the comment add/edit dialog
    await tester.tap(find.text(expectedCommentTitle));
    await tester.pumpAndSettle();

    final Finder commentAddEditDialogFinder =
        find.byType(CommentAddEditDialogWidget);

    // Verify audio title displayed in the comment add/edit dialog
    expect(
      find.descendant(
          of: commentAddEditDialogFinder,
          matching: find.text(audioTitleToVerifyInCommentAddEditDialog)),
      findsOneWidget,
    );

    // Tap on the cancel button to close the comment add/edit dialog
    await tester.tap(find.byKey(const Key('cancelTextButton')));
    await tester.pumpAndSettle();
  }

  // Close the comment list dialog
  await tester.tap(find.byKey(const Key('closeDialogTextButton')));
  await tester.pumpAndSettle();
}

void verifyAudioMenuItemsState({
  required WidgetTester tester,
  required bool areAudioMenuItemsDisabled,
}) {
  if (areAudioMenuItemsDisabled) {
    TestUtility.verifyWidgetIsEnabled(
      tester: tester,
      widgetKeyStr: 'define_sort_and_filter_audio_settings_dialog_item',
    );

    TestUtility.verifyWidgetIsDisabled(
      // no Sort/filter parameters history are available in test data
      tester: tester,
      widgetKeyStr: 'clear_sort_and_filter_audio_options_history_menu_item',
    );

    TestUtility.verifyWidgetIsEnabled(
      tester: tester,
      widgetKeyStr: 'save_sort_and_filter_audio_settings_in_playlist_item',
    );
  } else {
    TestUtility.verifyWidgetIsEnabled(
      tester: tester,
      widgetKeyStr: 'define_sort_and_filter_audio_settings_dialog_item',
    );

    TestUtility.verifyWidgetIsDisabled(
      // no Sort/filter parameters history are available in test data
      tester: tester,
      widgetKeyStr: 'clear_sort_and_filter_audio_options_history_menu_item',
    );

    TestUtility.verifyWidgetIsEnabled(
      tester: tester,
      widgetKeyStr: 'save_sort_and_filter_audio_settings_in_playlist_item',
    );
  }

  TestUtility.verifyWidgetIsEnabled(
    tester: tester,
    widgetKeyStr: 'update_playlist_json_dialog_item',
  );
}

Future<void> ensureNoButtonIsEnabledSinceNoPlaylistIsSelected(
    WidgetTester tester) async {
  TestUtility.verifyWidgetIsDisabled(
    tester: tester,
    widgetKeyStr: 'move_up_playlist_button',
  );

  TestUtility.verifyWidgetIsDisabled(
    tester: tester,
    widgetKeyStr: 'move_down_playlist_button',
  );

  TestUtility.verifyWidgetIsDisabled(
    tester: tester,
    widgetKeyStr: 'download_sel_playlists_button',
  );

  TestUtility.verifyWidgetIsDisabled(
    tester: tester,
    widgetKeyStr: 'audio_quality_checkbox',
  );

  // This menu button is always enabled since the Update playlist json file
  // menu item must be always accessible
  TestUtility.verifyWidgetIsEnabled(
    tester: tester,
    widgetKeyStr: 'audio_popup_menu_button',
  );

  // Now open the audio popup menu
  await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
  await tester.pumpAndSettle();

  // since the selected local playlist has no audios, the
  // audio menu items are disabled
  verifyAudioMenuItemsState(
    tester: tester,
    areAudioMenuItemsDisabled: true,
  );
}

Future<void> tapPlaylistCheckboxIfNotAlreadyChecked({
  required Finder playlistListTileWidgetFinder,
  required WidgetTester widgetTester,
}) async {
  final Finder youtubePlaylistListTileCheckboxWidgetFinder = find.descendant(
    of: playlistListTileWidgetFinder,
    matching: find.byType(Checkbox),
  );

  // Retrieve the Checkbox widget
  final Checkbox checkbox = widgetTester
      .widget<Checkbox>(youtubePlaylistListTileCheckboxWidgetFinder);

  // Check if the checkbox is checked
  if (checkbox.value == null || !checkbox.value!) {
    // Tap the ListTile Playlist checkbox to select it
    // so that the playlist audios are listed
    await widgetTester.tap(youtubePlaylistListTileCheckboxWidgetFinder);
    await widgetTester.pumpAndSettle();
  }
}

Future<void> _launchExpandablePlaylistListView({
  required tester,
  required AudioDownloadVM audioDownloadVM,
  required SettingsDataService settingsDataService,
  required PlaylistListVM expandablePlaylistListVM,
  required WarningMessageVM warningMessageVM,
  required AudioPlayerVM audioPlayerVM,
}) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => audioDownloadVM),
        ChangeNotifierProvider(
            create: (_) => ThemeProviderVM(
                  appSettings: settingsDataService,
                )),
        ChangeNotifierProvider(
            create: (_) => LanguageProviderVM(
                  appSettings: settingsDataService,
                )),
        ChangeNotifierProvider(create: (_) => expandablePlaylistListVM),
        ChangeNotifierProvider(create: (_) => warningMessageVM),
        ChangeNotifierProvider(create: (_) => audioPlayerVM),
      ],
      child: MaterialApp(
        // forcing dark theme
        theme: ScreenMixin.themeDataDark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: PlaylistDownloadView(
            settingsDataService: settingsDataService,
            onPageChangedFunction: changePage,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> findThenSelectAndTestListTileCheckbox({
  required WidgetTester tester,
  required String itemTextStr,
}) async {
  Finder listItemTileFinder = find.widgetWithText(ListTile, itemTextStr);

  // Find the Checkbox widget inside the ListTile
  Finder checkboxFinder = find.descendant(
    of: listItemTileFinder,
    matching: find.byType(Checkbox),
  );

  // Assert that the checkbox is not selected
  expect(tester.widget<Checkbox>(checkboxFinder).value, false);

  // now tap the item checkbox
  await tester.tap(find.descendant(
    of: listItemTileFinder,
    matching: find.byWidgetPredicate((widget) => widget is Checkbox),
  ));
  await tester.pump();

  // Find the Checkbox widget inside the ListTile

  listItemTileFinder = find.widgetWithText(ListTile, itemTextStr);

  checkboxFinder = find.descendant(
    of: listItemTileFinder,
    matching: find.byType(Checkbox),
  );

  expect(tester.widget<Checkbox>(checkboxFinder).value, true);
}

void changePage(int index) {
  onPageChanged(index);
  // _pageController.animateToPage(
  //   index,
  //   duration: pageTransitionDuration, // Use constant
  //   curve: pageTransitionCurve, // Use constant
  // );
}

void onPageChanged(int index) {
  // setState(() {
  //   _currentIndex = index;
  // });
}

/// Verifies the elements of the audio info dialog.
///
/// {tester} is the WidgetTester
///
/// {audioTitle} is the title of the audio the method verifies
/// the elements of the audio info dialog
///
/// {playlistEnclosingAudioTitle} is the title of the playlist
/// enclosing the audio
///
/// {copiedAudioSourcePlaylistTitle} is the title of the playlist
/// from which the audio was copied
///
/// {copiedAudioTargetPlaylistTitle} is the title of the playlist
/// to which the audio was copied
///
/// {movedAudioSourcePlaylistTitle} is the title of the playlist
/// from which the audio was moved
///
/// {movedAudioTargetPlaylistTitle} is the title of the playlist
/// to which the audio was moved
Future<void> verifyAudioInfoDialogElements({
  required WidgetTester tester,
  required String audioTitle,
  required String playlistEnclosingAudioTitle,
  required String copiedAudioSourcePlaylistTitle,
  required String copiedAudioTargetPlaylistTitle,
  required String movedAudioSourcePlaylistTitle,
  required String movedAudioTargetPlaylistTitle,
}) async {
  // Find the target ListTile Playlist containing the audio copied
  // from the source playlist

  // First, find the Playlist ListTile Text widget
  final Finder targetPlaylistListTileTextWidgetFinder =
      find.text(playlistEnclosingAudioTitle);

  // Then obtain the Playlist ListTile widget enclosing the Text widget
  // by finding its ancestor
  final Finder targetPlaylistListTileWidgetFinder = find.ancestor(
    of: targetPlaylistListTileTextWidgetFinder,
    matching: find.byType(ListTile),
  );

  // Now find the Checkbox widget located in the Playlist ListTile
  // and tap on it to select the playlist
  final Finder targetPlaylistListTileCheckboxWidgetFinder = find.descendant(
    of: targetPlaylistListTileWidgetFinder,
    matching: find.byType(Checkbox),
  );

  final checkboxWidget =
      tester.widget<Checkbox>(targetPlaylistListTileCheckboxWidgetFinder);

  if (!checkboxWidget.value!) {
    await tester.tap(targetPlaylistListTileCheckboxWidgetFinder);
    await tester.pumpAndSettle();
  }

  // Now we want to tap the popup menu of the Audio ListTile
  // "audio learn test short video one"

  // First, find the Audio sublist ListTile Text widget
  final Finder targetAudioListTileTextWidgetFinder = find.text(audioTitle);

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
  await tester.pumpAndSettle(); // Wait for popup menu to appear

  // Now find the popup menu item and tap on it
  Finder popupDisplayAudioInfoMenuItemFinder =
      find.byKey(const Key("popup_menu_display_audio_info"));

  await tester.tap(popupDisplayAudioInfoMenuItemFinder);
  await tester.pumpAndSettle();

  // Now verifying the display audio info audio copied dialog
  // elements

  // Verify the enclosing playlist title of the copied audio

  Text enclosingPlaylistTitleTextWidget =
      tester.widget<Text>(find.byKey(const Key('enclosingPlaylistTitleKey')));

  expect(enclosingPlaylistTitleTextWidget.data, playlistEnclosingAudioTitle);

  // Verify the copied from playlist title of the copied audio

  Text copiedFromPlaylistTitleTextWidget =
      tester.widget<Text>(find.byKey(const Key('copiedFromPlaylistTitleKey')));

  expect(
      copiedFromPlaylistTitleTextWidget.data, copiedAudioSourcePlaylistTitle);

  // Verify the copied to playlist title of the copied audio

  Text copiedToPlaylistTitleTextWidget =
      tester.widget<Text>(find.byKey(const Key('copiedToPlaylistTitleKey')));

  expect(copiedToPlaylistTitleTextWidget.data, copiedAudioTargetPlaylistTitle);

  // Verify the moved from playlist title of the copied audio

  Text movedFromPlaylistTitleTextWidget =
      tester.widget<Text>(find.byKey(const Key('movedFromPlaylistTitleKey')));

  expect(movedFromPlaylistTitleTextWidget.data, movedAudioSourcePlaylistTitle);

  // Verify the moved to playlist title of the copied audio

  Text movedToPlaylistTitleTextWidget =
      tester.widget<Text>(find.byKey(const Key('movedToPlaylistTitleKey')));

  expect(movedToPlaylistTitleTextWidget.data, movedAudioTargetPlaylistTitle);

  // Now find the ok button of the audio info dialog
  // and tap on it
  await tester.tap(find.byKey(const Key('audioInfoOkButtonKey')));
  await tester.pumpAndSettle();
}

import 'dart:convert';
import 'dart:io';

import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/viewmodels/comment_vm.dart';
import 'package:audiolearn/viewmodels/date_format_vm.dart';
import 'package:audiolearn/views/widgets/confirm_action_dialog.dart';
import 'package:audiolearn/views/widgets/audio_modification_dialog.dart';
import 'package:audiolearn/views/widgets/comment_add_edit_dialog.dart';
import 'package:audiolearn/views/widgets/comment_list_add_dialog.dart';
import 'package:audiolearn/views/widgets/playlist_comment_list_dialog.dart';
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
import 'package:audiolearn/views/widgets/warning_message_display.dart';
import 'package:audiolearn/views/widgets/playlist_list_item.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:audiolearn/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

import '../test/viewmodels/custom_mock_youtube_explode.dart';
import '../test/viewmodels/mock_audio_download_vm.dart';
import 'integration_test_util.dart';
import 'sort_filter_integration_test.dart';

void main() {
  // Necessary to avoid FatalFailureException (FatalFailureException: Failed
  // to perform an HTTP request to YouTube due to a fatal failure. In most
  // cases, this error indicates that YouTube most likely changed something,
  // which broke the library.
  // If this issue persists, please report it on the project's GitHub page.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  playlistDownloadViewSortFilterIntegrationTest();
  playlistOneDownloadViewIntegrationTest();
}

void playlistOneDownloadViewIntegrationTest() {
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

  group('Add or delete Youtube or local Playlist tests', () {
    testWidgets('Youtube playlist audio quality addition and then delete it ',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      // setting default playlist audio play speed to 1.25
      settingsDataService.set(
          settingType: SettingType.playlists,
          settingSubType: Playlists.playSpeed,
          value: 1.25);

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
      PlaylistListVM playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: playlistListVM,
        commentVM: CommentVM(),
      );

      DateFormatVM dateFormatVM = DateFormatVM(
        settingsDataService: settingsDataService,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        playlistListVM: playlistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
        dateFormatVM: dateFormatVM,
      );

      // Tap the 'Toggle List' button to display the playlist list. If the list
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
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        youtubePlaylistUrl,
      );
      await tester.pumpAndSettle();

      // Ensure the url text field contains the entered url
      TextField urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
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
        isMusicQuality: false,
        playlistType: PlaylistType.youtube,
      );

      // Ensure the URL TextField was emptied
      urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
      expect(urlTextField.controller!.text, '');

      // The list of Playlist's should have one item now
      expect(find.byType(ListTile), findsOneWidget);

      // Check if the added item is displayed correctly
      final PlaylistListItem playlistListItemWidget =
          tester.widget(find.byType(PlaylistListItem).first);
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
      expect(loadedNewPlaylist.audioPlaySpeed, 1.25);
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
      await tester.pumpAndSettle();

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget = tester
          .widget<Text>(find.byKey(const Key('confirmDialogTitleOneKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Delete Youtube Playlist "$youtubeNewPlaylistTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
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
      );
    });
    testWidgets('Add with comma titled Youtube playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      // setting default playlist audio play speed to 1.25
      settingsDataService.set(
          settingType: SettingType.playlists,
          settingSubType: Playlists.playSpeed,
          value: 1.25);

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
      PlaylistListVM playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: playlistListVM,
        commentVM: CommentVM(),
      );

      DateFormatVM dateFormatVM = DateFormatVM(
        settingsDataService: settingsDataService,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        playlistListVM: playlistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
        dateFormatVM: dateFormatVM,
      );

      // Tap the 'Toggle List' button to display the playlist list. If the list
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
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        youtubePlaylistUrl,
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Ensure the url text field contains the entered url
      TextField urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
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
      expect(find.byType(WarningMessageDisplayDialog), findsOneWidget);

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
      urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
      expect(urlTextField.controller!.text, youtubePlaylistUrl);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Youtube playlist music quality addition and then add it again with same
           URL''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      // setting default playlist audio play speed to 1.25
      settingsDataService.set(
          settingType: SettingType.playlists,
          settingSubType: Playlists.playSpeed,
          value: 1.25);

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: "temp\\wrong.json");

      // setting default playlist audio play speed to 1.25
      settingsDataService.set(
          settingType: SettingType.playlists,
          settingSubType: Playlists.playSpeed,
          value: 1.25);

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
      PlaylistListVM playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: playlistListVM,
        commentVM: CommentVM(),
      );

      DateFormatVM dateFormatVM = DateFormatVM(
        settingsDataService: settingsDataService,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        playlistListVM: playlistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
        dateFormatVM: dateFormatVM,
      );

      // Tap the 'Toggle List' button to display the playlist list. If the list
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
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        youtubePlaylistUrl,
      );

      // Ensure the url text field contains the entered url
      TextField urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
      expect(urlTextField.controller!.text, youtubePlaylistUrl);

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Set the quality to music
      await tester
          .tap(find.byKey(const Key('playlistQualityConfirmDialogCheckBox')));
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

      await checkWarningDialog(
        tester: tester,
        playlistTitle: youtubeNewPlaylistTitle,
        isMusicQuality: true,
        playlistType: PlaylistType.youtube,
      );

      // Ensure the URL TextField was emptied
      urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
      expect(urlTextField.controller!.text, '');

      // Check the saved Youtube playlist values in the json file

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
      expect(loadedNewPlaylist.playlistQuality, PlaylistQuality.music);
      expect(loadedNewPlaylist.audioPlaySpeed, 1.0);
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
      //   find.byKey(const Key('youtubeUrlOrSearchTextField'),),
      //   youtubePlaylistUrl,
      // );

      // Solving this problem
      tester
          .widget<TextField>(find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ))
          .controller!
          .text = youtubePlaylistUrl;

      await tester.pumpAndSettle();

      // Ensure the url text field contains the entered url
      urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
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
      expect(find.byType(WarningMessageDisplayDialog), findsOneWidget);

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
      urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
      expect(urlTextField.controller!.text, youtubePlaylistUrl);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });

    /// The objective of this integration test is to ensure that
    /// the url text field will not be emptied after clicking on
    /// the Cancel button of the add playlist dialog.
    testWidgets(
        '''Open the add playlist dialog to add a Youtube playlist and then
           click on Cancel button''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      // setting default playlist audio play speed to 1.25
      settingsDataService.set(
          settingType: SettingType.playlists,
          settingSubType: Playlists.playSpeed,
          value: 1.25);

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
      PlaylistListVM playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: playlistListVM,
        commentVM: CommentVM(),
      );

      DateFormatVM dateFormatVM = DateFormatVM(
        settingsDataService: settingsDataService,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        playlistListVM: playlistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
        dateFormatVM: dateFormatVM,
      );

      // Tap the 'Toggle List' button to display the playlist list. If the list
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
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        youtubePlaylistUrl,
      );

      // Ensure the url text field contains the entered url
      TextField urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
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
      urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
      expect(urlTextField.controller!.text, youtubePlaylistUrl);

      // The list of Playlist's should have 0 item
      expect(find.byType(ListTile), findsNothing);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Local playlist music quality addition with empty playlist URL''',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String localPlaylistTitle = 'audio_learn_local_playlist_test';

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to display the playlist list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list and audio list should exist now but be
      // empty (no ListTile widgets)
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);

      // Tap the 'Toggle List' button to hide the playlist list. Since
      // when adding a playlist, the list is expanded, we need to hide it
      // in order to ensure the list will be displayed.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

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
        playlistType: PlaylistType.local,
      );

      // The list of Playlist's should have one item now
      expect(find.byType(ListTile), findsOneWidget);

      // Check if the added item is displayed correctly
      final PlaylistListItem playlistListItemWidget =
          tester.widget(find.byType(PlaylistListItem).first);
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
      expect(loadedNewPlaylist.audioPlaySpeed, 1.0);
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
      await tester.pumpAndSettle();

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget = tester
          .widget<Text>(find.byKey(const Key('confirmDialogTitleOneKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Delete Local Playlist "$localPlaylistTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
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
      );
    });
    testWidgets(
        '''Local playlist audio quality addition with empty playlist URL and then
           delete local playlist''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String localPlaylistTitle = 'audio_learn_local_playlist_test';

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
        isTest: true,
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kDownloadAppTestSavedDataDir${path.separator}settings.json");

      // setting default playlist audio play speed to 1.25 instead of 1.0
      settingsDataService.set(
          settingType: SettingType.playlists,
          settingSubType: Playlists.playSpeed,
          value: 1.25);

      // saving the settings so that the app creation can access to them
      // as defined above
      settingsDataService.saveSettings();

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to display the playlist list. If the list
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

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is shown
      await checkWarningDialog(
        tester: tester,
        playlistTitle: localPlaylistTitle,
        isMusicQuality: false,
        playlistType: PlaylistType.local,
      );

      // The list of Playlist's should have one item now
      expect(find.byType(ListTile), findsOneWidget);

      // Check if the added item is displayed correctly
      final PlaylistListItem playlistListItemWidget =
          tester.widget(find.byType(PlaylistListItem).first);
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
      expect(loadedNewPlaylist.playlistQuality, PlaylistQuality.voice);
      expect(loadedNewPlaylist.audioPlaySpeed, 1.25);
      expect(loadedNewPlaylist.downloadedAudioLst.length, 0);
      expect(loadedNewPlaylist.playableAudioLst.length, 0);
      expect(loadedNewPlaylist.isSelected, false);
      expect(loadedNewPlaylist.downloadPath, newPlaylistPath);

      settingsDataService = SettingsDataService(
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
      await tester.pumpAndSettle();

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget = tester
          .widget<Text>(find.byKey(const Key('confirmDialogTitleOneKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Delete Local Playlist "$localPlaylistTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
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
      );
    });
    testWidgets(
        '''Add local playlist with title equal to previously created local
           playlist''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String localPlaylistTitle = 'audio_learn_local_playlist_test';

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to display the playlist list. If the list
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
      final PlaylistListItem playlistListItemWidget =
          tester.widget(find.byType(PlaylistListItem).first);
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
      expect(find.byType(WarningMessageDisplayDialog), findsOneWidget);

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
      );
    });
    testWidgets('Add local playlist with invalid title containing a comma',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String invalidLocalPlaylistTitle = 'local, with comma';

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to display the playlist list. If the list
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
      expect(find.byType(WarningMessageDisplayDialog), findsOneWidget);

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
        playlistType: PlaylistType.local,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Add local playlist with title equal to previously created Youtube
           playlist''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      // setting default playlist audio play speed to 1.25
      settingsDataService.set(
          settingType: SettingType.playlists,
          settingSubType: Playlists.playSpeed,
          value: 1.25);

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
      PlaylistListVM playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: playlistListVM,
        commentVM: CommentVM(),
      );

      DateFormatVM dateFormatVM = DateFormatVM(
        settingsDataService: settingsDataService,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        playlistListVM: playlistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
        dateFormatVM: dateFormatVM,
      );

      // Tap the 'Toggle List' button to display the playlist list. If the list
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
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
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
      expect(find.byType(WarningMessageDisplayDialog), findsOneWidget);

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
      );
    });
    testWidgets('''Open the add playlist dialog to add a local playlist and then
           click on Cancel button''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String localPlaylistTitle = 'audio_learn_local_playlist_test';

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to display the playlist list. If the list
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
      );
    });
    testWidgets('''Add Youtube and local playlist, download the Youtube playlist
           and restart the app''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      // setting default playlist audio play speed to 1.25
      settingsDataService.set(
          settingType: SettingType.playlists,
          settingSubType: Playlists.playSpeed,
          value: 1.25);

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
      PlaylistListVM playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: playlistListVM,
        commentVM: CommentVM(),
      );

      DateFormatVM dateFormatVM = DateFormatVM(
        settingsDataService: settingsDataService,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        playlistListVM: playlistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
        dateFormatVM: dateFormatVM,
      );

      // Tap the 'Toggle List' button to display the playlist list. If the list
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
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
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
        playlistListVM: playlistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
        dateFormatVM: dateFormatVM,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('Add Youtube playlist with invalid URL containing list=',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      // setting default playlist audio play speed to 1.25
      settingsDataService.set(
          settingType: SettingType.playlists,
          settingSubType: Playlists.playSpeed,
          value: 1.25);

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
      PlaylistListVM playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: playlistListVM,
        commentVM: CommentVM(),
      );

      DateFormatVM dateFormatVM = DateFormatVM(
        settingsDataService: settingsDataService,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        playlistListVM: playlistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
        dateFormatVM: dateFormatVM,
      );

      // Tap the 'Toggle List' button to display the playlist list. If the list
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
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        invalidYoutubePlaylistUrl,
      );

      // Ensure the url text field contains the entered url
      TextField urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
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
      expect(find.byType(WarningMessageDisplayDialog), findsOneWidget);

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
      urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
      expect(urlTextField.controller!.text, invalidYoutubePlaylistUrl);

      // The list of Playlist's should have zero item now
      expect(find.byType(ListTile), findsNothing);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('Add Youtube playlist with invalid URL', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      // setting default playlist audio play speed to 1.25
      settingsDataService.set(
          settingType: SettingType.playlists,
          settingSubType: Playlists.playSpeed,
          value: 1.25);

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
      PlaylistListVM playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: playlistListVM,
        commentVM: CommentVM(),
      );

      DateFormatVM dateFormatVM = DateFormatVM(
        settingsDataService: settingsDataService,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        playlistListVM: playlistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
        dateFormatVM: dateFormatVM,
      );

      // Tap the 'Toggle List' button to display the playlist list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      const String invalidYoutubePlaylistUrl = 'invalid';

      // Enter the invalid Youtube playlist URL into the url text
      // field
      await tester.enterText(
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        invalidYoutubePlaylistUrl,
      );

      // Ensure the url text field contains the entered url
      TextField urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
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
      expect(find.byType(WarningMessageDisplayDialog), findsOneWidget);

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
      urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
      expect(urlTextField.controller!.text, invalidYoutubePlaylistUrl);

      // The list of Playlist's should have zero item now
      expect(find.byType(ListTile), findsNothing);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('''Add and download 2 Youtube playlists using audio download VM
                   mock version.''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}simulate_creating_and_downloading_youtube_playlist_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
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

      // setting default playlist audio play speed to 1.25
      settingsDataService.set(
          settingType: SettingType.playlists,
          settingSubType: Playlists.playSpeed,
          value: 1.25);

      WarningMessageVM warningMessageVM = WarningMessageVM();
      MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        mockPlaylistDirectory: kApplicationPathWindowsTest,
        isTest: true,
      );

      // using the mockAudioDownloadVM to add the playlist
      // because YoutubeExplode can not access to internet
      // in integration tests in order to download the playlist
      // and so obtain the playlist title
      PlaylistListVM playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: playlistListVM,
        commentVM: CommentVM(),
      );

      DateFormatVM dateFormatVM = DateFormatVM(
        settingsDataService: settingsDataService,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: mockAudioDownloadVM,
        settingsDataService: settingsDataService,
        playlistListVM: playlistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
        dateFormatVM: dateFormatVM,
      );

      // Tap the 'Toggle List' button to display the empty playlist list.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // The playlist list and audio list should exist now but be
      // empty (no ListTile widgets)
      expect(find.byType(ListView), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);

      // Enter the 'Essai' Youtube playlist URL into the url text field
      await tester.enterText(
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        'https://youtube.com/playlist?list=PLzwWSJNcZTMSMSrQ7LA0uSn91uZz47JOh&si=-c9fkDSormJfnB4k',
      );
      await tester.pumpAndSettle();

      // Setting fist Youtube playlist title
      mockAudioDownloadVM.youtubePlaylistTitle = 'Essai';

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Check the value of the Warning dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'WARNING');

      // Now verifying the warning dialog message
      Text warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));
      expect(warningDialogMessageTextWidget.data,
          'Youtube playlist "Essai" of audio quality added at end of list of playlists.');

      // Close the warning dialog by tapping on the Ok button.
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Tap the first ListTile checkbox to select it
      await tester.tap(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      await tester.pumpAndSettle();

      // Tap the 'Download All' button to download the selected playlist.
      // This download is simulated by the mock audio download VM
      await tester.tap(find.byKey(const Key('download_sel_playlists_button')));
      await tester.pumpAndSettle();

      // And verify the downloaded playlist audio titles

      List<String> essaiDownloadedAudioTitles = [
        "La Chine a créé l'ARME ULTIME  - Plus PUISSANTE que l'étoilenoire",
        "Les IA ont-elles vraiment atteint l'AGI  Analyse_ Johann Oriel",
      ];

      IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
        tester: tester,
        audioOrPlaylistTitlesOrderedLst: essaiDownloadedAudioTitles,
        firstAudioListTileIndex: 1,
      );

      // Enter the 'audio_player_view_2_shorts_test' Youtube playlist URL
      // into the url text field
      // Enter the new Youtube playlist URL into the url text field.
      // I don't know why, but the next commented code does not work.
      //
      // await tester.enterText(
      //   find.byKey(
      //     const Key('youtubeUrlOrSearchTextField'),
      //   ),
      //   'https://youtube.com/playlist?list=PLzwWSJNcZTMRrOkIdVTkV58wpWIZQCkgd&si=fBu5t1hVFDHThbwy',
      // );
      // await tester.pumpAndSettle(const Duration(milliseconds: 1000));
      //
      // Solving this problem
      tester
              .widget<TextField>(find.byKey(
                const Key('youtubeUrlOrSearchTextField'),
              ))
              .controller!
              .text =
          'https://youtube.com/playlist?list=PLzwWSJNcZTMRrOkIdVTkV58wpWIZQCkgd&si=fBu5t1hVFDHThbwy';
      await tester.pumpAndSettle();

      // Setting second Youtube playlist title
      mockAudioDownloadVM.youtubePlaylistTitle =
          'audio_player_view_2_shorts_test';

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Check the value of the Warning dialog title
      warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'WARNING');

      // Now verifying the warning dialog message
      warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));
      expect(warningDialogMessageTextWidget.data,
          'Youtube playlist "audio_player_view_2_shorts_test" of audio quality added at end of list of playlists.');

      // Close the warning dialog by tapping on the Ok button.
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Tap the second ListTile checkbox to select it
      await tester.tap(find.descendant(
        of: find.byType(ListTile).at(1),
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      await tester.pumpAndSettle();

      // Tap the 'Download All' button to download the selected playlist.
      // This download is simulated by the mock audio download VM
      await tester.tap(find.byKey(const Key('download_sel_playlists_button')));
      await tester.pumpAndSettle();

      // And verify the downloaded playlist audio titles

      List<String> audioPlayerView2ShortsTestDownloadedaudiotitles = [
        "morning _ cinematic video",
        "Really short video",
      ];

      IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
        tester: tester,
        audioOrPlaylistTitlesOrderedLst:
            audioPlayerView2ShortsTestDownloadedaudiotitles,
        firstAudioListTileIndex: 2,
      );

      // Tap the first ListTile checkbox to select it
      await tester.tap(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      await tester.pumpAndSettle();

      // And verify the downloaded playlist audio titles

      IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
        tester: tester,
        audioOrPlaylistTitlesOrderedLst: essaiDownloadedAudioTitles,
        firstAudioListTileIndex: 2,
      );

      // Tap the second ListTile checkbox to select it
      await tester.tap(find.descendant(
        of: find.byType(ListTile).at(1),
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      await tester.pumpAndSettle();

      // And verify the downloaded playlist audio titles

      IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
        tester: tester,
        audioOrPlaylistTitlesOrderedLst:
            audioPlayerView2ShortsTestDownloadedaudiotitles,
        firstAudioListTileIndex: 2,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('Various Tests', () {
    testWidgets(
        '''Entered a Youtube playlist URL. Then switch to AudioPlayerView
           and then back to PlaylistView''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      await app.main(['test']);
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
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        youtubePlaylistUrl,
      );

      await tester.pumpAndSettle();

      // Ensure the url text field contains the entered url
      TextField urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
      expect(urlTextField.controller!.text, youtubePlaylistUrl);

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen

      final appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Now we tap on the PlaylistDownloadView icon button to go
      // back to the PlaylistDownloadView screen

      final playlistDownloadNavButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(playlistDownloadNavButton);
      await tester.pumpAndSettle();

      // Ensure the URL TextField was emptied
      urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
      expect(urlTextField.controller!.text, '');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });

    /// The objective of this integration test is to ensure that
    /// the url text field will not be emptied after adding a
    /// local playlist, in contrary of what happens after adding
    /// a Youtube playlist.
    testWidgets('Select then unselect local playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String localPlaylistTitle = 'audio_learn_local_playlist_test';

      await app.main(['test']);
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

      // Verify that the selected playlist Text is empty
      Text selectedPlaylistTitleText =
          tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));
      expect(selectedPlaylistTitleText.data, '');

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
      selectedPlaylistTitleText =
          tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));
      expect(
        selectedPlaylistTitleText.data,
        localPlaylistTitle,
      );

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
      selectedPlaylistTitleText =
          tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));
      expect(selectedPlaylistTitleText.data, '');

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
      );
    });
    testWidgets('Download single video audio with invalid URL', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      // setting default playlist audio play speed to 1.25
      settingsDataService.set(
          settingType: SettingType.playlists,
          settingSubType: Playlists.playSpeed,
          value: 1.25);

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
      PlaylistListVM playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: mockAudioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: playlistListVM,
        commentVM: CommentVM(),
      );

      DateFormatVM dateFormatVM = DateFormatVM(
        settingsDataService: settingsDataService,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        playlistListVM: playlistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
        dateFormatVM: dateFormatVM,
      );

      const String invalidSingleVideoUrl = 'invalid';

      // Tap the 'Toggle List' button to display the playlist list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Enter the invalid single video URL into the url text
      // field
      await tester.enterText(
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        invalidSingleVideoUrl,
      );

      // Ensure the url text field contains the entered url
      TextField urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
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
      expect(find.byType(WarningMessageDisplayDialog), findsOneWidget);

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
      urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
      expect(urlTextField.controller!.text, invalidSingleVideoUrl);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
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

      PlaylistListVM playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      AudioPlayerVM audioPlayerVM = AudioPlayerVM(
        playlistListVM: playlistListVM,
        commentVM: CommentVM(),
      );

      DateFormatVM dateFormatVM = DateFormatVM(
        settingsDataService: settingsDataService,
      );

      await _launchExpandablePlaylistListView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        playlistListVM: playlistListVM,
        warningMessageVM: warningMessageVM,
        audioPlayerVM: audioPlayerVM,
        dateFormatVM: dateFormatVM,
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
      await tester.pumpAndSettle();

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
        find.byKey(
          const Key('youtubeUrlOrSearchTextField'),
        ),
        singleVideoToDownloadUrl,
      );

      // Ensure the url text field contains the entered url
      TextField urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
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
      expect(find.byType(WarningMessageDisplayDialog), findsOneWidget);

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
      urlTextField = tester.widget(find.byKey(
        const Key('youtubeUrlOrSearchTextField'),
      ));
      expect(urlTextField.controller!.text, singleVideoToDownloadUrl);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('Settings update test', () {
    testWidgets('After moving down a playlist item', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to display the playlist list. If the list
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
      expect(find.byType(WarningMessageDisplayDialog), findsOneWidget);

      // Check the value of the warning dialog message
      Text warningDialogMessage =
          tester.widget(find.byKey(const Key('warningDialogMessage')));
      expect(warningDialogMessage.data,
          'Local playlist "$localAudioPlaylistTitle" of audio quality added at end of list of playlists.');

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // The list of Playlist's should have three items now
      expect(find.byType(ListTile), findsNWidgets(3));

      // Check if the added item is displayed correctly
      final PlaylistListItem playlistListItemWidget =
          tester.widget(find.byType(PlaylistListItem).first);
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
      );
    });
  });
  group('Copy audio test', () {
    testWidgets(
        '''Copy (+ check comment) audio twice. Second copy is refused with
           warning since the audio exist now in the target playlist. The
           same duplicate copy is then performed again, but this time the
           user tap on the cancel button instead of the confirm button. Then
           3rd time copy to another empty target playlist and click on cancel
           button''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to display the playlist list
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
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
      await tester.pumpAndSettle();

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

      Text selectedPlaylistTitleText = tester
          .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')));

      expect(selectedPlaylistTitleText.data, youtubeAudioSourcePlaylistTitle);

      // Now verifying that the source audio still access to its
      // comments

      // First, tap on the source audio ListTile to open the
      // audio player view
      await tester.tap(sourceAudioListTileWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Verify that the comment icon button is highlighted. This indiquates
      // that a comment exist for the audio
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        inkWellButtonKey: 'commentsInkWellButton',
        expectedIcon: Icons.bookmark_outline_outlined,
        expectedIconColor: Colors.white,
        expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
      );

      // Now verify that the moved audio can be played

      // Verify the current audio position
      Text audioPositionText = tester
          .widget<Text>(find.byKey(const Key('audioPlayerViewAudioPosition')));
      expect(audioPositionText.data, '0:05');

      Finder audioTitlePositionTextFinder =
          find.text("$copiedAudioTitle\n0:24");
      expect(audioTitlePositionTextFinder, findsOneWidget);

      // Now play then pause the copied audio
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Tap on pause button to pause the audio
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // Verify the audio position

      Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));

      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: audioPlayerViewAudioPositionFinder,
        minPositionTimeStr: '0:03',
        maxPositionTimeStr: '0:06',
      );

      // Return to the Playlist Download View
      final playlistDownloadViewNavButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(playlistDownloadViewNavButton);
      await tester.pumpAndSettle();

      // Now verifying that the source playlist directory still
      // contains the audio file copied to the target playlist
      List<String> sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle',
        fileExtension: 'mp3',
      );

      expect(sourcePlaylistMp3Lst, [
        "230628-033811-audio learn test short video one 23-06-10.mp3",
        "230628-033813-audio learn test short video two 23-06-10.mp3",
      ]);

      // And verify that the target playlist directory now
      // contains the audio file copied from the source playlist
      List<String> targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetPlaylistTitleTwo',
        fileExtension: 'mp3',
      );

      expect(targetPlaylistMp3Lst,
          ["230628-033811-audio learn test short video one 23-06-10.mp3"]);

      // Find the target ListTile Playlist containing the audio copied
      // from the source playlist

      await IntegrationTestUtil.selectPlaylistInPlaylistDownloadView(
        tester: tester,
        playlistToSelectTitle: localAudioTargetPlaylistTitleTwo,
      );

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
      await tester.pumpAndSettle();

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
      await tester.tap(find.byKey(const Key('audio_info_ok_button_key')));
      await tester.pumpAndSettle();

      // Now verifying that the target audio can access to its copied
      // comments

      // First, tap on the source audio ListTile to open the
      // audio player view
      await tester.tap(targetAudioListTileWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
        additionalMilliseconds: 1000,
      );

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
      Finder sourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioSourcePlaylistTitle);

      // Then obtain the source Playlist ListTile widget enclosing the
      // Text widget by finding its ancestor
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
      await tester.pumpAndSettle();

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

      // Now, we retry to copy a second time the audio already copied
      // to the target playlist, but instead of clicking on the confirm
      // button, we will click on the cancel button in order to verify
      // that no warning is displayed. This ensure that a previously
      // present bug was solved.

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
      await tester.pumpAndSettle();

      // Now find the copy audio popup menu item and tap on it
      popupCopyMenuItem =
          find.byKey(const Key("popup_menu_copy_audio_to_playlist"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

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

      // Now find the cancel button and tap on it
      await tester.tap(find.byKey(const Key('cancelButton')));
      await tester.pumpAndSettle();

      // Check that no warning is displayed
      expect(find.text('AVERTISSEMENT'), findsNothing);

      // Finally redo copying the audio to the other local (local_3)
      // playlist which contains no audio, but finally click on Cancel
      // button.

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
      await tester.pumpAndSettle();

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

      selectedPlaylistTitleText = tester
          .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')));

      expect(selectedPlaylistTitleText.data, youtubeAudioSourcePlaylistTitle);

      // Now verifying that the source playlist directory still
      // contains the audio file copied to the target playlist
      sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle',
        fileExtension: 'mp3',
      );

      expect(sourcePlaylistMp3Lst, [
        "230628-033811-audio learn test short video one 23-06-10.mp3",
        "230628-033813-audio learn test short video two 23-06-10.mp3",
      ]);

      // And verify that the target playlist directory does not
      // contains the audio file copied from the source playlist
      targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetPlaylistTitleThree',
        fileExtension: 'mp3',
      );

      expect(targetPlaylistMp3Lst, []);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Copy audio and then move it to same target playlist: the move is
           refused with warning since the copied audio now exists in the
           target playlist. Then 3rd time move to another playlist and click
           on cancel button''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to display the playlist list
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
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
      await tester.pumpAndSettle();

      // Now find the copy audio popup menu item and tap on it
      Finder popupMoveMenuItem =
          find.byKey(const Key("popup_menu_copy_audio_to_playlist"));

      await tester.tap(popupMoveMenuItem);
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

      Text selectedPlaylistTitleText = tester
          .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')));

      expect(selectedPlaylistTitleText.data, youtubeAudioSourcePlaylistTitle);

      // Now verifying that the source playlist directory still
      // contains the audio file copied to the target playlist
      List<String> sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle',
        fileExtension: 'mp3',
      );

      expect(sourcePlaylistMp3Lst, [
        "230628-033811-audio learn test short video one 23-06-10.mp3",
        "230628-033813-audio learn test short video two 23-06-10.mp3",
      ]);

      // And verify that the target playlist directory now
      // contains the audio file copied from the source playlist
      List<String> targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetPlaylistTitleTwo',
        fileExtension: 'mp3',
      );

      expect(targetPlaylistMp3Lst,
          ["230628-033811-audio learn test short video one 23-06-10.mp3"]);

      // Find the target ListTile Playlist containing the audio copied
      // from the source playlist

      await IntegrationTestUtil.selectPlaylistInPlaylistDownloadView(
        tester: tester,
        playlistToSelectTitle: localAudioTargetPlaylistTitleTwo,
      );

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
      await tester.pumpAndSettle();

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
      await tester.tap(find.byKey(const Key('audio_info_ok_button_key')));
      await tester.pumpAndSettle();

      // Then, we try to move the audio already copied to the same
      // target playlist in order to verify that a warning is
      // displayed informing that the audio was not moved because it
      // is already present in the target playlist

      // Find the ListTile Playlist containing the audio to copy to
      // the target local playlist

      // First, find the source Playlist ListTile Text widget
      Finder sourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioSourcePlaylistTitle);

      // Then obtain the source Playlist ListTile widget enclosing the
      // Text widget by finding its ancestor
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
      await tester.pumpAndSettle();

      // Now find the move audio popup menu item and tap on it
      popupMoveMenuItem =
          find.byKey(const Key("popup_menu_move_audio_to_playlist"));

      await tester.tap(popupMoveMenuItem);
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
      await tester.pumpAndSettle();

      // Now find the move audio popup menu item and tap on it
      popupMoveMenuItem =
          find.byKey(const Key("popup_menu_move_audio_to_playlist"));

      await tester.tap(popupMoveMenuItem);
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

      selectedPlaylistTitleText = tester
          .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')));

      expect(selectedPlaylistTitleText.data, youtubeAudioSourcePlaylistTitle);

      // Now verifying that the source playlist directory still
      // contains the audio file moved but canceled to the target
      // playlist
      sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle',
        fileExtension: 'mp3',
      );

      expect(sourcePlaylistMp3Lst, [
        "230628-033811-audio learn test short video one 23-06-10.mp3",
        "230628-033813-audio learn test short video two 23-06-10.mp3",
      ]);

      // And verify that the target playlist directory does not
      // contains the audio file copied from the source playlist
      targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetPlaylistTitleThree',
        fileExtension: 'mp3',
      );

      expect(targetPlaylistMp3Lst, []);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Copy/delete commented audio to target playlist. Copy commented
           audio to target playlist and then delete it from target playlist.
           A warning is displayed informing that the audio has comment(s)
           and that those comments will be deleted. Confirm deletion and
           then move the audio to the same target playlist.''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String youtubeAudioSourcePlaylistTitle =
          'audio_learn_test_download_2_small_videos';
      const String localAudioTargetPlaylistTitle = 'local_audio_playlist_2';
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to display the playlist list
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
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
      await tester.pumpAndSettle();

      // Now find the copy audio popup menu item and tap on it
      Finder popupMoveMenuItem =
          find.byKey(const Key("popup_menu_copy_audio_to_playlist"));

      await tester.tap(popupMoveMenuItem);
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
            (widget.title as Text).data == localAudioTargetPlaylistTitle,
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

      Text selectedPlaylistTitleText = tester
          .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')));

      expect(selectedPlaylistTitleText.data, youtubeAudioSourcePlaylistTitle);

      // Now verifying that the source playlist directory still
      // contains the audio file copied to the target playlist
      List<String> sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle',
        fileExtension: 'mp3',
      );

      expect(sourcePlaylistMp3Lst, [
        "230628-033811-audio learn test short video one 23-06-10.mp3",
        "230628-033813-audio learn test short video two 23-06-10.mp3",
      ]);

      // Now verifying that the source playlist directory still
      // contains the comment data of audio file copied to the target
      // playlist
      List<String> sourcePlaylistCommentFileLst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle${path.separator}$kCommentDirName',
        fileExtension: 'json',
      );

      expect(sourcePlaylistCommentFileLst, [
        "230628-033811-audio learn test short video one 23-06-10.json",
        "230628-033813-audio learn test short video two 23-06-10.json",
      ]);

      // And verify that the target playlist directory now
      // contains the audio file copied from the source playlist
      List<String> targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetPlaylistTitle',
        fileExtension: 'mp3',
      );

      expect(targetPlaylistMp3Lst,
          ["230628-033811-audio learn test short video one 23-06-10.mp3"]);

      // Verify as well that the target playlist directory now contains
      // the comment file of the audio copied from the source playlist
      List<String> targetPlaylistJsonLst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetPlaylistTitle${path.separator}$kCommentDirName',
        fileExtension: 'json',
      );

      expect(targetPlaylistJsonLst,
          ["230628-033811-audio learn test short video one 23-06-10.json"]);

      // Now, we want to delete the audio copied to the target playlist.
      // Since this audio has comments, its deletion will cause a confirm
      // action dialog to be displayed.

      // Find the target ListTile Playlist containing the audio copied
      // from the source playlist

      await IntegrationTestUtil.selectPlaylistInPlaylistDownloadView(
        tester: tester,
        playlistToSelectTitle: localAudioTargetPlaylistTitle,
      );

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
      await tester.pumpAndSettle();

      // Now find the popup menu delete audio item and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_delete_audio"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Since the copied audio contains comment(s), deleting it
      // causes a confirm action dialog to be displayed.

      // Checking the confirm dialog

      Finder confirmActionDialogFinder = find.byType(ConfirmActionDialog);

      // Check the value of the confirm dialog title
      Finder confirmActionDialogTitleText = find.descendant(
          of: confirmActionDialogFinder,
          matching: find.byKey(const Key("confirmDialogTitleOneKey")));

      expect(
        tester.widget<Text>(confirmActionDialogTitleText).data!,
        "Confirmez la suppression de l'audio commenté \"audio learn test short video one\"",
      );

      // Check the value of the confirm dialog message
      Finder confirmActionDialogMessageText = find.descendant(
          of: confirmActionDialogFinder,
          matching: find.byKey(const Key("confirmationDialogMessageKey")));

      expect(
        tester.widget<Text>(confirmActionDialogMessageText).data!,
        "L'audio contient 1 commentaire(s) qui seront également supprimés. Confirmer la suppression ?",
      );

      // Confirm the deletion of the audio and close the confirm
      // dialog by tapping on the Confirm button
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now verify that the target playlist directory no longer
      // contains the audio file copied from the source playlist
      targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetPlaylistTitle',
        fileExtension: 'mp3',
      );

      expect(targetPlaylistMp3Lst, []);

      // And verify that the target playlist comment directory no longer
      // contains the audio comment file of the audio copied from the
      // source playlist
      targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetPlaylistTitle${path.separator}$kCommentDirName',
        fileExtension: 'json',
      );

      expect(targetPlaylistMp3Lst, []);

      // Then, we move the audio already copied and deleted to the
      // same target playlist to ensure that even it has comment(s),
      // it is moved with no warning since the comments won't be
      // distroyd.

      // Find the ListTile Playlist containing the audio to move to
      // the target local playlist

      // First, find the source Playlist ListTile Text widget
      Finder sourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioSourcePlaylistTitle);

      // Then obtain the source Playlist ListTile widget enclosing the
      // Text widget by finding its ancestor
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
      await tester.pumpAndSettle();

      // Now find the move audio popup menu item and tap on it
      popupMoveMenuItem =
          find.byKey(const Key("popup_menu_move_audio_to_playlist"));

      await tester.tap(popupMoveMenuItem);
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
            (widget.title as Text).data == localAudioTargetPlaylistTitle,
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

      // Now verifying the selected playlist TextField still contains
      // the title of the source playlist

      selectedPlaylistTitleText = tester
          .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')));

      expect(selectedPlaylistTitleText.data, youtubeAudioSourcePlaylistTitle);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Copy/delete commented audio to target playlist. Copy commented
           audio to target playlist and then delete it from target playlist.
           A warning is displayed informing that the audio has comment(s)
           and that those comments will be deleted. Confirm deletion and
           then copy again the audio to the same target playlist.''',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String youtubeAudioSourcePlaylistTitle =
          'audio_learn_test_download_2_small_videos';
      const String localAudioTargetPlaylistTitle = 'local_audio_playlist_2';
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to display the playlist list
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
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
      await tester.pumpAndSettle();

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
            (widget.title as Text).data == localAudioTargetPlaylistTitle,
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

      Text selectedPlaylistTitleText = tester
          .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')));

      expect(selectedPlaylistTitleText.data, youtubeAudioSourcePlaylistTitle);

      // Now verifying that the source playlist directory still
      // contains the audio file copied to the target playlist
      List<String> sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle',
        fileExtension: 'mp3',
      );

      expect(sourcePlaylistMp3Lst, [
        "230628-033811-audio learn test short video one 23-06-10.mp3",
        "230628-033813-audio learn test short video two 23-06-10.mp3",
      ]);

      // And verify that the target playlist directory now
      // contains the audio file copied from the source playlist
      List<String> targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetPlaylistTitle',
        fileExtension: 'mp3',
      );

      expect(targetPlaylistMp3Lst,
          ["230628-033811-audio learn test short video one 23-06-10.mp3"]);

      // Find the target ListTile Playlist containing the audio copied
      // from the source playlist

      await IntegrationTestUtil.selectPlaylistInPlaylistDownloadView(
        tester: tester,
        playlistToSelectTitle: localAudioTargetPlaylistTitle,
      );

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
      await tester.pumpAndSettle();

      // Now find the popup menu delete audio item and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_delete_audio"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Since the copied audio contains comment(s), deleting it
      // causes a confirm action dialog to be displayed.

      Finder confirmActionDialogFinder = find.byType(ConfirmActionDialog);

      // Check the value of the confirm dialog title
      Finder confirmActionDialogTitleText = find.descendant(
          of: confirmActionDialogFinder,
          matching: find.byKey(const Key("confirmDialogTitleOneKey")));

      expect(
        tester.widget<Text>(confirmActionDialogTitleText).data!,
        "Confirmez la suppression de l'audio commenté \"audio learn test short video one\"",
      );

      // Check the value of the confirm dialog message
      Finder confirmActionDialogMessageText = find.descendant(
          of: confirmActionDialogFinder,
          matching: find.byKey(const Key("confirmationDialogMessageKey")));

      expect(
        tester.widget<Text>(confirmActionDialogMessageText).data!,
        "L'audio contient 1 commentaire(s) qui seront également supprimés. Confirmer la suppression ?",
      );

      // Confirm the deletion of the audio and close the confirm
      // dialog by tapping on the Confirm button
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now verify that the target playlist directory no longer
      // contains the audio file copied from the source playlist
      targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetPlaylistTitle',
        fileExtension: 'mp3',
      );

      expect(targetPlaylistMp3Lst, []);

      // Then, we move the audio already copied and deletedto to the
      // same target playlist in ensure it is moved with no warning

      // Find the ListTile Playlist containing the audio to move to
      // the target local playlist

      // First, find the source Playlist ListTile Text widget
      Finder sourcePlaylistListTileTextWidgetFinder =
          find.text(youtubeAudioSourcePlaylistTitle);

      // Then obtain the source Playlist ListTile widget enclosing the
      // Text widget by finding its ancestor
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
      await tester.pumpAndSettle();

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
            (widget.title as Text).data == localAudioTargetPlaylistTitle,
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

      selectedPlaylistTitleText = tester
          .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')));

      expect(selectedPlaylistTitleText.data, youtubeAudioSourcePlaylistTitle);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Copy (+ check comment) audio from the Youtube source playlist to
           the local target playlist, then copy it from the target playlist
           to the another target playlist. The purpose of this test is to check
           that the 'Copied from playlist' and 'Copied to playlist' audio info
           fields are correctly updated.''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String youtubeAudioSourcePlaylistTitle =
          'audio_learn_test_download_2_small_videos';
      const String localAudioTargetOnePlaylistTitle = 'local_audio_playlist_2';
      const String localAudioTargetTwoPlaylistTitle = 'local_3';
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // *** First copy audio from Youtube source playlist to local
      // target playlist.

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

      // Now find the leading menu icon button of the Audio ListTile and tap
      // on it
      Finder sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle();

      // Now find the copy audio popup menu item and tap on it
      Finder popupMoveMenuItem =
          find.byKey(const Key("popup_menu_copy_audio_to_playlist"));

      await tester.tap(popupMoveMenuItem);
      await tester.pumpAndSettle();

      // Check the value of the select one playlist AlertDialog
      // dialog title
      Text alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Sélectionnez une playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be moved

      Finder radioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioTargetOnePlaylistTitle,
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
          'Audio "audio learn test short video one" copié de la playlist Youtube "audio_learn_test_download_2_small_videos" vers la playlist locale "local_audio_playlist_2".');

      // Now find the ok button of the confirm warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now verifying the selected playlist TextField still
      // contains the title of the source playlist

      Text selectedPlaylistTitleText = tester
          .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')));

      expect(selectedPlaylistTitleText.data, youtubeAudioSourcePlaylistTitle);

      // Testing that the audio was copied from the source to the target
      // playlist directory

      List<String> sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle',
        fileExtension: 'mp3',
      );

      List<String> targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetOnePlaylistTitle',
        fileExtension: 'mp3',
      );

      expect(sourcePlaylistMp3Lst, [
        "230628-033811-audio learn test short video one 23-06-10.mp3",
        "230628-033813-audio learn test short video two 23-06-10.mp3"
      ]);
      expect(targetPlaylistMp3Lst,
          ["230628-033811-audio learn test short video one 23-06-10.mp3"]);

      // Now verifying the copied audio info dialog related content
      // in the source Youtube playlist

      await verifyAudioInfoDialog(
        tester: tester,
        audioEnclosingPlaylistTitle: youtubeAudioSourcePlaylistTitle,
        movedOrCopiedAudioTitle: copiedAudioTitle,
        movedFromPlaylistTitle: '',
        movedToPlaylistTitle: '',
        copiedFromPlaylistTitle: '',
        copiedToPlaylistTitle: localAudioTargetOnePlaylistTitle,
        audioDuration: '0:00:24.0',
      );

      // Find the target ListTile Playlist containing the audio moved
      // from the source playlist

      // First, find the Playlist ListTile Text widget
      Finder targetOnePlaylistListTileTextWidgetFinder =
          find.text(localAudioTargetOnePlaylistTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      Finder targetOnePlaylistListTileWidgetFinder = find.ancestor(
        of: targetOnePlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      Finder targetOnePlaylistListTileCheckboxWidgetFinder = find.descendant(
        of: targetOnePlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(targetOnePlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now verifying the copied audio info dialog related content
      // in the target local playlist

      Finder targetAudioListTileWidgetFinder = await verifyAudioInfoDialog(
        tester: tester,
        audioEnclosingPlaylistTitle: localAudioTargetOnePlaylistTitle,
        movedOrCopiedAudioTitle: copiedAudioTitle,
        movedFromPlaylistTitle: '',
        movedToPlaylistTitle: '',
        copiedFromPlaylistTitle: youtubeAudioSourcePlaylistTitle,
        copiedToPlaylistTitle: '',
        audioDuration: '0:00:24.0',
      );

      // Now verifying that the target audio can access to its copied
      // comments

      // First, tap on the copied audio ListTile to open the
      // audio player view
      await tester.tap(targetAudioListTileWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Verify that the comment icon button is highlighted. This indiquates
      // that a comment exist for the audio
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        inkWellButtonKey: 'commentsInkWellButton',
        expectedIcon: Icons.bookmark_outline_outlined,
        expectedIconColor: Colors.white,
        expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
      );

      // *** Then further copy the copied audio from the target local playlist
      // 'local_audio_playlist_2' to a new target local playlist 'local_3'.

      // Return to playlist download view
      Finder playlistDownloadViewNavButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(playlistDownloadViewNavButton);
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

      // Now find the leading menu icon button of the Audio ListTile and tap
      // on it
      sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle();

      // Now find the copy audio popup menu item and tap on it
      popupMoveMenuItem =
          find.byKey(const Key("popup_menu_copy_audio_to_playlist"));

      await tester.tap(popupMoveMenuItem);
      await tester.pumpAndSettle();

      // Find the RadioListTile target playlist to which the audio
      // will be moved

      radioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioTargetTwoPlaylistTitle,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(radioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now find the ok button of the displayed confirm warning
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now verifying the copied audio info dialog related content
      // in the source local playlist
      targetAudioListTileWidgetFinder = await verifyAudioInfoDialog(
        tester: tester,
        audioEnclosingPlaylistTitle: localAudioTargetOnePlaylistTitle,
        movedOrCopiedAudioTitle: copiedAudioTitle,
        movedFromPlaylistTitle: '',
        movedToPlaylistTitle: '',
        copiedFromPlaylistTitle: youtubeAudioSourcePlaylistTitle,
        copiedToPlaylistTitle: localAudioTargetTwoPlaylistTitle,
        audioDuration: '0:00:24.0',
      );

      // Now verifying the copied audio info dialog related content
      // in the target local playlist

      // First, find the Playlist ListTile Text widget
      final Finder targetTwoPlaylistListTileTextWidgetFinder =
          find.text(localAudioTargetTwoPlaylistTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder targetTwoPlaylistListTileWidgetFinder = find.ancestor(
        of: targetTwoPlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder targetTwoPlaylistListTileCheckboxWidgetFinder =
          find.descendant(
        of: targetTwoPlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(targetTwoPlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now verifying the copied audio info dialog related content
      // in the target local playlist
      targetAudioListTileWidgetFinder = await verifyAudioInfoDialog(
        tester: tester,
        audioEnclosingPlaylistTitle: localAudioTargetTwoPlaylistTitle,
        movedOrCopiedAudioTitle: copiedAudioTitle,
        movedFromPlaylistTitle: '',
        movedToPlaylistTitle: '',
        copiedFromPlaylistTitle: localAudioTargetOnePlaylistTitle,
        copiedToPlaylistTitle: '',
        audioDuration: '0:00:24.0',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Copy commented audio which was already manually copied to the target
           playlist directory. Since the audio file exist in the target playlist
           dir, a warning indicating that the audio copy is not performed.
           Verify that the audio comment file itself was not copied to the
           target playlist comment dir since the copy was excluded.''',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String youtubeAudioSourcePlaylistTitle =
          'audio_learn_test_download_2_small_videos';
      const String localAudioTargetPlaylistTitleThree = 'local_3';
      const String copiedCommentedAudioTitle =
          'audio learn test short video one';
      const String copiedCommentedAudioFileName =
          '230628-033811-audio learn test short video one 23-06-10.mp3';
      const String copiedCommentedAudioCommentFileName =
          '230628-033811-audio learn test short video one 23-06-10.json';

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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Manually copy the 'audio learn test short video one.mp3' file
      // to the 'local3' playlist dir.

      String targetPlaylistLocalDir =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetPlaylistTitleThree";

      DirUtil.copyFileToDirectorySync(
        sourceFilePathName:
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle${path.separator}$copiedCommentedAudioFileName",
        targetDirectoryPath: targetPlaylistLocalDir,
      );

      // Tap the 'Toggle List' button to display the playlist list
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      Finder sourceAudioListTileTextWidgetFinder =
          find.text(copiedCommentedAudioTitle);

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
      await tester.pumpAndSettle();

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
            (widget.title as Text).data == localAudioTargetPlaylistTitleThree,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(targetPlaylistRadioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Check the value of the Warning dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'AVERTISSEMENT');

      // Now verifying the warning dialog message

      Text warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

      expect(warningDialogMessageTextWidget.data,
          "L'audio \"audio learn test short video one\" n'a pas été copié de la playlist Youtube \"audio_learn_test_download_2_small_videos\" vers la playlist locale \"local_3\" car il est déjà présent dans cette playlist.");

      // Now find the ok button of the warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now verify that the audio comment file was not copied to the
      // target playlist comment dir since the copy was excluded
      expect(
        File("$targetPlaylistLocalDir${path.separator}$kCommentDirName${path.separator}$copiedCommentedAudioCommentFileName")
            .existsSync(),
        false,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Copy in new created local playlist an audio whose play speed is set to 
           1.5. Verify that the audio play speed is correctly set in the copied
           audio file''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String newLocalAudioTargetPlaylistTitle = 'new_local';
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Creating new local playlist

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Enter the title of the local playlist
      await tester.enterText(
        find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')),
        newLocalAudioTargetPlaylistTitle,
      );
      await tester.pumpAndSettle();

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one", the audio to be copied

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
      await tester.pumpAndSettle();

      // Now find the copy audio popup menu item and tap on it
      Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_copy_audio_to_playlist"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Find the RadioListTile target playlist to which the audio
      // will be copied

      Finder targetPlaylistRadioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == newLocalAudioTargetPlaylistTitle,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(targetPlaylistRadioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now find the ok button of the confirm dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Verify that the target playlist directory now
      // contains the audio file copied from the source playlist
      List<String> targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$newLocalAudioTargetPlaylistTitle',
        fileExtension: 'mp3',
      );

      expect(targetPlaylistMp3Lst,
          ["230628-033811-audio learn test short video one 23-06-10.mp3"]);

      // Find the target ListTile Playlist containing the audio copied
      // from the source playlist

      await IntegrationTestUtil.selectPlaylistInPlaylistDownloadView(
        tester: tester,
        playlistToSelectTitle: newLocalAudioTargetPlaylistTitle,
      );

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
      await tester.pumpAndSettle();

      // Now find the popup menu item and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_display_audio_info"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Now verifying the audio play speed in the displayed audio info
      final Text enclosingPlaylistTitleTextWidget =
          tester.widget<Text>(find.byKey(const Key('audioPlaySpeedKey')));

      expect(enclosingPlaylistTitleTextWidget.data, '1.25');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('Move audio test', () {
    testWidgets(
        '''Move (+ check comment) audio from the Youtube source playlist to
           the local target playlist, then move it back from the target to the
           source playlist, then move it again from source to target, then move
           it again back from the target to the source playlist. The purpose
           of this test is to check that the 'Moved from playlist' and 'Moved
           to playlist' audio info fields are correctly updated.''',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String youtubeAudioSourcePlaylistTitle =
          'audio_learn_test_download_2_small_videos';
      const String localAudioTargetPlaylistTitle = 'local_audio_playlist_2';
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // *** First move audio from Youtube source playlist to local
      // target playlist.

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      Finder sourceAudioListTileTextWidgetFinder = find.text(movedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      Finder sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile and tap
      // on it
      Finder sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle();

      // Now find the move audio popup menu item and tap on it
      Finder popupMoveMenuItem =
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

      Finder radioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == localAudioTargetPlaylistTitle,
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

      Text selectedPlaylistTitleText = tester
          .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')));

      expect(selectedPlaylistTitleText.data, youtubeAudioSourcePlaylistTitle);

      // Testing that the audio was moved from the source to the target
      // playlist directory

      List<String> sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle',
        fileExtension: 'mp3',
      );

      List<String> targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetPlaylistTitle',
        fileExtension: 'mp3',
      );

      // Contains only the not moved audio
      expect(sourcePlaylistMp3Lst,
          ["230628-033813-audio learn test short video two 23-06-10.mp3"]);

      // Contains only the moved audio
      expect(targetPlaylistMp3Lst,
          ["230628-033811-audio learn test short video one 23-06-10.mp3"]);

      // Find the target ListTile Playlist containing the audio moved
      // from the source playlist

      await IntegrationTestUtil.selectPlaylistInPlaylistDownloadView(
        tester: tester,
        playlistToSelectTitle: localAudioTargetPlaylistTitle,
      );

      // Now verifying the moved audio info dialog related content
      // in the target local playlist

      Finder targetAudioListTileWidgetFinder = await verifyAudioInfoDialog(
        tester: tester,
        audioEnclosingPlaylistTitle: localAudioTargetPlaylistTitle,
        movedOrCopiedAudioTitle: movedAudioTitle,
        movedFromPlaylistTitle: youtubeAudioSourcePlaylistTitle,
        movedToPlaylistTitle: '',
        copiedFromPlaylistTitle: '',
        copiedToPlaylistTitle: '',
        audioDuration: '0:00:24.0',
      );

      // Now verifying that the moved audio can access to its moved
      // comments

      // First, tap on the target audio ListTile to open the
      // audio player view
      await tester.tap(targetAudioListTileWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Verify that the comment icon button is highlighted. This indiquates
      // that a comment exist for the audio
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        inkWellButtonKey: 'commentsInkWellButton',
        expectedIcon: Icons.bookmark_outline_outlined,
        expectedIconColor: Colors.white,
        expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
      );

      // Now verify that the moved audio can be played

      // Verify the current audio position
      Text audioPositionText = tester
          .widget<Text>(find.byKey(const Key('audioPlayerViewAudioPosition')));
      expect(audioPositionText.data, '0:05');

      Finder audioTitlePositionTextFinder = find.text("$movedAudioTitle\n0:24");
      expect(audioTitlePositionTextFinder, findsOneWidget);

      // Now play then pause the moved audio
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Tap on pause button to pause the audio
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // Verify the audio position

      Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));

      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: audioPlayerViewAudioPositionFinder,
        minPositionTimeStr: '0:03',
        maxPositionTimeStr: '0:05',
      );

      // *** Then move back the moved audio from the target local playlist
      // to the Youtube source playlist.

      // Return to playlist download view
      Finder playlistDownloadViewNavButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(playlistDownloadViewNavButton);
      await tester.pumpAndSettle();

      // Click on playlist toggle button to hide the playlist list
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      Finder targetAudioListTileTextWidgetFinder = find.text(movedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      targetAudioListTileWidgetFinder = find.ancestor(
        of: targetAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile and tap
      // on it
      Finder targetAudioListTileLeadingMenuIconButton = find.descendant(
        of: targetAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(targetAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle();

      // Now find the move audio popup menu item and tap on it
      popupMoveMenuItem =
          find.byKey(const Key("popup_menu_move_audio_to_playlist"));

      await tester.tap(popupMoveMenuItem);
      await tester.pumpAndSettle();

      // Find the RadioListTile target playlist to which the audio
      // will be moved

      radioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == youtubeAudioSourcePlaylistTitle,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(radioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now find the ok button of the displayed confirm warning
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now verifying the moved audio info dialog related content
      // in the target youtube playlist

      // First, select the Youtube pléaylist ...

      // Find the ListTile Playlist containing the audio removed from
      // the target playlist

      // Click on playlist toggle button to display the playlist list
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      await IntegrationTestUtil.selectPlaylistInPlaylistDownloadView(
        tester: tester,
        playlistToSelectTitle: youtubeAudioSourcePlaylistTitle,
      );

      targetAudioListTileWidgetFinder = await verifyAudioInfoDialog(
        tester: tester,
        audioEnclosingPlaylistTitle: youtubeAudioSourcePlaylistTitle,
        movedOrCopiedAudioTitle: movedAudioTitle,
        movedFromPlaylistTitle: localAudioTargetPlaylistTitle,
        movedToPlaylistTitle: youtubeAudioSourcePlaylistTitle,
        copiedFromPlaylistTitle: '',
        copiedToPlaylistTitle: '',
        audioDuration: '0:00:24.0',
      );

      // *** Then move again the moved audio from the Youtube playlist
      // to the target local playlist.

      // Return to playlist download view
      await tester.tap(playlistDownloadViewNavButton);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      sourceAudioListTileTextWidgetFinder = find.text(movedAudioTitle);

      // Then obtain the Audio ListTile widget enclosing the Text widget by
      // finding its ancestor
      sourceAudioListTileWidgetFinder = find.ancestor(
        of: sourceAudioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the leading menu icon button of the Audio ListTile and tap
      // on it
      sourceAudioListTileLeadingMenuIconButton = find.descendant(
        of: sourceAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(sourceAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle();

      // Now find the move audio popup menu item and tap on it
      popupMoveMenuItem =
          find.byKey(const Key("popup_menu_move_audio_to_playlist"));

      await tester.tap(popupMoveMenuItem);
      await tester.pumpAndSettle();

      // Find the RadioListTile target playlist to which the audio
      // will be moved

      radioListTile = find.byWidgetPredicate((Widget widget) =>
          widget is RadioListTile &&
          widget.title is Text &&
          (widget.title as Text).data == localAudioTargetPlaylistTitle);

      // Tap the target playlist RadioListTile to select it
      await tester.tap(radioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now find the ok button of the displayed confirm warning
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Find the target ListTile Playlist containing the audio moved
      // from the source playlist

      await IntegrationTestUtil.selectPlaylistInPlaylistDownloadView(
        tester: tester,
        playlistToSelectTitle: localAudioTargetPlaylistTitle,
      );

      // Now verifying the moved audio info dialog related content
      // in the target local playlist

      targetAudioListTileWidgetFinder = await verifyAudioInfoDialog(
        tester: tester,
        audioEnclosingPlaylistTitle: localAudioTargetPlaylistTitle,
        movedOrCopiedAudioTitle: movedAudioTitle,
        movedFromPlaylistTitle: youtubeAudioSourcePlaylistTitle,
        movedToPlaylistTitle: localAudioTargetPlaylistTitle,
        copiedFromPlaylistTitle: '',
        copiedToPlaylistTitle: '',
        audioDuration: '0:00:24.0',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Move audio from Youtube to local playlist unchecking keep audio
           in source playlist checkbox. This displays a warning indicating
           that the audio reference in the Youtube playlist should be removed
           otherwise it will be downloaded again the next time the user
           will download this playlist.''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
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
      await tester.pumpAndSettle();

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
      );
    });
    testWidgets(
        '''Move commented audio which was already manually copied to the target
           playlist directory. Since the audio file exist in the target playlist
           dir, a warning indicating that the audio move is not performed.
           Verify that the audio comment file itself was not moved to the
           target playlist comment dir since the move operation was excluded.''',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String youtubeAudioSourcePlaylistTitle =
          'audio_learn_test_download_2_small_videos';
      const String localAudioTargetPlaylistTitleThree = 'local_3';
      const String movedCommentedAudioTitle =
          'audio learn test short video one';
      const String movedCommentedAudioFileName =
          '230628-033811-audio learn test short video one 23-06-10.mp3';
      const String movedCommentedAudioCommentFileName =
          '230628-033811-audio learn test short video one 23-06-10.json';

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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Manually copy the 'audio learn test short video one.mp3' file
      // to the 'local3' playlist dir.

      String targetPlaylistLocalDir =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetPlaylistTitleThree";

      DirUtil.copyFileToDirectorySync(
        sourceFilePathName:
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle${path.separator}$movedCommentedAudioFileName",
        targetDirectoryPath: targetPlaylistLocalDir,
      );

      // Tap the 'Toggle List' button to display the playlist list
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      Finder sourceAudioListTileTextWidgetFinder =
          find.text(movedCommentedAudioTitle);

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
      await tester.pumpAndSettle();

      // Now find the copy audio popup menu item and tap on it
      Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_move_audio_to_playlist"));

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
            (widget.title as Text).data == localAudioTargetPlaylistTitleThree,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(targetPlaylistRadioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Check the value of the Warning dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'AVERTISSEMENT');

      // Now verifying the warning dialog message

      Text warningDialogMessageTextWidget =
          tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

      expect(warningDialogMessageTextWidget.data,
          "L'audio \"audio learn test short video one\" n'a pas été déplacé de la playlist Youtube \"audio_learn_test_download_2_small_videos\" vers la playlist locale \"local_3\" car il est déjà présent dans cette playlist.");

      // Now find the ok button of the warning dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now verify that the audio comment file was not copied to the
      // target playlist comment dir since the copy was excluded
      expect(
        File("$targetPlaylistLocalDir${path.separator}$kCommentDirName${path.separator}$movedCommentedAudioCommentFileName")
            .existsSync(),
        false,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Move in new created local playlist an audio whose play speed is set to 
           1.5. Verify that the audio play speed is correctly set in the moved
           audio file''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}copy_move_audio_integr_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String newLocalAudioTargetPlaylistTitle = 'new_local';
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Creating new local playlist

      // Open the add playlist dialog by tapping the add playlist
      // button
      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Enter the title of the local playlist
      await tester.enterText(
        find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')),
        newLocalAudioTargetPlaylistTitle,
      );
      await tester.pumpAndSettle();

      // Confirm the addition by tapping the confirmation button in
      // the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one", the audio to be moved

      // First, find the Audio sublist ListTile Text widget
      Finder sourceAudioListTileTextWidgetFinder = find.text(movedAudioTitle);

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
      await tester.pumpAndSettle();

      // Now find the move audio popup menu item and tap on it
      Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_move_audio_to_playlist"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Find the RadioListTile target playlist to which the audio
      // will be moved

      Finder targetPlaylistRadioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == newLocalAudioTargetPlaylistTitle,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(targetPlaylistRadioListTile);
      await tester.pumpAndSettle();

      // Now find the confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Now find the ok button of the confirm dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Verify that the target playlist directory now
      // contains the audio file moved from the source playlist
      List<String> targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$newLocalAudioTargetPlaylistTitle',
        fileExtension: 'mp3',
      );

      expect(targetPlaylistMp3Lst,
          ["230628-033811-audio learn test short video one 23-06-10.mp3"]);

      // Find the target ListTile Playlist containing the audio moved
      // from the source playlist

      await IntegrationTestUtil.selectPlaylistInPlaylistDownloadView(
        tester: tester,
        playlistToSelectTitle: newLocalAudioTargetPlaylistTitle,
      );

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
      await tester.pumpAndSettle();

      // Now find the popup menu item and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_display_audio_info"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Now verifying the audio play speed in the displayed audio info
      final Text enclosingPlaylistTitleTextWidget =
          tester.widget<Text>(find.byKey(const Key('audioPlaySpeedKey')));

      expect(enclosingPlaylistTitleTextWidget.data, '1.25');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('Delete copied or moved audio test', () {
    testWidgets('''Delete an audio which was first copied from Youtube to local
           playlist and then was copied from the local playlist to an other
           Youtube playlist. This audio is then 'deleted from playlist as well'
           from the other Youtube playlist with no warning being displayed
           since, as a copied audio, it is not referenced in the Youtube
           playlist.''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // First, set the application language to French
      await IntegrationTestUtil.setApplicationLanguage(
        tester: tester,
        language: Language.french,
      );

      // *** First test part: Copy audio from Youtube to local
      // playlist

      // Tap the 'Toggle List' button to display the playlist list
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
      await tester.pumpAndSettle();

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

      Text selectedPlaylistTitleText = tester
          .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')));

      expect(
        selectedPlaylistTitleText.data,
        youtubeAudioSourcePlaylistTitle,
      );

      // Now verifying the audio was physically copied to the target
      // playlist directory.

      List<String> sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle',
        fileExtension: 'mp3',
      );

      List<String> targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetSourcePlaylistTitle',
        fileExtension: 'mp3',
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
      await tester.pumpAndSettle();

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

      selectedPlaylistTitleText = tester
          .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')));

      expect(
        selectedPlaylistTitleText.data,
        localAudioTargetSourcePlaylistTitle,
      );

      // Now verifying the audio was physically copied to the target
      // playlist directory.

      sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetSourcePlaylistTitle',
        fileExtension: 'mp3',
      );

      targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioTargetPlaylistTitle',
        fileExtension: 'mp3',
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
      await tester.pumpAndSettle();

      // Now find the popup menu item and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_delete_audio_from_playlist_aswell"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Now verifying the deleted audio was physically deleted from
      // the playlist directory. No warning was displayed.

      targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioTargetPlaylistTitle',
        fileExtension: 'mp3',
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
      );
    });
    testWidgets('''Delete an audio which was first moved from Youtube to local
           playlist and then was moved from the local playlist to an other
           Youtube playlist. This audio is then 'deleted from playlist as well'
           from the other Youtube playlist with no warning being displayed
           since, as a copied audio, it is not referenced in the Youtube
           playlist.''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // First, set the application language to French
      await IntegrationTestUtil.setApplicationLanguage(
        tester: tester,
        language: Language.french,
      );

      // *** First test part: Copy audio from Youtube to local
      // playlist

      // Tap the 'Toggle List' button to display the playlist list
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
      await tester.pumpAndSettle();

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

      Text selectedPlaylistTitleText = tester
          .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')));

      expect(
        selectedPlaylistTitleText.data,
        youtubeAudioSourcePlaylistTitle,
      );

      // Now verifying the audio was physically moved to the target
      // playlist directory.

      List<String> sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioSourcePlaylistTitle',
        fileExtension: 'mp3',
      );

      List<String> targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetSourcePlaylistTitle',
        fileExtension: 'mp3',
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
      await tester.pumpAndSettle();

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

      selectedPlaylistTitleText = tester
          .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')));

      expect(
          selectedPlaylistTitleText.data, localAudioTargetSourcePlaylistTitle);

      // Now verifying the audio was physically moved to the target
      // playlist directory.

      sourcePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioTargetSourcePlaylistTitle',
        fileExtension: 'mp3',
      );

      targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioTargetPlaylistTitle',
        fileExtension: 'mp3',
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
      await tester.pumpAndSettle();

      // Now find the 'Delete audio from playlist as well' popup menu item
      // and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_delete_audio_from_playlist_aswell"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Now verifying the deleted audio was physically deleted from
      // the playlist directory. No warning was displayed.

      targetPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath:
            '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubeAudioTargetPlaylistTitle',
        fileExtension: 'mp3',
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
      );
    });
  });
  group('''Executing update playable audio list after manually deleting audio
           files test''', () {
    testWidgets('Manually delete all audio in Youtube playlist directory.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      String youtubePlaylistPath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubePlaylistTitle';

      List<String> youtubePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath: youtubePlaylistPath,
        fileExtension: 'mp3',
      );

      // *** Manually deleting audio files from Youtube
      // playlist directory

      DirUtil.deleteMp3FilesInDir(
        youtubePlaylistPath,
      );

      // *** Updating the Youtube playlist

      // Tap the 'Toggle List' button to display the playlist list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the audio
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

      // Tap the 'Toggle List' button to hide the list of playlist
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Test that the Youtube playlist is still showing the
      // deleted audio

      Finder audioListTileTextWidgetFinder;

      for (String audioTitle in youtubePlaylistMp3Lst) {
        audioTitle = audioTitle
            .replaceAll(RegExp(r'[\d\-]'), '')
            .replaceFirst(' .mp', '')
            .replaceFirst(' fois', '3 fois')
            .replaceFirst('antinuke', 'anti-nuke');
        audioListTileTextWidgetFinder = find.text(audioTitle);

        expect(audioListTileTextWidgetFinder, findsOneWidget);
      }

      // Now update the playable audio list of the Youtube
      // playlist

      // Tap the 'Toggle List' button to display the playlist list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Now find the leading menu icon button of the Playlist ListTile
      // and tap on it
      Finder youtubePlaylistListTileLeadingMenuIconButton = find.descendant(
        of: youtubePlaylistListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(youtubePlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle();

      // Now find the update playlist popup menu item and tap on it
      Finder popupUpdatePlayableAudioListPlaylistMenuItem =
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
      // deleted audio

      for (String audioTitle in youtubePlaylistMp3Lst) {
        audioTitle = audioTitle
            .replaceAll(RegExp(r'[\d\-]'), '')
            .replaceFirst(' .mp', '')
            .replaceFirst(' fois', '3 fois')
            .replaceFirst('antinuke', 'anti-nuke');
        final Finder audioListTileTextWidgetFinder = find.text(audioTitle);

        expect(audioListTileTextWidgetFinder, findsNothing);
      }

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen

      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Verify the no selected audio title is displayed
      expect(find.text("No audio selected"), findsOneWidget);

      await IntegrationTestUtil.verifyTopButtonsState(
        tester: tester,
        isEnabled: false,
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        setAudioSpeedTextButtonValue: '1.00x',
      );

      // Now execute again the playlist update of the Youtube playlist.
      // This update won't change anything in the playlist.

      // Return to playlist download view
      Finder playlistDownloadViewNavButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(playlistDownloadViewNavButton);
      await tester.pumpAndSettle();

      // Now find the leading menu icon button of the Playlist ListTile
      // and tap on it
      youtubePlaylistListTileLeadingMenuIconButton = find.descendant(
        of: youtubePlaylistListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(youtubePlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle();

      // Now find the update playlist popup menu item and tap on it
      popupUpdatePlayableAudioListPlaylistMenuItem =
          find.byKey(const Key("popup_menu_update_playable_audio_list"));

      await tester.tap(popupUpdatePlayableAudioListPlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now verifying that no warning dialog is displayed since nothing
      // was updated in the playlist

      // Check the value of the warning dialog title
      expect(find.byKey(const Key('warningDialogTitle')), findsNothing);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('Manually delete all audio in local playlist directory.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      String localPlaylistPath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localPlaylistTitle';

      List<String> localPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath: localPlaylistPath,
        fileExtension: 'mp3',
      );

      // *** Manually deleting audio files from local
      // playlist directory

      DirUtil.deleteMp3FilesInDir(
        localPlaylistPath,
      );

      // *** Updating the local playlist

      // Tap the 'Toggle List' button to display the playlist list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the audio
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
      // deleted audio

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
      Finder localPlaylistListTileLeadingMenuIconButton = find.descendant(
        of: localPlaylistListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(localPlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle();

      // Now find the update playlist popup menu item and tap on it
      Finder popupUpdatePlayableAudioListPlaylistMenuItem =
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
      // deleted audio

      for (String audioTitle in localPlaylistMp3Lst) {
        audioTitle = audioTitle
            .replaceAll(RegExp(r'[\d\-]'), '')
            .replaceFirst(' .mp', '')
            .replaceFirst(' fois', '3 fois')
            .replaceFirst('antinuke', 'anti-nuke');
        final Finder audioListTileTextWidgetFinder = find.text(audioTitle);

        expect(audioListTileTextWidgetFinder, findsNothing);
      }

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen

      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Verify the no selected audio title is displayed
      expect(find.text("No audio selected"), findsOneWidget);

      await IntegrationTestUtil.verifyTopButtonsState(
        tester: tester,
        isEnabled: false,
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        setAudioSpeedTextButtonValue: '1.00x',
      );

      // Now execute again the playlist update of the Youtube playlist.
      // This update won't change anything in the playlist.

      // Return to playlist download view
      Finder playlistDownloadViewNavButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(playlistDownloadViewNavButton);
      await tester.pumpAndSettle();

      // Now find the leading menu icon button of the Playlist ListTile
      // and tap on it
      localPlaylistListTileLeadingMenuIconButton = find.descendant(
        of: localPlaylistListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(localPlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle();

      // Now find the update playlist popup menu item and tap on it
      popupUpdatePlayableAudioListPlaylistMenuItem =
          find.byKey(const Key("popup_menu_update_playable_audio_list"));

      await tester.tap(popupUpdatePlayableAudioListPlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now verifying that no warning dialog is displayed since nothing
      // was updated in the playlist

      // Check the value of the warning dialog title
      expect(find.byKey(const Key('warningDialogTitle')), findsNothing);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('Manually delete some audio in Youtube playlist directory.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      String youtubePlaylistPath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubePlaylistTitle';

      List<String> youtubePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath: youtubePlaylistPath,
        fileExtension: 'mp3',
      );

      // *** Manually deleting audio files from Youtube
      // playlist directory

      DirUtil.deleteFileIfExist(
        pathFileName:
            "$youtubePlaylistPath${path.separator}${youtubePlaylistMp3Lst[0]}",
      );

      // *** Updating the Youtube playlist

      // Tap the 'Toggle List' button to display the playlist list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the audio
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

      // Tap the 'Toggle List' button to hide the list of playlist
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Test that the Youtube playlist is still showing the
      // deleted audio

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

      // Tap the 'Toggle List' button to display the playlist list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Now find the leading menu icon button of the Playlist ListTile
      // and tap on it
      final Finder youtubePlaylistListTileLeadingMenuIconButton =
          find.descendant(
        of: youtubePlaylistListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(youtubePlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle();

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
          'Playable audio list for playlist "$youtubePlaylistTitle" was updated. 1 audio(s) were removed.');

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Test that the youtube playlist is no longer showing the
      // deleted audio

      int indexOfDeletedAudio = 0;

      for (String audioTitle in youtubePlaylistMp3Lst) {
        audioTitle = audioTitle
            .replaceAll(RegExp(r'[\d\-]'), '')
            .replaceFirst(' .mp', '')
            .replaceFirst(' fois', '3 fois')
            .replaceFirst('antinuke', 'anti-nuke');
        final Finder audioListTileTextWidgetFinder = find.text(audioTitle);

        if (indexOfDeletedAudio == 0) {
          expect(audioListTileTextWidgetFinder, findsNothing);
        } else {
          expect(audioListTileTextWidgetFinder, findsOneWidget);
        }

        indexOfDeletedAudio++;
      }

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen

      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Verify the displayed selected audio title
      expect(
          find.text(
              "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)\n20:32"),
          findsOneWidget);

      await IntegrationTestUtil.verifyTopButtonsState(
        tester: tester,
        isEnabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        setAudioSpeedTextButtonValue: '1.25x',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('Manually delete some audio in local playlist directory.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      String localPlaylistPath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localPlaylistTitle';

      List<String> localPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath: localPlaylistPath,
        fileExtension: 'mp3',
      );

      // *** Manually deleting audio files from local
      // playlist directory

      DirUtil.deleteFileIfExist(
        pathFileName:
            "$localPlaylistPath${path.separator}${localPlaylistMp3Lst[0]}",
      );

      // *** Updating the local playlist

      // Tap the 'Toggle List' button to display the playlist list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the audio
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
      // deleted audio

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
      await tester.pumpAndSettle();

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
          'Playable audio list for playlist "$localPlaylistTitle" was updated. 1 audio(s) were removed.');

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Test that the local playlist is no longer showing the
      // deleted audio

      int indexOfDeletedAudio = 0;

      for (String audioTitle in localPlaylistMp3Lst) {
        audioTitle = audioTitle
            .replaceAll(RegExp(r'[\d\-]'), '')
            .replaceFirst(' .mp', '')
            .replaceFirst(' fois', '3 fois')
            .replaceFirst('antinuke', 'anti-nuke');
        final Finder audioListTileTextWidgetFinder = find.text(audioTitle);

        if (indexOfDeletedAudio == 0) {
          expect(audioListTileTextWidgetFinder, findsNothing);
        } else {
          expect(audioListTileTextWidgetFinder, findsOneWidget);
        }

        indexOfDeletedAudio++;
      }

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen

      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Verify the displayed selected audio title
      expect(
          find.text(
              "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)\n20:32"),
          findsOneWidget);

      await IntegrationTestUtil.verifyTopButtonsState(
        tester: tester,
        isEnabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        setAudioSpeedTextButtonValue: '1.25x',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('''Executing update playlist JSON files after manually adding or
         deleting playlist directory and deleting audio files in other
         playlists test''', () {
    testWidgets(
        '''Manually delete all audio files in existing playlist and manually
           add a Youtube playlist directory.''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen in order to verify the current playable
      // audio

      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Verify the displayed current audio title
      expect(
          find.text(
              "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)\n20:32"),
          findsOneWidget);

      // And return to the playlist download view
      Finder playlistDownloadViewNavButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(playlistDownloadViewNavButton);
      await tester.pumpAndSettle();

      String s8AudioYoutubePlaylistPath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}$s8AudioYoutubePlaylistTitle';

      List<String> s8AudioYoutubePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath: s8AudioYoutubePlaylistPath,
        fileExtension: 'mp3',
      );

      // *** Manually deleting audio files from S8 Audio Youtube
      // playlist directory

      DirUtil.deleteMp3FilesInDir(
        s8AudioYoutubePlaylistPath,
      );

      // Test that the S8 Audio Youtube playlist is still showing the
      // deleted audio

      for (String audioTitle in s8AudioYoutubePlaylistMp3Lst) {
        audioTitle = audioTitle
            .replaceAll(RegExp(r'[\d\-]'), '')
            .replaceFirst(' .mp', '')
            .replaceFirst(' fois', '3 fois')
            .replaceFirst('antinuke', 'anti-nuke');
        final Finder audioListTileTextWidgetFinder = find.text(audioTitle);

        expect(audioListTileTextWidgetFinder, findsOneWidget);
      }

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen in order to verify that current playable
      // audio is still displayed, even if the audio was manually deleted

      appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Verify the displayed current audio title
      expect(
          find.text(
              "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)\n20:32"),
          findsOneWidget);

      // And return to the playlist download view
      playlistDownloadViewNavButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(playlistDownloadViewNavButton);
      await tester.pumpAndSettle();

      // *** Now, manually add the urgent_actus Youtube playlist directory
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}manually_added_playlist_dir",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // *** Now execute Updating playlist JSON file menu item

      // Tap the appbar leading popup menu button
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // Test that the S8 Audio Youtube playlist is no longer showing the
      // deleted audio

      for (String audioTitle in s8AudioYoutubePlaylistMp3Lst) {
        audioTitle = audioTitle
            .replaceAll(RegExp(r'[\d\-]'), '')
            .replaceFirst(' .mp', '')
            .replaceFirst(' fois', '3 fois')
            .replaceFirst('antinuke', 'anti-nuke');
        final Finder audioListTileTextWidgetFinder = find.text(audioTitle);

        expect(audioListTileTextWidgetFinder, findsNothing);
      }

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen in order to verify that "No audio
      // selected" is displayed

      appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Verify the no selected audio title is displayed
      expect(find.text("No audio selected"), findsOneWidget);

      // And return to the playlist download view
      playlistDownloadViewNavButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(playlistDownloadViewNavButton);
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

      // Test that the audio of the added urgent_actus Youtube playlist
      // are listed

      String urgentActusyoutubeplaylistpath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}$urgentActusyoutubeplaylisttitle';

      List<String> urgentActusyoutubeplaylistmp3lst =
          DirUtil.listFileNamesInDir(
        directoryPath: urgentActusyoutubeplaylistpath,
        fileExtension: 'mp3',
      );

      for (String audioTitle in urgentActusyoutubeplaylistmp3lst) {
        audioTitle = audioTitle
            .replaceAll(RegExp(r'[\d\-]'), '')
            .replaceFirst(' .mp', '')
            .replaceFirst(' fois', '3 fois');
        final Finder audioListTileTextWidgetFinder = find.text(audioTitle);

        expect(audioListTileTextWidgetFinder, findsOneWidget);
      }

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen in order to verify the current playable
      // audio of the manually added playlist

      appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Verify the displayed current audio title
      expect(
          find.text(
              'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau\n6:29'),
          findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('Manually add copied smartphone local playlist directory.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Manually add the local 'test' playlist directory which were copied
      // from a smartphone
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}manually_added_smartphone_local_playlist_dir",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // *** Execute Updating playlist JSON file menu item

      // Tap the appbar leading popup menu button
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // Test that the manually added test local smartphone playlist is
      // displayed

      // Tap the 'Toggle List' button to show the list of playlists. If the
      // list is not opened, checking that a ListTile with the title of
      // the manually added playlist was added to the ListView will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the manually added Youtube
      // playlist

      const String testLocalPlaylistTitle = 'test';

      // First, find the 'test' local playlist ListTile Text widget
      final Finder testLocalPlaylistTileTextWidgetFinder =
          find.text(testLocalPlaylistTitle);

      // Then obtain the 'test' source playlist ListTile widget
      // enclosing the Text widget by finding its ancestor
      final Finder testLocalPlaylistTileWidgetFinder = find.ancestor(
        of: testLocalPlaylistTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Ensure the new playlist has been unselected
      Finder localPlaylistListTileCheckboxWidgetFinder =
          await ensurePlaylistCheckboxIsNotChecked(
        playlistListTileWidgetFinder: testLocalPlaylistTileWidgetFinder,
        widgetTester: tester,
      );

      await tester.tap(localPlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Test that the audio of the added 'test' local playlist are
      // listed

      String testLocalPlaylistPath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}$testLocalPlaylistTitle';

      List<String> testLocalPlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath: testLocalPlaylistPath,
        fileExtension: 'mp3',
      );

      for (String audioTitle in testLocalPlaylistMp3Lst) {
        audioTitle = audioTitle
            .replaceAll(RegExp(r'[\d]'), '')
            .replaceAll(RegExp(r'\-\-'), '')
            .replaceFirst(' .mp', '')
            .replaceFirst(' minutes', '5 minutes');
        final Finder audioListTileTextWidgetFinder = find.text(audioTitle);

        expect(audioListTileTextWidgetFinder, findsOneWidget);
      }

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen in order to verify the current playable
      // audio of the added playlist

      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Verify the displayed current audio title
      expect(
          find.text(
              "Quand les humoristes parlent d'écologie - Thomas VDB, Félix Djhan, Pierre Thévenoux\n5:39"),
          findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('Manually add copied smartphone Youtube playlist directory.',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Manually add the Youtube 'Youtube_test' playlist directory which
      // were copied from a smartphone
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}manually_added_smartphone_Youtube_playlist_dir",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // *** Execute Updating playlist JSON file menu item

      // Tap the appbar leading popup menu button
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // Test that the manually added Youtube_test Youtube smartphone
      // playlist is displayed

      // Tap the 'Toggle List' button to show the list of playlists. If the
      // list is not opened, checking that a ListTile with the title of
      // the manually added playlist was added to the ListView will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the ListTile Playlist containing the manually added Youtube
      // playlist

      const String testYoutubePlaylistTitle = 'Youtube_test';

      // First, find the 'Youtube_test' Youtube playlist ListTile Text
      // widget
      final Finder testYoutubePlaylistTileTextWidgetFinder =
          find.text(testYoutubePlaylistTitle);

      // Then obtain the 'Youtube_test' source playlist ListTile widget
      // enclosing the Text widget by finding its ancestor
      final Finder testYoutubePlaylistTileWidgetFinder = find.ancestor(
        of: testYoutubePlaylistTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Ensure the new playlist has been unselected
      Finder youtubePlaylistListTileCheckboxWidgetFinder =
          await ensurePlaylistCheckboxIsNotChecked(
        playlistListTileWidgetFinder: testYoutubePlaylistTileWidgetFinder,
        widgetTester: tester,
      );

      await tester.tap(youtubePlaylistListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Test that the audio of the added 'Youtube_test' Youtube playlist
      // are listed

      String testYoutubePlaylistPath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}$testYoutubePlaylistTitle';

      List<String> testYoutubePlaylistMp3Lst = DirUtil.listFileNamesInDir(
        directoryPath: testYoutubePlaylistPath,
        fileExtension: 'mp3',
      );

      for (String audioTitle in testYoutubePlaylistMp3Lst) {
        audioTitle = audioTitle
            .replaceAll(RegExp(r'[\d]'), '')
            .replaceAll(RegExp(r'\-\-'), '')
            .replaceFirst(' .mp', '')
            .replaceFirst(' minutes', '5 minutes');
        final Finder audioListTileTextWidgetFinder = find.text(audioTitle);

        expect(audioListTileTextWidgetFinder, findsOneWidget);
      }

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen in order to verify the current playable
      // audio of the added playlist

      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Verify the displayed current audio title
      expect(
          find.text(
              "5 minutes d'éco-anxiété pour se motiver à bouger (Ringenbach, Janco, Barrau, Servigne)\n7:21"),
          findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Manually delete all application data including the settings.json file
           and then execute update playlist JSON files''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlists. If the
      // list is not opened, checking that a ListTile with the title of
      // the manually added playlist was added to the ListView will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Obtains all the ListTile widgets present in the playlist
      // download view (2 playlist items + 4 audio items)
      Finder listTilesFinder = find.byType(ListTile);
      expect(listTilesFinder, findsNWidgets(5));

      // Now manually delete all application data including the settings.json
      // file
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // *** Execute Updating playlist JSON file menu item

      // Tap the appbar leading popup menu button
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // Now verify that no more ListItem widget is displayed in the download
      // playlist view
      listTilesFinder = find.byType(ListTile);
      expect(listTilesFinder, findsNWidgets(0));

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen in order to verify that "No audio
      // selected" is displayed

      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Verify the no selected audio title is displayed
      expect(find.text("No audio selected"), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('''Manually delete Youtube playlist directory after adding it
           manually.''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // *** Manually add the urgent_actus Youtube playlist directory
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}manually_added_playlist_dir",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // *** Execute Updating playlist JSON file menu item

      // Tap the appbar leading popup menu button
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
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

      // Test that the audio of the added urgent_actus Youtube playlist
      // are listed

      String urgentActusyoutubeplaylistpath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}$urgentActusyoutubeplaylisttitle';

      List<String> urgentActusyoutubeplaylistmp3lst =
          DirUtil.listFileNamesInDir(
        directoryPath: urgentActusyoutubeplaylistpath,
        fileExtension: 'mp3',
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

      // Tap the appbar leading popup menu button
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
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
      );
    });
    testWidgets(
        '''Manually delete Youtube playlist directory with playlist expanded
           list closed after adding it manually.''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // *** Manually add the urgent_actus Youtube playlist directory
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}manually_added_playlist_dir",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // *** Execute Updating playlist JSON file menu item

      // Tap the appbar leading popup menu button
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
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

      // Test that the audio of the added urgent_actus Youtube playlist
      // are listed

      String urgentActusyoutubeplaylistpath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}$urgentActusyoutubeplaylisttitle';

      List<String> urgentActusyoutubeplaylistmp3lst =
          DirUtil.listFileNamesInDir(
        directoryPath: urgentActusyoutubeplaylistpath,
        fileExtension: 'mp3',
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

      // Tap the appbar leading popup menu button
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
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
      );
    });
    testWidgets(
        '''With Playlist list displayed, execute update playlist json file
           after deleting all files in app audio dir and verify audio menu
           state. Do same after re-adding app audio dir files.''',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
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
      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: false,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Now delete all the files in the app audio directory
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // *** Execute Updating playlist JSON file menu item

      // Tap twice on the appbar leading popup menu button. First tap
      // closes the audio popup menu and the second tap opens the
      // leading popup menu
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // Now tap on the audio menu button to re-open the audio menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are now disabled
      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Now restore the app data in the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // *** Execute again Updating playlist JSON file menu item

      // Tap twice on the appbar leading popup menu button. First tap
      // closes the audio popup menu and the second tap opens the
      // leading popup menu
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // open the popup menu again
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are still disabled since the
      // re-added playlist were no longer in the app settings sorted
      // playlist titles and so were added to the application being
      // deselected. This is due to the fact that any playlist added
      // by the update playlist JSON file fumctionality is deselected
      // in order that only one playlist is selected after the update.
      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''With Playlist list not displayed, execute update playlist json
           file after deleting all files in app audio dir and verify audio
           menu state. Do same after re-adding app audio dir files.''',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
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

      // Now tap on the audio menu button to re-open the audio menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are enabled
      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: false,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Now delete all the files in the app audio directory
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // *** Execute Updating playlist JSON file menu item

      // Tap twice on the appbar leading popup menu button. First tap
      // closes the audio popup menu and the second tap opens the
      // leading popup menu
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // Now tap on the audio menu button to re-open the audio menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are now disabled
      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Now restore the app data in the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // *** Execute again Updating playlist JSON file menu item

      // Tap twice on the appbar leading popup menu button. First tap
      // closes the audio popup menu and the second tap opens the
      // leading popup menu
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // open the popup menu again
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are still disabled since the
      // re-added playlist were no longer in the app settings sorted
      // playlist titles and so were added to the application being
      // deselected. This is due to the fact that any playlist added
      // by the update playlist JSON file fumctionality is deselected
      // in order that only one playlist is selected after the update.
      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''With Playlist list displayed and selected playlist empty, execute
           update playlist json file after deleting all files in app audio
           dir and verify audio menu state. Do same after re-adding app audio
           dir files.''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
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
      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Now delete all the files in the app audio directory
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // *** Execute Updating playlist JSON file menu item

      // Tap twice on the appbar leading popup menu button. First tap
      // closes the audio popup menu and the second tap opens the
      // leading popup menu
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // Now tap on the audio menu button to open the audio menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are now disabled
      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Now restore the app data in the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_empty_selected_playlist_widget_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // *** Execute again Updating playlist JSON file menu item

      // Tap twice on the appbar leading popup menu button. First tap
      // closes the audio popup menu and the second tap opens the
      // leading popup menu
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // open the popup menu again
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are now enabled
      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('''With Playlist list not displayed and selected playlist empty,
           execute update playlist json file after deleting all files in
           app audio dir and verify audio menu state. Do same after re-adding
           app audio dir files.''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
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

      // Now tap on the audio menu button to re-open the audio menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are disabled
      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Now delete all the files in the app audio directory
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // *** Execute Updating playlist JSON file menu item

      // Tap twice on the appbar leading popup menu button. First tap
      // closes the audio popup menu and the second tap opens the
      // leading popup menu
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // Now tap on the audio menu button to re-open the audio menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are now disabled
      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Now restore the app data in the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_empty_selected_playlist_widget_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // *** Execute again Updating playlist JSON file menu item

      // Tap twice on the appbar leading popup menu button. First tap
      // closes the audio popup menu and the second tap opens the
      // leading popup menu
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle();

      // open the popup menu again
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Ensure that the audio menu items are disabled
      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('''After copying playlist json file over the playlist json
                   file of an existing playlist. In the copied playlist json
                   file, the current or past playable audio is different. This
                   test demonstrates that after executing the update playlist
                   JSON file menu item, the current playlist audio displayed
                   in the audio player screen corresponds to the current audio
                   defined in the copied playlist JSON file.''',
        (WidgetTester tester) async {
      const String emptyPlaylistTitle = 'Empty'; // Youtube playlist
      const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
      const String firstDownloadedAudioTitle =
          "La surpopulation mondiale par Jancovici et Barrau";
      const String secondDownloadedAudioTitle =
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'update_playlist_json_file',
        selectedPlaylistTitle: emptyPlaylistTitle,
      );

      // Select the 'S8 audio' playlist

      // First, find the playlist to select ListTile Text widget
      Finder playlistToSelectListTileTextWidgetFinder =
          find.text(youtubePlaylistTitle);

      // Then obtain the playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      Finder playlistToSelectListTileWidgetFinder = find.ancestor(
        of: playlistToSelectListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the playlist ListTile
      // and tap on it to select the playlist
      Finder playlistToSelectListTileCheckboxWidgetFinder = find.descendant(
        of: playlistToSelectListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to select it
      await tester.tap(playlistToSelectListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Now tap on playlist download view playlist button to close the
      // playlist list so that all the 'S8 audio' audio are displayed
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio to be
      // selected and tap on it. This switches to the AudioPlayerView
      // and sets the playlist current or past playable audio index to 0
      await tester.tap(find.text(firstDownloadedAudioTitle));
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Verify the displayed audio title (La surpopulation mondiale par
      // Jancovici et Barrau)

      Finder audioPlayerViewAudioTitleFinder =
          find.byKey(const Key('audioPlayerViewCurrentAudioTitle'));
      String audioTitleWithDurationString =
          tester.widget<Text>(audioPlayerViewAudioTitleFinder).data!;

      String expectedAudioAndDurationTitle = "$firstDownloadedAudioTitle\n7:38";

      // Now, manually copy the 'S8 audio' Youtube playlist directory,
      // but first delete the dir, otherwise the playlist JSON file
      // will not be updated.

      String playlistS8audioDir =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio";

      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: playlistS8audioDir,
      );

      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}update_playlist_json_file${path.separator}S8 audio",
        destinationRootPath: playlistS8audioDir,
      );

      // Then return to playlist download view in order to execute
      // the playlist JSON files update
      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Tap on the appbar leading popup menu button to open the leading
      // popup menu
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // find the update playlist JSON file menu item and tap on it
      await tester
          .tap(find.byKey(const Key('update_playlist_json_dialog_item')));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Go to audio player view in order to verify the current playable
      // audio of the selected Youtube playlist
      appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Verify the displayed audio title (Jancovici m'explique l’importance
      // des ordres de grandeur face au changement climatique)

      audioPlayerViewAudioTitleFinder =
          find.byKey(const Key('audioPlayerViewCurrentAudioTitle'));
      audioTitleWithDurationString =
          tester.widget<Text>(audioPlayerViewAudioTitleFinder).data!;

      expectedAudioAndDurationTitle = "$secondDownloadedAudioTitle\n6:29";

      expect(
        audioTitleWithDurationString,
        expectedAudioAndDurationTitle,
        reason:
            "The actual audio title and duration $audioTitleWithDurationString displayed in the AudioPlayerView screen isn't the expected value $expectedAudioAndDurationTitle.",
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('Delete unique audio test', () {
    group('In playlist download view', () {
      group('Using SF parms, delete unique audio test', () {
        testWidgets(
            '''SF parms 'default' is applied. Then, click on the menu icon of the
           commented audio "Les besoins artificiels par R.Keucheyan" and select
           'Delete Audio ...'. Verify the displayed warning. Then click on the
           'Confirm' button. Verify the suppression of the audio mp3 file as well
           as its comment file. Verify also the updated playlist playable audio
           list.''', (tester) async {
          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'delete_filtered_audio_test',
            tapOnPlaylistToggleButton: false,
          );

          const String youtubePlaylistTitle = 'S8 audio';

          String defaultSortFilterParmName =
              'default'; // SF parm when opening the app

          // Verify the presence of the audio file which will be later deleted

          String audioFileNameToDelete =
              "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.mp3";

          List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
            fileExtension: 'mp3',
          );

          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            true,
          );

          // Verify the presence of the audio comment files which will be later
          // deleted

          String audioCommentFileNameToDelete =
              "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.json";

          List<String> listCommentJsonFileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio${path.separator}$kCommentDirName",
            fileExtension: 'json',
          );

          expect(
            listCommentJsonFileNames.contains(audioCommentFileNameToDelete),
            true,
          );

          String commentedAudioTitleToDelete =
              "Les besoins artificiels par R.Keucheyan";

          // First, find the Audio sublist ListTile Text widget
          final Finder commentedAudioTitleToDeleteListTileTextWidgetFinder =
              find.text(commentedAudioTitleToDelete);

          // Then obtain the Audio ListTile widget enclosing the Text widget by
          // finding its ancestor
          final Finder commentedAudioTitleToDeleteListTileWidgetFinder =
              find.ancestor(
            of: commentedAudioTitleToDeleteListTileTextWidgetFinder,
            matching: find.byType(ListTile),
          );

          // Now find the leading menu icon button of the Audio ListTile
          // and tap on it
          final Finder
              commentedAudioTitleToDeleteListTileLeadingMenuIconButton =
              find.descendant(
            of: commentedAudioTitleToDeleteListTileWidgetFinder,
            matching: find.byIcon(Icons.menu),
          );

          // Tap the leading menu icon button to open the popup menu
          await tester
              .tap(commentedAudioTitleToDeleteListTileLeadingMenuIconButton);
          await tester.pumpAndSettle();

          // Now find the delete audio popup menu item and tap on it
          final Finder popupCopyMenuItem =
              find.byKey(const Key("popup_menu_delete_audio"));

          await tester.tap(popupCopyMenuItem);
          await tester.pumpAndSettle();

          // Verifying the confirm dialog title

          final Text deleteFilteredAudioConfirmDialogTitleWidget = tester
              .widget<Text>(find.byKey(const Key('confirmDialogTitleOneKey')));

          expect(deleteFilteredAudioConfirmDialogTitleWidget.data,
              'Confirm deletion of the commented audio "$commentedAudioTitleToDelete"');

          // Verifying the confirm dialog message

          final Text deleteFilteredAudioConfirmDialogMessageTextWidget =
              tester.widget<Text>(
                  find.byKey(const Key('confirmationDialogMessageKey')));

          expect(deleteFilteredAudioConfirmDialogMessageTextWidget.data,
              'The audio contains 1 comment(s) which will be deleted as well. Confirm deletion ?');

          // Now find the confirm button of the delete filtered audio confirm
          // dialog and tap on it
          await tester.tap(find.byKey(const Key('confirmButton')));
          await tester.pumpAndSettle();

          // Verify that the applyed Sort/Filter parms name is displayed
          // after the selected playlist title

          Text selectedSortFilterParmsName = tester
              .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

          expect(
            selectedSortFilterParmsName.data,
            defaultSortFilterParmName,
          );

          // Verify that the audio file was deleted

          listMp3FileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
            fileExtension: 'mp3',
          );

          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            false,
          );

          // Verify that the audio comment files were deleted

          listCommentJsonFileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio${path.separator}$kCommentDirName",
            fileExtension: 'json',
          );

          expect(
            listCommentJsonFileNames.contains(audioCommentFileNameToDelete),
            false,
          );

          // Verify the 'S8 audio' playlist json file

          Playlist loadedPlaylist = loadPlaylist(youtubePlaylistTitle);

          expect(loadedPlaylist.downloadedAudioLst.length, 18);

          List<String> downloadedAudioLst = loadedPlaylist.downloadedAudioLst
              .map((Audio audio) => audio.validVideoTitle)
              .toList();

          expect(
            downloadedAudioLst.contains(commentedAudioTitleToDelete),
            true,
          );

          List<String> playableAudioLst = loadedPlaylist.playableAudioLst
              .map((Audio audio) => audio.validVideoTitle)
              .toList();

          expect(
            playableAudioLst.contains(commentedAudioTitleToDelete),
            false,
          );

          // Setting to this variables the currently selected audio title/subTitle
          // of the 'S8 audio' playlist
          String currentAudioTitle = "La résilience insulaire par Fiona Roche";
          String currentAudioSubTitle =
              "0:13:35.0. 4.97 MB at 2.67 MB/sec on 07/01/2024 at 08:16.";

          // Verify that the current audio is displayed with the correct
          // title and subtitle color
          await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
            tester: tester,
            currentAudioTitle: currentAudioTitle,
            currentAudioSubTitle: currentAudioSubTitle,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
        testWidgets(
            '''SF parms 'default' is applied. Then, click on the menu icon of the
           uncommented audio "Les besoins artificiels par R.Keucheyan" which is
           uncommented in 'delete_filtered_audio_one_uncommented_more_test') and
           select 'Delete Audio ...'. Verify the suppression of the audio mp3. Verify
           also the updated playlist playable audio list and the new not totally
           played selected audio and the new not totally played selected audio.''',
            (tester) async {
          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName:
                'delete_filtered_audio_one_uncommented_more_test',
            tapOnPlaylistToggleButton: false,
          );

          const String youtubePlaylistTitle = 'S8 audio';

          String defaultSortFilterParmName =
              'default'; // SF parm when opening the app

          // Verify the presence of the audio file which will be later deleted

          String audioFileNameToDelete =
              "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.mp3";

          List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
            fileExtension: 'mp3',
          );

          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            true,
          );

          String uncommentedAudioTitleToDelete =
              "Les besoins artificiels par R.Keucheyan";

          // First, find the Audio sublist ListTile Text widget
          final Finder commentedAudioTitleToDeleteListTileTextWidgetFinder =
              find.text(uncommentedAudioTitleToDelete);

          // Then obtain the Audio ListTile widget enclosing the Text widget by
          // finding its ancestor
          final Finder commentedAudioTitleToDeleteListTileWidgetFinder =
              find.ancestor(
            of: commentedAudioTitleToDeleteListTileTextWidgetFinder,
            matching: find.byType(ListTile),
          );

          // Now find the leading menu icon button of the Audio ListTile
          // and tap on it
          final Finder
              commentedAudioTitleToDeleteListTileLeadingMenuIconButton =
              find.descendant(
            of: commentedAudioTitleToDeleteListTileWidgetFinder,
            matching: find.byIcon(Icons.menu),
          );

          // Tap the leading menu icon button to open the popup menu
          await tester
              .tap(commentedAudioTitleToDeleteListTileLeadingMenuIconButton);
          await tester.pumpAndSettle();

          // Now find the delete audio popup menu item and tap on it
          final Finder popupCopyMenuItem =
              find.byKey(const Key("popup_menu_delete_audio"));

          await tester.tap(popupCopyMenuItem);
          await tester.pumpAndSettle();

          // Verify that the applyed Sort/Filter parms name is displayed
          // after the selected playlist title

          Text selectedSortFilterParmsName = tester
              .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

          expect(
            selectedSortFilterParmsName.data,
            defaultSortFilterParmName,
          );

          // Verify that the audio file was deleted

          listMp3FileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
            fileExtension: 'mp3',
          );

          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            false,
          );

          // Verify the 'S8 audio' playlist json file

          Playlist loadedPlaylist = loadPlaylist(youtubePlaylistTitle);

          expect(loadedPlaylist.downloadedAudioLst.length, 18);

          List<String> downloadedAudioLst = loadedPlaylist.downloadedAudioLst
              .map((Audio audio) => audio.validVideoTitle)
              .toList();

          expect(
            downloadedAudioLst.contains(uncommentedAudioTitleToDelete),
            true,
          );

          List<String> playableAudioLst = loadedPlaylist.playableAudioLst
              .map((Audio audio) => audio.validVideoTitle)
              .toList();

          expect(
            playableAudioLst.contains(uncommentedAudioTitleToDelete),
            false,
          );

          // Setting to this variables the currently selected audio title/subTitle
          // of the 'S8 audio' playlist
          String currentAudioTitle = "La résilience insulaire par Fiona Roche";
          String currentAudioSubTitle =
              "0:13:35.0. 4.97 MB at 2.67 MB/sec on 07/01/2024 at 08:16.";

          // Verify that the current audio is displayed with the correct
          // title and subtitle color
          await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
            tester: tester,
            currentAudioTitle: currentAudioTitle,
            currentAudioSubTitle: currentAudioSubTitle,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
        testWidgets(
            '''Defined SF parms 'applied' is applied. Then, click on the menu icon of the
           commented audio "Les besoins artificiels par R.Keucheyan" and select
           'Delete Audio ...'. Verify the displayed warning. Then click on the
           'Confirm' button. Verify the suppression of the audio mp3 file as well
           as its comment file. Verify also the updated playlist playable audio
           list.''', (tester) async {
          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'delete_filtered_audio_test',
            tapOnPlaylistToggleButton: false,
          );

          const String youtubePlaylistTitle = 'S8 audio';

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Now select the 'Audio title'item in the 'Sort by' dropdown button

          await tester
              .tap(find.byKey(const Key('sortingOptionDropdownButton')));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Audio title'));
          await tester.pumpAndSettle();

          // Then delete the "Audio download date" descending sort option

          // Find the Text with "Audio downl date" which is located in the
          // selected sort parameters ListView
          final Finder textFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Audio downl date'),
          );

          // Then find the ListTile ancestor of the 'Audio downl date' Text
          // widget. The ascending/descending and remove icon buttons are
          // contained in their ListTile ancestor
          final Finder listTileFinder = find.ancestor(
            of: textFinder,
            matching: find.byType(ListTile),
          );

          // Now, within that ListTile, find the sort option delete IconButton
          // with key 'removeSortingOptionIconButton'
          final Finder iconButtonFinder = find.descendant(
            of: listTileFinder,
            matching: find.byKey(const Key('removeSortingOptionIconButton')),
          );

          // Tap on the delete icon button to delete the 'Audio downl date'
          // descending sort option
          await tester.tap(iconButtonFinder);
          await tester.pumpAndSettle();

          // Click on the "Apply" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('applySortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          String appliedSortFilterParmName =
              'applied'; // SF parm after clicking on 'Apply' in SF Dialog

          // Verify the presence of the audio file which will be later deleted

          String audioFileNameToDelete =
              "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.mp3";

          List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
            fileExtension: 'mp3',
          );

          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            true,
          );

          // Verify the presence of the audio comment files which will be later
          // deleted

          String audioCommentFileNameToDelete =
              "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.json";

          List<String> listCommentJsonFileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio${path.separator}$kCommentDirName",
            fileExtension: 'json',
          );

          expect(
            listCommentJsonFileNames.contains(audioCommentFileNameToDelete),
            true,
          );

          String commentedAudioTitleToDelete =
              "Les besoins artificiels par R.Keucheyan";

          // First, find the Audio sublist ListTile Text widget
          final Finder commentedAudioTitleToDeleteListTileTextWidgetFinder =
              find.text(commentedAudioTitleToDelete);

          // Then obtain the Audio ListTile widget enclosing the Text widget by
          // finding its ancestor
          final Finder commentedAudioTitleToDeleteListTileWidgetFinder =
              find.ancestor(
            of: commentedAudioTitleToDeleteListTileTextWidgetFinder,
            matching: find.byType(ListTile),
          );

          // Now find the leading menu icon button of the Audio ListTile
          // and tap on it
          final Finder
              commentedAudioTitleToDeleteListTileLeadingMenuIconButton =
              find.descendant(
            of: commentedAudioTitleToDeleteListTileWidgetFinder,
            matching: find.byIcon(Icons.menu),
          );

          // Scrolling down the audios list in order to display the commented
          // audio title to delete

          // Find the audio list widget using its key
          final Finder listFinder = find.byKey(const Key('audio_list'));

          // Perform the scroll action
          await tester.drag(listFinder, const Offset(0, -1000));
          await tester.pumpAndSettle();

          // Tap the leading menu icon button to open the popup menu
          await tester
              .tap(commentedAudioTitleToDeleteListTileLeadingMenuIconButton);
          await tester.pumpAndSettle();

          // Now find the delete audio popup menu item and tap on it
          final Finder popupCopyMenuItem =
              find.byKey(const Key("popup_menu_delete_audio"));

          await tester.tap(popupCopyMenuItem);
          await tester.pumpAndSettle();

          // Verifying the confirm dialog title

          final Text deleteFilteredAudioConfirmDialogTitleWidget = tester
              .widget<Text>(find.byKey(const Key('confirmDialogTitleOneKey')));

          expect(deleteFilteredAudioConfirmDialogTitleWidget.data,
              'Confirm deletion of the commented audio "$commentedAudioTitleToDelete"');

          // Verifying the confirm dialog message

          final Text deleteFilteredAudioConfirmDialogMessageTextWidget =
              tester.widget<Text>(
                  find.byKey(const Key('confirmationDialogMessageKey')));

          expect(deleteFilteredAudioConfirmDialogMessageTextWidget.data,
              'The audio contains 1 comment(s) which will be deleted as well. Confirm deletion ?');

          // Now find the confirm button of the delete filtered audio confirm
          // dialog and tap on it
          await tester.tap(find.byKey(const Key('confirmButton')));
          await tester.pumpAndSettle();

          // Verify that the applyed Sort/Filter parms name is displayed
          // after the selected playlist title

          Text selectedSortFilterParmsName = tester
              .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

          expect(
            selectedSortFilterParmsName.data,
            appliedSortFilterParmName,
          );

          // Verify that the audio file was deleted

          listMp3FileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
            fileExtension: 'mp3',
          );

          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            false,
          );

          // Verify that the audio comment files were deleted

          listCommentJsonFileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio${path.separator}$kCommentDirName",
            fileExtension: 'json',
          );

          expect(
            listCommentJsonFileNames.contains(audioCommentFileNameToDelete),
            false,
          );

          // Verify the 'S8 audio' playlist json file

          Playlist loadedPlaylist = loadPlaylist(youtubePlaylistTitle);

          expect(loadedPlaylist.downloadedAudioLst.length, 18);

          List<String> downloadedAudioLst = loadedPlaylist.downloadedAudioLst
              .map((Audio audio) => audio.validVideoTitle)
              .toList();

          expect(
            downloadedAudioLst.contains(commentedAudioTitleToDelete),
            true,
          );

          List<String> playableAudioLst = loadedPlaylist.playableAudioLst
              .map((Audio audio) => audio.validVideoTitle)
              .toList();

          expect(
            playableAudioLst.contains(commentedAudioTitleToDelete),
            false,
          );

          // Setting to this variables the currently selected audio title/subTitle
          // of the 'S8 audio' playlist
          String currentAudioTitle = "La résilience insulaire par Fiona Roche";
          String currentAudioSubTitle =
              "0:13:35.0. 4.97 MB at 2.67 MB/sec on 07/01/2024 at 08:16.";

          // Verify that the current audio is displayed with the correct
          // title and subtitle color
          await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
            tester: tester,
            currentAudioTitle: currentAudioTitle,
            currentAudioSubTitle: currentAudioSubTitle,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
        testWidgets(
            '''Defined SF parms 'applied' is applied. Then, click on the menu icon of the
           uncommented audio "Les besoins artificiels par R.Keucheyan" and select
           'Delete Audio ...'. Verify the suppression of the audio mp3. Verify
           also the updated playlist playable audio list and the new not totally
           played selected audio and the new not totally played selected audio.''',
            (tester) async {
          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName:
                'delete_filtered_audio_one_uncommented_more_test',
            tapOnPlaylistToggleButton: false,
          );

          const String youtubePlaylistTitle = 'S8 audio';

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Now select the 'Audio title'item in the 'Sort by' dropdown button

          await tester
              .tap(find.byKey(const Key('sortingOptionDropdownButton')));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Audio title'));
          await tester.pumpAndSettle();

          // Then delete the "Audio download date" descending sort option

          // Find the Text with "Audio downl date" which is located in the
          // selected sort parameters ListView
          final Finder textFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Audio downl date'),
          );

          // Then find the ListTile ancestor of the 'Audio downl date' Text
          // widget. The ascending/descending and remove icon buttons are
          // contained in their ListTile ancestor
          final Finder listTileFinder = find.ancestor(
            of: textFinder,
            matching: find.byType(ListTile),
          );

          // Now, within that ListTile, find the sort option delete IconButton
          // with key 'removeSortingOptionIconButton'
          final Finder iconButtonFinder = find.descendant(
            of: listTileFinder,
            matching: find.byKey(const Key('removeSortingOptionIconButton')),
          );

          // Tap on the delete icon button to delete the 'Audio downl date'
          // descending sort option
          await tester.tap(iconButtonFinder);
          await tester.pumpAndSettle();

          // Click on the "Apply" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('applySortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          String appliedSortFilterParmName =
              'applied'; // SF parm after clicking on 'Apply' in SF Dialog

          // Verify the presence of the audio file which will be later deleted

          String audioFileNameToDelete =
              "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.mp3";

          List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
            fileExtension: 'mp3',
          );

          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            true,
          );

          // Scrolling down the audios list in order to display the commented
          // audio title to delete

          // Find the audio list widget using its key
          final Finder listFinder = find.byKey(const Key('audio_list'));

          // Perform the scroll action
          await tester.drag(listFinder, const Offset(0, -1000));
          await tester.pumpAndSettle();

          String uncommentedAudioTitleToDelete =
              "Les besoins artificiels par R.Keucheyan";

          // First, find the Audio sublist ListTile Text widget
          final Finder commentedAudioTitleToDeleteListTileTextWidgetFinder =
              find.text(uncommentedAudioTitleToDelete);

          // Then obtain the Audio ListTile widget enclosing the Text widget by
          // finding its ancestor
          final Finder commentedAudioTitleToDeleteListTileWidgetFinder =
              find.ancestor(
            of: commentedAudioTitleToDeleteListTileTextWidgetFinder,
            matching: find.byType(ListTile),
          );

          // Now find the leading menu icon button of the Audio ListTile
          // and tap on it
          final Finder
              commentedAudioTitleToDeleteListTileLeadingMenuIconButton =
              find.descendant(
            of: commentedAudioTitleToDeleteListTileWidgetFinder,
            matching: find.byIcon(Icons.menu),
          );

          // Tap the leading menu icon button to open the popup menu
          await tester
              .tap(commentedAudioTitleToDeleteListTileLeadingMenuIconButton);
          await tester.pumpAndSettle();

          // Now find the delete audio popup menu item and tap on it
          final Finder popupCopyMenuItem =
              find.byKey(const Key("popup_menu_delete_audio"));

          await tester.tap(popupCopyMenuItem);
          await tester.pumpAndSettle();

          // Verify that the applyed Sort/Filter parms name is displayed
          // after the selected playlist title

          Text selectedSortFilterParmsName = tester
              .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

          expect(
            selectedSortFilterParmsName.data,
            appliedSortFilterParmName,
          );

          // Verify that the audio file was deleted

          listMp3FileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
            fileExtension: 'mp3',
          );

          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            false,
          );

          // Verify the 'S8 audio' playlist json file

          Playlist loadedPlaylist = loadPlaylist(youtubePlaylistTitle);

          expect(loadedPlaylist.downloadedAudioLst.length, 18);

          List<String> downloadedAudioLst = loadedPlaylist.downloadedAudioLst
              .map((Audio audio) => audio.validVideoTitle)
              .toList();

          expect(
            downloadedAudioLst.contains(uncommentedAudioTitleToDelete),
            true,
          );

          List<String> playableAudioLst = loadedPlaylist.playableAudioLst
              .map((Audio audio) => audio.validVideoTitle)
              .toList();

          expect(
            playableAudioLst.contains(uncommentedAudioTitleToDelete),
            false,
          );

          // Setting to this variables the currently selected audio title/subTitle
          // of the 'S8 audio' playlist
          String currentAudioTitle = "La résilience insulaire par Fiona Roche";
          String currentAudioSubTitle =
              "0:13:35.0. 4.97 MB at 2.67 MB/sec on 07/01/2024 at 08:16.";

          // Verify that the current audio is displayed with the correct
          // title and subtitle color
          await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
            tester: tester,
            currentAudioTitle: currentAudioTitle,
            currentAudioSubTitle: currentAudioSubTitle,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
      });
      group(
          '''From playlist as well. Using SF parms, delete unique audio test from
             playlist as well''', () {
        testWidgets(
            '''SF parms 'default' is applied. Then, click on the menu icon of the
           commented audio "Les besoins artificiels par R.Keucheyan" and select
           'Delete Audio from Playlist as well ...'. Verify the displayed warning.
           Then click on the 'Confirm' button. Verify the suppression of the audio
           mp3 file as well as its comment file. Verify also the updated playlist
           playable audio list.''', (tester) async {
          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'delete_filtered_audio_test',
            tapOnPlaylistToggleButton: false,
          );

          const String youtubePlaylistTitle = 'S8 audio';

          String defaultSortFilterParmName =
              'default'; // SF parm when opening the app

          // Verify the presence of the audio file which will be later deleted

          String audioFileNameToDelete =
              "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.mp3";

          List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
            fileExtension: 'mp3',
          );

          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            true,
          );

          // Verify the presence of the audio comment files which will be later
          // deleted

          String audioCommentFileNameToDelete =
              "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.json";

          List<String> listCommentJsonFileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio${path.separator}$kCommentDirName",
            fileExtension: 'json',
          );

          expect(
            listCommentJsonFileNames.contains(audioCommentFileNameToDelete),
            true,
          );

          String commentedAudioTitleToDelete =
              "Les besoins artificiels par R.Keucheyan";

          // First, find the Audio sublist ListTile Text widget
          final Finder commentedAudioTitleToDeleteListTileTextWidgetFinder =
              find.text(commentedAudioTitleToDelete);

          // Then obtain the Audio ListTile widget enclosing the Text widget by
          // finding its ancestor
          final Finder commentedAudioTitleToDeleteListTileWidgetFinder =
              find.ancestor(
            of: commentedAudioTitleToDeleteListTileTextWidgetFinder,
            matching: find.byType(ListTile),
          );

          // Now find the leading menu icon button of the Audio ListTile
          // and tap on it
          final Finder
              commentedAudioTitleToDeleteListTileLeadingMenuIconButton =
              find.descendant(
            of: commentedAudioTitleToDeleteListTileWidgetFinder,
            matching: find.byIcon(Icons.menu),
          );

          // Tap the leading menu icon button to open the popup menu
          await tester
              .tap(commentedAudioTitleToDeleteListTileLeadingMenuIconButton);
          await tester.pumpAndSettle();

          // Now find the delete audio from playlist as well popup menu item
          // and tap on it
          final Finder popupCopyMenuItem = find
              .byKey(const Key("popup_menu_delete_audio_from_playlist_aswell"));

          await tester.tap(popupCopyMenuItem);
          await tester.pumpAndSettle();

          // Verifying the confirm dialog title

          final Text deleteFilteredAudioConfirmDialogTitleWidget = tester
              .widget<Text>(find.byKey(const Key('confirmDialogTitleOneKey')));

          expect(deleteFilteredAudioConfirmDialogTitleWidget.data,
              'Confirm deletion of the commented audio "$commentedAudioTitleToDelete"');

          // Verifying the confirm dialog message

          final Text deleteFilteredAudioConfirmDialogMessageTextWidget =
              tester.widget<Text>(
                  find.byKey(const Key('confirmationDialogMessageKey')));

          expect(deleteFilteredAudioConfirmDialogMessageTextWidget.data,
              'The audio contains 1 comment(s) which will be deleted as well. Confirm deletion ?');

          // Now find the confirm button of the delete filtered audio confirm
          // dialog and tap on it
          await tester.tap(find.byKey(const Key('confirmButton')));
          await tester.pumpAndSettle();

          // Check the value of the warning dialog title
          Text warningDialogTitle =
              tester.widget(find.byKey(const Key('warningDialogTitle')).at(1));
          expect(warningDialogTitle.data, 'WARNING');

          // Check the value of the warning dialog message
          Text warningDialogMessage =
              tester.widget(find.byKey(const Key('warningDialogMessage')).last);
          expect(warningDialogMessage.data,
              'If the deleted audio video "$commentedAudioTitleToDelete" remains in the "$youtubePlaylistTitle" Youtube playlist, it will be downloaded again the next time you download the playlist !');

          // Close the warning dialog by tapping on the Ok button
          await tester.tap(find.byKey(const Key('warningDialogOkButton')).last);
          await tester.pumpAndSettle();

          // Verify that the applyed Sort/Filter parms name is displayed
          // after the selected playlist title

          Text selectedSortFilterParmsName = tester
              .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

          expect(
            selectedSortFilterParmsName.data,
            defaultSortFilterParmName,
          );

          // Verify that the audio file was deleted

          listMp3FileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
            fileExtension: 'mp3',
          );

          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            false,
          );

          // Verify that the audio comment files were deleted

          listCommentJsonFileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio${path.separator}$kCommentDirName",
            fileExtension: 'json',
          );

          expect(
            listCommentJsonFileNames.contains(audioCommentFileNameToDelete),
            false,
          );

          // Verify the 'S8 audio' playlist json file

          Playlist loadedPlaylist = loadPlaylist(youtubePlaylistTitle);

          expect(loadedPlaylist.downloadedAudioLst.length, 17);

          List<String> downloadedAudioLst = loadedPlaylist.downloadedAudioLst
              .map((Audio audio) => audio.validVideoTitle)
              .toList();

          expect(
            downloadedAudioLst.contains(commentedAudioTitleToDelete),
            false,
          );

          List<String> playableAudioLst = loadedPlaylist.playableAudioLst
              .map((Audio audio) => audio.validVideoTitle)
              .toList();

          expect(
            playableAudioLst.contains(commentedAudioTitleToDelete),
            false,
          );

          // Setting to this variables the currently selected audio title/subTitle
          // of the 'S8 audio' playlist
          String currentAudioTitle = "La résilience insulaire par Fiona Roche";
          String currentAudioSubTitle =
              "0:13:35.0. 4.97 MB at 2.67 MB/sec on 07/01/2024 at 08:16.";

          // Verify that the current audio is displayed with the correct
          // title and subtitle color
          await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
            tester: tester,
            currentAudioTitle: currentAudioTitle,
            currentAudioSubTitle: currentAudioSubTitle,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
        testWidgets(
            '''SF parms 'default' is applied. Then, click on the menu icon of the
           uncommented audio "Les besoins artificiels par R.Keucheyan" which is
           uncommented in 'delete_filtered_audio_one_uncommented_more_test') and
           select 'Delete Audio from Playlist as well ...'. Verify the suppression
           of the audio mp3. Verify also the updated playlist playable audio list
           and the new not totally played selected audio and the new not totally
           played selected audio.''', (tester) async {
          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName:
                'delete_filtered_audio_one_uncommented_more_test',
            tapOnPlaylistToggleButton: false,
          );

          const String youtubePlaylistTitle = 'S8 audio';

          String defaultSortFilterParmName =
              'default'; // SF parm when opening the app

          // Verify the presence of the audio file which will be later deleted

          String audioFileNameToDelete =
              "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.mp3";

          List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
            fileExtension: 'mp3',
          );

          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            true,
          );

          String uncommentedAudioTitleToDelete =
              "Les besoins artificiels par R.Keucheyan";

          // First, find the Audio sublist ListTile Text widget
          final Finder commentedAudioTitleToDeleteListTileTextWidgetFinder =
              find.text(uncommentedAudioTitleToDelete);

          // Then obtain the Audio ListTile widget enclosing the Text widget by
          // finding its ancestor
          final Finder commentedAudioTitleToDeleteListTileWidgetFinder =
              find.ancestor(
            of: commentedAudioTitleToDeleteListTileTextWidgetFinder,
            matching: find.byType(ListTile),
          );

          // Now find the leading menu icon button of the Audio ListTile
          // and tap on it
          final Finder
              commentedAudioTitleToDeleteListTileLeadingMenuIconButton =
              find.descendant(
            of: commentedAudioTitleToDeleteListTileWidgetFinder,
            matching: find.byIcon(Icons.menu),
          );

          // Tap the leading menu icon button to open the popup menu
          await tester
              .tap(commentedAudioTitleToDeleteListTileLeadingMenuIconButton);
          await tester.pumpAndSettle();

          // Now find the delete audio from playlist as well popup menu item
          // and tap on it
          final Finder popupCopyMenuItem = find
              .byKey(const Key("popup_menu_delete_audio_from_playlist_aswell"));

          await tester.tap(popupCopyMenuItem);
          await tester.pumpAndSettle();

          // Check the value of the warning dialog title
          Text warningDialogTitle =
              tester.widget(find.byKey(const Key('warningDialogTitle')).last);
          expect(warningDialogTitle.data, 'WARNING');

          // Check the value of the warning dialog message
          Text warningDialogMessage =
              tester.widget(find.byKey(const Key('warningDialogMessage')).last);
          expect(warningDialogMessage.data,
              'If the deleted audio video "$uncommentedAudioTitleToDelete" remains in the "$youtubePlaylistTitle" Youtube playlist, it will be downloaded again the next time you download the playlist !');

          // Close the warning dialog by tapping on the Ok button
          await tester.tap(find.byKey(const Key('warningDialogOkButton')).last);
          await tester.pumpAndSettle();

          // Verify that the applyed Sort/Filter parms name is displayed
          // after the selected playlist title

          Text selectedSortFilterParmsName = tester
              .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

          expect(
            selectedSortFilterParmsName.data,
            defaultSortFilterParmName,
          );

          // Verify that the audio file was deleted

          listMp3FileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
            fileExtension: 'mp3',
          );

          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            false,
          );

          // Verify the 'S8 audio' playlist json file

          Playlist loadedPlaylist = loadPlaylist(youtubePlaylistTitle);

          expect(loadedPlaylist.downloadedAudioLst.length, 17);

          List<String> downloadedAudioLst = loadedPlaylist.downloadedAudioLst
              .map((Audio audio) => audio.validVideoTitle)
              .toList();

          expect(
            downloadedAudioLst.contains(uncommentedAudioTitleToDelete),
            false,
          );

          List<String> playableAudioLst = loadedPlaylist.playableAudioLst
              .map((Audio audio) => audio.validVideoTitle)
              .toList();

          expect(
            playableAudioLst.contains(uncommentedAudioTitleToDelete),
            false,
          );

          // Setting to this variables the currently selected audio title/subTitle
          // of the 'S8 audio' playlist
          String currentAudioTitle = "La résilience insulaire par Fiona Roche";
          String currentAudioSubTitle =
              "0:13:35.0. 4.97 MB at 2.67 MB/sec on 07/01/2024 at 08:16.";

          // Verify that the current audio is displayed with the correct
          // title and subtitle color
          await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
            tester: tester,
            currentAudioTitle: currentAudioTitle,
            currentAudioSubTitle: currentAudioSubTitle,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
        testWidgets(
            '''Saved defined SF parms 'Title asc' is applied. Then, click on the menu
           icon of the commented audio "Les besoins artificiels par R.Keucheyan"
           and select 'Delete Audio from Playlist as well ...'. Verify the displayed
           warning. Then click on the 'Confirm' button. Verify the suppression of
           the audio mp3 file as well as its comment file. Verify also the updated
           playlist playable audio list.''', (tester) async {
          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'delete_filtered_audio_test',
            tapOnPlaylistToggleButton: false,
          );

          const String youtubePlaylistTitle = 'S8 audio';

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type "Title asc" in the 'Save as' TextField

          String saveAsTitle = 'Title asc';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle();

          // Now select the 'Audio title'item in the 'Sort by' dropdown button

          await tester
              .tap(find.byKey(const Key('sortingOptionDropdownButton')));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Audio title'));
          await tester.pumpAndSettle();

          // Then delete the "Audio download date" descending sort option

          // Find the Text with "Audio downl date" which is located in the
          // selected sort parameters ListView
          final Finder textFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Audio downl date'),
          );

          // Then find the ListTile ancestor of the 'Audio downl date' Text
          // widget. The ascending/descending and remove icon buttons are
          // contained in their ListTile ancestor
          final Finder listTileFinder = find.ancestor(
            of: textFinder,
            matching: find.byType(ListTile),
          );

          // Now, within that ListTile, find the sort option delete IconButton
          // with key 'removeSortingOptionIconButton'
          final Finder iconButtonFinder = find.descendant(
            of: listTileFinder,
            matching: find.byKey(const Key('removeSortingOptionIconButton')),
          );

          // Tap on the delete icon button to delete the 'Audio downl date'
          // descending sort option
          await tester.tap(iconButtonFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Change unplayed to fully listened status of the "La
          // surpopulation mondiale par Jancovici et Barrau" audio

          String unplayedThenFullyListenedAudioTitle =
              "La surpopulation mondiale par Jancovici et Barrau";

          // Then, tap on the unplayed Audio ListTile Text widget finder to
          // select this unplayed audio. This switch to the audio player view.
          final Finder thirdDownloadedAudioListTileTextWidgetFinder =
              find.text(unplayedThenFullyListenedAudioTitle);

          await tester.tap(thirdDownloadedAudioListTileTextWidgetFinder);
          await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
            tester: tester,
          );

          // Then skip to the end of the audio to set it as fully played
          await tester
              .tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
          await tester.pumpAndSettle();

          // Now, go back to the playlist download view
          Finder audioPlayerNavButtonFinder =
              find.byKey(const ValueKey('playlistDownloadViewIconButton'));
          await tester.tap(audioPlayerNavButtonFinder);
          await tester.pumpAndSettle();

          // Verify the presence of the audio file which will be later deleted

          String audioFileNameToDelete =
              "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.mp3";

          List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
            fileExtension: 'mp3',
          );

          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            true,
          );

          // Verify the presence of the audio comment files which will be later
          // deleted

          String audioCommentFileNameToDelete =
              "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.json";

          List<String> listCommentJsonFileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio${path.separator}$kCommentDirName",
            fileExtension: 'json',
          );

          expect(
            listCommentJsonFileNames.contains(audioCommentFileNameToDelete),
            true,
          );

          String commentedAudioTitleToDelete =
              "Les besoins artificiels par R.Keucheyan";

          // First, find the Audio sublist ListTile Text widget
          final Finder commentedAudioTitleToDeleteListTileTextWidgetFinder =
              find.text(commentedAudioTitleToDelete);

          // Then obtain the Audio ListTile widget enclosing the Text widget by
          // finding its ancestor
          final Finder commentedAudioTitleToDeleteListTileWidgetFinder =
              find.ancestor(
            of: commentedAudioTitleToDeleteListTileTextWidgetFinder,
            matching: find.byType(ListTile),
          );

          // Now find the leading menu icon button of the Audio ListTile
          // and tap on it
          final Finder
              commentedAudioTitleToDeleteListTileLeadingMenuIconButton =
              find.descendant(
            of: commentedAudioTitleToDeleteListTileWidgetFinder,
            matching: find.byIcon(Icons.menu),
          );

          // Scrolling down the audios list in order to display the commented
          // audio title to delete

          // Find the audio list widget using its key
          final Finder listFinder = find.byKey(const Key('audio_list'));
          // Perform the scroll action
          await tester.drag(listFinder, const Offset(0, -1000));
          await tester.pumpAndSettle();

          // Tap the leading menu icon button to open the popup menu
          await tester
              .tap(commentedAudioTitleToDeleteListTileLeadingMenuIconButton);
          await tester.pumpAndSettle();

          // Now find the delete audio from playlist as well popup menu item
          // and tap on it
          final Finder popupCopyMenuItem = find
              .byKey(const Key("popup_menu_delete_audio_from_playlist_aswell"));

          await tester.tap(popupCopyMenuItem);
          await tester.pumpAndSettle();

          // Verifying the confirm dialog title

          final Text deleteFilteredAudioConfirmDialogTitleWidget = tester
              .widget<Text>(find.byKey(const Key('confirmDialogTitleOneKey')));

          expect(deleteFilteredAudioConfirmDialogTitleWidget.data,
              'Confirm deletion of the commented audio "$commentedAudioTitleToDelete"');

          // Verifying the confirm dialog message

          final Text deleteFilteredAudioConfirmDialogMessageTextWidget =
              tester.widget<Text>(
                  find.byKey(const Key('confirmationDialogMessageKey')));

          expect(deleteFilteredAudioConfirmDialogMessageTextWidget.data,
              'The audio contains 1 comment(s) which will be deleted as well. Confirm deletion ?');

          // Now find the confirm button of the delete filtered audio confirm
          // dialog and tap on it
          await tester.tap(find.byKey(const Key('confirmButton')));
          await tester.pumpAndSettle();

          // Ensure the warning dialog is shown
          expect(find.byType(WarningMessageDisplayDialog), findsOneWidget);

          // Check the value of the warning dialog title
          Text warningDialogTitle =
              tester.widget(find.byKey(const Key('warningDialogTitle')).at(1));
          expect(warningDialogTitle.data, 'WARNING');

          // Check the value of the warning dialog message
          Text warningDialogMessage =
              tester.widget(find.byKey(const Key('warningDialogMessage')).last);
          expect(warningDialogMessage.data,
              'If the deleted audio video "$commentedAudioTitleToDelete" remains in the "$youtubePlaylistTitle" Youtube playlist, it will be downloaded again the next time you download the playlist !');

          // Close the warning dialog by tapping on the Ok button
          await tester.tap(find.byKey(const Key('warningDialogOkButton')).last);
          await tester.pumpAndSettle();

          // Close the warning dialog by tapping on the Ok button
          await tester
              .tap(find.byKey(const Key('warningDialogOkButton')).last);
          await tester.pumpAndSettle();

          // Verify that the applyed Sort/Filter parms name is displayed
          // after the selected playlist title

          Text selectedSortFilterParmsName = tester
              .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

          expect(
            selectedSortFilterParmsName.data,
            saveAsTitle,
          );

          // Verify that the audio file was deleted

          listMp3FileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
            fileExtension: 'mp3',
          );

          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            false,
          );

          // Verify that the audio comment files were deleted

          listCommentJsonFileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio${path.separator}$kCommentDirName",
            fileExtension: 'json',
          );

          expect(
            listCommentJsonFileNames.contains(audioCommentFileNameToDelete),
            false,
          );

          // Verify the 'S8 audio' playlist json file

          Playlist loadedPlaylist = loadPlaylist(youtubePlaylistTitle);

          expect(loadedPlaylist.downloadedAudioLst.length, 17);

          List<String> downloadedAudioLst = loadedPlaylist.downloadedAudioLst
              .map((Audio audio) => audio.validVideoTitle)
              .toList();

          expect(
            downloadedAudioLst.contains(commentedAudioTitleToDelete),
            false,
          );

          List<String> playableAudioLst = loadedPlaylist.playableAudioLst
              .map((Audio audio) => audio.validVideoTitle)
              .toList();

          expect(
            playableAudioLst.contains(commentedAudioTitleToDelete),
            false,
          );

          // Setting to this variables the currently selected audio title/subTitle
          // of the 'S8 audio' playlist
          String currentAudioTitle = "La résilience insulaire par Fiona Roche";
          String currentAudioSubTitle =
              "0:13:35.0. 4.97 MB at 2.67 MB/sec on 07/01/2024 at 08:16.";

          // Verify that the current audio is displayed with the correct
          // title and subtitle color
          await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
            tester: tester,
            currentAudioTitle: currentAudioTitle,
            currentAudioSubTitle: currentAudioSubTitle,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
        testWidgets(
            '''Saved defined SF parms 'Title asc' is applied. Then, click on the menu
           icon of the uncommented audio "Les besoins artificiels par R.Keucheyan"
           and select 'Delete Audio from Playlist as well ...'. Verify the suppression
           of the audio mp3. Verify also the updated playlist playable audio list
           and the new not totally played selected audio and the new not totally
           played selected audio.''', (tester) async {
          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName:
                'delete_filtered_audio_one_uncommented_more_test',
            tapOnPlaylistToggleButton: false,
          );

          const String youtubePlaylistTitle = 'S8 audio';

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type "Title asc" in the 'Save as' TextField

          String saveAsTitle = 'Title asc';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle();

          // Now select the 'Audio title'item in the 'Sort by' dropdown button

          await tester
              .tap(find.byKey(const Key('sortingOptionDropdownButton')));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Audio title'));
          await tester.pumpAndSettle();

          // Then delete the "Audio download date" descending sort option

          // Find the Text with "Audio downl date" which is located in the
          // selected sort parameters ListView
          final Finder textFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Audio downl date'),
          );

          // Then find the ListTile ancestor of the 'Audio downl date' Text
          // widget. The ascending/descending and remove icon buttons are
          // contained in their ListTile ancestor
          final Finder listTileFinder = find.ancestor(
            of: textFinder,
            matching: find.byType(ListTile),
          );

          // Now, within that ListTile, find the sort option delete IconButton
          // with key 'removeSortingOptionIconButton'
          final Finder iconButtonFinder = find.descendant(
            of: listTileFinder,
            matching: find.byKey(const Key('removeSortingOptionIconButton')),
          );

          // Tap on the delete icon button to delete the 'Audio downl date'
          // descending sort option
          await tester.tap(iconButtonFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Change unplayed to fully listened status of the "La
          // surpopulation mondiale par Jancovici et Barrau" audio

          String unplayedThenFullyListenedAudioTitle =
              "La surpopulation mondiale par Jancovici et Barrau";

          // Then, tap on the unplayed Audio ListTile Text widget finder to
          // select this unplayed audio. This switch to the audio player view.
          final Finder thirdDownloadedAudioListTileTextWidgetFinder =
              find.text(unplayedThenFullyListenedAudioTitle);

          await tester.tap(thirdDownloadedAudioListTileTextWidgetFinder);
          await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
            tester: tester,
          );

          // Then skip to the end of the audio to set it as fully played
          await tester
              .tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
          await tester.pumpAndSettle();

          // Now, go back to the playlist download view
          Finder audioPlayerNavButtonFinder =
              find.byKey(const ValueKey('playlistDownloadViewIconButton'));
          await tester.tap(audioPlayerNavButtonFinder);
          await tester.pumpAndSettle();

          // Verify the presence of the audio file which will be later deleted

          String audioFileNameToDelete =
              "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.mp3";

          List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
            fileExtension: 'mp3',
          );

          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            true,
          );

          // Scrolling down the audios list in order to display the commented
          // audio title to delete

          // Find the audio list widget using its key
          final Finder listFinder = find.byKey(const Key('audio_list'));
          // Perform the scroll action
          await tester.drag(listFinder, const Offset(0, -1000));
          await tester.pumpAndSettle();

          String uncommentedAudioTitleToDelete =
              "Les besoins artificiels par R.Keucheyan";

          // First, find the Audio sublist ListTile Text widget
          final Finder commentedAudioTitleToDeleteListTileTextWidgetFinder =
              find.text(uncommentedAudioTitleToDelete);

          // Then obtain the Audio ListTile widget enclosing the Text widget by
          // finding its ancestor
          final Finder commentedAudioTitleToDeleteListTileWidgetFinder =
              find.ancestor(
            of: commentedAudioTitleToDeleteListTileTextWidgetFinder,
            matching: find.byType(ListTile),
          );

          // Now find the leading menu icon button of the Audio ListTile
          // and tap on it
          final Finder
              commentedAudioTitleToDeleteListTileLeadingMenuIconButton =
              find.descendant(
            of: commentedAudioTitleToDeleteListTileWidgetFinder,
            matching: find.byIcon(Icons.menu),
          );

          // Tap the leading menu icon button to open the popup menu
          await tester
              .tap(commentedAudioTitleToDeleteListTileLeadingMenuIconButton);
          await tester.pumpAndSettle();

          // Now find the delete audio from playlist as well popup menu item
          // and tap on it
          final Finder popupCopyMenuItem = find
              .byKey(const Key("popup_menu_delete_audio_from_playlist_aswell"));

          await tester.tap(popupCopyMenuItem);
          await tester.pumpAndSettle();

          // Check the value of the warning dialog title
          Text warningDialogTitle =
              tester.widget(find.byKey(const Key('warningDialogTitle')).at(1));
          expect(warningDialogTitle.data, 'WARNING');

          // Check the value of the warning dialog message
          Text warningDialogMessage =
              tester.widget(find.byKey(const Key('warningDialogMessage')).last);
          expect(warningDialogMessage.data,
              'If the deleted audio video "$uncommentedAudioTitleToDelete" remains in the "$youtubePlaylistTitle" Youtube playlist, it will be downloaded again the next time you download the playlist !');

          // Close the warning dialog by tapping on the Ok button
          await tester.tap(find.byKey(const Key('warningDialogOkButton')).last);
          await tester.pumpAndSettle();

          // Close the warning dialog by tapping on the Ok button
          await tester
              .tap(find.byKey(const Key('warningDialogOkButton')).last);
          await tester.pumpAndSettle();

          // Verify that the applyed Sort/Filter parms name is displayed
          // after the selected playlist title

          Text selectedSortFilterParmsName = tester
              .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

          expect(
            selectedSortFilterParmsName.data,
            saveAsTitle,
          );

          // Verify that the audio file was deleted

          listMp3FileNames = DirUtil.listFileNamesInDir(
            directoryPath:
                "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
            fileExtension: 'mp3',
          );

          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            false,
          );

          // Verify the 'S8 audio' playlist json file

          Playlist loadedPlaylist = loadPlaylist(youtubePlaylistTitle);

          expect(loadedPlaylist.downloadedAudioLst.length, 17);

          List<String> downloadedAudioLst = loadedPlaylist.downloadedAudioLst
              .map((Audio audio) => audio.validVideoTitle)
              .toList();

          expect(
            downloadedAudioLst.contains(uncommentedAudioTitleToDelete),
            false,
          );

          List<String> playableAudioLst = loadedPlaylist.playableAudioLst
              .map((Audio audio) => audio.validVideoTitle)
              .toList();

          expect(
            playableAudioLst.contains(uncommentedAudioTitleToDelete),
            false,
          );

          // Setting to this variables the currently selected audio title/subTitle
          // of the 'S8 audio' playlist
          String currentAudioTitle = "La résilience insulaire par Fiona Roche";
          String currentAudioSubTitle =
              "0:13:35.0. 4.97 MB at 2.67 MB/sec on 07/01/2024 at 08:16.";

          // Verify that the current audio is displayed with the correct
          // title and subtitle color
          await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
            tester: tester,
            currentAudioTitle: currentAudioTitle,
            currentAudioSubTitle: currentAudioSubTitle,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
      });
      group('In playlist download view, delete unique audio test', () {
        testWidgets(
            '''Delete unique audio mp3 only and then switch to AudioPlayerView
           screen.''', (tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
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

          await app.main(['test']);
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to display the playlist list
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
          final Finder uniqueAudioListTileLeadingMenuIconButton =
              find.descendant(
            of: uniqueAudioListTileWidgetFinder,
            matching: find.byIcon(Icons.menu),
          );

          // Tap the leading menu icon button to open the popup menu
          await tester.tap(uniqueAudioListTileLeadingMenuIconButton);
          await tester.pumpAndSettle();

          // Now find the delete audio popup menu item and tap on it
          final Finder popupCopyMenuItem =
              find.byKey(const Key("popup_menu_delete_audio"));

          await tester.tap(popupCopyMenuItem);
          await tester.pumpAndSettle();

          // Now verifying the selected playlist TextField still
          // contains the title of the source playlist

          Text selectedPlaylistTitleText = tester
              .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')));

          expect(
            selectedPlaylistTitleText.data,
            localAudioPlaylistTitle,
          );

          // Now verifying that the audio was physically deleted from the
          // local playlist directory.

          List<String> localPlaylistMp3Lst = DirUtil.listFileNamesInDir(
            directoryPath:
                '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioPlaylistTitle',
            fileExtension: 'mp3',
          );

          // Verify the local target playlist directory content
          expect(localPlaylistMp3Lst, []);

          // Now we tap on the AudioPlayerView icon button to open
          // AudioPlayerView screen

          final appScreenNavigationButton =
              find.byKey(const ValueKey('audioPlayerViewIconButton'));
          await tester.tap(appScreenNavigationButton);
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
          );
        });
        testWidgets(
            '''Delete unique audio from playlist as well and then switch to
           AudioPlayerView screen.''', (tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
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

          await app.main(['test']);
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to display the playlist list
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
          final Finder uniqueAudioListTileLeadingMenuIconButton =
              find.descendant(
            of: uniqueAudioListTileWidgetFinder,
            matching: find.byIcon(Icons.menu),
          );

          // Tap the leading menu icon button to open the popup menu
          await tester.tap(uniqueAudioListTileLeadingMenuIconButton);
          await tester.pumpAndSettle();

          // Now find the delete audio from playlist as well popup menu
          // item and tap on it. Since the audio is deleted from a local
          // plalist, no warning is displayed indicating that the audio
          // will be redownloaded unless it is suppressed from the Youtube
          // playlist as well !
          final Finder popupCopyMenuItem = find
              .byKey(const Key("popup_menu_delete_audio_from_playlist_aswell"));

          await tester.tap(popupCopyMenuItem);
          await tester.pumpAndSettle();

          // Now verifying the selected playlist TextField still
          // contains the title of the source playlist

          Text selectedPlaylistTitleText = tester
              .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')));

          expect(
            selectedPlaylistTitleText.data,
            localAudioPlaylistTitle,
          );

          // Now verifying that the audio was physically deleted from the
          // local playlist directory.

          List<String> localPlaylistMp3Lst = DirUtil.listFileNamesInDir(
            directoryPath:
                '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioPlaylistTitle',
            fileExtension: 'mp3',
          );

          // Verify the local target playlist directory content
          expect(localPlaylistMp3Lst, []);

          // Now we tap on the AudioPlayerView icon button to open
          // AudioPlayerView screen

          final appScreenNavigationButton =
              find.byKey(const ValueKey('audioPlayerViewIconButton'));
          await tester.tap(appScreenNavigationButton);
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
          );
        });
      });
    });
    group('In audio player view, delete unique audio test', () {
      testWidgets(
          '''Switch to AudioPlayerView screen and then delete unique audio mp3 only.''',
          (tester) async {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}one_local_playlist_with_one_audio",
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

        await app.main(['test']);
        await tester.pumpAndSettle();

        // Tap the 'Toggle List' button to display the playlist list
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

        // Now we tap on the AudioPlayerView icon button to open
        // AudioPlayerView screen

        Finder appScreenNavigationButton =
            find.byKey(const ValueKey('audioPlayerViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        // Tap the appbar leading popup menu button
        await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Now find the delete audio popup menu item and tap on it
        Finder popupMoveMenuItem =
            find.byKey(const Key("popup_menu_delete_audio"));

        await tester.tap(popupMoveMenuItem);
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

        // Now verifying the selected playlist TextField still
        // contains the title of the source playlist

        Text selectedPlaylistTitleText = tester
            .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')));

        expect(
          selectedPlaylistTitleText.data,
          localAudioPlaylistTitle,
        );

        // Now verifying that the audio was physically deleted from the
        // local playlist directory.

        List<String> localPlaylistMp3Lst = DirUtil.listFileNamesInDir(
          directoryPath:
              '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioPlaylistTitle',
          fileExtension: 'mp3',
        );

        // Verify the local target playlist directory content
        expect(localPlaylistMp3Lst, []);

        // Now, go back to the playlist download view.
        appScreenNavigationButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        // Now verifying the selected playlist TextField still
        // contains the title of the source playlist

        selectedPlaylistTitleText = tester
            .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')));

        expect(
          selectedPlaylistTitleText.data,
          localAudioPlaylistTitle,
        );

        // Verify the playlist audio list is empty

        List<String> playlistsTitles = [
          'local_audio_playlist_2',
        ];

        List<String> audioTitles = [];

        IntegrationTestUtil.checkPlaylistAndAudioTitlesOrderInListTile(
          tester: tester,
          playlistTitlesOrderedLst: playlistsTitles,
          audioTitlesOrderedLst: audioTitles,
          firstPlaylistListTileIndex: 0,
          firstAudioListTileIndex: 3,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets(
          '''Switch to AudioPlayerView screen and then delete unique audio mp3 from
          playlist as well.''', (tester) async {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}one_local_playlist_with_one_audio",
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

        await app.main(['test']);
        await tester.pumpAndSettle();

        // Tap the 'Toggle List' button to display the playlist list
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

        // Now we tap on the AudioPlayerView icon button to open
        // AudioPlayerView screen

        Finder appScreenNavigationButton =
            find.byKey(const ValueKey('audioPlayerViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        // Tap the appbar leading popup menu button
        await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Now find the delete audio from playlist as well popup menu
        // item and tap on it. Since the audio is deleted from a local
        // plalist, no warning is displayed indicating that the audio
        // will be redownloaded unless it is suppressed from the Youtube
        // playlist as well !
        Finder popupMoveMenuItem = find
            .byKey(const Key("popup_menu_delete_audio_from_playlist_aswell"));

        await tester.tap(popupMoveMenuItem);
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

        // Now verifying the selected playlist TextField still
        // contains the title of the source playlist

        Text selectedPlaylistTitleText = tester
            .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')));

        expect(
          selectedPlaylistTitleText.data,
          localAudioPlaylistTitle,
        );

        // Now verifying that the audio was physically deleted from the
        // local playlist directory.

        List<String> localPlaylistMp3Lst = DirUtil.listFileNamesInDir(
          directoryPath:
              '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localAudioPlaylistTitle',
          fileExtension: 'mp3',
        );

        // Verify the local target playlist directory content
        expect(localPlaylistMp3Lst, []);

        // Now, go back to the playlist download view.
        appScreenNavigationButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        // Now verifying the selected playlist TextField still
        // contains the title of the source playlist

        selectedPlaylistTitleText = tester
            .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')));

        expect(
          selectedPlaylistTitleText.data,
          localAudioPlaylistTitle,
        );

        // Verify the playlist audio list is empty

        List<String> playlistsTitles = [
          'local_audio_playlist_2',
        ];

        List<String> audioTitles = [];

        IntegrationTestUtil.checkPlaylistAndAudioTitlesOrderInListTile(
          tester: tester,
          playlistTitlesOrderedLst: playlistsTitles,
          audioTitlesOrderedLst: audioTitles,
          firstPlaylistListTileIndex: 0,
          firstAudioListTileIndex: 3,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
  });
  group('Bug fix tests', () {
    testWidgets('Verifying with partial download of single video audio',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Enter the single video URL into the url text field
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
      );
    });
    testWidgets('''Verifying execution of "Delete audio from playlist as well"
           playlist menu item''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
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
      await tester.pumpAndSettle();

      // Now find the popup menu item and tap on it
      final Finder popupDeleteAudioFromPlaylistAsWellMenuItem =
          find.byKey(const Key("popup_menu_delete_audio_from_playlist_aswell"));

      await tester.tap(popupDeleteAudioFromPlaylistAsWellMenuItem);
      await tester.pumpAndSettle();

      // Ensure the warning dialog is shown
      expect(find.byType(WarningMessageDisplayDialog), findsOneWidget);

      // Check the value of the warning dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')).last);
      expect(warningDialogTitle.data, 'WARNING');

      // Check the value of the warning dialog message
      Text warningDialogMessage =
          tester.widget(find.byKey(const Key('warningDialogMessage')));
      expect(warningDialogMessage.data,
          'If the deleted audio video "$audioToDeleteTitle" remains in the "$youtubeAudioPlaylistTitle" Youtube playlist, it will be downloaded again the next time you download the playlist !');

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')).last);
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
      );
    });
    testWidgets('Click on download at musical quality checkbox bug fix',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
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
      );
    });
  });
  group('Delete existing playlist test', () {
    testWidgets('Delete selected Youtube playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
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
      await tester.pumpAndSettle();

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget = tester
          .widget<Text>(find.byKey(const Key('confirmDialogTitleOneKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Supprimer la playlist Youtube "$youtubePlaylistToDeleteTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
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

      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Verifying that the selected playlist text field is empty
      expect(
        tester
            .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')))
            .data,
        '',
        reason: 'Selected playlist text field is not empty',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('Cancel delete selected Youtube playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
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
      await tester.pumpAndSettle();

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

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: false,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Verifying that the selected playlist text field is empty
      expect(
        tester
            .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')))
            .data,
        youtubePlaylistToDeleteTitle,
        reason: 'Selected playlist text field is empty',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('Delete selected local playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
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
      await tester.pumpAndSettle();

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget = tester
          .widget<Text>(find.byKey(const Key('confirmDialogTitleOneKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Supprimer la playlist locale "$localPlaylistToDeleteTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
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

      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Verifying that the selected playlist text field is empty
      expect(
        tester
            .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')))
            .data,
        '',
        reason: 'Selected playlist text field is not empty',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('Cancel delete selected local playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
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
      await tester.pumpAndSettle();

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

      // Check that the deletion cancelled playlist directory still exist
      expect(Directory(localPlaylistToDeletePath).existsSync(), true);

      // Since the deletion of the selected playlist was cancelled,
      // there is still a selected playlist. So, the selected playlist
      // widgets are enabled. Checking this now:

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // since the playlist whose deletion was cancelled has no audio,
      // the audui menu items are disabled
      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Verifying that the selected playlist text field is not empty
      expect(
        tester
            .widget<Text>(find.byKey(const Key('selectedPlaylistTitleText')))
            .data,
        localPlaylistToDeleteTitle,
        reason: 'Selected playlist text field is not empty',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('''Delete non selected Youtube playlist while another Youtube
           playlist is selected''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the playlist to obtain its ListTile

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
      await tester.pumpAndSettle();

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget = tester
          .widget<Text>(find.byKey(const Key('confirmDialogTitleOneKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Supprimer la playlist Youtube "$youtubePlaylistToDeleteTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
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

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Delete non selected Youtube playlist while a local playlist is
           selected''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Find the playlist to obtain its ListTile

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
      await tester.pumpAndSettle();

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget = tester
          .widget<Text>(find.byKey(const Key('confirmDialogTitleOneKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Supprimer la playlist Youtube "$youtubePlaylistToDeleteTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
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

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      // since a local playlist is selected, the download
      // audio of selected playlist button is disabled
      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // since the selected local playlist has no audio, the
      // audio menu item is disabled
      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('PlaylistDownloadView buttons state test', () {
    testWidgets('PlaylistDownloadView displayed with no selected playlist',
        (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
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
      );
    });
    testWidgets('Select a local playlist with no audio', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
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
      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'audio_quality_checkbox',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // since the selected local playlist has no audio, the
      // audio menu item is disabled
      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('Select a Youtube playlist with no audio', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
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
      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

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

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // since the selected local playlist has no audio, the
      // audio menu item is disabled
      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('Select a local playlist with audio', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
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
      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'audio_quality_checkbox',
      );

      // since the playlist has audio, the audio popup menu
      // button is enabled
      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('Select a Youtube playlist with audio', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
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
      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_quality_checkbox',
      );

      // since the playlist has audio, the audio popup menu
      // button is enabled
      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('Delete a Youtube playlist with audio', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
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
      await tester.pumpAndSettle();

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget = tester
          .widget<Text>(find.byKey(const Key('confirmDialogTitleOneKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Delete Youtube Playlist "$youtubePlaylistToSelectTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // since the Youtube playlist was deleted, verify that all
      // buttons are disabled
      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'audio_quality_checkbox',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // since the selected local playlist has no audio, the
      // audio menu item is disabled
      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('Delete a local playlist with 1 audio', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
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
      await tester.pumpAndSettle();

      // Now find the delete playlist popup menu item and tap on it
      final Finder popupDeletePlaylistMenuItem =
          find.byKey(const Key("popup_menu_delete_playlist"));

      await tester.tap(popupDeletePlaylistMenuItem);
      await tester.pumpAndSettle();

      // Now verifying the confirm dialog message

      final Text deletePlaylistDialogTitleWidget = tester
          .widget<Text>(find.byKey(const Key('confirmDialogTitleOneKey')));

      expect(deletePlaylistDialogTitleWidget.data,
          'Delete Local Playlist "$localPlaylistTitle"');

      // Now find the delete button of the delete playlist confirm
      // dialog and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // since the local playlist was deleted, verify that all
      // buttons are disabled
      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'audio_quality_checkbox',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // since the selected local playlist has no audio, the
      // audio menu item is disabled
      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('Delete a unique audio in a local playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
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
      await tester.pumpAndSettle();

      // Now find the delete audio popup menu item and tap on it
      final Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_delete_audio"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'download_sel_playlists_button',
      );

      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'audio_quality_checkbox',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // since the selected local playlist has no audio, the
      // audio menu item is disabled
      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('Delete a unique audio in a Youtube playlist', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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

      await app.main(['test']);
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
      await tester.pumpAndSettle();

      // Now find the delete audio popup menu item and tap on it
      final Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_delete_audio"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_up_playlist_button',
      );

      IntegrationTestUtil.verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'move_down_playlist_button',
      );

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

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // since the selected local playlist has no audio, the
      // audio menu item is disabled
      await IntegrationTestUtil.verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    group('Open app with or without selected playlist', () {
      group('With playlist list displayed', () {
        testWidgets('Selected local playlist with no audio', (tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}playlist_download_view_button_state_at_app_start_test",
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

          await app.main(['test']);
          await tester.pumpAndSettle();

          // since a local playlist is selected, verify that
          // some buttons and checkbox are enabled and some are disabled
          verifyLocalSelectedPlaylistButtonsAndCheckbox(
            tester: tester,
            isPlaylistListDisplayed: true,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
        testWidgets('Selected Youtube playlist with no audio', (tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}playlist_download_view_button_state_at_app_start_test",
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

          const String initiallySelectedPlaylistTitle =
              'local_audio_playlist_2';
          const String nowSelectedPlaylistTitle =
              'audio_player_view_2_shorts_test';

          modifySelectedPlaylistBeforeStartingApplication(
            playlistToUnselectTitle: initiallySelectedPlaylistTitle,
            playlistToSelectTitle: nowSelectedPlaylistTitle,
          );

          await app.main(['test']);
          await tester.pumpAndSettle();

          // since a locYoutubeal playlist is selected, verify that
          // some buttons and checkbox are enabled and some are disabled
          verifyYoutubeSelectedPlaylistButtonsAndCheckbox(
            tester: tester,
            isPlaylistListDisplayed: true,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
        testWidgets('Selected Local playlist with audio', (tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}playlist_download_view_button_state_at_app_start_test",
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

          const String initiallySelectedPlaylistTitle =
              'local_audio_playlist_2';
          const String nowSelectedPlaylistTitle = 'local_3';

          modifySelectedPlaylistBeforeStartingApplication(
            playlistToUnselectTitle: initiallySelectedPlaylistTitle,
            playlistToSelectTitle: nowSelectedPlaylistTitle,
          );

          await app.main(['test']);
          await tester.pumpAndSettle();

          // since a locYoutubeal playlist is selected, verify that
          // some buttons and checkbox are enabled and some are disabled
          verifyLocalSelectedPlaylistButtonsAndCheckbox(
            tester: tester,
            isPlaylistListDisplayed: true,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
        testWidgets('Selected Youtube playlist with audio', (tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}playlist_download_view_button_state_at_app_start_test",
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

          const String initiallySelectedPlaylistTitle =
              'local_audio_playlist_2';
          const String nowSelectedPlaylistTitle =
              'audio_learn_new_youtube_playlist_test';

          modifySelectedPlaylistBeforeStartingApplication(
            playlistToUnselectTitle: initiallySelectedPlaylistTitle,
            playlistToSelectTitle: nowSelectedPlaylistTitle,
          );

          await app.main(['test']);
          await tester.pumpAndSettle();

          // since a locYoutubeal playlist is selected, verify that
          // some buttons and checkbox are enabled and some are disabled
          verifyYoutubeSelectedPlaylistButtonsAndCheckbox(
            tester: tester,
            isPlaylistListDisplayed: true,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
      });
      group('With playlist list not displayed', () {
        testWidgets('Selected local playlist with no audio', (tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}playlist_download_view_button_state_at_app_start_test",
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

          // Changing the playlists list display before starting the
          // application
          settingsDataService.set(
              settingType: SettingType.playlists,
              settingSubType:
                  Playlists.arePlaylistsDisplayedInPlaylistDownloadView,
              value: false);

          settingsDataService.saveSettings();

          await app.main(['test']);
          await tester.pumpAndSettle();

          // since a local playlist is selected, verify that
          // some buttons and checkbox are enabled and some are disabled
          verifyLocalSelectedPlaylistButtonsAndCheckbox(
            tester: tester,
            isPlaylistListDisplayed: false,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
        testWidgets('Selected Youtube playlist with no audio', (tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}playlist_download_view_button_state_at_app_start_test",
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

          // Changing the playlists list display before starting the
          // application
          settingsDataService.set(
              settingType: SettingType.playlists,
              settingSubType:
                  Playlists.arePlaylistsDisplayedInPlaylistDownloadView,
              value: false);

          settingsDataService.saveSettings();

          const String initiallySelectedPlaylistTitle =
              'local_audio_playlist_2';
          const String nowSelectedPlaylistTitle =
              'audio_player_view_2_shorts_test';

          modifySelectedPlaylistBeforeStartingApplication(
            playlistToUnselectTitle: initiallySelectedPlaylistTitle,
            playlistToSelectTitle: nowSelectedPlaylistTitle,
          );

          await app.main(['test']);
          await tester.pumpAndSettle();

          // since a locYoutubeal playlist is selected, verify that
          // some buttons and checkbox are enabled and some are disabled
          verifyYoutubeSelectedPlaylistButtonsAndCheckbox(
            tester: tester,
            isPlaylistListDisplayed: false,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
        testWidgets('Selected Local playlist with audio', (tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}playlist_download_view_button_state_at_app_start_test",
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

          // Changing the playlists list display before starting the
          // application
          settingsDataService.set(
              settingType: SettingType.playlists,
              settingSubType:
                  Playlists.arePlaylistsDisplayedInPlaylistDownloadView,
              value: false);

          settingsDataService.saveSettings();

          const String initiallySelectedPlaylistTitle =
              'local_audio_playlist_2';
          const String nowSelectedPlaylistTitle = 'local_3';

          modifySelectedPlaylistBeforeStartingApplication(
            playlistToUnselectTitle: initiallySelectedPlaylistTitle,
            playlistToSelectTitle: nowSelectedPlaylistTitle,
          );

          await app.main(['test']);
          await tester.pumpAndSettle();

          // since a locYoutubeal playlist is selected, verify that
          // some buttons and checkbox are enabled and some are disabled
          verifyLocalSelectedPlaylistButtonsAndCheckbox(
            tester: tester,
            isPlaylistListDisplayed: false,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
        testWidgets('Selected Youtube playlist with audio', (tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}playlist_download_view_button_state_at_app_start_test",
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

          // Changing the playlists list display before starting the
          // application
          settingsDataService.set(
              settingType: SettingType.playlists,
              settingSubType:
                  Playlists.arePlaylistsDisplayedInPlaylistDownloadView,
              value: false);

          settingsDataService.saveSettings();

          const String initiallySelectedPlaylistTitle =
              'local_audio_playlist_2';
          const String nowSelectedPlaylistTitle =
              'audio_learn_new_youtube_playlist_test';

          modifySelectedPlaylistBeforeStartingApplication(
            playlistToUnselectTitle: initiallySelectedPlaylistTitle,
            playlistToSelectTitle: nowSelectedPlaylistTitle,
          );

          await app.main(['test']);
          await tester.pumpAndSettle();

          // since a locYoutubeal playlist is selected, verify that
          // some buttons and checkbox are enabled and some are disabled
          verifyYoutubeSelectedPlaylistButtonsAndCheckbox(
            tester: tester,
            isPlaylistListDisplayed: false,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
      });
    });
  });
  group('App settings dialog test', () {
    testWidgets(
        'Bug fix: open app settings dialog and save it without modification.',
        (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}app_settings_set_play_speed",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      final Map initialSettingsMap = loadSettingsMap();

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

      await app.main(['test']);
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
        initialSettingsMap,
        loadSettingsMap(),
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('Enter a non existing playlist root dir.',
        (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}app_settings_set_play_speed",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      final Map initialSettingsMap = loadSettingsMap();

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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Tap the appbar leading popup menu button
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // Now open the app settings dialog
      await tester.tap(find.byKey(const Key('appBarMenuOpenSettingsDialog')));
      await tester.pumpAndSettle();

      // Enter non existing dir path

      // Find the TextField using the Key
      final Finder textFieldFinder =
          find.byKey(const Key('playlistRootpathTextField'));

      // Retrieve the TextField widget
      final TextField textField = tester.widget<TextField>(textFieldFinder);

      // Obtain the current text value of the text field
      String text = textField.controller!.text;

      // Now enter the text in the text field
      await tester.enterText(
        textFieldFinder,
        '$text${path.separator}new',
      );

      await tester.pumpAndSettle();

      // And tap on save button
      await tester.tap(find.byKey(const Key('saveButton')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is shown
      expect(find.byType(WarningMessageDisplayDialog), findsOneWidget);

      // Check the value of the warning dialog title
      Text warningDialogTitle =
          tester.widget(find.byKey(const Key('warningDialogTitle')));
      expect(warningDialogTitle.data, 'WARNING');

      // Check the value of the warning dialog message
      Text warningDialogMessage =
          tester.widget(find.byKey(const Key('warningDialogMessage')));
      expect(warningDialogMessage.data,
          "The defined path \"$kApplicationPathWindowsTest${path.separator}new\" does not exist. Please enter a valid playlist root path and retry ...");

      // Close the warning dialog by tapping on the Ok button
      await tester.tap(find.byKey(const Key('warningDialogOkButton')));
      await tester.pumpAndSettle();

      // Ensure settings json file has not been modified
      expect(
        initialSettingsMap,
        loadSettingsMap(),
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Enter an existing playlist root dir in which a smartphone playlist
           dir exist and test that those smartphone audio are usable.''',
        (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}app_settings_set_play_speed",
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

      await app.main(['test']);
      await tester.pumpAndSettle();

      // Create the 'new' directory in the app dir
      String newDirectoryUsedLaterInApplicationSetting =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}new";

      Directory(newDirectoryUsedLaterInApplicationSetting).createSync();

      // Add the Youtube 'Youtube_test' playlist directory which were
      // copied from a smartphone
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}manually_added_smartphone_Youtube_playlist_dir",
        destinationRootPath: newDirectoryUsedLaterInApplicationSetting,
      );

      // Tap the 'Toggle List' button to show the list of playlists in the
      // 'new' playlist root directory.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Obtains all the ListTile widgets present in the playlist
      // download view
      final Finder lisTilesFinder = find.byType(ListTile);

      // Verify the playlist titles and the audio titles of the selected
      // playlist

      // S8 playlist title
      Finder playlistTitleTextFinder = find.descendant(
        of: lisTilesFinder.at(0),
        matching: find.byType(Text),
      );
      expect(tester.widget<Text>(playlistTitleTextFinder).data, 'S8 audio');

      // local playlist title
      playlistTitleTextFinder = find.descendant(
        of: lisTilesFinder.at(1),
        matching: find.byType(Text),
      );
      expect(tester.widget<Text>(playlistTitleTextFinder).data, 'local');

      // first audio of S8 audio playlist
      playlistTitleTextFinder = find.descendant(
        of: lisTilesFinder.at(2),
        matching: find.byType(Text),
      );
      expect(
        // 2 Text widgets exist in audio ListTile: the title and sub title
        tester.widget<Text>(playlistTitleTextFinder.at(0)).data,
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
      );

      // second audio of S8 audio playlist
      playlistTitleTextFinder = find.descendant(
        of: lisTilesFinder.at(3),
        matching: find.byType(Text),
      );
      expect(
        // 2 Text widgets exist in audio ListTile: the title and sub title
        tester.widget<Text>(playlistTitleTextFinder.at(0)).data,
        "La surpopulation mondiale par Jancovici et Barrau",
      );

      // Tap the appbar leading popup menu button
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // Now open the app settings dialog
      await tester.tap(find.byKey(const Key('appBarMenuOpenSettingsDialog')));
      await tester.pumpAndSettle();

      // Enter existing dir path

      // Find the TextField using the Key
      final Finder textFieldFinder =
          find.byKey(const Key('playlistRootpathTextField'));

      // Retrieve the TextField widget
      final TextField textField = tester.widget<TextField>(textFieldFinder);

      // Obtain the current text value of the text field
      String text = textField.controller!.text;

      // Now enter the text in the text field
      await tester.enterText(
        textFieldFinder,
        '$text${path.separator}new',
      );

      await tester.pumpAndSettle();

      // And tap on save button
      await tester.tap(find.byKey(const Key('saveButton')));
      await tester.pumpAndSettle();

      // Ensure settings json file has been modified
      String expSettings =
          "{\"SettingType.appTheme\":{\"SettingType.appTheme\":\"AppTheme.dark\"},\"SettingType.language\":{\"SettingType.language\":\"Language.english\"},\"SettingType.playlists\":{\"Playlists.arePlaylistsDisplayedInPlaylistDownloadView\":\"true\",\"Playlists.isMusicQualityByDefault\":\"false\",\"Playlists.orderedTitleLst\":\"[Youtube_test]\",\"Playlists.playSpeed\":\"1.25\"},\"SettingType.dataLocation\":{\"DataLocation.appSettingsPath\":\"C:\\\\Users\\\\Jean-Pierre\\\\Development\\\\Flutter\\\\audiolearn\\\\test\\\\data\\\\audio\",\"DataLocation.playlistRootPath\":\"C:\\\\Users\\\\Jean-Pierre\\\\Development\\\\Flutter\\\\audiolearn\\\\test\\\\data\\\\audio\\\\new\"},\"SettingType.formatOfDate\":{\"FormatOfDate.formatOfDate\":\"dd/MM/yyyy\"},\"namedAudioSortFilterSettings\":{\"default\":{\"selectedSortItemLst\":[{\"sortingOption\":\"audioDownloadDate\",\"isAscending\":false}],\"filterSentenceLst\":[],\"sentencesCombination\":0,\"ignoreCase\":true,\"searchAsWellInYoutubeChannelName\":true,\"searchAsWellInVideoCompactDescription\":true,\"filterMusicQuality\":false,\"filterFullyListened\":true,\"filterPartiallyListened\":true,\"filterNotListened\":true,\"filterCommented\":true,\"filterNotCommented\":true,\"downloadDateStartRange\":null,\"downloadDateEndRange\":null,\"uploadDateStartRange\":null,\"uploadDateEndRange\":null,\"fileSizeStartRangeMB\":0.0,\"fileSizeEndRangeMB\":0.0,\"durationStartRangeSec\":0,\"durationEndRangeSec\":0}},\"searchHistoryOfAudioSortFilterSettings\":\"[]\"}";
      expect(
        File("$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName")
            .readAsStringSync(),
        expSettings,
      );
      // Find the Youtube playlist to select

      // First, find the Playlist ListTile Text widget
      final Finder localPlaylistToSelectListTileTextWidgetFinder =
          find.text('Youtube_test');

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

      const String alreadyCommentedAudioTitle =
          "5 minutes d'éco-anxiété pour se motiver à bouger (Ringenbach, Janco, Barrau, Servigne)";

      // Then, get the ListTile Text widget finder of the already commented
      // audio and tap on it to open the AudioPlayerView
      final Finder alreadyCommentedAudioFinder =
          find.text(alreadyCommentedAudioTitle);
      await tester.tap(alreadyCommentedAudioFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Tap on the comment icon button to open the comment add list
      // dialog
      final Finder commentInkWellButtonFinder = find.byKey(
        const Key('commentsInkWellButton'),
      );

      await tester.tap(commentInkWellButtonFinder);
      await tester.pumpAndSettle();

      // Find the comment list add dialog widget
      final Finder commentListDialogFinder = find.byType(CommentListAddDialog);

      // Find the list body containing the comments
      final Finder listFinder = find.descendant(
          of: commentListDialogFinder, matching: find.byType(ListBody));

      // Find all the list items
      final Finder itemsFinder = find.descendant(
          // 3 GestureDetector per comment item
          of: listFinder,
          matching: find.byType(GestureDetector));

      // Unique comment index
      int uniqueCommentFinderIndex = 0;

      final Finder playIconButtonFinder = find.descendant(
        of: itemsFinder.at(uniqueCommentFinderIndex),
        matching: find.byKey(const Key('playPauseIconButton')),
      );

      // Tap on the play/pause icon button to play the audio from the
      // comment start position
      await tester.tap(playIconButtonFinder);
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      // Tap on the play/pause icon button to pause the audio
      await tester.tap(playIconButtonFinder);
      await tester.pumpAndSettle();

      // Tap on the Close button to close the comment list add dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    group('App settings set speed test', () {});
  });
  group('Rename audio file test and verify comment access', () {
    testWidgets('''Not existing new audio file name and the renamed audio has
                   no comments.''', (WidgetTester tester) async {
      const String youtubePlaylistTitle =
          'audio_player_view_2_shorts_test'; // Youtube playlist
      const String audioTitle = "Really short video";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: '2_youtube_2_local_playlists_integr_test_data',
        selectedPlaylistTitle: youtubePlaylistTitle,
      );

      // Deletion of comment file used by another test, but not needed
      // for this test
      final String commentFilePath =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubePlaylistTitle${path.separator}$kCommentDirName${path.separator}231117-002826-Really short video 23-07-01.json";
      DirUtil.deleteFileIfExist(pathFileName: commentFilePath);

      // First, find the audio sublist ListTile Text widget

      Finder audioListTileTextWidgetFinder = find.text(audioTitle);

      // Then obtain the audio ListTile widget enclosing the Text widget
      // by finding its ancestor
      Finder audioListTileWidgetFinder = find.ancestor(
        of: audioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now we want to tap the popup menu of the audio ListTile
      // "Really short video"

      // Find the leading menu icon button of the audio ListTile
      // and tap on it
      final Finder audioListTileLeadingMenuIconButton = find.descendant(
        of: audioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(audioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle();

      // Now find the rename audio file popup menu item and tap on it
      final Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_rename_audio_file"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Verify that the rename audio file dialog is displayed
      expect(find.byType(AudioModificationDialog), findsOneWidget);

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

      const String oldFileName =
          '231117-002826-Really short video 23-07-01.mp3';

      expect(textField.controller!.text, oldFileName);

      // Enter new file name

      const String newFileName = '231117-Really short video 23-07-01.mp3';

      await tester.enterText(
        textFieldFinder,
        newFileName,
      );
      await tester.pumpAndSettle();

      // Now tap the rename button
      await tester.tap(find.byKey(const Key('audioModificationButton')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is displayed
      await IntegrationTestUtil.verifyDisplayedWarningAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "Audio file \"$oldFileName\" renamed to \"$newFileName\".",
        isWarningConfirming: true,
      );

      // Verify that the renamed file exists
      final String renamedAudioFilePath =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubePlaylistTitle${path.separator}$newFileName";
      expect(File(renamedAudioFilePath).existsSync(), true);

      // Check the new file name in the audio info dialog

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(audioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle();

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
      await tester.tap(find.byKey(const Key('audio_info_ok_button_key')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('''Not existing new audio file name and not existing new comment
                   file name (the renamed audio has a comment file which will be
                   renamed as well).''', (WidgetTester tester) async {
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
      // file name. Before renaming the file, verify the comment exist ...
      String expectedCommentTitle = 'Accessible after renaming';

      await checkAudioCommentUsingAudioItemMenu(
        tester: tester,
        audioListTileWidgetFinder: audioListTileWidgetFinder,
        expectedCommentTitle: expectedCommentTitle,
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
      await tester.pumpAndSettle();

      // Now find the rename audio file popup menu item and tap on it
      final Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_rename_audio_file"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Verify that the rename audio file dialog is displayed
      expect(find.byType(AudioModificationDialog), findsOneWidget);

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

      const String oldMp3FileName =
          '231117-002828-morning _ cinematic video 23-07-01.mp3';

      expect(textField.controller!.text, oldMp3FileName);

      // Enter new file name

      const String newMp3FileName = '240610-Renamed video 23-07-01.mp3';

      await tester.enterText(
        textFieldFinder,
        newMp3FileName,
      );
      await tester.pumpAndSettle();

      // Now tap the rename button
      await tester.tap(find.byKey(const Key('audioModificationButton')));
      await tester.pumpAndSettle();

      // Ensure the warning dialog is displayed

      final String oldJsonFileName = oldMp3FileName.replaceAll('mp3', 'json');
      final String newJsonFileName = newMp3FileName.replaceAll('mp3', 'json');

      await IntegrationTestUtil.verifyDisplayedWarningAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "Audio file \"$oldMp3FileName\" renamed to \"$newMp3FileName\" as well as comment file \"$oldJsonFileName\" renamed to \"$newJsonFileName\".",
        isWarningConfirming: true,
      );

      // Verify that the renamed file exists
      final String renamedAudioFilePath =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubePlaylistTitle${path.separator}$newMp3FileName";
      expect(File(renamedAudioFilePath).existsSync(), true);

      // Check the new file name in the audio info dialog

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(audioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle();

      // Now find the popup menu item and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_display_audio_info"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Verify the audio new file name

      final Text audioFileNameTitleTextWidget =
          tester.widget<Text>(find.byKey(const Key('audioFileNameKey')));

      expect(audioFileNameTitleTextWidget.data, newMp3FileName);

      // Tap the Ok button to close the audio info dialog
      await tester.tap(find.byKey(const Key('audio_info_ok_button_key')));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // The audio file we could not rename still access to its comment ...
      await checkAudioCommentInAudioPlayerView(
        tester: tester,
        audioListTileWidgetFinder: audioListTileWidgetFinder,
        expectedCommentTitle: expectedCommentTitle,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Existing new audio file name. The new file name is the name of an
           existing file in the same directory. In this case, a warning is
           displayed and the file is not renamed.''',
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
      await tester.pumpAndSettle();

      // Now find the rename audio file popup menu item and tap on it
      final Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_rename_audio_file"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Verify that the rename audio file dialog is displayed
      expect(find.byType(AudioModificationDialog), findsOneWidget);

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

      // Now entering the name of an existing file in the audio directory
      // in the file name TextField
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
      await IntegrationTestUtil.verifyDisplayedWarningAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "The file name \"$fileNameOfExistingFile\" already exists in the same directory and cannot be used.",
      );

      // Verify that the old name file exists
      final String renamedAudioFilePath =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubePlaylistTitle${path.separator}$initialFileName";
      expect(File(renamedAudioFilePath).existsSync(), true);

      // Check the old file name in the audio info dialog

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(audioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle();

      // Now find the popup menu item and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_display_audio_info"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Verify the audio old file name

      final Text audioFileNameTitleTextWidget =
          tester.widget<Text>(find.byKey(const Key('audioFileNameKey')));

      expect(audioFileNameTitleTextWidget.data, initialFileName);

      // Tap the Ok button to close the audio info dialog
      await tester.tap(find.byKey(const Key('audio_info_ok_button_key')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Invalid new file name with no mp3 extension. In this case, a warning
           is displayed and the file is not renamed.''',
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
      await tester.pumpAndSettle();

      // Now find the rename audio file popup menu item and tap on it
      final Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_rename_audio_file"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Verify that the rename audio file dialog is displayed
      expect(find.byType(AudioModificationDialog), findsOneWidget);

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

      // Now entering an invalid file name in the file name TextField
      const String fileNameOfExistingFile = 'Really short video';

      await tester.enterText(
        textFieldFinder,
        fileNameOfExistingFile,
      );
      await tester.pumpAndSettle();

      // Now tap the rename button
      await tester.tap(find.byKey(const Key('audioModificationButton')));
      await tester.pumpAndSettle();

      // Since file name has no mp3 extension a warning will be displayed ...

      // Ensure the warning dialog is displayed
      await IntegrationTestUtil.verifyDisplayedWarningAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "The audio file name \"$fileNameOfExistingFile\" has no mp3 extension and so is invalid.",
      );

      // Verify that the old name file exists
      final String renamedAudioFilePath =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubePlaylistTitle${path.separator}$initialFileName";
      expect(File(renamedAudioFilePath).existsSync(), true);

      // Check the old file name in the audio info dialog

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(audioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle();

      // Now find the popup menu item and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_display_audio_info"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Verify the audio old file name

      final Text audioFileNameTitleTextWidget =
          tester.widget<Text>(find.byKey(const Key('audioFileNameKey')));

      expect(audioFileNameTitleTextWidget.data, initialFileName);

      // Tap the Ok button to close the audio info dialog
      await tester.tap(find.byKey(const Key('audio_info_ok_button_key')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('''Not existing new audio file name and existing new comment
                   file name. The renamed audio has a comment file which will be
                   renamed as well, but since a comment file exist with
                   the renamed comment file name, a warning will be displayed
                   and the file will not be renamed.''',
        (WidgetTester tester) async {
      const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
      const String audioToRenameTitle =
          "Quand Aurélien Barrau va dans une école de management";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_comment_corrected_test',
        selectedPlaylistTitle: youtubePlaylistTitle,
      );

      // Before renaming the audio file, we verify that the audio has
      // a comment

      // First, find the audio sublist ListTile Text widget

      Finder audioListTileTextWidgetFinder = find.text(audioToRenameTitle);

      // Then obtain the audio ListTile widget enclosing the Text widget
      // by finding its ancestor
      Finder audioListTileWidgetFinder = find.ancestor(
        of: audioListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // The audio file we will rename has a comment linked to this
      // file name. Before renaming the file, verify the comment exist ...

      String anAudioCommentTitle = 'Aurélien three';

      await checkAudioCommentUsingAudioItemMenu(
        tester: tester,
        audioListTileWidgetFinder: audioListTileWidgetFinder,
        expectedCommentTitle: anAudioCommentTitle,
      );

      // Now we want to tap the popup menu of the audio ListTile
      // "Quand Aurélien Barrau va dans une école de management"

      // Find the leading menu icon button of the audio ListTile
      // and tap on it
      final Finder audioListTileLeadingMenuIconButton = find.descendant(
        of: audioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(audioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle();

      // Now find the rename audio file popup menu item and tap on it
      final Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_rename_audio_file"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Verify that the rename audio file dialog is displayed
      expect(find.byType(AudioModificationDialog), findsOneWidget);

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
          '240722-081104-Quand Aurélien Barrau va dans une école de management 23-09-10.mp3');

      const String newFileName = 'New file name.mp3';

      await tester.enterText(
        textFieldFinder,
        newFileName,
      );

      await tester.pumpAndSettle();

      // Now tap the rename button
      await tester.tap(find.byKey(const Key('audioModificationButton')));
      await tester.pumpAndSettle();

      // Since file name is the name of an existing comment file in the
      // audio comment directory, a warning will be displayed ...

      // Ensure the warning dialog is displayed
      await IntegrationTestUtil.verifyDisplayedWarningAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "The comment file name \"${newFileName.substring(0, newFileName.length - 4)}.json\" already exists in the comment directory and so renaming the audio file with the name \"$newFileName\" is not possible.",
      );

      // Verify that the old name file exists
      const String initialFileName =
          "240722-081104-Quand Aurélien Barrau va dans une école de management 23-09-10.mp3";
      final String renamedAudioFilePath =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubePlaylistTitle${path.separator}$initialFileName";
      expect(File(renamedAudioFilePath).existsSync(), true);

      // Check the old file name in the audio info dialog

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(audioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle();

      // Now find the popup menu item and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_display_audio_info"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Verify the audio old file name

      final Text audioFileNameTitleTextWidget =
          tester.widget<Text>(find.byKey(const Key('audioFileNameKey')));

      expect(audioFileNameTitleTextWidget.data, initialFileName);

      // Tap the Ok button to close the audio info dialog
      await tester.tap(find.byKey(const Key('audio_info_ok_button_key')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('Modify audio title test and verify comment display change', () {
    testWidgets('Downl audio: change audio title', (WidgetTester tester) async {
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
      await tester.pumpAndSettle();

      // Now find the modify audio title popup menu item and tap on
      // it
      final Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_modify_audio_title"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Verify that the rename audio file dialog is displayed
      expect(find.byType(AudioModificationDialog), findsOneWidget);

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
      await tester.pumpAndSettle();

      // Now find the popup menu item and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_display_audio_info"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Verify the audio new title

      final Text audioTitleTextWidget =
          tester.widget<Text>(find.byKey(const Key('validVideoTitleKey')));

      expect(audioTitleTextWidget.data, newTitle);

      // Verify the presence of Original video title label
      expect(find.text('Original video title'), findsOneWidget);

      // Verify the absence of Audio title label
      expect(find.text('Audio title'), findsNothing);

      // Tap the Ok button to close the audio info dialog
      await tester.tap(find.byKey(const Key('audio_info_ok_button_key')));
      await tester.pumpAndSettle();

      // Verifying that the comment of the audio displays the modified audio title
      await checkAudioCommentUsingAudioItemMenu(
        tester: tester,
        audioListTileWidgetFinder: audioListTileWidgetFinder,
        expectedCommentTitle: 'Accessible after renaming',
        audioTitleToVerifyInCommentAddEditDialog: newTitle,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('Imported audio: change audio title',
        (WidgetTester tester) async {
      const String youtubePlaylistTitle =
          'audio_player_view_2_shorts_test'; // Youtube playlist
      const String audioTitle = "Really short video";

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
      await tester.pumpAndSettle();

      // Now find the modify audio title popup menu item and tap on
      // it
      final Finder popupCopyMenuItem =
          find.byKey(const Key("popup_menu_modify_audio_title"));

      await tester.tap(popupCopyMenuItem);
      await tester.pumpAndSettle();

      // Verify that the rename audio file dialog is displayed
      expect(find.byType(AudioModificationDialog), findsOneWidget);

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
      expect(textField.controller!.text, 'Really short video');

      const String newTitle = 'Really really short imported audio';
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
      await tester.pumpAndSettle();

      // Now find the popup menu item and tap on it
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_display_audio_info"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      // Verify the audio new title

      final Text audioTitleTextWidget =
          tester.widget<Text>(find.byKey(const Key('importedAudioTitleKey')));

      expect(audioTitleTextWidget.data, newTitle);

      // Verify the presence of Audio title label
      expect(find.text('Audio title'), findsOneWidget);

      // Verify the absence of Original video title label
      expect(find.text('Original video title'), findsNothing);

      // Tap the Close button to close the audio info dialog
      await tester.tap(find.byKey(const Key('audio_info_ok_button_key')));
      await tester.pumpAndSettle();

      // Verifying that the comment of the audio displays the modified audio title
      await checkAudioCommentUsingAudioItemMenu(
        tester: tester,
        audioListTileWidgetFinder: audioListTileWidgetFinder,
        expectedCommentTitle: 'Accessible after renaming',
        audioTitleToVerifyInCommentAddEditDialog: newTitle,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('Playlist audio comments dialog test', () {
    testWidgets(
        '''On empty playlist, opening the playlist audio comments dialog.''',
        (WidgetTester tester) async {
      const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
      const String emptyPlaylistTitle = 'Empty'; // Youtube playlist

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'import_audio_file_test',
        selectedPlaylistTitle: youtubePlaylistTitle,
      );

      // First, find the Empty playlist sublist ListTile Text widget
      Finder emptyPlaylistListTileTextWidgetFinder =
          find.text(emptyPlaylistTitle);

      // Then obtain the playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      Finder emptyPlaylistListTileWidgetFinder = find.ancestor(
        of: emptyPlaylistListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now we want to tap the popup menu of the Empty  playlist ListTile

      // Find the leading menu icon button of the playlist ListTile
      // and tap on it
      Finder emptyPlaylistListTileLeadingMenuIconButton = find.descendant(
        of: emptyPlaylistListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the leading menu icon button to open the popup menu
      await tester.tap(emptyPlaylistListTileLeadingMenuIconButton);
      await tester.pumpAndSettle();

      // Now find the List comments of playlist audio popup menu
      // item and tap on it
      final Finder popupPlaylistAudioCommentsMenuItem =
          find.byKey(const Key("popup_menu_display_playlist_audio_comments"));

      await tester.tap(popupPlaylistAudioCommentsMenuItem);
      await tester.pumpAndSettle();

      // Verify that the playlist audio comment dialog is displayed
      expect(find.byType(PlaylistCommentListDialog), findsOneWidget);

      // Verify the dialog title
      expect(find.text('Playlist audio comments'), findsOneWidget);

      // Verify that the audio comments list of the dialog is empty

      final Finder playlistCommentsLstFinder = find.byKey(const Key(
        'playlistCommentsListKey',
      ));

      // Ensure the list has no child widgets
      expect(
        tester.widget<ListBody>(playlistCommentsLstFinder).children.length,
        0,
      );

      // Tap on Close text button
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('''Playlist comments color verification.''',
        (WidgetTester tester) async {
      const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_comment_color_test',
        selectedPlaylistTitle: youtubePlaylistTitle,
      );

      // First, open the playlist comment dialog
      Finder playlistCommentListDialogFinder = await openPlaylistCommentDialog(
        tester: tester,
        playlistTitle: youtubePlaylistTitle,
      );

      final Finder playlistCommentListFinder =
          find.byKey(const Key('playlistCommentsListKey'));

      // Ensure the list has 8 child widgets
      expect(
        tester.widget<ListBody>(playlistCommentListFinder).children.length,
        8,
      );

      // Verify the color of the audio titles in the playlist comment dialog

      await verifyAudioTitlesColorInPlaylistCommentDialog(
        tester: tester,
        playlistCommentListDialogFinder: playlistCommentListDialogFinder,
      );

      // Verifying the color of the comments titles in the playlist comment
      // dialog

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        enclosingWidgetFinder: playlistCommentListDialogFinder,
        audioTitleOrSubTitle: "Barrau one",
        expectedTitleTextColor: null,
        expectedTitleTextBackgroundColor: null,
      );

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        enclosingWidgetFinder: playlistCommentListDialogFinder,
        audioTitleOrSubTitle: "One",
        expectedTitleTextColor: null,
        expectedTitleTextBackgroundColor: null,
      );

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        enclosingWidgetFinder: playlistCommentListDialogFinder,
        audioTitleOrSubTitle: "Comment Jancovici",
        expectedTitleTextColor: null,
        expectedTitleTextBackgroundColor: null,
      );

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        enclosingWidgetFinder: playlistCommentListDialogFinder,
        audioTitleOrSubTitle: "Start",
        expectedTitleTextColor: null,
        expectedTitleTextBackgroundColor: null,
      );

      // Tap on Close text button
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    group('Playing one comment, fully played audio', () {
      testWidgets('''One comment full play color verification. Play one comment
           completely. Then close the playlist comment dialog and reopen it.
           Verify that the played comment color was not changed, which means
           that the commented audio position change due to the comment play was
           undone. Verify as well that the current audio change caused by the
           played comment audio was undone as well.''',
          (WidgetTester tester) async {
        const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
        const String playedCommentAudioTitle =
            "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...";

        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'audio_comment_color_test',
          selectedPlaylistTitle: youtubePlaylistTitle,
        );

        // First, open the playlist comment dialog
        Finder playlistCommentListDialogFinder =
            await openPlaylistCommentDialog(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
        );

        // Find the list of comments in the playlist comment dialog
        final Finder listFinder = find.descendant(
            of: playlistCommentListDialogFinder,
            matching: find.byType(ListBody));

        // Find all the list items GestureDetector's
        final Finder gestureDetectorsFinder = find.descendant(
            // 3 GestureDetector per comment item
            of: listFinder,
            matching: find.byType(GestureDetector));

        // Now tap on the play icon button of the unique comment of the second
        // audio in order to play it completely
        await IntegrationTestUtil.playComment(
          tester: tester,
          gestureDetectorsFinder: gestureDetectorsFinder,
          itemIndex: 3,
          typeOnPauseAfterPlay: false,
          maxPlayDurationSeconds: 3,
        );

        // Tap on Close text button
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Now, re-open the playlist comment dialog
        playlistCommentListDialogFinder = await openPlaylistCommentDialog(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
        );

        // Verify the color of the audio titles in the playlist comment dialog

        await verifyAudioTitlesColorInPlaylistCommentDialog(
          tester: tester,
          playlistCommentListDialogFinder: playlistCommentListDialogFinder,
        );

        // Tap on Close text button
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // When closing the playlist comment dialog, the played comment audio
        // modification was undone. Verifying that ...
        await verifyUndoneListenedAudioPosition(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
          playedCommentAudioTitle: playedCommentAudioTitle,
          playableAudioLstAudioIndex: 1,
          audioPositionStr: '1:17:54',
          audioPositionSeconds: 4674,
          audioRemainingDurationStr: '0:00',
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          audioPausedDateTime: DateTime(2024, 9, 8, 14, 38, 43),
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets(
          '''One comment pause on partial play color verification. Play one comment
           partially, clicking on pause button after 1.5 seconds. Then close the
           playlist comment dialog and reopen it. Verify that the played comment
           color was not changed, which means that the commented audio position
           change due to the comment play was undone. Verify as well that the
           current audio change caused by the played comment audio was undone as
           well.''', (WidgetTester tester) async {
        const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
        const String playedCommentAudioTitle =
            "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...";

        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'audio_comment_color_test',
          selectedPlaylistTitle: youtubePlaylistTitle,
        );

        // First, open the playlist comment dialog
        Finder playlistCommentListDialogFinder =
            await openPlaylistCommentDialog(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
        );

        // Find the list of comments in the playlist comment dialog
        final Finder listFinder = find.descendant(
            of: playlistCommentListDialogFinder,
            matching: find.byType(ListBody));

        // Find all the list items GestureDetector's
        final Finder gestureDetectorsFinder = find.descendant(
            // 3 GestureDetector per comment item
            of: listFinder,
            matching: find.byType(GestureDetector));

        // Now tap on the play icon button of the unique comment of the fourth
        // audio in order to play it partially (during 1.5 seconds)
        await IntegrationTestUtil.playComment(
          tester: tester,
          gestureDetectorsFinder: gestureDetectorsFinder,
          itemIndex: 3,
          typeOnPauseAfterPlay: true,
          maxPlayDurationSeconds: 1.5,
        );

        // Tap on Close text button
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Now, re-open the playlist comment dialog
        playlistCommentListDialogFinder = await openPlaylistCommentDialog(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
        );

        // Verify the color of the audio titles in the playlist comment dialog

        await verifyAudioTitlesColorInPlaylistCommentDialog(
          tester: tester,
          playlistCommentListDialogFinder: playlistCommentListDialogFinder,
        );

        // Tap on Close text button
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // When closing the playlist comment dialog, the played comment audio
        // modification was undone. Verifying that ...
        await verifyUndoneListenedAudioPosition(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
          playedCommentAudioTitle: playedCommentAudioTitle,
          playableAudioLstAudioIndex: 1,
          audioPositionStr: '1:17:54',
          audioPositionSeconds: 4674,
          audioRemainingDurationStr: '0:00',
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          audioPausedDateTime: DateTime(2024, 9, 8, 14, 38, 43),
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets(
          '''One comment close on partial play color verification. Play one
           comment partially, clicking on close playlist comment dialog button
           after 1.5 seconds. Then reopen the dialog. Verify that the played comment
           color was not changed, which means that the commented audio position
           change due to the comment play was undone. Verify as well that the
           current audio change caused by the played comment audio was undone as
           well.''', (WidgetTester tester) async {
        const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
        const String playedCommentAudioTitle =
            "La surpopulation mondiale par Jancovici et Barrau";

        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'audio_comment_color_test',
          selectedPlaylistTitle: youtubePlaylistTitle,
        );

        // First, open the playlist comment dialog
        Finder playlistCommentListDialogFinder =
            await openPlaylistCommentDialog(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
        );

        // Find the list of comments in the playlist comment dialog
        final Finder listFinder = find.descendant(
            of: playlistCommentListDialogFinder,
            matching: find.byType(ListBody));

        // Find all the list items GestureDetector's
        final Finder gestureDetectorsFinder = find.descendant(
            // 3 GestureDetector per comment item
            of: listFinder,
            matching: find.byType(GestureDetector));

        // Now tap on the play icon button of the unique comment of the second
        // audio in order to play it partially (during 1.5 seconds)
        await IntegrationTestUtil.playComment(
          tester: tester,
          gestureDetectorsFinder: gestureDetectorsFinder,
          itemIndex: 9,
          typeOnPauseAfterPlay: false,
        );

        // Let the comment be played during 1.5 seconds and then clixk on the
        // playlist comment dialog close button
        await Future.delayed(const Duration(milliseconds: 1500));
        await tester.pumpAndSettle();

        // Tap on Close text button
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Now, re-open the playlist comment dialog
        playlistCommentListDialogFinder = await openPlaylistCommentDialog(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
        );

        // Verify the color of the audio titles in the playlist comment dialog

        await verifyAudioTitlesColorInPlaylistCommentDialog(
          tester: tester,
          playlistCommentListDialogFinder: playlistCommentListDialogFinder,
        );

        // Tap on Close text button
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Tap on the 'Toggle List' button to hide the playlist list
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // When closing the playlist comment dialog, the played comment audio
        // modification was undone. Verifying that ...
        await verifyUndoneListenedAudioPosition(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
          playedCommentAudioTitle: playedCommentAudioTitle,
          playableAudioLstAudioIndex: 2,
          audioPositionStr: '0:00',
          audioPositionSeconds: 0,
          audioRemainingDurationStr: '7:38',
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          audioPausedDateTime: null,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
    group('Playing one comment, partially played audio', () {
      testWidgets('''One comment partially play color verification. Play comment
           completely. Then close the playlist comment dialog and reopen it.
           Verify that the played comment color was not changed, which means
           that the commented audio position change due to the comment play was
           undone. Verify as well that the current audio change caused by the
           played comment audio was undone as well.''',
          (WidgetTester tester) async {
        const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
        const String playedCommentAudioTitle =
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique";

        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'audio_comment_color_test',
          selectedPlaylistTitle: youtubePlaylistTitle,
        );

        // First, open the playlist comment dialog
        Finder playlistCommentListDialogFinder =
            await openPlaylistCommentDialog(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
        );

        // Find the list of comments in the playlist comment dialog
        final Finder listFinder = find.descendant(
            of: playlistCommentListDialogFinder,
            matching: find.byType(ListBody));

        // Find all the list items GestureDetector's
        final Finder gestureDetectorsFinder = find.descendant(
            // 3 GestureDetector per comment item
            of: listFinder,
            matching: find.byType(GestureDetector));

        // Now tap on the play icon button of the unique comment of the third
        // audio in order to play it completely
        await IntegrationTestUtil.playComment(
          tester: tester,
          gestureDetectorsFinder: gestureDetectorsFinder,
          itemIndex: 6,
          typeOnPauseAfterPlay: false,
          maxPlayDurationSeconds: 3,
        );

        // Tap on Close text button
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Now, re-open the playlist comment dialog
        playlistCommentListDialogFinder = await openPlaylistCommentDialog(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
        );

        // Verify the color of the audio titles in the playlist comment dialog

        await verifyAudioTitlesColorInPlaylistCommentDialog(
          tester: tester,
          playlistCommentListDialogFinder: playlistCommentListDialogFinder,
        );

        // Tap on Close text button
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // When closing the playlist comment dialog, the played comment audio
        // modification was undone. Verifying that ...
        await verifyUndoneListenedAudioPosition(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
          playedCommentAudioTitle: playedCommentAudioTitle,
          playableAudioLstAudioIndex: 3,
          audioPositionStr: '5:11',
          audioPositionSeconds: 311,
          audioRemainingDurationStr: '1:18',
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: true,
          audioPausedDateTime: DateTime(2024, 9, 9, 19, 47, 23),
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets(
          '''One comment pause on partial play color verification. Play one comment
           partially, clicking on pause button after 1.5 seconds. Then close the
           playlist comment dialog and reopen it. Verify that the played comment
           color was not changed, which means that the commented audio position
           change due to the comment play was undone. Verify as well that the
           current audio change caused by the played comment audio was undone as
           well.''', (WidgetTester tester) async {
        const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
        const String playedCommentAudioTitle =
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique";

        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'audio_comment_color_test',
          selectedPlaylistTitle: youtubePlaylistTitle,
        );

        // First, open the playlist comment dialog
        Finder playlistCommentListDialogFinder =
            await openPlaylistCommentDialog(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
        );

        // Find the list of comments in the playlist comment dialog
        final Finder listFinder = find.descendant(
            of: playlistCommentListDialogFinder,
            matching: find.byType(ListBody));

        // Find all the list items GestureDetector's
        final Finder gestureDetectorsFinder = find.descendant(
            // 3 GestureDetector per comment item
            of: listFinder,
            matching: find.byType(GestureDetector));

        // Now tap on the play icon button of the unique comment of the fourth
        // audio in order to play it partially (during 1.5 seconds)
        await IntegrationTestUtil.playComment(
          tester: tester,
          gestureDetectorsFinder: gestureDetectorsFinder,
          itemIndex: 6,
          typeOnPauseAfterPlay: true,
          maxPlayDurationSeconds: 1.5,
        );

        // Tap on Close text button
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Now, re-open the playlist comment dialog
        playlistCommentListDialogFinder = await openPlaylistCommentDialog(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
        );

        // Verify the color of the audio titles in the playlist comment dialog

        await verifyAudioTitlesColorInPlaylistCommentDialog(
          tester: tester,
          playlistCommentListDialogFinder: playlistCommentListDialogFinder,
        );

        // Tap on Close text button
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // When closing the playlist comment dialog, the played comment audio
        // modification was undone. Verifying that ...
        await verifyUndoneListenedAudioPosition(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
          playedCommentAudioTitle: playedCommentAudioTitle,
          playableAudioLstAudioIndex: 3,
          audioPositionStr: '5:11',
          audioPositionSeconds: 311,
          audioRemainingDurationStr: '1:18',
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: true,
          audioPausedDateTime: DateTime(2024, 9, 9, 19, 47, 23),
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets(
          '''One comment close on partial play color verification. Play one
           comment partially, clicking on close playlist comment dialog button
           after 1.5 seconds. Then reopen the dialog. Verify that the played comment
           color was not changed, which means that the commented audio position
           change due to the comment play was undone. Verify as well that the
           current audio change caused by the played comment audio was undone as
           well.''', (WidgetTester tester) async {
        const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
        const String playedCommentAudioTitle =
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique";

        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'audio_comment_color_test',
          selectedPlaylistTitle: youtubePlaylistTitle,
        );

        // First, open the playlist comment dialog
        Finder playlistCommentListDialogFinder =
            await openPlaylistCommentDialog(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
        );

        // Find the list of comments in the playlist comment dialog
        final Finder listFinder = find.descendant(
            of: playlistCommentListDialogFinder,
            matching: find.byType(ListBody));

        // Find all the list items GestureDetector's
        final Finder gestureDetectorsFinder = find.descendant(
            // 3 GestureDetector per comment item
            of: listFinder,
            matching: find.byType(GestureDetector));

        // Now tap on the play icon button of the unique comment of the second
        // audio in order to play it partially (during 1.5 seconds)
        await IntegrationTestUtil.playComment(
          tester: tester,
          gestureDetectorsFinder: gestureDetectorsFinder,
          itemIndex: 6,
          typeOnPauseAfterPlay: false,
        );

        // Let the comment be played during 1.5 seconds and then clixk on the
        // playlist comment dialog close button
        await Future.delayed(const Duration(milliseconds: 1500));
        await tester.pumpAndSettle();

        // Tap on Close text button
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Now, re-open the playlist comment dialog
        playlistCommentListDialogFinder = await openPlaylistCommentDialog(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
        );

        // Verify the color of the audio titles in the playlist comment dialog

        await verifyAudioTitlesColorInPlaylistCommentDialog(
          tester: tester,
          playlistCommentListDialogFinder: playlistCommentListDialogFinder,
        );

        // Tap on Close text button
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Tap on the 'Toggle List' button to hide the playlist list
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // When closing the playlist comment dialog, the played comment audio
        // modification was undone. Verifying that ...
        await verifyUndoneListenedAudioPosition(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
          playedCommentAudioTitle: playedCommentAudioTitle,
          playableAudioLstAudioIndex: 3,
          audioPositionStr: '5:11',
          audioPositionSeconds: 311,
          audioRemainingDurationStr: '1:18',
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: true,
          audioPausedDateTime: DateTime(2024, 9, 9, 19, 47, 23),
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
    group('Playing one comment, unplayed audio', () {
      testWidgets('''One comment full play color verification. Play one comment
           completely. Then close the playlist comment dialog and reopen it.
           Verify that the played comment color was not changed, which means
           that the commented audio position change due to the comment play was
           undone. Verify as well that the current audio change caused by the
           played comment audio was undone as well.''',
          (WidgetTester tester) async {
        const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
        const String playedCommentAudioTitle =
            "La surpopulation mondiale par Jancovici et Barrau";

        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'audio_comment_color_test',
          selectedPlaylistTitle: youtubePlaylistTitle,
        );

        // First, open the playlist comment dialog
        Finder playlistCommentListDialogFinder =
            await openPlaylistCommentDialog(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
        );

        // Find the list of comments in the playlist comment dialog
        final Finder listFinder = find.descendant(
            of: playlistCommentListDialogFinder,
            matching: find.byType(ListBody));

        // Find all the list items GestureDetector's
        final Finder gestureDetectorsFinder = find.descendant(
            // 3 GestureDetector per comment item
            of: listFinder,
            matching: find.byType(GestureDetector));

        // Now tap on the play icon button of the unique comment of the second
        // audio in order to play it completely
        await IntegrationTestUtil.playComment(
          tester: tester,
          gestureDetectorsFinder: gestureDetectorsFinder,
          itemIndex: 9,
          typeOnPauseAfterPlay: false,
          maxPlayDurationSeconds: 3,
        );

        // Tap on Close text button
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Now, re-open the playlist comment dialog
        playlistCommentListDialogFinder = await openPlaylistCommentDialog(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
        );

        // Verify the color of the audio titles in the playlist comment dialog

        await verifyAudioTitlesColorInPlaylistCommentDialog(
          tester: tester,
          playlistCommentListDialogFinder: playlistCommentListDialogFinder,
        );

        // Tap on Close text button
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Tap on the 'Toggle List' button to hide the playlist list
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // When closing the playlist comment dialog, the played comment audio
        // modification was undone. Verifying that ...
        await verifyUndoneListenedAudioPosition(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
          playedCommentAudioTitle: playedCommentAudioTitle,
          playableAudioLstAudioIndex: 2,
          audioPositionStr: '0:00',
          audioPositionSeconds: 0,
          audioRemainingDurationStr: '7:38',
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          audioPausedDateTime: null,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets(
          '''One comment pause on partial play color verification. Play one comment
           partially, clicking on pause button after 1.5 seconds. Then close the
           playlist comment dialog and reopen it. Verify that the played comment
           color was not changed, which means that the commented audio position
           change due to the comment play was undone. Verify as well that the
           current audio change caused by the played comment audio was undone as
           well.''', (WidgetTester tester) async {
        const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
        const String playedCommentAudioTitle =
            "La surpopulation mondiale par Jancovici et Barrau";

        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'audio_comment_color_test',
          selectedPlaylistTitle: youtubePlaylistTitle,
        );

        // First, open the playlist comment dialog
        Finder playlistCommentListDialogFinder =
            await openPlaylistCommentDialog(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
        );

        // Find the list of comments in the playlist comment dialog
        final Finder listFinder = find.descendant(
            of: playlistCommentListDialogFinder,
            matching: find.byType(ListBody));

        // Find all the list items GestureDetector's
        final Finder gestureDetectorsFinder = find.descendant(
            // 3 GestureDetector per comment item
            of: listFinder,
            matching: find.byType(GestureDetector));

        // Now tap on the play icon button of the unique comment of the fourth
        // audio in order to play it partially (during 1.5 seconds)
        await IntegrationTestUtil.playComment(
          tester: tester,
          gestureDetectorsFinder: gestureDetectorsFinder,
          itemIndex: 9,
          typeOnPauseAfterPlay: true,
          maxPlayDurationSeconds: 1.5,
        );

        // Tap on Close text button
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Now, re-open the playlist comment dialog
        playlistCommentListDialogFinder = await openPlaylistCommentDialog(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
        );

        // Verify the color of the audio titles in the playlist comment dialog

        await verifyAudioTitlesColorInPlaylistCommentDialog(
          tester: tester,
          playlistCommentListDialogFinder: playlistCommentListDialogFinder,
        );

        // Tap on Close text button
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Tap on the 'Toggle List' button to hide the playlist list
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // When closing the playlist comment dialog, the played comment audio
        // modification was undone. Verifying that ...
        await verifyUndoneListenedAudioPosition(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
          playedCommentAudioTitle: playedCommentAudioTitle,
          playableAudioLstAudioIndex: 2,
          audioPositionStr: '0:00',
          audioPositionSeconds: 0,
          audioRemainingDurationStr: '7:38',
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          audioPausedDateTime: null,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets(
          '''One comment close on partial play color verification. Play one
           comment partially, clicking on close playlist comment dialog button
           after 1.5 seconds. Then reopen the dialog. Verify that the played comment
           color was not changed, which means that the commented audio position
           change due to the comment play was undone. Verify as well that the
           current audio change caused by the played comment audio was undone as
           well.''', (WidgetTester tester) async {
        const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
        const String playedCommentAudioTitle =
            "La surpopulation mondiale par Jancovici et Barrau";

        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'audio_comment_color_test',
          selectedPlaylistTitle: youtubePlaylistTitle,
        );

        // First, open the playlist comment dialog
        Finder playlistCommentListDialogFinder =
            await openPlaylistCommentDialog(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
        );

        // Find the list of comments in the playlist comment dialog
        final Finder listFinder = find.descendant(
            of: playlistCommentListDialogFinder,
            matching: find.byType(ListBody));

        // Find all the list items GestureDetector's
        final Finder gestureDetectorsFinder = find.descendant(
            // 3 GestureDetector per comment item
            of: listFinder,
            matching: find.byType(GestureDetector));

        // Now tap on the play icon button of the unique comment of the second
        // audio in order to play it partially (during 1.5 seconds)
        await IntegrationTestUtil.playComment(
          tester: tester,
          gestureDetectorsFinder: gestureDetectorsFinder,
          itemIndex: 9,
          typeOnPauseAfterPlay: false,
        );

        // Let the comment be played during 1.5 seconds and then clixk on the
        // playlist comment dialog close button
        await Future.delayed(const Duration(milliseconds: 1500));
        await tester.pumpAndSettle();

        // Tap on Close text button
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Now, re-open the playlist comment dialog
        playlistCommentListDialogFinder = await openPlaylistCommentDialog(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
        );

        // Verify the color of the audio titles in the playlist comment dialog

        await verifyAudioTitlesColorInPlaylistCommentDialog(
          tester: tester,
          playlistCommentListDialogFinder: playlistCommentListDialogFinder,
        );

        // Tap on Close text button
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Tap on the 'Toggle List' button to hide the playlist list
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // When closing the playlist comment dialog, the played comment audio
        // modification was undone. Verifying that ...
        await verifyUndoneListenedAudioPosition(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
          playedCommentAudioTitle: playedCommentAudioTitle,
          playableAudioLstAudioIndex: 2,
          audioPositionStr: '0:00',
          audioPositionSeconds: 0,
          audioRemainingDurationStr: '7:38',
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          audioPausedDateTime: null,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
    // group('Playing several comments', () {
    // testWidgets(
    //     '''Three comments partially played color verification. Play second
    //      comment partially, then play third comment partially, then play fourth
    //      comment partially until you close the playlist comment dialog. Then
    //      reopen the playlist comment dialog and verify that the played comments
    //      color was not changed, which means that the commented audio position
    //      changes related to the comment play of the three comments were undone.
    //      Verify as well that the played audio changes caused by the comments
    //      playing was undone as well.''', (WidgetTester tester) async {
    //   const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
    //   const String secondPlayedCommentAudioTitle =
    //       "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...";
    //   const String thirdPlayedCommentAudioTitle =
    //       "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique";
    //   const String fourthPlayedCommentAudioTitle =
    //       "La surpopulation mondiale par Jancovici et Barrau";

    //   await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
    //     tester: tester,
    //     savedTestDataDirName: 'audio_comment_color_test',
    //     selectedPlaylistTitle: youtubePlaylistTitle,
    //   );

    //   // First, open the playlist comment dialog
    //   Finder playlistCommentListDialogFinder =
    //       await openPlaylistCommentDialog(
    //     tester: tester,
    //     playlistTitle: youtubePlaylistTitle,
    //   );

    //   // Find the list of comments in the playlist comment dialog
    //   final Finder listFinder = find.descendant(
    //       of: playlistCommentListDialogFinder,
    //       matching: find.byType(ListBody));

    //   // Find all the list items GestureDetector's
    //   final Finder gestureDetectorsFinder = find.descendant(
    //       // 3 GestureDetector per comment item
    //       of: listFinder,
    //       matching: find.byType(GestureDetector));

    //   // Now tap on the play icon button of the unique comment of the second
    //   // audio in order to start playing it
    //   await IntegrationTestUtil.playComment(
    //     tester: tester,
    //     gestureDetectorsFinder: gestureDetectorsFinder,
    //     itemIndex: 3,
    //     typeOnPauseAfterPlay: false,
    //     maxPlayDurationSeconds: 3,
    //   );

    //   // Let the second comment be played during 1.5 seconds and then clixk
    //   // on the play button of the third comment
    //   await Future.delayed(const Duration(milliseconds: 1500));
    //   await tester.pumpAndSettle();

    //   // Now tap on the play icon button of the unique comment of the third
    //   // audio in order to start playing it
    //   await IntegrationTestUtil.playComment(
    //     tester: tester,
    //     gestureDetectorsFinder: gestureDetectorsFinder,
    //     itemIndex: 6,
    //     typeOnPauseAfterPlay: false,
    //     maxPlayDurationSeconds: 3,
    //   );

    //   // Let the third comment be played during 1.5 seconds and then clixk
    //   // on the play button of the fourth comment
    //   await Future.delayed(const Duration(milliseconds: 1500));
    //   await tester.pumpAndSettle();

    //   // Now tap on the play icon button of the unique comment of the fourth
    //   // audio in order to start playing it
    //   await IntegrationTestUtil.playComment(
    //     tester: tester,
    //     gestureDetectorsFinder: gestureDetectorsFinder,
    //     itemIndex: 9,
    //     typeOnPauseAfterPlay: false,
    //     maxPlayDurationSeconds: 3,
    //   );

    //   // Let the third comment be played during 1.5 seconds and then clixk
    //   // on the play button of the fourth comment
    //   await Future.delayed(const Duration(milliseconds: 1500));
    //   await tester.pumpAndSettle();

    //   // Tap on Close text button
    //   await tester.tap(find.byKey(const Key('closeDialogTextButton')));
    //   await tester.pumpAndSettle();

    //   // Now, re-open the playlist comment dialog
    //   playlistCommentListDialogFinder = await openPlaylistCommentDialog(
    //     tester: tester,
    //     playlistTitle: youtubePlaylistTitle,
    //   );

    //   // Verify the color of the audio titles in the playlist comment dialog

    //   await verifyAudioTitlesColorInPlaylistCommentDialog(
    //     tester: tester,
    //     playlistCommentListDialogFinder: playlistCommentListDialogFinder,
    //   );

    //   // Tap on Close text button
    //   await tester.tap(find.byKey(const Key('closeDialogTextButton')));
    //   await tester.pumpAndSettle();

    //   // Tap on the 'Toggle List' button to hide the playlist list
    //   await tester.tap(find.byKey(const Key('playlist_toggle_button')));
    //   await tester.pumpAndSettle();

    //   // When starting playing an other comment, the corresponding played
    //   // comment audio modification was undone. Verifying that for second
    //   // comment audio
    //   await verifyUndoneListenedAudioPosition(
    //     tester: tester,
    //     playlistTitle: youtubePlaylistTitle,
    //     playedCommentAudioTitle: secondPlayedCommentAudioTitle,
    //     playableAudioLstAudioIndex: 1,
    //     audioPositionStr: '1:17:54',
    //     audioPositionSeconds: 4674,
    //     audioRemainingDurationStr: '0:00',
    //     isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
    //     audioPausedDateTime: DateTime(2024, 9, 8, 14, 38, 43),
    //   );

    //   // When starting playing an other comment, the corresponding played
    //   // comment audio modification was undone. Verifying that for third
    //   // comment audio
    //   await verifyUndoneListenedAudioPosition(
    //     tester: tester,
    //     playlistTitle: youtubePlaylistTitle,
    //     playedCommentAudioTitle: thirdPlayedCommentAudioTitle,
    //     playableAudioLstAudioIndex: 3,
    //     audioPositionStr: '5:11',
    //     audioPositionSeconds: 311,
    //     audioRemainingDurationStr: '1:18',
    //     isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: true,
    //     audioPausedDateTime: DateTime(2024, 9, 9, 19, 47, 23),
    //   );

    //   // When starting playing an other comment, the corresponding played
    //   // comment audio modification was undone. Verifying that for fourth
    //   // comment audio
    //   await verifyUndoneListenedAudioPosition(
    //     tester: tester,
    //     playlistTitle: youtubePlaylistTitle,
    //     playedCommentAudioTitle: fourthPlayedCommentAudioTitle,
    //     playableAudioLstAudioIndex: 2,
    //     audioPositionStr: '0:00',
    //     audioPositionSeconds: 0,
    //     audioRemainingDurationStr: '7:38',
    //     isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
    //     audioPausedDateTime: null,
    //   );

    //   // Purge the test playlist directory so that the created test
    //   // files are not uploaded to GitHub
    //   DirUtil.deleteFilesInDirAndSubDirs(
    //     rootPath: kPlaylistDownloadRootPathWindowsTest,
    //   );
    // });
    // });
  });
}

Playlist loadPlaylist(String playListOneName) {
  return JsonDataService.loadFromFile(
      jsonPathFileName:
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$playListOneName${path.separator}$playListOneName.json",
      type: Playlist);
}

/// This code is used in integation tests for two purposes:
///   1/ for executing the expect that the playlist checkbox is checked code,
///   2/ for tapping on  the playlist checkbox.
/// The two boolean parameters define what this method does.
Future<void> onPlaylistDownloadViewCheckOrTapOnPlaylistCheckbox({
  required WidgetTester tester,
  required String playlistToSelectTitle,
  required bool verifyIfCheckboxIsChecked,
  required bool tapOnCheckbox,
}) async {
  Finder playlistToSelectListTileTextWidgetFinder =
      find.text(playlistToSelectTitle);

  // Then obtain the Playlist ListTile widget enclosing the Text widget
  // by finding its ancestor
  Finder playlistToSelectListTileWidgetFinder = find.ancestor(
    of: playlistToSelectListTileTextWidgetFinder,
    matching: find.byType(ListTile),
  );

  // Now find the Checkbox widget located in the Playlist ListTile
  // and tap on it to select the playlist
  Finder playlistToSelectListTileCheckboxWidgetFinder = find.descendant(
    of: playlistToSelectListTileWidgetFinder,
    matching: find.byKey(const Key('playlist_checkbox_key')),
  );

  // Verify that the Playlist ListTile checkbox is checked
  if (verifyIfCheckboxIsChecked) {
    final Checkbox checkboxWidget =
        tester.widget<Checkbox>(playlistToSelectListTileCheckboxWidgetFinder);

    expect(checkboxWidget.value!, true);
  }

  // Tap the ListTile Playlist checkbox to select it: This ensure
  // another bug was solved
  if (tapOnCheckbox) {
    await tester.tap(playlistToSelectListTileCheckboxWidgetFinder);
    await tester.pumpAndSettle();
  }
}

Future<void> onAudioPlayerViewCheckOrTapOnPlaylistCheckbox({
  required WidgetTester tester,
  required String playlistDownloadViewCurrentlySelectedPlaylistTitle,
  required String playlistToSelectTitleInAudioPlayerView,
}) async {
  // Go to the audio player view
  Finder appScreenNavigationButton =
      find.byKey(const ValueKey('audioPlayerViewIconButton'));
  await tester.tap(appScreenNavigationButton);
  await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
    tester: tester,
  );

  // Verify that the playlist download view currently selected playlist is
  // also selected in the playlist download view.

  // Tap on audio player view playlist button to display the playlists
  await tester.tap(find.byKey(const Key('playlist_toggle_button')));
  await tester.pumpAndSettle();

  // Find the currently selected playlist ListTile Text widget
  Finder playlistDownloadViewCurrentlySelectedPlaylistListTileTextWidgetFinder =
      find.text(playlistDownloadViewCurrentlySelectedPlaylistTitle);

  // Then obtain the playlist ListTile widget enclosing the Text widget
  // by finding its ancestor
  Finder playlistDownloadViewCurrentlySelectedPlaylistListTileWidgetFinder =
      find.ancestor(
    of: playlistDownloadViewCurrentlySelectedPlaylistListTileTextWidgetFinder,
    matching: find.byType(ListTile),
  );

  // Now find the Checkbox widget located in the playlist ListTile
  // and verify that it is checked

  Finder
      playlistDownloadViewCurrentlySelectedPlaylistListTileCheckboxWidgetFinder =
      find.descendant(
    of: playlistDownloadViewCurrentlySelectedPlaylistListTileWidgetFinder,
    matching: find.byType(Checkbox),
  );

  final Checkbox checkboxWidget = tester.widget<Checkbox>(
      playlistDownloadViewCurrentlySelectedPlaylistListTileCheckboxWidgetFinder);

  expect(checkboxWidget.value!, true);

  // Select the passed playlistToSelectTitle playlist

  // Find the playlist to select ListTile Text widget
  Finder playlistToSelectListTileTextWidgetFinder =
      find.text(playlistToSelectTitleInAudioPlayerView);

  // Then obtain the playlist ListTile widget enclosing the Text widget
  // by finding its ancestor
  Finder playlistToSelectListTileWidgetFinder = find.ancestor(
    of: playlistToSelectListTileTextWidgetFinder,
    matching: find.byType(ListTile),
  );

  // Now find the Checkbox widget located in the playlist ListTile
  // and tap on it to select the playlist
  Finder playlistToSelectListTileCheckboxWidgetFinder = find.descendant(
    of: playlistToSelectListTileWidgetFinder,
    matching: find.byType(Checkbox),
  );

  // Tap the ListTile Playlist checkbox to select it
  await tester.tap(playlistToSelectListTileCheckboxWidgetFinder);
  await tester.pumpAndSettle();

  // Now we go back to the PlayListDownloadView in order to
  // verify the scrolled selected playlist
  appScreenNavigationButton =
      find.byKey(const ValueKey('playlistDownloadViewIconButton'));
  await tester.tap(appScreenNavigationButton);
  await tester.pumpAndSettle();
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

  // Verify that the search icon button is now enabled
  IntegrationTestUtil.verifyWidgetIsEnabled(
    tester: tester,
    widgetKeyStr: 'search_icon_button',
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
    "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
    "La résilience insulaire par Fiona Roche",
    "Les besoins artificiels par R.Keucheyan",
    "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
  ];

  IntegrationTestUtil.checkPlaylistAndAudioTitlesOrderInListTile(
    tester: tester,
    playlistTitlesOrderedLst: playlistsTitles,
    audioTitlesOrderedLst: audioTitles,
    firstPlaylistListTileIndex: 0,
    firstAudioListTileIndex: 3,
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

  // Verify that the search icon button is still enabled
  IntegrationTestUtil.verifyWidgetIsEnabled(
    tester: tester,
    widgetKeyStr: 'search_icon_button',
  );

  // Ensure that since the search icon button was not yet pressed,
  // the displayed playlist list is the same as the one before entering
  // the first letter of the search word.
  IntegrationTestUtil.checkPlaylistAndAudioTitlesOrderInListTile(
    tester: tester,
    playlistTitlesOrderedLst: playlistsTitles,
    audioTitlesOrderedLst: audioTitles,
    firstPlaylistListTileIndex: 0,
    firstAudioListTileIndex: 3,
  );

  // Now tap on the search icon button
  await tester.tap(find.byKey(const Key('search_icon_button')));
  await tester.pumpAndSettle();

  // Verify that the search icon button is still enabled
  IntegrationTestUtil.verifyWidgetIsEnabled(
    tester: tester,
    widgetKeyStr: 'search_icon_button',
  );

  // Now verify the order of the reduced playlist titles

  playlistsTitles = [
    "S8 audio",
  ];

  IntegrationTestUtil.checkPlaylistAndAudioTitlesOrderInListTile(
    tester: tester,
    playlistTitlesOrderedLst: playlistsTitles,
    audioTitlesOrderedLst: audioTitles,
    firstPlaylistListTileIndex: 0,
    firstAudioListTileIndex: 1,
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

void verifyYoutubeSelectedPlaylistButtonsAndCheckbox({
  required WidgetTester tester,
  required bool isPlaylistListDisplayed,
}) {
  IntegrationTestUtil.verifyWidgetIsDisabled(
    tester: tester,
    widgetKeyStr: 'search_icon_button', // this button is disabled if the
    //                                     'Youtube Link or Search' dosn't
    //                                     contain a search word or sentence
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

void verifyLocalSelectedPlaylistButtonsAndCheckbox({
  required WidgetTester tester,
  required bool isPlaylistListDisplayed,
}) {
  IntegrationTestUtil.verifyWidgetIsDisabled(
    tester: tester,
    widgetKeyStr: 'search_icon_button', // this button is disabled if the
    //                                     'Youtube Link or Search' dosn't
    //                                     contain a search word or sentence
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

  IntegrationTestUtil.verifyWidgetIsDisabled(
    tester: tester,
    widgetKeyStr: 'download_sel_playlists_button',
  );

  IntegrationTestUtil.verifyWidgetIsDisabled(
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

  // Now find the ok button of the audio info dialog
  // and tap on it to close the dialog
  await tester.tap(find.byKey(const Key('audio_info_ok_button_key')));
  await tester.pumpAndSettle();

  return targetAudioListTileWidgetFinder;
}

Future<void> checkWarningDialog({
  required WidgetTester tester,
  required String playlistTitle,
  required bool isMusicQuality,
  required PlaylistType playlistType,
}) async {
  // Ensure the warning dialog is shown
  expect(find.byType(WarningMessageDisplayDialog), findsOneWidget);

  // Check the value of the warning dialog title
  Text warningDialogTitle =
      tester.widget(find.byKey(const Key('warningDialogTitle')));
  expect(warningDialogTitle.data, 'WARNING');

  // Check the value of the warning dialog message
  Text warningDialogMessage =
      tester.widget(find.byKey(const Key('warningDialogMessage')));

  if (playlistType == PlaylistType.youtube) {
    expect(warningDialogMessage.data,
        'Youtube playlist "$playlistTitle" of ${isMusicQuality ? 'music' : 'audio'} quality added at end of list of playlists.');
  } else {
    expect(warningDialogMessage.data,
        'Local playlist "$playlistTitle" of ${isMusicQuality ? 'music' : 'audio'} quality added at end of list of playlists.');
  }
  // Close the warning dialog by tapping on the Ok button
  await tester.tap(find.byKey(const Key('warningDialogOkButton')));
  await tester.pumpAndSettle();
}

Future<void> checkAudioCommentInAudioPlayerView({
  required WidgetTester tester,
  required Finder audioListTileWidgetFinder,
  required String expectedCommentTitle,
}) async {
  // Tap on the ListTile to open the audio player view on the
  // passed audio finder
  await tester.tap(audioListTileWidgetFinder);
  await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
    tester: tester,
  );

  // Tap on the comment icon button to open the comment add list
  // dialog
  final Finder commentInkWellButtonFinder = find.byKey(
    const Key('commentsInkWellButton'),
  );

  await tester.tap(commentInkWellButtonFinder);
  await tester.pumpAndSettle();

  // Verify that the expectedCommentTitle is listed

  Finder commentListDialogFinder = find.byType(CommentListAddDialog);

  expect(
      find.descendant(
          of: commentListDialogFinder,
          matching: find.text(expectedCommentTitle)),
      findsOneWidget);

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
  await tester.pumpAndSettle();

  // Now find the audio comments popup menu item and tap on it
  final Finder popupCommentMenuItem =
      find.byKey(const Key("popup_menu_audio_comment"));

  await tester.tap(popupCommentMenuItem);
  await tester.pumpAndSettle();

  // Verify that the comment list is displayed
  expect(find.byType(CommentListAddDialog), findsOneWidget);

  // Verify that the expectedCommentTitle is listed

  Finder commentListDialogFinder = find.byType(CommentListAddDialog);

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

    final Finder commentAddEditDialogFinder = find.byType(CommentAddEditDialog);

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

Future<void> ensureNoButtonIsEnabledSinceNoPlaylistIsSelected(
    WidgetTester tester) async {
  IntegrationTestUtil.verifyWidgetIsDisabled(
    tester: tester,
    widgetKeyStr: 'move_up_playlist_button',
  );

  IntegrationTestUtil.verifyWidgetIsDisabled(
    tester: tester,
    widgetKeyStr: 'move_down_playlist_button',
  );

  IntegrationTestUtil.verifyWidgetIsDisabled(
    tester: tester,
    widgetKeyStr: 'download_sel_playlists_button',
  );

  IntegrationTestUtil.verifyWidgetIsDisabled(
    tester: tester,
    widgetKeyStr: 'audio_quality_checkbox',
  );

  // This menu button is always enabled since the Update playlist json file
  // menu item must be always accessible
  IntegrationTestUtil.verifyWidgetIsEnabled(
    tester: tester,
    widgetKeyStr: 'audio_popup_menu_button',
  );

  // Now open the audio popup menu
  await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
  await tester.pumpAndSettle();

  // since the selected local playlist has no audio, the
  // audio menu items are disabled
  await IntegrationTestUtil.verifyAudioMenuItemsState(
    tester: tester,
    areAudioMenuItemsDisabled: true,
    audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
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
    // so that the playlist audio are listed
    await widgetTester.tap(youtubePlaylistListTileCheckboxWidgetFinder);
    await widgetTester.pumpAndSettle();
  }
}

Future<Finder> ensurePlaylistCheckboxIsNotChecked({
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

  // Check that the checkbox is not checked
  expect((checkbox.value == null || !checkbox.value!), true);

  return youtubePlaylistListTileCheckboxWidgetFinder;
}

Future<void> _launchExpandablePlaylistListView({
  required tester,
  required AudioDownloadVM audioDownloadVM,
  required SettingsDataService settingsDataService,
  required PlaylistListVM playlistListVM,
  required WarningMessageVM warningMessageVM,
  required AudioPlayerVM audioPlayerVM,
  required DateFormatVM dateFormatVM,
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
                  settingsDataService: settingsDataService,
                )),
        ChangeNotifierProvider(create: (_) => playlistListVM),
        ChangeNotifierProvider(create: (_) => warningMessageVM),
        ChangeNotifierProvider(create: (_) => audioPlayerVM),
        ChangeNotifierProvider(create: (_) => dateFormatVM),
      ],
      child: MaterialApp(
        // forcing dark theme
        theme: ScreenMixin.themeDataDark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: PlaylistDownloadView(
            settingsDataService: settingsDataService,
            onPageChangedFunction: changePage,
            isTest: true, // true increase the test app width on Windows
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
  await tester.pumpAndSettle();

  // Now find the popup menu item and tap on it
  Finder popupDisplayAudioInfoMenuItemFinder =
      find.byKey(const Key("popup_menu_display_audio_info"));

  await tester.tap(popupDisplayAudioInfoMenuItemFinder);
  await tester.pumpAndSettle();

  // Now verifying the display audio info audio copied dialog
  // elements

  // Verify the audio channel name

  Text youtubeChannelTextWidget =
      tester.widget<Text>(find.byKey(const Key('youtubeChannelKey')));

  expect(youtubeChannelTextWidget.data, "Jean-Pierre Schnyder");

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
  await tester.tap(find.byKey(const Key('audio_info_ok_button_key')));
  await tester.pumpAndSettle();
}

Future<void> executeSearchWordScrollTest({
  required WidgetTester tester,
  required String playlistTitle,
  double scrollUpOrDownPlaylistsList = 0,
}) async {
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
    '',
  );

  await tester.pumpAndSettle(const Duration(milliseconds: 200));

  if (scrollUpOrDownPlaylistsList != 0) {
    // Scrolling up or down the playlist list
    // Find the audio list widget using its key
    final listFinder = find.byKey(const Key('expandable_playlist_list'));
    // Perform the scroll action
    await tester.drag(
      listFinder,
      Offset(0, scrollUpOrDownPlaylistsList),
    );
    await tester.pumpAndSettle();
  }

  // Select the playlist
  await onPlaylistDownloadViewCheckOrTapOnPlaylistCheckbox(
    tester: tester,
    playlistToSelectTitle: playlistTitle,
    verifyIfCheckboxIsChecked: false,
    tapOnCheckbox: true,
  );

  // Now enter the '_1' search word
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
    '_1',
  );
  await tester.pumpAndSettle(const Duration(milliseconds: 200));

  // Now tap on the search icon button
  await tester.tap(find.byKey(const Key('search_icon_button')));
  await tester.pumpAndSettle();

  // Verify that the playlist is correctly scrolled so that it is
  // visible
  await onPlaylistDownloadViewCheckOrTapOnPlaylistCheckbox(
    tester: tester,
    playlistToSelectTitle: playlistTitle,
    verifyIfCheckboxIsChecked: true,
    tapOnCheckbox: false,
  );
}

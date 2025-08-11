import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/services/json_data_service.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/views/widgets/audio_sort_filter_dialog.dart';
import 'package:audiolearn/views/widgets/playlist_comment_list_dialog.dart';
import 'package:audiolearn/views/widgets/playlist_add_remove_sort_filter_options_dialog.dart';
import 'package:audiolearn/views/widgets/warning_message_display.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:audiolearn/models/playlist.dart';
import 'package:path/path.dart' as path;
import 'package:audiolearn/constants.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:audiolearn/main.dart' as app;

import 'integration_test_util.dart';
import 'mock_file_picker.dart';

const int secondsDelay = 5; // 7 works, but 10 is safer and 15 solves
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

/// This integration test contains the integration tests groups for the
/// sort/filter parms testing. The groups are included in the plalist download
/// view or in the audio player view integration test.
///
/// So, if you excute those two integration tests, you do not need to execute
/// this integration test !
Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  await IntegrationTestUtil.setWindowsAppSizeAndPosition(isTest: true);

  playlistDownloadViewSortFilterIntegrationTest();
  audioPlayerViewSortFilterIntegrationTest();
}

void audioPlayerViewSortFilterIntegrationTest() {
  group('Sort/filter audio player view tests', () {
    testWidgets(
        '''Playing last sorted audio with filter: "Fully listened" unchecked
           and "Partially listened" checked.''', (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName:
            'audio_player_view_sort_filter_partially_played_play_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      await tester.tap(find.text(toSelectAudioTitle));
      await tester.pumpAndSettle();

      // open the popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // find the sort/filter audio menu item and tap on it
      await tester
          .tap(find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
      await tester.pumpAndSettle();

      // tap on the sort option dropdown button to display the sort
      // parameters
      await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
      await tester.pumpAndSettle();

      // select the Audio duration sort option and tap on it to add
      // it to the sort option list
      await tester.tap(find.text('Audio duration'));
      await tester.pumpAndSettle();

      // Use the custom finder to find the first clear IconButton.
      // Then tap on it in order to suppress the Audio download
      // date sort option
      await tester
          .tap(IntegrationTestUtil.findIconButtonWithIcon(Icons.clear).at(1));
      await tester.pumpAndSettle();

      // Now tap the Fully listened checkbox in order to exclude
      // those audio from the sort/filter list
      await tester.tap(find.byKey(const Key('filterFullyListenedCheckbox')));
      await tester.pumpAndSettle();

      // Now tap the Not listened checkbox in order to exclude
      // those audio from the sort/filter list
      await tester.tap(find.byKey(const Key('filterNotListenedCheckbox')));
      await tester.pumpAndSettle();

      return; // next test code no more applicable to sort/filter dialog
// TODO: complete the test
      // Now tap on the Apply button
    });

    testWidgets(
        '''Menu Clear Sort/Filter Parameters History execution verifying that
           the confirm dialog is displayed in the audio player view.''',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "Quand Aurélien Barrau va dans une école de management";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'sort_filter_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it. This switches to the
      // AudioPlayerView
      await tester.tap(find.text(toSelectAudioTitle));
      await tester.pumpAndSettle();

      // Now open the popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // find the clear sort/filter audio history menu item and tap on it
      await tester.tap(find.byKey(
          const Key('clear_sort_and_filter_audio_parms_history_menu_item')));
      await tester.pumpAndSettle();

      // Verify that the confirm action dialog is displayed
      // with the expected text
      expect(find.text('Clear Sort/Filter Parameters History'), findsOneWidget);
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
          const Key('clear_sort_and_filter_audio_parms_history_menu_item')));
      await tester.pumpAndSettle();

      // Click on the confirm button to cause deletion
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Open again the popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // Verify that the clear sort/filter audio history menu item is
      // now disabled
      IntegrationTestUtil.verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: "clear_sort_and_filter_audio_parms_history_menu_item",
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Change the SF parms in in the dropdown button list to 'Title asc'
           and then verify its application. Then go to the audio player view
           and there verify that the order of the audios displayed in the
           playable audio list dialog is not sorted according to 'Title asc'
           since this SF parms was not saved in the playlist json file.

           Then, go back to the playlist download view and save the 'Title asc'
           SF parms selecting only audio player view SF parms name of the 'S8
           audio' playlist json file. Then go to the audio player view and
           there verify that the order of the audios displayed in the
           playable audio list dialog now corresponds to 'Title asc'. Since the
           Play order icon is ascending, the list is played from down to top.

           Then, click twice on |> go to end button in order to play the next
           playable audio according to the 'Title asc' order. Then reopen the
           playable audio list dialog and click on the Play order icon to
           change it from ascending to descending. This means that the displayed
           audio list corresponding to 'Title asc' SF parms will be played from
           top to down. Verify that clicking again twice on |> go to end button
           does play the correct audio.''', (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_three_playlists_test",
        destinationRootPath: kApplicationPathWindowsTest,
      );

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

      await app.main();
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Now tap on the current dropdown button item to open the dropdown
      // button items list

      final Finder dropDownButtonFinder =
          find.byKey(const Key('sort_filter_parms_dropdown_button'));

      final Finder dropDownButtonTextFinder = find.descendant(
        of: dropDownButtonFinder,
        matching: find.byType(Text),
      );

      await tester.tap(dropDownButtonTextFinder);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // And find the 'Title asc' sort/filter item
      String titleAscendingSFparmsName = 'Title asc';
      Finder titleAscDropDownTextFinder = find.text(titleAscendingSFparmsName);
      await tester.tap(titleAscDropDownTextFinder);
      await tester.pumpAndSettle();

      // And verify the order of the playlist audio titles

      List<String> audioTitlesSortedByTitleAscending = [
        "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        "La résilience insulaire par Fiona Roche",
        "La surpopulation mondiale par Jancovici et Barrau",
        "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        "Les besoins artificiels par R.Keucheyan",
      ];

      IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
        tester: tester,
        audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
      );

      // Then go to the audio player view
      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Now we open the AudioPlayableListDialog
      // and verify the the displayed audio titles

      await tester.tap(find
          .text("Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik\n13:39"));
      await tester.pumpAndSettle();

      List<String>
          audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        "La surpopulation mondiale par Jancovici et Barrau",
        "La résilience insulaire par Fiona Roche",
        "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        "Les besoins artificiels par R.Keucheyan",
        "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
      ];

      IntegrationTestUtil.checkAudioTitlesOrderInListBody(
        tester: tester,
        audioTitlesOrderLst:
            audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
      );

      // Tap on the Close button to close the AudioPlayableListDialog
      await tester.tap(find.byKey(const Key('closeTextButton')));
      await tester.pumpAndSettle();

      // Now return to the playlist download view
      appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(
          const Key('save_sort_and_filter_audio_parms_in_playlist_item')));
      await tester.pumpAndSettle();

      // Verify that the save SF parms dialog is displayed
      expect(find.byType(PlaylistAddRemoveSortFilterOptionsDialog),
          findsOneWidget);

      // Verify the dialog title
      expect(
        find.text("Save Sort/Filter \"Title asc\""),
        findsOneWidget,
      );

      // Verify the dialog content

      expect(
        find.text("To playlist \"S8 audio\""),
        findsOneWidget,
      );

      expect(
        find.text("For \"Download Audio\" screen"),
        findsOneWidget,
      );

      expect(
        find.text("For \"Play Audio\" screen"),
        findsOneWidget,
      );

      // Select the 'For "Play Audio" screen' checkbox
      await tester.tap(find.byKey(const Key('audioPlayerViewCheckbox')));
      await tester.pumpAndSettle();

      // Finally, click on save button
      await tester.tap(
          find.byKey(const Key('saveSortFilterOptionsToPlaylistSaveButton')));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "Sort/filter parameters \"Title asc\" were saved to playlist \"S8 audio\" for screen(s) \"Play Audio\".",
        isWarningConfirming: true,
      );

      // Verify that "Title asc" was correctly saved in the playlist
      // json file for the audio player view only.
      _verifyAudioSortFilterParmsNameStoredInPlaylistJsonFile(
        selectedPlaylistTitle: 'S8 audio',
        expectedAudioSortFilterParmsName: 'Title asc',
        audioLearnAppViewTypeLst: [AudioLearnAppViewType.audioPlayerView],
        audioPlayingOrder: AudioPlayingOrder.descending,
      );

      // Then go to the audio player view to verify that now the
      // ¨Title asc' sort/filter parms is applyed
      appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Now we open the AudioPlayableListDialog
      // and verify the the displayed audio titles

      await tester.tap(find
          .text("Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik\n13:39"));
      await tester.pumpAndSettle();

      IntegrationTestUtil.checkAudioTitlesOrderInListBody(
        tester: tester,
        audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
      );

      // Tap on the Close button to close the AudioPlayableListDialog
      await tester.tap(find.byKey(const Key('closeTextButton')));
      await tester.pumpAndSettle();

      // Now we tap twice on the >| button in order to start playing
      // the next audio according to the 'Title app' sort/filter parms

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      // Waiting one second so that the next audio starts playing
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Tap on pause button to pause the audio
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // Verify the next audio title
      Finder nextAudioTextFinder =
          find.text("Les besoins artificiels par R.Keucheyan\n19:05");

      expect(
        nextAudioTextFinder,
        findsOneWidget,
      );

      // Re-opening again the AudioPlayableListDialog in order to
      // change the audio playing order

      await tester.tap(nextAudioTextFinder);
      await tester.pumpAndSettle();

      // And tap on the play descending order icon button in order to change
      // it to play ascending order
      await tester.tap(
          find.byKey(const Key('play_order_ascending_or_descending_button')));
      await tester.pumpAndSettle();

      // Tap on the Close button to close the AudioPlayableListDialog
      await tester.tap(find.byKey(const Key('closeTextButton')));
      await tester.pumpAndSettle();

      // Verify that the audioPlayingOrder was modified and saved in the
      // playlist
      _verifyAudioSortFilterParmsNameStoredInPlaylistJsonFile(
        selectedPlaylistTitle: 'S8 audio',
        expectedAudioSortFilterParmsName: 'Title asc',
        audioLearnAppViewTypeLst: [AudioLearnAppViewType.audioPlayerView],
        audioPlayingOrder: AudioPlayingOrder.ascending,
      );

      // Now we tap twice on the >| button in order to start playing
      // the next audio according to the 'Title app' sort/filter parms
      // now applied descendingly

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      // Waiting one second so that the next audio starts playing
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Tap on pause button to pause the audio
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // Since the audio playing order was changed to 'ascending', clicking
      // twice on the >| button in order to start playing the next audio
      // selects the next playable audio which is before the now fully played
      // 'Les besoins artificiels par R.Keucheyan'
      nextAudioTextFinder =
          find.text("La surpopulation mondiale par Jancovici et Barrau\n7:38");

      expect(
        nextAudioTextFinder,
        findsOneWidget,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Click twice on the <| go to start button in order to select the previous
           playable audio. First, save the 'Title asc' SF parms selecting only
           audio player view SF parms name of the 'S8 audio' playlist json file.
        
           Then go to the audio player view and click twice on the <| go to start
           button in order to select the previous playable audio according to the
           'Title asc' order. Then reopen the playable audio list dialog and
           click on the Play order icon to change it from ascending to descending.
           This means that the displayed audio list corresponding to 'Title asc'
           SF parms will be played from top to down. Verify that clicking once
           on <| go to start button does select the correct audio.''',
        (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_three_playlists_test",
        destinationRootPath: kApplicationPathWindowsTest,
      );

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

      await app.main();
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Now tap on the current dropdown button item to open the dropdown
      // button items list

      final Finder dropDownButtonFinder =
          find.byKey(const Key('sort_filter_parms_dropdown_button'));

      final Finder dropDownButtonTextFinder = find.descendant(
        of: dropDownButtonFinder,
        matching: find.byType(Text),
      );

      await tester.tap(dropDownButtonTextFinder);
      await tester.pumpAndSettle();

      // And find the 'Title asc' sort/filter item
      String titleAscendingSFparmsName = 'Title asc';
      Finder titleAscDropDownTextFinder = find.text(titleAscendingSFparmsName);
      await tester.tap(titleAscDropDownTextFinder);
      await tester.pumpAndSettle();

      // Now open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(
          const Key('save_sort_and_filter_audio_parms_in_playlist_item')));
      await tester.pumpAndSettle();

      // Select the 'For "Play Audio" screen' checkbox
      await tester.tap(find.byKey(const Key('audioPlayerViewCheckbox')));
      await tester.pumpAndSettle();

      // Finally, click on save button
      await tester.tap(
          find.byKey(const Key('saveSortFilterOptionsToPlaylistSaveButton')));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "Sort/filter parameters \"Title asc\" were saved to playlist \"S8 audio\" for screen(s) \"Play Audio\".",
        isWarningConfirming: true,
      );

      // Then go to the audio player view
      final Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Now we tap twice on the |< button in order select the previous
      // audio according to the 'Title app' with descending audio playing order

      await tester
          .tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      await tester
          .tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      // Verify the next audio title
      Finder nextAudioTextFinder =
          find.text("La surpopulation mondiale par Jancovici et Barrau\n7:38");

      expect(
        nextAudioTextFinder,
        findsOneWidget,
      );

      // Opening the AudioPlayableListDialog in order to change
      // the descending audio playing order to ascending

      await tester.tap(nextAudioTextFinder);
      await tester.pumpAndSettle();

      // And tap on the play descending order icon button in order to change
      // it to play ascending order
      await tester.tap(
          find.byKey(const Key('play_order_ascending_or_descending_button')));
      await tester.pumpAndSettle();

      // Tap on the Close button to close the AudioPlayableListDialog
      await tester.tap(find.byKey(const Key('closeTextButton')));
      await tester.pumpAndSettle();

      // Verify that the audioPlayingOrder was modified and saved in the
      // playlist
      _verifyAudioSortFilterParmsNameStoredInPlaylistJsonFile(
        selectedPlaylistTitle: 'S8 audio',
        expectedAudioSortFilterParmsName: 'Title asc',
        audioLearnAppViewTypeLst: [AudioLearnAppViewType.audioPlayerView],
        audioPlayingOrder: AudioPlayingOrder.ascending,
      );

      // Now we tap once on the |< button in order select the previous
      // audio according to the 'Title app' with audio play ascending order

      await tester
          .tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      // Since the audio playing order was changed to 'ascending', clicking
      // once on the |< button in order to select the previous audio
      // selects the previous playable audio which is before the current
      // audio 'La surpopulation mondiale par Jancovici et Barrau'
      nextAudioTextFinder = find
          .text("Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik\n13:39");

      expect(
        nextAudioTextFinder,
        findsOneWidget,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
}

void playlistDownloadViewSortFilterIntegrationTest() {
  group('Sort/filter playlist download view tests', () {
    group('Audio sort filter dialog tests ', () {
      group('Clear tests ', () {
        testWidgets(
            '''Menu Clear SF Parameters History execution verifying that the confirm
             dialog is displayed in the playlist download view.''',
            (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_filter_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio titles
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now open the popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // find the clear sort/filter audio history menu item and tap on it
          await tester.tap(find.byKey(const Key(
              'clear_sort_and_filter_audio_parms_history_menu_item')));
          await tester.pumpAndSettle();

          // Verify that the confirm action dialog is displayed
          // with the expected text
          expect(find.text('Clear Sort/Filter Parameters History'),
              findsOneWidget);
          expect(find.text('Deleting all historical sort/filter parameters.'),
              findsOneWidget);

          // Click on the cancel button to cancel deletion
          await tester.tap(find.byKey(const Key('cancelButtonKey')));
          await tester.pumpAndSettle();

          // Open again the popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // find the clear sort/filter audio history menu item and tap on it
          await tester.tap(find.byKey(const Key(
              'clear_sort_and_filter_audio_parms_history_menu_item')));
          await tester.pumpAndSettle();

          // Click on the confirm button to apply deletion
          await tester.tap(find.byKey(const Key('confirmButton')));
          await tester.pumpAndSettle();

          // Open again the popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Verify that the clear sort/filter audio history menu item is
          // now disabled
          IntegrationTestUtil.verifyWidgetIsDisabled(
            tester: tester,
            widgetKeyStr: "clear_sort_and_filter_audio_parms_history_menu_item",
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Tapping on clear sort/filter parameters history icon button and verifying
             that the confirm warning is displayed in the audio player view.''',
            (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio titles
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now open the popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // find the sort/filter audio menu item and tap on it
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Verify that the left sort history icon button is disabled
          IntegrationTestUtil.verifyWidgetIsDisabled(
            tester: tester,
            widgetKeyStr: "search_history_arrow_left_button",
          );

          // Verify that the right sort history icon button is disabled
          IntegrationTestUtil.verifyWidgetIsDisabled(
            tester: tester,
            widgetKeyStr: "search_history_arrow_right_button",
          );

          // Verify that the clear sort history icon button is disabled
          IntegrationTestUtil.verifyWidgetIsDisabled(
            tester: tester,
            widgetKeyStr: "search_history_delete_all_button",
          );

          // Type "janco" in the audio title search sentence TextField
          await tester.enterText(
              find.byKey(const Key('audioTitleSearchSentenceTextField')),
              'janco');
          await tester.pumpAndSettle();

          // Click on the "+" icon button
          await tester.tap(find.byKey(const Key('addSentenceIconButton')));
          await tester.pumpAndSettle();

          // Verify that the left sort history icon button is still disabled
          IntegrationTestUtil.verifyWidgetIsDisabled(
            tester: tester,
            widgetKeyStr: "search_history_arrow_left_button",
          );

          // Verify that the right sort history icon button is still disabled
          IntegrationTestUtil.verifyWidgetIsDisabled(
            tester: tester,
            widgetKeyStr: "search_history_arrow_right_button",
          );

          // Verify that the clear sort history icon button is still disabled
          IntegrationTestUtil.verifyWidgetIsDisabled(
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

          // find the sort/filter audio menu item and tap on it
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Verify that the left sort history icon button is now enabled
          IntegrationTestUtil.verifyWidgetIsEnabled(
            tester: tester,
            widgetKeyStr: "search_history_arrow_left_button",
          );

          // Verify that the right sort history icon button is still disabled
          IntegrationTestUtil.verifyWidgetIsDisabled(
            tester: tester,
            widgetKeyStr: "search_history_arrow_right_button",
          );

          // Verify that the clear sort history icon button is now enabled
          IntegrationTestUtil.verifyWidgetIsEnabled(
            tester: tester,
            widgetKeyStr: "search_history_delete_all_button",
          );

          // Now click on the clear sort history icon button
          await tester
              .tap(find.byKey(const Key('search_history_delete_all_button')));
          await tester.pumpAndSettle();

          // Verify that the confirm action dialog is displayed
          // with the expected text
          expect(find.text('Clear Sort/Filter Parameters History'),
              findsOneWidget);
          expect(find.text('Deleting all historical sort/filter parameters.'),
              findsOneWidget);

          // Click on the cancel button to cancel deletion
          await tester.tap(find.byKey(const Key('cancelButtonKey')));
          await tester.pumpAndSettle();

          // Verify that the left sort history icon button is still enabled
          IntegrationTestUtil.verifyWidgetIsEnabled(
            tester: tester,
            widgetKeyStr: "search_history_arrow_left_button",
          );

          // Verify that the right sort history icon button is still disabled
          IntegrationTestUtil.verifyWidgetIsDisabled(
            tester: tester,
            widgetKeyStr: "search_history_arrow_right_button",
          );

          // Verify that the clear sort history icon button is still enabled
          IntegrationTestUtil.verifyWidgetIsEnabled(
            tester: tester,
            widgetKeyStr: "search_history_delete_all_button",
          );

          // Click again on the clear sort history icon button
          await tester
              .tap(find.byKey(const Key('search_history_delete_all_button')));
          await tester.pumpAndSettle();

          // Verify that the confirm action dialog is displayed
          // with the expected text
          expect(find.text('Clear Sort/Filter Parameters History'),
              findsOneWidget);
          expect(find.text('Deleting all historical sort/filter parameters.'),
              findsOneWidget);

          // Click on the confirm button to execute deletion
          await tester.tap(find.byKey(const Key('confirmButton')));
          await tester.pumpAndSettle();

          // Verify that the left sort history icon button is now disabled
          IntegrationTestUtil.verifyWidgetIsDisabled(
            tester: tester,
            widgetKeyStr: "search_history_arrow_left_button",
          );

          // Verify that the right sort history icon button is still disabled
          IntegrationTestUtil.verifyWidgetIsDisabled(
            tester: tester,
            widgetKeyStr: "search_history_arrow_right_button",
          );

          // Verify that the clear sort history icon button is now disabled
          IntegrationTestUtil.verifyWidgetIsDisabled(
            tester: tester,
            widgetKeyStr: "search_history_delete_all_button",
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Tapping on clear sort/filter parameters icon button and verifying the
             state of SF name as well as the Apply button.''',
            (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'janco' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text('janco').last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to modify the 'janco'
          // sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Now type on the clear sort/filter button in order to
          // reinitialize all the 'janco' sort/filter parms
          final Finder clearSFparmsIconButtonFinder =
              find.byKey(const Key('resetSortFilterOptionsIconButton'));
          await tester.tap(clearSFparmsIconButtonFinder);
          await tester.pumpAndSettle();

          // Verify that the sort/filter name is empty
          TextField sortFilterSaveAsNameTextField = tester.widget(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')));
          expect(
            sortFilterSaveAsNameTextField.controller!.text,
            '',
          );

          // Verify that the delete 'Save as' name icon button is disabled
          IntegrationTestUtil.verifyIconButtonColor(
            tester: tester,
            widgetKeyStr: 'deleteSaveAsNameIconButton',
            isIconButtonEnabled: false,
          );

          // Verify that the 'Apply' button has replaced the 'Save' button
          Finder applyButtonFinder =
              find.byKey(const Key('applySortFilterOptionsTextButton'));

          expect(
            applyButtonFinder,
            findsOneWidget,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Tapping on clear sort/filter name icon button and verifying the state
             of SF name as well as the Apply button.''',
            (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'janco' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text('janco').last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to modify the 'janco'
          // sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Now type on the clear sort/filter 'Save as' button in order
          // to clear the 'janco' sort/filter name
          final Finder clearSFparmsIconButtonFinder =
              find.byKey(const Key('deleteSaveAsNameIconButton'));
          await tester.tap(clearSFparmsIconButtonFinder);
          await tester.pumpAndSettle();

          // Verify that the sort/filter name is empty
          TextField sortFilterSaveAsNameTextField = tester.widget(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')));
          expect(
            sortFilterSaveAsNameTextField.controller!.text,
            '',
          );

          // Verify that the delete 'Save as' name icon button is disabled
          IntegrationTestUtil.verifyIconButtonColor(
            tester: tester,
            widgetKeyStr: 'deleteSaveAsNameIconButton',
            isIconButtonEnabled: false,
          );

          // Verify that the 'Apply' button has replaced the 'Save' button
          Finder applyButtonFinder =
              find.byKey(const Key('applySortFilterOptionsTextButton'));

          expect(
            applyButtonFinder,
            findsOneWidget,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
      });
      group(
          '''Audio download, video upload, audio file size, duration based sort/filter
           parameters creation and application''', () {
        testWidgets('''Audio download start/end date sort/filter.''',
            (WidgetTester tester) async {
          //    Click on 'Sort/filter audio' menu item of Audio popup menu to
          //    open sort filter audio dialog. Then creating a named audio download
          //    start/end date sort/filter parms and saving it. Then verifying that
          //    a Sort/filter dropdown button item has been created and is applied
          //    to the playlist download view list of audio.

          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type "Drop2023Title asc" in the 'Save as' TextField

          String saveAsTitle = 'Drop2023Title asc';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle();

          // Now select the 'Audio title' item in the 'Sort by' dropdown button

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

          // Now enter the start and end dates for the audio download date
          // sort/filter parms, but first scroll down the dialog so that
          // the date text fields are visible.

          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          await tester.enterText(
              find.byKey(const Key('startDownloadDateTextField')),
              '26/12/2023');
          await tester.pumpAndSettle(Duration(milliseconds: 200));

          await tester.enterText(
              find.byKey(const Key('endDownloadDateTextField')), '26/12/2023');
          await tester.pumpAndSettle(Duration(milliseconds: 200));

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the
          // 'Drop2023Title asc' sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Drop2023Title asc' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesSortedByTitleAscending = [
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Video upload start/end date sort/filter. Audio list item subtitle
             specific to video upload date sort/filter parms is verified.''',
            (WidgetTester tester) async {
          //    Click on 'Sort/filter audio' menu item of Audio popup menu to
          //    open sort filter audio dialog. Then creating a named video upload
          //    start/end date sort/filter parms and saving it. Then verifying that
          //    a Sort/filter dropdown button item has been created and is applied
          //    to the playlist download view list of audio. Then, edit the created
          //    video upload start/end date sort/filter parms in order to add to it
          //    sorting the filtered audios by descending video upload date. Finally,
          //    the modified sorted audio list.

          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type "UploadVideo" in the 'Save as' TextField

          String saveAsTitle = 'UploadVideo';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle();

          // Enter the start and end dates for the video upload date
          // sort/filter parms, but first scroll down the dialog so that
          // the date text fields are visible.

          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          await tester.enterText(
              find.byKey(const Key('startUploadDateTextField')), '12/06/2022');
          await tester.pumpAndSettle(Duration(milliseconds: 200));

          await tester.enterText(
              find.byKey(const Key('endUploadDateTextField')), '19/09/2023');
          await tester.pumpAndSettle(Duration(milliseconds: 200));

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'UploadVideo'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'UploadVideo' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesSortedByTitleAscending = [
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // And verify the order of the playlist audio subtitles

          List<String> audioSubTitlesSortedByTitleAscending = [
            "0:06:29.0. Video upload date: 12/06/2022.",
            "0:13:39.0. Video upload date: 10/09/2023.",
          ];

          IntegrationTestUtil.checkAudioSubTitlesOrderInListTile(
            tester: tester,
            audioSubTitlesOrderLst: audioSubTitlesSortedByTitleAscending,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'UploadVideo' sort/filter item
          final Finder uploadVideoDropDownTextFinder =
              find.text(saveAsTitle).last;
          await tester.tap(uploadVideoDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to modify the 'UploadVideo'
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Now select the 'Video upload date' item in the 'Sort by' dropdown button

          await tester
              .tap(find.byKey(const Key('sortingOptionDropdownButton')));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Video upload date'));
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

          await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
            tester: tester,
            confirmDialogTitleOne:
                'WARNING: the sort/filter parameters "$saveAsTitle" were modified. Do you want to update the existing sort/filter parms by clicking on "Confirm", or to save it with a different name or cancel the Save operation, this by clicking on "Cancel" ?',
            confirmDialogMessage:
                'Sort by:\n Present only in initial version:\n   Audio downl date desc\n Present only in modified version:\n   Video upload date desc',
            confirmOrCancelAction: true, // Confirm button is tapped
          );

          // Now verify the playlist download view state with the 'UploadVideo'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'UploadVideo' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          audioTitlesSortedByTitleAscending = [
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets('''Audio file size sort/filter.''',
            (WidgetTester tester) async {
          //    Click on 'Sort/filter audio' menu item of Audio popup menu to
          //    open sort filter audio dialog. Then creating a named audio file size
          //    sort/filter parms and saving it. Then verifying that
          //    a Sort/filter dropdown button item has been created and is applied
          //    to the playlist download view list of audio.

          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type "audioFileSize" in the 'Save as' TextField

          String saveAsTitle = 'audioFileSize';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle();

          // Enter the start and end file size MB range in the corresponding fields,
          // but first scroll down the dialog so that the date file size fields are
          // visible.

          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -350), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          await tester.enterText(
              find.byKey(const Key('startFileSizeTextField')), '2.37');
          await tester.pumpAndSettle(Duration(milliseconds: 200));

          await tester.enterText(
              find.byKey(const Key('endFileSizeTextField')), '2.8');
          await tester.pumpAndSettle(Duration(milliseconds: 200));

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'UploadVideo'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'UploadVideo' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesSortedByTitleAscending = [
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La surpopulation mondiale par Jancovici et Barrau",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets('''Audio duration sort/filter.''',
            (WidgetTester tester) async {
          //    Click on 'Sort/filter audio' menu item of Audio popup menu to
          //    open sort filter audio dialog. Then creating a named audio duration
          //    sort/filter parms and saving it. Then verifying that
          //    a Sort/filter dropdown button item has been created and is applied
          //    to the playlist download view list of audio.

          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type "audioFileSize" in the 'Save as' TextField

          String saveAsTitle = 'audioFileSize';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle();

          // Enter the start and end audio duration hh:mm range in the
          // corresponding fields, but first scroll down the dialog so
          // that the fields are visible.

          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -350), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          await tester.enterText(
              find.byKey(const Key('startAudioDurationTextField')), '0:06');
          await tester.pumpAndSettle(Duration(milliseconds: 200));

          await tester.enterText(
              find.byKey(const Key('endAudioDurationTextField')), '0:08');
          await tester.pumpAndSettle(Duration(milliseconds: 200));

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'UploadVideo'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'UploadVideo' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesSortedByTitleAscending = [
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La surpopulation mondiale par Jancovici et Barrau",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
      });
      group(
          '''Testing ConfirmActionDialog warning displayed when clicking on the
          save button of the audio sort filter dialog after creating new Sort/Filter
          parms with same name as existing Sort/Filter parms or after modifying
          an existing Sort/Filter parms...''', () {
        group(
            '''Testing in english. Necessary to test in different languages since
             handling the translation happens in the widget code and not only in
             the arb translation files.''', () {
          testWidgets(
              '''Modify all parms in 'Title asc' existing named and saved SF parms.
                 Then save it and verify ConfirmActionDialog content. Then reedit
                 and modify all sort/filter parms and save it with the same name
                 to verify that the ConfirmActionDialog content contains every
                 sort/filter parm.''', (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_filtered_parms_name_deletion_no_mp3_test",
              destinationRootPath: kApplicationPathWindowsTest,
            );

            final SettingsDataService settingsDataService = SettingsDataService(
              sharedPreferences: await SharedPreferences.getInstance(),
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            const String saveAsTitle = 'Title asc';

            // Edit the 'Title asc' sort/filter parms
            Finder dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Convert ascending to descending sort order of 'Audio title'.
            // So, the 'Title asc? sort/filter parms will in fact be descending !!
            await IntegrationTestUtil.invertSortingItemOrder(
              tester: tester,
              sortingItemName: 'Audio title',
            );

            // Now define an audio/video title or description filter word
            await _addAudioFilterStrAndClickOnPlusIconButton(
              tester: tester,
              audioFilterString: 'Jancovici',
            );

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'WARNING: the sort/filter parameters "$saveAsTitle" were modified. Do you want to update the existing sort/filter parms by clicking on "Confirm", or to save it with a different name or cancel the Save operation, this by clicking on "Cancel" ?',
              confirmDialogMessage:
                  "Sort by:\n Present only in initial version:\n   Audio title asc\n Present only in modified version:\n   Audio title desc\nFilter words:\n Present only in modified version:\n   'Jancovici'",
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Now reedit the 'Title asc' sort/filter parms and modify
            // every sort/filter parm

            dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the checkboxes
            // are visible and so accessible by the integration test.
            // WARNING: Scrolling down must be done before setting sort
            // options, otherwise, it does not work.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Tap on the Music qual. checkbox to unselect it
            await tester
                .tap(find.byKey(const Key('filterMusicQualityCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Spoken qual. checkbox to unselect it. This deselect
            // Spoken qual. and reselcet Music qual.
            await tester
                .tap(find.byKey(const Key('filterSpokenQualityCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Commented checkbox to unselect it
            await tester.tap(find.byKey(const Key('filterCommentedCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Uncom. checkbox to unselect it. This deselect
            // Uncom. and reselect Commented.
            await tester
                .tap(find.byKey(const Key('filterNotCommentedCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Pictured checkbox to unselect it
            await tester.tap(find.byKey(const Key('filterPicturedCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Unpictured checkbox to unselect it. This deselect
            // Unpictured and reselect Pictured.
            await tester
                .tap(find.byKey(const Key('filterNotPicturedCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Playable checkbox to unselect it
            await tester.tap(find.byKey(const Key('filterPlayableCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Not playable checkbox to unselect it. This deselect
            // Not playable and reselect Playable.
            await tester
                .tap(find.byKey(const Key('filterNotPlayableCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Downloaded checkbox to unselect it
            await tester.tap(find.byKey(const Key('filterDownloadedCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Imported checkbox to unselect it. This deselect
            // Imported and reselect Downloaded.
            await tester.tap(find.byKey(const Key('filterImportedCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Exclude ignore case checkbox to unselect it
            await tester.tap(find.byKey(const Key('ignoreCaseCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Search in video compact description checkbox to unselect it
            await tester
                .tap(find.byKey(const Key('searchInVideoCompactDescription')));
            await tester.pumpAndSettle();

            // Tap on the Search in Youtube compact description checkbox to unselect it
            await tester
                .tap(find.byKey(const Key('searchInYoutubeChannelName')));
            await tester.pumpAndSettle();

            // Set start and end audio download dates

            await tester.enterText(
                find.byKey(const Key('startDownloadDateTextField')),
                '26/12/2023');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endDownloadDateTextField')), '6/1/2024');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Set start and end dates for the video upload date

            await tester.enterText(
                find.byKey(const Key('startUploadDateTextField')),
                '12/06/2022');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endUploadDateTextField')), '19/09/2023');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Set start and end audio file size MB range

            await tester.enterText(
                find.byKey(const Key('startFileSizeTextField')), '2.37');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endFileSizeTextField')), '2.8');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Set start and end audio duration hh:mm range

            await tester.enterText(
                find.byKey(const Key('startAudioDurationTextField')), '0:06');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endAudioDurationTextField')), '0:08');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Scrolling up the sort filter dialog to access to sort options
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, 600), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Convert descending to ascending sort order of 'Audio title'.
            // So, the 'Title asc? sort/filter parms will in fact be ascending !!
            await IntegrationTestUtil.invertSortingItemOrder(
              tester: tester,
              sortingItemName: 'Audio title',
            );

            // Select the 'Audio chapter' item in the 'Sort by'
            // dropdown button
            await _selectSortByOption(
              tester: tester,
              audioSortOption: 'Audio chapter',
            );

            // Select the 'Video upload date' item in the 'Sort by'
            // dropdown button
            await _selectSortByOption(
              tester: tester,
              audioSortOption: 'Video upload date',
            );

            // Select the 'Audio duration' item in the 'Sort by'
            // dropdown button
            await _selectSortByOption(
              tester: tester,
              audioSortOption: 'Audio duration',
            );

            // Select the 'Audio listenable remaining duration' item in the 'Sort by'
            // dropdown button
            await _selectSortByOption(
              tester: tester,
              audioSortOption: 'Audio listenable remaining duration',
            );

            // Select the 'Audio downl speed' item in the 'Sort by'
            // dropdown button
            await _selectSortByOption(
              tester: tester,
              audioSortOption: 'Audio downl speed',
            );

            // Select the 'Audio downl duration' item in the 'Sort by'
            // dropdown button
            await _selectSortByOption(
              tester: tester,
              audioSortOption: 'Audio downl duration',
            );

            // Type "Jancovici" in the audio title search sentence TextField
            await _addAudioFilterStrAndClickOnPlusIconButton(
              tester: tester,
              audioFilterString: 'Jancovici',
            );

            // Type "Marine Le Pen" in the audio title search sentence TextField
            await _addAudioFilterStrAndClickOnPlusIconButton(
              tester: tester,
              audioFilterString: 'Marine Le Pen',
            );

            // Type "Emmanuel Macron" in the audio title search sentence TextField
            await _addAudioFilterStrAndClickOnPlusIconButton(
              tester: tester,
              audioFilterString: 'Emmanuel Macron',
            );

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'WARNING: the sort/filter parameters "$saveAsTitle" were modified. Do you want to update the existing sort/filter parms by clicking on "Confirm", or to save it with a different name or cancel the Save operation, this by clicking on "Cancel" ?',
              confirmDialogMessage:
                  "Sort by:\n Present only in initial version:\n   Audio title desc\n Present only in modified version:\n   Audio title asc,\n   Audio chapter asc,\n   Video upload date desc,\n   Audio duration asc,\n   Audio listenable remaining\n   duration asc,\n   Audio downl speed desc,\n   Audio downl duration desc\nFilter words:\n Present only in modified version:\n   'Marine Le Pen',\n   'Emmanuel Macron'\nFilter options:\n In initial version:\n   Ignore case: checked\n In modified version:\n   Ignore case: unchecked\n In initial version:\n   Include Youtube channel: checked\n In modified version:\n   Include Youtube\n   channel: unchecked\n In initial version:\n   Spoken q.: checked\n In modified version:\n   Spoken q.: unchecked\n In initial version:\n   Uncom.: checked\n In modified version:\n   Uncom.: unchecked\n In initial version:\n   Unpictured: checked\n In modified version:\n   Unpictured: unchecked\n In initial version:\n   Not playable: checked\n In modified version:\n   Not playable: unchecked\n In initial version:\n   Imported: checked\n In modified version:\n   Imported: unchecked\n In modified version:\n   Start downl date: 26/12/2023\n In modified version:\n   End downl date: 06/01/2024\n In modified version:\n   Start upl date: 12/06/2022\n In modified version:\n   End upl date: 19/09/2023\n In modified version:\n   File size range (MB) Start: 2.37\n In modified version:\n   File size range (MB) End: 2.8\n In modified version:\n   Audio duration range (hh:mm)\n   Start: 00:06\n In modified version:\n   Audio duration range (hh:mm)\n   End: 00:08",
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
          testWidgets(
              '''In 'Title asc' two filter words only, modified in the existing
               named and saved sort/filter parms. Then save it and verify
               ConfirmActionDialog content.''', (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_filtered_parms_name_deletion_no_mp3_test",
              destinationRootPath: kApplicationPathWindowsTest,
            );

            final SettingsDataService settingsDataService = SettingsDataService(
              sharedPreferences: await SharedPreferences.getInstance(),
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            const String saveAsTitle = 'Title asc';

            // Edit the 'Title asc' sort/filter parms
            Finder dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the checkboxes
            // are visible and so accessible by the integration test.
            // WARNING: Scrolling down must be done before setting sort
            // options, otherwise, it does not work.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Type "Jancovici" in the audio title search sentence TextField
            await _addAudioFilterStrAndClickOnPlusIconButton(
              tester: tester,
              audioFilterString: 'Jancovici',
            );

            // Type "Marine Le Pen" in the audio title search sentence TextField
            await _addAudioFilterStrAndClickOnPlusIconButton(
              tester: tester,
              audioFilterString: 'Marine Le Pen',
            );

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'WARNING: the sort/filter parameters "$saveAsTitle" were modified. Do you want to update the existing sort/filter parms by clicking on "Confirm", or to save it with a different name or cancel the Save operation, this by clicking on "Cancel" ?',
              confirmDialogMessage:
                  "Filter words:\n Present only in modified version:\n   'Jancovici',\n   'Marine Le Pen'",
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
          testWidgets(
              '''In 'Title asc' click on 'or' only after adding two filter
               words, modified in the existing named and saved sort/filter parms.
               Then save it and verify ConfirmActionDialog content.''',
              (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_filtered_parms_name_deletion_no_mp3_test",
              destinationRootPath: kApplicationPathWindowsTest,
            );

            final SettingsDataService settingsDataService = SettingsDataService(
              sharedPreferences: await SharedPreferences.getInstance(),
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            const String saveAsTitle = 'Title asc';

            // Edit the 'Title asc' sort/filter parms
            Finder dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the checkboxes
            // are visible and so accessible by the integration test.
            // WARNING: Scrolling down must be done before setting sort
            // options, otherwise, it does not work.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Type "Jancovici" in the audio title search sentence TextField
            await _addAudioFilterStrAndClickOnPlusIconButton(
              tester: tester,
              audioFilterString: 'Jancovici ',
            );

            // Type "Marine Le Pen" in the audio title search sentence TextField
            await _addAudioFilterStrAndClickOnPlusIconButton(
              tester: tester,
              audioFilterString: 'Marine Le Pen ',
            );

            // Tap on the 'or' checkbox set sentence combination
            await tester.tap(find.byKey(const Key('orCheckbox')));
            await tester.pumpAndSettle();

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'WARNING: the sort/filter parameters "$saveAsTitle" were modified. Do you want to update the existing sort/filter parms by clicking on "Confirm", or to save it with a different name or cancel the Save operation, this by clicking on "Cancel" ?',
              confirmDialogMessage:
                  "Filter words:\n Present only in modified version:\n   'Jancovici ',\n   'Marine Le Pen '\nFilter options:\n In initial version:\n   and / or: and\n In modified version:\n   and / or: or",
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
          testWidgets(
              '''In 'Title asc' click on 'and' only after adding two filter
               words. Clicking on 'and' which is initially checked does uncheck it
               and checks the 'or' checkbox. This modifies the existing named and
               saved sort/filter parms. Then save it and verify ConfirmActionDialog
               content.''', (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_filtered_parms_name_deletion_no_mp3_test",
              destinationRootPath: kApplicationPathWindowsTest,
            );

            final SettingsDataService settingsDataService = SettingsDataService(
              sharedPreferences: await SharedPreferences.getInstance(),
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            const String saveAsTitle = 'Title asc';

            // Edit the 'Title asc' sort/filter parms
            Finder dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the checkboxes
            // are visible and so accessible by the integration test.
            // WARNING: Scrolling down must be done before setting sort
            // options, otherwise, it does not work.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Type "Jancovici" in the audio title search sentence TextField
            await _addAudioFilterStrAndClickOnPlusIconButton(
              tester: tester,
              audioFilterString: 'Jancovici',
            );

            // Type "Marine Le Pen" in the audio title search sentence TextField
            await _addAudioFilterStrAndClickOnPlusIconButton(
              tester: tester,
              audioFilterString: 'Marine Le Pen',
            );

            // Tap on the 'and / or' checkbox set sentence combination
            // to 'or' instead of 'and'
            await tester.tap(find.byKey(const Key('andCheckbox')));
            await tester.pumpAndSettle();

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'WARNING: the sort/filter parameters "$saveAsTitle" were modified. Do you want to update the existing sort/filter parms by clicking on "Confirm", or to save it with a different name or cancel the Save operation, this by clicking on "Cancel" ?',
              confirmDialogMessage:
                  "Filter words:\n Present only in modified version:\n   'Jancovici',\n   'Marine Le Pen'\nFilter options:\n In initial version:\n   and / or: and\n In modified version:\n   and / or: or",
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
          testWidgets(
              '''In 'Title asc' audio download date only, modified in the existing
               named and saved sort/filter parms. Then save it and verify
               ConfirmActionDialog content. Then delete the download dates and
               verify date deletion in ConfirmActionDialog.''',
              (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_filtered_parms_name_deletion_no_mp3_test",
              destinationRootPath: kApplicationPathWindowsTest,
            );

            final SettingsDataService settingsDataService = SettingsDataService(
              sharedPreferences: await SharedPreferences.getInstance(),
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            const String saveAsTitle = 'Title asc';

            // Edit the 'Title asc' sort/filter parms
            Finder dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the date
            // fields are visible and so accessible by the integration test.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Set start and end audio download dates

            await tester.enterText(
                find.byKey(const Key('startDownloadDateTextField')),
                '26/12/2023');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endDownloadDateTextField')), '6/1/2024');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'WARNING: the sort/filter parameters "$saveAsTitle" were modified. Do you want to update the existing sort/filter parms by clicking on "Confirm", or to save it with a different name or cancel the Save operation, this by clicking on "Cancel" ?',
              confirmDialogMessage:
                  'Filter options:\n In modified version:\n   Start downl date: 26/12/2023\n In modified version:\n   End downl date: 06/01/2024',
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Now re-edit the 'Title asc' sort/filter parms in order to
            // delete the start and end download dates
            dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the date
            // fields are visible and so accessible by the integration test.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Delete start and end audio download dates

            await tester.enterText(
                find.byKey(const Key('startDownloadDateTextField')), '');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endDownloadDateTextField')), '');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Necessary, otherwise the start download date field is not
            // emptied !
            await tester.enterText(
                find.byKey(const Key('startDownloadDateTextField')), '');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'WARNING: the sort/filter parameters "$saveAsTitle" were modified. Do you want to update the existing sort/filter parms by clicking on "Confirm", or to save it with a different name or cancel the Save operation, this by clicking on "Cancel" ?',
              confirmDialogMessage:
                  'Filter options:\n In initial version:\n   Start downl date: 26/12/2023\n In modified version:\n   Start downl date: empty\n In initial version:\n   End downl date: 06/01/2024\n In modified version:\n   End downl date: empty',
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
          testWidgets(
              '''In 'Title asc' video upload date only, modified in the existing
               named and saved sort/filter parms. Then save it and verify
               ConfirmActionDialog content. Then delete the video upload dates and
               verify date deletion in ConfirmActionDialog.''',
              (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_filtered_parms_name_deletion_no_mp3_test",
              destinationRootPath: kApplicationPathWindowsTest,
            );

            final SettingsDataService settingsDataService = SettingsDataService(
              sharedPreferences: await SharedPreferences.getInstance(),
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            const String saveAsTitle = 'Title asc';

            // Edit the 'Title asc' sort/filter parms
            Finder dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the checkboxes
            // are visible and so accessible by the integration test.
            // WARNING: Scrolling down must be done before setting sort
            // options, otherwise, it does not work.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Set start and end dates for the video upload date

            await tester.enterText(
                find.byKey(const Key('startUploadDateTextField')),
                '12/06/2022');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endUploadDateTextField')), '19/09/2023');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'WARNING: the sort/filter parameters "$saveAsTitle" were modified. Do you want to update the existing sort/filter parms by clicking on "Confirm", or to save it with a different name or cancel the Save operation, this by clicking on "Cancel" ?',
              confirmDialogMessage:
                  'Filter options:\n In modified version:\n   Start upl date: 12/06/2022\n In modified version:\n   End upl date: 19/09/2023',
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Now re-edit the 'Title asc' sort/filter parms in order to
            // delete the start and end video upload date dates
            dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the date
            // fields are visible and so accessible by the integration test.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Delete start and end audio download dates

            await tester.enterText(
                find.byKey(const Key('startUploadDateTextField')), '');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endUploadDateTextField')), '');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Necessary, otherwise the start download date field is not
            // emptied !
            await tester.enterText(
                find.byKey(const Key('startUploadDateTextField')), '');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'WARNING: the sort/filter parameters "$saveAsTitle" were modified. Do you want to update the existing sort/filter parms by clicking on "Confirm", or to save it with a different name or cancel the Save operation, this by clicking on "Cancel" ?',
              confirmDialogMessage:
                  'Filter options:\n In initial version:\n   Start upl date: 12/06/2022\n In modified version:\n   Start upl date: empty\n In initial version:\n   End upl date: 19/09/2023\n In modified version:\n   End upl date: empty',
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
          testWidgets(
              '''In 'Title asc' audio file size only, modified in the existing
               named and saved sort/filter parms. Then save it and verify
               ConfirmActionDialog content. Then, delete the start and end file
               size and verify the ConfirmActionDialog content.''',
              (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_filtered_parms_name_deletion_no_mp3_test",
              destinationRootPath: kApplicationPathWindowsTest,
            );

            final SettingsDataService settingsDataService = SettingsDataService(
              sharedPreferences: await SharedPreferences.getInstance(),
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            const String saveAsTitle = 'Title asc';

            // Edit the 'Title asc' sort/filter parms
            Finder dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the checkboxes
            // are visible and so accessible by the integration test.
            // WARNING: Scrolling down must be done before setting sort
            // options, otherwise, it does not work.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Set start and end audio file size MB range

            await tester.enterText(
                find.byKey(const Key('startFileSizeTextField')), '2.37');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endFileSizeTextField')), '2.8');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'WARNING: the sort/filter parameters "$saveAsTitle" were modified. Do you want to update the existing sort/filter parms by clicking on "Confirm", or to save it with a different name or cancel the Save operation, this by clicking on "Cancel" ?',
              confirmDialogMessage:
                  'Filter options:\n In modified version:\n   File size range (MB) Start: 2.37\n In modified version:\n   File size range (MB) End: 2.8',
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Re-edit the 'Title asc' sort/filter parms in order to
            // delete the start and end file size range
            dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the checkboxes
            // are visible and so accessible by the integration test.
            // WARNING: Scrolling down must be done before setting sort
            // options, otherwise, it does not work.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Delete start and end audio file size MB range

            await tester.enterText(
                find.byKey(const Key('startFileSizeTextField')), '');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endFileSizeTextField')), '');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'WARNING: the sort/filter parameters "$saveAsTitle" were modified. Do you want to update the existing sort/filter parms by clicking on "Confirm", or to save it with a different name or cancel the Save operation, this by clicking on "Cancel" ?',
              confirmDialogMessage:
                  'Filter options:\n In initial version:\n   File size range (MB) Start: 2.37\n In modified version:\n   File size range (MB) Start: 0.0\n In initial version:\n   File size range (MB) End: 2.8\n In modified version:\n   File size range (MB) End: 0.0',
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
          testWidgets(
              '''In 'Title asc' audio duration only, modified in the existing
               named and saved sort/filter parms. Then save it and verify
               ConfirmActionDialog content. Then, delete the start and end audio
               duration and verify the ConfirmActionDialog content.''',
              (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_filtered_parms_name_deletion_no_mp3_test",
              destinationRootPath: kApplicationPathWindowsTest,
            );

            final SettingsDataService settingsDataService = SettingsDataService(
              sharedPreferences: await SharedPreferences.getInstance(),
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            const String saveAsTitle = 'Title asc';

            // Edit the 'Title asc' sort/filter parms
            Finder dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the checkboxes
            // are visible and so accessible by the integration test.
            // WARNING: Scrolling down must be done before setting sort
            // options, otherwise, it does not work.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Set start and end audio duration hh:mm range

            await tester.enterText(
                find.byKey(const Key('startAudioDurationTextField')), '0:06');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endAudioDurationTextField')), '0:08');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'WARNING: the sort/filter parameters "$saveAsTitle" were modified. Do you want to update the existing sort/filter parms by clicking on "Confirm", or to save it with a different name or cancel the Save operation, this by clicking on "Cancel" ?',
              confirmDialogMessage:
                  'Filter options:\n In modified version:\n   Audio duration range (hh:mm)\n   Start: 00:06\n In modified version:\n   Audio duration range (hh:mm)\n   End: 00:08',
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Re-edit the 'Title asc' sort/filter parms in order to
            // delete the start and end audi duration
            dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the checkboxes
            // are visible and so accessible by the integration test.
            // WARNING: Scrolling down must be done before setting sort
            // options, otherwise, it does not work.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Set start and end audio duration hh:mm range

            await tester.enterText(
                find.byKey(const Key('startAudioDurationTextField')), '');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endAudioDurationTextField')), '');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'WARNING: the sort/filter parameters "$saveAsTitle" were modified. Do you want to update the existing sort/filter parms by clicking on "Confirm", or to save it with a different name or cancel the Save operation, this by clicking on "Cancel" ?',
              confirmDialogMessage:
                  'Filter options:\n In initial version:\n   Audio duration range (hh:mm)\n   Start: 00:06\n In modified version:\n   Audio duration range (hh:mm)\n   Start: 00:00\n In initial version:\n   Audio duration range (hh:mm)\n   End: 00:08\n In modified version:\n   Audio duration range (hh:mm)\n   End: 00:00',
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
          testWidgets(
              '''Modify 'for test' existing named and saved sort/filter parms.
               Then save it and verify ConfirmActionDialog content.''',
              (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_filtered_parms_name_deletion_no_mp3_test",
              destinationRootPath: kApplicationPathWindowsTest,
            );

            final SettingsDataService settingsDataService = SettingsDataService(
              sharedPreferences: await SharedPreferences.getInstance(),
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            const String saveAsTitle = 'for test';

            // Now tap on the current dropdown button item to open the dropdown
            // button items list

            final Finder dropDownButtonFinder =
                find.byKey(const Key('sort_filter_parms_dropdown_button'));

            final Finder dropDownButtonTextFinder = find.descendant(
              of: dropDownButtonFinder,
              matching: find.byType(Text),
            );

            await tester.tap(dropDownButtonTextFinder);
            await tester.pumpAndSettle();

            // And find the 'for test' sort/filter item
            final Finder titleAscDropDownTextFinder =
                find.text(saveAsTitle).last;
            await tester.tap(titleAscDropDownTextFinder);
            await tester.pumpAndSettle();

            // Now open the audio popup menu in order to modify the 'for test'
            Finder dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Convert ascending to descending sort order of 'Audio listenable
            // remaining duration'. So, the 'for test? sort/filter parms will
            // in fact be descending !!
            await IntegrationTestUtil.invertSortingItemOrder(
              tester: tester,
              sortingItemName: 'Audio listenable remaining duration',
            );

            await _removeSortingItem(
              tester: tester,
              sortingItemName: 'Audio downl date',
            );

            await _removeSortingItem(
              tester: tester,
              sortingItemName: 'Video upload date',
            );

            await _removeSortingItem(
              tester: tester,
              sortingItemName: 'Audio title',
            );

            await _removeSortingItem(
              tester: tester,
              sortingItemName: 'Audio duration',
            );

            await _removeSortingItem(
              tester: tester,
              sortingItemName: 'Last listened date/time',
            );

            await _removeSortingItem(
              tester: tester,
              sortingItemName: 'Audio file size',
            );

            await _removeSortingItem(
              tester: tester,
              sortingItemName: 'Audio downl speed',
            );

            await _removeSortingItem(
              tester: tester,
              sortingItemName: 'Audio downl duration',
            );

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'WARNING: the sort/filter parameters "$saveAsTitle" were modified. Do you want to update the existing sort/filter parms by clicking on "Confirm", or to save it with a different name or cancel the Save operation, this by clicking on "Cancel" ?',
              confirmDialogMessage:
                  'Sort by:\n Present only in initial version:\n   Audio downl date asc,\n   Video upload date desc,\n   Audio title asc,\n   Audio duration asc,\n   Audio listenable remaining\n   duration asc,\n   Last listened date/time desc,\n   Audio file size desc,\n   Audio downl speed desc,\n   Audio downl duration desc\n Present only in modified version:\n   Audio listenable remaining\n   duration desc',
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
          testWidgets(
              '''Modify 'for test 2' existing named and saved sort/filter parms.
               Then save it and verify ConfirmActionDialog content.''',
              (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_filtered_parms_name_deletion_no_mp3_test",
              destinationRootPath: kApplicationPathWindowsTest,
            );

            final SettingsDataService settingsDataService = SettingsDataService(
              sharedPreferences: await SharedPreferences.getInstance(),
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            const String saveAsTitle = 'for test 2';

            // Now tap on the current dropdown button item to open the dropdown
            // button items list

            final Finder dropDownButtonFinder =
                find.byKey(const Key('sort_filter_parms_dropdown_button'));

            final Finder dropDownButtonTextFinder = find.descendant(
              of: dropDownButtonFinder,
              matching: find.byType(Text),
            );

            await tester.tap(dropDownButtonTextFinder);
            await tester.pumpAndSettle();

            // And find the 'for test 2' sort/filter item
            final Finder titleAscDropDownTextFinder =
                find.text(saveAsTitle).last;
            await tester.tap(titleAscDropDownTextFinder);
            await tester.pumpAndSettle();

            // Now open the audio popup menu in order to modify the 'for test'
            Finder dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Convert ascending to descending sort order of 'Audio listenable
            // remaining duration'. So, the 'for test? sort/filter parms will
            // in fact be descending !!
            await IntegrationTestUtil.invertSortingItemOrder(
              tester: tester,
              sortingItemName: 'Audio listenable remaining duration',
            );

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'WARNING: the sort/filter parameters "$saveAsTitle" were modified. Do you want to update the existing sort/filter parms by clicking on "Confirm", or to save it with a different name or cancel the Save operation, this by clicking on "Cancel" ?',
              confirmDialogMessage:
                  'Sort by:\n Present only in initial version:\n   Audio listenable remaining\n   duration desc\n Present only in modified version:\n   Audio listenable remaining\n   duration asc',
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
        });
        group(
            '''Testing in french. Necessary to test in different languages since
          handling the translation happens in the widget code and not only in the
          arb translation files.''', () {
          testWidgets(
              '''Modify all parms in 'Title asc' existing named and saved SF parms.
                 Then save it and verify ConfirmActionDialog content. Then reedit
                 and modify all sort/filter parms and save it with on the same name
                 to verify that the ConfirmActionDialog content contains every
                 sort/filter parm.''', (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_filtered_parms_name_deletion_no_mp3_test",
              destinationRootPath: kApplicationPathWindowsTest,
            );

            final SettingsDataService settingsDataService = SettingsDataService(
              sharedPreferences: await SharedPreferences.getInstance(),
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            const String saveAsTitle = 'Title asc';

            // Change the application language to french
            await IntegrationTestUtil.setApplicationLanguage(
              tester: tester,
              language: Language.french,
            );

            // Edit the 'Title asc' sort/filter parms
            Finder dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle(const Duration(milliseconds: 200));

            // Convert ascending to descending sort order of 'Audio title'.
            // So, the 'Title asc? sort/filter p
            //arms will in fact be descending !!
            await IntegrationTestUtil.invertSortingItemOrder(
              tester: tester,
              sortingItemName: 'Titre audio',
            );

            // Now define an audio/video title or description filter word
            await _addAudioFilterStrAndClickOnPlusIconButton(
              tester: tester,
              audioFilterString: 'Jancovici',
            );

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'ATTENTION: le paramètre de tri/filtre "$saveAsTitle" a été modifié. Voulez-vous mettre à jour le paramètre de tri/filtre existant en cliquant sur "Confirmer", ou le sauver sous un nom différent ou annuler l\'operation d\'édition, cela en cliquant sur "Annuler" ?',
              confirmDialogMessage:
                  "Trier par:\n Uniquement en version initiale:\n   Titre audio asc\n Uniquement en version modifiée:\n   Titre audio desc\nMots filtre:\n Uniquement en version modifiée:\n   'Jancovici'",
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Now reedit the 'Title asc' sort/filter parms and modify
            // every sort/filter parm

            dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the checkboxes
            // are visible and so accessible by the integration test.
            // WARNING: Scrolling down must be done before setting sort
            // options, otherwise, it does not work.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Tap on the Music qual. checkbox to unselect it
            await tester
                .tap(find.byKey(const Key('filterMusicQualityCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Spoken qual. checkbox to unselect it. This deselect
            // Spoken qual. and reselcet Music qual.
            await tester
                .tap(find.byKey(const Key('filterSpokenQualityCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Commented checkbox to unselect it
            await tester.tap(find.byKey(const Key('filterCommentedCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Uncom. checkbox to unselect it
            await tester
                .tap(find.byKey(const Key('filterNotCommentedCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Pictured checkbox to unselect it
            await tester.tap(find.byKey(const Key('filterPicturedCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Unpictured checkbox to unselect it
            await tester
                .tap(find.byKey(const Key('filterNotPicturedCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Not playable checkbox to unselect it. This deselect
            // Not playable.
            await tester
                .tap(find.byKey(const Key('filterNotPlayableCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Playable checkbox to unselect it. This deselect
            // Playable and reselect Not playable
            await tester.tap(find.byKey(const Key('filterPlayableCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Imported checkbox to unselect it. This deselect
            // Imported.
            await tester.tap(find.byKey(const Key('filterImportedCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Downloaded checkbox to unselect it. This deselects
            // Downloaded and reselects Imported.
            await tester.tap(find.byKey(const Key('filterDownloadedCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Exclude ignore case checkbox to unselect it
            await tester.tap(find.byKey(const Key('ignoreCaseCheckbox')));
            await tester.pumpAndSettle();

            // Tap on the Search in video compact description checkbox to unselect it
            await tester
                .tap(find.byKey(const Key('searchInVideoCompactDescription')));
            await tester.pumpAndSettle();

            // Tap on the Search in Youtube compact description checkbox to unselect it
            await tester
                .tap(find.byKey(const Key('searchInYoutubeChannelName')));
            await tester.pumpAndSettle();

            // Set start and end audio download dates

            await tester.enterText(
                find.byKey(const Key('startDownloadDateTextField')),
                '26/12/2023');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endDownloadDateTextField')), '6/1/2024');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Set start and end dates for the video upload date

            await tester.enterText(
                find.byKey(const Key('startUploadDateTextField')),
                '12/06/2022');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endUploadDateTextField')), '19/09/2023');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Set start and end audio file size MB range

            await tester.enterText(
                find.byKey(const Key('startFileSizeTextField')), '2.37');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endFileSizeTextField')), '2.8');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Set start and end audio duration hh:mm range

            await tester.enterText(
                find.byKey(const Key('startAudioDurationTextField')), '0:06');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endAudioDurationTextField')), '0:08');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Scrolling up the sort filter dialog to access to sort options
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, 600), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Convert descending to ascending sort order of 'Audio title'.
            // So, the 'Title asc? sort/filter parms will in fact be ascending !!
            await IntegrationTestUtil.invertSortingItemOrder(
              tester: tester,
              sortingItemName: 'Titre audio',
            );

            // Select the 'Audio chapter' item in the 'Sort by'
            // dropdown button
            await _selectSortByOption(
              tester: tester,
              audioSortOption: 'Chapitre audio',
            );

            // Select the 'Video upload date' item in the 'Sort by'
            // dropdown button
            await _selectSortByOption(
              tester: tester,
              audioSortOption: 'Date mise en ligne vidéo',
            );

            // Select the 'Audio duration' item in the 'Sort by'
            // dropdown button
            await _selectSortByOption(
              tester: tester,
              audioSortOption: 'Durée audio',
            );

            // Select the 'Audio listenable remaining duration' item in the 'Sort by'
            // dropdown button
            await _selectSortByOption(
              tester: tester,
              audioSortOption: 'Durée audio écoutable restante',
            );

            // Select the 'Audio downl speed' item in the 'Sort by'
            // dropdown button
            await _selectSortByOption(
              tester: tester,
              audioSortOption: 'Vitesse téléch audio',
            );

            // Select the 'Audio downl duration' item in the 'Sort by'
            // dropdown button
            await _selectSortByOption(
              tester: tester,
              audioSortOption: 'Durée téléch audio',
            );

            // Type "Jancovici" in the audio title search sentence TextField
            await _addAudioFilterStrAndClickOnPlusIconButton(
              tester: tester,
              audioFilterString: 'Jancovici',
            );

            // Type "Marine Le Pen" in the audio title search sentence TextField
            await _addAudioFilterStrAndClickOnPlusIconButton(
              tester: tester,
              audioFilterString: 'Marine Le Pen',
            );

            // Type "Emmanuel Macron" in the audio title search sentence TextField
            await _addAudioFilterStrAndClickOnPlusIconButton(
              tester: tester,
              audioFilterString: 'Emmanuel Macron',
            );

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'ATTENTION: le paramètre de tri/filtre "$saveAsTitle" a été modifié. Voulez-vous mettre à jour le paramètre de tri/filtre existant en cliquant sur "Confirmer", ou le sauver sous un nom différent ou annuler l\'operation d\'édition, cela en cliquant sur "Annuler" ?',
              confirmDialogMessage:
                  "Trier par:\n Uniquement en version initiale:\n   Titre audio desc\n Uniquement en version modifiée:\n   Titre audio asc,\n   Chapitre audio asc,\n   Date mise en ligne vidéo desc,\n   Durée audio asc,\n   Durée audio écoutable\n   restante asc,\n   Vitesse téléch audio desc,\n   Durée téléch audio desc\nMots filtre:\n Uniquement en version modifiée:\n   'Marine Le Pen',\n   'Emmanuel Macron'\nOptions filtre:\n En version initiale:\n   Ignorer la casse: coché\n En version modifiée:\n   Ignorer la casse: décoché\n En version initiale:\n   Inclure la chaîne Youtube: coché\n En version modifiée:\n   Inclure la chaîne\n   Youtube: décoché\n En version initiale:\n   Q. orale: coché\n En version modifiée:\n   Q. orale: décoché\n En version initiale:\n   Non com.: coché\n En version modifiée:\n   Non com.: décoché\n En version initiale:\n   Sans ph.: coché\n En version modifiée:\n   Sans ph.: décoché\n En version initiale:\n   Jouable: coché\n En version modifiée:\n   Jouable: décoché\n En version initiale:\n   Téléchargé: coché\n En version modifiée:\n   Téléchargé: décoché\n En version modifiée:\n   Date début téléch: 26/12/2023\n En version modifiée:\n   Date fin téléch: 06/01/2024\n En version modifiée:\n   Date début mise en\n   ligne: 12/06/2022\n En version modifiée:\n   Date fin mise en\n   ligne: 19/09/2023\n En version modifiée:\n   Intervalle taille fichier (MB)\n   Début: 2.37\n En version modifiée:\n   Intervalle taille fichier (MB)\n   Fin: 2.8\n En version modifiée:\n   Intervalle durée audio (hh:mm)\n   Début: 00:06\n En version modifiée:\n   Intervalle durée audio (hh:mm)\n   Fin: 00:08",
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
          testWidgets(
              '''In 'Title asc' click on 'or' only after adding two filter
               words, modified in the existing named and saved sort/filter parms.
               Then save it and verify ConfirmActionDialog content.''',
              (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_filtered_parms_name_deletion_no_mp3_test",
              destinationRootPath: kApplicationPathWindowsTest,
            );

            final SettingsDataService settingsDataService = SettingsDataService(
              sharedPreferences: await SharedPreferences.getInstance(),
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            const String saveAsTitle = 'Title asc';

            // Change the application language to french
            await IntegrationTestUtil.setApplicationLanguage(
              tester: tester,
              language: Language.french,
            );

            // Edit the 'Title asc' sort/filter parms
            Finder dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the checkboxes
            // are visible and so accessible by the integration test.
            // WARNING: Scrolling down must be done before setting sort
            // options, otherwise, it does not work.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Type "Jancovici" in the audio title search sentence TextField
            await _addAudioFilterStrAndClickOnPlusIconButton(
              tester: tester,
              audioFilterString: 'Jancovici',
            );

            // Type "Marine Le Pen" in the audio title search sentence TextField
            await _addAudioFilterStrAndClickOnPlusIconButton(
              tester: tester,
              audioFilterString: 'Marine Le Pen',
            );

            // Tap on the 'or' checkbox set sentence combination
            await tester.tap(find.byKey(const Key('orCheckbox')));
            await tester.pumpAndSettle();

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'ATTENTION: le paramètre de tri/filtre "$saveAsTitle" a été modifié. Voulez-vous mettre à jour le paramètre de tri/filtre existant en cliquant sur "Confirmer", ou le sauver sous un nom différent ou annuler l\'operation d\'édition, cela en cliquant sur "Annuler" ?',
              confirmDialogMessage:
                  "Mots filtre:\n Uniquement en version modifiée:\n   'Jancovici',\n   'Marine Le Pen'\nOptions filtre:\n En version initiale:\n   et / ou: et\n En version modifiée:\n   et / ou: ou",
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
          testWidgets(
              '''In 'Title asc' click on 'and' only after adding two filter
               words. Clicking on 'and' which is initially checked does uncheck it
               and checks the 'or' checkbox. This modifies the existing named and
               saved sort/filter parms. Then save it and verify ConfirmActionDialog
               content.''', (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_filtered_parms_name_deletion_no_mp3_test",
              destinationRootPath: kApplicationPathWindowsTest,
            );

            final SettingsDataService settingsDataService = SettingsDataService(
              sharedPreferences: await SharedPreferences.getInstance(),
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            const String saveAsTitle = 'Title asc';

            // Change the application language to french
            await IntegrationTestUtil.setApplicationLanguage(
              tester: tester,
              language: Language.french,
            );

            // Edit the 'Title asc' sort/filter parms
            Finder dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the checkboxes
            // are visible and so accessible by the integration test.
            // WARNING: Scrolling down must be done before setting sort
            // options, otherwise, it does not work.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Type "Jancovici" in the audio title search sentence TextField
            await _addAudioFilterStrAndClickOnPlusIconButton(
              tester: tester,
              audioFilterString: 'Jancovici',
            );

            // Type "Marine Le Pen" in the audio title search sentence TextField
            await _addAudioFilterStrAndClickOnPlusIconButton(
              tester: tester,
              audioFilterString: 'Marine Le Pen',
            );

            // Tap on the 'and / or' checkbox set sentence combination
            // to 'or' instead of 'and'
            await tester.tap(find.byKey(const Key('andCheckbox')));
            await tester.pumpAndSettle();

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'ATTENTION: le paramètre de tri/filtre "$saveAsTitle" a été modifié. Voulez-vous mettre à jour le paramètre de tri/filtre existant en cliquant sur "Confirmer", ou le sauver sous un nom différent ou annuler l\'operation d\'édition, cela en cliquant sur "Annuler" ?',
              confirmDialogMessage:
                  "Mots filtre:\n Uniquement en version modifiée:\n   'Jancovici',\n   'Marine Le Pen'\nOptions filtre:\n En version initiale:\n   et / ou: et\n En version modifiée:\n   et / ou: ou",
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
          testWidgets(
              '''In 'Title asc' audio download date only, modified in the existing
               named and saved sort/filter parms. Then save it and verify
               ConfirmActionDialog content.''', (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_filtered_parms_name_deletion_no_mp3_test",
              destinationRootPath: kApplicationPathWindowsTest,
            );

            final SettingsDataService settingsDataService = SettingsDataService(
              sharedPreferences: await SharedPreferences.getInstance(),
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            const String saveAsTitle = 'Title asc';

            // Change the application language to french
            await IntegrationTestUtil.setApplicationLanguage(
              tester: tester,
              language: Language.french,
            );

            // Edit the 'Title asc' sort/filter parms
            Finder dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the checkboxes
            // are visible and so accessible by the integration test.
            // WARNING: Scrolling down must be done before setting sort
            // options, otherwise, it does not work.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Set start and end audio download dates

            await tester.enterText(
                find.byKey(const Key('startDownloadDateTextField')),
                '26/12/2023');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endDownloadDateTextField')), '6/1/2024');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'ATTENTION: le paramètre de tri/filtre "$saveAsTitle" a été modifié. Voulez-vous mettre à jour le paramètre de tri/filtre existant en cliquant sur "Confirmer", ou le sauver sous un nom différent ou annuler l\'operation d\'édition, cela en cliquant sur "Annuler" ?',
              confirmDialogMessage:
                  'Options filtre:\n En version modifiée:\n   Date début téléch: 26/12/2023\n En version modifiée:\n   Date fin téléch: 06/01/2024',
              confirmOrCancelAction: true, // Confirm button is tapped
            );
            // Now re-edit the 'Title asc' sort/filter parms in order to
            // delete the start and end download dates
            dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the date
            // fields are visible and so accessible by the integration test.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Delete start and end audio download dates

            await tester.enterText(
                find.byKey(const Key('startDownloadDateTextField')), '');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endDownloadDateTextField')), '');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Necessary, otherwise the start download date field is not
            // emptied !
            await tester.enterText(
                find.byKey(const Key('startDownloadDateTextField')), '');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'ATTENTION: le paramètre de tri/filtre "$saveAsTitle" a été modifié. Voulez-vous mettre à jour le paramètre de tri/filtre existant en cliquant sur "Confirmer", ou le sauver sous un nom différent ou annuler l\'operation d\'édition, cela en cliquant sur "Annuler" ?',
              confirmDialogMessage:
                  'Options filtre:\n En version initiale:\n   Date début téléch: 26/12/2023\n En version modifiée:\n   Date début téléch: vide\n En version initiale:\n   Date fin téléch: 06/01/2024\n En version modifiée:\n   Date fin téléch: vide',
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
          testWidgets(
              '''In 'Title asc' video upload date only, modified in the existing
               named and saved sort/filter parms. Then save it and verify
               ConfirmActionDialog content.''', (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_filtered_parms_name_deletion_no_mp3_test",
              destinationRootPath: kApplicationPathWindowsTest,
            );

            final SettingsDataService settingsDataService = SettingsDataService(
              sharedPreferences: await SharedPreferences.getInstance(),
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            const String saveAsTitle = 'Title asc';

            // Change the application language to french
            await IntegrationTestUtil.setApplicationLanguage(
              tester: tester,
              language: Language.french,
            );

            // Edit the 'Title asc' sort/filter parms
            Finder dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the checkboxes
            // are visible and so accessible by the integration test.
            // WARNING: Scrolling down must be done before setting sort
            // options, otherwise, it does not work.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Set start and end dates for the video upload date

            await tester.enterText(
                find.byKey(const Key('startUploadDateTextField')),
                '12/06/2022');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endUploadDateTextField')), '19/09/2023');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'ATTENTION: le paramètre de tri/filtre "$saveAsTitle" a été modifié. Voulez-vous mettre à jour le paramètre de tri/filtre existant en cliquant sur "Confirmer", ou le sauver sous un nom différent ou annuler l\'operation d\'édition, cela en cliquant sur "Annuler" ?',
              confirmDialogMessage:
                  'Options filtre:\n En version modifiée:\n   Date début mise en\n   ligne: 12/06/2022\n En version modifiée:\n   Date fin mise en\n   ligne: 19/09/2023',
              confirmOrCancelAction: true, // Confirm button is tapped
            );
            // Now re-edit the 'Title asc' sort/filter parms in order to
            // delete the start and end video upload date dates
            dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the date
            // fields are visible and so accessible by the integration test.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Delete start and end audio download dates

            await tester.enterText(
                find.byKey(const Key('startUploadDateTextField')), '');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endUploadDateTextField')), '');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Necessary, otherwise the start download date field is not
            // emptied !
            await tester.enterText(
                find.byKey(const Key('startUploadDateTextField')), '');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'ATTENTION: le paramètre de tri/filtre "$saveAsTitle" a été modifié. Voulez-vous mettre à jour le paramètre de tri/filtre existant en cliquant sur "Confirmer", ou le sauver sous un nom différent ou annuler l\'operation d\'édition, cela en cliquant sur "Annuler" ?',
              confirmDialogMessage:
                  'Options filtre:\n En version initiale:\n   Date début mise en\n   ligne: 12/06/2022\n En version modifiée:\n   Date début mise en ligne: vide\n En version initiale:\n   Date fin mise en\n   ligne: 19/09/2023\n En version modifiée:\n   Date fin mise en ligne: vide',
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
          testWidgets(
              '''In 'Title asc' audio file size only, modified in the existing
               named and saved sort/filter parms. Then save it and verify
               ConfirmActionDialog content. Then, delete the start and end file
               size and verify the ConfirmActionDialog content.''',
              (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_filtered_parms_name_deletion_no_mp3_test",
              destinationRootPath: kApplicationPathWindowsTest,
            );

            final SettingsDataService settingsDataService = SettingsDataService(
              sharedPreferences: await SharedPreferences.getInstance(),
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            const String saveAsTitle = 'Title asc';

            // Change the application language to french
            await IntegrationTestUtil.setApplicationLanguage(
              tester: tester,
              language: Language.french,
            );

            // Edit the 'Title asc' sort/filter parms
            Finder dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the checkboxes
            // are visible and so accessible by the integration test.
            // WARNING: Scrolling down must be done before setting sort
            // options, otherwise, it does not work.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Set start and end audio file size MB range

            await tester.enterText(
                find.byKey(const Key('startFileSizeTextField')), '2.37');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endFileSizeTextField')), '2.8');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'ATTENTION: le paramètre de tri/filtre "$saveAsTitle" a été modifié. Voulez-vous mettre à jour le paramètre de tri/filtre existant en cliquant sur "Confirmer", ou le sauver sous un nom différent ou annuler l\'operation d\'édition, cela en cliquant sur "Annuler" ?',
              confirmDialogMessage:
                  'Options filtre:\n En version modifiée:\n   Intervalle taille fichier (MB)\n   Début: 2.37\n En version modifiée:\n   Intervalle taille fichier (MB)\n   Fin: 2.8',
              confirmOrCancelAction: true, // Confirm button is tapped
            );
            // Re-edit the 'Title asc' sort/filter parms in order to
            // delete the start and end file size range
            dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the checkboxes
            // are visible and so accessible by the integration test.
            // WARNING: Scrolling down must be done before setting sort
            // options, otherwise, it does not work.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Delete start and end audio file size MB range

            await tester.enterText(
                find.byKey(const Key('startFileSizeTextField')), '');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endFileSizeTextField')), '');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'ATTENTION: le paramètre de tri/filtre "$saveAsTitle" a été modifié. Voulez-vous mettre à jour le paramètre de tri/filtre existant en cliquant sur "Confirmer", ou le sauver sous un nom différent ou annuler l\'operation d\'édition, cela en cliquant sur "Annuler" ?',
              confirmDialogMessage:
                  'Options filtre:\n En version initiale:\n   Intervalle taille fichier (MB)\n   Début: 2.37\n En version modifiée:\n   Intervalle taille fichier (MB)\n   Début: 0.0\n En version initiale:\n   Intervalle taille fichier (MB)\n   Fin: 2.8\n En version modifiée:\n   Intervalle taille fichier (MB)\n   Fin: 0.0',
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
          testWidgets(
              '''In 'Title asc' audio duration only, modified in the existing
               named and saved sort/filter parms. Then save it and verify
               ConfirmActionDialog content. Then, delete the start and end audio
               duration and verify the ConfirmActionDialog content.''',
              (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_filtered_parms_name_deletion_no_mp3_test",
              destinationRootPath: kApplicationPathWindowsTest,
            );

            final SettingsDataService settingsDataService = SettingsDataService(
              sharedPreferences: await SharedPreferences.getInstance(),
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            const String saveAsTitle = 'Title asc';

            // Change the application language to french
            await IntegrationTestUtil.setApplicationLanguage(
              tester: tester,
              language: Language.french,
            );

            // Edit the 'Title asc' sort/filter parms
            Finder dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the checkboxes
            // are visible and so accessible by the integration test.
            // WARNING: Scrolling down must be done before setting sort
            // options, otherwise, it does not work.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Set start and end audio duration hh:mm range

            await tester.enterText(
                find.byKey(const Key('startAudioDurationTextField')), '0:06');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endAudioDurationTextField')), '0:08');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'ATTENTION: le paramètre de tri/filtre "$saveAsTitle" a été modifié. Voulez-vous mettre à jour le paramètre de tri/filtre existant en cliquant sur "Confirmer", ou le sauver sous un nom différent ou annuler l\'operation d\'édition, cela en cliquant sur "Annuler" ?',
              confirmDialogMessage:
                  'Options filtre:\n En version modifiée:\n   Intervalle durée audio (hh:mm)\n   Début: 00:06\n En version modifiée:\n   Intervalle durée audio (hh:mm)\n   Fin: 00:08',
              confirmOrCancelAction: true, // Confirm button is tapped
            );
            // Re-edit the 'Title asc' sort/filter parms in order to
            // delete the start and end audi duration
            dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Scrolling down the sort filter dialog so that the checkboxes
            // are visible and so accessible by the integration test.
            // WARNING: Scrolling down must be done before setting sort
            // options, otherwise, it does not work.
            await tester.drag(
              find.byType(AudioSortFilterDialog),
              const Offset(
                  0, -300), // Negative value for vertical drag to scroll down
            );
            await tester.pumpAndSettle();

            // Set start and end audio duration hh:mm range

            await tester.enterText(
                find.byKey(const Key('startAudioDurationTextField')), '');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            await tester.enterText(
                find.byKey(const Key('endAudioDurationTextField')), '');
            await tester.pumpAndSettle(Duration(milliseconds: 200));

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'ATTENTION: le paramètre de tri/filtre "$saveAsTitle" a été modifié. Voulez-vous mettre à jour le paramètre de tri/filtre existant en cliquant sur "Confirmer", ou le sauver sous un nom différent ou annuler l\'operation d\'édition, cela en cliquant sur "Annuler" ?',
              confirmDialogMessage:
                  'Options filtre:\n En version initiale:\n   Intervalle durée audio (hh:mm)\n   Début: 00:06\n En version modifiée:\n   Intervalle durée audio (hh:mm)\n   Début: 00:00\n En version initiale:\n   Intervalle durée audio (hh:mm)\n   Fin: 00:08\n En version modifiée:\n   Intervalle durée audio (hh:mm)\n   Fin: 00:00',
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
          testWidgets(
              '''Modify 'for test' existing named and saved sort/filter parms.
               Then save it and verify ConfirmActionDialog content.''',
              (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_filtered_parms_name_deletion_no_mp3_test",
              destinationRootPath: kApplicationPathWindowsTest,
            );

            final SettingsDataService settingsDataService = SettingsDataService(
              sharedPreferences: await SharedPreferences.getInstance(),
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            const String saveAsTitle = 'for test';

            // Change the application language to french
            await IntegrationTestUtil.setApplicationLanguage(
              tester: tester,
              language: Language.french,
            );

            // Now tap on the current dropdown button item to open the dropdown
            // button items list

            final Finder dropDownButtonFinder =
                find.byKey(const Key('sort_filter_parms_dropdown_button'));

            final Finder dropDownButtonTextFinder = find.descendant(
              of: dropDownButtonFinder,
              matching: find.byType(Text),
            );

            await tester.tap(dropDownButtonTextFinder);
            await tester.pumpAndSettle();

            // And find the 'for test' sort/filter item
            final Finder titleAscDropDownTextFinder =
                find.text(saveAsTitle).last;
            await tester.tap(titleAscDropDownTextFinder);
            await tester.pumpAndSettle();

            // Now open the audio popup menu in order to modify the 'for test'
            Finder dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Convert ascending to descending sort order of 'Audio listenable
            // remaining duration'. So, the 'for test? sort/filter parms will
            // in fact be descending !!
            await IntegrationTestUtil.invertSortingItemOrder(
              tester: tester,
              sortingItemName: 'Durée audio écoutable restante',
            );

            await _removeSortingItem(
              tester: tester,
              sortingItemName: 'Date téléch audio',
            );

            await _removeSortingItem(
              tester: tester,
              sortingItemName: 'Date mise en ligne vidéo',
            );

            await _removeSortingItem(
              tester: tester,
              sortingItemName: 'Titre audio',
            );

            await _removeSortingItem(
              tester: tester,
              sortingItemName: 'Durée audio',
            );

            await _removeSortingItem(
              tester: tester,
              sortingItemName: 'Date/heure dernière écoute',
            );

            await _removeSortingItem(
              tester: tester,
              sortingItemName: 'Taille fichier audio',
            );

            await _removeSortingItem(
              tester: tester,
              sortingItemName: 'Vitesse téléch audio',
            );

            await _removeSortingItem(
              tester: tester,
              sortingItemName: 'Durée téléch audio',
            );

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'ATTENTION: le paramètre de tri/filtre "$saveAsTitle" a été modifié. Voulez-vous mettre à jour le paramètre de tri/filtre existant en cliquant sur "Confirmer", ou le sauver sous un nom différent ou annuler l\'operation d\'édition, cela en cliquant sur "Annuler" ?',
              confirmDialogMessage:
                  'Trier par:\n Uniquement en version initiale:\n   Date téléch audio asc,\n   Date mise en ligne vidéo desc,\n   Titre audio asc,\n   Durée audio asc,\n   Durée audio écoutable\n   restante asc,\n   Date/heure dernière écoute desc,\n   Taille fichier audio desc,\n   Vitesse téléch audio desc,\n   Durée téléch audio desc\n Uniquement en version modifiée:\n   Durée audio écoutable\n   restante desc',
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
          testWidgets(
              '''Modify 'for test 2' existing named and saved sort/filter parms.
               Then save it and verify ConfirmActionDialog content.''',
              (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_filtered_parms_name_deletion_no_mp3_test",
              destinationRootPath: kApplicationPathWindowsTest,
            );

            final SettingsDataService settingsDataService = SettingsDataService(
              sharedPreferences: await SharedPreferences.getInstance(),
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            const String saveAsTitle = 'for test 2';

            // Change the application language to french
            await IntegrationTestUtil.setApplicationLanguage(
              tester: tester,
              language: Language.french,
            );

            // Now tap on the current dropdown button item to open the dropdown
            // button items list

            final Finder dropDownButtonFinder =
                find.byKey(const Key('sort_filter_parms_dropdown_button'));

            final Finder dropDownButtonTextFinder = find.descendant(
              of: dropDownButtonFinder,
              matching: find.byType(Text),
            );

            await tester.tap(dropDownButtonTextFinder);
            await tester.pumpAndSettle();

            // And find the 'for test 2' sort/filter item
            final Finder titleAscDropDownTextFinder =
                find.text(saveAsTitle).last;
            await tester.tap(titleAscDropDownTextFinder);
            await tester.pumpAndSettle();

            // Now open the audio popup menu in order to modify the 'for test'
            Finder dropdownItemEditIconButtonFinder = find.byKey(
                const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
            await tester.tap(dropdownItemEditIconButtonFinder);
            await tester.pumpAndSettle();

            // Convert ascending to descending sort order of 'Audio listenable
            // remaining duration'. So, the 'for test? sort/filter parms will
            // in fact be descending !!
            await IntegrationTestUtil.invertSortingItemOrder(
              tester: tester,
              sortingItemName: 'Durée audio écoutable restante',
            );

            // Click on the "Save" button.
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Verifying and closing the confirm dialog

            await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
              tester: tester,
              confirmDialogTitleOne:
                  'ATTENTION: le paramètre de tri/filtre "$saveAsTitle" a été modifié. Voulez-vous mettre à jour le paramètre de tri/filtre existant en cliquant sur "Confirmer", ou le sauver sous un nom différent ou annuler l\'operation d\'édition, cela en cliquant sur "Annuler" ?',
              confirmDialogMessage:
                  'Trier par:\n Uniquement en version initiale:\n   Durée audio écoutable\n   restante desc\n Uniquement en version modifiée:\n   Durée audio écoutable\n   restante asc',
              confirmOrCancelAction: true, // Confirm button is tapped
            );

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
        });
      });
    });
    group('''Saving defined sort/filter parms in sort/filter dialog in relation
             with Sort/filter dropdown button test''', () {
      testWidgets(
          '''Click on 'Sort/filter audio' menu item of Audio popup menu to
             open sort filter audio dialog. Then creating a named title
             ascending sort/filter parms and saving it. Then verifying that
             a Sort/filter dropdown button item has been created and is applied
             to the playlist download view list of audio. Then going to the
             audio player view and then going back to the playlist download view
             and verifying that the previously active and newly created sort/filter
             parms is displayed in the dropdown item button and applied to the
             audio. Then, select 'default' dropdown item and go to audio
             player view and back to playlist download view. Finally, select
             'Title asc' dropdown item and go to audio player view and back to
             playlist download view.''', (WidgetTester tester) async {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
          destinationRootPath: kApplicationPathWindowsTest,
        );

        final SettingsDataService settingsDataService = SettingsDataService(
          sharedPreferences: await SharedPreferences.getInstance(),
        );

        // Load the settings from the json file. This is necessary
        // otherwise the ordered playlist titles will remain empty
        // and the playlist list will not be filled with the
        // playlists available in the download app test dir
        await settingsDataService.loadSettingsFromFile(
            settingsJsonPathFileName:
                "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

        await app.main();
        await tester.pumpAndSettle();

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

        // Now select the 'Audio title' item in the 'Sort by' dropdown button

        await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
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

        // Now verify the playlist download view state with the 'Title asc'
        // sort/filter parms applied

        // Verify that the dropdown button has been updated with the
        // 'Title asc' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: saveAsTitle,
        );

        // And verify the order of the playlist audio titles

        List<String> audioTitlesSortedByTitleAscending = [
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La résilience insulaire par Fiona Roche",
          "La surpopulation mondiale par Jancovici et Barrau",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          // "Les besoins artificiels par R.Keucheyan"
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
        );

        // Now go to audio player view
        Finder appScreenNavigationButton =
            find.byKey(const ValueKey('audioPlayerViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // Then return to playlist download view in order to verify that
        // its state with the 'Title asc' sort/filter parms is still
        // applied and correctly sorts the current playable audio.
        appScreenNavigationButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        // Verify that the dropdown button has been updated with the
        // 'Title asc' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: saveAsTitle,
        );

        // And verify the order of the playlist audio titles
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
        );

        // Now, selecting 'default' dropdown button item to apply the
        // default sort/filter parms
        final Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        final Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        // Tap on the current dropdown button item to open the dropdown
        // button items list
        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // And select the default sort/filter item
        String defaultTitle = 'default';
        final Finder defaultDropDownTextFinder = find.text(defaultTitle);
        await tester.tap(defaultDropDownTextFinder);
        await tester.pumpAndSettle();

        // Now verify the playlist download view state with the 'default'
        // sort/filter parms applied

        // Verify that the dropdown button has been updated with the
        // 'default' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: defaultTitle,
        );

        // And verify the order of the playlist audio titles

        List<String>
            audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Now go to audio player view
        appScreenNavigationButton =
            find.byKey(const ValueKey('audioPlayerViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        // Then return to playlist download view in order to verify that
        // its state with the 'default' sort/filter parms is still
        // applied and correctly sorts the current playable audio.
        appScreenNavigationButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        // Verify that the dropdown button has been updated with the
        // 'default' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: defaultTitle,
        );

        // And verify the order of the playlist audio titles
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Finally tap on the current dropdown button item to open the dropdown
        // button items list
        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // And select the 'Title asc' sort/filter item
        final Finder titleAscDropDownTextFinder = find.text(saveAsTitle);
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Now verify the playlist download view state with the 'default'
        // sort/filter parms applied

        // Verify that the dropdown button has been updated with the
        // 'default' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: saveAsTitle,
        );

        // And verify the order of the playlist audio titles

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
        );

        // Now go to audio player view
        appScreenNavigationButton =
            find.byKey(const ValueKey('audioPlayerViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        // Then return to playlist download view in order to verify that
        // its state with the 'default' sort/filter parms is still
        // applied and correctly sorts the current playable audio.
        appScreenNavigationButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        // Verify that the dropdown button has been updated with the
        // 'default' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: saveAsTitle,
        );

        // And verify the order of the playlist audio titles
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets('''Click on 'default' dropdown button item edit icon button to
             open sort filter audio dialog. Then creating a named title
             ascending sort/filter parms and saving it. Then verifying that
             a Sort/filter dropdown button item has been created and is applied
             to the playlist download view list of audio. Then going to the
             audio player view and then going back to the playlist download view
             and verifying that the previously active and newly created sort/filter
             parms is displayed in the dropdown item button and applied to the
             audio.''', (WidgetTester tester) async {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
          destinationRootPath: kApplicationPathWindowsTest,
        );

        final SettingsDataService settingsDataService = SettingsDataService(
          sharedPreferences: await SharedPreferences.getInstance(),
        );

        // Load the settings from the json file. This is necessary
        // otherwise the ordered playlist titles will remain empty
        // and the playlist list will not be filled with the
        // playlists available in the download app test dir
        await settingsDataService.loadSettingsFromFile(
            settingsJsonPathFileName:
                "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

        await app.main();
        await tester.pumpAndSettle();

        final Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        final Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        // Tap twice on the dropdown button 'default' item so that its edit
        // icon button is displayed
        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();
        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        Finder dropdownItemEditIconButtonFinder = find.byKey(
          const Key('sort_filter_parms_dropdown_item_edit_icon_button'),
        );

        // Tap on the edit icon button to open the sort/filter dialog
        await tester.tap(dropdownItemEditIconButtonFinder);
        await tester.pumpAndSettle();

        // Type "Title asc" in the 'Save as' TextField

        String saveAsTitle = 'Title asc';

        await tester.enterText(
            find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
            saveAsTitle);
        await tester.pumpAndSettle();

        // Now select the 'Audio title' item in the 'Sort by' dropdown button

        await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
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

        // Now verify the playlist download view state with the 'Title asc'
        // sort/filter parms applied

        // Verify that the dropdown button has been updated with the
        // 'Title asc' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: saveAsTitle,
        );

        // And verify the order of the playlist audio titles

        List<String> audioTitlesSortedByTitleAscending = [
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La résilience insulaire par Fiona Roche",
          "La surpopulation mondiale par Jancovici et Barrau",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          // "Les besoins artificiels par R.Keucheyan"
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
        );

        // Now go to audio player view
        Finder appScreenNavigationButton =
            find.byKey(const ValueKey('audioPlayerViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        // Then return to playlist download view in order to verify that
        // its state with the 'Title asc' sort/filter parms is still
        // applied and correctly sorts the current playable audio.
        appScreenNavigationButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        // Verify that the dropdown button has been updated with the
        // 'Title asc' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: saveAsTitle,
        );

        // And verify the order of the playlist audio titles
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets('''Change language and verify impact on sort/filter dropdown
          button default title.''', (WidgetTester tester) async {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
          destinationRootPath: kApplicationPathWindowsTest,
        );

        final SettingsDataService settingsDataService = SettingsDataService(
          sharedPreferences: await SharedPreferences.getInstance(),
        );

        // Load the settings from the json file. This is necessary
        // otherwise the ordered playlist titles will remain empty
        // and the playlist list will not be filled with the
        // playlists available in the download app test dir
        await settingsDataService.loadSettingsFromFile(
            settingsJsonPathFileName:
                "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

        await app.main();
        await tester.pumpAndSettle();

        String defaultEnglishTitle = 'default';

        // Verify that the dropdown buttondefault title
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: defaultEnglishTitle,
        );

        // And verify the order of the playlist audio titles

        List<String>
            audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Change the app language to French

        // Open the appbar right menu
        await tester.tap(find.byKey(const Key('appBarRightPopupMenu')));
        await tester.pumpAndSettle();

        // And tap on 'Select French' to change he language
        await tester.tap(find.text('Select French'));
        await tester.pumpAndSettle();

        String defaultFrenchTitle = 'défaut';

        // Verify that the dropdown buttondefault title
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: defaultFrenchTitle,
        );

        // And verify the order of the playlist audio titles

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Now change the app language to English

        // Open the appbar right menu
        await tester.tap(find.byKey(const Key('appBarRightPopupMenu')));
        await tester.pumpAndSettle();

        // And tap on 'Select French' to change he language
        await tester.tap(find.text('Anglais'));
        await tester.pumpAndSettle();

        // Verify that the dropdown buttondefault title
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: defaultEnglishTitle,
        );

        // And verify the order of the playlist audio titles

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets(
          '''Create and then modify a named and saved title sort/filter parms.
             Then verifying that the corresponding sort/filter dropdown button
             item is applied to the playlist download view list of audio.''',
          (WidgetTester tester) async {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
          destinationRootPath: kApplicationPathWindowsTest,
        );

        final SettingsDataService settingsDataService = SettingsDataService(
          sharedPreferences: await SharedPreferences.getInstance(),
        );

        // Load the settings from the json file. This is necessary
        // otherwise the ordered playlist titles will remain empty
        // and the playlist list will not be filled with the
        // playlists available in the download app test dir
        await settingsDataService.loadSettingsFromFile(
            settingsJsonPathFileName:
                "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

        await app.main();
        await tester.pumpAndSettle();

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

        // Now select the 'Audio title' item in the 'Sort by' dropdown button

        await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Audio title'));
        await tester.pumpAndSettle();

        // Then delete the "Audio download date" descending sort option

        // Find the Text with "Audio downl date" which is located in the
        // selected sort parameters ListView
        Finder textFinder = find.descendant(
          of: find.byKey(const Key('selectedSortingOptionsListView')),
          matching: find.text('Audio downl date'),
        );

        // Then find the ListTile ancestor of the 'Audio downl date' Text
        // widget. The ascending/descending and remove icon buttons are
        // contained in their ListTile ancestor
        Finder listTileFinder = find.ancestor(
          of: textFinder,
          matching: find.byType(ListTile),
        );

        // Now, within that ListTile, find the sort option delete IconButton
        // with key 'removeSortingOptionIconButton'
        Finder iconButtonFinder = find.descendant(
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

        // Now verify the playlist download view state with the 'Title asc'
        // sort/filter parms applied

        // Verify that the dropdown button has been updated with the
        // 'Title asc' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: saveAsTitle,
        );

        // And verify the order of the playlist audio titles

        List<String> audioTitlesSortedByTitleAscending = [
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La résilience insulaire par Fiona Roche",
          "La surpopulation mondiale par Jancovici et Barrau",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          // "Les besoins artificiels par R.Keucheyan"
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
        );

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        final Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        final Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // And find the 'Title asc' sort/filter item
        final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Now open the audio popup menu in order to modify the 'Title asc'
        final Finder dropdownItemEditIconButtonFinder = find.byKey(
            const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
        await tester.tap(dropdownItemEditIconButtonFinder);
        await tester.pumpAndSettle();

        // Convert ascending to descending sort order of 'Audio title'.
        // So, the 'Title asc? sort/filter parms will in fact be descending !!
        await IntegrationTestUtil.invertSortingItemOrder(
          tester: tester,
          sortingItemName: 'Audio title',
        );

        // Now define an audio/video title or description filter word
        final Finder audioTitleSearchSentenceTextFieldFinder =
            find.byKey(const Key('audioTitleSearchSentenceTextField'));

        // Enter a selection word in the TextField. So, only the audio
        // whose title contain Jancovici will be selected.
        await tester.enterText(
          audioTitleSearchSentenceTextFieldFinder,
          'Jancovici',
        );
        await tester.pumpAndSettle();

        // And now click on the add icon button
        await tester.tap(find.byKey(const Key('addSentenceIconButton')));
        await tester.pumpAndSettle();

        // Click on the "Save" button. This closes the sort/filter dialog
        // and updates the sort/filter playlist download view dropdown
        // button with the modified sort/filter parms
        await tester
            .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
        await tester.pumpAndSettle();

        // Verifying and closing the confirm dialog

        await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
          tester: tester,
          confirmDialogTitleOne:
              'WARNING: the sort/filter parameters "$saveAsTitle" were modified. Do you want to update the existing sort/filter parms by clicking on "Confirm", or to save it with a different name or cancel the Save operation, this by clicking on "Cancel" ?',
          confirmDialogMessage:
              "Sort by:\n Present only in initial version:\n   Audio title asc\n Present only in modified version:\n   Audio title desc\nFilter words:\n Present only in modified version:\n   'Jancovici'",
          confirmOrCancelAction: true, // Confirm button is tapped
        );

        // Now verify the playlist download view state with the 'Title asc' -
        // in fact now descending - sort/filter parms now applied

        // Verify that the dropdown button remains with the 'Title asc'
        // sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: saveAsTitle,
        );

        // And verify the ordered and filtered audio titles of the playlist

        audioTitlesSortedByTitleAscending = [
          "La surpopulation mondiale par Jancovici et Barrau",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
        );

        // Now go to audio player view
        Finder appScreenNavigationButton =
            find.byKey(const ValueKey('audioPlayerViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // Then return to playlist download view in order to verify that
        // its state with the 'Title asc' sort/filter parms is still
        // applied and correctly sorts and filter the current playable
        // audio.
        appScreenNavigationButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        // Verify that the dropdown button has been updated with the
        // 'Title asc' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: saveAsTitle,
        );

        // And verify the order of the playlist audio titles
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets(
          '''Bug fixed on creating a named title ascending sort/filter parms and
             saving it. Then verifying that a Sort/filter dropdown button item
             has been created and is applied to the playlist download view list
             of audio.''', (WidgetTester tester) async {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_filter_title_bug_test",
          destinationRootPath: kApplicationPathWindowsTest,
        );

        final SettingsDataService settingsDataService = SettingsDataService(
          sharedPreferences: await SharedPreferences.getInstance(),
        );

        // Load the settings from the json file. This is necessary
        // otherwise the ordered playlist titles will remain empty
        // and the playlist list will not be filled with the
        // playlists available in the download app test dir
        await settingsDataService.loadSettingsFromFile(
            settingsJsonPathFileName:
                "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

        await app.main();
        await tester.pumpAndSettle();

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

        // Now select the 'Audio title' item in the 'Sort by' dropdown button

        await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
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

        // Now verify the playlist download view state with the 'Title asc'
        // sort/filter parms applied

        // Verify that the dropdown button has been updated with the
        // 'Title asc' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: saveAsTitle,
        );

        // And verify the order of the playlist audio titles

        List<String> audioTitlesSortedByTitleAscending = [
          "E.M.I _ NDE TERRIFIANTE #1 - LA GRANDE FAUCHEUSE",
          "EMI  - Un athée voyage au paradis et découvre la vérité - Expérience de mort imminente",
          "EMI -  Elle a vu l’avenir La fin des Jeux olympiques de 2024 à Paris !",
          "Expérience de mort imminente (EMI)  - je reviens de l'au-delà (1_2 ) _ RTS"
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
    });
    group('''Saving and deleting defined named sort/filter parms in sort/filter
             dialog in relation with Sort/filter dropdown button test''', () {
      testWidgets(
          '''Select a sort/filter named parms in the dropdown button list and
             then verify its application. Then defined an identical SF named
             parms and check its selection and application. Then define a new
             SF named parms and check its selection and application.''',
          (WidgetTester tester) async {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_three_playlists_test",
          destinationRootPath: kApplicationPathWindowsTest,
        );

        final SettingsDataService settingsDataService = SettingsDataService(
          sharedPreferences: await SharedPreferences.getInstance(),
        );

        // Load the settings from the json file. This is necessary
        // otherwise the ordered playlist titles will remain empty
        // and the playlist list will not be filled with the
        // playlists available in the download app test dir
        await settingsDataService.loadSettingsFromFile(
            settingsJsonPathFileName:
                "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

        await app.main();
        await tester.pumpAndSettle();

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        final Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        final Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // And find the 'desc listened' sort/filter item
        final Finder titleAscDropDownTextFinder = find.text('desc listened');
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // And verify the order of the playlist audio titles

        List<String> audioTitlesSortedByDateTimeListenedDescending = [
          "Les besoins artificiels par R.Keucheyan",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "La surpopulation mondiale par Jancovici et Barrau",
          // "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedByDateTimeListenedDescending,
        );

        String saveAsTitle = 'Desc listened';

        // Now open the audio popup menu
        await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
        await tester.pumpAndSettle();

        // Find the sort/filter audio menu item and tap on it to
        // open the audio sort filter dialog
        await tester.tap(
            find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
        await tester.pumpAndSettle();

        // Type "Desc listened" in the 'Save as' TextField

        await tester.enterText(
            find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
            saveAsTitle);
        await tester.pumpAndSettle();

        // Now select the 'Last listened date/time' item in the 'Sort by'
        // dropdown button

        await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Last listened date/time'));
        await tester.pumpAndSettle();

        // Then delete the "Audio download date" descending sort option

        // Find the Text with "Audio downl date" which is located in the
        // selected sort parameters ListView
        Finder textFinder = find.descendant(
          of: find.byKey(const Key('selectedSortingOptionsListView')),
          matching: find.text('Audio downl date'),
        );

        // Then find the ListTile ancestor of the 'Audio downl date' Text
        // widget. The ascending/descending and remove icon buttons are
        // contained in their ListTile ancestor
        Finder listTileFinder = find.ancestor(
          of: textFinder,
          matching: find.byType(ListTile),
        );

        // Now, within that ListTile, find the sort option delete IconButton
        // with key 'removeSortingOptionIconButton'
        Finder iconButtonFinder = find.descendant(
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

        // Now verify the playlist download view state with the 'Desc listened'
        // sort/filter parms applied

        // Verify that the dropdown button has been updated with the
        // 'Desc listened' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: saveAsTitle,
        );

        // And verify the order of the playlist audio titles

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedByDateTimeListenedDescending,
        );

        // Creating a Asc listened sort/filter parms

        // open the audio popup menu
        await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
        await tester.pumpAndSettle();

        // Find the sort/filter audio menu item and tap on it to
        // open the audio sort filter dialog
        await tester.tap(
            find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
        await tester.pumpAndSettle();

        // Type "Asc listened" in the 'Save as' TextField

        saveAsTitle = 'Asc listened';

        await tester.enterText(
            find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
            saveAsTitle);
        await tester.pumpAndSettle();

        // Now select the 'Last listened date/time' item in the 'Sort by'
        // dropdown button

        await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Last listened date/time'));
        await tester.pumpAndSettle();

        // Find the Text with 'Last listened date/time' which is located
        // in the selected sort parameters ListView
        textFinder = find.descendant(
          of: find.byKey(const Key('selectedSortingOptionsListView')),
          matching: find.text('Last listened date/time'),
        );

        // Convert descending to ascending sort order of 'Last listened date/time'.
        await IntegrationTestUtil.invertSortingItemOrder(
          tester: tester,
          sortingItemName: 'Last listened date/time',
        );

        // Then delete the "Audio download date" descending sort option

        // Find the Text with "Audio downl date" which is located in the
        // selected sort parameters ListView
        textFinder = find.descendant(
          of: find.byKey(const Key('selectedSortingOptionsListView')),
          matching: find.text('Audio downl date'),
        );

        // Then find the ListTile ancestor of the 'Audio downl date' Text
        // widget. The ascending/descending and remove icon buttons are
        // contained in their ListTile ancestor
        listTileFinder = find.ancestor(
          of: textFinder,
          matching: find.byType(ListTile),
        );

        // Now, within that ListTile, find the sort option delete IconButton
        // with key 'removeSortingOptionIconButton'
        iconButtonFinder = find.descendant(
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

        // Now verify the playlist download view state with the 'Asc listened'
        // sort/filter parms applied

        // Verify that the dropdown button has been updated with the
        // 'Asc listened' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: saveAsTitle,
        );

        // And verify the order of the playlist audio titles

        List<String> audioTitlesSortedByDateTimeListenedAscending = [
          "La surpopulation mondiale par Jancovici et Barrau",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La résilience insulaire par Fiona Roche",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          // "Les besoins artificiels par R.Keucheyan",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedByDateTimeListenedAscending,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets(
          '''Verifying delete sort/filter bug was fixed. Click on 'Sort/filter
             audio' menu item of Audio popup menu to open sort filter audio
             dialog. Then creating a named last listened date time descending
             sort/filter parms and saving it. Then verifying that a Sort/filter
             dropdown button item has been created and is applied to the
             playlist download view list of audio. Then creating a named last
             listened date time ascending sort/filter parms and saving it. Then
             verifying its application. Finally, deleting the named last
             listened date time ascending sort/filter parms and verify that now
             the default sort/filter parms is applied to the current playlist.''',
          (WidgetTester tester) async {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
          destinationRootPath: kApplicationPathWindowsTest,
        );

        final SettingsDataService settingsDataService = SettingsDataService(
          sharedPreferences: await SharedPreferences.getInstance(),
        );

        // Load the settings from the json file. This is necessary
        // otherwise the ordered playlist titles will remain empty
        // and the playlist list will not be filled with the
        // playlists available in the download app test dir
        await settingsDataService.loadSettingsFromFile(
            settingsJsonPathFileName:
                "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

        await app.main();
        await tester.pumpAndSettle();

        // Now open the audio popup menu
        await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
        await tester.pumpAndSettle();

        // Find the sort/filter audio menu item and tap on it to
        // open the audio sort filter dialog
        await tester.tap(
            find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
        await tester.pumpAndSettle();

        // Type "Desc listened" in the 'Save as' TextField

        String saveAsTitle = 'Desc listened';

        await tester.enterText(
            find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
            saveAsTitle);
        await tester.pumpAndSettle();

        // Now select the 'Last listened date/time' item in the 'Sort by'
        // dropdown button

        await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Last listened date/time'));
        await tester.pumpAndSettle();

        // Then delete the "Audio download date" descending sort option

        // Find the Text with "Audio downl date" which is located in the
        // selected sort parameters ListView
        Finder textFinder = find.descendant(
          of: find.byKey(const Key('selectedSortingOptionsListView')),
          matching: find.text('Audio downl date'),
        );

        // Then find the ListTile ancestor of the 'Audio downl date' Text
        // widget. The ascending/descending and remove icon buttons are
        // contained in their ListTile ancestor
        Finder listTileFinder = find.ancestor(
          of: textFinder,
          matching: find.byType(ListTile),
        );

        // Now, within that ListTile, find the sort option delete IconButton
        // with key 'removeSortingOptionIconButton'
        Finder iconButtonFinder = find.descendant(
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

        // Now verify the playlist download view state with the 'Desc listened'
        // sort/filter parms applied

        // Verify that the dropdown button has been updated with the
        // 'Desc listened' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: saveAsTitle,
        );

        // And verify the order of the playlist audio titles

        List<String> audioTitlesSortedByTitleAscending = [
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Les besoins artificiels par R.Keucheyan",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "La surpopulation mondiale par Jancovici et Barrau",
          // "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
        );

        // Creating a Asc listened sort/filter parms

        // open the audio popup menu
        await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
        await tester.pumpAndSettle();

        // Find the sort/filter audio menu item and tap on it to
        // open the audio sort filter dialog
        await tester.tap(
            find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
        await tester.pumpAndSettle();

        // Type "Asc listened" in the 'Save as' TextField

        saveAsTitle = 'Asc listened';

        await tester.enterText(
            find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
            saveAsTitle);
        await tester.pumpAndSettle();

        // Now select the 'Last listened date/time' item in the 'Sort by'
        // dropdown button

        await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Last listened date/time'));
        await tester.pumpAndSettle();

        // Convert descending to ascending sort order of 'Last listened date/time'.
        await IntegrationTestUtil.invertSortingItemOrder(
          tester: tester,
          sortingItemName: 'Last listened date/time',
        );

        // Then delete the "Audio download date" descending sort option

        // Find the Text with "Audio downl date" which is located in the
        // selected sort parameters ListView
        textFinder = find.descendant(
          of: find.byKey(const Key('selectedSortingOptionsListView')),
          matching: find.text('Audio downl date'),
        );

        // Then find the ListTile ancestor of the 'Audio downl date' Text
        // widget. The ascending/descending and remove icon buttons are
        // contained in their ListTile ancestor
        listTileFinder = find.ancestor(
          of: textFinder,
          matching: find.byType(ListTile),
        );

        // Now, within that ListTile, find the sort option delete IconButton
        // with key 'removeSortingOptionIconButton'
        iconButtonFinder = find.descendant(
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

        // Now verify the playlist download view state with the 'Asc listened'
        // sort/filter parms applied

        // Verify that the dropdown button has been updated with the
        // 'Asc listened' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: saveAsTitle,
        );

        // And verify the order of the playlist audio titles

        audioTitlesSortedByTitleAscending = [
          "La surpopulation mondiale par Jancovici et Barrau",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "La résilience insulaire par Fiona Roche",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "Les besoins artificiels par R.Keucheyan",
          // "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
        );

        // Now delete the 'Asc listened' sort/filter parms

        // Tap on the current dropdown button item to open the dropdown
        // button items list

        final Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        final Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // And find the 'Asc listened' sort/filter item
        final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Now open the audio popup menu in order to delete the
        // 'Asc listened' sf parms
        final Finder dropdownItemEditIconButtonFinder = find.byKey(
            const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
        await tester.tap(dropdownItemEditIconButtonFinder);
        await tester.pumpAndSettle();

        // Click on the "Delete" button. This closes the sort/filter dialog
        // and sets the default sort/filter parms in the playlist download
        // view dropdown button.
        await tester.tap(find.byKey(const Key('deleteSortFilterTextButton')));
        await tester.pumpAndSettle();

        // Now verify the playlist download view state with the 'default'
        // sort/filter parms applied

        // Verify that the dropdown button has been updated with the
        // 'default' sort/filter parms selected
        const String defaultTitle = 'default';
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: defaultTitle,
        );

        // And verify the order of the playlist audio titles

        List<String>
            audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
    });
    group('''Applying unnamed sort/filter parms, i.e defined SF parms which are
             not named, and so are applied.''', () {
      group(
          '''In english applying defined unnamed sort/filter parms in sort/filter
           dialog in relation with Sort/filter dropdown button test''', () {
        testWidgets(
            '''Click on 'Sort/filter audio' menu item of Audio popup menu to
             open sort filter audio dialog. Then creating an ascending unamed
             sort/filter parms and apply it. Then verifying that a Sort/filter
             dropdown button item has been created with the title 'applied'
             and is applied to the playlist download view list of audio. Then,
             going to the audio player view and click on the current audio title
             in order to open the audio playable list dialog.Then go back to the
             playlist download view and verifying that the previously active and
             newly created sort/filter parms is displayed in dropdown item button
             and applied to the audio. Then, select 'default' dropdown item and
             go to audio player view and back to playlist download view. Finally,
             select 'applied' dropdown item and go to audio player view and back
             to playlist download view.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Now select the 'Audio title' item in the 'Sort by' dropdown button

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

          // Now verify the playlist download view state with the 'applied'
          // sort/filter parms now applied

          const String appliedEnglishTitle = 'applied';

          // Verify that the dropdown button has been updated with the
          // 'applied' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            // ERROR
            tester: tester,
            dropdownButtonSelectedTitle: appliedEnglishTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesSortedByTitleAscending = [
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La résilience insulaire par Fiona Roche",
            "La surpopulation mondiale par Jancovici et Barrau",
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
            // "Les besoins artificiels par R.Keucheyan"
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Now go to audio player view
          Finder appScreenNavigationButton =
              find.byKey(const ValueKey('audioPlayerViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
            tester: tester,
          );

          // Now we open the AudioPlayableListDialog
          // and verify the the displayed audio titles

          await tester
              .tap(find.text("La résilience insulaire par Fiona Roche\n13:35"));
          await tester.pumpAndSettle();

          // Tap on the Close button to close the AudioPlayableListDialog
          await tester.tap(find.byKey(const Key('closeTextButton')));
          await tester.pumpAndSettle();

          // Then return to playlist download view in order to verify that
          // its state with the 'applied' sort/filter parms is still
          // applied and correctly sorts the current playable audio.
          appScreenNavigationButton =
              find.byKey(const ValueKey('playlistDownloadViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Verify that the dropdown button has been updated with the
          // 'applied' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedEnglishTitle,
          );

          // And verify the order of the playlist audio titles
          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Now, selecting 'default' dropdown button item to apply the
          // default sort/filter parms
          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          // Tap on the current dropdown button item to open the dropdown
          // button items list
          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And select the default sort/filter item
          String defaultTitle = 'default';
          final Finder defaultDropDownTextFinder = find.text(defaultTitle);
          await tester.tap(defaultDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'default'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'default' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: defaultTitle,
          );

          // And verify the order of the playlist audio titles

          List<String>
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La surpopulation mondiale par Jancovici et Barrau",
            "La résilience insulaire par Fiona Roche",
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
            "Les besoins artificiels par R.Keucheyan",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Now go to audio player view
          appScreenNavigationButton =
              find.byKey(const ValueKey('audioPlayerViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Then return to playlist download view in order to verify that
          // its state with the 'default' sort/filter parms is still
          // applied and correctly sorts the current playable audio.
          appScreenNavigationButton =
              find.byKey(const ValueKey('playlistDownloadViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Verify that the dropdown button has been updated with the
          // 'default' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: defaultTitle,
          );

          // And verify the order of the playlist audio titles
          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Finally tap on the current dropdown button item to open the dropdown
          // button items list
          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And select the 'applied' sort/filter item
          final Finder titleAscDropDownTextFinder =
              find.text(appliedEnglishTitle);
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'applied'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'applied' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedEnglishTitle,
          );

          // And verify the order of the playlist audio titles

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Now go to audio player view
          appScreenNavigationButton =
              find.byKey(const ValueKey('audioPlayerViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Then return to playlist download view in order to verify that
          // its state with the 'default' sort/filter parms is still
          // applied and correctly sorts the current playable audio.
          appScreenNavigationButton =
              find.byKey(const ValueKey('playlistDownloadViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Verify that the dropdown button has been updated with the
          // 'default' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedEnglishTitle,
          );

          // And verify the order of the playlist audio titles
          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Click on 'Sort/filter audio' menu item of Audio popup menu to
             open sort filter audio dialog. Then creating an ascending unamed
             sort/filter parms and apply it. Then verifying that a Sort/filter
             dropdown button item has been created with the title 'applied'
             and is applied to the playlist download view list of audio. Then
             recreate an 'applied' sort/filter parms and verify that the new
             applied sort/filter parms is displayed in the dropdown item button
             and applied to the audio. Then, going to the audio player view and
             then going back to the playlist download view and verifying that the
             newly created 'applied' sort/filter parms is displayed in the
             dropdown item button and applied to the audio.''',
            (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Now select the 'Audio title' item in the 'Sort by' dropdown button

          await tester
              .tap(find.byKey(const Key('sortingOptionDropdownButton')));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Audio title'));
          await tester.pumpAndSettle();

          // Then delete the "Audio download date" descending sort option

          // Find the Text with "Audio downl date" which is located in the
          // selected sort parameters ListView
          Finder textFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Audio downl date'),
          );

          // Then find the ListTile ancestor of the 'Audio downl date' Text
          // widget. The ascending/descending and remove icon buttons are
          // contained in their ListTile ancestor
          Finder listTileFinder = find.ancestor(
            of: textFinder,
            matching: find.byType(ListTile),
          );

          // Now, within that ListTile, find the sort option delete IconButton
          // with key 'removeSortingOptionIconButton'
          Finder iconButtonFinder = find.descendant(
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

          // Now verify the playlist download view state with the 'applied'
          // sort/filter parms now applied

          const String appliedEnglishTitle = 'applied';

          // Verify that the dropdown button has been updated with the
          // 'applied' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedEnglishTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesSortedByTitleAscending = [
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La résilience insulaire par Fiona Roche",
            "La surpopulation mondiale par Jancovici et Barrau",
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
            // "Les besoins artificiels par R.Keucheyan"
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Now reopen the audio popup menu in order to apply a new unamed
          // sort/filter parms
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Now select the 'Audio title' item in the 'Sort by' dropdown button

          await tester
              .tap(find.byKey(const Key('sortingOptionDropdownButton')));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Audio title'));
          await tester.pumpAndSettle();

          // Convert ascending to descending sort order of 'Audio title'.
          // So, the 'Title asc? sort/filter parms will in fact be descending !!
          await IntegrationTestUtil.invertSortingItemOrder(
            tester: tester,
            sortingItemName: 'Audio title',
          );

          // Then delete the "Audio download date" descending sort option

          // Find the Text with "Audio downl date" which is located in the
          // selected sort parameters ListView
          textFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Audio downl date'),
          );

          // Then find the ListTile ancestor of the 'Audio downl date' Text
          // widget. The ascending/descending and remove icon buttons are
          // contained in their ListTile ancestor
          listTileFinder = find.ancestor(
            of: textFinder,
            matching: find.byType(ListTile),
          );

          // Now, within that ListTile, find the sort option delete IconButton
          // with key 'removeSortingOptionIconButton'
          iconButtonFinder = find.descendant(
            of: listTileFinder,
            matching: find.byKey(const Key('removeSortingOptionIconButton')),
          );

          // Tap on the delete icon button to delete the 'Audio downl date'
          // descending sort option
          await tester.tap(iconButtonFinder);
          await tester.pumpAndSettle();

          // Now define an audio/video title or description filter word
          final Finder audioTitleSearchSentenceTextFieldFinder =
              find.byKey(const Key('audioTitleSearchSentenceTextField'));

          // Enter a selection word in the TextField
          await tester.enterText(
            audioTitleSearchSentenceTextFieldFinder,
            'Jancovici',
          );
          await tester.pumpAndSettle();

          // And now click on the add icon button
          await tester.tap(find.byKey(const Key('addSentenceIconButton')));
          await tester.pumpAndSettle();

          // Click on the "Apply" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('applySortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'applied'
          // sort/filter parms now applied

          // Verify that the dropdown button has been updated with the
          // 'applied' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedEnglishTitle,
          );

          // And verify the order of the playlist audio titles

          audioTitlesSortedByTitleAscending = [
            "La surpopulation mondiale par Jancovici et Barrau",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Now go to audio player view
          Finder appScreenNavigationButton =
              find.byKey(const ValueKey('audioPlayerViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Then return to playlist download view in order to verify that
          // its state with the 'applied' sort/filter parms is still
          // applied and correctly sorts the current playable audio.
          appScreenNavigationButton =
              find.byKey(const ValueKey('playlistDownloadViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Verify that the dropdown button has been updated with the
          // 'applied' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedEnglishTitle,
          );

          // And verify the order of the playlist audio titles
          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Now, selecting 'default' dropdown button item to apply the
          // default sort/filter parms
          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          // Tap on the current dropdown button item to open the dropdown
          // button items list
          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And select the default sort/filter item
          String defaultTitle = 'default';
          final Finder defaultDropDownTextFinder = find.text(defaultTitle);
          await tester.tap(defaultDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'default'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'default' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: defaultTitle,
          );

          // And verify the order of the playlist audio titles

          List<String>
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La surpopulation mondiale par Jancovici et Barrau",
            "La résilience insulaire par Fiona Roche",
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
            "Les besoins artificiels par R.Keucheyan",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Now go to audio player view
          appScreenNavigationButton =
              find.byKey(const ValueKey('audioPlayerViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Then return to playlist download view in order to verify that
          // its state with the 'default' sort/filter parms is still
          // applied and correctly sorts the current playable audio.
          appScreenNavigationButton =
              find.byKey(const ValueKey('playlistDownloadViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Verify that the dropdown button has been updated with the
          // 'default' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: defaultTitle,
          );

          // And verify the order of the playlist audio titles
          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Finally tap on the current dropdown button item to open the dropdown
          // button items list
          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And select the 'applied' sort/filter item
          final Finder titleAscDropDownTextFinder =
              find.text(appliedEnglishTitle);
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'default'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'default' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedEnglishTitle,
          );

          // And verify the order of the playlist audio titles

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Now go to audio player view
          appScreenNavigationButton =
              find.byKey(const ValueKey('audioPlayerViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Then return to playlist download view in order to verify that
          // its state with the 'default' sort/filter parms is still
          // applied and correctly sorts the current playable audio.
          appScreenNavigationButton =
              find.byKey(const ValueKey('playlistDownloadViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Verify that the dropdown button has been updated with the
          // 'default' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedEnglishTitle,
          );

          // And verify the order of the playlist audio titles
          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Click on 'default' dropdown button item edit icon button to
             open sort filter audio dialog. Then creating a ascending unamed
             sort/filter parms and applying it. Then verifying that a Sort/filter
             dropdown button item has been created with the title 'applied' and
             is applied to the playlist download view list of audio. Then going
             to the audio player view and then going back to the playlist
             download view and verifying that the previously active and newly
             created sort/filter parms is displayed in the dropdown item button
             and applied to the audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          // Tap twice on the dropdown button 'default' item so that its edit
          // icon button is displayed
          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();
          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          Finder dropdownItemEditIconButtonFinder = find.byKey(
            const Key('sort_filter_parms_dropdown_item_edit_icon_button'),
          );

          // Tap on the edit icon button to open the sort/filter dialog
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Now select the 'Audio title' item in the 'Sort by' dropdown button

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
              .tap(find.byKey(const Key('applySortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Title asc'
          // sort/filter parms applied

          const String appliedEnglishTitle = 'applied';

          // Verify that the dropdown button has been updated with the
          // 'Title asc' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedEnglishTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesSortedByTitleAscending = [
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La résilience insulaire par Fiona Roche",
            "La surpopulation mondiale par Jancovici et Barrau",
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
            // "Les besoins artificiels par R.Keucheyan"
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Now go to audio player view
          Finder appScreenNavigationButton =
              find.byKey(const ValueKey('audioPlayerViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Then return to playlist download view in order to verify that
          // its state with the 'Title asc' sort/filter parms is still
          // applied and correctly sorts the current playable audio.
          appScreenNavigationButton =
              find.byKey(const ValueKey('playlistDownloadViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Verify that the dropdown button has been updated with the
          // 'Title asc' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedEnglishTitle,
          );

          // And verify the order of the playlist audio titles
          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets('''Change language and verify impact on sort/filter dropdown
                       button default title.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          String defaultEnglishTitle = 'default';

          // Verify that the dropdown buttondefault title
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: defaultEnglishTitle,
          );

          // And verify the order of the playlist audio titles

          List<String>
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La surpopulation mondiale par Jancovici et Barrau",
            "La résilience insulaire par Fiona Roche",
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
            "Les besoins artificiels par R.Keucheyan",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Change the app language to French

          // Open the appbar right menu
          await tester.tap(find.byKey(const Key('appBarRightPopupMenu')));
          await tester.pumpAndSettle();

          // And tap on 'Select French' to change he language
          await tester.tap(find.text('Select French'));
          await tester.pumpAndSettle();

          String defaultFrenchTitle = 'défaut';

          // Verify that the dropdown buttondefault title
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: defaultFrenchTitle,
          );

          // And verify the order of the playlist audio titles

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Now change the app language to English

          // Open the appbar right menu
          await tester.tap(find.byKey(const Key('appBarRightPopupMenu')));
          await tester.pumpAndSettle();

          // And tap on 'Select French' to change he language
          await tester.tap(find.text('Anglais'));
          await tester.pumpAndSettle();

          // Verify that the dropdown buttondefault title
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: defaultEnglishTitle,
          );

          // And verify the order of the playlist audio titles

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Apply and finally delete an unamed ascending sort/filter parms after
               having selected it in a second playlist.''',
            (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Now select the 'Audio title' item in the 'Sort by' dropdown button

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

          // Now select the local playlist in order to apply the created
          // sort/filter parms to it

          // Tap on playlist button to expand the list of playlists
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Select the 'local' playlist

          await IntegrationTestUtil.selectPlaylist(
            tester: tester,
            playlistToSelectTitle: 'local',
          );

          // Now select the 'applied' sort/filter parms in the dropdown button

          // Tap on audio player view playlist button to contract the
          // list of playlists
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          // Tap on the current dropdown button item to open the dropdown
          // button items list
          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And select the 'applied' sort/filter item

          const String appliedEnglishTitle = 'applied';

          final Finder titleAscDropDownTextFinder =
              find.text(appliedEnglishTitle);
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'applied'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'applied' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedEnglishTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesSortedByTitleAscending = [
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La résilience insulaire par Fiona Roche",
            "morning _ cinematic video",
            "Really short video",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Verify that the dropdown button has been updated with the
          // 'applied' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedEnglishTitle,
          );

          // Then reselect the 'S8 audio' playlist

          // Tap on playlist button to expand the
          // list of playlists
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Select the 'local' playlist

          await IntegrationTestUtil.selectPlaylist(
            tester: tester,
            playlistToSelectTitle: 'S8 audio',
          );

          // Tap on audio player view playlist button to contract the
          // list of playlists
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Now verify that the 'applied' sort/filter parms is applied
          // to the 'S8 audio' playlist

          audioTitlesSortedByTitleAscending = [
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La résilience insulaire par Fiona Roche",
            "La surpopulation mondiale par Jancovici et Barrau",
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
            // "Les besoins artificiels par R.Keucheyan"
          ];

          // And verify the order of the playlist audio titles
          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Now delete the 'applied' sort/filter parms

          // Tap on the current dropdown button item to open the dropdown
          // button items list

          dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to delete the
          // 'applied' sf parms
          final Finder dropdownItemEditIconButtonFinder = find
              .byKey(
                  const Key('sort_filter_parms_dropdown_item_edit_icon_button'))
              .at(0);
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Click on the "Delete" button. This closes the sort/filter dialog
          // and sets the default sort/filter parms in the playlist download
          // view dropdown button.
          await tester.tap(find.byKey(const Key('deleteSortFilterTextButton')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'default'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'default' sort/filter parms selected
          const String defaultTitle = 'default';
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: defaultTitle,
          );

          // And verify the order of the playlist audio titles

          List<String>
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La surpopulation mondiale par Jancovici et Barrau",
            "La résilience insulaire par Fiona Roche",
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
            "Les besoins artificiels par R.Keucheyan",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Now return to local playlist and verify that the 'default'
          // sort/filter parms is applied

          // Tap on playlist button to expand the
          // list of playlists
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Tap on playlist button to expand the
          // list of playlists
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Select the 'local' playlist

          await IntegrationTestUtil.selectPlaylist(
            tester: tester,
            playlistToSelectTitle: 'local',
          );

          // Tap on audio player view playlist button to contract the
          // list of playlists
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Verify that the dropdown button has been updated with the
          // 'default' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: defaultTitle,
          );

          // And verify the order of the playlist audio titles

          audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
            "morning _ cinematic video",
            "Really short video",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La résilience insulaire par Fiona Roche",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        group('''Bug fix tests''', () {
          testWidgets(
              '''In playlist expanded situation, define an unamed SF parm with a filter
               string value and apply it. Several audio's are selected and the audio list is
               not empty. Then click on the "Playlist" button to shrink the list of playlists.
               This caused a bug.''', (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
              destinationRootPath: kApplicationPathWindowsTest,
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
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            // Tap the 'Toggle List' button to show the list of playlist's.
            await tester.tap(find.byKey(const Key('playlist_toggle_button')));
            await tester.pumpAndSettle();

            // Now open the audio popup menu
            await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
            await tester.pumpAndSettle();

            // Find the sort/filter audio menu item and tap on it to
            // open the audio sort filter dialog
            await tester.tap(find
                .byKey(const Key('define_sort_and_filter_audio_menu_item')));
            await tester.pumpAndSettle();

            // Type "janco" in the audio title search sentence TextField
            await tester.enterText(
                find.byKey(const Key('audioTitleSearchSentenceTextField')),
                'janco');
            await tester.pumpAndSettle();

            // Click on the "+" icon button
            await tester.tap(find.byKey(const Key('addSentenceIconButton')));
            await tester.pumpAndSettle();

            // Click on the "Apply" button. This closes the sort/filter dialog
            // and updates the sort/filter playlist download view dropdown
            // button with the newly created sort/filter parms
            await tester
                .tap(find.byKey(const Key('applySortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Tap the 'Toggle List' button to hide the list of playlist's.
            await tester.tap(find.byKey(const Key('playlist_toggle_button')));
            await tester.pumpAndSettle();

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
          testWidgets(
              '''In playlist expanded situation, define an unamed SF parm with a filter
               string value and apply it. No audio's are selected and the audio list is
               empty. Then click on the "Playlist" button to shrink the list of playlists.
               This caused a bug.''', (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
              destinationRootPath: kApplicationPathWindowsTest,
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
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            // Tap the 'Toggle List' button to show the list of playlist's.
            await tester.tap(find.byKey(const Key('playlist_toggle_button')));
            await tester.pumpAndSettle();

            // Now open the audio popup menu
            await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
            await tester.pumpAndSettle();

            // Find the sort/filter audio menu item and tap on it to
            // open the audio sort filter dialog
            await tester.tap(find
                .byKey(const Key('define_sort_and_filter_audio_menu_item')));
            await tester.pumpAndSettle();

            // Type "not exist, really not" in the audio title search sentence TextField
            await tester.enterText(
                find.byKey(const Key('audioTitleSearchSentenceTextField')),
                'not exist, really not');
            await tester.pumpAndSettle();

            // Click on the "+" icon button
            await tester.tap(find.byKey(const Key('addSentenceIconButton')));
            await tester.pumpAndSettle();

            // Click on the "Apply" button. This closes the sort/filter dialog
            // and updates the sort/filter playlist download view dropdown
            // button with the newly created sort/filter parms
            await tester
                .tap(find.byKey(const Key('applySortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Tap the 'Toggle List' button to hide the list of playlist's.
            await tester.tap(find.byKey(const Key('playlist_toggle_button')));
            await tester.pumpAndSettle();

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
          testWidgets(
              '''In playlist expanded situation, define a named SF parm with a filter
               string value and apply it. Several audio's are selected and the audio list is
               not empty. Then click on the "Playlist" button to shrink the list of playlists.
               This caused a bug.''', (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
              destinationRootPath: kApplicationPathWindowsTest,
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
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            // Tap the 'Toggle List' button to show the list of playlist's.
            await tester.tap(find.byKey(const Key('playlist_toggle_button')));
            await tester.pumpAndSettle();

            // Now open the audio popup menu
            await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
            await tester.pumpAndSettle();

            // Find the sort/filter audio menu item and tap on it to
            // open the audio sort filter dialog
            await tester.tap(find
                .byKey(const Key('define_sort_and_filter_audio_menu_item')));
            await tester.pumpAndSettle();

            // Type "janco SF" in the SF name TextField
            await tester.enterText(
                find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
                'janco SF');
            await tester.pumpAndSettle();

            // Type "janco" in the audio title search sentence TextField
            await tester.enterText(
                find.byKey(const Key('audioTitleSearchSentenceTextField')),
                'janco');
            await tester.pumpAndSettle();

            // Click on the "+" icon button
            await tester.tap(find.byKey(const Key('addSentenceIconButton')));
            await tester.pumpAndSettle();

            // Click on the "Save" button. This closes the sort/filter dialog
            // and updates the sort/filter playlist download view dropdown
            // button with the newly created sort/filter parms
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Tap the 'Toggle List' button to hide the list of playlist's.
            await tester.tap(find.byKey(const Key('playlist_toggle_button')));
            await tester.pumpAndSettle();

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
          testWidgets(
              '''In playlist expanded situation, define a named SF parm with a filter
               string value and apply it. No audio's are selected and the audio list is
               empty. Then click on the "Playlist" button to shrink the list of playlists.
               This caused a bug.''', (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
              destinationRootPath: kApplicationPathWindowsTest,
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
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            // Tap the 'Toggle List' button to show the list of playlist's.
            await tester.tap(find.byKey(const Key('playlist_toggle_button')));
            await tester.pumpAndSettle();

            // Now open the audio popup menu
            await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
            await tester.pumpAndSettle();

            // Find the sort/filter audio menu item and tap on it to
            // open the audio sort filter dialog
            await tester.tap(find
                .byKey(const Key('define_sort_and_filter_audio_menu_item')));
            await tester.pumpAndSettle();

            // Type "Not exist, really not SF" in the SF name TextField
            await tester.enterText(
                find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
                'Not exist, really not SF');
            await tester.pumpAndSettle();

            // Type "not exist, really not" in the audio title search sentence TextField
            await tester.enterText(
                find.byKey(const Key('audioTitleSearchSentenceTextField')),
                'not exist, really not');
            await tester.pumpAndSettle();

            // Click on the "+" icon button
            await tester.tap(find.byKey(const Key('addSentenceIconButton')));
            await tester.pumpAndSettle();

            // Click on the "Save" button. This closes the sort/filter dialog
            // and updates the sort/filter playlist download view dropdown
            // button with the newly created sort/filter parms
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Tap the 'Toggle List' button to hide the list of playlist's.
            await tester.tap(find.byKey(const Key('playlist_toggle_button')));
            await tester.pumpAndSettle();

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
          testWidgets(
              '''In audio player view, define an unamed SF parm with a filter string value and
               apply it. Verify the selected audio's in the playable audio list dialog. then
               go to the playlist download view whosevplaylist list is expanded and thrink the
               playlist list. Then select the "applied" SF parms and verify the selected audio's''',
              (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}restore_Android_zip_on_Windows_test",
              destinationRootPath: kApplicationPathWindowsTest,
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
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            // Type on the audio player view icon button to go to the audio player view
            await tester
                .tap(find.byKey(const Key('audioPlayerViewIconButton')));
            await tester.pumpAndSettle();

            // Now open the audio popup menu
            await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
            await tester.pumpAndSettle();

            // Find the sort/filter audio menu item and tap on it to
            // open the audio sort filter dialog
            await tester.tap(find
                .byKey(const Key('define_sort_and_filter_audio_menu_item')));
            await tester.pumpAndSettle();

            // Type "musk" in the audio title search sentence TextField
            await tester.enterText(
                find.byKey(const Key('audioTitleSearchSentenceTextField')),
                'musk');
            await tester.pumpAndSettle();

            // Click on the "+" icon button
            await tester.tap(find.byKey(const Key('addSentenceIconButton')));
            await tester.pumpAndSettle();

            // Click on the "Apply" button. This closes the sort/filter dialog.
            await tester
                .tap(find.byKey(const Key('applySortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Now we open the AudioPlayableListDialog and verify the the
            // displayed audio titles

            await tester.tap(find.text(
                "Cette IA PENSE mieux que NOUS et personne ne veut en parler !\n24:00"));
            await tester.pumpAndSettle();

            List<String>
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms =
                [
              "Interview CHOC d'Elon Musk  - 'L'IA va probablement tous nous tuer'",
            ];

            IntegrationTestUtil.checkAudioTitlesOrderInListBody(
              tester: tester,
              audioTitlesOrderLst:
                  audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
            );

            // Tap on the Close button to close the AudioPlayableListDialog
            await tester.tap(find.byKey(const Key('closeTextButton')));
            await tester.pumpAndSettle();

            // Now return to the playlist download view
            await tester
                .tap(find.byKey(const Key('playlistDownloadViewIconButton')));
            await tester.pumpAndSettle();

            // Tap the 'Toggle List' button to hide the list of playlist's.
            await tester.tap(find.byKey(const Key('playlist_toggle_button')));
            await tester.pumpAndSettle();

            // Now, selecting 'applied' dropdown button item to apply the
            // default sort/filter parms
            final Finder dropDownButtonFinder =
                find.byKey(const Key('sort_filter_parms_dropdown_button'));

            final Finder dropDownButtonTextFinder = find.descendant(
              of: dropDownButtonFinder,
              matching: find.byType(Text),
            );

            // Tap on the current dropdown button item to open the dropdown
            // button items list
            await tester.tap(dropDownButtonTextFinder);
            await tester.pumpAndSettle();

            // And select the applied sort/filter item
            String appliedTitle = 'applied';
            final Finder defaultDropDownTextFinder = find.text(appliedTitle);
            await tester.tap(defaultDropDownTextFinder);
            await tester.pumpAndSettle();

            // Now verify the playlist download view state with the 'applied'
            // sort/filter parms applied

            // Verify that the dropdown button has been updated with the
            // 'applied' sort/filter parms selected
            IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
              tester: tester,
              dropdownButtonSelectedTitle: appliedTitle,
            );

            // And verify the order of the playlist audio titles

            IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
              tester: tester,
              audioOrPlaylistTitlesOrderedLst:
                  audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
            );

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
          testWidgets(
              '''In audio player view, define a named SF parm with a filter string value and
               save it. Verify the selected audio's in the playable audio list dialog. then
               go to the playlist download view whosevplaylist list is expanded and thrink the
               playlist list. Then select the "Musk" SF parms and verify the selected audio's''',
              (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}restore_Android_zip_on_Windows_test",
              destinationRootPath: kApplicationPathWindowsTest,
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
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            // Type on the audio player view icon button to go to the audio player view
            await tester
                .tap(find.byKey(const Key('audioPlayerViewIconButton')));
            await tester.pumpAndSettle();

            // Now open the audio popup menu
            await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
            await tester.pumpAndSettle();

            // Find the sort/filter audio menu item and tap on it to
            // open the audio sort filter dialog
            await tester.tap(find
                .byKey(const Key('define_sort_and_filter_audio_menu_item')));
            await tester.pumpAndSettle();

            // Type "Musk" in the SF name TextField
            await tester.enterText(
                find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
                'Musk');
            await tester.pumpAndSettle();

            // Type "musk" in the audio title search sentence TextField
            await tester.enterText(
                find.byKey(const Key('audioTitleSearchSentenceTextField')),
                'musk');
            await tester.pumpAndSettle();

            // Click on the "+" icon button
            await tester.tap(find.byKey(const Key('addSentenceIconButton')));
            await tester.pumpAndSettle();

            // Click on the "Save" button. This closes the sort/filter dialog
            // and updates the sort/filter playlist download view dropdown
            // button with the newly created sort/filter parms
            await tester
                .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
            await tester.pumpAndSettle();

            // Now we open the AudioPlayableListDialog and verify the the
            // displayed audio titles

            await tester.tap(find.text(
                "Cette IA PENSE mieux que NOUS et personne ne veut en parler !\n24:00"));
            await tester.pumpAndSettle();

            List<String>
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms =
                [
              "Interview CHOC d'Elon Musk  - 'L'IA va probablement tous nous tuer'",
            ];

            IntegrationTestUtil.checkAudioTitlesOrderInListBody(
              tester: tester,
              audioTitlesOrderLst:
                  audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
            );

            // Tap on the Close button to close the AudioPlayableListDialog
            await tester.tap(find.byKey(const Key('closeTextButton')));
            await tester.pumpAndSettle();

            // Now return to the playlist download view
            await tester
                .tap(find.byKey(const Key('playlistDownloadViewIconButton')));
            await tester.pumpAndSettle();

            // Tap the 'Toggle List' button to hide the list of playlist's.
            await tester.tap(find.byKey(const Key('playlist_toggle_button')));
            await tester.pumpAndSettle();

            // Now, selecting 'Musk' dropdown button item to apply the
            // 'musk' sort/filter parms
            final Finder dropDownButtonFinder =
                find.byKey(const Key('sort_filter_parms_dropdown_button'));

            final Finder dropDownButtonTextFinder = find.descendant(
              of: dropDownButtonFinder,
              matching: find.byType(Text),
            );

            // Tap on the current dropdown button item to open the dropdown
            // button items list
            await tester.tap(dropDownButtonTextFinder);
            await tester.pumpAndSettle();

            // And select the Musk sort/filter item
            String muskSfTitle = 'Musk';
            final Finder defaultDropDownTextFinder = find.text(muskSfTitle);
            await tester.tap(defaultDropDownTextFinder);
            await tester.pumpAndSettle();

            // Now verify the playlist download view state with the 'applied'
            // sort/filter parms applied

            // Verify that the dropdown button has been updated with the
            // 'Musk' sort/filter parms selected
            IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
              tester: tester,
              dropdownButtonSelectedTitle: muskSfTitle,
            );

            // And verify the order of the playlist audio titles

            IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
              tester: tester,
              audioOrPlaylistTitlesOrderedLst:
                  audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
            );

            // Purge the test playlist directory so that the created test
            // files are not uploaded to GitHub
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );
          });
        });
        group('Restarting app without saving applied sort/filter parms', () {
          testWidgets(
              '''Click on 'Sort/filter audio' menu item of Audio popup menu to
             open sort filter audio dialog. Then creating a Title ascending
             unamed sort/filter parms and apply it.

             Then restart the application (in the next testWidgets()). Then
             verify that the playlist download view and the audio player view
             audio order is default.''', (WidgetTester tester) async {
            // Purge the test playlist directory if it exists so that the
            // playlist list is empty
            DirUtil.deleteFilesInDirAndSubDirs(
              rootPath: kApplicationPathWindowsTest,
            );

            // Copy the test initial audio data to the app dir
            DirUtil.copyFilesFromDirAndSubDirsToDirectory(
              sourceRootPath:
                  "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
              destinationRootPath: kApplicationPathWindowsTest,
            );

            final SettingsDataService settingsDataService = SettingsDataService(
              sharedPreferences: await SharedPreferences.getInstance(),
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            await app.main();
            await tester.pumpAndSettle();

            // Defining an unamed (applied) sort/filter parms

            // Now open the audio popup menu
            await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
            await tester.pumpAndSettle();

            // Find the sort/filter audio menu item and tap on it to
            // open the audio sort filter dialog
            await tester.tap(find
                .byKey(const Key('define_sort_and_filter_audio_menu_item')));
            await tester.pumpAndSettle();

            // Now select the 'Audio title' item in the 'Sort by' dropdown button

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
          });
          testWidgets(
              '''After restarting the application, verify that the playlist
                 download view and the audio player view audio order is default.''',
              (WidgetTester tester) async {
            final SettingsDataService settingsDataService = SettingsDataService(
              sharedPreferences: await SharedPreferences.getInstance(),
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

            // Restarting the app
            await app.main();
            await tester.pumpAndSettle();

            // The app was restarted. Since the in previous test defined and
            // applied sort filter parms was not saved to the playlist,
            // the default SF parms is applied in the restarted app. Vverify
            // that.

            // Verifying that the dropdown button 'default' sort/filter parms
            // is selected

            IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
              tester: tester,
              dropdownButtonSelectedTitle: 'default',
            );

            // And verify the order of the playlist audio titles

            List<String>
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms =
                [
              "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
              "La surpopulation mondiale par Jancovici et Barrau",
              "La résilience insulaire par Fiona Roche",
              "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
              "Les besoins artificiels par R.Keucheyan",
              "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
              "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            ];

            IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
              tester: tester,
              audioOrPlaylistTitlesOrderedLst:
                  audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
            );

            // Now go to the audio player view
            Finder appScreenNavigationButton =
                find.byKey(const ValueKey('audioPlayerViewIconButton'));
            await tester.tap(appScreenNavigationButton);
            await tester.pumpAndSettle();

            // Verify also the audio playable list dialog title and content
            await _verifyAudioPlayableList(
              tester: tester,
              currentAudioTitle:
                  "La résilience insulaire par Fiona Roche\n13:35",
              sortFilterParmsName: 'default',
              audioTitlesLst:
                  audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
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
          '''In french applying defined unnamed sort/filter parms in sort/filter
           dialog in relation with Sort/filter dropdown button test''', () {
        testWidgets(
            '''Click on 'Sort/filter audio' menu item of Audio popup menu to
             open sort filter audio dialog. Then creating an ascending unamed
             sort/filter parms and apply it. Then verifying that a Sort/filter
             dropdown button item has been created with the title 'appliqué'
             and is applied to the playlist download view list of audio. Then,
             going to the audio player view and then going back to the playlist
             download view and verifying that the previously active and newly
             created sort/filter parms is displayed in the dropdown item button
             and applied to the audio. Then, select 'défaut' dropdown item and
             go to audio player view and back to playlist download view. Finally,
             select 'appliqué' dropdown item and go to audio player view and back
             to playlist download view.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          // First, set the application language to French
          await IntegrationTestUtil.setApplicationLanguage(
            tester: tester,
            language: Language.french,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Now select the 'Audio title' item in the 'Sort by' dropdown button

          await tester
              .tap(find.byKey(const Key('sortingOptionDropdownButton')));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Titre audio'));
          await tester.pumpAndSettle();

          // Then delete the "Audio download date" descending sort option

          // Find the Text with "Audio downl date" which is located in the
          // selected sort parameters ListView
          final Finder textFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Date téléch audio'),
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

          // Now verify the playlist download view state with the 'applied'
          // sort/filter parms now applied

          String appliedFrenchTitle = 'appliqué';

          // Verify that the dropdown button has been updated with the
          // 'applied' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedFrenchTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesSortedByTitleAscending = [
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La résilience insulaire par Fiona Roche",
            "La surpopulation mondiale par Jancovici et Barrau",
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
            // "Les besoins artificiels par R.Keucheyan"
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Now go to audio player view
          Finder appScreenNavigationButton =
              find.byKey(const ValueKey('audioPlayerViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Then return to playlist download view in order to verify that
          // its state with the 'applied' sort/filter parms is still
          // applied and correctly sorts the current playable audio.
          appScreenNavigationButton =
              find.byKey(const ValueKey('playlistDownloadViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Verify that the dropdown button has been updated with the
          // 'appliqué' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedFrenchTitle,
          );

          // And verify the order of the playlist audio titles
          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Now, selecting 'défaut' dropdown button item to apply the
          // default sort/filter parms
          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          // Tap on the current dropdown button item to open the dropdown
          // button items list
          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And select the default sort/filter item
          String defaultFrenchTitle = 'défaut';
          final Finder defaultDropDownTextFinder =
              find.text(defaultFrenchTitle);
          await tester.tap(defaultDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'default'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'default' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: defaultFrenchTitle,
          );

          // And verify the order of the playlist audio titles

          List<String>
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La surpopulation mondiale par Jancovici et Barrau",
            "La résilience insulaire par Fiona Roche",
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
            "Les besoins artificiels par R.Keucheyan",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Now go to audio player view
          appScreenNavigationButton =
              find.byKey(const ValueKey('audioPlayerViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Then return to playlist download view in order to verify that
          // its state with the 'défaut' sort/filter parms is still
          // applied and correctly sorts the current playable audio.
          appScreenNavigationButton =
              find.byKey(const ValueKey('playlistDownloadViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Verify that the dropdown button has been updated with the
          // 'défaut' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: defaultFrenchTitle,
          );

          // And verify the order of the playlist audio titles
          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Finally tap on the current dropdown button item to open the dropdown
          // button items list
          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And select the 'appliqué' sort/filter item
          final Finder titleAscDropDownTextFinder =
              find.text(appliedFrenchTitle);
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'défaut'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'défaut' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedFrenchTitle,
          );

          // And verify the order of the playlist audio titles

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Now go to audio player view
          appScreenNavigationButton =
              find.byKey(const ValueKey('audioPlayerViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Then return to playlist download view in order to verify that
          // its state with the 'défaut' sort/filter parms is still
          // applied and correctly sorts the current playable audio.
          appScreenNavigationButton =
              find.byKey(const ValueKey('playlistDownloadViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Verify that the dropdown button has been updated with the
          // 'défaut' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedFrenchTitle,
          );

          // And verify the order of the playlist audio titles
          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Click on 'Sort/filter audio' menu item of Audio popup menu to
             open sort filter audio dialog. Then creating an ascending unamed
             sort/filter parms and apply it. Then verifying that a Sort/filter
             dropdown button item has been created with the title 'appliqué'
             and is applied to the playlist download view list of audio. Then
             recreate an 'appliqué' sort/filter parms and verify that the new
             applied sort/filter parms is displayed in the dropdown item button
             and applied to the audio. Then, going to the audio player view and
             then going back to the playlist download view and verifying that the
             newly created 'appliqué' sort/filter parms is displayed in the
             dropdown item button and applied to the audio.''',
            (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          // First, set the application language to French
          await IntegrationTestUtil.setApplicationLanguage(
            tester: tester,
            language: Language.french,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Now select the 'Titre audio' item in the 'Sort by' dropdown button

          await tester
              .tap(find.byKey(const Key('sortingOptionDropdownButton')));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Titre audio'));
          await tester.pumpAndSettle();

          // Then delete the "Date téléch audio" descending sort option

          // Find the Text with "Date téléch audio" which is located in the
          // selected sort parameters ListView
          Finder textFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Date téléch audio'),
          );

          // Then find the ListTile ancestor of the 'Date téléch audio' Text
          // widget. The ascending/descending and remove icon buttons are
          // contained in their ListTile ancestor
          Finder listTileFinder = find.ancestor(
            of: textFinder,
            matching: find.byType(ListTile),
          );

          // Now, within that ListTile, find the sort option delete IconButton
          // with key 'removeSortingOptionIconButton'
          Finder iconButtonFinder = find.descendant(
            of: listTileFinder,
            matching: find.byKey(const Key('removeSortingOptionIconButton')),
          );

          // Tap on the delete icon button to delete the 'Date téléch audio'
          // descending sort option
          await tester.tap(iconButtonFinder);
          await tester.pumpAndSettle();

          // Click on the "Appliq" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('applySortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'applied'
          // sort/filter parms now applied

          String appliedFrenchTitle = 'appliqué';

          // Verify that the dropdown button has been updated with the
          // 'applied' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedFrenchTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesSortedByTitleAscending = [
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La résilience insulaire par Fiona Roche",
            "La surpopulation mondiale par Jancovici et Barrau",
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
            // "Les besoins artificiels par R.Keucheyan"
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Now reopen the audio popup menu in order to apply a new unamed
          // sort/filter parms
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Now select the 'Titre audio' item in the 'Sort by' dropdown button

          await tester
              .tap(find.byKey(const Key('sortingOptionDropdownButton')));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Titre audio'));
          await tester.pumpAndSettle();

          // Convert ascending to descending sort order of 'Titre audio'.
          // So, the 'Title asc? sort/filter parms will in fact be descending !!
          await IntegrationTestUtil.invertSortingItemOrder(
            tester: tester,
            sortingItemName: 'Titre audio',
          );

          // Then delete the "Date téléch audio" descending sort option

          // Find the Text with "Date téléch audio" which is located in the
          // selected sort parameters ListView
          textFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Date téléch audio'),
          );

          // Then find the ListTile ancestor of the 'Date téléch audio' Text
          // widget. The ascending/descending and remove icon buttons are
          // contained in their ListTile ancestor
          listTileFinder = find.ancestor(
            of: textFinder,
            matching: find.byType(ListTile),
          );

          // Now, within that ListTile, find the sort option delete IconButton
          // with key 'removeSortingOptionIconButton'
          iconButtonFinder = find.descendant(
            of: listTileFinder,
            matching: find.byKey(const Key('removeSortingOptionIconButton')),
          );

          // Tap on the delete icon button to delete the 'Date téléch audio'
          // descending sort option
          await tester.tap(iconButtonFinder);
          await tester.pumpAndSettle();

          // Now define an audio/video title or description filter word
          final Finder audioTitleSearchSentenceTextFieldFinder =
              find.byKey(const Key('audioTitleSearchSentenceTextField'));

          // Enter a selection word in the TextField
          await tester.enterText(
            audioTitleSearchSentenceTextFieldFinder,
            'Jancovici',
          );
          await tester.pumpAndSettle();

          // And now click on the add icon button
          await tester.tap(find.byKey(const Key('addSentenceIconButton')));
          await tester.pumpAndSettle();

          // Click on the "Appliq" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('applySortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'applied'
          // sort/filter parms now applied

          // Verify that the dropdown button has been updated with the
          // 'appliqué' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedFrenchTitle,
          );

          // And verify the order of the playlist audio titles

          audioTitlesSortedByTitleAscending = [
            "La surpopulation mondiale par Jancovici et Barrau",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Now go to audio player view
          Finder appScreenNavigationButton =
              find.byKey(const ValueKey('audioPlayerViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Then return to playlist download view in order to verify that
          // its state with the 'applied' sort/filter parms is still
          // applied and correctly sorts the current playable audio.
          appScreenNavigationButton =
              find.byKey(const ValueKey('playlistDownloadViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Verify that the dropdown button has been updated with the
          // 'appliqué' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedFrenchTitle,
          );

          // And verify the order of the playlist audio titles
          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Now, selecting 'défaut' dropdown button item to apply the
          // défaut sort/filter parms
          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          // Tap on the current dropdown button item to open the dropdown
          // button items list
          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And select the default sort/filter item
          String defaultTitle = 'défaut';
          final Finder defaultDropDownTextFinder = find.text(defaultTitle);
          await tester.tap(defaultDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'défaut'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'défaut' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: defaultTitle,
          );

          // And verify the order of the playlist audio titles

          List<String>
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La surpopulation mondiale par Jancovici et Barrau",
            "La résilience insulaire par Fiona Roche",
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
            "Les besoins artificiels par R.Keucheyan",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Now go to audio player view
          appScreenNavigationButton =
              find.byKey(const ValueKey('audioPlayerViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Then return to playlist download view in order to verify that
          // its state with the 'default' sort/filter parms is still
          // applied and correctly sorts the current playable audio.
          appScreenNavigationButton =
              find.byKey(const ValueKey('playlistDownloadViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Verify that the dropdown button has been updated with the
          // 'défaut' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: defaultTitle,
          );

          // And verify the order of the playlist audio titles
          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Finally tap on the current dropdown button item to open the dropdown
          // button items list
          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And select the 'appliqué' sort/filter item
          final Finder titleAscDropDownTextFinder =
              find.text(appliedFrenchTitle);
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'défaut'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'défaut' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedFrenchTitle,
          );

          // And verify the order of the playlist audio titles

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Now go to audio player view
          appScreenNavigationButton =
              find.byKey(const ValueKey('audioPlayerViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Then return to playlist download view in order to verify that
          // its state with the 'défaut' sort/filter parms is still
          // applied and correctly sorts the current playable audio.
          appScreenNavigationButton =
              find.byKey(const ValueKey('playlistDownloadViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Verify that the dropdown button has been updated with the
          // 'défaut' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedFrenchTitle,
          );

          // And verify the order of the playlist audio titles
          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Click on 'défaut' dropdown button item edit icon button to
             open sort filter audio dialog. Then creating a ascending unamed
             sort/filter parms and applying it. Then verifying that a Sort/filter
             dropdown button item has been created with the title 'appliqué' and
             is applied to the playlist download view list of audio. Then going
             to the audio player view and then going back to the playlist
             download view and verifying that the previously active and newly
             created sort/filter parms is displayed in the dropdown item button
             and applied to the audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          // First, set the application language to French
          await IntegrationTestUtil.setApplicationLanguage(
            tester: tester,
            language: Language.french,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'défaut' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text('défaut').last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to modify the 'janco'
          // sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Now select the 'Titre audio' item in the 'Sort by' dropdown button

          await tester
              .tap(find.byKey(const Key('sortingOptionDropdownButton')));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Titre audio'));
          await tester.pumpAndSettle();

          // Then delete the "Date téléch audio" descending sort option

          // Find the Text with "Date téléch audio" which is located in the
          // selected sort parameters ListView
          final Finder textFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Date téléch audio'),
          );

          // Then find the ListTile ancestor of the 'Date téléch audio' Text
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

          // Now verify the playlist download view state with the 'Title asc'
          // sort/filter parms applied

          String appliedFrenchTitle = 'appliqué';

          // Verify that the dropdown button has been updated with the
          // 'appliqué' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedFrenchTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesSortedByTitleAscending = [
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La résilience insulaire par Fiona Roche",
            "La surpopulation mondiale par Jancovici et Barrau",
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
            // "Les besoins artificiels par R.Keucheyan"
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Now go to audio player view
          Finder appScreenNavigationButton =
              find.byKey(const ValueKey('audioPlayerViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Then return to playlist download view in order to verify that
          // its state with the 'Title asc' sort/filter parms is still
          // applied and correctly sorts the current playable audio.
          appScreenNavigationButton =
              find.byKey(const ValueKey('playlistDownloadViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Verify that the dropdown button has been updated with the
          // 'appliqué' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedFrenchTitle,
          );

          // And verifyagain the order of the playlist audio titles
          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
      });
    });
    group('''Verifying playlist selection change applies correctly their named
             sort/filter parms.''', () {
      testWidgets(
          '''Change the SF parms in the dropdown button list to 'Title asc'
             and then verify its application. Then go to the audio player view
             and there select another playlist. Then go back to the playlist
             download view, select the previously selected playlist and verify
             that its previously selected named sort/filter parms is selected
             and applied''', (WidgetTester tester) async {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_three_playlists_test",
          destinationRootPath: kApplicationPathWindowsTest,
        );

        final SettingsDataService settingsDataService = SettingsDataService(
          sharedPreferences: await SharedPreferences.getInstance(),
        );

        // Load the settings from the json file. This is necessary
        // otherwise the ordered playlist titles will remain empty
        // and the playlist list will not be filled with the
        // playlists available in the download app test dir
        await settingsDataService.loadSettingsFromFile(
            settingsJsonPathFileName:
                "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

        await app.main();
        await tester.pumpAndSettle();

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        final Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        final Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // And find the 'Title asc' sort/filter item
        String titleAscendingSFparmsName = 'Title asc';
        Finder titleAscDropDownTextFinder =
            find.text(titleAscendingSFparmsName);
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // And verify the order of the playlist audio titles

        List<String> audioTitlesSortedByTitleAscending = [
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La résilience insulaire par Fiona Roche",
          "La surpopulation mondiale par Jancovici et Barrau",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          // "Les besoins artificiels par R.Keucheyan"
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
        );

        // Then go to the audio player view
        Finder appScreenNavigationButton =
            find.byKey(const ValueKey('audioPlayerViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // Now, in the audio player view, select the 'Local' audio playlist using
        // the audio player view playlist selection button.

        // Tap on audio player view playlist button to display the playlists
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Select the 'local' playlist

        await IntegrationTestUtil.selectPlaylist(
          tester: tester,
          playlistToSelectTitle: 'local',
        );

        // Now return to the playlist download view
        appScreenNavigationButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        // Click on playlist toggle button to display the playlist list
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        await IntegrationTestUtil.selectPlaylist(
          tester: tester,
          playlistToSelectTitle: 'S8 audio',
        );

        // Click again on playlist toggle button to hide the playlist list
        // and display the sort filter dropdown button
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify that the dropdown button has been updated with the
        // 'Title asc' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: titleAscendingSFparmsName,
        );

        // And verify the order of the playlist audio titles

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
    });
    group('Saved to playlist named sort/filter parms', () {
      group('Saving different named sort/filter parms to playlist views', () {
        testWidgets(
            '''Select the 'desc listened' sort/filter parms. Then, in 'S8 audio',
               save it only to playlist download view. Verify playlist json file
               as well as the Save and Remove dialogs content..
               
               Then, select 'Title asc' in the sort/filter dropdown button and
               open the Save dialog in order to save this SF parms to the audio
               player view. Now verify the playlist json file as well as the
               fact that the audio player view playable audio list is correctly
               sorted.

               Then restart the application. Verify that 'desc listened' is
               selected. Open the Remove dialog to verify its content and remove
               the 'desc listened' SF parms. Then verify that the 'default'
               is applied to the playlist download view and not to the audio
               player view. Verify also the playlist json file as well as the
               save ... and remove ... audio popup menu items state.''',
            (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_three_playlists_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          const String descListenedSortFilterName = 'desc listened';
          const String titleAscSortFilterName = 'Title asc';

          // Save the 'desc listened' sort/filter parms to the 'S8 audio' playlist
          // for playlist download view only
          await IntegrationTestUtil.selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: descListenedSortFilterName,
            saveToPlaylistDownloadView: true,
            saveToAudioPlayerView: false,
          );

          // Verify confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                "Sort/filter parameters \"desc listened\" were saved to playlist \"S8 audio\" for screen(s) \"Download Audio\".",
            isWarningConfirming: true,
          );

          // Verifying that the playlist json file only contains a SF name for
          // the playlist download view and not for the audio player view.
          IntegrationTestUtil
              .verifyPlaylistDataElementsUpdatedInPlaylistJsonFile(
            selectedPlaylistTitle: 'S8 audio',
            audioSortFilterParmsNamePlaylistDownloadView:
                descListenedSortFilterName,
            audioSortFilterParmsNameAudioPlayerView: '',
          );

          // Now verify the save ... and remove ... audio popup menu items
          // state

          await _verifyAudioPopupMenuItemState(
            tester: tester,
            menuItemKey: 'save_sort_and_filter_audio_parms_in_playlist_item',
            isEnabled: true,
          );

          await _verifyAudioPopupMenuItemState(
            tester: tester,
            tapOnAudioPopupMenuButton: false, // since the audio popup menu
            //                                   is already open, do not tap
            //                                   on it again
            menuItemKey:
                'remove_sort_and_filter_audio_parms_from_playlist_item',
            isEnabled: true,
          );

          // Click on playlist toggle button to close the audio menu
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Verify the content of the save sort/filter parms dialog
          await _verifySaveSortFilterParmsToPlaylistDialog(
            tester: tester,
            playlistTitle: 'S8 audio',
            sortFilterParmsName: descListenedSortFilterName,
            isForPlaylistDownloadViewCheckboxDisplayed: false,
            isForAudioPlayerViewCheckboxDisplayed: true,
          );

          // Select and save the 'Title asc' sort/filter parms to the audio
          // player view of 'S8 audio' playlist
          await IntegrationTestUtil.selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: titleAscSortFilterName,
            saveToPlaylistDownloadView: false,
            saveToAudioPlayerView: true,
          );

          // Verify confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                "Sort/filter parameters \"Title asc\" were saved to playlist \"S8 audio\" for screen(s) \"Play Audio\".",
            isWarningConfirming: true,
          );

          // Verifying that the playlist json file was correctly modified.
          IntegrationTestUtil
              .verifyPlaylistDataElementsUpdatedInPlaylistJsonFile(
            selectedPlaylistTitle: 'S8 audio',
            audioSortFilterParmsNamePlaylistDownloadView:
                descListenedSortFilterName,
            audioSortFilterParmsNameAudioPlayerView: titleAscSortFilterName,
            audioPlayingOrder: AudioPlayingOrder.descending,
          );

          // Now go to the audio player view
          Finder appScreenNavigationButton =
              find.byKey(const ValueKey('audioPlayerViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          List<String> audioTitlesSortedByTitleAscending = [
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La résilience insulaire par Fiona Roche",
            "La surpopulation mondiale par Jancovici et Barrau",
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
            // "Les besoins artificiels par R.Keucheyan"
          ];

          // Verify also the audio playable list dialog title and content
          await _verifyAudioPlayableList(
            tester: tester,
            currentAudioTitle:
                "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik\n13:39",
            sortFilterParmsName: titleAscSortFilterName,
            audioTitlesLst: audioTitlesSortedByTitleAscending,
          );
        });
        testWidgets(
            '''Then restart the application. Verify that 'desc listened' is
               selected. Open the Remove dialog to verify its content and remove
               the 'desc listened' SF parms. Then verify that the 'default'
               is applied to the playlist download view and not to the audio
               player view. Verify also the playlist json file as well as the
               save ... and remove ... audio popup menu items state.''',
            (WidgetTester tester) async {
          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          const String descListenedSortFilterName = 'desc listened';
          const String titleAscSortFilterName = 'Title asc';

          // Verify that the 'desc listened' sort/filter parms is selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: descListenedSortFilterName,
          );

          // Now open the Remove dialog, check the 'Download Audio' screen
          // checkbox and click on Save button in order to remove this
          // Sort/Filter parms name for the playlist download view in the
          // playlist.
          await _selectAndRemoveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: descListenedSortFilterName,
            isOnPlaylistDownloadViewCheckboxDisplayed: true,
            tapOnRemoveFromPlaylistDownloadViewCheckbox: true,
            isOnAudioPlayerViewCheckboxDisplayed: false,
            tapOnRemoveFromAudioPlayerViewCheckbox: false,
          );

          // Verify confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                "Sort/filter parameters \"desc listened\" were removed from playlist \"S8 audio\" on screen(s) \"Download Audio\".",
            isWarningConfirming: true,
          );

          // Verifying that the playlist json file was correctly modified.
          IntegrationTestUtil
              .verifyPlaylistDataElementsUpdatedInPlaylistJsonFile(
            selectedPlaylistTitle: 'S8 audio',
            audioSortFilterParmsNamePlaylistDownloadView: '',
            audioSortFilterParmsNameAudioPlayerView: titleAscSortFilterName,
            audioPlayingOrder: AudioPlayingOrder.descending,
          );

          // Verify that the 'default' dropdown button sort/filter parms is
          // selected

          const String defaultTitle = 'default';

          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: defaultTitle,
          );

          // And verify the order of the playlist audio titles
          List<String>
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La surpopulation mondiale par Jancovici et Barrau",
            "La résilience insulaire par Fiona Roche",
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
            "Les besoins artificiels par R.Keucheyan",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Now verify the save ... and remove ... audio popup menu items
          // state

          await _verifyAudioPopupMenuItemState(
            tester: tester,
            menuItemKey: 'save_sort_and_filter_audio_parms_in_playlist_item',
            isEnabled: false,
          );

          await _verifyAudioPopupMenuItemState(
            tester: tester,
            menuItemKey:
                'remove_sort_and_filter_audio_parms_from_playlist_item',
            isEnabled: false,
            tapOnAudioPopupMenuButton: false, // since the audio popup menu
            //                                   is already open, do not tap
            //                                   on it again
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
      });
      group(
          '''After downloading a playlist video, saving a named sort/filter parms
             to playlist views. This tests a bug fix.''', () {
        const String sortFilterParmsName = 'short';
        const String playlistTitle = "MaValTest";

        testWidgets(
            '''In playlist list hidden situation, after having downloaded 2 audio's,
               select a sort/filter named parms in the dropdown button list and
               save it to the current playlist.''',
            (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_newly_downloaded_playlist_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          AudioDownloadVM audioDownloadVM = await IntegrationTestUtil
              .launchIntegrTestAppEnablingInternetAccess(
            tester: tester,
            forcedLocale: const Locale('en'),
          );

          // Now typing on the download playlist button to download the
          // 2 video audio's present the playlist.
          await tester
              .tap(find.byKey(const Key('download_sel_playlists_button')));
          await tester.pumpAndSettle();

          // Add a delay to allow the download to finish.
          for (int i = 0; i < 5; i++) {
            await Future.delayed(const Duration(seconds: 2));
            await tester.pumpAndSettle();
          }

          await Future.delayed(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          // Type on the Playlists button to hide the playlist view
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Verify the order of the playlist audio titles

          List<String> audioTitlesSortedByDateTimeListenedDescending = [
            "morning _ cinematic video",
            "Really short video",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst:
                audioTitlesSortedByDateTimeListenedDescending,
          );

          // Select and save the 'short' sort/filter parms to the audio
          // player view of the 'Maria Valtorta' playlist
          await IntegrationTestUtil.selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: sortFilterParmsName,
            saveToPlaylistDownloadView: false,
            saveToAudioPlayerView: true,
          );

          // Verify confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                "Sort/filter parameters \"$sortFilterParmsName\" were saved to playlist \"$playlistTitle\" for screen(s) \"Play Audio\".",
            isWarningConfirming: true,
          );

          String playlistDownloadPath =
              audioDownloadVM.listOfPlaylist[2].downloadPath;

          // Verifying that the playlist json file was correctly modified.
          IntegrationTestUtil
              .verifyPlaylistDataElementsUpdatedInPlaylistJsonFile(
            selectedPlaylistTitle: playlistTitle,
            audioSortFilterParmsNamePlaylistDownloadView:
                "", // The playlist download view is not affected
            audioSortFilterParmsNameAudioPlayerView: sortFilterParmsName,
            audioPlayingOrder: AudioPlayingOrder.ascending,
            playlistDownloadPath: playlistDownloadPath,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''In playlist list expand situation, download 2 audio's from the 'Maria Valtorta'
               playlist. Then hide the list of playlists and select a sort/filter named parms in
               the dropdown button list. Then expand the list of playlists and save the SF parms to
               the current playlist.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_newly_downloaded_playlist_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          AudioDownloadVM audioDownloadVM = await IntegrationTestUtil
              .launchIntegrTestAppEnablingInternetAccess(
            tester: tester,
            forcedLocale: const Locale('en'),
          );

          // Now typing on the download playlist button to download the
          // 2 video audio's present the created playlist.
          await tester
              .tap(find.byKey(const Key('download_sel_playlists_button')));
          await tester.pumpAndSettle();

          // Add a delay to allow the download to finish.
          for (int i = 0; i < 5; i++) {
            await Future.delayed(const Duration(seconds: 2));
            await tester.pumpAndSettle();
          }

          await Future.delayed(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          // Verify the order of the playlist audio titles

          List<String> audioTitlesSortedByDateTimeListenedDescending = [
            "morning _ cinematic video",
            "Really short video",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst:
                audioTitlesSortedByDateTimeListenedDescending,
            firstAudioListTileIndex: 3,
          );

          // Type on the Playlists button to hide the playlist view
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Select and save the 'spiritual' sort/filter parms to the audio
          // player view of the 'Maria Valtorta' playlist
          await IntegrationTestUtil.selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: sortFilterParmsName,
            saveToPlaylistDownloadView: true,
            saveToAudioPlayerView: false,
            displayPlaylistListBeforeSavingSFtoPlaylist: true,
          );

          // Verify confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                "Sort/filter parameters \"$sortFilterParmsName\" were saved to playlist \"$playlistTitle\" for screen(s) \"Download Audio\".",
            isWarningConfirming: true,
          );

          String playlistDownloadPath =
              audioDownloadVM.listOfPlaylist[2].downloadPath;

          // Verifying that the playlist json file was correctly modified.
          IntegrationTestUtil
              .verifyPlaylistDataElementsUpdatedInPlaylistJsonFile(
            selectedPlaylistTitle: playlistTitle,
            audioSortFilterParmsNamePlaylistDownloadView:
                sortFilterParmsName, // The playlist download view is not affected
            audioSortFilterParmsNameAudioPlayerView: "",
            audioPlayingOrder: AudioPlayingOrder.ascending,
            playlistDownloadPath: playlistDownloadPath,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
      });
      group(
          '''First, restore app data from Android zip file to Windows app. Then,
             select the restored 'MaValTTest' playlist and hide the list of playlists
             in order to be able to select a SF parms. The two integration tests test
             a bug fix.''', () {
        const String playlistToRedownloadTitle = "MaValTest";
        const String restorableZipFileName = 'audioLearn_2025-03-24_11_30.zip';
        const String notPlayableSortFilterParmsName = 'Not playable';

        testWidgets(
            '''After selecting the restored 'MaValTest' playlist and hiding the
               list of playlist, select the 'Not playable' SF which filters the not
               playable audio's. Then extend the list of playlists in order to redownload
               the 'Not playable' filtered audio's. Verify the now empty displayed
               audio list (empty since the redownloaded audio's are now playable) as
               well as the possibility of saving the named sort/filter parms to the
               playlist views.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}restore_Android_short_zip_on_Windows_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          AudioDownloadVM audioDownloadVM = await IntegrationTestUtil
              .launchIntegrTestAppEnablingInternetAccess(
            tester: tester,
            forcedLocale: const Locale('en'),
          );

          // Replace the platform instance with your mock
          MockFilePicker mockFilePicker = MockFilePicker();
          FilePicker.platform = mockFilePicker;

          mockFilePicker.setSelectedFiles([
            PlatformFile(
                name: restorableZipFileName,
                path:
                    '$kApplicationPathWindowsTest${path.separator}$restorableZipFileName',
                size: 1038533), // 1040384
          ]);

          // Execute the 'Restore Playlists, Comments and Settings from Zip
          // File ...' menu
          await IntegrationTestUtil.executeRestorePlaylists(
            tester: tester,
          );

          // Verify the displayed warning confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                'Restored 1 playlist, 1 comment and 0 picture JSON files as well as 2 audio reference(s) and 0 added plus 0 modified comment(s) and the application settings from "C:\\development\\flutter\\audiolearn\\test\\data\\audio\\$restorableZipFileName".',
            isWarningConfirming: true,
            warningTitle: 'CONFIRMATION',
          );

          // Select MaValTest playlist

          await IntegrationTestUtil.selectPlaylist(
            tester: tester,
            playlistToSelectTitle: playlistToRedownloadTitle,
          );

          // Type on the Playlists button to hide the playlist view
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Select the 'Not playable' sort/filter parms
          await IntegrationTestUtil.selectSortFilterParmsInDropDownButton(
            tester: tester,
            sortFilterParmsName: notPlayableSortFilterParmsName,
          );

          // Type on the Playlists button to display the playlists list
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Execute the redownload filtered audio menu by clicking first on
          // the 'Filtered Audio Actions ...' playlist menu item and then
          // on the 'Redownload Filtered Audio ...' sub-menu item.
          await IntegrationTestUtil.typeOnPlaylistSubMenuItem(
            tester: tester,
            playlistTitle: playlistToRedownloadTitle,
            playlistSubMenuKeyStr: 'popup_menu_redownload_filtered_audio',
          );

          // Add a delay to allow the download to finish.
          for (int i = 0; i < 5; i++) {
            await Future.delayed(const Duration(seconds: 1));
            await tester.pumpAndSettle();
          }

          await Future.delayed(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          int remainingNotPlayableAudioNumber = 0;

          final Finder warningMessageDisplayDialogFinder =
              find.byType(WarningMessageDisplayDialog);

          if (warningMessageDisplayDialogFinder.evaluate().isNotEmpty) {
            final Finder okButtonFinder =
                find.byKey(const Key('warningDialogOkButton')).last;

            FinderResult finderResult = okButtonFinder.evaluate();

            try {
              if (finderResult.isNotEmpty) {
                // Closing the Youtube error warning dialog
                await tester.tap(okButtonFinder);
                await tester.pumpAndSettle();
              }
              // ignore: empty_catches
            } catch (e) {}

            final Finder listTilesFinder = find.byType(ListTile);
            remainingNotPlayableAudioNumber =
                listTilesFinder.evaluate().length - 4; // 4 is the number of
            //                                            visible playlists in
            //                                            the expanded playlist list
          }

          if (remainingNotPlayableAudioNumber < 2) {
            // At least one not playable audio was redownloaded

            // Verify the value of the sort/filter parms name that is
            // displayed in the first line of the playlist download view
            expect(
              tester
                  .widget<Text>(
                      find.byKey(const Key('selectedPlaylistSFparmNameText')))
                  .data,
              notPlayableSortFilterParmsName,
            );

            // Select and save the 'Not playable' sort/filter parms to the audio
            // player view of the 'audio_learn_emi' playlist
            await IntegrationTestUtil.selectAndSaveSortFilterParmsToPlaylist(
              tester: tester,
              sortFilterParmsName: notPlayableSortFilterParmsName,
              saveToPlaylistDownloadView: true,
              saveToAudioPlayerView: false,
              displayPlaylistListBeforeSavingSFtoPlaylist: false,
              selectSortFilterParms: false,
            );

            // Verify confirmation dialog
            await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
              tester: tester,
              warningDialogMessage:
                  "Sort/filter parameters \"$notPlayableSortFilterParmsName\" were saved to playlist \"$playlistToRedownloadTitle\" for screen(s) \"Download Audio\".",
              isWarningConfirming: true,
            );

            String playlistDownloadPath =
                audioDownloadVM.listOfPlaylist[3].downloadPath;

            // Verifying that the playlist json file was correctly modified.
            IntegrationTestUtil
                .verifyPlaylistDataElementsUpdatedInPlaylistJsonFile(
              selectedPlaylistTitle: playlistToRedownloadTitle,
              audioSortFilterParmsNamePlaylistDownloadView:
                  notPlayableSortFilterParmsName, // The playlist download view is not affected
              audioSortFilterParmsNameAudioPlayerView: "",
              audioPlayingOrder: AudioPlayingOrder.ascending,
              playlistDownloadPath: playlistDownloadPath,
            );
          }

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Hiding the list of playlist after selecting the restored 'MaValTTest'
               playlist and select the 'Not playable' SF which filters the not
               playable audio's. Redownload only the 'Really short video' audio.
               Verify the displayed audio list which contains only one not yet
               redownloaded audio as well as the possibility of saving the named
               sort/filter parms to the playlist views.''',
            (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}restore_Android_short_zip_on_Windows_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          AudioDownloadVM audioDownloadVM = await IntegrationTestUtil
              .launchIntegrTestAppEnablingInternetAccess(
            tester: tester,
            forcedLocale: const Locale('en'),
          );

          // Replace the platform instance with your mock
          MockFilePicker mockFilePicker = MockFilePicker();
          FilePicker.platform = mockFilePicker;

          mockFilePicker.setSelectedFiles([
            PlatformFile(
                name: restorableZipFileName,
                path:
                    '$kApplicationPathWindowsTest${path.separator}$restorableZipFileName',
                size: 1038533), // 1040384
          ]);

          // Execute the 'Restore Playlists, Comments and Settings from Zip
          // File ...' menu
          await IntegrationTestUtil.executeRestorePlaylists(
            tester: tester,
          );

          // Verify the displayed warning confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                'Restored 1 playlist, 1 comment and 0 picture JSON files as well as 2 audio reference(s) and 0 added plus 0 modified comment(s) and the application settings from "C:\\development\\flutter\\audiolearn\\test\\data\\audio\\$restorableZipFileName".',
            isWarningConfirming: true,
            warningTitle: 'CONFIRMATION',
          );

          // Select MaValTest playlist

          await IntegrationTestUtil.selectPlaylist(
            tester: tester,
            playlistToSelectTitle: playlistToRedownloadTitle,
          );

          // Type on the Playlists button to hide the playlist view
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Select the 'Not playable' sort/filter parms
          await IntegrationTestUtil.selectSortFilterParmsInDropDownButton(
            tester: tester,
            sortFilterParmsName: notPlayableSortFilterParmsName,
          );

          // Now redownload the 'Really short video' audio

          // First, find the Audio sublist ListTile Text widget
          String audioToRedownloadTitle = 'Really short video';
          final Finder targetAudioListTileTextWidgetFinder =
              find.text(audioToRedownloadTitle);

          // Then obtain the Audio ListTile widget enclosing the Text widget by
          // finding its ancestor
          final Finder targetAudioListTileWidgetFinder = find.ancestor(
            of: targetAudioListTileTextWidgetFinder,
            matching: find.byType(ListTile),
          );

          // Now find the leading menu icon button of the Audio ListTile and tap
          // on it
          final Finder targetAudioListTileLeadingMenuIconButton =
              find.descendant(
            of: targetAudioListTileWidgetFinder,
            matching: find.byIcon(Icons.menu),
          );

          // Tap the leading menu icon button to open the popup menu
          await tester.tap(targetAudioListTileLeadingMenuIconButton);
          await tester.pumpAndSettle();

          // Now find the popup menu item and tap on it
          final Finder popupDisplayAudioInfoMenuItemFinder =
              find.byKey(const Key("popup_menu_redownload_delete_audio"));

          await tester.tap(popupDisplayAudioInfoMenuItemFinder);
          await tester.pumpAndSettle();

          // Add a delay to allow the download to finish.
          for (int i = 0; i < 2; i++) {
            await Future.delayed(const Duration(seconds: 1));
            await tester.pumpAndSettle();
          }

          await Future.delayed(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          // Verify the displayed warning confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                "The audio \"$audioToRedownloadTitle\" was redownloaded in the playlist \"$playlistToRedownloadTitle\".",
            isWarningConfirming: true,
            warningTitle: 'CONFIRMATION',
          );

          // Select and save the 'Not playable' sort/filter parms to the audio
          // player view of the 'audio_learn_emi' playlist
          await IntegrationTestUtil.selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: notPlayableSortFilterParmsName,
            saveToPlaylistDownloadView: true,
            saveToAudioPlayerView: true,
            displayPlaylistListBeforeSavingSFtoPlaylist: false,
            selectSortFilterParms: false,
          );

          // Verify confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                "Sort/filter parameters \"$notPlayableSortFilterParmsName\" were saved to playlist \"$playlistToRedownloadTitle\" for screen(s) \"Download Audio\" and \"Play Audio\".",
            isWarningConfirming: true,
          );

          String playlistDownloadPath =
              audioDownloadVM.listOfPlaylist[3].downloadPath;

          // Verifying that the playlist json file was correctly modified.
          IntegrationTestUtil
              .verifyPlaylistDataElementsUpdatedInPlaylistJsonFile(
            selectedPlaylistTitle: playlistToRedownloadTitle,
            audioSortFilterParmsNamePlaylistDownloadView:
                notPlayableSortFilterParmsName, // The playlist download view is not affected
            audioSortFilterParmsNameAudioPlayerView:
                notPlayableSortFilterParmsName,
            audioPlayingOrder: AudioPlayingOrder.ascending,
            playlistDownloadPath: playlistDownloadPath,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
      });
      group('Deleting saved to playlist named sort/filter parms', () {
        testWidgets(
            '''Delete saved to playlist named sort/filter bug fix verification:

               Select the 'Title asc' sort/filter parms. Then save it only to
               playlist download view. Then delete it. Verify that the playlist
               info still contains the reference to the deleted SF parms name
               and verify that the
               'default' sort/filter parms is applied to the playlist download
               view.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_three_playlists_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          // Tap on the current dropdown button item to open the dropdown
          // button items list

          Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          String titleAscSortFilterName = 'Title asc';

          // Find and select the 'Title asc' sort/filter item
          Finder titleAscDropDownTextFinder =
              find.text(titleAscSortFilterName).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // And open the 'Save sort/filter parameters to playlist' dialog
          await tester.tap(find.byKey(
              const Key('save_sort_and_filter_audio_parms_in_playlist_item')));
          await tester.pumpAndSettle();

          // Select only the 'For "Download Audio" screen' checkbox
          await tester
              .tap(find.byKey(const Key('playlistDownloadViewCheckbox')));
          await tester.pumpAndSettle();

          // Finally, click on save button
          await tester.tap(find
              .byKey(const Key('saveSortFilterOptionsToPlaylistSaveButton')));
          await tester.pumpAndSettle();

          // Verify confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                "Sort/filter parameters \"Title asc\" were saved to playlist \"S8 audio\" for screen(s) \"Download Audio\".",
            isWarningConfirming: true,
          );

          // Now delete the 'Title asc' sort/filter parms

          // Tap on the current dropdown button item to open the dropdown
          // button items list

          dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'Title asc' sort/filter item
          titleAscDropDownTextFinder = find.text(titleAscSortFilterName).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to delete the
          // 'Title asc' sf parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Click on the "Delete" button. This closes the sort/filter dialog
          // and sets the default sort/filter parms in the playlist download
          // view dropdown button.
          await tester.tap(find.byKey(const Key('deleteSortFilterTextButton')));
          await tester.pumpAndSettle();

          await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
            tester: tester,
            confirmDialogTitleOne:
                'WARNING: you are going to delete the Sort/Filter parms "$titleAscSortFilterName" which is used in 1 playlist(s) listed below',
            confirmDialogMessage: 'S8 audio',
            confirmOrCancelAction: true, // Confirm button is tapped
          );

          // Now verifying that the playlist data dialog still contains
          // the saved to playlist sort filter values. This is useful
          // if the user wants to recreste and reapply the deleted sort/
          // filter parms

          // Tap on playlist button to expand the list of playlists
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          await IntegrationTestUtil.verifyPlaylistInfoDialogContent(
            tester: tester,
            playlistTitle: 'S8 audio',
            playlistDownloadAudioSortFilterParmsName: 'Title asc',
            playlistPlayAudioSortFilterParmsName: '',
          );

          // Tap on playlist button to hide the list of playlists
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Now verify the playlist download view state with the 'default'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'default' sort/filter parms selected
          const String defaultTitle = 'default';
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: defaultTitle,
          );

          // And verify the order of the playlist audio titles

          List<String>
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La surpopulation mondiale par Jancovici et Barrau",
            "La résilience insulaire par Fiona Roche",
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
            "Les besoins artificiels par R.Keucheyan",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Delete then recreate saved to 2 playlists named sort/filter params:

               Select the 'Title asc' sort/filter parms. Then, in 'S8 audio' and
               in 'local' playlist, save it to playlist download view and to audio
               player view. Then delete 'Title asc' SF parms and verify that the
               'default' sort/filter parms is applied to the playlist download
               view as well as the audio player view in both 'S8 audio' and 'local'
               playlist. Finally, recreate the 'Title asc' sort/filter parms and
               verify its application in the two playlists.''',
            (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_three_playlists_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          const String titleAscSortFilterName = 'Title asc';

          // Save the 'Title asc' sort/filter parms to the 'S8 audio' playlist
          await IntegrationTestUtil.selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: titleAscSortFilterName,
            saveToPlaylistDownloadView: true,
            saveToAudioPlayerView: true,
          );

          // Verify confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                "Sort/filter parameters \"Title asc\" were saved to playlist \"S8 audio\" for screen(s) \"Download Audio\" and \"Play Audio\".",
            isWarningConfirming: true,
          );

          // Now switch to 'local' playlist
          await _switchToPlaylist(
            tester: tester,
            playlistTitle: 'local',
          );

          // Save the 'Title asc' sort/filter parms to the 'local' playlist
          await IntegrationTestUtil.selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: titleAscSortFilterName,
            saveToPlaylistDownloadView: true,
            saveToAudioPlayerView: true,
          );

          // Verify confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                "Sort/filter parameters \"Title asc\" were saved to playlist \"local\" for screen(s) \"Download Audio\" and \"Play Audio\".",
            isWarningConfirming: true,
          );

          // Now delete the 'Title asc' sort/filter parms

          // Tap on the current dropdown button item to open the dropdown
          // button items list

          Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'Title asc' sort/filter item
          Finder titleAscDropDownTextFinder =
              find.text(titleAscSortFilterName).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to delete the
          // 'Title asc' sf parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Click on the "Delete" button. This closes the sort/filter dialog
          // and sets the default sort/filter parms in the playlist download
          // view dropdown button.
          await tester.tap(find.byKey(const Key('deleteSortFilterTextButton')));
          await tester.pumpAndSettle();

          await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
            tester: tester,
            confirmDialogTitleOne:
                'WARNING: you are going to delete the Sort/Filter parms "$titleAscSortFilterName" which is used in 2 playlist(s) listed below',
            confirmDialogMessage: 'S8 audio,\nlocal',
            confirmOrCancelAction: true, // Confirm button is tapped
          );

          // Now verifying that the playlist data dialog still contains
          // the saved to playlist sort filter values. This is useful
          // if the user wants to recreste and reapply the deleted sort/
          // filter parms

          // Tap on playlist button to expand the list of playlists
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          await IntegrationTestUtil.verifyPlaylistInfoDialogContent(
            tester: tester,
            playlistTitle: 'S8 audio',
            playlistDownloadAudioSortFilterParmsName: 'Title asc',
            playlistPlayAudioSortFilterParmsName: 'Title asc',
            isPaylistSelected: false,
          );

          await IntegrationTestUtil.verifyPlaylistInfoDialogContent(
            tester: tester,
            playlistTitle: 'local',
            playlistDownloadAudioSortFilterParmsName: 'Title asc',
            playlistPlayAudioSortFilterParmsName: 'Title asc',
          );

          // Tap on playlist button to hide the list of playlists
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Now verify the playlist download view state with the 'default'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'default' sort/filter parms selected
          const String defaultTitle = 'default';

          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: defaultTitle,
          );

          // And verify the order of the playlist audio titles
          List<String>
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
            "morning _ cinematic video",
            "Really short video",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La résilience insulaire par Fiona Roche",
            "Les besoins artificiels par R.Keucheyan",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Verify also the audio playable list dialog title and content
          await _verifyAudioPlayableList(
            tester: tester,
            currentAudioTitle:
                "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique\n6:29",
            sortFilterParmsName: 'default',
            audioTitlesLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Return to the playlist download view
          Finder appScreenNavigationButton =
              find.byKey(const ValueKey('playlistDownloadViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Now switch back to the 'S8 audio' playlist
          await _switchToPlaylist(
            tester: tester,
            playlistTitle: 'S8 audio',
          );

          // Verify that the 'default' dropdown button sort/filter parms is
          // selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: defaultTitle,
          );

          // And verify the order of the playlist audio titles
          audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La surpopulation mondiale par Jancovici et Barrau",
            "La résilience insulaire par Fiona Roche",
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
            "Les besoins artificiels par R.Keucheyan",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Verify also the audio playable list dialog title and content
          await _verifyAudioPlayableList(
            tester: tester,
            currentAudioTitle:
                "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik\n13:39",
            sortFilterParmsName: 'default',
            audioTitlesLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Return to the playlist download view
          appScreenNavigationButton =
              find.byKey(const ValueKey('playlistDownloadViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Now recreate the 'Title asc' sort/filter parms

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

          // Now select the 'Audio title' item in the 'Sort by' dropdown button

          await tester
              .tap(find.byKey(const Key('sortingOptionDropdownButton')));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Audio title'));
          await tester.pumpAndSettle();

          // Then delete the "Audio download date" descending sort option

          // Find the Text with "Audio downl date" which is located in the
          // selected sort parameters ListView
          Finder textFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Audio downl date'),
          );

          // Then find the ListTile ancestor of the 'Audio downl date' Text
          // widget. The ascending/descending and remove icon buttons are
          // contained in their ListTile ancestor
          Finder listTileFinder = find.ancestor(
            of: textFinder,
            matching: find.byType(ListTile),
          );

          // Now, within that ListTile, find the sort option delete IconButton
          // with key 'removeSortingOptionIconButton'
          Finder iconButtonFinder = find.descendant(
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

          // Now verify the playlist download view state with the 'Title asc'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Title asc' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesSortedByTitleAscending = [
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La résilience insulaire par Fiona Roche",
            "La surpopulation mondiale par Jancovici et Barrau",
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
            // "Les besoins artificiels par R.Keucheyan"
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Now switch to 'local' playlist
          await _switchToPlaylist(
            tester: tester,
            playlistTitle: 'local',
          );

          // And verify the order of the playlist audio titles

          audioTitlesSortedByTitleAscending = [
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La résilience insulaire par Fiona Roche",
            "Les besoins artificiels par R.Keucheyan",
            "morning _ cinematic video",
            "Really short video",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
      });
      group('Removing saved to playlist named sort/filter parms', () {
        testWidgets(
            '''Select the 'Title asc' sort/filter parms. Then, in 'S8 audio',
               save it to playlist download view and to audio player view. Then
               remove 'Title asc' SF parms from playlist download view and from
               audio player view and verify that the 'default' sort/filter parms
               is applied to the playlist download view as well as to the audio
               player view in the 'S8 audio' playlist.''',
            (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_three_playlists_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          const String titleAscSortFilterName = 'Title asc';

          // Save the 'Title asc' sort/filter parms to the 'S8 audio' playlist
          await IntegrationTestUtil.selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: titleAscSortFilterName,
            saveToPlaylistDownloadView: true,
            saveToAudioPlayerView: true,
          );

          // Verify confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                "Sort/filter parameters \"Title asc\" were saved to playlist \"S8 audio\" for screen(s) \"Download Audio\" and \"Play Audio\".",
            isWarningConfirming: true,
          );

          // Now remove the 'Title asc' sort/filter parms from the 'S8 audio'
          // playlist
          await _selectAndRemoveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: titleAscSortFilterName,
            isOnPlaylistDownloadViewCheckboxDisplayed: true,
            tapOnRemoveFromPlaylistDownloadViewCheckbox: true,
            isOnAudioPlayerViewCheckboxDisplayed: true,
            tapOnRemoveFromAudioPlayerViewCheckbox: true,
          );

          // Verify confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                "Sort/filter parameters \"Title asc\" were removed from playlist \"S8 audio\" on screen(s) \"Download Audio\" and \"Play Audio\".",
            isWarningConfirming: true,
          );

          // Verifying that the playlist json file was correctly modified.
          IntegrationTestUtil
              .verifyPlaylistDataElementsUpdatedInPlaylistJsonFile(
            selectedPlaylistTitle: 'S8 audio',
            audioSortFilterParmsNamePlaylistDownloadView: '',
            audioSortFilterParmsNameAudioPlayerView: '',
            audioPlayingOrder: AudioPlayingOrder.descending,
          );

          // Verify that the 'default' dropdown button sort/filter parms is
          // selected

          const String defaultTitle = 'default';

          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: defaultTitle,
          );

          // And verify the order of the playlist audio titles
          List<String>
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La surpopulation mondiale par Jancovici et Barrau",
            "La résilience insulaire par Fiona Roche",
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
            "Les besoins artificiels par R.Keucheyan",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Now verify the save ... and remove ... audio popup menu items
          // state

          await _verifyAudioPopupMenuItemState(
            tester: tester,
            menuItemKey: 'save_sort_and_filter_audio_parms_in_playlist_item',
            isEnabled: false,
          );

          await _verifyAudioPopupMenuItemState(
            tester: tester,
            tapOnAudioPopupMenuButton: false, // since the audio popup menu
            //                                   is already open, do not tap
            //                                   on it again
            menuItemKey:
                'remove_sort_and_filter_audio_parms_from_playlist_item',
            isEnabled: false,
          );

          // Go to audio player view
          Finder appScreenNavigationButton =
              find.byKey(const ValueKey('audioPlayerViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Verify also the audio playable list dialog title and content
          await _verifyAudioPlayableList(
            tester: tester,
            currentAudioTitle:
                "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik\n13:39",
            sortFilterParmsName: 'default',
            audioTitlesLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Return to the playlist download view
          appScreenNavigationButton =
              find.byKey(const ValueKey('playlistDownloadViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Now verify the save ... and remove ... audio popup menu items
          // state

          await _verifyAudioPopupMenuItemState(
            tester: tester,
            menuItemKey: 'save_sort_and_filter_audio_parms_in_playlist_item',
            isEnabled: false,
          );

          await _verifyAudioPopupMenuItemState(
            tester: tester,
            tapOnAudioPopupMenuButton: false, // since the audio popup menu
            //                                   is already open, do not tap
            //                                   on it again
            menuItemKey:
                'remove_sort_and_filter_audio_parms_from_playlist_item',
            isEnabled: false,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Select the 'Title asc' sort/filter parms. Then, in 'S8 audio',
               save it only to playlist download view. Then remove 'Title asc'
               SF parms from playlist download view and verify that the 'default'
               sort/filter parms is applied to the playlist download view in the
               'S8 audio' playlist.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_three_playlists_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          const String titleAscSortFilterName = 'Title asc';

          // Save the 'Title asc' sort/filter parms to the 'S8 audio' playlist
          await IntegrationTestUtil.selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: titleAscSortFilterName,
            saveToPlaylistDownloadView: true,
            saveToAudioPlayerView: false,
          );

          // Verify confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                "Sort/filter parameters \"Title asc\" were saved to playlist \"S8 audio\" for screen(s) \"Download Audio\".",
            isWarningConfirming: true,
          );

          // Now remove the 'Title asc' sort/filter parms from the 'S8 audio'
          // playlist
          await _selectAndRemoveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: titleAscSortFilterName,
            isOnPlaylistDownloadViewCheckboxDisplayed: true,
            tapOnRemoveFromPlaylistDownloadViewCheckbox: true,
            isOnAudioPlayerViewCheckboxDisplayed: false,
            tapOnRemoveFromAudioPlayerViewCheckbox: false,
          );

          // Verify confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                "Sort/filter parameters \"Title asc\" were removed from playlist \"S8 audio\" on screen(s) \"Download Audio\".",
            isWarningConfirming: true,
          );

          // Verifying that the playlist json file was correctly modified.
          IntegrationTestUtil
              .verifyPlaylistDataElementsUpdatedInPlaylistJsonFile(
            selectedPlaylistTitle: 'S8 audio',
            audioSortFilterParmsNamePlaylistDownloadView: '',
            audioSortFilterParmsNameAudioPlayerView: '',
            audioPlayingOrder: AudioPlayingOrder.ascending,
          );

          // Verify that the 'default' dropdown button sort/filter parms is
          // selected

          const String defaultTitle = 'default';

          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: defaultTitle,
          );

          // And verify the order of the playlist audio titles
          List<String>
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La surpopulation mondiale par Jancovici et Barrau",
            "La résilience insulaire par Fiona Roche",
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
            "Les besoins artificiels par R.Keucheyan",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Verify also the audio playable list dialog title and content
          await _verifyAudioPlayableList(
            tester: tester,
            currentAudioTitle:
                "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik\n13:39",
            sortFilterParmsName: 'default',
            audioTitlesLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Return to the playlist download view
          Finder appScreenNavigationButton =
              find.byKey(const ValueKey('playlistDownloadViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Now verify the save ... and remove ... audio popup menu items
          // state

          await _verifyAudioPopupMenuItemState(
            tester: tester,
            menuItemKey: 'save_sort_and_filter_audio_parms_in_playlist_item',
            isEnabled: false,
          );

          await _verifyAudioPopupMenuItemState(
            tester: tester,
            tapOnAudioPopupMenuButton: false, // since the audio popup menu
            //                                   is already open, do not tap
            //                                   on it again
            menuItemKey:
                'remove_sort_and_filter_audio_parms_from_playlist_item',
            isEnabled: false,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Select the 'Title asc' sort/filter parms. Then, in 'S8 audio',
               save it only to playlist download view. Then remove 'Title asc'
               SF parms from playlist download view and verify that the 'default'
               sort/filter parms is applied to the playlist download view in the
               'S8 audio' playlist. Then verify the audio popup menu items state
               without having gone to the audio player view.''',
            (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_three_playlists_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          const String titleAscSortFilterName = 'Title asc';

          // Save the 'Title asc' sort/filter parms to the 'S8 audio' playlist
          await IntegrationTestUtil.selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: titleAscSortFilterName,
            saveToPlaylistDownloadView: true,
            saveToAudioPlayerView: false,
          );

          // Verify confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                "Sort/filter parameters \"Title asc\" were saved to playlist \"S8 audio\" for screen(s) \"Download Audio\".",
            isWarningConfirming: true,
          );

          // Now remove the 'Title asc' sort/filter parms from the 'S8 audio'
          // playlist
          await _selectAndRemoveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: titleAscSortFilterName,
            isOnPlaylistDownloadViewCheckboxDisplayed: true,
            tapOnRemoveFromPlaylistDownloadViewCheckbox: true,
            isOnAudioPlayerViewCheckboxDisplayed: false,
            tapOnRemoveFromAudioPlayerViewCheckbox: false,
          );

          // Verify confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                "Sort/filter parameters \"Title asc\" were removed from playlist \"S8 audio\" on screen(s) \"Download Audio\".",
            isWarningConfirming: true,
          );

          // Verify that the 'default' dropdown button sort/filter parms is
          // selected

          const String defaultTitle = 'default';

          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: defaultTitle,
          );

          // Now verify the save ... and remove ... audio popup menu items
          // state

          await _verifyAudioPopupMenuItemState(
            tester: tester,
            menuItemKey: 'save_sort_and_filter_audio_parms_in_playlist_item',
            isEnabled: false,
          );

          await _verifyAudioPopupMenuItemState(
            tester: tester,
            tapOnAudioPopupMenuButton: false, // since the audio popup menu
            //                                   is already open, do not tap
            //                                   on it again
            menuItemKey:
                'remove_sort_and_filter_audio_parms_from_playlist_item',
            isEnabled: false,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
      });
      group('Comments order tests', () {
        testWidgets(''''Title asc' to both app views.
               Select the 'Title asc' sort/filter parms. Then save it to both
               playlist download view and audio player view. Then open the
               playlist comment list.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}playlist_audio_comments_sort_integr_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          const String playlistTitle = "Conversation avec Dieu";

          // Display the playlist audio comments

          // First, find the playlist ListTile Text widget
          Finder playlistListTileTextWidgetFinder = find.text(playlistTitle);

          // Then obtain the playlist ListTile widget enclosing the Text widget by finding its ancestor
          Finder playlistListTileWidgetFinder = find.ancestor(
            of: playlistListTileTextWidgetFinder,
            matching: find.byType(ListTile),
          );

          // Find the leading menu icon button of the Playlist ListTile
          // and tap on it
          Finder playlistListTileLeadingMenuIconButton = find.descendant(
            of: playlistListTileWidgetFinder,
            matching: find.byIcon(Icons.menu),
          );

          // Tap the leading menu icon button to open the popup menu
          await tester.tap(playlistListTileLeadingMenuIconButton);
          await tester.pumpAndSettle();

          // Now find the 'Audio comments' popup menu item and tap on it
          Finder popupUpdatePlayableAudioListPlaylistMenuItem = find
              .byKey(const Key("popup_menu_display_playlist_audio_comments"));

          await tester.tap(popupUpdatePlayableAudioListPlaylistMenuItem);
          await tester.pumpAndSettle();

          final List<String> expectedDefaultCommentTitles = [
            "Mais comment tout cela est-il vrai ?",
            "L'amérique était un pays qui ne se détournait pas des affamés",
            "Début de Conversation avec Dieu",
            "Chapitre 3, les questions",
          ];

          final List<String> expectedDefaultCommentTimes = [
            "5:36:36",
            "2:55:00",
            "0:00",
            "2:36:27",
          ];

          // Verify the order of the playlist audio comments
          await _verifyOrderOfPlaylistAudioComments(
            tester: tester,
            expectedCommentTitles: expectedDefaultCommentTitles,
            expectedCommentTimes: expectedDefaultCommentTimes,
          );

          // Tap the 'Toggle List' button to contract the playlist list
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Tap on the current dropdown button item to open the dropdown
          // button items list

          Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          String titleAscSortFilterName = 'Title asc';

          // Find and select the 'Title asc' sort/filter item
          Finder titleAscDropDownTextFinder =
              find.text(titleAscSortFilterName).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Save the 'Title asc' sort/filter parms to the 'S8 audio' playlist
          await IntegrationTestUtil.selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: titleAscSortFilterName,
            saveToPlaylistDownloadView: true,
            saveToAudioPlayerView: true,
          );

          // Verify confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                "Sort/filter parameters \"Title asc\" were saved to playlist \"Conversation avec Dieu\" for screen(s) \"Download Audio\" and \"Play Audio\".",
            isWarningConfirming: true,
          );

          // Tap the 'Toggle List' button to display the playlist list.
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Display the playlist audio comments

          // First, find the playlist ListTile Text widget
          playlistListTileTextWidgetFinder = find.text(playlistTitle);

          // Then obtain the playlist ListTile widget enclosing the Text widget by finding its ancestor
          playlistListTileWidgetFinder = find.ancestor(
            of: playlistListTileTextWidgetFinder,
            matching: find.byType(ListTile),
          );

          // Find the leading menu icon button of the Playlist ListTile
          // and tap on it
          playlistListTileLeadingMenuIconButton = find.descendant(
            of: playlistListTileWidgetFinder,
            matching: find.byIcon(Icons.menu),
          );

          // Tap the leading menu icon button to open the popup menu
          await tester.tap(playlistListTileLeadingMenuIconButton);
          await tester.pumpAndSettle();

          // Now find the 'Audio comments' popup menu item and tap on it
          popupUpdatePlayableAudioListPlaylistMenuItem = find
              .byKey(const Key("popup_menu_display_playlist_audio_comments"));

          await tester.tap(popupUpdatePlayableAudioListPlaylistMenuItem);
          await tester.pumpAndSettle();

          // Verify the order of the playlist audio comments

          // Expected order and content of comments
          final List<String> expectedTitleAscCommentTitles = [
            "Début de Conversation avec Dieu",
            "Chapitre 3, les questions",
            "L'amérique était un pays qui ne se détournait pas des affamés",
            "Mais comment tout cela est-il vrai ?",
          ];

          final List<String> expectedTitleAscCommentTimes = [
            "0:00",
            "2:36:27",
            "2:55:00",
            "5:36:36",
          ];

          // Verify the order of the playlist audio comments
          await _verifyOrderOfPlaylistAudioComments(
            tester: tester,
            expectedCommentTitles: expectedTitleAscCommentTitles,
            expectedCommentTimes: expectedTitleAscCommentTimes,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(''''Title asc' only to audio player view.

               Select the 'Title asc' sort/filter parms. Then save it only to 
               audio player view. Then open the playlist comment list and verify
               its content.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}playlist_audio_comments_sort_integr_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          const String playlistTitle = "Conversation avec Dieu";

          // Tap the 'Toggle List' button to display the playlist list
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Tap on the current dropdown button item to open the dropdown
          // button items list

          Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          String titleAscSortFilterName = 'Title asc';

          // Find and select the 'Title asc' sort/filter item
          Finder titleAscDropDownTextFinder =
              find.text(titleAscSortFilterName).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Save the 'Title asc' sort/filter parms to the 'S8 audio' playlist
          await IntegrationTestUtil.selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: titleAscSortFilterName,
            saveToPlaylistDownloadView: false,
            saveToAudioPlayerView: true,
          );

          // Verify confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                "Sort/filter parameters \"Title asc\" were saved to playlist \"Conversation avec Dieu\" for screen(s) \"Play Audio\".",
            isWarningConfirming: true,
          );

          // Display the playlist audio comments

          // Tap the 'Toggle List' button to display the playlist list
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // First, find the playlist ListTile Text widget
          Finder playlistListTileTextWidgetFinder = find.text(playlistTitle);

          // Then obtain the playlist ListTile widget enclosing the Text widget by finding its ancestor
          Finder playlistListTileWidgetFinder = find.ancestor(
            of: playlistListTileTextWidgetFinder,
            matching: find.byType(ListTile),
          );

          // Find the leading menu icon button of the Playlist ListTile
          // and tap on it
          Finder playlistListTileLeadingMenuIconButton = find.descendant(
            of: playlistListTileWidgetFinder,
            matching: find.byIcon(Icons.menu),
          );

          // Tap the leading menu icon button to open the popup menu
          await tester.tap(playlistListTileLeadingMenuIconButton);
          await tester.pumpAndSettle();

          // Now find the 'Audio comments' popup menu item and tap on it
          Finder popupUpdatePlayableAudioListPlaylistMenuItem = find
              .byKey(const Key("popup_menu_display_playlist_audio_comments"));

          await tester.tap(popupUpdatePlayableAudioListPlaylistMenuItem);
          await tester.pumpAndSettle();

          // Verify the order of the playlist audio comments

          // Expected order and content of comments
          final List<String> expectedTitleAscCommentTitles = [
            "Début de Conversation avec Dieu",
            "Chapitre 3, les questions",
            "L'amérique était un pays qui ne se détournait pas des affamés",
            "Mais comment tout cela est-il vrai ?",
          ];

          final List<String> expectedTitleAscCommentTimes = [
            "0:00",
            "2:36:27",
            "2:55:00",
            "5:36:36",
          ];

          // Verify the order of the playlist audio comments
          await _verifyOrderOfPlaylistAudioComments(
            tester: tester,
            expectedCommentTitles: expectedTitleAscCommentTitles,
            expectedCommentTimes: expectedTitleAscCommentTimes,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(''''Title asc' only to playlist download view.
               Select the 'Title asc' sort/filter parms. Then save it only to
               playlist download view. Then open the playlist comment list.
               If saving it only to the playlist download view, the playlist
               comments are 'default' ordered and not 'Title asc' ordered''',
            (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}playlist_audio_comments_sort_integr_test",
            destinationRootPath: kApplicationPathWindowsTest,
          );

          final SettingsDataService settingsDataService = SettingsDataService(
            sharedPreferences: await SharedPreferences.getInstance(),
          );

          // Load the settings from the json file. This is necessary
          // otherwise the ordered playlist titles will remain empty
          // and the playlist list will not be filled with the
          // playlists available in the download app test dir
          await settingsDataService.loadSettingsFromFile(
              settingsJsonPathFileName:
                  "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

          await app.main();
          await tester.pumpAndSettle();

          const String playlistTitle = "Conversation avec Dieu";

          // Tap the 'Toggle List' button to display the playlist list. If the list
          // is not opened, checking that a ListTile with the title of
          // the playlist was added to the list will fail
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Tap on the current dropdown button item to open the dropdown
          // button items list

          Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          String titleAscSortFilterName = 'Title asc';

          // Find and select the 'Title asc' sort/filter item
          Finder titleAscDropDownTextFinder =
              find.text(titleAscSortFilterName).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Save the 'Title asc' sort/filter parms to the 'S8 audio' playlist
          await IntegrationTestUtil.selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: titleAscSortFilterName,
            saveToPlaylistDownloadView: true,
            saveToAudioPlayerView: false,
          );

          // Verify confirmation dialog
          await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
            tester: tester,
            warningDialogMessage:
                "Sort/filter parameters \"Title asc\" were saved to playlist \"Conversation avec Dieu\" for screen(s) \"Download Audio\".",
            isWarningConfirming: true,
          );

          // Tap the 'Toggle List' button to display the playlist list.
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Display the playlist audio comments

          // First, find the playlist ListTile Text widget
          Finder playlistListTileTextWidgetFinder = find.text(playlistTitle);

          // Then obtain the playlist ListTile widget enclosing the Text widget by finding its ancestor
          Finder playlistListTileWidgetFinder = find.ancestor(
            of: playlistListTileTextWidgetFinder,
            matching: find.byType(ListTile),
          );

          // Find the leading menu icon button of the Playlist ListTile
          // and tap on it
          Finder playlistListTileLeadingMenuIconButton = find.descendant(
            of: playlistListTileWidgetFinder,
            matching: find.byIcon(Icons.menu),
          );

          // Tap the leading menu icon button to open the popup menu
          await tester.tap(playlistListTileLeadingMenuIconButton);
          await tester.pumpAndSettle();

          // Now find the 'Audio comments' popup menu item and tap on it
          Finder popupUpdatePlayableAudioListPlaylistMenuItem = find
              .byKey(const Key("popup_menu_display_playlist_audio_comments"));

          await tester.tap(popupUpdatePlayableAudioListPlaylistMenuItem);
          await tester.pumpAndSettle();

          // Verify the order of the playlist audio comments

          final List<String> expectedDefaultCommentTitles = [
            "Début de Conversation avec Dieu",
            "Chapitre 3, les questions",
            "L'amérique était un pays qui ne se détournait pas des affamés",
            "Mais comment tout cela est-il vrai ?",
          ];

          final List<String> expectedDefaultCommentTimes = [
            "0:00",
            "2:36:27",
            "2:55:00",
            "5:36:36",
          ];

          // Verify the order of the playlist audio comments
          await _verifyOrderOfPlaylistAudioComments(
            tester: tester,
            expectedCommentTitles: expectedDefaultCommentTitles,
            expectedCommentTimes: expectedDefaultCommentTimes,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
      });
    });
    group('''Testing not yet tested sort options''', () {
      testWidgets(
          '''Video upload date sort. Audio list item subtitle specific to video
          upload date sort option is verified.''', (WidgetTester tester) async {
        // Click on 'Sort/filter audio' menu item of Audio popup menu to open
        // sort filter audio dialog. Then creating a named video upload date
        // sort option parms and saving it. Then verifying that a Sort/filter
        // dropdown button item has been created and is applied to the playlist
        // download view list of audio. The sorted audio list item title as well
        // as the subtitle specific to video upload date sort option is verified.

        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
          destinationRootPath: kApplicationPathWindowsTest,
        );

        final SettingsDataService settingsDataService = SettingsDataService(
          sharedPreferences: await SharedPreferences.getInstance(),
        );

        // Load the settings from the json file. This is necessary
        // otherwise the ordered playlist titles will remain empty
        // and the playlist list will not be filled with the
        // playlists available in the download app test dir
        await settingsDataService.loadSettingsFromFile(
            settingsJsonPathFileName:
                "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

        await app.main();
        await tester.pumpAndSettle();

        // Now open the audio popup menu
        await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
        await tester.pumpAndSettle();

        // Find the sort/filter audio menu item and tap on it to
        // open the audio sort filter dialog
        await tester.tap(
            find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
        await tester.pumpAndSettle();

        // Type "Video upload desc" in the 'Save as' TextField

        String saveAsTitle = 'Video upload desc';

        await tester.enterText(
            find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
            saveAsTitle);
        await tester.pumpAndSettle();

        // Now select the 'Video upload date' item in the 'Sort by'
        // dropdown button

        await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Video upload date'));
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

        // Now verify the playlist download view state with the 'Video upload date'
        // sort option applied

        // Verify that the dropdown button has been updated with the
        // 'Video upload desc' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: saveAsTitle,
        );

        // Verify the order of the playlist audio titles

        List<String> audioTitlesSortedByTitleAscending = [
          "Les besoins artificiels par R.Keucheyan",
          "La résilience insulaire par Fiona Roche",
          "La surpopulation mondiale par Jancovici et Barrau",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
        );

        // And verify the order of the playlist audio subtitles

        List<String> audioSubTitlesSortedByTitleAscending = [
          "0:19:05.0. Video upload date: 05/01/2024.",
          "0:13:35.0. Video upload date: 03/01/2024.",
          "0:07:38.0. Video upload date: 03/12/2023.",
          "0:20:32.0. Video upload date: 01/12/2023.",
          "0:06:29.0. Video upload date: 23/09/2023.",
          "0:13:39.0. Video upload date: 10/09/2023.",
        ];

        IntegrationTestUtil.checkAudioSubTitlesOrderInListTile(
          tester: tester,
          audioSubTitlesOrderLst: audioSubTitlesSortedByTitleAscending,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets('''Audio duration sort.''', (WidgetTester tester) async {
        // Click on 'Sort/filter audio' menu item of Audio popup menu to open
        // sort filter audio dialog. Then creating a named audio duration asc
        // sort option parms and saving it. Then verifying that a Sort/filter
        // dropdown button item has been created and is applied to the playlist
        // download view list of audio. The sorted audio list item title is
        // verified.

        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
          destinationRootPath: kApplicationPathWindowsTest,
        );

        final SettingsDataService settingsDataService = SettingsDataService(
          sharedPreferences: await SharedPreferences.getInstance(),
        );

        // Load the settings from the json file. This is necessary
        // otherwise the ordered playlist titles will remain empty
        // and the playlist list will not be filled with the
        // playlists available in the download app test dir
        await settingsDataService.loadSettingsFromFile(
            settingsJsonPathFileName:
                "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

        await app.main();
        await tester.pumpAndSettle();

        // Now open the audio popup menu
        await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
        await tester.pumpAndSettle();

        // Find the sort/filter audio menu item and tap on it to
        // open the audio sort filter dialog
        await tester.tap(
            find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
        await tester.pumpAndSettle();

        // Type "Audio duration asc" in the 'Save as' TextField

        String saveAsTitle = 'Audio duration asc';

        await tester.enterText(
            find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
            saveAsTitle);
        await tester.pumpAndSettle();

        // Now select the 'Audio duration' item in the 'Sort by'
        // dropdown button

        await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Audio duration'));
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

        // Now verify the playlist download view state with the 'Audio duration'
        // sort option applied

        // Verify that the dropdown button has been updated with the
        // 'Audio duration asc' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: saveAsTitle,
        );

        // Verify the order of the playlist audio titles

        List<String> audioTitlesSortedByTitleAscending = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets(
          '''Audio listenable remaining duration sort. Audio list item subtitle
          specific to Audio listenable remaining duration sort option is verified.''',
          (WidgetTester tester) async {
        // Click on 'Sort/filter audio' menu item of Audio popup menu to open
        // sort filter audio dialog. Then creating a named audio remaining duration
        // sort option parms and saving it. Then verifying that a Sort/filter
        // dropdown button item has been created and is applied to the playlist
        // download view list of audio. The sorted audio list item title as well
        // as the subtitle specific to Audio listenable remaining duration sort
        // option is verified.

        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
          destinationRootPath: kApplicationPathWindowsTest,
        );

        final SettingsDataService settingsDataService = SettingsDataService(
          sharedPreferences: await SharedPreferences.getInstance(),
        );

        // Load the settings from the json file. This is necessary
        // otherwise the ordered playlist titles will remain empty
        // and the playlist list will not be filled with the
        // playlists available in the download app test dir
        await settingsDataService.loadSettingsFromFile(
            settingsJsonPathFileName:
                "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

        await app.main();
        await tester.pumpAndSettle();

        // Now open the audio popup menu
        await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
        await tester.pumpAndSettle();

        // Find the sort/filter audio menu item and tap on it to
        // open the audio sort filter dialog
        await tester.tap(
            find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
        await tester.pumpAndSettle();

        // Type "Audio remaining duration" in the 'Save as' TextField

        String saveAsTitle = 'Audio remaining duration';

        await tester.enterText(
            find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
            saveAsTitle);
        await tester.pumpAndSettle();

        // Now select the 'Audio listenable remaining duration' item in the
        // 'Sort by' dropdown button

        await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Audio listenable remaining duration'));
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

        // Now verify the playlist download view state with the 'Audio
        // remaining duration' sort option applied

        // Verify that the dropdown button has been updated with the
        // 'Video upload desc' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: saveAsTitle,
        );

        // Verify the order of the playlist audio titles

        List<String> audioTitlesSortedByTitleAscending = [
          "Les besoins artificiels par R.Keucheyan",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
        );

        // And verify the order of the playlist audio subtitles

        List<String> audioSubTitlesSortedByTitleAscending = [
          "0:19:05.0. Remaining 00:00:00. Listened on 16/05/2024 at 17:09.",
          "0:06:29.0. Remaining 00:00:38. Listened on 16/03/2024 at 17:09.",
          "0:06:29.0. Remaining 00:06:29. Not listened.",
          "0:07:38.0. Remaining 00:07:38. Not listened.",
          "0:20:32.0. Remaining 00:10:32. Listened on 16/06/2024 at 17:09.",
          "0:13:35.0. Remaining 00:11:01. Listened on 16/02/2024 at 17:09.",
          "0:13:39.0. Remaining 00:13:39. Listened on 16/01/2024 at 17:09.",
        ];

        IntegrationTestUtil.checkAudioSubTitlesOrderInListTile(
          tester: tester,
          audioSubTitlesOrderLst: audioSubTitlesSortedByTitleAscending,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets(
          '''Audio last listened date/time sort. Audio list item subtitle
          specific to Audio listenable remaining duration sort option is verified.''',
          (WidgetTester tester) async {
        // Click on 'Sort/filter audio' menu item of Audio popup menu to open
        // sort filter audio dialog. Then creating a named audio last listened
        // date/time sort option parms and saving it. Then verifying that a Sort/
        // filter dropdown button item has been created and is applied to the playlist
        // download view list of audio. The sorted audio list item title as well
        // as the subtitle specific to Audio last listened date/time sort option
        // is verified.

        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
          destinationRootPath: kApplicationPathWindowsTest,
        );

        final SettingsDataService settingsDataService = SettingsDataService(
          sharedPreferences: await SharedPreferences.getInstance(),
        );

        // Load the settings from the json file. This is necessary
        // otherwise the ordered playlist titles will remain empty
        // and the playlist list will not be filled with the
        // playlists available in the download app test dir
        await settingsDataService.loadSettingsFromFile(
            settingsJsonPathFileName:
                "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

        await app.main();
        await tester.pumpAndSettle();

        // Now open the audio popup menu
        await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
        await tester.pumpAndSettle();

        // Find the sort/filter audio menu item and tap on it to
        // open the audio sort filter dialog
        await tester.tap(
            find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
        await tester.pumpAndSettle();

        // Type "Audio last listened date/time" in the 'Save as' TextField

        String saveAsTitle = 'Audio last listened date/time';

        await tester.enterText(
            find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
            saveAsTitle);
        await tester.pumpAndSettle();

        // Now select the 'Last listened date/time' item in the 'Sort by'
        // dropdown button

        await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Last listened date/time'));
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

        // Now verify the playlist download view state with the 'Audio last
        // listened date/time' sort option applied

        // Verify that the dropdown button has been updated with the
        // 'Last listened date/time' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: saveAsTitle,
        );

        // Verify the order of the playlist audio titles

        List<String> audioTitlesSortedByTitleAscending = [
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Les besoins artificiels par R.Keucheyan",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "La surpopulation mondiale par Jancovici et Barrau",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
        );

        // And verify the order of the playlist audio subtitles

        List<String> audioSubTitlesSortedByTitleAscending = [
          "0:20:32.0. Listened on 16/06/2024 at 17:09.",
          "0:19:05.0. Listened on 16/05/2024 at 17:09.",
          "0:06:29.0. Listened on 16/03/2024 at 17:09.",
          "0:13:35.0. Listened on 16/02/2024 at 17:09.",
          "0:13:39.0. Listened on 16/01/2024 at 17:09.",
          "0:07:38.0. Not listened.",
          "0:06:29.0. Not listened.",
        ];

        IntegrationTestUtil.checkAudioSubTitlesOrderInListTile(
          tester: tester,
          audioSubTitlesOrderLst: audioSubTitlesSortedByTitleAscending,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets('''Audio file size sort.''', (WidgetTester tester) async {
        // Click on 'Sort/filter audio' menu item of Audio popup menu to open
        // sort filter audio dialog. Then creating a named audio filesize desc
        // sort option parms and saving it. Then verifying that a Sort/filter
        // dropdown button item has been created and is applied to the playlist
        // download view list of audio. The sorted audio list item title is
        // verified.

        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
          destinationRootPath: kApplicationPathWindowsTest,
        );

        final SettingsDataService settingsDataService = SettingsDataService(
          sharedPreferences: await SharedPreferences.getInstance(),
        );

        // Load the settings from the json file. This is necessary
        // otherwise the ordered playlist titles will remain empty
        // and the playlist list will not be filled with the
        // playlists available in the download app test dir
        await settingsDataService.loadSettingsFromFile(
            settingsJsonPathFileName:
                "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

        await app.main();
        await tester.pumpAndSettle();

        // Now open the audio popup menu
        await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
        await tester.pumpAndSettle();

        // Find the sort/filter audio menu item and tap on it to
        // open the audio sort filter dialog
        await tester.tap(
            find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
        await tester.pumpAndSettle();

        // Type "Audio filesize desc" in the 'Save as' TextField

        String saveAsTitle = 'Audio filesize desc';

        await tester.enterText(
            find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
            saveAsTitle);
        await tester.pumpAndSettle();

        // Now select the 'Audio duration' item in the 'Sort by'
        // dropdown button

        await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Audio file size'));
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

        // Now verify the playlist download view state with the 'Audio duration'
        // sort option applied

        // Verify that the dropdown button has been updated with the
        // 'Audio duration asc' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: saveAsTitle,
        );

        // Verify the order of the playlist audio titles

        List<String> audioTitlesSortedByTitleAscending = [
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Les besoins artificiels par R.Keucheyan",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "La résilience insulaire par Fiona Roche",
          "La surpopulation mondiale par Jancovici et Barrau",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets('''Audio download speed sort.''',
          (WidgetTester tester) async {
        // Click on 'Sort/filter audio' menu item of Audio popup menu to open
        // sort filter audio dialog. Then creating a named audio download speed
        // desc sort option parms and saving it. Then verifying that a Sort/filter
        // dropdown button item has been created and is applied to the playlist
        // download view list of audio. The sorted audio list item title is
        // verified.

        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
          destinationRootPath: kApplicationPathWindowsTest,
        );

        final SettingsDataService settingsDataService = SettingsDataService(
          sharedPreferences: await SharedPreferences.getInstance(),
        );

        // Load the settings from the json file. This is necessary
        // otherwise the ordered playlist titles will remain empty
        // and the playlist list will not be filled with the
        // playlists available in the download app test dir
        await settingsDataService.loadSettingsFromFile(
            settingsJsonPathFileName:
                "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

        await app.main();
        await tester.pumpAndSettle();

        // Now open the audio popup menu
        await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
        await tester.pumpAndSettle();

        // Find the sort/filter audio menu item and tap on it to
        // open the audio sort filter dialog
        await tester.tap(
            find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
        await tester.pumpAndSettle();

        // Type "Audio download speed desc" in the 'Save as' TextField

        String saveAsTitle = 'Audio downl speed desc';

        await tester.enterText(
            find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
            saveAsTitle);
        await tester.pumpAndSettle();

        // Now select the 'Audio duration' item in the 'Sort by'
        // dropdown button

        await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Audio downl speed'));
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

        // Now verify the playlist download view state with the 'Audio duration'
        // sort option applied

        // Verify that the dropdown button has been updated with the
        // 'Audio duration asc' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: saveAsTitle,
        );

        // Verify the order of the playlist audio titles

        List<String> audioTitlesSortedByTitleAscending = [
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Les besoins artificiels par R.Keucheyan",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets('''Audio download duration sort. Audio list item subtitle
          specific to Audio listenable remaining duration sort option is verified.''',
          (WidgetTester tester) async {
        // Click on 'Sort/filter audio' menu item of Audio popup menu to open
        // sort filter audio dialog. Then creating a named audio download duration
        // decc sort option parms and saving it. Then verifying that a Sort/
        // filter dropdown button item has been created and is applied to the playlist
        // download view list of audio. The sorted audio list item title as well
        // as the subtitle specific to Audio download duration sort option is
        // verified.

        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
          destinationRootPath: kApplicationPathWindowsTest,
        );

        final SettingsDataService settingsDataService = SettingsDataService(
          sharedPreferences: await SharedPreferences.getInstance(),
        );

        // Load the settings from the json file. This is necessary
        // otherwise the ordered playlist titles will remain empty
        // and the playlist list will not be filled with the
        // playlists available in the download app test dir
        await settingsDataService.loadSettingsFromFile(
            settingsJsonPathFileName:
                "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

        await app.main();
        await tester.pumpAndSettle();

        // Now open the audio popup menu
        await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
        await tester.pumpAndSettle();

        // Find the sort/filter audio menu item and tap on it to
        // open the audio sort filter dialog
        await tester.tap(
            find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
        await tester.pumpAndSettle();

        // Type "Audio download duration desc" in the 'Save as' TextField

        String saveAsTitle = 'Audio downl duration desc';

        await tester.enterText(
            find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
            saveAsTitle);
        await tester.pumpAndSettle();

        // Now select the 'Last listened date/time' item in the 'Sort by'
        // dropdown button

        await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Audio downl duration'));
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

        // Now verify the playlist download view state with the 'Audio last
        // listened date/time' sort option applied

        // Verify that the dropdown button has been updated with the
        // 'Last listened date/time' sort/filter parms selected
        IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
          tester: tester,
          dropdownButtonSelectedTitle: saveAsTitle,
        );

        // Verify the order of the playlist audio titles

        List<String> audioTitlesSortedByTitleAscending = [
          // "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Les besoins artificiels par R.Keucheyan",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "La résilience insulaire par Fiona Roche",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitlesSortedByTitleAscending,
        );

        // And verify the order of the playlist audio subtitles

        List<String> audioSubTitlesSortedByTitleAscending = [
          // "0:20:32.0. 7.51 MB at 2.44 MB/sec on 26/12/2023 at 09:45. Audio downl duration: 0:00:03.",
          "0:19:05.0. 6.98 MB at 2.28 MB/sec on 07/01/2024 at 08:16. Audio downl duration: 0:00:03.",
          "0:13:39.0. 4.99 MB at 2.55 MB/sec on 07/01/2024 at 08:16. Audio downl duration: 0:00:01.",
          "0:13:35.0. 4.97 MB at 2.67 MB/sec on 07/01/2024 at 08:16. Audio downl duration: 0:00:01.",
          "0:06:29.0. 2.37 MB at 1.36 MB/sec on 26/12/2023 at 09:45. Audio downl duration: 0:00:01.",
          "0:06:29.0. 2.37 MB at 1.69 MB/sec on 08/01/2024 at 16:35. Audio downl duration: 0:00:01.",
        ];

        IntegrationTestUtil.checkAudioSubTitlesOrderInListTile(
          tester: tester,
          audioSubTitlesOrderLst: audioSubTitlesSortedByTitleAscending,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
    });
    group('''Testing not yet tested filter options''', () {
      group('''Comment related checkboxes''', () {
        testWidgets(
            '''Commented checkbox true and Not com. checkbox false in order to filter
             only the commented audio. Create and then edit a named and saved
             'Commented' filter parms. Then verifying that the corresponding sort/filter
             dropdown button item is applied to the playlist download view list of
             audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_comment_test',
            selectedPlaylistTitle: youtubePlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type "Commented" in the 'Save as' TextField

          String saveAsTitle = 'Commented';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Scrolling down the sort filter dialog so that the 'Comment' /
          // 'No com.' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Unselect the 'Not com.' checkbox

          // Find the 'Not com.' checkbox widget
          Finder notCommentedCheckboxWidgetFinder =
              find.byKey(const Key('filterNotCommentedCheckbox'));

          // Tap the checkbox to unselect it
          await tester.tap(notCommentedCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Commented'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Commented' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesFilteredByCommented = [
            "Quand Aurélien Barrau va dans une école de management",
            "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesFilteredByCommented,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'Commented' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the 'Commented'
          // sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Comment' /
          // 'No com.' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Commented' checkbox widget and verify it is
          // selected
          final Finder commentedCheckboxWidgetFinder =
              find.byKey(const Key('filterCommentedCheckbox'));

          expect(
            tester.widget<Checkbox>(commentedCheckboxWidgetFinder).value,
            true,
          );

          // Find the 'Not com.' checkbox widget and verify it is not
          // selected
          notCommentedCheckboxWidgetFinder =
              find.byKey(const Key('filterNotCommentedCheckbox'));

          expect(
            tester.widget<Checkbox>(notCommentedCheckboxWidgetFinder).value,
            false,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Commented checkbox false and Not com. checkbox true in order to filter
             only the not commented audio. Create and then edit a named and saved
             'Uncomm' filter parms. Then verifying that the corresponding sort/filter
             dropdown button item is applied to the playlist download view list of
             audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_comment_test',
            selectedPlaylistTitle: youtubePlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type "Commented" in the 'Save as' TextField

          String saveAsTitle = 'Uncomm';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Scrolling down the sort filter dialog so that the 'Comment' /
          // 'No com.' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Unselect the 'Comment' checkbox

          // Find the 'Comment' checkbox widget
          Finder commentedCheckboxWidgetFinder =
              find.byKey(const Key('filterCommentedCheckbox'));

          // Tap the checkbox to unselect it
          await tester.tap(commentedCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Uncomm'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Uncomm' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesFilteredByCommented = [
            "La surpopulation mondiale par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesFilteredByCommented,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'Uncomm' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the 'Uncomm'
          // sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Comment' /
          // 'No com.' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Commented' checkbox widget and verify it is
          // selected
          commentedCheckboxWidgetFinder =
              find.byKey(const Key('filterCommentedCheckbox'));

          expect(
            tester.widget<Checkbox>(commentedCheckboxWidgetFinder).value,
            false,
          );

          // Find the 'Not com.' checkbox widget and verify it is not
          // selected
          final Finder notCommentedCheckboxWidgetFinder =
              find.byKey(const Key('filterNotCommentedCheckbox'));

          expect(
            tester.widget<Checkbox>(notCommentedCheckboxWidgetFinder).value,
            true,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Both Commented and Not com. checkboxes true in order to filter both
             the commented and not commented audio. Create and then edit a named
             and saved 'ComUncom' filter parms. Then verifying that the corresponding
             sort/filter dropdown button item is applied to the playlist download
             view list of audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_comment_test',
            selectedPlaylistTitle: youtubePlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type "ComUncom" in the 'Save as' TextField

          String saveAsTitle = 'ComUncom';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Do not modify the default true values of the 'Commented' /
          // 'Uncom.' checkboxes

          // Scrolling down the sort filter dialog so that the 'Save' button is
          // visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Commented'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Commented' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesFilteredByCommented = [
            "Quand Aurélien Barrau va dans une école de management",
            "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La surpopulation mondiale par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesFilteredByCommented,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'Commented' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the 'Commented'
          // sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Comment' /
          // 'No com.' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Commented' checkbox widget and verify it is
          // selected
          final Finder commentedCheckboxWidgetFinder =
              find.byKey(const Key('filterCommentedCheckbox'));

          expect(
            tester.widget<Checkbox>(commentedCheckboxWidgetFinder).value,
            true,
          );

          // Find the 'Not com.' checkbox widget and verify it is not
          // selected
          final Finder notCommentedCheckboxWidgetFinder =
              find.byKey(const Key('filterNotCommentedCheckbox'));

          expect(
            tester.widget<Checkbox>(notCommentedCheckboxWidgetFinder).value,
            true,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Unselect Commented then Not com. checkbox in order to filter commented
             audio. Create and then edit a named and saved 'UnselectComThenUncom'
             sort filter parms. Then verifying that the corresponding sort/filter
             dropdown button item is applied to the playlist download view list
             of audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_comment_test',
            selectedPlaylistTitle: youtubePlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type "UnselectComThenUncom" in the 'Save as' TextField

          String saveAsTitle = 'UnselectComThenUncom';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Scrolling down the sort filter dialog so that the 'Comment' /
          // 'No com.' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Unselect the 'Comment' checkbox

          // Find the 'Comment' checkbox widget
          Finder commentedCheckboxWidgetFinder =
              find.byKey(const Key('filterCommentedCheckbox'));

          // Tap the checkbox to unselect it
          await tester.tap(commentedCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Unselect the 'Not com.' checkbox

          // Find the 'Not com.' checkbox widget
          Finder notCommentedCheckboxWidgetFinder =
              find.byKey(const Key('filterNotCommentedCheckbox'));

          // Tap the checkbox to unselect it. Since the two comment
          // related checkboxex can not be both unselected, the
          // 'Commented' checkbox is reselected.
          await tester.tap(notCommentedCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Commented'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Commented' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesFilteredByCommented = [
            "Quand Aurélien Barrau va dans une école de management",
            "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesFilteredByCommented,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'UnselectComThenUncom' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the
          // 'UnselectComThenUncom' sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Comment' /
          // 'No com.' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Commented' checkbox widget and verify it is
          // selected
          commentedCheckboxWidgetFinder =
              find.byKey(const Key('filterCommentedCheckbox'));

          expect(
            tester.widget<Checkbox>(commentedCheckboxWidgetFinder).value,
            true,
          );

          // Find the 'Not com.' checkbox widget and verify it is not
          // selected
          notCommentedCheckboxWidgetFinder =
              find.byKey(const Key('filterNotCommentedCheckbox'));

          expect(
            tester.widget<Checkbox>(notCommentedCheckboxWidgetFinder).value,
            false,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Unselect Not com. then Commented checkbox in order to filter not commented
             audio. Create and then edit a named and saved 'UnselectUncomThenCom'
             sort filter parms. Then verifying that the corresponding sort/filter
             dropdown button item is applied to the playlist download view list
             of audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_comment_test',
            selectedPlaylistTitle: youtubePlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type "UnselectUncomThenCom" in the 'Save as' TextField

          String saveAsTitle = 'UnselectUncomThenCom';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Scrolling down the sort filter dialog so that the 'Comment' /
          // 'No com.' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Unselect the 'Not com.' checkbox

          // Find the 'Not com.' checkbox widget
          Finder notCommentedCheckboxWidgetFinder =
              find.byKey(const Key('filterNotCommentedCheckbox'));

          // Tap the checkbox to unselect it.
          await tester.tap(notCommentedCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Unselect the 'Comment' checkbox

          // Find the 'Comment' checkbox widget
          Finder commentedCheckboxWidgetFinder =
              find.byKey(const Key('filterCommentedCheckbox'));

          // Tap the checkbox to unselect it.  Since the two comment
          // related checkboxex can not be both unselected, the
          // 'Not com.' checkbox is reselected.
          await tester.tap(commentedCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Commented'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Commented' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesFilteredByCommented = [
            "La surpopulation mondiale par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesFilteredByCommented,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'UnselectUncomThenCom' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the
          // 'UnselectUncomThenCom' sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Comment' /
          // 'No com.' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Commented' checkbox widget and verify it is
          // not selected
          commentedCheckboxWidgetFinder =
              find.byKey(const Key('filterCommentedCheckbox'));

          expect(
            tester.widget<Checkbox>(commentedCheckboxWidgetFinder).value,
            false,
          );

          // Find the 'Not com.' checkbox widget and verify it is
          // selected
          notCommentedCheckboxWidgetFinder =
              find.byKey(const Key('filterNotCommentedCheckbox'));

          expect(
            tester.widget<Checkbox>(notCommentedCheckboxWidgetFinder).value,
            true,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
      });
      group('''Picture related checkboxes''', () {
        testWidgets(
            '''Pictured checkbox true and Unpictured checkbox false in order to filter
             only the pictured audio. Create and then edit a named and saved
             'Pictured' filter parms. Then verifying that the corresponding sort/filter
             dropdown button item is applied to the playlist download view list of
             audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String youtubePlaylistTitle =
              'Jésus-Christ'; // Youtube playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_player_picture_test',
            selectedPlaylistTitle: youtubePlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type "Pictured" in the 'Save as' TextField

          String saveAsTitle = 'Pictured';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Scrolling down the sort filter dialog so that the 'Pictured' /
          // 'Unpictured' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Unselect the 'Unpictured' checkbox

          // Find the 'Unpictured' checkbox widget
          Finder notPictuedCheckboxWidgetFinder =
              find.byKey(const Key('filterNotPicturedCheckbox'));

          // Tap the checkbox to unselect it
          await tester.tap(notPictuedCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Pictured'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Pictured' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesFilteredByPictured = [
            "NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesFilteredByPictured,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'Pictured' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the 'Pictured'
          // sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Pictured' /
          // 'Unpictured' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Pictured' checkbox widget and verify it is
          // selected
          final Finder picturedCheckboxWidgetFinder =
              find.byKey(const Key('filterPicturedCheckbox'));

          expect(
            tester.widget<Checkbox>(picturedCheckboxWidgetFinder).value,
            true,
          );

          // Find the 'Unpictured' checkbox widget and verify it is not
          // selected
          notPictuedCheckboxWidgetFinder =
              find.byKey(const Key('filterNotPicturedCheckbox'));

          expect(
            tester.widget<Checkbox>(notPictuedCheckboxWidgetFinder).value,
            false,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Pictured checkbox false and Unpictured checkbox true in order to filter
             only the not pictured audio. Create and then edit a named and saved
             'Unpictured' filter parms. Then verifying that the corresponding sort/filter
             dropdown button item is applied to the playlist download view list of
             audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String youtubePlaylistTitle =
              'Jésus-Christ'; // Youtube playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_player_picture_test',
            selectedPlaylistTitle: youtubePlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type "Unpictured" in the 'Save as' TextField

          String saveAsTitle = 'Unpictured';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Scrolling down the sort filter dialog so that the 'Pictured' /
          // 'Unpictured' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Unselect the 'Pictured' checkbox

          // Find the 'Pictured' checkbox widget
          Finder picturedCheckboxWidgetFinder =
              find.byKey(const Key('filterPicturedCheckbox'));

          // Tap the checkbox to unselect it
          await tester.tap(picturedCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Unpictured'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Unpictured' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> filteredAudioTitles = [
            "CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: filteredAudioTitles,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'Unpictured' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the 'Unpictured'
          // sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Pictured' /
          // 'Unpictured' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Pictured' checkbox widget and verify it is not
          // selected
          picturedCheckboxWidgetFinder =
              find.byKey(const Key('filterPicturedCheckbox'));

          expect(
            tester.widget<Checkbox>(picturedCheckboxWidgetFinder).value,
            false,
          );

          // Find the 'Unpictured' checkbox widget and verify it is
          // selected
          final Finder notPictuedCheckboxWidgetFinder =
              find.byKey(const Key('filterNotPicturedCheckbox'));

          expect(
            tester.widget<Checkbox>(notPictuedCheckboxWidgetFinder).value,
            true,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Both Pictured and Unpictured checkboxes true in order to filter both
             the pictured and not pictured audio. Create and then edit a named
             and saved 'ComUncom' filter parms. Then verifying that the corresponding
             sort/filter dropdown button item is applied to the playlist download
             view list of audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String youtubePlaylistTitle =
              'Jésus-Christ'; // Youtube playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_player_picture_test',
            selectedPlaylistTitle: youtubePlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type "ComUncom" in the 'Save as' TextField

          String saveAsTitle = 'ComUncom';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Do not modify the default true values of the 'Pictured' /
          // 'Uncom.' checkboxes

          // Scrolling down the sort filter dialog so that the 'Save' button is
          // visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Pictured'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Pictured' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesFilteredByPictured = [
            "CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien",
            "NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesFilteredByPictured,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'Pictured' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the 'Pictured'
          // sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Pictured' /
          // 'Unpictured' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Pictured' checkbox widget and verify it is
          // selected
          final Finder picturedCheckboxWidgetFinder =
              find.byKey(const Key('filterPicturedCheckbox'));

          expect(
            tester.widget<Checkbox>(picturedCheckboxWidgetFinder).value,
            true,
          );

          // Find the 'Unpictured' checkbox widget and verify it is
          // selected
          final Finder notPictuedCheckboxWidgetFinder =
              find.byKey(const Key('filterNotPicturedCheckbox'));

          expect(
            tester.widget<Checkbox>(notPictuedCheckboxWidgetFinder).value,
            true,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Unselect Pictured then Unpictured checkbox in order to filter pictured
             audio. Create and then edit a named and saved 'UnselectPicThenUnpic'
             sort filter parms. Then verifying that the corresponding sort/filter
             dropdown button item is applied to the playlist download view list
             of audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String youtubePlaylistTitle =
              'Jésus-Christ'; // Youtube playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_player_picture_test',
            selectedPlaylistTitle: youtubePlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type "UnselectPicThenUnpic" in the 'Save as' TextField

          String saveAsTitle = 'UnselectPicThenUnpic';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Scrolling down the sort filter dialog so that the 'Pictured' /
          // 'Unpictured' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Unselect the 'Pictured' checkbox

          // Find the 'Pictured' checkbox widget
          Finder picturedCheckboxWidgetFinder =
              find.byKey(const Key('filterPicturedCheckbox'));

          // Tap the checkbox to unselect it
          await tester.tap(picturedCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Unselect the 'Unpictured' checkbox

          // Find the 'Unpictured' checkbox widget
          Finder notPictuedCheckboxWidgetFinder =
              find.byKey(const Key('filterNotPicturedCheckbox'));

          // Tap the checkbox to unselect it. Since the two picture
          // related checkboxex can not be both unselected, the
          // 'Pictured' checkbox is reselected.
          await tester.tap(notPictuedCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Pictured'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Pictured' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesFilteredByPictured = [
            "NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesFilteredByPictured,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'UnselectPicThenUnpic' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the
          // 'UnselectPicThenUnpic' sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Pictured' /
          // 'Unpictured' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Pictured' checkbox widget and verify it is
          // selected
          picturedCheckboxWidgetFinder =
              find.byKey(const Key('filterPicturedCheckbox'));

          expect(
            tester.widget<Checkbox>(picturedCheckboxWidgetFinder).value,
            true,
          );

          // Find the 'Unpictured' checkbox widget and verify it is not
          // selected
          notPictuedCheckboxWidgetFinder =
              find.byKey(const Key('filterNotPicturedCheckbox'));

          expect(
            tester.widget<Checkbox>(notPictuedCheckboxWidgetFinder).value,
            false,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Unselect Unpictured then Pictured checkbox in order to filter not pictured
             audio. Create and then edit a named and saved 'UnselectUnpicThenPic'
             sort filter parms. Then verifying that the corresponding sort/filter
             dropdown button item is applied to the playlist download view list
             of audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String youtubePlaylistTitle =
              'Jésus-Christ'; // Youtube playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_player_picture_test',
            selectedPlaylistTitle: youtubePlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type "UnselectUnpicThenPic" in the 'Save as' TextField

          String saveAsTitle = 'UnselectUnpicThenPic';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Scrolling down the sort filter dialog so that the 'Pictured' /
          // 'Unpictured' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Unselect the 'Unpictured' checkbox

          // Find the 'Unpictured' checkbox widget
          Finder notPictuedCheckboxWidgetFinder =
              find.byKey(const Key('filterNotPicturedCheckbox'));

          // Tap the checkbox to unselect it.
          await tester.tap(notPictuedCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Unselect the 'Pictured' checkbox

          // Find the 'Pictured' checkbox widget
          Finder picturedCheckboxWidgetFinder =
              find.byKey(const Key('filterPicturedCheckbox'));

          // Tap the checkbox to unselect it. Since the two picture
          // related checkboxex can not be both unselected, the
          // 'Unpictured' checkbox is reselected.
          await tester.tap(picturedCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Pictured'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Pictured' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesFilteredByPictured = [
            "CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesFilteredByPictured,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'UnselectUnpicThenPic' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the
          // 'UnselectUnpicThenPic' sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Pictured' /
          // 'Unpictured' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Pictured' checkbox widget and verify it is
          // not selected
          picturedCheckboxWidgetFinder =
              find.byKey(const Key('filterPicturedCheckbox'));

          expect(
            tester.widget<Checkbox>(picturedCheckboxWidgetFinder).value,
            false,
          );

          // Find the 'Unpictured' checkbox widget and verify it is
          // selected
          notPictuedCheckboxWidgetFinder =
              find.byKey(const Key('filterNotPicturedCheckbox'));

          expect(
            tester.widget<Checkbox>(notPictuedCheckboxWidgetFinder).value,
            true,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
      });
      group('''Audio quality related checkboxes''', () {
        testWidgets(
            '''Music qual. checkbox true and Spoken q. checkbox false in order to filter
             only the music qual. audio. Create and then edit a named and saved
             'Music qual' filter parms. Then verifying that the corresponding sort/filter
             dropdown button item is applied to the playlist download view list of
             audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String localPlaylistTitle = 'local'; // local playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_filter_dialog_test',
            selectedPlaylistTitle: localPlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type 'Music qual' in the 'Save as' TextField

          String saveAsTitle = 'Music qual';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Scrolling down the sort filter dialog so that the 'Music qual' /
          // 'Spoken q' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Unselect the 'Spoken q' checkbox

          // Find the 'Spoken q' checkbox widget
          Finder filterSpokenQualityCheckboxWidgetFinder =
              find.byKey(const Key('filterSpokenQualityCheckbox'));

          // Tap the checkbox to unselect it
          await tester.tap(filterSpokenQualityCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Music qual'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Music qual' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesFilteredByPictured = [
            "audio learn test short video one",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesFilteredByPictured,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'Music qual' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the 'Music qual'
          // sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Music qual' /
          // 'Spoken q' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Music qual' checkbox widget and verify it is
          // selected
          final Finder filterMusicQualityCheckboxWidgetFinder =
              find.byKey(const Key('filterMusicQualityCheckbox'));

          expect(
            tester
                .widget<Checkbox>(filterMusicQualityCheckboxWidgetFinder)
                .value,
            true,
          );

          // Find the 'Spoken q' checkbox widget and verify it is not
          // selected
          filterSpokenQualityCheckboxWidgetFinder =
              find.byKey(const Key('filterSpokenQualityCheckbox'));

          expect(
            tester
                .widget<Checkbox>(filterSpokenQualityCheckboxWidgetFinder)
                .value,
            false,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Music qual. checkbox false and Spoken q. checkbox true in order to filter
             only the not music qual. audio. Create and then edit a named and saved
             'Spoken q' filter parms. Then verifying that the corresponding sort/filter
             dropdown button item is applied to the playlist download view list of
             audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String localPlaylistTitle = 'local'; // local playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_filter_dialog_test',
            selectedPlaylistTitle: localPlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type 'Spoken q' in the 'Save as' TextField

          String saveAsTitle = 'Spoken q';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Scrolling down the sort filter dialog so that the 'Music qual' /
          // 'Spoken q' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Unselect the 'Music qual' checkbox

          // Find the 'Music qual' checkbox widget
          Finder filterMusicQualityCheckboxWidgetFinder =
              find.byKey(const Key('filterMusicQualityCheckbox'));

          // Tap the checkbox to unselect it
          await tester.tap(filterMusicQualityCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Spoken q'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Spoken q' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> filteredAudioTitles = [
            "morning _ cinematic video",
            "Really short video",
            "230628-033813-audio learn test short video two 23-06-10",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: filteredAudioTitles,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'Spoken q' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the 'Spoken q'
          // sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Music qual' /
          // 'Spoken q' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Music qual' checkbox widget and verify it is not
          // selected
          filterMusicQualityCheckboxWidgetFinder =
              find.byKey(const Key('filterMusicQualityCheckbox'));

          expect(
            tester
                .widget<Checkbox>(filterMusicQualityCheckboxWidgetFinder)
                .value,
            false,
          );

          // Find the 'Spoken q' checkbox widget and verify it is
          // selected
          final Finder filterSpokenQualityCheckboxWidgetFinder =
              find.byKey(const Key('filterSpokenQualityCheckbox'));

          expect(
            tester
                .widget<Checkbox>(filterSpokenQualityCheckboxWidgetFinder)
                .value,
            true,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Both Music qual. and Spoken q. checkboxes true in order to filter both
             the music qual. and not music qual. audio. Create and then edit a named
             and saved 'MusSpok' filter parms. Then verifying that the corresponding
             sort/filter dropdown button item is applied to the playlist download
             view list of audio. Finally, delete the created sort filter parameters.''',
            (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String localPlaylistTitle = 'local'; // local playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_filter_dialog_test',
            selectedPlaylistTitle: localPlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type "MusSpok" in the 'Save as' TextField

          String saveAsTitle = 'MusSpok';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Do not modify the default true values of the 'Music qual' /
          // 'Uncom.' checkboxes

          // Scrolling down the sort filter dialog so that the 'Save' button is
          // visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'MusSpok'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'MusSpok' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesFilteredByPictured = [
            "morning _ cinematic video",
            "Really short video",
            "230628-033813-audio learn test short video two 23-06-10",
            "audio learn test short video one",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesFilteredByPictured,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'MusSpok' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the 'MusSpok'
          // sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Music qual' /
          // 'Spoken q' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Music qual' checkbox widget and verify it is
          // selected
          final Finder filterMusicQualityCheckboxWidgetFinder =
              find.byKey(const Key('filterMusicQualityCheckbox'));

          expect(
            tester
                .widget<Checkbox>(filterMusicQualityCheckboxWidgetFinder)
                .value,
            true,
          );

          // Find the 'Spoken q' checkbox widget and verify it is
          // selected
          final Finder filterSpokenQualityCheckboxWidgetFinder =
              find.byKey(const Key('filterSpokenQualityCheckbox'));

          expect(
            tester
                .widget<Checkbox>(filterSpokenQualityCheckboxWidgetFinder)
                .value,
            true,
          );

          // Click on the "Delete" button. This closes the sort/filter dialog
          // and the 'MusSpok' sort/filter dropdown button item is removed
          await tester.tap(find.byKey(const Key('deleteSortFilterTextButton')));
          await tester.pumpAndSettle();

          // Verify that the 'MusSpok' sort/filter dropdown button item has been
          // removed from the dropdown button items list
          expect(
            find.text(saveAsTitle),
            findsNothing,
            reason: 'The MusSpok sort/filter dropdown button item should '
                'have been removed from the dropdown button items list.',
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Both Music qual. and Spoken q. checkboxes true in order to filter both
             the music qual. and not music qual. audio. Create and save a named 'MusSpok'
             filter parms. Then save the SF parms to the 'local' playlist download audio
             screen. Finally, delete the created sort filter parameters, verifying the
             displayed confirm dialog.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String localPlaylistTitle = 'local'; // local playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_filter_dialog_test',
            selectedPlaylistTitle: localPlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type "MusSpok" in the 'Save as' TextField

          String saveAsTitle = 'MusSpok';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Do not modify the default true values of the 'Music qual' /
          // 'Uncom.' checkboxes

          // Scrolling down the sort filter dialog so that the 'Save' button is
          // visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Save the 'desc listened' sort/filter parms to the 'S8 audio' playlist
          // for playlist download view only
          await IntegrationTestUtil.selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: saveAsTitle,
            saveToPlaylistDownloadView: true,
            saveToAudioPlayerView: false,
            selectSortFilterParms: false,
          );

          // Tap on the confirm wrning ok button to close the
          // confirm dialog
          await tester.tap(find.byKey(const Key('warningDialogOkButton')).last);
          await tester.pumpAndSettle();

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'MusSpok' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the 'MusSpok'
          // sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Music qual' /
          // 'Spoken q' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Click on the "Delete" button. This closes the sort/filter dialog
          // and the 'MusSpok' sort/filter dropdown button item is removed
          await tester.tap(find.byKey(const Key('deleteSortFilterTextButton')));
          await tester.pumpAndSettle();

          await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
            tester: tester,
            confirmDialogTitleOne:
                'WARNING: you are going to delete the Sort/Filter parms "$saveAsTitle" which is used in 1 playlist(s) listed below',
            confirmDialogMessage: 'local',
            confirmOrCancelAction: true, // Confirm button is tapped
          );

          // Verify that the 'MusSpok' sort/filter dropdown button item has been
          // removed from the dropdown button items list
          expect(
            find.text(saveAsTitle),
            findsNothing,
            reason: 'The MusSpok sort/filter dropdown button item should '
                'have been removed from the dropdown button items list.',
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Unselect Music qual. then Spoken q. checkbox in order to filter Music 
             qual. audio. Create and then edit a named and saved 'UnselectMusThenSpok'
             sort filter parms. Then verifying that the corresponding sort/filter
             dropdown button item is applied to the playlist download view list
             of audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String localPlaylistTitle = 'local'; // local playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_filter_dialog_test',
            selectedPlaylistTitle: localPlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type "UnselectMusThenSpok" in the 'Save as' TextField

          String saveAsTitle = 'UnselectMusThenSpok';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Scrolling down the sort filter dialog so that the 'Music qual' /
          // 'Spoken q' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Unselect the 'Music qual' checkbox

          // Find the 'Music qual' checkbox widget
          Finder filterMusicQualityCheckboxWidgetFinder =
              find.byKey(const Key('filterMusicQualityCheckbox'));

          // Tap the checkbox to unselect it
          await tester.tap(filterMusicQualityCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Unselect the 'Spoken q' checkbox

          // Find the 'Spoken q' checkbox widget
          Finder filterSpokenQualityCheckboxWidgetFinder =
              find.byKey(const Key('filterSpokenQualityCheckbox'));

          // Tap the checkbox to unselect it. Since the two picture
          // related checkboxex can not be both unselected, the
          // 'Music qual' checkbox is reselected.
          await tester.tap(filterSpokenQualityCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Music qual'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Music qual' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesFilteredByPictured = [
            "audio learn test short video one",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesFilteredByPictured,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'UnselectMusThenSpok' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the
          // 'UnselectMusThenSpok' sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Music qual' /
          // 'Spoken q' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Music qual' checkbox widget and verify it is
          // selected
          filterMusicQualityCheckboxWidgetFinder =
              find.byKey(const Key('filterMusicQualityCheckbox'));

          expect(
            tester
                .widget<Checkbox>(filterMusicQualityCheckboxWidgetFinder)
                .value,
            true,
          );

          // Find the 'Spoken q' checkbox widget and verify it is not
          // selected
          filterSpokenQualityCheckboxWidgetFinder =
              find.byKey(const Key('filterSpokenQualityCheckbox'));

          expect(
            tester
                .widget<Checkbox>(filterSpokenQualityCheckboxWidgetFinder)
                .value,
            false,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Unselect Spoken q. then Music qual. checkbox in order to filter not music
             qual audio. Create and then edit a named and saved 'UnselecSpokThenMus'
             sort filter parms. Then verifying that the corresponding sort/filter
             dropdown button item is applied to the playlist download view list
             of audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String localPlaylistTitle = 'local'; // local playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_filter_dialog_test',
            selectedPlaylistTitle: localPlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type "UnselecSpokThenMus" in the 'Save as' TextField

          String saveAsTitle = 'UnselecSpokThenMus';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Scrolling down the sort filter dialog so that the 'Music qual' /
          // 'Spoken q' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Unselect the 'Spoken q' checkbox

          // Find the 'Spoken q' checkbox widget
          Finder filterSpokenQualityCheckboxWidgetFinder =
              find.byKey(const Key('filterSpokenQualityCheckbox'));

          // Tap the checkbox to unselect it.
          await tester.tap(filterSpokenQualityCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Unselect the 'Music qual' checkbox

          // Find the 'Music qual' checkbox widget
          Finder filterMusicQualityCheckboxWidgetFinder =
              find.byKey(const Key('filterMusicQualityCheckbox'));

          // Tap the checkbox to unselect it. Since the two picture
          // related checkboxex can not be both unselected, the
          // 'Spoken q' checkbox is reselected.
          await tester.tap(filterMusicQualityCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Music qual'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Music qual' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesFilteredByPictured = [
            "morning _ cinematic video",
            "Really short video",
            "230628-033813-audio learn test short video two 23-06-10",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesFilteredByPictured,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'UnselecSpokThenMus' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the
          // 'UnselecSpokThenMus' sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Music qual' /
          // 'Spoken q' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Music qual' checkbox widget and verify it is
          // not selected
          filterMusicQualityCheckboxWidgetFinder =
              find.byKey(const Key('filterMusicQualityCheckbox'));

          expect(
            tester
                .widget<Checkbox>(filterMusicQualityCheckboxWidgetFinder)
                .value,
            false,
          );

          // Find the 'Spoken q' checkbox widget and verify it is
          // selected
          filterSpokenQualityCheckboxWidgetFinder =
              find.byKey(const Key('filterSpokenQualityCheckbox'));

          expect(
            tester
                .widget<Checkbox>(filterSpokenQualityCheckboxWidgetFinder)
                .value,
            true,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
      });
      group('''Playable related checkboxes''', () {
        testWidgets(
            '''Playable checkbox true and Not playable checkbox false in order to filter
             only the playable audio. Create and then edit a named and saved 'Playable'
             filter parms. Then verifying that the corresponding sort/filter dropdown
             button item is applied to the playlist download view list of audio.''',
            (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String localPlaylistTitle = 'local'; // local playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_filter_dialog_test',
            selectedPlaylistTitle: localPlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type 'Playable' in the 'Save as' TextField

          String saveAsTitle = 'Playable';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Scrolling down the sort filter dialog so that the 'Playable' /
          // 'Not playable' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Unselect the 'Not playable' checkbox

          // Find the 'Not playable' checkbox widget
          Finder filterNotPlayableCheckboxWidgetFinder =
              find.byKey(const Key('filterNotPlayableCheckbox'));

          // Tap the checkbox to unselect it
          await tester.tap(filterNotPlayableCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Playable'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Playable' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesFilteredByPictured = [
            "Really short video",
            "230628-033813-audio learn test short video two 23-06-10",
            "audio learn test short video one",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesFilteredByPictured,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'Playable' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the 'Playable'
          // sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Playable' /
          // 'Not playable' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Playable' checkbox widget and verify it is
          // selected
          final Finder filterPlayableCheckboxWidgetFinder =
              find.byKey(const Key('filterPlayableCheckbox'));

          expect(
            tester.widget<Checkbox>(filterPlayableCheckboxWidgetFinder).value,
            true,
          );

          // Find the 'Not playable' checkbox widget and verify it is not
          // selected
          filterNotPlayableCheckboxWidgetFinder =
              find.byKey(const Key('filterNotPlayableCheckbox'));

          expect(
            tester
                .widget<Checkbox>(filterNotPlayableCheckboxWidgetFinder)
                .value,
            false,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Playable checkbox false and Not playable checkbox true in order to filter
             only the not playable audio. Create and then edit a named and saved
             'Not playable' filter parms. Then verifying that the corresponding sort/filter
             dropdown button item is applied to the playlist download view list of
             audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String localPlaylistTitle = 'local'; // local playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_filter_dialog_test',
            selectedPlaylistTitle: localPlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type 'Not playable' in the 'Save as' TextField

          String saveAsTitle = 'Not playable';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Scrolling down the sort filter dialog so that the 'Playable' /
          // 'Not playable' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Unselect the 'Playable' checkbox

          // Find the 'Playable' checkbox widget
          Finder filterPlayableCheckboxWidgetFinder =
              find.byKey(const Key('filterPlayableCheckbox'));

          // Tap the checkbox to unselect it
          await tester.tap(filterPlayableCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Not playable'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Not playable' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> filteredAudioTitles = [
            "morning _ cinematic video",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: filteredAudioTitles,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'Not playable' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the 'Not playable'
          // sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Playable' /
          // 'Not playable' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Playable' checkbox widget and verify it is not
          // selected
          filterPlayableCheckboxWidgetFinder =
              find.byKey(const Key('filterPlayableCheckbox'));

          expect(
            tester.widget<Checkbox>(filterPlayableCheckboxWidgetFinder).value,
            false,
          );

          // Find the 'Not playable' checkbox widget and verify it is
          // selected
          final Finder filterNotPlayableCheckboxWidgetFinder =
              find.byKey(const Key('filterNotPlayableCheckbox'));

          expect(
            tester
                .widget<Checkbox>(filterNotPlayableCheckboxWidgetFinder)
                .value,
            true,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Both Playable and Not playable checkboxes true in order to filter both
             the playable and not playable audio. Create and then edit a named and
             saved 'PlayNotPlay' filter parms. Then verifying that the corresponding
             sort/filter dropdown button item is applied to the playlist download
             view list of audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String localPlaylistTitle = 'local'; // local playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_filter_dialog_test',
            selectedPlaylistTitle: localPlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type 'PlayNotPlay' in the 'Save as' TextField

          String saveAsTitle = 'PlayNotPlay';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Do not modify the default true values of the 'Playable' /
          // 'Not playable' checkboxes

          // Scrolling down the sort filter dialog so that the 'Save' button is
          // visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'PlayNotPlay'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'PlayNotPlay' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesFilteredByPictured = [
            "morning _ cinematic video",
            "Really short video",
            "230628-033813-audio learn test short video two 23-06-10",
            "audio learn test short video one",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesFilteredByPictured,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'PlayNotPlay' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the 'PlayNotPlay'
          // sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Playable' /
          // 'Not playable' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Playable' checkbox widget and verify it is
          // selected
          final Finder filterPlayableCheckboxWidgetFinder =
              find.byKey(const Key('filterPlayableCheckbox'));

          expect(
            tester.widget<Checkbox>(filterPlayableCheckboxWidgetFinder).value,
            true,
          );

          // Find the 'Not playable' checkbox widget and verify it is
          // selected
          final Finder filterNotPlayableCheckboxWidgetFinder =
              find.byKey(const Key('filterNotPlayableCheckbox'));

          expect(
            tester
                .widget<Checkbox>(filterNotPlayableCheckboxWidgetFinder)
                .value,
            true,
          );

          // Click on the 'Cancel' button. This closes the sort/filter dialog
          // and the 'PlayNotPlay' sort/filter dropdown button item is removed
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Unselect Playable then Not playable checkbox in order to filter Playable 
             audio. Create and then edit a named and saved 'UnselectPlayThenNotPlay' sort
             filter parms. Then verifying that the corresponding sort/filter dropdown
             button item is applied to the playlist download view list of audio.''',
            (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String localPlaylistTitle = 'local'; // local playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_filter_dialog_test',
            selectedPlaylistTitle: localPlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type 'UnselectPlayThenNotPlay' in the 'Save as' TextField

          String saveAsTitle = 'UnselectPlayThenNotPlay';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Scrolling down the sort filter dialog so that the 'Playable' /
          // 'Not playable' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Unselect the 'Playable' checkbox

          // Find the 'Playable' checkbox widget
          Finder filterPlayableCheckboxWidgetFinder =
              find.byKey(const Key('filterPlayableCheckbox'));

          // Tap the checkbox to unselect it
          await tester.tap(filterPlayableCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Unselect the 'Not playable' checkbox

          // Find the 'Not playable' checkbox widget
          Finder filterNotPlayableCheckboxWidgetFinder =
              find.byKey(const Key('filterNotPlayableCheckbox'));

          // Tap the checkbox to unselect it. Since the two playable
          // related checkboxex can not be both unselected, the
          // 'Playable' checkbox is reselected.
          await tester.tap(filterNotPlayableCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Playable'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Playable' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesFilteredByPictured = [
            "Really short video",
            "230628-033813-audio learn test short video two 23-06-10",
            "audio learn test short video one",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesFilteredByPictured,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'UnselectPlayThenNotPlay' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the
          // 'UnselectPlayThenNotPlay' sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Playable' /
          // 'Not playable' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Playable' checkbox widget and verify it is
          // selected
          filterPlayableCheckboxWidgetFinder =
              find.byKey(const Key('filterPlayableCheckbox'));

          expect(
            tester.widget<Checkbox>(filterPlayableCheckboxWidgetFinder).value,
            true,
          );

          // Find the 'Not playable' checkbox widget and verify it is not
          // selected
          filterNotPlayableCheckboxWidgetFinder =
              find.byKey(const Key('filterNotPlayableCheckbox'));

          expect(
            tester
                .widget<Checkbox>(filterNotPlayableCheckboxWidgetFinder)
                .value,
            false,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Unselect Not playable then Playable checkbox in order to filter not
             playable audio. Create and then edit a named and saved 'UnselecNotPlThenPlay'
             sort filter parms. Then verifying that the corresponding sort/filter
             dropdown button item is applied to the playlist download view list
             of audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String localPlaylistTitle = 'local'; // local playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_filter_dialog_test',
            selectedPlaylistTitle: localPlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type 'UnselecNotPlThenPlay' in the 'Save as' TextField

          String saveAsTitle = 'UnselecNotPlThenPlay';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Scrolling down the sort filter dialog so that the 'Playable' /
          // 'Not playable' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Unselect the 'Not playable' checkbox

          // Find the 'Not playable' checkbox widget
          Finder filterNotPlayableCheckboxWidgetFinder =
              find.byKey(const Key('filterNotPlayableCheckbox'));

          // Tap the checkbox to unselect it.
          await tester.tap(filterNotPlayableCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Unselect the 'Playable' checkbox

          // Find the 'Playable' checkbox widget
          Finder filterPlayableCheckboxWidgetFinder =
              find.byKey(const Key('filterPlayableCheckbox'));

          // Tap the checkbox to unselect it. Since the two playable
          // related checkboxex can not be both unselected, the
          // 'Not playable' checkbox is reselected.
          await tester.tap(filterPlayableCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Playable'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Playable' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesFilteredByPictured = [
            "morning _ cinematic video",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesFilteredByPictured,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'UnselecNotPlThenPlay' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the
          // 'UnselecNotPlThenPlay' sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Playable' /
          // 'Not playable' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Playable' checkbox widget and verify it is
          // not selected
          filterPlayableCheckboxWidgetFinder =
              find.byKey(const Key('filterPlayableCheckbox'));

          expect(
            tester.widget<Checkbox>(filterPlayableCheckboxWidgetFinder).value,
            false,
          );

          // Find the 'Not playable' checkbox widget and verify it is
          // selected
          filterNotPlayableCheckboxWidgetFinder =
              find.byKey(const Key('filterNotPlayableCheckbox'));

          expect(
            tester
                .widget<Checkbox>(filterNotPlayableCheckboxWidgetFinder)
                .value,
            true,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
      });
      group('''Downloaded/Imported related checkboxes''', () {
        testWidgets(
            '''Downloaded checkbox true and Imported checkbox false in order to filter
             only the downloaded audio. Create and then edit a named and saved 'Downloaded'
             filter parms. Then verifying that the corresponding sort/filter dropdown
             button item is applied to the playlist download view list of audio.''',
            (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String localPlaylistTitle = 'local'; // local playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_filter_dialog_test',
            selectedPlaylistTitle: localPlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type 'Downloaded' in the 'Save as' TextField

          String saveAsTitle = 'Downloaded';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Scrolling down the sort filter dialog so that the 'Downloaded' /
          // 'Imported' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Unselect the 'Imported' checkbox

          // Find the 'Imported' checkbox widget
          Finder filterImportedCheckboxWidgetFinder =
              find.byKey(const Key('filterImportedCheckbox'));

          // Tap the checkbox to unselect it
          await tester.tap(filterImportedCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Downloaded'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Downloaded' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesFilteredByPictured = [
            "morning _ cinematic video",
            "Really short video",
            "audio learn test short video one",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesFilteredByPictured,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'Downloaded' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the 'Downloaded'
          // sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Downloaded' /
          // 'Imported' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Downloaded' checkbox widget and verify it is
          // selected
          final Finder filterDownloadedCheckboxWidgetFinder =
              find.byKey(const Key('filterDownloadedCheckbox'));

          expect(
            tester.widget<Checkbox>(filterDownloadedCheckboxWidgetFinder).value,
            true,
          );

          // Find the 'Imported' checkbox widget and verify it is not
          // selected
          filterImportedCheckboxWidgetFinder =
              find.byKey(const Key('filterImportedCheckbox'));

          expect(
            tester
                .widget<Checkbox>(filterImportedCheckboxWidgetFinder)
                .value,
            false,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Downloaded checkbox false and Imported checkbox true in order to filter
             only the imported audio. Create and then edit a named and saved
             'Imported' filter parms. Then verifying that the corresponding sort/filter
             dropdown button item is applied to the playlist download view list of
             audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String localPlaylistTitle = 'local'; // local playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_filter_dialog_test',
            selectedPlaylistTitle: localPlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type 'Imported' in the 'Save as' TextField

          String saveAsTitle = 'Imported';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Scrolling down the sort filter dialog so that the 'Downloaded' /
          // 'Imported' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Unselect the 'Downloaded' checkbox

          // Find the 'Downloaded' checkbox widget
          Finder filterDownloadedCheckboxWidgetFinder =
              find.byKey(const Key('filterDownloadedCheckbox'));

          // Tap the checkbox to unselect it
          await tester.tap(filterDownloadedCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Imported'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Imported' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> filteredAudioTitles = [
            "230628-033813-audio learn test short video two 23-06-10",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: filteredAudioTitles,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'Imported' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the 'Imported'
          // sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Downloaded' /
          // 'Imported' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Downloaded' checkbox widget and verify it is not
          // selected
          filterDownloadedCheckboxWidgetFinder =
              find.byKey(const Key('filterDownloadedCheckbox'));

          expect(
            tester.widget<Checkbox>(filterDownloadedCheckboxWidgetFinder).value,
            false,
          );

          // Find the 'Imported' checkbox widget and verify it is
          // selected
          final Finder filterImportedCheckboxWidgetFinder =
              find.byKey(const Key('filterImportedCheckbox'));

          expect(
            tester
                .widget<Checkbox>(filterImportedCheckboxWidgetFinder)
                .value,
            true,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Both Downloaded and Imported checkboxes true in order to filter both
             the downloaded and imported audio. Create and then edit a named and
             saved 'downlImpor' filter parms. Then verifying that the corresponding
             sort/filter dropdown button item is applied to the playlist download
             view list of audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String localPlaylistTitle = 'local'; // local playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_filter_dialog_test',
            selectedPlaylistTitle: localPlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type 'downlImpor' in the 'Save as' TextField

          String saveAsTitle = 'downlImpor';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Do not modify the default true values of the 'Downloaded' /
          // 'Imported' checkboxes

          // Scrolling down the sort filter dialog so that the 'Save' button is
          // visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'downlImpor'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'downlImpor' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesFilteredByPictured = [
            "morning _ cinematic video",
            "Really short video",
            "230628-033813-audio learn test short video two 23-06-10",
            "audio learn test short video one",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesFilteredByPictured,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'downlImpor' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the 'downlImpor'
          // sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Downloaded' /
          // 'Imported' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Downloaded' checkbox widget and verify it is
          // selected
          final Finder filterDownloadedCheckboxWidgetFinder =
              find.byKey(const Key('filterDownloadedCheckbox'));

          expect(
            tester.widget<Checkbox>(filterDownloadedCheckboxWidgetFinder).value,
            true,
          );

          // Find the 'Imported' checkbox widget and verify it is
          // selected
          final Finder filterImportedCheckboxWidgetFinder =
              find.byKey(const Key('filterImportedCheckbox'));

          expect(
            tester
                .widget<Checkbox>(filterImportedCheckboxWidgetFinder)
                .value,
            true,
          );

          // Click on the 'Cancel' button. This closes the sort/filter dialog
          // and the 'downlImpor' sort/filter dropdown button item is removed
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Unselect Downloaded then Imported checkbox in order to filter Downloaded 
             audio. Create and then edit a named and saved 'UnselectDownlThenImp' sort
             filter parms. Then verifying that the corresponding sort/filter dropdown
             button item is applied to the playlist download view list of audio.''',
            (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String localPlaylistTitle = 'local'; // local playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_filter_dialog_test',
            selectedPlaylistTitle: localPlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type 'UnselectDownlThenImp' in the 'Save as' TextField

          String saveAsTitle = 'UnselectDownlThenImp';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Scrolling down the sort filter dialog so that the 'Downloaded' /
          // 'Imported' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Unselect the 'Downloaded' checkbox

          // Find the 'Downloaded' checkbox widget
          Finder filterDownloadedCheckboxWidgetFinder =
              find.byKey(const Key('filterDownloadedCheckbox'));

          // Tap the checkbox to unselect it
          await tester.tap(filterDownloadedCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Unselect the 'Imported' checkbox

          // Find the 'Imported' checkbox widget
          Finder filterImportedCheckboxWidgetFinder =
              find.byKey(const Key('filterImportedCheckbox'));

          // Tap the checkbox to unselect it. Since the two playable
          // related checkboxex can not be both unselected, the
          // 'Downloaded' checkbox is reselected.
          await tester.tap(filterImportedCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Downloaded'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Downloaded' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesFilteredByPictured = [
            "morning _ cinematic video",
            "Really short video",
            "audio learn test short video one",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesFilteredByPictured,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'UnselectDownlThenImp' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the
          // 'UnselectDownlThenImp' sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Downloaded' /
          // 'Imported' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Downloaded' checkbox widget and verify it is
          // selected
          filterDownloadedCheckboxWidgetFinder =
              find.byKey(const Key('filterDownloadedCheckbox'));

          expect(
            tester.widget<Checkbox>(filterDownloadedCheckboxWidgetFinder).value,
            true,
          );

          // Find the 'Imported' checkbox widget and verify it is not
          // selected
          filterImportedCheckboxWidgetFinder =
              find.byKey(const Key('filterImportedCheckbox'));

          expect(
            tester
                .widget<Checkbox>(filterImportedCheckboxWidgetFinder)
                .value,
            false,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
        testWidgets(
            '''Unselect Imported then Downloaded checkbox in order to filter imported
             audio. Create and then edit a named and saved 'UnselectImpThenDownl'
             sort filter parms. Then verifying that the corresponding sort/filter
             dropdown button item is applied to the playlist download view list
             of audio.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );

          const String localPlaylistTitle = 'local'; // local playlist

          await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
            tester: tester,
            savedTestDataDirName: 'audio_filter_dialog_test',
            selectedPlaylistTitle: localPlaylistTitle,
          );

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // Find the sort/filter audio menu item and tap on it to
          // open the audio sort filter dialog
          await tester.tap(
              find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
          await tester.pumpAndSettle();

          // Type 'UnselectImpThenDownl' in the 'Save as' TextField

          String saveAsTitle = 'UnselectImpThenDownl';

          await tester.enterText(
              find.byKey(const Key('sortFilterSaveAsUniqueNameTextField')),
              saveAsTitle);
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Scrolling down the sort filter dialog so that the 'Downloaded' /
          // 'Imported' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Unselect the 'Imported' checkbox

          // Find the 'Imported' checkbox widget
          Finder filterImportedCheckboxWidgetFinder =
              find.byKey(const Key('filterImportedCheckbox'));

          // Tap the checkbox to unselect it.
          await tester.tap(filterImportedCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Unselect the 'Downloaded' checkbox

          // Find the 'Downloaded' checkbox widget
          Finder filterDownloadedCheckboxWidgetFinder =
              find.byKey(const Key('filterDownloadedCheckbox'));

          // Tap the checkbox to unselect it. Since the two playable
          // related checkboxex can not be both unselected, the
          // 'Imported' checkbox is reselected.
          await tester.tap(filterDownloadedCheckboxWidgetFinder);
          await tester.pumpAndSettle();

          // Click on the "Save" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the newly created sort/filter parms
          await tester
              .tap(find.byKey(const Key('saveSortFilterOptionsTextButton')));
          await tester.pumpAndSettle();

          // Tap the 'Toggle List' button to avoid displaying the list
          // of playlists which may hide the audio title we want to
          // tap on
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle();

          // Now verify the playlist download view state with the 'Downloaded'
          // sort/filter parms applied

          // Verify that the dropdown button has been updated with the
          // 'Downloaded' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: saveAsTitle,
          );

          // And verify the order of the playlist audio titles

          List<String> audioTitlesFilteredByPictured = [
            "230628-033813-audio learn test short video two 23-06-10",
          ];

          IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
            tester: tester,
            audioOrPlaylistTitlesOrderedLst: audioTitlesFilteredByPictured,
          );

          // Now tap on the current dropdown button item to open the dropdown
          // button items list

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          await tester.tap(dropDownButtonTextFinder);
          await tester.pumpAndSettle();

          // And find the 'UnselectImpThenDownl' sort/filter item
          final Finder titleAscDropDownTextFinder = find.text(saveAsTitle).last;
          await tester.tap(titleAscDropDownTextFinder);
          await tester.pumpAndSettle();

          // Now open the audio popup menu in order to edit the
          // 'UnselectImpThenDownl' sort/filter parms
          final Finder dropdownItemEditIconButtonFinder = find.byKey(
              const Key('sort_filter_parms_dropdown_item_edit_icon_button'));
          await tester.tap(dropdownItemEditIconButtonFinder);
          await tester.pumpAndSettle();

          // Scrolling down the sort filter dialog so that the 'Downloaded' /
          // 'Imported' checkbox are visible and so accessible by the integration test
          await tester.drag(
            find.byType(AudioSortFilterDialog),
            const Offset(
                0, -300), // Negative value for vertical drag to scroll down
          );
          await tester.pumpAndSettle();

          // Find the 'Downloaded' checkbox widget and verify it is
          // not selected
          filterDownloadedCheckboxWidgetFinder =
              find.byKey(const Key('filterDownloadedCheckbox'));

          expect(
            tester.widget<Checkbox>(filterDownloadedCheckboxWidgetFinder).value,
            false,
          );

          // Find the 'Imported' checkbox widget and verify it is
          // selected
          filterImportedCheckboxWidgetFinder =
              find.byKey(const Key('filterImportedCheckbox'));

          expect(
            tester
                .widget<Checkbox>(filterImportedCheckboxWidgetFinder)
                .value,
            true,
          );

          // Click on the "Cancel" button. This closes the sort/filter dialog
          // and updates the sort/filter playlist download view dropdown
          // button with the modified sort/filter parms
          await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
          await tester.pumpAndSettle();

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kApplicationPathWindowsTest,
          );
        });
      });
    });
  });
}

Future<void> _selectSortByOption({
  required WidgetTester tester,
  required String audioSortOption,
}) async {
  await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
  await tester.pumpAndSettle();

  await tester.tap(find.text(audioSortOption));
  await tester.pumpAndSettle();
}

Future<void> _addAudioFilterStrAndClickOnPlusIconButton({
  required WidgetTester tester,
  required String audioFilterString,
}) async {
  Finder audioTitleSearchSentenceTextFieldFinder =
      find.byKey(const Key('audioTitleSearchSentenceTextField'));

  await tester.enterText(
    audioTitleSearchSentenceTextFieldFinder,
    audioFilterString,
  );
  await tester.pumpAndSettle();

  // And now click on the add icon button
  await tester.tap(find.byKey(const Key('addSentenceIconButton')));
  await tester.pumpAndSettle();
}

Future<void> _verifyOrderOfPlaylistAudioComments({
  required WidgetTester tester,
  required List<String> expectedCommentTitles,
  required List<String> expectedCommentTimes,
}) async {
  // Find the playlist comment list dialog widget
  Finder commentListDialogFinder = find.byType(PlaylistCommentListDialog);

  // Find the list body containing the comments
  Finder listFinder = find.descendant(
      of: commentListDialogFinder, matching: find.byType(ListBody));

  // Find all the list items
  Finder itemsFinder = find.descendant(
      // 3 GestureDetector per comment item
      of: listFinder,
      matching: find.byType(GestureDetector));

  int gestureDectectorNumberByCommentLine = 3;

  // Since there are 3 GestureDetector per comment item, we need to
  // multiply the comment line index by 3 to get the right index
  // of "Interview de Chat GPT  - IA, intelligence, philosophie,
  // géopolitique, post-vérité..."

  for (int i = 0; i < expectedCommentTitles.length; i++) {
    // Since each comment is composed of multiple GestureDetectors,
    // calculate the index for the specific comment.
    final Finder commentTitleFinder = find.descendant(
      of: itemsFinder.at(i * gestureDectectorNumberByCommentLine),
      matching: find.byKey(const Key('commentTitleKey')),
    );

    final Finder commentTimeFinder = find.descendant(
      of: itemsFinder.at(i * gestureDectectorNumberByCommentLine),
      matching: find.byKey(const Key('commentStartPositionKey')),
    );

    // Verify the comment title text
    expect(commentTitleFinder, findsOneWidget);
    expect(
        tester.widget<Text>(commentTitleFinder).data, expectedCommentTitles[i]);

    // Verify the comment time text
    expect(commentTimeFinder, findsOneWidget);
    expect(
        tester.widget<Text>(commentTimeFinder).data, expectedCommentTimes[i]);
  }

  // Tap on the Close button to close the playlist comment dialog
  await tester
      .tap(find.byKey(const Key('playlistCommentListCloseDialogTextButton')));
  await tester.pumpAndSettle();
}

Future<void> _verifyAudioPopupMenuItemState({
  required WidgetTester tester,
  required String menuItemKey,
  required bool isEnabled,
  bool tapOnAudioPopupMenuButton = true,
}) async {
  if (tapOnAudioPopupMenuButton) {
    // Now open the audio popup menu
    await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
    await tester.pumpAndSettle();
  }

  // Retrieve the PopupMenuItem widget
  final PopupMenuItem menuItem =
      tester.widget<PopupMenuItem>(find.byKey(Key(menuItemKey)));

  // Check if the menu item is disabled
  expect(menuItem.enabled, isEnabled);
}

void _verifyAudioSortFilterParmsNameStoredInPlaylistJsonFile({
  required String selectedPlaylistTitle,
  required String expectedAudioSortFilterParmsName,
  required List<AudioLearnAppViewType> audioLearnAppViewTypeLst,
  required AudioPlayingOrder audioPlayingOrder,
}) {
  final String selectedPlaylistPath = path.join(
    "$kApplicationPathWindowsTest${path.separator}playlists",
    selectedPlaylistTitle,
  );

  final selectedPlaylistFilePathName = path.join(
    selectedPlaylistPath,
    '$selectedPlaylistTitle.json',
  );

  // Load playlist from the json file
  Playlist loadedSelectedPlaylist = JsonDataService.loadFromFile(
    jsonPathFileName: selectedPlaylistFilePathName,
    type: Playlist,
  );

  String expectedValue = '';

  if (audioLearnAppViewTypeLst
      .contains(AudioLearnAppViewType.playlistDownloadView)) {
    expectedValue = expectedAudioSortFilterParmsName;
  }

  expect(loadedSelectedPlaylist.audioSortFilterParmsNameForPlaylistDownloadView,
      expectedValue);

  if (audioLearnAppViewTypeLst
      .contains(AudioLearnAppViewType.audioPlayerView)) {
    expectedValue = expectedAudioSortFilterParmsName;
  } else {
    expectedValue = '';
  }

  expect(loadedSelectedPlaylist.audioSortFilterParmsNameForAudioPlayerView,
      expectedValue);

  expect(
    loadedSelectedPlaylist.audioPlayingOrder,
    audioPlayingOrder,
  );
}

/// The PlaylistAddRemoveSortFilterOptionsDialog only display the
/// 'For "Download Audio" screen' and 'For "Play Audio" screen' checkboxes
/// if the {sortFilterParmsName} is not already saved in the playlist
/// for the screen.
Future<void> _verifySaveSortFilterParmsToPlaylistDialog({
  required WidgetTester tester,
  required String playlistTitle,
  required String sortFilterParmsName,
  required bool isForPlaylistDownloadViewCheckboxDisplayed,
  required bool isForAudioPlayerViewCheckboxDisplayed,
}) async {
  // Now open the audio popup menu
  await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
  await tester.pumpAndSettle();

  // And open the 'Save sort/filter parameters to playlist' dialog
  await tester.tap(find
      .byKey(const Key('save_sort_and_filter_audio_parms_in_playlist_item')));
  await tester.pumpAndSettle();

  expect(find.text(playlistTitle), findsOneWidget);
  expect(find.text(sortFilterParmsName), findsOneWidget);

  if (isForPlaylistDownloadViewCheckboxDisplayed) {
    expect(
      find.byKey(const Key('playlistDownloadViewCheckbox')),
      findsOneWidget,
    );
  } else {
    expect(
      find.byKey(const Key('playlistDownloadViewCheckbox')),
      findsNothing,
    );
  }

  if (isForAudioPlayerViewCheckboxDisplayed) {
    expect(
      find.byKey(const Key('audioPlayerViewCheckbox')),
      findsOneWidget,
    );
  } else {
    expect(
      find.byKey(const Key('audioPlayerViewCheckbox')),
      findsNothing,
    );
  }

  // Finally, click on cancel button
  await tester
      .tap(find.byKey(const Key('sortFilterOptionsToPlaylistCancelButton')));
  await tester.pumpAndSettle();
}

Future<void> _selectAndRemoveSortFilterParmsToPlaylist({
  required WidgetTester tester,
  required String sortFilterParmsName,
  bool isOnPlaylistDownloadViewCheckboxDisplayed = false,
  bool tapOnRemoveFromPlaylistDownloadViewCheckbox = false,
  bool isOnAudioPlayerViewCheckboxDisplayed = false,
  bool tapOnRemoveFromAudioPlayerViewCheckbox = false,
}) async {
  // Tap on the current dropdown button item to open the dropdown
  // button items list

  Finder dropDownButtonFinder =
      find.byKey(const Key('sort_filter_parms_dropdown_button'));

  Finder dropDownButtonTextFinder = find.descendant(
    of: dropDownButtonFinder,
    matching: find.byType(Text),
  );

  await tester.tap(dropDownButtonTextFinder);
  await tester.pumpAndSettle();

  // Find and select the sort filter parms item
  Finder titleAscDropDownTextFinder = find.text(sortFilterParmsName).last;
  await tester.tap(titleAscDropDownTextFinder);
  await tester.pumpAndSettle();

  // Now open the audio popup menu
  await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
  await tester.pumpAndSettle();

  // And open the 'Remove sort/filter parameters from playlist' dialog
  await tester.tap(find.byKey(
      const Key('remove_sort_and_filter_audio_parms_from_playlist_item')));
  await tester.pumpAndSettle();

  if (isOnPlaylistDownloadViewCheckboxDisplayed) {
    expect(
      find.byKey(const Key('playlistDownloadViewCheckbox')),
      findsOneWidget,
    );

    if (tapOnRemoveFromPlaylistDownloadViewCheckbox) {
      // Select the 'On "Download Audio" screen' checkbox
      await tester.tap(find.byKey(const Key('playlistDownloadViewCheckbox')));
      await tester.pumpAndSettle();
    }
  } else {
    expect(
      find.byKey(const Key('playlistDownloadViewCheckbox')),
      findsNothing,
    );
  }

  if (isOnAudioPlayerViewCheckboxDisplayed) {
    expect(
      find.byKey(const Key('audioPlayerViewCheckbox')),
      findsOneWidget,
    );

    if (tapOnRemoveFromAudioPlayerViewCheckbox) {
      // Select the 'On "Play Audio" screen' checkbox
      await tester.tap(find.byKey(const Key('audioPlayerViewCheckbox')));
      await tester.pumpAndSettle();
    }
  } else {
    expect(
      find.byKey(const Key('audioPlayerViewCheckbox')),
      findsNothing,
    );
  }

  // Finally, click on save button
  await tester
      .tap(find.byKey(const Key('saveSortFilterOptionsToPlaylistSaveButton')));
  await tester.pumpAndSettle();
}

Future<void> _switchToPlaylist({
  required WidgetTester tester,
  required String playlistTitle,
}) async {
  // Now select the local playlist in order to apply the created
  // sort/filter parms to it

  // Tap on audio playplaylist button to expand the
  // list of playlists
  await tester.tap(find.byKey(const Key('playlist_toggle_button')));
  await tester.pumpAndSettle(const Duration(milliseconds: 200));

  // Select the 'local' playlist

  await IntegrationTestUtil.selectPlaylist(
    tester: tester,
    playlistToSelectTitle: playlistTitle,
  );

  // Tap on audio player view playlist button to contract the
  // list of playlists
  await tester.tap(find.byKey(const Key('playlist_toggle_button')));
  await tester.pumpAndSettle(const Duration(milliseconds: 200));
}

Future<void> _verifyAudioPlayableList({
  required WidgetTester tester,
  required String currentAudioTitle,
  required String sortFilterParmsName,
  required List<String> audioTitlesLst,
}) async {
  // Going to the audio player view
  Finder appScreenNavigationButton =
      find.byKey(const ValueKey('audioPlayerViewIconButton'));
  await tester.tap(appScreenNavigationButton);
  await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
    tester: tester,
  );

  // Now we open the AudioPlayableListDialog
  // and verify the the displayed audio titles

  await tester.tap(find.text(currentAudioTitle));
  await tester.pumpAndSettle();

  RichText dialogTitle = tester.widget<RichText>(
      find.byKey(const ValueKey('audioPlayableListDialogTitle')));

  // Extract the main TextSpan
  final TextSpan textSpan = dialogTitle.text as TextSpan;

  // Verify the main text content
  expect(textSpan.text, 'Select an Audio'); // Replace with actual expected text

  // Verify the nested TextSpan content (children)
  final TextSpan nestedTextSpan = textSpan.children![1] as TextSpan;

  expect(nestedTextSpan.text, "($sortFilterParmsName)");

  IntegrationTestUtil.checkAudioTitlesOrderInListBody(
    tester: tester,
    audioTitlesOrderLst: audioTitlesLst,
  );

  // Tap on the Close button to close the AudioPlayableListDialog
  await tester.tap(find.byKey(const Key('closeTextButton')));
  await tester.pumpAndSettle();
}

Future<void> _removeSortingItem({
  required WidgetTester tester,
  required String sortingItemName,
}) async {
  // Find the Text with sortingItemName which is now located in the
  // selected sort parameters ListView
  Finder textFinder = find.descendant(
    of: find.byKey(const Key('selectedSortingOptionsListView')),
    matching: find.text(sortingItemName),
  );

  // Then find the ListTile ancestor of the sortingItemName Text
  // widget. The ascending/descending and remove icon buttons are
  // contained in their ListTile ancestor
  Finder listTileFinder = find.ancestor(
    of: textFinder,
    matching: find.byType(ListTile),
  );

  // Now, within that ListTile, find the sort remove IconButton
  // with key 'removeSortingOptionIconButton'
  Finder iconButtonFinder = find.descendant(
    of: listTileFinder,
    matching: find.byKey(const Key('removeSortingOptionIconButton')),
  );

  // Tap on the removeSortingOptionIconButton
  await tester.tap(iconButtonFinder);
  await tester.pumpAndSettle();
}

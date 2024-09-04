import 'package:audiolearn/services/json_data_service.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/views/widgets/playlist_comment_list_dialog.dart';
import 'package:audiolearn/views/widgets/playlist_add_remove_sort_filter_options_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:audiolearn/models/playlist.dart';
import 'package:path/path.dart' as path;
import 'package:audiolearn/constants.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:audiolearn/main.dart' as app;

import 'integration_test_util.dart';

/// This integration test contains the integration tests groups for the
/// sort/filter parms testing. The groups are included in the plalist download
/// view or in the audio player view integration test.
///
/// So, if you excute those two integration tests, you do not need to execute
/// this integration test !
void main() {
  playlistDownloadViewSortFilterIntregrationTest();
  audioPlayerViewSortFilterIntregrationTest();
}

void audioPlayerViewSortFilterIntregrationTest() {
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

      // select the Audio duration sort option and tapp on it to add
      // it to the sort option list
      await tester.tap(find.text('Audio duration'));
      await tester.pumpAndSettle();

      // Use the custom finder to find the first clear IconButton.
      // Then tap on it in order to suppress the Audio download
      // date sort option
      await tester
          .tap(IntegrationTestUtil.findIconButtonWithIcon(Icons.clear).first);
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
        '''Menu Clear sort/filter parameters history execution verifying that
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Change the SF parms in in the dropdown button list to 'Title asc'
           and then verify its application. Then go to the audio player view
           and there verify that the order of the audios displayed in the
           playable audio list dialog is not sorted according to ^Title asc'
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_three_playlists_test",
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

      // And verify the order of the playlist audio titles

      List<String> audioTitlesSortedByTitleAscending = [
        "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        "La résilience insulaire par Fiona Roche",
        "La surpopulation mondiale par Jancovici et Barrau",
        "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        "Les besoins artificiels par R.Keucheyan"
      ];

      IntegrationTestUtil.checkAudioTitlesOrderInListTile(
        tester: tester,
        audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
      );

      // Then go to the audio player view
      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Now we open the AudioPlayableListDialogWidget
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
        "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
      ];

      IntegrationTestUtil.checkAudioTitlesOrderInListBody(
        tester: tester,
        audioTitlesOrderLst:
            audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
      );

      // Tap on the Close button to close the AudioPlayableListDialogWidget
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

      // Verify that "Title asc" was correctly saved in the playlist
      // json file for the audio player view only.
      verifyAudioSortFilterParmsNameStoredInPlaylistJsonFile(
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

      // Now we open the AudioPlayableListDialogWidget
      // and verify the the displayed audio titles

      await tester.tap(find
          .text("Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik\n13:39"));
      await tester.pumpAndSettle();

      IntegrationTestUtil.checkAudioTitlesOrderInListBody(
        tester: tester,
        audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
      );

      // Tap on the Close button to close the AudioPlayableListDialogWidget
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

      // Re-opening again the AudioPlayableListDialogWidget in order to
      // change the audio playing order

      await tester.tap(nextAudioTextFinder);
      await tester.pumpAndSettle();

      // And tap on the play descending order icon button in order to change
      // it to play ascending order
      await tester.tap(
          find.byKey(const Key('play_order_ascending_or_descending_button')));
      await tester.pumpAndSettle();

      // Tap on the Close button to close the AudioPlayableListDialogWidget
      await tester.tap(find.byKey(const Key('closeTextButton')));
      await tester.pumpAndSettle();

      // Verify that the audioPlayingOrder was modified and saved in the
      // playlist
      verifyAudioSortFilterParmsNameStoredInPlaylistJsonFile(
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Click twice on the <| go to start button in order to select the previous
           playable audio. First the 'Title asc' SF parms selecting only audio
           player view SF parms name of the 'S8 audio' playlist json file.
        
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_three_playlists_test",
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

      // Then go to the audio player view
      final Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

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

      // Opening the AudioPlayableListDialogWidget in order to change
      // the descending audio playing order to ascending

      await tester.tap(nextAudioTextFinder);
      await tester.pumpAndSettle();

      // And tap on the play descending order icon button in order to change
      // it to play ascending order
      await tester.tap(
          find.byKey(const Key('play_order_ascending_or_descending_button')));
      await tester.pumpAndSettle();

      // Tap on the Close button to close the AudioPlayableListDialogWidget
      await tester.tap(find.byKey(const Key('closeTextButton')));
      await tester.pumpAndSettle();

      // Verify that the audioPlayingOrder was modified and saved in the
      // playlist
      verifyAudioSortFilterParmsNameStoredInPlaylistJsonFile(
        selectedPlaylistTitle: 'S8 audio',
        expectedAudioSortFilterParmsName: 'Title asc',
        audioLearnAppViewTypeLst: [AudioLearnAppViewType.audioPlayerView],
        audioPlayingOrder: AudioPlayingOrder.ascending,
      );

      // Now we tap twice on the |< button in order select the previous
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
}

void playlistDownloadViewSortFilterIntregrationTest() {
  group('Sort/filter playlist download view tests', () {
    group('Audio sort filter dialog tests ', () {
      testWidgets(
          '''Menu Clear sort/filter parameters history execution verifying
           that the confirm dialog is displayed in the playlist download
           view.''', (WidgetTester tester) async {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
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

        await app.main(['test']);
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
            const Key('clear_sort_and_filter_audio_parms_history_menu_item')));
        await tester.pumpAndSettle();

        // Verify that the confirm action dialog is displayed
        // with the expected text
        expect(
            find.text('Clear sort/filter parameters history'), findsOneWidget);
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets('''Sort filter audio dialog, tapping on clear sort/filter
           parameters history icon button and verifying that the confirm
           warning is displayed in the audio player view.''',
          (WidgetTester tester) async {
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
        expect(
            find.text('Clear sort/filter parameters history'), findsOneWidget);
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
        expect(
            find.text('Clear sort/filter parameters history'), findsOneWidget);
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
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

        await app.main(['test']);
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

        // Now select the 'Audio title'item in the 'Sort by' dropdown button

        await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Audio title'));
        await tester.pumpAndSettle();

        // Then delete the "Audio download date" descending sort option

        // Find the Text with "Audio downl date" which is located in the
        // selected sort parameters ListView
        final Finder texdtFinder = find.descendant(
          of: find.byKey(const Key('selectedSortingOptionsListView')),
          matching: find.text('Audio downl date'),
        );

        // Then find the ListTile ancestor of the 'Audio downl date' Text
        // widget. The ascending/descending and remove icon buttons are
        // contained in their ListTile ancestor
        final Finder listTileFinder = find.ancestor(
          of: texdtFinder,
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
          "Les besoins artificiels par R.Keucheyan"
        ];

        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
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
        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
        );

        // Now, selecting 'Default' dropdown button item to apply the
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
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        ];

        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst:
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
        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst:
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

        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
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
        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets('''Click on 'Default' dropdown button item edit icon button to
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
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

        await app.main(['test']);
        await tester.pumpAndSettle();

        final Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        final Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        // Tap twice on the dropdown button 'Default' item so that its edit
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

        // Now select the 'Audio title'item in the 'Sort by' dropdown button

        await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Audio title'));
        await tester.pumpAndSettle();

        // Then delete the "Audio download date" descending sort option

        // Find the Text with "Audio downl date" which is located in the
        // selected sort parameters ListView
        final Finder texdtFinder = find.descendant(
          of: find.byKey(const Key('selectedSortingOptionsListView')),
          matching: find.text('Audio downl date'),
        );

        // Then find the ListTile ancestor of the 'Audio downl date' Text
        // widget. The ascending/descending and remove icon buttons are
        // contained in their ListTile ancestor
        final Finder listTileFinder = find.ancestor(
          of: texdtFinder,
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
          "Les besoins artificiels par R.Keucheyan"
        ];

        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
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
        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets('''Change language and verify impact on sort/filter dropdown
          button default title.''', (WidgetTester tester) async {
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
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        ];

        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst:
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

        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst:
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

        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
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

        await app.main(['test']);
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

        // Now select the 'Audio title'item in the 'Sort by' dropdown button

        await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Audio title'));
        await tester.pumpAndSettle();

        // Then delete the "Audio download date" descending sort option

        // Find the Text with "Audio downl date" which is located in the
        // selected sort parameters ListView
        Finder texdtFinder = find.descendant(
          of: find.byKey(const Key('selectedSortingOptionsListView')),
          matching: find.text('Audio downl date'),
        );

        // Then find the ListTile ancestor of the 'Audio downl date' Text
        // widget. The ascending/descending and remove icon buttons are
        // contained in their ListTile ancestor
        Finder listTileFinder = find.ancestor(
          of: texdtFinder,
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
          "Les besoins artificiels par R.Keucheyan"
        ];

        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
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

        // Find the Text with 'Audio title' which is now located in the
        // selected sort parameters ListView
        texdtFinder = find.descendant(
          of: find.byKey(const Key('selectedSortingOptionsListView')),
          matching: find.text('Audio title'),
        );

        // Then find the ListTile ancestor of the 'Audio title' Text
        // widget. The ascending/descending and remove icon buttons are
        // contained in their ListTile ancestor
        listTileFinder = find.ancestor(
          of: texdtFinder,
          matching: find.byType(ListTile),
        );

        // Now, within that ListTile, find the sort option ascending/
        // descending IconButton with key 'sort_ascending_or_descending_button'
        iconButtonFinder = find.descendant(
          of: listTileFinder,
          matching:
              find.byKey(const Key('sort_ascending_or_descending_button')),
        );

        // Tap on the ascending/descending icon button to convert ascending
        // to descending sort order. So, the 'Title asc? sort/filter parms
        // will in fact be descending !!
        await tester.tap(iconButtonFinder);
        await tester.pumpAndSettle();

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

        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
        );

        // Now go to audio player view
        Finder appScreenNavigationButton =
            find.byKey(const ValueKey('audioPlayerViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

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
        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_filter_title_bug_test",
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

        await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Audio title'));
        await tester.pumpAndSettle();

        // Then delete the "Audio download date" descending sort option

        // Find the Text with "Audio downl date" which is located in the
        // selected sort parameters ListView
        final Finder texdtFinder = find.descendant(
          of: find.byKey(const Key('selectedSortingOptionsListView')),
          matching: find.text('Last listened date/time'),
        );

        // Then find the ListTile ancestor of the 'Audio downl date' Text
        // widget. The ascending/descending and remove icon buttons are
        // contained in their ListTile ancestor
        final Finder listTileFinder = find.ancestor(
          of: texdtFinder,
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

        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_three_playlists_test",
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
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        ];

        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst: audioTitlesSortedByDateTimeListenedDescending,
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
        Finder texdtFinder = find.descendant(
          of: find.byKey(const Key('selectedSortingOptionsListView')),
          matching: find.text('Audio downl date'),
        );

        // Then find the ListTile ancestor of the 'Audio downl date' Text
        // widget. The ascending/descending and remove icon buttons are
        // contained in their ListTile ancestor
        Finder listTileFinder = find.ancestor(
          of: texdtFinder,
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

        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst: audioTitlesSortedByDateTimeListenedDescending,
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
        texdtFinder = find.descendant(
          of: find.byKey(const Key('selectedSortingOptionsListView')),
          matching: find.text('Last listened date/time'),
        );

        // Then find the ListTile ancestor of the 'Audio title' Text
        // widget. The ascending/descending and remove icon buttons are
        // contained in their ListTile ancestor
        listTileFinder = find.ancestor(
          of: texdtFinder,
          matching: find.byType(ListTile),
        );

        // Now, within that ListTile, find the sort option ascending/
        // descending IconButton with key 'sort_ascending_or_descending_button'
        iconButtonFinder = find.descendant(
          of: listTileFinder,
          matching:
              find.byKey(const Key('sort_ascending_or_descending_button')),
        );

        // Tap on the ascending/descending icon button to convert ascending
        // to descending sort order. So, the 'Title asc? sort/filter parms
        // will in fact be descending !!
        await tester.tap(iconButtonFinder);
        await tester.pumpAndSettle();

        // Then delete the "Audio download date" descending sort option

        // Find the Text with "Audio downl date" which is located in the
        // selected sort parameters ListView
        texdtFinder = find.descendant(
          of: find.byKey(const Key('selectedSortingOptionsListView')),
          matching: find.text('Audio downl date'),
        );

        // Then find the ListTile ancestor of the 'Audio downl date' Text
        // widget. The ascending/descending and remove icon buttons are
        // contained in their ListTile ancestor
        listTileFinder = find.ancestor(
          of: texdtFinder,
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
          "Les besoins artificiels par R.Keucheyan",
        ];

        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst: audioTitlesSortedByDateTimeListenedAscending,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
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

        await app.main(['test']);
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
        Finder texdtFinder = find.descendant(
          of: find.byKey(const Key('selectedSortingOptionsListView')),
          matching: find.text('Audio downl date'),
        );

        // Then find the ListTile ancestor of the 'Audio downl date' Text
        // widget. The ascending/descending and remove icon buttons are
        // contained in their ListTile ancestor
        Finder listTileFinder = find.ancestor(
          of: texdtFinder,
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
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        ];

        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
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
        texdtFinder = find.descendant(
          of: find.byKey(const Key('selectedSortingOptionsListView')),
          matching: find.text('Last listened date/time'),
        );

        // Then find the ListTile ancestor of the 'Audio title' Text
        // widget. The ascending/descending and remove icon buttons are
        // contained in their ListTile ancestor
        listTileFinder = find.ancestor(
          of: texdtFinder,
          matching: find.byType(ListTile),
        );

        // Now, within that ListTile, find the sort option ascending/
        // descending IconButton with key 'sort_ascending_or_descending_button'
        iconButtonFinder = find.descendant(
          of: listTileFinder,
          matching:
              find.byKey(const Key('sort_ascending_or_descending_button')),
        );

        // Tap on the ascending/descending icon button to convert ascending
        // to descending sort order. So, the 'Title asc? sort/filter parms
        // will in fact be descending !!
        await tester.tap(iconButtonFinder);
        await tester.pumpAndSettle();

        // Then delete the "Audio download date" descending sort option

        // Find the Text with "Audio downl date" which is located in the
        // selected sort parameters ListView
        texdtFinder = find.descendant(
          of: find.byKey(const Key('selectedSortingOptionsListView')),
          matching: find.text('Audio downl date'),
        );

        // Then find the ListTile ancestor of the 'Audio downl date' Text
        // widget. The ascending/descending and remove icon buttons are
        // contained in their ListTile ancestor
        listTileFinder = find.ancestor(
          of: texdtFinder,
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
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        ];

        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
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
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        ];

        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
    group('Applying unnamed sort/filter parms', () {
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
            rootPath: kPlaylistDownloadRootPathWindowsTest,
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

          await app.main(['test']);
          await tester.pumpAndSettle();

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
          final Finder texdtFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Audio downl date'),
          );

          // Then find the ListTile ancestor of the 'Audio downl date' Text
          // widget. The ascending/descending and remove icon buttons are
          // contained in their ListTile ancestor
          final Finder listTileFinder = find.ancestor(
            of: texdtFinder,
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
            "Les besoins artificiels par R.Keucheyan"
          ];

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
          );

          // Now go to audio player view
          Finder appScreenNavigationButton =
              find.byKey(const ValueKey('audioPlayerViewIconButton'));
          await tester.tap(appScreenNavigationButton);
          await tester.pumpAndSettle();

          // Now we open the AudioPlayableListDialogWidget
          // and verify the the displayed audio titles

          await tester
              .tap(find.text("La résilience insulaire par Fiona Roche\n13:35"));
          await tester.pumpAndSettle();

          // Tap on the Close button to close the AudioPlayableListDialogWidget
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
          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
          );

          // Now, selecting 'Default' dropdown button item to apply the
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
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          ];

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst:
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
          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst:
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

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
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
          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
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
            rootPath: kPlaylistDownloadRootPathWindowsTest,
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

          await app.main(['test']);
          await tester.pumpAndSettle();

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
          Finder texdtFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Audio downl date'),
          );

          // Then find the ListTile ancestor of the 'Audio downl date' Text
          // widget. The ascending/descending and remove icon buttons are
          // contained in their ListTile ancestor
          Finder listTileFinder = find.ancestor(
            of: texdtFinder,
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
            "Les besoins artificiels par R.Keucheyan"
          ];

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
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

          // Now select the 'Audio title'item in the 'Sort by' dropdown button

          await tester
              .tap(find.byKey(const Key('sortingOptionDropdownButton')));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Audio title'));
          await tester.pumpAndSettle();

          // Tap on the ascending icon button in order to set descending
          // sort option

          // Find the Text with 'Audio title' which is now located in the
          // selected sort parameters ListView
          texdtFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Audio title'),
          );

          // Then find the ListTile ancestor of the 'Audio title' Text
          // widget. The ascending/descending and remove icon buttons are
          // contained in their ListTile ancestor
          listTileFinder = find.ancestor(
            of: texdtFinder,
            matching: find.byType(ListTile),
          );

          // Now, within that ListTile, find the sort option ascending/
          // descending IconButton with key 'sort_ascending_or_descending_button'
          iconButtonFinder = find.descendant(
            of: listTileFinder,
            matching:
                find.byKey(const Key('sort_ascending_or_descending_button')),
          );

          // Tap on the ascending/descending icon button to convert ascending
          // to descending sort order
          await tester.tap(iconButtonFinder);
          await tester.pumpAndSettle();

          // Then delete the "Audio download date" descending sort option

          // Find the Text with "Audio downl date" which is located in the
          // selected sort parameters ListView
          texdtFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Audio downl date'),
          );

          // Then find the ListTile ancestor of the 'Audio downl date' Text
          // widget. The ascending/descending and remove icon buttons are
          // contained in their ListTile ancestor
          listTileFinder = find.ancestor(
            of: texdtFinder,
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

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
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
          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
          );

          // Now, selecting 'Default' dropdown button item to apply the
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
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          ];

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst:
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
          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst:
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

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
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
          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
        testWidgets(
            '''Click on 'Default' dropdown button item edit icon button to
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
            rootPath: kPlaylistDownloadRootPathWindowsTest,
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

          await app.main(['test']);
          await tester.pumpAndSettle();

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          // Tap twice on the dropdown button 'Default' item so that its edit
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

          // Now select the 'Audio title'item in the 'Sort by' dropdown button

          await tester
              .tap(find.byKey(const Key('sortingOptionDropdownButton')));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Audio title'));
          await tester.pumpAndSettle();

          // Then delete the "Audio download date" descending sort option

          // Find the Text with "Audio downl date" which is located in the
          // selected sort parameters ListView
          final Finder texdtFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Audio downl date'),
          );

          // Then find the ListTile ancestor of the 'Audio downl date' Text
          // widget. The ascending/descending and remove icon buttons are
          // contained in their ListTile ancestor
          final Finder listTileFinder = find.ancestor(
            of: texdtFinder,
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
            "Les besoins artificiels par R.Keucheyan"
          ];

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
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
          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
        testWidgets('''Change language and verify impact on sort/filter dropdown
                       button default title.''', (WidgetTester tester) async {
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
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          ];

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst:
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

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst:
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

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
        testWidgets(
            '''Apply and finally delete an unamed ascending sort/filter parms after
               having selected it in a second playlist.''',
            (WidgetTester tester) async {
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
          final Finder texdtFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Audio downl date'),
          );

          // Then find the ListTile ancestor of the 'Audio downl date' Text
          // widget. The ascending/descending and remove icon buttons are
          // contained in their ListTile ancestor
          final Finder listTileFinder = find.ancestor(
            of: texdtFinder,
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

          // Tap on audio player view playlist button to expand the
          // list of playlists
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Find the playlist to select ListTile Text widget
          Finder playlistToSelectListTileTextWidgetFinder = find.text('local');

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

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
          );

          // Verify that the dropdown button has been updated with the
          // 'applied' sort/filter parms selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: appliedEnglishTitle,
          );

          // Then reselect the 'S8 audio' playlist

          // Tap on audio player view playlist button to expand the
          // list of playlists
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Find the playlist to select ListTile Text widget
          playlistToSelectListTileTextWidgetFinder = find.text('S8 audio');

          // Then obtain the playlist ListTile widget enclosing the Text widget
          // by finding its ancestor
          playlistToSelectListTileWidgetFinder = find.ancestor(
            of: playlistToSelectListTileTextWidgetFinder,
            matching: find.byType(ListTile),
          );

          // Now find the Checkbox widget located in the playlist ListTile
          // and tap on it to select the playlist
          playlistToSelectListTileCheckboxWidgetFinder = find.descendant(
            of: playlistToSelectListTileWidgetFinder,
            matching: find.byType(Checkbox),
          );

          // Tap the ListTile Playlist checkbox to select it
          await tester.tap(playlistToSelectListTileCheckboxWidgetFinder);
          await tester.pumpAndSettle();

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
            "Les besoins artificiels par R.Keucheyan"
          ];

          // And verify the order of the playlist audio titles
          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
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
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          ];

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Now return to local playlist and verify that the 'default'
          // sort/filter parms is applied

          // Tap on audio player view playlist button to expand the
          // list of playlists
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Tap on audio player view playlist button to expand the
          // list of playlists
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Find the playlist to select ListTile Text widget
          playlistToSelectListTileTextWidgetFinder = find.text('local');

          // Then obtain the playlist ListTile widget enclosing the Text widget
          // by finding its ancestor
          playlistToSelectListTileWidgetFinder = find.ancestor(
            of: playlistToSelectListTileTextWidgetFinder,
            matching: find.byType(ListTile),
          );

          // Now find the Checkbox widget located in the playlist ListTile
          // and tap on it to select the playlist
          playlistToSelectListTileCheckboxWidgetFinder = find.descendant(
            of: playlistToSelectListTileWidgetFinder,
            matching: find.byType(Checkbox),
          );

          // Tap the ListTile Playlist checkbox to select it
          await tester.tap(playlistToSelectListTileCheckboxWidgetFinder);
          await tester.pumpAndSettle();

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
            "Really short video",
            "morning _ cinematic video",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "La résilience insulaire par Fiona Roche",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
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
              rootPath: kPlaylistDownloadRootPathWindowsTest,
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

            await app.main(['test']);
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

            // Now select the 'Audio title'item in the 'Sort by' dropdown button

            await tester
                .tap(find.byKey(const Key('sortingOptionDropdownButton')));
            await tester.pumpAndSettle();

            await tester.tap(find.text('Audio title'));
            await tester.pumpAndSettle();

            // Then delete the "Audio download date" descending sort option

            // Find the Text with "Audio downl date" which is located in the
            // selected sort parameters ListView
            final Finder texdtFinder = find.descendant(
              of: find.byKey(const Key('selectedSortingOptionsListView')),
              matching: find.text('Audio downl date'),
            );

            // Then find the ListTile ancestor of the 'Audio downl date' Text
            // widget. The ascending/descending and remove icon buttons are
            // contained in their ListTile ancestor
            final Finder listTileFinder = find.ancestor(
              of: texdtFinder,
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
              isTest: true,
            );

            // Load the settings from the json file. This is necessary
            // otherwise the ordered playlist titles will remain empty
            // and the playlist list will not be filled with the
            // playlists available in the download app test dir
            await settingsDataService.loadSettingsFromFile(
                settingsJsonPathFileName:
                    "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

            // Restarting the app
            await app.main(['test']);
            await tester.pumpAndSettle();

            // The app was restarted. Since the in previous test defined and
            // applied sort filter parms wass not saved to the playlist,
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
              "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
              "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            ];

            IntegrationTestUtil.checkAudioTitlesOrderInListTile(
              tester: tester,
              audioTitlesOrderLst:
                  audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
            );

            // Now go to the audio player view
            Finder appScreenNavigationButton =
                find.byKey(const ValueKey('audioPlayerViewIconButton'));
            await tester.tap(appScreenNavigationButton);
            await tester.pumpAndSettle();

            // Verify also the audio playable list dialog title and content
            await verifyAudioPlayableList(
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
              rootPath: kPlaylistDownloadRootPathWindowsTest,
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
            rootPath: kPlaylistDownloadRootPathWindowsTest,
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

          await app.main(['test']);
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

          // Now select the 'Audio title'item in the 'Sort by' dropdown button

          await tester
              .tap(find.byKey(const Key('sortingOptionDropdownButton')));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Titre audio'));
          await tester.pumpAndSettle();

          // Then delete the "Audio download date" descending sort option

          // Find the Text with "Audio downl date" which is located in the
          // selected sort parameters ListView
          final Finder texdtFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Date téléch audio'),
          );

          // Then find the ListTile ancestor of the 'Audio downl date' Text
          // widget. The ascending/descending and remove icon buttons are
          // contained in their ListTile ancestor
          final Finder listTileFinder = find.ancestor(
            of: texdtFinder,
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
            "Les besoins artificiels par R.Keucheyan"
          ];

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
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
          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
          );

          // Now, selecting 'Défaut' dropdown button item to apply the
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
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          ];

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst:
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
          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst:
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

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
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
          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
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
            rootPath: kPlaylistDownloadRootPathWindowsTest,
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

          await app.main(['test']);
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
          Finder texdtFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Date téléch audio'),
          );

          // Then find the ListTile ancestor of the 'Date téléch audio' Text
          // widget. The ascending/descending and remove icon buttons are
          // contained in their ListTile ancestor
          Finder listTileFinder = find.ancestor(
            of: texdtFinder,
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
            "Les besoins artificiels par R.Keucheyan"
          ];

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
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

          // Tap on the ascending icon button in order to set descending
          // sort option

          // Find the Text with 'Titre audio' which is now located in the
          // selected sort parameters ListView
          texdtFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Titre audio'),
          );

          // Then find the ListTile ancestor of the 'Titre audio' Text
          // widget. The ascending/descending and remove icon buttons are
          // contained in their ListTile ancestor
          listTileFinder = find.ancestor(
            of: texdtFinder,
            matching: find.byType(ListTile),
          );

          // Now, within that ListTile, find the sort option ascending/
          // descending IconButton with key 'sort_ascending_or_descending_button'
          iconButtonFinder = find.descendant(
            of: listTileFinder,
            matching:
                find.byKey(const Key('sort_ascending_or_descending_button')),
          );

          // Tap on the ascending/descending icon button to convert ascending
          // to descending sort order
          await tester.tap(iconButtonFinder);
          await tester.pumpAndSettle();

          // Then delete the "Date téléch audio" descending sort option

          // Find the Text with "Date téléch audio" which is located in the
          // selected sort parameters ListView
          texdtFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Date téléch audio'),
          );

          // Then find the ListTile ancestor of the 'Date téléch audio' Text
          // widget. The ascending/descending and remove icon buttons are
          // contained in their ListTile ancestor
          listTileFinder = find.ancestor(
            of: texdtFinder,
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

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
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
          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
          );

          // Now, selecting 'Défaut' dropdown button item to apply the
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
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          ];

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst:
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
          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst:
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

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
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
          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
        testWidgets(
            '''Click on 'Default' dropdown button item edit icon button to
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
            rootPath: kPlaylistDownloadRootPathWindowsTest,
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

          await app.main(['test']);
          await tester.pumpAndSettle();

          // First, set the application language to French
          await IntegrationTestUtil.setApplicationLanguage(
            tester: tester,
            language: Language.french,
          );

          final Finder dropDownButtonFinder =
              find.byKey(const Key('sort_filter_parms_dropdown_button'));

          final Finder dropDownButtonTextFinder = find.descendant(
            of: dropDownButtonFinder,
            matching: find.byType(Text),
          );

          // Tap twice on the dropdown button 'Défaut' item so that its edit
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

          // Now select the 'Titre audio' item in the 'Sort by' dropdown button

          await tester
              .tap(find.byKey(const Key('sortingOptionDropdownButton')));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Titre audio'));
          await tester.pumpAndSettle();

          // Then delete the "Date téléch audio" descending sort option

          // Find the Text with "Date téléch audio" which is located in the
          // selected sort parameters ListView
          final Finder texdtFinder = find.descendant(
            of: find.byKey(const Key('selectedSortingOptionsListView')),
            matching: find.text('Date téléch audio'),
          );

          // Then find the ListTile ancestor of the 'Date téléch audio' Text
          // widget. The ascending/descending and remove icon buttons are
          // contained in their ListTile ancestor
          final Finder listTileFinder = find.ancestor(
            of: texdtFinder,
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

          String appliedFrenchTitle = 'appliqué';

          // Verify that the dropdown button has been updated with the
          // 'Title asc' sort/filter parms selected
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
            "Les besoins artificiels par R.Keucheyan"
          ];

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
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
            dropdownButtonSelectedTitle: appliedFrenchTitle,
          );

          // And verify the order of the playlist audio titles
          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
      });
    });
    group('''Verifying playlist selection change applies correctly their named
             sort/filter parms.''', () {
      testWidgets(
          '''Change the SF parms in in the dropdown button list to 'Title asc'
             and then verify its application. Then go to the audio player view
             and there select another playlist. Then go back to the playlist
             download view, select the previously selected playlist and verify
             that its previously selected named sort/filter parms is selected
             and applied''', (WidgetTester tester) async {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_three_playlists_test",
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
          "Les besoins artificiels par R.Keucheyan"
        ];

        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
        );

        // Then go to the audio player view
        Finder appScreenNavigationButton =
            find.byKey(const ValueKey('audioPlayerViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        // Now, in the audio player view, select the 'Local' audio playlist using
        // the audio player view playlist selection button.

        // Tap on audio player view playlist button to display the playlists
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Find the playlist to select ListTile Text widget
        final Finder playlistToSelectListTileTextWidgetFinder =
            find.text('local');

        // Then obtain the playlist ListTile widget enclosing the Text widget
        // by finding its ancestor
        final Finder playlistToSelectListTileWidgetFinder = find.ancestor(
          of: playlistToSelectListTileTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the Checkbox widget located in the playlist ListTile
        // and tap on it to select the playlist
        final Finder playlistToSelectListTileCheckboxWidgetFinder =
            find.descendant(
          of: playlistToSelectListTileWidgetFinder,
          matching: find.byType(Checkbox),
        );

        // Tap the ListTile Playlist checkbox to select it
        await tester.tap(playlistToSelectListTileCheckboxWidgetFinder);
        await tester.pumpAndSettle();

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

        IntegrationTestUtil.checkAudioTitlesOrderInListTile(
          tester: tester,
          audioTitlesOrderLst: audioTitlesSortedByTitleAscending,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
    group('Saved to playlist named sort/filter parms', () {
      group('Saving different named sort/filter parms to playlist views', () {
        testWidgets(
            '''Select the 'desc listened' sort/filter parms. Then, in 'S8 audio',
               save it only to playlist download view. Verify playlist json file
               as well as the Save and Remove dialogs content. Then reopen the
               'Save sort/filter parameters to playlist' dialog and save it after
               unchecking the 'Download Audio' checkbox. Then verifying that the
               playlist json file was not modified since in order to disable a
               saved playlist SF parms, the Remove dialog must be used.
               
               Then, select 'Title asc' in the sort/filter dropdown button and
               open the Save dialog in order to save this SF parms to the audio
               player view. Now verify the playlist json file as well as the
               fact that the audio player view playable audio list is correctly
               sorted.

               Then restart the application. Verify that 'desc listened' is
               selected. Open the Remove dialog to verify its content and remove
               the 'desc listened' SF parms. Then verify that the 'default'
               is applied to the playlist download view and not to the audio
               player view. Verify also the playlist json file.''',
            (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_three_playlists_test",
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

          const String descListenedSortFilterName = 'desc listened';
          const String titleAscSortFilterName = 'Title asc';

          // Save the 'desc listened' sort/filter parms to the 'S8 audio' playlist
          await selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: descListenedSortFilterName,
            saveToPlaylistDownloadView: true,
            saveToAudioPlayerView: false,
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

          await verifyAudioPopupMenuItemState(
            tester: tester,
            menuItemKey: 'save_sort_and_filter_audio_parms_in_playlist_item',
            isEnabled: true,
          );

          await verifyAudioPopupMenuItemState(
            tester: tester,
            doNotTapOnAudioPopupMenuButton: true, // since the audio popup menu
            //                                       is already open, do not tap
            //                                       on it again
            menuItemKey:
                'remove_sort_and_filter_audio_parms_from_playlist_item',
            isEnabled: true,
          );

          // Click on playlist toggle button to close the audio menu
          await tester.tap(find.byKey(const Key('playlist_toggle_button')));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          // Verify the content of the save sort/filter parms dialog
          await verifySaveSortFilterParmsToPlaylistDialog(
            tester: tester,
            playlistTitle: 'S8 audio',
            sortFilterParmsName: descListenedSortFilterName,
            forPlaylistDownloadViewCheckboxValue: true,
            forAudioPlayerViewCheckboxValue: false,
          );

          // Now reopen the Save dialog, uncheck the 'Download Audio' screen
          // checkbox and click on Save button.
          await selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: descListenedSortFilterName,
            saveToPlaylistDownloadView: false,
            saveToAudioPlayerView: false,
          );

          // Verifying that the playlist json file was not modified.
          IntegrationTestUtil
              .verifyPlaylistDataElementsUpdatedInPlaylistJsonFile(
            selectedPlaylistTitle: 'S8 audio',
            audioSortFilterParmsNamePlaylistDownloadView:
                descListenedSortFilterName,
            audioSortFilterParmsNameAudioPlayerView: '',
          );

          // Select and save the 'Title asc' sort/filter parms to the audio
          // player view of 'S8 audio' playlist
          await selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: titleAscSortFilterName,
            saveToPlaylistDownloadView: false,
            saveToAudioPlayerView: true,
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
            "Les besoins artificiels par R.Keucheyan"
          ];

          // Verify also the audio playable list dialog title and content
          await verifyAudioPlayableList(
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
               player view. Verify also the playlist json file.''',
            (WidgetTester tester) async {
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

          const String descListenedSortFilterName = 'desc listened';
          const String titleAscSortFilterName = 'Title asc';

          // Verify that the 'desc listened' sort/filter parms is selected
          IntegrationTestUtil.checkDropdopwnButtonSelectedTitle(
            tester: tester,
            dropdownButtonSelectedTitle: descListenedSortFilterName,
          );

          // Now remove the 'desc listened' sort/filter parms from the
          // 'Download Audio' screen 'S8 audio' playlist
          await selectAndRemoveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsNameName: descListenedSortFilterName,
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
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          ];

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Now verify the save ... and remove ... audio popup menu items
          // state

          await verifyAudioPopupMenuItemState(
            tester: tester,
            menuItemKey: 'save_sort_and_filter_audio_parms_in_playlist_item',
            isEnabled: false,
          );

          await verifyAudioPopupMenuItemState(
            tester: tester,
            doNotTapOnAudioPopupMenuButton: true, // since the audio popup menu
            //                                       is already open, do not tap
            //                                       on it again
            menuItemKey:
                'remove_sort_and_filter_audio_parms_from_playlist_item',
            isEnabled: false,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
      });
      group('Deleting saved to playlist named sort/filter parms', () {
        testWidgets(
            '''Delete saved to playlist named sort/filter bug fix verification:

               Select the 'Title asc' sort/filter parms. Then save it only to
               playlist download view. Then delete it and verify that the
               'default' sort/filter parms is applied to the playlist download
               view.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_three_playlists_test",
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
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          ];

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
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
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_three_playlists_test",
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

          const String titleAscSortFilterName = 'Title asc';

          // Save the 'Title asc' sort/filter parms to the 'S8 audio' playlist
          await selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: titleAscSortFilterName,
            saveToPlaylistDownloadView: true,
            saveToAudioPlayerView: true,
          );

          // Now switch to 'local' playlist
          await switchToPlaylist(
            tester: tester,
            playlistTitle: 'local',
          );

          // Save the 'Title asc' sort/filter parms to the 'local' playlist
          await selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: titleAscSortFilterName,
            saveToPlaylistDownloadView: true,
            saveToAudioPlayerView: true,
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
            "Really short video",
            "morning _ cinematic video",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "Les besoins artificiels par R.Keucheyan",
            "La résilience insulaire par Fiona Roche",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          ];

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
            "Really short video",
            "morning _ cinematic video",
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            "Les besoins artificiels par R.Keucheyan",
            "La résilience insulaire par Fiona Roche",
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          ];

          // Verify also the audio playable list dialog title and content
          await verifyAudioPlayableList(
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
          await switchToPlaylist(
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
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          ];

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Verify also the audio playable list dialog title and content
          await verifyAudioPlayableList(
            tester: tester,
            currentAudioTitle:
                "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik\n13:39",
            sortFilterParmsName: 'default',
            audioTitlesLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // TODO Now recreate the 'Title asc' sort/filter parms

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
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
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_three_playlists_test",
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

          const String titleAscSortFilterName = 'Title asc';

          // Save the 'Title asc' sort/filter parms to the 'S8 audio' playlist
          await selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: titleAscSortFilterName,
            saveToPlaylistDownloadView: true,
            saveToAudioPlayerView: true,
          );

          // Now remove the 'Title asc' sort/filter parms from the 'S8 audio'
          // playlist
          await selectAndRemoveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsNameName: titleAscSortFilterName,
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
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          ];

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Verify also the audio playable list dialog title and content
          await verifyAudioPlayableList(
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

          await verifyAudioPopupMenuItemState(
            tester: tester,
            menuItemKey: 'save_sort_and_filter_audio_parms_in_playlist_item',
            isEnabled: false,
          );

          await verifyAudioPopupMenuItemState(
            tester: tester,
            doNotTapOnAudioPopupMenuButton: true, // since the audio popup menu
            //                                       is already open, do not tap
            //                                       on it again
            menuItemKey:
                'remove_sort_and_filter_audio_parms_from_playlist_item',
            isEnabled: false,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
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
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_three_playlists_test",
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

          const String titleAscSortFilterName = 'Title asc';

          // Save the 'Title asc' sort/filter parms to the 'S8 audio' playlist
          await selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: titleAscSortFilterName,
            saveToPlaylistDownloadView: true,
            saveToAudioPlayerView: false,
          );

          // Now remove the 'Title asc' sort/filter parms from the 'S8 audio'
          // playlist
          await selectAndRemoveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsNameName: titleAscSortFilterName,
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
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          ];

          IntegrationTestUtil.checkAudioTitlesOrderInListTile(
            tester: tester,
            audioTitlesOrderLst:
                audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
          );

          // Verify also the audio playable list dialog title and content
          await verifyAudioPlayableList(
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

          await verifyAudioPopupMenuItemState(
            tester: tester,
            menuItemKey: 'save_sort_and_filter_audio_parms_in_playlist_item',
            isEnabled: false,
          );

          await verifyAudioPopupMenuItemState(
            tester: tester,
            doNotTapOnAudioPopupMenuButton: true, // since the audio popup menu
            //                                       is already open, do not tap
            //                                       on it again
            menuItemKey:
                'remove_sort_and_filter_audio_parms_from_playlist_item',
            isEnabled: false,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
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
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_three_playlists_test",
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

          const String titleAscSortFilterName = 'Title asc';

          // Save the 'Title asc' sort/filter parms to the 'S8 audio' playlist
          await selectAndSaveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsName: titleAscSortFilterName,
            saveToPlaylistDownloadView: true,
            saveToAudioPlayerView: false,
          );

          // Now remove the 'Title asc' sort/filter parms from the 'S8 audio'
          // playlist
          await selectAndRemoveSortFilterParmsToPlaylist(
            tester: tester,
            sortFilterParmsNameName: titleAscSortFilterName,
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

          await verifyAudioPopupMenuItemState(
            tester: tester,
            menuItemKey: 'save_sort_and_filter_audio_parms_in_playlist_item',
            isEnabled: false,
          );

          await verifyAudioPopupMenuItemState(
            tester: tester,
            doNotTapOnAudioPopupMenuButton: true, // since the audio popup menu
            //                                       is already open, do not tap
            //                                       on it again
            menuItemKey:
                'remove_sort_and_filter_audio_parms_from_playlist_item',
            isEnabled: false,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
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
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}playlist_audio_comments_sort_integr_test",
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
          await verifyOrderOfPlaylistAudioComments(
            tester: tester,
            expectedCommentTitles: expectedDefaultCommentTitles,
            expectedCommentTimes: expectedDefaultCommentTimes,
          );

          // Tap the 'Toggle List' button to display the playlist list If the list
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

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // And open the 'Save sort/filter parameters to playlist' dialog
          await tester.tap(find.byKey(
              const Key('save_sort_and_filter_audio_parms_in_playlist_item')));
          await tester.pumpAndSettle();

          // Select the 'For "Download Audio" screen' checkbox
          await tester
              .tap(find.byKey(const Key('playlistDownloadViewCheckbox')));
          await tester.pumpAndSettle();

          // Select the 'For "Play Audio" screen' checkbox
          await tester.tap(find.byKey(const Key('audioPlayerViewCheckbox')));
          await tester.pumpAndSettle();

          // Finally, click on save button
          await tester.tap(find
              .byKey(const Key('saveSortFilterOptionsToPlaylistSaveButton')));
          await tester.pumpAndSettle();

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
          await verifyOrderOfPlaylistAudioComments(
            tester: tester,
            expectedCommentTitles: expectedTitleAscCommentTitles,
            expectedCommentTimes: expectedTitleAscCommentTimes,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );
        });
        testWidgets(''''Title asc' only to audio player view.

               Select the 'Title asc' sort/filter parms. Then save it only to 
               audio player view. Then open the playlist comment list and verify
               its content.''', (WidgetTester tester) async {
          // Purge the test playlist directory if it exists so that the
          // playlist list is empty
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}playlist_audio_comments_sort_integr_test",
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

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // And open the 'Save sort/filter parameters to playlist' dialog
          await tester.tap(find.byKey(
              const Key('save_sort_and_filter_audio_parms_in_playlist_item')));
          await tester.pumpAndSettle();

          // Select the 'For "Play Audio" screen' checkbox
          await tester.tap(find.byKey(const Key('audioPlayerViewCheckbox')));
          await tester.pumpAndSettle();

          // Finally, click on save button
          await tester.tap(find
              .byKey(const Key('saveSortFilterOptionsToPlaylistSaveButton')));
          await tester.pumpAndSettle();

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
          await verifyOrderOfPlaylistAudioComments(
            tester: tester,
            expectedCommentTitles: expectedTitleAscCommentTitles,
            expectedCommentTimes: expectedTitleAscCommentTimes,
          );

          // Purge the test playlist directory so that the created test
          // files are not uploaded to GitHub
          DirUtil.deleteFilesInDirAndSubDirs(
            rootPath: kPlaylistDownloadRootPathWindowsTest,
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
            rootPath: kPlaylistDownloadRootPathWindowsTest,
          );

          // Copy the test initial audio data to the app dir
          DirUtil.copyFilesFromDirAndSubDirsToDirectory(
            sourceRootPath:
                "$kDownloadAppTestSavedDataDir${path.separator}playlist_audio_comments_sort_integr_test",
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

          const String playlistTitle = "Conversation avec Dieu";

          // Tap the 'Toggle List' button to display the playlist list If the list
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

          // Now open the audio popup menu
          await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
          await tester.pumpAndSettle();

          // And open the 'Save sort/filter parameters to playlist' dialog
          await tester.tap(find.byKey(
              const Key('save_sort_and_filter_audio_parms_in_playlist_item')));
          await tester.pumpAndSettle();

          // Select the 'For "Download Audio" screen' checkbox
          await tester
              .tap(find.byKey(const Key('playlistDownloadViewCheckbox')));
          await tester.pumpAndSettle();

          // Finally, click on save button
          await tester.tap(find
              .byKey(const Key('saveSortFilterOptionsToPlaylistSaveButton')));
          await tester.pumpAndSettle();

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
          await verifyOrderOfPlaylistAudioComments(
            tester: tester,
            expectedCommentTitles: expectedDefaultCommentTitles,
            expectedCommentTimes: expectedDefaultCommentTimes,
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
}

Future<void> verifyOrderOfPlaylistAudioComments({
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
      matching: find.byKey(const Key('commentPositionKey')),
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
  await tester.tap(find.byKey(const Key('closeDialogTextButton')));
  await tester.pumpAndSettle();
}

Future<void> verifyAudioPopupMenuItemState({
  required WidgetTester tester,
  bool doNotTapOnAudioPopupMenuButton = false,
  required String menuItemKey,
  required bool isEnabled,
}) async {
  if (!doNotTapOnAudioPopupMenuButton) {
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

void verifyAudioSortFilterParmsNameStoredInPlaylistJsonFile({
  required String selectedPlaylistTitle,
  required String expectedAudioSortFilterParmsName,
  required List<AudioLearnAppViewType> audioLearnAppViewTypeLst,
  required AudioPlayingOrder audioPlayingOrder,
}) {
  final String selectedPlaylistPath = path.join(
    kPlaylistDownloadRootPathWindowsTest,
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

Future<void> selectAndSaveSortFilterParmsToPlaylist({
  required WidgetTester tester,
  required String sortFilterParmsName,
  required bool saveToPlaylistDownloadView,
  required bool saveToAudioPlayerView,
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

  // And open the 'Save sort/filter parameters to playlist' dialog
  await tester.tap(find
      .byKey(const Key('save_sort_and_filter_audio_parms_in_playlist_item')));
  await tester.pumpAndSettle();

  if (saveToPlaylistDownloadView) {
    // Select the 'For "Download Audio" screen' checkbox
    await tester.tap(find.byKey(const Key('playlistDownloadViewCheckbox')));
    await tester.pumpAndSettle();
  }

  if (saveToAudioPlayerView) {
    // Select the 'For "Play Audio" screen' checkbox
    await tester.tap(find.byKey(const Key('audioPlayerViewCheckbox')));
    await tester.pumpAndSettle();
  }

  // Finally, click on save button
  await tester
      .tap(find.byKey(const Key('saveSortFilterOptionsToPlaylistSaveButton')));
  await tester.pumpAndSettle();
}

Future<void> verifySaveSortFilterParmsToPlaylistDialog({
  required WidgetTester tester,
  required String playlistTitle,
  required String sortFilterParmsName,
  required bool forPlaylistDownloadViewCheckboxValue,
  required bool forAudioPlayerViewCheckboxValue,
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
  expect(
    tester
        .widget<Checkbox>(find.byKey(const Key('playlistDownloadViewCheckbox')))
        .value,
    forPlaylistDownloadViewCheckboxValue,
  );
  expect(
    tester
        .widget<Checkbox>(find.byKey(const Key('audioPlayerViewCheckbox')))
        .value,
    forAudioPlayerViewCheckboxValue,
  );

  // Finally, click on cancel button
  await tester
      .tap(find.byKey(const Key('sortFilterOptionsToPlaylistCancelButton')));
  await tester.pumpAndSettle();
}

Future<void> selectAndRemoveSortFilterParmsToPlaylist({
  required WidgetTester tester,
  required String sortFilterParmsNameName,
  bool tapOnRemoveFromPlaylistDownloadViewCheckbox = false,
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
  Finder titleAscDropDownTextFinder = find.text(sortFilterParmsNameName).last;
  await tester.tap(titleAscDropDownTextFinder);
  await tester.pumpAndSettle();

  // Now open the audio popup menu
  await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
  await tester.pumpAndSettle();

  // And open the 'Remove sort/filter parameters from playlist' dialog
  await tester.tap(find.byKey(
      const Key('remove_sort_and_filter_audio_parms_from_playlist_item')));
  await tester.pumpAndSettle();

  if (tapOnRemoveFromPlaylistDownloadViewCheckbox) {
    // Select the 'On "Download Audio" screen' checkbox
    await tester.tap(find.byKey(const Key('playlistDownloadViewCheckbox')));
    await tester.pumpAndSettle();
  }

  if (tapOnRemoveFromAudioPlayerViewCheckbox) {
    // Select the 'On "Play Audio" screen' checkbox
    await tester.tap(find.byKey(const Key('audioPlayerViewCheckbox')));
    await tester.pumpAndSettle();
  }

  // Finally, click on save button
  await tester
      .tap(find.byKey(const Key('saveSortFilterOptionsToPlaylistSaveButton')));
  await tester.pumpAndSettle();
}

Future<void> switchToPlaylist({
  required WidgetTester tester,
  required String playlistTitle,
}) async {
  // Now select the local playlist in order to apply the created
  // sort/filter parms to it

  // Tap on audio player view playlist button to expand the
  // list of playlists
  await tester.tap(find.byKey(const Key('playlist_toggle_button')));
  await tester.pumpAndSettle(const Duration(milliseconds: 200));

  // Find the playlist to select ListTile Text widget
  Finder playlistToSelectListTileTextWidgetFinder = find.text(playlistTitle);

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

  // Tap on audio player view playlist button to contract the
  // list of playlists
  await tester.tap(find.byKey(const Key('playlist_toggle_button')));
  await tester.pumpAndSettle(const Duration(milliseconds: 200));
}

Future<void> verifyAudioPlayableList({
  required WidgetTester tester,
  required String currentAudioTitle,
  required String sortFilterParmsName,
  required List<String> audioTitlesLst,
}) async {
  // Going to the audio player view
  Finder appScreenNavigationButton =
      find.byKey(const ValueKey('audioPlayerViewIconButton'));
  await tester.tap(appScreenNavigationButton);
  await tester.pumpAndSettle();

  // Now we open the AudioPlayableListDialogWidget
  // and verify the the displayed audio titles

  await tester.tap(find.text(currentAudioTitle));
  await tester.pumpAndSettle();

  RichText dialogTitle = tester.widget<RichText>(
      find.byKey(const ValueKey('audioPlayableListDialogTitle')));

  // Extract the main TextSpan
  final TextSpan textSpan = dialogTitle.text as TextSpan;

  // Verify the main text content
  expect(textSpan.text, 'Select an audio'); // Replace with actual expected text

  // Verify the nested TextSpan content (children)
  final TextSpan nestedTextSpan = textSpan.children![1] as TextSpan;

  expect(nestedTextSpan.text, "($sortFilterParmsName)");

  IntegrationTestUtil.checkAudioTitlesOrderInListBody(
    tester: tester,
    audioTitlesOrderLst: audioTitlesLst,
  );

  // Tap on the Close button to close the AudioPlayableListDialogWidget
  await tester.tap(find.byKey(const Key('closeTextButton')));
  await tester.pumpAndSettle();
}

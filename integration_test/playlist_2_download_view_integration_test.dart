import 'dart:convert';
import 'dart:io';

import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/views/widgets/comment_add_edit_dialog.dart';
import 'package:audiolearn/views/widgets/comment_list_add_dialog.dart';
import 'package:audiolearn/views/widgets/playlist_comment_list_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/services/json_data_service.dart';
import 'package:audiolearn/views/widgets/warning_message_display.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/utils/dir_util.dart';

import '../test/services/mock_shared_preferences.dart';
import 'integration_test_util.dart';

void main() {
  // Necessary to avoid FatalFailureException (FatalFailureException: Failed
  // to perform an HTTP request to YouTube due to a fatal failure. In most
  // cases, this error indicates that YouTube most likely changed something,
  // which broke the library.
  // If this issue persists, please report it on the project's GitHub page.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Search icon button test', () {
    group('Audio search word selection', () {
      testWidgets('''First, select the existing 'janco' sort/filter
          parms in the SF dropdown button. Then enter the search word 'La' in the
          'Youtube Link''', (WidgetTester tester) async {
        // Link or Search' text field. After entering 'L', verify that the search
        // icon button is now enabled. Then, enter 'La' search word, click on the
        // enabled search icon button and verify the reduced displayed audio list.
        // After that, delete the 'a' letter from the 'La' search word and verify
        // the changed displayed audio list. Since the search button was used,
        // modifying the search text applies at each search text change. Then,
        // select the 'default' dropdon icon button and verify that now, as the
        // search button was tapped, applying the 'default' sort filter parms
        // is impacted by the still existing search word. Then, enters a https URL
        // in youtubeUrlOrSearchTextField and verify that the search icon button
        // is disabled.
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'sort_and_filter_audio_dialog_widget_test',
          tapOnPlaylistToggleButton: false,
        );

        // Select 'janco' dropdown button item to apply the existing
        // 'janco' sort/filter parms
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

        // And select the 'janco' sort/filter item
        String sortFilterParmsTitle = 'janco';
        Finder sortFilterParmsDropDownTextFinder =
            find.text(sortFilterParmsTitle);

        await tester.tap(sortFilterParmsDropDownTextFinder);
        await tester.pumpAndSettle();

        // And verify the order of the playlist audio titles

        List<String>
            audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Verify the disabled state of the search icon button
        IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button', // this button is disabled if the
          //                                     'Youtube Link or Search' dosn't
          //                                     contain a search word or sentence
        );

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
          'L',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is now enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Ensure that since the search icon button was not yet pressed,
        // the displayed audio list is the same as the one before entering
        // the first letter of the search word.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Enter the second letter of the 'La' search word. The crazy integration
        // test does not always update the test field. To fix this bug, first
        // select the text field and then enter the text.

        // Select the text field
        await tester.tap(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
        );
        await tester.pumpAndSettle();

        // Enter the second letter of the 'La' search word
        await tester.enterText(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
          'La',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is still enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Ensure that since the search icon button was not yet pressed,
        // the displayed audio list is the same as the one before entering
        // the first letter of the search word.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Verify that the search icon button is still enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Now verify the order of the reduced playlist audio titles

        audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Now remove the second letter of the 'La' search word
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
          'L',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is still enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // And verify the order of the playlist audio titles. Since
        // the search icon button was used, modifying the search text
        // is applied at each search text change

        audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button was used,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Verify that the search icon button is still enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Then reenter the second search word letter
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
          'La',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Now verify the order of the reduced playlist audio titles

        audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Tap on the current dropdown button item to open the dropdown
        // button items list
        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // And select the 'default' sort/filter item
        sortFilterParmsTitle = 'default';
        sortFilterParmsDropDownTextFinder = find.text(sortFilterParmsTitle);

        await tester.tap(sortFilterParmsDropDownTextFinder);
        await tester.pumpAndSettle();

        // And verify the order of the playlist audio titles

        audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Verify the enabled state of the search icon button
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button', // this button is disabled if the
          //                                     'Youtube Link or Search' dosn't
          //                                     contain a search word or sentence
        );

        // Now entering a URL in the search text word

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
          'https://www.youtube.com/watch?v=ctD3mbQ7RPk',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is now disabled
        IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
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

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets(
          '''Finish by emptying the search word. First, select the existing
          'janco' sort/filter parms in the SF dropdown button. Then enter the search
           word 'La' in the 'Youtube Link''', (WidgetTester tester) async {
        // Link or Search' text field. After entering 'L', verify that the search
        // icon button is now enabled. Then, select the 'default' dropdon icon
        // button and verify that now, as the search button was tapped, applying
        // the 'default' sort filter parms is impacted by the still existing search
        // word. Then, empty the search word and verify that the search icon button
        // is disabled.
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'sort_and_filter_audio_dialog_widget_test',
          tapOnPlaylistToggleButton: false,
        );

        // Select 'janco' dropdown button item to apply the existing
        // 'janco' sort/filter parms
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

        // And select the 'janco' sort/filter item
        String sortFilterParmsTitle = 'janco';
        Finder sortFilterParmsDropDownTextFinder =
            find.text(sortFilterParmsTitle);

        await tester.tap(sortFilterParmsDropDownTextFinder);
        await tester.pumpAndSettle();

        // And verify the order of the playlist audio titles

        List<String>
            audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Verify the disabled state of the search icon button
        IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button', // this button is disabled if the
          //                                     'Youtube Link or Search' dosn't
          //                                     contain a search word or sentence
        );

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
          'La',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is now enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // And verify the order of the playlist audio titles. Since
        // the search icon button was used, modifying the search text
        // is applied at each search text change

        audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        // Tap on the current dropdown button item to open the dropdown
        // button items list
        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // And select the 'default' sort/filter item
        sortFilterParmsTitle = 'default';
        sortFilterParmsDropDownTextFinder = find.text(sortFilterParmsTitle);

        await tester.tap(sortFilterParmsDropDownTextFinder);
        await tester.pumpAndSettle();

        // And verify the order of the playlist audio titles

        audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Verify the enabled state of the search icon button
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button', // this button is disabled if the
          //                                     'Youtube Link or Search' dosn't
          //                                     contain a search word or sentence
        );

        // Now emptying the search text word

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

        // Verify that the search icon button is now disabled
        IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
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

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets(
          '''Finish by entering a http (not https) URL. First, select the existing
          'janco' sort/filter parms in the SF dropdown button. Then enter the search
           word 'La' in the 'Youtube Link''', (WidgetTester tester) async {
        // Link or Search' text field. After entering 'L', verify that the search
        // icon button is now enabled. Then, select the 'default' dropdon icon
        // button and verify that now, as the search button was tapped, applying
        // the 'default' sort filter parms is impacted by the still existing search
        // word. Then, http URL and verify that the search icon button
        // is disabled.
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'sort_and_filter_audio_dialog_widget_test',
          tapOnPlaylistToggleButton: false,
        );

        // Select 'janco' dropdown button item to apply the existing
        // 'janco' sort/filter parms
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

        // And select the 'janco' sort/filter item
        String sortFilterParmsTitle = 'janco';
        Finder sortFilterParmsDropDownTextFinder =
            find.text(sortFilterParmsTitle);

        await tester.tap(sortFilterParmsDropDownTextFinder);
        await tester.pumpAndSettle();

        // And verify the order of the playlist audio titles

        List<String>
            audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Verify the disabled state of the search icon button
        IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button', // this button is disabled if the
          //                                     'Youtube Link or Search' dosn't
          //                                     contain a search word or sentence
        );

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
          'La',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is now enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // And verify the order of the playlist audio titles. Since
        // the search icon button was used, modifying the search text
        // is applied at each search text change

        audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        // Tap on the current dropdown button item to open the dropdown
        // button items list
        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // And select the 'default' sort/filter item
        sortFilterParmsTitle = 'default';
        sortFilterParmsDropDownTextFinder = find.text(sortFilterParmsTitle);

        await tester.tap(sortFilterParmsDropDownTextFinder);
        await tester.pumpAndSettle();

        // And verify the order of the playlist audio titles

        audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Verify the enabled state of the search icon button
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button', // this button is disabled if the
          //                                     'Youtube Link or Search' dosn't
          //                                     contain a search word or sentence
        );

        // Now emptying the search text word

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

        // Verify that the search icon button is now disabled
        IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
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

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
    group('Playlist search word selection', () {
      testWidgets('''First, enter the search word 'al' in the 'Youtube Link or
           Search' text field.''', (WidgetTester tester) async {
        // After entering 'a', verify that the search icon button is now enabled.
        // Then, enter 'al' search word, click on the enabled search icon button
        // and verify the reduced displayed playlist list list. Finally, add '_'
        // to the search word and verify the changed displayed playlist list.
        //
        // After that, delete the '_' letter from the 'al_' search word and verify
        // the changed displayed audio list. Since the search button was used,
        // modifying the search text applies at each search text change. Then,
        // delete the 'l' letter, then, empty the youtubeUrlOrSearchTextField
        // and verify that the search icon button is disabled. Finally, enters a
        // letter and verify it has no impact since the search button was not
        // pressed again.
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'sort_and_filter_audio_dialog_widget_three_playlists_test',
          tapOnPlaylistToggleButton: true,
        );

        // Verify the disabled state of the search icon button
        IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button', // this button is disabled if the
          //                                     'Youtube Link or Search' dosn't
          //                                     contain a search word or sentence
        );

        List<String> playlistsTitles =
            await _enteringFirstAndSecondLetterOfLocalPlaylistSearchWord(
          tester: tester,
        );

        // Now add the third letter of the 'al_' search word
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
          'al_',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is still enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // And verify the order of the playlist titles. Since
        // the search icon button was used, modifying the search text
        // is applied at each search text change

        playlistsTitles = [
          "local_2",
        ];

        // Ensure that since the search icon button was used,
        // the displayed playlist list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Verify that the search icon button is still enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Then erase the third search word letter
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
          'al',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Now verify the order of the augmented playlist titles

        playlistsTitles = [
          "local",
          "local_2",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Then erase the second search word letter
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
          'a',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Now verify the order of the augmented playlist titles

        playlistsTitles = [
          "S8 audio",
          "local",
          "local_2",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Now emptying the search text word
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

        // Verify that the search icon button is now disabled
        IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        await _enteringFirstAndSecondLetterOfLocalPlaylistSearchWord(
          tester: tester,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets('''Instead of emptying, add https URL. First, enter the search
           word 'al' in the 'Youtube Link or Search' text field.''',
          (WidgetTester tester) async {
        // After entering 'a', verify that the search icon button is now enabled.
        // Then, enter 'al' search word, click on the enabled search icon button
        // and verify the reduced displayed playlist list list. Finally, add '_'
        // to the search word and verify the changed displayed playlist list.
        //
        // After that, delete the '_' letter from the 'al_' search word and verify
        // the changed displayed audio list. Since the search button was used,
        // modifying the search text applies at each search text change. Then,
        // delete the 'l' letter, then, enter an https URL in the
        // youtubeUrlOrSearchTextField
        // and verify that the search icon button is disabled. Finally, enters a
        // letter and verify it has no impact since the search button was not
        // pressed again.
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'sort_and_filter_audio_dialog_widget_three_playlists_test',
          tapOnPlaylistToggleButton: true,
        );

        // Verify the disabled state of the search icon button
        IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button', // this button is disabled if the
          //                                     'Youtube Link or Search' dosn't
          //                                     contain a search word or sentence
        );

        List<String> playlistsTitles =
            await _enteringFirstAndSecondLetterOfLocalPlaylistSearchWord(
          tester: tester,
        );

        // Now add the third letter of the 'al_' search word
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
          '_',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is still enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // And verify the order of the playlist titles. Since
        // the search icon button was used, modifying the search text
        // is applied at each search text change

        playlistsTitles = [
          "local_2",
        ];

        // Ensure that since the search icon button was used,
        // the displayed playlist list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Verify that the search icon button is still enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Then erase the third search word letter
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
          'al',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Now verify the order of the augmented playlist titles

        playlistsTitles = [
          "local",
          "local_2",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Then erase the second search word letter
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
          'a',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Now verify the order of the augmented playlist titles

        playlistsTitles = [
          "S8 audio",
          "local",
          "local_2",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Now entering https URL instead of search text word
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
          'https://www.youtube.com/watch?v=ctD3mbQ7RPk',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is now disabled
        IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        await _enteringFirstAndSecondLetterOfLocalPlaylistSearchWord(
          tester: tester,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets('''Instead of emptying, add http URL. First, enter the search
           word 'al' in the 'Youtube Link or Search' text field.''',
          (WidgetTester tester) async {
        // After entering 'a', verify that the search icon button is now enabled.
        // Then, enter 'al' search word, click on the enabled search icon button
        // and verify the reduced displayed playlist list list. Finally, add '_'
        // to the search word and verify the changed displayed playlist list.
        //
        // After that, delete the '_' letter from the 'al_' search word and verify
        // the changed displayed audio list. Since the search button was used,
        // modifying the search text applies at each search text change. Then,
        // delete the 'l' letter, then, enter an http URL in the
        // youtubeUrlOrSearchTextField
        // and verify that the search icon button is disabled. Finally, enters a
        // letter and verify it has no impact since the search button was not
        // pressed again.
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'sort_and_filter_audio_dialog_widget_three_playlists_test',
          tapOnPlaylistToggleButton: true,
        );

        // Verify the disabled state of the search icon button
        IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button', // this button is disabled if the
          //                                     'Youtube Link or Search' dosn't
          //                                     contain a search word or sentence
        );

        List<String> playlistsTitles =
            await _enteringFirstAndSecondLetterOfLocalPlaylistSearchWord(
          tester: tester,
        );

        // Now add the third letter of the 'al_' search word
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
          '_',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is still enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // And verify the order of the playlist titles. Since
        // the search icon button was used, modifying the search text
        // is applied at each search text change

        playlistsTitles = [
          "local_2",
        ];

        // Ensure that since the search icon button was used,
        // the displayed playlist list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Verify that the search icon button is still enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Then erase the third search word letter
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
          'al',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Now verify the order of the augmented playlist titles

        playlistsTitles = [
          "local",
          "local_2",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Then erase the second search word letter
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
          'a',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Now verify the order of the augmented playlist titles

        playlistsTitles = [
          "S8 audio",
          "local",
          "local_2",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Now entering https URL instead of search text word
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
          'http://www.youtube.com/watch?v=ctD3mbQ7RPk',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is now disabled
        IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        await _enteringFirstAndSecondLetterOfLocalPlaylistSearchWord(
          tester: tester,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
    group('Selecting searched playlist found by applying search word', () {
      testWidgets('''First, enter the search word 'al' in the 'Youtube Link or
           Search' text field.''', (WidgetTester tester) async {
        // Click on the enabled search icon button and verify the reduced
        // displayed playlist list list, the currently selected playlist title
        // and its audio list.
        //
        // Then, select one of the filtered playlist and verify the updated
        // selected playlist title as well as its audio list.
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'sort_and_filter_audio_dialog_widget_three_playlists_test',
          tapOnPlaylistToggleButton: true,
        );

        List<String> playlistsTitles =
            await _enteringFirstAndSecondLetterOfLocalPlaylistSearchWord(
          tester: tester,
        );

        // Verify the currently selected playlist title

        Text selectedPlaylistTitleText =
            tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));

        expect(
          selectedPlaylistTitleText.data,
          'S8 audio',
        );

        // Find the local playlist to select

        // First, find the Playlist ListTile Text widget
        final Finder localPlaylistToSelectListTileTextWidgetFinder =
            find.text(playlistsTitles[0]); // local

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

        // Verify the newly selected playlist title

        selectedPlaylistTitleText =
            tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));

        expect(
          selectedPlaylistTitleText.data,
          'local',
        );

        // verify the newly selected playlist audio titles

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
          firstAudioListTileIndex: 2,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets('''First, select a local playlist. Then, enter the search word
          'S8' in the 'Youtube Link or Search' text field.''',
          (WidgetTester tester) async {
        // Click on the enabled search icon button and verify the modified
        // displayed playlist list list, the currently selected playlist title
        // and its audio list.
        //
        // Then, select the Youtube filtered playlist and verify the updated
        // selected playlist title as well as its audio list.
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'sort_and_filter_audio_dialog_widget_three_playlists_test',
          tapOnPlaylistToggleButton: true,
        );

        // Find the local playlist to select

        // First, find the Playlist ListTile Text widget
        final Finder localPlaylistToSelectListTileTextWidgetFinder =
            find.text('local');

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

        // Verify the newly selected playlist title

        Text selectedPlaylistTitleText =
            tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));

        expect(
          selectedPlaylistTitleText.data,
          'local',
        );

        // verify the local selected playlist audio titles

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

        playlistsTitles =
            await enteringFirstAndSecondLetterOfYoutubePlaylistSearchWord(
          tester: tester,
        );

        // Verify the currently selected playlist title

        selectedPlaylistTitleText =
            tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));

        expect(
          selectedPlaylistTitleText.data,
          'local',
        );

        // Find the Youtube playlist to select

        // First, find the Playlist ListTile Text widget
        final Finder youtubePlaylistToSelectListTileTextWidgetFinder =
            find.text('S8 audio');

        // Then obtain the Playlist ListTile widget enclosing the Text widget
        // by finding its ancestor
        final Finder youtubePlaylistToSelectListTileWidgetFinder =
            find.ancestor(
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

        // since a Youtube playlist is selected, verify that
        // some buttons are enabled and some are disabled
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

        // Verify the newly selected playlist title

        selectedPlaylistTitleText =
            tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));

        expect(
          selectedPlaylistTitleText.data,
          'S8 audio',
        );

        // verify the youtube selected playlist audio titles

        playlistsTitles = [
          "S8 audio",
        ];

        audioTitles = [
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        ];

        IntegrationTestUtil.checkPlaylistAndAudioTitlesOrderInListTile(
          tester: tester,
          playlistTitlesOrderedLst: playlistsTitles,
          audioTitlesOrderedLst: audioTitles,
          firstPlaylistListTileIndex: 0,
          firstAudioListTileIndex: 1,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
    group(
        'Selecting and moving searched playlist found by applying search word',
        () {
      testWidgets('''First, enter the search word 'al' in the 'Youtube Link or
           Search' text field.''', (WidgetTester tester) async {
        // Click on the enabled search icon button and verify the reduced
        // displayed playlist list list.
        //
        // Then, select one of the filtered playlist and click on the move
        // up icon button to reposition the selected playlist. Verify the
        // updated selected playlist title as well as its audio list.
        // Then click again on the move up icon button to reposition the
        // selected playlist. Remove the search word and verify the playlist
        // titles order.
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'sort_and_filter_audio_dialog_widget_three_playlists_test',
          tapOnPlaylistToggleButton: true,
        );

        List<String> playlistsTitles =
            await _enteringFirstAndSecondLetterOfLocalPlaylistSearchWord(
          tester: tester,
        );

        // Verify the currently selected playlist title

        Text selectedPlaylistTitleText =
            tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));

        expect(
          selectedPlaylistTitleText.data,
          'S8 audio',
        );

        // Find the local playlist to select

        // First, find the Playlist ListTile Text widget
        final Finder localPlaylistToSelectListTileTextWidgetFinder =
            find.text(playlistsTitles[1]); // local_2

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

        // Verify the newly selected playlist title

        selectedPlaylistTitleText =
            tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));

        expect(
          selectedPlaylistTitleText.data,
          'local_2',
        );

        // Now tap on the move up icon button to reposition the selected
        // playlist

        await tester.tap(find.byKey(const Key('move_up_playlist_button')));
        await tester.pumpAndSettle();

        // Verify the selected moved playlist title

        selectedPlaylistTitleText =
            tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));

        expect(
          selectedPlaylistTitleText.data,
          'local_2',
        );

        // verify the order of the reduced playlist titles

        playlistsTitles = [
          "local_2",
          "local",
        ];

        IntegrationTestUtil.checkPlaylistAndAudioTitlesOrderInListTile(
          tester: tester,
          playlistTitlesOrderedLst: playlistsTitles,
          audioTitlesOrderedLst: null,
          firstPlaylistListTileIndex: 0,
          firstAudioListTileIndex: 2,
        );

        // Now re-tap on the move up icon button to reposition the selected
        // playlist

        await tester.tap(find.byKey(const Key('move_up_playlist_button')));
        await tester.pumpAndSettle();

        // Verify the selected moved playlist title

        selectedPlaylistTitleText =
            tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));

        expect(
          selectedPlaylistTitleText.data,
          'local_2',
        );

        // verify the order of the reduced playlist titles

        playlistsTitles = [
          "local_2",
          "local",
        ];

        IntegrationTestUtil.checkPlaylistAndAudioTitlesOrderInListTile(
          tester: tester,
          playlistTitlesOrderedLst: playlistsTitles,
          audioTitlesOrderedLst: null,
          firstPlaylistListTileIndex: 0,
          firstAudioListTileIndex: 2,
        );

        // Finally, clear the search text word

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

        // verify the order of the complete playlist titles

        playlistsTitles = [
          "local_2",
          "S8 audio",
          "local",
        ];

        IntegrationTestUtil.checkPlaylistAndAudioTitlesOrderInListTile(
          tester: tester,
          playlistTitlesOrderedLst: playlistsTitles,
          audioTitlesOrderedLst: null,
          firstPlaylistListTileIndex: 0,
          firstAudioListTileIndex: 2,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
    group('Audio search word to playlist selection', () {
      testWidgets('''First, enter the search word 'al' in the
          'Youtube Link or Search' text field.''', (WidgetTester tester) async {
        // After entering 'al', verify that the search icon button is now enabled.
        // Then, click on the enabled search icon button and verify the reduced
        // displayed audio list. After that, click on the "Playlists" button in
        // order to display playlists and verify that the list of displayed
        // playlists corresponds to the search tet field. Then modify the search
        // word and finally empty it.
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'sort_and_filter_audio_dialog_widget_three_playlists_test',
          tapOnPlaylistToggleButton: false,
        );

        // Enter the two letters of the 'al' search word. The crazy integration
        // test does not always update the test field. To fix this bug, first
        // select the text field and then enter the text.

        // Select the text field
        await tester.tap(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
        );
        await tester.pumpAndSettle();

        // Enter the 2 letters of the 'al' search word
        await tester.enterText(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
          'al',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Now verify the order of the reduced playlist audio titles

        List<String>
            audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Now tap on the "Playlists" button
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the order of the reduced playlist titles

        List<String> playlistsTitles = [
          "local",
          "local_2",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed playlist list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Now add the third letter of the 'al_' search word
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
          '_',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is still enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // And verify the order of the playlist titles. Since
        // the search icon button was used, modifying the search text
        // is applied at each search text change

        playlistsTitles = [
          "local_2",
        ];

        // Ensure that since the search icon button was used,
        // the displayed playlist list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Now remove the third and second letter of the 'al_' search word
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
          'a',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is still enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Then erase the second search word letter
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
          'a',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Now verify the order of the augmented playlist titles

        playlistsTitles = [
          "S8 audio",
          "local",
          "local_2",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Now emptying the search text word
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

        // Verify that the search icon button is now disabled
        IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
    group('Playlist search word to audio selection', () {
      testWidgets('''First, enter the search word 'al' in the
          'Youtube Link or Search' text field.''', (WidgetTester tester) async {
        // After entering 'al', verify that the search icon button is now enabled.
        // Then, click on the enabled search icon button and verify the reduced
        // displayed playlist list. After that, click on the "Playlists" button in
        // order to hide the playlists and expand the audio list and verify that
        // the list of displayed audio corresponds to the search text field. Then
        // modify the search word and finally empty it.
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'sort_and_filter_audio_dialog_widget_three_playlists_test',
          tapOnPlaylistToggleButton: true,
        );

        // Enter the two letters of the 'al' search word. The crazy integration
        // test does not always update the test field. To fix this bug, first
        // select the text field and then enter the text.

        // Select the text field
        await tester.tap(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
        );
        await tester.pumpAndSettle();

        // Enter the 2 letters of the 'al' search word
        await tester.enterText(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
          'al',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Verify the order of the reduced playlist titles

        List<String> playlistsTitles = [
          "local",
          "local_2",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed playlist list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Now tap on the "Playlists" button to reduce the list
        // of playlists
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Now verify the order of the reduced selected playlist audio titles

        List<String>
            audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Now replace the second letter 'l' of 'al' by 'u' search word
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
          'au',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is still enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // And verify the order of the playlist titles. Since
        // the search icon button was used, modifying the search text
        // is applied at each search text change

        audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button was used,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Now empty the search word
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

        // Verify that the search icon button is now disabled
        IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
    group(
        'Audio search word to audio player view and back to playlist download view',
        () {
      testWidgets('''Clicking on audio player view button. First, enter the
           search word 'al' in the 'Youtube Link or Search' text field.''',
          (WidgetTester tester) async {
        // After entering 'al', verify that the search icon button is now enabled.
        // Then, click on the enabled search icon button and verify the reduced
        // displayed audio list. After that, click on the audio player view button
        // and then click on the playlist download view button.
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'sort_and_filter_audio_dialog_widget_three_playlists_test',
          tapOnPlaylistToggleButton: false,
        );

        // Enter the two letters of the 'al' search word. The crazy integration
        // test does not always update the test field. To fix this bug, first
        // select the text field and then enter the text.

        // Select the text field
        await tester.tap(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
        );
        await tester.pumpAndSettle();

        // Enter the two letters of the 'al' search word
        await tester.enterText(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
          'al',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Now verify the order of the reduced playlist audio titles

        List<String>
            audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Now we tap on the AudioPlayerView icon button to open
        // AudioPlayerView screen

        Finder appScreenNavigationButton =
            find.byKey(const ValueKey('audioPlayerViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // And return to the playlist download view
        Finder playlistDownloadViewNavButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(playlistDownloadViewNavButton);
        await tester.pumpAndSettle();

        // Verify that the search icon button is disabled
        IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Now verify the order of the reduced playlist audio titles

        audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets('''Clicking on audio play button. First, enter the
           search word 'al' in the 'Youtube Link or Search' text field.''',
          (WidgetTester tester) async {
        // After entering 'al', verify that the search icon button is now enabled.
        // Then, click on the enabled search icon button and verify the reduced
        // displayed audio list. After that, click on the audio play button to
        // start playing the audio and open the AudioPlayerView screen and then
        // click on the playlist download view button.
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'sort_and_filter_audio_dialog_widget_three_playlists_test',
          tapOnPlaylistToggleButton: false,
        );

        // Enter the two letters of the 'al' search word. The crazy integration
        // test does not always update the test field. To fix this bug, first
        // select the text field and then enter the text.

        // Select the text field
        await tester.tap(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
        );
        await tester.pumpAndSettle();

        // Enter the two letters of the 'al' search word
        await tester.enterText(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
          'al',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Now verify the order of the reduced playlist audio titles

        String remainingAudioTitle =
            "La surpopulation mondiale par Jancovici et Barrau";
        List<String>
            audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          remainingAudioTitle,
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Now we tap on the remaining audio play icon button to play the audio
        // and to open the AudioPlayerView screen

        final Finder lastDownloadedAudioListTileInkWellFinder =
            IntegrationTestUtil.findAudioItemInkWellWidget(
          remainingAudioTitle,
        );

        await tester.tap(lastDownloadedAudioListTileInkWellFinder);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
          additionalMilliseconds: 1500,
        );

        // And return to the playlist download view
        Finder playlistDownloadViewNavButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(playlistDownloadViewNavButton);
        await tester.pumpAndSettle();

        // Verify that the search icon button is disabled
        IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Now verify the order of the reduced playlist audio titles

        audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets('''Clicking on audio title. First, enter the
           search word 'al' in the 'Youtube Link or Search' text field.''',
          (WidgetTester tester) async {
        // After entering 'al', verify that the search icon button is now enabled.
        // Then, click on the enabled search icon button and verify the reduced
        // displayed audio list. After that, click on the audio play button to
        // start playing the audio and open the AudioPlayerView screen and then
        // click on the playlist download view button.
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'sort_and_filter_audio_dialog_widget_three_playlists_test',
          tapOnPlaylistToggleButton: false,
        );

        // Enter the two letters of the 'al' search word. The crazy integration
        // test does not always update the test field. To fix this bug, first
        // select the text field and then enter the text.

        // Select the text field
        await tester.tap(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
        );
        await tester.pumpAndSettle();

        // Enter the two letters of the 'al' search word
        await tester.enterText(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
          'al',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Now verify the order of the reduced playlist audio titles

        String remainingAudioTitle =
            "La surpopulation mondiale par Jancovici et Barrau";
        List<String>
            audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          remainingAudioTitle,
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Now we tap on the remaining audio title to open the AudioPlayerView
        // screen

        // widget finder and tap on it
        final Finder lastDownloadedAudioListTileTextWidgetFinder =
            find.text(remainingAudioTitle);

        await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // And return to the playlist download view
        Finder playlistDownloadViewNavButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(playlistDownloadViewNavButton);
        await tester.pumpAndSettle();

        // Verify that the search icon button is disabled
        IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Now verify the order of the reduced playlist audio titles

        audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
    group(
        'Playlist search word to audio player view and back to playlist download view',
        () {
      testWidgets('''Clicking on audio player view button. First, enter the
           search word 'al' in the 'Youtube Link or Search' text field.''',
          (WidgetTester tester) async {
        // After entering 'al', verify that the search icon button is now enabled.
        // Then, click on the enabled search icon button and verify the reduced
        // displayed audio list. After that, click on the audio player view button
        // and then click on the playlist download view button.
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'sort_and_filter_audio_dialog_widget_three_playlists_test',
          tapOnPlaylistToggleButton: true,
        );

        // Enter the two letters of the 'al' search word. The crazy integration
        // test does not always update the test field. To fix this bug, first
        // select the text field and then enter the text.

        // Select the text field
        await tester.tap(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
        );
        await tester.pumpAndSettle();

        // Enter the two letters of the 'al' search word
        await tester.enterText(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
          'al',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Now verify the order of the reduced playlist audio titles

        List<String> playlistsTitles = [
          "local",
          "local_2",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Now we tap on the AudioPlayerView icon button to open
        // AudioPlayerView screen

        Finder appScreenNavigationButton =
            find.byKey(const ValueKey('audioPlayerViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // And return to the playlist download view
        Finder playlistDownloadViewNavButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(playlistDownloadViewNavButton);
        await tester.pumpAndSettle();

        // Verify that the search icon button is disabled
        IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Now verify the order of the reduced playlist audio titles

        playlistsTitles = [
          "S8 audio",
          "local",
          "local_2",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets('''Clicking on audio play button. First, enter the
           search word 'al' in the 'Youtube Link or Search' text field.''',
          (WidgetTester tester) async {
        // After entering 'al', verify that the search icon button is now enabled.
        // Then, click on the enabled search icon button and verify the reduced
        // displayed audio list. After that, click on the audio play button to
        // start playing the audio and open the AudioPlayerView screen and then
        // click on the playlist download view button.
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'sort_and_filter_audio_dialog_widget_three_playlists_test',
          tapOnPlaylistToggleButton: true,
        );

        // Enter the two letters of the 'al' search word. The crazy integration
        // test does not always update the test field. To fix this bug, first
        // select the text field and then enter the text.

        // Select the text field
        await tester.tap(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
        );
        await tester.pumpAndSettle();

        // Enter the two letters of the 'al' search word
        await tester.enterText(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
          'al',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Now verify the order of the reduced playlist audio titles

        String remainingAudioTitle = "Les besoins artificiels par R.Keucheyan";

        List<String> playlistsTitles = [
          "local",
          "local_2",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed playlists list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Now we tap on the remaining audio play icon button to play the audio
        // and to open the AudioPlayerView screen

        final Finder lastDownloadedAudioListTileInkWellFinder =
            IntegrationTestUtil.findAudioItemInkWellWidget(
          remainingAudioTitle,
        );

        await tester.tap(lastDownloadedAudioListTileInkWellFinder);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
          additionalMilliseconds: 1500,
        );

        // And return to the playlist download view
        Finder playlistDownloadViewNavButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(playlistDownloadViewNavButton);
        await tester.pumpAndSettle();

        // Verify that the search icon button is disabled
        IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Now verify the order of the reduced playlist audio titles

        playlistsTitles = [
          "S8 audio",
          "local",
          "local_2",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets('''Clicking on audio title. First, enter the
           search word 'al' in the 'Youtube Link or Search' text field.''',
          (WidgetTester tester) async {
        // After entering 'al', verify that the search icon button is now enabled.
        // Then, click on the enabled search icon button and verify the reduced
        // displayed audio list. After that, click on the audio play button to
        // start playing the audio and open the AudioPlayerView screen and then
        // click on the playlist download view button.
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'sort_and_filter_audio_dialog_widget_three_playlists_test',
          tapOnPlaylistToggleButton: true,
        );

        // Enter the two letters of the 'al' search word. The crazy integration
        // test does not always update the test field. To fix this bug, first
        // select the text field and then enter the text.

        // Select the text field
        await tester.tap(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
        );
        await tester.pumpAndSettle();

        // Enter the two letters of the 'al' search word
        await tester.enterText(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
          'al',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Now verify the order of the reduced playlist audio titles

        String remainingAudioTitle = "Les besoins artificiels par R.Keucheyan";
        List<String> playlistsTitles = [
          "local",
          "local_2",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Now we tap on the remaining audio title to open the AudioPlayerView
        // screen

        // widget finder and tap on it
        final Finder lastDownloadedAudioListTileTextWidgetFinder =
            find.text(remainingAudioTitle);

        await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // And return to the playlist download view
        Finder playlistDownloadViewNavButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(playlistDownloadViewNavButton);
        await tester.pumpAndSettle();

        // Verify that the search icon button is disabled
        IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'search_icon_button',
        );

        // Now verify the order of the reduced playlist audio titles

        playlistsTitles = [
          "S8 audio",
          "local",
          "local_2",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
  });
  group('Rewind all playlist audio to start position test', () {
    testWidgets('''Rewind playlist audio for selected playlist''',
        (tester) async {
      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'sort_and_filter_audio_dialog_widget_test',
        tapOnPlaylistToggleButton: false,
      );

      const String youtubePlaylistToRewindTitle = 'S8 audio';

      // Verify the play/pause icon button format and color of
      // all audio of the selected playlist

      List<String> audioTitles = [
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        "La surpopulation mondiale par Jancovici et Barrau",
        "La résilience insulaire par Fiona Roche",
        "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        "Les besoins artificiels par R.Keucheyan",
        "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
      ];

      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: audioTitles[0],
        expectedIcon: Icons.play_arrow,
        expectedIconColor:
            kDarkAndLightEnabledIconColor, // not played icon color
        expectedIconBackgroundColor: Colors.black,
      );

      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: audioTitles[1],
        expectedIcon: Icons.play_arrow,
        expectedIconColor:
            kDarkAndLightEnabledIconColor, // not played icon color
        expectedIconBackgroundColor: Colors.black,
      );

      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: audioTitles[2],
        expectedIcon: Icons.play_arrow,
        expectedIconColor:
            Colors.white, // currently playing or paused icon color
        expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
      );

      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: audioTitles[3],
        expectedIcon: Icons.play_arrow,
        expectedIconColor:
            kDarkAndLightEnabledIconColor, // not played icon color
        expectedIconBackgroundColor: Colors.black,
      );

      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: audioTitles[4],
        expectedIcon: Icons.play_arrow,
        expectedIconColor:
            kSliderThumbColorInDarkMode, // Fully played audio item play icon color
        expectedIconBackgroundColor: Colors.black,
      );

      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: audioTitles[5],
        expectedIcon: Icons.play_arrow,
        expectedIconColor:
            Colors.white, // currently playing or paused icon color
        expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
      );

      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: audioTitles[6],
        expectedIcon: Icons.play_arrow,
        expectedIconColor:
            kSliderThumbColorInDarkMode, // Fully played audio item play icon color
        expectedIconBackgroundColor: Colors.black,
      );

      // Go to audio player view to verify the playlist current
      // audio position (La résilience insulaire par Fiona Roche)
      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Verify the current audio position
      Text audioPositionText = tester
          .widget<Text>(find.byKey(const Key('audioPlayerViewAudioPosition')));
      expect(audioPositionText.data, '2:34');

      Finder audioTitlePositionTextFinder =
          find.text("La résilience insulaire par Fiona Roche\n13:35");
      expect(audioTitlePositionTextFinder, findsOneWidget);

      // Return to playlist download view
      appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Rewind all playlist audio to start position
      await _tapOnRewindPlaylistAudioToStartPositionMenu(
        tester: tester,
        playlistToRewindTitle: youtubePlaylistToRewindTitle,
        numberOfRewindedAudio: 4,
      );

      // Return to audio player view to verify the playlist current
      // audio position set to start (La résilience insulaire par Fiona Roche)
      appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Verify the current audio position
      audioPositionText = tester
          .widget<Text>(find.byKey(const Key('audioPlayerViewAudioPosition')));
      expect(audioPositionText.data, '0:00');

      // Go back to playlist download view
      appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to reduce the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      _verifyAllNowUnplayedAudioPlayPauseIconColor(
        tester: tester,
        audioTitles: audioTitles,
      );

      // Now play then pause "Les besoins artificiels par R.Keucheyan"
      // before rewinding the playlist audio to start position
      await _rewindPlaylistAfterPlayThenPauseAnAudio(
        tester: tester,
        appScreenNavigationButton: appScreenNavigationButton,
        doExpandPlaylistList: true,
        playlistToRewindTitle: youtubePlaylistToRewindTitle,
        audioToPlayTitle: "Les besoins artificiels par R.Keucheyan",
        audioToPlayTitleAndDuration:
            "Les besoins artificiels par R.Keucheyan\n19:05",
      );

      // Now play then pause "La surpopulation mondiale par Jancovici et Barrau"
      // before rewinding the playlist audio to start position
      await _rewindPlaylistAfterPlayThenPauseAnAudio(
        tester: tester,
        appScreenNavigationButton: appScreenNavigationButton,
        doExpandPlaylistList: false,
        playlistToRewindTitle: youtubePlaylistToRewindTitle,
        audioToPlayTitle:
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        audioToPlayTitleAndDuration:
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau\n6:29",
        otherAudioTitleToTapOnBeforeRewinding:
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        otherAudioTitleToTapOnBeforeRewindingDuration:
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau\n6:29",
      );

      // Rewind again all playlist audio to start position. Since
      // the playlist was already rewinded, 0 audio will be rewinded !
      await _tapOnRewindPlaylistAudioToStartPositionMenu(
        tester: tester,
        playlistToRewindTitle: youtubePlaylistToRewindTitle,
        numberOfRewindedAudio: 0,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Rewind playlist audio for unselected playlist. No other playlist
        is selected.''', (tester) async {
      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'sort_and_filter_audio_dialog_widget_test',
        tapOnPlaylistToggleButton: false,
      );

      const String youtubePlaylistToRewindTitle = 'S8 audio';

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Deselect the selected playlist

      // First, find the Playlist ListTile Text widget
      final Finder localPlaylistToSelectListTileTextWidgetFinder =
          find.text(youtubePlaylistToRewindTitle); // 'S8 audio'

      // Then obtain the Playlist ListTile widget enclosing the Text widget
      // by finding its ancestor
      final Finder localPlaylistToSelectListTileWidgetFinder = find.ancestor(
        of: localPlaylistToSelectListTileTextWidgetFinder,
        matching: find.byType(ListTile),
      );

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to unselect the playlist
      final Finder localPlaylistToSelectListTileCheckboxWidgetFinder =
          find.descendant(
        of: localPlaylistToSelectListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Tap the ListTile Playlist checkbox to deselect it
      await tester.tap(localPlaylistToSelectListTileCheckboxWidgetFinder);
      await tester.pumpAndSettle();

      // Rewind all unselected playlist audio to start position
      await _tapOnRewindPlaylistAudioToStartPositionMenu(
        tester: tester,
        playlistToRewindTitle: youtubePlaylistToRewindTitle,
        numberOfRewindedAudio: 4,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('''Rewind playlist audio for unselected playlist, other selected
        playlist exist''', (tester) async {
      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'sort_and_filter_audio_dialog_widget_test',
        tapOnPlaylistToggleButton: false,
      );

      const String youtubePlaylistToRewindTitle = 'S8 audio';
      const String localPlaylistToSelectTitle = 'local';

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Select another playlist than the one whose audio will be
      // rewinded to start position

      // First, find the Playlist ListTile Text widget
      final Finder localPlaylistToSelectListTileTextWidgetFinder =
          find.text(localPlaylistToSelectTitle); // 'local'

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

      // Rewind all unselected playlist audio to start position
      await _tapOnRewindPlaylistAudioToStartPositionMenu(
        tester: tester,
        playlistToRewindTitle: youtubePlaylistToRewindTitle,
        numberOfRewindedAudio: 4,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Rewind local playlist audio for unselected playlist, other selected
        playlist exist''', (tester) async {
      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'sort_and_filter_audio_dialog_widget_test',
        tapOnPlaylistToggleButton: false,
      );

      const String localPlaylistToSelectTitle = 'local';

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Rewind all local playlist audio to start position
      await _tapOnRewindPlaylistAudioToStartPositionMenu(
        tester: tester,
        playlistToRewindTitle: localPlaylistToSelectTitle,
        numberOfRewindedAudio: 4,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('''Rewind local selected playlist audio to start position''',
        (tester) async {
      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'sort_and_filter_audio_dialog_widget_test',
        tapOnPlaylistToggleButton: false,
      );

      const String localPlaylistToSelectTitle = 'local';

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Select another playlist than the one whose audio will be
      // rewinded to start position

      // First, find the Playlist ListTile Text widget
      final Finder localPlaylistToSelectListTileTextWidgetFinder =
          find.text(localPlaylistToSelectTitle); // 'local'

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

      // Rewind all unselected playlist audio to start position
      await _tapOnRewindPlaylistAudioToStartPositionMenu(
        tester: tester,
        playlistToRewindTitle: localPlaylistToSelectTitle,
        numberOfRewindedAudio: 4,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''On audio player view, rewind playlist audio for selected playlist''',
        (tester) async {
      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'sort_and_filter_audio_dialog_widget_test',
        tapOnPlaylistToggleButton: false,
      );

      const String youtubePlaylistToRewindTitle = 'S8 audio';

      // Verify the play/pause icon button format and color of
      // all audio of the selected playlist

      // Go to audio player view to test rewinding current playlist
      // audio position
      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to show the list of playlist's.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Rewind all playlist audio to start position
      await _tapOnRewindPlaylistAudioToStartPositionMenu(
        tester: tester,
        playlistToRewindTitle: youtubePlaylistToRewindTitle,
        numberOfRewindedAudio: 4,
      );

      // Verify the current audio position
      Text audioPositionText = tester
          .widget<Text>(find.byKey(const Key('audioPlayerViewAudioPosition')));
      expect(audioPositionText.data, '0:00');

      // Go back to playlist download view
      appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      List<String> audioTitles = [
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        "La surpopulation mondiale par Jancovici et Barrau",
        "La résilience insulaire par Fiona Roche",
        "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        "Les besoins artificiels par R.Keucheyan",
        "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
      ];

      _verifyAllNowUnplayedAudioPlayPauseIconColor(
        tester: tester,
        audioTitles: audioTitles,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('Change application date format using the date format selection dialog',
      () {
    testWidgets(
        '''Change application date format to the 3 available date formats
        and verify the effect everywhere in the application where the date format
        is applied.''', (tester) async {
      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'date_format_dialog_test',
        tapOnPlaylistToggleButton: false,
      );

      const String youtubePlaylistTitle = 'S8 audio';

      // Verify the play/pause icon button format and color of
      // all audio of the selected playlist

      List<String> audioSubTitles = [
        "0:06:29.0. 2.37 MB at 1.69 MB/sec on 08/01/2024 at 16:35.",
        "0:13:39.0. 4.99 MB at 2.55 MB/sec on 07/01/2024 at 08:16.",
        "0:06:29.0. 2.37 MB at 1.36 MB/sec on 26/12/2023 at 09:45.",
      ];

      List<String> audioSubTitlesWithAudioDownloadDuration = [
        "0:13:39.0. 4.99 MB at 2.55 MB/sec on 07/01/2024 at 08:16. Audio download duration: 0:00:01.",
        "0:06:29.0. 2.37 MB at 1.36 MB/sec on 26/12/2023 at 09:45. Audio download duration: 0:00:01.",
        "0:06:29.0. 2.37 MB at 1.69 MB/sec on 08/01/2024 at 16:35. Audio download duration: 0:00:01.",
      ];

      List<String> audioSubTitlesWithAudioRemainingDuration = [
        "0:13:39.0. Remaining 00:00:04. Listened on 19/08/2024 at 14:46.",
        "0:06:29.0. Remaining 00:00:38. Listened on 16/03/2024 at 17:09.",
        "0:06:29.0. Remaining 00:06:29. Not listened.",
      ];

      List<String> audioSubTitlesLastListenedDateTimeDescending = [
        "0:13:39.0. Listened on 19/08/2024 at 14:46.",
        "0:06:29.0. Listened on 16/03/2024 at 17:09.",
        "0:06:29.0. Not listened.",
      ];

      List<String> audioSubTitlesTitleAsc = [
        "0:06:29.0. 2.37 MB at 1.36 MB/sec on 26/12/2023 at 09:45.",
        "0:06:29.0. 2.37 MB at 1.69 MB/sec on 08/01/2024 at 16:35.",
        "0:13:39.0. 4.99 MB at 2.55 MB/sec on 07/01/2024 at 08:16.",
      ];

      List<String> audioSubTitlesVideoUploadDate = [
        "0:06:29.0. Video upload date: 23/09/2023.",
        "0:13:39.0. Video upload date: 10/09/2023.",
        "0:06:29.0. Video upload date: 12/06/2022.",
      ];

      // Verifying initial dd/MM/yyyy date format application
      await _verifyDateFormatApplication(
        tester: tester,
        audioSubTitles: audioSubTitles,
        audioSubTitlesWithAudioDownloadDuration:
            audioSubTitlesWithAudioDownloadDuration,
        audioSubTitlesWithAudioRemainingDuration:
            audioSubTitlesWithAudioRemainingDuration,
        audioSubTitlesLastListenedDateTimeDescending:
            audioSubTitlesLastListenedDateTimeDescending,
        audioSubTitlesTitleAsc: audioSubTitlesTitleAsc,
        audioSubTitlesVideoUploadDate: audioSubTitlesVideoUploadDate,
        playlistTitle: youtubePlaylistTitle,
        videoUploadDate: "12/06/2022",
        audioDownloadDateTime: "08/01/2024 16:35",
        playlistLastDownloadDateTime: "07/01/2024 16:36",
        commentCreationDate: '12/10/2024',
        commentUpdateDate: '01/11/2024',
      );

      await _selectDateFormat(
        tester: tester,
        dateFormatToSelect: "MM/dd/yyyy",
        previouslySelectedDateFormat: "dd/MM/yyyy",
      );

      audioSubTitles = [
        "0:06:29.0. 2.37 MB at 1.69 MB/sec on 01/08/2024 at 16:35.",
        "0:13:39.0. 4.99 MB at 2.55 MB/sec on 01/07/2024 at 08:16.",
        "0:06:29.0. 2.37 MB at 1.36 MB/sec on 12/26/2023 at 09:45.",
      ];

      audioSubTitlesWithAudioDownloadDuration = [
        "0:13:39.0. 4.99 MB at 2.55 MB/sec on 01/07/2024 at 08:16. Audio download duration: 0:00:01.",
        "0:06:29.0. 2.37 MB at 1.36 MB/sec on 12/26/2023 at 09:45. Audio download duration: 0:00:01.",
        "0:06:29.0. 2.37 MB at 1.69 MB/sec on 01/08/2024 at 16:35. Audio download duration: 0:00:01.",
      ];

      audioSubTitlesWithAudioRemainingDuration = [
        "0:13:39.0. Remaining 00:00:04. Listened on 08/19/2024 at 14:46.",
        "0:06:29.0. Remaining 00:00:38. Listened on 03/16/2024 at 17:09.",
        "0:06:29.0. Remaining 00:06:29. Not listened.",
      ];

      audioSubTitlesLastListenedDateTimeDescending = [
        "0:13:39.0. Listened on 08/19/2024 at 14:46.",
        "0:06:29.0. Listened on 03/16/2024 at 17:09.",
        "0:06:29.0. Not listened.",
      ];

      audioSubTitlesTitleAsc = [
        "0:06:29.0. 2.37 MB at 1.36 MB/sec on 12/26/2023 at 09:45.",
        "0:06:29.0. 2.37 MB at 1.69 MB/sec on 01/08/2024 at 16:35.",
        "0:13:39.0. 4.99 MB at 2.55 MB/sec on 01/07/2024 at 08:16.",
      ];

      audioSubTitlesVideoUploadDate = [
        "0:06:29.0. Video upload date: 09/23/2023.",
        "0:13:39.0. Video upload date: 09/10/2023.",
        "0:06:29.0. Video upload date: 06/12/2022.",
      ];

      // Verifying initial dd/MM/yyyy date format application
      await _verifyDateFormatApplication(
        tester: tester,
        audioSubTitles: audioSubTitles,
        audioSubTitlesWithAudioDownloadDuration:
            audioSubTitlesWithAudioDownloadDuration,
        audioSubTitlesWithAudioRemainingDuration:
            audioSubTitlesWithAudioRemainingDuration,
        audioSubTitlesLastListenedDateTimeDescending:
            audioSubTitlesLastListenedDateTimeDescending,
        audioSubTitlesTitleAsc: audioSubTitlesTitleAsc,
        audioSubTitlesVideoUploadDate: audioSubTitlesVideoUploadDate,
        playlistTitle: youtubePlaylistTitle,
        videoUploadDate: "06/12/2022",
        audioDownloadDateTime: "01/08/2024 16:35",
        playlistLastDownloadDateTime: "01/07/2024 16:36",
        commentCreationDate: '10/12/2024',
        commentUpdateDate: '11/01/2024',
      );

      await _selectDateFormat(
        tester: tester,
        dateFormatToSelect: "yyyy/MM/dd",
        previouslySelectedDateFormat: "MM/dd/yyyy",
      );

      audioSubTitles = [
        "0:06:29.0. 2.37 MB at 1.69 MB/sec on 2024/01/08 at 16:35.",
        "0:13:39.0. 4.99 MB at 2.55 MB/sec on 2024/01/07 at 08:16.",
        "0:06:29.0. 2.37 MB at 1.36 MB/sec on 2023/12/26 at 09:45.",
      ];

      audioSubTitlesWithAudioDownloadDuration = [
        "0:13:39.0. 4.99 MB at 2.55 MB/sec on 2024/01/07 at 08:16. Audio download duration: 0:00:01.",
        "0:06:29.0. 2.37 MB at 1.36 MB/sec on 2023/12/26 at 09:45. Audio download duration: 0:00:01.",
        "0:06:29.0. 2.37 MB at 1.69 MB/sec on 2024/01/08 at 16:35. Audio download duration: 0:00:01.",
      ];

      audioSubTitlesWithAudioRemainingDuration = [
        "0:13:39.0. Remaining 00:00:04. Listened on 2024/08/19 at 14:46.",
        "0:06:29.0. Remaining 00:00:38. Listened on 2024/03/16 at 17:09.",
        "0:06:29.0. Remaining 00:06:29. Not listened.",
      ];

      audioSubTitlesLastListenedDateTimeDescending = [
        "0:13:39.0. Listened on 2024/08/19 at 14:46.",
        "0:06:29.0. Listened on 2024/03/16 at 17:09.",
        "0:06:29.0. Not listened.",
      ];

      audioSubTitlesTitleAsc = [
        "0:06:29.0. 2.37 MB at 1.36 MB/sec on 2023/12/26 at 09:45.",
        "0:06:29.0. 2.37 MB at 1.69 MB/sec on 2024/01/08 at 16:35.",
        "0:13:39.0. 4.99 MB at 2.55 MB/sec on 2024/01/07 at 08:16.",
      ];

      audioSubTitlesVideoUploadDate = [
        "0:06:29.0. Video upload date: 2023/09/23.",
        "0:13:39.0. Video upload date: 2023/09/10.",
        "0:06:29.0. Video upload date: 2022/06/12.",
      ];

      // Verifying initial dd/MM/yyyy date format application
      await _verifyDateFormatApplication(
        tester: tester,
        audioSubTitles: audioSubTitles,
        audioSubTitlesWithAudioDownloadDuration:
            audioSubTitlesWithAudioDownloadDuration,
        audioSubTitlesWithAudioRemainingDuration:
            audioSubTitlesWithAudioRemainingDuration,
        audioSubTitlesLastListenedDateTimeDescending:
            audioSubTitlesLastListenedDateTimeDescending,
        audioSubTitlesTitleAsc: audioSubTitlesTitleAsc,
        audioSubTitlesVideoUploadDate: audioSubTitlesVideoUploadDate,
        playlistTitle: youtubePlaylistTitle,
        videoUploadDate: "2022/06/12",
        audioDownloadDateTime: "2024/01/08 16:35",
        playlistLastDownloadDateTime: "2024/01/07 16:36",
        commentCreationDate: '2024/10/12',
        commentUpdateDate: '2024/11/01',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('Scrolling audio or playlists test', () {
    group('Scrolling audio test', () {
      testWidgets('''Automatic scrolling audio to display current audio.''',
          (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'scrolling_audio_and_playlists_test',
          tapOnPlaylistToggleButton: false,
        );

        // Setting to this field the currently selected playlist title
        String localPlaylistToSelectTitle = 'local_2';

        // Setting to this variables the currently selected audio title of the
        // 'local_2' playlist
        String currentAudioTitle =
            '99-audio learn test short video two 23-06-10';
        String currentAudioSubTitle =
            '0:00:09.8. 61 Ko importé le 30/10/2024 à 08:19.';

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: currentAudioTitle,
          currentAudioSubTitle: currentAudioSubTitle,
        );

        // Unselect the current playlist to verify no available audio
        // are handled correctly by the audio scroll determination

        // First, find the Playlist ListTile Text widget
        Finder localPlaylistToSelectListTileTextWidgetFinder =
            find.text(localPlaylistToSelectTitle);

        // Then obtain the Playlist ListTile widget enclosing the Text widget
        // by finding its ancestor
        Finder localPlaylistToSelectListTileWidgetFinder = find.ancestor(
          of: localPlaylistToSelectListTileTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the Checkbox widget located in the Playlist ListTile
        Finder localPlaylistToSelectListTileCheckboxWidgetFinder =
            find.descendant(
          of: localPlaylistToSelectListTileWidgetFinder,
          matching: find.byKey(const Key('playlist_checkbox_key')),
        );

        // Tap the ListTile Playlist checkbox to unselect it: This ensure
        // a bug was solved
        await tester.tap(localPlaylistToSelectListTileCheckboxWidgetFinder);
        await tester.pumpAndSettle();

        // Select the empty local_5 playlist to verify no available audio
        // are handled correctly by the audio scroll determination

        localPlaylistToSelectTitle = 'local_5';

        // First, find the Playlist ListTile Text widget
        localPlaylistToSelectListTileTextWidgetFinder =
            find.text(localPlaylistToSelectTitle);

        // Then obtain the Playlist ListTile widget enclosing the Text widget
        // by finding its ancestor
        localPlaylistToSelectListTileWidgetFinder = find.ancestor(
          of: localPlaylistToSelectListTileTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the Checkbox widget located in the Playlist ListTile
        // and tap on it to select the playlist
        localPlaylistToSelectListTileCheckboxWidgetFinder = find.descendant(
          of: localPlaylistToSelectListTileWidgetFinder,
          matching: find.byKey(const Key('playlist_checkbox_key')),
        );

        // Tap the ListTile Playlist checkbox to select it: This ensure
        // another bug was solved
        await tester.tap(localPlaylistToSelectListTileCheckboxWidgetFinder);
        await tester.pumpAndSettle();

        // Reselect the local_2 playlist

        localPlaylistToSelectTitle = 'local_2';

        // First, find the Playlist ListTile Text widget
        localPlaylistToSelectListTileTextWidgetFinder =
            find.text(localPlaylistToSelectTitle);

        // Then obtain the Playlist ListTile widget enclosing the Text widget
        // by finding its ancestor
        localPlaylistToSelectListTileWidgetFinder = find.ancestor(
          of: localPlaylistToSelectListTileTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the Checkbox widget located in the Playlist ListTile
        // and tap on it to select the playlist
        localPlaylistToSelectListTileCheckboxWidgetFinder = find.descendant(
          of: localPlaylistToSelectListTileWidgetFinder,
          matching: find.byKey(const Key('playlist_checkbox_key')),
        );

        // Tap the ListTile Playlist checkbox to select it: This ensure
        // another bug was solved
        await tester.tap(localPlaylistToSelectListTileCheckboxWidgetFinder);
        await tester.pumpAndSettle();

        String newAudioToSelectTitle =
            '6-audio learn test short video two 23-06-10';
        String newAudioToSelectSubTitle =
            '0:00:09.8. 61 Ko importé le 30/10/2024 à 08:23.';

        // Go to audio player view to select another audio
        await _selectNewAudioInAudioPlayerViewAndReturnToPlaylistDownloadView(
          tester: tester,
          currentAudioTitle: currentAudioTitle,
          newAudioTitle: newAudioToSelectTitle,
        );

        // Scrolling down the audios list in order to display the commented
        // audio title to delete

        // Find the audio list widget using its key
        final Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll action
        await tester.drag(listFinder, const Offset(0, 100));
        await tester.pumpAndSettle();

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: newAudioToSelectTitle,
          currentAudioSubTitle: newAudioToSelectSubTitle,
        );

        newAudioToSelectTitle = '7-audio learn test short video two 23-06-10';
        String newAudioSubTitle =
            '0:00:09.8. 61 Ko importé le 30/10/2024 à 08:22.';

        // Go to audio player view to select another audio
        await _selectNewAudioInAudioPlayerViewAndReturnToPlaylistDownloadView(
          tester: tester,
          currentAudioTitle: '6-audio learn test short video two 23-06-10',
          newAudioTitle: newAudioToSelectTitle,
        );

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: newAudioToSelectTitle,
          currentAudioSubTitle: newAudioSubTitle,
        );

        newAudioToSelectTitle = '3-audio learn test short video two 23-06-10';

        // Go to audio player view to select another audio
        await _selectNewAudioInAudioPlayerViewAndReturnToPlaylistDownloadView(
          tester: tester,
          currentAudioTitle: '7-audio learn test short video two 23-06-10',
          newAudioTitle: newAudioToSelectTitle,
          offsetValue: 500.0,
        );

        currentAudioSubTitle =
            '0:00:09.8. 61 Ko importé le 30/10/2024 à 08:26.';

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: newAudioToSelectTitle,
          currentAudioSubTitle: currentAudioSubTitle,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets(
          '''Playlist list not displayed, automatic scrolling audio to display current
              audio.''', (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'scrolling_audio_and_playlists_test',
          tapOnPlaylistToggleButton: true, // playlists list not expanded
        );

        // Setting to this variables the currently selected audio title of the
        // 'local_2' playlist
        String currentAudioTitle =
            '99-audio learn test short video two 23-06-10';
        String currentAudioSubTitle =
            '0:00:09.8. 61 Ko importé le 30/10/2024 à 08:19.';

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: currentAudioTitle,
          currentAudioSubTitle: currentAudioSubTitle,
        );

        String newAudioToSelectTitle =
            '8-audio learn test short video two 23-06-10';
        String newAudioToSelectSubTitle =
            '0:00:09.8. 61 Ko importé le 30/10/2024 à 08:21.';

        // Go to audio player view to select another audio
        await _selectNewAudioInAudioPlayerViewAndReturnToPlaylistDownloadView(
          tester: tester,
          currentAudioTitle: currentAudioTitle,
          newAudioTitle: newAudioToSelectTitle,
        );

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: newAudioToSelectTitle,
          currentAudioSubTitle: newAudioToSelectSubTitle,
        );

        newAudioToSelectTitle = '5-audio learn test short video two 23-06-10';

        // Go to audio player view to select another audio
        await _selectNewAudioInAudioPlayerViewAndReturnToPlaylistDownloadView(
          tester: tester,
          currentAudioTitle: '8-audio learn test short video two 23-06-10',
          newAudioTitle: newAudioToSelectTitle,
          offsetValue: 300.0,
        );

        currentAudioSubTitle =
            '0:00:09.8. 61 Ko importé le 30/10/2024 à 08:24.';

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: newAudioToSelectTitle,
          currentAudioSubTitle: currentAudioSubTitle,
        );

        newAudioToSelectTitle = '3-audio learn test short video two 23-06-10';

        // Go to audio player view to select another audio
        await _selectNewAudioInAudioPlayerViewAndReturnToPlaylistDownloadView(
          tester: tester,
          currentAudioTitle: '5-audio learn test short video two 23-06-10',
          newAudioTitle: newAudioToSelectTitle,
          offsetValue: 100.0,
        );

        currentAudioSubTitle =
            '0:00:09.8. 61 Ko importé le 30/10/2024 à 08:26.';

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: newAudioToSelectTitle,
          currentAudioSubTitle: currentAudioSubTitle,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets(
          '''Searching playlist and select it, verifying automatic scrolling
           audio displaying selected playlist current audio.''',
          (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'scrolling_audio_and_playlists_test',
          tapOnPlaylistToggleButton: false,
        );

        // Setting to this field the currently selected playlist title
        String playlistToSelectTitle = 'local_2';

        // Setting to this variables the currently selected audio title of the
        // 'local_2' playlist
        String currentAudioTitle =
            '99-audio learn test short video two 23-06-10';
        String currentAudioSubTitle =
            '0:00:09.8. 61 Ko importé le 30/10/2024 à 08:19.';

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: currentAudioTitle,
          currentAudioSubTitle: currentAudioSubTitle,
        );

        // Now enter the playlist search word
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
          'jeu',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Select the 'Jeunes pianistes extraordinaires' playlist

        playlistToSelectTitle = 'Jeunes pianistes extraordinaires';

        // First, find the Playlist ListTile Text widget
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

        // Tap the ListTile Playlist checkbox to select it: This ensure
        // another bug was solved
        await tester.tap(playlistToSelectListTileCheckboxWidgetFinder);
        await tester.pumpAndSettle();

        String newAudioToSelectTitle =
            'EMOTIONAL AUDITION! young piano prodigy makes the Judges CRY and gets the GOLDEN BUZZER  FGT 2022';

        String newAudioSubTitle =
            '0:10:14.0. 3.75 Mo à 1.64 Mo/sec le 03/11/2024 à 15:19.';

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: newAudioToSelectTitle,
          currentAudioSubTitle: newAudioSubTitle,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets(
          '''Changing sort/filter parameter, automatic scrolling audio to display current
              audio.''', (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'scrolling_audio_and_playlists_test',
          tapOnPlaylistToggleButton: true, // playlists list not expanded
        );

        // Setting to this variables the currently selected audio title of the
        // 'local_2' playlist
        String currentAudioTitle =
            '99-audio learn test short video two 23-06-10';
        String currentAudioSubTitle =
            '0:00:09.8. 61 Ko importé le 30/10/2024 à 08:19.';

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: currentAudioTitle,
          currentAudioSubTitle: currentAudioSubTitle,
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
        final Finder defaultDropDownTextFinder = find.text(defaultFrenchTitle);
        await tester.tap(defaultDropDownTextFinder);
        await tester.pumpAndSettle();

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
          '''Setting searching audio word, automatic scrolling audio to display
              current audio whose title contains the search word.''',
          (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'scrolling_audio_and_playlists_test',
          tapOnPlaylistToggleButton: true, // playlists list not expanded
        );

        // Setting to this variables the currently selected audio title of the
        // 'local_2' playlist
        String currentAudioTitle =
            '99-audio learn test short video two 23-06-10';
        String currentAudioSubTitle =
            '0:00:09.8. 61 Ko importé le 30/10/2024 à 08:19.';

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: currentAudioTitle,
          currentAudioSubTitle: currentAudioSubTitle,
        );

        // Now enter the audio search word
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
          '9-audio',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

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
          '''Selecting playlist in AudioPlayerView select it, verifying automatic scrolling
           audio displaying selected playlist current audio.''',
          (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'scrolling_audio_and_playlists_test',
          tapOnPlaylistToggleButton: false,
        );

        // Setting to this field the currently selected playlist title
        String playlistToSelectTitle = 'local_2';

        // Setting to this variables the currently selected audio title of the
        // 'local_2' playlist
        String currentAudioTitle =
            '99-audio learn test short video two 23-06-10';
        String currentAudioSubTitle =
            '0:00:09.8. 61 Ko importé le 30/10/2024 à 08:19.';

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: currentAudioTitle,
          currentAudioSubTitle: currentAudioSubTitle,
        );

        // Go to the audio player view
        Finder appScreenNavigationButton =
            find.byKey(const ValueKey('audioPlayerViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // Display the selectable playlists
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Select the 'Jeunes pianistes extraordinaires' playlist

        playlistToSelectTitle = 'Jeunes pianistes extraordinaires';

        // Find the playlist to select ListTile Text widget
        Finder playlistToSelectListTileTextWidgetFinder =
            find.text(playlistToSelectTitle);

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

        // Now return to the playlist download view
        appScreenNavigationButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        String newAudioToSelectTitle =
            'EMOTIONAL AUDITION! young piano prodigy makes the Judges CRY and gets the GOLDEN BUZZER  FGT 2022';

        String newAudioSubTitle =
            '0:10:14.0. 3.75 Mo à 1.64 Mo/sec le 03/11/2024 à 15:19.';

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: newAudioToSelectTitle,
          currentAudioSubTitle: newAudioSubTitle,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
    group('Scrolling playlist test', () {
      testWidgets(
          '''In playlist download view, selecting every available playlist and verifying
             it was scrolled correctly.''', (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'scrolling_audio_and_playlists_test',
          tapOnPlaylistToggleButton: false,
        );

        // Now enter the playlist search word
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
          'jeu',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Select the 'Jeunes pianistes extraordinaires' playlist

        String playlistToSelectTitle = 'Jeunes pianistes extraordinaires';

        // First, find the Playlist ListTile Text widget
        await onPlaylistDownloadViewCheckOrTapOnPlaylistCheckbox(
          tester: tester,
          playlistToSelectTitle: playlistToSelectTitle,
          verifyIfCheckboxIsChecked: false,
          tapOnCheckbox: true,
        );

        // Now remove the playlist search word
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

        await onPlaylistDownloadViewCheckOrTapOnPlaylistCheckbox(
          tester: tester,
          playlistToSelectTitle: playlistToSelectTitle,
          verifyIfCheckboxIsChecked: true,
          tapOnCheckbox: false,
        );

        // Now selecting and verifying all the next scrolled selected
        // playlists

        List<String> playlistTitleList = [
          'local_1',
          'local_2',
          'local_3',
          'local_4',
          'local_5',
          'local_6',
          'local_7',
          'local_8',
          'local_9',
          'local_10',
        ];

        for (String playlistToSelectTitle in playlistTitleList) {
          await onPlaylistDownloadViewCheckOrTapOnPlaylistCheckbox(
            tester: tester,
            playlistToSelectTitle: playlistToSelectTitle,
            verifyIfCheckboxIsChecked: false,
            tapOnCheckbox: true,
          );

          await onPlaylistDownloadViewCheckOrTapOnPlaylistCheckbox(
            tester: tester,
            playlistToSelectTitle: playlistToSelectTitle,
            verifyIfCheckboxIsChecked: true,
            tapOnCheckbox: false,
          );
        }

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets(
          '''With search '_1' in playlist download view, selecting available playlist
             and verifying it was scrolled correctly.''', (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'scrolling_playlists_test',
          tapOnPlaylistToggleButton: false,
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

        // Verify the 'local_10' is correctly scrolled so that it is
        // visible
        await onPlaylistDownloadViewCheckOrTapOnPlaylistCheckbox(
          tester: tester,
          playlistToSelectTitle: 'local_10',
          verifyIfCheckboxIsChecked: true,
          tapOnCheckbox: false,
        );

        await executeSearchWordScrollTest(
          tester: tester,
          playlistTitle: 'local_1',
          scrollUpOrDownPlaylistsList: 1000,
        );

        await executeSearchWordScrollTest(
          tester: tester,
          playlistTitle: 'local_13',
          scrollUpOrDownPlaylistsList: -1000,
        );

        await executeSearchWordScrollTest(
          tester: tester,
          playlistTitle: 'local_15',
          scrollUpOrDownPlaylistsList: -1000,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets(
          '''In audio player view, selecting every available playlist and verifying
             it was scrolled correctly in playlist download view.''',
          (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'scrolling_audio_and_playlists_test',
          tapOnPlaylistToggleButton: false,
        );

        // Now enter the playlist search word
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
          'jeu',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Select the 'Jeunes pianistes extraordinaires' playlist

        String playlistToSelectTitleInPlaylistDownloadView =
            'Jeunes pianistes extraordinaires';

        // First, find the Playlist ListTile Text widget
        await onPlaylistDownloadViewCheckOrTapOnPlaylistCheckbox(
          tester: tester,
          playlistToSelectTitle: playlistToSelectTitleInPlaylistDownloadView,
          verifyIfCheckboxIsChecked: false,
          tapOnCheckbox: true,
        );

        await onAudioPlayerViewCheckOrTapOnPlaylistCheckbox(
          tester: tester,
          playlistDownloadViewCurrentlySelectedPlaylistTitle:
              playlistToSelectTitleInPlaylistDownloadView,
          playlistToSelectTitleInAudioPlayerView: 'local_1',
        );

        await onPlaylistDownloadViewCheckOrTapOnPlaylistCheckbox(
          tester: tester,
          playlistToSelectTitle: 'local_1',
          verifyIfCheckboxIsChecked: true,
          tapOnCheckbox: false,
        );

        // Now selecting and verifying all the next scrolled selected
        // playlists

        List<String> playlistTitleList = [
          'local_1',
          'local_2',
          'local_3',
          'local_4',
          'local_5',
          'local_6',
          'local_7',
          'local_8',
          'local_9',
          'local_10',
        ];

        for (int i = 0; i < playlistTitleList.length - 2; i++) {
          String playlistToSelectTitle = playlistTitleList[i];
          String playlistToSelectTitleNext = playlistTitleList[i + 1];
          await onPlaylistDownloadViewCheckOrTapOnPlaylistCheckbox(
            tester: tester,
            playlistToSelectTitle: playlistToSelectTitle,
            verifyIfCheckboxIsChecked: true,
            tapOnCheckbox: false,
          );

          await onAudioPlayerViewCheckOrTapOnPlaylistCheckbox(
            tester: tester,
            playlistDownloadViewCurrentlySelectedPlaylistTitle:
                playlistToSelectTitle,
            playlistToSelectTitleInAudioPlayerView: playlistToSelectTitleNext,
          );
        }

        await onAudioPlayerViewCheckOrTapOnPlaylistCheckbox(
          tester: tester,
          playlistDownloadViewCurrentlySelectedPlaylistTitle: 'local_9',
          playlistToSelectTitleInAudioPlayerView: 'local_10',
        );

        await onPlaylistDownloadViewCheckOrTapOnPlaylistCheckbox(
          tester: tester,
          playlistToSelectTitle: 'local_10',
          verifyIfCheckboxIsChecked: true,
          tapOnCheckbox: false,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
  });
  group('Delete filtered audio from playlist test', () {
    group('Delete filtered uncommented audio from playlist test', () {
      testWidgets(
          '''Select a filter SF parms and apply it. Then, click on the 'Delete
           Filtered Audio' playlist menu and verify the audio suppression as
           well as the audio selection.''', (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'delete_filtered_audio_test',
          tapOnPlaylistToggleButton: true,
        );

        const String youtubePlaylistTitle = 'S8 audio';

        List<String> audioTitleBeforeDeletionLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Verify the displayed audio list before selecting the 'listenedNoCom'.
        // Sort/Filter parm.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleBeforeDeletionLst,
        );

        String sortFilterParmName = 'listenedNoCom';

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'listenedNoCom' sort/filter item
        Finder titleAscDropDownTextFinder = find.text(sortFilterParmName).last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'listenedNoCom'
        // sort/filter parms
        List<String> audioTitleToDeleteBeforeDeletionLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        ];

        // Verify the displayed audio list after selecting the 'listenedNoCom'
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleToDeleteBeforeDeletionLst,
        );

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        String currentAudioTitle =
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik";
        String currentAudioSubTitle =
            "0:13:39.0. 4.99 MB at 2.55 MB/sec on 07/01/2024 at 08:16.";

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: currentAudioTitle,
          currentAudioSubTitle: currentAudioSubTitle,
        );

        // Verify the presence of the audio files which will be deleted

        List<String> audioFileNameToDeleteLst = [
          "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
          "240107-094528-Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik 23-09-10.mp3",
        ];

        List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToDelete in audioFileNameToDeleteLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            true,
          );
        }

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify that the applyed Sort/Filter parms name is displayed
        // after the selected playlist title

        Text selectedSortFilterParmsName = tester
            .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

        expect(
          selectedSortFilterParmsName.data,
          sortFilterParmName,
        );

        // Now test deleting the filtered audio

        // Open the delete filtered audio dialog by clicking first on
        // the 'Filtered Audio Actions ...' playlist menu item and then
        // on the 'Delete Filtered Audio ...' sub-menu item
        await IntegrationTestUtil.typeOnPlaylistSubMenuItem(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
          playlistSubMenuKeyStr: 'popup_menu_delete_filtered_audio',
        );

        // Verifying the confirm dialog title

        final Text deleteFilteredAudioConfirmDialogTitleWidget = tester
            .widget<Text>(find.byKey(const Key('confirmDialogTitleOneKey')));

        expect(deleteFilteredAudioConfirmDialogTitleWidget.data,
            'Delete audio filtered by "$sortFilterParmName" parms from playlist "$youtubePlaylistTitle"');

        // Verify the absence of the help icon button
        expect(find.byIcon(Icons.help_outline), findsNothing);

        // Verifying the confirm dialog message

        final Text deleteFilteredAudioConfirmDialogMessageTextWidget =
            tester.widget<Text>(
                find.byKey(const Key('confirmationDialogMessageKey')));

        expect(deleteFilteredAudioConfirmDialogMessageTextWidget.data,
            'Audio to delete number: 2,\nCorresponding total file size: 7.37 MB,\nCorresponding total duration: 00:20:08.');

        // Now find the confirm button of the delete filtered audio confirm
        // dialog and tap on it
        await tester.tap(find.byKey(const Key('confirmButton')));
        await tester.pumpAndSettle();

        // Verify that the audio files were deleted

        listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToDelete in audioFileNameToDeleteLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            false,
          );
        }

        // Verify that the other files were not deleted

        List<String> remainingAudioFileNameLst = [
          "231226-094526-Ce qui va vraiment sauver notre espèce par Jancovici et Barrau 23-09-23.mp3",
          "231226-094534-3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01.mp3",
          "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.mp3",
          "240107-094546-La résilience insulaire par Fiona Roche 24-01-03.mp3",
          "240701-163607-La surpopulation mondiale par Jancovici et Barrau 23-12-03.mp3",
        ];

        for (String remainingAudioFileName in remainingAudioFileNameLst) {
          expect(
            listMp3FileNames.contains(remainingAudioFileName),
            true,
          );
        }

        // Verify the 'S8 audio' playlist json file

        Playlist loadedPlaylist = loadPlaylist(youtubePlaylistTitle);

        expect(loadedPlaylist.downloadedAudioLst.length, 18);

        List<String> downloadedAudioLst = loadedPlaylist.downloadedAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleToDelete in audioTitleBeforeDeletionLst) {
          expect(
            downloadedAudioLst.contains(audioTitleToDelete),
            true,
          );
        }

        expect(loadedPlaylist.playableAudioLst.length, 5);

        List<String> audioTitleAfterDeletionLst = [
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        List<String> playableAudioLst = loadedPlaylist.playableAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleAfterDeletion in audioTitleAfterDeletionLst) {
          expect(
            playableAudioLst.contains(audioTitleAfterDeletion),
            true,
          );
        }

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the audioTitles content by applying the 'listenedNoCom'
        // sort/filter parms. Since they have been moved, the list is
        // empty.

        // Verify the empty displayed audio list.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: [],
        );

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'default' sort/filter item
        titleAscDropDownTextFinder = find.text('default').last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'default'
        // sort/filter parms after having deleted the filtered audio

        // Verify the displayed audio list after selecting the 'default'.
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleAfterDeletionLst,
        );

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        currentAudioTitle = "La résilience insulaire par Fiona Roche";
        currentAudioSubTitle =
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
          '''Select a fully listened commented audio located in default SF parms
           lower than the filtered SF audio which will be deleted (was downloaded
           before them). Then select a filter SF parms and apply it. Then, click
           on the 'Delete Filtered Audio' playlist menu and verify the audio
           suppression as well as the audio selection.''', (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'delete_filtered_audio_test',
          tapOnPlaylistToggleButton: true,
        );

        const String youtubePlaylistTitle = 'S8 audio';

        List<String> audioTitleBeforeDeletionLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Verify the displayed audio list before selecting the 'listenedNoCom'.
        // Sort/Filter parm.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleBeforeDeletionLst,
        );

        String firstDownloadedAudioTitle =
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

        // Then, tap on the first downloaded Audio ListTile Text
        // widget finder to select this audio. This switch to the
        // audio player view
        final Finder lastDownloadedAudioListTileTextWidgetFinder =
            find.text(firstDownloadedAudioTitle);

        await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // Now, go back to the playlist download view
        final Finder audioPlayerNavButtonFinder =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(audioPlayerNavButtonFinder);
        await tester.pumpAndSettle();

        // Verify the currently selected audio title/subTitle of the
        // 'S8 audio' playlist
        String firstDownloadedAudioSubTitle =
            "0:20:32.0. 7.51 MB at 2.44 MB/sec on 26/12/2023 at 09:45.";

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: firstDownloadedAudioTitle,
          currentAudioSubTitle: firstDownloadedAudioSubTitle,
        );

        String sortFilterParmName = 'listenedNoCom';

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'listenedNoCom' sort/filter item
        Finder titleAscDropDownTextFinder = find.text(sortFilterParmName).last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'listenedNoCom'
        // sort/filter parms
        List<String> audioTitleToDeleteBeforeDeletionLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        ];

        // Verify the displayed audio list after selecting the 'listenedNoCom'
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleToDeleteBeforeDeletionLst,
        );

        // Verify the presence of the audio files which will be deleted

        List<String> audioFileNameToDeleteLst = [
          "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
          "240107-094528-Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik 23-09-10.mp3",
        ];

        List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToDelete in audioFileNameToDeleteLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            true,
          );
        }

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify that the applyed Sort/Filter parms name is displayed
        // after the selected playlist title

        Text selectedSortFilterParmsName = tester
            .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

        expect(
          selectedSortFilterParmsName.data,
          sortFilterParmName,
        );

        // Now test deleting the filtered audio

        // Open the delete filtered audio dialog by clicking first on
        // the 'Filtered Audio Actions ...' playlist menu item and then
        // on the 'Delete Filtered Audio ...' sub-menu item
        await IntegrationTestUtil.typeOnPlaylistSubMenuItem(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
          playlistSubMenuKeyStr: 'popup_menu_delete_filtered_audio',
        );

        // Verifying the confirm dialog message

        final Text deleteFilteredAudioConfirmDialogMessageTextWidget =
            tester.widget<Text>(
                find.byKey(const Key('confirmationDialogMessageKey')));

        expect(deleteFilteredAudioConfirmDialogMessageTextWidget.data,
            'Audio to delete number: 2,\nCorresponding total file size: 7.37 MB,\nCorresponding total duration: 00:20:08.');

        // Now find the confirm button of the delete filtered audio confirm
        // dialog and tap on it
        await tester.tap(find.byKey(const Key('confirmButton')));
        await tester.pumpAndSettle();

        // Verify that the audio files were deleted

        listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToDelete in audioFileNameToDeleteLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            false,
          );
        }

        // Verify that the other files were not deleted

        List<String> remainingAudioFileNameLst = [
          "231226-094526-Ce qui va vraiment sauver notre espèce par Jancovici et Barrau 23-09-23.mp3",
          "231226-094534-3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01.mp3",
          "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.mp3",
          "240107-094546-La résilience insulaire par Fiona Roche 24-01-03.mp3",
          "240701-163607-La surpopulation mondiale par Jancovici et Barrau 23-12-03.mp3",
        ];

        for (String remainingAudioFileName in remainingAudioFileNameLst) {
          expect(
            listMp3FileNames.contains(remainingAudioFileName),
            true,
          );
        }

        // Verify the 'S8 audio' playlist json file

        Playlist loadedPlaylist = loadPlaylist(youtubePlaylistTitle);

        expect(loadedPlaylist.downloadedAudioLst.length, 18);

        List<String> downloadedAudioLst = loadedPlaylist.downloadedAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleToDelete in audioTitleBeforeDeletionLst) {
          expect(
            downloadedAudioLst.contains(audioTitleToDelete),
            true,
          );
        }

        expect(loadedPlaylist.playableAudioLst.length, 5);

        List<String> audioTitleAfterDeletionLst = [
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        List<String> playableAudioLst = loadedPlaylist.playableAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleAfterDeletion in audioTitleAfterDeletionLst) {
          expect(
            playableAudioLst.contains(audioTitleAfterDeletion),
            true,
          );
        }

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the audioTitles content by applying the 'listenedNoCom'
        // sort/filter parms. Since they have been deleted, the list is
        // empty.

        // Verify the empty displayed audio list before selecting the
        // 'listenedNoCom' Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: [],
        );

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'default' sort/filter item
        titleAscDropDownTextFinder = find.text('default').last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'default'
        // sort/filter parms after having deleted the filtered audio

        // Verify the displayed audio list after selecting the 'default'.
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleAfterDeletionLst,
        );

        // Verify the currently selected audio title/subTitle of the
        // 'S8 audio' playlist

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: firstDownloadedAudioTitle,
          currentAudioSubTitle: firstDownloadedAudioSubTitle,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets(
          '''Select a partially listened not commented audio located in default SF
           parms lower than the filtered SF audio which will be deleted (was downloaded
           before them). Then select a filter SF parms and apply it. Then, click
           on the 'Delete Filtered Audio' playlist menu and verify the audio
           suppression as well as the audio selection.''', (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'delete_filtered_audio_test',
          tapOnPlaylistToggleButton: true,
        );

        const String youtubePlaylistTitle = 'S8 audio';

        List<String> audioTitleBeforeDeletionLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Verify the displayed audio list before selecting the 'listenedNoCom'.
        // Sort/Filter parm.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleBeforeDeletionLst,
        );

        String partiallyListenedAudioTitle =
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau";

        // Then, tap on the previously downloaded Audio ListTile Text
        // widget finder to select this audio. This switch to the
        // audio player view
        final Finder previouslyDownloadedAudioListTileTextWidgetFinder =
            find.text(partiallyListenedAudioTitle);

        await tester.tap(previouslyDownloadedAudioListTileTextWidgetFinder);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // Now, go back to the playlist download view
        final Finder audioPlayerNavButtonFinder =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(audioPlayerNavButtonFinder);
        await tester.pumpAndSettle();

        // Verify the currently selected audio title/subTitle of the
        // 'S8 audio' playlist
        String partiallyListenedAudioSubTitle =
            "0:06:29.0. 2.37 MB at 1.36 MB/sec on 26/12/2023 at 09:45.";

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: partiallyListenedAudioTitle,
          currentAudioSubTitle: partiallyListenedAudioSubTitle,
        );

        String sortFilterParmName = 'listenedNoCom';

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'listenedNoCom' sort/filter item
        Finder titleAscDropDownTextFinder = find.text(sortFilterParmName).last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'listenedNoCom'
        // sort/filter parms
        List<String> audioTitleToDeleteBeforeDeletionLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        ];

        // Verify the displayed audio list after selecting the 'listenedNoCom'
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleToDeleteBeforeDeletionLst,
        );

        // Verify the presence of the audio files which will be deleted

        List<String> audioFileNameToDeleteLst = [
          "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
          "240107-094528-Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik 23-09-10.mp3",
        ];

        List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToDelete in audioFileNameToDeleteLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            true,
          );
        }

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify that the applyed Sort/Filter parms name is displayed
        // after the selected playlist title

        Text selectedSortFilterParmsName = tester
            .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

        expect(
          selectedSortFilterParmsName.data,
          sortFilterParmName,
        );

        // Now test deleting the filtered audio

        // Open the delete filtered audio dialog by clicking first on
        // the 'Filtered Audio Actions ...' playlist menu item and then
        // on the 'Delete Filtered Audio ...' sub-menu item
        await IntegrationTestUtil.typeOnPlaylistSubMenuItem(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
          playlistSubMenuKeyStr: 'popup_menu_delete_filtered_audio',
        );

        // Verify the absence of the help icon button
        expect(find.byIcon(Icons.help_outline), findsNothing);

        // Verifying the confirm dialog message

        final Text deleteFilteredAudioConfirmDialogMessageTextWidget =
            tester.widget<Text>(
                find.byKey(const Key('confirmationDialogMessageKey')));

        expect(deleteFilteredAudioConfirmDialogMessageTextWidget.data,
            'Audio to delete number: 2,\nCorresponding total file size: 7.37 MB,\nCorresponding total duration: 00:20:08.');

        // Now find the confirm button of the delete filtered audio confirm
        // dialog and tap on it
        await tester.tap(find.byKey(const Key('confirmButton')));
        await tester.pumpAndSettle();

        // Verify that the audio files were deleted

        listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToDelete in audioFileNameToDeleteLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            false,
          );
        }

        // Verify that the other files were not deleted

        List<String> remainingAudioFileNameLst = [
          "231226-094526-Ce qui va vraiment sauver notre espèce par Jancovici et Barrau 23-09-23.mp3",
          "231226-094534-3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01.mp3",
          "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.mp3",
          "240107-094546-La résilience insulaire par Fiona Roche 24-01-03.mp3",
          "240701-163607-La surpopulation mondiale par Jancovici et Barrau 23-12-03.mp3",
        ];

        for (String remainingAudioFileName in remainingAudioFileNameLst) {
          expect(
            listMp3FileNames.contains(remainingAudioFileName),
            true,
          );
        }

        // Verify the 'S8 audio' playlist json file

        Playlist loadedPlaylist = loadPlaylist(youtubePlaylistTitle);

        expect(loadedPlaylist.downloadedAudioLst.length, 18);

        List<String> downloadedAudioLst = loadedPlaylist.downloadedAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleToDelete in audioTitleBeforeDeletionLst) {
          expect(
            downloadedAudioLst.contains(audioTitleToDelete),
            true,
          );
        }

        expect(loadedPlaylist.playableAudioLst.length, 5);

        List<String> audioTitleAfterDeletionLst = [
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        List<String> playableAudioLst = loadedPlaylist.playableAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleAfterDeletion in audioTitleAfterDeletionLst) {
          expect(
            playableAudioLst.contains(audioTitleAfterDeletion),
            true,
          );
        }

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the audioTitles content by applying the 'listenedNoCom'
        // sort/filter parms. Since they have been deleted, the list is
        // empty.

        // Verify the empty displayed audio list before selecting the
        // 'listenedNoCom' Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: [],
        );

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'default' sort/filter item
        titleAscDropDownTextFinder = find.text('default').last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'default'
        // sort/filter parms after having deleted the filtered audio

        // Verify the displayed audio list after selecting the 'default'.
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleAfterDeletionLst,
        );

        // Verify the currently selected audio title/subTitle of the
        // 'S8 audio' playlist

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: partiallyListenedAudioTitle,
          currentAudioSubTitle: partiallyListenedAudioSubTitle,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets(
          '''Select a partially listened not commented audio located in default SF
           parms higher than the filtered SF audio which will be deleted (was downloaded
           after them). Then select a filter SF parms and apply it. Then, click
           on the 'Delete Filtered Audio' playlist menu and verify the audio
           suppression as well as the audio selection.''', (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'delete_filtered_audio_test',
          tapOnPlaylistToggleButton: true,
        );

        const String youtubePlaylistTitle = 'S8 audio';

        List<String> audioTitleBeforeDeletionLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Verify the displayed audio list before selecting the 'listenedNoCom'.
        // Sort/Filter parm.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleBeforeDeletionLst,
        );

        // Scrolling up the audios list in order to display the last
        // downloaded audio title
        // Find the audio list widget using its key
        final Finder listFinder = find.byKey(const Key('audio_list'));
        // Perform the scroll action
        await tester.drag(listFinder, const Offset(0, 500));
        await tester.pumpAndSettle();

        String fullyThenPartiallyListenedAndFinallySelectedAudioTitle =
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique";

        // Then, tap on the first downloaded Audio ListTile Text
        // widget finder to select this audio. This switch to the
        // audio player view. Since the audio is currently fully
        // played, it will be transformed to partially played.
        final Finder firstDownloadedAudioListTileTextWidgetFinder =
            find.text(fullyThenPartiallyListenedAndFinallySelectedAudioTitle);

        await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // Tapping 2 times on the backward 1 minute icon button. Now, the
        // last downloaded audio of the playlist is partially listened.
        for (int i = 0; i < 5; i++) {
          await tester
              .tap(find.byKey(const Key('audioPlayerViewRewind1mButton')));
          await tester.pumpAndSettle();
        }

        // Now, go back to the playlist download view
        Finder audioPlayerNavButtonFinder =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(audioPlayerNavButtonFinder);
        await tester.pumpAndSettle();

        // Verify the currently selected audio title/subTitle of the
        // 'S8 audio' playlist
        String fullyThenPartiallyListenedAndFinallySelectedAudioSubTitle =
            "0:06:29.0. 2.37 MB at 1.69 MB/sec on 08/01/2024 at 16:35.";

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle:
              fullyThenPartiallyListenedAndFinallySelectedAudioTitle,
          currentAudioSubTitle:
              fullyThenPartiallyListenedAndFinallySelectedAudioSubTitle,
        );

        String partiallyThenFullyListenedAudioTitle =
            "La résilience insulaire par Fiona Roche";

        // Then, tap on the third downloaded Audio ListTile Text
        // widget finder to select this partially played audio.
        // This switch to the audio player view.
        final Finder thirdDownloadedAudioListTileTextWidgetFinder =
            find.text(partiallyThenFullyListenedAudioTitle);

        await tester.tap(thirdDownloadedAudioListTileTextWidgetFinder);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // Now skip to the end of the audio to set it as fully played
        await tester
            .tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
        await tester.pumpAndSettle();

        // Now, go back to the playlist download view
        audioPlayerNavButtonFinder =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(audioPlayerNavButtonFinder);
        await tester.pumpAndSettle();

        // Verify the currently selected audio title/subTitle of the
        // 'S8 audio' playlist
        String partiallyThenFullyListenedAudioSubTitle =
            "0:13:35.0. 4.97 MB at 2.67 MB/sec on 07/01/2024 at 08:16.";

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: partiallyThenFullyListenedAudioTitle,
          currentAudioSubTitle: partiallyThenFullyListenedAudioSubTitle,
        );

        String sortFilterParmName = 'listenedNoCom';

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'listenedNoCom' sort/filter item
        Finder titleAscDropDownTextFinder = find.text(sortFilterParmName).last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'listenedNoCom'
        // sort/filter parms
        List<String> audioTitleToDeleteBeforeDeletionLst = [
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        ];

        // Verify the displayed audio list after selecting the 'listenedNoCom'
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleToDeleteBeforeDeletionLst,
        );

        // Verify the presence of the audio files which will be deleted

        List<String> audioFileNameToDeleteLst = [
          "240107-094546-La résilience insulaire par Fiona Roche 24-01-03.mp3",
          "240107-094528-Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik 23-09-10.mp3",
        ];

        List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToDelete in audioFileNameToDeleteLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            true,
          );
        }

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify that the applyed Sort/Filter parms name is displayed
        // after the selected playlist title

        Text selectedSortFilterParmsName = tester
            .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

        expect(
          selectedSortFilterParmsName.data,
          sortFilterParmName,
        );

        // Now test deleting the filtered audio

        // Open the delete filtered audio dialog by clicking first on
        // the 'Filtered Audio Actions ...' playlist menu item and then
        // on the 'Delete Filtered Audio ...' sub-menu item
        await IntegrationTestUtil.typeOnPlaylistSubMenuItem(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
          playlistSubMenuKeyStr: 'popup_menu_delete_filtered_audio',
        );

        // Verifying the confirm dialog message

        final Text deleteFilteredAudioConfirmDialogMessageTextWidget =
            tester.widget<Text>(
                find.byKey(const Key('confirmationDialogMessageKey')));

        expect(deleteFilteredAudioConfirmDialogMessageTextWidget.data,
            'Audio to delete number: 2,\nCorresponding total file size: 9.96 MB,\nCorresponding total duration: 00:27:14.');

        // Now find the confirm button of the delete filtered audio confirm
        // dialog and tap on it
        await tester.tap(find.byKey(const Key('confirmButton')));
        await tester.pumpAndSettle();

        // Verify that the audio files were deleted

        listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToDelete in audioFileNameToDeleteLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            false,
          );
        }

        // Verify that the other files were not deleted

        List<String> remainingAudioFileNameLst = [
          "231226-094526-Ce qui va vraiment sauver notre espèce par Jancovici et Barrau 23-09-23.mp3",
          "231226-094534-3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01.mp3",
          "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.mp3",
          "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
          "240701-163607-La surpopulation mondiale par Jancovici et Barrau 23-12-03.mp3",
        ];

        for (String remainingAudioFileName in remainingAudioFileNameLst) {
          expect(
            listMp3FileNames.contains(remainingAudioFileName),
            true,
          );
        }

        // Verify the 'S8 audio' playlist json file

        Playlist loadedPlaylist = loadPlaylist(youtubePlaylistTitle);

        expect(loadedPlaylist.downloadedAudioLst.length, 18);

        List<String> downloadedAudioLst = loadedPlaylist.downloadedAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleToDelete in audioTitleBeforeDeletionLst) {
          expect(
            downloadedAudioLst.contains(audioTitleToDelete),
            true,
          );
        }

        expect(loadedPlaylist.playableAudioLst.length, 5);

        List<String> audioTitleAfterDeletionLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        List<String> playableAudioLst = loadedPlaylist.playableAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleAfterDeletion in audioTitleAfterDeletionLst) {
          expect(
            playableAudioLst.contains(audioTitleAfterDeletion),
            true,
          );
        }

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the audioTitles content by applying the 'listenedNoCom'
        // sort/filter parms. Since they have been deleted, the list is
        // empty.

        // Verify the empty displayed audio list before selecting the
        // 'listenedNoCom' Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: [],
        );

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'default' sort/filter item
        titleAscDropDownTextFinder = find.text('default').last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'default'
        // sort/filter parms after having deleted the filtered audio

        // Verify the displayed audio list after selecting the 'default'.
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleAfterDeletionLst,
        );

        // Verify the currently selected audio title/subTitle of the
        // 'S8 audio' playlist

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle:
              fullyThenPartiallyListenedAndFinallySelectedAudioTitle,
          currentAudioSubTitle:
              fullyThenPartiallyListenedAndFinallySelectedAudioSubTitle,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
    group('Delete filtered commented audio from playlist test', () {
      testWidgets(
          '''Select the 'FullyListened' SF parms and apply it. Then, click on the 'Delete
           Filtered Audio' playlist menu and verify the displayed warning as well
           as the suppression of all playlist fully listened audio as well as their
           comments.''', (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'delete_filtered_audio_test',
          tapOnPlaylistToggleButton: true,
        );

        const String youtubePlaylistTitle = 'S8 audio';

        List<String> audioTitleBeforeDeletionLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Verify the displayed audio list before selecting the 'FullyListened'
        // Sort/Filter parm.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleBeforeDeletionLst,
        );

        String sortFilterParmName = 'FullyListened';

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'FullyListened' sort/filter item
        Finder titleAscDropDownTextFinder = find.text(sortFilterParmName).last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'FullyListened'
        // sort/filter parms
        List<String> audioTitleToDeleteBeforeDeletionLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        ];

        // Verify the displayed audio list after selecting the 'listenedNoCom'
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleToDeleteBeforeDeletionLst,
        );

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        String currentAudioTitle =
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik";
        String currentAudioSubTitle =
            "0:13:39.0. 4.99 MB at 2.55 MB/sec on 07/01/2024 at 08:16.";

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: currentAudioTitle,
          currentAudioSubTitle: currentAudioSubTitle,
        );

        // Verify the presence of the audio files which will be later deleted

        List<String> audioFileNameToDeleteLst = [
          "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
          "240107-094528-Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik 23-09-10.mp3",
          "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.mp3",
          "231226-094534-3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01.mp3",
        ];

        List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToDelete in audioFileNameToDeleteLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            true,
          );
        }

        // Verify the presence of the audio comment files which will be later
        // deleted or not

        List<String> audioCommentFileNameToDeleteLst = [
          "231226-094534-3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01.json",
          "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.json",
        ];

        List<String> listCommentJsonFileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio${path.separator}$kCommentDirName",
          fileExtension: 'json',
        );

        for (String audioCommentFileNameToDelete
            in audioCommentFileNameToDeleteLst) {
          expect(
            listCommentJsonFileNames.contains(audioCommentFileNameToDelete),
            true,
          );
        }

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify that the applyed Sort/Filter parms name is displayed
        // after the selected playlist title

        Text selectedSortFilterParmsName = tester
            .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

        expect(
          selectedSortFilterParmsName.data,
          sortFilterParmName,
        );

        // Now test deleting the filtered audio

        // Open the delete filtered audio dialog by clicking first on
        // the 'Filtered Audio Actions ...' playlist menu item and then
        // on the 'Delete Filtered Audio ...' sub-menu item
        await IntegrationTestUtil.typeOnPlaylistSubMenuItem(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
          playlistSubMenuKeyStr: 'popup_menu_delete_filtered_audio',
        );

        // Verifying the confirm dialog title

        Text deleteFilteredAudioConfirmDialogTitleWidget = tester
            .widget<Text>(find.byKey(const Key('confirmDialogTitleOneKey')));

        expect(deleteFilteredAudioConfirmDialogTitleWidget.data,
            'WARNING: you are going to');

        deleteFilteredAudioConfirmDialogTitleWidget = tester
            .widget<Text>(find.byKey(const Key('confirmDialogTitleTwoKey')));

        expect(deleteFilteredAudioConfirmDialogTitleWidget.data,
            'delete COMMENTED and uncommented audio filtered by "$sortFilterParmName" parms from playlist "$youtubePlaylistTitle". Watch the help to solve the problem ...');

        // Verify the absence of the help icon button
        expect(find.byIcon(Icons.help_outline), findsOneWidget);

        // Verifying the confirm dialog message

        final Text deleteFilteredAudioConfirmDialogMessageTextWidget =
            tester.widget<Text>(
                find.byKey(const Key('confirmationDialogMessageKey')));

        expect(deleteFilteredAudioConfirmDialogMessageTextWidget.data,
            'Total audio to delete number: 4,\nCOMMENTED audio to delete number: 2,\nCorresponding total file size: 21.86 MB,\nCorresponding total duration: 00:59:45.');

        // Now find the confirm button of the delete filtered audio confirm
        // dialog and tap on it
        await tester.tap(find.byKey(const Key('confirmButton')));
        await tester.pumpAndSettle();

        // Verify that the audio files were deleted

        listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToDelete in audioFileNameToDeleteLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            false,
          );
        }

        // Verify that the audio comment files were deleted

        listCommentJsonFileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio${path.separator}$kCommentDirName",
          fileExtension: 'json',
        );

        for (String audioCommentFileNameToDelete
            in audioCommentFileNameToDeleteLst) {
          expect(
            listCommentJsonFileNames.contains(audioCommentFileNameToDelete),
            false,
          );
        }

        // Verify that the other files were not deleted

        List<String> remainingAudioFileNameLst = [
          "231226-094526-Ce qui va vraiment sauver notre espèce par Jancovici et Barrau 23-09-23.mp3",
          "240107-094546-La résilience insulaire par Fiona Roche 24-01-03.mp3",
          "240701-163607-La surpopulation mondiale par Jancovici et Barrau 23-12-03.mp3",
        ];

        for (String remainingAudioFileName in remainingAudioFileNameLst) {
          expect(
            listMp3FileNames.contains(remainingAudioFileName),
            true,
          );
        }

        // Verify that the other audio comment files were not deleted

        listCommentJsonFileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio${path.separator}$kCommentDirName",
          fileExtension: 'json',
        );

        final List<String> audioCommentFileNameNotDeletedLst = [
          "231226-094526-Ce qui va vraiment sauver notre espèce par Jancovici et Barrau 23-09-23.json",
        ];

        for (String audioCommentFileNameNotDeleted
            in audioCommentFileNameNotDeletedLst) {
          expect(
            listCommentJsonFileNames.contains(audioCommentFileNameNotDeleted),
            true,
          );
        }

        // Verify the 'S8 audio' playlist json file

        Playlist loadedPlaylist = loadPlaylist(youtubePlaylistTitle);

        expect(loadedPlaylist.downloadedAudioLst.length, 18);

        List<String> downloadedAudioLst = loadedPlaylist.downloadedAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleToDelete in audioTitleBeforeDeletionLst) {
          expect(
            downloadedAudioLst.contains(audioTitleToDelete),
            true,
          );
        }

        expect(loadedPlaylist.playableAudioLst.length, 3);

        List<String> audioTitleAfterDeletionLst = [
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        List<String> playableAudioLst = loadedPlaylist.playableAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleAfterDeletion in audioTitleAfterDeletionLst) {
          expect(
            playableAudioLst.contains(audioTitleAfterDeletion),
            true,
          );
        }

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the audioTitles content by applying the 'listenedNoCom'
        // sort/filter parms. Since they have been deleted, the list is
        // empty.

        // Verify the empty displayed audio list before selecting the
        // 'listenedNoCom' Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: [],
        );

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'default' sort/filter item
        titleAscDropDownTextFinder = find.text('default').last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'default'
        // sort/filter parms after having deleted the filtered audio

        // Verify the displayed audio list after selecting the 'default'.
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleAfterDeletionLst,
        );

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        currentAudioTitle = "La résilience insulaire par Fiona Roche";
        currentAudioSubTitle =
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
          '''SF parms 'default' is applied. Then, click on the 'Delete Filtered
           Audio' playlist menu and verify the displayed warning as well as
           the suppression of all playlist fully listened audio as well as their
           comments.''', (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'delete_filtered_audio_test',
          tapOnPlaylistToggleButton: true,
        );

        const String youtubePlaylistTitle = 'S8 audio';

        List<String> audioTitleBeforeDeletionLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Verify the displayed audio list.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleBeforeDeletionLst,
        );

        String defaultSortFilterParmName =
            'default'; // SF parm when opening the app

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        String currentAudioTitle =
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik";
        String currentAudioSubTitle =
            "0:13:39.0. 4.99 MB at 2.55 MB/sec on 07/01/2024 at 08:16.";

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: currentAudioTitle,
          currentAudioSubTitle: currentAudioSubTitle,
        );

        // Verify the presence of the audio files which will be later deleted

        List<String> audioFileNameToDeleteLst = [
          "231226-094526-Ce qui va vraiment sauver notre espèce par Jancovici et Barrau 23-09-23.mp3",
          "240107-094546-La résilience insulaire par Fiona Roche 24-01-03.mp3",
          "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
          "240107-094528-Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik 23-09-10.mp3",
          "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.mp3",
          "231226-094534-3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01.mp3",
          "240701-163607-La surpopulation mondiale par Jancovici et Barrau 23-12-03.mp3",
        ];

        List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToDelete in audioFileNameToDeleteLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToDelete),
            true,
          );
        }

        // Verify the presence of the audio comment files which will be later
        // deleted

        List<String> audioCommentFileNameToDeleteLst = [
          "231226-094526-Ce qui va vraiment sauver notre espèce par Jancovici et Barrau 23-09-23.json",
          "231226-094534-3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01.json",
          "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.json",
        ];

        List<String> listCommentJsonFileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio${path.separator}$kCommentDirName",
          fileExtension: 'json',
        );

        for (String audioCommentFileNameToDelete
            in audioCommentFileNameToDeleteLst) {
          expect(
            listCommentJsonFileNames.contains(audioCommentFileNameToDelete),
            true,
          );
        }

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify that the applyed Sort/Filter parms name is displayed
        // after the selected playlist title

        Text selectedSortFilterParmsName = tester
            .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

        expect(
          selectedSortFilterParmsName.data,
          defaultSortFilterParmName,
        );

        // Now test deleting the filtered audio

        // Open the delete filtered audio dialog by clicking first on
        // the 'Filtered Audio Actions ...' playlist menu item and then
        // on the 'Delete Filtered Audio ...' sub-menu item
        await IntegrationTestUtil.typeOnPlaylistSubMenuItem(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
          playlistSubMenuKeyStr: 'popup_menu_delete_filtered_audio',
        );

        // Verifying the confirm dialog title

        Text deleteFilteredAudioConfirmDialogTitleWidget = tester
            .widget<Text>(find.byKey(const Key('confirmDialogTitleOneKey')));

        expect(deleteFilteredAudioConfirmDialogTitleWidget.data,
            'WARNING: you are going to');

        deleteFilteredAudioConfirmDialogTitleWidget = tester
            .widget<Text>(find.byKey(const Key('confirmDialogTitleTwoKey')));

        expect(deleteFilteredAudioConfirmDialogTitleWidget.data,
            'delete COMMENTED and uncommented audio filtered by "$defaultSortFilterParmName" parms from playlist "$youtubePlaylistTitle". Watch the help to solve the problem ...');

        // Verify the presence of the help icon button
        expect(find.byIcon(Icons.help_outline), findsOneWidget);

        // Verifying the confirm dialog message

        final Text deleteFilteredAudioConfirmDialogMessageTextWidget =
            tester.widget<Text>(
                find.byKey(const Key('confirmationDialogMessageKey')));

        expect(deleteFilteredAudioConfirmDialogMessageTextWidget.data,
            'Total audio to delete number: 7,\nCOMMENTED audio to delete number: 3,\nCorresponding total file size: 31.99 MB,\nCorresponding total duration: 01:27:27.');

        // Now find the confirm button of the delete filtered audio confirm
        // dialog and tap on it
        await tester.tap(find.byKey(const Key('confirmButton')));
        await tester.pumpAndSettle();

        // Verify that the audio files were deleted

        listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        expect(
          listMp3FileNames.isEmpty,
          true,
        );

        // Verify that the audio comment files were deleted

        listCommentJsonFileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio${path.separator}$kCommentDirName",
          fileExtension: 'json',
        );

        expect(
          listCommentJsonFileNames.isEmpty,
          true,
        );

        // Verify the 'S8 audio' playlist json file

        Playlist loadedPlaylist = loadPlaylist(youtubePlaylistTitle);

        expect(loadedPlaylist.downloadedAudioLst.length, 18);

        List<String> downloadedAudioLst = loadedPlaylist.downloadedAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleToDelete in audioTitleBeforeDeletionLst) {
          expect(
            downloadedAudioLst.contains(audioTitleToDelete),
            true,
          );
        }

        expect(
          loadedPlaylist.playableAudioLst.isEmpty,
          true,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify that the audioTitles content list is empty.

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: [],
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
  });
  group('Move filtered audio from playlist test', () {
    group('Move filtered uncommented audio from playlist test', () {
      testWidgets('''Apply the 'listenedNoCom' SF parms. Then, click on the
          'Move Filtered Audio' playlist menu and verify the audio moved as well
          as the audio selection.''', (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'delete_filtered_audio_test',
          tapOnPlaylistToggleButton: true,
        );

        const String sourcePlaylistTitle = 'S8 audio';
        const String targetPlaylistTitle = 'temp';

        List<String> audioTitleBeforeMovingLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Verify the displayed audio list before selecting the 'listenedNoCom'
        // Sort/Filter parm.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleBeforeMovingLst,
        );

        String sortFilterParmName = 'listenedNoCom';

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'listenedNoCom' sort/filter item
        Finder titleAscDropDownTextFinder = find.text(sortFilterParmName).last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'listenedNoCom'
        // sort/filter parms
        List<String> audioTitleToMoveBeforeMovingLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        ];

        // Verify the displayed audio list after selecting the 'listenedNoCom'
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleToMoveBeforeMovingLst,
        );

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        String currentAudioTitle =
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik";
        String currentAudioSubTitle =
            "0:13:39.0. 4.99 MB at 2.55 MB/sec on 07/01/2024 at 08:16.";

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: currentAudioTitle,
          currentAudioSubTitle: currentAudioSubTitle,
        );

        // Verify the presence of the audio files which will be later moved

        List<String> audioFileNameToMoveLst = [
          "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
          "240107-094528-Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik 23-09-10.mp3",
        ];

        List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToMove in audioFileNameToMoveLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToMove),
            true,
          );
        }

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify that the applyed Sort/Filter parms name is displayed
        // after the selected playlist title

        Text selectedSortFilterParmsName = tester
            .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

        expect(
          selectedSortFilterParmsName.data,
          sortFilterParmName,
        );

        // Now test moving the filtered audio

        // Open the move filtered audio dialog by clicking first on
        // the 'Filtered Audio Actions ...' playlist menu item and then
        // on the 'Move Filtered Audio to Playlist ...' sub-menu item
        await _testMovingOrCopyingFilteredAudio(
          tester: tester,
          sourcePlaylistTitle: sourcePlaylistTitle,
          targetPlaylistTitle: targetPlaylistTitle,
          sortFilterParmName: sortFilterParmName,
          isMove: true,
          movedOrCopiedAudioNumber: 2,
          commentedAudioNumber: 0,
          unmovedOrUncopiedAudioNumber: 0,
        );

        // Verify in source playlist directory that the audio files were
        // moved from

        listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToMove in audioFileNameToMoveLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToMove),
            false,
          );
        }

        // Verify that the other files were not moved

        List<String> remainingAudioFileNameLst = [
          "240107-094546-La résilience insulaire par Fiona Roche 24-01-03.mp3",
          "231226-094526-Ce qui va vraiment sauver notre espèce par Jancovici et Barrau 23-09-23.mp3",
          "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.mp3",
          "231226-094534-3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01.mp3",
          "240701-163607-La surpopulation mondiale par Jancovici et Barrau 23-12-03.mp3",
        ];

        for (String remainingAudioFileName in remainingAudioFileNameLst) {
          expect(
            listMp3FileNames.contains(remainingAudioFileName),
            true,
          );
        }

        // Verify that the audio comment files were not moved

        List<String> listCommentJsonFileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio${path.separator}$kCommentDirName",
          fileExtension: 'json',
        );

        final List<String> audioCommentFileNameNotMovedLst = [
          "231226-094526-Ce qui va vraiment sauver notre espèce par Jancovici et Barrau 23-09-23.json",
          "231226-094534-3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01.json",
          "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.json",
        ];

        for (String audioCommentFileNameNotMoved
            in audioCommentFileNameNotMovedLst) {
          expect(
            listCommentJsonFileNames.contains(audioCommentFileNameNotMoved),
            true,
          );
        }

        // Verify the source 'S8 audio' playlist json file

        Playlist loadedPlaylist = loadPlaylist(sourcePlaylistTitle);

        expect(loadedPlaylist.downloadedAudioLst.length, 18);

        List<String> downloadedAudioLst = loadedPlaylist.downloadedAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleToMove in audioTitleBeforeMovingLst) {
          expect(
            downloadedAudioLst.contains(audioTitleToMove),
            true,
          );
        }

        expect(loadedPlaylist.playableAudioLst.length, 5);

        List<String> audioTitleAfterMovingLst = [
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        List<String> playableAudioLst = loadedPlaylist.playableAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleAfterMoving in audioTitleAfterMovingLst) {
          expect(
            playableAudioLst.contains(audioTitleAfterMoving),
            true,
          );
        }

        // Verify the target playlist directory in which the audio files
        // were moved

        listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$targetPlaylistTitle",
          fileExtension: 'mp3',
        );

        for (String audioFileNameMoved in audioFileNameToMoveLst) {
          expect(
            listMp3FileNames.contains(audioFileNameMoved),
            true,
          );
        }

        // Verify in target playlist directory in which no audio
        // comment files were moved

        listCommentJsonFileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$targetPlaylistTitle${path.separator}$kCommentDirName",
          fileExtension: 'json',
        );

        expect(listCommentJsonFileNames.isEmpty, true);

        // Verify the target 'temp' playlist json file

        loadedPlaylist = loadPlaylist(targetPlaylistTitle);

        expect(loadedPlaylist.downloadedAudioLst.length, 3);

        downloadedAudioLst = loadedPlaylist.downloadedAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleToMove in audioTitleToMoveBeforeMovingLst) {
          expect(
            downloadedAudioLst.contains(audioTitleToMove),
            true,
          );
        }

        expect(loadedPlaylist.playableAudioLst.length, 3);

        playableAudioLst = loadedPlaylist.playableAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleToMove in audioTitleToMoveBeforeMovingLst) {
          expect(
            playableAudioLst.contains(audioTitleToMove),
            true,
          );
        }

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the audioTitles content by applying the 'listenedNoCom'
        // sort/filter parms. Since they have been moved, the list is
        // empty.

        // Verify the empty displayed audio list before selecting the
        // 'default' Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: [],
        );

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'default' sort/filter item
        titleAscDropDownTextFinder = find.text('default').last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'default'
        // sort/filter parms after having moved the filtered audio

        // Verify the displayed audio list after selecting the 'default'.
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleAfterMovingLst,
        );

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        currentAudioTitle = "La résilience insulaire par Fiona Roche";
        currentAudioSubTitle =
            "0:13:35.0. 4.97 MB at 2.67 MB/sec on 07/01/2024 at 08:16.";

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: currentAudioTitle,
          currentAudioSubTitle: currentAudioSubTitle,
        );

        // Verifying the 'temp' target playlist

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Select the 'temp' playlist

        await IntegrationTestUtil.selectPlaylistInPlaylistDownloadView(
          tester: tester,
          playlistToSelectTitle: targetPlaylistTitle,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the moved audioTitles displayed by applying the
        // 'default' SF parms

        audioTitleToMoveBeforeMovingLst.insert(0, "morning _ cinematic video");

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleToMoveBeforeMovingLst,
        );

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        currentAudioTitle = "morning _ cinematic video";
        currentAudioSubTitle =
            "0:00:59.0. 360 KB at 283 KB/sec on 10/01/2024 at 18:18.";

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
      testWidgets('''Select a fully listened commented audio located in default
           SF parms lower than the filtered SF audio which will be moved (was downloaded
           before them). Then select 'listenedNoCom' SF parms and apply it. Then,
           click on the 'Move Filtered Audio' playlist menu and verify the audio
           move as well as the audio selection.''', (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'delete_filtered_audio_test',
          tapOnPlaylistToggleButton: true,
        );

        const String sourcePlaylistTitle = 'S8 audio';
        const String targetPlaylistTitle = 'temp';

        // First, select a fully listened audio downloaded before the
        // audio which will be moved
        //
        // Get the ListTile Text widget finder and tap on it to go
        // to audio player view
        final Finder lastDownloadedAudioListTileTextWidgetFinder = find.text(
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)");

        await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // Go back to playlist download view
        final Finder audioPlayerNavButtonFinder =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(audioPlayerNavButtonFinder);
        await tester.pumpAndSettle();

        String sortFilterParmName = 'listenedNoCom';

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'listenedNoCom' sort/filter item
        Finder titleAscDropDownTextFinder = find.text(sortFilterParmName).last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'listenedNoCom'
        // sort/filter parms
        List<String> audioTitleToMoveBeforeMovingLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        ];

        // Verify the displayed audio list after selecting the 'listenedNoCom'
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleToMoveBeforeMovingLst,
        );

        // Verify the presence of the audio files which will be later moved

        List<String> audioFileNameToMoveLst = [
          "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
          "240107-094528-Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik 23-09-10.mp3",
        ];

        List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToMove in audioFileNameToMoveLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToMove),
            true,
          );
        }

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify that the applyed Sort/Filter parms name is displayed
        // after the selected playlist title

        Text selectedSortFilterParmsName = tester
            .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

        expect(
          selectedSortFilterParmsName.data,
          sortFilterParmName,
        );

        // Now test moving the filtered audio

        // Open the move filtered audio dialog by clicking first on
        // the 'Filtered Audio Actions ...' playlist menu item and then
        // on the 'Move Filtered Audio to Playlist ...' sub-menu item
        await _testMovingOrCopyingFilteredAudio(
          tester: tester,
          sourcePlaylistTitle: sourcePlaylistTitle,
          targetPlaylistTitle: targetPlaylistTitle,
          sortFilterParmName: sortFilterParmName,
          isMove: true,
          movedOrCopiedAudioNumber: 2,
          commentedAudioNumber: 0,
          unmovedOrUncopiedAudioNumber: 0,
        );

        // Verify in source playlist directory that the audio files were
        // moved from

        listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToMove in audioFileNameToMoveLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToMove),
            false,
          );
        }

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'default' sort/filter item
        titleAscDropDownTextFinder = find.text('default').last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'default'
        // sort/filter parms after having moved the filtered audio

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        String currentAudioTitle =
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";
        String currentAudioSubTitle =
            "0:20:32.0. 7.51 MB at 2.44 MB/sec on 26/12/2023 at 09:45.";

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
          '''Select a partially listened not commented audio located in default SF
           parms lower than the filtered SF audio which will be moved (was downloaded
           before them). Then select 'listenedNoCom' SF parms and apply it. Then,
           click  on the 'Move Filtered Audio' playlist menu and verify the audio
           move as well as the audio selection.''', (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'delete_filtered_audio_test',
          tapOnPlaylistToggleButton: true,
        );

        const String sourcePlaylistTitle = 'S8 audio';
        const String targetPlaylistTitle = 'temp';

        // First, select a partially listened audio downloaded before the
        // audio which will be moved
        //
        // Get the ListTile Text widget finder and tap on it to go
        // to audio player view
        final Finder lastDownloadedAudioListTileTextWidgetFinder = find.text(
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        );

        await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
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

        // Now tap on the delete comment icon button to delete the comment
        await tester.tap(find.byKey(const Key('deleteCommentIconButton')));
        await tester.pumpAndSettle();

        // Confirm the deletion of the comment
        await tester.tap(find.byKey(const Key('confirmButton')));
        await tester.pumpAndSettle();

        // Now close the comment list dialog
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Go back to playlist download view
        final Finder audioPlayerNavButtonFinder =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(audioPlayerNavButtonFinder);
        await tester.pumpAndSettle();

        String sortFilterParmName = 'listenedNoCom';

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'listenedNoCom' sort/filter item
        Finder titleAscDropDownTextFinder = find.text(sortFilterParmName).last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'listenedNoCom'
        // sort/filter parms
        List<String> audioTitleToMoveBeforeMovingLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        ];

        // Verify the displayed audio list after selecting the 'listenedNoCom'
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleToMoveBeforeMovingLst,
        );

        // Verify the presence of the audio files which will be later moved

        List<String> audioFileNameToMoveLst = [
          "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
          "240107-094528-Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik 23-09-10.mp3",
        ];

        List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToMove in audioFileNameToMoveLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToMove),
            true,
          );
        }

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify that the applyed Sort/Filter parms name is displayed
        // after the selected playlist title

        Text selectedSortFilterParmsName = tester
            .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

        expect(
          selectedSortFilterParmsName.data,
          sortFilterParmName,
        );

        // Now test moving the filtered audio

        // Open the move filtered audio dialog by clicking first on
        // the 'Filtered Audio Actions ...' playlist menu item and then
        // on the 'Move Filtered Audio to Playlist ...' sub-menu item
        await _testMovingOrCopyingFilteredAudio(
          tester: tester,
          sourcePlaylistTitle: sourcePlaylistTitle,
          targetPlaylistTitle: targetPlaylistTitle,
          sortFilterParmName: sortFilterParmName,
          isMove: true,
          movedOrCopiedAudioNumber: 2,
          commentedAudioNumber: 0,
          unmovedOrUncopiedAudioNumber: 0,
        );

        // Verify in source playlist directory that the audio files were
        // moved from

        listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToMove in audioFileNameToMoveLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToMove),
            false,
          );
        }

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'default' sort/filter item
        titleAscDropDownTextFinder = find.text('default').last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'default'
        // sort/filter parms after having moved the filtered audio

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        String currentAudioTitle =
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau";
        String currentAudioSubTitle =
            "0:06:29.0. 2.37 MB at 1.36 MB/sec on 26/12/2023 at 09:45.";

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
      testWidgets('''Select a partially listened not commented audio located in
           default SF parms higher than the filtered SF audio which will be moved
           (was downloaded after them). Then copy a fully listened not commented
           audio to the target playlist. Then select 'listenedNoCom' SF parms and
           apply it. Then, click on the 'Move Filtered Audio' playlist menu and
           verify the audio move as well as the audio selection.''',
          (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'delete_filtered_audio_test',
          tapOnPlaylistToggleButton: true,
        );

        const String sourcePlaylistTitle = 'S8 audio';
        const String targetPlaylistTitle = 'temp';

        // First, select a fully listened and commented audio downloaded
        // before the audio which will be moved and delete its comment in
        // order for it to be able to be moved. Then copy it to the target
        // playlist so that it won't be moved.
        //
        // Get the ListTile Text widget finder and tap on it to go
        // to audio player view
        final Finder firstDownloadedAudioListTileTextWidgetFinder = find.text(
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        );

        await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
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

        // Now tap on the delete comment icon button to delete the comment
        await tester.tap(find.byKey(const Key('deleteCommentIconButton')));
        await tester.pumpAndSettle();

        // Confirm the deletion of the comment
        await tester.tap(find.byKey(const Key('confirmButton')));
        await tester.pumpAndSettle();

        // Now close the comment list dialog
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Go back to playlist download view
        Finder audioPlayerNavButtonFinder =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(audioPlayerNavButtonFinder);
        await tester.pumpAndSettle();

        // Now, copy this audio to the target playlist so that when
        // moving the uncommented and fully listened audio, this audio
        // won't be moved.

        // Now we want to tap the popup menu of the Audio ListTile
        // "3 fois où un économiste m'a ouvert les yeux (Giraud,
        // Lefournier, Porcher)"

        // Then obtain the Audio ListTile widget enclosing the Text widget by
        // finding its ancestor
        Finder sourceAudioListTileWidgetFinder = find.ancestor(
          of: firstDownloadedAudioListTileTextWidgetFinder,
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
        final Finder popupCopyMenuItem =
            find.byKey(const Key("popup_menu_copy_audio_to_playlist"));

        await tester.tap(popupCopyMenuItem);
        await tester.pumpAndSettle();

        // Find the RadioListTile target playlist to which the audio
        // will be copied

        final Finder targetPlaylistRadioListTile = find.byWidgetPredicate(
          (Widget widget) =>
              widget is RadioListTile &&
              widget.title is Text &&
              (widget.title as Text).data == targetPlaylistTitle,
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

        // Scrolling up the audios list in order to display the last
        // downloaded audio title

        // Find the audio list widget using its key
        final Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll action
        await tester.drag(listFinder, const Offset(0, 400));
        await tester.pumpAndSettle();

        // Now, select a fully listened audio downloaded after the
        // audio which will be moved and transform it to partially
        // played audio
        //
        // Get the ListTile Text widget finder and tap on it to go
        // to audio player view
        final Finder lastDownloadedAudioListTileTextWidgetFinder = find.text(
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        );

        await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // Tap on back 1 minute button to set it partially played
        await tester
            .tap(find.byKey(const Key('audioPlayerViewRewind1mButton')));
        await tester.pumpAndSettle();

        // Go back to playlist download view
        audioPlayerNavButtonFinder =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(audioPlayerNavButtonFinder);
        await tester.pumpAndSettle();

        String sortFilterParmName = 'listenedNoCom';

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'listenedNoCom' sort/filter item
        Finder dropDownTextFinder = find.text(sortFilterParmName).last;
        await tester.tap(dropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'listenedNoCom'
        // sort/filter parms
        List<String> audioTitleToMoveBeforeMovingLst = [
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        ];

        // Verify the displayed audio list after selecting the 'listenedNoCom'
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleToMoveBeforeMovingLst,
        );

        // Verify the presence of the audio files which will be later
        // tried to be moved

        List<String> audioFileNameToMoveLst = [
          "240107-094528-Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik 23-09-10.mp3",
          "231226-094534-3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01.mp3",
        ];

        List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToMove in audioFileNameToMoveLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToMove),
            true,
          );
        }

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Now test moving the filtered audio

        // Open the move filtered audio dialog by clicking first on
        // the 'Filtered Audio Actions ...' playlist menu item and then
        // on the 'Move Filtered Audio to Playlist ...' sub-menu item
        await _testMovingOrCopyingFilteredAudio(
          tester: tester,
          sourcePlaylistTitle: sourcePlaylistTitle,
          targetPlaylistTitle: targetPlaylistTitle,
          sortFilterParmName: sortFilterParmName,
          isMove: true,
          movedOrCopiedAudioNumber: 1,
          commentedAudioNumber: 0,
          unmovedOrUncopiedAudioNumber: 1,
        );

        // Verify in source playlist directory that the audio file were
        // moved from. Only one was moved since the other was copied before
        // on the target playlist

        List<String> audioFileNameMovedLst = [
          "240107-094528-Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik 23-09-10.mp3",
        ];

        listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToMove in audioFileNameMovedLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToMove),
            false,
          );
        }

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'default' sort/filter item
        dropDownTextFinder = find.text('default').last;
        await tester.tap(dropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'default'
        // sort/filter parms after having moved the filtered audio

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        String currentAudioTitle =
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique";
        String currentAudioSubTitle =
            "0:06:29.0. 2.37 MB at 1.69 MB/sec on 08/01/2024 at 16:35.";

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: currentAudioTitle,
          currentAudioSubTitle: currentAudioSubTitle,
        );

        // Verifying the 'temp' target playlist

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Select the 'temp' playlist

        await IntegrationTestUtil.selectPlaylistInPlaylistDownloadView(
          tester: tester,
          playlistToSelectTitle: targetPlaylistTitle,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the moved audioTitles displayed by applying the
        // 'default' SF parms

        audioTitleToMoveBeforeMovingLst.insert(0, "morning _ cinematic video");

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleToMoveBeforeMovingLst,
        );

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        currentAudioTitle = "morning _ cinematic video";
        currentAudioSubTitle =
            "0:00:59.0. 360 KB at 283 KB/sec on 10/01/2024 at 18:18.";

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
    group('Move filtered commented audio from playlist test', () {
      testWidgets('''Select the 'toMoveOrCopy' SF parms and apply it. Then,
           click on the 'Move Filtered Audio' playlist menu and verify the displayed
           warning as well as the move of all playlist fully listened audio as well
           as their comments. Verification done on source as well as target playlists.''',
          (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'delete_filtered_audio_test',
          tapOnPlaylistToggleButton: true,
        );

        const String sourcePlaylistTitle = 'S8 audio';
        const String targetPlaylistTitle = 'temp';

        List<String> audioTitleBeforeMovingLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Verify the displayed audio list before selecting the 'toMoveOrCopy'
        // Sort/Filter parm.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleBeforeMovingLst,
        );

        String sortFilterParmName = 'toMoveOrCopy';

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'toMoveOrCopy' sort/filter item
        Finder titleAscDropDownTextFinder = find.text(sortFilterParmName).last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'toMoveOrCopy'
        // sort/filter parms
        List<String> audioTitleToMoveBeforeMovingLst = [
          "La surpopulation mondiale par Jancovici et Barrau",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        ];

        // Verify the displayed audio list after selecting the 'toMoveOrCopy'
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleToMoveBeforeMovingLst,
        );

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        String currentAudioTitle =
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik";
        String currentAudioSubTitle =
            "0:13:39.0. 4.99 MB at 2.55 MB/sec on 07/01/2024 at 08:16.";

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: currentAudioTitle,
          currentAudioSubTitle: currentAudioSubTitle,
        );

        // Verify the presence of the audio files which will be later moved

        List<String> audioFileNameToMoveLst = [
          "240701-163607-La surpopulation mondiale par Jancovici et Barrau 23-12-03.mp3",
          "240107-094528-Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik 23-09-10.mp3",
          "231226-094534-3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01.mp3",
        ];

        List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToMove in audioFileNameToMoveLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToMove),
            true,
          );
        }

        // Verify the presence of the audio comment files which will be later
        // moved or not

        List<String> audioCommentFileNameToMoveLst = [
          "231226-094534-3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01.json",
        ];

        List<String> listCommentJsonFileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio${path.separator}$kCommentDirName",
          fileExtension: 'json',
        );

        for (String audioCommentFileNameToMove
            in audioCommentFileNameToMoveLst) {
          expect(
            listCommentJsonFileNames.contains(audioCommentFileNameToMove),
            true,
          );
        }

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify that the applyed Sort/Filter parms name is displayed
        // after the selected playlist title

        Text selectedSortFilterParmsName = tester
            .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

        expect(
          selectedSortFilterParmsName.data,
          sortFilterParmName,
        );

        // Now test moving the filtered audio

        // Open the move filtered audio dialog by clicking first on
        // the 'Filtered Audio Actions ...' playlist menu item and then
        // on the 'Move Filtered Audio to Playlist ...' sub-menu item
        await _testMovingOrCopyingFilteredAudio(
          tester: tester,
          sourcePlaylistTitle: sourcePlaylistTitle,
          targetPlaylistTitle: targetPlaylistTitle,
          sortFilterParmName: sortFilterParmName,
          isMove: true,
          movedOrCopiedAudioNumber: 3,
          commentedAudioNumber: 1,
          unmovedOrUncopiedAudioNumber: 0,
        );

        // Verify in source playlist directory that the audio files were
        // moved from

        listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToMove in audioFileNameToMoveLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToMove),
            false,
          );
        }

        // Verify in source playlist directory that the audio comment files
        // were moved from

        listCommentJsonFileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio${path.separator}$kCommentDirName",
          fileExtension: 'json',
        );

        for (String audioCommentFileNameToMove
            in audioCommentFileNameToMoveLst) {
          expect(
            listCommentJsonFileNames.contains(audioCommentFileNameToMove),
            false,
          );
        }

        // Verify that the other files were not moved

        List<String> remainingAudioFileNameLst = [
          "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
          "240107-094546-La résilience insulaire par Fiona Roche 24-01-03.mp3",
          "231226-094526-Ce qui va vraiment sauver notre espèce par Jancovici et Barrau 23-09-23.mp3",
          "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.mp3",
        ];

        for (String remainingAudioFileName in remainingAudioFileNameLst) {
          expect(
            listMp3FileNames.contains(remainingAudioFileName),
            true,
          );
        }

        // Verify that the other audio comment files were not moved

        listCommentJsonFileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio${path.separator}$kCommentDirName",
          fileExtension: 'json',
        );

        final List<String> audioCommentFileNameNotMovedLst = [
          "231226-094526-Ce qui va vraiment sauver notre espèce par Jancovici et Barrau 23-09-23.json",
        ];

        for (String audioCommentFileNameNotMoved
            in audioCommentFileNameNotMovedLst) {
          expect(
            listCommentJsonFileNames.contains(audioCommentFileNameNotMoved),
            true,
          );
        }

        // Verify the source 'S8 audio' playlist json file

        Playlist loadedPlaylist = loadPlaylist(sourcePlaylistTitle);

        expect(loadedPlaylist.downloadedAudioLst.length, 18);

        List<String> downloadedAudioLst = loadedPlaylist.downloadedAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleToMove in audioTitleBeforeMovingLst) {
          expect(
            downloadedAudioLst.contains(audioTitleToMove),
            true,
          );
        }

        expect(loadedPlaylist.playableAudioLst.length, 4);

        List<String> audioTitleAfterMovingLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La résilience insulaire par Fiona Roche",
          "Les besoins artificiels par R.Keucheyan",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        List<String> playableAudioLst = loadedPlaylist.playableAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleAfterMoving in audioTitleAfterMovingLst) {
          expect(
            playableAudioLst.contains(audioTitleAfterMoving),
            true,
          );
        }

        // Verify the target playlist directory in which the audio files
        // were moved

        listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$targetPlaylistTitle",
          fileExtension: 'mp3',
        );

        for (String audioFileNameMoved in audioFileNameToMoveLst) {
          expect(
            listMp3FileNames.contains(audioFileNameMoved),
            true,
          );
        }

        // Verify in target playlist directory in which the audio comment
        // files were moved

        listCommentJsonFileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$targetPlaylistTitle${path.separator}$kCommentDirName",
          fileExtension: 'json',
        );

        for (String audioCommentFileNameMoved
            in audioCommentFileNameToMoveLst) {
          expect(
            listCommentJsonFileNames.contains(audioCommentFileNameMoved),
            true,
          );
        }

        // Verify the target 'temp' playlist json file

        loadedPlaylist = loadPlaylist(targetPlaylistTitle);

        expect(loadedPlaylist.downloadedAudioLst.length, 4);

        downloadedAudioLst = loadedPlaylist.downloadedAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleMoved in audioTitleToMoveBeforeMovingLst) {
          expect(
            downloadedAudioLst.contains(audioTitleMoved),
            true,
          );
        }

        expect(loadedPlaylist.playableAudioLst.length, 4);

        playableAudioLst = loadedPlaylist.playableAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleMoved in audioTitleToMoveBeforeMovingLst) {
          expect(
            playableAudioLst.contains(audioTitleMoved),
            true,
          );
        }

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the audioTitles content by applying the 'toMoveOrCopy'
        // sort/filter parms. Since they have been moved, the list is
        // empty.

        // Verify the empty displayed audio list before selecting the
        // 'default' Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: [],
        );

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'default' sort/filter item
        titleAscDropDownTextFinder = find.text('default').last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'default'
        // sort/filter parms after having moved the filtered audio

        // Verify the displayed audio list after selecting the 'default'.
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleAfterMovingLst,
        );

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        currentAudioTitle = "La résilience insulaire par Fiona Roche";
        currentAudioSubTitle =
            "0:13:35.0. 4.97 MB at 2.67 MB/sec on 07/01/2024 at 08:16.";

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: currentAudioTitle,
          currentAudioSubTitle: currentAudioSubTitle,
        );

        // Verifying the 'temp' target playlist

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Select the 'temp' playlist

        await IntegrationTestUtil.selectPlaylistInPlaylistDownloadView(
          tester: tester,
          playlistToSelectTitle: targetPlaylistTitle,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the moved audioTitles displayed by applying the
        // 'default' SF parms

        audioTitleToMoveBeforeMovingLst.insert(0, "morning _ cinematic video");

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleToMoveBeforeMovingLst,
        );

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        currentAudioTitle = "morning _ cinematic video";
        currentAudioSubTitle =
            "0:00:59.0. 360 KB at 283 KB/sec on 10/01/2024 at 18:18.";

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
          '''SF parms 'default' is applied. Then, click on the 'Move Filtered
           Audio' playlist menu and verify the displayed warning indicating
           that the move operation can not be done when 'default' is applyed.''',
          (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'delete_filtered_audio_test',
          tapOnPlaylistToggleButton: true,
        );

        const String sourcePlaylistTitle = 'S8 audio';
        const String targetPlaylistTitle = 'temp';

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify that the applyed Sort/Filter parms name is displayed
        // after the selected playlist title

        Text selectedSortFilterParmsName = tester
            .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

        expect(
          selectedSortFilterParmsName.data,
          'default',
        );

        // Now test moving the filtered audio

        // Open the move filtered audio dialog by clicking first on
        // the 'Filtered Audio Actions ...' playlist menu item and then
        // on the 'Move Filtered Audio to Playlist ...' sub-menu item
        await IntegrationTestUtil.typeOnPlaylistSubMenuItem(
          tester: tester,
          playlistTitle: sourcePlaylistTitle,
          playlistSubMenuKeyStr: 'popup_menu_move_filtered_audio',
        );

        // Select the target 'temp' playlist

        // Check the value of the select one playlist AlertDialog
        // dialog title
        Text alertDialogTitle = tester.widget(
            find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
        expect(alertDialogTitle.data, 'Select a playlist');

        // Find the RadioListTile target playlist to which the audio
        // will be moved

        Finder radioListTile = find.byWidgetPredicate(
          (Widget widget) {
            return widget is RadioListTile &&
                widget.title is Text &&
                (widget.title as Text).data == targetPlaylistTitle;
          },
        );

        // Tap the target playlist RadioListTile to select it
        await tester.tap(radioListTile);
        await tester.pumpAndSettle();

        // Now find the confirm button and tap on it
        await tester.tap(find.byKey(const Key('confirmButton')));
        await tester.pumpAndSettle();

        // Verifying the warning title

        Text moveFilteredAudioConfirmWarningTitleWidget =
            tester.widget<Text>(find.byKey(const Key('warningDialogTitle')));

        expect(moveFilteredAudioConfirmWarningTitleWidget.data, 'WARNING');

        // Verifying the confirm warning message

        Text moveFilteredAudioConfirmWarningMessageWidget =
            tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

        expect(moveFilteredAudioConfirmWarningMessageWidget.data,
            'Since "default" Sort/Filter parms is selected, no audio can be moved from Youtube playlist "$sourcePlaylistTitle" to local playlist "$targetPlaylistTitle". SOLUTION: define a Sort/Filter parms and apply it before executing this operation ...');

        // Now find the ok button of the confirm dialog and tap on it
        await tester.tap(find.byKey(const Key('warningDialogOkButton')));
        await tester.pumpAndSettle();

        // Verifying the 'temp' target playlist

        // Select the 'temp' playlist

        await IntegrationTestUtil.selectPlaylistInPlaylistDownloadView(
          tester: tester,
          playlistToSelectTitle: targetPlaylistTitle,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the audioTitles with no moved audio displayed by applying
        // the 'default' SF parms

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: ["morning _ cinematic video"],
        );

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        String currentAudioTitle = "morning _ cinematic video";
        String currentAudioSubTitle =
            "0:00:59.0. 360 KB at 283 KB/sec on 10/01/2024 at 18:18.";

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
  });
  group('Copy filtered audio from playlist test', () {
    group('Copy filtered uncommented audio from playlist test', () {
      testWidgets('''Apply the 'listenedNoCom' SF parms. Then, click
          on the 'Copy Filtered Audio' playlist menu and verify the audio copied
          as well as the audio selection.''', (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'delete_filtered_audio_test',
          tapOnPlaylistToggleButton: true,
        );

        const String sourcePlaylistTitle = 'S8 audio';
        const String targetPlaylistTitle = 'temp';

        List<String> audioTitleBeforeCopyingLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Verify the displayed audio list before selecting the 'listenedNoCom'
        // Sort/Filter parm.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleBeforeCopyingLst,
        );

        String sortFilterParmName = 'listenedNoCom';

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'listenedNoCom' sort/filter item
        Finder titleAscDropDownTextFinder = find.text(sortFilterParmName).last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'listenedNoCom'
        // sort/filter parms
        List<String> audioTitleToCopyLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        ];

        // Verify the displayed audio list after selecting the 'listenedNoCom'
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleToCopyLst,
        );

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        String currentAudioTitle =
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik";
        String currentAudioSubTitle =
            "0:13:39.0. 4.99 MB at 2.55 MB/sec on 07/01/2024 at 08:16.";

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: currentAudioTitle,
          currentAudioSubTitle: currentAudioSubTitle,
        );

        // Verify the presence of the audio files which will be later copied

        List<String> audioFileNameToCopyLst = [
          "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
          "240107-094528-Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik 23-09-10.mp3",
        ];

        List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToCopy in audioFileNameToCopyLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToCopy),
            true,
          );
        }

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify that the applyed Sort/Filter parms name is displayed
        // after the selected playlist title

        Text selectedSortFilterParmsName = tester
            .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

        expect(
          selectedSortFilterParmsName.data,
          sortFilterParmName,
        );

        // Now test copying the filtered audio

        // Open the copy filtered audio dialog by clicking first on
        // the 'Filtered Audio Actions ...' playlist menu item and then
        // on the 'Copy Filtered Audio to Playlist ...' sub-menu item
        await _testMovingOrCopyingFilteredAudio(
          tester: tester,
          sourcePlaylistTitle: sourcePlaylistTitle,
          targetPlaylistTitle: targetPlaylistTitle,
          sortFilterParmName: sortFilterParmName,
          isMove: false,
          movedOrCopiedAudioNumber: 2,
          commentedAudioNumber: 0,
          unmovedOrUncopiedAudioNumber: 0,
        );

        // Verify in source playlist directory that the audio files
        // are present after they have been copied

        listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToCopy in audioFileNameToCopyLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToCopy),
            true,
          );
        }

        // Verify the source 'S8 audio' playlist json file

        Playlist loadedPlaylist = loadPlaylist(sourcePlaylistTitle);

        expect(loadedPlaylist.downloadedAudioLst.length, 18);

        List<String> downloadedAudioLst = loadedPlaylist.downloadedAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleToCopy in audioTitleBeforeCopyingLst) {
          expect(
            downloadedAudioLst.contains(audioTitleToCopy),
            true,
          );
        }

        expect(loadedPlaylist.playableAudioLst.length, 7);

        List<String> playableAudioLst = loadedPlaylist.playableAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleAfterCopying in audioTitleBeforeCopyingLst) {
          expect(
            playableAudioLst.contains(audioTitleAfterCopying),
            true,
          );
        }

        // Verify the target playlist directory in which the audio files
        // were copied

        listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$targetPlaylistTitle",
          fileExtension: 'mp3',
        );

        for (String audioFileNameCopied in audioFileNameToCopyLst) {
          expect(
            listMp3FileNames.contains(audioFileNameCopied),
            true,
          );
        }

        // Verify in target playlist directory in which no audio
        // comment files were copied

        List<String> listCommentJsonFileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$targetPlaylistTitle${path.separator}$kCommentDirName",
          fileExtension: 'json',
        );

        expect(listCommentJsonFileNames.isEmpty, true);

        // Verify the target 'temp' playlist json file

        loadedPlaylist = loadPlaylist(targetPlaylistTitle);

        expect(loadedPlaylist.downloadedAudioLst.length, 3);

        downloadedAudioLst = loadedPlaylist.downloadedAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleToCopy in audioTitleToCopyLst) {
          expect(
            downloadedAudioLst.contains(audioTitleToCopy),
            true,
          );
        }

        expect(loadedPlaylist.playableAudioLst.length, 3);

        playableAudioLst = loadedPlaylist.playableAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleToCopy in audioTitleToCopyLst) {
          expect(
            playableAudioLst.contains(audioTitleToCopy),
            true,
          );
        }

        // Tap the 'Toggle List' button to hide the list of playlist's.
        // The source playlist is selected.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the audioTitles content by applying the 'listenedNoCom'
        // sort/filter parms. Since they have been copied, the list was
        // not changed.

        // Verify the filtered audio list before selecting the 'default'
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleToCopyLst,
        );

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'default' sort/filter item
        titleAscDropDownTextFinder = find.text('default').last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'default'
        // sort/filter parms after having copied the filtered audio

        // Verify the displayed audio list after selecting the 'default'.
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleBeforeCopyingLst,
        );

        // Setting to this variables the currently selected audio
        // title/subTitle of the 'S8 audio' playlist
        currentAudioTitle =
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik";
        currentAudioSubTitle =
            "0:13:39.0. 4.99 MB at 2.55 MB/sec on 07/01/2024 at 08:16.";

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: currentAudioTitle,
          currentAudioSubTitle: currentAudioSubTitle,
        );

        // Verifying the 'temp' target playlist

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Select the 'temp' playlist

        await IntegrationTestUtil.selectPlaylistInPlaylistDownloadView(
          tester: tester,
          playlistToSelectTitle: targetPlaylistTitle,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the moved audioTitles displayed by applying the
        // 'default' SF parms

        audioTitleToCopyLst.insert(0, "morning _ cinematic video");

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleToCopyLst,
        );

        // Setting to this variables the currently selected audio
        // title/subTitle of the 'S8 audio' playlist
        currentAudioTitle = "morning _ cinematic video";
        currentAudioSubTitle =
            "0:00:59.0. 360 KB at 283 KB/sec on 10/01/2024 at 18:18.";

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
      testWidgets('''Select a fully listened commented audio located
           in default SF parms lower than the filtered SF audio which will be copied
           (was downloaded before them). Then select 'listenedNoCom' SF parms and
           apply it. Then, click on the 'Copy Filtered Audio' playlist menu and
           verify the audio copy as well as the audio selection.''', (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'delete_filtered_audio_test',
          tapOnPlaylistToggleButton: true,
        );

        const String sourcePlaylistTitle = 'S8 audio';
        const String targetPlaylistTitle = 'temp';

        // First, select a fully listened audio downloaded before the
        // audio which will be copied
        //
        // Get the ListTile Text widget finder and tap on it to go
        // to audio player view
        final Finder lastDownloadedAudioListTileTextWidgetFinder = find.text(
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)");

        await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // Go back to playlist download view
        final Finder audioPlayerNavButtonFinder =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(audioPlayerNavButtonFinder);
        await tester.pumpAndSettle();

        String sortFilterParmName = 'listenedNoCom';

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'listenedNoCom' sort/filter item
        Finder titleAscDropDownTextFinder = find.text(sortFilterParmName).last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'listenedNoCom'
        // sort/filter parms
        List<String> audioTitleToCopyLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        ];

        // Verify the displayed audio list after selecting the 'listenedNoCom'
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleToCopyLst,
        );

        // Verify the presence of the audio files which will be later copied

        List<String> audioFileNameToCopyLst = [
          "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
          "240107-094528-Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik 23-09-10.mp3",
        ];

        List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToCopy in audioFileNameToCopyLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToCopy),
            true,
          );
        }

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify that the applyed Sort/Filter parms name is displayed
        // after the selected playlist title

        Text selectedSortFilterParmsName = tester
            .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

        expect(
          selectedSortFilterParmsName.data,
          sortFilterParmName,
        );

        // Now test copying the filtered audio

        // Open the copy filtered audio dialog by clicking first on
        // the 'Filtered Audio Actions ...' playlist menu item and then
        // on the 'Copy Filtered Audio to Playlist ...' sub-menu item
        await _testMovingOrCopyingFilteredAudio(
          tester: tester,
          sourcePlaylistTitle: sourcePlaylistTitle,
          targetPlaylistTitle: targetPlaylistTitle,
          sortFilterParmName: sortFilterParmName,
          isMove: false, // Copy
          movedOrCopiedAudioNumber: 2,
          commentedAudioNumber: 0,
          unmovedOrUncopiedAudioNumber: 0,
        );

        // Verify in source playlist directory that the audio files were
        // not deleted since they were copied

        listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToCopy in audioFileNameToCopyLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToCopy),
            true,
          );
        }

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'default' sort/filter item
        titleAscDropDownTextFinder = find.text('default').last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'default'
        // sort/filter parms after having copied the filtered audio

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        String currentAudioTitle =
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";
        String currentAudioSubTitle =
            "0:20:32.0. 7.51 MB at 2.44 MB/sec on 26/12/2023 at 09:45.";

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
          '''Select a partially listened not commented audio located
           in default SF parms lower than the filtered SF audio which will be copied
           (was downloaded before them). Then select 'listenedNoCom' SF parms and
           apply it. Then, click on the 'Copy Filtered Audio' playlist menu and
           verify the audio copy as well as the audio selection.''', (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'delete_filtered_audio_test',
          tapOnPlaylistToggleButton: true,
        );

        const String sourcePlaylistTitle = 'S8 audio';
        const String targetPlaylistTitle = 'temp';

        // First, select a partially listened audio downloaded before the
        // audio which will be copied
        //
        // Get the ListTile Text widget finder and tap on it to go
        // to audio player view
        final Finder lastDownloadedAudioListTileTextWidgetFinder = find.text(
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        );

        await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
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

        // Now tap on the delete comment icon button to delete the comment
        await tester.tap(find.byKey(const Key('deleteCommentIconButton')));
        await tester.pumpAndSettle();

        // Confirm the deletion of the comment
        await tester.tap(find.byKey(const Key('confirmButton')));
        await tester.pumpAndSettle();

        // Now close the comment list dialog
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Go back to playlist download view
        final Finder audioPlayerNavButtonFinder =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(audioPlayerNavButtonFinder);
        await tester.pumpAndSettle();

        String sortFilterParmName = 'listenedNoCom';

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'listenedNoCom' sort/filter item
        Finder titleAscDropDownTextFinder = find.text(sortFilterParmName).last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'listenedNoCom'
        // sort/filter parms
        List<String> audioTitleToCopyLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        ];

        // Verify the displayed audio list after selecting the 'listenedNoCom'
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleToCopyLst,
        );

        // Verify the presence of the audio files which will be later copied

        List<String> audioFileNameToCopyLst = [
          "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
          "240107-094528-Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik 23-09-10.mp3",
        ];

        List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToCopy in audioFileNameToCopyLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToCopy),
            true,
          );
        }

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify that the applyed Sort/Filter parms name is displayed
        // after the selected playlist title

        Text selectedSortFilterParmsName = tester
            .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

        expect(
          selectedSortFilterParmsName.data,
          sortFilterParmName,
        );

        // Now test moving the filtered audio

        // Open the copy filtered audio dialog by clicking first on
        // the 'Filtered Audio Actions ...' playlist menu item and then
        // on the 'Copy Filtered Audio to Playlist ...' sub-menu item
        await _testMovingOrCopyingFilteredAudio(
          tester: tester,
          sourcePlaylistTitle: sourcePlaylistTitle,
          targetPlaylistTitle: targetPlaylistTitle,
          sortFilterParmName: sortFilterParmName,
          isMove: false, // Copy
          movedOrCopiedAudioNumber: 2,
          commentedAudioNumber: 0,
          unmovedOrUncopiedAudioNumber: 0,
        );

        // Verify in source playlist directory that the audio files were
        // not moved

        listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToMove in audioFileNameToCopyLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToMove),
            true,
          );
        }

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'default' sort/filter item
        titleAscDropDownTextFinder = find.text('default').last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'default'
        // sort/filter parms after having copied the filtered audio

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        String currentAudioTitle =
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau";
        String currentAudioSubTitle =
            "0:06:29.0. 2.37 MB at 1.36 MB/sec on 26/12/2023 at 09:45.";

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
      testWidgets('''After copy, select a partially listened not commented audio
           located in default SF parms higher than the filtered SF audio which will
           be copied (was downloaded after them). Then copy a fully listened not
           commented audio to the target playlist. Then select 'listenedNoCom' SF
           parms and apply it. Then, click on the 'Copy Filtered Audio' playlist
           menu and verify the audio copy as well as the audio selection.''',
          (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'delete_filtered_audio_test',
          tapOnPlaylistToggleButton: true,
        );

        const String sourcePlaylistTitle = 'S8 audio';
        const String targetPlaylistTitle = 'temp';

        // First, select a fully listened and commented audio downloaded
        // before the audio which will be copied and delete its comment in
        // order for it to be able to be copied. Then copy it to the target
        // playlist so that it won't be copied when executing the filtered
        // audio copy operation.
        //
        // Get the ListTile Text widget finder and tap on it to go to audio
        // player view
        final Finder firstDownloadedAudioListTileTextWidgetFinder = find.text(
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        );

        await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
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

        // Now tap on the delete comment icon button to delete the comment
        await tester.tap(find.byKey(const Key('deleteCommentIconButton')));
        await tester.pumpAndSettle();

        // Confirm the deletion of the comment
        await tester.tap(find.byKey(const Key('confirmButton')));
        await tester.pumpAndSettle();

        // Now close the comment list dialog
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Go back to playlist download view
        Finder audioPlayerNavButtonFinder =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(audioPlayerNavButtonFinder);
        await tester.pumpAndSettle();

        // Now, copy this audio to the target playlist so that when
        // copying the uncommented and fully listened audio, this audio
        // won't be copied.

        // Now we want to tap the popup menu of the Audio ListTile
        // "3 fois où un économiste m'a ouvert les yeux (Giraud,
        // Lefournier, Porcher)"

        // Then obtain the Audio ListTile widget enclosing the Text widget
        // by finding its ancestor
        Finder sourceAudioListTileWidgetFinder = find.ancestor(
          of: firstDownloadedAudioListTileTextWidgetFinder,
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
        final Finder popupCopyMenuItem =
            find.byKey(const Key("popup_menu_copy_audio_to_playlist"));

        await tester.tap(popupCopyMenuItem);
        await tester.pumpAndSettle();

        // Find the RadioListTile target playlist to which the audio
        // will be copied

        final Finder targetPlaylistRadioListTile = find.byWidgetPredicate(
          (Widget widget) =>
              widget is RadioListTile &&
              widget.title is Text &&
              (widget.title as Text).data == targetPlaylistTitle,
        );

        // Tap the target playlist RadioListTile to select it
        await tester.tap(targetPlaylistRadioListTile);
        await tester.pumpAndSettle();

        // Now find the confirm button and tap on it
        await tester.tap(find.byKey(const Key('confirmButton')));
        await tester.pumpAndSettle();

        // Now find the ok button of the confirm dialog and tap on it
        await tester.tap(find.byKey(const Key('warningDialogOkButton')));
        await tester.pumpAndSettle();

        // Scrolling up the audios list in order to display the last
        // downloaded audio title

        // Find the audio list widget using its key
        final Finder listFinder = find.byKey(const Key('audio_list'));

        // Perform the scroll action
        await tester.drag(listFinder, const Offset(0, 400));
        await tester.pumpAndSettle();

        // Now, select a fully listened audio downloaded after the
        // audio which will be copied and transform it to partially
        // played audio
        //
        // Get the ListTile Text widget finder and tap on it to go
        // to audio player view
        final Finder lastDownloadedAudioListTileTextWidgetFinder = find.text(
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        );

        await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // Tap on back 1 minute button to set it partially played
        await tester
            .tap(find.byKey(const Key('audioPlayerViewRewind1mButton')));
        await tester.pumpAndSettle();

        // Go back to playlist download view
        audioPlayerNavButtonFinder =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(audioPlayerNavButtonFinder);
        await tester.pumpAndSettle();

        String sortFilterParmName = 'listenedNoCom';

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'listenedNoCom' sort/filter item
        Finder dropDownTextFinder = find.text(sortFilterParmName).last;
        await tester.tap(dropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'listenedNoCom'
        // sort/filter parms
        List<String> filteredAudioTitleToCopyLst = [
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        ];

        // Verify the displayed audio list after selecting the 'listenedNoCom'
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: filteredAudioTitleToCopyLst,
        );

        // Verify the presence of the audio files which will be later
        // tried to be copied

        List<String> audioFileNameToCopyLst = [
          "240107-094528-Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik 23-09-10.mp3",
          "231226-094534-3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01.mp3",
        ];

        List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToCopy in audioFileNameToCopyLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToCopy),
            true,
          );
        }

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Now test copying the filtered audio

        // Open the copy filtered audio dialog by clicking first on
        // the 'Filtered Audio Actions ...' playlist menu item and then
        // on the 'Copy Filtered Audio to Playlist ...' sub-menu item
        await _testMovingOrCopyingFilteredAudio(
          tester: tester,
          sourcePlaylistTitle: sourcePlaylistTitle,
          targetPlaylistTitle: targetPlaylistTitle,
          sortFilterParmName: sortFilterParmName,
          isMove: false, // Copy
          movedOrCopiedAudioNumber: 1,
          commentedAudioNumber: 0,
          unmovedOrUncopiedAudioNumber: 1,
        );

        // Verify in source playlist directory that the copied audio file
        // are still present.

        listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameCopied in audioFileNameToCopyLst) {
          expect(
            listMp3FileNames.contains(audioFileNameCopied),
            true,
          );
        }

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'default' sort/filter item
        dropDownTextFinder = find.text('default').last;
        await tester.tap(dropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'default'
        // sort/filter parms after having copied the filtered audio

        // Setting to this variables the currently selected audio title/
        // subTitle of the 'S8 audio' playlist
        String currentAudioTitle =
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique";
        String currentAudioSubTitle =
            "0:06:29.0. 2.37 MB at 1.69 MB/sec on 08/01/2024 at 16:35.";

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: currentAudioTitle,
          currentAudioSubTitle: currentAudioSubTitle,
        );

        // Verifying the 'temp' target playlist

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Select the 'temp' playlist

        await IntegrationTestUtil.selectPlaylistInPlaylistDownloadView(
          tester: tester,
          playlistToSelectTitle: targetPlaylistTitle,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the copied audioTitles displayed by applying the
        // 'default' SF parms

        filteredAudioTitleToCopyLst.insert(0, "morning _ cinematic video");

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: filteredAudioTitleToCopyLst,
        );

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        currentAudioTitle = "morning _ cinematic video";
        currentAudioSubTitle =
            "0:00:59.0. 360 KB at 283 KB/sec on 10/01/2024 at 18:18.";

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
    group('Copy filtered commented audio from playlist test', () {
      testWidgets('''Select the 'toMoveOrCopy' SF parms and apply it. Then,
           click on the 'copy Filtered Audio' playlist menu and verify the displayed
           warning as well as the copy of all playlist fully listened audio as well
           as their comments. Verification done on source as well as target playlists.''',
          (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'delete_filtered_audio_test',
          tapOnPlaylistToggleButton: true,
        );

        const String sourcePlaylistTitle = 'S8 audio';
        const String targetPlaylistTitle = 'temp';

        List<String> audioTitleBeforeCopyingLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Verify the displayed audio list before selecting the 'toMoveOrCopy'
        // Sort/Filter parm.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleBeforeCopyingLst,
        );

        String sortFilterParmName = 'toMoveOrCopy';

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        Finder dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        Finder dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'toMoveOrCopy' sort/filter item
        Finder titleAscDropDownTextFinder = find.text(sortFilterParmName).last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'toMoveOrCopy'
        // sort/filter parms
        List<String> audioTitleToCopyLst = [
          "La surpopulation mondiale par Jancovici et Barrau",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        ];

        // Verify the displayed audio list after selecting the 'toMoveOrCopy'
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleToCopyLst,
        );

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        String currentAudioTitle =
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik";
        String currentAudioSubTitle =
            "0:13:39.0. 4.99 MB at 2.55 MB/sec on 07/01/2024 at 08:16.";

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: currentAudioTitle,
          currentAudioSubTitle: currentAudioSubTitle,
        );

        // Verify the presence of the audio files which will be later copied

        List<String> audioFileNameToCopyLst = [
          "240701-163607-La surpopulation mondiale par Jancovici et Barrau 23-12-03.mp3",
          "240107-094528-Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik 23-09-10.mp3",
          "231226-094534-3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01.mp3",
        ];

        List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToMove in audioFileNameToCopyLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToMove),
            true,
          );
        }

        // Verify the presence of the audio comment files which will be later
        // copied or not

        List<String> audioCommentFileNameToCopyLst = [
          "231226-094534-3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01.json",
        ];

        List<String> listCommentJsonFileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio${path.separator}$kCommentDirName",
          fileExtension: 'json',
        );

        for (String audioCommentFileNameToMove
            in audioCommentFileNameToCopyLst) {
          expect(
            listCommentJsonFileNames.contains(audioCommentFileNameToMove),
            true,
          );
        }

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify that the applyed Sort/Filter parms name is displayed
        // after the selected playlist title

        Text selectedSortFilterParmsName = tester
            .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

        expect(
          selectedSortFilterParmsName.data,
          sortFilterParmName,
        );

        // Now test copying the filtered audio

        // Open the copy filtered audio dialog by clicking first on
        // the 'Filtered Audio Actions ...' playlist menu item and then
        // on the 'Copy Filtered Audio to Playlist ...' sub-menu item
        await _testMovingOrCopyingFilteredAudio(
          tester: tester,
          sourcePlaylistTitle: sourcePlaylistTitle,
          targetPlaylistTitle: targetPlaylistTitle,
          sortFilterParmName: sortFilterParmName,
          isMove: false, // Copy
          movedOrCopiedAudioNumber: 3,
          commentedAudioNumber: 1,
          unmovedOrUncopiedAudioNumber: 0,
        );

        // Verify in source playlist directory that the audio files were
        // copied from

        listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
          fileExtension: 'mp3',
        );

        for (String audioFileNameToCopy in audioFileNameToCopyLst) {
          expect(
            listMp3FileNames.contains(audioFileNameToCopy),
            true,
          );
        }

        // Verify in source playlist directory that the audio comment files
        // were copied from

        listCommentJsonFileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio${path.separator}$kCommentDirName",
          fileExtension: 'json',
        );

        for (String audioCommentFileNameToCopy
            in audioCommentFileNameToCopyLst) {
          expect(
            listCommentJsonFileNames.contains(audioCommentFileNameToCopy),
            true,
          );
        }

        // Verify the source 'S8 audio' playlist json file

        Playlist loadedPlaylist = loadPlaylist(sourcePlaylistTitle);

        expect(loadedPlaylist.downloadedAudioLst.length, 18);

        List<String> downloadedAudioLst = loadedPlaylist.downloadedAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleToMove in audioTitleBeforeCopyingLst) {
          expect(
            downloadedAudioLst.contains(audioTitleToMove),
            true,
          );
        }

        expect(loadedPlaylist.playableAudioLst.length, 7);

        List<String> playableAudioLst = loadedPlaylist.playableAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleAfterMoving in audioTitleBeforeCopyingLst) {
          expect(
            playableAudioLst.contains(audioTitleAfterMoving),
            true,
          );
        }

        // Verify the target playlist directory in which the audio files
        // were copied

        listMp3FileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$targetPlaylistTitle",
          fileExtension: 'mp3',
        );

        for (String audioFileNameCopied in audioFileNameToCopyLst) {
          expect(
            listMp3FileNames.contains(audioFileNameCopied),
            true,
          );
        }

        // Verify in target playlist directory in which the audio comment
        // files were copied

        listCommentJsonFileNames = DirUtil.listFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$targetPlaylistTitle${path.separator}$kCommentDirName",
          fileExtension: 'json',
        );

        for (String audioCommentFileNameCopied
            in audioCommentFileNameToCopyLst) {
          expect(
            listCommentJsonFileNames.contains(audioCommentFileNameCopied),
            true,
          );
        }

        // Verify the target 'temp' playlist json file

        loadedPlaylist = loadPlaylist(targetPlaylistTitle);

        expect(loadedPlaylist.downloadedAudioLst.length, 4);

        downloadedAudioLst = loadedPlaylist.downloadedAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleCopied in audioTitleToCopyLst) {
          expect(
            downloadedAudioLst.contains(audioTitleCopied),
            true,
          );
        }

        expect(loadedPlaylist.playableAudioLst.length, 4);

        playableAudioLst = loadedPlaylist.playableAudioLst
            .map((Audio audio) => audio.validVideoTitle)
            .toList();

        for (String audioTitleCopied in audioTitleToCopyLst) {
          expect(
            playableAudioLst.contains(audioTitleCopied),
            true,
          );
        }

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the audioTitles content by applying the 'toMoveOrCopy'
        // sort/filter parms. Since they have been copied, the list is
        // not empty.

        // Verify the displayed audio list before selecting the 'default'
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleToCopyLst,
        );

        // Now tap on the current dropdown button item to open the dropdown
        // button items list

        dropDownButtonFinder =
            find.byKey(const Key('sort_filter_parms_dropdown_button'));

        dropDownButtonTextFinder = find.descendant(
          of: dropDownButtonFinder,
          matching: find.byType(Text),
        );

        await tester.tap(dropDownButtonTextFinder);
        await tester.pumpAndSettle();

        // Find and tap on the 'default' sort/filter item
        titleAscDropDownTextFinder = find.text('default').last;
        await tester.tap(titleAscDropDownTextFinder);
        await tester.pumpAndSettle();

        // Verify the audioTitles selected by applying the 'default'
        // sort/filter parms after having moved the filtered audio

        // Verify the displayed audio list after selecting the 'default'.
        // Sort/Filter parms.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleBeforeCopyingLst,
        );

        // Verify that the current audio is displayed with the correct
        // title and subtitle color
        await IntegrationTestUtil.verifyCurrentAudioTitleAndSubTitleColor(
          tester: tester,
          currentAudioTitle: currentAudioTitle,
          currentAudioSubTitle: currentAudioSubTitle,
        );

        // Verifying the 'temp' target playlist

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Select the 'temp' playlist

        await IntegrationTestUtil.selectPlaylistInPlaylistDownloadView(
          tester: tester,
          playlistToSelectTitle: targetPlaylistTitle,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the copied audioTitles displayed by applying the
        // 'default' SF parms

        audioTitleToCopyLst.insert(0, "morning _ cinematic video");

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: audioTitleToCopyLst,
        );

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        currentAudioTitle = "morning _ cinematic video";
        currentAudioSubTitle =
            "0:00:59.0. 360 KB at 283 KB/sec on 10/01/2024 at 18:18.";

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
          '''SF parms 'default' is applied. Then, click on the 'Copy Filtered
           Audio' playlist menu and verify the displayed warning indicating
           that the copy operation can not be done when 'default' is applyed.''',
          (tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'delete_filtered_audio_test',
          tapOnPlaylistToggleButton: true,
        );

        const String sourcePlaylistTitle = 'S8 audio';
        const String targetPlaylistTitle = 'temp';

        // Tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify that the applyed Sort/Filter parms name is displayed
        // after the selected playlist title

        Text selectedSortFilterParmsName = tester
            .widget(find.byKey(const Key('selectedPlaylistSFparmNameText')));

        expect(
          selectedSortFilterParmsName.data,
          'default',
        );

        // Now test copying the filtered audio

        // Open the copy filtered audio dialog by clicking first on
        // the 'Filtered Audio Actions ...' playlist menu item and then
        // on the 'Copy Filtered Audio to Playlist ...' sub-menu item
        await IntegrationTestUtil.typeOnPlaylistSubMenuItem(
          tester: tester,
          playlistTitle: sourcePlaylistTitle,
          playlistSubMenuKeyStr: 'popup_menu_copy_filtered_audio',
        );

        // Select the target 'temp' playlist

        // Check the value of the select one playlist AlertDialog
        // dialog title
        Text alertDialogTitle = tester.widget(
            find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
        expect(alertDialogTitle.data, 'Select a playlist');

        // Find the RadioListTile target playlist to which the audio
        // will be copied

        Finder radioListTile = find.byWidgetPredicate(
          (Widget widget) {
            return widget is RadioListTile &&
                widget.title is Text &&
                (widget.title as Text).data == targetPlaylistTitle;
          },
        );

        // Tap the target playlist RadioListTile to select it
        await tester.tap(radioListTile);
        await tester.pumpAndSettle();

        // Now find the confirm button and tap on it
        await tester.tap(find.byKey(const Key('confirmButton')));
        await tester.pumpAndSettle();

        // Verifying the warning title

        Text moveFilteredAudioConfirmWarningTitleWidget =
            tester.widget<Text>(find.byKey(const Key('warningDialogTitle')));

        expect(moveFilteredAudioConfirmWarningTitleWidget.data, 'WARNING');

        // Verifying the confirm warning message

        Text moveFilteredAudioConfirmWarningMessageWidget =
            tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

        expect(moveFilteredAudioConfirmWarningMessageWidget.data,
            'Since "default" Sort/Filter parms is selected, no audio can be copied from Youtube playlist "$sourcePlaylistTitle" to local playlist "$targetPlaylistTitle". SOLUTION: define a Sort/Filter parms and apply it before executing this operation ...');

        // Now find the ok button of the confirm dialog and tap on it
        await tester.tap(find.byKey(const Key('warningDialogOkButton')));
        await tester.pumpAndSettle();

        // Verifying the 'temp' target playlist

        // Select the 'temp' playlist

        await IntegrationTestUtil.selectPlaylistInPlaylistDownloadView(
          tester: tester,
          playlistToSelectTitle: targetPlaylistTitle,
        );

        // Tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the audioTitles with no movcopieded audio displayed by applying
        // the 'default' SF parms

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: ["morning _ cinematic video"],
        );

        // Setting to this variables the currently selected audio title/subTitle
        // of the 'S8 audio' playlist
        String currentAudioTitle = "morning _ cinematic video";
        String currentAudioSubTitle =
            "0:00:59.0. 360 KB at 283 KB/sec on 10/01/2024 at 18:18.";

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
  });
}

Future<void> _testMovingOrCopyingFilteredAudio({
  required WidgetTester tester,
  required String sourcePlaylistTitle,
  required String targetPlaylistTitle,
  required String sortFilterParmName,
  required bool isMove, // true: move, false: copy
  required int movedOrCopiedAudioNumber,
  required int commentedAudioNumber,
  required int unmovedOrUncopiedAudioNumber,
}) async {
  // Now test moving the filtered audio

  String playlistSubMenuKeyStr;

  if (isMove) {
       playlistSubMenuKeyStr = 'popup_menu_move_filtered_audio';
  } else {
       playlistSubMenuKeyStr = 'popup_menu_copy_filtered_audio';
  }

  // Open the move or copy filtered audio dialog by clicking first on
  // the 'Filtered Audio Actions ...' playlist menu item and then
  // on the 'Move/Copy Filtered Audio to Playlist ...' sub-menu item
  await IntegrationTestUtil.typeOnPlaylistSubMenuItem(
    tester: tester,
    playlistTitle: sourcePlaylistTitle,
    playlistSubMenuKeyStr: playlistSubMenuKeyStr,
  );

  // Select the target 'temp' playlist

  // Check the value of the select one playlist AlertDialog
  // dialog title
  Text alertDialogTitle = tester
      .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
  expect(alertDialogTitle.data, 'Select a playlist');

  // Find the RadioListTile target playlist to which the audio
  // will be moved or copied

  Finder radioListTile = find.byWidgetPredicate(
    (Widget widget) {
      return widget is RadioListTile &&
          widget.title is Text &&
          (widget.title as Text).data == targetPlaylistTitle;
    },
  );

  // Tap the target playlist RadioListTile to select it
  await tester.tap(radioListTile);
  await tester.pumpAndSettle();

  // Now find the confirm button and tap on it
  await tester.tap(find.byKey(const Key('confirmButton')));
  await tester.pumpAndSettle();

  // Verifying the confirm warning title

  Text moveFilteredAudioConfirmWarningTitleWidget =
      tester.widget<Text>(find.byKey(const Key('warningDialogTitle')));

  expect(moveFilteredAudioConfirmWarningTitleWidget.data, 'CONFIRMATION');

  // Verifying the confirm warning message

  Text moveFilteredAudioConfirmWarningMessageWidget =
      tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

  if (isMove) {
    expect(moveFilteredAudioConfirmWarningMessageWidget.data,
        'Applying Sort/Filter parms "$sortFilterParmName", from Youtube playlist "$sourcePlaylistTitle" to local playlist "$targetPlaylistTitle", $movedOrCopiedAudioNumber audio(s) were moved from which $commentedAudioNumber were commented, and $unmovedOrUncopiedAudioNumber audio(s) were unmoved.');
  } else {
    // copying
    expect(moveFilteredAudioConfirmWarningMessageWidget.data,
        'Applying Sort/Filter parms "$sortFilterParmName", from Youtube playlist "$sourcePlaylistTitle" to local playlist "$targetPlaylistTitle", $movedOrCopiedAudioNumber audio(s) were copied from which $commentedAudioNumber were commented, and $unmovedOrUncopiedAudioNumber audio(s) were not copied.');
  }

  // Now find the ok button of the confirm dialog and tap on it
  await tester.tap(find.byKey(const Key('warningDialogOkButton')));
  await tester.pumpAndSettle();
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

Future<void> _selectNewAudioInAudioPlayerViewAndReturnToPlaylistDownloadView({
  required WidgetTester tester,
  required String currentAudioTitle,
  required String newAudioTitle,
  double offsetValue = 0.0,
}) async {
  // Go to audio player view to select another audio
  Finder appScreenNavigationButton =
      find.byKey(const ValueKey('audioPlayerViewIconButton'));
  await tester.tap(appScreenNavigationButton);
  await tester.pumpAndSettle();

  // Now we open the AudioPlayableListDialog by tapping on the
  // audio title
  await tester.tap(find.text("$currentAudioTitle\n0:10"));
  await tester.pumpAndSettle();

  // Select an audio in the AudioPlayableListDialog
  await IntegrationTestUtil.selectAudioInAudioPlayableDialog(
    tester: tester,
    audioToSelectTitle: newAudioTitle,
    offsetValue: offsetValue, // scrolling down may be necessary in order to
    //                           find the audioToSelectTitle
  );

  // Return to playlist download view
  appScreenNavigationButton =
      find.byKey(const ValueKey('playlistDownloadViewIconButton'));
  await tester.tap(appScreenNavigationButton);
  await tester.pumpAndSettle();
}

Future<void> _selectDateFormat({
  required WidgetTester tester,
  required String dateFormatToSelect,
  required String previouslySelectedDateFormat,
}) async {
  await tester.tap(find.byKey(const Key('appBarRightPopupMenu')));
  await tester.pumpAndSettle();

  // Open the date format selection dialog
  await tester.tap(find.byKey(const Key('appBarMenuDateFormat')));
  await tester.pumpAndSettle();

  // Check the value of the date format selection dialog title
  Text alertDialogTitle =
      tester.widget(find.byKey(const Key('dateFormatSelectionDialogTitleKey')));
  expect(alertDialogTitle.data, 'Select the application date format');

  // Find the RadioListTile date format to select

  Finder radioListTile = find.byWidgetPredicate(
    (Widget widget) {
      return widget is RadioListTile &&
          widget.title is Text &&
          (widget.title as Text).data!.contains(dateFormatToSelect);
    },
  );

  // Tap the target playlist RadioListTile to select it
  await tester.tap(radioListTile);
  await tester.pumpAndSettle();

  await _verifyApplicationSettingsDateFormatValue(
    dateFormatValue: previouslySelectedDateFormat,
  );

  // Now find the confirm button and tap on it
  await tester.tap(find.byKey(const Key('confirmButton')));
  await tester.pumpAndSettle();

  await _verifyApplicationSettingsDateFormatValue(
    dateFormatValue: dateFormatToSelect,
  );
}

Future<void> _verifyApplicationSettingsDateFormatValue({
  required String dateFormatValue,
}) async {
  SettingsDataService settingsDataService = SettingsDataService(
    sharedPreferences: MockSharedPreferences(),
    isTest: true,
  );

  await settingsDataService.loadSettingsFromFile(
      settingsJsonPathFileName:
          "$kPlaylistDownloadRootPathWindowsTest${Platform.pathSeparator}$kSettingsFileName");

  expect(
      settingsDataService.get(
          settingType: SettingType.formatOfDate,
          settingSubType: FormatOfDate.formatOfDate),
      dateFormatValue);
}

Future<void> _verifyDateFormatApplication({
  required WidgetTester tester,
  required List<String> audioSubTitles,
  required List<String> audioSubTitlesWithAudioDownloadDuration,
  required List<String> audioSubTitlesWithAudioRemainingDuration,
  required List<String> audioSubTitlesLastListenedDateTimeDescending,
  required List<String> audioSubTitlesTitleAsc,
  required List<String> audioSubTitlesVideoUploadDate,
  required String playlistTitle,
  required String videoUploadDate,
  required audioDownloadDateTime,
  required String playlistLastDownloadDateTime,
  required String commentCreationDate,
  required String commentUpdateDate,
}) async {
  IntegrationTestUtil.checkAudioSubTitlesOrderInListTile(
    tester: tester,
    audioSubTitlesOrderLst: audioSubTitles,
  );

  // Now we want to tap the popup menu of the Audio ListTile
  // "Jancovici m'explique l’importance des ordres de grandeur
  // face au changement climatique",

  const String audioInfoTitle =
      "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique";

  // First, find the Audio sublist ListTile Text widget
  Finder targetAudioListTileTextWidgetFinder = find.text(audioInfoTitle);

  // Then obtain the Audio ListTile widget enclosing the Text widget by
  // finding its ancestor
  Finder targetAudioListTileWidgetFinder = find.ancestor(
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

  // Now find the popup menu item and tap on it
  final Finder popupDisplayAudioInfoMenuItemFinder =
      find.byKey(const Key("popup_menu_display_audio_info"));

  await tester.tap(popupDisplayAudioInfoMenuItemFinder);
  await tester.pumpAndSettle();

  // Now verifying the display audio info audio copied dialog
  // elements

  // Verify the video upload date of the audio

  final Text videoUploadDateTextWidget =
      tester.widget<Text>(find.byKey(const Key('videoUploadDateKey')));

  expect(
    videoUploadDateTextWidget.data,
    videoUploadDate,
  );

  // Verify the audio download date time of the audio

  final Text audioDownloadDateTimeTextWidget =
      tester.widget<Text>(find.byKey(const Key('audioDownloadDateTimeKey')));

  expect(
    audioDownloadDateTimeTextWidget.data,
    audioDownloadDateTime,
  );

  // Now find the ok button of the audio info dialog
  // and tap on it
  await tester.tap(find.byKey(const Key('audio_info_ok_button_key')));
  await tester.pumpAndSettle();

  // Tap the 'Toggle List' button to display the list of playlist's.
  await tester.tap(find.byKey(const Key('playlist_toggle_button')));
  await tester.pumpAndSettle();

  // Find the playlist whose audio are commented

  // First, find the Playlist ListTile Text widget. Two exist:
  // "S8 audio" under the 'Youtube Link or Search' text field and
  // "S8 audio" as PlaylistItem
  final Finder playlistToExamineInfoTextWidgetFinder =
      find.text(playlistTitle).at(1);

  // Then obtain the Playlist ListTile widget enclosing the Text widget
  // by finding its ancestor
  final Finder playlistWithCommentedAudioListTileWidgetFinder = find.ancestor(
    of: playlistToExamineInfoTextWidgetFinder,
    matching: find.byType(ListTile),
  );

  // Now find the leading menu icon button of the playlist and tap on it
  final Finder playlistListTileLeadingMenuIconButton = find.descendant(
    of: playlistWithCommentedAudioListTileWidgetFinder,
    matching: find.byIcon(Icons.menu),
  );

  // Tap the leading menu icon button to open the popup menu
  await tester.tap(playlistListTileLeadingMenuIconButton);
  await tester.pumpAndSettle(); // Wait for popup menu to appear

  // Now find the playlist info popup menu item and tap on it
  // to open the PlaylistInfoDialog
  final Finder popupPlaylistInfoMenuItem =
      find.byKey(const Key("popup_menu_display_playlist_info"));

  await tester.tap(popupPlaylistInfoMenuItem);
  await tester.pumpAndSettle();

  // Verify the playlist last download date time

  final Text playlistLastDownloadDateTimeTextWidget = tester
      .widget<Text>(find.byKey(const Key('playlist_last_download_date_time')));

  expect(
    playlistLastDownloadDateTimeTextWidget.data,
    playlistLastDownloadDateTime,
  );

  // Now find the ok button of the playlist info dialog
  // and tap on it
  await tester.tap(find.byKey(const Key('playlist_info_ok_button_key')));
  await tester.pumpAndSettle();

  // Tap the 'Toggle List' button to hide the list of playlist's.
  await tester.tap(find.byKey(const Key('playlist_toggle_button')));
  await tester.pumpAndSettle();

  // Now, selecting 'audio downl dur' dropdown button item to
  // apply this sort/filter parms
  await _selectApplyAndVerifySortFilterParms(
    tester: tester,
    sortFilterParms: 'audio downl dur',
    audioSubTitles: audioSubTitlesWithAudioDownloadDuration,
  );

  // Now, selecting 'audio remai. duration' dropdown button item to
  // apply this sort/filter parms
  await _selectApplyAndVerifySortFilterParms(
    tester: tester,
    sortFilterParms: 'audio remai. duration',
    audioSubTitles: audioSubTitlesWithAudioRemainingDuration,
  );

  // Now, selecting 'desc listened' dropdown button item to
  // apply this sort/filter parms
  await _selectApplyAndVerifySortFilterParms(
    tester: tester,
    sortFilterParms: 'desc listened',
    audioSubTitles: audioSubTitlesLastListenedDateTimeDescending,
  );

  // Now, selecting 'Title asc' dropdown button item to
  // apply this sort/filter parms
  await _selectApplyAndVerifySortFilterParms(
    tester: tester,
    sortFilterParms: 'Title asc',
    audioSubTitles: audioSubTitlesTitleAsc,
  );

  // Now, selecting 'video upl date' dropdown button item to
  // apply this sort/filter parms
  await _selectApplyAndVerifySortFilterParms(
    tester: tester,
    sortFilterParms: 'video upl date',
    audioSubTitles: audioSubTitlesVideoUploadDate,
  );

  // Reset 'default' sort/filter parm

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

  // And select the 'default' sort/filter item
  final Finder defaultDropDownTextFinder = find.text('default');
  await tester.tap(defaultDropDownTextFinder);
  await tester.pumpAndSettle();

  // Verifying the comment date format

  // First, find the Audio sublist ListTile Text widget
  targetAudioListTileTextWidgetFinder = find.text(audioInfoTitle);

  // Then obtain the Audio ListTile widget enclosing the Text widget by
  // finding its ancestor
  targetAudioListTileWidgetFinder = find.ancestor(
    of: targetAudioListTileTextWidgetFinder,
    matching: find.byType(ListTile),
  );

  // Now find the leading menu icon button of the Audio ListTile and tap
  // on it
  targetAudioListTileLeadingMenuIconButton = find.descendant(
    of: targetAudioListTileWidgetFinder,
    matching: find.byIcon(Icons.menu),
  );

  // Tap the leading menu icon button to open the popup menu
  await tester.tap(targetAudioListTileLeadingMenuIconButton);
  await tester.pumpAndSettle();

  // Now find the popup menu item and tap on it
  final Finder popupDisplayAudioCommentMenuItemFinder =
      find.byKey(const Key("popup_menu_audio_comment"));

  await tester.tap(popupDisplayAudioCommentMenuItemFinder);
  await tester.pumpAndSettle();

  expect(find.text(commentCreationDate), findsOneWidget);
  expect(find.text(commentUpdateDate), findsOneWidget);

  // Now close the comment list dialog
  await tester.tap(find.byKey(const Key('closeDialogTextButton')));
  await tester.pumpAndSettle();
}

Future<void> _selectApplyAndVerifySortFilterParms({
  required WidgetTester tester,
  required String sortFilterParms,
  required List<String> audioSubTitles,
}) async {
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

  // And select the 'audio downl dur' sort/filter item
  final Finder titleAscDropDownTextFinder = find.text(sortFilterParms);
  await tester.tap(titleAscDropDownTextFinder);
  await tester.pumpAndSettle();

  // Verify the audio sub-titles order in the list tile which correspond
  // to the audio download duration sort order selected parms
  IntegrationTestUtil.checkAudioSubTitlesOrderInListTile(
    tester: tester,
    audioSubTitlesOrderLst: audioSubTitles,
  );
}

Future<void> _rewindPlaylistAfterPlayThenPauseAnAudio({
  required WidgetTester tester,
  required Finder appScreenNavigationButton,
  required bool doExpandPlaylistList,
  required String playlistToRewindTitle,
  required String audioToPlayTitle,
  required String audioToPlayTitleAndDuration,
  String? otherAudioTitleToTapOnBeforeRewinding,
  String? otherAudioTitleToTapOnBeforeRewindingDuration,
}) async {
  // Now play then pause audioToPlayTitle

  Finder audioToPlayTitleFinder = find.text(audioToPlayTitle);

  // This opens the play audio view
  await tester.tap(audioToPlayTitleFinder);
  await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
    tester: tester,
    additionalMilliseconds: 2000,
  );

  // Now play the audio and wait 5 seconds
  await tester.tap(find.byIcon(Icons.play_arrow));
  await tester.pumpAndSettle();

  await Future.delayed(const Duration(seconds: 5));
  await tester.pumpAndSettle();

  // Now pause the audio
  final Finder pauseIconFinder = find.byIcon(Icons.pause);
  await tester.tap(pauseIconFinder);
  await tester.pumpAndSettle();

  // Go back to playlist download view
  appScreenNavigationButton =
      find.byKey(const ValueKey('playlistDownloadViewIconButton'));
  await tester.tap(appScreenNavigationButton);
  await tester.pumpAndSettle(const Duration(milliseconds: 200));

  if (doExpandPlaylistList) {
    // Tap the 'Toggle List' button to show the list of playlist's.
    await tester.tap(find.byKey(const Key('playlist_toggle_button')));
    await tester.pumpAndSettle();
  }

  if (otherAudioTitleToTapOnBeforeRewinding != null) {
    // Simply click on another audio so that the playlist current
    // audio is no longer the last played and paused audio. This verify
    // the correction of a rewind playlist audio to start position bug
    Finder audioToPlayTitleFinder =
        find.text(otherAudioTitleToTapOnBeforeRewinding);

    await tester.tap(audioToPlayTitleFinder);
    await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
      tester: tester,
      additionalMilliseconds: 1500,
    );

    // Go back to playlist download view
    appScreenNavigationButton =
        find.byKey(const ValueKey('playlistDownloadViewIconButton'));
    await tester.tap(appScreenNavigationButton);
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
  }

  // Rewind all playlist audio to start position
  await _tapOnRewindPlaylistAudioToStartPositionMenu(
    tester: tester,
    playlistToRewindTitle: playlistToRewindTitle,
    numberOfRewindedAudio: 1,
  );

  // Return to audio player view to verify the playlist current
  // audio title audio position set to start
  appScreenNavigationButton =
      find.byKey(const ValueKey('audioPlayerViewIconButton'));
  await tester.tap(appScreenNavigationButton);
  await tester.pumpAndSettle(const Duration(milliseconds: 200));

  Finder currentAudioTitleFinder;

  if (otherAudioTitleToTapOnBeforeRewinding != null) {
    currentAudioTitleFinder =
        find.text(otherAudioTitleToTapOnBeforeRewindingDuration!);
  } else {
    currentAudioTitleFinder = find.text(audioToPlayTitleAndDuration);
  }

  expect(
    currentAudioTitleFinder,
    findsOneWidget,
  );

  // Verify the current audio position
  Text audioPositionText = tester
      .widget<Text>(find.byKey(const Key('audioPlayerViewAudioPosition')));
  expect(audioPositionText.data, '0:00');

  // Go back to playlist download view
  appScreenNavigationButton =
      find.byKey(const ValueKey('playlistDownloadViewIconButton'));
  await tester.tap(appScreenNavigationButton);
  await tester.pumpAndSettle();
}

Future<void> _tapOnRewindPlaylistAudioToStartPositionMenu({
  required WidgetTester tester,
  required String playlistToRewindTitle,
  required int numberOfRewindedAudio,
}) async {
  // Find the playlist to rewind audio ListTile

  // First, find the Playlist ListTile Text widget
  final Finder youtubePlaylistToRewindListTileTextWidgetFinder =
      find.text(playlistToRewindTitle);

  // Then obtain the Playlist ListTile widget enclosing the Text widget
  // by finding its ancestor
  final Finder youtubePlaylistToRewindListTileWidgetFinder = find.ancestor(
    of: youtubePlaylistToRewindListTileTextWidgetFinder,
    matching: find.byType(ListTile),
  );

  // Now test rewinding the playlist audio to start position

  // Find the playlist leading menu icon button
  final Finder firstPlaylistListTileLeadingMenuIconButton = find.descendant(
    of: youtubePlaylistToRewindListTileWidgetFinder,
    matching: find.byIcon(Icons.menu),
  );

  // Tap the leading menu icon button to open the popup menu
  await tester.tap(firstPlaylistListTileLeadingMenuIconButton);
  await tester.pumpAndSettle();

  // Now find the 'Rewind Audio to Start' playlist popup menu item
  // and tap on it
  final Finder popupDeletePlaylistMenuItem =
      find.byKey(const Key("popup_menu_rewind_audio_to_start"));

  await tester.tap(popupDeletePlaylistMenuItem);
  await tester.pumpAndSettle(const Duration(milliseconds: 200));

  // Check the value of the Confirm dialog title
  Text warningDialogTitle =
      tester.widget(find.byKey(const Key('warningDialogTitle')));
  expect(warningDialogTitle.data, 'CONFIRMATION');

  // Now verifying the confirm dialog message

  Text warningDialogMessageTextWidget =
      tester.widget<Text>(find.byKey(const Key('warningDialogMessage')));

  expect(warningDialogMessageTextWidget.data,
      '$numberOfRewindedAudio playlist audio were repositioned to start.');

  // Now find the ok button of the confirm dialog
  // and tap on it
  await tester.tap(find.byKey(const Key('warningDialogOkButton')));
  await tester.pumpAndSettle();
}

void _verifyAllNowUnplayedAudioPlayPauseIconColor({
  required WidgetTester tester,
  required List<String> audioTitles,
}) {
  for (String audioTitle in audioTitles) {
    IntegrationTestUtil.validateInkWellButton(
      tester: tester,
      audioTitle: audioTitle,
      expectedIcon: Icons.play_arrow,
      expectedIconColor: kDarkAndLightEnabledIconColor, // not played icon color
      expectedIconBackgroundColor: Colors.black,
    );
  }
}

Future<List<String>> _enteringFirstAndSecondLetterOfLocalPlaylistSearchWord({
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
    'a',
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
    "La résilience insulaire par Fiona Roche",
    "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
    "Les besoins artificiels par R.Keucheyan",
    "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
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
    'al',
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
    "local",
    "local_2",
  ];

  IntegrationTestUtil.checkPlaylistAndAudioTitlesOrderInListTile(
    tester: tester,
    playlistTitlesOrderedLst: playlistsTitles,
    audioTitlesOrderedLst: audioTitles,
    firstPlaylistListTileIndex: 0,
    firstAudioListTileIndex: 2,
  );

  return playlistsTitles;
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
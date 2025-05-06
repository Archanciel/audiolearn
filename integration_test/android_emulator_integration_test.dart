import 'dart:convert';
import 'dart:io';

import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/models/picture.dart';
import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/audio_player_vm.dart';
import 'package:audiolearn/viewmodels/comment_vm.dart';
import 'package:audiolearn/viewmodels/date_format_vm.dart';
import 'package:audiolearn/viewmodels/picture_vm.dart';
import 'package:audiolearn/viewmodels/playlist_list_vm.dart';
import 'package:audiolearn/viewmodels/warning_message_vm.dart';
import 'package:audiolearn/views/widgets/audio_sort_filter_dialog.dart';
import 'package:audiolearn/views/widgets/comment_list_add_dialog.dart';
import 'package:audiolearn/views/widgets/playlist_comment_list_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:audiolearn/main.dart' as app;

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/services/json_data_service.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/services/mock_shared_preferences.dart';
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
        // is disabled. and that the download single video button is enabled. Then,
        // tap on the delete button to delete the URL in the search text word and
        // verify that the search icon button is disabled and that the download
        // single video button is disabled. Finally, verify that the search text
        // field is empty and that the displayed audio list is the same as the one
        // before entering the search word.
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'sort_and_filter_audio_dialog_widget_test',
          tapOnPlaylistToggleButton: false,
        );

        // Verify that the download single video button is
        // now disabled
        await IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'downloadSingleVideoButton',
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
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
        );

        // Verify the presence of the disabled stop button
        await IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr:
              'stopDownloadingButton', // this button is disabled if the
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

        // Verify that the search icon button is now enabled but inactive
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.enabledInactive,
        );

        // Verify the presence of the delete button
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr:
              'clearPlaylistUrlOrSearchButtonKey', // this button is disabled if the
          //                                     'Youtube Link or Search' dosn't
          //                                     contain a search word or sentence
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

        // Verify that the search icon button is now enabled but inactive
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.enabledInactive,
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

        // Verify that the search icon button is now enabled and active
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.enabledActive,
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

        // Verify that the search icon button is now enabled and active
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.enabledActive,
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

        // Verify that the search icon button is now enabled and active
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.enabledActive,
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

        // Verify that the search icon button is now enabled and active
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.enabledActive,
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
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
        );

        // Verify that the download single video button is
        // now enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'downloadSingleVideoButton',
        );

        // Verify the presence of the delete button
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr:
              'clearPlaylistUrlOrSearchButtonKey', // this button is disabled if the
          //                                     'Youtube Link or Search' dosn't
          //                                     contain a search word or sentence
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

        // Now tap on the delete button to delete the URL in the search
        // text word
        await tester.tap(
          find.byKey(
            const Key('clearPlaylistUrlOrSearchButtonKey'),
          ),
        );
        await tester.pumpAndSettle();

        // Verify that the stop text button replaced the
        // delete icon button, but is disabled
        await IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'stopDownloadingButton',
        );

        // Verify that the download single video button is
        // now disabled
        await IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'downloadSingleVideoButton',
        );

        // And verify that the search text field is empty
        expect(
          (find.byKey(const Key('youtubeUrlOrSearchTextField'))),
          findsOneWidget,
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets(
          '''Finish by reducing, then emptying the search word. First, select the
           existing 'janco' sort/filter parms in the SF dropdown button. Then enter
           the search word 'La' in the 'Youtube ''',
          (WidgetTester tester) async {
        // Link or Search' text field. After entering 'La', verify that the search
        // icon button is now enabled and click on it. Then, reduce the search word
        // to one letter ('L') and verify that the audio liat was updatefd. Then,
        // select the 'default' dropdon icon
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
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
        );

        // Now enter the 2 letters of the search word
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

        // Verify that the search icon button is now enabled but inactive
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.enabledInactive,
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

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Now reduce the search word to 1 letter
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

        // Verify the order of the playlist audio titles. Since
        // the search icon button was used, modifying the search text
        // is applied at each search text change

        audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst:
              audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms,
        );

        // Now re-enter the 2 letters of the search word
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

        // And verify the order of the playlist audio titles. Since
        // the search icon button was used, modifying the search text
        // is applied at each search text change

        audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

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

        // Verify that the search icon button is now enabled and active
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.enabledActive,
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
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
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
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
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

        // Verify that the search icon button is now enabled but inactive
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.enabledInactive,
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

        // Verify that the search icon button is now enabled and active
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.enabledActive,
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
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
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
        // and verify that the search icon button is disabled. Then, enters a
        // letter and verify it has no impact since the search button was not
        // pressed again. Finally, re-enter the 2 first letters of the 'al' search
        // word, verify the reduced displayed playlist list then click on the
        // delete button and verify the result.
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'sort_and_filter_audio_dialog_widget_three_playlists_test',
          tapOnPlaylistToggleButton: true,
        );

        // Verify the disabled state of the search icon button
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
        );

        // Verify the presence of the disabled stop button
        await IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr:
              'stopDownloadingButton', // this button is disabled if the
          //                                     'Youtube Link or Search' dosn't
          //                                     contain a search word or sentence
        );

        // Now add the first 2 letters of the 'al' search word and tap
        // on the search icon button. Then verify that the search icon
        // button is now enabled and active
        List<String> playlistsTitles =
            await _enteringFirstAndSecondLetterOfLocalPlaylistSearchWord(
          tester: tester,
        );

        // Verify the presence of the delete button
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr:
              'clearPlaylistUrlOrSearchButtonKey', // this button is disabled if the
          //                                     'Youtube Link or Search' dosn't
          //                                     contain a search word or sentence
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

        // Verify that the search icon button is now enabled and active
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.enabledActive,
        );

        // And verify the order of the playlist titles.

        playlistsTitles = [
          "local_2",
        ];

        // Ensure that since the search icon button was used,
        // the displayed playlist list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Verify that the search icon button is now enabled and active
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.enabledActive,
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
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
        );

        // Now re-enter the first 2 letters of the 'al' search word and tap
        // on the search icon button. Then verify that the search icon
        // button is now enabled and active
        await _enteringFirstAndSecondLetterOfLocalPlaylistSearchWord(
          tester: tester,
        );

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

        // Now tap on the delete button to empty the search text
        // field
        await tester.tap(
          find.byKey(
            const Key('clearPlaylistUrlOrSearchButtonKey'),
          ),
        );
        await tester.pumpAndSettle();

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
        // youtubeUrlOrSearchTextField and verify that the search icon button is
        // disabled. Finally, enters a
        // letter and verify it has no impact since the search button was not
        // pressed again.
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'sort_and_filter_audio_dialog_widget_three_playlists_test',
          tapOnPlaylistToggleButton: true,
        );

        // Verify the disabled state of the search icon button
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
        );

        // Now add the first 2 letters of the 'al' search word and tap
        // on the search icon button. Then verify that the search icon
        // button is now enabled and active
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

        // Verify that the search icon button is now enabled and active
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.enabledActive,
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

        // Verify that the search icon button is now enabled and active
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.enabledActive,
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
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
        );

        // Verify that the delete button is now enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'clearPlaylistUrlOrSearchButtonKey',
        );

        // Now, click on the delete button to empty the search
        // text field
        await tester.tap(
          find.byKey(
            const Key('clearPlaylistUrlOrSearchButtonKey'),
          ),
        );
        await tester.pumpAndSettle();

        // Verify that the search icon button is disabled
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
        );

        // Verify that the stop text button replaced the
        // delete icon button, but is disabled
        await IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'stopDownloadingButton',
        );

        // And verify that the search text field is empty
        expect(
          (find.byKey(const Key('youtubeUrlOrSearchTextField'))),
          findsOneWidget,
        );

        // Then re-enter a two letters search word
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

        // Verify that the search icon button is now enabled but inactive
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.enabledInactive,
        );

        // Verify that the delete button is enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'clearPlaylistUrlOrSearchButtonKey',
        );

        // Verify that the playlist titles list was not modified
        // since the search icon button was not pressed

        playlistsTitles = [
          "S8 audio",
          "local",
          "local_2",
        ];

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
      testWidgets('''First, enter 'http' as search word in the 'Youtube Link or
          Search' text field. This selects the 'http_local' playlist.''',
          (WidgetTester tester) async {
        // Then add ':/' to the search sentence. No more playlist are selected,
        // but the search icon button is still enabled as well as the delete
        // button. Then, add '/' to the search sentence. The search icon button
        // is now disabled and the delete button is still enabled. All the
        // playlist are now displayed since the search button is disabled.
        // Finally, click on the delete button and verify that the search
        // sentence is empty and the search icon button is disabled.
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'sort_and_filter_audio_dialog_widget_two_playlists_test',
          tapOnPlaylistToggleButton: false,
        );

        // Verify the disabled state of the search icon button
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
        );

        // Now add the 'http' search word
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
          'http',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is now enabled but inactive
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.enabledInactive,
        );

        // Verify that the delete icon button is enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'clearPlaylistUrlOrSearchButtonKey',
        );

        // Verify that the download single video button is
        // disabled
        await IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'downloadSingleVideoButton',
        );

        // And verify the order of the playlist titles
        // before tapping on the search icon button.

        List<String> playlistsTitles = [
          "local",
          "http_local",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // And verify the order of the playlist titles
        // after tapping on the search icon button.

        playlistsTitles = [
          "http_local",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Now add the ':/' to the search word
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
          'http:/',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is now enabled and active
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.enabledActive,
        );

        // Verify that the delete icon button is enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'clearPlaylistUrlOrSearchButtonKey',
        );

        // Verify that the download single video button is
        // disabled
        await IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'downloadSingleVideoButton',
        );

        // And verify the order of the playlist titles
        // before tapping on the search icon button.

        playlistsTitles = [];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Now add the second '/' to the search word
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
          'http://',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is disabled
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
        );

        // Verify that the delete icon button is enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'clearPlaylistUrlOrSearchButtonKey',
        );

        // Verify that the download single video button is
        // now enabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'downloadSingleVideoButton',
        );

        // And verify the order of the playlist titles
        // before tapping on the search icon button.

        playlistsTitles = [
          "local",
          "http_local",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Now, click on the delete button to empty the search
        // text field
        await tester.tap(
          find.byKey(
            const Key('clearPlaylistUrlOrSearchButtonKey'),
          ),
        );
        await tester.pumpAndSettle();

        // Verify that the search icon button is now disabled
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
        );

        // Verify that the stop text button replaced the
        // delete icon button, but is disabled
        await IntegrationTestUtil.verifyWidgetIsDisabled(
          tester: tester,
          widgetKeyStr: 'stopDownloadingButton',
        );

        // And verify that the search text field is empty
        expect(
          (find.byKey(const Key('youtubeUrlOrSearchTextField'))),
          findsOneWidget,
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

        // Now add the first 2 letters of the 'al' search word and tap
        // on the search icon button. Then verify that the search icon
        // button is now enabled and active
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

        // Select the local playlist

        await IntegrationTestUtil.selectPlaylist(
          tester: tester,
          playlistToSelectTitle: playlistsTitles[0],
        );

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

        // Verify the newly selected playlist title

        selectedPlaylistTitleText =
            tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));

        expect(
          selectedPlaylistTitleText.data,
          'local',
        );

        // verify the newly selected playlist audio titles

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

        // Select the local playlist

        await IntegrationTestUtil.selectPlaylist(
          tester: tester,
          playlistToSelectTitle: 'local',
        );

        // some buttons are enabled and some are disabled
        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'move_up_playlist_button',
        );

        IntegrationTestUtil.verifyWidgetIsEnabled(
          tester: tester,
          widgetKeyStr: 'move_down_playlist_button',
        );

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

        // Select the Youtube playlist

        await IntegrationTestUtil.selectPlaylist(
          tester: tester,
          playlistToSelectTitle: 'S8 audio',
        );

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
        // displayed playlist list.
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

        // Now add the first 2 letters of the 'al' search word and tap
        // on the search icon button. Then verify that the search icon
        // button is now enabled and active
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

        // Select the local playlist

        await IntegrationTestUtil.selectPlaylist(
          tester: tester,
          playlistToSelectTitle: playlistsTitles[1], // local_2
        );

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

        List<String> audioTitles = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La résilience insulaire par Fiona Roche",
          "Les besoins artificiels par R.Keucheyan",
        ];

        IntegrationTestUtil.checkPlaylistAndAudioTitlesOrderInListTile(
          tester: tester,
          playlistTitlesOrderedLst: playlistsTitles,
          audioTitlesOrderedLst: audioTitles,
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
          audioTitlesOrderedLst: audioTitles,
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
          audioTitlesOrderedLst: audioTitles,
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

        // Verify that the search icon button is enabled but inactive
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.enabledInactive);

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Verify that the search icon button is enabled and active
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.enabledActive);

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
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.enabledActive);

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
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.enabledActive);

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
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
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

        // Verify that the search icon button is enabled butb inactive
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.enabledInactive);

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
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.enabledActive);

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
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
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
        '''Audio search word set in playlist download view, then go to audio player
           view and back to playlist download view''', () {
      testWidgets(
          '''First, enter the search word 'al' in the 'Youtube Link or Search'
                     text field.''', (WidgetTester tester) async {
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

        // Verify that the search icon button is enabled but inactive
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.enabledInactive);

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

        // Verify that the search icon button is now disabled
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
        );

        // Now verify the order of the playlist audio titles

        audioTitlesSortedDownloadDateDescendingDefaultSortFilterParms = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button is now disabled,
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
      testWidgets('''At end, clicking on audio play button. First, enter the
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

        // Verify that the search icon button is enabled but inactive
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.enabledInactive);

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
        );

        // And return to the playlist download view
        Finder playlistDownloadViewNavButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(playlistDownloadViewNavButton);
        await tester.pumpAndSettle();

        // Verify that the search icon button is now disabled
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
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

        // Verify that the search icon button is enabled but inactive
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.enabledInactive);

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

        // Verify that the search icon button is now disabled
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
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

        // Verify that the search icon button is enabled but inactive
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.enabledInactive);

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Verify that the search icon button is enabled and active
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.enabledActive);

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

        // Verify that the search icon button is now disabled
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
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

        // Verify that the search icon button is enabled but inactive
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.enabledInactive);

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
        );

        // And return to the playlist download view
        Finder playlistDownloadViewNavButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(playlistDownloadViewNavButton);
        await tester.pumpAndSettle();

        // Verify that the search icon button is now disabled
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
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

        // Verify that the search icon button is enabled but inactive
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.enabledInactive);

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

        // Verify that the search icon button is now disabled
        IntegrationTestUtil.validateSearchIconButton(
          tester: tester,
          searchIconButtonState: SearchIconButtonState.disabled,
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
    group(
        '''Click and un-click on search icon button. This added functionality enables to
            use the search sentence on other playlists.''', () {
      testWidgets(
          '''First, enter the search word 'mo' in the 'Youtube Link or Search' text
            field. Then click and un-click on the search icon button, select another
            playlist and select a sort filter item ...''',
          (WidgetTester tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'sort_and_filter_audio_dialog_widget_three_playlists_test',
          tapOnPlaylistToggleButton: false,
        );

        // Verify that the search icon button is now disabled
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.disabled);

        // Enter the two letters of the 'mo' search word.

        // Select the text field
        await tester.tap(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
        );
        await tester.pumpAndSettle();

        // Enter the 2 letters of the 'mo' search word
        await tester.enterText(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
          'mo',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is enabled, but inactive
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.enabledInactive);

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Verify that the search icon button is now active
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.enabledActive);

        // Now verify the order of the reduced playlist audio titles

        List<String> playlistDisplayedAudioTitles = [
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistDisplayedAudioTitles,
        );

        // Now tap on the search icon button to deactivate it
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Verify that the search icon button is enabled but inactive
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.enabledInactive);

        // Verify that the search text field content was not changed
        IntegrationTestUtil.verifyTextFieldContent(
          tester: tester,
          textFieldKeyStr: 'youtubeUrlOrSearchTextField',
          expectedTextFieldContent: 'mo',
        );

        // Now verify the order of the no longer reduced playlist
        // audio titles

        playlistDisplayedAudioTitles = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button was un-pressed,
        // the displayed audio list returned to the default list.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistDisplayedAudioTitles,
        );

        // Now tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the order of the normal playlist titles

        List<String> playlistsTitles = [
          "S8 audio",
          "local",
          "local_2",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed playlist list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // Now select the 'local' playlist
        await IntegrationTestUtil.selectPlaylist(
          tester: tester,
          playlistToSelectTitle: 'local',
        );

        // Verify that the search text field content was conserved
        IntegrationTestUtil.verifyTextFieldContent(
          tester: tester,
          textFieldKeyStr: 'youtubeUrlOrSearchTextField',
          expectedTextFieldContent: 'mo',
        );

        // Now tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // And verify the order of the default playlist audio titles

        playlistDisplayedAudioTitles = [
          "morning _ cinematic video",
          "Really short video",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La résilience insulaire par Fiona Roche",
          "Les besoins artificiels par R.Keucheyan",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button was un-pressed,
        // the displayed audio list returned to the default list.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistDisplayedAudioTitles,
        );

        // Tap on the search icon button to activate it on the 'local'
        // playlist
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // And verify the order of the filtered playlist audio titles

        playlistDisplayedAudioTitles = [
          "morning _ cinematic video",
        ];

        // Ensure that since the search icon button was pressed,
        // the displayed audio is filtered.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistDisplayedAudioTitles,
        );

        // Then, tap on the search icon button to deactivate it
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Verify that the search text field content was not changed
        IntegrationTestUtil.verifyTextFieldContent(
          tester: tester,
          textFieldKeyStr: 'youtubeUrlOrSearchTextField',
          expectedTextFieldContent: 'mo',
        );

        // And verify the order of the default playlist audio titles

        playlistDisplayedAudioTitles = [
          "morning _ cinematic video",
          "Really short video",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La résilience insulaire par Fiona Roche",
          "Les besoins artificiels par R.Keucheyan",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button was un-pressed,
        // the displayed audio list returned to the default list.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistDisplayedAudioTitles,
        );

        // Now select the 'asc listened' sort/filter item in the dropdown
        // button items list

        // Tap on the current dropdown button item to open the dropdown
        // button items list

        List<String> playlistDisplayedAudioTitlesLst = [
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "Really short video",
          "morning _ cinematic video",
          "La résilience insulaire par Fiona Roche",
          "Les besoins artificiels par R.Keucheyan",
        ];

        await _selectAndApplySortFilterParms(
          tester: tester,
          playlistDisplayedAudioTitlesLst: playlistDisplayedAudioTitlesLst,
          sfParmsName: 'asc listened',
          textFieldContentStr: 'mo',
        );

        // Now tap on the search icon button to activate it on the 'local'
        // playlist
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // And verify the order of the filtered playlist audio titles

        playlistDisplayedAudioTitles = [
          "morning _ cinematic video",
        ];

        // Then, re-tap on the search icon button to deactivate it
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Verify that the search text field content was not changed
        IntegrationTestUtil.verifyTextFieldContent(
          tester: tester,
          textFieldKeyStr: 'youtubeUrlOrSearchTextField',
          expectedTextFieldContent: 'mo',
        );

        // And verify the order of the 'asc listened' playlist audio
        // titles

        playlistDisplayedAudioTitles = [
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "Really short video",
          "morning _ cinematic video",
          "La résilience insulaire par Fiona Roche",
          "Les besoins artificiels par R.Keucheyan",
        ];

        // Ensure that since the search icon button was un-pressed,
        // the displayed audio list returned to the 'asc listened'
        // list.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistDisplayedAudioTitles,
        );

        // Re-tap on the search icon button to re-activate it
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // And tap on the 'Toggle List' button to display the list
        // of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify that the search text field content was not changed
        IntegrationTestUtil.verifyTextFieldContent(
          tester: tester,
          textFieldKeyStr: 'youtubeUrlOrSearchTextField',
          expectedTextFieldContent: 'mo',
        );

        // Verify that the search icon button is enabled and active
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.enabledActive);

        // Verify that the list of playlists is empty since the search
        // text field is applied to the playlist list.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: [],
          firstAudioListTileIndex: 6,
        );

        // Now tap on the search icon button to deactivate it
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Verify the displayed playlist titles order
        playlistsTitles = [
          "S8 audio",
          "local",
          "local_2",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // And select the 'S8 audio' playlist
        await IntegrationTestUtil.selectPlaylist(
          tester: tester,
          playlistToSelectTitle: 'S8 audio',
        );

        // Tap on the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        playlistDisplayedAudioTitlesLst = [
          "La surpopulation mondiale par Jancovici et Barrau",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La résilience insulaire par Fiona Roche",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
        ];

        // Now select the 'asc listened' sort/filter item in the dropdown
        // button items list

        // Tap on the current dropdown button item to open the dropdown
        // button items list

        await _selectAndApplySortFilterParms(
          tester: tester,
          playlistDisplayedAudioTitlesLst: playlistDisplayedAudioTitlesLst,
          sfParmsName: 'asc listened',
          textFieldContentStr: 'mo',
        );

        // Re-tap on the search icon button to re-activate it
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // And verify the order of the reduced playlist audio titles

        playlistDisplayedAudioTitles = [
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistDisplayedAudioTitles,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets(
          '''First, select a sort filter item. Then, enter the search word 'mo' in the
           'Youtube Link or Search' text field. Then click and un-click on the search icon
           button, select another playlist ...''', (WidgetTester tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'sort_and_filter_audio_dialog_widget_three_playlists_test',
          tapOnPlaylistToggleButton: false,
        );

        List<String> playlistDisplayedAudioTitlesLst = [
          "La surpopulation mondiale par Jancovici et Barrau",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La résilience insulaire par Fiona Roche",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
        ];

        // Now select the 'asc listened' sort/filter item in the dropdown
        // button items list

        // Tap on the current dropdown button item to open the dropdown
        // button items list

        await _selectAndApplySortFilterParms(
          tester: tester,
          playlistDisplayedAudioTitlesLst: playlistDisplayedAudioTitlesLst,
          sfParmsName: 'asc listened',
          textFieldContentStr: '',
        );

        // Enter the two letters of the 'mo' search word.

        // Select the text field
        await tester.tap(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
        );
        await tester.pumpAndSettle();

        // Enter the 2 letters of the 'mo' search word
        await tester.enterText(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
          'mo',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is enabled but inactive
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.enabledInactive);

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Now verify the order of the reduced playlist audio titles

        List<String> playlistDisplayedAudioTitles = [
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistDisplayedAudioTitles,
        );

        // Now tap the 'Toggle List' button to show the list of playlist's.
        // Since the search icon button was pressed, the displayed playlist
        // list is empty since no playlist title contains the 'mo' search
        // word.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the order of the normal playlist titles

        List<String> playlistsTitles = [];

        // Ensure that since the search icon button was now pressed,
        // the displayed playlist list is empty.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
          firstAudioListTileIndex: 5,
        );

        // And verify the displayd audio titles list
        playlistDisplayedAudioTitlesLst = [
          "La résilience insulaire par Fiona Roche",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
        ];

        // Since the displayed playlist list is empty due to the applied search
        // word, the displayed audio titles list is not filtered.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistDisplayedAudioTitlesLst,
        );

        // Now tap on the search icon button to deactivate it
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Verify the displayed playlist titles list
        playlistsTitles = [
          "S8 audio",
          "local",
          "local_2",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // And verify the displayd audio titles list
        playlistDisplayedAudioTitlesLst = [
          "La résilience insulaire par Fiona Roche",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
        ];

        // Since the displayed playlist list is not filtered due to the
        // fact that the search icon button was un-pressed, the displayed
        // audio titles list start at index 3.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistDisplayedAudioTitlesLst,
          firstAudioListTileIndex: 3,
        );

        // Now re-tap on the search icon button to re-activate it
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // And tap on the 'Toggle List' button to reduce the list of
        // playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the filtered audio titles list
        playlistDisplayedAudioTitles = [
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        // Now re-tap on the search icon button to de-activate it
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // And tap on the 'Toggle List' button to redisplay the list of
        // playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Now select the 'local' playlist
        await IntegrationTestUtil.selectPlaylist(
          tester: tester,
          playlistToSelectTitle: 'local',
        );

        // Verify that the search text field content was conserved
        IntegrationTestUtil.verifyTextFieldContent(
          tester: tester,
          textFieldKeyStr: 'youtubeUrlOrSearchTextField',
          expectedTextFieldContent: 'mo',
        );

        // Now tap the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // And verify the order of the default playlist audio titles

        playlistDisplayedAudioTitles = [
          "morning _ cinematic video",
          "Really short video",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La résilience insulaire par Fiona Roche",
          "Les besoins artificiels par R.Keucheyan",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button was un-pressed,
        // the displayed audio list returned to the default list.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistDisplayedAudioTitles,
        );

        // Tap on the search icon button to activate it on the 'local'
        // playlist
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // And verify the order of the filtered playlist audio titles

        playlistDisplayedAudioTitles = [
          "morning _ cinematic video",
        ];

        // Ensure that since the search icon button was un-pressed,
        // the displayed audio list returned to the default list.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistDisplayedAudioTitles,
        );

        // Then, tap on the search icon button to deactivate it
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Verify that the search text field content was not changed
        IntegrationTestUtil.verifyTextFieldContent(
          tester: tester,
          textFieldKeyStr: 'youtubeUrlOrSearchTextField',
          expectedTextFieldContent: 'mo',
        );

        // And verify the order of the default playlist audio titles

        playlistDisplayedAudioTitles = [
          "morning _ cinematic video",
          "Really short video",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La résilience insulaire par Fiona Roche",
          "Les besoins artificiels par R.Keucheyan",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button was un-pressed,
        // the displayed audio list returned to the default list.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistDisplayedAudioTitles,
        );

        // Now select the 'asc listened' sort/filter item in the dropdown
        // button items list

        // Tap on the current dropdown button item to open the dropdown
        // button items list

        playlistDisplayedAudioTitlesLst = [
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "Really short video",
          "morning _ cinematic video",
          "La résilience insulaire par Fiona Roche",
          "Les besoins artificiels par R.Keucheyan",
        ];

        // Now select the 'asc listened' sort/filter item in the dropdown
        // button items list

        // Tap on the current dropdown button item to open the dropdown
        // button items list

        await _selectAndApplySortFilterParms(
          tester: tester,
          playlistDisplayedAudioTitlesLst: playlistDisplayedAudioTitlesLst,
          sfParmsName: 'asc listened',
          textFieldContentStr: 'mo',
        );

        // Now tap on the search icon button to activate it on the 'local'
        // playlist
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // And verify the order of the filtered playlist audio titles

        playlistDisplayedAudioTitles = [
          "morning _ cinematic video",
        ];

        // Then, re-tap on the search icon button to deactivate it
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Verify that the search text field content was not changed
        IntegrationTestUtil.verifyTextFieldContent(
          tester: tester,
          textFieldKeyStr: 'youtubeUrlOrSearchTextField',
          expectedTextFieldContent: 'mo',
        );

        // And verify the order of the 'asc listened' playlist audio
        // titles

        playlistDisplayedAudioTitles = [
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "Really short video",
          "morning _ cinematic video",
          "La résilience insulaire par Fiona Roche",
          "Les besoins artificiels par R.Keucheyan",
        ];

        // Ensure that since the search icon button was un-pressed,
        // the displayed audio list returned to the default list.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistDisplayedAudioTitles,
        );

        // Re-tap on the search icon button to re-activate it
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // And tap on the 'Toggle List' button to display the list
        // of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify that the search text field content was not changed
        IntegrationTestUtil.verifyTextFieldContent(
          tester: tester,
          textFieldKeyStr: 'youtubeUrlOrSearchTextField',
          expectedTextFieldContent: 'mo',
        );

        // Verify that the search icon button is enabled and active
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.enabledActive);

        // Verify that the list of playlists is empty since the search
        // text field is applied to the playlist list.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: [],
          firstAudioListTileIndex: 6,
        );

        // Now tap on the search icon button to deactivate it
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Verify the displayed playlist titles order
        playlistsTitles = [
          "S8 audio",
          "local",
          "local_2",
        ];

        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
        );

        // And select the 'S8 audio' playlist
        await IntegrationTestUtil.selectPlaylist(
          tester: tester,
          playlistToSelectTitle: 'S8 audio',
        );

        // Tap on the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        playlistDisplayedAudioTitlesLst = [
          "La surpopulation mondiale par Jancovici et Barrau",
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La résilience insulaire par Fiona Roche",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
          "Les besoins artificiels par R.Keucheyan",
        ];

        // Now select the 'asc listened' sort/filter item in the dropdown
        // button items list

        // Tap on the current dropdown button item to open the dropdown
        // button items list

        await _selectAndApplySortFilterParms(
          tester: tester,
          playlistDisplayedAudioTitlesLst: playlistDisplayedAudioTitlesLst,
          sfParmsName: 'asc listened',
          textFieldContentStr: 'mo',
        );

        // Re-tap on the search icon button to re-activate it
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // And verify the order of the reduced playlist audio titles

        playlistDisplayedAudioTitles = [
          "La surpopulation mondiale par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistDisplayedAudioTitles,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets(
          '''First, click on audio item to select it and go to the audio player view.
            Then, return to the playlist download view and enter the search word 'no'
            in the 'Youtube Link or Search' text field. Then click on the search icon
            button, then click on the 'Toggle List' button to show the empty list of
            playlists ...''', (WidgetTester tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'sort_and_filter_audio_dialog_widget_three_playlists_test',
          tapOnPlaylistToggleButton: false,
        );

        // Verify that the search icon button is now disabled
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.disabled);

        // Click on "Jancovici m'explique l’importance des ordres de
        // grandeur face au changement climatique"
        await tester.tap(find.text(
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        ));
        await tester.pumpAndSettle();

        // Then return to playlist download view
        Finder applicationViewNavButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(applicationViewNavButton);
        await tester.pumpAndSettle();

        // Enter the two letters of the 'no' search word.

        // Select the text field
        await tester.tap(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
        );
        await tester.pumpAndSettle();

        // Enter the 2 letters of the 'mo' search word
        await tester.enterText(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
          'no',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Verify that the search icon button is enabled, but inactive
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.enabledInactive);

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Verify that the search icon button is now active
        IntegrationTestUtil.validateSearchIconButton(
            tester: tester,
            searchIconButtonState: SearchIconButtonState.enabledActive);

        // Now verify the order of the reduced playlist audio titles

        List<String> playlistDisplayedAudioTitles = [
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        ];

        // Ensure that since the search icon button was now pressed,
        // the displayed audio list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistDisplayedAudioTitles,
        );

        // Now tap the 'Toggle List' button to show the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the order of the filtered playlist titles

        List<String> playlistsTitles = [];

        // Ensure that since the search icon button was now pressed,
        // the displayed playlist list is modified.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistsTitles,
          firstAudioListTileIndex: 4,
        );

        // And verify the displayd audio titles list
        List<String> playlistDisplayedAudioTitlesLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          "La surpopulation mondiale par Jancovici et Barrau",
          "La résilience insulaire par Fiona Roche",
          "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        ];

        // Since the displayed playlist list is empty due to the applied search
        // word, the displayed audio titles list is not filtered.
        IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
          tester: tester,
          audioOrPlaylistTitlesOrderedLst: playlistDisplayedAudioTitlesLst,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
    group(
        '''Use a search word to select audio's and start moving or copying one audio
          verifying the displayed target playlists is not filtered by the search
          sentence.''', () {
      testWidgets(
          '''Verifying the displayed target playlists is not filtered by the search
            sentence.''', (WidgetTester tester) async {
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'copy_move_audio_integr_test_data',
          tapOnPlaylistToggleButton: false,
        );

        // Change the app language to English

        // Open the appbar right menu
        await tester.tap(find.byKey(const Key('appBarRightPopupMenu')));
        await tester.pumpAndSettle();

        // And tap on 'Select English' to change the language
        await tester.tap(find.text('Anglais'));
        await tester.pumpAndSettle();

        // Tap on the 'Toggle List' button to display the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Open the add playlist dialog by tapping the add playlist
        // button
        await tester.tap(find.byKey(const Key('addPlaylistButton')));
        await tester.pumpAndSettle();

        const String localTwoPlaylistTitle = 'local_two';

        // Enter the title of the local playlist
        await tester.enterText(
          find.byKey(const Key('playlistLocalTitleConfirmDialogTextField')),
          localTwoPlaylistTitle,
        );
        await tester.pumpAndSettle();

        // Confirm the addition by tapping the confirmation button in
        // the AlertDialog
        await tester
            .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
        await tester.pumpAndSettle();

        // Close the warning dialog by tapping the ok button
        await tester.tap(find.byKey(const Key('warningDialogOkButton')));
        await tester.pumpAndSettle();

        // Enter the 'two' search word.

        // Select the text field
        await tester.tap(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
        );
        await tester.pumpAndSettle();

        // Enter the 'two' search word
        await tester.enterText(
          find.byKey(
            const Key('youtubeUrlOrSearchTextField'),
          ),
          'two',
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Now tap on the search icon button
        await tester.tap(find.byKey(const Key('search_icon_button')));
        await tester.pumpAndSettle();

        // Verify the search sentence application

        List<String> playlistsTitles = [
          "local_two",
        ];

        List<String> audioTitles = [
          "audio learn test short video two",
          "audio learn test short video one",
        ];

        IntegrationTestUtil.checkPlaylistAndAudioTitlesOrderInListTile(
          tester: tester,
          playlistTitlesOrderedLst: playlistsTitles,
          audioTitlesOrderedLst: audioTitles,
        );

        // Now tap on the 'Toggle List' button to hide the list of playlist's.
        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // Verify the search sentence application

        playlistsTitles = [];

        audioTitles = [
          "audio learn test short video two",
        ];

        IntegrationTestUtil.checkPlaylistAndAudioTitlesOrderInListTile(
          tester: tester,
          playlistTitlesOrderedLst: playlistsTitles,
          audioTitlesOrderedLst: audioTitles,
        );

        // Verify that the target playlist list is not filtered
        // by the search sentence after tapping on the audio
        // item  move menu

        await _verifyTargetListTitles(
          tester: tester,
          moveOrCopyMenuKeyStr: 'popup_menu_move_audio_to_playlist',
        );

        // Verify that the target playlist list is not filtered
        // by the search sentence after tapping on the audio
        // item copy menu

        await _verifyTargetListTitles(
          tester: tester,
          moveOrCopyMenuKeyStr: 'popup_menu_copy_audio_to_playlist',
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
  });
  group('Save playlist, comments, pictures and settings to zip file menu test',
      () {
    testWidgets(
        '''Successful save. The integration test verify the confirmation displayed
           warning''', (WidgetTester tester) async {
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

      // Replace the platform instance with your mock
      MockFilePicker mockFilePicker = MockFilePicker();
      FilePicker.platform = mockFilePicker;

      await app.main();
      await tester.pumpAndSettle();

      // First, set the application language to english
      await IntegrationTestUtil.setApplicationLanguage(
        tester: tester,
        language: Language.english,
      );

      // Create a new directory to which the zip file will be saved

      String saveZipFilePath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}appSave';

      DirUtil.createDirIfNotExistSync(
        pathStr: saveZipFilePath,
      );

      // Setting the path value returned by the FilePicker mock.
      mockFilePicker.setPathToSelect(
        pathToSelectStr: saveZipFilePath,
      );

      // Tap the appbar leading popup menu button
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // Now tap on the 'Save Playlists and Comments to zip File' menu
      await tester.tap(
          find.byKey(const Key('appBarMenuCopyPlaylistsAndCommentsToZip')));
      await tester.pumpAndSettle();

      // Verify the displayed warning dialog
      await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "Saved playlist, comment and picture JSON files as well as application settings to \"$saveZipFilePath${path.separator}audioLearn_${yearMonthDayDateTimeFormatForFileName.format(DateTime.now())}.zip\".",
        isWarningConfirming: true,
      );

      List<String> zipLst = DirUtil.listFileNamesInDir(
        directoryPath: saveZipFilePath,
        fileExtension: 'zip',
      );

      List<String> expectedZipContentLst = [
        "audio_learn_test_download_2_small_videos\\audio_learn_test_download_2_small_videos.json",
        "audio_learn_test_download_2_small_videos\\comments\\230628-033811-audio learn test short video one 23-06-10.json",
        "audio_learn_test_download_2_small_videos\\comments\\230628-033813-audio learn test short video two 23-06-10.json",
        "audio_player_view_2_shorts_test\\audio_player_view_2_shorts_test.json",
        "local_3\\local_3.json",
        "local_audio_playlist_2\\local_audio_playlist_2.json",
        "settings.json",
      ];

      List<String> zipContentLst = await DirUtil.listPathFileNamesInZip(
        zipFilePathName: "$saveZipFilePath${path.separator}${zipLst[0]}",
      );

      expect(
        zipContentLst,
        expectedZipContentLst,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets(
        '''Unsuccessful save which happens on the S8 Galaxy smartphone. The
           integration test verify the displayed warning''',
        (WidgetTester tester) async {
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

      // Replace the platform instance with your mock
      MockFilePicker mockFilePicker = MockFilePicker();
      FilePicker.platform = mockFilePicker;

      await app.main();
      await tester.pumpAndSettle();

      // Create a new directory to which the zip file will be saved

      String saveZipFilePath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}appSave';

      DirUtil.createDirIfNotExistSync(
        pathStr: saveZipFilePath,
      );

      // Setting the path value returned by the FilePicker mock. This
      // path value is the one returned on the S8 Galaxy smartphone !
      mockFilePicker.setPathToSelect(
        pathToSelectStr: '/',
      );

      // Tap the appbar leading popup menu button
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // Now tap on the 'Save Playlists and Comments to zip File' menu
      await tester.tap(
          find.byKey(const Key('appBarMenuCopyPlaylistsAndCommentsToZip')));
      await tester.pumpAndSettle();

      // Verify the displayed warning dialog
      await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "Playlist, comment and picture JSON files as well as application settings could not be saved to zip.",
        isWarningConfirming: false,
      );

      List<String> zipLst = DirUtil.listFileNamesInDir(
        directoryPath: saveZipFilePath,
        fileExtension: 'zip',
      );

      expect(zipLst.isEmpty, true);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('''After picture and comment addition, save to zip file.''',
        (WidgetTester tester) async {
      // Replace the platform instance with your mock
      MockFilePicker mockFilePicker = MockFilePicker();
      FilePicker.platform = mockFilePicker;

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_zip_comment_picture_test',
        tapOnPlaylistToggleButton: false,
      );

      final String availablePicturesDir =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}availablePictures";

      final String appPictureAudioMapDir =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kPictureDirName";

      const String localPlaylistTitle = 'local';
      final String localPlaylistPictureDir =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}playlists${path.separator}$localPlaylistTitle${path.separator}$kPictureDirName";
      final String localPlaylistPictureJsonFilesDir =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}playlists${path.separator}$localPlaylistTitle${path.separator}$kPictureDirName";

      const String localAudioOneTitle =
          'CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien';
      const String localAudioOneDurationStr = '40:53';

      const String jesusChristPlaylistTitle = 'Jésus-Christ';
      final String jesusChristPlaylistPictureJsonFilesDir =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}playlists${path.separator}$jesusChristPlaylistTitle${path.separator}$kPictureDirName";

      const String jesusChristAudioOneTitle =
          'NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE';
      const String jesusChristAudioOneDurationStr = '24:07';

      const String pictureOneFileName = "Jésus, mon amour.jpg";
      const int pictureOneFileSize = 94507;
      const String pictureTwoFileName = "Jésus je T'adore.jpg";
      const int pictureTwoFileSize = 154529;
      const String pictureThreeFileName = "Jésus je T'aime.jpg";
      const int pictureThreeFileSize = 125867;
      const String pictureFourFileName = "Jésus l'Amour de ma vie.jpg";
      const int pictureFourFileSize = 187362;

      // Select the local playlist containing the audio to which we
      // will add a first picture
      await IntegrationTestUtil.selectPlaylist(
        tester: tester,
        playlistToSelectTitle: localPlaylistTitle,
      );

      // Verify that the appPictureAudioMap dir is not present
      Directory appPictureAudioMapDirectory = Directory(appPictureAudioMapDir);
      expect(appPictureAudioMapDirectory.existsSync(), false);

      // Verify that the local playlist picture dir is not present
      Directory localPlaylistPictureDirDirectory =
          Directory(localPlaylistPictureDir);
      expect(localPlaylistPictureDirDirectory.existsSync(), false);

      // First picture addition (to a local playlist audio)
      await _addPictureToAudioExecutingAudioListItemMenu(
        tester: tester,
        mockFilePicker: mockFilePicker,
        pictureFileName: pictureOneFileName, // "Jésus, mon amour.jpg"
        pictureSourcePath: availablePicturesDir,
        pictureFileSize: pictureOneFileSize,
        audioForPictureTitle: localAudioOneTitle, // CETTE SOEUR GUÉRIT ...
      );

      List<String> audioForPictureTitleLstJesusJeTaime = [
        "local|250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01"
      ];

      List<String> playlistJesusChristAudioOnePictureLstJsonFileName = [
        "241210-073532-NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE 24-11-12.json",
      ];

      // Now verifying the audio picture first addition result

      List<String> playlistLocalAudioOnePictureLstJsonFileName = [
        "250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01.json",
      ];

      List<String> audioForPictureTitleLstJesusMonAmour = [
        "local|250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01",
      ];

      await IntegrationTestUtil.verifyPictureAddition(
        tester: tester,
        applicationPictureDir: appPictureAudioMapDir,
        playlistPictureJsonFilesDir: localPlaylistPictureJsonFilesDir,
        audioForPictureTitle: localAudioOneTitle, // CETTE SOEUR GUÉRIT ...
        audioForPictureTitleDurationStr: localAudioOneDurationStr,
        playlistAudioPictureJsonFileNameLst:
            playlistLocalAudioOnePictureLstJsonFileName,
        pictureFileNameOne: pictureOneFileName, // "Jésus mon amour.jpg"
        audioForPictureTitleOneLst: audioForPictureTitleLstJesusMonAmour,
        mustPlayableAudioListBeUsed: false,
      );

      // Now go back to the playlist download view, select another playlist
      // and add another picture to a new audio.

      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Select the Jésus-Christ playlist containing the audio to which we
      // will add a first picture
      await IntegrationTestUtil.selectPlaylist(
        tester: tester,
        playlistToSelectTitle: jesusChristPlaylistTitle,
      );

      // Second picture addition (to a jésus-christ playlist audio)
      await _addPictureToAudioExecutingAudioListItemMenu(
        tester: tester,
        mockFilePicker: mockFilePicker,
        pictureFileName: pictureOneFileName, // "Jésus, mon amour.jpg"
        pictureSourcePath: availablePicturesDir,
        pictureFileSize: pictureOneFileSize,
        audioForPictureTitle:
            jesusChristAudioOneTitle, // NE VOUS METTEZ PLUS JAMAIS EN COLÈRE ...
      );

      audioForPictureTitleLstJesusMonAmour = [
        "local|250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01",
        "Jésus-Christ|241210-073532-NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE 24-11-12",
      ];

      // Now verifying the second audio picture addition result
      await IntegrationTestUtil.verifyPictureAddition(
        tester: tester,
        applicationPictureDir: appPictureAudioMapDir,
        playlistPictureJsonFilesDir: jesusChristPlaylistPictureJsonFilesDir,
        pictureFileNameOne: pictureOneFileName, // "Jésus mon amour.jpg"
        audioForPictureTitle:
            jesusChristAudioOneTitle, // NE VOUS METTEZ PLUS JAMAIS EN COLÈRE ...
        audioForPictureTitleDurationStr: jesusChristAudioOneDurationStr,
        playlistAudioPictureJsonFileNameLst:
            playlistJesusChristAudioOnePictureLstJsonFileName,
        audioForPictureTitleOneLst: audioForPictureTitleLstJesusMonAmour,
        mustPlayableAudioListBeUsed: false,
      );

      // Go back to the playlist download view, re-select the local playlist
      // and add another picture to a the audio which already has a picture.

      appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Select the local playlist containing the audio to which we
      // will add a new picture
      await IntegrationTestUtil.selectPlaylist(
        tester: tester,
        playlistToSelectTitle: localPlaylistTitle,
      );

      // Third picture addition, to the local playlist audio which
      // already has a picture
      await _addPictureToAudioExecutingAudioListItemMenu(
        tester: tester,
        mockFilePicker: mockFilePicker,
        pictureFileName: pictureTwoFileName, // "Jésus je T'adore.jpg"
        pictureSourcePath: availablePicturesDir,
        pictureFileSize: pictureTwoFileSize,
        audioForPictureTitle:
            localAudioOneTitle, // NE VOUS METTEZ PLUS JAMAIS EN COLÈRE ...
      );

      audioForPictureTitleLstJesusMonAmour = [
        "local|250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01",
        "Jésus-Christ|241210-073532-NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE 24-11-12",
      ];

      List<String> audioForPictureTitleLstJesusJeTadore = [
        "local|250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01",
      ];

      List<List<Picture>> expectedPlaylistAudioPictureLst = [
        [
          Picture(
            fileName: pictureOneFileName, // "Jésus mon amour.jpg"
          ),
          Picture(
            fileName: pictureTwoFileName, // "Jésus je T'adore.jpg"
          ),
        ],
      ];

      // Now verifying the second audio picture addition result
      await IntegrationTestUtil.verifyPictureAddition(
        tester: tester,
        applicationPictureDir: appPictureAudioMapDir,
        playlistPictureJsonFilesDir: localPlaylistPictureJsonFilesDir,
        audioForPictureTitle: localAudioOneTitle, // CETTE SOEUR GUÉRIT ...
        audioForPictureTitleDurationStr: localAudioOneDurationStr,
        playlistAudioPictureJsonFileNameLst:
            playlistLocalAudioOnePictureLstJsonFileName,
        audioPictureJsonFileContentLst: expectedPlaylistAudioPictureLst,
        pictureFileNameOne: pictureOneFileName, // "Jésus mon amour.jpg"
        audioForPictureTitleOneLst: audioForPictureTitleLstJesusMonAmour,
        pictureFileNameTwo: pictureTwoFileName, // "Jésus je T'adore.jpg"
        audioForPictureTitleTwoLst: audioForPictureTitleLstJesusJeTadore,
        mustPlayableAudioListBeUsed: false,
      );

      // Return to the playlist download view and add another picture
      // to a the audio which already has two pictures.

      appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Fourth picture addition, to the local playlist audio which
      // already has two pictures
      await _addPictureToAudioExecutingAudioListItemMenu(
        tester: tester,
        mockFilePicker: mockFilePicker,
        pictureFileName: pictureThreeFileName, // "Jésus je T'aime.jpg"
        pictureSourcePath: availablePicturesDir,
        pictureFileSize: pictureThreeFileSize,
        audioForPictureTitle:
            localAudioOneTitle, // NE VOUS METTEZ PLUS JAMAIS EN COLÈRE ...
      );

      audioForPictureTitleLstJesusMonAmour = [
        "local|250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01",
        "Jésus-Christ|241210-073532-NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE 24-11-12",
      ];

      audioForPictureTitleLstJesusJeTadore = [
        "local|250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01",
      ];

      audioForPictureTitleLstJesusJeTaime = [
        "local|250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01",
      ];

      expectedPlaylistAudioPictureLst = [
        [
          Picture(
            fileName: pictureOneFileName, // "Jésus mon amour.jpg"
          ),
          Picture(
            fileName: pictureTwoFileName, // "Jésus je T'adore.jpg"
          ),
          Picture(
            fileName: pictureThreeFileName, // "Jésus je T'aime.jpg"
          ),
        ],
      ];

      // Now verifying the third audio picture addition result
      await IntegrationTestUtil.verifyPictureAddition(
        tester: tester,
        applicationPictureDir: appPictureAudioMapDir,
        playlistPictureJsonFilesDir: localPlaylistPictureJsonFilesDir,
        audioForPictureTitle: localAudioOneTitle, // CETTE SOEUR GUÉRIT ...
        audioForPictureTitleDurationStr: localAudioOneDurationStr,
        playlistAudioPictureJsonFileNameLst:
            playlistLocalAudioOnePictureLstJsonFileName,
        audioPictureJsonFileContentLst: expectedPlaylistAudioPictureLst,
        pictureFileNameOne: pictureOneFileName, // "Jésus mon amour.jpg"
        audioForPictureTitleOneLst: audioForPictureTitleLstJesusMonAmour,
        pictureFileNameTwo: pictureTwoFileName, // "Jésus je T'adore.jpg"
        audioForPictureTitleTwoLst: audioForPictureTitleLstJesusJeTadore,
        pictureFileNameThree: pictureThreeFileName, // "Jésus je T'aime.jpg"
        audioForPictureTitleThreeLst: audioForPictureTitleLstJesusJeTaime,
        mustPlayableAudioListBeUsed: false,
      );

      // Now go back to the playlist download view and remove the
      // last added audio picture

      appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Deleting the last added audio picture
      await _removeAudioPictureExecutingAudioListItemMenu(
        tester: tester,
        picturedAudioTitle: localAudioOneTitle,
      );

      await IntegrationTestUtil.verifyPictureSuppression(
        tester: tester,
        applicationPictureDir: appPictureAudioMapDir,
        playlistPictureDir: localPlaylistPictureDir,
        audioForPictureTitle: localAudioOneTitle, // CETTE SOEUR GUÉRIT ...
        audioPictureJsonFileName:
            playlistLocalAudioOnePictureLstJsonFileName[0],
        deletedPictureFileName: pictureThreeFileName, // "Jésus je T'adore.jpg"
        pictureFileNameOne: pictureOneFileName, // "Jésus mon amour.jpg"
        audioForPictureTitleOneLst: audioForPictureTitleLstJesusMonAmour,
        pictureFileNameTwo: pictureTwoFileName, // "Jésus je T'adore.jpg"
        audioForPictureTitleTwoLst: audioForPictureTitleLstJesusJeTadore,
      );

      // Now go back to the playlist download view and add again a
      // picture to the same audio whose picture was removed

      appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Third picture addition
      await _addPictureToAudioExecutingAudioListItemMenu(
        tester: tester,
        mockFilePicker: mockFilePicker,
        pictureFileName: pictureFourFileName, // "Jésus l'Amour de ma vie.jpg"
        pictureSourcePath: availablePicturesDir,
        pictureFileSize: pictureFourFileSize,
        audioForPictureTitle: localAudioOneTitle, // CETTE SOEUR GUÉRIT ...
      );

      List<String> audioForPictureTitleLstJesusLamourDeMaVie = [
        "local|250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01",
      ];

      expectedPlaylistAudioPictureLst = [
        [
          Picture(
            fileName: pictureOneFileName, // "Jésus mon amour.jpg"
          ),
          Picture(
            fileName: pictureTwoFileName, // "Jésus je T'adore.jpg"
          ),
          Picture(
            fileName: pictureFourFileName, // "Jésus l'Amour de ma vie.jpg"
          ),
        ],
      ];

      // Now verifying the third audio picture addition result
      await IntegrationTestUtil.verifyPictureAddition(
        tester: tester,
        applicationPictureDir: appPictureAudioMapDir,
        playlistPictureJsonFilesDir: localPlaylistPictureJsonFilesDir,
        audioForPictureTitle: localAudioOneTitle, // CETTE SOEUR GUÉRIT ...
        audioForPictureTitleDurationStr: localAudioOneDurationStr,
        playlistAudioPictureJsonFileNameLst:
            playlistLocalAudioOnePictureLstJsonFileName,
        audioPictureJsonFileContentLst: expectedPlaylistAudioPictureLst,
        pictureFileNameOne: pictureOneFileName, // "Jésus mon amour.jpg"
        audioForPictureTitleOneLst: audioForPictureTitleLstJesusMonAmour,
        pictureFileNameTwo: pictureTwoFileName, // "Jésus je T'adore.jpg"
        audioForPictureTitleTwoLst: audioForPictureTitleLstJesusJeTadore,
        pictureFileNameThree:
            pictureFourFileName, // "Jésus l'Amour de ma vie.jpg"
        audioForPictureTitleThreeLst: audioForPictureTitleLstJesusLamourDeMaVie,
        mustPlayableAudioListBeUsed: true,
      );

      // Finally, go back to the playlist download view and save
      // the playlists, comments, pictures and settings to a zip file

      appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      String saveZipFilePath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}backupFolder';

      // Setting the path value returned by the FilePicker mock.
      mockFilePicker.setPathToSelect(
        pathToSelectStr: saveZipFilePath,
      );

      // Tap the appbar leading popup menu button
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // Now tap on the 'Save Playlists and Comments to zip File' menu
      await tester.tap(
          find.byKey(const Key('appBarMenuCopyPlaylistsAndCommentsToZip')));
      await tester.pumpAndSettle();

      // Verify the displayed warning dialog
      await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "Saved playlist, comment and picture JSON files as well as application settings to \"$saveZipFilePath${path.separator}audioLearn_${yearMonthDayDateTimeFormatForFileName.format(DateTime.now())}.zip\".\n\nSaved also 4 picture JPG file(s) in same directory / pictures.",
        isWarningConfirming: true,
      );

      List<String> pictureNamesLst = DirUtil.listFileNamesInDir(
        directoryPath:
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}backupFolder${path.separator}$kPictureDirName",
        fileExtension: 'jpg',
      );

      List<String> expectedPictureNamesLst = [
        "Jésus je T'adore.jpg",
        "Jésus je T'aime.jpg",
        "Jésus l'Amour de ma vie.jpg",
        "Jésus, mon amour.jpg",
      ];
      expect(
        pictureNamesLst,
        expectedPictureNamesLst,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group(
      'Restore playlist, comments, pictures and settings from zip file menu test',
      () {
    testWidgets(
        '''Sel playlist. Restore Windows zip to Windows application in which
           an existing playlist is selected. Then, select a SF parm and redownload
           the filtered audio. Finally, redownload an individual not playable
           audio.''', (tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String restorableZipFileName =
          'audioLearn_audio_comment_zip_test_2025-03-09_23_03.zip';

      // Copy the integration test data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}restore_zip_existing_playlist_selected_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
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
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

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

      const String playlistRootDirName = 'playlists';

      // Verify the content of the 'A restaurer' playlist dir
      // and comments and pictures dir before restoring.
      IntegrationTestUtil.verifyPlaylistDirectoryContents(
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
          "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.jpg",
          "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.jpg",
          "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.jpg",
        ],
        playlistRootDir: playlistRootDirName,
      );

      // Verify the content of the 'local' playlist dir
      // and comments and pictures dir before restoring.
      IntegrationTestUtil.verifyPlaylistDirectoryContents(
        playlistTitle: 'local',
        expectedAudioFiles: [
          "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.mp3"
        ],
        expectedCommentFiles: [
          "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json"
        ],
        expectedPictureFiles: [
          "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.jpg"
        ],
        playlistRootDir: playlistRootDirName,
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
      // File ...' menu
      await IntegrationTestUtil.executeRestorePlaylists(
        tester: tester,
      );

      // Verify the displayed warning confirmation dialog
      await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
        tester: tester,
        warningDialogMessage:
            'Restored 4 playlist, 5 comment and 0 picture JSON files as well as the application settings from "C:\\development\\flutter\\audiolearn\\test\\data\\audio\\$restorableZipFileName".',
        isWarningConfirming: true,
        warningTitle: 'CONFIRMATION',
      );

      // Verifying the existing and the restored playlists
      // list as well as the selected playlist 'A restaurer'
      // displayed audio titles and subtitles.

      List<String> playlistsTitles = [
        "A restaurer",
        "local",
        "Empty",
        "local_comment",
        "local_delete_comment",
        "S8 audio",
      ];

      List<String> audioTitles = [
        "Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage!",
        "L'histoire secrète derrière la progression de l'IA",
        "Le 21 juillet 1913 _ Prières et méditations, La Mère",
        "Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...)",
      ];

      List<String> audioSubTitles = [
        "0:24:21.7. 9.84 MB at 510 KB/sec on 24/02/2025 at 13:27.",
        "0:22:57.8. 8.72 MB at 203 KB/sec on 24/02/2025 at 13:16.",
        "0:00:58.7. 359 KB at 89 KB/sec on 13/02/2025 at 10:43.",
        "0:22:57.8. 8.72 MB at 2.14 MB/sec on 13/02/2025 at 08:30.",
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
        "morning _ cinematic video",
        "Really short video",
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
      ];

      audioSubTitles = [
        "0:24:21.8. 8.92 MB at 1.62 MB/sec on 13/02/2025 at 08:30.",
        "0:00:59.0. 360 KB at 283 KB/sec on 10/01/2024 at 18:18.",
        "0:00:10.0. 61 KB at 20 KB/sec on 10/01/2024 at 18:18.",
        "0:06:29.0. 2.37 MB at 1.69 MB/sec on 08/01/2024 at 16:35.",
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

      audioTitles = [
        "Quand Aurélien Barrau va dans une école de management",
        "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...",
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        "La surpopulation mondiale par Jancovici et Barrau",
      ];

      audioSubTitles = [
        "0:17:59.0. 6.58 MB at 1.80 MB/sec on 22/07/2024 at 08:11.",
        "1:17:53.6. 28.50 MB at 1.63 MB/sec on 28/05/2024 at 13:06.",
        "0:06:29.0. 2.37 MB at 1.69 MB/sec on 08/01/2024 at 16:35.",
        "0:07:38.0. 2.79 MB at 2.73 MB/sec on 07/01/2024 at 16:36.",
      ];

      const String youtubePlaylistTitle = 'S8 audio';
      await IntegrationTestUtil.selectPlaylist(
        tester: tester,
        playlistToSelectTitle: youtubePlaylistTitle,
      );

      _verifyRestoredPlaylistAndAudio(
        tester: tester,
        selectedPlaylistTitle: youtubePlaylistTitle,
        playlistsTitles: playlistsTitles,
        audioTitles: audioTitles,
        audioSubTitles: audioSubTitles,
      );

      // Verify the content of the 'A restaurer' playlist dir
      // and comments and pictures dir after restoration.
      IntegrationTestUtil.verifyPlaylistDirectoryContents(
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
          "250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12.jpg",
          "250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12.jpg",
          "250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.jpg",
        ],
        playlistRootDir: playlistRootDirName,
      );

      // Verify the content of the 'local' playlist dir
      // and comments and pictures dir after restoration.
      IntegrationTestUtil.verifyPlaylistDirectoryContents(
        playlistTitle: 'local',
        expectedAudioFiles: [
          "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.mp3"
        ],
        expectedCommentFiles: [
          "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.json"
        ],
        expectedPictureFiles: [
          "250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09.jpg"
        ],
        playlistRootDir: playlistRootDirName,
      );

      // Verify the content of the 'S8 audio' playlist dir
      // and comments and pictures dir after restoration.
      IntegrationTestUtil.verifyPlaylistDirectoryContents(
        playlistTitle: youtubePlaylistTitle,
        expectedAudioFiles: [],
        expectedCommentFiles: [
          "New file name.json",
          "240722-081104-Quand Aurélien Barrau va dans une école de management 23-09-10.json",
          "240528-130636-Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité... 24-01-12.json",
        ],
        expectedPictureFiles: [],
        playlistRootDir: playlistRootDirName,
      );

      // Now, select a filter parms using the drop down button.

      // First, tap the 'Toggle List' button to hide the playlist list.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

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

      // And find the 'commented_7MB' sort/filter item
      Finder titleAscDropDownTextFinder = find.text('commented_7MB').last;
      await tester.tap(titleAscDropDownTextFinder);
      await tester.pumpAndSettle();

      // Re-tap the 'Toggle List' button to display the playlist list.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Execute the redownload filtered audio menu by clicking first on
      // the 'Filtered Audio Actions ...' playlist menu item and then
      // on the 'Redownload Filtered Audio ...' sub-menu item.
      await IntegrationTestUtil.typeOnPlaylistSubMenuItem(
        tester: tester,
        playlistTitle: youtubePlaylistTitle,
        playlistSubMenuKeyStr: 'popup_menu_redownload_filtered_audio',
      );

      // Add a delay to allow the download to finish.
      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(seconds: 2));
        await tester.pumpAndSettle();
      }

      // Verifying and closing the confirm dialog

      // await IntegrationTestUtil.verifyAndCloseConfirmActionDialog(
      //   tester: tester,
      //   confirmDialogTitleOne:
      //       "Delete audio's filtered by \"\" parms from playlist \"\"",
      //   confirmDialogMessage:
      //       "Audio's to delete number: 2,\nCorresponding total file size: 7.37 MB,\nCorresponding total duration: 00:20:08.",
      //   confirmOrCancelAction: true, // Confirm button is tapped
      // );

      // Tap the 'Toggle List' button to hide the playlist list.
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Now, select the 'default' filter parms using the drop down button.

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

      // And find the 'default' sort/filter item
      titleAscDropDownTextFinder = find.text('default').last;
      await tester.tap(titleAscDropDownTextFinder);
      await tester.pumpAndSettle();

      // Now we want to tap the popup menu of the Audio ListTile
      // "audio learn test short video one"

      // First, find the Audio sublist ListTile Text widget
      const String audioTitle =
          'Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...';
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
      final Finder popupDisplayAudioInfoMenuItemFinder =
          find.byKey(const Key("popup_menu_redownload_delete_audio"));

      await tester.tap(popupDisplayAudioInfoMenuItemFinder);
      await tester.pumpAndSettle();

      await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "The audio \"$audioTitle\" was redownloaded in the playlist \"$youtubePlaylistTitle\".",
        isWarningConfirming: true,
      );

      // Verify the content of the 'S8 audio' playlist dir
      // and comments and pictures dir after redownloading
      // filtered audio's by 'commented_7MB' SF parms as well
      // as redownloading single audio 'Interview de Chat GPT
      // - IA, intelligence, philosophie, géopolitique,
      // post-vérité...'.
      IntegrationTestUtil.verifyPlaylistDirectoryContents(
        playlistTitle: 'S8 audio',
        expectedAudioFiles: [
          "240528-130636-Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité... 24-01-12.mp3",
          "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
          "240722-081104-Quand Aurélien Barrau va dans une école de management 23-09-10.mp3",
        ],
        expectedCommentFiles: [
          "240528-130636-Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité... 24-01-12.json",
          "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.json",
          "240722-081104-Quand Aurélien Barrau va dans une école de management 23-09-10.json",
          "New file name.json",
        ],
        expectedPictureFiles: [],
        playlistRootDir: playlistRootDirName,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('Manage picture for audio', () {
    group('From audio list item in playlist download view', () {
      testWidgets(
          '''Add a picture to audio, then add another picture to the same audio. This
           will replace the existing picture. Then remove the audio picture and re-add
           a picture to the same audio.''', (WidgetTester tester) async {
        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'audio_player_picture_test',
          tapOnPlaylistToggleButton: false,
        );

        const String localPlaylistTitle = 'local';
        final String playlistPictureDir =
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}playlists${path.separator}$localPlaylistTitle${path.separator}$kPictureDirName";
        const String audioForPictureTitle =
            'CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien';
        const String audioForPictureTitleDurationStr = '40:53';
        const String pictureFileNameZero = "Jésus, mon amour.jpg";
        const String pictureFileName = "Jésus je T'adore.jpg";
        const int pictureFileSize = 154529;
        const String secondPictureFileName = "Jésus je T'aime.jpg";
        const int secondPictureFileSize = 125867;
        const String thirdPictureFileName = "Jésus l'Amour de ma vie.jpg";
        const int thirdPictureFileSize = 187362;

        // Available pictures file path
        String pictureSourcePath =
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kPictureDirName";

        // Select the local playlist whose audio we will add the picture
        await IntegrationTestUtil.selectPlaylist(
          tester: tester,
          playlistToSelectTitle: localPlaylistTitle,
        );

        // First picture addition
        String pictureFilePathName =
            await _addPictureToAudioExecutingAudioListItemMenu(
          tester: tester,
          mockFilePicker: mockFilePicker,
          pictureFileName: pictureFileName, // "Jésus je T'adore.jpg"
          pictureSourcePath: pictureSourcePath,
          pictureFileSize: pictureFileSize,
          audioForPictureTitle: audioForPictureTitle, // CETTE SOEUR GUÉRIT ...
        );

        List<String> audioForPictureTitleLstJesusMonAmour = [
          "Jésus-Christ|241210-073532-NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE 24-11-12",
        ];

        List<String> audioForPictureTitleLstJesusJeTadore = [
          "local|250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01",
        ];

        List<String> audioForPictureTitleLstJesusJeTaime = [
          "local|250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01"
        ];

        String playlistPictureJsonFilesDir =
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}playlists${path.separator}$localPlaylistTitle${path.separator}$kPictureDirName";

        List<String> pictureFileNamesLst = [
          "250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01.json",
        ];

        final String applicationPictureDir =
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kPictureDirName";

        // Now verifying the audio picture addition result
        await IntegrationTestUtil.verifyPictureAddition(
          tester: tester,
          applicationPictureDir: applicationPictureDir,
          playlistPictureJsonFilesDir: playlistPictureJsonFilesDir,
          pictureFileNameOne: pictureFileNameZero, // "Jésus, mon amour.jpg"
          audioForPictureTitle: audioForPictureTitle, // CETTE SOEUR GUÉRIT ...
          audioForPictureTitleDurationStr: audioForPictureTitleDurationStr,
          playlistAudioPictureJsonFileNameLst: pictureFileNamesLst,
          audioForPictureTitleOneLst: audioForPictureTitleLstJesusMonAmour,
          pictureFileNameTwo: pictureFileName, // "Jésus je T'adore.jpg"
          audioForPictureTitleTwoLst: audioForPictureTitleLstJesusJeTaime,
          mustPlayableAudioListBeUsed: true,
        );

        // Now go back to the playlist download view and add another
        // picture to the same audio. This will replace the first added
        // picture by the second one.

        Finder appScreenNavigationButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        // Second picture addition
        pictureFilePathName =
            await _addPictureToAudioExecutingAudioListItemMenu(
          tester: tester,
          mockFilePicker: mockFilePicker,
          pictureFileName: secondPictureFileName, // "Jésus je T'aime.jpg"
          pictureSourcePath: pictureSourcePath,
          pictureFileSize: secondPictureFileSize,
          audioForPictureTitle: audioForPictureTitle, // CETTE SOEUR GUÉRIT ...
        );

        // Now verifying the second audio picture addition result
        await IntegrationTestUtil.verifyPictureAddition(
          tester: tester,
          applicationPictureDir: applicationPictureDir,
          playlistPictureJsonFilesDir: playlistPictureDir,
          pictureFileNameOne: pictureFileName, // "Jésus je T'adore.jpg"
          audioForPictureTitle: audioForPictureTitle, // CETTE SOEUR GUÉRIT ...
          audioForPictureTitleDurationStr: audioForPictureTitleDurationStr,
          playlistAudioPictureJsonFileNameLst: pictureFileNamesLst,
          audioForPictureTitleOneLst: audioForPictureTitleLstJesusJeTadore,
          pictureFileNameTwo: pictureFileName, // "Jésus je T'adore.jpg"
          audioForPictureTitleTwoLst: audioForPictureTitleLstJesusJeTadore,
          pictureFileNameThree: secondPictureFileName, // "Jésus je T'aime.jpg"
          audioForPictureTitleThreeLst: audioForPictureTitleLstJesusJeTaime,
          mustPlayableAudioListBeUsed: false,
        );

        // Now go back to the playlist download view and remove the
        // audio picture

        appScreenNavigationButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        // Deleting the added audio picture
        await _removeAudioPictureExecutingAudioListItemMenu(
          tester: tester,
          picturedAudioTitle: audioForPictureTitle,
        );

        await IntegrationTestUtil.verifyPictureSuppression(
          tester: tester,
          applicationPictureDir: applicationPictureDir,
          playlistPictureDir: playlistPictureDir,
          audioForPictureTitle: audioForPictureTitle,
          audioPictureJsonFileName:
              "250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01.json",
          deletedPictureFileName: secondPictureFileName,
        );

        // Now go back to the playlist download view and add again a
        // picture to the same audio whose picture was removed

        appScreenNavigationButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        // Third picture addition
        pictureFilePathName =
            await _addPictureToAudioExecutingAudioListItemMenu(
          tester: tester,
          mockFilePicker: mockFilePicker,
          pictureFileName:
              thirdPictureFileName, // "Jésus l'Amour de ma vie.jpg"
          pictureSourcePath: pictureSourcePath,
          pictureFileSize: thirdPictureFileSize,
          audioForPictureTitle: audioForPictureTitle, // CETTE SOEUR GUÉRIT ...
        );

        // Now verifying the third audio picture addition result
        await IntegrationTestUtil.verifyPictureAddition(
          tester: tester,
          applicationPictureDir: applicationPictureDir,
          playlistPictureJsonFilesDir: playlistPictureDir,
          pictureFileNameOne: pictureFilePathName,
          audioForPictureTitle: audioForPictureTitle, // CETTE SOEUR GUÉRIT ...
          audioForPictureTitleDurationStr: audioForPictureTitleDurationStr,
          playlistAudioPictureJsonFileNameLst: pictureFileNamesLst,
          mustPlayableAudioListBeUsed: false,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets('''Add audio picture to other audio in same playlist.''',
          (WidgetTester tester) async {
        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        const String youtubePlaylistTitle = 'Jésus-Christ';
        final String playlistPictureDir =
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}playlists${path.separator}$youtubePlaylistTitle${path.separator}$kPictureDirName";
        final String applicationPictureDir =
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kPictureDirName";
        const String audioForPictureTitle =
            'CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien';
        const String audioForPictureTitleDurationStr = '40:53';
        const String audioAlreadyUsingPictureTitle =
            'NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE';
        const String audioAlreadyUsingPictureDurationStr = '24:07';
        const String pictureFileNameZero = "Jésus, mon amour.jpg";
        const String pictureFileName = "Jésus, mon amour.jpg";
        const int pictureFileSize = 94507;

        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'audio_player_picture_test',
          selectedPlaylistTitle: youtubePlaylistTitle,
          tapOnPlaylistToggleButton: false,
        );

        // First picture addition
        await _addPictureToAudioExecutingAudioListItemMenu(
          tester: tester,
          mockFilePicker: mockFilePicker,
          pictureFileName: pictureFileName,
          pictureSourcePath: applicationPictureDir,
          pictureFileSize: pictureFileSize,
          audioForPictureTitle: audioForPictureTitle,
        );

        // Picture json files path
        String playlistPictureJsonFilesDir =
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}playlists${path.separator}$youtubePlaylistTitle${path.separator}$kPictureDirName";

        List<String> pictureFileNamesLst = [
          '241210-073532-NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE 24-11-12.json',
          "250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01.json",
        ];

        List<String> audioForPictureTitleLst = [
          "Jésus-Christ|241210-073532-NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE 24-11-12",
          "Jésus-Christ|250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01",
        ];

        // Now verifying the audio picture addition result
        await IntegrationTestUtil.verifyPictureAddition(
          tester: tester,
          applicationPictureDir: applicationPictureDir,
          playlistPictureJsonFilesDir: playlistPictureJsonFilesDir,
          pictureFileNameOne: pictureFileName,
          audioForPictureTitle: audioForPictureTitle,
          audioForPictureTitleDurationStr: audioForPictureTitleDurationStr,
          playlistAudioPictureJsonFileNameLst: pictureFileNamesLst,
          audioForPictureTitleOneLst: audioForPictureTitleLst,
          mustPlayableAudioListBeUsed: true,
        );

        // Now go back to the playlist download view and add another
        // picture to the same audio. This will replace the first added
        // picture by the second one.

        Finder appScreenNavigationButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        // Deleting the added audio picture
        await _removeAudioPictureExecutingAudioListItemMenu(
          tester: tester,
          picturedAudioTitle: audioForPictureTitle,
        );

        List<String> pictureFileNamesAfterDeletionLst = [
          '241210-073532-NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE 24-11-12.json',
        ];

        await IntegrationTestUtil.verifyPictureSuppression(
            tester: tester,
            applicationPictureDir: applicationPictureDir,
            playlistPictureDir: playlistPictureDir,
            audioForPictureTitle: audioForPictureTitle,
            audioPictureJsonFileName:
                "250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01.json",
            deletedPictureFileName: "Jésus, mon amour.jpg",
            isPictureFileNameDeleted: true);

        // Go back to playlist download view in order to ensure that
        // the audio already using a picture was not impacted by
        // the previous picture suppression
        appScreenNavigationButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        List<String> audioForPictureTitleLstJesusMonAmour = [
          "Jésus-Christ|241210-073532-NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE 24-11-12",
        ];

        // Verifying that the audio already using a picture was not
        // impacted by the previous picture suppression
        await IntegrationTestUtil.verifyPictureAddition(
          tester: tester,
          applicationPictureDir: applicationPictureDir,
          playlistPictureJsonFilesDir: playlistPictureJsonFilesDir,
          pictureFileNameOne: pictureFileNameZero,
          audioForPictureTitle: audioAlreadyUsingPictureTitle,
          audioForPictureTitleDurationStr: audioAlreadyUsingPictureDurationStr,
          playlistAudioPictureJsonFileNameLst: pictureFileNamesAfterDeletionLst,
          audioForPictureTitleOneLst: audioForPictureTitleLstJesusMonAmour,
          mustPlayableAudioListBeUsed: true,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
    group('From appbar left popup menu in audio player view', () {
      testWidgets(
          '''Add a picture to audio, then add another picture to the same audio. This
           will replace the existing picture. Then delete the audio picture and re-add
           a picture to the same audio. The effects are identical to the previous test,
           but the actions are performed from the audio player view.''',
          (WidgetTester tester) async {
        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'audio_player_picture_test',
          tapOnPlaylistToggleButton: false,
        );

        const String localPlaylistTitle = 'local';
        final String playlistPictureDir =
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}playlists${path.separator}$localPlaylistTitle${path.separator}$kPictureDirName";
        const String audioForPictureTitle =
            'CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien';
        const String audioForPictureTitleDurationStr = '40:53';
        const String pictureFileNameZero = "Jésus, mon amour.jpg";
        const String pictureFileName = "Jésus je T'adore.jpg";
        const int pictureFileSize = 154529;
        const String secondPictureFileName = "Jésus je T'aime.jpg";
        const int secondPictureFileSize = 125867;
        const String thirdPictureFileName = "Jésus l'Amour de ma vie.jpg";
        const int thirdPictureFileSize = 187362;

        // Select the local playlist whose audio we will add the picture
        await IntegrationTestUtil.selectPlaylist(
          tester: tester,
          playlistToSelectTitle: localPlaylistTitle,
        );

        // Available pictures file path
        String pictureSourcePath =
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kPictureDirName";

        // Go to the audio player view
        Finder appScreenNavigationButton =
            find.byKey(const ValueKey('audioPlayerViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // Verify that the picture play/pause button is not present
        // since no picture is displayed.
        expect(
          find.byKey(const Key('picture_displayed_play_pause_button_key')),
          findsNothing,
        );

        // First picture addition
        await _addPictureToAudioExecutingAudioPlayerViewLeftAppbarMenu(
          tester: tester,
          mockFilePicker: mockFilePicker,
          pictureFileName: pictureFileName,
          pictureSourcePath: pictureSourcePath,
          pictureFileSize: pictureFileSize,
        );

        List<String> audioForPictureTitleLstJesusMonAmour = [
          "Jésus-Christ|241210-073532-NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE 24-11-12",
        ];

        List<String> audioForPictureTitleLstJesusJeTadore = [
          "local|250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01",
        ];

        List<String> audioForPictureTitleLstJesusLamourDeMaVie = [
          "local|250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01",
        ];

        List<String> audioForPictureTitleLstJesusJeTaime = [
          "local|250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01"
        ];

        List<String> pictureFileNamesLst = [
          "250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01.json",
        ];

        final String applicationPictureDir =
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kPictureDirName";

        // Now verifying the audio picture addition result
        await IntegrationTestUtil.verifyPictureAddition(
          tester: tester,
          applicationPictureDir: applicationPictureDir,
          playlistPictureJsonFilesDir: playlistPictureDir,
          pictureFileNameOne: pictureFileNameZero,
          audioForPictureTitle: audioForPictureTitle,
          audioForPictureTitleDurationStr: audioForPictureTitleDurationStr,
          playlistAudioPictureJsonFileNameLst: pictureFileNamesLst,
          audioForPictureTitleOneLst: audioForPictureTitleLstJesusMonAmour,
          pictureFileNameTwo: pictureFileName,
          audioForPictureTitleTwoLst: audioForPictureTitleLstJesusJeTadore,
          goToAudioPlayerView: false,
          mustPlayableAudioListBeUsed: false,
        );

        // Now add another picture to the same audio. This will replace
        // the first added picture by the second one.

        // Second picture addition
        await _addPictureToAudioExecutingAudioPlayerViewLeftAppbarMenu(
          tester: tester,
          mockFilePicker: mockFilePicker,
          pictureFileName: secondPictureFileName,
          pictureSourcePath: pictureSourcePath,
          pictureFileSize: secondPictureFileSize,
        );

        // Now verifying the second audio picture addition result
        await IntegrationTestUtil.verifyPictureAddition(
          tester: tester,
          applicationPictureDir: applicationPictureDir,
          playlistPictureJsonFilesDir: playlistPictureDir,
          pictureFileNameOne: pictureFileNameZero,
          audioForPictureTitle: audioForPictureTitle,
          audioForPictureTitleDurationStr: audioForPictureTitleDurationStr,
          playlistAudioPictureJsonFileNameLst: pictureFileNamesLst,
          audioForPictureTitleOneLst: audioForPictureTitleLstJesusMonAmour,
          pictureFileNameTwo: pictureFileName,
          audioForPictureTitleTwoLst: audioForPictureTitleLstJesusJeTadore,
          pictureFileNameThree: secondPictureFileName,
          audioForPictureTitleThreeLst: audioForPictureTitleLstJesusJeTaime,
          goToAudioPlayerView: false,
          mustPlayableAudioListBeUsed: false,
        );

        // Deleting the added audio picture
        await _removeAudioPictureInAudioPlayerView(
          tester: tester,
          picturedAudioTitle: audioForPictureTitle,
        );

        await IntegrationTestUtil.verifyPictureSuppression(
          tester: tester,
          applicationPictureDir: applicationPictureDir,
          playlistPictureDir: playlistPictureDir,
          audioForPictureTitle: audioForPictureTitle,
          audioPictureJsonFileName:
              "250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01.json",
          deletedPictureFileName: "Jésus je T'aime.jpg",
          goToAudioPlayerView: false,
        );

        // Third picture addition
        await _addPictureToAudioExecutingAudioPlayerViewLeftAppbarMenu(
          tester: tester,
          mockFilePicker: mockFilePicker,
          pictureFileName: thirdPictureFileName,
          pictureSourcePath: pictureSourcePath,
          pictureFileSize: thirdPictureFileSize,
        );

        // Now verifying the third audio picture addition result
        await IntegrationTestUtil.verifyPictureAddition(
          tester: tester,
          applicationPictureDir: applicationPictureDir,
          playlistPictureJsonFilesDir: playlistPictureDir,
          pictureFileNameOne: pictureFileNameZero,
          audioForPictureTitle: audioForPictureTitle,
          audioForPictureTitleDurationStr: audioForPictureTitleDurationStr,
          playlistAudioPictureJsonFileNameLst: pictureFileNamesLst,
          audioForPictureTitleOneLst: audioForPictureTitleLstJesusMonAmour,
          pictureFileNameTwo: pictureFileName,
          audioForPictureTitleTwoLst: audioForPictureTitleLstJesusJeTadore,
          pictureFileNameThree: thirdPictureFileName,
          audioForPictureTitleThreeLst:
              audioForPictureTitleLstJesusLamourDeMaVie,
          goToAudioPlayerView: false,
          mustPlayableAudioListBeUsed: false,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets(
          '''Add audio picture to other audio in same playlist. The effects are
             identical to the previous test, but the actions are performed from
             the audio player view.''', (WidgetTester tester) async {
        // Replace the platform instance with your mock
        MockFilePicker mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        const String youtubePlaylistTitle = 'Jésus-Christ';
        final String playlistPictureDir =
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}playlists${path.separator}$youtubePlaylistTitle${path.separator}$kPictureDirName";
        const String audioForPictureTitle =
            'CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien';
        const String audioForPictureTitleDurationStr = '40:53';
        const String audioAlreadyUsingPictureTitle =
            'NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE';
        const String audioAlreadyUsingPictureDurationStr = '24:07';
        const String pictureFileNameZero = "Jésus, mon amour.jpg";
        const String pictureFileName = "Jésus, mon amour.jpg";
        const int pictureFileSize = 94507;

        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'audio_player_picture_test',
          selectedPlaylistTitle: youtubePlaylistTitle,
          tapOnPlaylistToggleButton: false,
        );

        // Available pictures file path
        String pictureSourcePath =
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}$youtubePlaylistTitle${path.separator}$kPictureDirName";

        // Go to the audio player view
        final Finder audioForPictureTitleListTileTextWidgetFinder =
            find.text(audioForPictureTitle);

        await tester.tap(audioForPictureTitleListTileTextWidgetFinder);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // First picture addition
        await _addPictureToAudioExecutingAudioPlayerViewLeftAppbarMenu(
          tester: tester,
          mockFilePicker: mockFilePicker,
          pictureFileName: pictureFileName,
          pictureSourcePath: pictureSourcePath,
          pictureFileSize: pictureFileSize,
        );

        // Picture json files path
        String playlistPictureJsonFilesDir =
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}playlists${path.separator}$youtubePlaylistTitle${path.separator}$kPictureDirName";

        List<String> pictureFileNamesLst = [
          '241210-073532-NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE 24-11-12.json',
          "250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01.json",
        ];

        final String applicationPictureDir =
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kPictureDirName";

        List<String> audioForPictureTitleLst = [
          "Jésus-Christ|241210-073532-NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE 24-11-12",
          "Jésus-Christ|250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01",
        ];

        // Now verifying the audio picture addition result
        await IntegrationTestUtil.verifyPictureAddition(
          tester: tester,
          applicationPictureDir: applicationPictureDir,
          playlistPictureJsonFilesDir: playlistPictureJsonFilesDir,
          pictureFileNameOne: pictureFileNameZero,
          audioForPictureTitle: audioForPictureTitle,
          audioForPictureTitleDurationStr: audioForPictureTitleDurationStr,
          playlistAudioPictureJsonFileNameLst: pictureFileNamesLst,
          goToAudioPlayerView: false,
          audioForPictureTitleOneLst: audioForPictureTitleLst,
          mustPlayableAudioListBeUsed: false,
        );

        // Deleting the added audio picture
        await _removeAudioPictureInAudioPlayerView(
          tester: tester,
          picturedAudioTitle: audioForPictureTitle,
        );

        List<String> pictureFileNamesAfterDeletionLst = [
          '241210-073532-NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE 24-11-12.json',
        ];

        await IntegrationTestUtil.verifyPictureSuppression(
            tester: tester,
            applicationPictureDir: applicationPictureDir,
            playlistPictureDir: playlistPictureDir,
            audioForPictureTitle: audioForPictureTitle,
            audioPictureJsonFileName:
                "250103-125311-CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien 24-07-01.json",
            deletedPictureFileName: "Jésus, mon amour.jpg",
            isPictureFileNameDeleted: true);

        // Go back to playlist download view in order to ensure that
        // the audio already using a picture was not impacted by
        // the previous picture suppression
        Finder appScreenNavigationButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        audioForPictureTitleLst = [
          "Jésus-Christ|241210-073532-NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE 24-11-12",
        ];

        // Verifying that the audio already using a picture was not
        // impacted by the previous picture suppression
        await IntegrationTestUtil.verifyPictureAddition(
          tester: tester,
          applicationPictureDir: applicationPictureDir,
          playlistPictureJsonFilesDir: playlistPictureJsonFilesDir,
          pictureFileNameOne: pictureFileNameZero,
          audioForPictureTitle: audioAlreadyUsingPictureTitle,
          audioForPictureTitleDurationStr: audioAlreadyUsingPictureDurationStr,
          playlistAudioPictureJsonFileNameLst: pictureFileNamesAfterDeletionLst,
          audioForPictureTitleOneLst: audioForPictureTitleLst,
          mustPlayableAudioListBeUsed: true,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
    group('Comment minimization for pictured or not audio', () {
      testWidgets(
          '''Click on the comment icon button after clicking on the pictured and commented audio title to open the
             audio player view. Then, the comment add list dialog is open. Verify that the play/pause button present
             when a picture is present was hidden since the comments dialog was opened. Then, minimize the comment
             add list dialog and verify that the play/pause button displayed when a picture is present remains hidden
             while the comments dialog is minimized. Finally, maximize the comment add list dialog and verify that
             the play/pause button displayed when a picture is present remains hidden while the comments dialog is
             open.
             
             Then, play the comment and minimize the comment add list dialog. Do that also with a comment whose end
             position corresponds to the audio end position.''',
          (WidgetTester tester) async {
        const String youtubePlaylistTitle = 'Jésus-Christ';
        const String audioAlreadyUsingPictureTitle =
            'NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE';

        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'audio_player_picture_test',
          selectedPlaylistTitle: youtubePlaylistTitle,
          tapOnPlaylistToggleButton: false,
        );

        // Go to the audio player view
        final Finder audioForPictureTitleListTileTextWidgetFinder =
            find.text(audioAlreadyUsingPictureTitle);

        await tester.tap(audioForPictureTitleListTileTextWidgetFinder);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // Verify that the play/pause button displayed when a picture
        // is present is displayed in the top of audio player view.
        Finder playPauseButtonFinder = find.byKey(
          const Key('picture_displayed_play_pause_button_key'),
        );
        expect(playPauseButtonFinder, findsOneWidget);

        // Tap on the comment icon button to open the comment add list
        // dialog
        Finder commentInkWellButtonFinder = find.byKey(
          const Key('commentsInkWellButton'),
        );

        await tester.tap(commentInkWellButtonFinder);
        await tester.pumpAndSettle();

        // Now verify that the play/pause button displayed when a picture
        // is present was hidden since the comments dialog was opened.
        playPauseButtonFinder = find.byKey(
          const Key('picture_displayed_play_pause_button_key'),
        );
        expect(playPauseButtonFinder, findsNothing);

        // Tap on the minimize icon button to minimize the comment add
        // list dialog
        Finder minimizeButtonFinder = find.byKey(
          const Key('minimizeCommentListAddDialogKey'),
        );

        await tester.tap(minimizeButtonFinder);
        await tester.pumpAndSettle();

        // Verify again that the play/pause button displayed when a picture
        // is present remains hidden while the comments dialog is minimized.
        playPauseButtonFinder = find.byKey(
          const Key('picture_displayed_play_pause_button_key'),
        );
        expect(playPauseButtonFinder, findsNothing);

        // Then, tap on the maximize icon button to reset the comment
        // add list dialog
        Finder maximizeButtonFinder = find.byKey(
          const Key('maximizeCommentListAddDialogKey'),
        );

        await tester.tap(maximizeButtonFinder);
        await tester.pumpAndSettle();

        // Verify that the play/pause button displayed when a picture
        // is present remains hidden while the comments dialog is open.
        playPauseButtonFinder = find.byKey(
          const Key('picture_displayed_play_pause_button_key'),
        );
        expect(playPauseButtonFinder, findsNothing);

        // Now play the comment and minimize the comment add list dialog.

        await IntegrationTestUtil.playCommentFromListAddDialog(
          tester: tester,
          commentPosition: 1,
          isCommentListAddDialogAlreadyOpen: true,
        );

        // Tap on the minimize icon button to minimize the comment add
        // list dialog
        minimizeButtonFinder = find.byKey(
          const Key('minimizeCommentListAddDialogKey'),
        );
        await tester.tap(minimizeButtonFinder);
        await tester.pumpAndSettle();

        // Wait for the comment to finish playing
        await Future.delayed(const Duration(seconds: 4));
        await tester.pumpAndSettle();

        // Verify the audio position and remaining duration text

        Text audioPositionText = tester.widget<Text>(
            find.byKey(const Key('audioPlayerViewAudioPosition')));

        IntegrationTestUtil.verifyPositionWithAcceptableDifferenceSeconds(
          tester: tester,
          actualPositionTimeStr: audioPositionText.data!,
          expectedPositionTimeStr: '23:46',
          plusMinusSeconds: 1,
        );

        Text audioRemainingDurationText = tester.widget<Text>(
            find.byKey(const Key('audioPlayerViewAudioRemainingDuration')));

        IntegrationTestUtil.verifyPositionWithAcceptableDifferenceSeconds(
          tester: tester,
          actualPositionTimeStr: audioRemainingDurationText.data!,
          expectedPositionTimeStr: '0:21',
          plusMinusSeconds: 1,
        );

        // Now, tap on the maximize icon button to reset the comment
        // add list dialog
        maximizeButtonFinder = find.byKey(
          const Key('maximizeCommentListAddDialogKey'),
        );
        await tester.tap(maximizeButtonFinder);
        await tester.pumpAndSettle();

        // Now play the comment whose end position corresponds to the
        // audio end.
        await IntegrationTestUtil.playCommentFromListAddDialog(
          tester: tester,
          commentPosition: 2,
          isCommentListAddDialogAlreadyOpen: true,
        );

        // Tap on the minimize icon button to minimize the comment add
        // list dialog
        minimizeButtonFinder = find.byKey(
          const Key('minimizeCommentListAddDialogKey'),
        );
        await tester.tap(minimizeButtonFinder);
        await tester.pumpAndSettle();

        // Wait for the comment to finish playing
        await Future.delayed(const Duration(seconds: 4));
        await tester.pumpAndSettle();

        // Verify the audio position and remaining duration text

        audioPositionText = tester.widget<Text>(
            find.byKey(const Key('audioPlayerViewAudioPosition')));

        IntegrationTestUtil.verifyPositionWithAcceptableDifferenceSeconds(
          tester: tester,
          actualPositionTimeStr: audioPositionText.data!,
          expectedPositionTimeStr: '24:07',
          plusMinusSeconds: 1,
        );

        audioRemainingDurationText = tester.widget<Text>(
            find.byKey(const Key('audioPlayerViewAudioRemainingDuration')));

        IntegrationTestUtil.verifyPositionWithAcceptableDifferenceSeconds(
          tester: tester,
          actualPositionTimeStr: audioRemainingDurationText.data!,
          expectedPositionTimeStr: '0:00',
          plusMinusSeconds: 1,
        );

        // Now, tap on the maximize icon button to reset the comment
        // add list dialog
        maximizeButtonFinder = find.byKey(
          const Key('maximizeCommentListAddDialogKey'),
        );
        await tester.tap(maximizeButtonFinder);
        await tester.pumpAndSettle();

        // Now close the comment list dialog
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      testWidgets(
          '''Click on the 'Audio Comments ...' menu present in the audio player left appbar menu after clicking on
             the pictured and commented audio title to open the audio player view. Then, the comment add list dialog
             is open. Verify that the play/pause button present when
             a picture is present was hidden since the comments dialog was opened. Then, minimize the comment add
             list dialog and verify that the play/pause button displayed when a picture is present remains hidden
             while the comments dialog is minimized. Finally, maximize the comment add list dialog and verify that
             the play/pause button displayed when a picture is present remains hidden while the comments dialog is
             open.
             
             Then, play the comment and minimize the comment add list dialog. Do that also with a comment whose
             end position corresponds to the audio end position.''',
          (WidgetTester tester) async {
        const String youtubePlaylistTitle = 'Jésus-Christ';
        const String audioAlreadyUsingPictureTitle =
            'NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE';

        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'audio_player_picture_test',
          selectedPlaylistTitle: youtubePlaylistTitle,
          tapOnPlaylistToggleButton: false,
        );

        // Go to the audio player view
        final Finder audioForPictureTitleListTileTextWidgetFinder =
            find.text(audioAlreadyUsingPictureTitle);

        await tester.tap(audioForPictureTitleListTileTextWidgetFinder);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // Verify that the play/pause button displayed when a picture
        // is present is displayed in the top of audio player view.
        Finder playPauseButtonFinder = find.byKey(
          const Key('picture_displayed_play_pause_button_key'),
        );
        expect(playPauseButtonFinder, findsOneWidget);

        // Tap on the appbar leading popup menu button
        await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
        await tester.pumpAndSettle();

        // Find the 'Audio Comments ...' menu item and tap on it to open the
        // comment add list dialog
        await tester
            .tap(find.byKey(const Key('appbar_popup_menu_audio_comment')));
        await tester.pumpAndSettle();

        // Now verify that the play/pause button displayed when a picture
        // is present was hidden since the comments dialog was opened.
        playPauseButtonFinder = find.byKey(
          const Key('picture_displayed_play_pause_button_key'),
        );
        expect(playPauseButtonFinder, findsNothing);

        // Tap on the minimize icon button to minimize the comment add
        // list dialog
        Finder minimizeButtonFinder = find.byKey(
          const Key('minimizeCommentListAddDialogKey'),
        );

        await tester.tap(minimizeButtonFinder);
        await tester.pumpAndSettle();

        // Verify again that the play/pause button displayed when a picture
        // is present remains hidden while the comments dialog is minimized.
        playPauseButtonFinder = find.byKey(
          const Key('picture_displayed_play_pause_button_key'),
        );
        expect(playPauseButtonFinder, findsNothing);

        // Then, tap on the maximize icon button to reset the comment
        // add list dialog
        Finder maximizeButtonFinder = find.byKey(
          const Key('maximizeCommentListAddDialogKey'),
        );

        await tester.tap(maximizeButtonFinder);
        await tester.pumpAndSettle();

        // Verify that the play/pause button displayed when a picture
        // is present remains hidden while the comments dialog is open.
        playPauseButtonFinder = find.byKey(
          const Key('picture_displayed_play_pause_button_key'),
        );
        expect(playPauseButtonFinder, findsNothing);

        // Now play the comment whose end position corresponds to the
        // audio end.
        await IntegrationTestUtil.playCommentFromListAddDialog(
          tester: tester,
          commentPosition: 2,
          isCommentListAddDialogAlreadyOpen: true,
        );

        // Tap on the minimize icon button to minimize the comment add
        // list dialog
        minimizeButtonFinder = find.byKey(
          const Key('minimizeCommentListAddDialogKey'),
        );
        await tester.tap(minimizeButtonFinder);
        await tester.pumpAndSettle();

        // Wait for the comment to finish playing
        await Future.delayed(const Duration(seconds: 4));
        await tester.pumpAndSettle();

        // Verify the audio position and remaining duration text

        Text audioPositionText = tester.widget<Text>(
            find.byKey(const Key('audioPlayerViewAudioPosition')));

        IntegrationTestUtil.verifyPositionWithAcceptableDifferenceSeconds(
          tester: tester,
          actualPositionTimeStr: audioPositionText.data!,
          expectedPositionTimeStr: '24:07',
          plusMinusSeconds: 1,
        );

        Text audioRemainingDurationText = tester.widget<Text>(
            find.byKey(const Key('audioPlayerViewAudioRemainingDuration')));

        IntegrationTestUtil.verifyPositionWithAcceptableDifferenceSeconds(
          tester: tester,
          actualPositionTimeStr: audioRemainingDurationText.data!,
          expectedPositionTimeStr: '0:00',
          plusMinusSeconds: 1,
        );

        // Now, tap on the maximize icon button to reset the comment
        // add list dialog
        maximizeButtonFinder = find.byKey(
          const Key('maximizeCommentListAddDialogKey'),
        );
        await tester.tap(maximizeButtonFinder);
        await tester.pumpAndSettle();

        // Now close the comment list dialog
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Click on the playlist download view icon button to go back to the
        // playlist download view
        Finder appScreenNavigationButton =
            find.byKey(const ValueKey('playlistDownloadViewIconButton'));
        await tester.tap(appScreenNavigationButton);
        await tester.pumpAndSettle();

        // First, find the Audio sublist ListTile Text widget of
        // 'NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE'.
        Finder targetAudioListTileTextWidgetFinder =
            find.text(audioAlreadyUsingPictureTitle);

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
        final Finder popupDisplayAudioCommentMenuItemFinder =
            find.byKey(const Key("popup_menu_audio_comment"));

        await tester.tap(popupDisplayAudioCommentMenuItemFinder);
        await tester.pumpAndSettle();

        // Verify that no minimize icon button is displayed in the
        // comment add list dialog since the dialog isn't open in
        // the audio player view.
        minimizeButtonFinder = find.byKey(
          const Key('minimizeCommentListAddDialogKey'),
        );
        expect(minimizeButtonFinder, findsNothing);

        // Then close the comment list dialog
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        await IntegrationTestUtil.openPlaylistCommentDialog(
          tester: tester,
          playlistTitle: youtubePlaylistTitle,
        );

        // Verify that no minimize icon button is displayed in the
        // comment add list dialog since the dialog isn't open in
        // the audio player view.
        minimizeButtonFinder = find.byKey(
          const Key('minimizeCommentListAddDialogKey'),
        );
        expect(minimizeButtonFinder, findsNothing);

        // Then close the comment list dialog
        await tester.tap(
            find.byKey(const Key('playlistCommentListCloseDialogTextButton')));
        await tester.pumpAndSettle();

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });
    testWidgets(
        '''Open the app in Android similar size and select the french language. Click on the comment icon button after
           clicking on the pictured and commented audio title to open the audio player view. Then, the comment add list
           dialog is opened. Verify that the create comment is usable to add a new comment. Since the french translation
           of 'Comments' is 'Commentaires' which requests more space than the english one, the comment add button was
           not clickable before this bug was fixed. This test is verify that the bug is fixed.''',
        (WidgetTester tester) async {
      const String youtubePlaylistTitle = 'Jésus-Christ';
      const String audioAlreadyUsingPictureTitle =
          'NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_picture_test',
        selectedPlaylistTitle: youtubePlaylistTitle,
        tapOnPlaylistToggleButton: false,
        setAppSizeToAndroidSize: true,
      );

      // First, set the application language to French
      await IntegrationTestUtil.setApplicationLanguage(
        tester: tester,
        language: Language.french,
      );

      // Go to the audio player view
      final Finder audioForPictureTitleListTileTextWidgetFinder =
          find.text(audioAlreadyUsingPictureTitle);

      await tester.tap(audioForPictureTitleListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Tap on the comment icon button to open the comment list add
      // dialog

      Finder commentInkWellButtonFinder = find.byKey(
        const Key('commentsInkWellButton'),
      );

      await tester.tap(commentInkWellButtonFinder);
      await tester.pumpAndSettle();

      // Tap on the Add comment icon button to open the add edit comment
      // dialog
      await tester
          .tap(find.byKey(const Key('addPositionedCommentIconButtonKey')));
      await tester.pumpAndSettle();

      // Enter comment title text
      String commentTitle = 'New comment';
      final Finder textFieldFinder =
          find.byKey(const Key('commentTitleTextField'));

      await tester.enterText(
        textFieldFinder,
        commentTitle,
      );
      await tester.pumpAndSettle();

      // Enter comment text
      String commentText = 'New comment description';
      final Finder commentContentTextFieldFinder =
          find.byKey(const Key('commentContentTextField'));

      await tester.enterText(
        commentContentTextFieldFinder,
        commentText,
      );
      await tester.pumpAndSettle();

      // Tap on the add/edit comment button to save the comment

      final Finder addOrUpdateCommentTextButton =
          find.byKey(const Key('addOrUpdateCommentTextButton'));
      await tester.tap(addOrUpdateCommentTextButton);
      await tester.pumpAndSettle();

      // Verify that the comment list dialog now displays the
      // added comment

      final Finder commentListDialogFinder = find.byType(CommentListAddDialog);

      List<String> expectedTitles = [
        'New comment',
        '7ème leçon: rempli ton coeur de gratitude pour éteindre la colère',
        'Till end', // created comment
      ];

      List<String> expectedContents = [
        'New comment description', // created comment
        "Jusqu'à la fin.",
        '',
      ];

      List<String> expectedStartPositions = [
        '14:16', // created comment
        '23:42',
        '24:04',
      ];

      List<String> expectedEndPositions = [
        '14:16', // created comment
        '23:46',
        '24:08',
      ];

      List<String> expectedCreationDates = [
        frenchDateFormatYy.format(DateTime.now()), // created comment
        '13/12/24',
        '01/04/25',
      ];

      List<String> expectedUpdateDates = [
        '', // created comment
        '01/04/25',
        '',
      ];

      // Verify content of each list item
      IntegrationTestUtil.verifyCommentsInCommentListDialog(
          tester: tester,
          commentListDialogFinder: commentListDialogFinder,
          commentsNumber: 3,
          expectedTitlesLst: expectedTitles,
          expectedContentsLst: expectedContents,
          expectedStartPositionsLst: expectedStartPositions,
          expectedEndPositionsLst: expectedEndPositions,
          expectedCreationDatesLst: expectedCreationDates,
          expectedUpdateDatesLst: expectedUpdateDates);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
}

Future<void> _verifyTargetListTitles({
  required WidgetTester tester,
  required String moveOrCopyMenuKeyStr,
}) async {
  // Now we want to tap the popup menu of the Audio ListTile
  // "audio learn test short video two"

  const String movedAudioTitle = "audio learn test short video two";

  // First, find the Audio sublist ListTile Text widget
  final Finder sourceAudioListTileTextWidgetFinder = find.text(movedAudioTitle);

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

  // Now find the move or copy audio popup menu item and tap on it
  final Finder popupMoveMenuItem = find.byKey(Key(moveOrCopyMenuKeyStr));

  await tester.tap(popupMoveMenuItem);
  await tester.pumpAndSettle();

  // Verify that the target playlist list is not filtered
  // by the search sentence

  final playlistTitles = IntegrationTestUtil.getPlaylistTitlesFromDialog(
    tester: tester,
  );

  expect(
      playlistTitles,
      equals([
        'local_3',
        'local_audio_playlist_2',
        'local_two',
      ]));

  // Now find the confirm button and tap on it
  await tester.tap(find.byKey(const Key('cancelButton')));
  await tester.pumpAndSettle();
}

Future<void> _selectAndApplySortFilterParms({
  required WidgetTester tester,
  required List<String> playlistDisplayedAudioTitlesLst,
  required String sfParmsName,
  required String textFieldContentStr,
}) async {
  // Now select the 'asc listened' sort/filter item in the dropdown
  // button items list

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

  // And find the 'asc listened' sort/filter item
  final Finder titleAscDropDownTextFinder = find.text(sfParmsName).last;
  await tester.tap(titleAscDropDownTextFinder);
  await tester.pumpAndSettle();

  // Verify that the search text field content was not changed
  IntegrationTestUtil.verifyTextFieldContent(
    tester: tester,
    textFieldKeyStr: 'youtubeUrlOrSearchTextField',
    expectedTextFieldContent: textFieldContentStr,
  );

  // And verify the order of the 'asc listened' playlist audio
  // titles

  // Ensure that since the search icon button was un-pressed,
  // the displayed audio list returned to the default list.
  IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
    tester: tester,
    audioOrPlaylistTitlesOrderedLst: playlistDisplayedAudioTitlesLst,
  );
}

Future<void> _resetUnselectedPlaylistAudioQualityAndThenSelectPlaylist({
  required WidgetTester tester,
  required String playlistTitle,
  required bool isPlaylistLocal,
  required PlaylistQuality playlistQuality,
}) async {
  if (playlistQuality == PlaylistQuality.voice) {
    // Re-set the unselected MyValTest playlist audio quality
    // to spoken.
    await _tapOnSetAudioQualityMenu(
      tester: tester,
      playlistToModifyTitle: playlistTitle,
      setMusicQuality: false,
    );
  } else {
    // Re-set the unselected MyValTest playlist audio quality
    // to musical.
    await _tapOnSetAudioQualityMenu(
      tester: tester,
      playlistToModifyTitle: playlistTitle,
      setMusicQuality: true,
    );
  }

  // Now selecting the MyValTest playlist by tapping on the
  // playlist checkbox.
  await IntegrationTestUtil.selectPlaylist(
    tester: tester,
    playlistToSelectTitle: playlistTitle,
  );

  if (!isPlaylistLocal) {
    // Verify that the music quality checkbox is enabled
    IntegrationTestUtil.verifyWidgetIsEnabled(
      tester: tester,
      widgetKeyStr: 'audio_quality_checkbox',
    );
  } else {
    // Verify that the music quality checkbox is disabled
    await IntegrationTestUtil.verifyWidgetIsDisabled(
      tester: tester,
      widgetKeyStr: 'audio_quality_checkbox',
    );
  }

  Finder downloadAtMusicalQualityCheckBoxFinder =
      find.byKey(const Key('audio_quality_checkbox'));
  Checkbox downloadAtMusicalQualityCheckBoxWidget =
      tester.widget<Checkbox>(downloadAtMusicalQualityCheckBoxFinder);

  if (playlistQuality == PlaylistQuality.voice) {
    expect(downloadAtMusicalQualityCheckBoxWidget.value, false);
  } else {
    expect(downloadAtMusicalQualityCheckBoxWidget.value, true);
  }
}

Future<void> _verifyPlaylistAudioQuality({
  required WidgetTester tester,
  required String playlistTitle,
  required bool isPlaylistLocal,
  required PlaylistQuality playlistQuality,
}) async {
  if (isPlaylistLocal) {
    await IntegrationTestUtil.verifyWidgetIsDisabled(
      tester: tester,
      widgetKeyStr: 'audio_quality_checkbox',
    );
  } else {
    IntegrationTestUtil.verifyWidgetIsEnabled(
      tester: tester,
      widgetKeyStr: 'audio_quality_checkbox',
    );
  }

  Finder downloadAtMusicalQualityCheckBoxFinder =
      find.byKey(const Key('audio_quality_checkbox'));
  Checkbox downloadAtMusicalQualityCheckBoxWidget =
      tester.widget<Checkbox>(downloadAtMusicalQualityCheckBoxFinder);
  String playlistWrittenQuality;

  if (playlistQuality == PlaylistQuality.music) {
    // Verify that the download at musical quality checkbox is
    // checked
    expect(downloadAtMusicalQualityCheckBoxWidget.value, true);
    playlistWrittenQuality = 'musical';
  } else {
    // Verify that the download at musical quality checkbox is
    // unchecked
    expect(downloadAtMusicalQualityCheckBoxWidget.value, false);
    playlistWrittenQuality = 'spoken';
  }

  await IntegrationTestUtil.verifyPlaylistDataDialogContent(
    tester: tester,
    playlistTitle: playlistTitle,
    playlistDownloadAudioSortFilterParmsName: 'default',
    playlistPlayAudioSortFilterParmsName: 'default',
    playlistAudioQuality: playlistWrittenQuality,
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
  IntegrationTestUtil.verifyPlaylistIsSelected(
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

/// Returns the added [pictureFilePathName]
Future<String> _addPictureToAudioExecutingAudioListItemMenu({
  required WidgetTester tester,
  required MockFilePicker mockFilePicker,
  required String pictureFileName,
  required String pictureSourcePath,
  required int pictureFileSize,
  required String audioForPictureTitle,
}) async {
  String pictureFilePathName =
      "$pictureSourcePath${path.separator}$pictureFileName";

  mockFilePicker.setSelectedFiles([
    PlatformFile(
        name: pictureFileName,
        path: pictureFilePathName,
        size: pictureFileSize),
  ]);

  // Now we want to tap the popup menu of the Audio ListTile

  // First, find the Audio sublist ListTile Text widget
  Finder audioForPictureTitleTextWidgetFinder = find.text(audioForPictureTitle);

  // Then obtain the Audio ListTile widget enclosing the Text widget by
  // finding its ancestor
  Finder audioForPictureListTileWidgetFinder = find.ancestor(
    of: audioForPictureTitleTextWidgetFinder,
    matching: find.byType(ListTile),
  );

  // Now find the leading menu icon button of the Audio ListTile and tap
  // on it
  Finder audioForPictureListTileLeadingMenuIconButton = find.descendant(
    of: audioForPictureListTileWidgetFinder,
    matching: find.byIcon(Icons.menu),
  );

  // Tap the leading menu icon button to open the popup menu
  await tester.tap(audioForPictureListTileLeadingMenuIconButton);
  await tester.pumpAndSettle();

  // Now find the Add Picture popup menu item and tap on it
  Finder addPictureMenuItem =
      find.byKey(const Key("popup_menu_add_audio_picture"));

  await tester.tap(addPictureMenuItem);
  await tester.pumpAndSettle(const Duration(microseconds: 200));

  return pictureFilePathName;
}

/// Returns the added [pictureFilePathName]
Future<String> _addPictureToAudioExecutingAudioPlayerViewLeftAppbarMenu({
  required WidgetTester tester,
  required MockFilePicker mockFilePicker,
  required String pictureFileName,
  required String pictureSourcePath,
  required int pictureFileSize,
}) async {
  String pictureFilePathName =
      "$pictureSourcePath${path.separator}$pictureFileName";

  mockFilePicker.setSelectedFiles([
    PlatformFile(
        name: pictureFileName,
        path: pictureFilePathName,
        size: pictureFileSize),
  ]);

  // Now we want to tap on the audio player view left appbar menu

  await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
  await tester.pumpAndSettle(const Duration(milliseconds: 200));

  // Now find the Add Audio Picture popup menu item and tap on it
  Finder addPictureMenuItem =
      find.byKey(const Key("popup_menu_add_audio_picture"));

  await tester.tap(addPictureMenuItem);
  await tester.pumpAndSettle();

  return pictureFilePathName;
}

Future<void> _removeAudioPictureExecutingAudioListItemMenu({
  required WidgetTester tester,
  required String picturedAudioTitle,
}) async {
  // Tapping the popup menu of the Audio ListTile

  // First, find the Audio sublist ListTile Text widget
  Finder audioForPictureTitleTextWidgetFinder = find.text(picturedAudioTitle);

  // Then obtain the Audio ListTile widget enclosing the Text widget by
  // finding its ancestor
  Finder audioForPictureListTileWidgetFinder = find.ancestor(
    of: audioForPictureTitleTextWidgetFinder,
    matching: find.byType(ListTile),
  );

  // Now find the leading menu icon button of the Audio ListTile and tap
  // on it
  Finder audioForPictureListTileLeadingMenuIconButton = find.descendant(
    of: audioForPictureListTileWidgetFinder,
    matching: find.byIcon(Icons.menu),
  );

  // Tap the leading menu icon button to open the popup menu
  await tester.tap(audioForPictureListTileLeadingMenuIconButton);
  await tester.pumpAndSettle();

  // Find the Remove Audio Picture popup menu item and tap on it
  Finder addPictureMenuItem =
      find.byKey(const Key("popup_menu_remove_audio_picture"));

  await tester.tap(addPictureMenuItem);
  await tester.pumpAndSettle(const Duration(microseconds: 200));
}

Future<void> _removeAudioPictureInAudioPlayerView({
  required WidgetTester tester,
  required String picturedAudioTitle,
}) async {
  // Tap on the audio player view left appbar menu

  await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
  await tester.pumpAndSettle(const Duration(milliseconds: 200));

  // Now find the Remove Audio Picture popup menu item and tap on it
  Finder removePictureMenuItem =
      find.byKey(const Key("popup_menu_remove_audio_picture"));

  await tester.tap(removePictureMenuItem);
  await tester.pumpAndSettle();
}

Future<void> _changePlaylistRootPath({
  required WidgetTester tester,
  required MockFilePicker mockFilePicker,
  required String pathToSelectStr,
  required List<String> playlistTitlesInModifiedDir,
  required String expectedSettingsContent,
  required String selectedPlaylistTitle,
}) async {
  // Tap the appbar leading popup menu button
  await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
  await tester.pumpAndSettle();

  // Now open the app settings dialog
  await tester.tap(find.byKey(const Key('appBarMenuOpenSettingsDialog')));
  await tester.pumpAndSettle();

  // Select the modified dir path. Tapping on the select directory
  // icon button does not open the directory picker dialog. Instead,
  // the FilePicker mock is used to simulate the selection of the
  // directory.

  // Setting the path value returned by the FilePicker mock.
  mockFilePicker.setPathToSelect(
    pathToSelectStr: pathToSelectStr,
  );

  await tester.tap(find.byKey(const Key('openDirectoryIconButton')));
  await tester.pumpAndSettle();

  // Find the Text using the Key
  final Finder textFinder = find.byKey(const Key('playlistsRootPathText'));

  // Retrieve the Text widget
  String text = tester.widget<Text>(textFinder).data ?? '';

  // Verify the selected directory path
  expect(
    text,
    pathToSelectStr,
  );

  // And tap on save button
  await tester.tap(find.byKey(const Key('saveButton')));
  await tester.pumpAndSettle();

  // Verify the modified directory playlist titles

  IntegrationTestUtil.checkAudioOrPlaylistTitlesOrderInListTile(
    tester: tester,
    audioOrPlaylistTitlesOrderedLst: playlistTitlesInModifiedDir,
  );

  // Verify the selected playlist
  IntegrationTestUtil.verifyPlaylistIsSelected(
    tester: tester,
    playlistTitle: selectedPlaylistTitle,
  );

  // Ensure settings json file has been modified
  expect(
    File("$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName")
        .readAsStringSync(),
    expectedSettingsContent,
  );
}

Future<void> _verifyDatePickerTitleTranslation({
  required WidgetTester tester,
  required String datePickerTranslatedTitleStr,
  required String datePickerCancelButtonTranslatedStr,
}) async {
  await _openSortFilterThenDatePickerDialog(tester);

  // Verify the translated title in the DatePicker dialog
  expect(find.text(datePickerTranslatedTitleStr), findsOneWidget);

  // Now close the DatePicker dialog by tapping on the cancel button
  await tester.tap(find.text(datePickerCancelButtonTranslatedStr).last);
  await tester.pumpAndSettle();

  // Now close the audio sort filter dialog by tapping on its cancel
  // button
  await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
  await tester.pumpAndSettle();
}

Future<void> _openSortFilterThenDatePickerDialog(WidgetTester tester) async {
  // Open the audio popup menu
  await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
  await tester.pumpAndSettle();

  // Find the sort/filter audio menu item and tap on it to
  // open the audio sort filter dialog
  await tester
      .tap(find.byKey(const Key('define_sort_and_filter_audio_menu_item')));
  await tester.pumpAndSettle();

  // Now open the DatePicker dialog, but first scroll down the dialog so that
  // the date text fields are visible.

  await tester.drag(
    find.byType(AudioSortFilterDialog),
    const Offset(0, -300), // Negative value for vertical drag to scroll down
  );
  await tester.pumpAndSettle();

  // Find the DatePicker dialog icon button and tap on it to
  // open the dialog
  await tester.tap(find.byKey(const Key('startDownloadDateIconButton')));
  await tester.pumpAndSettle();
}

void _verifyEnglishInPlaylistDownloadView() {
  expect(find.text('Download Audio'), findsOneWidget);
  expect(find.text('Youtube Link or Search'), findsOneWidget);
  expect(find.text('default'), findsOneWidget);
  expect(find.text('Add'), findsOneWidget);
  expect(find.text('One'), findsOneWidget);
}

void _verifyFrenchInPlaylistDownloadView() {
  expect(find.text('Téléch. Audio'), findsOneWidget);
  expect(find.text('Lien Youtube ou recherche'), findsOneWidget);
  expect(find.text('défaut'), findsOneWidget);
  expect(find.text('Ajout'), findsOneWidget);
  expect(find.text('Un'), findsOneWidget);
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
  expect(alertDialogTitle.data, 'Select a Playlist');

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
Future<void> _onPlaylistDownloadViewCheckOrTapOnPlaylistCheckbox({
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

Future<void> _onAudioPlayerViewCheckOrTapOnPlaylistCheckbox({
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

  await IntegrationTestUtil.selectPlaylist(
    tester: tester,
    playlistToSelectTitle: playlistToSelectTitleInAudioPlayerView,
  );

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

  // Select an Audio in the AudioPlayableListDialog
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
  required String dateFormatToSelectLowCase,
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
  expect(alertDialogTitle.data, 'Select the Application Date Format');

  // Find the RadioListTile date format to select

  Finder radioListTile = find.byWidgetPredicate(
    (Widget widget) {
      return widget is RadioListTile &&
          widget.title is Text &&
          (widget.title as Text).data!.contains(dateFormatToSelectLowCase);
    },
  );

  // Tap the target dateformat RadioListTile to select it
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
  required String datePickerDateStr,
}) async {
  IntegrationTestUtil.checkAudioSubTitlesOrderInListTile(
    tester: tester,
    audioSubTitlesOrderLst: audioSubTitles,
  );

  // Now we want to tap the popup menu of the Audio ListTile
  // "Jancovici m'explique l’importance des ordres de grandeur
  // face au changement climatique",

  const String audioTitle =
      "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique";

  // First, find the Audio sublist ListTile Text widget
  Finder targetAudioListTileTextWidgetFinder = find.text(audioTitle);

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

  // Now find the close button of the audio info dialog
  // and tap on it
  await tester.tap(find.byKey(const Key('audio_info_close_button_key')));
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
  targetAudioListTileTextWidgetFinder = find.text(audioTitle);

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

  // Now verify the date picker date format usage in the
  // start download date field

  await _openSortFilterThenDatePickerDialog(tester);

  // Confirm the date picker dialog
  final Finder confirmButton = find.text('OK');
  await tester.tap(confirmButton);
  await tester.pumpAndSettle();

  // Verify the set date displayed in the start download date text
  // field
  final Finder selectedDateText =
      find.byKey(const Key('startDownloadDateTextField'));
  expect(
    tester.widget<TextField>(selectedDateText).controller!.text,
    datePickerDateStr,
  );

  // Now close the audio sort filter dialog by tapping on its cancel
  // button
  await tester.tap(find.byKey(const Key('cancelSortFilterButton')));
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

  // And select the sortFilterParms sort/filter item
  final Finder titleAscDropDownTextFinder = find.text(sortFilterParms);
  await tester.tap(titleAscDropDownTextFinder);
  await tester.pumpAndSettle();

  // Verify the audio sub-titles order in the list tile which correspond
  // to the sortFilterParms sort order selected parms
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
  int audioRewindedNumber = 1,
}) async {
  // Now play then pause audioToPlayTitle

  Finder audioToPlayTitleFinder = find.text(audioToPlayTitle);

  // This opens the play audio view
  await tester.tap(audioToPlayTitleFinder);
  await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
    tester: tester,
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
    // Tap the 'Toggle List' button to display the list of playlist's.
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
    numberOfRewindedAudio: audioRewindedNumber,
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

  await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
    tester: tester,
    warningDialogMessage:
        "$numberOfRewindedAudio playlist audio's were repositioned to start.",
    isWarningConfirming: true,
  );
}

Future<void> _tapOnSetAudioQualityMenu({
  required WidgetTester tester,
  required String playlistToModifyTitle,
  required bool setMusicQuality, // true: set music quality,
  //                                 false: set spoken quality
}) async {
  // Find the playlist to rewind audio ListTile

  // First, find the Playlist ListTile Text widget
  final Finder playlistToModifyListTileTextWidgetFinder =
      find.text(playlistToModifyTitle);

  // Then obtain the Playlist ListTile widget enclosing the Text widget
  // by finding its ancestor
  final Finder playlistToModifyListTileWidgetFinder = find.ancestor(
    of: playlistToModifyListTileTextWidgetFinder,
    matching: find.byType(ListTile),
  );

  // Now test changing the playlist audio quality

  // Find the playlist leading menu icon button
  final Finder playlistToModifyListTileLeadingMenuIconButton = find.descendant(
    of: playlistToModifyListTileWidgetFinder,
    matching: find.byIcon(Icons.menu),
  );

  // Tap the leading menu icon button to open the popup menu
  await tester.tap(playlistToModifyListTileLeadingMenuIconButton);
  await tester.pumpAndSettle();

  // Now find the 'Set Audio Quality ...' playlist popup menu item
  // and tap on it
  final Finder setAudioQualityPlaylistMenuItem =
      find.byKey(const Key("popup_menu_set_audio_quality"));

  await tester.tap(setAudioQualityPlaylistMenuItem);
  await tester.pumpAndSettle(const Duration(milliseconds: 200));

  // Check the value of the AlertDialog dialog title
  Text alertDialogTitle =
      tester.widget(find.byKey(const Key('setValueToTargetDialogTitleKey')));
  expect(alertDialogTitle.data, 'Playlist Audio Quality');

  // Check the value of the AlertDialog dialog text
  Text alertDialogText =
      tester.widget(find.byKey(const Key('setValueToTargetDialogKey')));
  expect(alertDialogText.data, 'Select audio quality');

  if (setMusicQuality) {
    // Tap on the 'musical' quality checkbox to select it
    await tester.tap(find.byKey(const Key('checkbox_1_key')));
    await tester.pumpAndSettle();
  } else {
    // Tap on the 'spoken' quality checkbox to select it
    await tester.tap(find.byKey(const Key('checkbox_0_key')));
    await tester.pumpAndSettle();
  }

  // And click on the 'OK' button to confirm the selection
  await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
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
    "La résilience insulaire par Fiona Roche",
    "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
    "Les besoins artificiels par R.Keucheyan",
    "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
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
    'al',
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
    "local",
    "local_2",
  ];

  IntegrationTestUtil.checkPlaylistAndAudioTitlesOrderInListTile(
    tester: tester,
    playlistTitlesOrderedLst: playlistsTitles,
    audioTitlesOrderedLst: audioTitles,
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

Future<void> _executeSearchWordScrollTest({
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
  await _onPlaylistDownloadViewCheckOrTapOnPlaylistCheckbox(
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
  await _onPlaylistDownloadViewCheckOrTapOnPlaylistCheckbox(
    tester: tester,
    playlistToSelectTitle: playlistTitle,
    verifyIfCheckboxIsChecked: true,
    tapOnCheckbox: false,
  );
}

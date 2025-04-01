// ignore_for_file: avoid_print

import 'package:audiolearn/viewmodels/audio_player_vm.dart';
import 'package:audiolearn/viewmodels/comment_vm.dart';
import 'package:audiolearn/viewmodels/date_format_vm.dart';
import 'package:audiolearn/viewmodels/picture_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as path;

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/playlist_list_vm.dart';
import 'package:audiolearn/viewmodels/language_provider_vm.dart';
import 'package:audiolearn/viewmodels/theme_provider_vm.dart';
import 'package:audiolearn/viewmodels/warning_message_vm.dart';
import 'package:audiolearn/views/playlist_download_view.dart';
import '../services/mock_shared_preferences.dart';
import '../viewmodels/mock_app_localizations.dart';

class MockAppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return MockAppLocalizations();
  }

  @override
  bool shouldReload(MockAppLocalizationsDelegate old) => false;
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
      'Testing expandable playlist list located in PlaylistDownloadView functions',
      () {
    testWidgets(
        'should render ListView widget, not using MyApp but ListView widget',
        (WidgetTester tester) async {
      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      expect(find.byType(PlaylistDownloadView), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });

    // I don't know why next tests are no longer executable
    testWidgets('should toggle list on press', (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_expandable_4_playlists_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
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
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pumpAndSettle();

      final Finder listTileFinder = find.byType(ListTile);
      expect(listTileFinder, findsWidgets);

      final List<Widget> listTileLst =
          tester.widgetList(listTileFinder).toList();
      expect(listTileLst.length, 4);

      // hidding the list
      await tester.tap(toggleButtonFinder);
      await tester.pumpAndSettle();

      expect(listTileFinder, findsNothing);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });

    testWidgets('check buttons enabled after item selected',
        (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_expandable_7_playlists_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
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
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      final Finder listItemFinder = find.byType(ListTile).first;
      await tester.tap(listItemFinder);
      await tester.pump();

      // The Delete button does not exist on the
      // ExpandableListView.
      // testing that the Delete button is disabled
      // Finder deleteButtonFinder = find.byKey(const ValueKey('delete_button'));
      // expect(deleteButtonFinder, findsOneWidget);
      // expect(
      //     tester.widget<TextButton>(deleteButtonFinder).enabled, isFalse);

      // testing that the up and down buttons are disabled

      Finder widgetWithIconFinder =
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up);

      if (widgetWithIconFinder.evaluate().isNotEmpty) {
        IconButton upButton = tester.widget<IconButton>(widgetWithIconFinder);
        expect(upButton.onPressed, isNull);

        IconButton downButton = tester.widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.arrow_drop_down));
        expect(downButton.onPressed, isNull);
      }

      // Verify that the first ListTile checkbox is not
      // selected
      Checkbox firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isFalse);

      // Tap the first ListTile checkbox to select it
      await tester.tap(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      await tester.pumpAndSettle();

      // Verify that the first ListTile checkbox is now
      // selected. The check box must be obtained again
      // since the widget has been recreated !
      firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isTrue);

      // Verify that the up and down buttons are now enabled.
      // The Up and Down buttons must be obtained again
      // since the widget has been recreated !
      IconButton upButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up));
      expect(upButton.onPressed, isNotNull);

      IconButton downButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_down));
      expect(downButton.onPressed, isNotNull);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });

    testWidgets(
        'check checkbox remains selected after toggling list up and down',
        (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_expandable_7_playlists_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
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
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      final Finder listItemFinder = find.byType(ListTile).first;
      await tester.tap(listItemFinder);
      await tester.pump();

      // Tap the first ListTile checkbox to select it
      await tester.tap(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      await tester.pump();

      // Verify that the first ListTile checkbox is now
      // selected. The check box must be obtained again
      // since the widget has been recreated !
      Checkbox firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isTrue);

      // hidding the list
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      // The Delete button does not exist on the
      // ExpandableListView.
      // testing that the Delete button is disabled
      // Finder deleteButtonFinder = find.byKey(const ValueKey('Delete'));
      // expect(deleteButtonFinder, findsOneWidget);
      // expect(
      //     tester.widget<TextButton>(deleteButtonFinder).enabled, isFalse);

      // testing that the up and down buttons are disabled

      Finder widgetWithIconFinder =
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up);

      if (widgetWithIconFinder.evaluate().isNotEmpty) {
        IconButton upButton = tester.widget<IconButton>(widgetWithIconFinder);
        expect(upButton.onPressed, isNull);

        IconButton downButton = tester.widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.arrow_drop_down));
        expect(downButton.onPressed, isNull);
      }

      // redisplaying the list
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      // The Delete button does not exist on the
      // ExpandableListView.
      // Verify that the Delete button is now enabled.
      // The Delete button must be obtained again
      // since the widget has been recreated !
      // expect(
      //   tester.widget<TextButton>(
      //       find.widgetWithText(TextButton, 'Delete')),
      //   isA<TextButton>().having((b) => b.enabled, 'enabled', true),
      // );

      // Verify that the up and down buttons are now enabled.
      // The Up and Down buttons must be obtained again
      // since the widget has been recreated !
      IconButton upButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up));
      expect(upButton.onPressed, isNotNull);

      IconButton downButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_down));
      expect(downButton.onPressed, isNotNull);

      // Verify that the first ListTile checkbox is always
      // selected. The check box must be obtained again
      // since the widget has been recreated !
      firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isTrue);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });

    testWidgets('check buttons disabled after item unselected',
        (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_expandable_7_playlists_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
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
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      final Finder listItemFinder = find.byType(ListTile).first;
      await tester.tap(listItemFinder);
      await tester.pump();

      // Verify that the first ListTile checkbox is not
      // selected
      Checkbox firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isFalse);

      // Tap the first ListTile checkbox to select it
      await tester.tap(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      await tester.pump();

      // Verify that the first ListTile checkbox is now
      // selected. The check box must be obtained again
      // since the widget has been recreated !
      firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isTrue);

      // The Delete button does not exist on the
      // ExpandableListView.
      // Verify that the Delete button is now enabled.
      // The Delete button must be obtained again
      // since the widget has been recreated !
      // expect(
      //   tester.widget<TextButton>(
      //       find.widgetWithText(TextButton, 'Delete')),
      //   isA<TextButton>().having((b) => b.enabled, 'enabled', true),
      // );

      // Verify that the up and down buttons are now enabled.
      // The Up and Down buttons must be obtained again
      // since the widget has been recreated !

      Finder widgetWithIconFinder =
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up);

      if (widgetWithIconFinder.evaluate().isNotEmpty) {
        IconButton upButton = tester.widget<IconButton>(widgetWithIconFinder);
        expect(upButton.onPressed, isNotNull);

        IconButton downButton = tester.widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.arrow_drop_down));
        expect(downButton.onPressed, isNotNull);
      }

      // Retap the first ListTile checkbox to unselect it
      await tester.tap(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      await tester.pump();

      // Verify that the first ListTile checkbox is now
      // unselected. The check box must be obtained again
      // since the widget has been recreated !
      firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isFalse);

      // The Delete button does not exist on the
      // ExpandableListView.
      // testing that the Delete button is now disabled
      // Finder deleteButtonFinder = find.byKey(const ValueKey('Delete'));
      // expect(deleteButtonFinder, findsOneWidget);
      // expect(
      //     tester.widget<TextButton>(deleteButtonFinder).enabled, isFalse);

      // testing that the up and down buttons are now disabled

      widgetWithIconFinder =
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up);

      if (widgetWithIconFinder.evaluate().isNotEmpty) {
        IconButton upButton = tester.widget<IconButton>(widgetWithIconFinder);
        expect(upButton.onPressed, isNull);

        IconButton downButton = tester.widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.arrow_drop_down));
        expect(downButton.onPressed, isNull);
      }

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });

    testWidgets('ensure only one checkbox is selectable',
        (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_expandable_7_playlists_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
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
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      // final Finder listItem = find.byType(ListTile).first;
      // await tester.tap(listItem);
      // await tester.pump();

      // Verify that the first ListTile checkbox is not
      // selected
      Checkbox firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isFalse);

      // Tap the first ListTile checkbox to select it
      await tester.tap(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      await tester.pump();

      // Verify that the first ListTile checkbox is now
      // selected. The check box must be obtained again
      // since the widget has been recreated !
      firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isTrue);

      // Find and select the ListTile with text 'local_audio_playlist_4'
      String itemTextStr = 'local_audio_playlist_4';
      await findThenSelectAndTestListTileCheckbox(
        tester: tester,
        itemTextStr: itemTextStr,
      );

      // Verify that the first ListTile checkbox is no longer
      // selected. The check box must be obtained again
      // since the widget has been recreated !
      firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isFalse);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });

    // The Delete button does not exist on the
    // ExpandableListView.
    // testWidgets('select and delete item', (WidgetTester tester) async {
    // SettingsDataService settingsDataService = SettingsDataService(
    //
    // );

    //   // Load the settings from the json file. This is necessary
    //   // otherwise the ordered playlist titles will remain empty
    //   // and the playlist list will not be filled with the
    //   // playlists available in the download app test dir
    //   await settingsDataService.loadSettingsFromFile(
    //       jsonPathFileName:
    //           "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

    //   WarningMessageVM warningMessageVM = WarningMessageVM();
    //   AudioDownloadVM audioDownloadVM = AudioDownloadVM(
    // warningMessageVM:  warningMessageVM,
    //
    //   );

    //   await createWidget(
    //     tester: tester,
    //     warningMessageVM: warningMessageVM,
    //     audioDownloadVM: audioDownloadVM,
    //     settingsDataService: settingsDataService,
    //   );

    //   // displaying the list
    //   final Finder toggleButtonFinder =
    //       find.byKey(const ValueKey('playlist_toggle_button'));
    //   await tester.tap(toggleButtonFinder);
    //   await tester.pump();

    //   Finder listViewFinder = find.byType(ExpandablePlaylistListView);

    //   // tester.element(listViewFinder) returns a StatefulElement
    //   // which is a BuildContext
    //   ExpandablePlaylistListVM listViewModel =
    //       Provider.of<ExpandablePlaylistListVM>(tester.element(listViewFinder),
    //           listen: false);
    //   expect(listViewModel.getUpToDateSelectablePlaylists().length, 7);

    //   // Verify that the Delete button is disabled
    //   expect(find.text('Delete'), findsOneWidget);
    //   expect(find.widgetWithText(TextButton, 'Delete'), findsOneWidget);
    //   expect(
    //     tester.widget<TextButton>(
    //         find.widgetWithText(TextButton, 'Delete')),
    //     isA<TextButton>().having((b) => b.enabled, 'enabled', false),
    //   );

    //   // Find and select the ListTile item to delete
    //   const String itemToDeleteTextStr = 'local_audio_playlist_3';

    //   await findSelectAndTestListTileCheckbox(
    //     tester: tester,
    //     itemTextStr: itemToDeleteTextStr,
    //   );

    //   // Verify that the Delete button is now enabled
    //   expect(
    //     tester.widget<TextButton>(
    //         find.widgetWithText(TextButton, 'Delete')),
    //     isA<TextButton>().having((b) => b.enabled, 'enabled', true),
    //   );

    //   // Tap the Delete button
    //   await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    //   await tester.pump();

    //   // Verify that the item was deleted by checking that
    //   // the ListViewModel.items getter return a list whose
    //   // length is 10 minus 1 and secondly verify that
    //   // the deleted ListTile is no longer displayed.

    //   listViewFinder = find.byType(ExpandablePlaylistListView);

    //   // tester.element(listViewFinder) returns a StatefulElement
    //   // which is a BuildContext
    //   listViewModel = Provider.of<ExpandablePlaylistListVM>(
    //       tester.element(listViewFinder),
    //       listen: false);
    //   expect(listViewModel.getUpToDateSelectablePlaylists().length, 6);

    //   expect(find.widgetWithText(ListTile, itemToDeleteTextStr), findsNothing);
    // });

    testWidgets('select and move down item', (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_expandable_7_playlists_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
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
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      Finder listViewFinder = find.byType(PlaylistDownloadView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      PlaylistListVM listViewModel = Provider.of<PlaylistListVM>(
          tester.element(listViewFinder),
          listen: false);
      expect(listViewModel.getUpToDateSelectablePlaylists().length, 7);

      // Find and select the ListTile to move'
      const String playlistToSelectTitle = 'local_audio_playlist_2';

      await findThenSelectAndTestListTileCheckbox(
        tester: tester,
        itemTextStr: playlistToSelectTitle,
      );

      // Verify that the move buttons are enabled
      IconButton upButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up));
      expect(upButton.onPressed, isNotNull);

      Finder downIconButtonFinder =
          find.widgetWithIcon(IconButton, Icons.arrow_drop_down);
      IconButton downButton = tester.widget<IconButton>(downIconButtonFinder);
      expect(downButton.onPressed, isNotNull);

      // Tap the move down button
      await tester.tap(downIconButtonFinder);
      await tester.pump();

      listViewFinder = find.byType(PlaylistDownloadView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      listViewModel = Provider.of<PlaylistListVM>(
          tester.element(listViewFinder),
          listen: false);
      expect(listViewModel.getUpToDateSelectablePlaylists()[1].title,
          'local_audio_playlist_3');
      expect(listViewModel.getUpToDateSelectablePlaylists()[2].title,
          'local_audio_playlist_2');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });

    testWidgets('select and move down twice before last item',
        (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_expandable_4_playlists_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
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
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      Finder listViewFinder = find.byType(PlaylistDownloadView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      PlaylistListVM listViewModel = Provider.of<PlaylistListVM>(
          tester.element(listViewFinder),
          listen: false);
      expect(listViewModel.getUpToDateSelectablePlaylists().length, 4);

      // Find and select the ListTile to move'
      const String itemToMoveTitle = 'local_audio_playlist_2';

      await findThenSelectAndTestListTileCheckbox(
        tester: tester,
        itemTextStr: itemToMoveTitle,
      );

      // Verify that the move buttons are enabled
      IconButton upButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up));
      expect(upButton.onPressed, isNotNull);

      Finder dowButtonFinder =
          find.widgetWithIcon(IconButton, Icons.arrow_drop_down);
      IconButton downButton = tester.widget<IconButton>(dowButtonFinder);
      expect(downButton.onPressed, isNotNull);

      // Tap the move down button twice
      await tester.tap(dowButtonFinder);
      await tester.pump();
      await tester.tap(dowButtonFinder);
      await tester.pump();

      listViewFinder = find.byType(PlaylistDownloadView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      listViewModel = Provider.of<PlaylistListVM>(
          tester.element(listViewFinder),
          listen: false);
      expect(listViewModel.getUpToDateSelectablePlaylists()[0].title,
          'local_audio_playlist_1');
      expect(listViewModel.getUpToDateSelectablePlaylists()[3].title,
          'local_audio_playlist_2');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    testWidgets('select and move down twice over last item',
        (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_expandable_4_playlists_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
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
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      Finder listViewFinder = find.byType(PlaylistDownloadView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      PlaylistListVM listViewModel = Provider.of<PlaylistListVM>(
          tester.element(listViewFinder),
          listen: false);
      expect(listViewModel.getUpToDateSelectablePlaylists().length, 4);

      // Find and select the ListTile to move'
      const String itemToMoveTitle = 'local_audio_playlist_3';

      await findThenSelectAndTestListTileCheckbox(
        tester: tester,
        itemTextStr: itemToMoveTitle,
      );

      // Verify that the move buttons are enabled
      IconButton upButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up));
      expect(upButton.onPressed, isNotNull);

      Finder dowButtonFinder =
          find.widgetWithIcon(IconButton, Icons.arrow_drop_down);
      IconButton downButton = tester.widget<IconButton>(dowButtonFinder);
      expect(downButton.onPressed, isNotNull);

      // Tap the move down button twice
      await tester.tap(dowButtonFinder);
      await tester.pump();
      await tester.tap(dowButtonFinder);
      await tester.pump();

      listViewFinder = find.byType(PlaylistDownloadView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      listViewModel = Provider.of<PlaylistListVM>(
          tester.element(listViewFinder),
          listen: false);
      expect(listViewModel.getUpToDateSelectablePlaylists()[0].title,
          'local_audio_playlist_3');
      expect(listViewModel.getUpToDateSelectablePlaylists()[3].title,
          'local_audio_playlist_4');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });

    testWidgets('select and move up item', (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_expandable_7_playlists_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
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
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pumpAndSettle();

      Finder listViewFinder = find.byType(PlaylistDownloadView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      PlaylistListVM listViewModel = Provider.of<PlaylistListVM>(
          tester.element(listViewFinder),
          listen: false);
      expect(listViewModel.getUpToDateSelectablePlaylists().length, 7);

      // Find and select the ListTile to move'
      const String itemToMoveTextStr = 'local_audio_playlist_4';

      await findThenSelectAndTestListTileCheckbox(
        tester: tester,
        itemTextStr: itemToMoveTextStr,
      );

      // Verify that the move buttons are enabled
      Finder upButtonFinder =
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up);
      IconButton upButton = tester.widget<IconButton>(upButtonFinder);
      expect(upButton.onPressed, isNotNull);

      IconButton downButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_down));
      expect(downButton.onPressed, isNotNull);

      // Tap the move up button
      await tester.tap(upButtonFinder);
      await tester.pump();

      listViewFinder = find.byType(PlaylistDownloadView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      listViewModel = Provider.of<PlaylistListVM>(
          tester.element(listViewFinder),
          listen: false);
      expect(listViewModel.getUpToDateSelectablePlaylists()[2].title,
          'local_audio_playlist_4');
      expect(listViewModel.getUpToDateSelectablePlaylists()[3].title,
          'local_audio_playlist_3');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });

    testWidgets('select and move up twice first item',
        (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_expandable_7_playlists_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
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
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      Finder listViewFinder = find.byType(PlaylistDownloadView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      PlaylistListVM listViewModel = Provider.of<PlaylistListVM>(
          tester.element(listViewFinder),
          listen: false);
      expect(listViewModel.getUpToDateSelectablePlaylists().length, 7);

      // Find and select the ListTile to move'
      const String itemToMoveTitle = 'local_audio_playlist_1';

      await findThenSelectAndTestListTileCheckbox(
        tester: tester,
        itemTextStr: itemToMoveTitle,
      );

      // Verify that the move buttons are enabled
      Finder upButtonFinder =
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up);
      IconButton upButton = tester.widget<IconButton>(upButtonFinder);
      expect(upButton.onPressed, isNotNull);

      IconButton downButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_down));
      expect(downButton.onPressed, isNotNull);

      // Tap twice the move up button
      await tester.tap(upButtonFinder);
      await tester.pump();
      await tester.tap(upButtonFinder);
      await tester.pump();

      listViewFinder = find.byType(PlaylistDownloadView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      listViewModel = Provider.of<PlaylistListVM>(
          tester.element(listViewFinder),
          listen: false);
      expect(listViewModel.getUpToDateSelectablePlaylists()[0].title,
          'local_audio_playlist_2');
      expect(listViewModel.getUpToDateSelectablePlaylists()[5].title,
          'local_audio_playlist_1');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
}

/// This constructor instanciates the [PlaylistDownloadView]
/// with the [MockPlaylistListVM]
Future<void> _createPlaylistDownloadView({
  required WidgetTester tester,
  required AudioDownloadVM audioDownloadVM,
  required SettingsDataService settingsDataService,
  required WarningMessageVM warningMessageVM,
}) async {
  // Setting the max width of the dropdown button to 315,
  // otherwise the test will fail because the width of
  // the dropdown button is set to 140 in constants.dart
  kDropdownButtonMaxWidth = 315;
  final PlaylistListVM playlistListVM = PlaylistListVM(
    warningMessageVM: warningMessageVM,
    audioDownloadVM: audioDownloadVM,
    commentVM: CommentVM(),
    pictureVM: PictureVM(),
    settingsDataService: settingsDataService,
  );
  final CommentVM commentVM = CommentVM();

  // necessary so that the playlist list of the
  // PlaylistListVM is filled. Otherwise, the
  // playlist list is empty and the
  // ExpandablePlaylistListView is not displayed,
  // which causes the tests to fail
  playlistListVM.getUpToDateSelectablePlaylists();

  final AudioPlayerVM audioPlayerVM = AudioPlayerVM(
    settingsDataService: settingsDataService,
    playlistListVM: playlistListVM,
    commentVM: commentVM,
  );

  final DateFormatVM dateFormatVM = DateFormatVM(
    settingsDataService: settingsDataService,
  );

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PlaylistListVM>(
          create: (_) => playlistListVM,
        ),
        ChangeNotifierProvider(create: (_) => audioDownloadVM),
        ChangeNotifierProvider(
          create: (_) => ThemeProviderVM(
            appSettings: settingsDataService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LanguageProviderVM(
            settingsDataService: settingsDataService,
          ),
        ),
        ChangeNotifierProvider(create: (_) => warningMessageVM),
        ChangeNotifierProvider(create: (_) => audioPlayerVM),
        ChangeNotifierProvider(create: (_) => dateFormatVM),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          MockAppLocalizationsDelegate(),
        ],
        home: Scaffold(
          body: PlaylistDownloadView(
            settingsDataService: settingsDataService,
            onPageChangedFunction: changePage,
          ),
        ),
      ),
    ),
  );

  // necessary, otherwise test not working
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

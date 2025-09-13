import 'dart:convert';
import 'dart:io';
import 'package:audiolearn/l10n/app_localizations.dart';
import 'package:audiolearn/models/picture.dart';
import 'package:audiolearn/viewmodels/picture_vm.dart';
import 'package:audiolearn/views/my_home_page.dart';
import 'package:audiolearn/views/widgets/audio_info_dialog.dart';
import 'package:audiolearn/views/widgets/playlist_comment_list_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:window_size/window_size.dart';
import 'package:yaml/yaml.dart';

import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/services/json_data_service.dart';
import 'package:audiolearn/utils/date_time_util.dart';
import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/audio_player_vm.dart';
import 'package:audiolearn/viewmodels/comment_vm.dart';
import 'package:audiolearn/viewmodels/date_format_vm.dart';
import 'package:audiolearn/viewmodels/language_provider_vm.dart';
import 'package:audiolearn/viewmodels/playlist_list_vm.dart';
import 'package:audiolearn/viewmodels/theme_provider_vm.dart';
import 'package:audiolearn/viewmodels/warning_message_vm.dart';
import 'package:audiolearn/views/screen_mixin.dart';
import 'package:audiolearn/views/widgets/audio_playable_list_dialog.dart';
import 'package:audiolearn/views/widgets/warning_message_display.dart';
import 'package:flutter/material.dart';
import 'package:audiolearn/constants.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:audiolearn/main.dart' as app;

enum SearchIconButtonState {
  disabled,
  enabledInactive,
  enabledActive,
}

class IntegrationTestUtil {
  static const Color fullyPlayedAudioTitleColor = kSliderThumbColorInDarkMode;
  static const Color currentlyPlayingAudioTitleTextColor = Colors.white;
  static const Color currentlyPlayingAudioTitleTextBackgroundColor =
      Colors.blue;
  static const Color unplayedAudioTitleTextColor = Colors.white;
  static const Color partiallyPlayedAudioTitleTextdColor = Colors.blue;
  static String audioplayersVersion = '';

  /// This method is necessary due to replacing audioplayers 5.2.1 by
  /// audioplayers 6.1.0 or next.
  static Future<void> pumpAndSettleDueToAudioPlayers({
    required WidgetTester tester,
    int additionalMilliseconds = 0,
  }) async {
    if (audioplayersVersion == '') {
      audioplayersVersion = await getAudioplayersVersion();
    }

    if (audioplayersVersion != '^5.2.1') {
      await tester.pumpAndSettle(
        Duration(
          milliseconds: 1200 + additionalMilliseconds,
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
    } else {
      await tester.pumpAndSettle(
        Duration(
          // milliseconds: 200 + additionalMilliseconds,
          milliseconds:
              1700, // 1500 as well as only 200 no longer work 10/2/2025
        ),
      );
    }
  }

  static Future<String> getAudioplayersVersion() async {
    // Path to the pubspec.yaml file
    final file = File('pubspec.yaml');

    // Check if the file exists
    if (await file.exists()) {
      // Read the content of pubspec.yaml
      final content = await file.readAsString();

      // Load YAML content
      final yamlMap = loadYaml(content) as YamlMap;

      // Access the dependencies section
      final dependencies = yamlMap['dependencies'] as YamlMap;

      // Get the audioplayers version
      return dependencies['audioplayers'];
    } else {
      return '';
    }
  }

  /// Verify that the position displayed in the {textWidgetFinder} text
  /// widget is between - or equal to - the minimum and maximum position
  /// time strings.
  static void verifyPositionBetweenMinMax({
    required WidgetTester tester,
    required final Finder textWidgetFinder,
    required String minPositionTimeStr,
    required String maxPositionTimeStr,
  }) {
    String actualPositionTimeString =
        tester.widget<Text>(textWidgetFinder).data!;
    int actualPositionTenthOfSeconds = DateTimeUtil.convertToTenthsOfSeconds(
      timeString: actualPositionTimeString,
    );

    int expectedMinPositionTenthSeconds =
        DateTimeUtil.convertToTenthsOfSeconds(timeString: minPositionTimeStr);
    int expectedMaxPositionTenthSeconds =
        DateTimeUtil.convertToTenthsOfSeconds(timeString: maxPositionTimeStr);

    IntegrationTestUtil.expectWithSuccessMessage(
      actual: actualPositionTenthOfSeconds,
      matcher: allOf(
        [
          greaterThanOrEqualTo(expectedMinPositionTenthSeconds),
          lessThanOrEqualTo(expectedMaxPositionTenthSeconds),
        ],
      ),
      reason:
          "Expected value between $expectedMinPositionTenthSeconds and $expectedMaxPositionTenthSeconds but obtained $actualPositionTenthOfSeconds",
      successMessage:
          "Acceptable position between $minPositionTimeStr and $maxPositionTimeStr is $actualPositionTimeString",
    );
  }

  /// Verify that the position displayed in the {textWidgetFinder} text
  /// widget is between - or equal to - the minimum and maximum position
  /// time strings.
  static void verifyPositionWithAcceptableDifferenceSeconds({
    required WidgetTester tester,
    required String actualPositionTimeStr,
    required String expectedPositionTimeStr,
    required int plusMinusSeconds,
  }) {
    int actualPositionTenthOfSeconds = DateTimeUtil.convertToTenthsOfSeconds(
      timeString: actualPositionTimeStr,
    );

    int convertedBasePositionToTenthsOfSeconds =
        DateTimeUtil.convertToTenthsOfSeconds(
            timeString: expectedPositionTimeStr);
    int expectedMinPositionTenthSeconds =
        convertedBasePositionToTenthsOfSeconds - plusMinusSeconds * 10;
    int expectedMaxPositionTenthSeconds =
        convertedBasePositionToTenthsOfSeconds + plusMinusSeconds * 10;

    IntegrationTestUtil.expectWithSuccessMessage(
      actual: actualPositionTenthOfSeconds,
      matcher: allOf(
        [
          greaterThanOrEqualTo(expectedMinPositionTenthSeconds),
          lessThanOrEqualTo(expectedMaxPositionTenthSeconds),
        ],
      ),
      reason:
          "Expected value between $expectedMinPositionTenthSeconds and $expectedMaxPositionTenthSeconds but obtained $actualPositionTenthOfSeconds",
    );
  }

  static Future<void> typeOnPlaylistMenuItem({
    required WidgetTester tester,
    required String playlistTitle,
    required String playlistMenuKeyStr,
    bool dragToBottom = false,
  }) async {
    // Now find the leading menu icon button of the Playlist ListTile
    // and tap on it

    // First, find the playlist ListTile Text widget
    final Finder playlistListTileTextWidgetFinder = find.text(playlistTitle);

    // Then obtain the source playlist ListTile widget enclosing the
    // Text widget by finding its ancestor
    final Finder playlistListTileWidgetFinder = find.ancestor(
      of: playlistListTileTextWidgetFinder,
      matching: find.byType(ListTile),
    );

    final Finder firstPlaylistListTileLeadingMenuIconButton = find.descendant(
      of: playlistListTileWidgetFinder,
      matching: find.byIcon(Icons.menu),
    );

    // Tap the leading menu icon button to open the popup menu
    await tester.tap(firstPlaylistListTileLeadingMenuIconButton);
    await tester.pumpAndSettle();

    if (dragToBottom) {
      await tester.drag(
        find.byType(Material).last, // The popup menu is wrapped in Material
        const Offset(0, -300),
      );

      await tester.pumpAndSettle();
    }

    // Now find the playlist popup menu item and tap on it
    final Finder popupFilteredAudioActionPlaylistMenuItem =
        find.byKey(Key(playlistMenuKeyStr));

    await tester.tap(popupFilteredAudioActionPlaylistMenuItem);
    await tester.pumpAndSettle();
  }

  /// Taps on the appbar leading popup menu button and then on the
  /// passed menu item key. This works on the Playlist Download View
  /// as well as on the Audio Player View.
  static Future<void> typeOnAppbarMenuItem({
    required WidgetTester tester,
    required String appbarMenuKeyStr,
  }) async {
    // Tap the appbar leading popup menu button
    await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
    await tester.pumpAndSettle();

    // Now tap on the passed menu item key
    await tester.tap(find.byKey(Key(appbarMenuKeyStr)));
    await tester.pumpAndSettle();
  }

  static Future<void> typeOnPlaylistSubMenuItem({
    required WidgetTester tester,
    required String playlistTitle,
    required String playlistSubMenuKeyStr,
  }) async {
    // Open the delete filtered audio dialog by clicking first on
    // the 'Filtered Audio Actions ...' playlist menu item and then
    // on the 'Delete Filtered Audio ...' sub-menu item

    // Now find the leading menu icon button of the Playlist ListTile
    // and tap on it

    // First, find the playlist ListTile Text widget
    final Finder playlistListTileTextWidgetFinder = find.text(playlistTitle);

    // Then obtain the source playlist ListTile widget enclosing the
    // Text widget by finding its ancestor
    final Finder playlistListTileWidgetFinder = find.ancestor(
      of: playlistListTileTextWidgetFinder,
      matching: find.byType(ListTile),
    );

    final Finder firstPlaylistListTileLeadingMenuIconButton = find.descendant(
      of: playlistListTileWidgetFinder,
      matching: find.byIcon(Icons.menu),
    );

    // Tap the leading menu icon button to open the popup menu
    await tester.tap(firstPlaylistListTileLeadingMenuIconButton);
    await tester.pumpAndSettle();

    // Now find the filtered Audio's Action playlist popup menu
    // item and tap on it
    final Finder popupFilteredAudioActionPlaylistMenuItem =
        find.byKey(const Key("popup_menu_filtered_audio_actions"));

    await tester.tap(popupFilteredAudioActionPlaylistMenuItem);
    await tester.pumpAndSettle();

    // Now find the filtered Audio's Action playlist submenu
    // item and tap on it
    final Finder popupPlaylistSubMenuItem =
        find.byKey(Key(playlistSubMenuKeyStr));

    await tester.tap(popupPlaylistSubMenuItem);
    await tester.pumpAndSettle();
  }

  static Future<void> verifyCurrentAudioTitleAndSubTitleColor({
    required WidgetTester tester,
    required String currentAudioTitle,
    required String currentAudioSubTitle,
  }) async {
    await IntegrationTestUtil.checkAudioTextColor(
      tester: tester,
      audioTitleOrSubTitle: currentAudioTitle,
      expectedTitleTextColor:
          IntegrationTestUtil.currentlyPlayingAudioTitleTextColor,
      expectedTitleTextBackgroundColor:
          IntegrationTestUtil.currentlyPlayingAudioTitleTextBackgroundColor,
    );

    await IntegrationTestUtil.checkAudioTextColor(
      tester: tester,
      audioTitleOrSubTitle: currentAudioSubTitle,
      expectedTitleTextColor:
          IntegrationTestUtil.currentlyPlayingAudioTitleTextColor,
      expectedTitleTextBackgroundColor:
          IntegrationTestUtil.currentlyPlayingAudioTitleTextBackgroundColor,
    );
  }

  static Finder validateInkWellButton({
    required WidgetTester tester,
    String? audioTitle,
    String? inkWellButtonKey,
    required IconData expectedIcon,
    required Color expectedIconColor,
    required Color expectedIconBackgroundColor,
  }) {
    final Finder audioListTileInkWellFinder;

    if (inkWellButtonKey != null) {
      audioListTileInkWellFinder = find.byKey(Key(inkWellButtonKey));
    } else {
      audioListTileInkWellFinder = findAudioItemInkWellWidget(
        audioTitle: audioTitle!,
      );
    }

    // Find the Icon within the InkWell
    final Finder iconFinder = find.descendant(
      of: audioListTileInkWellFinder,
      matching: find.byType(Icon),
    );
    Icon iconWidget = tester.widget<Icon>(iconFinder);

    // Assert Icon type
    expect(iconWidget.icon, equals(expectedIcon));

    // Assert Icon color
    expect(iconWidget.color, equals(expectedIconColor));

    // Find the CircleAvatar within the InkWell
    final Finder circleAvatarFinder = find.descendant(
      of: audioListTileInkWellFinder,
      matching: find.byType(CircleAvatar),
    );
    CircleAvatar circleAvatarWidget =
        tester.widget<CircleAvatar>(circleAvatarFinder);

    // Assert CircleAvatar background color
    expect(circleAvatarWidget.backgroundColor,
        equals(expectedIconBackgroundColor));

    return audioListTileInkWellFinder;
  }

  static Finder findAudioItemInkWellWidget({
    required String audioTitle,
  }) {
    // First, get the downloaded Audio item ListTile Text
    // widget finder
    final Finder audioListTileTextWidgetFinder = find.text(audioTitle);

    // Then obtain the downloaded Audio item ListTile
    // widget enclosing the Text widget by finding its ancestor
    final Finder audioListTileWidgetFinder = find.ancestor(
      of: audioListTileTextWidgetFinder,
      matching: find.byType(ListTile),
    );

    // Now find the InkWell widget located in the downloaded
    // Audio item ListTile
    final Finder audioListTileInkWellFinder = find.descendant(
      of: audioListTileWidgetFinder,
      matching: find.byKey(const Key("play_pause_audio_item_inkwell")),
    );

    return audioListTileInkWellFinder;
  }

  /// Initializes the application and selects the playlist if
  /// [selectedPlaylistTitle] is not null.
  static Future<void> initializeApplicationAndSelectPlaylist({
    required WidgetTester tester,
    String? savedTestDataDirName,
    String? selectedPlaylistTitle,
    String? replacePlaylistJsonFileName,
    bool tapOnPlaylistToggleButton = true,
    bool setAppSizeToAndroidSize = false,
  }) async {
    // Purge the test playlist directory if it exists so that the
    // playlist list is empty
    DirUtil.deleteFilesInDirAndSubDirsWithRetry(
      rootPath: kApplicationPathWindowsTest,
    );

    if (setAppSizeToAndroidSize) {
      // Create a 'isAppSizeNotTest.txt' file to indicate that the app is
      // opened in Android similar size.
      String isAppSizeNotTestFilePath =
          "$kApplicationPathWindowsTest${path.separator}isAppSizeNotTest.txt";
      File(isAppSizeNotTestFilePath).createSync(recursive: true);
    }

    if (savedTestDataDirName != null) {
      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}$savedTestDataDirName",
        destinationRootPath: kApplicationPathWindowsTest,
      );
    }

    if (replacePlaylistJsonFileName != null) {
      // Copy the test initial audio data to the app dir
      final String playlistPath =
          "$kApplicationPathWindowsTest${path.separator}$selectedPlaylistTitle${path.separator}";
      final String playlistJsonFileName = '$selectedPlaylistTitle.json';
      DirUtil.deleteFileIfExist(
        pathFileName: '$playlistPath$playlistJsonFileName',
      );

      DirUtil.renameFile(
          fileToRenameFilePathName: "$playlistPath$replacePlaylistJsonFileName",
          newFileName: playlistJsonFileName);
    }

    final SettingsDataService settingsDataService = SettingsDataService(
      sharedPreferences: await SharedPreferences.getInstance(),
      isTest: true,
    );

    // load settings from file which does not exist. This
    // will ensure that the default playlist root path is set
    await settingsDataService.loadSettingsFromFile(
        settingsJsonPathFileName: "temp\\wrong.json");

    // Load the settings from the json file. This is necessary
    // otherwise the ordered playlist titles will remain empty
    // and the playlist list will not be filled with the
    // playlists available in the download app test dir
    await settingsDataService.loadSettingsFromFile(
        settingsJsonPathFileName:
            "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

    await app.main();
    await tester.pumpAndSettle();

    if (tapOnPlaylistToggleButton) {
      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();
    }

    if (selectedPlaylistTitle != null) {
      // Find the ListTile Playlist containing the playlist which
      // contains the audio to play

      // First, find the Playlist ListTile Text widget
      Finder audioPlayerSelectedPlaylistFinder =
          find.text(selectedPlaylistTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text
      // widget by finding its ancestor
      Finder selectedPlaylistListTileWidgetFinder = find.ancestor(
        of: audioPlayerSelectedPlaylistFinder,
        matching: find.byType(ListTile),
      );

      if (selectedPlaylistListTileWidgetFinder.evaluate().isEmpty) {
        // In this case, the first tap on the 'Toggle List' button
        // did close the list of playlists. Tap the 'Toggle List' button
        // again to show the list. If the list selecting the playlist
        // won't be possible.

        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // First, find the Playlist ListTile Text widget
        audioPlayerSelectedPlaylistFinder = find.text(selectedPlaylistTitle);

        // Then obtain the Playlist ListTile widget enclosing the Text
        // widget by finding its ancestor
        selectedPlaylistListTileWidgetFinder = find.ancestor(
          of: audioPlayerSelectedPlaylistFinder,
          matching: find.byType(ListTile),
        );
      }

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder selectedPlaylistCheckboxWidgetFinder = find.descendant(
        of: selectedPlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Retrieve the Checkbox widget
      final Checkbox checkbox =
          tester.widget<Checkbox>(selectedPlaylistCheckboxWidgetFinder);

      // Tap on the playlist checkbox to select it if it is not
      // already selected
      if (checkbox.value == null || !checkbox.value!) {
        // Tap the ListTile Playlist checkbox to select it
        // so that the playlist audio are listed
        await tester.tap(selectedPlaylistCheckboxWidgetFinder);
        await tester.pumpAndSettle();
      }
    }
  }

  /// Initializes the application on Android emulator and selects the playlist if
  /// [selectedPlaylistTitle] is not null.
  static Future<void> initializeAndroidApplicationAndSelectPlaylist({
    required WidgetTester tester,
    String? selectedPlaylistTitle,
    String? replacePlaylistJsonFileName,
    bool tapOnPlaylistToggleButton = true,
    bool setAppSizeToAndroidSize = false,
  }) async {
    final SettingsDataService settingsDataService = SettingsDataService(
      sharedPreferences: await SharedPreferences.getInstance(),
      isTest: true,
    );

    // load settings from file which does not exist. This
    // will ensure that the default playlist root path is set
    // await settingsDataService.loadSettingsFromFile(
    //     settingsJsonPathFileName: "$kApplicationPathAndroidTest/wrong.json");

    // Load the settings from the json file. This is necessary
    // otherwise the ordered playlist titles will remain empty
    // and the playlist list will not be filled with the
    // playlists available in the download app test dir
    await settingsDataService.loadSettingsFromFile(
        settingsJsonPathFileName:
            "$kApplicationPathAndroidTest/$kSettingsFileName");

    await app.main();
    await tester.pumpAndSettle();

    if (tapOnPlaylistToggleButton) {
      // Tap the 'Toggle List' button to show the list. If the list
      // is not opened, checking that a ListTile with the title of
      // the playlist was added to the list will fail
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();
    }

    if (selectedPlaylistTitle != null) {
      // Find the ListTile Playlist containing the playlist which
      // contains the audio to play

      // First, find the Playlist ListTile Text widget
      Finder audioPlayerSelectedPlaylistFinder =
          find.text(selectedPlaylistTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text
      // widget by finding its ancestor
      Finder selectedPlaylistListTileWidgetFinder = find.ancestor(
        of: audioPlayerSelectedPlaylistFinder,
        matching: find.byType(ListTile),
      );

      if (selectedPlaylistListTileWidgetFinder.evaluate().isEmpty) {
        // In this case, the first tap on the 'Toggle List' button
        // did close the list of playlists. Tap the 'Toggle List' button
        // again to show the list. If the list selecting the playlist
        // won't be possible.

        await tester.tap(find.byKey(const Key('playlist_toggle_button')));
        await tester.pumpAndSettle();

        // First, find the Playlist ListTile Text widget
        audioPlayerSelectedPlaylistFinder = find.text(selectedPlaylistTitle);

        // Then obtain the Playlist ListTile widget enclosing the Text
        // widget by finding its ancestor
        selectedPlaylistListTileWidgetFinder = find.ancestor(
          of: audioPlayerSelectedPlaylistFinder,
          matching: find.byType(ListTile),
        );
      }

      // Now find the Checkbox widget located in the Playlist ListTile
      // and tap on it to select the playlist
      final Finder selectedPlaylistCheckboxWidgetFinder = find.descendant(
        of: selectedPlaylistListTileWidgetFinder,
        matching: find.byType(Checkbox),
      );

      // Retrieve the Checkbox widget
      final Checkbox checkbox =
          tester.widget<Checkbox>(selectedPlaylistCheckboxWidgetFinder);

      // Tap on the playlist checkbox to select it if it is not
      // already selected
      if (checkbox.value == null || !checkbox.value!) {
        // Tap the ListTile Playlist checkbox to select it
        // so that the playlist audio are listed
        await tester.tap(selectedPlaylistCheckboxWidgetFinder);
        await tester.pumpAndSettle();
      }
    }
  }

  static Future<void> modifyAudioInPlaylistJsonFileAndUpgradePlaylists({
    required WidgetTester tester,
    required String playlistTitle,
    required int playableAudioLstAudioIndex,
    DateTime? modifiedAudioPausedDateTime,
    int modifiedAudioPositionSeconds = 0,
    bool doRemoveDeletedAudioFiles = true,
  }) async {
    final String selectedPlaylistPath = path.join(
      kApplicationPathWindowsTest,
      playlistTitle,
    );

    final selectedPlaylistFilePathName = path.join(
      selectedPlaylistPath,
      '$playlistTitle.json',
    );

    // Load playlist from the json file
    Playlist loadedSelectedPlaylist = JsonDataService.loadFromFile(
      jsonPathFileName: selectedPlaylistFilePathName,
      type: Playlist,
    );

    Audio audioToModify =
        loadedSelectedPlaylist.playableAudioLst[playableAudioLstAudioIndex];

    if (modifiedAudioPausedDateTime != null) {
      audioToModify.audioPausedDateTime = modifiedAudioPausedDateTime;
    }

    if (modifiedAudioPositionSeconds != 0) {
      audioToModify.audioPositionSeconds = modifiedAudioPositionSeconds;
      audioToModify.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd = true;
    }

    // Save the modified playlist to the json file
    JsonDataService.saveToFile(
      model: loadedSelectedPlaylist,
      path: selectedPlaylistFilePathName,
    );

    // After having modified the audio paused date time, execute
    // 'Updating playlist JSON file' menu item so that all playlists,
    // including the playlist containing the modified audio paused date
    // time, are reloaded.

    await executeUpdatePlaylistJsonFiles(
      tester: tester,
      doRemoveDeletedAudioFiles: doRemoveDeletedAudioFiles,
    );
  }

  static Future<void> executeUpdatePlaylistJsonFiles({
    required WidgetTester tester,
    bool doRemoveDeletedAudioFiles = true,
  }) async {
    // Now tap the appbar leading popup menu and then the
    // 'Update playlist JSON file' menu item
    await IntegrationTestUtil.typeOnAppbarMenuItem(
      tester: tester,
      appbarMenuKeyStr: 'update_playlist_json_dialog_item',
    );

    if (doRemoveDeletedAudioFiles) {
      // Find the 'Remove deleted audio files' checkbox and tap
      // on it
      await tester.tap(find.byKey(const Key('checkbox_0_key')));
      await tester.pumpAndSettle();
    }

    // Tap on the Ok button to set the comment end position to the
    // audio duration value in the comment previous dialog.
    await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
    await tester.pumpAndSettle();
  }

  static Future<void> executeRestorePlaylists({
    required WidgetTester tester,
    bool doReplaceExistingPlaylists = true,
    List<String> playlistTitlesToDelete = const [],
  }) async {
    if (playlistTitlesToDelete.isNotEmpty) {
      // Delete the playlists which are to be deleted
      for (String playlistTitle in playlistTitlesToDelete) {
        // First, find the playlist ListTile Text widget
        final Finder playlistListTileTextWidgetFinder =
            find.text(playlistTitle);

        // If the playlist ListTile Text widget is not found, continue
        if (playlistListTileTextWidgetFinder.evaluate().isEmpty) {
          continue;
        }

        await typeOnPlaylistMenuItem(
            tester: tester,
            playlistTitle: playlistTitle,
            playlistMenuKeyStr: 'popup_menu_delete_playlist',
            dragToBottom: true);

        // Now find the confirm button of the delete playlist confirm
        // dialog and tap on it
        await tester.tap(find.byKey(const Key('confirmButton')));
        await tester.pumpAndSettle();
      }
    }

    // Now tap the appbar leading popup menu and then the
    // 'Restore Playlist(s), Comments, Pictures and Settings
    // from ZIP file' menu item
    await IntegrationTestUtil.typeOnAppbarMenuItem(
      tester: tester,
      appbarMenuKeyStr: 'appBarMenuRestorePlaylistsCommentsAndSettingsFromZip',
    );

    if (doReplaceExistingPlaylists) {
      // Find the 'Remove deleted audio files' checkbox and tap
      // on it
      await tester.tap(find.byKey(const Key('checkbox_0_key')));
      await tester.pumpAndSettle();
    }

    // Tap on the Ok button to launch the restoration.
    await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  static void expectWithSuccessMessage({
    required dynamic actual,
    required dynamic matcher,
    String? reason,
    String? successMessage,
    dynamic skip,
  }) {
    try {
      expect(actual, matcher, reason: reason, skip: skip);
      if (successMessage != null) {
        // ignore: avoid_print
        print(successMessage);
      }
    } catch (e) {
      rethrow; // Rethrow the exception if the expectation fails
    }
  }

  /// If {offsetValue} is negative, the list is scroll down
  static Future<void> selectAudioInAudioPlayableDialog({
    required WidgetTester tester,
    required String audioToSelectTitle,
    double offsetValue = 0.0,
  }) async {
    // Find the AudioPlayableListDialog
    Finder audioPlayableListDialogFinder = find.byType(AudioPlayableListDialog);

    if (offsetValue != 0.0) {
      // Find the list body containing the audio titles
      final Finder audioPlayableListBodyFinder = find.descendant(
          of: audioPlayableListDialogFinder, matching: find.byType(ListBody));

      // Scrolling down the audios list in order to display the first
      // downloaded audio title

      // Perform the scroll action
      await tester.drag(audioPlayableListBodyFinder, Offset(0, offsetValue));
      await tester.pumpAndSettle();
    }

    // Then get the audio to select ListTile Text widget finder
    // and tap on it

    // Find the list body containing the audio titles
    final Finder audioPlayableListBodyFinder = find.descendant(
        of: audioPlayableListDialogFinder, matching: find.byType(ListBody));

    // Find the ListTile containing the specific audio title
    final Finder audioTitleFinder = find.descendant(
        of: audioPlayableListBodyFinder,
        matching: find.text(audioToSelectTitle));

    // Tap on the ListTile containing the specific audio title
    await tester.tap(audioTitleFinder);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
  }

  static void verifyPlaylistSelection({
    required WidgetTester tester,
    required String playlistTitle,
    bool isSelected = true,
    String? modifiedPlaylistRootPath,
  }) async {
    Finder listItemTileFinder = find.widgetWithText(ListTile, playlistTitle);

    // Find the Checkbox widget inside the ListTile
    Finder checkboxFinder = find.descendant(
      of: listItemTileFinder,
      matching: find.byType(Checkbox),
    );

    // Assert that the checkbox is selected or not
    expect(
      tester.widget<Checkbox>(checkboxFinder).value,
      isSelected,
    );

    // Verifying that the playlist selection value in the
    // playlist json file is the same as the one wich is
    // expected

    String playlistPathFileName;

    if (modifiedPlaylistRootPath != null) {
      // If the modified playlist root path is specified, use it
      playlistPathFileName =
          '$modifiedPlaylistRootPath${path.separator}$playlistTitle${path.separator}$playlistTitle.json';
    } else {
      // Otherwise, use the default playlist download root path
      playlistPathFileName =
          '${DirUtil.getPlaylistDownloadRootPath(isTest: true)}${path.separator}$playlistTitle${path.separator}$playlistTitle.json';
    }

    Playlist loadedPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: playlistPathFileName, type: Playlist);
    expect(loadedPlaylist.isSelected, isSelected);
  }

  /// In this version, the second audio menu item is disabled.
  static Future<void> verifyTwoFirstAudioMenuItemsState({
    required WidgetTester tester,
    required bool isFirstAudioMenuItemDisabled,
    required AudioLearnAppViewType audioLearnAppViewType,
  }) async {
    if (isFirstAudioMenuItemDisabled) {
      verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'define_sort_and_filter_audio_menu_item',
      );

      verifyWidgetIsDisabled(
        // no Sort/filter parameters history are available in test data
        tester: tester,
        widgetKeyStr: 'clear_sort_and_filter_audio_parms_history_menu_item',
      );

      // The save sort and filter audio parameters in playlist menu item
      // is currently disabled in the audio player view
      // verifyWidgetIsDisabled(
      //   tester: tester,
      //   widgetKeyStr: 'save_sort_and_filter_audio_parms_in_playlist_item',
      // );
    } else {
      verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'define_sort_and_filter_audio_menu_item',
      );

      verifyWidgetIsDisabled(
        // no Sort/filter parameters history are available in test data
        tester: tester,
        widgetKeyStr: 'clear_sort_and_filter_audio_parms_history_menu_item',
      );
    }

    if (audioLearnAppViewType == AudioLearnAppViewType.audioPlayerView) {
      // Tap on the AudioPlayerView icon button to close the audio menu
      // item

      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
    }
  }

  static String getTestName() {
    return 'testName';
  }

  static void verifyWidgetIsEnabled({
    required WidgetTester tester,
    required String widgetKeyStr,
  }) {
    // Find the widget by its key
    final Finder widgetFinder = find.byKey(Key(widgetKeyStr));

    // Retrieve the widget as a generic Widget
    final Widget widget = tester.widget(widgetFinder);

    // Check if the widget is enabled based on its type
    if (widget is IconButton) {
      expect(widget.onPressed, isNotNull,
          reason: 'IconButton should be enabled');
    } else if (widget is TextButton) {
      expect(widget.onPressed, isNotNull,
          reason: 'TextButton should be enabled');
    } else if (widget is Checkbox) {
      // For Checkbox, you can check if onChanged is null
      expect(widget.onChanged, isNotNull, reason: 'Checkbox should be enabled');
    } else if (widget is PopupMenuButton) {
      // For PopupMenuButton, check the enabled property
      expect(widget.enabled, isTrue,
          reason: 'PopupMenuButton should be enabled');
    } else if (widget is PopupMenuItem) {
      // For PopupMenuButton, check the enabled property
      expect(widget.enabled, isTrue, reason: 'PopupMenuItem should be enabled');
    } else if (widget is InkWell) {
      // For InkWell button, check the onTap property
      expect(widget.onTap, isNotNull,
          reason: 'InkWell button should be enabled');
    } else {
      fail(
          'The widget with key $widgetKeyStr is not a recognized type for this test');
    }
  }

  static void verifyWidgetIsDisabled({
    required WidgetTester tester,
    required String widgetKeyStr,
    bool isSaveSortFilterMenuDisabled = false,
  }) {
    // Find the widget by its key
    final Finder widgetFinder = find.byKey(Key(widgetKeyStr));

    // Retrieve the widget as a generic Widget
    final Widget widget = tester.widget(widgetFinder);

    // Check if the widget is disabled based on its type
    if (widget is IconButton) {
      expect(widget.onPressed, isNull, reason: 'IconButton should be disabled');
    } else if (widget is TextButton) {
      expect(widget.onPressed, isNull, reason: 'TextButton should be disabled');
    } else if (widget is Checkbox) {
      // For Checkbox, you can check if onChanged is null
      expect(widget.onChanged, isNull, reason: 'Checkbox should be disabled');
    } else if (widget is PopupMenuButton) {
      // For PopupMenuButton, check the enabled property
      expect(widget.enabled, isFalse,
          reason: 'PopupMenuButton should be disabled');
    } else if (widget is PopupMenuItem) {
      // For PopupMenuButton, check the enabled property
      expect(widget.enabled, isFalse,
          reason: 'PopupMenuItem should be disabled');
    } else if (widget is InkWell) {
      // Fall back to the original check for other InkWell widgets
      expect(widget.onTap, isNull, reason: 'InkWell button should be disabled');
    } else {
      fail(
          'The widget with key $widgetKeyStr is not a recognized type for this test');
    }
  }

  static void verifyIconButtonColor({
    required WidgetTester tester,
    required String widgetKeyStr,
    required bool isIconButtonEnabled,
  }) {
    // Find the widget by its key
    final Finder widgetFinder = find.byKey(Key(widgetKeyStr));

    if (widgetFinder.evaluate().isEmpty) {
      // The case if playlists are not displayed or if no playlist
      // is selected. In this case, the widget is not found since
      // in place of up down button a sort filter parameters dropdown
      // button is displayed
      return;
    }

    // Retrieve the icon of the IconButton
    final Icon icon = (tester.widget(widgetFinder) as IconButton).icon as Icon;

    // Check if the icon color is correct based on the enabled status
    if (isIconButtonEnabled) {
      expect(icon.color, kDarkAndLightEnabledIconColor,
          reason: 'IconButton color should be enabled color');
    } else {
      expect(icon.color, kDarkAndLightDisabledIconColor,
          reason: 'IconButton color should be disabled color');
    }
  }

  static Future<void> verifyTopButtonsState({
    required WidgetTester tester,
    required bool areEnabled,
    required AudioLearnAppViewType audioLearnAppViewType,
    required String setAudioSpeedTextButtonValue,
  }) async {
    if (areEnabled) {
      verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'decreaseAudioVolumeIconButton',
      );

      verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'increaseAudioVolumeIconButton',
      );

      verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'setAudioSpeedTextButton',
      );

      verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'commentsInkWellButton',
      );

      verifyWidgetIsEnabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );
    } else {
      verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'decreaseAudioVolumeIconButton',
      );

      verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'increaseAudioVolumeIconButton',
      );

      verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'setAudioSpeedTextButton',
      );

      verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'commentsInkWellButton',
      );

      verifyWidgetIsDisabled(
        tester: tester,
        widgetKeyStr: 'audio_popup_menu_button',
      );
    }

    final Finder setAudioSpeedTextButtonFinder =
        find.byKey(const Key('setAudioSpeedTextButton'));

    final Finder setAudioSpeedTextOfButtonFinder = find.descendant(
      of: setAudioSpeedTextButtonFinder,
      matching: find.byType(Text),
    );

    // Verify that the Text widget contains the expected content

    String setAudioSpeedTextOfButton =
        tester.widget<Text>(setAudioSpeedTextOfButtonFinder).data!;

    expect(
      setAudioSpeedTextOfButton,
      setAudioSpeedTextButtonValue,
    );

    if (areEnabled) {
      // Open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // since the selected local playlist has audio, the
      // audio menu items are enabled
      await verifyTwoFirstAudioMenuItemsState(
        tester: tester,
        isFirstAudioMenuItemDisabled: false,
        audioLearnAppViewType: audioLearnAppViewType,
      );
    }
  }

  static Future<void> verifyWarningDisplayAndCloseIt({
    required WidgetTester tester,
    required String warningDialogMessage,
    String warningDialogMessageAlternative = '',
    bool isWarningConfirming = false,
    bool tapTwiceOnOkButton = false,
    String warningTitle =
        'WARNING', // useful for AVERTISSEMENT title in french !
  }) async {
    // Ensure the warning dialog is shown
    final Finder warningMessageDisplayDialogFinder =
        find.byType(WarningMessageDisplayDialog);
    expect(warningMessageDisplayDialogFinder, findsOneWidget);

    // Check the value of the warning dialog title

    Text warningDialogTitle =
        tester.widget(find.byKey(const Key('warningDialogTitle')).last);

    if (isWarningConfirming) {
      expect(warningDialogTitle.data, 'CONFIRMATION');
    } else {
      expect(warningDialogTitle.data, warningTitle);
    }

    // Check the value of the warning dialog message

    if (warningDialogMessageAlternative.isNotEmpty) {
      expect(
        tester
            .widget<Text>(find.byKey(const Key('warningDialogMessage')).last)
            .data,
        anyOf([
          equals(warningDialogMessage),
          equals(warningDialogMessageAlternative),
        ]),
      );
    } else {
      expect(
        tester
            .widget<Text>(find.byKey(const Key('warningDialogMessage')).last)
            .data,
        warningDialogMessage,
      );
    }

    // Close the warning dialog by tapping on the Ok button

    if (tapTwiceOnOkButton) {
      await tester.tap(find.byKey(const Key('warningDialogOkButton')).last);
      await tester.pumpAndSettle(const Duration(milliseconds: 400));

      await tester.tap(find.byKey(const Key('warningDialogOkButton')).last);
      await tester.pumpAndSettle(const Duration(milliseconds: 400));
    } else {
      await tester.tap(find.byKey(const Key('warningDialogOkButton')).last);
      await tester.pumpAndSettle();
    }
  }

  static Future<void> verifyAlertDisplayAndCloseIt({
    required WidgetTester tester,
    required String alertDialogMessage,
    bool tapTwiceOnOkButton = false,
  }) async {
    // Ensure the alert dialog is shown
    final Finder alertDialogDisplayDialogFinder = find.byType(AlertDialog);
    expect(alertDialogDisplayDialogFinder, findsOneWidget);

    // Check the value of the alert dialog title

    Text alertDialogTitle =
        tester.widget(find.byKey(const Key('confirmationDialogTitleKey')).last);

    expect(alertDialogTitle.data, 'CONFIRMATION');

    // Check the value of the alert dialog message
    expect(
      tester
          .widget<Text>(
              find.byKey(const Key('confirmationDialogMessageKey')).last)
          .data,
      alertDialogMessage,
    );

    // Close the warning dialog by tapping on the Ok button

    if (tapTwiceOnOkButton) {
      await tester.tap(find.byKey(const Key('okButtonKey')).last);
      await tester.pumpAndSettle(const Duration(milliseconds: 400));

      await tester.tap(find.byKey(const Key('okButtonKey')).last);
      await tester.pumpAndSettle(const Duration(milliseconds: 400));
    } else {
      await tester.tap(find.byKey(const Key('okButtonKey')).last);
      await tester.pumpAndSettle();
    }
  }

  static Future<void> selectPlaylist({
    required WidgetTester tester,
    required String playlistToSelectTitle,
    Duration? selectPlaylistPumpAndSettleDuration,
  }) async {
    // First, find the source Playlist ListTile Text widget
    final Finder playlistListTileTextWidgetFinder =
        find.text(playlistToSelectTitle);

    // Then obtain the source Playlist ListTile widget enclosing the Text widget
    // by finding its ancestor
    final Finder playlistListTileWidgetFinder = find.ancestor(
      of: playlistListTileTextWidgetFinder,
      matching: find.byType(ListTile),
    );

    // Now find the Checkbox widget located in the Playlist ListTile
    // and tap on it to select the playlist
    final Finder playlistListTileCheckboxWidgetFinder = find.descendant(
      of: playlistListTileWidgetFinder,
      matching: find.byType(Checkbox),
    );

    // Tap the ListTile Playlist checkbox to select or unselect it
    await tester.tap(playlistListTileCheckboxWidgetFinder);

    if (selectPlaylistPumpAndSettleDuration != null) {
      await tester.pumpAndSettle(selectPlaylistPumpAndSettleDuration);
    } else {
      await tester.pumpAndSettle();
    }
  }

  static Future<bool> isPlaylistSelected({
    required WidgetTester tester,
    required String playlistToCheckTitle,
  }) async {
    // First, find the source Playlist ListTile Text widget
    final Finder playlistListTileTextWidgetFinder =
        find.text(playlistToCheckTitle);

    // Then obtain the source Playlist ListTile widget enclosing the Text widget
    // by finding its ancestor
    final Finder playlistListTileWidgetFinder = find.ancestor(
      of: playlistListTileTextWidgetFinder,
      matching: find.byType(ListTile),
    );

    // Now find the Checkbox widget located in the Playlist ListTile
    final Finder playlistListTileCheckboxWidgetFinder = find.descendant(
      of: playlistListTileWidgetFinder,
      matching: find.byType(Checkbox),
    );

    // Check if the checkbox exists
    if (playlistListTileCheckboxWidgetFinder.evaluate().isEmpty) {
      return false; // Checkbox not found
    }

    // Get the checkbox widget and check its value
    final Checkbox checkboxWidget =
        tester.widget<Checkbox>(playlistListTileCheckboxWidgetFinder);

    return checkboxWidget.value ?? false;
  }

  static Future<void> verifyNoPlaylistCheckboxSelected({
    required WidgetTester tester,
  }) async {
    // Find all ListTile widgets in the playlist list
    final Finder listTileFinder = find.byType(ListTile);

    // Iterate over each ListTile widget
    for (final listTileElement in listTileFinder.evaluate()) {
      // Find the Checkbox widget inside the current ListTile
      final Finder checkboxFinder = find.descendant(
        of: find.byWidget(listTileElement.widget),
        matching: find.byType(Checkbox),
      );

      // Ensure the Checkbox widget exists
      expect(checkboxFinder, findsOneWidget);

      // Get the Checkbox widget's value
      final Checkbox checkboxWidget = tester.widget<Checkbox>(checkboxFinder);
      expect(checkboxWidget.value, isFalse,
          reason: 'A playlist checkbox is selected.');
    }
  }

  static void checkPlaylistAndAudioTitlesOrderInListTile({
    required WidgetTester tester,
    required List<String> playlistTitlesOrderedLst,
    required List<String> audioTitlesOrderedLst,
  }) {
    // Obtains all the ListTile widgets present in the playlist
    // download view
    final Finder listTilesFinder = find.byType(ListTile);
    int playlistListTileIndex = 0;

    if (playlistTitlesOrderedLst.isNotEmpty) {
      for (String title in playlistTitlesOrderedLst) {
        Finder playlistTitleTextFinder = find.descendant(
          of: listTilesFinder.at(playlistListTileIndex++),
          matching: find.byType(Text),
        );

        expect(
          tester.widget<Text>(playlistTitleTextFinder.at(0)).data,
          title,
        );
      }
    }

    if (audioTitlesOrderedLst.isNotEmpty) {
      for (String title in audioTitlesOrderedLst) {
        Finder playlistTitleTextFinder = find.descendant(
          of: listTilesFinder.at(playlistListTileIndex++),
          matching: find.byType(Text),
        );

        expect(
          tester.widget<Text>(playlistTitleTextFinder.at(0)).data,
          title,
        );
      }
    } else {
      // Verify that the second list is empty
      int totalListTiles = tester.widgetList(listTilesFinder).length;

      // The total number of ListTile widgets should equal the
      // playlist titles count plus the starting index of the first
      // audio list tile
      expect(
        totalListTiles,
        playlistTitlesOrderedLst.length,
        reason: '''The playlist download view audio list should be empty
            when the passed audioTitlesOrderedLst is [].''',
      );
    }
  }

  static void verifyAudioPlaySpeedStoredInPlaylistJsonFile({
    required String selectedPlaylistTitle,
    required int playableAudioLstAudioIndex,
    required double expectedAudioPlaySpeed,
  }) {
    final String selectedPlaylistPath = path.join(
      kApplicationPathWindowsTest,
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

    expect(
        loadedSelectedPlaylist
            .playableAudioLst[playableAudioLstAudioIndex].audioPlaySpeed,
        expectedAudioPlaySpeed);
  }

  /// Method used to verify the presence and the order of the listed
  /// playlist titles or the listed audio titles in the playlist download
  /// view or the audio player view. If the audio list is verifyed, the
  /// [firstAudioListTileIndex] is equal to the number of playlist titles
  /// in the list of playlist in case this list is expanded. If the playlist
  /// list is verifyed, the [firstAudioListTileIndex] is equal to 0. But
  /// if the playlist list is empty, the [firstAudioListTileIndex] must
  /// be equal to the number of displayed audio list items due to the test
  /// at the end of the method.
  static void checkAudioOrPlaylistTitlesOrderInListTile({
    required WidgetTester tester,
    required List<String> audioOrPlaylistTitlesOrderedLst,
    int firstAudioListTileIndex = 0,
  }) {
    // Obtains all the ListTile widgets present in the playlist
    // download view
    final Finder listTilesFinder = find.byType(ListTile);

    for (String title in audioOrPlaylistTitlesOrderedLst) {
      Finder playlistTitleTextFinder = find.descendant(
        of: listTilesFinder.at(firstAudioListTileIndex++),
        matching: find.byType(Text),
      );

      expect(
        // 2 Text widgets exist in audio ListTile: the title and sub title
        tester.widget<Text>(playlistTitleTextFinder.at(0)).data,
        title,
      );
    }

    // If the audioOrPlaylistTitlesOrderedLst is empty, check that the
    // number of ListTile widgets is equal to the passed
    // firstAudioListTileIndex
    if (audioOrPlaylistTitlesOrderedLst.isEmpty) {
      expect(
        tester.widgetList(listTilesFinder).length,
        firstAudioListTileIndex,
      );
    }
  }

  /// Method used to verify the presence (not the order) of the listed
  /// playlist titles or the listed audio titles in the playlist download
  /// view or the audio player view.
  static void checkAudioOrPlaylistTitlesPresenceInListTile({
    required WidgetTester tester,
    required List<String> audioOrPlaylistTitlesLst,
  }) {
    // Find all ListTile widgets in the current view
    final Finder listTilesFinder = find.byType(ListTile);

    // Retrieve the text data of each ListTile in the playlist download view
    final List<String?> audioOrPlaylistTitleLst = tester
        .widgetList<Text>(find.descendant(
          of: listTilesFinder,
          matching: find.byType(Text),
        ))
        .map((textWidget) => textWidget.data)
        .toList();

    // If the audioOrPlaylistTitlesLst is not empty, ensure that all titles
    // are present in the ListTile widgets
    if (audioOrPlaylistTitlesLst.isNotEmpty) {
      for (String title in audioOrPlaylistTitlesLst) {
        expect(
          audioOrPlaylistTitleLst.contains(title),
          true,
          reason: 'Title "$title" not found in the ListTile list.',
        );
      }
    } else {
      // If the list is empty, ensure no ListTile widgets are present
      expect(tester.widgetList(listTilesFinder).length, 0);
    }
  }

  static void checkAudioSubTitlesOrderInListTile({
    required WidgetTester tester,
    required List<String> audioSubTitlesOrderLst,
    int firstAudioListTileIndex = 0,
  }) {
    // Obtains all the ListTile widgets present in the playlist
    // download view
    final Finder listTilesFinder = find.byType(ListTile);

    for (String subTitle in audioSubTitlesOrderLst) {
      Finder playlistTitleTextFinder = find.descendant(
        of: listTilesFinder.at(firstAudioListTileIndex++),
        matching: find.byType(Text),
      );

      expect(
        // 2 Text widgets exist in audio ListTile: the title and sub title
        tester.widget<Text>(playlistTitleTextFinder.last).data,
        subTitle,
      );
    }
  }

  static void checkAudioTitlesOrderInListBody({
    required WidgetTester tester,
    required List<String> audioTitlesOrderLst,
  }) {
    // Obtains all the ListBody widgets present in the playlist download view
    final Finder listBodyFinder = find.byType(ListBody);

    int i = 0;
    for (String title in audioTitlesOrderLst) {
      // Finds the Text widget inside the ListBody
      Finder listBodyTextFinder = find
          .descendant(
            of: listBodyFinder,
            matching: find.byType(Text),
          )
          .at(i++);

      expect(
        // Assuming each ListBody item has a single Text widget representing the title
        tester.widget<Text>(listBodyTextFinder).data,
        title,
      );
    }
  }

  static void checkDropdopwnButtonSelectedTitle({
    required WidgetTester tester,
    required String dropdownButtonSelectedTitle,
  }) {
    final Finder dropDownButtonFinder =
        find.byKey(const Key('sort_filter_parms_dropdown_button'));

    final Finder dropDownButtonTextFinder = find.descendant(
      of: dropDownButtonFinder,
      matching: find.byType(Text),
    );

    expect(
      tester.widget<Text>(dropDownButtonTextFinder).data,
      dropdownButtonSelectedTitle,
    );
  }

  /// {confirmOrCancelAction} is true if the confirm button will be tapped.
  /// Otherwise, the cancel button will be tapped.
  static Future<void> verifyAndCloseConfirmActionDialog({
    required WidgetTester tester,
    required String confirmDialogTitleOne,
    String confirmDialogTitleTwo = '',
    required String confirmDialogMessage,
    required bool confirmOrCancelAction,
    bool isHelpIconPresent = false,
  }) async {
    // Verifying the confirm dialog title

    Text confirmDialogTitleTextWidget =
        tester.widget<Text>(find.byKey(const Key('confirmDialogTitleOneKey')));

    expect(
      confirmDialogTitleTextWidget.data,
      confirmDialogTitleOne,
    );

    // Verifying the confirm dialog title two

    if (confirmDialogTitleTwo.isNotEmpty) {
      confirmDialogTitleTextWidget = tester
          .widget<Text>(find.byKey(const Key('confirmDialogTitleTwoKey')));

      expect(
        confirmDialogTitleTextWidget.data,
        confirmDialogTitleTwo,
      );
    }

    if (isHelpIconPresent) {
      // Verify the presence of the help icon button
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
    } else {
      // Verify the absence of the help icon button
      expect(find.byIcon(Icons.help_outline), findsNothing);
    }

    // Verifying the confirm dialog message

    final Text confirmDialogMessageTextWidget = tester
        .widget<Text>(find.byKey(const Key('confirmationDialogMessageKey')));

    expect(
      confirmDialogMessageTextWidget.data,
      confirmDialogMessage,
    );

    if (confirmOrCancelAction) {
      // Now find the confirm button of the confirm action dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();
    } else {
      // Now find the cancel button of the confirm action dialog
      // and tap on it
      await tester.tap(find.byKey(const Key('cancelButton')));
      await tester.pumpAndSettle();
    }
  }

// A custom finder that finds an IconButton with the specified icon data.
  static Finder findIconButtonWithIcon(IconData iconData) {
    return find.byWidgetPredicate(
      (Widget widget) =>
          widget is IconButton &&
          widget.icon is Icon &&
          (widget.icon as Icon).icon == iconData,
    );
  }

  static Future<void> setApplicationLanguage({
    required WidgetTester tester,
    required Language language,
  }) async {
    // Tap the appbar leading popup menu button
    await tester.tap(find.byKey(const Key('appBarRightPopupMenu')));
    await tester.pumpAndSettle();

    if (language == Language.english) {
      // Select English
      await tester.tap(find.byKey(const Key('appBarMenuEnglish')));
    } else {
      // Select French
      await tester.tap(find.byKey(const Key('appBarMenuFrench')));
    }

    await tester.pumpAndSettle();
  }

  static void verifyAudioDataElementsUpdatedInPlaylistJsonFile({
    required String audioPlayerSelectedPlaylistTitle,
    required int playableAudioLstAudioIndex,
    required String audioTitle,
    required int audioPositionSeconds,
    required bool isPaused,
    required bool isPlayingOrPausedWithPositionBetweenAudioStartAndEnd,
    required DateTime? audioPausedDateTime,
  }) {
    final String selectedPlaylistPath = path.join(
      kApplicationPathWindowsTest,
      audioPlayerSelectedPlaylistTitle,
    );

    final selectedPlaylistFilePathName = path.join(
      selectedPlaylistPath,
      '$audioPlayerSelectedPlaylistTitle.json',
    );

    // Load playlist from the json file
    Playlist loadedSelectedPlaylist = JsonDataService.loadFromFile(
      jsonPathFileName: selectedPlaylistFilePathName,
      type: Playlist,
    );

    expect(
        loadedSelectedPlaylist
            .playableAudioLst[playableAudioLstAudioIndex].validVideoTitle,
        audioTitle);

    int actualAudioPositionSeconds = loadedSelectedPlaylist
        .playableAudioLst[playableAudioLstAudioIndex].audioPositionSeconds;

    expect(
        (actualAudioPositionSeconds - audioPositionSeconds).abs() <= 1, isTrue,
        reason:
            "Expected audioPositionSeconds: $audioPositionSeconds, actual: $actualAudioPositionSeconds");

    expect(
        loadedSelectedPlaylist
            .playableAudioLst[playableAudioLstAudioIndex].isPaused,
        isPaused);

    expect(
        loadedSelectedPlaylist.playableAudioLst[playableAudioLstAudioIndex]
            .isPlayingOrPausedWithPositionBetweenAudioStartAndEnd,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd);

    if (audioPausedDateTime == null) {
      expect(
          loadedSelectedPlaylist
              .playableAudioLst[playableAudioLstAudioIndex].audioPausedDateTime,
          audioPausedDateTime);
    } else {
      expect(
          DateTimeUtil.areDateTimesEqualWithinTolerance(
              dateTimeOne: DateTimeUtil.getDateTimeLimitedToSeconds(
                  loadedSelectedPlaylist
                      .playableAudioLst[playableAudioLstAudioIndex]
                      .audioPausedDateTime!),
              dateTimeTwo:
                  DateTimeUtil.getDateTimeLimitedToSeconds(audioPausedDateTime),
              toleranceInSeconds: 1),
          isTrue);
    }
  }

  static void verifyPlaylistDataElementsUpdatedInPlaylistJsonFile({
    required String selectedPlaylistTitle,
    String audioSortFilterParmsNamePlaylistDownloadView = '',
    String audioSortFilterParmsNameAudioPlayerView = '',
    AudioPlayingOrder audioPlayingOrder = AudioPlayingOrder.ascending,
    String playlistDownloadPath = '',
  }) {
    final String selectedPlaylistPath;

    if (playlistDownloadPath.isEmpty) {
      playlistDownloadPath = kPlaylistDownloadRootPathWindowsTest;
      selectedPlaylistPath = path.join(
        playlistDownloadPath,
        selectedPlaylistTitle,
      );
    } else {
      selectedPlaylistPath = playlistDownloadPath;
    }

    final selectedPlaylistFilePathName = path.join(
      selectedPlaylistPath,
      '$selectedPlaylistTitle.json',
    );

    // Load playlist from the json file
    Playlist loadedSelectedPlaylist = JsonDataService.loadFromFile(
      jsonPathFileName: selectedPlaylistFilePathName,
      type: Playlist,
    );

    expect(
        loadedSelectedPlaylist.audioSortFilterParmsNameForPlaylistDownloadView,
        audioSortFilterParmsNamePlaylistDownloadView);

    expect(loadedSelectedPlaylist.audioSortFilterParmsNameForAudioPlayerView,
        audioSortFilterParmsNameAudioPlayerView);

    expect(
      loadedSelectedPlaylist.audioPlayingOrder,
      audioPlayingOrder,
    );
  }

  /// Passing {enclosingWidgetFinder} depends on the context the integration
  /// test which call this method.
  static Future<void> checkAudioTextColor({
    required WidgetTester tester,
    Finder? enclosingWidgetFinder,
    required String audioTitleOrSubTitle,
    required Color? expectedTitleTextColor,
    required Color? expectedTitleTextBackgroundColor,
  }) async {
    // Find the Text widget by its text content
    final Finder textFinder;

    if (enclosingWidgetFinder != null) {
      // Find the Text widget within the enclosing widget
      textFinder = find.descendant(
        of: enclosingWidgetFinder,
        matching: find.text(audioTitleOrSubTitle),
      );
    } else {
      textFinder = find.text(audioTitleOrSubTitle);
    }

    // Retrieve the Text widget
    final Text textWidget = tester.widget(textFinder) as Text;

    // Check if the color of the Text widget is as expected
    expect(textWidget.style?.color, equals(expectedTitleTextColor));
    expect(textWidget.style?.backgroundColor,
        equals(expectedTitleTextBackgroundColor));
  }

  static Future<void> playComment({
    required WidgetTester tester,
    required final Finder gestureDetectorsFinder,
    required int itemIndex,
    required bool typeOnPauseAfterPlay,
    double maxPlayDurationSeconds = 1,
  }) async {
    final Finder playIconButtonFinder = find.descendant(
      of: gestureDetectorsFinder.at(itemIndex),
      matching: find.byKey(const Key('playPauseIconButton')),
    );

    await tester.tap(playIconButtonFinder);
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    await Future.delayed(
        Duration(milliseconds: maxPlayDurationSeconds * 1000 ~/ 1));

    if (typeOnPauseAfterPlay) {
      await tester.tap(playIconButtonFinder);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
    }
  }

  /// [commentPosition] is the position of the comment in the list set to 1 if you want
  /// to play the first comment.
  static Future<void> playCommentFromListAddDialog({
    required WidgetTester tester,
    required int commentPosition, // first = 1, second = 2, ...
    bool mustAudioBePaused = false,
    bool isCommentListAddDialogAlreadyOpen = false,
  }) async {
    if (!isCommentListAddDialogAlreadyOpen) {
      // Tap on the comment icon button to open the comment add list
      // dialog
      final Finder commentInkWellButtonFinder = find.byKey(
        const Key('commentsInkWellButton'),
      );
      await tester.tap(commentInkWellButtonFinder);
      await tester.pumpAndSettle();
    }

    // **UPDATED**: Find the dialog using the ListBody key directly
    // This approach works regardless of the dialog wrapper structure
    final Finder listFinder = find.byKey(const Key('audioCommentsListKey'));

    // Verify the list exists
    if (listFinder.evaluate().isEmpty) {
      throw Exception('Comment list not found. Make sure the dialog is open.');
    }

    // **UPDATED**: Find all play/pause buttons directly using their key
    final Finder playPauseButtonsFinder =
        find.byKey(const Key('playPauseIconButton'));

    // Verify we have enough comments
    final int totalPlayPauseButtons = playPauseButtonsFinder.evaluate().length;
    if (totalPlayPauseButtons < commentPosition) {
      throw Exception(
        'Comment position $commentPosition requested but only $totalPlayPauseButtons comments found',
      );
    }

    // Get the specific play/pause button for the requested comment position
    final Finder targetPlayIconButtonFinder =
        playPauseButtonsFinder.at(commentPosition - 1);

    // Tap on the play/pause icon button to play the audio from the comment
    await tester.tap(targetPlayIconButtonFinder);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    if (mustAudioBePaused) {
      // Tap on the play/pause icon button to pause the audio
      await tester.tap(targetPlayIconButtonFinder);
      await tester.pumpAndSettle();
    }
  }

  static void verifyFileSize({
    required String filePathName,
    required int fileSizeInBytes,
  }) async {
    final file = File(filePathName);

    expect(
      file.lengthSync(),
      fileSizeInBytes,
    ); // Size in bytes
  }

  /// Verify that the picture was added to the playlist and that the
  /// corresponding json file was created in the playlist picture directory.
  ///
  /// [audioForPictureTitleDurationStr] is the audio duration string which is
  /// used to create the audioTitleWithDuration used if [goToAudioPlayerView]
  /// is true.
  ///
  /// [playlistAudioPictureJsonFileNameLst] is the list of json files names
  /// created in the playlist picture directory [playlistPictureJsonFilesDir].
  /// Example: if the playlist has 3 audio's of which 2 were modified with one
  /// or more pictures, the [playlistAudioPictureJsonFileNameLst] has 2 json
  /// files names.
  ///
  /// [audioPictureJsonFileContentLst] is the list of Picture list which are
  /// contained in json files located in the passed playlist picture directory
  /// [playlistPictureJsonFilesDir].
  ///
  /// The [audioForPictureTitleOneLst] is the list of audio titles which are
  /// associated to the picture file name [pictureFileNameOne] in the
  /// application picture json file.
  ///
  /// The [audioForPictureTitleTwoLst] is the list of audio titles which are
  /// associated to the picture file name [pictureFileNameTwo] in the
  /// application picture json file.
  ///
  /// The [audioForPictureTitleThreeLst] is the list of audio titles which are
  /// associated to the picture file name [pictureFileNameThree] in the
  /// application picture json file.
  static Future<void> verifyPictureAddition({
    required WidgetTester tester,
    required String applicationPictureDir,
    required String playlistPictureJsonFilesDir,
    required String audioForPictureTitle,
    required String audioForPictureTitleDurationStr,
    required List<String> playlistAudioPictureJsonFileNameLst,
    List<List<Picture>> audioPictureJsonFileContentLst = const [],
    bool goToAudioPlayerView = true,
    required bool mustPlayableAudioListBeUsed,
    required String pictureFileNameOne,
    List<String> audioForPictureTitleOneLst = const [],
    String pictureFileNameTwo = '',
    List<String> audioForPictureTitleTwoLst = const [],
    String pictureFileNameThree = '',
    List<String> audioForPictureTitleThreeLst = const [],
    bool mustAudioBePaused = false,
  }) async {
    // Now verifying that the playlist picture directory contains
    // the added picture file
    List<String> playlistPicturesLst = DirUtil.listFileNamesInDir(
      directoryPath: playlistPictureJsonFilesDir,
      fileExtension: 'json',
    );

    expect(playlistPicturesLst, playlistAudioPictureJsonFileNameLst);

    // Read the application picture json file and verify its
    // content

    _verifyApplicationPictureJsonMap(
      applicationPictureDir: applicationPictureDir,
      pictureFileNameOne: pictureFileNameOne,
      audioForPictureTitleOneLst: audioForPictureTitleOneLst,
      pictureFileNameTwo: pictureFileNameTwo,
      audioForPictureTitleTwoLst: audioForPictureTitleTwoLst,
      pictureFileNameThree: pictureFileNameThree,
      audioForPictureTitleThreeLst: audioForPictureTitleThreeLst,
    );

    // Verify that the json files created in the playlist picture
    // directory contain the expected content
    _verifyAudioPictureJsonFileContent(
      playlistPictureJsonFilesDir: playlistPictureJsonFilesDir,
      playlistAudioPictureJsonFileNameLst: playlistAudioPictureJsonFileNameLst,
      audioPictureJsonFileContentLst: audioPictureJsonFileContentLst,
    );

    if (goToAudioPlayerView) {
      // Now go to the audio player view
      final Finder audioForPictureTitleListTileTextWidgetFinder =
          find.text(audioForPictureTitle);

      await tester.tap(audioForPictureTitleListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );
    }

    String audioTitleWithDuration;

    if (mustPlayableAudioListBeUsed) {
      // Due to the not working integration test which prevents the
      // audio picture to be displayed, we open and close the playable
      // audio list dialog. This will cause the added picture to be
      // displayed. When a picture is added manually in the Audio Learn
      // application, the picture IS displayed after the 'Add Audio
      // Picture' menu was executed !

      audioTitleWithDuration =
          '$audioForPictureTitle\n$audioForPictureTitleDurationStr';

      await tester.tap(find.text(audioTitleWithDuration));
      await tester.pumpAndSettle();

      // Tap on Close button to close the
      // DisplaySelectableAudioListDialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    }

    // Now that the audio picture was added, verify that the
    // play/pause button is displayed at top of the screen
    expect(
      find.byKey(const Key('picture_displayed_play_pause_button_key')),
      findsOneWidget,
    );

    // Now that the audio picture was added, verify that the
    // regular play/pause button is notdisplayed
    expect(
      find.byKey(const Key('middleScreenPlayPauseButton')),
      findsNothing,
    );

    // Now that the audio picture was added, verify that the
    // audio title with duration is displayed

    audioTitleWithDuration =
        '$audioForPictureTitle\n$audioForPictureTitleDurationStr';

    expect(
      find.text(audioTitleWithDuration),
      findsOneWidget,
    );
  }

  static void _verifyApplicationPictureJsonMap({
    required String applicationPictureDir,
    required String pictureFileNameOne,
    List<String> audioForPictureTitleOneLst = const [],
    String pictureFileNameTwo = '',
    List<String> audioForPictureTitleTwoLst = const [],
    String pictureFileNameThree = '',
    List<String> audioForPictureTitleThreeLst = const [],
    String pictureFileNameFour = '',
    List<String> audioForPictureTitleFourLst = const [],
  }) {
    Map<String, List<String>> applicationPictureJsonMap = _readPictureAudioMap(
      applicationPicturePath: applicationPictureDir,
    );

    List<String> pictureAudioLst =
        applicationPictureJsonMap[pictureFileNameOne] ?? [];

    if (audioForPictureTitleOneLst.isNotEmpty) {
      // Verify that the picture audio list contains the audio title
      // and the audio duration
      expect(
        pictureAudioLst,
        audioForPictureTitleOneLst,
      );
    }

    pictureAudioLst = applicationPictureJsonMap[pictureFileNameTwo] ?? [];

    if (audioForPictureTitleTwoLst.isNotEmpty) {
      // Verify that the picture audio list contains the audio title
      // and the audio duration
      expect(
        pictureAudioLst,
        audioForPictureTitleTwoLst,
      );
    }

    pictureAudioLst = applicationPictureJsonMap[pictureFileNameThree] ?? [];

    if (audioForPictureTitleThreeLst.isNotEmpty) {
      // Verify that the picture audio list contains the audio title
      // and the audio duration
      expect(
        pictureAudioLst,
        audioForPictureTitleThreeLst,
      );
    }

    pictureAudioLst = applicationPictureJsonMap[pictureFileNameFour] ?? [];

    if (audioForPictureTitleThreeLst.isNotEmpty) {
      // Verify that the picture audio list contains the audio title
      // and the audio duration
      expect(
        pictureAudioLst,
        audioForPictureTitleFourLst,
      );
    }
  }

  static void _verifyAudioPictureJsonFileContent({
    required String playlistPictureJsonFilesDir,
    required List<String> playlistAudioPictureJsonFileNameLst,
    required List<List<Picture>> audioPictureJsonFileContentLst,
  }) {
    for (String audioPictureJsonFileName
        in playlistAudioPictureJsonFileNameLst) {
      List<Picture> audioPictureJsonFileContent =
          JsonDataService.loadListFromFile(
        jsonPathFileName:
            "$playlistPictureJsonFilesDir${path.separator}$audioPictureJsonFileName",
        type: Picture,
      ).map((dynamic item) => item as Picture).toList();

      if (audioPictureJsonFileContentLst.isNotEmpty) {
        List<Picture> audioPictureJsonFileContentExpected =
            audioPictureJsonFileContentLst.elementAt(
                playlistAudioPictureJsonFileNameLst
                    .indexOf(audioPictureJsonFileName));

        for (int i = 0; i < audioPictureJsonFileContent.length; i++) {
          expect(
            audioPictureJsonFileContent[i].fileName,
            audioPictureJsonFileContentExpected[i].fileName,
          );
          expect(
            audioPictureJsonFileContent[i].additionToAudioDateTime,
            _isDateTimeWithinRange(
              expectedDateTime: audioPictureJsonFileContentExpected[i]
                  .additionToAudioDateTime,
              secondsRange: 30,
            ),
          );
          expect(
            audioPictureJsonFileContent[i].lastDisplayDateTime,
            _isDateTimeWithinRange(
              expectedDateTime:
                  audioPictureJsonFileContentExpected[i].lastDisplayDateTime,
              secondsRange: 30,
            ),
          );
          expect(
            audioPictureJsonFileContent[i].isDisplayable,
            audioPictureJsonFileContentExpected[i].isDisplayable,
          );
        }
      }
    }
  }

  static Matcher _isDateTimeWithinRange({
    required DateTime expectedDateTime,
    required int secondsRange,
  }) {
    return predicate((DateTime actual) {
      final int difference =
          actual.difference(expectedDateTime).inSeconds.abs();
      return difference <= secondsRange;
    }, 'DateTime within $secondsRange seconds of $expectedDateTime');
  }

  static Map<String, List<String>> _readPictureAudioMap({
    required String applicationPicturePath,
  }) {
    final File jsonFile = File(
        "$applicationPicturePath${path.separator}$kPictureAudioMapFileName");

    try {
      final String content = jsonFile.readAsStringSync();
      final Map<String, dynamic> jsonMap = json.decode(content);

      // Convert the dynamic values back to List<String>
      final Map<String, List<String>> typedMap = {};
      jsonMap.forEach((key, value) {
        if (value is List) {
          typedMap[key] = value.cast<String>();
        }
      });

      return typedMap;
    } catch (e) {
      // ignore: avoid_print
      print('Error reading pictureAudio.json: $e');
      return {};
    }
  }

  static Future<void> verifyPictureSuppression({
    required WidgetTester tester,
    required String applicationPictureDir,
    required String playlistPictureDir,
    required String audioForPictureTitle,
    required String audioPictureJsonFileName,
    required String deletedPictureFileName,
    bool goToAudioPlayerView = true,
    bool isPictureFileNameDeleted = false,
    String pictureFileNameOne = '',
    List<String> audioForPictureTitleOneLst = const [],
    String pictureFileNameTwo = '',
    List<String> audioForPictureTitleTwoLst = const [],
    String pictureFileNameThree = '',
    List<String> audioForPictureTitleThreeLst = const [],
  }) async {
    String pictureJsonFilePathName =
        "$playlistPictureDir${path.separator}$audioPictureJsonFileName";

    if (isPictureFileNameDeleted) {
      // Verify that the picture file name is deleted from the json file
      expect(
        File(pictureJsonFilePathName).existsSync(),
        false,
        reason: 'The json file $pictureJsonFilePathName should not exist',
      );

      return;
    }

    // Verifying the picture json file content of the audio from which
    // the picture was deleted.

    List<Picture> pictureLst = JsonDataService.loadListFromFile(
      jsonPathFileName: pictureJsonFilePathName,
      type: Picture,
    ).map((dynamic item) => item as Picture).toList();

    // Now verifying that the pictureLst does not contains the
    // PPicture whose fileName == deletedPictureFileName.
    for (Picture picture in pictureLst) {
      expect(
        picture.fileName,
        isNot(deletedPictureFileName),
        reason: 'The picture file name should not be $deletedPictureFileName',
      );
    }

    // Now read the application picture json file and verify its
    // content

    _verifyApplicationPictureJsonMap(
      applicationPictureDir: applicationPictureDir,
      pictureFileNameOne: pictureFileNameOne,
      audioForPictureTitleOneLst: audioForPictureTitleOneLst,
      pictureFileNameTwo: pictureFileNameTwo,
      audioForPictureTitleTwoLst: audioForPictureTitleTwoLst,
      pictureFileNameThree: pictureFileNameThree,
      audioForPictureTitleThreeLst: audioForPictureTitleThreeLst,
    );

    if (goToAudioPlayerView) {
      // Now go to the audio player view
      final Finder audioForPictureTitleListTileTextWidgetFinder =
          find.text(audioForPictureTitle);

      await tester.tap(audioForPictureTitleListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );
    }
  }

  /// This method is used as an alternative to calling app.main(). It enables
  /// to download playlists or video audio files from the internet.
  ///
  /// Passing a [forcedLocale] will force the locale to be used in the test. If
  /// [forcedLocale] is null, the language defined in settings.json will be used.
  /// [forcedLocale] can be const Locale('en') or const Locale('fr').
  static Future<AudioDownloadVM> launchIntegrTestAppEnablingInternetAccess({
    required WidgetTester tester,
    Locale? forcedLocale,
    SharedPreferences? mockSharedPreferences,
  }) async {
    SettingsDataService settingsDataService;

    if (mockSharedPreferences != null) {
      settingsDataService = SettingsDataService(
        sharedPreferences: mockSharedPreferences,
        isTest: true,
      );
    } else {
      settingsDataService = SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
        isTest: true,
      );
    }

    // load settings from file which does not exist. This
    // will ensure that the default playlist root path is set
    await settingsDataService.loadSettingsFromFile(
        settingsJsonPathFileName:
            "$kApplicationPathWindowsTest${path.separator}settings.json");

    final WarningMessageVM warningMessageVM = WarningMessageVM();

    final AudioDownloadVM audioDownloadVM = AudioDownloadVM(
      warningMessageVM: warningMessageVM,
      settingsDataService: settingsDataService,
    );

    final PlaylistListVM playlistListVM = PlaylistListVM(
      warningMessageVM: warningMessageVM,
      audioDownloadVM: audioDownloadVM,
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

    final AudioPlayerVM audioPlayerVM = AudioPlayerVM(
      settingsDataService: settingsDataService,
      playlistListVM: playlistListVM,
      commentVM: CommentVM(),
    );

    final DateFormatVM dateFormatVM = DateFormatVM(
      settingsDataService: settingsDataService,
    );

    await setWindowsAppSizeAndPosition(isTest: true);

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
          ChangeNotifierProvider(
            create: (_) => PictureVM(
              settingsDataService: settingsDataService,
            ),
          ),
          ChangeNotifierProvider(create: (_) => playlistListVM),
          ChangeNotifierProvider(create: (_) => warningMessageVM),
          ChangeNotifierProvider(create: (_) => audioPlayerVM),
          ChangeNotifierProvider(create: (_) => dateFormatVM),
          ChangeNotifierProvider(create: (_) => CommentVM()),
        ],
        child: Consumer2<ThemeProviderVM, LanguageProviderVM>(
          builder: (context, themeProvider, languageProvider, child) {
            return MaterialApp(
              title: 'Audio Learn',
              locale: (forcedLocale == null)
                  ? languageProvider.currentLocale
                  : forcedLocale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales:
                  AppLocalizations.supportedLocales, // French only
              theme: ScreenMixin.themeDataDark,
              home: MyHomePage(
                settingsDataService: settingsDataService,
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    return audioDownloadVM;
  }

  /// This method is used as an alternative to calling app.main(). If the real
  /// AudioDownloadVM and not its mock version is passed, it enables to download
  /// playlists or video audio files from the internet.
  ///
  /// Since we maybe have to use a mock AudioDownloadVM, we can not use app.main()
  /// to start the app because app.main() uses the real AudioDownloadVM and we
  /// don't want to make the main.dart file dependent off a mock class.
  ///
  /// Passing a [forcedLocale] will force the locale to be used in the test. If
  /// [forcedLocale] is null, the language defined in settings.json will be used.
  /// [forcedLocale] can be const Locale('en') or const Locale('fr').
  static Future<void> launchIntegrTestAppEnablingInternetAccessWithMock({
    required WidgetTester tester,
    required AudioDownloadVM audioDownloadVM,
    required SettingsDataService settingsDataService,
    required PlaylistListVM playlistListVM,
    required WarningMessageVM warningMessageVM,
    required AudioPlayerVM audioPlayerVM,
    required DateFormatVM dateFormatVM,
    Locale? forcedLocale,
  }) async {
    await setWindowsAppSizeAndPosition(isTest: true);

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
          ChangeNotifierProvider(
            create: (_) => PictureVM(
              settingsDataService: settingsDataService,
            ),
          ),
          ChangeNotifierProvider(create: (_) => playlistListVM),
          ChangeNotifierProvider(create: (_) => warningMessageVM),
          ChangeNotifierProvider(create: (_) => audioPlayerVM),
          ChangeNotifierProvider(create: (_) => dateFormatVM),
          ChangeNotifierProvider(create: (_) => CommentVM()),
        ],
        child: Consumer2<ThemeProviderVM, LanguageProviderVM>(
          builder: (context, themeProvider, languageProvider, child) {
            return MaterialApp(
              title: 'AudioLearn',
              locale: (forcedLocale == null)
                  ? languageProvider.currentLocale
                  : forcedLocale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales:
                  AppLocalizations.supportedLocales, // French only
              theme: ScreenMixin.themeDataDark,
              home: MyHomePage(
                settingsDataService: settingsDataService,
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  static Future<void> invertSortingItemOrder({
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

    // Now, within that ListTile, find the sort option ascending/
    // descending IconButton with key 'sort_ascending_or_descending_button'
    Finder iconButtonFinder = find.descendant(
      of: listTileFinder,
      matching: find.byKey(const Key('sort_ascending_or_descending_button')),
    );

    // Tap on the ascending/descending icon button to convert ascending
    // to descending or descending to ascending sort order.
    await tester.tap(iconButtonFinder);
    await tester.pumpAndSettle();
  }

  /// If app runs on Windows, Linux or MacOS, set the app size
  /// and position.
  static Future<void> setWindowsAppSizeAndPosition({
    required bool isTest,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    if (ScreenMixin.isHardwarePc()) {
      await getScreenList().then((List<Screen> screens) {
        // Assumez que vous voulez utiliser le premier écran (principal)
        final Screen screen = screens.first;
        final Rect screenRect = screen.visibleFrame;

        // Définissez la largeur et la hauteur de votre fenêtre
        double windowWidth = (isTest) ? 900 : 730;
        double windowHeight = (isTest) ? 1700 : 1300;

        // Calculez la position X pour placer la fenêtre sur le côté droit de l'écran
        final double posX = screenRect.right - windowWidth + 10;
        // Optionnellement, ajustez la position Y selon vos préférences
        final double posY = (screenRect.height - windowHeight) / 2;

        final Rect windowRect =
            Rect.fromLTWH(posX, posY, windowWidth, windowHeight);
        setWindowFrame(windowRect);
      });
    }
  }

  static void verifyPlaylistDirectoryContents({
    required String playlistTitle,
    required List<String> expectedAudioFiles,
    required List<String> expectedCommentFiles,
    required List<String> expectedPictureFiles,
    String playlistRootDir = '',
    bool doesPictureAudioMapFileNameExist = false,
    String applicationPictureDir = '',
    String pictureFileNameOne = '',
    List<String> audioForPictureTitleOneLst = const [],
    String pictureFileNameTwo = '',
    List<String> audioForPictureTitleTwoLst = const [],
    String pictureFileNameThree = '',
    List<String> audioForPictureTitleThreeLst = const [],
    String pictureFileNameFour = '',
    List<String> audioForPictureTitleFourLst = const [],
    String pictureFileNameFive = '',
    List<String> audioForPictureTitleFiveLst = const [],
    String pictureFileNameSix = '',
    List<String> audioForPictureTitleSixLst = const [],
  }) {
    String playlistDir;

    if (playlistRootDir.isEmpty) {
      playlistDir =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$playlistTitle";
    } else {
      playlistDir =
          "$kApplicationPathWindowsTest${path.separator}$playlistRootDir${path.separator}$playlistTitle";
    }

    String commentsDir = "$playlistDir${path.separator}$kCommentDirName";
    String picturesDir = "$playlistDir${path.separator}$kPictureDirName";

    // Verify audio files in playlist directory
    List<String> actualAudioFiles = DirUtil.listFileNamesInDir(
      directoryPath: playlistDir,
      fileExtension: 'mp3',
    );
    assert(
      actualAudioFiles.toSet().containsAll(expectedAudioFiles.toSet()),
      "Mismatch in expected and actual audio files in '$playlistDir'.\nExpected: $expectedAudioFiles\nActual: $actualAudioFiles",
    );

    // Verify JSON comment files in comments directory
    List<String> actualCommentFiles = DirUtil.listFileNamesInDir(
      directoryPath: commentsDir,
      fileExtension: 'json',
    );
    assert(
      actualCommentFiles.toSet().containsAll(expectedCommentFiles.toSet()),
      "Mismatch in expected and actual comment files in '$commentsDir'.\nExpected: $expectedCommentFiles\nActual: $actualCommentFiles",
    );

    // Verify image files in pictures directory
    List<String> actualPictureFiles = DirUtil.listFileNamesInDir(
      directoryPath: picturesDir,
      fileExtension: 'json',
    );
    assert(
      actualPictureFiles.toSet().containsAll(expectedPictureFiles.toSet()),
      "Mismatch in expected and actual picture files in '$picturesDir'.\nExpected: $expectedPictureFiles\nActual: $actualPictureFiles",
    );

    // Verify pictureAudioMap.json file existence

    String pictureAudioMapFileName =
        "$kApplicationPathWindowsTest${path.separator}$kPictureDirName${path.separator}$kPictureAudioMapFileName";

    if (doesPictureAudioMapFileNameExist) {
      assert(
        File(pictureAudioMapFileName).existsSync(),
        "The file '$pictureAudioMapFileName' should exist.",
      );

      _verifyApplicationPictureJsonMap(
        applicationPictureDir: applicationPictureDir,
        pictureFileNameOne: pictureFileNameOne,
        audioForPictureTitleOneLst: audioForPictureTitleOneLst,
        pictureFileNameTwo: pictureFileNameTwo,
        audioForPictureTitleTwoLst: audioForPictureTitleTwoLst,
        pictureFileNameThree: pictureFileNameThree,
        audioForPictureTitleThreeLst: audioForPictureTitleThreeLst,
        pictureFileNameFour: pictureFileNameFour,
        audioForPictureTitleFourLst: audioForPictureTitleFourLst,
      );
    } else {
      assert(
        !File(pictureAudioMapFileName).existsSync(),
        "The file '$pictureAudioMapFileName' should not exist.",
      );
    }
  }

  static void verifyPlaylistDirectoryContentsOnAndroid({
    required String playlistTitle,
    required List<String> expectedAudioFiles,
    required List<String> expectedCommentFiles,
    required List<String> expectedPictureFiles,
    bool doesPictureAudioMapFileNameExist = false,
    String pictureFileNameOne = '',
    List<String> audioForPictureTitleOneLst = const [],
    String pictureFileNameTwo = '',
    List<String> audioForPictureTitleTwoLst = const [],
    String pictureFileNameThree = '',
    List<String> audioForPictureTitleThreeLst = const [],
    String pictureFileNameFour = '',
    List<String> audioForPictureTitleFourLst = const [],
  }) {
    String playlistDir;

    playlistDir =
        "$kPlaylistDownloadRootPathAndroidTest${path.separator}$playlistTitle";

    String commentsDir = "$playlistDir${path.separator}$kCommentDirName";
    String picturesDir = "$playlistDir${path.separator}$kPictureDirName";

    // Verify audio files in playlist directory
    List<String> actualAudioFiles = DirUtil.listFileNamesInDir(
      directoryPath: playlistDir,
      fileExtension: 'mp3',
    );
    assert(
      actualAudioFiles.toSet().containsAll(expectedAudioFiles.toSet()),
      "Mismatch in expected and actual audio files in '$playlistDir'.\nExpected: $expectedAudioFiles\nActual: $actualAudioFiles",
    );

    // Verify JSON comment files in comments directory
    List<String> actualCommentFiles = DirUtil.listFileNamesInDir(
      directoryPath: commentsDir,
      fileExtension: 'json',
    );
    assert(
      actualCommentFiles.toSet().containsAll(expectedCommentFiles.toSet()),
      "Mismatch in expected and actual comment files in '$commentsDir'.\nExpected: $expectedCommentFiles\nActual: $actualCommentFiles",
    );

    // Verify image files in pictures directory
    List<String> actualPictureFiles = DirUtil.listFileNamesInDir(
      directoryPath: picturesDir,
      fileExtension: 'json',
    );
    assert(
      actualPictureFiles.toSet().containsAll(expectedPictureFiles.toSet()),
      "Mismatch in expected and actual picture files in '$picturesDir'.\nExpected: $expectedPictureFiles\nActual: $actualPictureFiles",
    );

    // Verify pictureAudioMap.json file existence

    String pictureAudioMapFileName =
        "$kApplicationPathAndroidTest${path.separator}$kPictureDirName${path.separator}$kPictureAudioMapFileName";

    if (doesPictureAudioMapFileNameExist) {
      assert(
        File(pictureAudioMapFileName).existsSync(),
        "The file '$pictureAudioMapFileName' should exist.",
      );

      _verifyApplicationPictureJsonMap(
        applicationPictureDir:
            "$kApplicationPathAndroidTest${path.separator}$kPictureDirName",
        pictureFileNameOne: pictureFileNameOne,
        audioForPictureTitleOneLst: audioForPictureTitleOneLst,
        pictureFileNameTwo: pictureFileNameTwo,
        audioForPictureTitleTwoLst: audioForPictureTitleTwoLst,
        pictureFileNameThree: pictureFileNameThree,
        audioForPictureTitleThreeLst: audioForPictureTitleThreeLst,
        pictureFileNameFour: pictureFileNameFour,
        audioForPictureTitleFourLst: audioForPictureTitleFourLst,
      );
    } else {
      assert(
        !File(pictureAudioMapFileName).existsSync(),
        "The file '$pictureAudioMapFileName' should not exist.",
      );
    }
  }

  static Future<void> verifyPlaylistInfoDialogContent({
    required WidgetTester tester,
    required String playlistTitle,
    required String playlistDownloadAudioSortFilterParmsName,
    required String playlistPlayAudioSortFilterParmsName,
    isPaylistSelected = true,
    String playlistAudioQuality = '',
    String playlistInfoTotalAudioNumber = '',
    String playlistInfoPlayableAudioNumber = '',
    String playlistInfoAudioCommentNumber = '',
    String playlistInfoPlayableAudioTotalDuration = '',
    String playlistInfoPlayableAudioTotalRemainingDuration = '',
    String playlistInfoPlayableAudioTotalFileSize = '',
  }) async {
    Finder playlistToExamineInfoTextWidgetFinder;

    if (isPaylistSelected) {
      // Firt, find the Playlist ListTile Text widget. Two exist
      // since the playlist is selected.
      //
      // For example, "S8 audio" under the 'Youtube Link or Search'
      // text field and "S8 audio" as PlaylistItem
      playlistToExamineInfoTextWidgetFinder = find.text(playlistTitle).at(1);
    } else {
      // First, find the Playlist ListTile Text widget.
      playlistToExamineInfoTextWidgetFinder = find.text(playlistTitle);
    }

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

    // Verify the playlist 'Download Audio sort/filter value
    final Text playlistLastDownloadDateTimeTextWidget = tester.widget<Text>(
        find.byKey(const Key(
            'playlist_info_download_audio_sort_filter_parameters_key')));

    expect(
      playlistLastDownloadDateTimeTextWidget.data,
      playlistDownloadAudioSortFilterParmsName,
    );

    if (playlistAudioQuality.isNotEmpty) {
      // Verify the playlist audio quality
      final Text playlistAudioQualityTextWidget = tester.widget<Text>(
          find.byKey(const Key('playlist_info_audio_quality_key')));

      expect(
        playlistAudioQualityTextWidget.data,
        playlistAudioQuality,
      );
    }

    if (playlistInfoTotalAudioNumber.isNotEmpty) {
      // Verify the playlist total audio number
      final Text playlistInfoTotalAudioNumberTextWidget = tester.widget<Text>(
          find.byKey(const Key('playlist_info_total_audio_number_key')));

      expect(
        playlistInfoTotalAudioNumberTextWidget.data,
        playlistInfoTotalAudioNumber,
      );
    }

    if (playlistInfoPlayableAudioNumber.isNotEmpty) {
      // Verify the playlist playable audio number
      final Text playlistInfoPlayableAudioNumberTextWidget =
          tester.widget<Text>(
              find.byKey(const Key('playlist_info_playable_audio_number_key')));

      expect(
        playlistInfoPlayableAudioNumberTextWidget.data,
        playlistInfoPlayableAudioNumber,
      );
    }

    if (playlistInfoAudioCommentNumber.isNotEmpty) {
      // Verify the playlist audio comment number
      final Text playlistInfoAudioCommentNumberTextWidget = tester.widget<Text>(
          find.byKey(const Key('playlist_info_audio_comment_number_key')));

      expect(
        playlistInfoAudioCommentNumberTextWidget.data,
        playlistInfoAudioCommentNumber,
      );
    }

    if (playlistInfoPlayableAudioTotalDuration.isNotEmpty) {
      // Verify the playlist playable audio total duration
      final Text playlistInfoPlayableAudioTotalDurationTextWidget =
          tester.widget<Text>(find.byKey(
              const Key('playlist_info_playable_audio_total_duration_key')));

      expect(
        playlistInfoPlayableAudioTotalDurationTextWidget.data,
        playlistInfoPlayableAudioTotalDuration,
      );
    }

    if (playlistInfoPlayableAudioTotalRemainingDuration.isNotEmpty) {
      // Verify the playlist playable audio total remaining duration
      final Text playlistInfoPlayableAudioTotalRemainingDurationTextWidget =
          tester.widget<Text>(find.byKey(const Key(
              'playlist_info_playable_audio_total_remaining_duration_key')));

      expect(
        playlistInfoPlayableAudioTotalRemainingDurationTextWidget.data,
        playlistInfoPlayableAudioTotalRemainingDuration,
      );
    }

    if (playlistInfoPlayableAudioTotalFileSize.isNotEmpty) {
      // Verify the playlist playable audio total file size
      final Text playlistInfoPlayableAudioTotalFileSizeTextWidget =
          tester.widget<Text>(find.byKey(
              const Key('playlist_info_playable_audio_total_file_size_key')));

      expect(
        playlistInfoPlayableAudioTotalFileSizeTextWidget.data,
        playlistInfoPlayableAudioTotalFileSize,
      );
    }

    // Now find the ok button of the playlist info dialog
    // and tap on it
    await tester.tap(find.byKey(const Key('playlist_info_ok_button_key')));
    await tester.pumpAndSettle();
  }

  static Future<void> selectAndSaveSortFilterParmsToPlaylist({
    required WidgetTester tester,
    required String sortFilterParmsName,
    required bool saveToPlaylistDownloadView,
    required bool saveToAudioPlayerView,
    bool displayPlaylistListBeforeSavingSFtoPlaylist = false,
    bool selectSortFilterParms = true,
  }) async {
    if (selectSortFilterParms) {
      // Tap on the current dropdown button item to open the dropdown
      // button items list
      await selectSortFilterParmsInDropDownButton(
        tester: tester,
        sortFilterParmsName: sortFilterParmsName,
      );
    }

    if (displayPlaylistListBeforeSavingSFtoPlaylist) {
      // Tap the 'Toggle List' button to display the list of playlists
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();
    }

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
    await tester.tap(
        find.byKey(const Key('saveSortFilterOptionsToPlaylistSaveButton')));
    await tester.pumpAndSettle();
  }

  static Future<void> selectSortFilterParmsInDropDownButton({
    required WidgetTester tester,
    required String sortFilterParmsName,
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
  }

  static Future<Finder> verifyAudioInfoDialog({
    required WidgetTester tester,
    AudioType audioType = AudioType.downloaded,
    bool inAudioPlayerView = false,
    String youtubeChannel = "Jean-Pierre Schnyder",
    String originalVideoTitle = "",
    String videoUploadDate = '',
    String audioDownloadDateTime = '',
    bool isAudioPlayable = true,
    String videoUrl = '',
    String compactVideoDescription = '',
    required String validVideoTitleOrAudioTitle, // valid video title
    String audioEnclosingPlaylistTitle = '',
    String movedFromPlaylistTitle = '',
    String movedToPlaylistTitle = '',
    String copiedFromPlaylistTitle = '',
    String copiedToPlaylistTitle = '',
    String audioDownloadDuration = '',
    String audioDownloadSpeed = '',
    String audioDuration = '',
    String audioPosition = '',
    String audioState = '',
    String lastListenDateTime = '',
    String audioFileName = '',
    String audioFileSize = '',
    bool isMusicQuality = false,
    String audioPlaySpeed = '',
    String audioVolume = '',
    int audioCommentNumber = 0,
    Language language = Language.english,
    bool doDropDown = false,
  }) async {
    // Now we want to tap the popup menu of the Audio ListTile
    // "audio learn test short video one" in order to display
    // the audio info dialog

    // First, find the Audio sublist ListTile Text widget
    final Finder targetAudioListTileTextWidgetFinder =
        find.text(validVideoTitleOrAudioTitle);

    // Then obtain the Audio ListTile widget enclosing the Text widget by
    // finding its ancestor
    final Finder targetAudioListTileWidgetFinder = find.ancestor(
      of: targetAudioListTileTextWidgetFinder,
      matching: find.byType(ListTile),
    );

    if (inAudioPlayerView) {
      // Now find the audio leading menu icon button of the Audio ListTile and tap
      // on it
      final Finder targetAudioListTileLeadingMenuIconButton = find.byKey(
        const Key(
          "appBarLeadingPopupMenuWidget",
        ),
      );

      // Tap the appbar left icon button to open the popup menu
      await tester.tap(targetAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle();
    } else {
      // Now find the audio leading menu icon button of the Audio ListTile and tap
      // on it
      final Finder targetAudioListTileLeadingMenuIconButton = find.descendant(
        of: targetAudioListTileWidgetFinder,
        matching: find.byIcon(Icons.menu),
      );

      // Tap the audio leading menu icon button to open the popup menu
      await tester.tap(targetAudioListTileLeadingMenuIconButton);
      await tester.pumpAndSettle();
    }

    // Now find the audio info popup menu item and tap on it
    final Finder popupDisplayAudioInfoMenuItemFinder =
        find.byKey(const Key("popup_menu_display_audio_info"));

    await tester.tap(popupDisplayAudioInfoMenuItemFinder);
    await tester.pumpAndSettle();

    // Now verifying the display audio info dialog elements

    // Verifying the presence or absence of the audio info dialog
    // label's. The label's depend on the audio type.

    if (language == Language.english) {
      switch (audioType) {
        case AudioType.downloaded:
          expect(find.text('Downloaded Audio Info'), findsOneWidget);
          expect(find.text('Youtube channel'), findsOneWidget);
          expect(find.text('Original video title'), findsOneWidget);
          expect(find.text('Video upload date'), findsOneWidget);
          expect(find.text('Audio downl date time'), findsOneWidget);
          expect(find.text('Playable'), findsOneWidget);
          expect(find.text('Video URL'), findsOneWidget);
          expect(find.text('Compact video description'), findsOneWidget);
          expect(find.text('Valid video title'), findsOneWidget);

          break;
        case AudioType.imported:
          expect(find.text('Imported Audio Info'), findsOneWidget);
          expect(find.text('Youtube channel'), findsNothing);
          expect(find.text('Audio title'), findsOneWidget);
          expect(find.text('Video upload date'), findsNothing);
          expect(find.text('Imported audio date time'), findsOneWidget);
          expect(find.text('Playable'), findsOneWidget);
          expect(find.text('Video URL'), findsNothing);
          expect(find.text('Compact video description'), findsNothing);
          expect(find.text('Valid video title'), findsNothing);

          break;
        case AudioType.textToSpeech:
          expect(find.text('Converted Audio Info'), findsOneWidget);
          expect(find.text('Youtube channel'), findsNothing);
          expect(find.text('Audio title'), findsOneWidget);
          expect(find.text('Video upload date'), findsNothing);
          expect(find.text('Converted text first date time'), findsOneWidget);
          expect(find.text('Playable'), findsOneWidget);
          expect(find.text('Video URL'), findsNothing);
          expect(find.text('Compact video description'), findsNothing);
          expect(find.text('Valid video title'), findsNothing);

          break;
      }
    } else {
      // language == Language.french
      switch (audioType) {
        case AudioType.downloaded:
          expect(
              find.text("Informations sur l'audio téléchargé"), findsOneWidget);
          expect(find.text('Chaîne Youtube'), findsOneWidget);
          expect(find.text('Titre vidéo original'), findsOneWidget);
          expect(find.text('Date mise en ligne'), findsOneWidget);
          expect(find.text('Date/heure téléch'), findsOneWidget);
          expect(find.text('Jouable'), findsOneWidget);
          expect(find.text('URL vidéo'), findsOneWidget);
          expect(find.text('Description vidéo compacte'), findsOneWidget);
          expect(find.text('Titre vidéo valide'), findsOneWidget);

          break;
        case AudioType.imported:
          expect(find.text("Informations sur l'audio importé"), findsOneWidget);
          expect(find.text('Chaîne Youtube'), findsNothing);
          expect(find.text('Titre audio'), findsOneWidget);
          expect(find.text('Date mise en ligne'), findsNothing);
          expect(find.text('Date/heure import'), findsOneWidget);
          expect(find.text('Jouable'), findsOneWidget);
          expect(find.text('URL vidéo'), findsNothing);
          expect(find.text('Description vidéo compacte'), findsNothing);
          expect(find.text('Titre vidéo valide'), findsNothing);

          break;
        case AudioType.textToSpeech:
          expect(
              find.text("Informations sur l'audio converti"), findsOneWidget);
          expect(find.text('Chaîne Youtube'), findsNothing);
          expect(find.text('Titre audio'), findsOneWidget);
          expect(find.text('Date mise en ligne'), findsNothing);
          expect(find.text('Date/heure prem conversion'), findsOneWidget);
          expect(find.text('Jouable'), findsOneWidget);
          expect(find.text('URL vidéo'), findsNothing);
          expect(find.text('Description vidéo compacte'), findsNothing);
          expect(find.text('Titre vidéo valide'), findsNothing);

          break;
      }
    }

    switch (audioType) {
      case AudioType.downloaded:
        // Verify the audio channel name
        Text youtubeChannelTextWidget =
            tester.widget<Text>(find.byKey(const Key('youtubeChannelKey')));
        expect(youtubeChannelTextWidget.data, youtubeChannel);

        // Verify the original video title of the audio
        if (originalVideoTitle.isNotEmpty) {
          final Text originalVideoTitleTextWidget = tester
              .widget<Text>(find.byKey(const Key('originalVideoTitleKey')));
          expect(originalVideoTitleTextWidget.data, originalVideoTitle);
        }

        // Verify the video upload date of the audio
        if (videoUploadDate.isNotEmpty) {
          final Text videoUploadDateTextWidget =
              tester.widget<Text>(find.byKey(const Key('videoUploadDateKey')));
          expect(videoUploadDateTextWidget.data, videoUploadDate);
        }

        // Verify the audio download date time of the audio
        if (audioDownloadDateTime.isNotEmpty) {
          final Text audioDownloadDateTimeTextWidget = tester
              .widget<Text>(find.byKey(const Key('audioDownloadDateTimeKey')));
          expect(audioDownloadDateTimeTextWidget.data, audioDownloadDateTime);
        }

        // Verify if the audio is playable or not
        if (language == Language.english) {
          // In English, the 'isAudioPlayableKey' Text widget contains
          // 'Yes' or 'No'
          final Text isAudioPlayableTextWidget =
              tester.widget<Text>(find.byKey(const Key('isAudioPlayableKey')));
          if (isAudioPlayable) {
            expect(isAudioPlayableTextWidget.data, 'Yes');
          } else {
            expect(isAudioPlayableTextWidget.data, 'No');
          }
        } else {
          // In French, the 'isAudioPlayableKey' Text widget contains
          // 'Oui' or 'Non'
          final Text isAudioPlayableTextWidget =
              tester.widget<Text>(find.byKey(const Key('isAudioPlayableKey')));
          if (isAudioPlayable) {
            expect(isAudioPlayableTextWidget.data, 'Oui');
          } else {
            expect(isAudioPlayableTextWidget.data, 'Non');
          }
        }

        // Verify the video URL of the audio
        if (videoUrl.isNotEmpty) {
          final Text videoUrlTextWidget =
              tester.widget<Text>(find.byKey(const Key('videoUrlKey')));
          expect(videoUrlTextWidget.data, videoUrl);
        }

        // Verify the compact video description of the audio
        if (compactVideoDescription.isNotEmpty) {
          final Text compactVideoDescriptionTextWidget = tester.widget<Text>(
              find.byKey(const Key('compactVideoDescriptionKey')));
          expect(
              compactVideoDescriptionTextWidget.data, compactVideoDescription);
        }

        // Verify the valid video title of the audio
        final Text validVideoTitleTextWidget =
            tester.widget<Text>(find.byKey(const Key('validVideoTitleKey')));
        expect(validVideoTitleTextWidget.data, validVideoTitleOrAudioTitle);

        break;
      case AudioType.imported:
        // Verify the valid video title of the audio
        final Text validVideoTitleTextWidget =
            tester.widget<Text>(find.byKey(const Key('importedAudioTitleKey')));
        expect(validVideoTitleTextWidget.data, validVideoTitleOrAudioTitle);

        // Verify the audio download date time of the audio
        if (audioDownloadDateTime.isNotEmpty) {
          final Text audioDownloadDateTimeTextWidget = tester
              .widget<Text>(find.byKey(const Key('importedAudioDateTimeKey')));
          expect(audioDownloadDateTimeTextWidget.data, audioDownloadDateTime);
        }

        // Verify if the audio is playable or not
        if (language == Language.english) {
          // In English, the 'isAudioPlayableKey' Text widget contains
          // 'Yes' or 'No'
          final Text isAudioPlayableTextWidget =
              tester.widget<Text>(find.byKey(const Key('isAudioPlayableKey')));
          if (isAudioPlayable) {
            expect(isAudioPlayableTextWidget.data, 'Yes');
          } else {
            expect(isAudioPlayableTextWidget.data, 'No');
          }
        } else {
          // In French, the 'isAudioPlayableKey' Text widget contains
          // 'Oui' or 'Non'
          final Text isAudioPlayableTextWidget =
              tester.widget<Text>(find.byKey(const Key('isAudioPlayableKey')));
          if (isAudioPlayable) {
            expect(isAudioPlayableTextWidget.data, 'Oui');
          } else {
            expect(isAudioPlayableTextWidget.data, 'Non');
          }
        }

        break;
      case AudioType.textToSpeech:
        // Verify the valid video title of the audio
        final Text validVideoTitleTextWidget = tester
            .widget<Text>(find.byKey(const Key('convertedAudioTitleKey')));
        expect(validVideoTitleTextWidget.data, validVideoTitleOrAudioTitle);

        // Verify the audio download date time of the audio
        if (audioDownloadDateTime.isNotEmpty) {
          final Text audioDownloadDateTimeTextWidget = tester
              .widget<Text>(find.byKey(const Key('convertedAudioDateTimeKey')));
          expect(audioDownloadDateTimeTextWidget.data, audioDownloadDateTime);
        }

        // Verify if the audio is playable or not
        if (language == Language.english) {
          // In English, the 'isAudioPlayableKey' Text widget contains
          // 'Yes' or 'No'
          final Text isAudioPlayableTextWidget =
              tester.widget<Text>(find.byKey(const Key('isAudioPlayableKey')));
          if (isAudioPlayable) {
            expect(isAudioPlayableTextWidget.data, 'Yes');
          } else {
            expect(isAudioPlayableTextWidget.data, 'No');
          }
        } else {
          // In French, the 'isAudioPlayableKey' Text widget contains
          // 'Oui' or 'Non'
          final Text isAudioPlayableTextWidget =
              tester.widget<Text>(find.byKey(const Key('isAudioPlayableKey')));
          if (isAudioPlayable) {
            expect(isAudioPlayableTextWidget.data, 'Oui');
          } else {
            expect(isAudioPlayableTextWidget.data, 'Non');
          }
        }

        break;
    }

    // Verify the enclosing playlist title of the audio

    if (audioEnclosingPlaylistTitle.isNotEmpty) {
      final Text enclosingPlaylistTitleTextWidget = tester
          .widget<Text>(find.byKey(const Key('enclosingPlaylistTitleKey')));
      expect(
        enclosingPlaylistTitleTextWidget.data,
        audioEnclosingPlaylistTitle,
      );
    }

    // Verify the 'Moved from playlist' title of the audio

    final Text movedFromPlaylistTitleTextWidget =
        tester.widget<Text>(find.byKey(const Key('movedFromPlaylistTitleKey')));
    expect(movedFromPlaylistTitleTextWidget.data, movedFromPlaylistTitle);

    // Verify the 'Moved to playlist title' of the audio

    final Text movedToPlaylistTitleTextWidget =
        tester.widget<Text>(find.byKey(const Key('movedToPlaylistTitleKey')));
    expect(movedToPlaylistTitleTextWidget.data, movedToPlaylistTitle);

    // Verify the 'Copied from playlist' title of the audio

    final Text copiedFromPlaylistTitleTextWidget = tester
        .widget<Text>(find.byKey(const Key('copiedFromPlaylistTitleKey')));
    expect(copiedFromPlaylistTitleTextWidget.data, copiedFromPlaylistTitle);

    // Verify the 'Copied to playlist title' of the audio

    final Text copiedToPlaylistTitleTextWidget =
        tester.widget<Text>(find.byKey(const Key('copiedToPlaylistTitleKey')));
    expect(copiedToPlaylistTitleTextWidget.data, copiedToPlaylistTitle);

    if (audioType == AudioType.downloaded) {
      await tester.drag(
        find.byType(AudioInfoDialog),
        const Offset(
            0, -900), // Negative value for vertical drag to scroll down
      );
      await tester.pumpAndSettle();

      // Verify audio download duration
      if (audioDownloadDuration.isNotEmpty) {
        final Text audioDownloadDurationTextWidget = tester
            .widget<Text>(find.byKey(const Key('audioDownloadDurationKey')));
        expect(audioDownloadDurationTextWidget.data, audioDownloadDuration);
      }

      // Verify audio download speed
      if (audioDownloadSpeed.isNotEmpty) {
        final Text audioDownloadSpeedTextWidget =
            tester.widget<Text>(find.byKey(const Key('audioDownloadSpeedKey')));
        expect(audioDownloadSpeedTextWidget.data, audioDownloadSpeed);
      }
    }

    // Verify the 'Audio duration' of the audio
    if (audioDuration.isNotEmpty) {
      final Text audioDurationTextWidget =
          tester.widget<Text>(find.byKey(const Key('audioDurationKey')));
      expect(audioDurationTextWidget.data, audioDuration);
    }

    // Verify the 'Audio position' of the audio
    if (audioPosition.isNotEmpty) {
      final Text audioPositionTextWidget =
          tester.widget<Text>(find.byKey(const Key('audioPositionKey')));
      expect(audioPositionTextWidget.data, audioPosition);
    }

    // Verify the 'Audio state' of the audio
    if (audioState.isNotEmpty) {
      final Text audioStateTextWidget =
          tester.widget<Text>(find.byKey(const Key('audioStateKey')));
      expect(audioStateTextWidget.data, audioState);
    }

    // Verify the 'Last listen date/time' of the audio
    if (lastListenDateTime.isNotEmpty) {
      final Text lastListenDateTimeTextWidget =
          tester.widget<Text>(find.byKey(const Key('lastListenDateTimeKey')));
      expect(lastListenDateTimeTextWidget.data, lastListenDateTime);
    }

    // Verify the audio file name of the audio
    if (audioFileName.isNotEmpty) {
      final Text audioFileNameTextWidget =
          tester.widget<Text>(find.byKey(const Key('audioFileNameKey')));
      expect(audioFileNameTextWidget.data, audioFileName);
    }

    // Verify the audio file size of the audio
    if (audioFileSize.isNotEmpty) {
      final Text audioFileSizeTextWidget =
          tester.widget<Text>(find.byKey(const Key('audioFileSizeKey')));
      expect(audioFileSizeTextWidget.data, audioFileSize);
    }

    if (language == Language.english) {
      if (isMusicQuality) {
        // Verify the audio quality of the audio
        final Text audioQualityTextWidget =
            tester.widget<Text>(find.byKey(const Key('audioInfoQualityKey')));
        expect(audioQualityTextWidget.data, 'Yes');
      } else {
        final Text audioQualityTextWidget =
            tester.widget<Text>(find.byKey(const Key('audioInfoQualityKey')));
        expect(audioQualityTextWidget.data, 'No');
      }
    } else {
      // language == Language.french
      if (isMusicQuality) {
        // Verify the audio quality of the audio
        final Text audioQualityTextWidget =
            tester.widget<Text>(find.byKey(const Key('audioInfoQualityKey')));
        expect(audioQualityTextWidget.data, 'Oui');
      } else {
        final Text audioQualityTextWidget =
            tester.widget<Text>(find.byKey(const Key('audioInfoQualityKey')));
        expect(audioQualityTextWidget.data, 'Non');
      }
    }

    if (doDropDown) {
      await tester.drag(
        find.byType(AudioInfoDialog),
        const Offset(0, -400), // Positive value for vertical drag to scroll up
      );
      await tester.pumpAndSettle();
    }

    // Verify the play speed of the audio
    if (audioPlaySpeed.isNotEmpty) {
      final Text audioPlaySpeedTextWidget =
          tester.widget<Text>(find.byKey(const Key('audioPlaySpeedKey')));
      expect(audioPlaySpeedTextWidget.data, audioPlaySpeed);
    }

    // Verify the sound volume of the audio
    if (audioVolume.isNotEmpty) {
      final Text audioVolumeTextWidget =
          tester.widget<Text>(find.byKey(const Key('audioVolumeKey')));
      expect(audioVolumeTextWidget.data, audioVolume);
    }

    // Verify the number of comments of the audio
    if (audioCommentNumber > 0) {
      final Text audioNumberOfCommentsTextWidget =
          tester.widget<Text>(find.byKey(const Key('commentsNumberKey')));
      expect(
        audioNumberOfCommentsTextWidget.data,
        audioCommentNumber.toString(),
      );
    }

    // Now find the close button of the audio info dialog
    // and tap on it to close the dialog
    await tester.tap(find.byKey(const Key('audio_info_close_button_key')));
    await tester.pumpAndSettle();

    return targetAudioListTileWidgetFinder;
  }

  static Future<Finder> openPlaylistCommentDialog({
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

    // Now we want to tap the popup menu of the playlist ListTile

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

  static Future<void> checkTextFieldStyleAndEnterText({
    required WidgetTester tester,
    required String textFieldKeyStr,
    required int fontSize,
    required FontWeight fontWeight,
    required String textToEnter,
  }) async {
    // Find the TextField using the Key
    final Finder textFieldFinder = find.byKey(Key(textFieldKeyStr));

    // Retrieve the TextField widget
    final TextField textField = tester.widget<TextField>(textFieldFinder);

    // Extract the TextStyle used in the TextField
    final TextStyle textStyle = textField.style ?? const TextStyle();

    // Check the font size of the TextField
    expect(textStyle.fontSize, fontSize);

    if (fontWeight == FontWeight.normal) {
      // Check the font weight of the TextField
      expect(textStyle.fontWeight, null);
    } else {
      // Check the font weight of the TextField
      expect(textStyle.fontWeight, fontWeight);
    }

    // Now enter the text to the text field
    await tester.enterText(
      textFieldFinder,
      textToEnter,
    );

    await tester.pumpAndSettle();
  }

  static Future<void> copyAudioFromSourceToTargetPlaylist({
    required WidgetTester tester,
    required String sourcePlaylistTitle,
    required String targetPlaylistTitle,
    required String audioToCopyTitle,
  }) async {
    // First, select the source playlist
    await IntegrationTestUtil.selectPlaylist(
      tester: tester,
      playlistToSelectTitle: sourcePlaylistTitle,
    );

    // Click on playlist toggle button to hide the playlist list
    await tester.tap(find.byKey(const Key('playlist_toggle_button')));
    await tester.pumpAndSettle();

    // Now we want to tap the popup menu of the Audio ListTile
    // "audio learn test short video one"

    // First, find the Audio sublist ListTile Text widget
    final Finder sourceAudioListTileTextWidgetFinder =
        find.text(audioToCopyTitle);

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

    // Find the RadioListTile target playlist to which the audio
    // will be copied
    Finder targetPlaylistRadioListTile = find.ancestor(
      of: find.text(targetPlaylistTitle),
      matching: find.byType(ListTile),
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

    // Click on playlist toggle button to display the playlist list
    await tester.tap(find.byKey(const Key('playlist_toggle_button')));
    await tester.pumpAndSettle();
  }

  static void verifyTextFieldContent({
    required WidgetTester tester,
    required String textFieldKeyStr,
    required String expectedTextFieldContent,
  }) {
    // Find the TextField using the Key
    final Finder textFieldFinder = find.byKey(Key(textFieldKeyStr));

    // Retrieve the TextField widget
    final TextField textField = tester.widget<TextField>(textFieldFinder);

    // Check the content of the TextField
    expect(textField.controller?.text, expectedTextFieldContent);
  }

  static void validateSearchIconButton({
    required WidgetTester tester,
    required SearchIconButtonState searchIconButtonState,
  }) {
    if (searchIconButtonState == SearchIconButtonState.disabled) {
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        inkWellButtonKey: 'search_icon_button',
        expectedIcon: Icons.search,
        expectedIconColor:
            Color.fromRGBO(117, 117, 117, 1.0), // RGBA with alpha as a double,
        expectedIconBackgroundColor: Color.fromRGBO(0, 0, 0, 1.0),
      );
    } else if (searchIconButtonState == SearchIconButtonState.enabledInactive) {
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        inkWellButtonKey: 'search_icon_button',
        expectedIcon: Icons.search,
        expectedIconColor: kDarkAndLightEnabledIconColor,
        expectedIconBackgroundColor: Color.fromRGBO(0, 0, 0, 1.0),
      );
    } else {
      // searchIconButtonState == SearchIconButtonState.enabledActive
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        inkWellButtonKey: 'search_icon_button',
        expectedIcon: Icons.search,
        expectedIconColor: Colors.white,
        expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
      );
    }
  }

  static List<String> getPlaylistTitlesFromDialog({
    required WidgetTester tester,
  }) {
    final Iterable<ListTile> listTiles =
        tester.widgetList<ListTile>(find.byType(ListTile));

    return listTiles
        .where(
            (tile) => tile.title is Text && (tile.title as Text).data != null)
        .map((tile) {
      final Text titleText = tile.title as Text;
      return titleText.data!;
    }).toList();
  }

  static Finder verifyCommentsInCommentListDialog({
    required WidgetTester tester,
    required Finder commentListDialogFinder,
    required int commentsNumber,
    required List<String> expectedTitlesLst,
    required List<String> expectedContentsLst,
    required List<String> expectedStartPositionsLst,
    required List<String> expectedEndPositionsLst,
    required List<String> expectedCreationDatesLst,
    required List<String> expectedUpdateDatesLst,
  }) {
    // **UPDATED**: Since commentListDialogFinder is already pointing to the ListBody
    // (using the 'audioCommentsListKey'), we can use it directly instead of
    // looking for ListBody as a descendant
    final Finder listFinder = commentListDialogFinder;

    // **UPDATED**: More robust way to find comment items
    // Instead of relying on GestureDetector count, find comment items directly
    final Finder commentTitlesFinder = find.descendant(
      of: listFinder,
      matching: find.byKey(const Key('commentTitleKey')),
    );

    // Verify we have the expected number of comments
    expect(
      commentTitlesFinder,
      findsNWidgets(commentsNumber),
      reason:
          'Expected $commentsNumber comments but found ${commentTitlesFinder.evaluate().length}',
    );

    // Verify content of each comment
    for (var i = 0; i < commentsNumber; i++) {
      // Find specific comment elements by index
      final Finder specificCommentTitleFinder = commentTitlesFinder.at(i);

      // Find the parent GestureDetector of this comment title
      final Finder commentGestureDetectorFinder = find
          .ancestor(
            of: specificCommentTitleFinder,
            matching: find.byType(GestureDetector),
          )
          .first;

      // Find all elements within this specific comment
      final Finder commentContentFinder = find.descendant(
        of: commentGestureDetectorFinder,
        matching: find.byKey(const Key('commentTextKey')),
      );

      final Finder commentStartPositionFinder = find.descendant(
        of: commentGestureDetectorFinder,
        matching: find.byKey(const Key('commentStartPositionKey')),
      );

      final Finder commentEndPositionFinder = find.descendant(
        of: commentGestureDetectorFinder,
        matching: find.byKey(const Key('commentEndPositionKey')),
      );

      final Finder commentCreationDateFinder = find.descendant(
        of: commentGestureDetectorFinder,
        matching: find.byKey(const Key('creation_date_key')),
      );

      final Finder commentUpdateDateFinder = find.descendant(
        of: commentGestureDetectorFinder,
        matching: find.byKey(const Key('last_update_date_key')),
      );

      // Verify the text in the title, content, and position of each comment
      expect(
        tester.widget<Text>(specificCommentTitleFinder).data,
        expectedTitlesLst[i],
        reason: 'Comment title mismatch at index $i',
      );

      if (expectedContentsLst[i].isNotEmpty) {
        expect(
          tester.widget<Text>(commentContentFinder).data,
          expectedContentsLst[i],
          reason: 'Comment content mismatch at index $i',
        );
      }

      expect(
        tester.widget<Text>(commentStartPositionFinder).data,
        expectedStartPositionsLst[i],
        reason: 'Comment start position mismatch at index $i',
      );

      expect(
        tester.widget<Text>(commentEndPositionFinder).data,
        expectedEndPositionsLst[i],
        reason: 'Comment end position mismatch at index $i',
      );

      expect(
        tester.widget<Text>(commentCreationDateFinder).data,
        expectedCreationDatesLst[i],
        reason: 'Comment creation date mismatch at index $i',
      );

      if (expectedUpdateDatesLst[i].isNotEmpty) {
        // if the update date equals the creation date, the Text widget
        // is not displayed
        expect(
          tester.widget<Text>(commentUpdateDateFinder).data,
          expectedUpdateDatesLst[i],
          reason: 'Comment update date mismatch at index $i',
        );
      }
    }

    // Return all comment GestureDetectors for backward compatibility
    return find.descendant(
      of: listFinder,
      matching: find.byType(GestureDetector),
    );
  }

  static void verifyPictureAudioMapBeforePlaylistDeletion({
    required PictureVM pictureVM,
  }) {
    // Load the application picture audio map from the
    // application picture audio map json file.
    Map<String, List<String>> applicationPictureAudioMap =
        pictureVM.readAppPictureAudioMap();

    // Verify application picture audio map

    expect(applicationPictureAudioMap.length, 6);
    expect(
      applicationPictureAudioMap.containsKey("Jean-Pierre.jpg"),
      true,
    );
    expect(
      applicationPictureAudioMap.containsKey(
          "Bora_Bora_2560_1440_Youtube_2 - Voyage vers l'Inde intérieure.jpg"),
      true,
    );
    expect(
      applicationPictureAudioMap.containsKey("Sam Altman.jpg"),
      true,
    );
    expect(
      applicationPictureAudioMap.containsKey("Jésus mon Amour.jpg"),
      true,
    );
    expect(
      applicationPictureAudioMap.containsKey("Jésus le Dieu vivant.jpg"),
      true,
    );
    expect(
      applicationPictureAudioMap.containsKey("Jésus je T'adore.jpg"),
      true,
    );

    List pictureAudioMapLst =
        (applicationPictureAudioMap["Jean-Pierre.jpg"] as List);
    expect(pictureAudioMapLst.length, 1);
    expect(
      pictureAudioMapLst[0],
      "Restore- short - test - playlist|250518-164035-Really short video 23-07-01",
    );

    pictureAudioMapLst = (applicationPictureAudioMap[
            "Bora_Bora_2560_1440_Youtube_2 - Voyage vers l'Inde intérieure.jpg"]
        as List);
    expect(pictureAudioMapLst.length, 2);
    expect(
      pictureAudioMapLst[0],
      "Restore- short - test - playlist|250518-164039-morning _ cinematic video 23-07-01",
    );
    expect(
      pictureAudioMapLst[1],
      "Restore- short - test - playlist|250518-164035-Really short video 23-07-01",
    );

    pictureAudioMapLst = (applicationPictureAudioMap["Sam Altman.jpg"] as List);
    expect(pictureAudioMapLst.length, 2);
    expect(
      pictureAudioMapLst[0],
      "A restaurer|250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12",
    );
    expect(
      pictureAudioMapLst[1],
      "A restaurer|250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12",
    );

    pictureAudioMapLst =
        (applicationPictureAudioMap["Jésus mon Amour.jpg"] as List);
    expect(pictureAudioMapLst.length, 1);
    expect(
      pictureAudioMapLst[0],
      "A restaurer|250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09",
    );

    pictureAudioMapLst =
        (applicationPictureAudioMap["Jésus le Dieu vivant.jpg"] as List);
    expect(pictureAudioMapLst.length, 3);
    expect(
      pictureAudioMapLst[0],
      "A restaurer|250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09",
    );
    expect(
      pictureAudioMapLst[1],
      "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09",
    );
    expect(
      pictureAudioMapLst[2],
      "Restore- short - test - playlist|250518-164043-People Talking at The Table _ Free Video Loop 19-09-28",
    );

    pictureAudioMapLst =
        (applicationPictureAudioMap["Jésus je T'adore.jpg"] as List);
    expect(pictureAudioMapLst.length, 1);
    expect(
      pictureAudioMapLst[0],
      "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09",
    );
  }

  static void verifyPictureAudioMapAfterPlaylistDeletion({
    required PictureVM pictureVM,
  }) {
    // Load the application picture audio map from the
    // application picture audio map json file.
    Map<String, List<String>> applicationPictureAudioMap =
        pictureVM.readAppPictureAudioMap();

    // Verify application picture audio map

    expect(applicationPictureAudioMap.length, 4);
    expect(
      applicationPictureAudioMap.containsKey("Jean-Pierre.jpg"),
      false,
    );
    expect(
      applicationPictureAudioMap.containsKey(
          "Bora_Bora_2560_1440_Youtube_2 - Voyage vers l'Inde intérieure.jpg"),
      false,
    );
    expect(
      applicationPictureAudioMap.containsKey("Sam Altman.jpg"),
      true,
    );
    expect(
      applicationPictureAudioMap.containsKey("Jésus mon Amour.jpg"),
      true,
    );
    expect(
      applicationPictureAudioMap.containsKey("Jésus le Dieu vivant.jpg"),
      true,
    );
    expect(
      applicationPictureAudioMap.containsKey("Jésus je T'adore.jpg"),
      true,
    );

    List pictureAudioMapLst =
        (applicationPictureAudioMap["Sam Altman.jpg"] as List);
    expect(pictureAudioMapLst.length, 2);
    expect(
      pictureAudioMapLst[0],
      "A restaurer|250213-083024-Sam Altman prédit la FIN de 99% des développeurs humains (c'estpour2025...) 25-02-12",
    );
    expect(
      pictureAudioMapLst[1],
      "A restaurer|250224-131619-L'histoire secrète derrière la progression de l'IA 25-02-12",
    );

    pictureAudioMapLst =
        (applicationPictureAudioMap["Jésus mon Amour.jpg"] as List);
    expect(pictureAudioMapLst.length, 1);
    expect(
      pictureAudioMapLst[0],
      "A restaurer|250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09",
    );

    pictureAudioMapLst =
        (applicationPictureAudioMap["Jésus le Dieu vivant.jpg"] as List);
    expect(pictureAudioMapLst.length, 2);
    expect(
      pictureAudioMapLst[0],
      "A restaurer|250224-132737-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09",
    );
    expect(
      pictureAudioMapLst[1],
      "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09",
    );

    pictureAudioMapLst =
        (applicationPictureAudioMap["Jésus je T'adore.jpg"] as List);
    expect(pictureAudioMapLst.length, 1);
    expect(
      pictureAudioMapLst[0],
      "local|250213-083015-Un fille revient de la mort avec un message HORRIFIANT de Jésus - Témoignage! 25-02-09",
    );
  }

  static Future<void> verifyNoPlaylistSelected() async {
    final SettingsDataService settingsDataService = SettingsDataService(
      sharedPreferences: await SharedPreferences.getInstance(),
      isTest: true,
    );

    // load settings from file which does not exist. This
    // will ensure that the default playlist root path is set
    await settingsDataService.loadSettingsFromFile(
        settingsJsonPathFileName:
            "$kApplicationPathWindowsTest${path.separator}settings.json");

    final WarningMessageVM warningMessageVM = WarningMessageVM();

    final AudioDownloadVM audioDownloadVM = AudioDownloadVM(
      warningMessageVM: warningMessageVM,
      settingsDataService: settingsDataService,
    );

    final PlaylistListVM playlistListVM = PlaylistListVM(
      warningMessageVM: warningMessageVM,
      audioDownloadVM: audioDownloadVM,
      commentVM: CommentVM(),
      pictureVM: PictureVM(
        settingsDataService: settingsDataService,
      ),
      settingsDataService: settingsDataService,
    );

    expect(playlistListVM.getSelectedPlaylists().length, 0);
  }

  static void verifyPictureAudioMapAfterPlaylistRestoration({
    required PictureVM pictureVM,
  }) {
    // Load the application picture audio map from the
    // application picture audio map json file.
    Map<String, List<String>> applicationPictureAudioMap =
        pictureVM.readAppPictureAudioMap();

    // Verify application picture audio map

    expect(applicationPictureAudioMap.length, 3);
    expect(
      applicationPictureAudioMap.containsKey("Jean-Pierre.jpg"),
      true,
    );
    expect(
      applicationPictureAudioMap.containsKey(
          "Bora_Bora_2560_1440_Youtube_2 - Voyage vers l'Inde intérieure.jpg"),
      true,
    );
    expect(
      applicationPictureAudioMap.containsKey("Jésus le Dieu vivant.jpg"),
      true,
    );

    List pictureAudioMapLst =
        (applicationPictureAudioMap["Jean-Pierre.jpg"] as List);
    expect(pictureAudioMapLst.length, 2);
    expect(
      pictureAudioMapLst[0],
      "Restore- short - test - playlist|250518-164035-Really short video 23-07-01",
    );
    expect(
      pictureAudioMapLst[1],
      "Local restore- short - test - playlist|250518-164035-Really short video 23-07-01",
    );

    pictureAudioMapLst = (applicationPictureAudioMap[
            "Bora_Bora_2560_1440_Youtube_2 - Voyage vers l'Inde intérieure.jpg"]
        as List);
    expect(pictureAudioMapLst.length, 4);
    expect(
      pictureAudioMapLst[0],
      "Restore- short - test - playlist|250518-164039-morning _ cinematic video 23-07-01",
    );
    expect(
      pictureAudioMapLst[1],
      "Restore- short - test - playlist|250518-164035-Really short video 23-07-01",
    );
    expect(
      pictureAudioMapLst[2],
      "Local restore- short - test - playlist|250518-164039-morning _ cinematic video 23-07-01",
    );
    expect(pictureAudioMapLst[3],
        "Local restore- short - test - playlist|250518-164035-Really short video 23-07-01");

    pictureAudioMapLst =
        (applicationPictureAudioMap["Jésus le Dieu vivant.jpg"] as List);
    expect(pictureAudioMapLst.length, 3);
    expect(
      pictureAudioMapLst[0],
      "Restore- short - test - playlist|250518-164043-People Talking at The Table _ Free Video Loop 19-09-28",
    );
    expect(
      pictureAudioMapLst[1],
      "Local restore- short - test - playlist|250518-164043-People Talking at The Table _ Free Video Loop 19-09-28",
    );
    expect(pictureAudioMapLst[2],
        "Prières du Maître|Omraam Mikhaël Aïvanhov  'Je vivrai d’après l'amour!'");
  }

  /// {audioSpeed} can only be one of the following values: 0.7, 1.0, 1.25, 1.5.
  static Future<void> setAudioSpeed({
    required WidgetTester tester,
    double audioSpeed = 0.0,
    int minusTapNumber = 0,
    int plusTapNumber = 0,
  }) async {
    // Now open the audio play speed dialog
    await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
    await tester.pumpAndSettle();

    if (audioSpeed == 0.7 ||
        audioSpeed == 1.0 ||
        audioSpeed == 1.25 ||
        audioSpeed == 1.5) {
      // Now select the ...x play speed
      await tester.tap(find.text('${audioSpeed}x'));
      await tester.pumpAndSettle();
    }

    if (minusTapNumber != 0) {
      // Now select the custom play speed
      for (int i = 0; i < minusTapNumber; i++) {
        // Tap on the minus button to decrease the speed
        await tester.tap(find.byKey(const Key('minusButtonKey')));
        await tester.pumpAndSettle();
      }
    } else if (plusTapNumber != 0) {
      // Now select the custom play speed
      for (int i = 0; i < plusTapNumber; i++) {
        // Tap on the plus button to increase the speed
        await tester.tap(find.byKey(const Key('plusButtonKey')));
        await tester.pumpAndSettle();
      }
    } else {
      return;
    }

    // And click on the Ok button
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
  }

  static Future<void> verifySetValueToTargetDialog({
    required WidgetTester tester,
    String? dialogTitle,
    bool isHelpIconPresent = false,
    String? dialogMessage,
    bool closeDialog = false,
  }) async {
    if (dialogTitle != null) {
      // Verify the displayed dialog title
      expect(
        tester
            .widget<Text>(find.byKey(
              const Key('setValueToTargetDialogTitleKey'),
            ))
            .data,
        dialogTitle,
      );
    }

    if (isHelpIconPresent) {
      // Verify the presence of the help icon button
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
    }

    if (dialogMessage != null) {
      // Verify the displayed dialog message
      expect(
        tester
            .widget<Text>(find.byKey(
              const Key('setValueToTargetDialogKey'),
            ))
            .data,
        dialogMessage,
      );
    }

    if (closeDialog) {
      // Tap on the Cancel button of the MP3 Restoration dialog
      await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
      await tester.pumpAndSettle();
      return;
    }
  }
}

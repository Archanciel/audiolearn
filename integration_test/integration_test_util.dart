import 'dart:io';

import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/services/json_data_service.dart';
import 'package:audiolearn/utils/date_time_util.dart';
import 'package:audiolearn/views/widgets/audio_playable_list_dialog.dart';
import 'package:audiolearn/views/widgets/warning_message_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:audiolearn/main.dart' as app;
import 'package:yaml/yaml.dart';

class IntegrationTestUtil {
  static const Color fullyPlayedAudioTitleColor = kSliderThumbColorInDarkMode;
  static const Color currentlyPlayingAudioTitleTextColor = Colors.white;
  static const Color currentlyPlayingAudioTitleTextBackgroundColor =
      Colors.blue;
  static const Color unplayedAudioTitleTextColor = Colors.white;
  static const Color partiallyPlayedAudioTitleTextdColor = Colors.blue;
  static String audioplayersVersion = '';

  /// This method is necessary due to replacing audioplayers 5.2.1 by
  /// audioplayers 6.1.0.
  static Future<void> pumpAndSettleDueToAudioPlayers({
    required WidgetTester tester,
    int additionalMilliseconds = 0,
  }) async {
    if (audioplayersVersion == '') {
      audioplayersVersion = await getAudioplayersVersion();
    }

    if (audioplayersVersion == '^6.1.0') {
      await tester.pumpAndSettle(
        Duration(
          milliseconds: 1200 + additionalMilliseconds,
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
    } else {
      await tester.pumpAndSettle(
        Duration(
          milliseconds: 200 + additionalMilliseconds,
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
  String actualPositionTimeString = tester.widget<Text>(textWidgetFinder).data!;
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

    // First, find the Youtube playlist ListTile Text widget
    final Finder youtubePlaylistListTileTextWidgetFinder =
        find.text(playlistTitle);

    // Then obtain the Youtube source playlist ListTile widget
    // enclosing the Text widget by finding its ancestor
    final Finder youtubePlaylistListTileWidgetFinder = find.ancestor(
      of: youtubePlaylistListTileTextWidgetFinder,
      matching: find.byType(ListTile),
    );

    final Finder firstPlaylistListTileLeadingMenuIconButton = find.descendant(
      of: youtubePlaylistListTileWidgetFinder,
      matching: find.byIcon(Icons.menu),
    );

    // Tap the leading menu icon button to open the popup menu
    await tester.tap(firstPlaylistListTileLeadingMenuIconButton);
    await tester.pumpAndSettle();

    // Now find the delete playlist popup menu item and tap on it
    final Finder popupFilteredAudioActionPlaylistMenuItem =
        find.byKey(const Key("popup_menu_filtered_audio_actions"));

    await tester.tap(popupFilteredAudioActionPlaylistMenuItem);
    await tester.pumpAndSettle();

    // Now find the delete playlist popup menu item and tap on it
    final Finder popupDeletePlaylistSubMenuItem =
        find.byKey(Key(playlistSubMenuKeyStr));

    await tester.tap(popupDeletePlaylistSubMenuItem);
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
        audioTitle!,
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

  static Finder findAudioItemInkWellWidget(String audioTitle) {
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
  }) async {
    // Purge the test playlist directory if it exists so that the
    // playlist list is empty
    DirUtil.deleteFilesInDirAndSubDirs(
      rootPath: kPlaylistDownloadRootPathWindowsTest,
    );

    if (savedTestDataDirName != null) {
      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}$savedTestDataDirName",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    }

    if (replacePlaylistJsonFileName != null) {
      // Copy the test initial audio data to the app dir
      final String playlistPath =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$selectedPlaylistTitle${path.separator}";
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
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

    await app.main(['test']);
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
  }) async {
    final String selectedPlaylistPath = path.join(
      kPlaylistDownloadRootPathWindowsTest,
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

    // Tap the appbar leading popup menu button
    await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
    await tester.pumpAndSettle();

    // find the update playlist JSON file menu item and tap on it
    await tester.tap(find.byKey(const Key('update_playlist_json_dialog_item')));
    await tester.pumpAndSettle();
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

  static Future<void> verifyAudioMenuItemsState({
    required WidgetTester tester,
    required bool areAudioMenuItemsDisabled,
    required AudioLearnAppViewType audioLearnAppViewType,
  }) async {
    if (areAudioMenuItemsDisabled) {
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

      // The save sort and filter audio parameters in playlist menu item
      // is currently disabled in the audio player view
      // verifyWidgetIsEnabled(
      //   tester: tester,
      //   widgetKeyStr: 'save_sort_and_filter_audio_parms_in_playlist_item',
      // );
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
      // For InkWell button, check the onTap property
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
    required bool isEnabled,
    required AudioLearnAppViewType audioLearnAppViewType,
    required String setAudioSpeedTextButtonValue,
  }) async {
    if (isEnabled) {
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

    if (isEnabled) {
      // Open the audio popup menu
      await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
      await tester.pumpAndSettle();

      // since the selected local playlist has audio, the
      // audio menu items are enabled
      await verifyAudioMenuItemsState(
        tester: tester,
        areAudioMenuItemsDisabled: false,
        audioLearnAppViewType: audioLearnAppViewType,
      );
    }
  }

  static Future<void> verifyDisplayedWarningAndCloseIt({
    required WidgetTester tester,
    required String warningDialogMessage,
    bool isWarningConfirming = false,
  }) async {
    // Ensure the warning dialog is shown
    final Finder warningMessageDisplayDialogFinder =
        find.byType(WarningMessageDisplayDialog);
    expect(warningMessageDisplayDialogFinder, findsOneWidget);

    // Check the value of the warning dialog title

    Text warningDialogTitle =
        tester.widget(find.byKey(const Key('warningDialogTitle')));

    if (isWarningConfirming) {
      expect(warningDialogTitle.data, 'CONFIRMATION');
    } else {
      expect(warningDialogTitle.data, 'WARNING');
    }

    // Check the value of the warning dialog message
    expect(
      tester.widget<Text>(find.byKey(const Key('warningDialogMessage'))).data,
      warningDialogMessage,
    );

    // Close the warning dialog by tapping on the Ok button
    await tester.tap(find.byKey(const Key('warningDialogOkButton')));
    await tester.pumpAndSettle();
  }

  static Future<void> selectPlaylist({
    required WidgetTester tester,
    required String playlistToSelectTitle,
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

    // Tap the ListTile Playlist checkbox to select it
    await tester.tap(playlistListTileCheckboxWidgetFinder);
    await tester.pumpAndSettle();
  }

  static void checkPlaylistAndAudioTitlesOrderInListTile({
    required WidgetTester tester,
    required List<String>? playlistTitlesOrderedLst,
    required List<String>? audioTitlesOrderedLst,
    int firstPlaylistListTileIndex = 0,
    int firstAudioListTileIndex = 3,
  }) {
    // Obtains all the ListTile widgets present in the playlist
    // download view
    final Finder listTilesFinder = find.byType(ListTile);

    if (playlistTitlesOrderedLst != null) {
      for (String title in playlistTitlesOrderedLst) {
        Finder playlistTitleTextFinder = find.descendant(
          of: listTilesFinder.at(firstPlaylistListTileIndex++),
          matching: find.byType(Text),
        );

        expect(
          // 2 Text widgets exist in playlist ListTile: the title and sub title
          tester.widget<Text>(playlistTitleTextFinder.at(0)).data,
          title,
        );
      }
    }

    if (audioTitlesOrderedLst != null) {
      for (String title in audioTitlesOrderedLst) {
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
    }
  }

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

    // If the list is empty, check that no ListTile is present
    if (audioOrPlaylistTitlesOrderedLst.isEmpty) {
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
        tester.widget<Text>(playlistTitleTextFinder.at(1)).data,
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
    // First, set the application language to French
    // Tap the appbar leading popup menu button
    await tester.tap(find.byKey(const Key('appBarRightPopupMenu')));
    await tester.pumpAndSettle();

    // Select French
    await tester.tap(find.byKey(const Key('appBarMenuFrench')));
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
      kPlaylistDownloadRootPathWindowsTest,
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
}

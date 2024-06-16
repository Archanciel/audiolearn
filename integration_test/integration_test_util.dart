import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/services/json_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:audiolearn/main.dart' as app;

class IntegrationTestUtil {
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

    // Tap the 'Toggle List' button to show the list. If the list
    // is not opened, checking that a ListTile with the title of
    // the playlist was added to the list will fail
    await tester.tap(find.byKey(const Key('playlist_toggle_button')));
    await tester.pumpAndSettle();

    if (selectedPlaylistTitle != null) {
      // Find the ListTile Playlist containing the playlist which
      // contains the audio to play

      // First, find the Playlist ListTile Text widget
      final Finder audioPlayerSelectedPlaylistFinder =
          find.text(selectedPlaylistTitle);

      // Then obtain the Playlist ListTile widget enclosing the Text
      // widget by finding its ancestor
      final Finder selectedPlaylistListTileWidgetFinder = find.ancestor(
        of: audioPlayerSelectedPlaylistFinder,
        matching: find.byType(ListTile),
      );

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
        // so that the playlist audios are listed
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

    // open the popup menu
    await tester.tap(find.byKey(const Key('audio_popup_menu_button')));
    await tester.pumpAndSettle();

    // find the update playlist JSON file menu item and tap on it
    await tester.tap(find.byKey(const Key('update_playlist_json_dialog_item')));
    await tester.pumpAndSettle();
  }
}

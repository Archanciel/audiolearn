import 'dart:io';

import 'package:audiolearn/models/comment.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/services/json_data_service.dart';
import 'package:audiolearn/utils/date_time_parser.dart';
import 'package:audiolearn/utils/date_time_util.dart';
import 'package:audiolearn/views/audio_player_view.dart';
import 'package:audiolearn/views/widgets/comment_add_edit_dialog_widget.dart';
import 'package:audiolearn/views/widgets/comment_list_add_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;
import 'package:audiolearn/constants.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:audiolearn/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

import '../test/util/test_utility.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('play/pause/start/end tests', () {
    testWidgets(
        'Clicking on audio title to open AudioPlayerView. Then check play/pause button conversion only.',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_2_shorts_test';
      const String lastDownloadedAudioTitle = 'morning _ cinematic video';

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the lastly downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the currently paused audio

      // First, get the lastly downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder lastDownloadedAudioListTileTextWidgetFinder =
          find.text(lastDownloadedAudioTitle);

      await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify if the play button changes to pause button
      expect(find.byIcon(Icons.pause), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets(
        'Clicking on audio title to open AudioPlayerView. Then play audio during 5 seconds and then pause it. Then click on |<, and then on |> button',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_2_shorts_test';
      const String lastDownloadedAudioTitle = 'morning _ cinematic video';

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the lastly downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the currently not played audio

      // First, get the lastly downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder lastDownloadedAudioListTileTextWidgetFinder =
          find.text(lastDownloadedAudioTitle);

      await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now verify if the displayed audio position and remaining
      // duration are correct

      Text audioPositionText = tester
          .widget<Text>(find.byKey(const Key('audioPlayerViewAudioPosition')));
      expect(audioPositionText.data, '0:00');

      Text audioRemainingDurationText = tester.widget<Text>(
          find.byKey(const Key('audioPlayerViewAudioRemainingDuration')));
      expect(audioRemainingDurationText.data, '0:59');

      verifyAudioDataElementsUpdatedInJsonFile(
        audioPlayerSelectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: 0,
        audioTitle: lastDownloadedAudioTitle,
        audioPositionSeconds: 0,
        isPaused: true,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        audioPausedDateTime: null,
      );

      // Now play the audio and wait 5 seconds
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      verifyAudioDataElementsUpdatedInJsonFile(
        audioPlayerSelectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: 0,
        audioTitle: lastDownloadedAudioTitle,
        audioPositionSeconds: 0,
        isPaused: false,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: true,
        audioPausedDateTime: null,
      );

      // Verify if the play button changed to pause button
      Finder pauseIconFinder = find.byIcon(Icons.pause);
      expect(pauseIconFinder, findsOneWidget);

      // Now pause the audio and wait 1 second
      await tester.tap(pauseIconFinder);
      await tester.pumpAndSettle();

      DateTime pausedAudioAtDateTime = DateTime.now();

      verifyAudioDataElementsUpdatedInJsonFile(
        audioPlayerSelectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: 0,
        audioTitle: lastDownloadedAudioTitle,
        audioPositionSeconds: 5,
        isPaused: true,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: true,
        audioPausedDateTime: pausedAudioAtDateTime,
      );

      await Future.delayed(const Duration(seconds: 1));

      audioPositionText = tester
          .widget<Text>(find.byKey(const Key('audioPlayerViewAudioPosition')));
      Duration audioPositionDurationAfterPauseActual =
          DateTimeParser.parseMMSSDuration(audioPositionText.data ?? '')!;

      audioRemainingDurationText = tester.widget<Text>(
          find.byKey(const Key('audioPlayerViewAudioRemainingDuration')));
      Duration audioRemainingDurationAfterPauseActual =
          DateTimeParser.parseMMSSDuration(
              audioRemainingDurationText.data ?? '')!;

      Duration sumDurations = audioPositionDurationAfterPauseActual +
          audioRemainingDurationAfterPauseActual;

      // Check if the sum of the actual audio position duration
      // and the actual audio remaining duration is equal to 58 or
      // 59 seconds which is the total duration of the listened
      // audio minus 1 second. Checking the value of the audio
      // position and remaining duration is not safe.
      expect(sumDurations >= const Duration(seconds: 58), isTrue);
      expect(sumDurations <= const Duration(seconds: 59), isTrue);

      // Verify if the pause button changed back to play button
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Now go to the end of the audio
      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      verifyAudioDataElementsUpdatedInJsonFile(
        audioPlayerSelectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: 0,
        audioTitle: lastDownloadedAudioTitle,
        audioPositionSeconds: 59,
        isPaused: true,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        audioPausedDateTime: pausedAudioAtDateTime,
      );

      // Now go to the start of the audio
      await tester
          .tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      verifyAudioDataElementsUpdatedInJsonFile(
        audioPlayerSelectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: 0,
        audioTitle: lastDownloadedAudioTitle,
        audioPositionSeconds: 0,
        isPaused: true,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        audioPausedDateTime: pausedAudioAtDateTime,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets(
        'Clicking on audio title to open AudioPlayerView. Then click on play button to finish playing the first downloaded audio and start playing the last downloaded audio, ignoring the 2 precendent audios already fully played.',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String firstDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_first_to_last_audio_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now we tap on the play button in order to finish
      // playing the first downloaded audio and start playing
      // the last downloaded audio of the playlist. The 2
      // audios in between are ignored since they are already
      // fully played.

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Verify the last downloaded played audio title
      expect(
          find.text(
              '3 fois où Aurélien Barrau tire à balles réelles sur les riches\n8:50'),
          findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets(
        'Clicking on audio play button to open AudioPlayerView. Then back to playlist download view and click on pause, then on play again. Check the audio item play/pause icon as well as their color',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_2_shorts_test';
      const String lastDownloadedAudioTitle = 'Really short video';

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the previously downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the not yet played audio.

      // First, validate the play/pause button of the previously
      // downloaded Audio item InkWell widget and obtain again the
      // previously downloaded Audio item InkWell widget finder

      Finder lastDownloadedAudioListTileInkWellFinder = validateInkWellButton(
        tester: tester,
        audioTitle: lastDownloadedAudioTitle,
        expectedIcon: Icons.play_arrow,
        expectedIconColor: kDarkAndLightEnabledIconColor,
        expectedIconBackgroundColor: Colors.black,
      );

      // Now tap on the InkWell to play the audio and draw to the audio
      // player screen
      await tester.tap(lastDownloadedAudioListTileInkWellFinder);
      await tester.pumpAndSettle();

      // Without delaying, the playing audio and dragging to the
      // AudioPlayerView screen will not be successful !
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify if the pause button is present
      expect(find.byIcon(Icons.pause), findsOneWidget);

      // Now we go back to the PlayListDownloadView in order
      // to tap on play/pause audio item InkWell to pause the
      // audio
      final audioPlayerNavButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(audioPlayerNavButton);
      await tester.pumpAndSettle();

      // Again, validate the play/pause button of the previously
      // downloaded Audio item InkWell widget and obtain again the
      // previously downloaded Audio item InkWell widget finder
      lastDownloadedAudioListTileInkWellFinder =
          lastDownloadedAudioListTileInkWellFinder = validateInkWellButton(
        tester: tester,
        audioTitle: lastDownloadedAudioTitle,
        expectedIcon: Icons.pause,
        expectedIconColor: Colors.white,
        expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
      );

      // Now tap on the InkWell to pause the audio
      await tester.tap(lastDownloadedAudioListTileInkWellFinder);
      await tester.pumpAndSettle();

      // Verify if the play icon is present as well as its color and
      // its enclosing CircleAvatar background color

      lastDownloadedAudioListTileInkWellFinder = validateInkWellButton(
        tester: tester,
        audioTitle: lastDownloadedAudioTitle,
        expectedIcon: Icons.play_arrow,
        expectedIconColor: Colors.white,
        expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
      );

      // Now tap on the InkWell to play the previously paused audio
      // and draw to the audio player screen
      await tester.tap(lastDownloadedAudioListTileInkWellFinder);
      await tester.pumpAndSettle();

      // Without delaying, the playing audio and dragging to the
      // AudioPlayerView screen will not be successful !
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });

  group('audio info audio state verification', () {
    testWidgets(
        'After starting to play the audio, go back to playlist download view in order to verify audio info and audio play/pause icon type and state.',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_2_shorts_test';
      const String lastDownloadedAudioTitle = 'morning _ cinematic video';

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // checking the audio state displayed in audio information
      // dialog as well as audio right icon before playing
      // the audio
      await goBackToPlaylistdownloadViewToCheckAudioStateAndIcon(
        tester: tester,
        audioTitle: lastDownloadedAudioTitle,
        audioStateExpectedValue: "Non écouté",
        expectedAudioRightIcon: Icons.play_arrow,
        expectedAudioRightIconColor: kDarkAndLightEnabledIconColor,
        expectedAudioRightIconSurroundedColor: Colors.black,
      );

      // Now we want to tap on the lastly downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the currently paused audio

      // First, get the lastly downloaded Audio ListTile Text
      // widget finder and tap on it to move to audio player view
      Finder lastDownloadedAudioListTileTextWidgetFinder =
          find.text(lastDownloadedAudioTitle);

      await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // checking the audio state displayed in audio information
      // dialog as well as audio right icon while audio is playing
      await goBackToPlaylistdownloadViewToCheckAudioStateAndIcon(
        tester: tester,
        audioTitle: lastDownloadedAudioTitle,
        audioStateExpectedValue: "En lecture",
        expectedAudioRightIcon: Icons.pause,
        expectedAudioRightIconColor: Colors.white,
        expectedAudioRightIconSurroundedColor: kDarkAndLightEnabledIconColor,
      );

      // Go back to audio player view in order to pause the audio
      Finder audioPlayerNavButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(audioPlayerNavButton);
      await tester.pumpAndSettle();

      // Pause the audio
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // checking the audio state displayed in audio information
      // dialog as well as audio right icon while audio is playing
      await goBackToPlaylistdownloadViewToCheckAudioStateAndIcon(
        tester: tester,
        audioTitle: lastDownloadedAudioTitle,
        audioStateExpectedValue: "En pause",
        expectedAudioRightIcon: Icons.play_arrow,
        expectedAudioRightIconColor: Colors.white,
        expectedAudioRightIconSurroundedColor: kDarkAndLightEnabledIconColor,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets(
        'After starting to play the audio, click to end icon and go back to playlist download view in order to verify audio info and audio play/pause icon type and state.',
        (
      WidgetTester tester,
    ) async {
      // PLACING THIS TEST IN THE PREVIOUS testWidgets FUNCTION
      // MAKES THE TEST TO FAIL. SO, IT IS PLACED IN A SEPARATE
      // testWidgets FUNCTION. WHY DID IT FAIL ? I DON'T KNOW !
      // THIS IS A FLUTTER BUG !
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_2_shorts_test';
      const String lastDownloadedAudioTitle = 'morning _ cinematic video';

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the lastly downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the currently not played audio

      // First, get the lastly downloaded Audio ListTile Text
      // widget finder and tap on it to move to audio player view
      Finder lastDownloadedAudioListTileTextWidgetFinder =
          find.text(lastDownloadedAudioTitle);

      await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // checking the audio state displayed in audio information
      // dialog as well as audio right icon while audio is playing
      await goBackToPlaylistdownloadViewToCheckAudioStateAndIcon(
        tester: tester,
        audioTitle: lastDownloadedAudioTitle,
        audioStateExpectedValue: "En lecture",
        expectedAudioRightIcon: Icons.pause,
        expectedAudioRightIconColor: Colors.white,
        expectedAudioRightIconSurroundedColor: kDarkAndLightEnabledIconColor,
      );

      // Go back to audio player view in order to go to end the audio
      Finder audioPlayerNavButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(audioPlayerNavButton);
      await tester.pumpAndSettle();

      // Tap on the |> button to go to the end of the audio
      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      // checking the audio state displayed in audio information
      // dialog as well as audio right icon when audio was played
      // to the end
      await goBackToPlaylistdownloadViewToCheckAudioStateAndIcon(
        tester: tester,
        audioTitle: lastDownloadedAudioTitle,
        audioStateExpectedValue: "Terminé",
        expectedAudioRightIcon: Icons.play_arrow,
        expectedAudioRightIconColor: kDarkAndLightEnabledIconColor,
        expectedAudioRightIconSurroundedColor: Colors.black,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });
  group('no audio selected tests', () {
    testWidgets(
        'Opening AudioPlayerView by clicking on AudioPlayerView icon button with a playlist recently downloaded with no previously selected audio.',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_no_sel_audio_test';

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen which displays the current
      // playable audio which is paused

      // Assuming you have a button to navigate to the AudioPlayerView
      final audioPlayerNavButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(audioPlayerNavButton);
      await tester.pumpAndSettle();

      // Test play button
      final playButton = find.byIcon(Icons.play_arrow);
      await tester.tap(playButton);
      await tester.pumpAndSettle();

      // Verify the no selected audio title is displayed
      expect(find.text("Aucun audio sélectionné"), findsOneWidget);

      // Verify if the play button remained the same since
      // there is no audio to play
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets(
        'Opening AudioPlayerView by clicking on AudioPlayerView icon button in situation where no playlist is selected.',
        (WidgetTester tester) async {
      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_no_playlist_selected_test',
        selectedPlaylistTitle: null, // no playlist selected
      );

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen which displays the current
      // playable audio which is paused

      // Assuming you have a button to navigate to the AudioPlayerView
      final audioPlayerNavButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(audioPlayerNavButton);
      await tester.pumpAndSettle();

      // Verify the no selected audio title is displayed
      Finder noAudioTitleFinder = find.text("No audio selected");
      expect(noAudioTitleFinder, findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });
  group('set play speed tests', () {
    testWidgets(
        'Reduce play speed. Then go back to PlaylistDownloadView and click on another audio title.',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String lastDownloadedAudioTitle =
          '3 fois où Aurélien Barrau tire à balles réelles sur les riches';
      const String firstDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_play_speed_bug_fix_test_data',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now open the audio play speed dialog
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Now select the 0.7x play speed
      await tester.tap(find.text('0.7x'));
      await tester.pumpAndSettle();

      // And click on the Ok button
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      // Verify if the play speed is 0.70x
      expect(find.text('0.70x'), findsOneWidget);

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      int playableAudioLstAudioIndex = 1;
      double expectedAudioPlaySpeed = 0.7;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Now we go back to the PlayListDownloadView in order
      // to tap on the last downloaded audio title

      final audioPlayerNavButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(audioPlayerNavButton);
      await tester.pumpAndSettle();

      // Now we want to tap on the last downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the last downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder lastDownloadedAudioListTileTextWidgetFinder =
          find.text(lastDownloadedAudioTitle);

      await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Verify if the play speed of the last downloaded audio
      // which was not modified is 1.50x
      expect(find.text('1.50x'), findsOneWidget);

      // Check the saved playlist last downloaded audio
      // play speed value in the json file

      playableAudioLstAudioIndex = 0;
      expectedAudioPlaySpeed = 1.5;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets(
        'Reduce play speed. Then click twice on >| button to start playing the most recently downloaded audio.',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String firstDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_play_speed_bug_fix_test_data',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now open the audio play speed dialog
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Now select the 0.7x play speed
      await tester.tap(find.text('0.7x'));
      await tester.pumpAndSettle();

      // And click on the Ok button
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      // Verify if the play speed is 0.70x
      expect(find.text('0.70x'), findsOneWidget);

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      int playableAudioLstAudioIndex = 1;
      double expectedAudioPlaySpeed = 0.7;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Now we tap twice on the >| button in order to start
      // playing the last downloaded audio of the playlist

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      // Verify if the play speed of the last downloaded audio
      // which was not modified is 1.50x
      expect(find.text('1.50x'), findsOneWidget);

      playableAudioLstAudioIndex = 0;
      expectedAudioPlaySpeed = 1.5;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets(
        'Reduce play speed. Then click on play button to finish playing the first downloaded audio and start playing the next downloaded audio.',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String firstDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_play_speed_bug_fix_test_data',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now open the audio play speed dialog
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Now select the 0.7x play speed
      await tester.tap(find.text('0.7x'));
      await tester.pumpAndSettle();

      // And click on the Ok button
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      // Verify if the play speed is 0.70x
      expect(find.text('0.70x'), findsOneWidget);

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      int playableAudioLstAudioIndex = 1;
      double expectedAudioPlaySpeed = 0.7;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Now we tap on the play button in order to finish
      // playing the first downloaded audio and start playing
      // the last downloaded audio of the playlist

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Verify if the play speed of the last downloaded audio
      // which was not modified is 1.50x
      expect(find.text('1.50x'), findsOneWidget);

      playableAudioLstAudioIndex = 0;
      expectedAudioPlaySpeed = 1.5;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets('Reduce play speed. Then click on Cancel.', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String firstDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_play_speed_bug_fix_test_data',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now open the audio play speed dialog
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Now select the 0.7x play speed
      await tester.tap(find.text('0.7x'));
      await tester.pumpAndSettle();

      // And click on the Cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify if the play speed is 1.25x
      expect(find.text('1.25x'), findsOneWidget);

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      int playableAudioLstAudioIndex = 1;
      double expectedAudioPlaySpeed = 1.25;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets(
        'Reduce play speed. Then click on play button to finish playing the first downloaded audio and start playing the last downloaded audio, ignoring the 2 precendent audios already fully played.',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String firstDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_first_to_last_audio_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now open the audio play speed dialog
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Now select the 0.7x play speed
      await tester.tap(find.text('0.7x'));
      await tester.pumpAndSettle();

      // And click on the Ok button
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      // Verify if the play speed is 0.70x
      expect(find.text('0.70x'), findsOneWidget);

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      int playableAudioLstAudioIndex = 1;
      double expectedAudioPlaySpeed = 0.7;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Now we tap on the play button in order to finish
      // playing the first downloaded audio and start playing
      // the last downloaded audio of the playlist. The 2
      // audios in between are ignored since they are already
      // fully played.

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Verify if the play speed of the last downloaded audio
      // which was not modified is 1.50x
      expect(find.text('1.50x'), findsOneWidget);

      playableAudioLstAudioIndex = 0;
      expectedAudioPlaySpeed = 1.5;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets(
        'Reduce play speed. Then open the DisplaySelectableAudioListDialogWidget and select the most recently downloaded audio.',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String nextUnreadAndLastDownloadedAudioTitle =
          '3 fois où Aurélien Barrau tire à balles réelles sur les riches';
      const String firstDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_play_speed_bug_fix_test_data',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now open the audio play speed dialog
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Now select the 0.7x play speed
      await tester.tap(find.text('0.7x'));
      await tester.pumpAndSettle();

      // And click on the Ok button
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      // Verify if the play speed is 0.70x
      expect(find.text('0.70x'), findsOneWidget);

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      int playableAudioLstAudioIndex = 1;
      double expectedAudioPlaySpeed = 0.7;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Now we open the DisplaySelectableAudioListDialogWidget
      // and select the last downloaded audio of the playlist

      await tester.tap(find.text(
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau\n6:29'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(nextUnreadAndLastDownloadedAudioTitle));
      await tester.pumpAndSettle();

      // Verify if the play speed of the last downloaded audio
      // which was not modified is 1.50x
      expect(find.text('1.50x'), findsOneWidget);

      playableAudioLstAudioIndex = 0;
      expectedAudioPlaySpeed = 1.5;

      verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex,
        expectedAudioPlaySpeed,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });
  group('skip to next audio ignoring already listened audios tests.', () {
    testWidgets(
        'The next unread audio is also the last downloaded audio of the playlist.',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String firstDownloadedAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";
      const String lastDownloadedAudioTitle =
          "La résilience insulaire par Fiona Roche\n13:35";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName:
            'audio_play_skip_to_next_and_last_unread_audio_test',
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

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // The audio position is 2 seconds before end. Now play
      // the audio and wait 5 seconds so that the next audio
      // will start to play

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Verify if the last downloaded audio title is displayed
      expect(find.text(lastDownloadedAudioTitle), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });
  group('display audio list.', () {
    const Color fullyPlayedAudioTitleColor = kSliderThumbColorInDarkMode;
    const Color currentlyPlayingAudioTitleTextColor = Colors.white;
    const Color currentlyPlayingAudioTitleTextBackgroundColor = Colors.blue;
    const Color? unplayedAudioTitleTextColor = null;
    const Color partiallyPlayedAudioTitleTextdColor = Colors.blue;

    testWidgets('All, then only no played or partially played, audio displayed',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String currentPartiallyPlayedAudioTitle =
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_display_audio_list_test',
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

      // First, get the current partially played Audio ListTile Text
      // widget finder and tap on it
      final Finder currentPartiallyPlayedAudioListTileTextWidgetFinder =
          find.text(currentPartiallyPlayedAudioTitle);

      await tester.tap(currentPartiallyPlayedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now we open the AudioPlayableListDialogWidget
      // and verify the color of the displayed audio titles

      await tester.tap(find.text(
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau\n6:29'));
      await tester.pumpAndSettle();

      await checkAudioTextColor(
        tester: tester,
        audioTitle:
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        expectedTitleTextColor: fullyPlayedAudioTitleColor,
        expectedTitleTextBackgroundColor: null,
      );

      await checkAudioTextColor(
        tester: tester,
        audioTitle:
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        expectedTitleTextColor: currentlyPlayingAudioTitleTextColor,
        expectedTitleTextBackgroundColor:
            currentlyPlayingAudioTitleTextBackgroundColor,
      );

      await checkAudioTextColor(
        tester: tester,
        audioTitle: "Really short video",
        expectedTitleTextColor: fullyPlayedAudioTitleColor,
        expectedTitleTextBackgroundColor: null,
      );

      await checkAudioTextColor(
        tester: tester,
        audioTitle: "morning _ cinematic video",
        expectedTitleTextColor: unplayedAudioTitleTextColor,
        expectedTitleTextBackgroundColor: null,
      );

      await checkAudioTextColor(
        tester: tester,
        audioTitle: "La résilience insulaire par Fiona Roche",
        expectedTitleTextColor: partiallyPlayedAudioTitleTextdColor,
        expectedTitleTextBackgroundColor: null,
      );

      // Now we tap the Exclude fully played audio checkbox
      await tester
          .tap(find.byKey(const Key('excludeFullyPlayedAudiosCheckbox')));
      await tester.pumpAndSettle();

      // Verifying that the fully played audio titles are not displayed

      expect(
          find.text(
              "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)"),
          findsNothing);
      expect(find.text("Really short video"), findsNothing);

      await checkAudioTextColor(
        tester: tester,
        audioTitle:
            "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        expectedTitleTextColor: currentlyPlayingAudioTitleTextColor,
        expectedTitleTextBackgroundColor:
            currentlyPlayingAudioTitleTextBackgroundColor,
      );

      await checkAudioTextColor(
        tester: tester,
        audioTitle: "morning _ cinematic video",
        expectedTitleTextColor: unplayedAudioTitleTextColor,
        expectedTitleTextBackgroundColor: null,
      );

      await checkAudioTextColor(
        tester: tester,
        audioTitle: "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        expectedTitleTextColor: unplayedAudioTitleTextColor,
        expectedTitleTextBackgroundColor: null,
      );

      await checkAudioTextColor(
        tester: tester,
        audioTitle: "La résilience insulaire par Fiona Roche",
        expectedTitleTextColor: partiallyPlayedAudioTitleTextdColor,
        expectedTitleTextBackgroundColor: null,
      );

      // Tap on Cancel button to close the
      // DisplaySelectableAudioListDialogWidget
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets(
        'Select first downloaded audio, then verify that displayed audio list is moved down in order to display this audio title',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String currentNotPlayedAudioTitle =
          "Les besoins artificiels par R.Keucheyan";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_display_audio_list_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Go to the audio player view by tapping on the audio player
      // icon button
      Finder audioPlayerNavButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(audioPlayerNavButton);
      await tester.pumpAndSettle();

      // The current audio is the first downloaded audio of the playlist
      // Now we open the AudioPlayableListDialogWidget by tapping on the
      // audio title

      await tester.tap(find.text("${currentNotPlayedAudioTitle}\n19:05"));
      await tester.pumpAndSettle();

      // The list has been moved down so that the current audio is
      // displayed at the botom of the list
      await checkAudioTextColor(
        tester: tester,
        audioTitle: currentNotPlayedAudioTitle,
        expectedTitleTextColor: currentlyPlayingAudioTitleTextColor,
        expectedTitleTextBackgroundColor:
            currentlyPlayingAudioTitleTextBackgroundColor,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });
  group('single undo/redo tests', () {
    testWidgets('forward 1 minute position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
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
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester.tap(find.byKey(const Key('audioPlayerViewForward1mButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('11:00'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('11:00'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets('forward 10 seconds position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
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
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester
          .tap(find.byKey(const Key('audioPlayerViewForward10sButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:10'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:10'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets('backward 1 minute position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
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
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester.tap(find.byKey(const Key('audioPlayerViewRewind1mButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:00'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:00'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets('backward 10 seconds position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
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
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester.tap(find.byKey(const Key('audioPlayerViewRewind10sButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:50'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:50'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets('skip to start position change', (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
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
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position to audio start

      await tester
          .tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('0:00'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('0:00'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets('skip to end position change', (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
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
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position to audio end

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('20:32'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('20:32'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });
  group('undo/redo with new command between tests', () {
    testWidgets('forward 1 minute position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
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
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's play position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester.tap(find.byKey(const Key('audioPlayerViewForward1mButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('11:00'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // new command: change the current audio's play position to audio start

      await tester
          .tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      expect(find.text('0:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('11:00'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets('forward 10 seconds position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
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
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's initial position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester
          .tap(find.byKey(const Key('audioPlayerViewForward10sButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:10'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // new command: change the current audio's play position to audio start

      await tester
          .tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      expect(find.text('0:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's redoned change position
      expect(find.text('10:10'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets('backward 1 minute position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
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
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's play position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester.tap(find.byKey(const Key('audioPlayerViewRewind1mButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:00'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // new command: change the current audio's play position to audio end

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      expect(find.text('20:32'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:00'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets('backward 10 seconds position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
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
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's play position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester.tap(find.byKey(const Key('audioPlayerViewRewind10sButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:50'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // new command: change the current audio's play position to audio end

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      expect(find.text('20:32'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:50'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets('skip to start position change', (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
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
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position to audio start

      await tester
          .tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('0:00'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // new command: go forward 1 minute

      await tester.tap(find.byKey(const Key('audioPlayerViewForward1mButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('11:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('0:00'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets('skip to end position change', (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
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
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position to audio end

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('20:32'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // new command: go back 1 minute

      await tester.tap(find.byKey(const Key('audioPlayerViewRewind1mButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('20:32'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });
  group('Sort/filter audios tests', () {
    testWidgets(
        'Playing last sorted audio with filter: "Fully listened" unchecked and "Partially listened" checked.',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await initializeApplicationAndSelectPlaylist(
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

      // find the sort/filter audios menu item and tap on it
      await tester.tap(find.byKey(
          const Key('define_sort_and_filter_audio_settings_dialog_item')));
      await tester.pumpAndSettle();

      // tap on the sort option dropdown button to display the sort
      // options
      await tester.tap(find.byKey(const Key('sortingOptionDropdownButton')));
      await tester.pumpAndSettle();

      // select the Audio duration sort option and tapp on it to add
      // it to the sort option list
      await tester.tap(find.text('Audio duration'));
      await tester.pumpAndSettle();

      // Use the custom finder to find the first clear IconButton.
      // Then tap on it in order to suppress the Audio download
      // date sort option
      await tester.tap(findIconButtonWithIcon(Icons.clear).first);
      await tester.pumpAndSettle();

      // Now tap the Fully listened checkbox in order to exclude
      // those audios from the sort/filter list
      await tester.tap(find.byKey(const Key('filterFullyListenedCheckbox')));
      await tester.pumpAndSettle();

      // Now tap the Fully listened checkbox in order to exclude
      // those audios from the sort/filter list
      await tester.tap(find.byKey(const Key('filterNotListenedCheckbox')));
      await tester.pumpAndSettle();

      return; // next test code no more applicable to sort/filter dialog
// TODO: complete the test
      // Now tap on the Apply button
    });
    testWidgets(
        'Menu Clear sort/filter parameters history execution verifying that the confirm dialog is displayed in the play audio view.',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "Quand Aurélien Barrau va dans une école de management";

      await initializeApplicationAndSelectPlaylist(
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
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });
  group('Audio comment tests', () {
    testWidgets(
        'Manage comments in initially empty playlist. Copy audio to the empty playlist, add a comment, then edit it, define start, then end, comment position and finally delete it.',
        (WidgetTester tester) async {
      const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
      const String emptyPlaylistTitle = 'Empty'; // Local empty playlist
      const String audioToCommentTitle =
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_comment_test',
        selectedPlaylistTitle: emptyPlaylistTitle,
      );

      // Go to the audio player view
      Finder audioPlayerNavButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(audioPlayerNavButton);
      await tester.pumpAndSettle();

      // Verify that the comment icon button is disabled since no
      // audio is available to be played or commented
      validateInkWellButton(
        tester: tester,
        inkWellButtonKey: 'commentsInkWellButton',
        expectedIcon: Icons.bookmark_outline_outlined,
        expectedIconColor: kDarkAndLightDisabledIconColor,
        expectedIconBackgroundColor: Colors.black,
      );

      // Now we go back to the PlayListDownloadView in order
      // to copy an audio in the empty playlist
      audioPlayerNavButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(audioPlayerNavButton);
      await tester.pumpAndSettle();

      // Copy an uncommented audio from the Youtube playlist to
      // the empty playlist
      await copyAudioFromSourceToTargetPlaylist(
        tester: tester,
        sourcePlaylistTitle: youtubePlaylistTitle,
        targetPlaylistTitle: emptyPlaylistTitle,
        audioToCopyTitle: audioToCommentTitle,
      );

      // Now we want to tap on the copied uncommented audio in the
      // empty playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, select the empty playlist
      await selectPlaylist(
        tester: tester,
        playlistToSelectTitle: emptyPlaylistTitle,
      );

      // Then, get the ListTile Text widget finder of the uncommented
      // audio copied in the empty playlist and tap on it to open the
      // AudioPlayerView
      Finder audioTitleNotYetCommentedFinder = find.text(audioToCommentTitle);
      await tester.tap(audioTitleNotYetCommentedFinder);
      await tester.pumpAndSettle();

      // Ensure that the comment playlist directory does not exist
      final Directory directory = Directory(
          "kPlaylistDownloadRootPathWindowsTest${path.separator}$emptyPlaylistTitle${path.separator}$kCommentDirName");

      expect(directory.existsSync(), false);

      // Verify that the comment icon button is now enabled since now
      // an audio is available to be played or commented
      Finder commentInkWellButtonFinder = validateInkWellButton(
        tester: tester,
        inkWellButtonKey: 'commentsInkWellButton',
        expectedIcon: Icons.bookmark_outline_outlined,
        expectedIconColor: kDarkAndLightEnabledIconColor,
        expectedIconBackgroundColor: Colors.black,
      );

      // Verify the current audio position in the audio player view.

      String expectedAudioPlayerViewCurrentAudioPosition = '0:43';
      Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));
      String actualAudioPlayerViewCurrentAudioPosition =
          tester.widget<Text>(audioPlayerViewAudioPositionFinder).data!;

      expect(
        expectedAudioPlayerViewCurrentAudioPosition,
        actualAudioPlayerViewCurrentAudioPosition,
      );

      // Tap on the comment icon button to open the comment add list
      // dialog
      await tester.tap(commentInkWellButtonFinder);
      await tester.pumpAndSettle();

      // Verify that the comment dialog is displayed
      expect(find.text('Comments'), findsOneWidget);

      // Verify that no comment is displayed in the comment list
      final commentWidget = find.byKey(const ValueKey('commentTitleKey'));

      // Assert that no comment widgets are found
      expect(commentWidget, findsNothing);

      // Now tap on the Add comment icon button to open the add
      // edit comment dialog
      await tester
          .tap(find.byKey(const Key('addPositionedCommentIconButtonKey')));
      await tester.pumpAndSettle();

      // Verify style of title TextField and enter title text
      String commentTitle = 'Comment title';
      await checkTextFieldStyleAndEnterText(
        tester: tester,
        textFieldKeyStr: 'commentTitleTextField',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        textToEnter: commentTitle,
      );

      // Verify style of comment TextField and enter comment text
      String commentText = 'Comment text';
      String commentContentTextFieldKeyStr = 'commentContentTextField';
      await checkTextFieldStyleAndEnterText(
        tester: tester,
        textFieldKeyStr: commentContentTextFieldKeyStr,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        textToEnter: commentText,
      );

      // Verify audio title displayed in the comment dialog
      expect(find.text(audioToCommentTitle), findsOneWidget);

      // Verify the initial comment position displayed in the
      // comment start and end positions in the comment dialog.
      // This position was the audio player view position when
      // the comment dialog was opened.
      String commentStartAndEndInitialPosition =
          expectedAudioPlayerViewCurrentAudioPosition;

      Finder commentStartTextWidgetFinder =
          find.byKey(const Key('commentStartPositionText')); // 0:43
      Finder commentEndTextWidgetFinder =
          find.byKey(const Key('commentEndPositionText')); // 0:43

      expect(
        tester.widget<Text>(commentStartTextWidgetFinder).data!,
        commentStartAndEndInitialPosition, // 0:43
      );
      expect(
        tester.widget<Text>(commentEndTextWidgetFinder).data!,
        commentStartAndEndInitialPosition, // 0:43
      );

      // Setting the comment start position in seconds ...

      // Tap three times on the forward comment start icon button, then
      // one time on the backward comment start icon button and finally
      // one time again on the forward comment start icon button to change
      // the comment start position. Since the tenth of seconds checkbox
      // is not checked, the comment start position is changed in seconds.
      Finder forwardCommentStartIconButtonFinder =
          find.byKey(const Key('forwardCommentStartIconButton'));
      Finder backwardCommentStartIconButtonFinder =
          find.byKey(const Key('backwardCommentStartIconButton'));

      await tester.tap(forwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(backwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      // Verify the comment start position displayed in the comment
      // dialog
      String commentStartPosition = '0:46';
      expect(
        tester.widget<Text>(commentStartTextWidgetFinder).data!,
        commentStartPosition, // 0:46
      );

      // Verify that the comment end position displayed in the comment
      // dialog is not yet modified.
      //
      // The comment end position was automatically set with the current
      // audio position in the audio player view.
      expect(
        tester.widget<Text>(commentEndTextWidgetFinder).data!,
        commentStartAndEndInitialPosition, // 0:43
      );

      // Let the audio be played during 2 second. As consequence, the
      // comment end position will be 2 seconds after the set comment
      // start position.
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Tap on the play/pause button to stop playing the audio
      await tester.tap(find.byKey(const Key('playPauseIconButton')));
      await tester.pumpAndSettle();

      // Now verify the comment end position displayed in the comment dialog.
      // The comment end position was automatically set to the current
      // audio position in the audio player view after the user tapped on
      // the play/pause button to stop playing the audio.

      // Obtain the current audio position in the audio player view
      String audioPlayerViewCurrentAudioPosition =
          tester.widget<Text>(audioPlayerViewAudioPositionFinder).data!;

      // Verify that the comment end position displayed in the comment
      // dialog is now the same as the current audio position in the
      // audio player view.
      expect(
        tester.widget<Text>(commentEndTextWidgetFinder).data!,
        audioPlayerViewCurrentAudioPosition, // 0:48
      );

      // Now, modifying the comment start position in tenth of
      // seconds

      // Tap on the tenth of seconds checkbox to enable the
      // modification of the comment start position in tenth of
      // seconds
      await tester
          .tap(find.byKey(const Key('commentStartTenthOfSecondsCheckbox')));
      await tester.pumpAndSettle();

      // Verify that the comment start position is now displayed
      // with added tenth of seconds value
      String commentStartPositionWithTensOfSecond = '0:46.0';

      expect(
        tester.widget<Text>(commentStartTextWidgetFinder).data!,
        commentStartPositionWithTensOfSecond, // 0:46.0
      );

      // Tap three times on the forward comment start icon button, then
      // one time on the backward comment start icon button and finally
      // one time again on the forward comment start icon button to change
      // the comment start position. Since the tenth of seconds checkbox
      // is now checked, the comment start position is changed in tenth
      // of seconds.
      await tester.tap(forwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(backwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(backwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      // Verify the comment start position displayed in the comment
      // dialog
      String expectedCommentStartPositionWithTensOfSecond = '0:46.1';
      String actualCommentStartPositionWithTensOfSecondStr = tester
          .widget<Text>(find.byKey(const Key('commentStartPositionText')))
          .data!;

      expect(
        actualCommentStartPositionWithTensOfSecondStr,
        expectedCommentStartPositionWithTensOfSecond, // 0:46.1
        reason:
            'Expected comment start position not found. Real value: $actualCommentStartPositionWithTensOfSecondStr',
      );

      // Tap on the play/pause button to stop playing the audio
      await tester.tap(find.byKey(const Key('playPauseIconButton')));
      await tester.pumpAndSettle();

      // Tap on the comment end tenth of seconds checkbox to enable
      // displaying the comment end position with tenth of seconds
      Finder commentEndTenthOfSecondsCheckboxFinder =
          find.byKey(const Key('commentEndTenthOfSecondsCheckbox'));
      await tester.tap(commentEndTenthOfSecondsCheckboxFinder);
      await tester.pumpAndSettle();

      String expectedCommentEndPositionWithTensOfSecondMin = '0:48.1';
      String expectedCommentEndPositionWithTensOfSecondMax = '0:49.2';

      verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: commentEndTextWidgetFinder,
        minPositionTimeStr: expectedCommentEndPositionWithTensOfSecondMin,
        maxPositionTimeStr: expectedCommentEndPositionWithTensOfSecondMax,
      );

      // Reset the comment end modification to seconds
      await tester.tap(commentEndTenthOfSecondsCheckboxFinder);
      await tester.pumpAndSettle();

      // Now, setting the comment end position in seconds ...

      // Tap three times on the forward comment end icon button, then
      // one time on the backward comment end icon button and finally
      // one time again on the forward comment end icon button to change
      // the comment end position. Since the tenth of seconds checkbox
      // is not checked, the comment end position is changed in seconds.
      Finder forwardCommentEndIconButtonFinder =
          find.byKey(const Key('forwardCommentEndIconButton'));
      Finder backwardCommentEndIconButtonFinder =
          find.byKey(const Key('backwardCommentEndIconButton'));

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(backwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      // Tap on the play/pause button to stop playing the audio
      await tester.tap(find.byKey(const Key('playPauseIconButton')));
      await tester.pumpAndSettle();

      // Verify the comment end position displayed in the comment
      // dialog

      String expectedCommentEndPositionSeconds =
          '0:52'; // 0:49:2 + 3 - 1 + 1 seconds
      String actualCommentEndPositionSecondsStr =
          tester.widget<Text>(commentEndTextWidgetFinder).data!;

      expect(
        actualCommentEndPositionSecondsStr,
        expectedCommentEndPositionSeconds, // 0:52
        reason:
            'Expected comment end position not found. Real value: $actualCommentStartPositionWithTensOfSecondStr',
      );

      // Verify the current audio position in the audio player view.
      // The audio position correspond to the comment start position
      // in seconds.
      String expectedAudioPlayerAudioPositionMin = '0:48';
      String expectedAudioPlayerAudioPositionMax = '0:49';

      verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: audioPlayerViewAudioPositionFinder,
        minPositionTimeStr: expectedAudioPlayerAudioPositionMin,
        maxPositionTimeStr: expectedAudioPlayerAudioPositionMax,
      );

      // Now, modifying the comment end position in tenth of
      // seconds

      // Tap on the tenth of seconds checkbox to enable the
      // modification of the comment end position in tenth of
      // seconds
      await tester.tap(commentEndTenthOfSecondsCheckboxFinder);
      await tester.pumpAndSettle();

      // Verify that the comment end position is now displayed
      // with added tenth of seconds value

      String expectedCommentEndPositionMin = '0:52.0';
      String expectedCommentEndPositionMax = '0:52.1';

      verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: commentEndTextWidgetFinder,
        minPositionTimeStr: expectedCommentEndPositionMin,
        maxPositionTimeStr: expectedCommentEndPositionMax,
      );

      // Tap three times on the forward comment end icon button, then
      // one time on the backward comment end icon button and finally
      // one time again on the forward comment end icon button to change
      // the comment end position. Since the tenth of seconds checkbox
      // is checked, the comment end position is changed in tenth of
      // seconds.
      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(backwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      // Verify the comment end position displayed in the comment
      // dialog

      expectedCommentEndPositionMin = '0:52.1';
      expectedCommentEndPositionMax = '0:52.4';

      String actualCommentEndPositionWithTenthOfSecondsStr =
          tester.widget<Text>(commentEndTextWidgetFinder).data!;

      verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: commentEndTextWidgetFinder,
        minPositionTimeStr: expectedCommentEndPositionMin,
        maxPositionTimeStr: expectedCommentEndPositionMax,
      );

      // Tap on the play/pause button to stop playing the audio
      await tester.tap(find.byKey(const Key('playPauseIconButton')));
      await tester.pumpAndSettle();

      // Verify the current audio position in the audio player view.
      // The audio position correspond to the comment start position
      // in seconds.

      expectedAudioPlayerAudioPositionMin = '0:48';
      expectedAudioPlayerAudioPositionMax = '0:49';

      verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: audioPlayerViewAudioPositionFinder,
        minPositionTimeStr: expectedAudioPlayerAudioPositionMin,
        maxPositionTimeStr: expectedAudioPlayerAudioPositionMax,
      );

      // Tap on the add/edit comment button to save the comment

      Finder addOrUpdateCommentTextButton =
          find.byKey(const Key('addOrUpdateCommentTextButton'));

      // Verify the add/update comment button text
      TextButton addEditTextButton =
          tester.widget<TextButton>(addOrUpdateCommentTextButton);
      expect((addEditTextButton.child! as Text).data, 'Add');

      // Tap on the add/edit comment button to save the comment
      await tester.tap(addOrUpdateCommentTextButton);
      await tester.pumpAndSettle();

      // Verify that the comment list dialog now displays the
      // added comment

      Finder commentListDialogFinder = find.byType(CommentListAddDialogWidget);

      expect(
          find.descendant(
              of: commentListDialogFinder, matching: find.text(commentTitle)),
          findsOneWidget);
      expect(
          find.descendant(
              of: commentListDialogFinder, matching: find.text(commentText)),
          findsOneWidget);

      expect(
          find.descendant(
            of: commentListDialogFinder,
            matching: find.text(commentStartPosition), // 0:46
          ),
          findsOneWidget);

      // Now tap on the comment title text to edit the comment
      await tester.tap(find.text(commentTitle));
      await tester.pumpAndSettle();

      // Verify that the add/edit comment button text is now 'Update'
      addEditTextButton =
          tester.widget<TextButton>(addOrUpdateCommentTextButton);
      expect((addEditTextButton.child! as Text).data, 'Update');

      // Now modify the comment text

      final textFieldFinder = find.byKey(Key(commentContentTextFieldKeyStr));
      const String updatedCommentText = 'Updated comm. text';

      await tester.enterText(
        textFieldFinder,
        updatedCommentText,
      );
      await tester.pumpAndSettle();

      // Tap on the add/update comment button to save the updated comment
      await tester.tap(addOrUpdateCommentTextButton);
      await tester.pumpAndSettle();

      verifyCommentDataStoredInJsonFile(
        playlistTitle: emptyPlaylistTitle,
        audioFileNameNoExt:
            "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12",
        commentTitle: commentTitle,
        commentContent: updatedCommentText,
        commentStartPositionTenthOfSeconds:
            DateTimeUtil.convertToTenthsOfSeconds(
          timeString: actualCommentStartPositionWithTensOfSecondStr,
        ),
        commentEndPositionTenthOfSeconds: DateTimeUtil.convertToTenthsOfSeconds(
          timeString: actualCommentEndPositionWithTenthOfSecondsStr,
        ),
      );

      // Verify that the comment list dialog now displays correctly the
      // updated comment

      commentListDialogFinder = find.byType(CommentListAddDialogWidget);
      expect(
          find.descendant(
              of: commentListDialogFinder, matching: find.text(commentTitle)),
          findsOneWidget);
      expect(
          find.descendant(
              of: commentListDialogFinder, matching: find.text(commentText)),
          findsNothing);
      expect(
          find.descendant(
              of: commentListDialogFinder,
              matching: find.text(updatedCommentText)),
          findsOneWidget);
      expect(
          find.descendant(
            of: commentListDialogFinder,
            matching: find.text(commentStartPosition),
          ),
          findsOneWidget);

      // Now close the comment list dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle();

      // Verify that the comment icon button is now highlighted since now
      // a comment exist for the audio
      commentInkWellButtonFinder = validateInkWellButton(
        tester: tester,
        inkWellButtonKey: 'commentsInkWellButton',
        expectedIcon: Icons.bookmark_outline_outlined,
        expectedIconColor: Colors.white,
        expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
      );

      // Now set the audio player view position to the desired comment
      // end position

      // Tap 5 times on the forward 1 minute icon button
      for (int i = 0; i < 5; i++) {
        await tester
            .tap(find.byKey(const Key('audioPlayerViewForward1mButton')));
        await tester.pumpAndSettle();
      }

      // Verify the current audio position in the audio player view

      expectedAudioPlayerAudioPositionMin = '5:48';
      expectedAudioPlayerAudioPositionMax = '5:49';

      verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: audioPlayerViewAudioPositionFinder,
        minPositionTimeStr: expectedAudioPlayerAudioPositionMin,
        maxPositionTimeStr: expectedAudioPlayerAudioPositionMax,
      );

      // Tap on the comment icon button to re-open the comment list
      // dialog
      await tester.tap(commentInkWellButtonFinder);
      await tester.pumpAndSettle();

      // Now tap on the comment title text to re-edit the comment
      await tester.tap(find.text(commentTitle));
      await tester.pumpAndSettle();

      // Verify that the comment end position has the same value as
      // when it was saved

      String actualAudioPlayerViewAudioPosition =
          tester.widget<Text>(audioPlayerViewAudioPositionFinder).data!;

      expect(
        tester.widget<Text>(commentEndTextWidgetFinder).data!,
        actualCommentEndPositionSecondsStr, // 0:52
      );

      // Verify that the audio player view audio position displayed
      // in the comment dialog is the same as the audio player view
      // audio position
      Finder commentDialogAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPositionText'));
      String commentDialogAudioPlayerViewAudioPositionText =
          tester.widget<Text>(commentDialogAudioPositionFinder).data!;

      expect(
        commentDialogAudioPlayerViewAudioPositionText,
        actualAudioPlayerViewAudioPosition,
      );

      // Tap once on the forward comment end icon button to increase the
      // comment end position
      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      // Tap on the comment end checkbox to enable the modification of the
      // comment end position in tenth of seconds
      await tester.tap(commentEndTenthOfSecondsCheckboxFinder);
      await tester.pumpAndSettle();

      // Now tap twice on the backward comment end icon button to decrease
      // the comment end position of 2 tenth of seconds
      await tester.tap(backwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(backwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      // Verify the comment end position displayed in the comment dialog
      // is equal to the value whwn it was saved + 1 sec - 2 tenth of seconds
      int expectedCommentEndPositionInTenthOfSeconds =
          DateTimeUtil.convertToTenthsOfSeconds(
                timeString: actualCommentEndPositionSecondsStr,
              ) +
              10 -
              2;

      int actualCommentEndPositionInTenthOfSeconds =
          DateTimeUtil.convertToTenthsOfSeconds(
        timeString: tester.widget<Text>(commentEndTextWidgetFinder).data!,
      );

      expect(
          actualCommentEndPositionInTenthOfSeconds,
          inInclusiveRange(expectedCommentEndPositionInTenthOfSeconds - 1,
              expectedCommentEndPositionInTenthOfSeconds + 4));

      // Verify that the audio player view audio position displayed
      // in the comment dialog is the same as the audio player view
      // audio position
      commentDialogAudioPlayerViewAudioPositionText =
          tester.widget<Text>(commentDialogAudioPositionFinder).data!;
      actualAudioPlayerViewAudioPosition =
          tester.widget<Text>(audioPlayerViewAudioPositionFinder).data!;

      expect(
        commentDialogAudioPlayerViewAudioPositionText,
        actualAudioPlayerViewAudioPosition,
      );

      // Now, tap on the add/update comment button to save the updated
      // comment
      await tester.tap(addOrUpdateCommentTextButton);
      await tester.pumpAndSettle();

      // Now tap on the delete comment icon button to delete the comment
      await tester.tap(find.byKey(const Key('deleteCommentIconButton')));
      await tester.pumpAndSettle();

      // Verify the delete comment dialog title
      expect(find.text('Delete comment'), findsOneWidget);

      // Verify the delete comment dialog message
      expect(find.text("Deleting comment \"$commentTitle\"."), findsOneWidget);

      // Confirm the deletion of the comment
      await tester.tap(find.byKey(const Key('confirmButtonKey')));
      await tester.pumpAndSettle();

      // Verify that the comment list dialog now displays no comment
      expect(
          find.descendant(
              of: commentListDialogFinder, matching: find.text(commentTitle)),
          findsNothing);

      // Now close the comment list dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));

      // Verify that the comment icon button is enabled but no longer
      // highlighted since no comment exist for the audio
      commentInkWellButtonFinder = validateInkWellButton(
        tester: tester,
        inkWellButtonKey: 'commentsInkWellButton',
        expectedIcon: Icons.bookmark_outline_outlined,
        expectedIconColor: kDarkAndLightEnabledIconColor,
        expectedIconBackgroundColor: Colors.black,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets(
        'Add comment near end to already commented audio. Then play comments',
        (WidgetTester tester) async {
      const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
      const String alreadyCommentedAudioTitle =
          "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_comment_test',
        selectedPlaylistTitle: youtubePlaylistTitle,
      );

      // Then, get the ListTile Text widget finder of the already commented
      // audio and tap on it to open the AudioPlayerView
      Finder alreadyCommentedAudioFinder =
          find.text(alreadyCommentedAudioTitle);
      await tester.tap(alreadyCommentedAudioFinder);
      await tester.pumpAndSettle();

      // Verify the current audio position in the audio player view.

      String expectedAudioPlayerViewCurrentAudioPosition = '1:12:48';
      Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));
      String actualAudioPlayerViewCurrentAudioPosition =
          tester.widget<Text>(audioPlayerViewAudioPositionFinder).data!;

      expect(
        expectedAudioPlayerViewCurrentAudioPosition,
        actualAudioPlayerViewCurrentAudioPosition,
      );

      // Tap on the comment icon button to open the comment add list
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
      String commentTitle = 'Four';
      Finder textFieldFinder = find.byKey(const Key('commentTitleTextField'));

      await tester.enterText(
        textFieldFinder,
        commentTitle,
      );
      await tester.pumpAndSettle();

      // Enter comment text
      String commentText = 'Fourth comment';
      Finder commentContentTextFieldFinder =
          find.byKey(const Key('commentContentTextField'));

      await tester.enterText(
        commentContentTextFieldFinder,
        commentText,
      );
      await tester.pumpAndSettle();

      // Verify the initial comment position displayed in the
      // comment start and end positions in the comment dialog.
      // This position was the audio player view position when
      // the comment dialog was opened.
      String commentStartAndEndInitialPosition =
          expectedAudioPlayerViewCurrentAudioPosition;

      Finder commentStartTextWidgetFinder =
          find.byKey(const Key('commentStartPositionText')); // 1:12:48
      Finder commentEndTextWidgetFinder =
          find.byKey(const Key('commentEndPositionText')); // 1:12:48

      expect(
        tester.widget<Text>(commentStartTextWidgetFinder).data!,
        commentStartAndEndInitialPosition, // 1:12:48
      );
      expect(
        tester.widget<Text>(commentEndTextWidgetFinder).data!,
        commentStartAndEndInitialPosition, // 1:12:48
      );

      // Setting the comment start position in seconds ...

      // Tap two times on the backward comment start icon button
      Finder backwardCommentStartIconButtonFinder =
          find.byKey(const Key('backwardCommentStartIconButton'));

      await tester.tap(backwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(backwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      // Verify the comment start position displayed in the comment
      // dialog
      String commentStartPosition = '1:12:46';
      expect(
        tester.widget<Text>(commentStartTextWidgetFinder).data!,
        commentStartPosition, // 1:12:46
      );

      // Verify that the comment end position displayed in the comment
      // dialog is not yet modified.
      //
      // The comment end position was automatically set with the current
      // audio position in the audio player view.
      expect(
        tester.widget<Text>(commentEndTextWidgetFinder).data!,
        commentStartAndEndInitialPosition, // 1:12:48
      );

      // Now, forwarding the comment end position in seconds ...

      // Tap four times on the forward comment end icon button, then 1 time
      // backward and 1 time forward
      Finder forwardCommentEndIconButtonFinder =
          find.byKey(const Key('forwardCommentEndIconButton'));
      Finder backwardCommentEndIconButtonFinder =
          find.byKey(const Key('backwardCommentEndIconButton'));

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(backwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      // Verify the comment end position displayed in the comment
      // dialog
      String expectedCommentEndPositionMin = '1:12:52';
      String expectedCommentEndPositionMax = '1:12:52';

      verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: commentEndTextWidgetFinder,
        minPositionTimeStr: expectedCommentEndPositionMin,
        maxPositionTimeStr: expectedCommentEndPositionMax,
      );

      // Now, modifying the comment end position in tenth of
      // seconds

      // Tap on the tenth of seconds checkbox to enable the
      // modification of the comment end position in tenth of
      // seconds
      await tester
          .tap(find.byKey(const Key('commentEndTenthOfSecondsCheckbox')));
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(backwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      // Verify that the comment end position is now displayed
      // with added tenth of seconds value

      expectedCommentEndPositionMin = '1:12:52.4';
      expectedCommentEndPositionMax = '1:12:52.4';

      verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: commentEndTextWidgetFinder,
        minPositionTimeStr: expectedCommentEndPositionMin,
        maxPositionTimeStr: expectedCommentEndPositionMax,
      );

      // Tap on the play/pause button to stop playing the audio
      await tester.tap(find.byKey(const Key('playPauseIconButton')));
      await tester.pumpAndSettle();

      // Tap on the add/edit comment button to save the comment

      Finder addOrUpdateCommentTextButton =
          find.byKey(const Key('addOrUpdateCommentTextButton'));

      // Verify the add/update comment button text
      TextButton addEditTextButton =
          tester.widget<TextButton>(addOrUpdateCommentTextButton);
      expect((addEditTextButton.child! as Text).data, 'Add');

      // Tap on the add/edit comment button to save the comment
      await tester.tap(addOrUpdateCommentTextButton);
      await tester.pumpAndSettle();

      Finder commentListDialogFinder = find.byType(CommentListAddDialogWidget);

      // Find the list body containing the comments
      final Finder listFinder = find.descendant(
          of: commentListDialogFinder, matching: find.byType(ListBody));

      // Find all the list items
      final Finder itemsFinder = find.descendant(
          of: listFinder, matching: find.byType(GestureDetector));

      // Check the number of items
      expect(itemsFinder, findsNWidgets(15)); // Assuming there are 4 items

      // Now tap on first comment play icon button to ensure you can play
      // a comment located before the comment you added
      await playComment(
        tester: tester,
        itemsFinder: itemsFinder,
        itemIndex: 0,
        typeOnPauseAfterPlay: true,
      );

      // Verify that the comment list dialog now displays the
      // added comment

      List<String> expectedTitles = [
        'One',
        'Two',
        'Four',
        'Three',
        'I did not thank ChatGPT',
      ];

      List<String> expectedContents = [
        'First comment',
        'Second comment',
        'Fourth comment',
        'Third comment',
        'He explains why ...',
      ];

      List<String> expectedPositions = [
        '10:47',
        '23:47',
        '1:12:46',
        '1:16:40',
        '1:17:12',
      ];

      // Verify content of each list item
      int j = 0;

      Finder commentTitleFinder;
      Finder commentContentFinder;
      Finder commentPositionFinder;

      for (var i = 0; i < 15; i += 3) {
        commentTitleFinder = find.descendant(
          of: itemsFinder.at(i),
          matching: find.byKey(Key('commentTitleKey')),
        );
        commentContentFinder = find.descendant(
          of: itemsFinder.at(i),
          matching: find.byKey(Key('commentTextKey')),
        );
        commentPositionFinder = find.descendant(
          of: itemsFinder.at(i),
          matching: find.byKey(Key('commentPositionKey')),
        );

        // Verify the text in the title, content, and position of each comment
        expect(
          tester.widget<Text>(commentTitleFinder).data,
          expectedTitles[j], // Replace with your expected titles
        );
        expect(
          tester.widget<Text>(commentContentFinder).data,
          expectedContents[j], // Replace with your expected contents
        );
        expect(
          tester.widget<Text>(commentPositionFinder).data,
          expectedPositions[j], // Replace with your expected positions
        );

        j++;
      }

      // Play comments after playing a previous comment

      // Now tap on first comment play icon button
      await playComment(
        tester: tester,
        itemsFinder: itemsFinder,
        itemIndex: 0,
        typeOnPauseAfterPlay: false,
      );

      // Now tap on fourth comment play icon button
      await playComment(
        tester: tester,
        itemsFinder: itemsFinder,
        itemIndex: 9,
        typeOnPauseAfterPlay: false,
      );

      // Now tap on second comment play icon button
      await playComment(
        tester: tester,
        itemsFinder: itemsFinder,
        itemIndex: 3,
        typeOnPauseAfterPlay: false,
      );

      // Play comments after pausing a previous comment

      // Now tap on first comment play icon button
      await playComment(
        tester: tester,
        itemsFinder: itemsFinder,
        itemIndex: 0,
        typeOnPauseAfterPlay: true,
      );

      // Now tap on fourth comment play icon button
      await playComment(
        tester: tester,
        itemsFinder: itemsFinder,
        itemIndex: 9,
        typeOnPauseAfterPlay: true,
      );

      // Now tap on second comment play icon button
      await playComment(
        tester: tester,
        itemsFinder: itemsFinder,
        itemIndex: 3,
        typeOnPauseAfterPlay: true,
      );

      // Now close the comment list dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    testWidgets(
        'Add comment near start to already commented audio. Then play comments',
        (WidgetTester tester) async {
      const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
      const String alreadyCommentedAudioTitle =
          "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...";

      await initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_comment_test',
        selectedPlaylistTitle: youtubePlaylistTitle,
      );

      // Then, get the ListTile Text widget finder of the already commented
      // audio and tap on it to open the AudioPlayerView
      Finder alreadyCommentedAudioFinder =
          find.text(alreadyCommentedAudioTitle);
      await tester.tap(alreadyCommentedAudioFinder);
      await tester.pumpAndSettle();

      // Tap on |< button to go to the beginning of the audio
      await tester
          .tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      // Tap 5 times on the forward 1 minute icon button
      Finder forwardOneMinuteButtonFinder =
          find.byKey(const Key('audioPlayerViewForward1mButton'));

      for (int i = 0; i < 5; i++) {
        await tester.tap(forwardOneMinuteButtonFinder);
        await tester.pumpAndSettle();
      }

      // Tap on the comment icon button to open the comment add list
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
      String commentTitle = 'New';
      Finder textFieldFinder = find.byKey(const Key('commentTitleTextField'));

      await tester.enterText(
        textFieldFinder,
        commentTitle,
      );
      await tester.pumpAndSettle();

      // Enter comment text
      String commentText = 'New comment';
      Finder commentContentTextFieldFinder =
          find.byKey(const Key('commentContentTextField'));

      await tester.enterText(
        commentContentTextFieldFinder,
        commentText,
      );
      await tester.pumpAndSettle();

      // Now, set the comment end position in seconds

      Finder forwardCommentEndIconButtonFinder =
          find.byKey(const Key('forwardCommentEndIconButton'));

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      // Saving the comment

      Finder addOrUpdateCommentTextButton =
          find.byKey(const Key('addOrUpdateCommentTextButton'));

      // Tap on the add/edit comment button to save the comment
      await tester.tap(addOrUpdateCommentTextButton);
      await tester.pumpAndSettle();

      Finder commentListDialogFinder = find.byType(CommentListAddDialogWidget);

      // Find the list body containing the comments
      final Finder listFinder = find.descendant(
          of: commentListDialogFinder, matching: find.byType(ListBody));

      // Find all the list items
      final Finder itemsFinder = find.descendant(
          of: listFinder, matching: find.byType(GestureDetector));

      // Check the number of items
      expect(itemsFinder, findsNWidgets(15)); // Assuming there are 4 items

      // Now tap on first comment play icon button to ensure you can play
      // a comment located before the comment you added
      await playComment(
        tester: tester,
        itemsFinder: itemsFinder,
        itemIndex: 9,
        typeOnPauseAfterPlay: true,
      );

      // Now close the comment list dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });
}

Future<void> playComment({
  required WidgetTester tester,
  required Finder itemsFinder,
  required int itemIndex,
  required bool typeOnPauseAfterPlay,
}) async {
  Finder playIconButtonFinder = find.descendant(
    of: itemsFinder.at(itemIndex),
    matching: find.byKey(const Key('playPauseIconButton')),
  );

  await tester.tap(playIconButtonFinder);
  await tester.pumpAndSettle();

  Finder iconFinder;
  for (int i = 0; i < 15; i += 3) {
    if (i == itemIndex) {
      iconFinder = find.descendant(
        of: itemsFinder.at(i),
        matching: find.byIcon(Icons.pause),
      );
      expect(iconFinder, findsOneWidget);
    } else {
      iconFinder = find.descendant(
        of: itemsFinder.at(i),
        matching: find.byIcon(Icons.play_arrow),
      );
      expect(iconFinder, findsOneWidget);
    }
  }

  await Future.delayed(const Duration(seconds: 1));
  await tester.pumpAndSettle();

  if (typeOnPauseAfterPlay) {
    await tester.tap(playIconButtonFinder);
    await tester.pumpAndSettle();
  }
}

/// Verify that the position displayed in the {textWidgetFinder} text
/// widget is between - or equal to - the minimum and maximum position
/// time strings.
void verifyPositionBetweenMinMax({
  required WidgetTester tester,
  required Finder textWidgetFinder,
  required String minPositionTimeStr,
  required String maxPositionTimeStr,
}) {
  int actualPositionTenthOfSeconds = DateTimeUtil.convertToTenthsOfSeconds(
    timeString: tester.widget<Text>(textWidgetFinder).data!,
  );

  int expectedMinPositionTenthSeconds =
      DateTimeUtil.convertToTenthsOfSeconds(timeString: minPositionTimeStr);
  int expectedMaxPositionTenthSeconds =
      DateTimeUtil.convertToTenthsOfSeconds(timeString: maxPositionTimeStr);
  expect(
    actualPositionTenthOfSeconds,
    allOf(
      [
        greaterThanOrEqualTo(expectedMinPositionTenthSeconds),
        lessThanOrEqualTo(expectedMaxPositionTenthSeconds)
      ],
    ),
    reason:
        "Expected value between $expectedMinPositionTenthSeconds and $expectedMaxPositionTenthSeconds but obtained $actualPositionTenthOfSeconds",
  );
}

Matcher inInclusiveRange(int min, int max) => predicate(
    (int value) => value >= min && value <= max,
    'is in the range [$min, $max]');

Future<void> checkTextFieldStyleAndEnterText({
  required WidgetTester tester,
  required String textFieldKeyStr,
  required int fontSize,
  required FontWeight fontWeight,
  required String textToEnter,
}) async {
  // Find the TextField using the Key
  final textFieldFinder = find.byKey(Key(textFieldKeyStr));

  // Retrieve the TextField widget
  final textField = tester.widget<TextField>(textFieldFinder);

  // Extract the TextStyle used in the TextField
  final textStyle = textField.style ?? const TextStyle();

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

Future<void> copyAudioFromSourceToTargetPlaylist({
  required WidgetTester tester,
  required String sourcePlaylistTitle,
  required String targetPlaylistTitle,
  required String audioToCopyTitle,
}) async {
  // First, select the source playlist
  await selectPlaylist(
    tester: tester,
    playlistToSelectTitle: sourcePlaylistTitle,
  );

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
  await tester.pumpAndSettle(); // Wait for tap action to complete

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
}

Future<void> selectPlaylist({
  required WidgetTester tester,
  required String playlistToSelectTitle,
}) async {
  // First, find the source Playlist ListTile Text widget
  Finder playlistListTileTextWidgetFinder = find.text(playlistToSelectTitle);

  // Then obtain the source Playlist ListTile widget enclosing the Text widget
  // by finding its ancestor
  Finder playlistListTileWidgetFinder = find.ancestor(
    of: playlistListTileTextWidgetFinder,
    matching: find.byType(ListTile),
  );

  // Now find the Checkbox widget located in the Playlist ListTile
  // and tap on it to select the playlist
  Finder playlistListTileCheckboxWidgetFinder = find.descendant(
    of: playlistListTileWidgetFinder,
    matching: find.byType(Checkbox),
  );

  // Tap the ListTile Playlist checkbox to select it
  await tester.tap(playlistListTileCheckboxWidgetFinder);
  await tester.pumpAndSettle();
}

Finder validateInkWellButton({
  required WidgetTester tester,
  String? audioTitle,
  String? inkWellButtonKey,
  required IconData expectedIcon,
  required Color expectedIconColor,
  required Color expectedIconBackgroundColor,
}) {
  Finder audioListTileInkWellFinder;

  if (inkWellButtonKey != null) {
    audioListTileInkWellFinder = find.byKey(Key(inkWellButtonKey));
  } else {
    audioListTileInkWellFinder = findAudioItemInkWellWidget(
      audioTitle!,
    );
  }

  // Find the Icon within the InkWell
  Finder iconFinder = find.descendant(
    of: audioListTileInkWellFinder,
    matching: find.byType(Icon),
  );
  Icon iconWidget = tester.widget<Icon>(iconFinder);

  // Assert Icon type
  expect(iconWidget.icon, equals(expectedIcon));

  // Assert Icon color
  expect(iconWidget.color, equals(expectedIconColor));

  // Find the CircleAvatar within the InkWell
  Finder circleAvatarFinder = find.descendant(
    of: audioListTileInkWellFinder,
    matching: find.byType(CircleAvatar),
  );
  CircleAvatar circleAvatarWidget =
      tester.widget<CircleAvatar>(circleAvatarFinder);

  // Assert CircleAvatar background color
  expect(
      circleAvatarWidget.backgroundColor, equals(expectedIconBackgroundColor));

  return audioListTileInkWellFinder;
}

Future<void> goBackToPlaylistdownloadViewToCheckAudioStateAndIcon({
  required WidgetTester tester,
  required String audioTitle,
  required String audioStateExpectedValue,
  required IconData expectedAudioRightIcon,
  required Color expectedAudioRightIconColor,
  required Color expectedAudioRightIconSurroundedColor,
}) async {
  // Go back to playlist download view without pausing audio
  final Finder audioPlayerNavButtonFinder =
      find.byKey(const ValueKey('playlistDownloadViewIconButton'));
  await tester.tap(audioPlayerNavButtonFinder);
  await tester.pumpAndSettle();

  // Now we want to tap the popup menu of the Audio audioTitle
  // ListTile

  // First, find the Audio sublist ListTile Text widget
  final Finder targetAudioListTileTextWidgetFinder = find.text(
    audioTitle,
  );

  // Then obtain the Audio ListTile widget enclosing the Text widget
  // by finding its ancestor
  final Finder targetAudioListTileWidgetFinder = find.ancestor(
    of: targetAudioListTileTextWidgetFinder,
    matching: find.byType(ListTile),
  );

  // Now find the leading menu icon button of the Audio ListTile
  // and tap on it
  final Finder targetAudioListTileLeadingMenuIconButtonFinder = find.descendant(
    of: targetAudioListTileWidgetFinder,
    matching: find.byIcon(Icons.menu),
  );

  // Tap the leading menu icon button to open the popup menu items
  await tester.tap(targetAudioListTileLeadingMenuIconButtonFinder);
  await tester.pumpAndSettle(); // Wait for popup menu to appear

  // Now find the display audio info popup menu item and tap on it
  Finder popupDisplayAudioInfoMenuItemFinder =
      find.byKey(const Key("popup_menu_display_audio_info"));

  await tester.tap(popupDisplayAudioInfoMenuItemFinder);
  await tester.pumpAndSettle();

  // Now verifying the audio info state

  Text audioStateTextWidget =
      tester.widget<Text>(find.byKey(const Key('audioStateKey')));

  expect(audioStateTextWidget.data, audioStateExpectedValue);

  // Now click on Ok button to close the audio info dialog
  await tester.tap(find.byKey(const Key('audioInfoOkButtonKey')));
  await tester.pumpAndSettle();

  // Now verifying the audio right button state

  // First, get the currently listening Audio item InkWell widget
  // finder. The InkWell widget contains the play or pause icon
  // and tapping on it plays or pauses the audio.
  Finder lastDownloadedAudioListTileInkWellFinder = findAudioItemInkWellWidget(
    audioTitle,
  );

  // Find the Icon within the InkWell
  Finder iconFinder = find.descendant(
    of: lastDownloadedAudioListTileInkWellFinder,
    matching: find.byType(Icon),
  );
  Icon iconWidget = tester.widget<Icon>(iconFinder);

  // Assert Icon type
  expect(iconWidget.icon, equals(expectedAudioRightIcon));

  // Assert Icon color
  expect(iconWidget.color, equals(expectedAudioRightIconColor));

  // Find the CircleAvatar within the InkWell which surround the
  // audio right icon
  Finder circleAvatarFinder = find.descendant(
    of: lastDownloadedAudioListTileInkWellFinder,
    matching: find.byType(CircleAvatar),
  );
  CircleAvatar circleAvatarWidget =
      tester.widget<CircleAvatar>(circleAvatarFinder);

  // Assert CircleAvatar background color
  expect(circleAvatarWidget.backgroundColor,
      equals(expectedAudioRightIconSurroundedColor));
}

Finder findAudioItemInkWellWidget(String audioTitle) {
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

// A custom finder that finds an IconButton with the specified icon data.
Finder findIconButtonWithIcon(IconData iconData) {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is IconButton &&
        widget.icon is Icon &&
        (widget.icon as Icon).icon == iconData,
  );
}

Future<void> checkAudioTextColor({
  required WidgetTester tester,
  required String audioTitle,
  required Color? expectedTitleTextColor,
  required Color? expectedTitleTextBackgroundColor,
}) async {
  // Find the Text widget by its text content
  final Finder textFinder = find.text(audioTitle);

  // Retrieve the Text widget
  final Text textWidget = tester.widget(textFinder) as Text;

  // Check if the color of the Text widget is as expected
  expect(textWidget.style?.color, equals(expectedTitleTextColor));
  expect(textWidget.style?.backgroundColor,
      equals(expectedTitleTextBackgroundColor));
}

void verifyAudioPlaySpeedStoredInPlaylistJsonFile(
    String audioPlayerSelectedPlaylistTitle,
    int playableAudioLstAudioIndex,
    double expectedAudioPlaySpeed) {
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
          .playableAudioLst[playableAudioLstAudioIndex].audioPlaySpeed,
      expectedAudioPlaySpeed);
}

void verifyAudioDataElementsUpdatedInJsonFile({
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
      (actualAudioPositionSeconds - audioPositionSeconds).abs() <= 1, isTrue);

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

void verifyCommentDataStoredInJsonFile({
  required String playlistTitle,
  required String audioFileNameNoExt,
  required String commentTitle,
  required String commentContent,
  required int commentStartPositionTenthOfSeconds,
  required int commentEndPositionTenthOfSeconds,
}) {
  final String commentPath =
      "$kPlaylistDownloadRootPathWindowsTest${path.separator}$playlistTitle${path.separator}$kCommentDirName";

  final commentPathFileName = path.join(
    commentPath,
    '$audioFileNameNoExt.json',
  );

  // Load comment from the json file
  List<Comment> loadedCommentLst = JsonDataService.loadListFromFile(
    jsonPathFileName: commentPathFileName,
    type: Comment,
  );

  Comment loadedComment = loadedCommentLst.first;

  expect(loadedComment.title, commentTitle);
  expect(loadedComment.content, commentContent);
  expect(
    loadedComment.commentStartPositionInTenthOfSeconds,
    commentStartPositionTenthOfSeconds,
    reason:
        "json commentStartPositionInTenthOfSeconds: ${loadedComment.commentStartPositionInTenthOfSeconds}, expected $commentStartPositionTenthOfSeconds",
  );
  expect(
    loadedComment.commentEndPositionInTenthOfSeconds,
    commentEndPositionTenthOfSeconds,
    reason:
        "json commentEndPositionInTenthOfSeconds: ${loadedComment.commentEndPositionInTenthOfSeconds}, expected $commentEndPositionTenthOfSeconds",
  );
}

String? getActualText(Finder textWidgetFinder) {
  final elements = textWidgetFinder.evaluate();

  if (elements.isNotEmpty) {
    final textElement = elements.first.widget as Text;
    return textElement.data;
  }

  return null;
}

/// Initializes the application and selects the playlist if
/// [selectedPlaylistTitle] is not null.
Future<void> initializeApplicationAndSelectPlaylist({
  required WidgetTester tester,
  String? savedTestDataDirName,
  String? selectedPlaylistTitle,
}) async {
  // Purge the test playlist directory if it exists so that the
  // playlist list is empty
  DirUtil.deleteFilesInDirAndSubDirs(
    rootPath: kPlaylistDownloadRootPathWindowsTest,
    deleteSubDirectoriesAsWell: true,
  );

  if (savedTestDataDirName != null) {
    // Copy the test initial audio data to the app dir
    DirUtil.copyFilesFromDirAndSubDirsToDirectory(
      sourceRootPath:
          "$kDownloadAppTestSavedDataDir${path.separator}$savedTestDataDirName",
      destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
    );
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

Duration parseDuration(String hhmmString) {
  List<String> parts = hhmmString.split(':');
  if (parts.length != 2) {
    throw const FormatException("Invalid duration format");
  }

  int hours = int.parse(parts[0]);
  int minutes = int.parse(parts[1]);

  return Duration(hours: hours, minutes: minutes);
}

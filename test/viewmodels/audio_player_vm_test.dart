import 'dart:io';

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/services/json_data_service.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:audiolearn/viewmodels/audio_player_vm.dart';
import 'package:audiolearn/viewmodels/comment_vm.dart';
import 'package:audiolearn/viewmodels/picture_vm.dart';
import 'package:audiolearn/viewmodels/playlist_list_vm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/warning_message_vm.dart';

import '../services/mock_shared_preferences.dart';
import 'audio_player_vm_test_version.dart';

/// This unit test does not pass in the Main branch due to the AudioPlayerVM Main branch
/// version which uses the latest version of the audio_player package which cannot be used
/// in integration tests.
void main() {
  group('AudioPlayerVM changeAudioPlayPosition undo/redo', () {
    test('Test single undo/redo of forward position change', () async {
      final AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audio of the selected
      // playlist ordered by download date
      final List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(
        audio: selectedPlaylistAudioList[0],
      );

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition = audioPlayerVM.currentAudioPosition;

      // change the current audio's play position

      int forwardChangePosition = 38;
      await audioPlayerVM.changeAudioPlayPosition(
          posOrNegPositionDurationChange:
              Duration(seconds: forwardChangePosition));

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioChangedPosition.inSeconds -
              currentAudioInitialPosition.inSeconds,
          forwardChangePosition);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds,
          currentAudioInitialPosition.inSeconds);

      // redo the change
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioPositionAfterRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          forwardChangePosition);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test('Test single undo/redo of backward position change', () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audio of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(
        audio: selectedPlaylistAudioList[0],
      );

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition = audioPlayerVM.currentAudioPosition;

      // change the current audio's play position

      int backwardChangePosition = -100;
      await audioPlayerVM.changeAudioPlayPosition(
          posOrNegPositionDurationChange:
              Duration(seconds: backwardChangePosition));

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioChangedPosition.inSeconds -
              currentAudioInitialPosition.inSeconds,
          backwardChangePosition);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds,
          currentAudioInitialPosition.inSeconds);

      // redo the change
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioPositionAfterRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          backwardChangePosition);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        'Test single undo/redo of multiple forward and backward position changes',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audio of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(
        audio: selectedPlaylistAudioList[0],
      );

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition = audioPlayerVM.currentAudioPosition;

      // change three times the current audio's play position

      int forwardChangePositionOne = 18;
      await audioPlayerVM.changeAudioPlayPosition(
          posOrNegPositionDurationChange:
              Duration(seconds: forwardChangePositionOne));

      int backwardChangePositionOne = -60;
      await audioPlayerVM.changeAudioPlayPosition(
          posOrNegPositionDurationChange:
              Duration(seconds: backwardChangePositionOne));

      int forwardChangePositionTwo = 80;
      await audioPlayerVM.changeAudioPlayPosition(
          posOrNegPositionDurationChange:
              Duration(seconds: forwardChangePositionTwo));

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioChangedPosition.inSeconds -
              currentAudioInitialPosition.inSeconds,
          forwardChangePositionOne +
              backwardChangePositionOne +
              forwardChangePositionTwo);

      // undo the last change
      audioPlayerVM.undo();

      // obtain the current audio's position after the first undo
      Duration currentAudioPositionAfterFirstUndo =
          audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioPositionAfterFirstUndo.inSeconds,
          currentAudioInitialPosition.inSeconds +
              forwardChangePositionOne +
              backwardChangePositionOne);

      // redo the change
      audioPlayerVM.redo();

      // obtain the current audio's position after the first redo
      Duration currentAudioPositionAfterFirstRedo =
          audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioPositionAfterFirstRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          forwardChangePositionOne +
              backwardChangePositionOne +
              forwardChangePositionTwo);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        'Test multiple undo/redo of multiple forward and backward position changes',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audio of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(
        audio: selectedPlaylistAudioList[0],
      );

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition = audioPlayerVM.currentAudioPosition;

      // change three times the current audio's play position

      int forwardChangePositionOne = 18;
      await audioPlayerVM.changeAudioPlayPosition(
          posOrNegPositionDurationChange:
              Duration(seconds: forwardChangePositionOne));

      int backwardChangePositionOne = -60;
      await audioPlayerVM.changeAudioPlayPosition(
          posOrNegPositionDurationChange:
              Duration(seconds: backwardChangePositionOne));

      int forwardChangePositionTwo = 80;
      await audioPlayerVM.changeAudioPlayPosition(
          posOrNegPositionDurationChange:
              Duration(seconds: forwardChangePositionTwo));

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioChangedPosition.inSeconds -
              currentAudioInitialPosition.inSeconds,
          forwardChangePositionOne +
              backwardChangePositionOne +
              forwardChangePositionTwo);

      // undo the last and previous change
      audioPlayerVM.undo();
      audioPlayerVM.undo();

      // obtain the current audio's position after the two undo's
      Duration currentAudioPositionAfterTwoUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterTwoUndo.inSeconds,
          currentAudioInitialPosition.inSeconds + forwardChangePositionOne);

      // redo the previous change
      audioPlayerVM.redo();

      // obtain the current audio's position after the first redo
      Duration currentAudioPositionAfterFirstRedo =
          audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioPositionAfterFirstRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          forwardChangePositionOne + backwardChangePositionOne);

      // redo the last change
      audioPlayerVM.redo();

      // obtain the current audio's position after the second redo
      Duration currentAudioPositionAfterSecondRedo =
          audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioPositionAfterSecondRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          forwardChangePositionOne +
              backwardChangePositionOne +
              forwardChangePositionTwo);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        'Test insert a new command between multiple undo/redo of multiple forward and backward position changes',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audio of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(
        audio: selectedPlaylistAudioList[0],
      );

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition =
          audioPlayerVM.currentAudioPosition; // 600

      // change three times the current audio's play position

      int forwardChangePositionOne = 18;
      await audioPlayerVM.changeAudioPlayPosition(
          posOrNegPositionDurationChange:
              Duration(seconds: forwardChangePositionOne)); // 700

      int backwardChangePositionOne = -60;
      await audioPlayerVM.changeAudioPlayPosition(
          posOrNegPositionDurationChange:
              Duration(seconds: backwardChangePositionOne)); // 640

      int forwardChangePositionTwo = 80;
      await audioPlayerVM.changeAudioPlayPosition(
          posOrNegPositionDurationChange:
              Duration(seconds: forwardChangePositionTwo)); // 720

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioChangedPosition.inSeconds - // 720
              currentAudioInitialPosition.inSeconds,
          forwardChangePositionOne + // 100 +
              backwardChangePositionOne + // -60 +
              forwardChangePositionTwo); // 80 --> 120

      // undo the last forward change (forward two)
      audioPlayerVM.undo();

      // enter a new command
      int forwardChangePositionThree = 120;
      await audioPlayerVM.changeAudioPlayPosition(
          // 765
          posOrNegPositionDurationChange:
              Duration(seconds: forwardChangePositionThree));

      // obtain the current audio's position after
      // the undo and the new command
      Duration currentAudioPositionAfterUndoAndCommand =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndoAndCommand.inSeconds,
          currentAudioInitialPosition.inSeconds + 38); // 389

      // redo the last forward change (forward two)
      audioPlayerVM.redo();

      // obtain the current audio's position after the redoing
      // the last forward change (forward two)
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioPositionAfterRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          38);

      // undo the last forward change (forward two), the new
      // command and the previous backward change (backward one)
      audioPlayerVM.undo(); // 765
      audioPlayerVM.undo(); // 640
      audioPlayerVM.undo(); // 700

      // obtain the current audio's position after the second redo
      Duration currentAudioPositionAfterThreeUndo =
          audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioPositionAfterThreeUndo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          18);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group('AudioPlayerVM goToAudioPlayPosition undo/redo', () {
    test('Test single undo/redo of forward slider position change', () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audio of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(
        audio: selectedPlaylistAudioList[0],
      );

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition =
          audioPlayerVM.currentAudioPosition; // 600

      // change the current audio's play slider position

      int forwardNewSliderPosition = 700;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: forwardNewSliderPosition));

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioChangedPosition.inSeconds -
              currentAudioInitialPosition.inSeconds,
          349);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds,
          currentAudioInitialPosition.inSeconds);

      // redo the change
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterRedo.inSeconds, 700);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test('Test single undo/redo of backward slider position change', () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audio of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(
        audio: selectedPlaylistAudioList[0],
      );

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition =
          audioPlayerVM.currentAudioPosition; // 600

      // change the current audio's play slider position

      int backwardNewSliderPosition = 540;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: backwardNewSliderPosition));

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioChangedPosition.inSeconds -
              currentAudioInitialPosition.inSeconds,
          189);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds,
          currentAudioInitialPosition.inSeconds);

      // redo the change
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioPositionAfterRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          189);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        'Test single undo/redo of multiple forward and backward slider position changes',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audio of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(
        audio: selectedPlaylistAudioList[0],
      );

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition =
          audioPlayerVM.currentAudioPosition; // 600

      // change three times the current audio's play slider position

      int forwardNewSliderPositionOne = 700;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: forwardNewSliderPositionOne));

      int backwardNewSliderPositionOne = 640;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: backwardNewSliderPositionOne));

      int forwardNewSliderPositionTwo = 720;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: forwardNewSliderPositionTwo));

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition =
          audioPlayerVM.currentAudioPosition; // 720

      expect(
          currentAudioChangedPosition.inSeconds -
              currentAudioInitialPosition.inSeconds,
          369);

      // undo the last change
      audioPlayerVM.undo();

      // obtain the current audio's position after the first undo
      Duration currentAudioPositionAfterFirstUndo =
          audioPlayerVM.currentAudioPosition; // 640

      expect(currentAudioPositionAfterFirstUndo.inSeconds, 640);

      // redo the change
      audioPlayerVM.redo();

      // obtain the current audio's position after the first redo
      Duration currentAudioPositionAfterFirstRedo =
          audioPlayerVM.currentAudioPosition; // 720

      expect(
          currentAudioPositionAfterFirstRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          369);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        'Test multiple undo/redo of multiple forward and backward slider position changes',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audio of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(
        audio: selectedPlaylistAudioList[0],
      );

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition =
          audioPlayerVM.currentAudioPosition; // 600

      // change three times the current audio's slider play position

      int forwardNewSliderPositionOne = 700;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: forwardNewSliderPositionOne));

      int backwardNewSliderPositionOne = 640;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: backwardNewSliderPositionOne));

      int forwardNewSliderPositionTwo = 720;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: forwardNewSliderPositionTwo));

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition =
          audioPlayerVM.currentAudioPosition; // 720

      expect(
          currentAudioChangedPosition.inSeconds -
              currentAudioInitialPosition.inSeconds,
          369);

      // undo the last and previous change
      audioPlayerVM.undo(); // undo 720 --> 640
      audioPlayerVM.undo(); // undo 640 --> 700

      // obtain the current audio's position after the two undo's
      Duration currentAudioPositionAfterTwoUndo =
          audioPlayerVM.currentAudioPosition; // 700

      expect(currentAudioPositionAfterTwoUndo.inSeconds, 700);

      // redo the previous change
      audioPlayerVM.redo(); // redo 640 --> 640

      // obtain the current audio's position after the first redo
      Duration currentAudioPositionAfterFirstRedo =
          audioPlayerVM.currentAudioPosition; // 640

      expect(
          currentAudioPositionAfterFirstRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          289);

      // redo the last change
      audioPlayerVM.redo(); // redo 720 --> 720

      // obtain the current audio's position after the second redo
      Duration currentAudioPositionAfterSecondRedo =
          audioPlayerVM.currentAudioPosition; // 720

      expect(
          currentAudioPositionAfterSecondRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          369);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        'Test insert a new slider command between multiple undo/redo of multiple forward and backward slider position changes',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audio of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(
        audio: selectedPlaylistAudioList[0],
      );

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition =
          audioPlayerVM.currentAudioPosition; // 600

      // change three times the current audio's play position

      int forwardNewSliderPositionOne = 700;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: forwardNewSliderPositionOne));

      int backwardNewSliderPositionOne = 640;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: backwardNewSliderPositionOne));

      int forwardNewSliderPositionTwo = 720;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: forwardNewSliderPositionTwo));

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition =
          audioPlayerVM.currentAudioPosition; // 720

      expect(
          currentAudioChangedPosition.inSeconds -
              currentAudioInitialPosition.inSeconds,
          369);

      // undo the last slider change
      audioPlayerVM.undo(); // undo 720 --> 640

      // enter a new command
      int forwardNewSliderPositionThree = 825;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: forwardNewSliderPositionThree));

      // obtain the current audio's position after
      // the undo and the new slider command
      Duration currentAudioPositionAfterUndoAndNewSliderCommand =
          audioPlayerVM.currentAudioPosition; // 825

      expect(currentAudioPositionAfterUndoAndNewSliderCommand.inSeconds,
          currentAudioInitialPosition.inSeconds + 474); // 825

      // redo the last slider forward change (forward two)
      audioPlayerVM.redo(); // redo 720 --> 720

      // obtain the current audio's position after the redoing
      // the last forward change (forward two)
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition; // 720

      expect(
          currentAudioPositionAfterRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          369);

      // undo the last forward change (forward two), the new
      // command and the previous backward change (backward one)
      audioPlayerVM.undo(); // 720 --> 640
      audioPlayerVM.undo(); // 825 --> 640
      audioPlayerVM.undo(); // 640 --> 700

      // obtain the current audio's position after the second redo
      Duration currentAudioPositionAfterThreeUndo =
          audioPlayerVM.currentAudioPosition; // 700

      expect(
          currentAudioPositionAfterThreeUndo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          349);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        "Test insert a new slider command after first undo forward slider position change, then perform one undo before one redo. This test could not be done in the AudioPlayerView integration test because the moving the slider to a new position is not possible in the integration test.",
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audio of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(
        audio: selectedPlaylistAudioList[0],
      );

      // change one time the current audio's play position

      int forwardNewSliderPositionOne = 720;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: forwardNewSliderPositionOne));

      // check the current audio's changed position
      expect(audioPlayerVM.currentAudioPosition.inSeconds, 720);

      // undo the first slider forward change
      audioPlayerVM.undo(); // undo 720 --> 600

      // enter a new command. Entering a new command does not affect the
      // undo command list
      int backwardNewSliderPositionTwo = 560;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: backwardNewSliderPositionTwo));

      // check the current audio's position after the first undo and the
      // new slider backward command
      expect(audioPlayerVM.currentAudioPosition.inSeconds, 560);

      // redo the first slider undone change (forward one). Entering a new
      // command did not affect the redoing of the first undone slider change
      audioPlayerVM.redo(); // redo 720 --> 720

      // check the current audio's position after the redoing the first
      // forward change (forward one)
      expect(audioPlayerVM.currentAudioPosition.inSeconds, 720);

      // undo the redone first forward change (forward one)
      audioPlayerVM.undo(); // 720 --> 600

      // check the current audio's position after the first undo
      expect(audioPlayerVM.currentAudioPosition.inSeconds, 351);

      // redo the first slider change
      audioPlayerVM.redo(); // redo 720 --> 720

      // check the current audio's position after the redo
      expect(audioPlayerVM.currentAudioPosition.inSeconds, 720);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        "Test insert a new slider command after first undo forward slider position change, then perform two undo's before one redo in order to redo the new slider backward command. This test could not be done in the AudioPlayerView integration test because the moving the slider to a new position is not possible in the integration test.",
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audio of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(
        audio: selectedPlaylistAudioList[0],
      );

      // change one time the current audio's play position

      int forwardNewSliderPositionOne = 720;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: forwardNewSliderPositionOne));

      // check the current audio's changed position
      expect(audioPlayerVM.currentAudioPosition.inSeconds, 720);

      // undo the first slider forward change
      audioPlayerVM.undo(); // undo 720 --> 600

      // enter a new command. Entering a new command does not affect the
      // undo command list
      int backwardNewSliderPositionTwo = 560;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: backwardNewSliderPositionTwo));

      // check the current audio's position after the first undo and the
      // new slider backward command
      expect(audioPlayerVM.currentAudioPosition.inSeconds, 560);

      // redo the first slider undone change (forward one). Entering a new
      // command did not affect the redoing of the first undone slider change
      audioPlayerVM.redo(); // redo 720 --> 720

      // check the current audio's position after the redoing the first
      // forward change (forward one)
      expect(audioPlayerVM.currentAudioPosition.inSeconds, 720);

      // undo the redone first forward change (forward one)
      audioPlayerVM.undo(); // 720 --> 600

      // perform a second undo in order to be able to redo the slider new
      // backward command
      audioPlayerVM.undo(); // 600 --> 600

      // check the current audio's position after the first undo
      expect(audioPlayerVM.currentAudioPosition.inSeconds, 351);

      // redo the first slider change
      audioPlayerVM.redo(); // redo 560 --> 560

      // check the current audio's position after the redo
      expect(audioPlayerVM.currentAudioPosition.inSeconds, 560);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group('AudioPlayerVM bug', () {
    test(
        'Test bug single undo/redo of sliding backward to 3 seconds and then going 1 minute backward',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audio of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(
        audio: selectedPlaylistAudioList[0],
      );

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition =
          audioPlayerVM.currentAudioPosition; // 600

      // change the current audio's play slider position to 3
      // seconds

      int backwardNewSliderPositionThreeSeconds = 3;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition:
              Duration(seconds: backwardNewSliderPositionThreeSeconds));

      // obtain the current audio's new position
      Duration currentAudioNewPosition =
          audioPlayerVM.currentAudioPosition; // 3

      expect(
          currentAudioInitialPosition.inSeconds - // 600 - 3
              currentAudioNewPosition.inSeconds,
          348);

      // change the current audio's play position minus 1 minute

      int backwardChangePositionOneMinute = -60;
      await audioPlayerVM.changeAudioPlayPosition(
          posOrNegPositionDurationChange:
              Duration(seconds: backwardChangePositionOneMinute));

      // obtain the current audio's changed position (0 second)
      currentAudioNewPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioNewPosition.inSeconds, 0);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds, 3);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        'Test bug single undo/redo of sliding backward to 3 seconds and then going 10 seconds backward',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audio of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(
        audio: selectedPlaylistAudioList[0],
      );

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition =
          audioPlayerVM.currentAudioPosition; // 600

      // change the current audio's play slider position to 3
      // seconds

      int backwardNewSliderPositionThreeSeconds = 3;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition:
              Duration(seconds: backwardNewSliderPositionThreeSeconds));

      // obtain the current audio's new position
      Duration currentAudioNewPosition =
          audioPlayerVM.currentAudioPosition; // 3

      expect(
          currentAudioInitialPosition.inSeconds - // 600 - 3
              currentAudioNewPosition.inSeconds,
          348);

      // change the current audio's play position minus 1 minute

      int backwardChangePositionTenSeconds = -10;
      await audioPlayerVM.changeAudioPlayPosition(
          posOrNegPositionDurationChange:
              Duration(seconds: backwardChangePositionTenSeconds));

      // obtain the current audio's changed position (0 second)
      currentAudioNewPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioNewPosition.inSeconds, 0);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds, 3);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        'Test bug single undo/redo of sliding forward to 20 minutes 25 seconds and then going 1 minute forward',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audio of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(
        audio: selectedPlaylistAudioList[0],
      );

      // change the current audio's play slider position to 3
      // seconds

      int forwardNewSliderPositionTwentyMinutesTwentyFiveSeconds = 1225;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(
              seconds: forwardNewSliderPositionTwentyMinutesTwentyFiveSeconds));

      // obtain the current audio's new position
      Duration currentAudioNewPosition =
          audioPlayerVM.currentAudioPosition; // 20 minutes 25 secs = 1225 secs

      expect(currentAudioNewPosition.inSeconds, 1225);

      // change the current audio's play position plus 1 minute

      int backwardChangePositionOneMinute = 60;
      await audioPlayerVM.changeAudioPlayPosition(
          posOrNegPositionDurationChange:
              Duration(seconds: backwardChangePositionOneMinute));

      // obtain the current audio's changed position (audio duration)
      currentAudioNewPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioNewPosition.inSeconds,
          audioPlayerVM.currentAudio!.audioDuration.inSeconds);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds, 1225);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        'Test bug single undo/redo of sliding forward to 20 minutes 25 seconds and then going 10 seconds forward',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audio of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(
        audio: selectedPlaylistAudioList[0],
      );

      // change the current audio's play slider position to 3
      // seconds

      int forwardNewSliderPositionTwentyMinutesTwentyFiveSeconds = 1225;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(
              seconds: forwardNewSliderPositionTwentyMinutesTwentyFiveSeconds));

      // obtain the current audio's new position
      Duration currentAudioNewPosition =
          audioPlayerVM.currentAudioPosition; // 20 minutes 25 secs = 1225 secs

      expect(currentAudioNewPosition.inSeconds, 1225);

      // change the current audio's play position plus 1 minute

      int forwardChangePositionTenSeconds = 10;
      await audioPlayerVM.changeAudioPlayPosition(
          posOrNegPositionDurationChange:
              Duration(seconds: forwardChangePositionTenSeconds));

      // obtain the current audio's changed position (audio duration)
      currentAudioNewPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioNewPosition.inSeconds,
          audioPlayerVM.currentAudio!.audioDuration.inSeconds);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds, 1225);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        '''Test audio speed zero bug fix. Now audio with speed zero can be played
           since its peed is set to default playlist speed.''', () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM(
        savedTestDataDirName: 'audio_player_view_zero_speed_test',
      );

      // obtain the list of playable audio of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      Audio currentAudio = selectedPlaylistAudioList[0];

      expect(currentAudio.audioPlaySpeed, 0.0);

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(
        audio: currentAudio,
      );

      expect(currentAudio.audioPlaySpeed, 1.25);

      const String playListOneName = "audio_player_view_0_speed_test";

      // Load Playlist from the file
      Playlist loadedPlaylistOne = loadPlaylist(playListOneName);

      expect(loadedPlaylistOne.playableAudioLst[0].audioPlaySpeed, 1.25);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group('AudioPlayerVM skipToStart undo/redo', () {
    test('Test single undo/redo of skipToStart position change', () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audio of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(
        audio: selectedPlaylistAudioList[0],
      );

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition =
          audioPlayerVM.currentAudioPosition; // 600

      // skip to the start of the current audio

      await audioPlayerVM.skipToStart();

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds, 0);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds,
          currentAudioInitialPosition.inSeconds);

      // redo the change
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterRedo.inSeconds, 0);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        'Test multiple undo/redo of multiple forward and skipToStart position change',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audio of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(
        audio: selectedPlaylistAudioList[0],
      );

      // skip to the end of the current audio

      await audioPlayerVM.skipToStart();

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds, 0);

      // change the current audio's play position from the start
      // to 100 seconds

      int forwardChangePosition = 100;
      await audioPlayerVM.changeAudioPlayPosition(
          posOrNegPositionDurationChange:
              Duration(seconds: forwardChangePosition));

      // obtain the current audio's changed position
      currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioChangedPosition.inSeconds, forwardChangePosition); // 100

      // skip a second time to the start of the current audio

      await audioPlayerVM.skipToStart();

      // obtain the current audio's changed position
      currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds, 0);

      // undo the second skip to start
      audioPlayerVM.undo();

      currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds, 100);

      // undo forward change to 100 seconds
      audioPlayerVM.undo();

      // obtain the current audio's position after the second undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds, 0);

      // undo the first skip to start
      audioPlayerVM.undo();

      currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds, 351);

      // redo the first skip to start
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterRedo.inSeconds, 0);

      // redo the first forward change to 100 seconds
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      currentAudioPositionAfterRedo = audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterRedo.inSeconds, 100);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group('AudioPlayerVM skipToEndAndPlay undo/redo', () {
    test('Test single undo/redo of skipToEnd position change', () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audio of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(
        audio: selectedPlaylistAudioList[0],
      );

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition =
          audioPlayerVM.currentAudioPosition; // 600

      // skip to the end of the current audio

      await audioPlayerVM.skipToEndAndPlay();

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds,
          audioPlayerVM.currentAudio!.audioDuration.inSeconds);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds,
          currentAudioInitialPosition.inSeconds);

      // redo the change
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterRedo.inSeconds,
          audioPlayerVM.currentAudio!.audioDuration.inSeconds);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        'Test multiple undo/redo of multiple forward and skipToEnd position change',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audio of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(
        audio: selectedPlaylistAudioList[0],
      );

      // skip to the start of the current audio

      await audioPlayerVM.skipToEndAndPlay();

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      int currentAudioTotalDurationInSeconds =
          audioPlayerVM.currentAudioTotalDuration.inSeconds;

      expect(currentAudioChangedPosition.inSeconds,
          currentAudioTotalDurationInSeconds);

      // change the current audio's play position from the start
      // to 100 seconds

      int backwardChangePosition = -100;

      await audioPlayerVM.changeAudioPlayPosition(
          posOrNegPositionDurationChange:
              Duration(seconds: backwardChangePosition));

      // obtain the current audio's changed position
      currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds,
          currentAudioTotalDurationInSeconds - 100);

      // skip a second time to the end of the current audio

      await audioPlayerVM.skipToEndAndPlay();

      // obtain the current audio's changed position
      currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds,
          currentAudioTotalDurationInSeconds);

      // undo the second skip to end
      audioPlayerVM.undo();

      currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds,
          currentAudioTotalDurationInSeconds - 100); // 100

      // undo backward change to -100 seconds
      audioPlayerVM.undo();

      // obtain the current audio's position after the second undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds,
          currentAudioTotalDurationInSeconds);

      // undo the first skip to end
      audioPlayerVM.undo();

      currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds, 351);

      // redo the first skip to end
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterRedo.inSeconds,
          currentAudioTotalDurationInSeconds);

      // redo the first backward change to -100 seconds
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      currentAudioPositionAfterRedo = audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterRedo.inSeconds,
          currentAudioTotalDurationInSeconds - 100);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
}

Future<AudioPlayerVM> createAudioPlayerVM({
  String savedTestDataDirName = 'audio_player_vm_play_position_undo_redo_test',
}) async {
  final SettingsDataService settingsDataService =
      await initializeTestDataAndLoadSettingsDataService(
    savedTestDataDirName: savedTestDataDirName,
  );
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
  final CommentVM commentVM = CommentVM();

  // calling getUpToDateSelectablePlaylists() loads all the
  // playlist json files from the app dir and so enables
  // playlistListVM to know which playlists are
  // selected and which are not
  playlistListVM.getUpToDateSelectablePlaylists();

  final AudioPlayerVM audioPlayerVM = AudioPlayerVMTestVersion(
    settingsDataService: settingsDataService,
    playlistListVM: playlistListVM,
    commentVM: commentVM,
  );

  return audioPlayerVM;
}

Future<SettingsDataService> initializeTestDataAndLoadSettingsDataService({
  String? savedTestDataDirName,
}) async {
  // Purge the test playlist directory if it exists so that the
  // playlist list is empty
  DirUtil.deleteFilesInDirAndSubDirs(
    rootPath: kApplicationPathWindowsTest,
    deleteSubDirectoriesAsWell:
        true, // reduce number of times the Flutter test fails. Not explanable.
  );

  if (savedTestDataDirName != null) {
    // Copy the test initial audio data to the app dir
    DirUtil.copyFilesFromDirAndSubDirsToDirectory(
      sourceRootPath:
          "$kDownloadAppTestSavedDataDir${Platform.pathSeparator}$savedTestDataDirName",
      destinationRootPath: kApplicationPathWindowsTest,
    );
  }

  SettingsDataService settingsDataService = SettingsDataService(
    sharedPreferences: MockSharedPreferences(),
  );

  // Load the settings from the json file. This is necessary
  // otherwise the ordered playlist titles will remain empty
  // and the playlist list will not be filled with the
  // playlists available in the download app test dir
  await settingsDataService.loadSettingsFromFile(
      settingsJsonPathFileName:
          "$kApplicationPathWindowsTest${Platform.pathSeparator}$kSettingsFileName");

  return settingsDataService;
}

Playlist loadPlaylist(String playListOneName) {
  return JsonDataService.loadFromFile(
      jsonPathFileName:
          "$kApplicationPathWindowsTest${path.separator}$playListOneName${path.separator}$playListOneName.json",
      type: Playlist);
}

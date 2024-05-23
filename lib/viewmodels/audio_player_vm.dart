import 'package:flutter/material.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

import '../constants.dart';
import '../models/audio.dart';
import '../models/playlist.dart';
import '../services/json_data_service.dart';
import '../services/sort_filter_parameters.dart';
import '../utils/duration_expansion.dart';
import 'playlist_list_vm.dart';

/// Abstract class used to implement the Command design pattern
/// for the undo/redo functionality.
abstract class Command {
  void redo();
  void undo();
}

/// Command class used when the user clicks on
/// '>>' 10 seconds or 1 minute buttons OR
/// '<<' 10 seconds or 1 minute buttons
/// or when the user clicks the first time on
/// the >| icon if the audio position is not already at end or
/// when the user clicks on the the first time on
/// the |< icon if the audio position is not already at start or
/// when the user clicks on the audio slider.
class SetAudioPositionCommand implements Command {
  final AudioPlayerVM audioPlayerVM;
  final Duration oldDurationPosition;
  final Duration newDurationPosition;

  SetAudioPositionCommand({
    required this.audioPlayerVM,
    required this.oldDurationPosition,
    required this.newDurationPosition,
  });

  @override
  void redo() {
    audioPlayerVM.goToAudioPlayPosition(
      durationPosition: newDurationPosition,
      isUndoRedo: true,
    );
  }

  @override
  void undo() {
    audioPlayerVM.goToAudioPlayPosition(
      durationPosition: oldDurationPosition,
      isUndoRedo: true,
    );
  }
}

/// This VM (View Model) class is part of the MVVM architecture.
///
/// This class manages the audio player obtained from the
/// audioplayers package.
///
/// It is used in the AudioPlayerView screen to manage the audio
/// playing position modifications as well as the reference on the
/// current playing audio.
///
/// As Consumer<AudioPlayerVM> in the AudioPlayerView screen, it
/// updates the different widgets showing the current audio playing
/// position and the current audio title.
///
/// It is also used in the AudioListItemWidget to display the
/// current audio playing status.
///
/// It is also used in the AudioOneSelectableDialogWidget to
/// obtain the list of audios - currently ordered by download
/// date - to be displayed in the dialog.
class AudioPlayerVM extends ChangeNotifier {
  Audio? _currentAudio;
  Audio? get currentAudio => _currentAudio;
  final PlaylistListVM _playlistListVM;
  AudioPlayer? _audioPlayerPlugin;
  Duration _currentAudioTotalDuration = const Duration();
  Duration _currentAudioPosition = const Duration();

  Duration get currentAudioPosition => _currentAudioPosition;
  Duration get currentAudioTotalDuration => _currentAudioTotalDuration;
  Duration get currentAudioRemainingDuration =>
      _currentAudioTotalDuration - _currentAudioPosition;

  bool get isPlaying => _audioPlayerPlugin!.state == PlayerState.playing;

  DateTime _currentAudioLastSaveDateTime = DateTime.now();

  final List<Command> _undoList = [];
  final List<Command> _redoList = [];

  AudioPlayerVM({
    required PlaylistListVM playlistListVM,
  }) : _playlistListVM = playlistListVM {
    initializeAudioPlayerPlugin();
  }

  @override
  void dispose() {
    if (_audioPlayerPlugin != null) {
      _audioPlayerPlugin!.dispose();
    }

    super.dispose();
  }

  /// Calling this method instead of the AudioPlayerVM dispose()
  /// method enables audio player view integr test to be ok even
  /// if the test app is not the active Windows app.
  void disposeAudioPlayer() {
    if (_audioPlayerPlugin != null) {
      _audioPlayerPlugin!.dispose();
    }
  }

  bool isCurrentAudioVolumeMax() {
    if (_currentAudio == null) {
      return false;
    }

    return _currentAudio!.audioPlayVolume == 1.0;
  }

  bool isCurrentAudioVolumeMin() {
    if (_currentAudio == null) {
      return false;
    }

    return _currentAudio!.audioPlayVolume == 0.0;
  }

  /// {volumeChangedValue} must be between -1.0 and 1.0. The
  /// initial audio volume is 0.5 and will be decreased or
  /// increased by this value.
  void changeAudioVolume({
    required double volumeChangedValue,
  }) {
    double newAudioPlayVolume =
        (_currentAudio!.audioPlayVolume + volumeChangedValue).clamp(0.0, 1.0);
    _currentAudio!.audioPlayVolume =
        newAudioPlayVolume; // Increase and clamp to max 1.0
    _audioPlayerPlugin!.setVolume(newAudioPlayVolume);

    updateAndSaveCurrentAudio(forceSave: true);

    notifyListeners();
  }

  /// Method called when the user clicks on the audio title or sub
  /// title or when he clicks on a play icon or when he selects an
  /// audio in the AudioOneSelectableDialogWidget displayed by
  /// clicking on the audio title on the AudioPlayerView or by
  /// long pressing on the >| button.
  ///
  /// Method called also by setNextAudio() or setPreviousAudio().
  Future<void> setCurrentAudio(Audio audio) async {
    await _setCurrentAudioAndInitializeAudioPlayer(audio);

    audio.enclosingPlaylist!.setCurrentOrPastPlayableAudio(audio);
    updateAndSaveCurrentAudio(forceSave: true);
    _clearUndoRedoLists();

    notifyListeners();
  }

  /// Method called when the user clicks on the audio title or sub
  /// title or when he clicks on a play icon or when he selects an
  /// audio in the AudioOneSelectableDialogWidget displayed by
  /// clicking on the audio title on the AudioPlayerView or by
  /// long pressing on the >| button.
  void _clearUndoRedoLists() {
    _undoList.clear();
    _redoList.clear();
  }

  /// Method called indirectly when the user clicks on the audio title
  /// or sub title or when he clicks on a play icon or when he selects
  /// an audio in the AudioOneSelectableDialogWidget displayed by
  /// clicking on the audio title on the AudioPlayerView or by
  /// long pressing on the >| button.
  ///
  /// Method called indirectly also by setNextAudio() or
  /// setPreviousAudio().
  ///
  /// Method called indirectly also when the user clicks on the
  /// AudioPlayerView icon or drag to this screen. This switches to
  /// the AudioPlayerView screen without playing the selected playlist
  /// current or last played audio which is displayed correctly in the
  /// AudioPlayerView screen.
  Future<void> _setCurrentAudioAndInitializeAudioPlayer(
    Audio audio,
  ) async {
    if (_currentAudio != null && !_currentAudio!.isPaused) {
      _currentAudio!.isPaused = true;
      // saving the previous current audio state before changing
      // the current audio
      updateAndSaveCurrentAudio(forceSave: true);
    }

    _currentAudio = audio;

    // without setting _currentAudioTotalDuration to the audio duration,
    // the next instruction causes an error: Failed assertion: line 194
    // pos 15: 'value >= min && value <= max': Value 3.0 is not between
    // minimum 0.0 and maximum 0.0
    _currentAudioTotalDuration = audio.audioDuration ?? const Duration();

    // setting the audio position to the audio position stored on the
    // audio. The advantage is that when the AudioPlayerView is opened
    // the audio position is set to the last position played.
    //
    // Then, when the user clicks on the play icon, the audio position
    // is reduced according to the time elapsed since the audio was
    // paused, which is done in _setCurrentAudioPosition().
    _currentAudioPosition = Duration(seconds: audio.audioPositionSeconds);
    _clearUndoRedoLists();

    initializeAudioPlayerPlugin();
  }

  /// Adjusts the playback start position of the current audio based on the elapsed
  /// time since it was last paused.
  ///
  /// This method applies a decrement to the saved play position to accommodate
  /// for human memory retention and comfort when resuming audio playback.
  ///
  /// The decrement is determined by the duration for which the audio has been paused:
  /// - If the audio was paused less than a minute ago, the play position will be
  ///   rewound by 2 seconds to help recall the immediate context.
  /// - If the audio was paused more than a minute ago but less than an hour, the
  ///   play position will be rewound by 20 seconds to re-establish context without
  ///   significant overlap.
  /// - If the audio was paused for an hour or longer, the play position will be
  ///   rewound by 30 seconds to cater for a longer gap in listening continuity.
  ///
  /// The play position will not be adjusted to a negative value; if the rewind
  /// operation results in a negative position, it will be set to the start of the
  /// audio.
  ///
  /// Precondition:
  /// The `_currentAudio` must be non-null and must have a valid `audioPositionSeconds`.
  ///
  /// Postcondition:
  /// The `_currentAudioPosition` will be updated to reflect the adjusted play position,
  /// and the audio player will seek to this new position.
  ///
  /// If the `audioPausedDateTime` is null, indicating that the audio has not been paused,
  /// the audio player's position will not be adjusted.
  Future<void> _rewindAudioPositionBasedOnPauseDuration() async {
    DateTime? audioPausedDateTime = _currentAudio!.audioPausedDateTime;

    if (audioPausedDateTime != null) {
      final int pausedDurationSecs =
          DateTime.now().difference(audioPausedDateTime).inSeconds;
      int rewindSeconds = 0;

      if (pausedDurationSecs < 60) {
        rewindSeconds = 2;
      } else if (pausedDurationSecs < 3600) {
        rewindSeconds = 20;
      } else {
        rewindSeconds = 30;
      }

      int newPositionSeconds =
          _currentAudio!.audioPositionSeconds - rewindSeconds;
      // Ensure the new position is not negative
      _currentAudioPosition = Duration(
          seconds: newPositionSeconds.clamp(
              0, _currentAudio!.audioDuration!.inSeconds));

      await _audioPlayerPlugin!.seek(_currentAudioPosition);
    }
  }

  /// Method called by skipToEndNoPlay() if the audio is positioned
  /// at end and by playNextAudio().
  Future<bool> _setNextNotPlayedAudio() async {
    Audio? nextAudio;

    nextAudio = _playlistListVM.getSubsequentlyDownloadedNotFullyPlayedAudio(
      currentAudio: _currentAudio!,
    );

    if (nextAudio == null) {
      // the case if the current audio is the last playable audio of the
      // playlist
      return false;
    }

    await setCurrentAudio(nextAudio);

    return true;
  }

  /// Method called by skipToStart() if the audio is positioned at
  /// start.
  Future<void> _setPreviousAudio() async {
    Audio? previousAudio = _playlistListVM.getPreviouslyDownloadedPlayableAudio(
      currentAudio: _currentAudio!,
    );

    if (previousAudio == null) {
      return;
    }

    await setCurrentAudio(previousAudio);
  }

  /// Method to be redefined in AudioPlayerVMTestVersion in order
  /// to avoid the use of the audio player plugin in unit tests.
  void initializeAudioPlayerPlugin() {
    if (_audioPlayerPlugin != null) {
      _audioPlayerPlugin!.dispose();
    }

    _audioPlayerPlugin = AudioPlayer();

    // Assuming filePath is the full path to your audio file
    String audioFilePathName = _currentAudio?.filePathName ?? '';

    // Check if the file exists before attempting to play it
    if (audioFilePathName.isNotEmpty && File(audioFilePathName).existsSync()) {
      _audioPlayerPlugin!.onDurationChanged.listen((duration) {
        _currentAudioTotalDuration = duration;
        notifyListeners();
      });

      _audioPlayerPlugin!
          .setVolume(_currentAudio?.audioPlayVolume ?? kAudioDefaultPlayVolume);

      _audioPlayerPlugin!.onPositionChanged.listen((position) {
        if (_audioPlayerPlugin!.state == PlayerState.playing) {
          // this test avoids that when selecting another audio
          // the selected audio position is set to 0 since the
          // passed position value of an AudioPlayer not playing
          // is 0 !
          _currentAudioPosition = position;
          updateAndSaveCurrentAudio();
        }

        _audioPlayerPlugin!.onPlayerComplete.listen((event) async {
          // fixing the bug when the audio is at end the smartphone did
          // not start the next playable audio. This happens on S20, but
          // not on S8.
          _currentAudioPosition = _currentAudioTotalDuration;

          // Play next audio when current audio finishes.
          await playNextAudio();
        });

        notifyListeners();
      });
    }
  }

  /// Method called when the user clicks on the AudioPlayerView
  /// icon or drag to this screen.
  ///
  /// This switches to the AudioPlayerView screen without playing
  /// the selected playlist current or last played audio which
  /// is displayed correctly in the AudioPlayerView screen.
  Future<void> setCurrentAudioFromSelectedPlaylist() async {
    List<Playlist> selectedPlaylistLst = _playlistListVM.getSelectedPlaylists();

    if (selectedPlaylistLst.isEmpty) {
      // ensures that when the user deselect the playlist, switching
      // to the AudioPlayerView screen causes the "No audio selected"
      // audio title to be displayed in the AudioPlayerView screen.
      _clearCurrentAudio();
      _clearUndoRedoLists();

      return;
    }

    Audio? currentOrPastPlaylistAudio = selectedPlaylistLst.first
        .getCurrentOrLastlyPlayedAudioContainedInPlayableAudioLst();

    if (currentOrPastPlaylistAudio == null) {
      // causes "No audio selected" audio title to be displayed
      // in the AudioPlayerView screen. Reinitializing the
      // the _currentAudioPosition as well as the
      // _currentAudioTotalDuration ensure that the audio slider
      // is correctly displayed at position 0:00 and that the
      // displayed audio duration is 0:00.
      _currentAudio = null;
      _currentAudioPosition = const Duration();
      _currentAudioTotalDuration = const Duration();

      _clearUndoRedoLists();
      initializeAudioPlayerPlugin();

      return;
    }

    if (_currentAudio == currentOrPastPlaylistAudio) {
      return;
    }

    await _setCurrentAudioAndInitializeAudioPlayer(currentOrPastPlaylistAudio);
  }

  void _clearCurrentAudio() {
    _currentAudio = null;
    _currentAudioTotalDuration = const Duration();
    _currentAudioPosition = const Duration(seconds: 0);

    _audioPlayerPlugin!.dispose();
  }

  /// Method called when the user clicks on the audio play icon
  Future<void> playFromCurrentAudioFile({
    bool rewindAudioPositionBasedOnPauseDuration = true,
  }) async {
    if (_currentAudio == null) {
      // the case if the AudioPlayerView is opened directly by
      // dragging to it or clicking on the title or sub title
      // of an audio and not after the user has clicked on the
      // Playlist Download View audio play icon button.
      //
      // Getting the first selected playlist makes sense since
      // currently only one playlist can be selected at a time
      // in the PlaylistDownloadView.
      _currentAudio = _playlistListVM
          .getSelectedPlaylists()
          .first
          .getCurrentOrLastlyPlayedAudioContainedInPlayableAudioLst();

      if (_currentAudio == null) {
        // the case if no audio in the selected playlist was ever played
        return;
      }
    }

    String audioFilePathName = _currentAudio!.filePathName;

    // Check if the file exists before attempting to play it
    if (File(audioFilePathName).existsSync()) {
      if (rewindAudioPositionBasedOnPauseDuration) {
        await _rewindAudioPositionBasedOnPauseDuration();
      }

      await _audioPlayerPlugin!.play(DeviceFileSource(
          audioFilePathName)); // <-- Directly using play method
      await _audioPlayerPlugin!.setPlaybackRate(_currentAudio!.audioPlaySpeed);

      _currentAudio!.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd =
          true;
      _currentAudio!.isPaused = false;
      
      updateAndSaveCurrentAudio(forceSave: true);

      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _audioPlayerPlugin!.pause();

    if (_currentAudio!.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd) {
      _currentAudio!.isPaused = true;
      _currentAudio!.audioPausedDateTime = DateTime.now();
    }

    updateAndSaveCurrentAudio(forceSave: true);
    notifyListeners();
  }

  /// Method called when the user clicks on the '<<' or '>>'
  /// 10 seconds or 1 minute buttons.
  ///
  /// {positiveOrNegativeDuration} is the duration to be added or
  /// subtracted to the current audio position.
  ///
  /// {isUndoRedo} is true when the method is called by the AudioPlayerVM
  /// undo or redo methods. In this case, the method does not add a
  /// command to the undo list.
  Future<void> changeAudioPlayPosition({
    required Duration positiveOrNegativeDuration,
    bool isUndoRedo = false,
  }) async {
    Duration currentAudioDuration =
        _currentAudio!.audioDuration ?? Duration.zero;
    Duration newAudioPosition =
        _currentAudioPosition + positiveOrNegativeDuration;

    // Check if the new audio position is within the audio duration.
    // If not, set the audio position to the beginning or the end
    // of the audio. This is necessary to avoid a slider error.
    //
    // This fixes the bug when clicking on >> after having clicked
    // on >| or clicking on << after having clicked on |<.

    if (newAudioPosition < Duration.zero) {
      newAudioPosition = Duration.zero;
    } else if (newAudioPosition > currentAudioDuration) {
      newAudioPosition = currentAudioDuration;
    }

    if (!isUndoRedo) {
      Command command = SetAudioPositionCommand(
        audioPlayerVM: this,
        oldDurationPosition: _currentAudioPosition,
        newDurationPosition: newAudioPosition,
      );

      _undoList.add(command);
    }

    _currentAudioPosition = newAudioPosition;

    // necessary so that the audio position is stored on the
    // audio
    _currentAudio!.audioPositionSeconds = newAudioPosition.inSeconds;

    await modifyAudioPlayerPluginPosition(_currentAudioPosition);

    // now, when clicking on position buttons, the playlist.json file
    // is updated
    updateAndSaveCurrentAudio(forceSave: true);

    notifyListeners();
  }

  /// Method called when the user clicks on the audio slider.
  ///
  /// {durationPosition} is the new audio position.
  ///
  /// {isUndoRedo} is true when the method is called by the
  /// AudioPlayerVM undo or redo methods as well as when the
  /// method is called after clicking on the audio title in
  /// theIn this case, the method does not add a
  /// command to the undo list.
  Future<void> goToAudioPlayPosition({
    required Duration durationPosition,
    bool isUndoRedo = false,
  }) async {
    if (!isUndoRedo) {
      Command command = SetAudioPositionCommand(
        audioPlayerVM: this,
        oldDurationPosition: _currentAudioPosition,
        newDurationPosition: durationPosition,
      );

      _undoList.add(command);
    }

    _currentAudioPosition = durationPosition; // Immediately update the position

    // necessary so that the audio position is stored on the
    // audio
    _currentAudio!.audioPositionSeconds = _currentAudioPosition.inSeconds;

    await modifyAudioPlayerPluginPosition(durationPosition);

    notifyListeners();
  }

  /// Method to be redefined in AudioPlayerVMTestVersion in order
  /// to avoid the use of the audio player plugin in unit tests.
  Future<void> modifyAudioPlayerPluginPosition(
      Duration durationPosition) async {
    await _audioPlayerPlugin!.seek(durationPosition);
  }

  /// Method called when the user clicks on the |< icon.
  ///
  /// {isUndoRedo} is true when the method is called by the AudioPlayerVM
  /// undo or redo methods. In this case, the method does not add a
  /// command to the undo list.
  Future<void> skipToStart({
    bool isUndoRedo = false,
  }) async {
    if (_currentAudioPosition.inSeconds == 0) {
      // situation when the user clicks on |< when the audio
      // position is at audio start. The case if the user clicked
      // twice on the |< icon. In this case, the previous audio
      // is set.
      await _setPreviousAudio();

      notifyListeners();

      return;
    }

    if (!isUndoRedo) {
      Command command = SetAudioPositionCommand(
        audioPlayerVM: this,
        oldDurationPosition: _currentAudioPosition,
        newDurationPosition: Duration.zero,
      );

      _undoList.add(command);
    }

    _currentAudioPosition = Duration.zero;

    // necessary so that the audio position is stored on the
    // audio
    _currentAudio!.audioPositionSeconds = _currentAudioPosition.inSeconds;
    _currentAudio!.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd = false;
    updateAndSaveCurrentAudio(forceSave: true);

    await modifyAudioPlayerPluginPosition(_currentAudioPosition);

    notifyListeners();
  }

  /// Method not used for the moment
  ///
  /// {isUndoRedo} is true when the method is called by the AudioPlayerVM
  /// undo or redo methods. In this case, the method does not add a
  /// command to the undo list.
  Future<void> skipToEndNoPlay({
    bool isUndoRedo = false,
  }) async {
    if (_currentAudioPosition == _currentAudioTotalDuration) {
    updateAndSaveCurrentAudio(forceSave: true);

      // situation when the user clicks on >| when the audio
      // position is at audio end. This is the case if the user
      // clicks twice on the >| icon.
      await _setNextNotPlayedAudio();

      notifyListeners();

      return;
    }

    // subtracting 1 second is necessary to avoid a slider error
    // which happens when clicking on AudioListItemWidget play icon
    //
    // I commented out next code since commenting it does not
    // causes a slider error happening when clicking on
    // AudioListItemWidget play icon. to see if realy ok !
    // _currentAudioPosition =
    //     _currentAudioTotalDuration - const Duration(seconds: 1);

    if (!isUndoRedo) {
      Command command = SetAudioPositionCommand(
        audioPlayerVM: this,
        oldDurationPosition: _currentAudioPosition,
        newDurationPosition: _currentAudioTotalDuration,
      );

      _undoList.add(command);
    }

    _currentAudioPosition = _currentAudioTotalDuration;

    // necessary so that the audio position is stored on the
    // audio
    _currentAudio!.audioPositionSeconds = _currentAudioPosition.inSeconds;
    _currentAudio!.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd = false;
    updateAndSaveCurrentAudio(forceSave: true);

    await modifyAudioPlayerPluginPosition(_currentAudioTotalDuration);

    notifyListeners();
  }

  /// Method called when the user clicks on the >| icon,
  /// either the first time or the second time.
  ///
  /// {isUndoRedo} is true when the method is called by the AudioPlayerVM
  /// undo or redo methods. In this case, the method does not add a
  /// command to the undo list.
  Future<void> skipToEndAndPlay({
    bool isUndoRedo = false,
  }) async {
    if (_currentAudioPosition == _currentAudioTotalDuration) {
      // situation when the user clicks on >| when the audio
      // position is at audio end. This is also the case when
      // the user clicks twice on the >| icon.
      await playNextAudio();

      return;
    }

    // part of method executed when the user click the first time
    // on the >| icon button

    if (!isUndoRedo) {
      Command command = SetAudioPositionCommand(
        audioPlayerVM: this,
        oldDurationPosition: _currentAudioPosition,
        newDurationPosition: _currentAudioTotalDuration,
      );

      _undoList.add(command);
    }

    _currentAudioPosition = _currentAudioTotalDuration;
    _currentAudio!.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd = false;

    updateAndSaveCurrentAudio(forceSave: true);

    await modifyAudioPlayerPluginPosition(_currentAudioTotalDuration);

    notifyListeners();
  }

  /// Method called when _audioPlayer.onPlayerComplete happens,
  /// i.e. when the current audio is terminated or when
  /// skipToEndAndPlay() is executed after the user clicked
  /// the second time on the >| icon button.
  Future<void> playNextAudio() async {
    // since the current audio is no longer playing, the isPaused
    // attribute is set to true
    _currentAudio!.isPaused = true;

    // set to false since the audio playing position is set to
    // audio end
    _currentAudio!.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd = false;

    updateAndSaveCurrentAudio(forceSave: true);

    if (await _setNextNotPlayedAudio()) {
      await playFromCurrentAudioFile();

      notifyListeners();
    }
  }

  /// When the method is called in case of the audio is at end,
  /// the {forceSave} parameter is set to true in order to save
  /// the current audio position to the end of audio position.
  void updateAndSaveCurrentAudio({
    bool forceSave = false,
  }) {
    // necessary so that the audio position is stored on the
    // audio. Must not be located after the if which can return
    // without saving the audio position. This would cause the
    // play icon's appearance to be wrong.
    if (_currentAudio == null) {
      return; // the case if "No audio selected" audio title is displayed
      // and the app becomes inactive
    }

    _currentAudio!.audioPositionSeconds = _currentAudioPosition.inSeconds;

    DateTime now = DateTime.now();

    if (!forceSave) {
      // saving the current audio position only every 30 seconds

      if (_currentAudioLastSaveDateTime
          .add(const Duration(seconds: 30))
          .isAfter(now)) {
        return;
      }
    }

    Playlist? currentAudioPlaylist = _currentAudio!.enclosingPlaylist;
    JsonDataService.saveToFile(
      model: currentAudioPlaylist,
      path: currentAudioPlaylist!.getPlaylistDownloadFilePathName(),
    );

    _currentAudioLastSaveDateTime = now;
  }

  /// The returned list is ordered by download date, placing
  /// the first downloaded audio at the begining of the list and
  /// the latest downloaded audios at end of list, so reversing
  /// the playlist playable audio list.
  ///
  /// playableAudioLst order: [available audio last downloaded, ...,
  ///                          available audio first downloaded]
  ///
  /// Example:
  ///
  /// playableAudioList
  /// 24 nov
  /// 21 nov
  /// 5 nov
  /// 28 oct
  ///
  /// playable audios ordered by download date
  /// 28 oct
  /// 5 nov
  /// 21 nov
  /// 24 nov
  List<Audio> getPlayableAudiosApplyingSortFilterParameters(
    AudioLearnAppViewType audioLearnAppViewType,
  ) {
    List<Playlist> selectedPlaylists = _playlistListVM.getSelectedPlaylists();

    if (selectedPlaylists.isEmpty) {
      // the case if no playlist is selected. Solves
      // AudioPlayerView integration test no playlist
      // selected or no playlist exist failure.
      return [];
    }

    return _playlistListVM
        .getSelectedPlaylistPlayableAudiosApplyingSortFilterParameters(
      audioLearnAppViewType: audioLearnAppViewType,
    );
  }

  List<Audio> getNotFullyPlayedAudiosApplyingSortFilterParameters(
    AudioLearnAppViewType audioLearnAppViewType,
  ) {
    return _playlistListVM
        .getSelectedPlaylistNotFullyPlayedAudiosApplyingSortFilterParameters(
      audioLearnAppViewType,
    );
  }

  List<SortingItem> getSortingItemLstForViewType(
      AudioLearnAppViewType audioLearnAppViewType) {
    return _playlistListVM.getSortingItemLstForViewType(audioLearnAppViewType);
  }

  String? getCurrentAudioTitleWithDuration() {
    if (_currentAudio == null) {
      return null;
    }

    return '${_currentAudio!.validVideoTitle}\n${_currentAudio!.audioDuration!.HHmmssZeroHH()}';
  }

  int getCurrentAudioIndex() {
    if (_currentAudio == null) {
      // the case if "No audio selected" audio title is
      // displayed in the AudioPlayerView screen
      return -1;
    }

    return _currentAudio!.enclosingPlaylist!.playableAudioLst.reversed
        .toList()
        .indexWhere((element) => element == _currentAudio);
  }

  void changeAudioPlaySpeed(double speed) async {
    if (_currentAudio == null) {
      return;
    }

    _currentAudio!.audioPlaySpeed = speed;
    await _audioPlayerPlugin!.setPlaybackRate(speed);
    updateAndSaveCurrentAudio(forceSave: true);

    notifyListeners();
  }

  // void _executeCommand(Command command) {
  //   command.execute();
  //   _undoList.add(command);
  //   // redoList.clear();
  //   notifyListeners();
  // }

  void undo() {
    if (_undoList.isNotEmpty) {
      Command command = _undoList.removeLast();
      command.undo();
      _redoList.add(command);
      notifyListeners();
    }
  }

  void redo() {
    if (_redoList.isNotEmpty) {
      Command command = _redoList.removeLast();
      command.redo();
      _undoList.add(command);
      notifyListeners();
    }
  }

  /// Method used to activate or deactivate the AudioPlayerView
  /// undo button
  bool isUndoListEmpty() {
    return _undoList.isEmpty;
  }

  /// Method used to activate or deactivate the AudioPlayerView
  /// redo button
  bool isRedoListEmpty() {
    return _redoList.isEmpty;
  }
}

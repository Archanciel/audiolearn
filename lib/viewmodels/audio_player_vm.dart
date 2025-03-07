import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

import '../constants.dart';
import '../models/audio.dart';
import '../models/playlist.dart';
import '../services/json_data_service.dart';
import '../services/settings_data_service.dart';
import '../services/sort_filter_parameters.dart';
import '../utils/duration_expansion.dart';
import 'comment_vm.dart';
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
/// As `Consumer<AudioPlayerVM>` in the AudioPlayerView screen, it
/// updates the different widgets showing the current audio playing
/// position and the current audio title.
///
/// It is also used in the AudioListItemWidget to display the
/// current audio playing status.
///
/// It is also used in the AudioOneSelectableDialog to
/// obtain the list of audio - currently ordered by download
/// date - to be displayed in the dialog.
class AudioPlayerVM extends ChangeNotifier {
  Audio? _currentAudio;
  Audio? get currentAudio => _currentAudio;
  final PlaylistListVM _playlistListVM;
  final CommentVM _commentVM;
  AudioPlayer? _audioPlayer;

  Duration _currentAudioTotalDuration = Duration.zero;
  Duration _currentAudioPosition = Duration.zero;

  Duration get currentAudioPosition => _currentAudioPosition;
  Duration get currentAudioTotalDuration => _currentAudioTotalDuration;
  Duration get currentAudioRemainingDuration =>
      _currentAudioTotalDuration - _currentAudioPosition;

  bool get isPlaying => _audioPlayer!.state == PlayerState.playing;

  DateTime _currentAudioLastSaveDateTime = DateTime.now();

  final List<Command> _undoList = [];
  final List<Command> _redoList = [];

  bool _isCommentPlaying = false;

  // Stream subscriptions
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  final SettingsDataService _settingsDataService;

  final ValueNotifier<Duration> currentAudioPositionNotifier =
      ValueNotifier(Duration.zero);

  // Tracks the last time the currentAudioPositionNotifier was
  // updated. This enable to update the currentAudioPositionNotifier
  // every 0.5 seconds.
  DateTime? _lastPositionUpdate;

  // This notifier is used to update the audio play/pause icon
  // button displayed in the audio player view
  final ValueNotifier<bool> currentAudioPlayPauseNotifier =
      ValueNotifier(false); // false means the play/pause
  //                           button will is set to play

  // This notifier is used to update the audio title with duration
  // displayed in the audio player view
  final ValueNotifier<String?> currentAudioTitleNotifier =
      ValueNotifier<String?>(null);

  // This notifier is used to update the audio speed of the audio
  // speed text button displayed in the audio player view
  final ValueNotifier<double> currentAudioPlaySpeedNotifier =
      ValueNotifier(1.0);

  // Necessary so that the value of the audio speed text button
  // is updated when the user clicks on the audio speed text button
  // in the audio player view and otherwise is set to the audio
  // speed stored in the playlist json file.
  bool wasPlaySpeedNotifierChanged = false;

  // This notifier is used to update the audio volume icon buttons
  // displayed in the audio player view
  final ValueNotifier<double> currentAudioPlayVolumeNotifier =
      ValueNotifier(0.5);

  // This private variable is set to true when await _audioPlayer!.stop()
  // is called in the pause() method. This is necessary to avoid that
  // the audio starts when an alarm or a phone call happens on the
  // smartphone. The value is re-set to false when the user clicks on the
  // play icon in the audio player view or on the slider or on the start/end
  // or the other position buttons.
  bool _wasAudioPlayersStopped = false;

  AudioPlayerVM({
    required SettingsDataService settingsDataService,
    required PlaylistListVM playlistListVM,
    required CommentVM commentVM,
  })  : _settingsDataService = settingsDataService,
        _playlistListVM = playlistListVM,
        _commentVM = commentVM {
    initializeAudioPlayer();
  }

  @override
  Future<void> dispose() async {
    if (_audioPlayer != null) {
      try {
        // necessary to avoid the error which causes integration test to fail
        await _audioPlayer!.dispose();
      } catch (e) {
        // ignore: avoid_print
        print('***** AudioPlayerVM.dispose() error: $e');
      }
    }
    // await _audioPlayer!.dispose(); // on main project

    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();

    super.dispose();
  }

  /// {volumeChangedValue} must be between -1.0 and 1.0. The
  /// initial audio volume is 0.5 and will be decreased or
  /// increased by this value.
  Future<void> changeAudioVolume({
    required double volumeChangedValue,
  }) async {
    // It is important to limit the volume to 0.1 and not to 0.0
    // since at 0.0, the audio is no more listenable.
    double newAudioPlayVolume =
        (_currentAudio!.audioPlayVolume + volumeChangedValue).clamp(0.1, 1.0);

    _currentAudio!.audioPlayVolume =
        newAudioPlayVolume; // Increase and clamp to max 1.0
    await _audioPlayer!.setVolume(newAudioPlayVolume);

    // Enables the modified audio volume icob button appearance
    // to be updated in the audio player view.
    currentAudioPlayVolumeNotifier.value = newAudioPlayVolume;

    updateAndSaveCurrentAudio();
  }

  /// Method called when the user clicks on the audio title or sub
  /// title or play icon displayed in the playlist download view or
  /// when he selects an audio in the AudioPlayableListDialog
  /// displayed by clicking on the audio title on the audio player
  /// view or by long pressing on the >| button.
  ///
  /// Method called also by setNextAudio() or setPreviousAudio().
  ///
  /// {doClearUndoRedoLists} is set to false when the user clicks on
  /// the close button of the comment list add dialog. In this case,
  /// maintening the undo/redo lists is useful to enable the user to
  /// undo the audio position change.
  ///
  /// If the audio was redownloaded, setting the current audio even
  /// if _currentAudio == audio prevents that the audio slider and the
  /// audio position fields in the audio player view are not updated
  /// when playing an audio the first time after having redownloaded
  /// it or having redownloaded several filtered audio's.
  Future<void> setCurrentAudio({
    required Audio audio,
    bool audioWasRedownloaded = false,
  }) async {
    bool doClearUndoRedoLists;

    if (_currentAudio != audio) {
      // The case if the user clicked on an audio title or sub title
      // different from the current audio.
      doClearUndoRedoLists = true;
    } else {
      // The case if the user clicked on the current audio title or
      // sub title of the current audio.
      doClearUndoRedoLists = false;
    }

    await _setCurrentAudio(
      audio: audio,
      doClearUndoRedoLists: doClearUndoRedoLists,
      audioWasRedownloaded: audioWasRedownloaded,
    );

    audio.enclosingPlaylist!.setCurrentOrPastPlayableAudio(
      audio: audio,
    );

    // This fixes a surprising bug: when the user clicks on an audio
    // whose play speed is 0.0, the audio speed is set to the default
    // playlist play speed, otherwise, the audio can not be played and
    // the app is considered as bugged.
    if (audio.audioPlaySpeed == 0.0) {
      audio.audioPlaySpeed = _settingsDataService.get(
        settingType: SettingType.playlists,
        settingSubType: Playlists.playSpeed,
      );
    }

    updateAndSaveCurrentAudio();

    currentAudioTitleNotifier.value = getCurrentAudioTitleWithDuration();
    currentAudioPositionNotifier.value = _currentAudioPosition;
  }

  /// Method called when the user in the PlaylistDownloadView clicks
  /// on the audio title or sub title or when he clicks on a play icon
  /// or, in the AudioPlayerView, when he selects an audio in the
  /// AudioOneSelectableDialog displayed by clicking on the audio
  /// title on the AudioPlayerView or by long pressing on the >| button.
  void _clearUndoRedoLists() {
    _undoList.clear();
    _redoList.clear();
  }

  /// Method called indirectly when the user clicks on the audio title
  /// or sub title or when he clicks on a play icon or when he selects
  /// an audio in the AudioOneSelectableDialog displayed by
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
  ///
  /// Read below the usefullness of the [audioWasRedownloaded] parameter.
  Future<void> _setCurrentAudio({
    required Audio audio,
    bool doClearUndoRedoLists = true,
    bool audioWasRedownloaded = false,
  }) async {
    // necessary to avoid position error when the chosen audio is displayed
    // in the AudioPlayerView screen.
    // if (_audioPlayer != null) {
    //   // this test is necessary in order to avoid unit test failure since
    //   // the AudioPlayerVMTestVersion does not instanciate the _audioPlayer
    //   await _audioPlayer!.pause();
    // }

    // If the audio was redownloaded, setting the current audio even
    // if _currentAudio == audio prevents that the audio slider and the
    // audio position fields in the audio player view are not updated
    // when playing an audio the first time after having redownloaded
    // it or having redownloaded several filtered audio's.
    if (!audioWasRedownloaded && _currentAudio == audio) {
      return;
    }

    if (_currentAudio != null && !_currentAudio!.isPaused) {
      _currentAudio!.isPaused = true;
      // saving the previous current audio state before changing
      // the current audio
      updateAndSaveCurrentAudio();
    }

    _currentAudio = audio;

    // without setting _currentAudioTotalDuration to the audio duration,
    // the next instruction causes an error: Failed assertion: line 194
    // pos 15: 'value >= min && value <= max': Value 3.0 is not between
    // minimum 0.0 and maximum 0.0
    _currentAudioTotalDuration = audio.audioDuration;

    // setting the audio position to the audio position stored on the
    // audio. The advantage is that when the AudioPlayerView is opened
    // the audio position is set to the last position played.
    //
    // Then, when the user clicks on the play icon, the audio position
    // is reduced according to the time elapsed since the audio was
    // paused, which is done in _setCurrentAudioPosition().
    _currentAudioPosition = Duration(seconds: audio.audioPositionSeconds);

    if (doClearUndoRedoLists) {
      _clearUndoRedoLists();
    }

    await initializeAudioPlayer(); // on audio_player_vm_audioplayers_
    //                                5_2_1_ALL_TESTS_PASS.dart version

    // start Main version
    // final String audioFilePathName = _currentAudio?.filePathName ?? '';

    // if (audioFilePathName.isNotEmpty && File(audioFilePathName).existsSync()) {
    //   await audioPlayerSetSource(audioFilePathName);

    //   // Setting the value to false avoid that the audioplayers source
    //   // is set again when the user clicks on another position button or
    //   // on the audio slider.
    //   _wasAudioPlayersStopped = false;
    // }

    // await _audioPlayer!.setVolume(
    //   audio.audioPlayVolume,
    // );
    // end Main version

    // audioplayers_5_2_1_ALL_TESTS_PASS version
    if (_audioPlayer != null && File(audio.filePathName).existsSync()) {
      // necessary to avoid unit test failure
      await _audioPlayer!.setVolume(
        audio.audioPlayVolume,
      );

      await modifyAudioPlayerPosition(
        durationPosition: _currentAudioPosition,
      );
    }
  }

  // /// Method defined as public since it is redefined in the mock subclass
  // /// AudioPlayerVMTestVersion which does not access to audioplayers plugin.
  // Future<void> audioPlayerSetSource(String audioFilePathName) async {
  //   await _audioPlayer!.setSource(DeviceFileSource(audioFilePathName));
  // } // on main project

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

      // Reason why pausedDurationSecs <= 1:
      //
      // when the user clicks on << or >> button, the audio paused
      // DateTime is set to now. This avoids that when the user clicks
      // on the play icon, the audio is rewinded maybe half a minute if
      // the audio was paused 1 hour ago...
      if (pausedDurationSecs > 1) {
        if (pausedDurationSecs < 60) {
          rewindSeconds = 2;
        } else if (pausedDurationSecs < 3600) {
          rewindSeconds = 20;
        } else {
          rewindSeconds = 30;
        }
      }

      int newPositionSeconds =
          _currentAudio!.audioPositionSeconds - rewindSeconds;

      // Ensure the new position is not negative
      _currentAudioPosition = Duration(
          seconds: newPositionSeconds.clamp(
              0, _currentAudio!.audioDuration.inSeconds));
    }

    /// Must be called even if rewiding was not necessary. For example,
    /// if the user change the position of a not yet played audio and then
    /// plays an audio previously downloaded, once this audio ends, if
    /// this instruction was located inside the previous if block, the
    /// not yet played audio starts playing not at the changed position,
    /// but at the start position !
    ///
    /// This integration test checks this bug fix:
    ///
    /// testWidgets('User modifies the position of next fully unread audio which is also the last downloaded audio of the playlist.').

    await _audioPlayer!.seek(_currentAudioPosition);

    // Necessary so that the audio play view current audio position
    // and remaining duration are updated
    currentAudioPositionNotifier.value = _currentAudioPosition;
  }

  /// Returns true if a next not fully played audio was found, false
  /// otherwise.
  Future<bool> _setNextNotFullyPlayedAudioAsCurrentAudio() async {
    Audio? nextAudio;

    nextAudio =
        _playlistListVM.getNextDownloadedOrSortFilteredNotFullyPlayedAudio(
      audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
      currentAudio: _currentAudio!,
    );

    if (nextAudio == null) {
      // the case if the current audio is the last playable audio of the
      // sort/filter or not playlist playableAudioLst.

      // necessary so that the play/pause icon is updated to play.
      // Otherwise, the icon remains at pause value.
      currentAudioPlayPauseNotifier.value = false;

      return false;
    }

    await setCurrentAudio(
      audio: nextAudio,
    );

    return true;
  }

  /// Method called by skipToStart() if the audio is positioned at
  /// start.
  Future<void> _setPreviousAudio() async {
    if (_currentAudio == null) {
      // the case when rewinding the audio position to start of an
      // unselected playlist
      return;
    }

    Audio? previousAudio =
        _playlistListVM.getPreviouslyDownloadedOrSortFilteredAudio(
      audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
      currentAudio: _currentAudio!,
    );

    if (previousAudio == null) {
      return;
    }

    await setCurrentAudio(
      audio: previousAudio,
    );
  }

  /// Method to be redefined in AudioPlayerVMTestVersion in order
  /// to avoid the use of the audio player plugin in unit tests.
  ///
  /// For this reason, the method is not private !
  Future<void> initializeAudioPlayer() async {
    if (_audioPlayer != null) {
      try {
        // necessary to avoid the error which causes integration test to fail
        await _audioPlayer!.dispose();
      } catch (e) {
        // ignore: avoid_print
        print('***** AudioPlayerVM.initializeAudioPlayerPlugin() error: $e');
      }
    }

    _audioPlayer = AudioPlayer();

    // Available only on version 6 !
    // _audioPlayerPlugin!.positionUpdater = TimerPositionUpdater(
    //   interval: const Duration(milliseconds: 100),
    //   getPosition: _audioPlayerPlugin!.getCurrentPosition,
    // );
    // _initAudioPlayer(); // on main project

    // Assuming filePath is the full path to your audio file
    String audioFilePathName = _currentAudio?.filePathName ?? '';

    // Check if the file exists before attempting to play it
    if (audioFilePathName.isNotEmpty && File(audioFilePathName).existsSync()) {
      await _audioPlayer!
          .setVolume(_currentAudio?.audioPlayVolume ?? kAudioDefaultPlayVolume);

      // setting audio player plugin listeners

      _initAudioPlayer(); // Load the file but don't play yet
      // await _audioPlayer!.setVolume(
      //   _currentAudio?.audioPlayVolume ?? kAudioDefaultPlayVolume,
      // ); // on main project
    }
  }

  /// This method sets the audio player listeners. Those listeners will be
  /// cancelled in the AudioPlayerVM dispose() method.
  void _initAudioPlayer() {
    _positionSubscription = _audioPlayer!.onPositionChanged.listen((position) {
      if (_audioPlayer!.state == PlayerState.playing) {
        // this test avoids that when selecting another audio
        // the selected audio position is set to 0 since the
        // passed position value of an AudioPlayer not playing
        // is 0 !
        _currentAudioPosition = position;

        // Only update the currentAudioPositionNotifier every 0.5 second
        if (_lastPositionUpdate == null ||
            DateTime.now().difference(_lastPositionUpdate!) >=
                const Duration(milliseconds: 500)) {
          _lastPositionUpdate = DateTime.now();
          currentAudioPositionNotifier.value = position;
        }

        if (_currentAudio == null) {
          // This happens when the user deletes the current and unique
          // audio of the playlist.
          return;
        }

        // This instruction must be executed before the next if block,
        // otherwise, if the user opens the audio info dialog while the
        // audio is playing, the audio position displayed in the audio
        // info dialog opened on the current audio which does display
        // the audio position obtained from the audio player view model
        // will display the correct audio position only every 30 seconds.
        // This is demonstrated by the audio info audio state integration
        // tests.
        //
        // The audioPositionSeconds of the current audio will be saved
        // in its enclosing playlist json file every 30 seconds or when
        // the audio is paused or when the audio is at end.
        _currentAudio!.audioPositionSeconds = _currentAudioPosition.inSeconds;

        if (_currentAudioLastSaveDateTime
            .add(const Duration(seconds: 30))
            .isAfter(DateTime.now())) {
          return;
        }

        // saving the current audio position only every 30 seconds
        updateAndSaveCurrentAudio();
      }
    });

    _playerCompleteSubscription =
        _audioPlayer!.onPlayerComplete.listen((event) async {
      if (_isCommentPlaying) {
        // In this situation, if a comment is playing and arrives to the
        // audio end, the next audio is not played.

        // necessary so that the play/pause icon is updated to play.
        // Otherwise, the icon remains at pause value.
        currentAudioPlayPauseNotifier.value = false;

        return;
      }

      // Ensures that the audio player view audio position slider is
      // updated to end when the audio play was complete. Otherwise,
      // if the audio plays while the smartphone screen is turned off,
      // the slider won't be set to end position.
      _currentAudioPosition = _currentAudioTotalDuration;

      // Usefull for PlaylistDownloadView only. Without this instruction,
      // the play/pause button of the audio item in the playlist download
      // view is not updated when clicking on pause button in the audio
      // player view. Since audio list item no longer uses audio player VM
      // listen true, the notifyListeners() instruction is no longer
      // necessary.
      // notifyListeners();

      // Set the current audio to its end position
      _setCurrentAudioToEndPosition();
      updateAndSaveCurrentAudio();

      // If a comment was playing, reset the state and stop processing
      if (_isCommentPlaying) {
        _isCommentPlaying = false;
        currentAudioPlayPauseNotifier.value = false; // Update UI state
        return;
      }

      // Play the next audio if applicable
      if (await _setNextNotFullyPlayedAudioAsCurrentAudio()) {
        await playCurrentAudio(rewindAudioPositionBasedOnPauseDuration: true);
      } else {
        // Necessary so that the slider and the position fields are
        // updated when the unique audio of the playlist plays till
        // end. Without this instruction, the audio slider and the
        // audio position fields remain with a value before the audio
        // end state.
        currentAudioPositionNotifier.value = _currentAudioTotalDuration;
      }
    });

    // Code below does not improve anything in the integration
    // test problems related to aidioplayers 6.1.0.
    // _playerStateChangeSubscription =
    //     _audioPlayer!.onPlayerStateChanged.listen((state) {
    //
    // });
  }

  /// Method passed to the audio player onPositionChanged listener on
  /// AudioPlayerVM version used in project audioplayers_5_2_1_ALL_TESTS_PASS.
  void handlePositionChanged({
    required Duration position,
  }) {
    if (_audioPlayer!.state == PlayerState.playing) {
      // this test avoids that when selecting another audio
      // the selected audio position is set to 0 since th
      // passed position value of an AudioPlayer not playing
      // is 0 !
      _currentAudioPosition = position;

      // This instruction must be executed before the next if block,
      // otherwise, if the user opens the audio info dialog while the
      // audio is playing, the audio position displayed in the audio
      // info dialog opened on the current audio which does display
      // the audio position obtained from the audio player view model
      // will display the correct audio position only every 30 seconds.
      // This is demonstrated by the audio indo audio state integration
      // tests.
      //
      // The audioPositionSeconds of the current audio will be saved
      // in its enclosing playlist json file every 30 seconds or when
      // the audio is paused or when the audio is at end.
      _currentAudio!.audioPositionSeconds = _currentAudioPosition.inSeconds;

      if (_currentAudioLastSaveDateTime
          .add(const Duration(seconds: 30))
          .isAfter(DateTime.now())) {
        return;
      }

      // saving the current audio position only every 30 seconds
      updateAndSaveCurrentAudio();
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
      await _handleNoPlayableAudioAvailable();

      return;
    }

    Audio? currentOrPastPlaylistAudio = selectedPlaylistLst.first
        .getCurrentOrLastlyPlayedAudioContainedInPlayableAudioLst();

    if (currentOrPastPlaylistAudio == null) {
      // causes "No audio selected" audio title to be displayed
      // in the AudioPlayerView screen. Reinitializing the
      // _currentAudioPosition and the _currentAudioTotalDuration
      // ensure that the audio slider is correctly displayed at
      // position 0:00 and that the displayed audio duration is 0:00.
      _currentAudio = null;
      _currentAudioPosition = Duration.zero;
      _currentAudioTotalDuration = Duration.zero;

      _clearUndoRedoLists();
      initializeAudioPlayer();

      return;
    }

    if (_currentAudio == currentOrPastPlaylistAudio) {
      return;
    }

    await _setCurrentAudio(
      audio: currentOrPastPlaylistAudio,
    );

    currentAudioTitleNotifier.value = getCurrentAudioTitleWithDuration();
  }

  /// Used as well when the user moves or deletes in the audio
  /// player view the unique audio available in the current playlist.
  Future<void> handleNoPlayableAudioAvailable() async {
    await _handleNoPlayableAudioAvailable();

    return;
  }

  /// Ensures that when the user deselect the playlist, switching
  /// to the AudioPlayerView screen causes the "No audio selected"
  /// audio title to be displayed in the AudioPlayerView screen since
  /// _currentAudio == null.
  Future<void> _handleNoPlayableAudioAvailable() async {
    await _clearCurrentAudio();

    _clearUndoRedoLists();
  }

  Future<void> _clearCurrentAudio() async {
    _currentAudio = null;
    _currentAudioTotalDuration = Duration.zero;
    _currentAudioPosition = const Duration(seconds: 0);

    currentAudioTitleNotifier.value = null;
  }

  /// Method called when the user clicks on the audio play icon
  /// of the AudioListItemWidget displayed in the PlaylistDownloadView
  /// or on the audio play icon in the AudioPlayerView or on the play
  /// icon in the CommentListAddDialog or PlaylistCommentDialog
  /// or on the play icon in the CommentAddEditDialog or on the play
  /// icon in the second audio player line which exist if a picture is
  /// displayed instead the regular play/pause icon.
  Future<void> playCurrentAudio({
    bool rewindAudioPositionBasedOnPauseDuration = true,
    bool isCommentPlaying = false,
    bool isFromAudioPlayerView = false,
  }) async {
    _isCommentPlaying = isCommentPlaying;

    List<Playlist> selectedPlaylistsLst =
        _playlistListVM.getSelectedPlaylists();

    if (_currentAudio == null && selectedPlaylistsLst.isNotEmpty) {
      // the case if the AudioPlayerView is opened directly by
      // dragging to it or clicking on the title or sub title
      // of an audio and not after the user has clicked on the
      // Playlist Download View audio play icon button.
      //
      // Getting the first selected playlist makes sense since
      // currently only one playlist can be selected at a time
      // in the PlaylistDownloadView.
      _currentAudio = selectedPlaylistsLst.first
          .getCurrentOrLastlyPlayedAudioContainedInPlayableAudioLst();
    }

    if (_currentAudio == null) {
      // the case if no audio in the selected playlist was ever played
      return;
    }

    String audioFilePathName = _currentAudio!.filePathName;

    // Check if the file exists before attempting to play it
    if (File(audioFilePathName).existsSync()) {
      if ((isFromAudioPlayerView || isCommentPlaying) &&
          _wasAudioPlayersStopped) {
        // Set the source again since clicking on the pause icon
        // stopped the audio player.
        await _audioPlayer!
            .setSource(DeviceFileSource(_currentAudio!.filePathName));

        // Setting the value to false avoid that the audioplayers source
        // is set again when the user clicks on another position button or
        // on the audio slider.
        _wasAudioPlayersStopped = false;
      }

      if (rewindAudioPositionBasedOnPauseDuration) {
        await _rewindAudioPositionBasedOnPauseDuration();
      }

      await _audioPlayer!.play(DeviceFileSource(audioFilePathName));
      await _audioPlayer!.setPlaybackRate(_currentAudio!.audioPlaySpeed);

      _currentAudio!.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd =
          true;
      _currentAudio!.isPaused = false;

      updateAndSaveCurrentAudio();

      // Necessary so that the play/pause icon is updated after
      // clicking on it
      currentAudioPlayPauseNotifier.value = true; // true means the play/pause
      //                                             button will be set to pause
    }
  }

  Future<void> pause() async {
    if (_wasAudioPlayersStopped) {
      // Avoid executing _audioPlayer!.stop() several times, which
      // causes an error due to an audioplayers is disposed exception
      // in the integration tests.
      return;
    }

    // Calling _audioPlayer!.stop() instead of _audioPlayer!.pause()
    // avoids that the paused audio starts when an alarm or a call
    // happens on the smartphone. This requires to call _audioPlayer!.
    // setSource() in the playCurrentAudio() method ...
    _wasAudioPlayersStopped = true;

    try {
      // avoid ridiculous error in integration tests
      await _audioPlayer!.stop();
    } catch (e) {
      // ignore: avoid_print
      print('***** AudioPlayerVM.pause() error: $e');
      return;
    }

    if (_currentAudio !=
            null && // necessary to avoid the error when deleting a playing audio
        _currentAudio!.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd) {
      _currentAudio!.isPaused = true;
      _currentAudio!.audioPositionSeconds = _currentAudioPosition.inSeconds;
      _currentAudio!.audioPausedDateTime = DateTime.now();
    }

    updateAndSaveCurrentAudio();
    _commentVM.undoAllRecordedCommentPlayCommands(
      playlistListVM: _playlistListVM,
    );

    // Necessary so that the play/pause icon is updated after
    // clicking on it
    currentAudioPlayPauseNotifier.value = false; // false means the play/pause
    //                                              button will be set to play

    // Required so that the audio item in the playlist download view
    // play/pause button is correctly updated when clicking on it in
    // order to pause the playing audio. Otherwise, the audio is paused,
    // but the button is not converted to play button.

    // Usefull for PlaylistDownloadView only. Without this instruction,
    // the play/pause button of the audio item in the playlist download
    // view is not updated when clicking on pause button in the audio
    // player view. Since audio list item no longer uses audio player VM
    // listen true, the notifyListeners() instruction is no longer
    // necessary.
    // notifyListeners();
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
    required Duration posOrNegPositionDurationChange,
    bool isUndoRedo = false,
  }) async {
    if (_wasAudioPlayersStopped) {
      // Set the source again since clicking on the pause icon
      // stopped the audio player.
      await _audioPlayer!
          .setSource(DeviceFileSource(_currentAudio!.filePathName));

      // Setting the value to false avoid that the audioplayers source
      // is set again when the user clicks on another position button or
      // on the audio slider.
      _wasAudioPlayersStopped = false;
    }

    Duration newAudioPosition =
        _currentAudioPosition + posOrNegPositionDurationChange;

    // Check if the new audio position is within the audio duration.
    // If not, set the audio position to the beginning or the end
    // of the audio. This is necessary to avoid a slider error.
    //
    // This fixes the bug when clicking on >> after having clicked
    // on >| or clicking on << after having clicked on |<.

    // Total duration of audio
    Duration currentAudioDuration = _currentAudio!.audioDuration;

    if (newAudioPosition < Duration.zero) {
      newAudioPosition = Duration.zero;
    } else if (newAudioPosition > currentAudioDuration) {
      newAudioPosition = currentAudioDuration;
    }

    _modifyCurrentAudioPlayingOrPausedWithPositionBetweenAudioStartAndEnd(
      newAudioPosition: newAudioPosition,
    );

    if (!isUndoRedo) {
      addUndoCommand(
        newDurationPosition: newAudioPosition,
      );
    }

    if (!File(_currentAudio!.filePathName).existsSync()) {
      // If File(audioFilePathName).existsSync() is false, this means
      // that the audio file was deleted. This can happen when the user
      // deletes the audio file in the file explorer or when the user
      // executes the 'Restore Playlists, Comments and Settings' menu.
      // In this situation, the displayed playlist audio's are not
      // playable (no mp3 file available).

      return;
    }

    _currentAudioPosition = newAudioPosition;

    // necessary so that the audio position is stored on the
    // audio
    _currentAudio!.audioPositionSeconds = newAudioPosition.inSeconds;

    // setting the audio paused date time to now avoid that if you play the
    // audio after having changed its position by clicking on << or >>
    // button, the audio is rewinded maybe half a minute ...
    _currentAudio!.audioPausedDateTime = DateTime.now();

    await modifyAudioPlayerPosition(
      durationPosition: _currentAudioPosition,
    );

    // now, when clicking on position buttons, the playlist.json file
    // is updated
    updateAndSaveCurrentAudio();
  }

  /// Method called when the user clicks on the audio slider or on the
  /// audio position buttons (<<, >>, |<, >|). The utility of this method
  /// is to set the current audio
  /// isPlayingOrPausedWithPositionBetweenAudioStartAndEnd value. This
  /// instance variable is used to modify the inkwell audio play icon color
  /// in the AudioListItemWidget used in the PlaylistDownloadView.
  void _modifyCurrentAudioPlayingOrPausedWithPositionBetweenAudioStartAndEnd({
    required Duration newAudioPosition,
  }) {
    if (newAudioPosition > Duration.zero &&
        newAudioPosition <
            (_currentAudio!.audioDuration -
                Duration(seconds: Audio.fullyListenedBufferSeconds))) {
      _currentAudio!.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd =
          true;
    } else {
      _currentAudio!.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd =
          false;
    }
  }

  /// Method called when the user clicks on the audio slider.
  ///
  /// {durationPosition} is the new audio position.
  Future<void> slideToAudioPlayPosition({
    required Duration durationPosition,
    bool isUndoRedo = false,
  }) async {
    if (_wasAudioPlayersStopped) {
      // Set the source again since clicking on the pause icon
      // stopped the audio player.
      await _audioPlayer!
          .setSource(DeviceFileSource(_currentAudio!.filePathName));

      // Setting the value to false avoid that the audioplayers source
      // is set again when the user clicks on another position button or
      // on the audio slider.
      _wasAudioPlayersStopped = false;
    }

    // setting the audio paused date time to now avoid that if you play the
    // audio after having changed the position clicking on the slider, the
    // audio is rewinded maybe half a minute ...
    _currentAudio!.audioPausedDateTime = DateTime.now();

    await goToAudioPlayPosition(
      durationPosition: durationPosition,
    );
  }

  /// Method called after clicking on the audio title or when
  /// the user clicks on the audio slider. Also called when
  /// clicking on the undo or redo buttons.
  ///
  /// {durationPosition} is the new audio position.
  ///
  /// {isUndoRedo} is true when the method is called by the
  /// AudioPlayerVM undo or redo methods as well as when the
  /// method is called after clicking on the audio title. In
  /// this case, the method does not add a command to the
  /// undo list.
  Future<void> goToAudioPlayPosition({
    required Duration durationPosition,
    bool isUndoRedo = false,
  }) async {
    _modifyCurrentAudioPlayingOrPausedWithPositionBetweenAudioStartAndEnd(
      newAudioPosition: durationPosition,
    );

    if (!isUndoRedo) {
      addUndoCommand(
        newDurationPosition: durationPosition,
      );
    }

    _currentAudioPosition = durationPosition; // Immediately update the position

    // necessary so that the audio position is stored on the
    // audio
    _currentAudio!.audioPositionSeconds = _currentAudioPosition.inSeconds;

    // This method must be executed even if the audio player plugin
    // position is set in the _rewindAudioPositionBasedOnPauseDuration()
    // method called by the playCurrentAudio() method. This is necessary
    // so that if we click on the slider or on an audio position button
    // while the audio is playing, the audio play position is changed.
    await modifyAudioPlayerPosition(
      durationPosition: durationPosition,
    );
  }

  /// This method is called also by CommentAddEditDialog, CommentListAddDialog and
  /// PlaylistCommentListDialog. In those cases, [addUndoCommand] is set to true
  /// so that the audio position modified by playing a comment can be undone by
  /// clicking on the audio player view undo button.
  ///
  /// The method is redefined in AudioPlayerVMTestVersion in order to avoid using
  /// the audio player plugin in unit tests.
  Future<void> modifyAudioPlayerPosition({
    required Duration durationPosition,
    bool isUndoCommandToAdd = false,
  }) async {
    if (isUndoCommandToAdd) {
      addUndoCommand(
        newDurationPosition: durationPosition,
      );
    }

    if (_wasAudioPlayersStopped) {
      // Set the source again since clicking on the pause icon
      // stopped the audio player.
      await _audioPlayer!
          .setSource(DeviceFileSource(_currentAudio!.filePathName));

      // Setting the value to false avoid that the audioplayers source
      // is set again after it was re-set.
      _wasAudioPlayersStopped = false;
    }

    _currentAudioPosition = durationPosition;

    try {
      await _audioPlayer!.seek(durationPosition);
    } catch (e) {
      // ignore: avoid_print
      print('***** AudioPlayerVM.modifyAudioPlayerPosition() error: $e');
    }

    // Necessary so that the audio position is updated in the
    // position text fields and the slider in the AudioPlayerView
    // screen.
    currentAudioPositionNotifier.value = durationPosition;
  }

  /// This method is not private since it is called in the mock subclass
  /// AudioPlayerVMTestVersion.
  void addUndoCommand({
    required Duration newDurationPosition,
  }) {
    Command command = SetAudioPositionCommand(
      audioPlayerVM: this,
      oldDurationPosition: _currentAudioPosition,
      newDurationPosition: newDurationPosition,
    );

    _undoList.add(command);
  }

  /// Method called when the user clicks on the |< icon.
  ///
  /// {isUndoRedo} is true when the method is called by the AudioPlayerVM
  /// undo or redo methods. In this case, the method does not add a
  /// command to the undo list.
  Future<void> skipToStart({
    bool isUndoRedo = false,
    bool isFromAudioPlayerView = false,
    bool isAfterRewindingAudioPosition = false,
  }) async {
    if (isFromAudioPlayerView && _wasAudioPlayersStopped) {
      // Set the source again since clicking on the pause icon
      // stopped the audio player.
      await _audioPlayer!
          .setSource(DeviceFileSource(_currentAudio!.filePathName));

      // Setting the value to false avoid that the audioplayers source
      // is set again when the user clicks on another position button or
      // on the audio slider.
      _wasAudioPlayersStopped = false;
    }

    if (!isAfterRewindingAudioPosition && // in rewinding situation, setting
        // the current audio to the previous audio is an error
        _currentAudioPosition.inSeconds == 0) {
      // situation when the user clicks on |< when the audio
      // position is at audio start. The case if the user clicked
      // twice on the |< icon. In this case, the previous audio
      // is set.
      await _setPreviousAudio();

      currentAudioPositionNotifier.value = _currentAudioPosition;

      return;
    }

    if (!isUndoRedo) {
      addUndoCommand(
        newDurationPosition: Duration.zero,
      );
    }

    _currentAudioPosition = Duration.zero;

    // necessary so that the audio position is stored on the
    // audio
    _currentAudio!.audioPositionSeconds = _currentAudioPosition.inSeconds;

    _currentAudio!.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd = false;

    updateAndSaveCurrentAudio();

    await modifyAudioPlayerPosition(
      durationPosition: _currentAudioPosition,
    );
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
    if (_currentAudio == null) {
      return;
    }

    if (_wasAudioPlayersStopped) {
      // Set the source again since clicking on the pause icon
      // stopped the audio player.
      await _audioPlayer!
          .setSource(DeviceFileSource(_currentAudio!.filePathName));

      // Setting the value to false avoid that the audioplayers source
      // is set again when the user clicks on another position button or
      // on the audio slider.
      _wasAudioPlayersStopped = false;
    }

    if (_currentAudioPosition == _currentAudioTotalDuration) {
      // Situation when the user clicks on >| when the audio
      // position is at audio end. This is also the case when
      // the user clicks twice on the >| icon.
      //
      // Before playing the next audio, the current audio is
      // saved in its enclosed playlist json file ...
      await _playNextAudio();

      return;
    }

    // Part of method executed when the user click the first time
    // on the >| icon button

    if (!isUndoRedo) {
      addUndoCommand(
        newDurationPosition: _currentAudioTotalDuration,
      );
    }

    _currentAudioPosition = _currentAudioTotalDuration;

    _setCurrentAudioToEndPosition();
    updateAndSaveCurrentAudio();

    await modifyAudioPlayerPosition(
      durationPosition: _currentAudioTotalDuration,
    );
  }

  /// Method called when _audioPlayer!.onPlayerComplete happens,
  /// i.e. when the current audio is terminated or when
  /// skipToEndAndPlay() is executed after the user clicked
  /// the second time on the >| icon button.
  Future<void> _playNextAudio() async {
    _setCurrentAudioToEndPosition();
    updateAndSaveCurrentAudio();

    if (await _setNextNotFullyPlayedAudioAsCurrentAudio()) {
      await playCurrentAudio(
        // it makes sense that if the next played is partially played,
        // it is rewinded according to the time elapsed since it was
        // paused.
        rewindAudioPositionBasedOnPauseDuration: true,
      );
    }
  }

  void _setCurrentAudioToEndPosition() {
    // since the current audio is no longer playing, the isPaused
    // attribute is set to true
    _currentAudio!.isPaused = true;

    _currentAudio!.audioPausedDateTime = DateTime.now();

    // This should fix the problem when the application plays an audio
    // till its end and due to a problem of the audioplayer plugin, the
    // next audio is not playxed. When reopening the smartphone after
    // a long time, the audio is not positioned at the end of the audio.
    _currentAudio!.audioPositionSeconds =
        _currentAudio!.audioDuration.inSeconds;

    // set to false since the audio playing position is set to
    // audio end
    _currentAudio!.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd = false;
  }

  /// Method called in AudioPlayerView.didChangeAppLifecycleState(
  /// AppLifecycleState state) method when the app is paused (screen turns off
  /// oe user select another app) or becomes inactive (is closed).
  ///
  /// Method called as well in several AudioPlayerVM methods.
  void updateAndSaveCurrentAudio() {
    if (_currentAudio == null) {
      return; // the case if "No audio selected" audio title is displayed
      //         and the app becomes inactive
    }

    _currentAudioLastSaveDateTime = DateTime.now();

    Playlist? currentAudioPlaylist = _currentAudio!.enclosingPlaylist;

    JsonDataService.saveToFile(
      model: currentAudioPlaylist,
      path: currentAudioPlaylist!.getPlaylistDownloadFilePathName(),
    );
  }

  /// The returned list is ordered by download date if no sort/filter parms
  /// is applicable, placing the first downloaded audio at the begining of the
  /// list and the latest downloaded audio at end of list, so reversing
  /// the playlist playable audio list.
  ///
  /// If sort/filter parms are applicable, the list is ordered by the
  /// sort/filter parms.
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
  /// playable audio ordered by download date
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
        .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
      audioLearnAppViewType: audioLearnAppViewType,
    );
  }

  /// Method used by AudioPlayableListDialog if the 'Exclude fully played audio
  /// checkbox is checked in order to get the not fully played audios of the
  /// selected playlist.
  List<Audio> getNotFullyPlayedAudiosApplyingSortFilterParameters({
    required AudioLearnAppViewType audioLearnAppViewType,
  }) {
    return _playlistListVM
        .getSelectedPlaylistNotFullyPlayedAudioApplyingSortFilterParameters(
      audioLearnAppViewType: audioLearnAppViewType,
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

    return '${_currentAudio!.validVideoTitle}\n${_currentAudio!.audioDuration.HHmmssZeroHH()}';
  }

  Future<void> changeAudioPlaySpeed(double speed) async {
    if (_currentAudio == null) {
      return;
    }

    _currentAudio!.audioPlaySpeed = speed;
    await _audioPlayer!.setPlaybackRate(speed);
    updateAndSaveCurrentAudio();
  }

  void undo() {
    if (_undoList.isNotEmpty) {
      Command command = _undoList.removeLast();
      command.undo();
      _redoList.add(command);
    }
  }

  void redo() {
    if (_redoList.isNotEmpty) {
      Command command = _redoList.removeLast();
      command.redo();
      _undoList.add(command);
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

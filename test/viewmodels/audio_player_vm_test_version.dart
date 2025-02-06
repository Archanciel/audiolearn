import 'package:audiolearn/viewmodels/audio_player_vm.dart';

/// This is a test version of the AudioPlayerVM. It is used in the
/// test environment to avoid the use of the audio player plugin
/// since the audio player plugin can be used in integration tests
/// but not in unit tests.
///
/// The test version of the AudioPlayerVM is a subclass of the
/// AudioPlayerVM. It overrides the methods initializeAudioPlayer
/// and modifyAudioPlayerPosition to avoid using the audio
/// player plugin.
class AudioPlayerVMTestVersion extends AudioPlayerVM {
  AudioPlayerVMTestVersion({
    required super.settingsDataService,
    required super.playlistListVM,
    required super.commentVM,
  });

  @override
  Future<void> audioPlayerSetSource(String audioFilePathName) async {
    // does not access to the audio player plugin so that unit
    // tests can be run without throwing an exception
  }

  @override
  Future<void> initializeAudioPlayer() {
    // does not access to the audio player plugin so that unit
    // tests can be run without throwing an exception
    return Future.value();
  }

  @override
  Future<void> modifyAudioPlayerPosition({
    required Duration durationPosition,
    bool isUndoCommandToAdd = false,
  }) async {
    // does not access to the audio player plugin so that unit
    // tests can be run without throwing an exception

    if (isUndoCommandToAdd) {
      addUndoCommand(
        newDurationPosition: durationPosition,
      );
    }

    // Necessary so that the audio position is updated in the
    // position text fields and the slider in the AudioPlayerView
    // screen.
    currentAudioPositionNotifier.value = durationPosition;
  }
}

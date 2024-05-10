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
    required super.playlistListVM,
  });

  @override
  void initializeAudioPlayerPlugin() {
    // does not access to the audio player plugin so that unit
    // tests can be run without throwing an exception
  }

  @override
  Future<void> modifyAudioPlayerPluginPosition(
      Duration durationPosition) async {
    // does not access to the audio player plugin so that unit
    // tests can be run without throwing an exception
  }
}

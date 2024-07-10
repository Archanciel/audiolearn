import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'audio_task_handler.dart';

class AudioPlayerVM extends ChangeNotifier {
  final AudioTaskHandler _audioTaskHandler;
  AudioPlayerVM(this._audioTaskHandler);

  AudioPlayer get _audioPlayer => _audioTaskHandler.audioPlayer;

  Future<void> playCurrentAudio(String audioFilePathName) async {
    if (audioFilePathName.isNotEmpty) {
      await _audioPlayer.play(DeviceFileSource(audioFilePathName));
      notifyListeners();
    }
  }

  Future<void> pauseCurrentAudio() async {
    await _audioPlayer.pause();
    notifyListeners();
  }
}

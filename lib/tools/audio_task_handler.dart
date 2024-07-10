import 'dart:isolate';
import 'package:path/path.dart' as path;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'package:audioplayers/audioplayers.dart';
import '../constants.dart';

class AudioTaskHandler extends TaskHandler {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayer get audioPlayer => _audioPlayer;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    await _initializeAudioPlayer();
  }

  Future<void> _initializeAudioPlayer() async {
    await _audioPlayer.setVolume(1.0);

    _audioPlayer.onDurationChanged.listen((duration) {
      // Handle duration change
    });

    _audioPlayer.onPositionChanged.listen((position) {
      // Handle position change
    });

    _audioPlayer.onPlayerComplete.listen((event) async {
      await _handleAudioCompletion();
    });
  }

  Future<void> _handleAudioCompletion() async {
    String nextAudioPath =
        '$kApplicationPathWindows${path.separator}S8 audio${path.separator}240701-163607-La surpopulation mondiale par Jancovici et Barrau 23-12-03.mp3'; // Replace with your audio file path

    await _audioPlayer.play(DeviceFileSource(nextAudioPath));

    // Define completion handling logic
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    // Handle events
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    _audioPlayer.dispose();
  }
}

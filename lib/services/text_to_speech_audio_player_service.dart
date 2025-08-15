import 'package:audioplayers/audioplayers.dart';
import 'logging_service.dart';
import '../models/audio_file.dart';

class TextToSpeechAudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playAudioFile({
    required AudioFile audioFile,
  }) async {
    try {
      await _audioPlayer.play(DeviceFileSource(audioFile.filePath));
    } catch (e) {
      logInfo('Erreur lors de la lecture: $e');
    }
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }

  Stream<PlayerState> get playerStateStream =>
      _audioPlayer.onPlayerStateChanged;

  Stream<Duration> get positionStream => _audioPlayer.onPositionChanged;

  Stream<Duration> get durationStream => _audioPlayer.onDurationChanged;

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

class AudioPlayerViewModel extends ChangeNotifier {
  late AudioPlayer _player;
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;
  String? _selectedFile;

  // Stream subscriptions
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  AudioPlayerViewModel() {
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.stop);

    _initPlayer();
  }

  // Getters
  bool get isPlaying => _playerState == PlayerState.playing;
  bool get isPaused => _playerState == PlayerState.paused;
  Duration? get duration => _duration;
  Duration? get position => _position;
  String? get selectedFile => _selectedFile;
  String get durationText => _duration?.toString().split('.').first ?? '';
  String get positionText => _position?.toString().split('.').first ?? '';

  // Select MP3 File
  Future<void> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      _selectedFile = filePath;
      notifyListeners();
      await _player.setSource(DeviceFileSource(filePath));
    }
  }

  // Play, Pause, Stop methods
  Future<void> play() async {
    if (_selectedFile != null) {
      await _player.resume();
      _playerState = PlayerState.playing;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _player.pause();
    _playerState = PlayerState.paused;
    notifyListeners();
  }

  Future<void> stop() async {
    await _player.stop();
    _playerState = PlayerState.stopped;
    _position = Duration.zero;
    notifyListeners();
  }

  void seek(double value) {
    if (_duration != null) {
      final position = value * _duration!.inMilliseconds;
      _player.seek(Duration(milliseconds: position.round()));
    }
  }

  // Initialize streams to listen to audio events
  void _initPlayer() {
    _player.setVolume(1.0);
    _durationSubscription = _player.onDurationChanged.listen((duration) {
      _duration = duration;
      notifyListeners();
    });

    _positionSubscription = _player.onPositionChanged.listen((p) {
      _position = p;
      notifyListeners();
    });

    _playerCompleteSubscription = _player.onPlayerComplete.listen((event) {
      _playerState = PlayerState.stopped;
      _position = Duration.zero;
      notifyListeners();
    });

    _playerStateChangeSubscription = _player.onPlayerStateChanged.listen((state) {
      _playerState = state;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }
}

import 'dart:async';
import 'package:path/path.dart' as path;

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

  // File path to load on start
  final String initialFilePath =
      "D:${path.separator}Users${path.separator}Jean-Pierre${path.separator}OneDrive${path.separator}Musique${path.separator}Organ_Voluntary_in_G_Major,_Op._7,_No._9-_I._Largo_Staccato[1].MP3";

  // The initial position to seek to when the file is loaded
  final Duration initialSeekPosition =
      const Duration(seconds: 30); // Set your desired position

  AudioPlayerViewModel() {
    _initPlayer();
    _loadInitialFileAndSeek();
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
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.stop);

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

    _playerStateChangeSubscription =
        _player.onPlayerStateChanged.listen((state) {
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

  // Load the initial file and seek to a specific position on startup
  Future<void> _loadInitialFileAndSeek() async {
    _selectedFile = initialFilePath;
    notifyListeners(); // Notify UI that a file is loaded

    // Load the file but don't play yet
    await _player.setSource(DeviceFileSource(_selectedFile!));

    // Play briefly to enable seeking, then pause and seek to the desired position
    await _player.resume(); // Start playback briefly to enable seek
    await _player.pause(); // Pause immediately

    // Now seek to the desired initial position
    await _player.seek(initialSeekPosition);
    notifyListeners(); // Notify listeners after seeking
  }
}

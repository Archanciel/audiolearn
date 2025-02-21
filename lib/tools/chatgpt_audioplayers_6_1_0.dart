import 'dart:io';

import 'package:audiolearn/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import 'dart:async';
import 'package:path/path.dart' as path;

import 'package:audioplayers/audioplayers.dart';
import '../viewmodels/audio_extractor_vm.dart';

class AudioPlayerViewModel extends ChangeNotifier {
  final AudioPlayer _audioPlayer;
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;
  String? _selectedFilePathName;

  // Stream subscriptions
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  // File path to load on start
  final String initialFilePath =
      "C:${path.separator}temp${path.separator}Organ_Voluntary_in_G_Major,_Op._7,_No._9-_I._Largo_Staccato.MP3";

  // The initial position to seek to when the file is loaded
  final Duration initialSeekPosition =
      const Duration(seconds: 0); // Set your desired position

  AudioPlayerViewModel() : _audioPlayer = AudioPlayer() {
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _initPlayer();
    _loadInitialFileAndSeek();
  }

  // Getters
  bool get isPlaying => _playerState == PlayerState.playing;
  bool get isPaused => _playerState == PlayerState.paused;
  Duration? get duration => _duration;
  Duration? get position => _position;
  String? get selectedFile => _selectedFilePathName;
  String get durationText => _duration?.toString().split('.').first ?? '';
  String get positionText => _position?.toString().split('.').first ?? '';

  // Play, Pause, Stop methods
  Future<void> play() async {
    if (_selectedFilePathName != null) {
      await _audioPlayer.play(DeviceFileSource(_selectedFilePathName!));
      await _audioPlayer.setPlaybackRate(1.0);
      _playerState = PlayerState.playing;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    _playerState = PlayerState.paused;
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _playerState = PlayerState.stopped;
    _position = Duration.zero;
    notifyListeners();
  }

  void seek(double value) {
    if (_duration != null) {
      final position = value * _duration!.inMilliseconds;
      _audioPlayer.seek(Duration(milliseconds: position.round()));
    }
  }

  // Initialize streams to listen to audio events
  void _initPlayer() {
    _audioPlayer.setVolume(1.0);
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration;
      notifyListeners();
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((p) {
      _position = p;
      notifyListeners();
    });

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      _playerState = PlayerState.stopped;
      _position = Duration.zero;
      notifyListeners();
    });

    _playerStateChangeSubscription =
        _audioPlayer.onPlayerStateChanged.listen((state) {
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
    _audioPlayer.dispose();
    super.dispose();
  }

  // Load the initial file and seek to a specific position on startup
  Future<void> _loadInitialFileAndSeek() async {
    _selectedFilePathName = initialFilePath;

    // Load the file but don't play yet
    await _audioPlayer.setSource(DeviceFileSource(_selectedFilePathName!));

    // Now seek to the desired initial position
    await _audioPlayer.seek(initialSeekPosition);
    notifyListeners(); // Notify listeners after seeking
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure plugins are initialized

  setWindowsAppSizeAndPosition(isTest: true);
  runApp(const MaterialApp(home: SimpleExampleApp()));
}

/// If app runs on Windows, Linux or MacOS, set the app size
/// and position.
Future<void> setWindowsAppSizeAndPosition({
  required bool isTest,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  if ((Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await getScreenList().then((List<Screen> screens) {
      // Assumez que vous voulez utiliser le premier écran (principal)
      final Screen screen = screens.first;
      final Rect screenRect = screen.visibleFrame;

      // Définissez la largeur et la hauteur de votre fenêtre
      double windowWidth = (isTest) ? 900 : 730;
      const double windowHeight = 1300;

      // Calculez la position X pour placer la fenêtre sur le côté droit de l'écran
      final double posX = screenRect.right - windowWidth + 10;
      // Optionnellement, ajustez la position Y selon vos préférences
      final double posY = (screenRect.height - windowHeight) / 2;

      final Rect windowRect =
          Rect.fromLTWH(posX, posY, windowWidth, windowHeight);
      setWindowFrame(windowRect);
    });
  }
}

class SimpleExampleApp extends StatelessWidget {
  const SimpleExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AudioPlayerViewModel()),
        ChangeNotifierProvider(
            create: (context) => AudioExtractorVM()), // ✅ Add this
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Simple Player MVVM'),
        ),
        body: const PlayerView(),
      ),
    );
  }
}

class PlayerView extends StatelessWidget {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const PlayerControls(),
        Consumer<AudioPlayerViewModel>(
          builder: (context, viewModel, child) {
            return Slider(
              onChanged: (value) => viewModel.seek(value),
              value: (viewModel.position != null &&
                      viewModel.duration != null &&
                      viewModel.position!.inMilliseconds > 0 &&
                      viewModel.position!.inMilliseconds <
                          viewModel.duration!.inMilliseconds)
                  ? viewModel.position!.inMilliseconds /
                      viewModel.duration!.inMilliseconds
                  : 0.0,
            );
          },
        ),
        Consumer<AudioPlayerViewModel>(
          builder: (context, viewModel, child) {
            return Text(
              viewModel.position != null
                  ? '${viewModel.positionText} / ${viewModel.durationText}'
                  : viewModel.duration != null
                      ? viewModel.durationText
                      : '',
              style: const TextStyle(fontSize: 16.0),
            );
          },
        ),
      ],
    );
  }
}

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;

    return Consumer2<AudioPlayerViewModel, AudioExtractorVM>(
      builder: (context, viewModel, audioExtractorVM, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: viewModel.isPlaying ? null : viewModel.play,
              iconSize: 48.0,
              icon: const Icon(Icons.play_arrow),
              color: color,
            ),
            IconButton(
              onPressed: viewModel.isPlaying ? viewModel.pause : null,
              iconSize: 48.0,
              icon: const Icon(Icons.pause),
              color: color,
            ),
            IconButton(
              onPressed: viewModel.isPlaying || viewModel.isPaused
                  ? viewModel.stop
                  : null,
              iconSize: 48.0,
              icon: const Icon(Icons.stop),
              color: color,
            ),
            IconButton(
              onPressed: () async {
                String playlistChristDownloadRootPath = '$kPlaylistDownloadRootPath${path.separator}Jésus-Christ';
                await audioExtractorVM.extractMp3FilePartToMp3File(
                  sourceMp3FilePathName: "$playlistChristDownloadRootPath${path.separator}250124-193109-Cela Changera Ta Foi  - Comment AIMER DIEU par-dessus TOUT, Selon JÉSUS ! 25-01-15.mp3",
                  extractMp3FilePathName:
                      '$playlistChristDownloadRootPath${path.separator}output.mp3',
                  startTime: 30.0,
                  duration: 60.0,
                );
              },
              iconSize: 48.0,
              icon: const Icon(Icons.cut),
              color: color,
            ),
          ],
        );
      },
    );
  }
}

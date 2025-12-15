import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class ExtractMp3AudioPlayerVM extends ChangeNotifier {
  // The audio player instance
  AudioPlayer? _player;

  // Current playback state
  bool _isPlaying = false;

  bool _isLoaded = false;
  set isLoaded(bool value) {
    _isLoaded = value;
    notifyListeners();
  }

  String? _currentFilePath;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Error tracking
  bool _hasError = false;
  String _errorMessage = '';

  // Stream subscriptions
  List<StreamSubscription?> _subscriptions = [];

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isLoaded => _isLoaded;
  String? get currentFilePath => _currentFilePath;
  Duration get duration => _duration;
  Duration get position => _position;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  double get progressPercent =>
      _duration.inMilliseconds > 0
          ? _position.inMilliseconds / _duration.inMilliseconds
          : 0.0;

  ExtractMp3AudioPlayerVM() {
    _initializePlayer();
  }

  void _initializePlayer() {
    try {
      // Create a new player instance
      _disposeCurrentPlayer();
      _player = AudioPlayer();
      _setupPlayerListeners();
    } catch (e) {
      _setError(message: 'Error initializing player: $e');
    }
  }

  void _setupPlayerListeners() {
    if (_player == null) return;

    // Clear previous subscriptions if any
    _cancelSubscriptions();

    try {
      // Listen to player state changes
      _subscriptions.add(
        _player!.onPlayerStateChanged.listen(
          (state) {
            _isPlaying = state == PlayerState.playing;
            notifyListeners();
          },
          onError: (e) {
            debugPrint('Player state error: $e');
          },
        ),
      );

      // Listen to duration changes
      _subscriptions.add(
        _player!.onDurationChanged.listen(
          (newDuration) {
            _duration = newDuration;
            notifyListeners();
          },
          onError: (e) {
            debugPrint('Duration stream error: $e');
          },
        ),
      );

      // Listen to position changes
      _subscriptions.add(
        _player!.onPositionChanged.listen(
          (newPosition) {
            _position = newPosition;
            notifyListeners();
          },
          onError: (e) {
            debugPrint('Position stream error: $e');
          },
        ),
      );

      // Listen for completion - FIXED FOR ANDROID
      _subscriptions.add(
        _player!.onPlayerComplete.listen(
          (_) async {
            // Reset playing state first
            _isPlaying = false;

            // Reset position to beginning
            _position = Duration.zero;

            // For Windows and Android, we need to reload the file to ensure it can be replayed
            if ((Platform.isWindows || Platform.isAndroid) &&
                _currentFilePath != null) {
              try {
                // Reload the source to ensure it's ready for replay
                await _player!.setSource(
                  DeviceFileSource(_currentFilePath!),
                );
              } catch (e) {
                debugPrint(
                  'Error reloading source after completion: $e',
                );
                // If reloading fails, try to seek to beginning as fallback
                try {
                  await _player!.seek(Duration.zero);
                } catch (seekError) {
                  debugPrint(
                    'Error seeking after completion: $seekError',
                  );
                }
              }
            } else {
              // For other platforms, just seek to beginning
              try {
                await _player!.seek(Duration.zero);
              } catch (e) {
                debugPrint('Error seeking after completion: $e');
              }
            }

            notifyListeners();
          },
          onError: (e) {
            debugPrint('Player complete error: $e');
          },
        ),
      );
    } catch (e) {
      debugPrint('Error setting up listeners: $e');
    }
  }

  void _cancelSubscriptions() {
    for (var subscription in _subscriptions) {
      subscription?.cancel();
    }
    _subscriptions = [];
  }

  // Load a file for playback
  Future<void> loadFile({required String filePath}) async {
    // Reset error state
    _hasError = false;
    _errorMessage = '';

    try {
      if (!File(filePath).existsSync()) {
        _setError(message: 'File does not exist: $filePath');
        return;
      }

      // On Windows, recreate the player for each file to avoid threading issues
      if (Platform.isWindows) {
        _initializePlayer();
      }

      try {
        if (_player == null) {
          _initializePlayer();
        }

        // Wrap in a try-catch to handle potential PlatformExceptions
        try {
          // For audioplayers, we use setSource with a DeviceFileSource
          await _player!.setSource(DeviceFileSource(filePath));
          _isLoaded = true;
          _currentFilePath = filePath;
          notifyListeners();
        } on PlatformException catch (e) {
          debugPrint('Platform exception loading file: $e');
          // Try one more time with a recreated player
          _initializePlayer();
          await Future.delayed(const Duration(milliseconds: 500));
          await _player!.setSource(DeviceFileSource(filePath));
          _isLoaded = true;
          _currentFilePath = filePath;
          notifyListeners();
        }
      } catch (e) {
        _setError(message: 'Error loading audio: $e');
      }
    } catch (e) {
      _setError(message: 'Error loading audio file: $e');
    }
  }

  // Play or pause the current track
  Future<void> togglePlay() async {
    if (!_isLoaded || _player == null) return;

    try {
      if (_isPlaying) {
        await _player!.pause();
      } else {
        // For Windows, add a safety check
        if (Platform.isWindows &&
            _currentFilePath != null &&
            !_isPlaying) {
          // Check if we need to reload the file
          if (_position == Duration.zero &&
              _duration == Duration.zero) {
            await loadFile(filePath: _currentFilePath!);
          }
        }
        await _player!.resume();
      }
    } catch (e) {
      _setError(message: 'Error toggling playback: $e');
    }
  }

  // Seek to a specific position
  Future<void> _seekTo({required Duration position}) async {
    if (!_isLoaded || _player == null) return;

    try {
      await _player!.seek(position);
    } catch (e) {
      debugPrint('Error seeking: $e');
    }
  }

  // Seek by percentage (0.0 to 1.0)
  Future<void> seekByPercentage({required double percentage}) async {
    if (!_isLoaded || _duration == Duration.zero || _player == null)
      return;

    final newPosition = Duration(
      milliseconds: (percentage * _duration.inMilliseconds).round(),
    );
    await _seekTo(position: newPosition);
  }

  // Set error state
  void _setError({required String message}) {
    _hasError = true;
    _errorMessage = message;
    _isLoaded = false;
    debugPrint('AudioPlayer error: $message');
    notifyListeners();
  }

  // NEW: Release the current file to prevent file locking issues (especially on Windows)
  Future<void> releaseCurrentFile() async {
    try {
      debugPrint('Releasing current file...');

      if (_player != null) {
        // Stop playback if playing
        if (_isPlaying) {
          await _player!.stop();
        }

        // Reset state
        _isPlaying = false;
        _isLoaded = false;
        _position = Duration.zero;
        _duration = Duration.zero;

        // Dispose of the current player to release file handles
        _disposeCurrentPlayer();

        // Wait a bit to ensure file handles are released
        await Future.delayed(const Duration(milliseconds: 200));

        // Reinitialize the player for future use
        _initializePlayer();

        debugPrint('File released successfully');
      }

      _currentFilePath = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error releasing file: $e');
    }
  }

  // Attempt to fix player issues
  Future<void> tryRepairPlayer() async {
    _initializePlayer();
    if (_currentFilePath != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      await loadFile(filePath: _currentFilePath!);
    }
  }

  void _disposeCurrentPlayer() {
    _cancelSubscriptions();
    _player?.dispose();
    _player = null;
  }

  // Clean up resources
  @override
  void dispose() {
    _disposeCurrentPlayer();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

import '../constants.dart';

class MyAudioHandler extends BaseAudioHandler {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<MediaItem> _queue = [];
  int _currentIndex = 0;

  MyAudioHandler() {
    _initListeners();
  }

  void _initListeners() {
    _audioPlayer.onPlayerComplete.listen((_) {
      skipToNext();
    });
  }

  MediaItem mediaItemFromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] as String,
      title: json['title'] as String,
      album: json['album'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'])
          : null,
      artUri: json['artUri'] != null ? Uri.parse(json['artUri']) : null,
    );
  }

  @override
  Future<dynamic> customAction(String name,
      [Map<String, dynamic>? extras]) async {
    if (name == 'setQueue') {
      final List<dynamic> mediaItems = extras?['mediaItems'] ?? [];
      _setQueue(mediaItems.map((item) => mediaItemFromJson(item)).toList());
    }
  }

  void _setQueue(List<MediaItem> mediaItems) {
    _queue.clear();
    _queue.addAll(mediaItems);
    queue.add(_queue); // Notify listeners about the updated queue
    if (_queue.isNotEmpty) {
      mediaItem.add(_queue[0]); // Set the first item as the current MediaItem
    }
  }

  @override
  Future<void> play() async {
    if (_queue.isNotEmpty && _currentIndex < _queue.length) {
      final MediaItem currentMediaItem = _queue[_currentIndex];
      mediaItem.add(
          currentMediaItem); // Notify listeners about the current MediaItem
      await _audioPlayer.play(DeviceFileSource(currentMediaItem.id));
      playbackState.add(playbackState.value.copyWith(
        playing: true,
        controls: [
          MediaControl.pause,
          MediaControl.stop,
          MediaControl.skipToNext,
          MediaControl.skipToPrevious,
        ],
      ));
    }
  }

  @override
  Future<void> pause() async {
    await _audioPlayer.pause();
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      controls: [
        MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
        MediaControl.skipToPrevious,
      ],
    ));
  }

  @override
  Future<void> skipToNext() async {
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      play();
    } else {
      stop();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      play();
    }
  }

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      controls: [],
    ));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request permissions before initializing audio service
  if (await Permission.storage.request().isGranted) {
    print('Storage permission granted.');

    // Initialize AudioService
    final AudioHandler audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.example.audio',
        androidNotificationChannelName: 'Audio Playback',
        androidNotificationOngoing: true,
      ),
    );

    runApp(MyApp(audioHandler: audioHandler));
  } else {
    print('Storage permission not granted.');
    // Optionally show an error or exit the app
  }
}

class MyApp extends StatelessWidget {
  final AudioHandler audioHandler;

  const MyApp({
    super.key,
    required this.audioHandler,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Player with Queue',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AudioPlayerPage(audioHandler: audioHandler),
    );
  }
}

class AudioPlayerPage extends StatefulWidget {
  final AudioHandler audioHandler;

  const AudioPlayerPage({
    super.key,
    required this.audioHandler,
  });

  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  List<File> _audioFiles = [];

  @override
  void initState() {
    super.initState();
    _loadAudioFiles();
  }

Future<void> _loadAudioFiles() async {
  if (mounted) {
    // Ensure this runs in the context of a valid UI activity
    if (await Permission.storage.request().isGranted) {
      final Directory dir = Directory('$kApplicationPath${path.separator}Jésus-Christ'); // Example directory
      if (dir.existsSync()) {
        final files =
            dir.listSync().where((f) => f.path.endsWith('.mp3')).toList();
        setState(() {
          _audioFiles = files.map((f) => File(f.path)).toList();
        });

        // Create MediaItems and load them into the queue
        final mediaItems = _audioFiles
            .map((file) => MediaItem(
                  id: file.path,
                  title: file.path.split('/').last,
                  album: 'Local Files',
                ))
            .toList();

        await widget.audioHandler.customAction('setQueue', {
          'mediaItems': mediaItems.map((item) {
            return {
              'id': item.id,
              'title': item.title,
              'album': item.album,
              'artist': item.artist,
              'duration': item.duration?.inMilliseconds,
              'artUri': item.artUri?.toString(),
            };
          }).toList(),
        });
      }
    } else {
      // Handle case where permissions are denied
      print('Storage permission not granted.');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audio Player with Queue')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _audioFiles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_audioFiles[index].path.split('/').last),
                  onTap: () {
                    widget.audioHandler.skipToQueueItem(index);
                  },
                );
              },
            ),
          ),
          StreamBuilder<PlaybackState>(
            stream: widget.audioHandler.playbackState,
            builder: (context, snapshot) {
              final state = snapshot.data;
              final playing = state?.playing ?? false;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.skip_previous),
                    onPressed: () => widget.audioHandler.skipToPrevious(),
                  ),
                  IconButton(
                    icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      if (playing) {
                        widget.audioHandler.pause();
                      } else {
                        widget.audioHandler.play();
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next),
                    onPressed: () => widget.audioHandler.skipToNext(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

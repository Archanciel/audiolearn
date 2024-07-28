import 'dart:io';

import 'package:audiolearn/constants.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:window_size/window_size.dart';

import '../utils/duration_expansion.dart';
void main() {
  setWindowsAppSizeAndPosition(isTest: true);
  runApp(const MyApp());
}

/// If app runs on Windows, Linux or MacOS, set the app size
/// and position.
Future<void> setWindowsAppSizeAndPosition({
  required bool isTest,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MP3 Duration Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _duration;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (result != null) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        //      int? duration = await getMp3Duration(filePath);
        Duration? duration = await getMp3DurationWithAudioPlayer(filePath);
        setState(() {
          _duration = duration != null
              ? duration.HHmmss()
              : 'Failed to get duration';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MP3 Duration Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await _pickFile();
              },
              child: const Text('Pick MP3 File'),
            ),
            if (_duration != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Duration: $_duration'),
              ),
          ],
        ),
      ),
    );
  }

  Future<Duration?> getMp3DurationWithAudioPlayer(String filePath) async {
    AudioPlayer audioPlayer = AudioPlayer();
    Duration? duration;

    // Load audio file
    await audioPlayer.setSource(DeviceFileSource(filePath));
    // Get duration
    await audioPlayer.getDuration().then((value) {
      duration = value;
    });

    // Dispose of audio player
    await audioPlayer.dispose();

    return duration;
  }
}

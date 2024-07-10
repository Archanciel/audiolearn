import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

import '../constants.dart';
import 'audio_service.dart';
import 'audio_player_vm.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AudioService _audioService = AudioService();

  @override
  Widget build(BuildContext context) {
    _audioService.startService();

    return ChangeNotifierProvider(
      create: (_) => AudioPlayerVM(_audioService.audioTaskHandler),
      child: MaterialApp(
        title: 'Flutter Audio App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String audioFilePath =
      // '$kApplicationPathWindows${path.separator}S8 audio${path.separator}240701-163607-La surpopulation mondiale par Jancovici et Barrau 23-12-03.mp3'; // Replace with your audio file path
      '$kApplicationPathWindows${path.separator}local${path.separator}240110-181805-Really short video 23-07-01.mp3'; // Replace with your audio file path

  @override
  Widget build(BuildContext context) {
    final audioPlayerVM = Provider.of<AudioPlayerVM>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Audio App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                audioPlayerVM.playCurrentAudio(audioFilePath);
              },
              child: Text('Play Audio'),
            ),
            ElevatedButton(
              onPressed: () {
                audioPlayerVM.pauseCurrentAudio();
              },
              child: Text('Pause Audio'),
            ),
          ],
        ),
      ),
    );
  }
}

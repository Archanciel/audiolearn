import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import '../constants.dart';
import 'audio_player_view_model.dart';

void main() {
  setWindowsAppSizeAndPosition(isTest: true);
  runApp(const MaterialApp(home: SimpleExampleApp()));
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

class SimpleExampleApp extends StatelessWidget {
  const SimpleExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AudioPlayerViewModel(),
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
        Consumer<AudioPlayerViewModel>(
          builder: (context, viewModel, child) {
            return Text(
              viewModel.selectedFile != null
                  ? 'Selected File: ${viewModel.selectedFile!.split('/').last}'
                  : 'No file selected',
              style: const TextStyle(fontSize: 16),
            );
          },
        ),
        const SizedBox(height: 20),
        Consumer<AudioPlayerViewModel>(
          builder: (context, viewModel, child) {
            return ElevatedButton(
              onPressed: viewModel.selectFile,
              child: const Text('Select MP3'),
            );
          },
        ),
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

    return Consumer<AudioPlayerViewModel>(
      builder: (context, viewModel, child) {
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
          ],
        );
      },
    );
  }
}

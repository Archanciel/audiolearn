import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';

import '../constants.dart';
import '../models/playlist.dart';
import 'chatGPT_warning_message_vm.dart';

import 'chatGPT_warning_message_display_widget.dart';

Future<void> main() async {
  // Now proceed with setting up the app window size and position if needed
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await setWindowsAppSizeAndPosition(isTest: true);
  }

  runApp(MyApp());
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

Future<void> setWindowsAppVersionSize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(600, 715),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    // keeping Windows title bar enables to move the app window
    // titleBarStyle: TitleBarStyle.hidden,
    // windowButtonVisibility: false,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WarningMessageVM(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multiple Warning Display'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _simulateFileImport(context);
              },
              child: Text('Simulate File Import'),
            ),
            WarningMessageDisplayWidget(
              parentContext: context,
              warningMessageVM: Provider.of<WarningMessageVM>(context),
            ),
          ],
        ),
      ),
    );
  }

  void _simulateFileImport(BuildContext context) {
    String rejectedImportedFileNames = 'audio1.mp3, audio2.mp3, ';
    String acceptableImportedFileNames = 'audio3.mp3, audio4.mp3, ';

    WarningMessageVM warningMessageVM =
        Provider.of<WarningMessageVM>(context, listen: false);

    if (rejectedImportedFileNames.isNotEmpty) {
      warningMessageVM.setAudioNotImportedToPlaylistTitles(
        rejectedImportedAudioFileNames: rejectedImportedFileNames.substring(
            0, rejectedImportedFileNames.length - 2),
        importedToPlaylistTitle: 'target playlist',
        importedToPlaylistType: PlaylistType.local,
      );
    }

    if (acceptableImportedFileNames.isNotEmpty) {
      warningMessageVM.setAudioNotImportedToPlaylistTitles(
        rejectedImportedAudioFileNames: acceptableImportedFileNames.substring(
            0, acceptableImportedFileNames.length - 2),
        importedToPlaylistTitle: 'target playlist',
        importedToPlaylistType: PlaylistType.local,
      );
    }
  }
}

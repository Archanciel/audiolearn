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

  runApp(const MainApp());
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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => WarningMessageVM(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _textValue = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiple Warning Display'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _displayNoWarning(context);
                setState(() {
                  _textValue = 'No warning displayed';
                });
              },
              child: const Text('Display no warning'),
            ),
            ElevatedButton(
              onPressed: () {
                _displayOneWarnings(context);
                setState(() {
                  _textValue = 'One warning displayed';
                });
              },
              child: const Text('Display 1 warning'),
            ),
            ElevatedButton(
              onPressed: () {
                _displayTwoWarnings(context);
                setState(() {
                  _textValue = 'Two warnings displayed';
                });
              },
              child: const Text('Display 2 warnings'),
            ),
            const SizedBox(height: 200),
            Text(_textValue),

            // Must be instanciated here !!
            WarningMessageDisplayWidget(
              parentContext: context,
              warningMessageVM: Provider.of<WarningMessageVM>(context),
            ),
          ],
        ),
      ),
    );
  }

  void _displayNoWarning(BuildContext context) {
    String rejectedImportedFileNames = '';
    String acceptableImportedFileNames = '';

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

  void _displayOneWarnings(BuildContext context) {
    String rejectedImportedFileNames = 'audio1.mp3, audio2.mp3, ';
    String acceptableImportedFileNames = '';

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

  void _displayTwoWarnings(BuildContext context) {
    String rejectedImportedFileNames = 'First warning, audio1.mp3, audio2.mp3, ';
    String acceptableImportedFileNames = 'Second warning, audio3.mp3, audio4.mp3, ';

    WarningMessageVM warningMessageVM =
        Provider.of<WarningMessageVM>(context, listen: false);

    if (acceptableImportedFileNames.isNotEmpty) {
      warningMessageVM.setAudioNotImportedToPlaylistTitles(
        rejectedImportedAudioFileNames: acceptableImportedFileNames.substring(
            0, acceptableImportedFileNames.length - 2),
        importedToPlaylistTitle: 'target playlist',
        importedToPlaylistType: PlaylistType.local,
      );
    }

    if (rejectedImportedFileNames.isNotEmpty) {
      warningMessageVM.setAudioNotImportedToPlaylistTitles(
        rejectedImportedAudioFileNames: rejectedImportedFileNames.substring(
            0, rejectedImportedFileNames.length - 2),
        importedToPlaylistTitle: 'target playlist',
        importedToPlaylistType: PlaylistType.local,
      );
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

import '../constants.dart';

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
      // Assume you want to use the primary screen
      final Screen screen = screens.first;
      final Rect screenRect = screen.visibleFrame;

      // Define the window width and height
      double windowWidth = (isTest) ? 900 : 730;
      const double windowHeight = 1300;

      // Calculate the position X to place the window on the right side of the screen
      final double posX = screenRect.right - windowWidth + 10;
      // Optionally, adjust the Y position as desired
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
      title: 'Scrollable Articles',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ArticleListPage(),
    );
  }
}

class ArticleListPage extends StatelessWidget {
  const ArticleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample article titles of varying lengths
    final List<String> articles = List.generate(
      50,
      (index) => 'Article ${index + 1}:\n' +
          List.generate(index % 5 + 1, (i) => 'Line ${i + 1}')
              .join('\n'), // Generate titles with 1-5 lines
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles List'),
      ),
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  articles[index],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

import '../constants.dart';

// https://chatgpt.com/share/67304f80-ce4c-8004-85d2-4d090d195a31
//
// The value of const double itemHeight = 120.0; was an approximation based on
// the assumed average height of each ListView item. This height includes the
// combined height of the text content, padding, and any decorations (e.g., the
// Card widget). Here's a breakdown of how it might have been estimated:

// Breakdown of itemHeight Calculation
// Text Height:

// Each article consists of multiple lines of text.
// The height of a single line of text can be calculated as:
// dart
// Copier le code
// double lineHeight = fontSize * 1.2; // 1.2 is the typical line height multiplier
// For example, with a font size of 16:
// dart
// Copier le code
// double lineHeight = 16.0 * 1.2 = 19.2;
// If most articles have an average of ~4 lines, the total text height would be:
// dart
// Copier le code
// textHeight = lineHeight * 4 = 19.2 * 4 = 76.8;
// Padding:

// The Card widget and its inner Padding contribute additional height:
// Outer Padding: const EdgeInsets.all(8.0) = 8 + 8 = 16
// Inner Padding: const EdgeInsets.all(16.0) = 16 + 16 = 32
// Total padding: 16 + 32 = 48
// Total Estimated Height:

// Adding the text height and padding:
// dart
// Copier le code
// itemHeight = textHeight + totalPadding = 76.8 + 48 = ~125
// Adjustment for Consistency:

// For simplicity, the value was rounded down to 120.0, a common practice to
// avoid overly specific constants.

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
      final Screen screen = screens.first;
      final Rect screenRect = screen.visibleFrame;

      double windowWidth = (isTest) ? 900 : 730;
      const double windowHeight = 1300;

      final double posX = screenRect.right - windowWidth + 10;
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

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _articleNumberController =
      TextEditingController();

  late final List<String> articles = List.generate(
    400,
    (index) {
      final int numberOfLines = _getRandomLineCount();
      final String lines =
          List.generate(numberOfLines, (i) => 'Line ${i + 1}').join('\n');
      return 'Article ${index + 1}:\n$lines';
    },
  );

  /// Scroll to the specified article index
  void _scrollToArticle() {
    final int articleIndex = int.tryParse(_articleNumberController.text) ?? -1;

    if (articleIndex >= 1 && articleIndex <= articles.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToItem(articleIndex - 1);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid article number')),
      );
    }
  }

  /// Compute the exact scroll offset for the desired index
  void _scrollToItem(int index) {
    double itemHeight = 190.0; // Approximate height per item
    if (index > 160) {
      itemHeight = 192.93; // Approximate height per item
    }
    _scrollController.animateTo(
      index * itemHeight,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  /// Generates a random number of lines based on a probability distribution
  int _getRandomLineCount() {
    final Random random = Random();
    final double probability = random.nextDouble();

    if (probability < 0.35) {
      return 6; // 35% chance for 7 lines
    } else if (probability < 0.7) {
      return 5; // 35% chance for 6 lines
    } else if (probability < 0.9) {
      return 4; // 20% chance for 5 lines
    } else {
      return 3; // 10% chance for 4 lines
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _articleNumberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter article number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _scrollToArticle,
                  child: const Text('Scroll'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
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
          ),
        ],
      ),
    );
  }
}

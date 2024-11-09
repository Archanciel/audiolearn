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
  final List<String> articles = List.generate(
    50,
    (index) => 'Article ${index + 1}:\n' +
        List.generate(index % 5 + 1, (i) => 'Line ${i + 1}').join('\n'),
  );

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _articleNumberController =
      TextEditingController();

  /// Scroll to the specified article index
  void _scrollToArticle() {
    final int articleIndex =
        int.tryParse(_articleNumberController.text) ?? -1;

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
    final RenderBox? renderBox =
        _scrollController.position.context.storageContext.findRenderObject()
            as RenderBox?;
    if (renderBox != null) {
      final double offset = renderBox.localToGlobal(Offset.zero).dy;
      _scrollController.animateTo(
        index * offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

import '../constants.dart';

void main() {
  setWindowsAppSizeAndPosition(isTest: true);
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final double fontSizeConst = 30;

  @override
  Widget build(BuildContext context) {
    String text =
        "First comment.\n\nChatGPT is a chatbot and virtual assistant developed by OpenAI and launched on November 30, 2022. Based on large language models (LLMs), it enables users to refine and steer a conversation towards a desired length, format, style, level of detail, and language. Successive user prompts and replies are considered at each conversation stage as context.";

    int lineCount = calculateTextLines(context, text);

    return Scaffold(
      appBar: AppBar(title: const Text('Text Line Calculation')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Text Example'),
                  content: SingleChildScrollView(
                    child: SingleChildScrollView(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: fontSizeConst,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
          child: Text('Show Dialog ($lineCount lines)'),
        ),
      ),
    );
  }

  int calculateTextLines(BuildContext context, String text) {
    // Define your TextStyle
    TextStyle style = TextStyle(fontSize: fontSizeConst,);

    // Create TextSpan with your text
    TextSpan textSpan = TextSpan(text: text, style: style);

    // Create TextPainter with TextSpan and other text settings
    TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: null,
    );

    // Set max width constraints (e.g., max width of AlertDialog)
    double maxWidth = MediaQuery.of(context).size.width * 0.67;

    // Layout the text with given constraints
    textPainter.layout(maxWidth: maxWidth);

    // Calculate the number of lines required
    int lineCount = textPainter.computeLineMetrics().length;

    return lineCount; // Add 1 for the last line
  }
}

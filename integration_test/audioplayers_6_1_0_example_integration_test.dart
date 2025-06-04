// integration_test/audioplayers_6_1_0_example_integration_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:audiolearn/tools/audioplayers_example.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Audio Player Integration Test', () {
    testWidgets('Play and Pause Test', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Find the play button
      final playButton = find.byIcon(Icons.play_arrow);
      expect(playButton, findsOneWidget);

      // Tap the play button
      await tester.tap(playButton);
      await tester.pumpAndSettle();

      // Add delays to display the slider progression.
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
      }

      // Find the pause button (after playing)
      final pauseButton = find.byIcon(Icons.pause);
      expect(pauseButton, findsOneWidget);

      // Tap the pause button
      await tester.tap(pauseButton);
      await tester.pumpAndSettle();

      // Assert that the pause button is disabled after pausing
      expect(playButton, findsOneWidget);
    });
  });
}
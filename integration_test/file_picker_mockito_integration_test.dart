import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

// Custom Mock FilePicker
class MockFilePicker extends FilePicker {
  @override
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    bool lockParentWindow = false,
    String? initialDirectory,
  }) async {
    return '$initialDirectory/local';
  }
}

void main() {
  testWidgets('Select local directory via File Picker', (WidgetTester tester) async {
    // Replace the platform instance with your mock
    FilePicker.platform = MockFilePicker();

    // Build the app UI for testing
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('File Picker Test')),
        body: Column(
          children: [
            TextField(key: const Key('directoryTextField')),
            IconButton(
              key: const Key('openDirectoryIconButton'),
              icon: const Icon(Icons.folder),
              onPressed: () async {
                final path = await FilePicker.platform.getDirectoryPath(
                  initialDirectory: '/test/data/audio',
                );
                // Simulate displaying the selected path
                if (path != null) {
                  debugPrint('Selected Path: $path');
                }
              },
            ),
          ],
        ),
      ),
    ));

    // Simulate tapping the button
    await tester.tap(find.byKey(const Key('openDirectoryIconButton')));
    await tester.pumpAndSettle();

    // Verify the expected behavior
    expect(find.byType(IconButton), findsOneWidget);
  });
}

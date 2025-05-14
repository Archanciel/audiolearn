// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';
import 'package:window_size/window_size.dart';

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

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Directory Copier to ZIP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DirectoryCopierPage(),
    );
  }
}

class DirectoryCopierPage extends StatefulWidget {
  const DirectoryCopierPage({super.key});

  @override
  _DirectoryCopierPageState createState() => _DirectoryCopierPageState();
}

class _DirectoryCopierPageState extends State<DirectoryCopierPage> {
  String? sourceDirectory;
  String? targetDirectory;
  String extension = '';

  // Method to pick a directory using File Picker
  Future<void> pickSourceDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        sourceDirectory = selectedDirectory;
      });
    }
  }

  Future<void> pickTargetDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        targetDirectory = selectedDirectory;
      });
    }
  }

  // Function to zip files with a specific extension
  Future<void> zipDirectory(String sourceDir, String targetDir, String fileExtension) async {
    Directory source = Directory(sourceDir);

    if (!source.existsSync()) {
      print("Source directory doesn't exist.");
      return;
    }

    // Create a zip encoder
    final archive = Archive();

    // Traverse the source directory and find matching files
    await for (var entity in source.list(recursive: true, followLinks: false)) {
      if (entity is File && path.extension(entity.path) == fileExtension) {
        String relativePath = path.relative(entity.path, from: sourceDir);
        
        // Add the file to the archive, preserving the relative path
        List<int> fileBytes = await entity.readAsBytes();
        archive.addFile(ArchiveFile(relativePath, fileBytes.length, fileBytes));
      }
    }

    // Save the archive to a zip file in the target directory
    String zipFileName = 'archived_files.zip';
    String zipFilePath = path.join(targetDir, zipFileName);

    File zipFile = File(zipFilePath);
    zipFile.writeAsBytesSync(ZipEncoder().encode(archive), flush: true);
    print('ZIP file created at: $zipFilePath');
  }

  // UI for picking directories and zipping files
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Directory Copier to ZIP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickSourceDirectory,
              child: Text('Select Source Directory'),
            ),
            if (sourceDirectory != null) Text('Source: $sourceDirectory'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickTargetDirectory,
              child: Text('Select Target Directory'),
            ),
            if (targetDirectory != null) Text('Target: $targetDirectory'),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: 'File Extension (e.g., .txt, .mp3)'),
              onChanged: (value) {
                setState(() {
                  extension = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (sourceDirectory != null && targetDirectory != null && extension.isNotEmpty)
                  ? () async {
                      await zipDirectory(sourceDirectory!, targetDirectory!, extension);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ZIP Created Successfully')));
                    }
                  : null,
              child: Text('Create ZIP'),
            ),
          ],
        ),
      ),
    );
  }
}

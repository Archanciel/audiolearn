import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';

import '../constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Picker Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FilePickerScreen(),
    );
  }
}

class FilePickerScreen extends StatefulWidget {
  const FilePickerScreen({
    super.key,
  });

  @override
  _FilePickerScreenState createState() => _FilePickerScreenState();
}

class _FilePickerScreenState extends State<FilePickerScreen> {
  List<PlatformFile>? _filePickerSelectedFiles;
  String? _targetDirectory;

  Future<void> _filePickerSelectAudioFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
      allowMultiple: true,
      initialDirectory: '$kApplicationPathWindowsTest${path.separator}S8 audio',
    );

    if (result != null) {
      setState(() {
        _filePickerSelectedFiles = result.files;
      });
    }
  }

  Future<void> _filePickerSelectTargetDirectory() async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath(
      initialDirectory: kApplicationPathWindowsTest,
    );

    if (directoryPath != null) {
      setState(() {
        _targetDirectory = directoryPath;
      });
    }
  }

  Future<void> _copyFilesToTargetDirectory() async {
    if (_filePickerSelectedFiles != null && _targetDirectory != null) {
      for (PlatformFile file in _filePickerSelectedFiles!) {
        String fileName = file.path!.split(path.separator).last;
        File sourceFile = File(file.path!);
        File targetFile =
            File('${_targetDirectory!}${path.separator}$fileName');

        await sourceFile.copy(targetFile.path);
      }
    }
  }

  Future<void> _moveFilesToTargetDirectory() async {
    if (_filePickerSelectedFiles != null && _targetDirectory != null) {
      for (PlatformFile file in _filePickerSelectedFiles!) {
        String fileName = file.path!.split(path.separator).last;
        File sourceFile = File(file.path!);
        File targetFile =
            File('${_targetDirectory!}${path.separator}$fileName');

        await sourceFile.rename(targetFile.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Picker Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _filePickerSelectAudioFiles();
              },
              child: const Text('Select MP3 Files'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _filePickerSelectTargetDirectory();
              },
              child: const Text('Select Target Directory'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _copyFilesToTargetDirectory();
              },
              child: const Text('Copy Files'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _moveFilesToTargetDirectory();
              },
              child: const Text('Move Files'),
            ),
            _filePickerSelectedFiles != null
                ? Text('Selected files: ${_filePickerSelectedFiles!.length}')
                : const Text('No files selected'),
          ],
        ),
      ),
    );
  }
}

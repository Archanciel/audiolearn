import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Picker Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FilePickerScreen(),
    );
  }
}

class FilePickerScreen extends StatefulWidget {
  @override
  _FilePickerScreenState createState() => _FilePickerScreenState();
}

class _FilePickerScreenState extends State<FilePickerScreen> {
  List<PlatformFile>? _filePickerSelectedFiles;
  String? _targetDirectory;

  Future<void> _pickDirectory() async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath != null) {
      setState(() {
        _targetDirectory = directoryPath;
      });
    }
  }

  Future<void> _filePickerPickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _filePickerSelectedFiles = result.files;
      });
    }
  }

  void _copyFiles() async {
    if (_filePickerSelectedFiles != null && _targetDirectory != null) {
      for (PlatformFile file in _filePickerSelectedFiles!) {
        String fileName = file.path!.split(path.separator).last;
        File sourceFile = File(file.path!);
        File targetFile = File('${_targetDirectory!}${path.separator}$fileName');
        sourceFile.copySync (targetFile.path);
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
              onPressed: _filePickerPickFiles,
              child: const Text('File Picker Select MP3 Files'),
            ),
            ElevatedButton(
              onPressed: _pickDirectory,
              child: const Text('Select Target Directory'),
            ),
            ElevatedButton(
              onPressed: _copyFiles,
              child: const Text('Copy Files'),
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

import 'dart:io';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:flutter/material.dart';

/// Commando generate the apk:
///
/// flutter build apk --release --target=lib/settingsConverter.dart
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Modify JSON App',
      home: JsonModifier(),
    );
  }
}

class JsonModifier extends StatefulWidget {
  const JsonModifier({super.key});

  @override
  _JsonModifierState createState() => _JsonModifierState();
}

class _JsonModifierState extends State<JsonModifier> {
  final TextEditingController _controller = TextEditingController();
  String _status = '';

  @override
  Widget build(BuildContext context) {
    _controller.text = "/storage/emulated/0/Download/audiolearn/settings.json";
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modify JSON'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter application root path',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _modifyJsonFile,
            child: const Text('Update settings.json'),
          ),
          const SizedBox(height: 20),
          Text(_status),
        ],
      ),
    );
  }

  Future<void> _modifyJsonFile() async {
    String filePath = _controller.text;
    try {
      await SettingsDataService.removePlaylistSettingsFromJsonFile(
        settingsJsonFile: File(filePath),
      );
      setState(() {
        _status =
            'settings.json modified successfully ! Now, install the new version of audioLearn.apk.';
      });
    } catch (e) {
      setState(() {
        _status =
            'Error modifying settings.json: $e. Do not install the new version of audioLearn.apk';
      });
    }
  }
}

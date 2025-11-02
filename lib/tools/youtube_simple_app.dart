import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:window_size/window_size.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() {
  setWindowsAppSizeAndPosition(isTest: true);

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YtAudioDownloaderApp());
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

class YtAudioDownloaderApp extends StatelessWidget {
  const YtAudioDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Audio Downloader',
      theme: ThemeData(
        colorSchemeSeed: Colors.blueGrey,
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _urlController = TextEditingController();
  final _yt = YoutubeExplode();

  String? _targetDir;
  double _progress = 0.0;
  bool _isDownloading = false;
  String _status = 'Idle';
  StreamSubscription<List<int>>? _downloadSub;

  @override
  void dispose() {
    _downloadSub?.cancel();
    _yt.close();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickDirectory() async {
    final dir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose target folder',
      initialDirectory: _targetDir,
      lockParentWindow: false,
    );
    if (dir != null) {
      setState(() => _targetDir = dir);
    }
  }

  Future<void> _download() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _setStatus('Please paste a YouTube URL.');
      return;
    }
    if (_targetDir == null) {
      _setStatus('Please choose a target folder first.');
      return;
    }

    try {
      setState(() {
        _isDownloading = true;
        _progress = 0.0;
        _status = 'Fetching video info...';
      });

      // 1) Resolve video and audio streams
      final video = await _yt.videos.get(url);
      final manifest = await _yt.videos.streamsClient.getManifest(video.id);

      // 2) Choose the best audio-only stream (highest bitrate)
      final audioOnly = manifest.audioOnly.sortByBitrate().lastOrNull;
      if (audioOnly == null) {
        _setStatus('No audio-only streams found for this video.');
        setState(() => _isDownloading = false);
        return;
      }

      // 3) Determine a sane file name & extension
      final containerExt = audioOnly.container.name; // e.g., "m4a", "webm"
      final safeTitle = _safeFileName(video.title);
      final fileName = '$safeTitle.$containerExt';
      final outPath = p.join(_targetDir!, fileName);

      // 4) Prepare file writer
      final file = File(outPath);
      final sink = file.openWrite();

      _setStatus('Downloading audio...');
      final totalBytes = audioOnly.size.totalBytes;
      int received = 0;

      // 5) Download stream with progress updates
      final stream = _yt.videos.streamsClient.get(audioOnly);

      _downloadSub = stream.listen(
        (data) {
          sink.add(data);
          received += data.length;
          if (totalBytes > 0) {
            setState(() => _progress = received / totalBytes);
          }
        },
        onDone: () async {
          await sink.flush();
          await sink.close();
          setState(() {
            _isDownloading = false;
            _progress = 1.0;
            _status = 'Completed: $fileName';
          });
        },
        onError: (e, st) async {
          await sink.flush();
          await sink.close();
          _handleError('Download failed', e);
        },
        cancelOnError: true,
      );
    } catch (e) {
      _handleError('Operation failed', e);
    }
  }

  void _cancel() {
    _downloadSub?.cancel();
    setState(() {
      _isDownloading = false;
      _progress = 0.0;
      _status = 'Canceled.';
    });
  }

  void _handleError(String prefix, Object e) {
    debugPrint('Error: $e');
    setState(() {
      _isDownloading = false;
      _status = '$prefix: $e';
    });
  }

  void _setStatus(String s) => setState(() => _status = s);

  String _safeFileName(String input) {
    // Create a Windows-safe file name (no reserved characters; trimmed length)
    final sanitized = input
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    // Limit to avoid OS path length issues
    return sanitized.isEmpty
        ? 'audio'
        : (sanitized.length > 150 ? sanitized.substring(0, 150) : sanitized);
  }

  @override
  Widget build(BuildContext context) {
    final canDownload = !_isDownloading &&
        (_targetDir != null) &&
        _urlController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('YouTube Audio Downloader (Windows)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // URL input
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'YouTube URL',
                hintText: 'https://www.youtube.com/watch?v=...',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            // Target folder picker
            Row(
              children: [
                Expanded(
                  child: Text(
                    _targetDir == null
                        ? 'No target folder chosen'
                        : _targetDir!,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isDownloading ? null : _pickDirectory,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Choose Folder'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Download / Cancel buttons
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: canDownload ? _download : null,
                  icon: const Icon(Icons.download),
                  label: const Text('Download audio'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _isDownloading ? _cancel : null,
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress + status
            if (_isDownloading || _progress > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                      value: _isDownloading ? _progress : null),
                  const SizedBox(height: 8),
                  Text(_isDownloading
                      ? 'Progress: ${(_progress * 100).toStringAsFixed(1)} %'
                      : _status),
                ],
              ),
            if (!_isDownloading && _progress == 0)
              Align(alignment: Alignment.centerLeft, child: Text(_status)),
            const Spacer(),
            const Divider(),
            const Text(
              'This tool saves the best available audio-only stream without transcoding.\n'
              'File type will match the stream container (e.g., .m4a, .webm).',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

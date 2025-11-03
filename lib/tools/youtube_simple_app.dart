import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:window_size/window_size.dart';

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
      theme: ThemeData(colorSchemeSeed: Colors.blueGrey, useMaterial3: true),
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
  final _urlCtrl = TextEditingController();
  Process? _ytDlpProc; // track the external process so Cancel can kill it

  String? _targetDir;
  final String _ytDlpPath = 'c:\\YtDlp\\yt-dlp.exe'; // Optional explicit path to yt-dlp.exe
  double _progress = 0.0;
  bool _busy = false;
  String _status = 'Idle';
  StreamSubscription<List<int>>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDirectory() async {
    final dir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose target folder',
      initialDirectory: _targetDir,
    );
    if (dir != null) setState(() => _targetDir = dir);
  }

  Future<void> _download() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) {
      _setStatus('Please paste a YouTube URL.');
      return;
    }
    if (_targetDir == null) {
      _setStatus('Please choose a target folder first.');
      return;
    }

    setState(() {
      _busy = true;
      _progress = 0.0;
      _status = 'Preparing…';
    });

    try {
      final ok = await _downloadWithYtDlp(url); // go straight to yt-dlp
      setState(() {
        _busy = false;
        _progress = ok ? 1.0 : 0.0;
        if (ok) _status = 'Download completed (MP3 ready).';
      });
    } catch (e) {
      setState(() {
        _busy = false;
        _status = 'yt-dlp failed: $e';
      });
    }
  }

  Future<bool> _downloadWithYtDlp(String url) async {
    final exe = _ytDlpPath;

    // Requires ffmpeg.exe to be available (PATH or next to yt-dlp.exe)
    final outTpl = p.join(_targetDir!, '%(title).150s.%(ext)s');

    final args = [
      '-f', 'bestaudio/best',
      '--extract-audio',
      '--audio-format', 'mp3',
      '--audio-quality', '0', // best
      '-o', outTpl,
      '--restrict-filenames',
      '--newline',
      url,
    ];

    _setStatus('Downloading and converting to MP3…');
    setState(() => _progress = 0.0);

    // Start process and keep a handle for Cancel
    _ytDlpProc = await Process.start(exe, args, runInShell: true);

    // Parse progress from stdout like: [download]  37.4% of ...
    final stdoutLines = _ytDlpProc!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    final stderrLines = _ytDlpProc!.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    final subs = <StreamSubscription>[];

    subs.add(stdoutLines.listen((line) {
      final m = RegExp(r'\[download\]\s+(\d+(?:\.\d+)?)%').firstMatch(line);
      if (m != null) {
        final pct = double.tryParse(m.group(1)!);
        if (pct != null) setState(() => _progress = pct / 100.0);
      }
      if (line.contains('has already been downloaded')) {
        setState(() => _progress = 1.0);
      }
    }));

    subs.add(stderrLines.listen((line) {
      // yt-dlp warns on stderr; show the latest message as status
      _setStatus(line);
    }));

    final code = await _ytDlpProc!.exitCode;
    for (final s in subs) {
      await s.cancel();
    }
    _ytDlpProc = null;

    if (code == 0) {
      setState(() {
        _progress = 1.0;
      });
      return true;
    }
    throw 'yt-dlp exited with code $code';
  }

  void _cancel() {
    // cancel any youtube_explode stream listener if you kept it
    _sub?.cancel();
    _sub = null;

    // kill yt-dlp if running
    if (_ytDlpProc != null) {
      // Try graceful, then force if needed
      _ytDlpProc!.kill(ProcessSignal.sigint);
      // If it ignores SIGINT on Windows, fallback to kill:
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_ytDlpProc != null) {
          _ytDlpProc!.kill(ProcessSignal.sigkill);
        }
      });
    }

    setState(() {
      _ytDlpProc = null;
      _busy = false;
      _progress = 0.0;
      _status = 'Canceled.';
    });
  }

  void _setStatus(String s) => setState(() => _status = s);

  @override
  Widget build(BuildContext context) {
    final canDownload =
        !_busy && (_targetDir != null) && _urlCtrl.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('YouTube Audio Downloader (Windows)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _urlCtrl,
              decoration: const InputDecoration(
                labelText: 'YouTube URL',
                hintText: 'https://www.youtube.com/watch?v=...',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: Text(_targetDir ?? 'No target folder chosen',
                      overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                  onPressed: _busy ? null : _pickDirectory,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Choose Folder')),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: Text(_ytDlpPath,
                      overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              ElevatedButton.icon(
                  onPressed: canDownload ? _download : null,
                  icon: const Icon(Icons.download),
                  label: const Text('Download audio')),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                  onPressed: _busy ? _cancel : null,
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel')),
            ]),
            const SizedBox(height: 16),
            if (_busy || _progress > 0) ...[
              LinearProgressIndicator(value: _progress.clamp(0.0, 1.0)),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(_busy
                    ? 'Progress: ${(_progress * 100).toStringAsFixed(1)} %'
                    : _status),
              ),
            ] else
              Align(alignment: Alignment.centerLeft, child: Text(_status)),
            const Spacer(),
            const Divider(),
            const Text(
              'Primary: youtube_explode_dart (no API key).\nFallback: yt-dlp (external exe) for maximum reliability.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

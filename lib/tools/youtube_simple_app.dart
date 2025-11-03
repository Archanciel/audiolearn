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

/// If app runs on Windows, Linux or MacOS, set the app size and position.
Future<void> setWindowsAppSizeAndPosition({
  required bool isTest,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await getScreenList().then((List<Screen> screens) {
      final Screen screen = screens.first;
      final Rect screenRect = screen.visibleFrame;

      double windowWidth = (isTest) ? 900 : 730;
      const double windowHeight = 1300;

      final double posX = screenRect.right - windowWidth + 10;
      final double posY = (screenRect.height - windowHeight) / 2;

      final Rect windowRect = Rect.fromLTWH(posX, posY, windowWidth, windowHeight);
      setWindowFrame(windowRect);

      // Optional: avoid too-small windows breaking layout
      setWindowMinSize(const Size(600, 300));
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

  // Keep a handle on the external process so Cancel can kill it
  Process? _ytDlpProc;

  String? _targetDir;

  // Your preferred hard-coded location (kept), but we also provide a PATH fallback.
  final String _hardcodedYtDlp = r'c:\YtDlp\yt-dlp.exe';

  double _progress = 0.0;
  bool _busy = false;
  String _status = 'Idle';
  String? _lastOutputPath; // final destination path from yt-dlp logs

  // (Only relevant if you keep a youtube_explode stream – left for completeness)
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

  // -------- Utilities --------

  void _setStatus(String s) => setState(() => _status = s);

  String? _findYtDlpExe() {
    // 1) Your hardcoded path
    if (File(_hardcodedYtDlp).existsSync()) return _hardcodedYtDlp;

    // 2) PATH lookup
    final envPath = Platform.environment['PATH'] ?? '';
    for (final part in envPath.split(Platform.isWindows ? ';' : ':')) {
      final exe = p.join(part.trim(), Platform.isWindows ? 'yt-dlp.exe' : 'yt-dlp');
      if (File(exe).existsSync()) return exe;
    }

    // 3) Working directory
    final localExe = p.join(Directory.current.path, Platform.isWindows ? 'yt-dlp.exe' : 'yt-dlp');
    if (File(localExe).existsSync()) return localExe;

    return null;
  }

  Future<bool> _isFfmpegAvailable() async {
    try {
      final res = await Process.run(Platform.isWindows ? 'ffmpeg.exe' : 'ffmpeg', ['-version']);
      return res.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  Future<void> _killProcessHard(Process p) async {
    try {
      // Try graceful stop first
      p.kill(ProcessSignal.sigint);
      await Future.delayed(const Duration(milliseconds: 250));

      // If still running, force kill (Windows-friendly)
      if (Platform.isWindows) {
        // /T kills child processes as well, /F is force
        await Process.run('taskkill', ['/PID', p.pid.toString(), '/T', '/F']);
      } else {
        p.kill(ProcessSignal.sigkill);
      }
    } catch (_) {
      // If anything fails, we just ignore – process will end or user can retry
    }
  }

  // -------- Main flow --------

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

    // Ensure FFmpeg exists for MP3 conversion
    if (!await _isFfmpegAvailable()) {
      _setStatus('FFmpeg not found: place ffmpeg.exe next to yt-dlp.exe or add it to PATH.');
      return;
    }

    setState(() {
      _busy = true;
      _progress = 0.0;
      _status = 'Preparing…';
      _lastOutputPath = null;
    });

    try {
      final ok = await _downloadWithYtDlp(url);
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
    final exe = _findYtDlpExe();
    if (exe == null) throw 'yt-dlp not found in c:\\YtDlp, PATH, or working directory.';

    // Always create MP3 (uses FFmpeg for post-processing)
    final outTpl = p.join(_targetDir!, '%(title).150s.%(ext)s');

    final args = [
      '--yes-playlist',               // supports both single video or playlist URL
      '-f', 'bestaudio/best',
      '--extract-audio',
      '--audio-format', 'mp3',
      '--audio-quality', '0',         // best
      '-o', outTpl,
      '--restrict-filenames',
      '--newline',
      url,
    ];

    _setStatus('Downloading and converting to MP3…');
    setState(() => _progress = 0.0);

    _ytDlpProc = await Process.start(exe, args, runInShell: true);

    final stdoutLines = _ytDlpProc!.stdout.transform(utf8.decoder).transform(const LineSplitter());
    final stderrLines = _ytDlpProc!.stderr.transform(utf8.decoder).transform(const LineSplitter());

    final subs = <StreamSubscription>[];

    subs.add(stdoutLines.listen((line) {
      // 1) Progress during the download phase
      final m = RegExp(r'\[download\]\s+(\d+(?:\.\d+)?)%').firstMatch(line);
      if (m != null) {
        final pct = double.tryParse(m.group(1)!);
        if (pct != null) setState(() => _progress = pct / 100.0);
      }

      // 2) Destination path capture
      final destMatch = RegExp(r'Destination:\s(.+)$').firstMatch(line);
      if (destMatch != null) {
        _lastOutputPath = destMatch.group(1);
      }

      // 3) Post-processing status (extraction/conversion)
      if (line.contains('[ExtractAudio]') || line.contains('[ffmpeg]')) {
        _setStatus('Converting to MP3…');
      }

      // 4) Already downloaded case
      if (line.contains('has already been downloaded')) {
        setState(() => _progress = 1.0);
        _setStatus('File already present; verifying/processing…');
      }
    }));

    subs.add(stderrLines.listen((line) {
      // yt-dlp often writes warnings/info to stderr – show the latest as status
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
    _sub?.cancel();
    _sub = null;

    final p = _ytDlpProc;
    _ytDlpProc = null;
    if (p != null) {
      _killProcessHard(p);
    }

    setState(() {
      _busy = false;
      _progress = 0.0;
      _status = 'Canceled.';
    });
  }

  // -------- UI --------

  @override
  Widget build(BuildContext context) {
    final canDownload = !_busy && (_targetDir != null) && _urlCtrl.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('YouTube Audio Downloader (Windows)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _urlCtrl,
              decoration: const InputDecoration(
                labelText: 'YouTube URL (video or playlist)',
                hintText: 'https://www.youtube.com/watch?v=...  or playlist URL',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 12),

            Row(children: [
              Expanded(
                child: Text(_targetDir ?? 'No target folder chosen',
                  overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _busy ? null : _pickDirectory,
                icon: const Icon(Icons.folder_open),
                label: const Text('Choose Folder'),
              ),
            ]),

            const SizedBox(height: 12),

            Row(children: [
              Expanded(
                child: Text(
                  _findYtDlpExe() ?? '(yt-dlp not found yet)',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),

            const SizedBox(height: 16),

            Row(children: [
              ElevatedButton.icon(
                onPressed: canDownload ? _download : null,
                icon: const Icon(Icons.download),
                label: const Text('Download audio'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _busy ? _cancel : null,
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel'),
              ),
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

            const SizedBox(height: 8),

            if (_lastOutputPath != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Saved to: ${_lastOutputPath!}',
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    try {
                      final dir = File(_lastOutputPath!).parent.path;
                      if (Platform.isWindows) {
                        Process.run('explorer', [dir]);
                      } else if (Platform.isMacOS) {
                        Process.run('open', [dir]);
                      } else if (Platform.isLinux) {
                        Process.run('xdg-open', [dir]);
                      }
                    } catch (_) {
                      // no-op
                    }
                  },
                  icon: const Icon(Icons.folder),
                  label: const Text('Open folder'),
                ),
              ),
            ],

            const Spacer(),
            const Divider(),
            const Text(
              'Downloads with yt-dlp and converts to MP3 via FFmpeg.\n'
              'No YouTube API key required.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

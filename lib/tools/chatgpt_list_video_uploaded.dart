import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';

void main() {
  setWindowsAppSizeAndPosition(isTest: true);
  runApp(const MyApp());
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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Video List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VideoListScreen(),
    );
  }
}

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  final String apiKey = 'AIzaSyDhywmh5EKopsNsaszzMkLJ719aQa2NHBw';
  final String channelId = 'UCP4LykxRItz7-jcvICUOvDg';
  // final String channelId = 'UCElH9qAoRv-jCRU9RYMLZEQ';
  final int maxResults = 200;
  List videos = [];

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    final String playlistId = await fetchUploadsPlaylistId();
    String nextPageToken = '';
    List fetchedVideos = [];

    do {
      final response = await http.get(
        Uri.parse(
            'https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=$playlistId&maxResults=50&pageToken=$nextPageToken&key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        fetchedVideos.addAll(data['items']);
        nextPageToken = data['nextPageToken'] ?? '';
      } else {
        throw Exception('Failed to load videos');
      }
    } while (nextPageToken.isNotEmpty);

    setState(() {
      videos = fetchedVideos;
    });
  }

  Future<String> fetchUploadsPlaylistId() async {
    final response = await http.get(
      Uri.parse(
          'https://www.googleapis.com/youtube/v3/channels?part=contentDetails&id=$channelId&key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['items'][0]['contentDetails']['relatedPlaylists']['uploads'];
    } else {
      throw Exception('Failed to load playlist ID');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Videos'),
      ),
      body: videos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index]['snippet'];
                final url =
                    'https://www.youtube.com/watch?v=${video['resourceId']['videoId']}';
                // ignore: avoid_print
                print(url);
                return ListTile(
                  title: Text("${index + 1}: ${video['title']}"),
                  subtitle: Text(video['resourceId']['videoId']),
                  onTap: () {
                    // ignore: deprecated_member_use
                    launch(url);
                  },
                );
              },
            ),
    );
  }
}
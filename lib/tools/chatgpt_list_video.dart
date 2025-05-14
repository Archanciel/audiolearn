import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

import '../constants.dart';

class YoutubeService {
  final String apiKey = kGoogleApiKey; // Replace with your API key
  final String channelId = 'UCP4LykxRItz7-jcvICUOvDg';
  final String channelId_2 = 'UCElH9qAoRv-jCRU9RYMLZEQ';
  final int maxResults = 200;

  Future<List<String>> fetchVideoLinks() async {
    final url =
        'https://www.googleapis.com/youtube/v3/search?key=$apiKey&channelId=$channelId&part=snippet,id&order=date&maxResults=$maxResults';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final videoUrls = <String>[];

      for (var item in jsonResponse['items']) {
        if (item['id']['kind'] == 'youtube#video') {
          videoUrls
              .add('https://www.youtube.com/watch?v=${item['id']['videoId']}');
        }
      }
      return videoUrls;
    } else {
      throw Exception('Failed to load video links');
    }
  }
}

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
      title: 'YouTube Video Links',
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
  late Future<List<String>> futureVideoLinks;

  @override
  void initState() {
    super.initState();
    futureVideoLinks = YoutubeService().fetchVideoLinks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Video Links'),
      ),
      body: FutureBuilder<List<String>>(
        future: futureVideoLinks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No video links found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Video ${index + 1}'),
                  subtitle: Text(snapshot.data![index]),
                  onTap: () {
                    // Handle tap to open the link
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart'; // Import file_picker package
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';

// How to get the channel id is documented in Evernote !
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
  final String apiKey = kGoogleApiKey;
  final String channelId = 'UCP4LykxRItz7-jcvICUOvDg';
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

  Future<void> saveUrlsToFile() async {
    List<String> urls = videos.map((video) {
      return 'https://www.youtube.com/watch?v=${video['snippet']['resourceId']['videoId']}';
    }).toList();

    // Open file picker to select directory
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save URLs to text file',
      fileName: 'youtube_urls.txt',
    );

    if (outputFile != null) {
      // Write URLs to the selected file
      final file = File(outputFile);
      await file.writeAsString(urls.join('\n'));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File saved at: $outputFile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "YouTube Video URL's",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: kSliderThumbColorInLightMode,
          ),
        ),
        actions: [
          TextButton(
            onPressed: saveUrlsToFile,
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  side: const BorderSide(
                    color: kSliderThumbColorInLightMode,
                  ),
                ),
              ),
            ),
            child: const Text(
              "Save URL's to file",
            ), // Save URL list to file
          ),
          const SizedBox(
            width: 100.0,
          ),
        ],
      ),
      body: videos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index]['snippet'];
                final url =
                    'https://www.youtube.com/watch?v=${video['resourceId']['videoId']}';
                return ListTile(
                  title: Text("${index + 1}: ${video['title']}",
                      style: const TextStyle(
                        color: kSliderThumbColorInLightMode,
                      )),
                  subtitle: Text(video['resourceId']['videoId']),
                  onTap: () {
                    launchUrl(Uri.parse(url));
                  },
                );
              },
            ),
    );
  }
}

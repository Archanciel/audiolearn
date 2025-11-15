import 'dart:io';

import 'package:audiolearn/viewmodels/comment_vm.dart';
import 'package:audiolearn/viewmodels/date_format_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_size/window_size.dart';

import 'constants.dart';
import 'services/settings_data_service.dart';
import 'utils/dir_util.dart';
import 'views/my_home_page.dart';
import 'views/screen_mixin.dart';
import 'viewmodels/picture_vm.dart';
import 'viewmodels/playlist_list_vm.dart';
import 'viewmodels/audio_download_vm.dart';
import 'viewmodels/audio_player_vm.dart';
import 'viewmodels/language_provider_vm.dart';
import 'viewmodels/text_to_speech_vm.dart';
import 'viewmodels/theme_provider_vm.dart';
import 'viewmodels/warning_message_vm.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter bindings are initialized.

  bool isTest = false; // Must be set to false instead of true before
  //                     generating the Android as well as the Windows
  //                     version of the app so that the app accesses the
  //                     correct application directory and not the test
  //                     directory. Must also be set to false when
  //                     debugging the application on the smartphone.

  // Obtain or create the application directory
  final String applicationPath = DirUtil.getApplicationPath(
    isTest: isTest,
  );

  // Now proceed with setting up the app window size and position if needed
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await _setWindowsAppSizeAndPosition(
      isTest: isTest,
    );
  }

  // We no longer create SettingsDataService here.
  // We let a Flutter widget handle it (BootstrapApp).
  runApp(
    BootstrapApp(
      isTest: isTest,
      applicationPath: applicationPath,
    ),
  );
}

/// If app runs on Windows, Linux or MacOS, set the app size
/// and position.
Future<void> _setWindowsAppSizeAndPosition({
  required bool isTest,
}) async {
  await getScreenList().then((List<Screen> screens) {
    // Assumez que vous voulez utiliser le premier écran (principal)
    final Screen screen = screens.first;
    final Rect screenRect = screen.visibleFrame;

    // Définissez la largeur et la hauteur de votre fenêtre
    double windowWidth = (isTest) ? 900 : 730;
    double windowHeight = (isTest) ? 1700 : 1480;

    // Calculez la position X pour placer la fenêtre sur le côté droit de l'écran
    final double posX = screenRect.right - windowWidth + 10;
    // Optionnellement, ajustez la position Y selon vos préférences
    final double posY = (screenRect.height - windowHeight) / 2;

    final Rect windowRect =
        Rect.fromLTWH(posX, posY, windowWidth, windowHeight);
    setWindowFrame(windowRect);
  });
}

/// Small bootstrap widget that initializes SettingsDataService
/// (SharedPreferences + reading the JSON file) BEFORE constructing MainApp.
class BootstrapApp extends StatelessWidget {
  final bool isTest;
  final String applicationPath;

  const BootstrapApp({
    super.key,
    required this.isTest,
    required this.applicationPath,
  });

  Future<SettingsDataService> _initSettings() async {
    final sharedPreferences = await SharedPreferences.getInstance();

    final settingsDataService = SettingsDataService(
      sharedPreferences: sharedPreferences,
      isTest: isTest,
    );

    await settingsDataService.loadSettingsFromFile(
      settingsJsonPathFileName:
          '$applicationPath${Platform.pathSeparator}$kSettingsFileName',
    );

    return settingsDataService;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SettingsDataService>(
      future: _initSettings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // Petit écran de chargement au tout début
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          // En cas de problème de lecture des préférences ou du fichier
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                    'Error while initializing settings: ${snapshot.error}'),
              ),
            ),
          );
        }

        return MainApp(
          settingsDataService: snapshot.data!,
        );
      },
    );
  }
}

/// MainApp reste identique (j’ai seulement remonté ses imports plus haut).
class MainApp extends StatelessWidget with ScreenMixin {
  final SettingsDataService _settingsDataService;

  MainApp({
    required SettingsDataService settingsDataService,
    super.key,
  }) : _settingsDataService = settingsDataService;

  @override
  Widget build(BuildContext context) {
    final WarningMessageVM warningMessageVM = WarningMessageVM();

    final AudioDownloadVM audioDownloadVM = AudioDownloadVM(
      warningMessageVM: warningMessageVM,
      settingsDataService: _settingsDataService,
    );

    final CommentVM commentVM = CommentVM();

    final PictureVM pictureVM = PictureVM(
      settingsDataService: _settingsDataService,
    );

    final TextToSpeechVM textToSpeechVM = TextToSpeechVM();

    final PlaylistListVM playlistListVM = PlaylistListVM(
      warningMessageVM: warningMessageVM,
      audioDownloadVM: audioDownloadVM,
      commentVM: commentVM,
      pictureVM: pictureVM,
      settingsDataService: _settingsDataService,
    );

    final AudioPlayerVM audioPlayerVM = AudioPlayerVM(
      settingsDataService: _settingsDataService,
      playlistListVM: playlistListVM,
      commentVM: commentVM,
    );

    // globalAudioPlayerVM is defined in ScreenMixin
    globalAudioPlayerVM = audioPlayerVM;

    // calling getUpToDateSelectablePlaylists() loads all the
    // playlist json files from the app dir and so enables
    // playlistListVM to know which playlists are
    // selected and which are not
    playlistListVM.getUpToDateSelectablePlaylists();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => audioDownloadVM),
        ChangeNotifierProvider(
          create: (_) => audioPlayerVM,
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProviderVM(
            appSettings: _settingsDataService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LanguageProviderVM(
            settingsDataService: _settingsDataService,
          ),
        ),
        ChangeNotifierProvider(create: (_) => playlistListVM),
        ChangeNotifierProvider(create: (_) => warningMessageVM),
        ChangeNotifierProvider(create: (_) => commentVM),
        ChangeNotifierProvider(
            create: (_) => DateFormatVM(
                  settingsDataService: _settingsDataService,
                )),
        ChangeNotifierProvider(create: (_) => pictureVM),
        ChangeNotifierProvider(create: (_) => textToSpeechVM),
      ],
      child: Consumer2<ThemeProviderVM, LanguageProviderVM>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            title: 'Audio Learn',
            locale: languageProvider.currentLocale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: themeProvider.currentTheme == AppTheme.dark
                ? ScreenMixin.themeDataDark
                : ScreenMixin.themeDataLight,
            home: MyHomePage(
              settingsDataService: _settingsDataService,
            ),
          );
        },
      ),
    );
  }
}

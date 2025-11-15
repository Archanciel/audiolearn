import 'dart:io';
import 'dart:ui';

import 'package:audiolearn/viewmodels/playlist_list_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volume_controller/volume_controller.dart';
import 'widgets/appbar_left_popup_menu.dart';
import 'widgets/appbar_right_popup_menu.dart';
import 'widgets/appbar_title_for_audio_player_view.dart';
import '../l10n/app_localizations.dart';

import '../constants.dart';
import '../models/sort_filter_parameters.dart';
import '../viewmodels/audio_player_vm.dart';
import '../viewmodels/theme_provider_vm.dart';
import '../services/settings_data_service.dart';
import '../services/permission_requester_service.dart';
import '../views/screen_mixin.dart';
import '../views/playlist_download_view.dart';
import '../views/audio_player_view.dart';
import '../views/widgets/appbar_title_for_playlist_download_view.dart';

/// Before enclosing Scaffold in MyHomePage, this exception was
/// thrown:
///
/// Exception has occurred.
/// _CastError (Null check operator used on a null value)
///
/// if the AppBar title is obtained that way:
///
///            home: Scaffold(
///              appBar: AppBar(
///                title: Text(AppLocalizations.of(context)!.title),
///
/// The issue occurs because the context provided to the
/// AppLocalizations.of(context) is not yet aware of the
/// localization configuration, as it's being accessed within
/// the same MaterialApp widget where you define the localization
/// delegates and the locale.
///
/// To fix this issue, you can wrap your Scaffold in a new widget,
/// like MyHomePage, which will have access to the correct context.

const Duration pageTransitionDuration = Duration(milliseconds: 20);
const Curve pageTransitionCurve = Curves.ease;

class MyHomePage extends StatefulWidget {
  final SettingsDataService settingsDataService;

  const MyHomePage({
    super.key,
    required this.settingsDataService,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with ScreenMixin {
  int _currentIndex = 0;

  // _pageController is the PageView controller
  final PageController _pageController = PageController();

  final List<IconData> _screenNavigationIconLst = [
    Icons.download,
    Icons.audiotrack,
    // Icons.edit,
  ];

  final List<AudioLearnAppViewType> _audioLearnAppViewTypeLst = [
    AudioLearnAppViewType.playlistDownloadView,
    AudioLearnAppViewType.audioPlayerView,
    // AudioLearnAppViewType.audioExtractorView,
  ];

  final List<Key> _screenNavigationIconButtonKeyLst = [
    const Key('playlistDownloadViewIconButton'),
    const Key('audioPlayerViewIconButton'),
    // const Key('audioExtractorIconButton'),
  ];

  // contains a list of widgets which build the AppBar title. Each
  // widget is specific to the screen currently displayed. This list
  // is filled in the initState() method.
  final List<Widget> _appBarTitleWidgetLst = [];

  // contains the list of screens displayable on the application home
  // page. This list is filled in the initState() method.
  final List<StatefulWidget> _screenWidgetLst = [];

  // Windows volume management instance variables

  AppLifecycleListener? _lifecycleListener;
  double _originalVolume = 0.06;
  VolumeController? _volumeController;

  @override
  void initState() {
    super.initState();

    // Asking permissions if needed once the app was launched
    _requestPermissionsIfNeeded();

    _appBarTitleWidgetLst
      ..add(
        AppBarTitleForPlaylistDownloadView(),
      )
      ..add(
        const AppBarTitleForAudioPlayerView(),
      );
    // ..add(AppBarTitleForAudioExtractorView());

    _screenWidgetLst
      ..add(PlaylistDownloadView(
        settingsDataService: widget.settingsDataService,
        onPageChangedFunction: changePage,
      ))
      ..add(AudioPlayerView(
        settingsDataService: widget.settingsDataService,
      ));
    // ..add(const AudioExtractorView());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Platform.isWindows && !widget.settingsDataService.isTest) {
        _volumeController = VolumeController.instance;
        _originalVolume = await _volumeController!.getVolume();
        _volumeController!.setVolume(kWindowsSystemVolume);

        _lifecycleListener = AppLifecycleListener(
          onExitRequested: () async {
            await _restoreOriginalVolume();
            return AppExitResponse.exit;
          },
        );
      }
    });
  }

  @override
  void dispose() {
    if (_lifecycleListener != null) {
      // If the lifecycle listener is not null, dispose it
      // to avoid memory leaks.
      _lifecycleListener!.dispose();
    }

    super.dispose();
  }

  Future<void> _requestPermissionsIfNeeded() async {
    if (!Platform.isAndroid) {
      // Les permissions gérées par permission_handler ne concernent
      // que l’Android dans votre cas actuel.
      return;
    }

    try {
      await PermissionRequesterService.requestMultiplePermissions();
    } catch (e) {
      // Éviter un crash en cas de problème inattendu
      debugPrint('Error while requesting permissions: $e');
    }
  }

  Future<void> _restoreOriginalVolume() async {
    if (Platform.isWindows && _volumeController != null) {
      await _volumeController!.setVolume(_originalVolume);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Creating a default sort filter parameters which will be
    // applied for sorting the playlists audio if no other
    // sort filter parameters are defined and applied.
    widget.settingsDataService.addOrReplaceNamedAudioSortFilterParameters(
      audioSortFilterParametersName:
          AppLocalizations.of(context)!.sortFilterParametersDefaultName,
      audioSortFilterParameters:
          AudioSortFilterParameters.createDefaultAudioSortFilterParameters(),
    );
    final ThemeProviderVM themeProviderVMlistenTrue =
        Provider.of<ThemeProviderVM>(
      context,
      listen: true,
    );
    final AudioPlayerVM audioPlayerVMlistenFalse = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );

    // This list is used to display the application action icons
    // located in in the AppBar after the AppBar title. The
    // content of the list is the same for all displayable screens
    // since it enables to select the light or dark theme and to
    // select the app language.
    List<Widget> appBarApplicationActionLst = [
      IconButton(
        onPressed: () {
          themeProviderVMlistenTrue.toggleTheme();
        },
        icon: Icon(themeProviderVMlistenTrue.currentTheme == AppTheme.dark
            ? Icons.light_mode
            : Icons.dark_mode),
      ),
      AppBarRightPopupMenu(themeProvider: themeProviderVMlistenTrue),
    ];

    return Scaffold(
      appBar: AppBar(
        title: _appBarTitleWidgetLst[_currentIndex],
        leading: AppBarLeftPopupMenuWidget(
            key: const Key('appBarLeadingPopupMenuWidget'),
            audioLearnAppViewType: _audioLearnAppViewTypeLst[_currentIndex],
            themeProvider: themeProviderVMlistenTrue,
            settingsDataService: widget.settingsDataService),
        actions: appBarApplicationActionLst,
      ),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _buildPageView(_screenWidgetLst[_currentIndex]),
          _buildBottomScreenIconButtonRow(
            themeProvider: themeProviderVMlistenTrue,
            audioPlayerVMlistenedFalse: audioPlayerVMlistenFalse,
          ),
        ],
      ),
    );
  }

  /// This method builds the PageView widget which enables to drag
  /// to the PlaylistDownloadView, AudioPlayerView and AudioExtractorView
  /// screens.
  Expanded _buildPageView(StatefulWidget screenWidget) {
    return Expanded(
      // PageView enables changing screen by dragging
      child: PageView.builder(
        itemCount:
            _screenNavigationIconLst.length, // specifies the number of pages
        //                           that can be swiped by dragging left or right
        controller: _pageController,
        onPageChanged: onPageChangedFunction,
        itemBuilder: (context, index) {
          return screenWidget;
        },
      ),
    );
  }

  /// This method builds the row of icon buttons located at the bottom
  /// of the application. Each icon enables to drag to a specific screen:
  /// PlaylistDownloadView, AudioPlayerView and AudioExtractorView.
  Row _buildBottomScreenIconButtonRow({
    required ThemeProviderVM themeProvider,
    required AudioPlayerVM audioPlayerVMlistenedFalse,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _screenNavigationIconLst.asMap().entries.map((entry) {
        return IconButton(
          key: _screenNavigationIconButtonKeyLst[entry.key],
          icon: IconTheme(
            data: _currentIndex == entry.key
                ? getIconThemeData(
                    themeProviderVM: themeProvider,
                    iconType: MultipleIconType.iconOne,
                  )
                : getIconThemeData(
                    themeProviderVM: themeProvider,
                    iconType: MultipleIconType.iconTwo,
                  ),
            child: Icon(entry.value),
          ),
          onPressed: () async {
            await changePage(entry.key);
          },
          padding: EdgeInsets
              .zero, // This is crucial to avoid default IconButton padding
        );
      }).toList(),
    );
  }

  /// This function causes PageView to drag to the screen
  /// associated to the passed index.
  Future<void> changePage(int index) async {
    await onPageChangedFunction(index);

    // _pageController is the PageView controller
    if (_pageController.hasClients) {
      // Using if (_pageController.hasClients) ensures that the PageController
      // is in a valid state before attempting to perform operations on it,
      // which can help to avoid errors and makes the code more robust.
      await _pageController.animateToPage(
        index,
        duration: pageTransitionDuration, // Use constant
        curve: pageTransitionCurve, // Use constant
      );
    }
  }

  /// This function is passed as the onPageChanged: parameter
  /// of the PageView builder. The function is called each time
  /// the PageView drag to another screen.
  Future<void> onPageChangedFunction(int index) async {
    switch (index) {
      case ScreenMixin.PLAYLIST_DOWNLOAD_VIEW_DRAGGABLE_INDEX:
        PlaylistListVM playlistListVMlistenFalse = Provider.of<PlaylistListVM>(
          context,
          listen: false,
        );
        playlistListVMlistenFalse.backToPlaylistDownloadView();
        break;
      case ScreenMixin.AUDIO_PLAYER_VIEW_DRAGGABLE_INDEX:
        PlaylistListVM playlistListVMlistenFalse = Provider.of<PlaylistListVM>(
          context,
          listen: false,
        );

        if (playlistListVMlistenFalse.isSearchButtonEnabled) {
          // Necessary to disable the search button and clear the search
          // sentence when dragging to the AudioPlayerView screen.
          playlistListVMlistenFalse.disableSearchSentence();
        }

        // dragging to the AudioPlayerView screen requires to set
        // the current audio defined on the currently selected playlist.
        await globalAudioPlayerVM.setCurrentAudioFromSelectedPlaylist();
        break;
      default:
        break;
    }

    setState(() {
      _currentIndex = index;
    });
  }
}

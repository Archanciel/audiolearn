import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// The page title displayed in the appbar.
  ///
  /// In en, this message translates to:
  /// **'Download Audio'**
  String get appBarTitleDownloadAudio;

  /// No description provided for @downloadAudioScreen.
  ///
  /// In en, this message translates to:
  /// **'Download Audio screen'**
  String get downloadAudioScreen;

  /// No description provided for @appBarTitleAudioPlayer.
  ///
  /// In en, this message translates to:
  /// **'Play Audio'**
  String get appBarTitleAudioPlayer;

  /// No description provided for @audioPlayerScreen.
  ///
  /// In en, this message translates to:
  /// **'Play Audio screen'**
  String get audioPlayerScreen;

  /// No description provided for @toggleList.
  ///
  /// In en, this message translates to:
  /// **'Toggle List'**
  String get toggleList;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @moveItemUp.
  ///
  /// In en, this message translates to:
  /// **'Move item up'**
  String get moveItemUp;

  /// No description provided for @moveItemDown.
  ///
  /// In en, this message translates to:
  /// **'Move item down'**
  String get moveItemDown;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @downloadAudio.
  ///
  /// In en, this message translates to:
  /// **'Download Audio Youtube'**
  String get downloadAudio;

  /// Appbar language selection menu item.
  ///
  /// In en, this message translates to:
  /// **'Select {language}'**
  String translate(String language);

  /// No description provided for @musicalQualityTooltip.
  ///
  /// In en, this message translates to:
  /// **'For Youtube playlist, if set, downloads at musical quality. For local playlist, if set, indicates that the playlist is at music quality.'**
  String get musicalQualityTooltip;

  /// No description provided for @ofPreposition.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofPreposition;

  /// No description provided for @atPreposition.
  ///
  /// In en, this message translates to:
  /// **'at'**
  String get atPreposition;

  /// No description provided for @ytPlaylistLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Youtube Link or Search'**
  String get ytPlaylistLinkLabel;

  /// No description provided for @ytPlaylistLinkHintText.
  ///
  /// In en, this message translates to:
  /// **'Enter Youtube link or sentence'**
  String get ytPlaylistLinkHintText;

  /// No description provided for @addPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addPlaylist;

  /// No description provided for @downloadSingleVideoAudio.
  ///
  /// In en, this message translates to:
  /// **'One'**
  String get downloadSingleVideoAudio;

  /// No description provided for @downloadSelectedPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get downloadSelectedPlaylist;

  /// No description provided for @stopDownload.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopDownload;

  /// No description provided for @audioDownloadingStopping.
  ///
  /// In en, this message translates to:
  /// **'Stopping download ...'**
  String get audioDownloadingStopping;

  /// No description provided for @audioDownloadError.
  ///
  /// In en, this message translates to:
  /// **'Error downloading audio: {error}'**
  String audioDownloadError(Object error);

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About ...'**
  String get about;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help ...'**
  String get help;

  /// No description provided for @defineSortFilterAudiosMenu.
  ///
  /// In en, this message translates to:
  /// **'Sort/Filter Audio ...'**
  String get defineSortFilterAudiosMenu;

  /// No description provided for @clearSortFilterAudiosParmsHistoryMenu.
  ///
  /// In en, this message translates to:
  /// **'Clear Sort/Filter Parameters History'**
  String get clearSortFilterAudiosParmsHistoryMenu;

  /// No description provided for @saveSortFilterAudiosOptionsToPlaylistMenu.
  ///
  /// In en, this message translates to:
  /// **'Save Sort/Filter Parameters to Playlist ...'**
  String get saveSortFilterAudiosOptionsToPlaylistMenu;

  /// No description provided for @sortFilterDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort and Filter Parms'**
  String get sortFilterDialogTitle;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by:'**
  String get sortBy;

  /// No description provided for @audioDownloadDate.
  ///
  /// In en, this message translates to:
  /// **'Audio downl date'**
  String get audioDownloadDate;

  /// No description provided for @videoUploadDate.
  ///
  /// In en, this message translates to:
  /// **'Video upload date'**
  String get videoUploadDate;

  /// No description provided for @audioEnclosingPlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio playlist title'**
  String get audioEnclosingPlaylistTitle;

  /// No description provided for @audioDuration.
  ///
  /// In en, this message translates to:
  /// **'Audio duration'**
  String get audioDuration;

  /// No description provided for @audioRemainingDuration.
  ///
  /// In en, this message translates to:
  /// **'Audio listenable remaining duration'**
  String get audioRemainingDuration;

  /// No description provided for @audioFileSize.
  ///
  /// In en, this message translates to:
  /// **'Audio file size'**
  String get audioFileSize;

  /// No description provided for @audioMusicQuality.
  ///
  /// In en, this message translates to:
  /// **'Music qual.'**
  String get audioMusicQuality;

  /// No description provided for @audioSpokenQuality.
  ///
  /// In en, this message translates to:
  /// **'Spoken q.'**
  String get audioSpokenQuality;

  /// No description provided for @audioDownloadSpeed.
  ///
  /// In en, this message translates to:
  /// **'Audio downl speed'**
  String get audioDownloadSpeed;

  /// No description provided for @audioDownloadDuration.
  ///
  /// In en, this message translates to:
  /// **'Audio downl duration'**
  String get audioDownloadDuration;

  /// No description provided for @sortAscending.
  ///
  /// In en, this message translates to:
  /// **'Asc'**
  String get sortAscending;

  /// No description provided for @sortDescending.
  ///
  /// In en, this message translates to:
  /// **'Desc'**
  String get sortDescending;

  /// No description provided for @filterSentences.
  ///
  /// In en, this message translates to:
  /// **'Filter words:'**
  String get filterSentences;

  /// No description provided for @filterOptions.
  ///
  /// In en, this message translates to:
  /// **'Filter options:'**
  String get filterOptions;

  /// No description provided for @videoTitleOrDescription.
  ///
  /// In en, this message translates to:
  /// **'Video title (word or sentence)'**
  String get videoTitleOrDescription;

  /// No description provided for @startDownloadDate.
  ///
  /// In en, this message translates to:
  /// **'Start downl date'**
  String get startDownloadDate;

  /// No description provided for @endDownloadDate.
  ///
  /// In en, this message translates to:
  /// **'End downl date'**
  String get endDownloadDate;

  /// No description provided for @startUploadDate.
  ///
  /// In en, this message translates to:
  /// **'Start upl date'**
  String get startUploadDate;

  /// No description provided for @endUploadDate.
  ///
  /// In en, this message translates to:
  /// **'End upl date'**
  String get endUploadDate;

  /// No description provided for @fileSizeRange.
  ///
  /// In en, this message translates to:
  /// **'File size range (MB)'**
  String get fileSizeRange;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @audioDurationRange.
  ///
  /// In en, this message translates to:
  /// **'Audio duration range (hh:mm)'**
  String get audioDurationRange;

  /// No description provided for @openYoutubeVideo.
  ///
  /// In en, this message translates to:
  /// **'Open Youtube Video'**
  String get openYoutubeVideo;

  /// No description provided for @openYoutubePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Open Youtube Playlist'**
  String get openYoutubePlaylist;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @deleteAudio.
  ///
  /// In en, this message translates to:
  /// **'Delete Audio ...'**
  String get deleteAudio;

  /// No description provided for @deleteAudioFromPlaylistAswell.
  ///
  /// In en, this message translates to:
  /// **'Delete Audio from Playlist as well ...'**
  String get deleteAudioFromPlaylistAswell;

  /// No description provided for @deleteAudioFromPlaylistAswellWarning.
  ///
  /// In en, this message translates to:
  /// **'If the deleted audio \"{audioTitle}\" remains in the \"{playlistTitle}\" playlist located on Youtube, it will be downloaded again the next time you download the playlist !'**
  String deleteAudioFromPlaylistAswellWarning(
      Object audioTitle, Object playlistTitle);

  /// No description provided for @deleteMultipleAudiosFromPlaylistAswellWarning.
  ///
  /// In en, this message translates to:
  /// **'If the deleted audios remain in the \"{playlistTitle}\" playlist located on Youtube, they will be downloaded again the next time you download the playlist !'**
  String deleteMultipleAudiosFromPlaylistAswellWarning(Object playlistTitle);

  /// No description provided for @warningDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'WARNING'**
  String get warningDialogTitle;

  /// Warning announcing that the playlist url was updated.
  ///
  /// In en, this message translates to:
  /// **'Youtube playlist \"{title}\" URL was updated. The playlist can be downloaded with its new URL.'**
  String updatedPlaylistUrlTitle(Object title);

  /// Warning announcing that the playlist was added at the end of the playlist list
  ///
  /// In en, this message translates to:
  /// **'Youtube playlist \"{title}\" of {quality} quality added at the end of the playlist list.'**
  String addYoutubePlaylistTitle(Object title, Object quality);

  /// Warning announcing that the playlist was added with a corrected title at the end of the playlist list
  ///
  /// In en, this message translates to:
  /// **'Youtube playlist \"{originalTitle}\" of {quality} quality added with corrected title \"{correctedTitle}\" at the end of the playlist list.'**
  String addCorrectedYoutubePlaylistTitle(
      Object originalTitle, Object quality, Object correctedTitle);

  /// Warning announcing that the playlist was added at the end of the playlist list.
  ///
  /// In en, this message translates to:
  /// **'Local playlist \"{title}\" of {quality} quality added at the end of the playlist list.'**
  String addLocalPlaylistTitle(Object title, Object quality);

  /// Warning announcing that the playlist with invalid URL was not added.
  ///
  /// In en, this message translates to:
  /// **'Playlist with invalid URL \"{url}\" neither added nor modified.'**
  String invalidPlaylistUrl(Object url);

  /// Warning announcing that the playlist with invalid URL was not added.
  ///
  /// In en, this message translates to:
  /// **'The file name \"{fileName}\" already exists in the same directory and cannot be used.'**
  String renameFileNameAlreadyUsed(Object fileName);

  /// Warning announcing that the playlist with the URL is already in the playlist list.
  ///
  /// In en, this message translates to:
  /// **'Playlist \"{title}\" with this URL \"{url}\" is already in the playlist list and so won\'t be recreated.'**
  String playlistWithUrlAlreadyInListOfPlaylists(Object url, Object title);

  /// Warning announcing that the local playlist with the title is already in the playlist list and so will not be created.
  ///
  /// In en, this message translates to:
  /// **'Local playlist \"{title}\" already exists in the playlist list. Therefore, the local playlist with this title won\'t be created.'**
  String localPlaylistWithTitleAlreadyInListOfPlaylists(Object title);

  /// Warning announcing that the Youtube playlist with the title is already in the playlist list and so will not be created.
  ///
  /// In en, this message translates to:
  /// **'Youtube playlist \"{title}\" already exists in the playlist list. Therefore, the local playlist with this title won\'t be created.'**
  String youtubePlaylistWithTitleAlreadyInListOfPlaylists(Object title);

  /// Warning announcing that downloading the audios from Youtube failed.
  ///
  /// In en, this message translates to:
  /// **'Downloading the audio of the video \"{videoTitle}\" from Youtube FAILED: \"{exceptionMessage}\".'**
  String downloadAudioYoutubeError(Object videoTitle, Object exceptionMessage);

  /// Warning announcing that downloading the audios from Youtube failed.
  ///
  /// In en, this message translates to:
  /// **'Error downloading audio from Youtube: \"{exceptionMessage}\".'**
  String downloadAudioYoutubeErrorExceptionMessageOnly(Object exceptionMessage);

  /// Warning announcing that downloading the audio from Youtube failed due to presence of this audio in the playlist.
  ///
  /// In en, this message translates to:
  /// **'Error downloading audio from Youtube. The playlist \"{playlistTitle}\" contains a live video which causes the playlist audio downloading failure. To solve the problem, after having downloaded the audio of the live video as explained below, remove the live video from the playlist, then restart the application and retry.\n\nThe live video URL contains the following string: \"{liveVideoString}\". In order to add the live video audio to the playlist \"{playlistTitle}\", download it separately as single video download adding it to the playlist \"{playlistTitle}\".'**
  String downloadAudioYoutubeErrorDueToLiveVideoInPlaylist(
      Object playlistTitle, Object liveVideoString);

  /// Warning announcing that the audio file is already in the target playlist directory.
  ///
  /// In en, this message translates to:
  /// **'Audio \"{audioValidVideoTitle}\" is contained in file \"{fileName}\" present in the target playlist \"{playlistTitle}\" directory and so won\'t be redownloaded.'**
  String downloadAudioFileAlreadyOnAudioDirectory(
      Object audioValidVideoTitle, Object fileName, Object playlistTitle);

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No Internet. Please connect your device and retry.'**
  String get noInternet;

  /// Warning announcing that the single video with invalid URL was not downloaded.
  ///
  /// In en, this message translates to:
  /// **'The URL \"{url}\" supposed to point to a unique video is invalid. Therefore, no video has been downloaded.'**
  String invalidSingleVideoUUrl(Object url);

  /// No description provided for @copyYoutubeVideoUrl.
  ///
  /// In en, this message translates to:
  /// **'Copy Youtube Video URL'**
  String get copyYoutubeVideoUrl;

  /// No description provided for @displayAudioInfo.
  ///
  /// In en, this message translates to:
  /// **'Audio Information ...'**
  String get displayAudioInfo;

  /// No description provided for @renameAudioFile.
  ///
  /// In en, this message translates to:
  /// **'Rename Audio File ...'**
  String get renameAudioFile;

  /// No description provided for @moveAudioToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Move Audio to Playlist ...'**
  String get moveAudioToPlaylist;

  /// No description provided for @copyAudioToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Copy Audio to Playlist ...'**
  String get copyAudioToPlaylist;

  /// No description provided for @audioInfoDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloaded Audio Info'**
  String get audioInfoDialogTitle;

  /// No description provided for @youtubeChannelLabel.
  ///
  /// In en, this message translates to:
  /// **'Youtube channel'**
  String get youtubeChannelLabel;

  /// No description provided for @originalVideoTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Original video title'**
  String get originalVideoTitleLabel;

  /// No description provided for @validVideoTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Valid video title'**
  String get validVideoTitleLabel;

  /// No description provided for @videoUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Video URL'**
  String get videoUrlLabel;

  /// No description provided for @audioDownloadDateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio downl date time'**
  String get audioDownloadDateTimeLabel;

  /// No description provided for @audioDownloadDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio downl duration'**
  String get audioDownloadDurationLabel;

  /// No description provided for @audioDownloadSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio downl speed'**
  String get audioDownloadSpeedLabel;

  /// No description provided for @videoUploadDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Video upload date'**
  String get videoUploadDateLabel;

  /// No description provided for @audioDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio duration'**
  String get audioDurationLabel;

  /// No description provided for @audioFileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio file name'**
  String get audioFileNameLabel;

  /// No description provided for @audioFileSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio file size'**
  String get audioFileSizeLabel;

  /// No description provided for @isMusicQualityLabel.
  ///
  /// In en, this message translates to:
  /// **'Is music quality'**
  String get isMusicQualityLabel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @octetShort.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get octetShort;

  /// No description provided for @infiniteBytesPerSecond.
  ///
  /// In en, this message translates to:
  /// **'infinite B/sec'**
  String get infiniteBytesPerSecond;

  /// No description provided for @updatePlaylistJsonFilesMenu.
  ///
  /// In en, this message translates to:
  /// **'Update Playlist JSON Files ...'**
  String get updatePlaylistJsonFilesMenu;

  /// No description provided for @compactVideoDescription.
  ///
  /// In en, this message translates to:
  /// **'Compact video description'**
  String get compactVideoDescription;

  /// No description provided for @ignoreCase.
  ///
  /// In en, this message translates to:
  /// **'Ignore case'**
  String get ignoreCase;

  /// No description provided for @searchInVideoCompactDescription.
  ///
  /// In en, this message translates to:
  /// **'Include description'**
  String get searchInVideoCompactDescription;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get on;

  /// No description provided for @copyYoutubePlaylistUrl.
  ///
  /// In en, this message translates to:
  /// **'Copy Youtube Playlist URL'**
  String get copyYoutubePlaylistUrl;

  /// No description provided for @displayPlaylistInfo.
  ///
  /// In en, this message translates to:
  /// **'Playlist Information ...'**
  String get displayPlaylistInfo;

  /// No description provided for @playlistInfoDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlist Information'**
  String get playlistInfoDialogTitle;

  /// No description provided for @playlistTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Playlist title'**
  String get playlistTitleLabel;

  /// No description provided for @playlistIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Playlist ID'**
  String get playlistIdLabel;

  /// No description provided for @playlistUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Playlist URL'**
  String get playlistUrlLabel;

  /// No description provided for @playlistDownloadPathLabel.
  ///
  /// In en, this message translates to:
  /// **'Playlist path'**
  String get playlistDownloadPathLabel;

  /// No description provided for @playlistLastDownloadDateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Playlist last downl date time'**
  String get playlistLastDownloadDateTimeLabel;

  /// No description provided for @playlistIsSelectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Playlist is selected'**
  String get playlistIsSelectedLabel;

  /// No description provided for @playlistTotalAudioNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Playlist total audios'**
  String get playlistTotalAudioNumberLabel;

  /// No description provided for @playlistPlayableAudioNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Playable audios'**
  String get playlistPlayableAudioNumberLabel;

  /// No description provided for @playlistPlayableAudioTotalDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Playable audios total duration'**
  String get playlistPlayableAudioTotalDurationLabel;

  /// No description provided for @playlistPlayableAudioTotalRemainingDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Playable audios total remaining duration'**
  String get playlistPlayableAudioTotalRemainingDurationLabel;

  /// No description provided for @playlistPlayableAudioTotalSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Playable audios total file size'**
  String get playlistPlayableAudioTotalSizeLabel;

  /// No description provided for @updatePlaylistPlayableAudioList.
  ///
  /// In en, this message translates to:
  /// **'Update playable Audios List'**
  String get updatePlaylistPlayableAudioList;

  /// No description provided for @updatedPlayableAudioLst.
  ///
  /// In en, this message translates to:
  /// **'Playable audio list for playlist \"{title}\" was updated. {number} audio(s) were removed.'**
  String updatedPlayableAudioLst(Object number, Object title);

  /// No description provided for @addYoutubePlaylistDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Youtube Playlist'**
  String get addYoutubePlaylistDialogTitle;

  /// No description provided for @addLocalPlaylistDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Local Playlist'**
  String get addLocalPlaylistDialogTitle;

  /// No description provided for @renameAudioFileDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Audio File'**
  String get renameAudioFileDialogTitle;

  /// No description provided for @renameAudioFileDialogComment.
  ///
  /// In en, this message translates to:
  /// **''**
  String get renameAudioFileDialogComment;

  /// No description provided for @renameAudioFileLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get renameAudioFileLabel;

  /// No description provided for @renameAudioFileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Renaming the audio file also renames the audio comment file and the picture audio file if they exist'**
  String get renameAudioFileTooltip;

  /// No description provided for @renameAudioFileButton.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameAudioFileButton;

  /// No description provided for @modifyAudioTitleDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Modify Audio Title'**
  String get modifyAudioTitleDialogTitle;

  /// No description provided for @modifyAudioTitleTooltip.
  ///
  /// In en, this message translates to:
  /// **''**
  String get modifyAudioTitleTooltip;

  /// No description provided for @modifyAudioTitleDialogComment.
  ///
  /// In en, this message translates to:
  /// **'Modify the audio title to allow adjusting its playback order.'**
  String get modifyAudioTitleDialogComment;

  /// No description provided for @modifyAudioTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get modifyAudioTitleLabel;

  /// No description provided for @modifyAudioTitleButton.
  ///
  /// In en, this message translates to:
  /// **'Modify'**
  String get modifyAudioTitleButton;

  /// No description provided for @youtubePlaylistUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Youtube playlist URL'**
  String get youtubePlaylistUrlLabel;

  /// No description provided for @localPlaylistTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Local playlist title'**
  String get localPlaylistTitleLabel;

  /// No description provided for @playlistTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Playlist type'**
  String get playlistTypeLabel;

  /// No description provided for @playlistTypeYoutube.
  ///
  /// In en, this message translates to:
  /// **'Youtube'**
  String get playlistTypeYoutube;

  /// No description provided for @playlistTypeLocal.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get playlistTypeLocal;

  /// No description provided for @playlistQualityLabel.
  ///
  /// In en, this message translates to:
  /// **'Playlist quality'**
  String get playlistQualityLabel;

  /// No description provided for @playlistQualityMusic.
  ///
  /// In en, this message translates to:
  /// **'musical'**
  String get playlistQualityMusic;

  /// No description provided for @playlistQualityAudio.
  ///
  /// In en, this message translates to:
  /// **'spoken'**
  String get playlistQualityAudio;

  /// No description provided for @audioQualityHighSnackBarMessage.
  ///
  /// In en, this message translates to:
  /// **'Download at music quality'**
  String get audioQualityHighSnackBarMessage;

  /// No description provided for @audioQualityLowSnackBarMessage.
  ///
  /// In en, this message translates to:
  /// **'Download at audio quality'**
  String get audioQualityLowSnackBarMessage;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @noSortFilterSaveAsNameWarning.
  ///
  /// In en, this message translates to:
  /// **'No sort/filter save as name defined. Please enter a name and retry ...'**
  String get noSortFilterSaveAsNameWarning;

  /// No description provided for @noPlaylistSelectedForSingleVideoDownloadWarning.
  ///
  /// In en, this message translates to:
  /// **'No playlist selected for single video download. Select one playlist and retry ...'**
  String get noPlaylistSelectedForSingleVideoDownloadWarning;

  /// No description provided for @noPlaylistSelectedForAudioCopyWarning.
  ///
  /// In en, this message translates to:
  /// **'No playlist selected for copying audio. Select one playlist and retry ...'**
  String get noPlaylistSelectedForAudioCopyWarning;

  /// No description provided for @noPlaylistSelectedForAudioMoveWarning.
  ///
  /// In en, this message translates to:
  /// **'No playlist selected for moving audio. Select one playlist and retry ...'**
  String get noPlaylistSelectedForAudioMoveWarning;

  /// No description provided for @tooManyPlaylistSelectedForSingleVideoDownloadWarning.
  ///
  /// In en, this message translates to:
  /// **'More than one playlist selected for single video download. Select only one playlist and retry ...'**
  String get tooManyPlaylistSelectedForSingleVideoDownloadWarning;

  /// No description provided for @noSortFilterParameterWasModifiedWarning.
  ///
  /// In en, this message translates to:
  /// **'No sort/filter parameter was modified. Please set a sort/filter parameter and retry ...'**
  String get noSortFilterParameterWasModifiedWarning;

  /// No description provided for @deletedSortFilterParameterNotExistWarning.
  ///
  /// In en, this message translates to:
  /// **'The sort/filter parameter you try to delete does not exist. Please define an existing sort/filter parameter and retry ...'**
  String get deletedSortFilterParameterNotExistWarning;

  /// No description provided for @historicalSortFilterParameterWasDeletedWarning.
  ///
  /// In en, this message translates to:
  /// **'The historical sort/filter parameter was deleted.'**
  String get historicalSortFilterParameterWasDeletedWarning;

  /// No description provided for @allHistoricalSortFilterParameterWereDeletedWarning.
  ///
  /// In en, this message translates to:
  /// **'All historical sort/filter parameters were deleted.'**
  String get allHistoricalSortFilterParameterWereDeletedWarning;

  /// No description provided for @allHistoricalSortFilterParametersDeleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Deleting all historical sort/filter parameters.'**
  String get allHistoricalSortFilterParametersDeleteConfirmation;

  /// No description provided for @playlistRootPathNotExistWarning.
  ///
  /// In en, this message translates to:
  /// **'The defined path \"{playlistRootPath}\" does not exist. Please enter a valid playlist root path and retry ...'**
  String playlistRootPathNotExistWarning(Object playlistRootPath);

  /// No description provided for @confirmDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'CONFIRMATION'**
  String get confirmDialogTitle;

  /// No description provided for @confirmSingleVideoAudioPlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm target playlist \"{title}\" for downloading single video audio in spoken quality.'**
  String confirmSingleVideoAudioPlaylistTitle(Object title);

  /// No description provided for @confirmSingleVideoAudioAtMusicQualityPlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm target playlist \"{title}\" for downloading single video audio in high-quality music format.'**
  String confirmSingleVideoAudioAtMusicQualityPlaylistTitle(Object title);

  /// No description provided for @playlistJsonFileSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'JSON file size'**
  String get playlistJsonFileSizeLabel;

  /// No description provided for @playlistOneSelectedDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a Playlist'**
  String get playlistOneSelectedDialogTitle;

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @enclosingPlaylistLabel.
  ///
  /// In en, this message translates to:
  /// **'Enclosing playlist'**
  String get enclosingPlaylistLabel;

  /// Not moved warning
  ///
  /// In en, this message translates to:
  /// **'Audio \"{audioTitle}\" NOT moved from local playlist \"{fromPlaylistTitle}\" to local playlist \"{toPlaylistTitle}\" {notCopiedOrMovedReason}.'**
  String audioNotMovedFromLocalPlaylistToLocalPlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle);

  /// Not moved warning
  ///
  /// In en, this message translates to:
  /// **'Audio \"{audioTitle}\" NOT moved from local playlist \"{fromPlaylistTitle}\" to Youtube playlist \"{toPlaylistTitle}\" {notCopiedOrMovedReason}.'**
  String audioNotMovedFromLocalPlaylistToYoutubePlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle);

  /// Not moved warning
  ///
  /// In en, this message translates to:
  /// **'Audio \"{audioTitle}\" NOT moved from Youtube playlist \"{fromPlaylistTitle}\" to local playlist \"{toPlaylistTitle}\" {notCopiedOrMovedReason}.'**
  String audioNotMovedFromYoutubePlaylistToLocalPlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle);

  /// Not moved warning
  ///
  /// In en, this message translates to:
  /// **'Audio \"{audioTitle}\" NOT moved from Youtube playlist \"{fromPlaylistTitle}\" to Youtube playlist \"{toPlaylistTitle}\" {notCopiedOrMovedReason}.'**
  String audioNotMovedFromYoutubePlaylistToYoutubePlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle);

  /// Not moved warning
  ///
  /// In en, this message translates to:
  /// **'Audio \"{audioTitle}\" NOT copied from local playlist \"{fromPlaylistTitle}\" to local playlist \"{toPlaylistTitle}\" {notCopiedOrMovedReason}.'**
  String audioNotCopiedFromLocalPlaylistToLocalPlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle);

  /// Not moved warning
  ///
  /// In en, this message translates to:
  /// **'Audio \"{audioTitle}\" NOT copied from local playlist \"{fromPlaylistTitle}\" to Youtube playlist \"{toPlaylistTitle}\" {notCopiedOrMovedReason}.'**
  String audioNotCopiedFromLocalPlaylistToYoutubePlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle);

  /// Not moved warning
  ///
  /// In en, this message translates to:
  /// **'Audio \"{audioTitle}\" NOT copied from Youtube playlist \"{fromPlaylistTitle}\" to local playlist \"{toPlaylistTitle}\" {notCopiedOrMovedReason}.'**
  String audioNotCopiedFromYoutubePlaylistToLocalPlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle);

  /// Not moved warning
  ///
  /// In en, this message translates to:
  /// **'Audio \"{audioTitle}\" NOT copied from Youtube playlist \"{fromPlaylistTitle}\" to Youtube playlist \"{toPlaylistTitle}\" {notCopiedOrMovedReason}.'**
  String audioNotCopiedFromYoutubePlaylistToYoutubePlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle);

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author:'**
  String get author;

  /// No description provided for @authorName.
  ///
  /// In en, this message translates to:
  /// **'Jean-Pierre Schnyder / Switzerland'**
  String get authorName;

  /// No description provided for @aboutAppDescription.
  ///
  /// In en, this message translates to:
  /// **'AudioLearn allows you to download audio from videos included in Youtube playlists whose links are added to the application, or from individual Youtube videos using their URLs.\n\nYou can also import audio files, such as audiobooks, directly into the application or convert text into audio. This feature is particularly useful for listening to written prayers found on the Internet.\n\nIn addition to listening the audio files, AudioLearn offers the ability to add timestamped comments to each file, making it easier to replay their most interesting parts.\n\nIt is also possible to extract the parts marked by comments into a new MP3 file, which can then be shared by email or via WhatsApp, or added to an existing playlist.\n\nFinally, the app allows you to sort and filter audio files based on various criteria in order to select the listenable audios.'**
  String get aboutAppDescription;

  /// No description provided for @keepAudioEntryInSourcePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Keep audio data in source playlist'**
  String get keepAudioEntryInSourcePlaylist;

  /// No description provided for @keepAudioEntryInSourcePlaylistTooltip.
  ///
  /// In en, this message translates to:
  /// **'Keep audio data in the original playlist\'s JSON file even after transferring the audio file to another playlist. This prevents re-downloading the audio file if it no longer exists in its original directory.'**
  String get keepAudioEntryInSourcePlaylistTooltip;

  /// No description provided for @movedFromPlaylistLabel.
  ///
  /// In en, this message translates to:
  /// **'Moved from playlist'**
  String get movedFromPlaylistLabel;

  /// No description provided for @movedToPlaylistLabel.
  ///
  /// In en, this message translates to:
  /// **'Moved to playlist'**
  String get movedToPlaylistLabel;

  /// No description provided for @downloadSingleVideoButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Download single video audio.\n\nTo download a single video audio, enter its URL in the \"Youtube Link\" field and click the One button. You then have to select the playlist to which the audio will be added.'**
  String get downloadSingleVideoButtonTooltip;

  /// No description provided for @addPlaylistButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add a Youtube or local playlist.\n\nTo add a Youtube playlist, enter its URL in the \"Youtube Link\" field and click the Add button. IMPORTANT: for a Youtube playlist to be downloaded by the app, its privacy setting must not be \"Private\" but \"Unlisted\" or \"Public\".\n\nTo set up a local playlist, click the Add button while the \"Youtube Link\" field is empty.'**
  String get addPlaylistButtonTooltip;

  /// No description provided for @stopDownloadingButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Stop downloading ...'**
  String get stopDownloadingButtonTooltip;

  /// No description provided for @clearPlaylistUrlOrSearchButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear \"Youtube link or sentence\" field.'**
  String get clearPlaylistUrlOrSearchButtonTooltip;

  /// No description provided for @playlistToggleButtonInPlaylistDownloadViewTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show/hide playlists.'**
  String get playlistToggleButtonInPlaylistDownloadViewTooltip;

  /// No description provided for @downloadSelPlaylistsButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Download audios of the selected playlist.'**
  String get downloadSelPlaylistsButtonTooltip;

  /// No description provided for @audioOneSelectedDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select an Audio'**
  String get audioOneSelectedDialogTitle;

  /// No description provided for @audioPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio position'**
  String get audioPositionLabel;

  /// No description provided for @audioStateLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio state'**
  String get audioStateLabel;

  /// No description provided for @audioStatePaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get audioStatePaused;

  /// No description provided for @audioStatePlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get audioStatePlaying;

  /// No description provided for @audioStateTerminated.
  ///
  /// In en, this message translates to:
  /// **'Terminated'**
  String get audioStateTerminated;

  /// No description provided for @audioStateNotListened.
  ///
  /// In en, this message translates to:
  /// **'Not listened'**
  String get audioStateNotListened;

  /// No description provided for @audioPausedDateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Last listened date/time'**
  String get audioPausedDateTimeLabel;

  /// No description provided for @audioPlaySpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Play speed'**
  String get audioPlaySpeedLabel;

  /// No description provided for @playlistAudioPlaySpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio play speed'**
  String get playlistAudioPlaySpeedLabel;

  /// No description provided for @audioPlayVolumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Sound volume'**
  String get audioPlayVolumeLabel;

  /// No description provided for @copiedFromPlaylistLabel.
  ///
  /// In en, this message translates to:
  /// **'Copied from playlist'**
  String get copiedFromPlaylistLabel;

  /// No description provided for @copiedToPlaylistLabel.
  ///
  /// In en, this message translates to:
  /// **'Copied to playlist'**
  String get copiedToPlaylistLabel;

  /// No description provided for @audioPlayerViewNoCurrentAudio.
  ///
  /// In en, this message translates to:
  /// **'No audio selected'**
  String get audioPlayerViewNoCurrentAudio;

  /// No description provided for @deletePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Delete Playlist ...'**
  String get deletePlaylist;

  /// No description provided for @deleteYoutubePlaylistDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Youtube Playlist \"{title}\"'**
  String deleteYoutubePlaylistDialogTitle(Object title);

  /// No description provided for @deleteLocalPlaylistDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Local Playlist \"{title}\"'**
  String deleteLocalPlaylistDialogTitle(Object title);

  /// Confirm message for deleting the playlist
  ///
  /// In en, this message translates to:
  /// **'Deleting the playlist and its {audioNumber} audios, {audioCommentsNumber} audio comment(s), {audioPicturesNumber} audio picture(s) as well as its JSON file and its directory.'**
  String deletePlaylistDialogComment(Object audioNumber,
      Object audioCommentsNumber, Object audioPicturesNumber);

  /// No description provided for @appBarTitleAudioExtractor.
  ///
  /// In en, this message translates to:
  /// **'Extract Audio'**
  String get appBarTitleAudioExtractor;

  /// No description provided for @setAudioPlaySpeedDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Playback Speed'**
  String get setAudioPlaySpeedDialogTitle;

  /// No description provided for @setAudioPlaySpeedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Set audios play speed.'**
  String get setAudioPlaySpeedTooltip;

  /// No description provided for @exclude.
  ///
  /// In en, this message translates to:
  /// **'Exclude '**
  String get exclude;

  /// No description provided for @fullyPlayed.
  ///
  /// In en, this message translates to:
  /// **'fully played '**
  String get fullyPlayed;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'audio'**
  String get audio;

  /// No description provided for @increaseAudioVolumeIconButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Increase the audio volume (currently {percentValue}). Disabled when maximum volume is reached.'**
  String increaseAudioVolumeIconButtonTooltip(Object percentValue);

  /// No description provided for @decreaseAudioVolumeIconButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Decrease the audio volume (currently {percentValue}). Disabled when minimum volume is reached.'**
  String decreaseAudioVolumeIconButtonTooltip(Object percentValue);

  /// No description provided for @resetSortFilterOptionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reset the sort and filter parameters.'**
  String get resetSortFilterOptionsTooltip;

  /// No description provided for @clickToSetAscendingOrDescendingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Click to set ascending or descending sort order.'**
  String get clickToSetAscendingOrDescendingTooltip;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @videoTitleSearchSentenceTextFieldTooltip.
  ///
  /// In en, this message translates to:
  /// **'Enter a word or a sentence to be selected in the video title and in the Youtube channel if \'înclude Youtube channel\' is checked and in the video description if \'Include description\' is checked. THEN, CLICK ON THE \'+\' BUTTON.'**
  String get videoTitleSearchSentenceTextFieldTooltip;

  /// No description provided for @andSentencesTooltip.
  ///
  /// In en, this message translates to:
  /// **'If set, only audio containing all the listed words or sentences are selected.'**
  String get andSentencesTooltip;

  /// No description provided for @orSentencesTooltip.
  ///
  /// In en, this message translates to:
  /// **'If set, audio containing one of the listed words or sentences are selected.'**
  String get orSentencesTooltip;

  /// No description provided for @searchInVideoCompactDescriptionTooltip.
  ///
  /// In en, this message translates to:
  /// **'If set, search words or sentences are searched on video description as well.'**
  String get searchInVideoCompactDescriptionTooltip;

  /// No description provided for @fullyListened.
  ///
  /// In en, this message translates to:
  /// **'Fully listened'**
  String get fullyListened;

  /// No description provided for @partiallyListened.
  ///
  /// In en, this message translates to:
  /// **'Partially listened'**
  String get partiallyListened;

  /// No description provided for @notListened.
  ///
  /// In en, this message translates to:
  /// **'Not listened'**
  String get notListened;

  /// No description provided for @saveSortFilterOptionsToPlaylistDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Sort/Filter \"{sortFilterParmsName}\"'**
  String saveSortFilterOptionsToPlaylistDialogTitle(Object sortFilterParmsName);

  /// No description provided for @saveSortFilterOptionsToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'To playlist \"{title}\"'**
  String saveSortFilterOptionsToPlaylist(Object title);

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @errorInPlaylistJsonFile.
  ///
  /// In en, this message translates to:
  /// **'File \"{filePathName}\" contains an invalid data definition. Try finding the problem in order to correct it before executing again the operation.'**
  String errorInPlaylistJsonFile(Object filePathName);

  /// No description provided for @updatePlaylistJsonFilesMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'If one or several playlist directories containing or not audios were manually added or deleted in the application directory containing the playlists or if audios were manually deleted from one or several playlist directories, this functionality updates the playlist JSON files as well as the JSON file containing the application settings in order to reflect the changes in the application screens. Playlist directories located on PC can as well be copied in the Android application directory containing the playlists. Additionally, playlist directories located on Android can as well be copied in the PC application directory containing the playlists ...'**
  String get updatePlaylistJsonFilesMenuTooltip;

  /// No description provided for @updatePlaylistPlayableAudioListTooltip.
  ///
  /// In en, this message translates to:
  /// **'If audios were manually deleted from the playlist directory, this functionality updates the playlist JSON file to reflect the changes in the application screen.'**
  String get updatePlaylistPlayableAudioListTooltip;

  /// No description provided for @audioPlayedInThisOrderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Audio are played in this order. By default, the last downloaded audios are at bottom of the list.'**
  String get audioPlayedInThisOrderTooltip;

  /// No description provided for @playableAudioDialogSortDescriptionTooltipBottomDownloadBefore.
  ///
  /// In en, this message translates to:
  /// **'Audio at bottom were downloaded before those at top.'**
  String get playableAudioDialogSortDescriptionTooltipBottomDownloadBefore;

  /// No description provided for @playableAudioDialogSortDescriptionTooltipBottomDownloadAfter.
  ///
  /// In en, this message translates to:
  /// **'Audio at the bottom were downloaded after those at the top.'**
  String get playableAudioDialogSortDescriptionTooltipBottomDownloadAfter;

  /// No description provided for @playableAudioDialogSortDescriptionTooltipBottomUploadBefore.
  ///
  /// In en, this message translates to:
  /// **'Videos at the bottom were uploaded before those at the top.'**
  String get playableAudioDialogSortDescriptionTooltipBottomUploadBefore;

  /// No description provided for @playableAudioDialogSortDescriptionTooltipBottomUploadAfter.
  ///
  /// In en, this message translates to:
  /// **'Videos at the bottom were uploaded after those at the top.'**
  String get playableAudioDialogSortDescriptionTooltipBottomUploadAfter;

  /// No description provided for @playableAudioDialogSortDescriptionTooltipTopDurationBigger.
  ///
  /// In en, this message translates to:
  /// **'Audio at the top have a longer duration than those at the bottom.'**
  String get playableAudioDialogSortDescriptionTooltipTopDurationBigger;

  /// No description provided for @playableAudioDialogSortDescriptionTooltipTopDurationSmaller.
  ///
  /// In en, this message translates to:
  /// **'Audio at the top have a shorter duration than those at the bottom.'**
  String get playableAudioDialogSortDescriptionTooltipTopDurationSmaller;

  /// No description provided for @playableAudioDialogSortDescriptionTooltipTopRemainingDurationBigger.
  ///
  /// In en, this message translates to:
  /// **'Audio at the top have more remaining listenable duration than those at the bottom.'**
  String
      get playableAudioDialogSortDescriptionTooltipTopRemainingDurationBigger;

  /// No description provided for @playableAudioDialogSortDescriptionTooltipTopRemainingDurationSmaller.
  ///
  /// In en, this message translates to:
  /// **'Audio at the top have less remaining listenable duration than those at the bottom.'**
  String
      get playableAudioDialogSortDescriptionTooltipTopRemainingDurationSmaller;

  /// No description provided for @playableAudioDialogSortDescriptionTooltipTopLastListenedDateTimeBigger.
  ///
  /// In en, this message translates to:
  /// **'Audio at the top were listened more recently than those at the bottom.'**
  String
      get playableAudioDialogSortDescriptionTooltipTopLastListenedDateTimeBigger;

  /// No description provided for @playableAudioDialogSortDescriptionTooltipTopLastListenedDateTimeSmaller.
  ///
  /// In en, this message translates to:
  /// **'Audio at the top were listened less recently than those at the bottom.'**
  String
      get playableAudioDialogSortDescriptionTooltipTopLastListenedDateTimeSmaller;

  /// No description provided for @saveAs.
  ///
  /// In en, this message translates to:
  /// **'Save as:'**
  String get saveAs;

  /// No description provided for @sortFilterSaveAsTextFieldTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save the sort/filter settings with the specified name. Existing settings with the same name will be updated.'**
  String get sortFilterSaveAsTextFieldTooltip;

  /// No description provided for @applySortFilterToView.
  ///
  /// In en, this message translates to:
  /// **'Apply sort/filter to:'**
  String get applySortFilterToView;

  /// No description provided for @applySortFilterToViewTooltip.
  ///
  /// In en, this message translates to:
  /// **'Selecting sort/filter application to one or two audio views. This will be applied to the playlists to which this sort/filter is associated.'**
  String get applySortFilterToViewTooltip;

  /// No description provided for @saveSortFilterOptionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Update existing sort/filter parameters with modified parameters if the name already exists.'**
  String get saveSortFilterOptionsTooltip;

  /// No description provided for @applyButton.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyButton;

  /// No description provided for @applySortFilterOptionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Apply the sort/filter parameters and add them to the sort/filter history if the name is empty.'**
  String get applySortFilterOptionsTooltip;

  /// No description provided for @deleteSortFilterOptionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'After deletion, the Default sort/filter parameters will be applied if these settings are in use.'**
  String get deleteSortFilterOptionsTooltip;

  /// No description provided for @deleteShort.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteShort;

  /// No description provided for @sortFilterParametersDefaultName.
  ///
  /// In en, this message translates to:
  /// **'default'**
  String get sortFilterParametersDefaultName;

  /// No description provided for @sortFilterParametersDownloadButtonHint.
  ///
  /// In en, this message translates to:
  /// **'Sel sort/filter'**
  String get sortFilterParametersDownloadButtonHint;

  /// No description provided for @appBarMenuOpenSettingsDialog.
  ///
  /// In en, this message translates to:
  /// **'Application Settings ...'**
  String get appBarMenuOpenSettingsDialog;

  /// No description provided for @appSettingsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Settings'**
  String get appSettingsDialogTitle;

  /// No description provided for @setAudioPlaySpeed.
  ///
  /// In en, this message translates to:
  /// **'Set Audios Play Speed ...'**
  String get setAudioPlaySpeed;

  /// No description provided for @applyToAlreadyDownloadedAudio.
  ///
  /// In en, this message translates to:
  /// **'Apply to already downloaded,\nimported or converted audios'**
  String get applyToAlreadyDownloadedAudio;

  /// No description provided for @applyToAlreadyDownloadedAudioTooltip.
  ///
  /// In en, this message translates to:
  /// **'Apply the playback speed to audios in all existing playlists. If not set, apply it only to newly added playlists.'**
  String get applyToAlreadyDownloadedAudioTooltip;

  /// No description provided for @applyToAlreadyDownloadedAudioOfCurrentPlaylistTooltip.
  ///
  /// In en, this message translates to:
  /// **'Apply the playback speed to audios in the current playlist. If not set, apply it only to newly downloaded, imported or converted audios (converted audios are audios created by converting text to audio).'**
  String get applyToAlreadyDownloadedAudioOfCurrentPlaylistTooltip;

  /// No description provided for @applyToExistingPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Apply to existing playlists'**
  String get applyToExistingPlaylist;

  /// No description provided for @applyToExistingPlaylistTooltip.
  ///
  /// In en, this message translates to:
  /// **'Apply the playback speed to all existing playlists. If not set, apply it only to newly added playlists.'**
  String get applyToExistingPlaylistTooltip;

  /// No description provided for @playlistRootpathLabel.
  ///
  /// In en, this message translates to:
  /// **'Playlists root path'**
  String get playlistRootpathLabel;

  /// No description provided for @closeTextButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeTextButton;

  /// No description provided for @helpDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpDialogTitle;

  /// No description provided for @defaultApplicationHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Default Application'**
  String get defaultApplicationHelpTitle;

  /// No description provided for @defaultApplicationHelpContent.
  ///
  /// In en, this message translates to:
  /// **'If no option is selected, the defined playback speed will only apply to newly created playlists.'**
  String get defaultApplicationHelpContent;

  /// No description provided for @modifyingExistingPlaylistsHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Modifying Existing Playlists'**
  String get modifyingExistingPlaylistsHelpTitle;

  /// No description provided for @modifyingExistingPlaylistsHelpContent.
  ///
  /// In en, this message translates to:
  /// **'By selecting the first checkbox, all existing playlists will be set to use the new playback speed. However, this change will only affect audio files that are downloaded after this option is enabled.'**
  String get modifyingExistingPlaylistsHelpContent;

  /// No description provided for @alreadyDownloadedAudiosHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Already Downloaded or Imported Audio'**
  String get alreadyDownloadedAudiosHelpTitle;

  /// No description provided for @alreadyDownloadedAudiosHelpContent.
  ///
  /// In en, this message translates to:
  /// **'Selecting the second checkbox allows you to change the playback speed for audio files already present on the device.'**
  String get alreadyDownloadedAudiosHelpContent;

  /// No description provided for @excludingFutureDownloadsHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Excluding Future Downloads'**
  String get excludingFutureDownloadsHelpTitle;

  /// No description provided for @excludingFutureDownloadsHelpContent.
  ///
  /// In en, this message translates to:
  /// **'If only the second checkbox is checked, the playback speed will not be modified for audios that will be downloaded later in existing playlists. However, as mentioned previously, new playlists will use the newly defined playback speed for all downloaded audio.'**
  String get excludingFutureDownloadsHelpContent;

  /// No description provided for @alreadyDownloadedAudiosPlaylistHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply to already downloaded or imported Audios'**
  String get alreadyDownloadedAudiosPlaylistHelpTitle;

  /// No description provided for @alreadyDownloadedAudiosPlaylistHelpContent.
  ///
  /// In en, this message translates to:
  /// **'Selecting this checkbox allows you to change the playback speed for the playlist audio files already present on the device.'**
  String get alreadyDownloadedAudiosPlaylistHelpContent;

  /// No description provided for @commentsIconButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show or insert comments at specific points in the audio.'**
  String get commentsIconButtonTooltip;

  /// No description provided for @commentsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsDialogTitle;

  /// No description provided for @playlistCommentsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlist Audio Comments'**
  String get playlistCommentsDialogTitle;

  /// No description provided for @addPositionedCommentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add a comment at the current audio position.'**
  String get addPositionedCommentTooltip;

  /// No description provided for @commentTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get commentTitle;

  /// No description provided for @commentText.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get commentText;

  /// No description provided for @commentDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get commentDialogTitle;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @deleteCommentConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Comment'**
  String get deleteCommentConfirmTitle;

  /// No description provided for @deleteCommentConfirnBody.
  ///
  /// In en, this message translates to:
  /// **'Deleting comment \"{title}\".'**
  String deleteCommentConfirnBody(Object title);

  /// No description provided for @commentMenu.
  ///
  /// In en, this message translates to:
  /// **'Audio Comments ...'**
  String get commentMenu;

  /// No description provided for @tenthOfSecondsCheckboxTooltip.
  ///
  /// In en, this message translates to:
  /// **'Enable this checkbox to specify the comment position with precision up to a tenth of second.'**
  String get tenthOfSecondsCheckboxTooltip;

  /// No description provided for @setCommentPosition.
  ///
  /// In en, this message translates to:
  /// **'Set comment position'**
  String get setCommentPosition;

  /// No description provided for @commentPosition.
  ///
  /// In en, this message translates to:
  /// **'Position (hh:)mm:ss(.t)'**
  String get commentPosition;

  /// No description provided for @commentPositionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clearing the position field and selecting the \"Start\" checkbox will set the comment\'s start position to 0:00. Selecting the \"End\" checkbox will set the comment\'s end position to the total duration of the audio.'**
  String get commentPositionTooltip;

  /// No description provided for @commentPositionExplanation.
  ///
  /// In en, this message translates to:
  /// **'The proposed comment position corresponds to the current audio position. Modify it if needed and select to which position it must be applied. Look in help the usefulness of emptying the position field.'**
  String get commentPositionExplanation;

  /// No description provided for @commentPositionHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Entry Tip'**
  String get commentPositionHelpTitle;

  /// No description provided for @commentPositionHelpContent.
  ///
  /// In en, this message translates to:
  /// **'If you clear the position field and then:\n\n• Check \"Start\" and click \"Ok\", the comment start position will be set to 0:00.\n• Check \"End\" and click \"Ok\", the end position will be set to the total audio duration.\n\nThis avoids manually entering these common values.'**
  String get commentPositionHelpContent;

  /// No description provided for @commentStartPosition.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get commentStartPosition;

  /// No description provided for @commentEndPosition.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get commentEndPosition;

  /// No description provided for @updateCommentStartEndPositionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Update comment start or end position.'**
  String get updateCommentStartEndPositionTooltip;

  /// No description provided for @noCheckboxSelectedWarning.
  ///
  /// In en, this message translates to:
  /// **'No checkbox selected. Please select {atLeast}one checkbox before clicking \'Ok\', or click \'Cancel\' to exit.'**
  String noCheckboxSelectedWarning(Object atLeast);

  /// No description provided for @atLeast.
  ///
  /// In en, this message translates to:
  /// **'at least '**
  String get atLeast;

  /// No description provided for @commentCreationDateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Comment creation date'**
  String get commentCreationDateTooltip;

  /// No description provided for @commentUpdateDateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Comment last update date'**
  String get commentUpdateDateTooltip;

  /// No description provided for @playlistCommentMenu.
  ///
  /// In en, this message translates to:
  /// **'Audio Comments ...'**
  String get playlistCommentMenu;

  /// No description provided for @modifyAudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Modify Audio Title ...'**
  String get modifyAudioTitle;

  /// No description provided for @invalidLocalPlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'The local playlist title \"{playlistTitle}\" can not contain any comma. Please correct the title and retry ...'**
  String invalidLocalPlaylistTitle(Object playlistTitle);

  /// No description provided for @invalidYoutubePlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'The Youtube playlist title \"{playlistTitle}\" can not contain any comma. Please correct the title and retry ...'**
  String invalidYoutubePlaylistTitle(Object playlistTitle);

  /// No description provided for @setValueToTargetWarning.
  ///
  /// In en, this message translates to:
  /// **'The entered value {invalidValueWarningParam} ({maxMinPossibleValue}). Please correct it and retry ...'**
  String setValueToTargetWarning(
      Object invalidValueWarningParam, Object maxMinPossibleValue);

  /// No description provided for @invalidValueTooBig.
  ///
  /// In en, this message translates to:
  /// **'exceeds the maximal value'**
  String get invalidValueTooBig;

  /// No description provided for @invalidValueTooSmall.
  ///
  /// In en, this message translates to:
  /// **'is below the minimal value'**
  String get invalidValueTooSmall;

  /// No description provided for @confirmCommentedAudioDeletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion of the commented audio \"{audioTitle}\"'**
  String confirmCommentedAudioDeletionTitle(Object audioTitle);

  /// No description provided for @confirmCommentedAudioDeletionComment.
  ///
  /// In en, this message translates to:
  /// **'The audio contains {commentNumber} comment(s) which will be deleted as well. Confirm deletion ?'**
  String confirmCommentedAudioDeletionComment(Object commentNumber);

  /// No description provided for @commentStartPositionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Comment start position in audio.'**
  String get commentStartPositionTooltip;

  /// No description provided for @commentEndPositionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Comment end position in audio.'**
  String get commentEndPositionTooltip;

  /// No description provided for @playlistToggleButtonInAudioPlayerViewTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show/hide playlists. Then check a playlist to select its current listened audio.'**
  String get playlistToggleButtonInAudioPlayerViewTooltip;

  /// No description provided for @playlistSelectedSnackBarMessage.
  ///
  /// In en, this message translates to:
  /// **'Playlist \"{title}\" selected'**
  String playlistSelectedSnackBarMessage(Object title);

  /// No description provided for @playlistImportAudioMenu.
  ///
  /// In en, this message translates to:
  /// **'Import Audio File(s) ...'**
  String get playlistImportAudioMenu;

  /// No description provided for @playlistImportAudioMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import MP3 audio file(s) or MP4 video file(s) converted to MP3 audio file(s) into the playlist in order to be able to listen them and add positionned comments and pictures to them.'**
  String get playlistImportAudioMenuTooltip;

  /// No description provided for @setPlaylistAudioPlaySpeedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Set audio play speed for the playlist existing and next downloaded audio.'**
  String get setPlaylistAudioPlaySpeedTooltip;

  /// No description provided for @audioNotImportedToLocalPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Audio(s)\n\n{rejectedImportedAudioFileNames}\n\nNOT imported to local playlist \"{toPlaylistTitle}\" since the playlist directory already contains the audio(s).'**
  String audioNotImportedToLocalPlaylist(
      Object rejectedImportedAudioFileNames, Object toPlaylistTitle);

  /// No description provided for @audioNotImportedToYoutubePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Audio(s)\n\n{rejectedImportedAudioFileNames}\n\nNOT imported to Youtube playlist \"{toPlaylistTitle}\" since the playlist directory already contains the audio(s).'**
  String audioNotImportedToYoutubePlaylist(
      Object rejectedImportedAudioFileNames, Object toPlaylistTitle);

  /// No description provided for @audioImportedToLocalPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Audio(s)\n\n{importedAudioFileNames}\n\nimported to local playlist \"{toPlaylistTitle}\".'**
  String audioImportedToLocalPlaylist(
      Object importedAudioFileNames, Object toPlaylistTitle);

  /// No description provided for @audioImportedToYoutubePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Audio(s)\n\n{importedAudioFileNames}\n\nimported to Youtube playlist \"{toPlaylistTitle}\".'**
  String audioImportedToYoutubePlaylist(
      Object importedAudioFileNames, Object toPlaylistTitle);

  /// No description provided for @imported.
  ///
  /// In en, this message translates to:
  /// **'imported'**
  String get imported;

  /// No description provided for @audioImportedInfoDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Imported Audio Info'**
  String get audioImportedInfoDialogTitle;

  /// No description provided for @audioTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio title'**
  String get audioTitleLabel;

  /// No description provided for @chapterAudioTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio chapter'**
  String get chapterAudioTitleLabel;

  /// No description provided for @importedAudioDateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Imported audio date time'**
  String get importedAudioDateTimeLabel;

  /// No description provided for @sortFilterParametersAppliedName.
  ///
  /// In en, this message translates to:
  /// **'applied'**
  String get sortFilterParametersAppliedName;

  /// No description provided for @lastListenedDateTime.
  ///
  /// In en, this message translates to:
  /// **'Last listened date/time'**
  String get lastListenedDateTime;

  /// No description provided for @downloadSingleVideoAudioAtMusicQuality.
  ///
  /// In en, this message translates to:
  /// **'Download single video audio at music quality'**
  String get downloadSingleVideoAudioAtMusicQuality;

  /// No description provided for @videoTitleNotWrittenInOccidentalLettersWarning.
  ///
  /// In en, this message translates to:
  /// **'Since the original video title is not written in occidental letters, the audio title is empty. You can use the \'Modify audio title ...\' audio menu in order to define a valid title. Same remark for improving the audio file name ...'**
  String get videoTitleNotWrittenInOccidentalLettersWarning;

  /// No description provided for @renameCommentFileNameAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'The comment file name \"{fileName}.json\" already exists in the comment directory and so renaming the audio file with the name \"{fileName}.mp3\" is not possible.'**
  String renameCommentFileNameAlreadyUsed(Object fileName);

  /// No description provided for @renameFileNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'The audio file name \"{fileName}\" has no mp3 extension and so is invalid.'**
  String renameFileNameInvalid(Object fileName);

  /// No description provided for @renameAudioFileConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Audio file \"{oldFileIame}.mp3\" renamed to \"{newFileName}.mp3\".'**
  String renameAudioFileConfirmation(Object newFileName, Object oldFileIame);

  /// No description provided for @renameAudioAndAssociatedFilesConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Audio file \"{oldFileIame}.mp3\" renamed to \"{newFileName}.mp3\" {secondMessagePart}.'**
  String renameAudioAndAssociatedFilesConfirmation(
      Object newFileName, Object oldFileIame, Object secondMessagePart);

  /// No description provided for @secondMessagePartCommentOnly.
  ///
  /// In en, this message translates to:
  /// **'as well as comment file \"{oldFileIame}.json\" renamed to \"{newFileName}.json\"'**
  String secondMessagePartCommentOnly(Object newFileName, Object oldFileIame);

  /// No description provided for @secondMessagePartPictureOnly.
  ///
  /// In en, this message translates to:
  /// **'as well as picture file \"{oldFileIame}.json\" renamed to \"{newFileName}.json\"'**
  String secondMessagePartPictureOnly(Object newFileName, Object oldFileIame);

  /// No description provided for @secondMessagePartCommentAndPicture.
  ///
  /// In en, this message translates to:
  /// **'as well as comment and picture files \"{oldFileIame}.json\" renamed to \"{newFileName}.json\"'**
  String secondMessagePartCommentAndPicture(
      Object newFileName, Object oldFileIame);

  /// No description provided for @forScreen.
  ///
  /// In en, this message translates to:
  /// **'For \"{screenName}\" screen'**
  String forScreen(Object screenName);

  /// No description provided for @downloadVideoUrlsFromTextFileInPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Download URLs from Text File ...'**
  String get downloadVideoUrlsFromTextFileInPlaylist;

  /// No description provided for @downloadVideoUrlsFromTextFileInPlaylistTooltip.
  ///
  /// In en, this message translates to:
  /// **'Download audios to the playlist from video URLs listed in a text file to select. The text file must contain one video URL per line.'**
  String get downloadVideoUrlsFromTextFileInPlaylistTooltip;

  /// No description provided for @downloadAudioFromVideoUrlsInPlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Download video audio to playlist \"{title}\"'**
  String downloadAudioFromVideoUrlsInPlaylistTitle(Object title);

  /// No description provided for @downloadAudioFromVideoUrlsInPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Downloading {number} audios in selected quality.'**
  String downloadAudioFromVideoUrlsInPlaylist(Object number);

  /// No description provided for @notRedownloadAudioFilesInPlaylistDirectory.
  ///
  /// In en, this message translates to:
  /// **'{number} audios are already contained in the target playlist \"{playlistTitle}\" directory and so were not redownloaded.'**
  String notRedownloadAudioFilesInPlaylistDirectory(
      Object number, Object playlistTitle);

  /// No description provided for @clickToSetAscendingOrDescendingPlayingOrderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Click to set ascending or descending playing order.'**
  String get clickToSetAscendingOrDescendingPlayingOrderTooltip;

  /// No description provided for @removeSortFilterAudiosOptionsFromPlaylistMenu.
  ///
  /// In en, this message translates to:
  /// **'Remove Sort/Filter Parameters from Playlist ...'**
  String get removeSortFilterAudiosOptionsFromPlaylistMenu;

  /// No description provided for @removeSortFilterOptionsFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'From playlist \"{title}\"'**
  String removeSortFilterOptionsFromPlaylist(Object title);

  /// No description provided for @removeSortFilterOptionsFromPlaylistDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Sort/Filter Parameters \"{sortFilterParmsName}\"'**
  String removeSortFilterOptionsFromPlaylistDialogTitle(
      Object sortFilterParmsName);

  /// No description provided for @fromScreen.
  ///
  /// In en, this message translates to:
  /// **'On \"{screenName}\" screen'**
  String fromScreen(Object screenName);

  /// No description provided for @removeButton.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeButton;

  /// Confirmation message for saving sort/filter parameters
  ///
  /// In en, this message translates to:
  /// **'Sort/filter parameters \"{sortFilterParmsName}\" were saved to playlist \"{playlistTitle}\" for screen(s) \"{forViewMessage}\".'**
  String saveSortFilterParmsConfirmation(
      Object sortFilterParmsName, Object playlistTitle, Object forViewMessage);

  /// Confirmation message for removing sort/filter parameters
  ///
  /// In en, this message translates to:
  /// **'Sort/filter parameters \"{sortFilterParmsName}\" were removed from playlist \"{playlistTitle}\" on screen(s) \"{forViewMessage}\".'**
  String removeSortFilterParmsConfirmation(
      Object sortFilterParmsName, Object playlistTitle, Object forViewMessage);

  /// No description provided for @playlistSortFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'{screenName} sort/filter'**
  String playlistSortFilterLabel(Object screenName);

  /// No description provided for @playlistAudioCommentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio comments'**
  String get playlistAudioCommentsLabel;

  /// No description provided for @playlistAudioPicturesLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio pictures'**
  String get playlistAudioPicturesLabel;

  /// No description provided for @listenedOn.
  ///
  /// In en, this message translates to:
  /// **'Listened on'**
  String get listenedOn;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @searchInYoutubeChannelName.
  ///
  /// In en, this message translates to:
  /// **'Include Youtube channel'**
  String get searchInYoutubeChannelName;

  /// No description provided for @searchInYoutubeChannelNameTooltip.
  ///
  /// In en, this message translates to:
  /// **'If set, search words or sentences are searched on Youtube channel name as well.'**
  String get searchInYoutubeChannelNameTooltip;

  /// No description provided for @savePlaylistAndCommentsToZipMenu.
  ///
  /// In en, this message translates to:
  /// **'Save Playlists, Comments, Pictures and Settings to ZIP File ...'**
  String get savePlaylistAndCommentsToZipMenu;

  /// No description provided for @savePlaylistAndCommentsToZipTooltip.
  ///
  /// In en, this message translates to:
  /// **'Saving the playlists, their audio comments and pictures to a ZIP file. The ZIP file will contain the playlists JSON files as well as the comment and picture JSON files. Additionally, the application settings.json will be saved. The MP3 and JPG files will not be included.'**
  String get savePlaylistAndCommentsToZipTooltip;

  /// No description provided for @setYoutubeChannelMenu.
  ///
  /// In en, this message translates to:
  /// **'Youtube channel setting'**
  String get setYoutubeChannelMenu;

  /// Confirmation message indicating how many downloaded audios and playable audios were modified
  ///
  /// In en, this message translates to:
  /// **'The Youtube channel was set in {numberOfModifiedDownloadedAudio} downloaded audios and in {numberOfModifiedPlayableAudio} playable audio.'**
  String confirmYoutubeChannelModifications(
      Object numberOfModifiedDownloadedAudio,
      Object numberOfModifiedPlayableAudio);

  /// No description provided for @rewindAudioToStart.
  ///
  /// In en, this message translates to:
  /// **'Rewind all Audios to Start'**
  String get rewindAudioToStart;

  /// No description provided for @rewindAudioToStartTooltip.
  ///
  /// In en, this message translates to:
  /// **'Rewind all playlist audios to start position. This is useful if you wish to replay all the audios.'**
  String get rewindAudioToStartTooltip;

  /// No description provided for @rewindedPlayableAudioNumber.
  ///
  /// In en, this message translates to:
  /// **'{number} playlist audios were repositioned to start and the first listenable audio was selected.'**
  String rewindedPlayableAudioNumber(Object number);

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'Select Date Format ...'**
  String get dateFormat;

  /// No description provided for @dateFormatSelectionDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select the Application Date Format'**
  String get dateFormatSelectionDialogTitle;

  /// No description provided for @commented.
  ///
  /// In en, this message translates to:
  /// **'Commented'**
  String get commented;

  /// No description provided for @notCommented.
  ///
  /// In en, this message translates to:
  /// **'Uncom.'**
  String get notCommented;

  /// Confirmation title for deleting filtered audio
  ///
  /// In en, this message translates to:
  /// **'Delete audios filtered by \"{sortFilterParmsName}\" parms from playlist \"{playlistTitle}\"'**
  String deleteFilteredAudioConfirmationTitle(
      Object sortFilterParmsName, Object playlistTitle);

  /// Confirmation message for deleting filtered audio
  ///
  /// In en, this message translates to:
  /// **'Audios to delete number: {deleteAudioNumber},\nCorresponding total file size: {deleteAudioTotalFileSize},\nCorresponding total duration: {deleteAudioTotalDuration}.'**
  String deleteFilteredAudioConfirmation(Object deleteAudioNumber,
      Object deleteAudioTotalFileSize, Object deleteAudioTotalDuration);

  /// No description provided for @deleteFilteredCommentedAudioWarningTitleOne.
  ///
  /// In en, this message translates to:
  /// **'WARNING: you are going to'**
  String get deleteFilteredCommentedAudioWarningTitleOne;

  /// Warning title for deleting commented and uncommented filtered audio
  ///
  /// In en, this message translates to:
  /// **'delete COMMENTED and uncommented audios filtered by \"{sortFilterParmsName}\" parms from playlist \"{playlistTitle}\". Watch the help to solve the problem ...'**
  String deleteFilteredCommentedAudioWarningTitleTwo(
      Object sortFilterParmsName, Object playlistTitle);

  /// Warning message for deleting commented and uncommented filtered audio
  ///
  /// In en, this message translates to:
  /// **'Total audios to delete number: {deleteAudioNumber},\nCOMMENTED audios to delete number: {deleteCommentedAudioNumber},\nCorresponding total file size: {deleteAudioTotalFileSize},\nCorresponding total duration: {deleteAudioTotalDuration}.'**
  String deleteFilteredCommentedAudioWarning(
      Object deleteAudioNumber,
      Object deleteCommentedAudioNumber,
      Object deleteAudioTotalFileSize,
      Object deleteAudioTotalDuration);

  /// No description provided for @commentedAudioDeletionHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'How to create and use a Sort/Filter parameter to prevent deleting commented audios ?'**
  String get commentedAudioDeletionHelpTitle;

  /// No description provided for @commentedAudioDeletionHelpContent.
  ///
  /// In en, this message translates to:
  /// **'This guide explains how to delete fully listened audios that are not commented.'**
  String get commentedAudioDeletionHelpContent;

  /// No description provided for @commentedAudioDeletionSolutionHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'The solution is to create a Sort/Filter parameter to select only fully played uncommented audio'**
  String get commentedAudioDeletionSolutionHelpTitle;

  /// No description provided for @commentedAudioDeletionSolutionHelpContent.
  ///
  /// In en, this message translates to:
  /// **'In the Sort/Filter definition dialog, the selection parameters are represented by checkboxes ...'**
  String get commentedAudioDeletionSolutionHelpContent;

  /// No description provided for @commentedAudioDeletionOpenSFDialogHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Open the Sort/Filter Definition Dialog'**
  String get commentedAudioDeletionOpenSFDialogHelpTitle;

  /// No description provided for @commentedAudioDeletionOpenSFDialogHelpContent.
  ///
  /// In en, this message translates to:
  /// **'Click the right menu icon in the download audio view, then select \"Sort/Filter Audio ...\".'**
  String get commentedAudioDeletionOpenSFDialogHelpContent;

  /// No description provided for @commentedAudioDeletionCreateSFParmHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a valid Sort/Filter Parameter'**
  String get commentedAudioDeletionCreateSFParmHelpTitle;

  /// No description provided for @commentedAudioDeletionCreateSFParmHelpContent.
  ///
  /// In en, this message translates to:
  /// **'In the \"Save as\" field, enter a name for the Sort/Filter parameter (e.g., FullyListenedUncom). Uncheck the checkboxes for \"Partially listened\", \"Not listened\" and \"Commented\". Then click on \"Save\".'**
  String get commentedAudioDeletionCreateSFParmHelpContent;

  /// No description provided for @commentedAudioDeletionSelectSFParmHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Once saved, the Sort/Filter parameter is applied to the playlist, reducing the displayed audios list.'**
  String get commentedAudioDeletionSelectSFParmHelpTitle;

  /// No description provided for @commentedAudioDeletionSelectSFParmHelpContent.
  ///
  /// In en, this message translates to:
  /// **'Click on the \"Playlists\" button to hide the playlist list. You’ll see your newly created SF parameter selected in the dropdown menu. You can apply this parameter or another one to any playlist ...'**
  String get commentedAudioDeletionSelectSFParmHelpContent;

  /// No description provided for @commentedAudioDeletionApplyingNewSFParmHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Finally, reclick on the \"Playlists\" button to display the playlist list, open the source playlist menu and click on \"Filtered Audios Actions ...\" and then on \"Delete filtered Audios ...\"'**
  String get commentedAudioDeletionApplyingNewSFParmHelpTitle;

  /// No description provided for @commentedAudioDeletionApplyingNewSFParmHelpContent.
  ///
  /// In en, this message translates to:
  /// **'This time, since a correct SF parameter is applied, no warning will be displayed when deleting the selected uncommented audio.'**
  String get commentedAudioDeletionApplyingNewSFParmHelpContent;

  /// No description provided for @filteredAudioActions.
  ///
  /// In en, this message translates to:
  /// **'Filtered Audios Actions ...'**
  String get filteredAudioActions;

  /// No description provided for @moveFilteredAudio.
  ///
  /// In en, this message translates to:
  /// **'Move filtered Audios to Playlist ...'**
  String get moveFilteredAudio;

  /// No description provided for @copyFilteredAudio.
  ///
  /// In en, this message translates to:
  /// **'Copy filtered Audios to Playlist ...'**
  String get copyFilteredAudio;

  /// No description provided for @extractFilteredAudio.
  ///
  /// In en, this message translates to:
  /// **'Extract filtered Audios to unique MP3 ...'**
  String get extractFilteredAudio;

  /// No description provided for @deleteFilteredAudio.
  ///
  /// In en, this message translates to:
  /// **'Delete filtered Audios ...'**
  String get deleteFilteredAudio;

  /// Confirmation message indicating how many audios were moved and unmoved
  ///
  /// In en, this message translates to:
  /// **'Applying Sort/Filter parms \"{sortedFilterParmsName}\", from Youtube playlist \"{sourcePlaylistTitle}\" to Youtube playlist \"{targetPlaylistTitle}\", {movedAudioNumber} audio(s) were moved from which {movedCommentedAudioNumber} were commented, and {unmovedAudioNumber} audio(s) were unmoved.'**
  String confirmMovedUnmovedAudioNumberFromYoutubeToYoutubePlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object movedAudioNumber,
      Object movedCommentedAudioNumber,
      Object unmovedAudioNumber);

  /// Confirmation message indicating how many audios were moved and unmoved
  ///
  /// In en, this message translates to:
  /// **'Applying Sort/Filter parms \"{sortedFilterParmsName}\", from Youtube playlist \"{sourcePlaylistTitle}\" to local playlist \"{targetPlaylistTitle}\", {movedAudioNumber} audio(s) were moved from which {movedCommentedAudioNumber} were commented, and {unmovedAudioNumber} audio(s) were unmoved.'**
  String confirmMovedUnmovedAudioNumberFromYoutubeToLocalPlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object movedAudioNumber,
      Object movedCommentedAudioNumber,
      Object unmovedAudioNumber);

  /// Confirmation message indicating how many audios were moved and unmoved
  ///
  /// In en, this message translates to:
  /// **'Applying Sort/Filter parms \"{sortedFilterParmsName}\", from local playlist \"{sourcePlaylistTitle}\" to Youtube playlist \"{targetPlaylistTitle}\", {movedAudioNumber} audio(s) were moved from which {movedCommentedAudioNumber} were commented, and {unmovedAudioNumber} audio(s) were unmoved.'**
  String confirmMovedUnmovedAudioNumberFromLocalToYoutubePlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object movedAudioNumber,
      Object movedCommentedAudioNumber,
      Object unmovedAudioNumber);

  /// Confirmation message indicating how many audios were moved and unmoved
  ///
  /// In en, this message translates to:
  /// **'Applying Sort/Filter parms \"{sortedFilterParmsName}\", from local playlist \"{sourcePlaylistTitle}\" to local playlist \"{targetPlaylistTitle}\", {movedAudioNumber} audio(s) were moved from which {movedCommentedAudioNumber} were commented, and {unmovedAudioNumber} audio(s) were unmoved.'**
  String confirmMovedUnmovedAudioNumberFromLocalToLocalPlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object movedAudioNumber,
      Object movedCommentedAudioNumber,
      Object unmovedAudioNumber);

  /// Confirmation message indicating how many audios were copied and not copied
  ///
  /// In en, this message translates to:
  /// **'Applying Sort/Filter parms \"{sortedFilterParmsName}\", from Youtube playlist \"{sourcePlaylistTitle}\" to Youtube playlist \"{targetPlaylistTitle}\", {copiedAudioNumber} audio(s) were copied from which {copiedCommentedAudioNumber} were commented, and {notCopiedAudioNumber} audio(s) were not copied.'**
  String confirmCopiedNotCopiedAudioNumberFromYoutubeToYoutubePlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object copiedAudioNumber,
      Object copiedCommentedAudioNumber,
      Object notCopiedAudioNumber);

  /// Confirmation message indicating how many audios were copied and not copied
  ///
  /// In en, this message translates to:
  /// **'Applying Sort/Filter parms \"{sortedFilterParmsName}\", from Youtube playlist \"{sourcePlaylistTitle}\" to local playlist \"{targetPlaylistTitle}\", {copiedAudioNumber} audio(s) were copied from which {copiedCommentedAudioNumber} were commented, and {notCopiedAudioNumber} audio(s) were not copied.'**
  String confirmCopiedNotCopiedAudioNumberFromYoutubeToLocalPlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object copiedAudioNumber,
      Object copiedCommentedAudioNumber,
      Object notCopiedAudioNumber);

  /// Confirmation message indicating how many audios were copied and not copied
  ///
  /// In en, this message translates to:
  /// **'Applying Sort/Filter parms \"{sortedFilterParmsName}\", from local playlist \"{sourcePlaylistTitle}\" to Youtube playlist \"{targetPlaylistTitle}\", {copiedAudioNumber} audio(s) were copied from which {copiedCommentedAudioNumber} were commented, and {notCopiedAudioNumber} audio(s) were not copied.'**
  String confirmCopiedNotCopiedAudioNumberFromLocalToYoutubePlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object copiedAudioNumber,
      Object copiedCommentedAudioNumber,
      Object notCopiedAudioNumber);

  /// Confirmation message indicating how many audios were copied and not copied
  ///
  /// In en, this message translates to:
  /// **'Applying Sort/Filter parms \"{sortedFilterParmsName}\", from local playlist \"{sourcePlaylistTitle}\" to local playlist \"{targetPlaylistTitle}\", {copiedAudioNumber} audio(s) were copied from which {copiedCommentedAudioNumber} were commented, and {notCopiedAudioNumber} audio(s) were not copied.'**
  String confirmCopiedNotCopiedAudioNumberFromLocalToLocalPlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object copiedAudioNumber,
      Object copiedCommentedAudioNumber,
      Object notCopiedAudioNumber);

  /// Warning message indicating that the default SF parms were not applied to move audio
  ///
  /// In en, this message translates to:
  /// **'Since \"{sortedFilterParmsName}\" Sort/Filter parms is selected, no audio can be moved from Youtube playlist \"{sourcePlaylistTitle}\" to Youtube playlist \"{targetPlaylistTitle}\". SOLUTION: define a Sort/Filter parms and apply it before executing this operation ...'**
  String defaultSFPNotApplyedToMoveAudioFromYoutubeToYoutubePlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName);

  /// Warning message indicating that the default SF parms were not applied to move audio
  ///
  /// In en, this message translates to:
  /// **'Since \"{sortedFilterParmsName}\" Sort/Filter parms is selected, no audio can be moved from Youtube playlist \"{sourcePlaylistTitle}\" to local playlist \"{targetPlaylistTitle}\". SOLUTION: define a Sort/Filter parms and apply it before executing this operation ...'**
  String defaultSFPNotApplyedToMoveAudioFromYoutubeToLocalPlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName);

  /// Warning message indicating that the default SF parms were not applied to move audio
  ///
  /// In en, this message translates to:
  /// **'Since \"{sortedFilterParmsName}\" Sort/Filter parms is selected, no audio can be moved from local playlist \"{sourcePlaylistTitle}\" to Youtube playlist \"{targetPlaylistTitle}\". SOLUTION: define a Sort/Filter parms and apply it before executing this operation ...'**
  String defaultSFPNotApplyedToMoveAudioFromLocalToYoutubePlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName);

  /// Warning message indicating that the default SF parms were not applied to move audio
  ///
  /// In en, this message translates to:
  /// **'Since \"{sortedFilterParmsName}\" Sort/Filter parms is selected, no audio can be moved from local playlist \"{sourcePlaylistTitle}\" to local playlist \"{targetPlaylistTitle}\". SOLUTION: define a Sort/Filter parms and apply it before executing this operation ...'**
  String defaultSFPNotApplyedToMoveAudioFromLocalToLocalPlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName);

  /// Warning message indicating that the default SF parms were not applied to move audio
  ///
  /// In en, this message translates to:
  /// **'Since \"{sortedFilterParmsName}\" Sort/Filter parms is selected, no audio can be copied from Youtube playlist \"{sourcePlaylistTitle}\" to Youtube playlist \"{targetPlaylistTitle}\". SOLUTION: define a Sort/Filter parms and apply it before executing this operation ...'**
  String defaultSFPNotApplyedToCopyAudioFromYoutubeToYoutubePlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName);

  /// Warning message indicating that the default SF parms were not applied to move audio
  ///
  /// In en, this message translates to:
  /// **'Since \"{sortedFilterParmsName}\" Sort/Filter parms is selected, no audio can be copied from Youtube playlist \"{sourcePlaylistTitle}\" to local playlist \"{targetPlaylistTitle}\". SOLUTION: define a Sort/Filter parms and apply it before executing this operation ...'**
  String defaultSFPNotApplyedToCopyAudioFromYoutubeToLocalPlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName);

  /// Warning message indicating that the default SF parms were not applied to move audio
  ///
  /// In en, this message translates to:
  /// **'Since \"{sortedFilterParmsName}\" Sort/Filter parms is selected, no audio can be copied from local playlist \"{sourcePlaylistTitle}\" to Youtube playlist \"{targetPlaylistTitle}\". SOLUTION: define a Sort/Filter parms and apply it before executing this operation ...'**
  String defaultSFPNotApplyedToCopyAudioFromLocalToYoutubePlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName);

  /// Warning message indicating that the default SF parms were not applied to move audio
  ///
  /// In en, this message translates to:
  /// **'Since \"{sortedFilterParmsName}\" Sort/Filter parms is selected, no audio can be copied from local playlist \"{sourcePlaylistTitle}\" to local playlist \"{targetPlaylistTitle}\". SOLUTION: define a Sort/Filter parms and apply it before executing this operation ...'**
  String defaultSFPNotApplyedToCopyAudioFromLocalToLocalPlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName);

  /// No description provided for @appBarMenuEnableNextAudioAutoPlay.
  ///
  /// In en, this message translates to:
  /// **'Enable playing next Audio automatically ...'**
  String get appBarMenuEnableNextAudioAutoPlay;

  /// No description provided for @batteryParameters.
  ///
  /// In en, this message translates to:
  /// **'Battery Parameter Change'**
  String get batteryParameters;

  /// No description provided for @disableBatteryOptimisation.
  ///
  /// In en, this message translates to:
  /// **'Display the battery settings in order to disable its optimization. The result is that it allows the application to automatically play the next audio in the current playlist.\n\nClick on the button below, then select the \"Battery\" option at the bottom of the list. Next, choose \"Unrestricted\" and quit the settings.'**
  String get disableBatteryOptimisation;

  /// No description provided for @openBatteryOptimisationButton.
  ///
  /// In en, this message translates to:
  /// **'Display the battery settings'**
  String get openBatteryOptimisationButton;

  /// Warning message for deleting a used SF parms
  ///
  /// In en, this message translates to:
  /// **'WARNING: you are going to delete the Sort/Filter parms \"{sortFilterParmsName}\" which is used in {playlistNumber} playlist(s) listed below'**
  String deleteSortFilterParmsWarningTitle(
      Object sortFilterParmsName, Object playlistNumber);

  /// No description provided for @updatingSortFilterParmsWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'WARNING: the sort/filter parameters \"{sortFilterParmsName}\" were modified. Do you want to update the existing sort/filter parms by clicking on \"Confirm\", or to save it with a different name or cancel the Save operation, this by clicking on \"Cancel\" ?'**
  String updatingSortFilterParmsWarningTitle(Object sortFilterParmsName);

  /// No description provided for @presentOnlyInFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'Present only in initial version'**
  String get presentOnlyInFirstTitle;

  /// No description provided for @presentOnlyInSecondTitle.
  ///
  /// In en, this message translates to:
  /// **'Present only in modified version'**
  String get presentOnlyInSecondTitle;

  /// No description provided for @ascendingShort.
  ///
  /// In en, this message translates to:
  /// **'asc'**
  String get ascendingShort;

  /// No description provided for @descendingShort.
  ///
  /// In en, this message translates to:
  /// **'desc'**
  String get descendingShort;

  /// No description provided for @startAudioDownloadDateSortFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Lists all audios downloaded on or after the specified start date if set.'**
  String get startAudioDownloadDateSortFilterTooltip;

  /// No description provided for @endAudioDownloadDateSortFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Lists all audios downloaded on or before the specified end date if set.'**
  String get endAudioDownloadDateSortFilterTooltip;

  /// No description provided for @startVideoUploadDateSortFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Lists all videos uploaded on or after the specified start date if set.'**
  String get startVideoUploadDateSortFilterTooltip;

  /// No description provided for @endVideoUploadDateSortFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Lists all videos uploaded on or before the specified end date if set.'**
  String get endVideoUploadDateSortFilterTooltip;

  /// No description provided for @startAudioDurationSortFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Lists all audios with a duration equal to or greater than the specified minimum duration if set.'**
  String get startAudioDurationSortFilterTooltip;

  /// No description provided for @endAudioDurationSortFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Lists all audios with a duration equal to or less than the specified maximum duration if set.'**
  String get endAudioDurationSortFilterTooltip;

  /// No description provided for @startAudioFileSizeSortFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Lists all audios with a file size equal to or greater than the specified minimum size if set.'**
  String get startAudioFileSizeSortFilterTooltip;

  /// No description provided for @endAudioFileSizeSortFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Lists all audios with a file size equal to or less than the specified maximum size if set.'**
  String get endAudioFileSizeSortFilterTooltip;

  /// No description provided for @valueInInitialVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'In initial version'**
  String get valueInInitialVersionTitle;

  /// No description provided for @valueInModifiedVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'In modified version'**
  String get valueInModifiedVersionTitle;

  /// No description provided for @checked.
  ///
  /// In en, this message translates to:
  /// **'checked'**
  String get checked;

  /// No description provided for @unchecked.
  ///
  /// In en, this message translates to:
  /// **'unchecked'**
  String get unchecked;

  /// No description provided for @emptyDate.
  ///
  /// In en, this message translates to:
  /// **'empty'**
  String get emptyDate;

  /// No description provided for @helpMainTitle.
  ///
  /// In en, this message translates to:
  /// **'AudioLearn Help'**
  String get helpMainTitle;

  /// No description provided for @helpMainIntroduction.
  ///
  /// In en, this message translates to:
  /// **'Consult the AudioLearn Introduction Help the first time you use the application in order to initialize it correctly !'**
  String get helpMainIntroduction;

  /// No description provided for @helpAudioLearnIntroductionTitle.
  ///
  /// In en, this message translates to:
  /// **'AudioLearn Introduction'**
  String get helpAudioLearnIntroductionTitle;

  /// No description provided for @helpAudioLearnIntroductionSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Defining, adding and downloading a Youtube playlist'**
  String get helpAudioLearnIntroductionSubTitle;

  /// No description provided for @helpLocalPlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Local Playlist'**
  String get helpLocalPlaylistTitle;

  /// No description provided for @helpLocalPlaylistSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Defining and using a local playlist'**
  String get helpLocalPlaylistSubTitle;

  /// No description provided for @helpPlaylistMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlist Menu'**
  String get helpPlaylistMenuTitle;

  /// No description provided for @helpPlaylistMenuSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlist menu functionalities'**
  String get helpPlaylistMenuSubTitle;

  /// No description provided for @helpAudioMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio Menu'**
  String get helpAudioMenuTitle;

  /// No description provided for @helpAudioMenuSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio menu functionalities'**
  String get helpAudioMenuSubTitle;

  /// No description provided for @addPrivateYoutubePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Trying to add a private Youtube playlist is not possible since the audios of a private playlist can not be downloaded. To solve the problem, edit the playlist on Youtube and change its visibility from \"Private\" to \"Unlisted\" or to \"Public\" and then re-add it to the application.'**
  String get addPrivateYoutubePlaylist;

  /// No description provided for @addAudioPicture.
  ///
  /// In en, this message translates to:
  /// **'Add Audio Picture ...'**
  String get addAudioPicture;

  /// No description provided for @removeAudioPicture.
  ///
  /// In en, this message translates to:
  /// **'Remove Audio Picture'**
  String get removeAudioPicture;

  /// No description provided for @savedAppDataToZip.
  ///
  /// In en, this message translates to:
  /// **'Saved playlist, comment and picture JSON files as well as application settings to \"{filePathName}\".'**
  String savedAppDataToZip(Object filePathName);

  /// No description provided for @appDataCouldNotBeSavedToZip.
  ///
  /// In en, this message translates to:
  /// **'Playlist, comment and picture JSON files as well as application settings could not be saved to ZIP.'**
  String get appDataCouldNotBeSavedToZip;

  /// No description provided for @pictured.
  ///
  /// In en, this message translates to:
  /// **'Pictured'**
  String get pictured;

  /// No description provided for @notPictured.
  ///
  /// In en, this message translates to:
  /// **'Unpictured'**
  String get notPictured;

  /// No description provided for @restorePlaylistAndCommentsFromZipMenu.
  ///
  /// In en, this message translates to:
  /// **'Restore Playlist(s), Comments, Pictures and Settings from ZIP File ...'**
  String get restorePlaylistAndCommentsFromZipMenu;

  /// No description provided for @restorePlaylistAndCommentsFromZipTooltip.
  ///
  /// In en, this message translates to:
  /// **'According to the content of the selected ZIP file, restoring a unique or multiple playlists, their audio comments, pictures and, if awailable, the application settings. The audio files are not included in the ZIP file.'**
  String get restorePlaylistAndCommentsFromZipTooltip;

  /// No description provided for @appDataCouldNotBeRestoredFromZip.
  ///
  /// In en, this message translates to:
  /// **'Playlist, comment and picture JSON files as well as application settings could not be restored from ZIP.'**
  String get appDataCouldNotBeRestoredFromZip;

  /// No description provided for @deleteFilteredAudioFromPlaylistAsWell.
  ///
  /// In en, this message translates to:
  /// **'Delete filtered Audios from Playlist as well ...'**
  String get deleteFilteredAudioFromPlaylistAsWell;

  /// Confirmation title for deleting filtered audio
  ///
  /// In en, this message translates to:
  /// **'Delete audios filtered by \"{sortFilterParmsName}\" parms from playlist \"{playlistTitle}\" as well (will be re-downloadable)'**
  String deleteFilteredAudioFromPlaylistAsWellConfirmationTitle(
      Object sortFilterParmsName, Object playlistTitle);

  /// No description provided for @redownloadFilteredAudio.
  ///
  /// In en, this message translates to:
  /// **'Redownload filtered Audios'**
  String get redownloadFilteredAudio;

  /// No description provided for @redownloadFilteredAudioTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filtered audio files are re-downloaded using their original file names.'**
  String get redownloadFilteredAudioTooltip;

  /// Confirmation title for redownloading filtered audio
  ///
  /// In en, this message translates to:
  /// **'\"{redownloadedAudioNumber}\" audios were redownloaded to the playlist \"{playlistTitle}\". \"{notRedownloadedAudioNumber}\" audios were not redownloaded since they are already present in the playlist directory.'**
  String redownloadedAudioNumbersConfirmation(Object playlistTitle,
      Object redownloadedAudioNumber, Object notRedownloadedAudioNumber);

  /// No description provided for @redownloadDeletedAudio.
  ///
  /// In en, this message translates to:
  /// **'Redownload deleted Audio'**
  String get redownloadDeletedAudio;

  /// Confirmation title for redownloading audio
  ///
  /// In en, this message translates to:
  /// **'The audio \"{redownloadedAudioTitle}\" was redownloaded in the playlist \"{playlistTitle}\".'**
  String redownloadedAudioConfirmation(
      Object playlistTitle, Object redownloadedAudioTitle);

  /// No description provided for @playable.
  ///
  /// In en, this message translates to:
  /// **'Playable'**
  String get playable;

  /// No description provided for @notPlayable.
  ///
  /// In en, this message translates to:
  /// **'Not playable'**
  String get notPlayable;

  /// Warning title for not redownloading audio
  ///
  /// In en, this message translates to:
  /// **'The audio \"{redownloadedAudioTitle}\" was NOT redownloaded in the playlist \"{playlistTitle}\" because it already exists in the playlist directory.'**
  String audioNotRedownloadedWarning(
      Object playlistTitle, Object redownloadedAudioTitle);

  /// No description provided for @isPlayableLabel.
  ///
  /// In en, this message translates to:
  /// **'Playable'**
  String get isPlayableLabel;

  /// No description provided for @setPlaylistAudioQuality.
  ///
  /// In en, this message translates to:
  /// **'Set Audio Quality ...'**
  String get setPlaylistAudioQuality;

  /// No description provided for @setPlaylistAudioQualityTooltip.
  ///
  /// In en, this message translates to:
  /// **'The selected audio quality will be applied to the next downloaded audios. If the audio quality must be applied to the already downloaded audios, those audios must be deleted \"from playlist as well\" so that they will be redownloadable in the modified audio quality.'**
  String get setPlaylistAudioQualityTooltip;

  /// No description provided for @setPlaylistAudioQualityDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlist Audio Quality'**
  String get setPlaylistAudioQualityDialogTitle;

  /// No description provided for @selectAudioQuality.
  ///
  /// In en, this message translates to:
  /// **'Select audio quality'**
  String get selectAudioQuality;

  /// Not moved warning. No period in end of message since the period is added by the warning message display
  ///
  /// In en, this message translates to:
  /// **'Audio \"{audioTitle}\"{yesOrNo}{operationType} from {fromPlaylistType} playlist \"{fromPlaylistTitle}\" to {toPlaylistType} playlist \"{toPlaylistTitle}\"{notCopiedOrMovedReason}'**
  String audioCopiedOrMovedFromPlaylistToPlaylist(
      Object audioTitle,
      Object yesOrNo,
      Object operationType,
      Object fromPlaylistType,
      Object fromPlaylistTitle,
      Object toPlaylistTitle,
      Object toPlaylistType,
      Object notCopiedOrMovedReason);

  /// No description provided for @sinceAbsentFromSourcePlaylist.
  ///
  /// In en, this message translates to:
  /// **' since its MP3 is not present in the source playlist.'**
  String get sinceAbsentFromSourcePlaylist;

  /// No description provided for @sinceAlreadyPresentInTargetPlaylist.
  ///
  /// In en, this message translates to:
  /// **' since it is already present in the destination playlist.'**
  String get sinceAlreadyPresentInTargetPlaylist;

  /// Warning title for not redownloading audio
  ///
  /// In en, this message translates to:
  /// **'.\n\nIF THE DELETED AUDIO VIDEO \"{audioTitle}\" REMAINS IN THE \"{fromPlaylistTitle}\" YOUTUBE PLAYLIST, IT WILL BE DOWNLOADED AGAIN THE NEXT TIME YOU DOWNLOAD THE PLAYLIST !'**
  String audioNotKeptInSourcePlaylist(
      Object audioTitle, Object fromPlaylistTitle);

  /// No description provided for @noOperation.
  ///
  /// In en, this message translates to:
  /// **' NOT '**
  String get noOperation;

  /// No description provided for @yesOperation.
  ///
  /// In en, this message translates to:
  /// **' '**
  String get yesOperation;

  /// No description provided for @localPlaylistType.
  ///
  /// In en, this message translates to:
  /// **'local'**
  String get localPlaylistType;

  /// No description provided for @youtubePlaylistType.
  ///
  /// In en, this message translates to:
  /// **'Youtube'**
  String get youtubePlaylistType;

  /// No description provided for @movedOperationType.
  ///
  /// In en, this message translates to:
  /// **'moved'**
  String get movedOperationType;

  /// No description provided for @copiedOperationType.
  ///
  /// In en, this message translates to:
  /// **'copied'**
  String get copiedOperationType;

  /// No description provided for @noOperationMovedOperationType.
  ///
  /// In en, this message translates to:
  /// **'moved'**
  String get noOperationMovedOperationType;

  /// No description provided for @noOperationCopiedOperationType.
  ///
  /// In en, this message translates to:
  /// **'copied'**
  String get noOperationCopiedOperationType;

  /// No description provided for @savedPictureNumberMessage.
  ///
  /// In en, this message translates to:
  /// **'\n\nSaved also {pictureNumber} picture JPG file(s) in same directory / pictures.'**
  String savedPictureNumberMessage(Object pictureNumber);

  /// No description provided for @savedPictureNumberMessageToZip.
  ///
  /// In en, this message translates to:
  /// **'\n\nSaved also {pictureNumber} picture JPG file(s) in the ZIP file.'**
  String savedPictureNumberMessageToZip(Object pictureNumber);

  /// No description provided for @addedToZipPictureNumberMessage.
  ///
  /// In en, this message translates to:
  /// **'\n\nSaved also {pictureNumber} picture JPG file(s) in the ZIP file.'**
  String addedToZipPictureNumberMessage(Object pictureNumber);

  /// No description provided for @replaceExistingPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Replace existing playlist(s)'**
  String get replaceExistingPlaylists;

  /// No description provided for @deleteExistingPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Delete existing playlists not\ncontained in ZIP'**
  String get deleteExistingPlaylists;

  /// No description provided for @playlistRestorationDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlists Restoration'**
  String get playlistRestorationDialogTitle;

  /// No description provided for @playlistRestorationExplanation.
  ///
  /// In en, this message translates to:
  /// **'Important: if you\'ve modified your existing playlists (added audio files, comments, or pictures) since creating the ZIP backup, keep the \'Replace existing playlist(s)\' checkbox UNCHECKED. Otherwise, your recent changes will be replaced by the older versions contained in the backup.\n\nPlaylists not in the ZIP will only be deleted if they existed BEFORE the backup was created. Any playlists created or modified AFTER the backup date are automatically protected and will be kept, even if the delete checkbox is checked.'**
  String get playlistRestorationExplanation;

  /// No description provided for @playlistRestorationHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlist Restoration Function'**
  String get playlistRestorationHelpTitle;

  /// No description provided for @playlistRestorationFirstHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Problematic scenario: you restored playlists from a ZIP file, then ran the \"Update playlist JSON files\" function with the \"Remove deleted audio files\" checkbox enabled. Since restoration from a ZIP doesn\'t reinstall the audio files, enabling this option removed these files from the application. As a result, they are no longer available for re-downloading.'**
  String get playlistRestorationFirstHelpTitle;

  /// No description provided for @playlistRestorationFirstHelpContent.
  ///
  /// In en, this message translates to:
  /// **'To resolve this issue, you need to delete the playlists affected by the loss of their audio files. Here are two methods for deleting these playlists:\n\n1 - Deletion through the application\nEach  playlist has a menu. Use its last element \"Delete Playlist ...\".\n\n2 - Manual deletion (recommended if multiple playlists must be deleted)\nNavigate to the application\'s storage directory in which the playlist directories are present. Select the folders to be removed and delete the selected group.'**
  String get playlistRestorationFirstHelpContent;

  /// No description provided for @playlistRestorationSecondHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'After deleting the affected playlists, restore them again from the ZIP file. Afterwards, you can re-download audio files that are not playable using the playlist menu \"Filtered Audios Actions ...\" and the submenu \"Redownload filtered Audios\". If the sort filter parameter is set to \"default\", all non-playable audio files will be re-downloaded. To limit which files are re-downloaded, select or define a specific sort filter parameter.'**
  String get playlistRestorationSecondHelpTitle;

  /// No description provided for @playlistJsonFilesUpdateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlist JSON Files Update'**
  String get playlistJsonFilesUpdateDialogTitle;

  /// No description provided for @playlistJsonFilesUpdateExplanation.
  ///
  /// In en, this message translates to:
  /// **'Important: if you\'ve restored from a ZIP backup AND manually added playlists afterward, please use caution when updating. When you run \"Update Playlist JSON Files\", any restored audio files that haven\'t been redownloaded will disappear from your playlists. To preserve these files and conserve the possibility of redownloading them, make sure the \"Remove deleted audio files\" checkbox remains UNCHECKED before updating.'**
  String get playlistJsonFilesUpdateExplanation;

  /// No description provided for @removeDeletedAudioFiles.
  ///
  /// In en, this message translates to:
  /// **'Remove deleted audio files'**
  String get removeDeletedAudioFiles;

  /// No description provided for @updatePlaylistJsonFilesHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Playlist JSON Files Function'**
  String get updatePlaylistJsonFilesHelpTitle;

  /// No description provided for @updatePlaylistJsonFilesHelpContent.
  ///
  /// In en, this message translates to:
  /// **'Important note: This function is only necessary for changes made OUTSIDE the application. Changes made directly within the application (adding/removing playlists, adding/importing/deleting audio files) are automatically processed and do not require using this update function.'**
  String get updatePlaylistJsonFilesHelpContent;

  /// No description provided for @updatePlaylistJsonFilesFirstHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Using the Update Playlist JSON Files Function'**
  String get updatePlaylistJsonFilesFirstHelpTitle;

  /// No description provided for @saveUniquePlaylistCommentsAndPicturesToZipMenu.
  ///
  /// In en, this message translates to:
  /// **'Save the Playlist, its Comments and its Pictures to ZIP File ...'**
  String get saveUniquePlaylistCommentsAndPicturesToZipMenu;

  /// No description provided for @saveUniquePlaylistCommentsAndPicturesToZipTooltip.
  ///
  /// In en, this message translates to:
  /// **'Saving the playlist, their audio comments and pictures to a ZIP file. Only the JSON and JPG files are copied. The MP3 files will not be included.'**
  String get saveUniquePlaylistCommentsAndPicturesToZipTooltip;

  /// No description provided for @savedUniquePlaylistToZip.
  ///
  /// In en, this message translates to:
  /// **'Saved playlist, comment and picture JSON files to \"{filePathName}\".'**
  String savedUniquePlaylistToZip(Object filePathName);

  /// No description provided for @downloadedCheckbox.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloadedCheckbox;

  /// No description provided for @downloadedCheckboxTooltip.
  ///
  /// In en, this message translates to:
  /// **'Selecting downloaded audios.'**
  String get downloadedCheckboxTooltip;

  /// No description provided for @importedCheckbox.
  ///
  /// In en, this message translates to:
  /// **'Import.'**
  String get importedCheckbox;

  /// No description provided for @importedCheckboxTooltip.
  ///
  /// In en, this message translates to:
  /// **'Selecting imported audios.'**
  String get importedCheckboxTooltip;

  /// No description provided for @convertedCheckbox.
  ///
  /// In en, this message translates to:
  /// **'Converted'**
  String get convertedCheckbox;

  /// No description provided for @convertedCheckboxTooltip.
  ///
  /// In en, this message translates to:
  /// **'Selecting text converted to MP3 audios.'**
  String get convertedCheckboxTooltip;

  /// No description provided for @extractedCheckbox.
  ///
  /// In en, this message translates to:
  /// **'Extracted'**
  String get extractedCheckbox;

  /// No description provided for @extractedCheckboxTooltip.
  ///
  /// In en, this message translates to:
  /// **'Selecting audios created by comment(s) extraction to MP3. If necessary, ensure both \"Music qual.\" and \"Spoken q.\" checkboxes are checked.'**
  String get extractedCheckboxTooltip;

  /// No description provided for @restoredElementsHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Restored Elements Description'**
  String get restoredElementsHelpTitle;

  /// No description provided for @restoredElementsHelpContent.
  ///
  /// In en, this message translates to:
  /// **'N playlist: number of new playlist JSON files created by the restoration.\n\nN comment: number of new comment JSON files created by the restoration. This happens only if the commented audio had no comment before the restoration. Otherwise, the new comment is added to the existing audio comment JSON file.\n\nN picture: number of new picture JSON files created by the restoration. This happens only if the pictured audio had no picture before the restoration. Otherwise, the new picture is added to the existing audio picture JSON file.\n\nN audio reference: number of playable audio elements contained in the unique or multiple new playlist json file(s) created by the restoration. If the restored playlist number is 0, then the audio reference(s) number correspond to the number of audio element(s) added to their enclosing playlist JSON file by the restoration. The restoration does not add MP3 files since no MP3 is contained in the ZIP file. The added referenced audios can be downloaded after the restoration.\n\nN added comment: number of comments added by the restoration to the existing audio comment JSON files.\n\nN modified comment: number of comments modified by the restoration in the existing audio comment JSON files.'**
  String get restoredElementsHelpContent;

  /// No description provided for @playlistInfoDownloadAudio.
  ///
  /// In en, this message translates to:
  /// **'Download audio'**
  String get playlistInfoDownloadAudio;

  /// No description provided for @playlistInfoAudioPlayer.
  ///
  /// In en, this message translates to:
  /// **'Play audio'**
  String get playlistInfoAudioPlayer;

  /// No description provided for @savePlaylistsAudioMp3FilesToZipMenu.
  ///
  /// In en, this message translates to:
  /// **'Save Playlists Audios MP3 to ZIP File(s) ...'**
  String get savePlaylistsAudioMp3FilesToZipMenu;

  /// No description provided for @savePlaylistsAudioMp3FilesToZipTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save audio MP3 files from all playlists to ZIP file(s). You can specify a date/time filter to only include audio files downloaded on or after that date.'**
  String get savePlaylistsAudioMp3FilesToZipTooltip;

  /// No description provided for @setAudioDownloadFromDateTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Set the Download Date'**
  String get setAudioDownloadFromDateTimeTitle;

  /// No description provided for @audioDownloadFromDateTimeAllPlaylistsExplanation.
  ///
  /// In en, this message translates to:
  /// **'The default specified download date corresponds to the oldest audio download date from all playlists. Modify this value by specifying the download date from which the audio MP3 files will be included in the ZIP.'**
  String get audioDownloadFromDateTimeAllPlaylistsExplanation;

  /// No description provided for @audioDownloadFromDateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Date/time {selectedAppDateFormat} hh:mm'**
  String audioDownloadFromDateTimeLabel(Object selectedAppDateFormat);

  /// No description provided for @audioDownloadFromDateTimeAllPlaylistsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Since the current date/time value corresponds to the application oldest date/time downladed audio value, if the date/time is not modified, all the application audio MP3 files will be included in the ZIP file.'**
  String get audioDownloadFromDateTimeAllPlaylistsTooltip;

  /// No description provided for @audioDownloadFromDateTimeSinglePlaylistTooltip.
  ///
  /// In en, this message translates to:
  /// **'Since the current date/time value corresponds to the playlist oldest date/time downladed audio value, if the date/time is not modified, all the playlist audio MP3 files will be included in the ZIP file.'**
  String get audioDownloadFromDateTimeSinglePlaylistTooltip;

  /// No description provided for @noAudioMp3WereSavedToZip.
  ///
  /// In en, this message translates to:
  /// **'No audio MP3 file was saved to ZIP since no audio was downloaded on or after {audioDownloadFromDateTime}.'**
  String noAudioMp3WereSavedToZip(Object audioDownloadFromDateTime);

  /// No description provided for @savePlaylistAudioMp3FilesToZipMenu.
  ///
  /// In en, this message translates to:
  /// **'Save the Playlist Audios MP3 to 1 or n ZIP File(s) ...'**
  String get savePlaylistAudioMp3FilesToZipMenu;

  /// No description provided for @savePlaylistAudioMp3FilesToZipTooltip.
  ///
  /// In en, this message translates to:
  /// **'Saving the playlist audio MP3 files to one or several ZIP file(s). You can specify a date/time filter to only include audio files downloaded on or after that date.'**
  String get savePlaylistAudioMp3FilesToZipTooltip;

  /// No description provided for @audioDownloadFromDateTimeUniquePlaylistExplanation.
  ///
  /// In en, this message translates to:
  /// **'The default specified download date corresponds to the oldest audio download date from the playlist. Modify this value by specifying the download date from which the audio MP3 files will be included in the ZIP.'**
  String get audioDownloadFromDateTimeUniquePlaylistExplanation;

  /// No description provided for @audioDownloadFromDateTimeUniquePlaylistTooltip.
  ///
  /// In en, this message translates to:
  /// **'Since the current date/time value corresponds to the playlist oldest date/time downladed audio value, if the date/time is not modified, all the playlist audio MP3 files will be included in the ZIP file.'**
  String get audioDownloadFromDateTimeUniquePlaylistTooltip;

  /// No description provided for @invalidDateFormatErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'{dateStr} does not respect the date or date/time format.'**
  String invalidDateFormatErrorMessage(Object dateStr);

  /// No description provided for @emptyDateErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Defining an empty date or date/time download date is not possible.'**
  String get emptyDateErrorMessage;

  /// No description provided for @savingUniquePlaylistAudioMp3.
  ///
  /// In en, this message translates to:
  /// **'Saving {playlistTitle} audio files to ZIP ...'**
  String savingUniquePlaylistAudioMp3(Object playlistTitle);

  /// No description provided for @savingMultiplePlaylistsAudioMp3.
  ///
  /// In en, this message translates to:
  /// **'Saving multiple playlists audio files to ZIP ...'**
  String get savingMultiplePlaylistsAudioMp3;

  /// No description provided for @savingMultiplePlaylists.
  ///
  /// In en, this message translates to:
  /// **'Saving all playlists to ZIP ...'**
  String get savingMultiplePlaylists;

  /// No description provided for @savingApproximativeTime.
  ///
  /// In en, this message translates to:
  /// **'Should approxim. take {saveTime}. ZIP number: {zipNumber}'**
  String savingApproximativeTime(Object saveTime, Object zipNumber);

  /// No description provided for @savingUpToHalfHour.
  ///
  /// In en, this message translates to:
  /// **'Please wait, this may take 10 to 30 minutes or more ...'**
  String get savingUpToHalfHour;

  /// No description provided for @savingAudioToZipTime.
  ///
  /// In en, this message translates to:
  /// **'Saving the audio MP3 in one or several ZIP file(s) will take this estimated duration (hh:mm:ss): {evaluatedSaveTime}.'**
  String savingAudioToZipTime(Object evaluatedSaveTime);

  /// No description provided for @savingAudioToZipTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Prevision of the Save Duration'**
  String get savingAudioToZipTimeTitle;

  /// Confirmation message after saving the audio MP3 downloaded at or after a specified date time of a unique playlist to a ZIP file
  ///
  /// In en, this message translates to:
  /// **'Saved to ZIP file(s) unique playlist audio MP3 files downloaded from {audioDownloadFromDateTime}.\n\nTotal saved audio number: {savedAudioNumber}, total size: {savedAudioTotalFileSize} and total duration: {savedAudioTotalDuration}.\n\nSave operation real duration: {saveOperationRealDuration}, number of bytes saved per second: {bytesNumberSavedPerSecond}, number of created ZIP file(s): {zipFilesNumber}.\n\nZIP file path name: \"{filePathName}\".{zipTooLargeFileInfo}'**
  String correctedSavedUniquePlaylistAudioMp3ToZip(
      Object audioDownloadFromDateTime,
      Object savedAudioNumber,
      Object savedAudioTotalFileSize,
      Object savedAudioTotalDuration,
      Object saveOperationRealDuration,
      Object bytesNumberSavedPerSecond,
      Object filePathName,
      Object zipFilesNumber,
      Object zipTooLargeFileInfo);

  /// Confirmation message after saving the audio MP3 downloaded at or after a specified date time of all application playlists to a ZIP file
  ///
  /// In en, this message translates to:
  /// **'Saved to ZIP all playlists audio MP3 files downloaded from {audioDownloadFromDateTime}.\n\nTotal saved audio number: {savedAudioNumber}, total size: {savedAudioTotalFileSize} and total duration: {savedAudioTotalDuration}.\n\nSave operation real duration: {saveOperationRealDuration}, number of bytes saved per second: {bytesNumberSavedPerSecond}, number of created ZIP file(s): {zipFilesNumber}.\n\nZIP file path name: \"{filePathName}\".{zipTooLargeFileInfo}'**
  String correctedSavedMultiplePlaylistsAudioMp3ToZip(
      Object audioDownloadFromDateTime,
      Object savedAudioNumber,
      Object savedAudioTotalFileSize,
      Object savedAudioTotalDuration,
      Object saveOperationRealDuration,
      Object bytesNumberSavedPerSecond,
      Object filePathName,
      Object zipFilesNumber,
      Object zipTooLargeFileInfo);

  /// No description provided for @restorePlaylistsAudioMp3FilesFromZipMenu.
  ///
  /// In en, this message translates to:
  /// **'Restore Playlists Audios MP3 from one or several ZIP File(s)  ...'**
  String get restorePlaylistsAudioMp3FilesFromZipMenu;

  /// No description provided for @restorePlaylistsAudioMp3FilesFromZipTooltip.
  ///
  /// In en, this message translates to:
  /// **'Restoring audios MP3 not yet present in the playlists from a saved ZIP file. Only the MP3 relative to the audios listed in the playlists are restorable.'**
  String get restorePlaylistsAudioMp3FilesFromZipTooltip;

  /// No description provided for @audioMp3RestorationDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'MP3 Restoration'**
  String get audioMp3RestorationDialogTitle;

  /// No description provided for @audioMp3RestorationExplanation.
  ///
  /// In en, this message translates to:
  /// **'Only the MP3 relative to the audios listed in the playlists which are not already present in the playlists are restorable.'**
  String get audioMp3RestorationExplanation;

  /// No description provided for @restorePlaylistAudioMp3FilesFromZipMenu.
  ///
  /// In en, this message translates to:
  /// **'Restore Playlist Audios MP3 from one or several ZIP File(s) ...'**
  String get restorePlaylistAudioMp3FilesFromZipMenu;

  /// No description provided for @restorePlaylistAudioMp3FilesFromZipTooltip.
  ///
  /// In en, this message translates to:
  /// **'Restoring audios MP3 not yet present in the playlist from a saved ZIP file. Only the MP3 relative to the audios listed in the playlist are restorable.'**
  String get restorePlaylistAudioMp3FilesFromZipTooltip;

  /// No description provided for @audioMp3UniquePlaylistRestorationDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'MP3 Restoration'**
  String get audioMp3UniquePlaylistRestorationDialogTitle;

  /// No description provided for @audioMp3UniquePlaylistRestorationExplanation.
  ///
  /// In en, this message translates to:
  /// **'Only the MP3 relative to the audios listed in the playlist which are not already present in the playlist are restorable.'**
  String get audioMp3UniquePlaylistRestorationExplanation;

  /// No description provided for @playlistInvalidRootPathWarning.
  ///
  /// In en, this message translates to:
  /// **'The defined path \"{playlistRootPath}\" is invalid since the playlists final dir name \'{wrongName}\' is not equal to \'playlists\'. Please define a valid playlist directory and retry changing the playlists root path.'**
  String playlistInvalidRootPathWarning(
      Object playlistRootPath, Object wrongName);

  /// No description provided for @restoringUniquePlaylistAudioMp3.
  ///
  /// In en, this message translates to:
  /// **'Restoring {playlistTitle} audio files from ZIP ...'**
  String restoringUniquePlaylistAudioMp3(Object playlistTitle);

  /// No description provided for @movingAudioMp3Zip.
  ///
  /// In en, this message translates to:
  /// **'Moving {mp3ZipName} to selected dir ...'**
  String movingAudioMp3Zip(Object mp3ZipName);

  /// No description provided for @playlistsMp3RestorationHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlists Mp3 Restoration Function'**
  String get playlistsMp3RestorationHelpTitle;

  /// No description provided for @playlistsMp3RestorationHelpContent.
  ///
  /// In en, this message translates to:
  /// **'This function is useful in the situation where playlists were restored from a ZIP file which only contained the playlists, comments and pictures JSON files and so did not contain the audio MP3 files.'**
  String get playlistsMp3RestorationHelpContent;

  /// No description provided for @uniquePlaylistMp3RestorationHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlist Mp3 Restoration Function'**
  String get uniquePlaylistMp3RestorationHelpTitle;

  /// No description provided for @uniquePlaylistMp3RestorationHelpContent.
  ///
  /// In en, this message translates to:
  /// **'This function is useful in the situation where the playlist was restored from a ZIP file which only contained the playlist, comments and pictures JSON files and so did not contain the audio MP3 files.'**
  String get uniquePlaylistMp3RestorationHelpContent;

  /// No description provided for @playlistsMp3SaveHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlists Mp3 Save Function'**
  String get playlistsMp3SaveHelpTitle;

  /// No description provided for @playlistsMp3SaveHelpContent.
  ///
  /// In en, this message translates to:
  /// **'If you already executed this save MP3 functionality a couple of weeks ago, the following example will help you to understand the result of the new save playlists MP3 execution. Consider that the first created MP3 saved ZIP is named audioLearn_mp3_from_2023-05-17_07_03_50_on_2025-06-15_11_59_38.zip. Now, on {dateOne} at 10:00 you do a new playlist MP3 backup with setting the oldest audio download date to {dateTwo}, i.e. the date on which the previous MP3 ZIP file was created. But if the newly created ZIP file is named audioLearn_mp3_from_2025-06-20_09_25_34_on_2025-07-27_16_23_32.zip and not audioLearn_mp3_from_2025-06-15_on_2025-07-27_16_23_32.zip, the reason is that the oldest downloaded audio after {dateTwo} was downloaded on {dateThree} 09:25:34.'**
  String playlistsMp3SaveHelpContent(
      Object dateOne, Object dateThree, Object dateTwo);

  /// No description provided for @uniquePlaylistMp3SaveHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlist Mp3 Save Function'**
  String get uniquePlaylistMp3SaveHelpTitle;

  /// No description provided for @uniquePlaylistMp3SaveHelpContent.
  ///
  /// In en, this message translates to:
  /// **'If you already executed this save MP3 functionality a couple of weeks ago, the following example will help you to understand the result of the new save playlist MP3 execution. Consider that the first created MP3 saved ZIP is named audioLearn_mp3_from_2023-05-17_07_03_50_on_2025-06-15_11_59_38.zip. Now, on {dateOne} at 10:00 you do a new playlist MP3 backup with setting the oldest audio download date to {dateTwo}, i.e. the date on which the previous MP3 ZIP file was created. But if the newly created ZIP file is named audioLearn_mp3_from_2025-06-20_09_25_34_on_2025-07-27_16_23_32.zip and not audioLearn_mp3_from_2025-06-15_on_2025-07-27_16_23_32.zip, the reason is that the oldest downloaded audio after {dateTwo} was downloaded on {dateThree} 09:25:34.'**
  String uniquePlaylistMp3SaveHelpContent(
      Object dateOne, Object dateThree, Object dateTwo);

  /// No description provided for @insufficientStorageSpace.
  ///
  /// In en, this message translates to:
  /// **'Insufficient storage space detected when selecting the ZIP file containing MP3\'s.'**
  String get insufficientStorageSpace;

  /// No description provided for @pathError.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve file path.'**
  String get pathError;

  /// No description provided for @androidStorageAccessErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not access Android external storage.'**
  String get androidStorageAccessErrorMessage;

  /// No description provided for @zipTooLargeFileInfoLabel.
  ///
  /// In en, this message translates to:
  /// **'Those files are too large to be included in the MP3 saved ZIP file and so were not saved:\n'**
  String get zipTooLargeFileInfoLabel;

  /// No description provided for @mp3ZipFileSizeLimitInMbLabel.
  ///
  /// In en, this message translates to:
  /// **'ZIP file size limit in MB'**
  String get mp3ZipFileSizeLimitInMbLabel;

  /// No description provided for @mp3ZipFileSizeLimitInMbTooltip.
  ///
  /// In en, this message translates to:
  /// **'Maximum size in MB for each ZIP file when saving audio MP3 files. On Android devices, if this limit is set too high, the save operation will fail due to memory constraints. Multiple ZIP files will be created automatically if the total content exceeds this limit.'**
  String get mp3ZipFileSizeLimitInMbTooltip;

  /// No description provided for @zipTooLargeOneFileInfoLabel.
  ///
  /// In en, this message translates to:
  /// **'This file is too large to be included in the MP3 saved ZIP file and so was not saved:\n'**
  String get zipTooLargeOneFileInfoLabel;

  /// No description provided for @androidZipFileCreationError.
  ///
  /// In en, this message translates to:
  /// **'Error saving the ZIP file {zipFileName}. This is due to its too large size: {zipFileSize}.\n\nSolution: in the application settings, reduce the maximum ZIP file size and re-run the save MP3 to ZIP function.'**
  String androidZipFileCreationError(Object zipFileName, Object zipFileSize);

  /// No description provided for @obtainMostRecentAudioDownloadDateTimeMenu.
  ///
  /// In en, this message translates to:
  /// **'Get latest Audio download Date'**
  String get obtainMostRecentAudioDownloadDateTimeMenu;

  /// No description provided for @obtainMostRecentAudioDownloadDateTimeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Finds the most recent audio download date across all playlists. Use this date when creating ZIP backups with the \'Save Playlists Audios MP3 to ZIP File(s)\' menu to ensure you capture only the newest audio files for restoring them to the current app version.'**
  String get obtainMostRecentAudioDownloadDateTimeTooltip;

  /// No description provided for @displayNewestAudioDownloadDateTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Latest Audio Download Date'**
  String get displayNewestAudioDownloadDateTimeTitle;

  /// No description provided for @displayNewestAudioDownloadDateTime.
  ///
  /// In en, this message translates to:
  /// **'This is the latest audio download date/time: {newestAudioDownloadDateTime}.'**
  String displayNewestAudioDownloadDateTime(Object newestAudioDownloadDateTime);

  /// No description provided for @audioTitleModificationHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Using Audio Title Modification'**
  String get audioTitleModificationHelpTitle;

  /// No description provided for @audioTitleModificationHelpContent.
  ///
  /// In en, this message translates to:
  /// **'For example, if in a playlist we have three audios that were downloaded in this order:\n  last\n  first\n  second\nand we want to listen to them in order according to their title, it is useful to rename the titles this way:\n  3-last\n  1-first\n  2-second\n\nThen you need to click on the \"Sort/Filter Audio ...\" menu to define a sort that you name and that sorts the audios according to their title.\n\nOnce the \"Sort and Filter Parameters\" dialog is open, define the filter name in the \"Save as:\" field and open the \"Sort by:\" list. Select \"Audio title\" and then remove \"Audio downl date\". Finally, click on \"Save\".\n\nOnce this sort is defined, check that it is selected and use the \"Save Sort/Filter Parameters to Playlist ...\" menu by selecting the screen for which the sort will be applied. This way, the audios will be played in the order in which you want to listen to them.'**
  String get audioTitleModificationHelpContent;

  /// No description provided for @playlistConvertTextToAudioMenu.
  ///
  /// In en, this message translates to:
  /// **'Convert Text to Audio ...'**
  String get playlistConvertTextToAudioMenu;

  /// No description provided for @playlistConvertTextToAudioMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Convert a text to a listenable audio which is added to the playlist. Adding positionned comments or a picture to this audio will be possible like for the other audios.'**
  String get playlistConvertTextToAudioMenuTooltip;

  /// No description provided for @convertTextToAudioDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Convert Text to Audio'**
  String get convertTextToAudioDialogTitle;

  /// No description provided for @textToConvert.
  ///
  /// In en, this message translates to:
  /// **'Text to convert, {brace_1} = silence'**
  String textToConvert(Object brace_1);

  /// No description provided for @textToConvertTextFieldTooltip.
  ///
  /// In en, this message translates to:
  /// **'Enter the text to convert an audio added to the playlist. The audio is created using the selected voice. Add one or several brace(s) to include one or several second(s) of silence at this position.'**
  String get textToConvertTextFieldTooltip;

  /// No description provided for @textToConvertTextFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your text here ...'**
  String get textToConvertTextFieldHint;

  /// No description provided for @conversionVoiceSelection.
  ///
  /// In en, this message translates to:
  /// **'Voice selection:'**
  String get conversionVoiceSelection;

  /// No description provided for @masculineVoice.
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get masculineVoice;

  /// No description provided for @femineVoice.
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get femineVoice;

  /// No description provided for @listenTextButton.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listenTextButton;

  /// No description provided for @listenTextButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Listening the text to convert with the selected voice.'**
  String get listenTextButtonTooltip;

  /// No description provided for @createAudioFileButton.
  ///
  /// In en, this message translates to:
  /// **'Create MP3'**
  String get createAudioFileButton;

  /// No description provided for @createAudioFileButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create the audio file using the selected voice and add it to the playlist.'**
  String get createAudioFileButtonTooltip;

  /// No description provided for @stopListeningTextButton.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopListeningTextButton;

  /// No description provided for @stopListeningTextButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Stop listening the text using the selected voice.'**
  String get stopListeningTextButtonTooltip;

  /// No description provided for @mp3FileName.
  ///
  /// In en, this message translates to:
  /// **'MP3 File Name'**
  String get mp3FileName;

  /// No description provided for @enterMp3FileName.
  ///
  /// In en, this message translates to:
  /// **'Enter the MP3 file name'**
  String get enterMp3FileName;

  /// No description provided for @selectMp3FileToReplace.
  ///
  /// In en, this message translates to:
  /// **'Select existing file'**
  String get selectMp3FileToReplace;

  /// No description provided for @selectMp3FileToReplaceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Use this option if you have modified the text to be converted to audio or changed the selected voice and want to replace the existing MP3 file.'**
  String get selectMp3FileToReplaceTooltip;

  /// No description provided for @myMp3FileName.
  ///
  /// In en, this message translates to:
  /// **'file name'**
  String get myMp3FileName;

  /// No description provided for @createMP3.
  ///
  /// In en, this message translates to:
  /// **'Create MP3'**
  String get createMP3;

  /// No description provided for @audioImportedFromTextToSpeechToLocalPlaylist.
  ///
  /// In en, this message translates to:
  /// **'The audio created by the text to MP3 conversion\n\n{importedAudioFileNames}\n\nwas {replacedOrAdded} local playlist \"{toPlaylistTitle}\".'**
  String audioImportedFromTextToSpeechToLocalPlaylist(
      Object importedAudioFileNames,
      Object replacedOrAdded,
      Object toPlaylistTitle);

  /// No description provided for @audioImportedFromTextToSpeechToYoutubePlaylist.
  ///
  /// In en, this message translates to:
  /// **'The audio created by the text to MP3 conversion\n\n{importedAudioFileNames}\n\nwas {replacedOrAdded} Youtube playlist \"{toPlaylistTitle}\".'**
  String audioImportedFromTextToSpeechToYoutubePlaylist(
      Object importedAudioFileNames,
      Object replacedOrAdded,
      Object toPlaylistTitle);

  /// No description provided for @addedTo.
  ///
  /// In en, this message translates to:
  /// **'added to'**
  String get addedTo;

  /// No description provided for @replacedIn.
  ///
  /// In en, this message translates to:
  /// **'replaced in'**
  String get replacedIn;

  /// No description provided for @replaceExistingAudioInPlaylist.
  ///
  /// In en, this message translates to:
  /// **'The file \"{fileName}.mp3\" already exists in the playlist \"{playlistTitle}\". If you want to replace it with the new version, click on the \"Confirm\" button. Otherwise, click on the \"Cancel\" button and you will be able to define a different file name.'**
  String replaceExistingAudioInPlaylist(Object fileName, Object playlistTitle);

  /// No description provided for @speech.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get speech;

  /// No description provided for @textToSpeech.
  ///
  /// In en, this message translates to:
  /// **'converted'**
  String get textToSpeech;

  /// No description provided for @audioTextToSpeechInfoDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Converted Audio Info'**
  String get audioTextToSpeechInfoDialogTitle;

  /// No description provided for @audioExtractedInfoDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio Extracted through Comments Info'**
  String get audioExtractedInfoDialogTitle;

  /// No description provided for @convertedAudioDateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Converted text first date time'**
  String get convertedAudioDateTimeLabel;

  /// No description provided for @fromMp3ZipFileUsedToRestoreUniquePlaylist.
  ///
  /// In en, this message translates to:
  /// **'playlist(s) from the MP3 zip file \"{zipFilePathNName}\"'**
  String fromMp3ZipFileUsedToRestoreUniquePlaylist(Object zipFilePathNName);

  /// No description provided for @fromMp3ZipFileUsedToRestoreMultiplePlaylists.
  ///
  /// In en, this message translates to:
  /// **'playlist(s) from one or several MP3 zip files contained in directory \"{zipFilePathNName}\"'**
  String fromMp3ZipFileUsedToRestoreMultiplePlaylists(Object zipFilePathNName);

  /// No description provided for @fromMultipleMp3ZipFileUsedToRestoreMultiplePlaylists.
  ///
  /// In en, this message translates to:
  /// **'playlist(s) from the multiple MP3 zip files contained in dir \"{zipFilePathNName}\"'**
  String fromMultipleMp3ZipFileUsedToRestoreMultiplePlaylists(
      Object zipFilePathNName);

  /// No description provided for @confirmMp3RestorationFromMp3Zip.
  ///
  /// In en, this message translates to:
  /// **'Restored {audioNNumber} audio(s) MP3 in {playlistsNumber} {secondMsgPart}.'**
  String confirmMp3RestorationFromMp3Zip(
      Object audioNNumber, Object playlistsNumber, Object secondMsgPart);

  /// No description provided for @restorePlaylistTitlesOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlist Titles Order Restoration'**
  String get restorePlaylistTitlesOrderTitle;

  /// No description provided for @restorePlaylistTitlesOrderMessage.
  ///
  /// In en, this message translates to:
  /// **'A previous playlist titles order file is available in the selected playlist root path. Do you want to restore this saved order or keep the current playlist titles order? Click on \"Confirm\" to restore the saved order or on \"Cancel\" to keep the current order.'**
  String get restorePlaylistTitlesOrderMessage;

  /// Warning message indicating that a unique playlist was restored from ZIP created from playlist item menu
  ///
  /// In en, this message translates to:
  /// **'Restored {playlistsNumber} playlist saved individually, {commentsNumber} comment and {picturesNumber} picture JSON files as well as {addedPictureJpgNumber} picture JPG file(s) in the application pictures directory and {audiosNumber} audio reference(s) and {addedCommentNumber} added plus {deletedCommentNumber} deleted plus {updatedCommentNumber} modified comment(s) in existing audio comment file(s) from \"{filePathName}\".{deletedAudioAndMp3FilesMsg}{addedAtEndOfPlaylistLstMsg}'**
  String doRestoreUniquePlaylistFromZip(
      Object playlistsNumber,
      Object audiosNumber,
      Object commentsNumber,
      Object updatedCommentNumber,
      Object addedCommentNumber,
      Object deletedCommentNumber,
      Object picturesNumber,
      Object addedPictureJpgNumber,
      Object deletedAudioAndMp3FilesMsg,
      Object filePathName,
      Object addedAtEndOfPlaylistLstMsg);

  /// Warning message indicating that a unique playlist was restored from ZIP created from playlist item menu
  ///
  /// In en, this message translates to:
  /// **'Restored {playlistsNumber} playlist, {commentsNumber} comment and {picturesNumber} picture JSON files as well as {addedPictureJpgNumber} picture JPG file(s) in the application pictures directory and {audiosNumber} audio reference(s) and {addedCommentNumber} added plus {deletedCommentNumber} deleted plus {updatedCommentNumber} modified comment(s) in existing audio comment file(s) and the application settings from \"{filePathName}\".{deletedAudioAndMp3FilesMsg}{addedAtEndOfPlaylistLstMsg}'**
  String doRestoreMultiplePlaylistFromZip(
      Object playlistsNumber,
      Object audiosNumber,
      Object commentsNumber,
      Object updatedCommentNumber,
      Object addedCommentNumber,
      Object deletedCommentNumber,
      Object picturesNumber,
      Object addedPictureJpgNumber,
      Object deletedAudioAndMp3FilesMsg,
      Object filePathName,
      Object addedAtEndOfPlaylistLstMsg);

  /// No description provided for @newPlaylistsAddedAtEndOfPlaylistLst.
  ///
  /// In en, this message translates to:
  /// **'\n\nThe created playlists are positioned at the end of the playlist list.'**
  String get newPlaylistsAddedAtEndOfPlaylistLst;

  /// No description provided for @uniquePlaylistAddedAtEndOfPlaylistLst.
  ///
  /// In en, this message translates to:
  /// **'\n\nSince the playlist\n  \"{addedPlaylistTitles}\"\nwas created, it is positioned at the end of the playlist list.'**
  String uniquePlaylistAddedAtEndOfPlaylistLst(Object addedPlaylistTitles);

  /// No description provided for @multiplePlaylistsAddedAtEndOfPlaylistLst.
  ///
  /// In en, this message translates to:
  /// **'\n\nSince the playlists\n  \"{addedPlaylistTitles}\"\nwere created, they are positioned at the end of the playlist list.'**
  String multiplePlaylistsAddedAtEndOfPlaylistLst(Object addedPlaylistTitles);

  /// No description provided for @playlistsSaveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlists Backup to ZIP'**
  String get playlistsSaveDialogTitle;

  /// No description provided for @playlistsSaveExplanation.
  ///
  /// In en, this message translates to:
  /// **'Checking the \"Add all JPG pictures to ZIP\" checkbox will add all the application audio pictures to the created ZIP. This is only useful if the ZIP file will be used to restore another application.'**
  String get playlistsSaveExplanation;

  /// No description provided for @addPictureJpgFilesToZip.
  ///
  /// In en, this message translates to:
  /// **'Add all JPG pictures to ZIP'**
  String get addPictureJpgFilesToZip;

  /// No description provided for @confirmAudioFromPlaylistDeletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion of the audio \"{audioTitle}\" from the Youtube playlist'**
  String confirmAudioFromPlaylistDeletionTitle(Object audioTitle);

  /// No description provided for @confirmAudioFromPlaylistDeletion.
  ///
  /// In en, this message translates to:
  /// **'Delete the audio \"{audioTitle}\" from the playlist \"{playlistTitle}\" defined on the Youtube site, otherwise the audio will be downloaded again during the next playlist download. Or click on \"Cancel\" and choose \"Delete Audio ...\" instead of \"Delete Audio from Playlist as well ...\". So, the audio will be removed from the playable audio list, but will remain in the downloaded audio list, which will prevent its re-download.'**
  String confirmAudioFromPlaylistDeletion(
      Object audioTitle, Object playlistTitle);

  /// No description provided for @deletedAudioAndMp3FilesMessage.
  ///
  /// In en, this message translates to:
  /// **'\n\nDeleted {deletedAudioAndMp3FilesNumber} audio(s)\n  \"{deletedAudioTitles}\"\nand their comment(s) and picture(s) as well as their MP3 file.'**
  String deletedAudioAndMp3FilesMessage(
      Object deletedAudioAndMp3FilesNumber, Object deletedAudioTitles);

  /// No description provided for @deletedExistingPlaylistsMessage.
  ///
  /// In en, this message translates to:
  /// **'\n\nDeleted {deletedExistingPlaylistNumber} playlist(s)\n  \"{deletedExistingPlaylistTitles}\"\nno longer present in the restore ZIP file and not created or modified after the ZIP creation.'**
  String deletedExistingPlaylistsMessage(Object deletedExistingPlaylistNumber,
      Object deletedExistingPlaylistTitles);

  /// No description provided for @selectFileOrDirTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore MP3 Files'**
  String get selectFileOrDirTitle;

  /// No description provided for @selectQuestion.
  ///
  /// In en, this message translates to:
  /// **'What would you like to select ?'**
  String get selectQuestion;

  /// No description provided for @selectZipFile.
  ///
  /// In en, this message translates to:
  /// **'A Single ZIP File'**
  String get selectZipFile;

  /// No description provided for @selectDirectory.
  ///
  /// In en, this message translates to:
  /// **'A Directory with ZIP\'s'**
  String get selectDirectory;

  /// No description provided for @dateFormatddMMyyyy.
  ///
  /// In en, this message translates to:
  /// **'dd/MM/yyyy'**
  String get dateFormatddMMyyyy;

  /// No description provided for @dateFormatMMddyyyy.
  ///
  /// In en, this message translates to:
  /// **'MM/dd/yyyy'**
  String get dateFormatMMddyyyy;

  /// No description provided for @dateFormatyyyyMMdd.
  ///
  /// In en, this message translates to:
  /// **'yyyy/MM/dd'**
  String get dateFormatyyyyMMdd;

  /// No description provided for @clearEndLineSelection.
  ///
  /// In en, this message translates to:
  /// **'Remove line breaks'**
  String get clearEndLineSelection;

  /// No description provided for @clearEndLineSelectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Line break invisible characters in incorrect locations can cause unwanted pauses in the generated audio. Removing them improves audio quality.'**
  String get clearEndLineSelectionTooltip;

  /// No description provided for @lastCommentDateTime.
  ///
  /// In en, this message translates to:
  /// **'Last comment date/time'**
  String get lastCommentDateTime;

  /// No description provided for @playableAudioDialogSortDescriptionTooltipTopLastCommentDateTimeBigger.
  ///
  /// In en, this message translates to:
  /// **'Audio at the top has a last comment created or modified more recently than those at the bottom.'**
  String
      get playableAudioDialogSortDescriptionTooltipTopLastCommentDateTimeBigger;

  /// No description provided for @playableAudioDialogSortDescriptionTooltipTopLastCommentDateTimeSmaller.
  ///
  /// In en, this message translates to:
  /// **'Audio at the top has a last comment created or modified less recently than those at the bottom.'**
  String
      get playableAudioDialogSortDescriptionTooltipTopLastCommentDateTimeSmaller;

  /// No description provided for @audioStateNoComment.
  ///
  /// In en, this message translates to:
  /// **'Not commented'**
  String get audioStateNoComment;

  /// No description provided for @commentedOn.
  ///
  /// In en, this message translates to:
  /// **'Commented on'**
  String get commentedOn;

  /// No description provided for @convertingDownloadedAudioToMP3.
  ///
  /// In en, this message translates to:
  /// **'Converting downloaded audio to MP3 ...'**
  String get convertingDownloadedAudioToMP3;

  /// No description provided for @creatingMp3.
  ///
  /// In en, this message translates to:
  /// **'Creating MP3'**
  String get creatingMp3;

  /// No description provided for @renamePlaylistMenu.
  ///
  /// In en, this message translates to:
  /// **'Rename Playlist ...'**
  String get renamePlaylistMenu;

  /// No description provided for @renamePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Rename Playlist'**
  String get renamePlaylist;

  /// No description provided for @renamePlaylistLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get renamePlaylistLabel;

  /// No description provided for @renamePlaylistTooltip.
  ///
  /// In en, this message translates to:
  /// **'Renaming the playlist ...'**
  String get renamePlaylistTooltip;

  /// No description provided for @renamePlaylistButton.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renamePlaylistButton;

  /// No description provided for @renamePictureFileNameAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'The picture file name \"{fileName}.json\" already exists in the picture directory and so renaming the audio file with the name \"{fileName}.mp3\" is not possible.'**
  String renamePictureFileNameAlreadyUsed(Object fileName);

  /// No description provided for @playlistWithTitleAlreadyExist.
  ///
  /// In en, this message translates to:
  /// **'A playlist with the title \"{title}\" already exists in the playlists list and so the playlist can\'t be renamed to this title.'**
  String playlistWithTitleAlreadyExist(Object title);

  /// No description provided for @invalidModifiedPlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'The modified playlist title \"{playlistTitle}\" can not contain any comma. Please correct the title and retry ...'**
  String invalidModifiedPlaylistTitle(Object playlistTitle);

  /// Warning announcing that importing the audios from mp4 file failed.
  ///
  /// In en, this message translates to:
  /// **'Importing the audio of the mp4 video \"{videoTitle}\" FAILED: \"{exceptionMessage}\".'**
  String importingMp4Error(Object videoTitle, Object exceptionMessage);

  /// No description provided for @convertingMp4ToMP3.
  ///
  /// In en, this message translates to:
  /// **'Converting imported MP4 to MP3 ...'**
  String get convertingMp4ToMP3;

  /// No description provided for @addPositionToAudioTitleMenu.
  ///
  /// In en, this message translates to:
  /// **'Add Position to Audios Title'**
  String get addPositionToAudioTitleMenu;

  /// No description provided for @moveAudioToPositionMenu.
  ///
  /// In en, this message translates to:
  /// **'Set Audio to Position ...'**
  String get moveAudioToPositionMenu;

  /// No description provided for @moveAudioToPosition.
  ///
  /// In en, this message translates to:
  /// **'Move Audio to Int Position'**
  String get moveAudioToPosition;

  /// No description provided for @audioIntPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio int position'**
  String get audioIntPositionLabel;

  /// No description provided for @moveAudioToPositionButton.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get moveAudioToPositionButton;

  /// No description provided for @audioPositionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Define the int position which will be addid to the audio title.'**
  String get audioPositionTooltip;

  /// No description provided for @extractCommentsToMp3TextButton.
  ///
  /// In en, this message translates to:
  /// **'Extract comments to MP3'**
  String get extractCommentsToMp3TextButton;

  /// No description provided for @extractCommentsToMp3TextButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Extract audio segments defined by comment timestamps to MP3.'**
  String get extractCommentsToMp3TextButtonTooltip;

  /// No description provided for @audioExtractorDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments to MP3'**
  String get audioExtractorDialogTitle;

  /// No description provided for @editCommentDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Comment'**
  String get editCommentDialogTitle;

  /// No description provided for @addCommentDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Comment'**
  String get addCommentDialogTitle;

  /// No description provided for @deleteCommentDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Comment'**
  String get deleteCommentDialogTitle;

  /// No description provided for @deleteCommentExplanation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this comment ?'**
  String get deleteCommentExplanation;

  /// No description provided for @clearAllCommentDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all Comments'**
  String get clearAllCommentDialogTitle;

  /// No description provided for @clearAllCommentExplanation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all comments ?'**
  String get clearAllCommentExplanation;

  /// No description provided for @maxDuration.
  ///
  /// In en, this message translates to:
  /// **'Total audio duration'**
  String get maxDuration;

  /// No description provided for @startPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Start position (h:mm:ss.t)'**
  String get startPositionLabel;

  /// No description provided for @endPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'End position (h:mm:ss.t)'**
  String get endPositionLabel;

  /// No description provided for @silenceDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Silence duration after end (h:mm:ss.t)'**
  String get silenceDurationLabel;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @silence.
  ///
  /// In en, this message translates to:
  /// **'silence'**
  String get silence;

  /// No description provided for @totalDuration.
  ///
  /// In en, this message translates to:
  /// **'Total duration'**
  String get totalDuration;

  /// No description provided for @clearAllButton.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAllButton;

  /// No description provided for @extractMp3Button.
  ///
  /// In en, this message translates to:
  /// **'Extract MP3'**
  String get extractMp3Button;

  /// No description provided for @addAtLeastOneCommentMessage.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one comment to the audio'**
  String get addAtLeastOneCommentMessage;

  /// No description provided for @noCommentFoundInAudioMessage.
  ///
  /// In en, this message translates to:
  /// **'No comment found in the audio'**
  String get noCommentFoundInAudioMessage;

  /// No description provided for @inMusicQualityLabel.
  ///
  /// In en, this message translates to:
  /// **'In music quality'**
  String get inMusicQualityLabel;

  /// No description provided for @inMusicQuality.
  ///
  /// In en, this message translates to:
  /// **'musicQuality'**
  String get inMusicQuality;

  /// No description provided for @fadeStartPosition.
  ///
  /// In en, this message translates to:
  /// **'Increase duration'**
  String get fadeStartPosition;

  /// No description provided for @soundReductionPosition.
  ///
  /// In en, this message translates to:
  /// **'Reduction position'**
  String get soundReductionPosition;

  /// No description provided for @soundReductionDuration.
  ///
  /// In en, this message translates to:
  /// **'Reduction duration'**
  String get soundReductionDuration;

  /// No description provided for @fadeStartPositionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Defines how long the audio fades in from 0% to 100% at the start of the comment.'**
  String get fadeStartPositionTooltip;

  /// No description provided for @soundReductionPositionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Defines the position where the audio starts fading out from 100% to 0%.'**
  String get soundReductionPositionTooltip;

  /// No description provided for @soundReductionDurationTooltip.
  ///
  /// In en, this message translates to:
  /// **'Defines how long the audio fades out from 100% to 0%. Ideally, the fade-out start position plus its duration should match the comment end position.'**
  String get soundReductionDurationTooltip;

  /// No description provided for @volumeFadeOutOptional.
  ///
  /// In en, this message translates to:
  /// **'Volume fade-out (optional)'**
  String get volumeFadeOutOptional;

  /// No description provided for @fadeStartPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Fade start position (h:mm:ss.t)'**
  String get fadeStartPositionLabel;

  /// No description provided for @fadeStartPositionHintText.
  ///
  /// In en, this message translates to:
  /// **'0:00.0 (absolute time in source file)'**
  String get fadeStartPositionHintText;

  /// No description provided for @fadeStartPositionHelperText.
  ///
  /// In en, this message translates to:
  /// **'Position where volume starts fading to 0'**
  String get fadeStartPositionHelperText;

  /// No description provided for @fadeDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Fade duration (h:mm:ss.t)'**
  String get fadeDurationLabel;

  /// No description provided for @fadeDurationHelperText.
  ///
  /// In en, this message translates to:
  /// **'Duration to fade volume from 100% to 0%'**
  String get fadeDurationHelperText;

  /// No description provided for @endPositionError.
  ///
  /// In en, this message translates to:
  /// **'End position must be after start position ({startPosition}) and not exceed'**
  String endPositionError(Object startPosition);

  /// No description provided for @startPositionError.
  ///
  /// In en, this message translates to:
  /// **'Start position must be between 0 and {inclusive} inclusive'**
  String startPositionError(Object inclusive);

  /// No description provided for @negativeSilenceDurationError.
  ///
  /// In en, this message translates to:
  /// **'Silence duration cannot be negative'**
  String get negativeSilenceDurationError;

  /// No description provided for @negativeSoundDurationError.
  ///
  /// In en, this message translates to:
  /// **'Sound reduction duration cannot be negative'**
  String get negativeSoundDurationError;

  /// No description provided for @negativeSoundPositionError.
  ///
  /// In en, this message translates to:
  /// **'Sound reduction position cannot be negative'**
  String get negativeSoundPositionError;

  /// No description provided for @soundPositionBeforeStartError.
  ///
  /// In en, this message translates to:
  /// **'Sound reduction position ({value}) must be after or at the comment start position'**
  String soundPositionBeforeStartError(Object value);

  /// No description provided for @soundPositionBeyondEndError.
  ///
  /// In en, this message translates to:
  /// **'Sound reduction position ({value}) must be before the comment end position'**
  String soundPositionBeyondEndError(Object value);

  /// No description provided for @soundPositionPlusDurationBeyondEndError.
  ///
  /// In en, this message translates to:
  /// **'Sound reduction of {value1} must complete before or at the comment end position ({value2})'**
  String soundPositionPlusDurationBeyondEndError(Object value1, Object value2);

  /// No description provided for @loadedComments.
  ///
  /// In en, this message translates to:
  /// **'Loaded {commentNumber} comment(s)'**
  String loadedComments(Object commentNumber);

  /// No description provided for @skippedComments.
  ///
  /// In en, this message translates to:
  /// **'({commentNumber} skipped)'**
  String skippedComments(Object commentNumber);

  /// No description provided for @fadeInDurationError.
  ///
  /// In en, this message translates to:
  /// **'Increase duration cannot be negative'**
  String get fadeInDurationError;

  /// No description provided for @fadeInExceedsCommentDurationError.
  ///
  /// In en, this message translates to:
  /// **'Increase duration end ({detail}) cannot exceed comment end position'**
  String fadeInExceedsCommentDurationError(Object detail);

  /// No description provided for @volumeFadeInOptional.
  ///
  /// In en, this message translates to:
  /// **'Volume fade-in (optional)'**
  String get volumeFadeInOptional;

  /// No description provided for @fadeInDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Increase duration (h:mm:ss.t)'**
  String get fadeInDurationLabel;

  /// No description provided for @fadeInDurationHelperText.
  ///
  /// In en, this message translates to:
  /// **'Duration to fade volume from 0% to 100% at comment start'**
  String get fadeInDurationHelperText;

  /// No description provided for @extractedMp3Saved.
  ///
  /// In en, this message translates to:
  /// **'Extracted MP3 saved to'**
  String get extractedMp3Saved;

  /// No description provided for @inDirectoryLabel.
  ///
  /// In en, this message translates to:
  /// **'In directory'**
  String get inDirectoryLabel;

  /// No description provided for @inDirectoryLabelTooltip.
  ///
  /// In en, this message translates to:
  /// **'The created MP3 is stored in the \"audiolearn/saved/MP3\" directory.'**
  String get inDirectoryLabelTooltip;

  /// No description provided for @inPlaylistLabel.
  ///
  /// In en, this message translates to:
  /// **'In playlist'**
  String get inPlaylistLabel;

  /// No description provided for @inPlaylistLabelTooltip.
  ///
  /// In en, this message translates to:
  /// **'An audio containing the created MP3 and its associated comment(s) is added to the selected playlist.'**
  String get inPlaylistLabelTooltip;

  /// No description provided for @noPlaylistSelectedForExtractedMp3LocationWarning.
  ///
  /// In en, this message translates to:
  /// **'No playlist selected for the addition of the audio containing the extracted MP3. Select one playlist and retry ...'**
  String get noPlaylistSelectedForExtractedMp3LocationWarning;

  /// No description provided for @extractedAudioDateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Extracted audio date time'**
  String get extractedAudioDateTimeLabel;

  /// No description provided for @extractedFromPlaylistLabel.
  ///
  /// In en, this message translates to:
  /// **'Extracted from playlist'**
  String get extractedFromPlaylistLabel;

  /// No description provided for @extracted.
  ///
  /// In en, this message translates to:
  /// **'extracted'**
  String get extracted;

  /// No description provided for @extractedAudioNotAddedToPlaylistMessage.
  ///
  /// In en, this message translates to:
  /// **'The extracted audio was not added to the \"{targetPlaylist}\" playlist because it already exists in it. To resolve this, please delete the existing extracted audio before running the extraction again.'**
  String extractedAudioNotAddedToPlaylistMessage(Object targetPlaylist);

  /// No description provided for @commentWasDeleted.
  ///
  /// In en, this message translates to:
  /// **'Comment not included'**
  String get commentWasDeleted;

  /// No description provided for @commentWasDeletedTooltip.
  ///
  /// In en, this message translates to:
  /// **'This comment was previously removed from the \"Comments to MP3\" list so it is not included in the extracted MP3. To include it again, edit the comment and save it.'**
  String get commentWasDeletedTooltip;

  /// No description provided for @deleteInvalidCommentsMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete invalid comment(s) with end position greater than audio duration which is {audioDuration}.'**
  String deleteInvalidCommentsMessage(Object audioDuration);

  /// No description provided for @fileNotExistError.
  ///
  /// In en, this message translates to:
  /// **'File does not exist'**
  String get fileNotExistError;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @replaceMp3FileDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'MP3 File Replacement'**
  String get replaceMp3FileDialogTitle;

  /// No description provided for @extractAudioPlaySpeed.
  ///
  /// In en, this message translates to:
  /// **'Play speed'**
  String get extractAudioPlaySpeed;

  /// No description provided for @extractAudioPlaySpeedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Defines the play speed of this comment audio extraction part'**
  String get extractAudioPlaySpeedTooltip;

  /// No description provided for @invalidPlaySpeedError.
  ///
  /// In en, this message translates to:
  /// **'The defined play speed must be between 0.5 and 2.0'**
  String get invalidPlaySpeedError;

  /// No description provided for @playSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Play speed'**
  String get playSpeedLabel;

  /// No description provided for @extractionToPlaylistNotPossibleWhenPlaySpeedDiffersFromOne.
  ///
  /// In en, this message translates to:
  /// **'Extraction to playlist not possible when play speed is different from 1.0 in one of the extracted comments.'**
  String get extractionToPlaylistNotPossibleWhenPlaySpeedDiffersFromOne;

  /// No description provided for @loadedCommentsFromMultipleAudios.
  ///
  /// In en, this message translates to:
  /// **'Loaded {audioCount} audios with {segmentCount} total segments.'**
  String loadedCommentsFromMultipleAudios(
      Object audioCount, Object segmentCount);

  /// No description provided for @fadeInDuration.
  ///
  /// In en, this message translates to:
  /// **'Volume fade-in'**
  String get fadeInDuration;

  /// No description provided for @audioFileNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'Audio file not found'**
  String get audioFileNotFoundError;

  /// No description provided for @segmentEndPositionError.
  ///
  /// In en, this message translates to:
  /// **'Comment end position ({segmentEndPosition}) exceeds audio duration ({zAudioDuration}) for'**
  String segmentEndPositionError(
      Object segmentEndPosition, Object zAudioDuration);

  /// No description provided for @audios.
  ///
  /// In en, this message translates to:
  /// **'Audios'**
  String get audios;

  /// No description provided for @audioExtractorMultiAudiosDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Audios to MP3'**
  String get audioExtractorMultiAudiosDialogTitle;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'{commentTitle}. Invalid reduction position: fade start correspond to {reductionPos} - {startPos} = {fadeStart} which is greater than segment duration {segDuration} = {endPos} - {startPos}. Solution: close the extract dialog. Then, remove all comments of the audio containing \"{commentTitle}\" and reexecute the \"Extract filtered Audios to unique MP3 ...\" menu.'**
  String invalidReductionPositionError(Object commentTitle, Object reductionPos,
      Object startPos, Object fadeStart, Object segDuration, Object endPos);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

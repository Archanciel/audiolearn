import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum PopupMenuButtonType {
  openSortFilterAudioDialog,
  clearSortFilterAudioParmsHistory,
  saveSortFilterAudioParmsToPlaylist,
  removeSortFilterAudioParmsFromPlaylist,
}

enum AudioLearnAppViewType {
  playlistDownloadView,
  audioPlayerView,
  audioExtractorView,
}

enum AudioPopupMenuAction {
  openYoutubeVideo,
  copyYoutubeVideoUrl,
  displayAudioInfo,
  renameAudioFile,
  moveAudioToPlaylist,
  copyAudioToPlaylist,
  deleteAudio,
  deleteAudioFromPlaylistAswell,
  audioComment,
  modifyAudioTitle,
  addAudioPicture,
  removeAudioPicture,
  redownloadDeletedAudio,
}

const String kApplicationName = "Audio Learn";
const String kApplicationVersion = '1.3.78';
const String kApplicationPath = "/storage/emulated/0/Documents/audiolearn";
const String kPlaylistDownloadRootPath =
    "/storage/emulated/0/Documents/audiolearn/playlists";
const String kSettingsFileName = 'settings.json';
const String kOrderedPlaylistTitlesFileName = 'savedOrderedPlaylistTitles.txt';

// Used for testing and debugging
const String kApplicationPathWindowsTest =
    "C:\\development\\flutter\\audiolearn\\test\\data\\audio";
const String kPlaylistDownloadRootPathWindowsTest =
    "C:\\development\\flutter\\audiolearn\\test\\data\\audio";
const String kDownloadAppTestSavedDataDir =
    "C:\\development\\flutter\\audiolearn\\test\\data\\saved";

// Used for Windows installation
const String kApplicationPathWindows =
    "C:\\audiolearn";
const String kPlaylistDownloadRootPathWindows =
    "C:\\audiolearn\\playlists";

const String kCommentDirName = 'comments';
const String kPictureDirName = 'pictures';

// this constant enables to download a playlist in the emulator in which
// pasting a URL is not possible. The constant is used in
// _ExpandablePlaylistListViewState.initState().
// const String kPastedPlaylistUrl =
//     'https://youtube.com/playlist?list=PLzwWSJNcZTMSOMooR_y9PtJlJLpEKWbAv&si=LJ7w9Ms_ymqwJdT';

// usefull to delete all files in the audio dir of the emulator
const bool kDeleteAppDirOnEmulator = false;

const double kAudioDefaultPlaySpeed = 1.0;

const String kGoogleApiKey = 'AIzaSyDhywmh5EKopsNsaszzMkLJ719aQa2NHBw';

/// A constant that is true if the application was compiled to run on
/// the web. Its value determines if requesting storage permission must
/// be performed.
const bool kIsWeb = bool.fromEnvironment('dart.library.js_util');

const String kStartAtZeroPosition = '0Pos';

const double kRowSmallWidthSeparator = 3.0;
const double kRowNormalWidthSeparator = 10.0;
const double kRowButtonGroupWidthSeparator = 30.0;
const double kUpDownButtonSize = 50.0;
const double kGreaterButtonWidth = 65.0;
const double kNormalButtonWidth = 62.0;
const double kSmallButtonWidth = 45.0; // 40.0; fails the app on S20 !
const double kSmallestButtonWidth = 35.0; // 40.0; fails the app on S20 !
const double kSmallIconButtonWidth = 30.0;
const double kNormalButtonHeight = 25.0;
const double kSmallButtonInsidePadding = 3.0;
const double kDefaultMargin = 5.0;
const double kRoundedButtonBorderRadius = 11.0;
const Color kDarkAndLightEnabledIconColor =
    Color.fromARGB(246, 44, 61, 255); // rgba(44, 61, 246, 255)
final Color kDarkAndLightDisabledIconColor = Colors.grey.shade600;
const Color kButtonColor = Color(0xFF3D3EC2);
const Color kScreenButtonColor = kSliderThumbColorInDarkMode;
const double kAudioDefaultPlayVolume = 0.5;
const double kDropdownMenuItemMaxWidth = 90;
const double kConfirmActionDialogSmallerFontSize = 20;

// the width of the dropdown button in the dropdown menu
// of the playlist download view can not be declared const
// because it must be set to a larger width in the
// playlist download view unit test.
double kDropdownButtonMaxWidth = 140;

const double kDropdownItemEditIconButtonWidth = 25.0;
const double kYoutubeImageAssetHeight = 38.0;

const int kMaxAudioSortFilterSettingsSearchHistory = 20;

const Duration kScrollDuration = Duration(milliseconds: 700);

DateFormat englishDateTimeFormat = DateFormat("MM/dd/yyyy HH:mm");
DateFormat frenchDateTimeFormat = DateFormat("dd/MM/yyyy HH:mm");
DateFormat englishDateFormat = DateFormat("MM/dd/yyyy");
DateFormat frenchDateFormat = DateFormat("dd/MM/yyyy");
DateFormat frenchDateFormatYy = DateFormat("dd/MM/yy");
DateFormat timeFormat = DateFormat("HH:mm");
DateFormat yearMonthDayDateTimeFormat = DateFormat("yyyy/MM/dd HH:mm");
DateFormat yearMonthDayDateTimeFormatForFileName =
    DateFormat("yyyy-MM-dd_HH_mm");

const TextStyle kDialogTitlesStyle = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.bold,
);

const TextStyle kDialogLabelStyle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.normal,
);

const TextStyle kDialogTextFieldStyle = TextStyle(
  fontSize: 16,
);

// Used by the audio sort filter dialog.
const TextStyle kDialogDateTextFieldStyle = TextStyle(
  fontSize: 15,
);

const TextStyle kDialogTextFieldBoldStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

const double kDialogTextFieldHeight = 32.0;

const double kDialogTextFieldVerticalSeparation = 10.0;

const String kYoutubeUrl = 'https://www.youtube.com/';

// true makes sense if audio are played in
// Smart AudioBook app
const bool kAudioFileNamePrefixIncludeTime = true;

const kPositionButtonTextStyle = TextStyle(
  // the color is the one defined in textTheme bodyMedium
  // specified in the ScreenMixin theme's
  fontSize: 17.0,
  color: kButtonColor,
);

const Color kSliderThumbColorInDarkMode = Color(0xffd0bcff);
const Color kSliderThumbColorInLightMode = Color(0xff6750a4);

const double kTextButtonFontSize = 15.0;
const double kTextButtonSmallerFontSize = 13.0;
const double kCommentedAudioTitleFontSize = 16.0;

const kTextButtonStyleDarkMode = TextStyle(
  // the color is the one defined in textTheme bodyMedium
  // specified in the ScreenMixin theme's
  fontSize: kTextButtonFontSize,
  color: kSliderThumbColorInDarkMode,
);

const kTextButtonStyleLightMode = TextStyle(
  // the color is the one defined in textTheme bodyMedium
  // specified in the ScreenMixin theme's
  fontSize: kTextButtonFontSize,
  color: kSliderThumbColorInLightMode,
);

const kTextButtonSmallStyleDarkMode = TextStyle(
  // the color is the one defined in textTheme bodyMedium
  // specified in the ScreenMixin theme's
  fontSize: kTextButtonSmallerFontSize,
  color: kSliderThumbColorInDarkMode,
);

const kTextButtonSmallStyleLightMode = TextStyle(
  // the color is the one defined in textTheme bodyMedium
  // specified in the ScreenMixin theme's
  fontSize: kTextButtonSmallerFontSize,
  color: kSliderThumbColorInLightMode,
);

const kSliderValueTextStyle = TextStyle(
  // the color is the one defined in textTheme bodyMedium
  // specified in the ScreenMixin theme's
  fontSize: kAudioTitleFontSize,
  color: kButtonColor,
);

const kSliderThickness = 2.0;

const double kDropdownMenuItemFontSize = 15.0;
const double kAudioTitleFontSize = 14.0;
const double kListDialogBottomTextFontSize = 16.0;

const kAudioExtractorExtractPositionStyle = TextStyle(
  fontSize: 14.0,
);

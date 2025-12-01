// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appBarTitleDownloadAudio => 'Download Audio';

  @override
  String get downloadAudioScreen => 'Download Audio screen';

  @override
  String get appBarTitleAudioPlayer => 'Play Audio';

  @override
  String get audioPlayerScreen => 'Play Audio screen';

  @override
  String get toggleList => 'Toggle List';

  @override
  String get delete => 'Delete';

  @override
  String get moveItemUp => 'Move item up';

  @override
  String get moveItemDown => 'Move item down';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get downloadAudio => 'Download Audio Youtube';

  @override
  String translate(String language) {
    return 'Select $language';
  }

  @override
  String get musicalQualityTooltip =>
      'For Youtube playlist, if set, downloads at musical quality. For local playlist, if set, indicates that the playlist is at music quality.';

  @override
  String get ofPreposition => 'of';

  @override
  String get atPreposition => 'at';

  @override
  String get ytPlaylistLinkLabel => 'Youtube Link or Search';

  @override
  String get ytPlaylistLinkHintText => 'Enter Youtube link or sentence';

  @override
  String get addPlaylist => 'Add';

  @override
  String get downloadSingleVideoAudio => 'One';

  @override
  String get downloadSelectedPlaylist => 'Playlist';

  @override
  String get stopDownload => 'Stop';

  @override
  String get audioDownloadingStopping => 'Stopping download ...';

  @override
  String audioDownloadError(Object error) {
    return 'Error downloading audio: $error';
  }

  @override
  String get about => 'About ...';

  @override
  String get help => 'Help ...';

  @override
  String get defineSortFilterAudiosMenu => 'Sort/Filter Audio ...';

  @override
  String get clearSortFilterAudiosParmsHistoryMenu =>
      'Clear Sort/Filter Parameters History';

  @override
  String get saveSortFilterAudiosOptionsToPlaylistMenu =>
      'Save Sort/Filter Parameters to Playlist ...';

  @override
  String get sortFilterDialogTitle => 'Sort and Filter Parms';

  @override
  String get sortBy => 'Sort by:';

  @override
  String get audioDownloadDate => 'Audio downl date';

  @override
  String get videoUploadDate => 'Video upload date';

  @override
  String get audioEnclosingPlaylistTitle => 'Audio playlist title';

  @override
  String get audioDuration => 'Audio duration';

  @override
  String get audioRemainingDuration => 'Audio listenable remaining duration';

  @override
  String get audioFileSize => 'Audio file size';

  @override
  String get audioMusicQuality => 'Music qual.';

  @override
  String get audioSpokenQuality => 'Spoken q.';

  @override
  String get audioDownloadSpeed => 'Audio downl speed';

  @override
  String get audioDownloadDuration => 'Audio downl duration';

  @override
  String get sortAscending => 'Asc';

  @override
  String get sortDescending => 'Desc';

  @override
  String get filterSentences => 'Filter words:';

  @override
  String get filterOptions => 'Filter options:';

  @override
  String get videoTitleOrDescription => 'Video title (word or sentence)';

  @override
  String get startDownloadDate => 'Start downl date';

  @override
  String get endDownloadDate => 'End downl date';

  @override
  String get startUploadDate => 'Start upl date';

  @override
  String get endUploadDate => 'End upl date';

  @override
  String get fileSizeRange => 'File size range (MB)';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get audioDurationRange => 'Audio duration range (hh:mm)';

  @override
  String get openYoutubeVideo => 'Open Youtube Video';

  @override
  String get openYoutubePlaylist => 'Open Youtube Playlist';

  @override
  String get apply => 'Apply';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteAudio => 'Delete Audio ...';

  @override
  String get deleteAudioFromPlaylistAswell =>
      'Delete Audio from Playlist as well ...';

  @override
  String deleteAudioFromPlaylistAswellWarning(
      Object audioTitle, Object playlistTitle) {
    return 'If the deleted audio \"$audioTitle\" remains in the \"$playlistTitle\" playlist located on Youtube, it will be downloaded again the next time you download the playlist !';
  }

  @override
  String get warningDialogTitle => 'WARNING';

  @override
  String updatedPlaylistUrlTitle(Object title) {
    return 'Youtube playlist \"$title\" URL was updated. The playlist can be downloaded with its new URL.';
  }

  @override
  String addYoutubePlaylistTitle(Object title, Object quality) {
    return 'Youtube playlist \"$title\" of $quality quality added at the end of the playlist list.';
  }

  @override
  String addCorrectedYoutubePlaylistTitle(
      Object originalTitle, Object quality, Object correctedTitle) {
    return 'Youtube playlist \"$originalTitle\" of $quality quality added with corrected title \"$correctedTitle\" at the end of the playlist list.';
  }

  @override
  String addLocalPlaylistTitle(Object title, Object quality) {
    return 'Local playlist \"$title\" of $quality quality added at the end of the playlist list.';
  }

  @override
  String invalidPlaylistUrl(Object url) {
    return 'Playlist with invalid URL \"$url\" neither added nor modified.';
  }

  @override
  String renameFileNameAlreadyUsed(Object fileName) {
    return 'The file name \"$fileName\" already exists in the same directory and cannot be used.';
  }

  @override
  String playlistWithUrlAlreadyInListOfPlaylists(Object url, Object title) {
    return 'Playlist \"$title\" with this URL \"$url\" is already in the playlist list and so won\'t be recreated.';
  }

  @override
  String localPlaylistWithTitleAlreadyInListOfPlaylists(Object title) {
    return 'Local playlist \"$title\" already exists in the playlist list. Therefore, the local playlist with this title won\'t be created.';
  }

  @override
  String youtubePlaylistWithTitleAlreadyInListOfPlaylists(Object title) {
    return 'Youtube playlist \"$title\" already exists in the playlist list. Therefore, the local playlist with this title won\'t be created.';
  }

  @override
  String downloadAudioYoutubeError(Object videoTitle, Object exceptionMessage) {
    return 'Downloading the audio of the video \"$videoTitle\" from Youtube FAILED: \"$exceptionMessage\".';
  }

  @override
  String downloadAudioYoutubeErrorExceptionMessageOnly(
      Object exceptionMessage) {
    return 'Error downloading audio from Youtube: \"$exceptionMessage\".';
  }

  @override
  String downloadAudioYoutubeErrorDueToLiveVideoInPlaylist(
      Object playlistTitle, Object liveVideoString) {
    return 'Error downloading audio from Youtube. The playlist \"$playlistTitle\" contains a live video which causes the playlist audio downloading failure. To solve the problem, after having downloaded the audio of the live video as explained below, remove the live video from the playlist, then restart the application and retry.\n\nThe live video URL contains the following string: \"$liveVideoString\". In order to add the live video audio to the playlist \"$playlistTitle\", download it separately as single video download adding it to the playlist \"$playlistTitle\".';
  }

  @override
  String downloadAudioFileAlreadyOnAudioDirectory(
      Object audioValidVideoTitle, Object fileName, Object playlistTitle) {
    return 'Audio \"$audioValidVideoTitle\" is contained in file \"$fileName\" present in the target playlist \"$playlistTitle\" directory and so won\'t be redownloaded.';
  }

  @override
  String get noInternet => 'No Internet. Please connect your device and retry.';

  @override
  String invalidSingleVideoUUrl(Object url) {
    return 'The URL \"$url\" supposed to point to a unique video is invalid. Therefore, no video has been downloaded.';
  }

  @override
  String get copyYoutubeVideoUrl => 'Copy Youtube Video URL';

  @override
  String get displayAudioInfo => 'Audio Information ...';

  @override
  String get renameAudioFile => 'Rename Audio File ...';

  @override
  String get moveAudioToPlaylist => 'Move Audio to Playlist ...';

  @override
  String get copyAudioToPlaylist => 'Copy Audio to Playlist ...';

  @override
  String get audioInfoDialogTitle => 'Downloaded Audio Info';

  @override
  String get youtubeChannelLabel => 'Youtube channel';

  @override
  String get originalVideoTitleLabel => 'Original video title';

  @override
  String get validVideoTitleLabel => 'Valid video title';

  @override
  String get videoUrlLabel => 'Video URL';

  @override
  String get audioDownloadDateTimeLabel => 'Audio downl date time';

  @override
  String get audioDownloadDurationLabel => 'Audio downl duration';

  @override
  String get audioDownloadSpeedLabel => 'Audio downl speed';

  @override
  String get videoUploadDateLabel => 'Video upload date';

  @override
  String get audioDurationLabel => 'Audio duration';

  @override
  String get audioFileNameLabel => 'Audio file name';

  @override
  String get audioFileSizeLabel => 'Audio file size';

  @override
  String get isMusicQualityLabel => 'Is music quality';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get octetShort => 'B';

  @override
  String get infiniteBytesPerSecond => 'infinite B/sec';

  @override
  String get updatePlaylistJsonFilesMenu => 'Update Playlist JSON Files';

  @override
  String get compactVideoDescription => 'Compact video description';

  @override
  String get ignoreCase => 'Ignore case';

  @override
  String get searchInVideoCompactDescription => 'Include description';

  @override
  String get on => 'on';

  @override
  String get copyYoutubePlaylistUrl => 'Copy Youtube Playlist URL';

  @override
  String get displayPlaylistInfo => 'Playlist Information ...';

  @override
  String get playlistInfoDialogTitle => 'Playlist Information';

  @override
  String get playlistTitleLabel => 'Playlist title';

  @override
  String get playlistIdLabel => 'Playlist ID';

  @override
  String get playlistUrlLabel => 'Playlist URL';

  @override
  String get playlistDownloadPathLabel => 'Playlist path';

  @override
  String get playlistLastDownloadDateTimeLabel =>
      'Playlist last downl date time';

  @override
  String get playlistIsSelectedLabel => 'Playlist is selected';

  @override
  String get playlistTotalAudioNumberLabel => 'Playlist total audio\'s';

  @override
  String get playlistPlayableAudioNumberLabel => 'Playable audio\'s';

  @override
  String get playlistPlayableAudioTotalDurationLabel =>
      'Playable audio\'s total duration';

  @override
  String get playlistPlayableAudioTotalRemainingDurationLabel =>
      'Playable audio\'s total remaining duration';

  @override
  String get playlistPlayableAudioTotalSizeLabel =>
      'Playable audio\'s total file size';

  @override
  String get updatePlaylistPlayableAudioList => 'Update playable Audio\'s List';

  @override
  String updatedPlayableAudioLst(Object number, Object title) {
    return 'Playable audio list for playlist \"$title\" was updated. $number audio(s) were removed.';
  }

  @override
  String get addYoutubePlaylistDialogTitle => 'Add Youtube Playlist';

  @override
  String get addLocalPlaylistDialogTitle => 'Add Local Playlist';

  @override
  String get renameAudioFileDialogTitle => 'Rename Audio File';

  @override
  String get renameAudioFileDialogComment => '';

  @override
  String get renameAudioFileLabel => 'Name';

  @override
  String get renameAudioFileTooltip =>
      'Renaming the audio file also renames the audio comment file and the picture audio file if they exist';

  @override
  String get renameAudioFileButton => 'Rename';

  @override
  String get modifyAudioTitleDialogTitle => 'Modify Audio Title';

  @override
  String get modifyAudioTitleTooltip => '';

  @override
  String get modifyAudioTitleDialogComment =>
      'Modify the audio title to allow adjusting its playback order.';

  @override
  String get modifyAudioTitleLabel => 'Title';

  @override
  String get modifyAudioTitleButton => 'Modify';

  @override
  String get youtubePlaylistUrlLabel => 'Youtube playlist URL';

  @override
  String get localPlaylistTitleLabel => 'Local playlist title';

  @override
  String get playlistTypeLabel => 'Playlist type';

  @override
  String get playlistTypeYoutube => 'Youtube';

  @override
  String get playlistTypeLocal => 'Local';

  @override
  String get playlistQualityLabel => 'Playlist quality';

  @override
  String get playlistQualityMusic => 'musical';

  @override
  String get playlistQualityAudio => 'spoken';

  @override
  String get audioQualityHighSnackBarMessage => 'Download at music quality';

  @override
  String get audioQualityLowSnackBarMessage => 'Download at audio quality';

  @override
  String get add => 'Add';

  @override
  String get noSortFilterSaveAsNameWarning =>
      'No sort/filter save as name defined. Please enter a name and retry ...';

  @override
  String get noPlaylistSelectedForSingleVideoDownloadWarning =>
      'No playlist selected for single video download. Select one playlist and retry ...';

  @override
  String get noPlaylistSelectedForAudioCopyWarning =>
      'No playlist selected for copying audio. Select one playlist and retry ...';

  @override
  String get noPlaylistSelectedForAudioMoveWarning =>
      'No playlist selected for moving audio. Select one playlist and retry ...';

  @override
  String get tooManyPlaylistSelectedForSingleVideoDownloadWarning =>
      'More than one playlist selected for single video download. Select only one playlist and retry ...';

  @override
  String get noSortFilterParameterWasModifiedWarning =>
      'No sort/filter parameter was modified. Please set a sort/filter parameter and retry ...';

  @override
  String get deletedSortFilterParameterNotExistWarning =>
      'The sort/filter parameter you try to delete does not exist. Please define an existing sort/filter parameter and retry ...';

  @override
  String get historicalSortFilterParameterWasDeletedWarning =>
      'The historical sort/filter parameter was deleted.';

  @override
  String get allHistoricalSortFilterParameterWereDeletedWarning =>
      'All historical sort/filter parameters were deleted.';

  @override
  String get allHistoricalSortFilterParametersDeleteConfirmation =>
      'Deleting all historical sort/filter parameters.';

  @override
  String playlistRootPathNotExistWarning(Object playlistRootPath) {
    return 'The defined path \"$playlistRootPath\" does not exist. Please enter a valid playlist root path and retry ...';
  }

  @override
  String get confirmDialogTitle => 'CONFIRMATION';

  @override
  String confirmSingleVideoAudioPlaylistTitle(Object title) {
    return 'Confirm target playlist \"$title\" for downloading single video audio in spoken quality.';
  }

  @override
  String confirmSingleVideoAudioAtMusicQualityPlaylistTitle(Object title) {
    return 'Confirm target playlist \"$title\" for downloading single video audio in high-quality music format.';
  }

  @override
  String get playlistJsonFileSizeLabel => 'JSON file size';

  @override
  String get playlistOneSelectedDialogTitle => 'Select a Playlist';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get enclosingPlaylistLabel => 'Enclosing playlist';

  @override
  String audioNotMovedFromLocalPlaylistToLocalPlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" NOT moved from local playlist \"$fromPlaylistTitle\" to local playlist \"$toPlaylistTitle\" $notCopiedOrMovedReason.';
  }

  @override
  String audioNotMovedFromLocalPlaylistToYoutubePlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" NOT moved from local playlist \"$fromPlaylistTitle\" to Youtube playlist \"$toPlaylistTitle\" $notCopiedOrMovedReason.';
  }

  @override
  String audioNotMovedFromYoutubePlaylistToLocalPlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" NOT moved from Youtube playlist \"$fromPlaylistTitle\" to local playlist \"$toPlaylistTitle\" $notCopiedOrMovedReason.';
  }

  @override
  String audioNotMovedFromYoutubePlaylistToYoutubePlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" NOT moved from Youtube playlist \"$fromPlaylistTitle\" to Youtube playlist \"$toPlaylistTitle\" $notCopiedOrMovedReason.';
  }

  @override
  String audioNotCopiedFromLocalPlaylistToLocalPlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" NOT copied from local playlist \"$fromPlaylistTitle\" to local playlist \"$toPlaylistTitle\" $notCopiedOrMovedReason.';
  }

  @override
  String audioNotCopiedFromLocalPlaylistToYoutubePlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" NOT copied from local playlist \"$fromPlaylistTitle\" to Youtube playlist \"$toPlaylistTitle\" $notCopiedOrMovedReason.';
  }

  @override
  String audioNotCopiedFromYoutubePlaylistToLocalPlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" NOT copied from Youtube playlist \"$fromPlaylistTitle\" to local playlist \"$toPlaylistTitle\" $notCopiedOrMovedReason.';
  }

  @override
  String audioNotCopiedFromYoutubePlaylistToYoutubePlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" NOT copied from Youtube playlist \"$fromPlaylistTitle\" to Youtube playlist \"$toPlaylistTitle\" $notCopiedOrMovedReason.';
  }

  @override
  String get author => 'Author:';

  @override
  String get authorName => 'Jean-Pierre Schnyder / Switzerland';

  @override
  String get aboutAppDescription =>
      'Audio Learn allows you to download audio from videos included in Youtube playlists whose links are added to the application, or from individual Youtube videos using their URL\'s.\n\nYou can also import audio files, such as audiobooks, directly into the application.\n\nIn addition to listening the audio files, Audio Learn offers the ability to add timestamped comments to each file, making it easier to replay their most interesting parts.\n\nFinally, the app allows you to sort and filter audio files based on various criteria.\n\nIn the next version, you will be able to extract commented audio segments to share them via email or WhatsApp, or combine them to create a new summarized audio file.';

  @override
  String get keepAudioEntryInSourcePlaylist =>
      'Keep audio data in source playlist';

  @override
  String get keepAudioEntryInSourcePlaylistTooltip =>
      'Keep audio data in the original playlist\'s JSON file even after transferring the audio file to another playlist. This prevents re-downloading the audio file if it no longer exists in its original directory.';

  @override
  String get movedFromPlaylistLabel => 'Moved from playlist';

  @override
  String get movedToPlaylistLabel => 'Moved to playlist';

  @override
  String get downloadSingleVideoButtonTooltip =>
      'Download single video audio.\n\nTo download a single video audio, enter its URL in the \"Youtube Link\" field and click the One button. You then have to select the playlist to which the audio will be added.';

  @override
  String get addPlaylistButtonTooltip =>
      'Add a Youtube or local playlist.\n\nTo add a Youtube playlist, enter its URL in the \"Youtube Link\" field and click the Add button. IMPORTANT: for a Youtube playlist to be downloaded by the app, its privacy setting must not be \"Private\" but \"Unlisted\" or \"Public\".\n\nTo set up a local playlist, click the Add button while the \"Youtube Link\" field is empty.';

  @override
  String get stopDownloadingButtonTooltip => 'Stop downloading ...';

  @override
  String get clearPlaylistUrlOrSearchButtonTooltip =>
      'Clear \"Youtube link or sentence\" field.';

  @override
  String get playlistToggleButtonInPlaylistDownloadViewTooltip =>
      'Show/hide playlists.';

  @override
  String get downloadSelPlaylistsButtonTooltip =>
      'Download audio\'s of the selected playlist.';

  @override
  String get audioOneSelectedDialogTitle => 'Select an Audio';

  @override
  String get audioPositionLabel => 'Audio position';

  @override
  String get audioStateLabel => 'Audio state';

  @override
  String get audioStatePaused => 'Paused';

  @override
  String get audioStatePlaying => 'Playing';

  @override
  String get audioStateTerminated => 'Terminated';

  @override
  String get audioStateNotListened => 'Not listened';

  @override
  String get audioPausedDateTimeLabel => 'Last listened date/time';

  @override
  String get audioPlaySpeedLabel => 'Play speed';

  @override
  String get playlistAudioPlaySpeedLabel => 'Audio play speed';

  @override
  String get audioPlayVolumeLabel => 'Sound volume';

  @override
  String get copiedFromPlaylistLabel => 'Copied from playlist';

  @override
  String get copiedToPlaylistLabel => 'Copied to playlist';

  @override
  String get audioPlayerViewNoCurrentAudio => 'No audio selected';

  @override
  String get deletePlaylist => 'Delete Playlist ...';

  @override
  String deleteYoutubePlaylistDialogTitle(Object title) {
    return 'Delete Youtube Playlist \"$title\"';
  }

  @override
  String deleteLocalPlaylistDialogTitle(Object title) {
    return 'Delete Local Playlist \"$title\"';
  }

  @override
  String deletePlaylistDialogComment(Object audioNumber,
      Object audioCommentsNumber, Object audioPicturesNumber) {
    return 'Deleting the playlist and its $audioNumber audio\'s, $audioCommentsNumber audio comment(s), $audioPicturesNumber audio picture(s) as well as its JSON file and its directory.';
  }

  @override
  String get appBarTitleAudioExtractor => 'Extract Audio';

  @override
  String get setAudioPlaySpeedDialogTitle => 'Playback Speed';

  @override
  String get setAudioPlaySpeedTooltip => 'Set audio\'s play speed.';

  @override
  String get exclude => 'Exclude ';

  @override
  String get fullyPlayed => 'fully played ';

  @override
  String get audio => 'audio';

  @override
  String increaseAudioVolumeIconButtonTooltip(Object percentValue) {
    return 'Increase the audio volume (currently $percentValue). Disabled when maximum volume is reached.';
  }

  @override
  String decreaseAudioVolumeIconButtonTooltip(Object percentValue) {
    return 'Decrease the audio volume (currently $percentValue). Disabled when minimum volume is reached.';
  }

  @override
  String get resetSortFilterOptionsTooltip =>
      'Reset the sort and filter parameters.';

  @override
  String get clickToSetAscendingOrDescendingTooltip =>
      'Click to set ascending or descending sort order.';

  @override
  String get and => 'and';

  @override
  String get or => 'or';

  @override
  String get videoTitleSearchSentenceTextFieldTooltip =>
      'Enter a word or a sentence to be selected in the video title and in the Youtube channel if \'înclude Youtube channel\' is checked and in the video description if \'Include description\' is checked. THEN, CLICK ON THE \'+\' BUTTON.';

  @override
  String get andSentencesTooltip =>
      'If set, only audio containing all the listed words or sentences are selected.';

  @override
  String get orSentencesTooltip =>
      'If set, audio containing one of the listed words or sentences are selected.';

  @override
  String get searchInVideoCompactDescriptionTooltip =>
      'If set, search words or sentences are searched on video description as well.';

  @override
  String get fullyListened => 'Fully listened';

  @override
  String get partiallyListened => 'Partially listened';

  @override
  String get notListened => 'Not listened';

  @override
  String saveSortFilterOptionsToPlaylistDialogTitle(
      Object sortFilterParmsName) {
    return 'Save Sort/Filter \"$sortFilterParmsName\"';
  }

  @override
  String saveSortFilterOptionsToPlaylist(Object title) {
    return 'To playlist \"$title\"';
  }

  @override
  String get saveButton => 'Save';

  @override
  String errorInPlaylistJsonFile(Object filePathName) {
    return 'File \"$filePathName\" contains an invalid data definition. Try finding the problem in order to correct it before executing again the operation.';
  }

  @override
  String get updatePlaylistJsonFilesMenuTooltip =>
      'If one or several playlist directories containing or not audio\'s were manually added or deleted in the application directory containing the playlists or if audio\'s were manually deleted from one or several playlist directories, this functionality updates the playlist JSON files as well as the JSON file containing the application settings in order to reflect the changes in the application screens. Playlist directories located on PC can as well be copied in the Android application directory containing the playlists. Additionally, playlist directories located on Android can as well be copied in the PC application directory containing the playlists ...';

  @override
  String get updatePlaylistPlayableAudioListTooltip =>
      'If audio\'s were manually deleted from the playlist directory, this functionality updates the playlist JSON file to reflect the changes in the application screen.';

  @override
  String get audioPlayedInThisOrderTooltip =>
      'Audio are played in this order. By default, the last downloaded audio\'s are at bottom of the list.';

  @override
  String get playableAudioDialogSortDescriptionTooltipBottomDownloadBefore =>
      'Audio at bottom were downloaded before those at top.';

  @override
  String get playableAudioDialogSortDescriptionTooltipBottomDownloadAfter =>
      'Audio at the bottom were downloaded after those at the top.';

  @override
  String get playableAudioDialogSortDescriptionTooltipBottomUploadBefore =>
      'Videos at the bottom were uploaded before those at the top.';

  @override
  String get playableAudioDialogSortDescriptionTooltipBottomUploadAfter =>
      'Videos at the bottom were uploaded after those at the top.';

  @override
  String get playableAudioDialogSortDescriptionTooltipTopDurationBigger =>
      'Audio at the top have a longer duration than those at the bottom.';

  @override
  String get playableAudioDialogSortDescriptionTooltipTopDurationSmaller =>
      'Audio at the top have a shorter duration than those at the bottom.';

  @override
  String get playableAudioDialogSortDescriptionTooltipTopRemainingDurationBigger =>
      'Audio at the top have more remaining listenable duration than those at the bottom.';

  @override
  String get playableAudioDialogSortDescriptionTooltipTopRemainingDurationSmaller =>
      'Audio at the top have less remaining listenable duration than those at the bottom.';

  @override
  String get playableAudioDialogSortDescriptionTooltipTopLastListenedDateTimeBigger =>
      'Audio at the top were listened more recently than those at the bottom.';

  @override
  String get playableAudioDialogSortDescriptionTooltipTopLastListenedDateTimeSmaller =>
      'Audio at the top were listened less recently than those at the bottom.';

  @override
  String get saveAs => 'Save as:';

  @override
  String get sortFilterSaveAsTextFieldTooltip =>
      'Save the sort/filter settings with the specified name. Existing settings with the same name will be updated.';

  @override
  String get applySortFilterToView => 'Apply sort/filter to:';

  @override
  String get applySortFilterToViewTooltip =>
      'Selecting sort/filter application to one or two audio views. This will be applied to the playlists to which this sort/filter is associated.';

  @override
  String get saveSortFilterOptionsTooltip =>
      'Update existing sort/filter parameters with modified parameters if the name already exists.';

  @override
  String get applyButton => 'Apply';

  @override
  String get applySortFilterOptionsTooltip =>
      'Apply the sort/filter parameters and add them to the sort/filter history if the name is empty.';

  @override
  String get deleteSortFilterOptionsTooltip =>
      'After deletion, the Default sort/filter parameters will be applied if these settings are in use.';

  @override
  String get deleteShort => 'Delete';

  @override
  String get sortFilterParametersDefaultName => 'default';

  @override
  String get sortFilterParametersDownloadButtonHint => 'Sel sort/filter';

  @override
  String get appBarMenuOpenSettingsDialog => 'Application Settings ...';

  @override
  String get appSettingsDialogTitle => 'Application Settings';

  @override
  String get setAudioPlaySpeed => 'Set Audio\'s Play Speed ...';

  @override
  String get applyToAlreadyDownloadedAudio =>
      'Apply to already downloaded,\nimported or converted audio\'s';

  @override
  String get applyToAlreadyDownloadedAudioTooltip =>
      'Apply the playback speed to audio\'s in all existing playlists. If not set, apply it only to newly added playlists.';

  @override
  String get applyToAlreadyDownloadedAudioOfCurrentPlaylistTooltip =>
      'Apply the playback speed to audio\'s in the current playlist. If not set, apply it only to newly downloaded or imported audio.';

  @override
  String get applyToExistingPlaylist => 'Apply to existing playlists';

  @override
  String get applyToExistingPlaylistTooltip =>
      'Apply the playback speed to all existing playlists. If not set, apply it only to newly added playlists.';

  @override
  String get playlistRootpathLabel => 'Playlists root path';

  @override
  String get closeTextButton => 'Close';

  @override
  String get helpDialogTitle => 'Help';

  @override
  String get defaultApplicationHelpTitle => 'Default Application';

  @override
  String get defaultApplicationHelpContent =>
      'If no option is selected, the defined playback speed will only apply to newly created playlists.';

  @override
  String get modifyingExistingPlaylistsHelpTitle =>
      'Modifying Existing Playlists';

  @override
  String get modifyingExistingPlaylistsHelpContent =>
      'By selecting the first checkbox, all existing playlists will be set to use the new playback speed. However, this change will only affect audio files that are downloaded after this option is enabled.';

  @override
  String get alreadyDownloadedAudiosHelpTitle =>
      'Already Downloaded or Imported Audio';

  @override
  String get alreadyDownloadedAudiosHelpContent =>
      'Selecting the second checkbox allows you to change the playback speed for audio files already present on the device.';

  @override
  String get excludingFutureDownloadsHelpTitle => 'Excluding Future Downloads';

  @override
  String get excludingFutureDownloadsHelpContent =>
      'If only the second checkbox is checked, the playback speed will not be modified for audio\'s that will be downloaded later in existing playlists. However, as mentioned previously, new playlists will use the newly defined playback speed for all downloaded audio.';

  @override
  String get alreadyDownloadedAudiosPlaylistHelpTitle =>
      'Apply to already downloaded or imported Audio\'s';

  @override
  String get alreadyDownloadedAudiosPlaylistHelpContent =>
      'Selecting this checkbox allows you to change the playback speed for the playlist audio files already present on the device.';

  @override
  String get commentsIconButtonTooltip =>
      'Show or insert comments at specific points in the audio.';

  @override
  String get commentsDialogTitle => 'Comments';

  @override
  String get playlistCommentsDialogTitle => 'Playlist Audio Comments';

  @override
  String get addPositionedCommentTooltip =>
      'Add a comment at the current audio position.';

  @override
  String get commentTitle => 'Title';

  @override
  String get commentText => 'Comment';

  @override
  String get commentDialogTitle => 'Comment';

  @override
  String get update => 'Update';

  @override
  String get deleteCommentConfirnTitle => 'Delete Comment';

  @override
  String deleteCommentConfirnBody(Object title) {
    return 'Deleting comment \"$title\".';
  }

  @override
  String get commentMenu => 'Audio Comments ...';

  @override
  String get tenthOfSecondsCheckboxTooltip =>
      'Enable this checkbox to specify the comment position with precision up to a tenth of second.';

  @override
  String get setCommentPosition => 'Set comment position';

  @override
  String get commentPosition => 'Position (hh:)mm:ss(.t)';

  @override
  String get commentPositionTooltip =>
      'Clearing the position field and selecting the \"Start\" checkbox will set the comment\'s start position to 0:00. Selecting the \"End\" checkbox will set the comment\'s end position to the total duration of the audio.';

  @override
  String get commentPositionExplanation =>
      'The proposed comment position corresponds to the current audio position. Modify it if needed and select to which position it must be applied. Look in help the usefulness of emptying the position field.';

  @override
  String get commentPositionHelpTitle => 'Quick Entry Tip';

  @override
  String get commentPositionHelpContent =>
      'If you clear the position field and then:\n\n• Check \"Start\" and click \"Ok\", the comment start position will be set to 0:00.\n• Check \"End\" and click \"Ok\", the end position will be set to the total audio duration.\n\nThis avoids manually entering these common values.';

  @override
  String get commentStartPosition => 'Start';

  @override
  String get commentEndPosition => 'End';

  @override
  String get updateCommentStartEndPositionTooltip =>
      'Update comment start or end position.';

  @override
  String noCheckboxSelectedWarning(Object atLeast) {
    return 'No checkbox selected. Please select ${atLeast}one checkbox before clicking \'Ok\', or click \'Cancel\' to exit.';
  }

  @override
  String get atLeast => 'at least ';

  @override
  String get commentCreationDateTooltip => 'Comment creation date';

  @override
  String get commentUpdateDateTooltip => 'Comment last update date';

  @override
  String get playlistCommentMenu => 'Audio Comments ...';

  @override
  String get modifyAudioTitle => 'Modify Audio Title ...';

  @override
  String invalidLocalPlaylistTitle(Object playlistTitle) {
    return 'The local playlist title \"$playlistTitle\" can not contain any comma. Please correct the title and retry ...';
  }

  @override
  String invalidYoutubePlaylistTitle(Object playlistTitle) {
    return 'The Youtube playlist title \"$playlistTitle\" can not contain any comma. Please correct the title and retry ...';
  }

  @override
  String setValueToTargetWarning(
      Object invalidValueWarningParam, Object maxMinPossibleValue) {
    return 'The entered value $invalidValueWarningParam ($maxMinPossibleValue). Please correct it and retry ...';
  }

  @override
  String get invalidValueTooBig => 'exceeds the maximal value';

  @override
  String get invalidValueTooSmall => 'is below the minimal value';

  @override
  String confirmCommentedAudioDeletionTitle(Object audioTitle) {
    return 'Confirm deletion of the commented audio \"$audioTitle\"';
  }

  @override
  String confirmCommentedAudioDeletionComment(Object commentNumber) {
    return 'The audio contains $commentNumber comment(s) which will be deleted as well. Confirm deletion ?';
  }

  @override
  String get commentStartPositionTooltip => 'Comment start position in audio.';

  @override
  String get commentEndPositionTooltip => 'Comment end position in audio.';

  @override
  String get playlistToggleButtonInAudioPlayerViewTooltip =>
      'Show/hide playlists. Then check a playlist to select its current listened audio.';

  @override
  String playlistSelectedSnackBarMessage(Object title) {
    return 'Playlist \"$title\" selected';
  }

  @override
  String get playlistImportAudioMenu => 'Import Audio File(s) ...';

  @override
  String get playlistImportAudioMenuTooltip =>
      'Import audio file(s) into the playlist in order to be able to listen them and add positionned comments to them.';

  @override
  String get setPlaylistAudioPlaySpeedTooltip =>
      'Set audio play speed for the playlist existing and next downloaded audio.';

  @override
  String audioNotImportedToLocalPlaylist(
      Object rejectedImportedAudioFileNames, Object toPlaylistTitle) {
    return 'Audio(s)\n\n$rejectedImportedAudioFileNames\n\nNOT imported to local playlist \"$toPlaylistTitle\" since the playlist directory already contains the audio(s).';
  }

  @override
  String audioNotImportedToYoutubePlaylist(
      Object rejectedImportedAudioFileNames, Object toPlaylistTitle) {
    return 'Audio(s)\n\n$rejectedImportedAudioFileNames\n\nNOT imported to Youtube playlist \"$toPlaylistTitle\" since the playlist directory already contains the audio(s).';
  }

  @override
  String audioImportedToLocalPlaylist(
      Object importedAudioFileNames, Object toPlaylistTitle) {
    return 'Audio(s)\n\n$importedAudioFileNames\n\nimported to local playlist \"$toPlaylistTitle\".';
  }

  @override
  String audioImportedToYoutubePlaylist(
      Object importedAudioFileNames, Object toPlaylistTitle) {
    return 'Audio(s)\n\n$importedAudioFileNames\n\nimported to Youtube playlist \"$toPlaylistTitle\".';
  }

  @override
  String get imported => 'imported';

  @override
  String get audioImportedInfoDialogTitle => 'Imported Audio Info';

  @override
  String get audioTitleLabel => 'Audio title';

  @override
  String get chapterAudioTitleLabel => 'Audio chapter';

  @override
  String get importedAudioDateTimeLabel => 'Imported audio date time';

  @override
  String get sortFilterParametersAppliedName => 'applied';

  @override
  String get lastListenedDateTime => 'Last listened date/time';

  @override
  String get downloadSingleVideoAudioAtMusicQuality =>
      'Download single video audio at music quality';

  @override
  String get videoTitleNotWrittenInOccidentalLettersWarning =>
      'Since the original video title is not written in occidental letters, the audio title is empty. You can use the \'Modify audio title ...\' audio menu in order to define a valid title. Same remark for improving the audio file name ...';

  @override
  String renameCommentFileNameAlreadyUsed(Object fileName) {
    return 'The comment file name \"$fileName.json\" already exists in the comment directory and so renaming the audio file with the name \"$fileName.mp3\" is not possible.';
  }

  @override
  String renameFileNameInvalid(Object fileName) {
    return 'The audio file name \"$fileName\" has no mp3 extension and so is invalid.';
  }

  @override
  String renameAudioFileConfirmation(Object newFileName, Object oldFileIame) {
    return 'Audio file \"$oldFileIame.mp3\" renamed to \"$newFileName.mp3\".';
  }

  @override
  String renameAudioAndAssociatedFilesConfirmation(
      Object newFileName, Object oldFileIame, Object secondMessagePart) {
    return 'Audio file \"$oldFileIame.mp3\" renamed to \"$newFileName.mp3\" $secondMessagePart.';
  }

  @override
  String secondMessagePartCommentOnly(Object newFileName, Object oldFileIame) {
    return 'as well as comment file \"$oldFileIame.json\" renamed to \"$newFileName.json\"';
  }

  @override
  String secondMessagePartPictureOnly(Object newFileName, Object oldFileIame) {
    return 'as well as picture file \"$oldFileIame.json\" renamed to \"$newFileName.json\"';
  }

  @override
  String secondMessagePartCommentAndPicture(
      Object newFileName, Object oldFileIame) {
    return 'as well as comment and picture files \"$oldFileIame.json\" renamed to \"$newFileName.json\"';
  }

  @override
  String forScreen(Object screenName) {
    return 'For \"$screenName\" screen';
  }

  @override
  String get downloadVideoUrlsFromTextFileInPlaylist =>
      'Download URLs from Text File ...';

  @override
  String get downloadVideoUrlsFromTextFileInPlaylistTooltip =>
      'Download audio\'s to the playlist from video URLs listed in a text file to select. The text file must contain one video URL per line.';

  @override
  String downloadAudioFromVideoUrlsInPlaylistTitle(Object title) {
    return 'Download video audio to playlist \"$title\"';
  }

  @override
  String downloadAudioFromVideoUrlsInPlaylist(Object number) {
    return 'Downloading $number audio\'s in selected quality.';
  }

  @override
  String notRedownloadAudioFilesInPlaylistDirectory(
      Object number, Object playlistTitle) {
    return '$number audio\'s are already contained in the target playlist \"$playlistTitle\" directory and so were not redownloaded.';
  }

  @override
  String get clickToSetAscendingOrDescendingPlayingOrderTooltip =>
      'Click to set ascending or descending playing order.';

  @override
  String get removeSortFilterAudiosOptionsFromPlaylistMenu =>
      'Remove Sort/Filter Parameters from Playlist ...';

  @override
  String removeSortFilterOptionsFromPlaylist(Object title) {
    return 'From playlist \"$title\"';
  }

  @override
  String removeSortFilterOptionsFromPlaylistDialogTitle(
      Object sortFilterParmsName) {
    return 'Remove Sort/Filter Parameters \"$sortFilterParmsName\"';
  }

  @override
  String fromScreen(Object screenName) {
    return 'On \"$screenName\" screen';
  }

  @override
  String get removeButton => 'Remove';

  @override
  String saveSortFilterParmsConfirmation(
      Object sortFilterParmsName, Object playlistTitle, Object forViewMessage) {
    return 'Sort/filter parameters \"$sortFilterParmsName\" were saved to playlist \"$playlistTitle\" for screen(s) \"$forViewMessage\".';
  }

  @override
  String removeSortFilterParmsConfirmation(
      Object sortFilterParmsName, Object playlistTitle, Object forViewMessage) {
    return 'Sort/filter parameters \"$sortFilterParmsName\" were removed from playlist \"$playlistTitle\" on screen(s) \"$forViewMessage\".';
  }

  @override
  String playlistSortFilterLabel(Object screenName) {
    return '$screenName sort/filter';
  }

  @override
  String get playlistAudioCommentsLabel => 'Audio comments';

  @override
  String get playlistAudioPicturesLabel => 'Audio pictures';

  @override
  String get listenedOn => 'Listened on';

  @override
  String get remaining => 'Remaining';

  @override
  String get searchInYoutubeChannelName => 'Include Youtube channel';

  @override
  String get searchInYoutubeChannelNameTooltip =>
      'If set, search words or sentences are searched on Youtube channel name as well.';

  @override
  String get savePlaylistAndCommentsToZipMenu =>
      'Save Playlists, Comments, Pictures and Settings to ZIP File ...';

  @override
  String get savePlaylistAndCommentsToZipTooltip =>
      'Saving the playlists, their audio comments and pictures to a ZIP file. The ZIP file will contain the playlists JSON files as well as the comment and picture JSON files. Additionally, the application settings.json will be saved. The MP3 and JPG files will not be included.';

  @override
  String get setYoutubeChannelMenu => 'Youtube channel setting';

  @override
  String confirmYoutubeChannelModifications(
      Object numberOfModifiedDownloadedAudio,
      Object numberOfModifiedPlayableAudio) {
    return 'The Youtube channel was set in $numberOfModifiedDownloadedAudio downloaded audio\'s and in $numberOfModifiedPlayableAudio playable audio.';
  }

  @override
  String get rewindAudioToStart => 'Rewind all Audio\'s to Start';

  @override
  String get rewindAudioToStartTooltip =>
      'Rewind all playlist audio\'s to start position. This is useful if you wish to replay all the audio\'s.';

  @override
  String rewindedPlayableAudioNumber(Object number) {
    return '$number playlist audio\'s were repositioned to start and the first listenable audio was selected.';
  }

  @override
  String get dateFormat => 'Select Date Format ...';

  @override
  String get dateFormatSelectionDialogTitle =>
      'Select the Application Date Format';

  @override
  String get commented => 'Commented';

  @override
  String get notCommented => 'Uncom.';

  @override
  String deleteFilteredAudioConfirmationTitle(
      Object sortFilterParmsName, Object playlistTitle) {
    return 'Delete audio\'s filtered by \"$sortFilterParmsName\" parms from playlist \"$playlistTitle\"';
  }

  @override
  String deleteFilteredAudioConfirmation(Object deleteAudioNumber,
      Object deleteAudioTotalFileSize, Object deleteAudioTotalDuration) {
    return 'Audio\'s to delete number: $deleteAudioNumber,\nCorresponding total file size: $deleteAudioTotalFileSize,\nCorresponding total duration: $deleteAudioTotalDuration.';
  }

  @override
  String get deleteFilteredCommentedAudioWarningTitleOne =>
      'WARNING: you are going to';

  @override
  String deleteFilteredCommentedAudioWarningTitleTwo(
      Object sortFilterParmsName, Object playlistTitle) {
    return 'delete COMMENTED and uncommented audio\'s filtered by \"$sortFilterParmsName\" parms from playlist \"$playlistTitle\". Watch the help to solve the problem ...';
  }

  @override
  String deleteFilteredCommentedAudioWarning(
      Object deleteAudioNumber,
      Object deleteCommentedAudioNumber,
      Object deleteAudioTotalFileSize,
      Object deleteAudioTotalDuration) {
    return 'Total audio\'s to delete number: $deleteAudioNumber,\nCOMMENTED audio\'s to delete number: $deleteCommentedAudioNumber,\nCorresponding total file size: $deleteAudioTotalFileSize,\nCorresponding total duration: $deleteAudioTotalDuration.';
  }

  @override
  String get commentedAudioDeletionHelpTitle =>
      'How to create and use a Sort/Filter parameter to prevent deleting commented audio\'s ?';

  @override
  String get commentedAudioDeletionHelpContent =>
      'This guide explains how to delete fully listened audio\'s that are not commented.';

  @override
  String get commentedAudioDeletionSolutionHelpTitle =>
      'The solution is to create a Sort/Filter parameter to select only fully played uncommented audio';

  @override
  String get commentedAudioDeletionSolutionHelpContent =>
      'In the Sort/Filter definition dialog, the selection parameters are represented by checkboxes ...';

  @override
  String get commentedAudioDeletionOpenSFDialogHelpTitle =>
      'Open the Sort/Filter Definition Dialog';

  @override
  String get commentedAudioDeletionOpenSFDialogHelpContent =>
      'Click the right menu icon in the download audio view, then select \"Sort/Filter Audio ...\".';

  @override
  String get commentedAudioDeletionCreateSFParmHelpTitle =>
      'Create a valid Sort/Filter Parameter';

  @override
  String get commentedAudioDeletionCreateSFParmHelpContent =>
      'In the \"Save as\" field, enter a name for the Sort/Filter parameter (e.g., FullyListenedUncom). Uncheck the checkboxes for \"Partially listened\", \"Not listened\" and \"Commented\". Then click on \"Save\".';

  @override
  String get commentedAudioDeletionSelectSFParmHelpTitle =>
      'Once saved, the Sort/Filter parameter is applied to the playlist, reducing the displayed audio\'s list.';

  @override
  String get commentedAudioDeletionSelectSFParmHelpContent =>
      'Click on the \"Playlists\" button to hide the playlist list. You’ll see your newly created SF parameter selected in the dropdown menu. You can apply this parameter or another one to any playlist ...';

  @override
  String get commentedAudioDeletionApplyingNewSFParmHelpTitle =>
      'Finally, reclick on the \"Playlists\" button to display the playlist list, open the source playlist menu and click on \"Filtered Audio\'s Actions ...\" and then on \"Delete filtered Audio\'s ...\"';

  @override
  String get commentedAudioDeletionApplyingNewSFParmHelpContent =>
      'This time, since a correct SF parameter is applied, no warning will be displayed when deleting the selected uncommented audio.';

  @override
  String get filteredAudioActions => 'Filtered Audio\'s Actions ...';

  @override
  String get moveFilteredAudio => 'Move filtered Audio\'s to Playlist ...';

  @override
  String get copyFilteredAudio => 'Copy filtered Audio\'s to Playlist ...';

  @override
  String get deleteFilteredAudio => 'Delete filtered Audio\'s ...';

  @override
  String confirmMovedUnmovedAudioNumberFromYoutubeToYoutubePlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object movedAudioNumber,
      Object movedCommentedAudioNumber,
      Object unmovedAudioNumber) {
    return 'Applying Sort/Filter parms \"$sortedFilterParmsName\", from Youtube playlist \"$sourcePlaylistTitle\" to Youtube playlist \"$targetPlaylistTitle\", $movedAudioNumber audio(s) were moved from which $movedCommentedAudioNumber were commented, and $unmovedAudioNumber audio(s) were unmoved.';
  }

  @override
  String confirmMovedUnmovedAudioNumberFromYoutubeToLocalPlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object movedAudioNumber,
      Object movedCommentedAudioNumber,
      Object unmovedAudioNumber) {
    return 'Applying Sort/Filter parms \"$sortedFilterParmsName\", from Youtube playlist \"$sourcePlaylistTitle\" to local playlist \"$targetPlaylistTitle\", $movedAudioNumber audio(s) were moved from which $movedCommentedAudioNumber were commented, and $unmovedAudioNumber audio(s) were unmoved.';
  }

  @override
  String confirmMovedUnmovedAudioNumberFromLocalToYoutubePlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object movedAudioNumber,
      Object movedCommentedAudioNumber,
      Object unmovedAudioNumber) {
    return 'Applying Sort/Filter parms \"$sortedFilterParmsName\", from local playlist \"$sourcePlaylistTitle\" to Youtube playlist \"$targetPlaylistTitle\", $movedAudioNumber audio(s) were moved from which $movedCommentedAudioNumber were commented, and $unmovedAudioNumber audio(s) were unmoved.';
  }

  @override
  String confirmMovedUnmovedAudioNumberFromLocalToLocalPlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object movedAudioNumber,
      Object movedCommentedAudioNumber,
      Object unmovedAudioNumber) {
    return 'Applying Sort/Filter parms \"$sortedFilterParmsName\", from local playlist \"$sourcePlaylistTitle\" to local playlist \"$targetPlaylistTitle\", $movedAudioNumber audio(s) were moved from which $movedCommentedAudioNumber were commented, and $unmovedAudioNumber audio(s) were unmoved.';
  }

  @override
  String confirmCopiedNotCopiedAudioNumberFromYoutubeToYoutubePlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object copiedAudioNumber,
      Object copiedCommentedAudioNumber,
      Object notCopiedAudioNumber) {
    return 'Applying Sort/Filter parms \"$sortedFilterParmsName\", from Youtube playlist \"$sourcePlaylistTitle\" to Youtube playlist \"$targetPlaylistTitle\", $copiedAudioNumber audio(s) were copied from which $copiedCommentedAudioNumber were commented, and $notCopiedAudioNumber audio(s) were not copied.';
  }

  @override
  String confirmCopiedNotCopiedAudioNumberFromYoutubeToLocalPlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object copiedAudioNumber,
      Object copiedCommentedAudioNumber,
      Object notCopiedAudioNumber) {
    return 'Applying Sort/Filter parms \"$sortedFilterParmsName\", from Youtube playlist \"$sourcePlaylistTitle\" to local playlist \"$targetPlaylistTitle\", $copiedAudioNumber audio(s) were copied from which $copiedCommentedAudioNumber were commented, and $notCopiedAudioNumber audio(s) were not copied.';
  }

  @override
  String confirmCopiedNotCopiedAudioNumberFromLocalToYoutubePlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object copiedAudioNumber,
      Object copiedCommentedAudioNumber,
      Object notCopiedAudioNumber) {
    return 'Applying Sort/Filter parms \"$sortedFilterParmsName\", from local playlist \"$sourcePlaylistTitle\" to Youtube playlist \"$targetPlaylistTitle\", $copiedAudioNumber audio(s) were copied from which $copiedCommentedAudioNumber were commented, and $notCopiedAudioNumber audio(s) were not copied.';
  }

  @override
  String confirmCopiedNotCopiedAudioNumberFromLocalToLocalPlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object copiedAudioNumber,
      Object copiedCommentedAudioNumber,
      Object notCopiedAudioNumber) {
    return 'Applying Sort/Filter parms \"$sortedFilterParmsName\", from local playlist \"$sourcePlaylistTitle\" to local playlist \"$targetPlaylistTitle\", $copiedAudioNumber audio(s) were copied from which $copiedCommentedAudioNumber were commented, and $notCopiedAudioNumber audio(s) were not copied.';
  }

  @override
  String defaultSFPNotApplyedToMoveAudioFromYoutubeToYoutubePlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName) {
    return 'Since \"$sortedFilterParmsName\" Sort/Filter parms is selected, no audio can be moved from Youtube playlist \"$sourcePlaylistTitle\" to Youtube playlist \"$targetPlaylistTitle\". SOLUTION: define a Sort/Filter parms and apply it before executing this operation ...';
  }

  @override
  String defaultSFPNotApplyedToMoveAudioFromYoutubeToLocalPlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName) {
    return 'Since \"$sortedFilterParmsName\" Sort/Filter parms is selected, no audio can be moved from Youtube playlist \"$sourcePlaylistTitle\" to local playlist \"$targetPlaylistTitle\". SOLUTION: define a Sort/Filter parms and apply it before executing this operation ...';
  }

  @override
  String defaultSFPNotApplyedToMoveAudioFromLocalToYoutubePlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName) {
    return 'Since \"$sortedFilterParmsName\" Sort/Filter parms is selected, no audio can be moved from local playlist \"$sourcePlaylistTitle\" to Youtube playlist \"$targetPlaylistTitle\". SOLUTION: define a Sort/Filter parms and apply it before executing this operation ...';
  }

  @override
  String defaultSFPNotApplyedToMoveAudioFromLocalToLocalPlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName) {
    return 'Since \"$sortedFilterParmsName\" Sort/Filter parms is selected, no audio can be moved from local playlist \"$sourcePlaylistTitle\" to local playlist \"$targetPlaylistTitle\". SOLUTION: define a Sort/Filter parms and apply it before executing this operation ...';
  }

  @override
  String defaultSFPNotApplyedToCopyAudioFromYoutubeToYoutubePlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName) {
    return 'Since \"$sortedFilterParmsName\" Sort/Filter parms is selected, no audio can be copied from Youtube playlist \"$sourcePlaylistTitle\" to Youtube playlist \"$targetPlaylistTitle\". SOLUTION: define a Sort/Filter parms and apply it before executing this operation ...';
  }

  @override
  String defaultSFPNotApplyedToCopyAudioFromYoutubeToLocalPlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName) {
    return 'Since \"$sortedFilterParmsName\" Sort/Filter parms is selected, no audio can be copied from Youtube playlist \"$sourcePlaylistTitle\" to local playlist \"$targetPlaylistTitle\". SOLUTION: define a Sort/Filter parms and apply it before executing this operation ...';
  }

  @override
  String defaultSFPNotApplyedToCopyAudioFromLocalToYoutubePlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName) {
    return 'Since \"$sortedFilterParmsName\" Sort/Filter parms is selected, no audio can be copied from local playlist \"$sourcePlaylistTitle\" to Youtube playlist \"$targetPlaylistTitle\". SOLUTION: define a Sort/Filter parms and apply it before executing this operation ...';
  }

  @override
  String defaultSFPNotApplyedToCopyAudioFromLocalToLocalPlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName) {
    return 'Since \"$sortedFilterParmsName\" Sort/Filter parms is selected, no audio can be copied from local playlist \"$sourcePlaylistTitle\" to local playlist \"$targetPlaylistTitle\". SOLUTION: define a Sort/Filter parms and apply it before executing this operation ...';
  }

  @override
  String get appBarMenuEnableNextAudioAutoPlay =>
      'Enable playing next Audio automatically ...';

  @override
  String get batteryParameters => 'Battery Parameter Change';

  @override
  String get disableBatteryOptimisation =>
      'Display the battery settings in order to disable its optimization. The result is that it allows the application to automatically play the next audio in the current playlist.\n\nClick on the button below, then select the \"Battery\" option at the bottom of the list. Next, choose \"Unrestricted\" and quit the settings.';

  @override
  String get openBatteryOptimisationButton => 'Display the battery settings';

  @override
  String deleteSortFilterParmsWarningTitle(
      Object sortFilterParmsName, Object playlistNumber) {
    return 'WARNING: you are going to delete the Sort/Filter parms \"$sortFilterParmsName\" which is used in $playlistNumber playlist(s) listed below';
  }

  @override
  String updatingSortFilterParmsWarningTitle(Object sortFilterParmsName) {
    return 'WARNING: the sort/filter parameters \"$sortFilterParmsName\" were modified. Do you want to update the existing sort/filter parms by clicking on \"Confirm\", or to save it with a different name or cancel the Save operation, this by clicking on \"Cancel\" ?';
  }

  @override
  String get presentOnlyInFirstTitle => 'Present only in initial version';

  @override
  String get presentOnlyInSecondTitle => 'Present only in modified version';

  @override
  String get ascendingShort => 'asc';

  @override
  String get descendingShort => 'desc';

  @override
  String get startAudioDownloadDateSortFilterTooltip =>
      'Lists all audio\'s downloaded on or after the specified start date if set.';

  @override
  String get endAudioDownloadDateSortFilterTooltip =>
      'Lists all audio\'s downloaded on or before the specified end date if set.';

  @override
  String get startVideoUploadDateSortFilterTooltip =>
      'Lists all videos uploaded on or after the specified start date if set.';

  @override
  String get endVideoUploadDateSortFilterTooltip =>
      'Lists all videos uploaded on or before the specified end date if set.';

  @override
  String get startAudioDurationSortFilterTooltip =>
      'Lists all audio\'s with a duration equal to or greater than the specified minimum duration if set.';

  @override
  String get endAudioDurationSortFilterTooltip =>
      'Lists all audio\'s with a duration equal to or less than the specified maximum duration if set.';

  @override
  String get startAudioFileSizeSortFilterTooltip =>
      'Lists all audio\'s with a file size equal to or greater than the specified minimum size if set.';

  @override
  String get endAudioFileSizeSortFilterTooltip =>
      'Lists all audio\'s with a file size equal to or less than the specified maximum size if set.';

  @override
  String get valueInInitialVersionTitle => 'In initial version';

  @override
  String get valueInModifiedVersionTitle => 'In modified version';

  @override
  String get checked => 'checked';

  @override
  String get unchecked => 'unchecked';

  @override
  String get emptyDate => 'empty';

  @override
  String get helpMainTitle => 'Audio Learn Help';

  @override
  String get helpMainIntroduction =>
      'Consult the Audio Learn Introduction Help the first time you use the application in order to initialize it correctly !';

  @override
  String get helpAudioLearnIntroductionTitle => 'Audio Learn Introduction';

  @override
  String get helpAudioLearnIntroductionSubTitle =>
      'Defining, adding and downloading a Youtube playlist';

  @override
  String get helpLocalPlaylistTitle => 'Local Playlist';

  @override
  String get helpLocalPlaylistSubTitle => 'Defining and using a local playlist';

  @override
  String get helpPlaylistMenuTitle => 'Playlist Menu';

  @override
  String get helpPlaylistMenuSubTitle => 'Playlist menu functionalities';

  @override
  String get helpAudioMenuTitle => 'Audio Menu';

  @override
  String get helpAudioMenuSubTitle => 'Audio menu functionalities';

  @override
  String get addPrivateYoutubePlaylist =>
      'Trying to add a private Youtube playlist is not possible since the audio\'s of a private playlist can not be downloaded. To solve the problem, edit the playlist on Youtube and change its visibility from \"Private\" to \"Unlisted\" or to \"Public\" and then re-add it to the application.';

  @override
  String get addAudioPicture => 'Add Audio Picture ...';

  @override
  String get removeAudioPicture => 'Remove Audio Picture';

  @override
  String savedAppDataToZip(Object filePathName) {
    return 'Saved playlist, comment and picture JSON files as well as application settings to \"$filePathName\".';
  }

  @override
  String get appDataCouldNotBeSavedToZip =>
      'Playlist, comment and picture JSON files as well as application settings could not be saved to ZIP.';

  @override
  String get pictured => 'Pictured';

  @override
  String get notPictured => 'Unpictured';

  @override
  String get restorePlaylistAndCommentsFromZipMenu =>
      'Restore Playlist(s), Comments, Pictures and Settings from ZIP File ...';

  @override
  String get restorePlaylistAndCommentsFromZipTooltip =>
      'According to the content of the selected ZIP file, restoring a unique or multiple playlists, their audio comments, pictures and, if awailable, the application settings. The audio files are not included in the ZIP file.';

  @override
  String get appDataCouldNotBeRestoredFromZip =>
      'Playlist, comment and picture JSON files as well as application settings could not be restored from ZIP.';

  @override
  String get deleteFilteredAudioFromPlaylistAsWell =>
      'Delete filtered Audio\'s from Playlist as well ...';

  @override
  String deleteFilteredAudioFromPlaylistAsWellConfirmationTitle(
      Object sortFilterParmsName, Object playlistTitle) {
    return 'Delete audio\'s filtered by \"$sortFilterParmsName\" parms from playlist \"$playlistTitle\" as well (will be re-downloadable)';
  }

  @override
  String get redownloadFilteredAudio => 'Redownload filtered Audio\'s';

  @override
  String get redownloadFilteredAudioTooltip =>
      'Filtered audio files are re-downloaded using their original file names.';

  @override
  String redownloadedAudioNumbersConfirmation(Object playlistTitle,
      Object redownloadedAudioNumber, Object notRedownloadedAudioNumber) {
    return '\"$redownloadedAudioNumber\" audio\'s were redownloaded to the playlist \"$playlistTitle\". \"$notRedownloadedAudioNumber\" audio\'s were not redownloaded since they are already present in the playlist directory.';
  }

  @override
  String get redownloadDeletedAudio => 'Redownload deleted Audio';

  @override
  String redownloadedAudioConfirmation(
      Object playlistTitle, Object redownloadedAudioTitle) {
    return 'The audio \"$redownloadedAudioTitle\" was redownloaded in the playlist \"$playlistTitle\".';
  }

  @override
  String get playable => 'Playable';

  @override
  String get notPlayable => 'Not playable';

  @override
  String audioNotRedownloadedWarning(
      Object playlistTitle, Object redownloadedAudioTitle) {
    return 'The audio \"$redownloadedAudioTitle\" was NOT redownloaded in the playlist \"$playlistTitle\" because it already exists in the playlist directory.';
  }

  @override
  String get isPlayableLabel => 'Playable';

  @override
  String get setPlaylistAudioQuality => 'Set Audio Quality ...';

  @override
  String get setPlaylistAudioQualityTooltip =>
      'The selected audio quality will be applied to the next downloaded audio\'s. If the audio quality must be applied to the already downloaded audio\'s, those audio\'s must be deleted \"from playlist as well\" so that they will be redownloadable in the modified audio quality.';

  @override
  String get setPlaylistAudioQualityDialogTitle => 'Playlist Audio Quality';

  @override
  String get selectAudioQuality => 'Select audio quality';

  @override
  String audioCopiedOrMovedFromPlaylistToPlaylist(
      Object audioTitle,
      Object yesOrNo,
      Object operationType,
      Object fromPlaylistType,
      Object fromPlaylistTitle,
      Object toPlaylistTitle,
      Object toPlaylistType,
      Object notCopiedOrMovedReason) {
    return 'Audio \"$audioTitle\"$yesOrNo$operationType from $fromPlaylistType playlist \"$fromPlaylistTitle\" to $toPlaylistType playlist \"$toPlaylistTitle\"$notCopiedOrMovedReason';
  }

  @override
  String get sinceAbsentFromSourcePlaylist =>
      ' since it is not present in the source playlist.';

  @override
  String get sinceAlreadyPresentInTargetPlaylist =>
      ' since it is already present in the destination playlist.';

  @override
  String audioNotKeptInSourcePlaylist(
      Object audioTitle, Object fromPlaylistTitle) {
    return '.\n\nIF THE DELETED AUDIO VIDEO \"$audioTitle\" REMAINS IN THE \"$fromPlaylistTitle\" YOUTUBE PLAYLIST, IT WILL BE DOWNLOADED AGAIN THE NEXT TIME YOU DOWNLOAD THE PLAYLIST !';
  }

  @override
  String get noOperation => ' NOT ';

  @override
  String get yesOperation => ' ';

  @override
  String get localPlaylistType => 'local';

  @override
  String get youtubePlaylistType => 'Youtube';

  @override
  String get movedOperationType => 'moved';

  @override
  String get copiedOperationType => 'copied';

  @override
  String get noOperationMovedOperationType => 'moved';

  @override
  String get noOperationCopiedOperationType => 'copied';

  @override
  String savedPictureNumberMessage(Object pictureNumber) {
    return '\n\nSaved also $pictureNumber picture JPG file(s) in same directory / pictures.';
  }

  @override
  String savedPictureNumberMessageToZip(Object pictureNumber) {
    return '\n\nSaved also $pictureNumber picture JPG file(s) in the ZIP file.';
  }

  @override
  String addedToZipPictureNumberMessage(Object pictureNumber) {
    return '\n\nSaved also $pictureNumber picture JPG file(s) in the ZIP file.';
  }

  @override
  String get replaceExistingPlaylists => 'Replace existing playlist(s)';

  @override
  String get deleteExistingPlaylists =>
      'Delete existing playlists not\ncontained in ZIP';

  @override
  String get playlistRestorationDialogTitle => 'Playlists Restoration';

  @override
  String get playlistRestorationExplanation =>
      'Important: if you\'ve modified your existing playlists (added audio files, comments, or pictures) since creating the ZIP backup, keep the \'Replace existing playlist(s)\' checkbox UNCHECKED. Otherwise, your recent changes will be replaced by the older versions contained in the backup.\n\nPlaylists not in the ZIP will only be deleted if they existed BEFORE the backup was created. Any playlists created or modified AFTER the backup date are automatically protected and will be kept, even if the delete checkbox is checked.';

  @override
  String get playlistRestorationHelpTitle => 'Playlist Restoration Function';

  @override
  String get playlistRestorationFirstHelpTitle =>
      'Problematic scenario: you restored playlists from a ZIP file, then ran the \"Update playlist JSON files\" function with the \"Remove deleted audio files\" checkbox enabled. Since restoration from a ZIP doesn\'t reinstall the audio files, enabling this option removed these files from the application. As a result, they are no longer available for re-downloading.';

  @override
  String get playlistRestorationFirstHelpContent =>
      'To resolve this issue, you need to delete the playlists affected by the loss of their audio files. Here are two methods for deleting these playlists:\n\n1 - Deletion through the application\nEach  playlist has a menu. Use its last element \"Delete Playlist ...\".\n\n2 - Manual deletion (recommended if multiple playlists must be deleted)\nNavigate to the application\'s storage directory in which the playlist directories are present. Select the folders to be removed and delete the selected group.';

  @override
  String get playlistRestorationSecondHelpTitle =>
      'After deleting the affected playlists, restore them again from the ZIP file while ensuring the \"Remove deleted audio files\" checkbox remains UNCHECKED. This step is crucial as it will allow audio files to remain available for downloading after restoration.';

  @override
  String get playlistJsonFilesUpdateDialogTitle => 'Playlist JSON Files Update';

  @override
  String get playlistJsonFilesUpdateExplanation =>
      'Important: if you\'ve restored from a ZIP backup AND manually added playlists afterward, please use caution when updating. When you run \"Update Playlist JSON Files\", any restored audio files that haven\'t been redownloaded will disappear from your playlists. To preserve these files and conserve the possibility of redownloading them, make sure the \"Remove deleted audio files\" checkbox remains UNCHECKED before updating.';

  @override
  String get removeDeletedAudioFiles => 'Remove deleted audio files';

  @override
  String get updatePlaylistJsonFilesHelpTitle =>
      'Update Playlist JSON Files Function';

  @override
  String get updatePlaylistJsonFilesHelpContent =>
      'Important note: This function is only necessary for changes made OUTSIDE the application. Changes made directly within the application (adding/removing playlists, adding/importing/deleting audio files) are automatically processed and do not require using this update function.';

  @override
  String get updatePlaylistJsonFilesFirstHelpTitle =>
      'Using the Update Playlist JSON Files Function';

  @override
  String get saveUniquePlaylistCommentsAndPicturesToZipMenu =>
      'Save the Playlist, its Comments and its Pictures to ZIP File ...';

  @override
  String get saveUniquePlaylistCommentsAndPicturesToZipTooltip =>
      'Saving the playlist, their audio comments and pictures to a ZIP file. Only the JSON and JPG files are copied. The MP3 files will not be included.';

  @override
  String savedUniquePlaylistToZip(Object filePathName) {
    return 'Saved playlist, comment and picture JSON files to \"$filePathName\".';
  }

  @override
  String get downloadedCheckbox => 'Downloaded';

  @override
  String get importedCheckbox => 'Imported';

  @override
  String get convertedCheckbox => 'Converted';

  @override
  String get restoredElementsHelpTitle => 'Restored Elements Description';

  @override
  String get restoredElementsHelpContent =>
      'N playlist: number of new playlist JSON files created by the restoration.\n\nN comment: number of new comment JSON files created by the restoration. This happens only if the commented audio had no comment before the restoration. Otherwise, the new comment is added to the existing audio comment JSON file.\n\nN picture: number of new picture JSON files created by the restoration. This happens only if the pictured audio had no picture before the restoration. Otherwise, the new picture is added to the existing audio picture JSON file.\n\nN audio reference: number of playable audio elements contained in the unique or multiple new playlist json file(s) created by the restoration. If the restored playlist number is 0, then the audio reference(s) number correspond to the number of audio element(s) added to their enclosing playlist JSON file by the restoration. The restoration does not add MP3 files since no MP3 is contained in the ZIP file. The added referenced audio\'s can be downloaded after the restoration.\n\nN added comment: number of comments added by the restoration to the existing audio comment JSON files.\n\nN modified comment: number of comments modified by the restoration in the existing audio comment JSON files.';

  @override
  String get playlistInfoDownloadAudio => 'Download audio';

  @override
  String get playlistInfoAudioPlayer => 'Play audio';

  @override
  String get savePlaylistsAudioMp3FilesToZipMenu =>
      'Save Playlists Audio\'s MP3 to ZIP File(s) ...';

  @override
  String get savePlaylistsAudioMp3FilesToZipTooltip =>
      'Save audio MP3 files from all playlists to ZIP file(s). You can specify a date/time filter to only include audio files downloaded on or after that date.';

  @override
  String get setAudioDownloadFromDateTimeTitle => 'Set the Download Date';

  @override
  String get audioDownloadFromDateTimeAllPlaylistsExplanation =>
      'The default specified download date corresponds to the oldest audio download date from all playlists. Modify this value by specifying the download date from which the audio MP3 files will be included in the ZIP.';

  @override
  String audioDownloadFromDateTimeLabel(Object selectedAppDateFormat) {
    return 'Date/time $selectedAppDateFormat hh:mm';
  }

  @override
  String get audioDownloadFromDateTimeAllPlaylistsTooltip =>
      'Since the current date/time value corresponds to the application oldest date/time downladed audio value, if the date/time is not modified, all the application audio MP3 files will be included in the ZIP file.';

  @override
  String get audioDownloadFromDateTimeSinglePlaylistTooltip =>
      'Since the current date/time value corresponds to the playlist oldest date/time downladed audio value, if the date/time is not modified, all the playlist audio MP3 files will be included in the ZIP file.';

  @override
  String noAudioMp3WereSavedToZip(Object audioDownloadFromDateTime) {
    return 'No audio MP3 file was saved to ZIP since no audio was downloaded on or after $audioDownloadFromDateTime.';
  }

  @override
  String get savePlaylistAudioMp3FilesToZipMenu =>
      'Save the Playlist Audio\'s MP3 to 1 or n ZIP File(s) ...';

  @override
  String get savePlaylistAudioMp3FilesToZipTooltip =>
      'Saving the playlist audio MP3 files to one or several ZIP file(s). You can specify a date/time filter to only include audio files downloaded on or after that date.';

  @override
  String get audioDownloadFromDateTimeUniquePlaylistExplanation =>
      'The default specified download date corresponds to the oldest audio download date from the playlist. Modify this value by specifying the download date from which the audio MP3 files will be included in the ZIP.';

  @override
  String get audioDownloadFromDateTimeUniquePlaylistTooltip =>
      'Since the current date/time value corresponds to the playlist oldest date/time downladed audio value, if the date/time is not modified, all the playlist audio MP3 files will be included in the ZIP file.';

  @override
  String invalidDateFormatErrorMessage(Object dateStr) {
    return '$dateStr does not respect the date or date/time format.';
  }

  @override
  String get emptyDateErrorMessage =>
      'Defining an empty date or date/time download date is not possible.';

  @override
  String savingUniquePlaylistAudioMp3(Object playlistTitle) {
    return 'Saving $playlistTitle audio files to ZIP ...';
  }

  @override
  String get savingMultiplePlaylistsAudioMp3 =>
      'Saving multiple playlists audio files to ZIP ...';

  @override
  String savingApproximativeTime(Object saveTime, Object zipNumber) {
    return 'Should approxim. take $saveTime. ZIP number: $zipNumber';
  }

  @override
  String get savingUpToHalfHour =>
      'Please wait, this may take 10 to 30 minutes or more ...';

  @override
  String savingAudioToZipTime(Object evaluatedSaveTime) {
    return 'Saving the audio MP3 in one or several ZIP file(s) will take this estimated duration (hh:mm:ss): $evaluatedSaveTime.';
  }

  @override
  String get savingAudioToZipTimeTitle => 'Prevision of the Save Duration';

  @override
  String correctedSavedUniquePlaylistAudioMp3ToZip(
      Object audioDownloadFromDateTime,
      Object savedAudioNumber,
      Object savedAudioTotalFileSize,
      Object savedAudioTotalDuration,
      Object saveOperationRealDuration,
      Object bytesNumberSavedPerSecond,
      Object filePathName,
      Object zipFilesNumber,
      Object zipTooLargeFileInfo) {
    return 'Saved to ZIP file(s) unique playlist audio MP3 files downloaded from $audioDownloadFromDateTime.\n\nTotal saved audio number: $savedAudioNumber, total size: $savedAudioTotalFileSize and total duration: $savedAudioTotalDuration.\n\nSave operation real duration: $saveOperationRealDuration, number of bytes saved per second: $bytesNumberSavedPerSecond, number of created ZIP file(s): $zipFilesNumber.\n\nZIP file path name: \"$filePathName\".$zipTooLargeFileInfo';
  }

  @override
  String correctedSavedMultiplePlaylistsAudioMp3ToZip(
      Object audioDownloadFromDateTime,
      Object savedAudioNumber,
      Object savedAudioTotalFileSize,
      Object savedAudioTotalDuration,
      Object saveOperationRealDuration,
      Object bytesNumberSavedPerSecond,
      Object filePathName,
      Object zipFilesNumber,
      Object zipTooLargeFileInfo) {
    return 'Saved to ZIP all playlists audio MP3 files downloaded from $audioDownloadFromDateTime.\n\nTotal saved audio number: $savedAudioNumber, total size: $savedAudioTotalFileSize and total duration: $savedAudioTotalDuration.\n\nSave operation real duration: $saveOperationRealDuration, number of bytes saved per second: $bytesNumberSavedPerSecond, number of created ZIP file(s): $zipFilesNumber.\n\nZIP file path name: \"$filePathName\".$zipTooLargeFileInfo';
  }

  @override
  String get restorePlaylistsAudioMp3FilesFromZipMenu =>
      'Restore Playlists Audio\'s MP3 from one or several ZIP File(s)  ...';

  @override
  String get restorePlaylistsAudioMp3FilesFromZipTooltip =>
      'Restoring audio\'s MP3 not yet present in the playlists from a saved ZIP file. Only the MP3 relative to the audio\'s listed in the playlists are restorable.';

  @override
  String get audioMp3RestorationDialogTitle => 'MP3 Restoration';

  @override
  String get audioMp3RestorationExplanation =>
      'Only the MP3 relative to the audio\'s listed in the playlists which are not already present in the playlists are restorable.';

  @override
  String get restorePlaylistAudioMp3FilesFromZipMenu =>
      'Restore Playlist Audio\'s MP3 from one or several ZIP File(s) ...';

  @override
  String get restorePlaylistAudioMp3FilesFromZipTooltip =>
      'Restoring audio\'s MP3 not yet present in the playlist from a saved ZIP file. Only the MP3 relative to the audio\'s listed in the playlist are restorable.';

  @override
  String get audioMp3UniquePlaylistRestorationDialogTitle => 'MP3 Restoration';

  @override
  String get audioMp3UniquePlaylistRestorationExplanation =>
      'Only the MP3 relative to the audio\'s listed in the playlist which are not already present in the playlist are restorable.';

  @override
  String playlistInvalidRootPathWarning(
      Object playlistRootPath, Object wrongName) {
    return 'The defined path \"$playlistRootPath\" is invalid since the playlists final dir name \'$wrongName\' is not equal to \'playlists\'. Please define a valid playlist directory and retry changing the playlists root path.';
  }

  @override
  String restoringUniquePlaylistAudioMp3(Object playlistTitle) {
    return 'Restoring $playlistTitle audio files from ZIP ...';
  }

  @override
  String movingAudioMp3Zip(Object mp3ZipName) {
    return 'Moving $mp3ZipName to selected dir ...';
  }

  @override
  String get playlistsMp3RestorationHelpTitle =>
      'Playlists Mp3 Restoration Function';

  @override
  String get playlistsMp3RestorationHelpContent =>
      'This function is useful in the situation where playlists were restored from a ZIP file which only contained the playlists, comments and pictures JSON files and so did not contain the audio MP3 files.';

  @override
  String get uniquePlaylistMp3RestorationHelpTitle =>
      'Playlist Mp3 Restoration Function';

  @override
  String get uniquePlaylistMp3RestorationHelpContent =>
      'This function is useful in the situation where the playlist was restored from a ZIP file which only contained the playlist, comments and pictures JSON files and so did not contain the audio MP3 files.';

  @override
  String get playlistsMp3SaveHelpTitle => 'Playlists Mp3 Save Function';

  @override
  String playlistsMp3SaveHelpContent(
      Object dateOne, Object dateThree, Object dateTwo) {
    return 'If you already executed this save MP3 functionality a couple of weeks ago, the following example will help you to understand the result of the new save playlists MP3 execution. Consider that the first created MP3 saved ZIP is named audioLearn_mp3_from_2023-05-17_07_03_50_on_2025-06-15_11_59_38.zip. Now, on $dateOne at 10:00 you do a new playlist MP3 backup with setting the oldest audio download date to $dateTwo, i.e. the date on which the previous MP3 ZIP file was created. But if the newly created ZIP file is named audioLearn_mp3_from_2025-06-20_09_25_34_on_2025-07-27_16_23_32.zip and not audioLearn_mp3_from_2025-06-15_on_2025-07-27_16_23_32.zip, the reason is that the oldest downloaded audio after $dateTwo was downloaded on $dateThree 09:25:34.';
  }

  @override
  String get uniquePlaylistMp3SaveHelpTitle => 'Playlist Mp3 Save Function';

  @override
  String uniquePlaylistMp3SaveHelpContent(
      Object dateOne, Object dateThree, Object dateTwo) {
    return 'If you already executed this save MP3 functionality a couple of weeks ago, the following example will help you to understand the result of the new save playlist MP3 execution. Consider that the first created MP3 saved ZIP is named audioLearn_mp3_from_2023-05-17_07_03_50_on_2025-06-15_11_59_38.zip. Now, on $dateOne at 10:00 you do a new playlist MP3 backup with setting the oldest audio download date to $dateTwo, i.e. the date on which the previous MP3 ZIP file was created. But if the newly created ZIP file is named audioLearn_mp3_from_2025-06-20_09_25_34_on_2025-07-27_16_23_32.zip and not audioLearn_mp3_from_2025-06-15_on_2025-07-27_16_23_32.zip, the reason is that the oldest downloaded audio after $dateTwo was downloaded on $dateThree 09:25:34.';
  }

  @override
  String get insufficientStorageSpace =>
      'Insufficient storage space detected when selecting the ZIP file containing MP3\'s.';

  @override
  String get pathError => 'Failed to retrieve file path.';

  @override
  String get androidStorageAccessErrorMessage =>
      'Could not access Android external storage.';

  @override
  String get zipTooLargeFileInfoLabel =>
      'Those files are too large to be included in the MP3 saved ZIP file and so were not saved:\n';

  @override
  String get mp3ZipFileSizeLimitInMbLabel => 'ZIP file size limit in MB';

  @override
  String get mp3ZipFileSizeLimitInMbTooltip =>
      'Maximum size in MB for each ZIP file when saving audio MP3 files. On Android devices, if this limit is set too high, the save operation will fail due to memory constraints. Multiple ZIP files will be created automatically if the total content exceeds this limit.';

  @override
  String get zipTooLargeOneFileInfoLabel =>
      'This file is too large to be included in the MP3 saved ZIP file and so was not saved:\n';

  @override
  String androidZipFileCreationError(Object zipFileName, Object zipFileSize) {
    return 'Error saving the ZIP file $zipFileName. This is due to its too large size: $zipFileSize.\n\nSolution: in the application settings, reduce the maximum ZIP file size and re-run the save MP3 to ZIP function.';
  }

  @override
  String get obtainMostRecentAudioDownloadDateTimeMenu =>
      'Get latest Audio download Date';

  @override
  String get obtainMostRecentAudioDownloadDateTimeTooltip =>
      'Finds the most recent audio download date across all playlists. Use this date when creating ZIP backups with the \'Save Playlists Audio\'s MP3 to ZIP File(s)\' menu to ensure you capture only the newest audio files for restoring them to the current app version.';

  @override
  String get displayNewestAudioDownloadDateTimeTitle =>
      'Latest Audio Download Date';

  @override
  String displayNewestAudioDownloadDateTime(
      Object newestAudioDownloadDateTime) {
    return 'This is the latest audio download date/time: $newestAudioDownloadDateTime.';
  }

  @override
  String get audioTitleModificationHelpTitle =>
      'Using Audio Title Modification';

  @override
  String get audioTitleModificationHelpContent =>
      'For example, if in a playlist we have three audios that were downloaded in this order:\n  last\n  first\n  second\nand we want to listen to them in order according to their title, it is useful to rename the titles this way:\n  3-last\n  1-first\n  2-second\n\nThen you need to click on the \"Sort/Filter Audio ...\" menu to define a sort that you name and that sorts the audio\'s according to their title.\n\nOnce the \"Sort and Filter Parameters\" dialog is open, define the filter name in the \"Save as:\" field and open the \"Sort by:\" list. Select \"Audio title\" and then remove \"Audio downl date\". Finally, click on \"Save\".\n\nOnce this sort is defined, check that it is selected and use the \"Save Sort/Filter Parameters to Playlist ...\" menu by selecting the screen for which the sort will be applied. This way, the audios will be played in the order in which you want to listen to them.';

  @override
  String get playlistConvertTextToAudioMenu => 'Convert Text to Audio ...';

  @override
  String get playlistConvertTextToAudioMenuTooltip =>
      'Convert a text to a listenable audio which is added to the playlist. Adding positionned comments or a picture to this audio will be possible like for the other audio\'s.';

  @override
  String get convertTextToAudioDialogTitle => 'Convert Text to Audio';

  @override
  String textToConvert(Object brace_1) {
    return 'Text to convert, $brace_1 = silence';
  }

  @override
  String get textToConvertTextFieldTooltip =>
      'Enter the text to convert an audio added to the playlist. The audio is created using the selected voice. Add one or several brace(s) to include one or several second(s) of silence at this position.';

  @override
  String get textToConvertTextFieldHint => 'Enter your text here ...';

  @override
  String get conversionVoiceSelection => 'Voice selection:';

  @override
  String get masculineVoice => 'masculine';

  @override
  String get femineVoice => 'feminine';

  @override
  String get listenTextButton => 'Listen';

  @override
  String get listenTextButtonTooltip =>
      'Listening the text to convert with the selected voice.';

  @override
  String get createAudioFileButton => 'Create MP3';

  @override
  String get createAudioFileButtonTooltip =>
      'Create the audio file using the selected voice and add it to the playlist.';

  @override
  String get stopListeningTextButton => 'Stop';

  @override
  String get stopListeningTextButtonTooltip =>
      'Stop listening the text using the selected voice.';

  @override
  String get mp3FileName => 'MP3 File Name';

  @override
  String get enterMp3FileName => 'Enter the MP3 file name';

  @override
  String get myMp3FileName => 'file name';

  @override
  String get createMP3 => 'Create MP3';

  @override
  String audioImportedFromTextToSpeechToLocalPlaylist(
      Object importedAudioFileNames,
      Object replacedOrAdded,
      Object toPlaylistTitle) {
    return 'The audio created by the text to MP3 conversion\n\n$importedAudioFileNames\n\nwas $replacedOrAdded local playlist \"$toPlaylistTitle\".';
  }

  @override
  String audioImportedFromTextToSpeechToYoutubePlaylist(
      Object importedAudioFileNames,
      Object replacedOrAdded,
      Object toPlaylistTitle) {
    return 'The audio created by the text to MP3 conversion\n\n$importedAudioFileNames\n\nwas $replacedOrAdded Youtube playlist \"$toPlaylistTitle\".';
  }

  @override
  String get addedTo => 'added to';

  @override
  String get replacedIn => 'replaced in';

  @override
  String replaceExistingAudioInPlaylist(Object fileName, Object playlistTitle) {
    return 'The file \"$fileName.mp3\" already exists in the playlist \"$playlistTitle\". If you want to replace it with the new version, click on the \"Confirm\" button. Otherwise, click on the \"Cancel\" button and you will be able to define a different file name.';
  }

  @override
  String get speech => 'Text';

  @override
  String convertTextToAudioHelpTitle(Object brace_1) {
    return 'Using the $brace_1 character which adds 1 second of silence';
  }

  @override
  String convertTextToAudioHelpContent(
      Object brace_1, Object brace_2, Object brace_3) {
    return '${brace_1}A text with a character that introduces a 1-second silence. At the beginning of the text, 2 seconds of silence are added. $brace_2 Before this sentence, 4 seconds of silence are introduced. $brace_3 Here, one second of silence. This character was chosen because it is not normally used in writing.';
  }

  @override
  String get textToSpeech => 'converted';

  @override
  String get audioTextToSpeechInfoDialogTitle => 'Converted Audio Info';

  @override
  String get convertedAudioDateTimeLabel => 'Converted text first date time';

  @override
  String fromMp3ZipFileUsedToRestoreUniquePlaylist(Object zipFilePathNName) {
    return 'playlist(s) from the MP3 zip file \"$zipFilePathNName\"';
  }

  @override
  String fromMp3ZipFileUsedToRestoreMultiplePlaylists(Object zipFilePathNName) {
    return 'playlist(s) from one or several MP3 zip files contained in directory \"$zipFilePathNName\"';
  }

  @override
  String fromMultipleMp3ZipFileUsedToRestoreMultiplePlaylists(
      Object zipFilePathNName) {
    return 'playlist(s) from the multiple MP3 zip files contained in dir \"$zipFilePathNName\"';
  }

  @override
  String confirmMp3RestorationFromMp3Zip(
      Object audioNNumber, Object playlistsNumber, Object secondMsgPart) {
    return 'Restored $audioNNumber audio(s) MP3 in $playlistsNumber $secondMsgPart.';
  }

  @override
  String get restorePlaylistTitlesOrderTitle =>
      'Playlist Titles Order Restoration';

  @override
  String get restorePlaylistTitlesOrderMessage =>
      'A previous playlist titles order file is available in the selected playlist root path. Do you want to restore this saved order or keep the current playlist titles order? Click on \"Confirm\" to restore the saved order or on \"Cancel\" to keep the current order.';

  @override
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
      Object addedAtEndOfPlaylistLstMsg) {
    return 'Restored $playlistsNumber playlist saved individually, $commentsNumber comment and $picturesNumber picture JSON files as well as $addedPictureJpgNumber picture JPG file(s) in the application pictures directory and $audiosNumber audio reference(s) and $addedCommentNumber added plus $deletedCommentNumber deleted plus $updatedCommentNumber modified comment(s) in existing audio comment file(s) from \"$filePathName\".$deletedAudioAndMp3FilesMsg$addedAtEndOfPlaylistLstMsg';
  }

  @override
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
      Object addedAtEndOfPlaylistLstMsg) {
    return 'Restored $playlistsNumber playlist, $commentsNumber comment and $picturesNumber picture JSON files as well as $addedPictureJpgNumber picture JPG file(s) in the application pictures directory and $audiosNumber audio reference(s) and $addedCommentNumber added plus $deletedCommentNumber deleted plus $updatedCommentNumber modified comment(s) in existing audio comment file(s) and the application settings from \"$filePathName\".$deletedAudioAndMp3FilesMsg$addedAtEndOfPlaylistLstMsg';
  }

  @override
  String get newPlaylistsAddedAtEndOfPlaylistLst =>
      '\n\nThe created playlists are positioned at the end of the playlist list.';

  @override
  String uniquePlaylistAddedAtEndOfPlaylistLst(Object addedPlaylistTitles) {
    return '\n\nSince the playlist\n  \"$addedPlaylistTitles\"\nwas created, it is positioned at the end of the playlist list.';
  }

  @override
  String multiplePlaylistsAddedAtEndOfPlaylistLst(Object addedPlaylistTitles) {
    return '\n\nSince the playlists\n  \"$addedPlaylistTitles\"\nwere created, they are positioned at the end of the playlist list.';
  }

  @override
  String get playlistsSaveDialogTitle => 'Playlists Backup to ZIP';

  @override
  String get playlistsSaveExplanation =>
      'Checking the \"Add all JPG pictures to ZIP\" checkbox will add all the application audio pictures to the created ZIP. This is only useful if the ZIP file will be used to restore another application.';

  @override
  String get addPictureJpgFilesToZip => 'Add all JPG pictures to ZIP';

  @override
  String confirmAudioFromPlaylistDeletionTitle(Object audioTitle) {
    return 'Confirm deletion of the audio \"$audioTitle\" from the Youtube playlist';
  }

  @override
  String confirmAudioFromPlaylistDeletion(
      Object audioTitle, Object playlistTitle) {
    return 'Delete the audio \"$audioTitle\" from the playlist \"$playlistTitle\" defined on the Youtube site, otherwise the audio will be downloaded again during the next playlist download. Or click on \"Cancel\" and choose \"Delete Audio ...\" instead of \"Delete Audio from Playlist as well ...\". So, the audio will be removed from the playable audio list, but will remain in the downloaded audio list, which will prevent its re-download.';
  }

  @override
  String deletedAudioAndMp3FilesMessage(
      Object deletedAudioAndMp3FilesNumber, Object deletedAudioTitles) {
    return '\n\nDeleted $deletedAudioAndMp3FilesNumber audio(s)\n  \"$deletedAudioTitles\"\nand their comment(s) and picture(s) as well as their MP3 file.';
  }

  @override
  String deletedExistingPlaylistsMessage(Object deletedExistingPlaylistNumber,
      Object deletedExistingPlaylistTitles) {
    return '\n\nDeleted $deletedExistingPlaylistNumber playlist(s)\n  \"$deletedExistingPlaylistTitles\"\nno longer present in the restore ZIP file and not created or modified after the ZIP creation.';
  }

  @override
  String get selectFileOrDirTitle => 'Restore MP3 Files';

  @override
  String get selectQuestion => 'What would you like to select ?';

  @override
  String get selectZipFile => 'A Single ZIP File';

  @override
  String get selectDirectory => 'A Directory with ZIP\'s';

  @override
  String get dateFormatddMMyyyy => 'dd/MM/yyyy';

  @override
  String get dateFormatMMddyyyy => 'MM/dd/yyyy';

  @override
  String get dateFormatyyyyMMdd => 'yyyy/MM/dd';

  @override
  String get clearEndLineSelection => 'Remove line breaks';

  @override
  String get clearEndLineSelectionTooltip =>
      'Line break invisible characters in incorrect locations can cause unwanted pauses in the generated audio. Removing them improves audio quality.';

  @override
  String get lastCommentDateTime => 'Last comment date/time';

  @override
  String get playableAudioDialogSortDescriptionTooltipTopLastCommentDateTimeBigger =>
      'Audio at the top has a last comment created or modified more recently than those at the bottom.';

  @override
  String get playableAudioDialogSortDescriptionTooltipTopLastCommentDateTimeSmaller =>
      'Audio at the top has a last comment created or modified less recently than those at the bottom.';

  @override
  String get audioStateNoComment => 'Not commented';

  @override
  String get commentedOn => 'Commented on';

  @override
  String get convertingDownloadedAudioToMP3 =>
      'Converting downloaded audio to MP3 ...';

  @override
  String get creatingMp3 => 'Creating MP3';

  @override
  String get renamePlaylistMenu => 'Rename Playlist ...';

  @override
  String get renamePlaylist => 'Rename Playlist';

  @override
  String get renamePlaylistLabel => 'Name';

  @override
  String get renamePlaylistTooltip => 'Renaming the playlist ...';

  @override
  String get renamePlaylistButton => 'Rename';

  @override
  String renamePictureFileNameAlreadyUsed(Object fileName) {
    return 'The picture file name \"$fileName.json\" already exists in the picture directory and so renaming the audio file with the name \"$fileName.mp3\" is not possible.';
  }

  @override
  String playlistWithTitleAlreadyExist(Object title) {
    return 'A playlist with the title \"$title\" already exists in the playlists list and so the playlist can\'t be renamed to this title.';
  }

  @override
  String invalidModifiedPlaylistTitle(Object playlistTitle) {
    return 'The modified playlist title \"$playlistTitle\" can not contain any comma. Please correct the title and retry ...';
  }
}

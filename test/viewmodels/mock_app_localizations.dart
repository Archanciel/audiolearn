import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// This mock class is necessary in order to define two getters
/// which return an empty string. This is necessary to avoid the
/// following error when running the playlist_download_view_test
/// tests:
///
/// ══╡ EXCEPTION CAUGHT BY RENDERING LIBRARY
/// ╞═════════════════════════════════════════════════════════
/// The following assertion was thrown during layout:
/// A RenderFlex overflowed by 44 pixels on the right.
///
/// The relevant error-causing widget was:
/// Row
/// Row:file:///C:/Users/Jean-Pierre/Development/Flutter/
/// audiolearn/lib/views/playlist_download_view.dart:510:28 ...
class MockAppLocalizations extends AppLocalizations {
  MockAppLocalizations() : super('en');

  // Getters changed in mock version. All other methods are the same
  // as the original class AppLocalizationsEn located in
  // audiolearn\.dart_tool\flutter_gen\gen_l10n from which the mock
  // code was copied.

  @override
  // Getter mock version replacing 'One' by ''
  String get downloadSingleVideoAudio => '';

  @override
  // Getter mock version replacing 'Playlist' by ''
  String get downloadSelectedPlaylist => '';

  @override
  String get appBarTitleDownloadAudio => 'Download Audio';

  @override
  String get downloadAudioScreen => "Download Audio screen";

  @override
  String get appBarTitleAudioPlayer => 'Audio Player';

  @override
  String get audioPlayerScreen => "Play Audio screen";

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
  String translate(Object language) {
    return 'Select $language';
  }

  @override
  String get musicalQualityTooltip => 'If set, downloads at musical quality';

  @override
  String get ofPreposition => 'of';

  @override
  String get atPreposition => 'at';

  @override
  String get ytPlaylistLinkLabel => 'Youtube Playlist Link';

  @override
  String get ytPlaylistLinkHintText => 'Enter a Youtube playlist link';

  @override
  String get addPlaylist => 'Add';

  @override
  String get renameAudioFileButton => 'Rename';

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
  String get defineSortFilterAudiosMenu => 'Sort/filter audio';

  @override
  String get clearSortFilterAudiosParmsHistoryMenu =>
      "Clear sort/filter parameters history";

  @override
  String get saveSortFilterAudiosOptionsToPlaylistMenu =>
      'Sub sort/filter audio';

  @override
  String get sortFilterDialogTitle => 'Sort and Filter Options';

  @override
  String get sortBy => 'Sort by:';

  @override
  String get audioDownloadDate => 'Audio download date';

  @override
  String get videoUploadDate => 'Video upload date';

  @override
  String get audioEnclosingPlaylistTitle => 'Audio playlist title';

  @override
  String get audioDuration => 'Audio duration';

  @override
  String get audioFileSize => 'Audio file size';

  @override
  String get audioMusicQuality => 'Audio music quality';

  @override
  String get audioDownloadSpeed => 'Audio download speed';

  @override
  String get audioDownloadDuration => 'Audio download duration';

  @override
  String get sortAscending => 'Asc';

  @override
  String get sortDescending => 'Desc';

  @override
  String get filterOptions => 'Filter options:';

  @override
  String get videoTitleOrDescription => 'Video title (and description)';

  @override
  String get startDownloadDate => 'Start downl date';

  @override
  String get endDownloadDate => 'End downl date';

  @override
  String get startUploadDate => 'Start upl date';

  @override
  String get endUploadDate => 'End upl date';

  @override
  String get fileSizeRange => 'File Size Range (bytes)';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get audioDurationRange => 'Audio duration range (hh:mm)';

  @override
  String get openYoutubeVideo => 'Open Youtube video';

  @override
  String get openYoutubePlaylist => 'Open Youtube playlist';

  @override
  String get apply => 'Apply';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteAudio => 'Delete audio';

  @override
  String get deleteAudioFromPlaylistAswell =>
      'Delete audio from playlist as well';

  @override
  String deleteAudioFromPlaylistAswellWarning(
      Object audioTitle, Object playlistTitle) {
    return 'If the deleted audio video "$audioTitle" remains in the "$playlistTitle" Youtube playlist, it will be downloaded again the next time you download the playlist !';
  }

  @override
  String get warningDialogTitle => 'WARNING';

  @override
  String updatedPlaylistUrlTitle(Object title) {
    return 'Playlist "$title" URL was updated. The playlist can be downloaded with its new URL.';
  }

  @override
  String addPlaylistTitle(Object title, Object quality) {
    return 'Playlist "$title" of $quality quality added at end of list of playlists.';
  }

  @override
  String invalidPlaylistUrl(Object url) {
    return 'Playlist with invalid URL "$url" neither added nor modified.';
  }

  @override
  String playlistWithUrlAlreadyInListOfPlaylists(Object url, Object title) {
    return 'Playlist "$title" with this URL "$url" is already in the list of playlists and so won\'t be recreated.';
  }

  @override
  String localPlaylistWithTitleAlreadyInListOfPlaylists(Object title) {
    return 'Local playlist "$title" already exists in the list of playlists and so won\'t be recreated.';
  }

  @override
  String downloadAudioYoutubeError(Object exceptionMessage) {
    return 'Error downloading audio from Youtube: "$exceptionMessage"';
  }

  @override
  String downloadAudioYoutubeErrorDueToLiveVideoInPlaylist(
      Object playlistTitle, Object liveVideoString) {
    return 'Error downloading audio from Youtube. The playlist "$playlistTitle" contains a live video which causes the playlist audio downloading failure. To solve the problem, after having downloaded the audio of the live video as explained below, remove the live video from the playlist, then restart the application and retry.\n\nThe live video URL contains the following string: "$liveVideoString". In order to add the live video audio to the playlist "$playlistTitle", download it separately as single video download adding it to the playlist "$playlistTitle".';
  }

  @override
  String downloadAudioFileAlreadyOnAudioDirectory(
      Object audioValidVideoTitle, Object fileName, Object playlistTitle) {
    return 'Audio "$audioValidVideoTitle" is contained in file "$fileName" present in the "$playlistTitle" playlist directory and so won\'t be redownloaded.';
  }

  @override
  String get noInternet => 'No Internet. Please connect your device and retry.';

  @override
  String invalidSingleVideoUUrl(Object url) {
    return 'Single video with invalid URL "$url" could not be downloaded.';
  }

  @override
  String get copyYoutubeVideoUrl => 'Copy Youtube video URL';

  @override
  String get displayAudioInfo => 'Display audio data';

  @override
  String get renameAudioFile => 'Rename audio file';

  @override
  String get moveAudioToPlaylist => 'Move audio to playlist ...';

  @override
  String get copyAudioToPlaylist => 'Copy audio in playlist ...';

  @override
  String get audioInfoDialogTitle => 'Audio Info';

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
  String get updatePlaylistJsonFilesMenu => 'Update playlist JSON files';

  @override
  String get compactVideoDescription => 'Compact video description';

  @override
  String get ignoreCase => 'Ignore case';

  @override
  String get searchInVideoCompactDescription => 'Include description';

  @override
  String get on => 'on';

  @override
  String get copyYoutubePlaylistUrl => 'Copy Youtube playlist URL';

  @override
  String get displayPlaylistInfo => 'Display playlist data';

  @override
  String get playlistInfoDialogTitle => 'Playlist Info';

  @override
  String get playlistTitleLabel => 'Playlist title';

  @override
  String get playlistIdLabel => 'Playlist ID';

  @override
  String get playlistUrlLabel => 'Playlist URL';

  @override
  String get playlistDownloadPathLabel => 'Playlist download path';

  @override
  String get playlistLastDownloadDateTimeLabel =>
      'Playlist last downl date time';

  @override
  String get playlistIsSelectedLabel => 'Playlist is selected';

  @override
  String get playlistTotalAudioNumberLabel => 'Playlist total audio number';

  @override
  String get playlistPlayableAudioNumberLabel => 'Playable audio number';

  @override
  String get playlistPlayableAudioTotalDurationLabel =>
      'Playable audio total duration';

  @override
  String get playlistPlayableAudioTotalSizeLabel => 'Playable audio total size';

  @override
  String get updatePlaylistPlayableAudioList => 'Update playable audio list';

  @override
  String updatedPlayableAudioLst(Object number, Object title) {
    return 'Playable audio list for playlist "$title" was updated. $number audio(s) were removed.';
  }

  @override
  String get addYoutubePlaylistDialogTitle => 'Add Playlist';

  @override
  String get addLocalPlaylistDialogTitle => 'Add Playlist';

  @override
  String get renameAudioFileDialogTitle => 'Rename Audio File';

  @override
  String get renameAudioFileDialogComment =>
      'Renaming audio file in order to improve their playing order.';

  @override
  String get youtubePlaylistUrlLabel => 'Youtube playlist URL';

  @override
  String get localPlaylistTitleLabel => 'Local playlist title';

  @override
  String get renameAudioFileLabel => 'Audio file name';

  @override
  String get playlistTypeLabel => 'Playlist type';

  @override
  String get playlistTypeYoutube => 'Youtube';

  @override
  String get playlistTypeLocal => 'Local';

  @override
  String get playlistQualityLabel => 'Playlist quality';

  @override
  String get playlistQualityMusic => 'music';

  @override
  String get playlistQualityAudio => 'audio';

  @override
  String get audioQualityHighSnackBarMessage => 'Download at music quality';

  @override
  String get audioQualityLowSnackBarMessage => 'Download at audio quality';

  @override
  String get add => 'Add';

  @override
  String get noPlaylistSelectedForSingleVideoDownloadWarning =>
      'No playlist selected for single video download. Select one playlist and retry ...';

  @override
  String get tooManyPlaylistSelectedForSingleVideoDownloadWarning =>
      'More than one playlist selected for single video download. Select only one playlist and retry ...';

  @override
  String get confirmDialogTitle => 'CONFIRMATION';

  @override
  String confirmSingleVideoAudioPlaylistTitle(Object title) {
    return 'Confirm playlist "$title" for downloading single video audio.';
  }

  @override
  String get playlistJsonFileSizeLabel => 'JSON file size';

  @override
  String get playlistOneSelectedDialogTitle => 'Select a playlist';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get enclosingPlaylistLabel => 'Enclosing playlist';

  @override
  String audioMovedFromLocalPlaylistToLocalPlaylist(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" moved from local playlist "$fromPlaylistTitle" to local playlist "$toPlaylistTitle".';
  }

  @override
  String audioMovedFromLocalPlaylistToYoutubePlaylist(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" moved from local playlist "$fromPlaylistTitle" to Youtube playlist "$toPlaylistTitle".';
  }

  @override
  String audioMovedFromYoutubePlaylistToLocalPlaylistPlaylistWarning(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" moved from Youtube playlist "$fromPlaylistTitle" to local playlist "$toPlaylistTitle".\n\nIF THE DELETED AUDIO VIDEO "$audioTitle" REMAINS IN THE "$fromPlaylistTitle" YOUTUBE PLAYLIST, IT WILL BE DOWNLOADED AGAIN THE NEXT TIME YOU DOWNLOAD THE PLAYLIST !';
  }

  @override
  String audioMovedFromYoutubePlaylistToYoutubePlaylistPlaylistWarning(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" moved from Youtube playlist "$fromPlaylistTitle" to Youtube playlist "$toPlaylistTitle".\n\nIF THE DELETED AUDIO VIDEO "$audioTitle" REMAINS IN THE "$fromPlaylistTitle" YOUTUBE PLAYLIST, IT WILL BE DOWNLOADED AGAIN THE NEXT TIME YOU DOWNLOAD THE PLAYLIST !';
  }

  @override
  String audioMovedFromYoutubePlaylistToLocalPlaylist(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" moved from Youtube playlist "$fromPlaylistTitle" to local playlist "$toPlaylistTitle".';
  }

  @override
  String audioMovedFromYoutubePlaylistToYoutubePlaylist(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" moved from Youtube playlist "$fromPlaylistTitle" to Youtube playlist "$toPlaylistTitle".';
  }

  @override
  String get author => 'Author:';

  @override
  String get authorName => 'Jean-Pierre Schnyder / Switzerland';

  @override
  String get aboutAppDescription =>
      'This application allows you to download audio from Youtube playlists or from single video links.\n\nThe future version will enable you to listen the audio, to add comments to them and to extract significative portions of the audio and share them or combine them in a new summary audio.';

  @override
  String get keepAudioEntryInSourcePlaylist =>
      'Keep audio entry in source playlist';

  @override
  String get movedFromPlaylistLabel => 'Moved from playlist';

  @override
  String get movedToPlaylistLabel => 'Moved to playlist';

  @override
  String get downloadSingleVideoButtonTooltip => 'Download single video audio';

  @override
  String get addPlaylistButtonTooltip => 'Add Youtube or local playlist';

  @override
  String get stopDownloadingButtonTooltip => 'Stop downloading';

  @override
  String get playlistToggleButtonInPlaylistDownloadViewTooltip =>
      'Show/hide playlists';

  @override
  String get downloadSelPlaylistsButtonTooltip =>
      'Download audio of selected playlist';

  @override
  String get audioOneSelectedDialogTitle => 'Select an audio';

  @override
  String get audioPositionLabel => 'Audio position';

  @override
  String get audioStateLabel => 'Audio state';

  @override
  String get audioStatePaused => 'Paused';

  @override
  String get audioStatePlaying => 'Playing';

  @override
  String get audioStateTerminated => 'Stopped';

  @override
  String get audioStateNotListened => 'Not started';

  @override
  String get audioPausedDateTimeLabel => 'Date/time paused';

  @override
  String get audioPlaySpeedLabel => 'Play speed';

  @override
  String get playlistAudioPlaySpeedLabel => "Audio play speed";

  @override
  String get audioPlayVolumeLabel => 'Play volume';

  @override
  String audioCopiedFromLocalPlaylistToLocalPlaylist(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" copied from local playlist "$fromPlaylistTitle" to local playlist "$toPlaylistTitle".';
  }

  @override
  String audioCopiedFromLocalPlaylistToYoutubePlaylist(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" copied from local playlist "$fromPlaylistTitle" to Youtube playlist "$toPlaylistTitle".';
  }

  @override
  String audioCopiedFromYoutubePlaylistToLocalPlaylist(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" copied from Youtube playlist "$fromPlaylistTitle" to local playlist "$toPlaylistTitle".';
  }

  @override
  String audioCopiedFromYoutubePlaylistToYoutubePlaylist(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" copied from Youtube playlist "$fromPlaylistTitle" to Youtube playlist "$toPlaylistTitle".';
  }

  @override
  String get copiedFromPlaylistLabel => 'Copied from playlist';

  @override
  String get copiedToPlaylistLabel => 'Copied to playlist';

  @override
  String get audioPlayerViewNoCurrentAudio => 'No audio selected';

  @override
  String get deletePlaylist => 'Delete playlist ...';

  @override
  String deleteYoutubePlaylistDialogTitle(Object title) {
    return 'Delete Youtube Playlist "$title"';
  }

  @override
  String deleteLocalPlaylistDialogTitle(Object title) {
    return 'Delete Local Playlist "$title"';
  }

  @override
  String get deletePlaylistDialogComment =>
      'Deleting the playlist and all its audio as well as its JSON file and its directory.';

  @override
  String get appBarTitleAudioExtractor => 'Audio Extractor';

  @override
  String get setAudioPlaySpeedDialogTitle => 'Playback speed';

  @override
  String get setAudioPlaySpeedTooltip => 'Set audio play speed';

  @override
  String get increaseAudioVolumeIconButtonTooltip => 'Increase audio volume';

  @override
  String get decreaseAudioVolumeIconButtonTooltip => 'Increase audio volume';

  @override
  String get resetSortFilterOptionsTooltip => 'Reset sort and filter options';

  @override
  String get clickToSetAscendingOrDescendingTooltip =>
      'Click to set ascending or descending';

  @override
  String get and => 'And';

  @override
  String get or => 'Or';

  @override
  String get audioTitleSearchSentenceTextFieldTooltip =>
      "Contains a word or a sentence searched on video title and on video description if checkbox 'Include description' is set";

  @override
  String get andSentencesTooltip =>
      "If set, only audio containing all the listed words or sentences are selected";

  @override
  String get orSentencesTooltip =>
      "If set, audio containing one of the listed words or sentences are selected";

  @override
  String get searchInVideoCompactDescriptionTooltip =>
      "If set, search words or sentences are searched on video description as well";

  @override
  String get exclude => "Exclude ";

  @override
  String get fullyPlayed => "fully played ";

  @override
  String get audio => "audio";

  @override
  String get fullyListened => "Fully listened";

  @override
  String get partiallyListened => "Partially listened";

  @override
  String get notListened => "Not listened";

  @override
  String saveSortFilterOptionsToPlaylist(Object title) => "To playlist $title";

  @override
  String get saveButton => "Save";

  @override
  String errorInPlaylistJsonFile(Object filePathName) =>
      "File $filePathName contains an invalid data definition. Try finding the problem in order to correct it before executing again the operation.";

  @override
  String youtubePlaylistWithTitleAlreadyInListOfPlaylists(Object title) =>
      "Youtube playlist \"{title}\" already exists in the list of playlists and so a local playlist with this title won't be created.";

  @override
  String get updatePlaylistJsonFilesMenuTooltip =>
      "If one or several playlist directories containing or not audio were manually added to the application data root directory or if audio were manually deleted from one or several playlist directories, this functionality updates the playlist JSON files as well as the application settings JSON file in order to reflect the changes in the application screens.";

  @override
  String get updatePlaylistPlayableAudioListTooltip =>
      "If audio were manually deleted from one or several playlist directories, this functionality updates the playlist JSON files to reflect the changes in the application screens.";

  @override
  String get audioPlayedInThisOrderTooltip =>
      "Les audio sont joués dans cet ordre.";

  @override
  String get playableAudioDialogSortDescriptionTooltipBottomDownloadBefore =>
      "Les audio au bas de l'écran ont été téléchargés avant les audio en haut de l'écran.";

  @override
  String get playableAudioDialogSortDescriptionTooltipBottomDownloadAfter =>
      "Les audio au bas de l'écran ont été téléchargés après les audio en haut de l'écran.";

  @override
  String get playableAudioDialogSortDescriptionTooltipBottomUploadBefore =>
      "Les audio au bas de l'écran ont été téléchargés avant les audio en haut de l'écran.";

  @override
  String get playableAudioDialogSortDescriptionTooltipBottomUploadAfter =>
      "Les audio au bas de l'écran ont été téléchargés après les audio en haut de l'écran.";

  @override
  String get playableAudioDialogSortDescriptionTooltipTopDurationBigger =>
      "Les audio au bas de l'écran ont été téléchargés avant les audio en haut de l'écran.";

  @override
  String get playableAudioDialogSortDescriptionTooltipTopDurationSmaller =>
      "Les audio au bas de l'écran ont été téléchargés après les audio en haut de l'écran.";

  @override
  String get playableAudioDialogSortDescriptionTooltipTopRemainingDurationBigger =>
      "Les audio au bas de l'écran ont été téléchargés avant les audio en haut de l'écran.";

  @override
  String get playableAudioDialogSortDescriptionTooltipTopRemainingDurationSmaller =>
      "Les audio au bas de l'écran ont été téléchargés après les audio en haut de l'écran.";

  @override
  String get saveAs => "Save as:";

  @override
  String get sortFilterSaveAsTextFieldTooltip =>
      "Saving with the same \"Save as\" name updates the existing sort/filter settings to the modified parameters.";

  @override
  String get applySortFilterToView => "Apply sort/filter to view";

  @override
  String get saveSortFilterOptionsTooltip =>
      "If the name already exists, the existing sort/filter options are updated with the modified parameters.";

  @override
  String get deleteSortFilterOptionsTooltip =>
      "If those sort/filter options are applied in a view, the Default sort/filter options will be applied instead.";

  @override
  String get deleteShort => "Delete";

  @override
  String get applySortFilterToViewTooltip =>
      "Selecting sort/filter application to one or two audio views. This will be applied to the playlists to which this sort/filter is associated.";

  @override
  String get sortFilterParametersDefaultName => "default";

  @override
  String get sortFilterParametersDownloadButtonHint => "Select sort/filter";

  @override
  String audioNotMovedFromLocalPlaylistToLocalPlaylist(
    Object audioTitle,
    Object fromPlaylistTitle,
    Object toPlaylistTitle,
  ) =>
      "Audio \"{audioTitle}\" NOT moved from local playlist \"{fromPlaylistTitle}\" to local playlist \"{toPlaylistTitle}\" since it is already present in the destination playlist.";

  @override
  String audioNotMovedFromLocalPlaylistToYoutubePlaylist(
    Object audioTitle,
    Object fromPlaylistTitle,
    Object toPlaylistTitle,
  ) =>
      "Audio \"{audioTitle}\" NOT moved from local playlist \"{fromPlaylistTitle}\" to Youtube playlist \"{toPlaylistTitle}\" since it is already present in the destination playlist.";

  @override
  String audioNotMovedFromYoutubePlaylistToLocalPlaylist(
    Object audioTitle,
    Object fromPlaylistTitle,
    Object toPlaylistTitle,
  ) =>
      "Audio \"{audioTitle}\" NOT moved from Youtube playlist \"{fromPlaylistTitle}\" to local playlist \"{toPlaylistTitle}\" since it is already present in the destination playlist.";

  @override
  String audioNotMovedFromYoutubePlaylistToYoutubePlaylist(
    Object audioTitle,
    Object fromPlaylistTitle,
    Object toPlaylistTitle,
  ) =>
      "Audio \"{audioTitle}\" NOT moved from Youtube playlist \"{fromPlaylistTitle}\" to Youtube playlist \"{toPlaylistTitle}\" since it is already present in the destination playlist.";

  @override
  String audioNotCopiedFromLocalPlaylistToLocalPlaylist(
    Object audioTitle,
    Object fromPlaylistTitle,
    Object toPlaylistTitle,
  ) =>
      "Audio \"{audioTitle}\" NOT copied from local playlist \"{fromPlaylistTitle}\" to local playlist \"{toPlaylistTitle}\" since it is already present in the destination playlist.";

  @override
  String audioNotCopiedFromLocalPlaylistToYoutubePlaylist(
    Object audioTitle,
    Object fromPlaylistTitle,
    Object toPlaylistTitle,
  ) =>
      "Audio \"{audioTitle}\" NOT copied from local playlist \"{fromPlaylistTitle}\" to Youtube playlist \"{toPlaylistTitle}\" since it is already present in the destination playlist.";

  @override
  String audioNotCopiedFromYoutubePlaylistToLocalPlaylist(
    Object audioTitle,
    Object fromPlaylistTitle,
    Object toPlaylistTitle,
  ) =>
      "Audio \"{audioTitle}\" NOT copied from Youtube playlist \"{fromPlaylistTitle}\" to local playlist \"{toPlaylistTitle}\" since it is already present in the destination playlist.";

  @override
  String audioNotCopiedFromYoutubePlaylistToYoutubePlaylist(
    Object audioTitle,
    Object fromPlaylistTitle,
    Object toPlaylistTitle,
  ) =>
      "Audio \"{audioTitle}\" NOT copied from Youtube playlist \"{fromPlaylistTitle}\" to Youtube playlist \"{toPlaylistTitle}\" since it is already present in the destination playlist.";

  @override
  String playlistRootPathNotExistWarning(Object playlistRootPath) =>
      "The playlist root path \"{playlistRootPath}\" does not exist. Please enter a valid playlist root path and retry ...";

  @override
  String get keepAudioEntryInSourcePlaylistTooltip =>
      "Maintains audio data in the original playlist's JSON file, even after the audio file is transferred to another playlist. This prevents re-downloading the audio file if it no longer exists in its original directory.";

  @override
  String get noPlaylistSelectedForAudioCopyWarning =>
      "No playlist selected for copying audio. Select one playlist and retry ...";

  @override
  String get noPlaylistSelectedForAudioMoveWarning =>
      "No playlist selected for moving audio. Select one playlist and retry ...";

  @override
  String get audioRemainingDuration => "Audio listenable remaining duration";

  @override
  String get noSortFilterSaveAsNameWarning =>
      "Le nom de sauvegarde des options de tri/filtre ne peut pas être vide. Entrez un nom valide et rééssayez.";

  @override
  String get applyButton => "Apply";

  @override
  String get applySortFilterOptionsTooltip =>
      "Since the name is empty, the set sort/filter parameters are applied and then added to the sort filter history.";

  @override
  String get noSortFilterParameterWasModifiedWarning =>
      "No sort/filter parameter was modified. Please set a sort/filter parameter and retry ...";

  @override
  String get deletedSortFilterParameterNotExistWarning =>
      "The sort/filter parameter you try to delete does not exist. Please select an existing sort/filter parameter and retry ...";

  @override
  String get historicalSortFilterParameterWasDeletedWarning =>
      "The historical sort/filter parameter was deleted.";

  @override
  String get allHistoricalSortFilterParameterWereDeletedWarning =>
      "All historical sort/filter parameters were deleted.";

  @override
  String get allHistoricalSortFilterParametersDeleteConfirmation =>
      "Deleting all historical sort/filter parameters.";

  @override
  String get appBarMenuOpenSettingsDialog => "Application settings ...";

  @override
  String get appSettingsDialogTitle => "Application Settings";

  @override
  String get setAudioPlaySpeed => "Set audio play speed ...";

  @override
  String get applyToAlreadyDownloadedAudio =>
      "Apply to audio already downloaded";

  @override
  String get applyToAlreadyDownloadedAudioTooltip =>
      "If set, the playback speed is applied to the playable audio of all the existing playlists. If not set and if the apply to the existing playlist checkbox is set, then the playback speed will be applied to the next downloaded audio of the existing playlists.";

  @override
  String get applyToAlreadyDownloadedAudioOfCurrentPlaylistTooltip =>
      "If set, the playback speed is applied to the playable audio of the playlist. If not set, then the playback speed will be applied to the next downloaded audio of the playlist.";

  @override
  String get applyToExistingPlaylist => "apply to existing\nplaylists";

  @override
  String get applyToExistingPlaylistTooltip =>
      "If set, the playback speed is applied to all the existing playlists. If not set, the playback speed will be applied only to the next added playlists.";

  @override
  String get playlistRootpathLabel => "Playlists root path";

  @override
  String get closeTextButton => "Close";

  @override
  String get helpDialogTitle => "Help";

  @override
  String get defaultApplicationHelpTitle => "Default Application";

  @override
  String get defaultApplicationHelpContent =>
      "If no option is selected, the defined playback speed will only apply to newly created playlists.";

  @override
  String get modifyingExistingPlaylistsHelpTitle =>
      "Modifying Existing Playlists";

  @override
  String get modifyingExistingPlaylistsHelpContent =>
      "By selecting the first checkbox, all existing playlists will be set to use the new playback speed. However, this change will only affect audio files that are downloaded after this option is enabled.";

  @override
  String get alreadyDownloadedAudiosHelpTitle => "Already Downloaded Audio";

  @override
  String get alreadyDownloadedAudiosHelpContent =>
      "Selecting the second checkbox allows you to change the playback speed for audio files already present on the device.";

  @override
  String get excludingFutureDownloadsHelpTitle => "Excluding Future Downloads";

  @override
  String get excludingFutureDownloadsHelpContent =>
      "If only the second checkbox is checked, the playback speed will not be modified for audio that will be downloaded later in existing playlists. However, as mentioned previously, new playlists will use the newly defined playback speed for all downloaded audio.";

  @override
  String get alreadyDownloadedAudiosPlaylistHelpTitle =>
      "Already Downloaded Audio";

  @override
  String get alreadyDownloadedAudiosPlaylistHelpContent =>
      "Selecting the checkbox allows you to change the playback speed for playlist audio files already present on the device.";

  @override
  String get commentsIconButtonTooltip =>
      "Show or insert comments at specific points in the audio.";

  @override
  String get commentsDialogTitle => "Comment";

  @override
  String get addPositionedCommentTooltip =>
      "Add a comment at the current position in the audio.";

  @override
  String get commentTitle => "Title";

  @override
  String get commentText => "Comment";

  @override
  String get commentDialogTitle => "Comment";

  @override
  String get update => "Update";

  @override
  String get deleteCommentConfirnTitle => "Delete comment";

  @override
  String deleteCommentConfirnBody(
    Object title,
  ) =>
      "Deleting comment \"$title\".";

  @override
  String get commentMenu => "Audio comments ...";

  @override
  String get tenthOfSecondsCheckboxTooltip =>
      "Enable this checkbox to specify the comment position with precision up to a tenth of second.";

  @override
  String get setCommentPosition => "Set comment position";

  @override
  String get commentPosition => "Position (hh:)mm:ss";

  @override
  String get commentPositionExplanation =>
      "The proposed comment position corresponds to the current audio position. Modify it if needed and select to which position it must be applied.";

  @override
  String get commentStartPosition => "Start";

  @override
  String get commentEndPosition => "End";

  @override
  String get updateCommentStartEndPositionTooltip =>
      "Update comment start or end position";

  @override
  String get commentCreationDateTooltip => "Comment creation date";

  @override
  String get commentUpdateDateTooltip => "Comment last update date";

  @override
  String get playlistCommentMenu => "Comments of playlist audio ...";

  @override
  String get modifyAudioTitleDialogTitle => "Modify Audio Title";

  @override
  String get modifyAudioTitleDialogComment =>
      "Improving or translating audio title ...";

  @override
  String get modifyAudioTitleLabel => "Audio title";

  @override
  String get modifyAudioTitleButton => "Modify";

  @override
  String get modifyAudioTitle => "Modify audio title ...";

  @override
  String renameFileNameAlreadyUsed(
    Object fileName,
  ) =>
      "The file name \"$fileName\" already exists in the same directory and cannot be used.";

  @override
  String invalidLocalPlaylistTitle(
    Object playlistTitle,
  ) =>
      "This local playlist title \"$playlistTitle\" can not contain commas. Commas are replaced by colons.";

  @override
  String invalidYoutubePlaylistTitle(
    Object playlistTitle,
  ) =>
      "This Youtube playlist title \"$playlistTitle\" can not contain commas. Commas are replaced by colons.";

  @override
  String setValueToTargetWarning(
    Object invalidValueWarningParam,
    Object maxMinPossibleValue,
  ) =>
      "The entered value $invalidValueWarningParam ($maxMinPossibleValue). Please correct it and retry ...";

  @override
  String get invalidValueTooBig => "exceeds the maximal value";

  @override
  String get invalidValueTooSmall => "is below the minimal value";

  @override
  String noCheckboxSelectedWarning(
    Object atLeast,
  ) =>
      "No checkbox selected. Please select $atLeast checkbox before clicking 'Ok', or click 'Cancel' to exit.";

  @override
  String get atLeast => "at least one";

  @override
  String confirmCommentedAudioDeletionTitle(
    Object audioTitle,
  ) =>
      "Confirm deletion of the commented audio \"$audioTitle\"";

  @override
  String confirmCommentedAudioDeletionComment(
    Object commentNumber,
  ) =>
      "The audio contains \"$commentNumber\" comments which will be deleted as well. Confirm deletion ?";

  @override
  String get commentStartPositionTooltip => "Comment start position";

  @override
  String get playlistToggleButtonInAudioPlayerViewTooltip =>
      "Show/hide playlists. Then select a playlist to display its current listened audio.";

  @override
  String get playlistCommentsDialogTitle => "Playlist audio comments";

  @override
  String playlistSelectedSnackBarMessage(
    Object title,
  ) =>
      "Playlist \"$title\" selected";

  @override
  String get playlistImportAudioMenu => "Import audio files ...";

  @override
  String get playlistImportAudioMenuTooltip =>
      "Import audio files into the playlist in order to listen an add comments to them.";

  @override
  String get setPlaylistAudioPlaySpeedTooltip =>
      "Set audio play speed for the playlist existing and next downloaded audio.";

  @override
  String audioNotImportedToLocalPlaylist(
    Object rejectedImportedAudioFileNames,
    Object toPlaylistTitle,
  ) =>
      "Audio \"$rejectedImportedAudioFileNames\" NOT imported to local playlist \"$toPlaylistTitle\" since it is already present in the destination playlist.";

  @override
  String audioNotImportedToYoutubePlaylist(
    Object rejectedImportedAudioFileNames,
    Object toPlaylistTitle,
  ) =>
      "Audio \"$rejectedImportedAudioFileNames\" NOT imported to Youtube playlist \"$toPlaylistTitle\" since it is already present in the destination playlist.";

  @override
  String audioImportedToLocalPlaylist(
    Object importedAudioFileNames,
    Object toPlaylistTitle,
  ) =>
      "Audio(s) \"$importedAudioFileNames\" imported to local playlist \"$toPlaylistTitle\".";

  @override
  String audioImportedToYoutubePlaylist(
    Object importedAudioFileNames,
    Object toPlaylistTitle,
  ) =>
      "Audio(s) \"$importedAudioFileNames\" imported to Youtube playlist \"$toPlaylistTitle\".";

  @override
  String get imported => "imported";

  @override
  String get audioImportedInfoDialogTitle => "Imported Audio Info";

  @override
  String get audioTitleLabel => "Imported audio title";

  @override
  String get importedAudioDateTimeLabel => "Imported audio date time";

  @override
  String get importedAudioUrlLabel => "Imported audio URL";

  @override
  String get importedAudioDescriptionLabel => "Imported audio description";

  @override
  String get sortFilterParametersAppliedName => "applied";

  @override
  String get lastListenedDateTime => "Last listened date/time";

  @override
  String get playableAudioDialogSortDescriptionTooltipTopLastListenedDatrTimeBigger =>
      "Audio at the top were listened more recently than those at the bottom.";

  @override
  String get playableAudioDialogSortDescriptionTooltipTopLastListenedDatrTimeSmaller =>
      "Audio at the top were listened less recently than those at the bottom.";

  @override
  String get downloadSingleVideoAudioAtMusicQuality =>
      "Download single video audio at music quality";

  @override
  String confirmSingleVideoAudioAtMusicQualityPlaylistTitle(
    Object title,
  ) =>
      "Confirm target playlist \"$title\" for downloading single video audio at music quality.";

  @override
  String get videoTitleNotWrittenInOccidentalLettersWarning =>
      "Since the original video title is not written in occidental letters, the audio title is empty. You can use the 'Modify audio title ...' audio menu in order to define a valid title. Same remark for the audio file name ...";

  @override
  String renameCommentFileNameAlreadyUsed(
    Object fileName,
  ) =>
      "The comment file name \"$fileName\".json already exists in the comment directory and so renaming the audio file with this name \"$fileName\".mp3 is not possible.";

  @override
  String renameFileNameInvalid(
    Object fileName,
  ) =>
      "The audio file name \"$fileName\" has no mp3 extension and so is invalid.";

  @override
  String renameAudioFileConfirmation(
    Object oldFileIame,
    Object newFileName,
  ) =>
      "Audio file \"$oldFileIame.mp3\" renamed to \"$newFileName.mp3\".";

  @override
  String renameAudioAndCommentFileConfirmation(
    Object oldFileIame,
    Object newFileName,
  ) =>
      "Audio file \"$oldFileIame.mp3\" renamed to \"$newFileName.mp3\" as well as comment file \"$oldFileIame.json\" renamed to \"$newFileName.json\".";

  @override
  String forScreen(
    Object screenName,
  ) =>
      "For \"$screenName\" screen";

  @override
  String saveSortFilterOptionsToPlaylistDialogTitle(
    Object sortFilterParmsName,
  ) =>
      "Save Sort/Filter \"$sortFilterParmsName\"";

  @override
  String get downloadVideoUrlsFromTextFileInPlaylist =>
      "Download video URLs from text file ...";

  @override
  String get downloadVideoUrlsFromTextFileInPlaylistTooltip =>
      "Download audio to the playlist from video URLs listed in a selected text file. The text file must contain one video URL per line.";

  @override
  String downloadAudioFromVideoUrlsInPlaylistTitle(
    Object title,
  ) =>
      "Download video audio to playlist \"$title\"";

  @override
  String downloadAudioFromVideoUrlsInPlaylist(
    Object number,
  ) =>
      "Downloading $number audio.";

  @override
  String notRedownloadAudioFilesInPlaylistDirectory(
    Object number,
    Object playlistTitle,
  ) =>
      "$number audio are already contained in the target playlist \"$playlistTitle\" directory and so were not redownloaded.";

  @override
  String get clickToSetAscendingOrDescendingPlayingOrderTooltip =>
      "Click to set ascending or descending playing order.";

  @override
  String get removeSortFilterAudiosOptionsFromPlaylistMenu =>
      "Remove sort/filter options from playlist";

  @override
  String removeSortFilterOptionsFromPlaylist(
    Object title,
  ) =>
      "From playlist \"$title\"";

  @override
  String fromScreen(
    Object screenName,
  ) =>
      "From \"$screenName\" screen";

  @override
  String removeSortFilterOptionsFromPlaylistDialogTitle(
    Object sortFilterParmsName,
  ) =>
      "Remove Sort/Filter options \"$sortFilterParmsName\"";

  @override
  String get removeButton => "Remove";

  @override
  String saveSortFilterParmsConfirmation(
    Object sortFilterParmsName,
    Object playlistTitle,
    Object forViewMessage,
  ) =>
      "Sort/filter parameters \"$sortFilterParmsName\" were saved to playlist \"$playlistTitle\" for screen(s) \"$forViewMessage\".";

  @override
  String removeSortFilterParmsConfirmation(
    Object sortFilterParmsName,
    Object playlistTitle,
    Object forViewMessage,
  ) =>
      "Sort/filter parameters \"$sortFilterParmsName\" were removed from playlist \"$playlistTitle\" on screen(s) \"$forViewMessage\".";

  @override
  String playlistSortFilterLabel(
    Object screenName,
  ) =>
      "\"$screenName\" sort/filter";

  @override
  String get playlistAudioCommentsLabel => "Audio comments";

  @override
  String get listenedOn => "Listened on";

  @override
  String get remaining => "Remaining";

  @override
  String get youtubeChannelLabel => "Youtube channel";

  @override
  String get searchInYoutubeChannelName => "Include Youtube channel";

  @override
  String get searchInYoutubeChannelNameTooltip =>
      "If set, search words or sentences are searched on Youtube channel name as well.";

  @override
  String get savePlaylistAndCommentsToZipMenu =>
      "Save playlists and comments to zip file ...";

  @override
  String get savePlaylistAndCommentsToZipTooltip =>
      "Save the playlists and their audio comments to a zip file. The zip file will contain the playlists JSON files as well as the comments JSON files.";

  @override
  String get setYoutubeChannelMenu => "Youtube channel setting";

  @override
  String confirmYoutubeChannelModifications(
    Object numberOfModifiedDownloadedAudio,
    Object numberOfModifiedPlayableAudio,
  ) =>
      "The Youtube channel was modified in $numberOfModifiedDownloadedAudio downloaded audio and in $numberOfModifiedPlayableAudio playable audio.";

  @override
  String get playlistPlayableAudioTotalRemainingDurationLabel =>
      "Playable audio total remaining duration";

  @override
  String get rewindAudioToStart => "Rewind Audio to Start";

  @override
  String get rewindAudioToStartTooltip =>
      "Rewind all playlist audio to start position. This is usefull in order to replay the audio.";

  @override
  String rewindedPlayableAudioNumber(
    Object number,
  ) =>
      "$number playlist audio were repositioned to start.";
}

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
/// Row:file:///C:/Users/Jean-Pierre/development/flutter/
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
    return 'Youtube playlist "$title" URL was updated. The playlist can be downloaded with its new URL.';
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
  String get playlistOneSelectedDialogTitle => 'Select a Playlist';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get enclosingPlaylistLabel => 'Enclosing playlist';

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
  String get appBarTitleAudioExtractor => 'Audio Extractor';

  @override
  String get setAudioPlaySpeedDialogTitle => 'Playback Speed';

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
  String get videoTitleSearchSentenceTextFieldTooltip =>
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
    Object notCopiedOrMovedReason,
    Object toPlaylistTitle,
  ) =>
      "Audio \"{audioTitle}\" NOT moved from local playlist \"{fromPlaylistTitle}\" to local playlist \"{toPlaylistTitle}\" {notCopiedOrMovedReason}.";

  @override
  String audioNotMovedFromLocalPlaylistToYoutubePlaylist(
    Object audioTitle,
    Object fromPlaylistTitle,
    Object notCopiedOrMovedReason,
    Object toPlaylistTitle,
  ) =>
      "Audio \"{audioTitle}\" NOT moved from local playlist \"{fromPlaylistTitle}\" to Youtube playlist \"{toPlaylistTitle}\" {notCopiedOrMovedReason}.";

  @override
  String audioNotMovedFromYoutubePlaylistToLocalPlaylist(
    Object audioTitle,
    Object fromPlaylistTitle,
    Object notCopiedOrMovedReason,
    Object toPlaylistTitle,
  ) =>
      "Audio \"{audioTitle}\" NOT moved from Youtube playlist \"{fromPlaylistTitle}\" to local playlist \"{toPlaylistTitle}\" {notCopiedOrMovedReason}.";

  @override
  String audioNotMovedFromYoutubePlaylistToYoutubePlaylist(
    Object audioTitle,
    Object fromPlaylistTitle,
    Object notCopiedOrMovedReason,
    Object toPlaylistTitle,
  ) =>
      "Audio \"{audioTitle}\" NOT moved from Youtube playlist \"{fromPlaylistTitle}\" to Youtube playlist \"{toPlaylistTitle}\" {notCopiedOrMovedReason}.";

  @override
  String audioNotCopiedFromLocalPlaylistToLocalPlaylist(
    Object audioTitle,
    Object fromPlaylistTitle,
    Object notCopiedOrMovedReason,
    Object toPlaylistTitle,
  ) =>
      "Audio \"{audioTitle}\" NOT copied from local playlist \"{fromPlaylistTitle}\" to local playlist \"{toPlaylistTitle}\" {notCopiedOrMovedReason}.";

  @override
  String audioNotCopiedFromLocalPlaylistToYoutubePlaylist(
    Object audioTitle,
    Object fromPlaylistTitle,
    Object notCopiedOrMovedReason,
    Object toPlaylistTitle,
  ) =>
      "Audio \"{audioTitle}\" NOT copied from local playlist \"{fromPlaylistTitle}\" to Youtube playlist \"{toPlaylistTitle}\" {notCopiedOrMovedReason}.";

  @override
  String audioNotCopiedFromYoutubePlaylistToLocalPlaylist(
    Object audioTitle,
    Object fromPlaylistTitle,
    Object notCopiedOrMovedReason,
    Object toPlaylistTitle,
  ) =>
      "Audio \"{audioTitle}\" NOT copied from Youtube playlist \"{fromPlaylistTitle}\" to local playlist \"{toPlaylistTitle}\" {notCopiedOrMovedReason}.";

  @override
  String audioNotCopiedFromYoutubePlaylistToYoutubePlaylist(
    Object audioTitle,
    Object fromPlaylistTitle,
    Object notCopiedOrMovedReason,
    Object toPlaylistTitle,
  ) =>
      "Audio \"{audioTitle}\" NOT copied from Youtube playlist \"{fromPlaylistTitle}\" to Youtube playlist \"{toPlaylistTitle}\" {notCopiedOrMovedReason}.";

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
  String get deleteCommentConfirnTitle => "Delete Comment";

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
  String get playlistToggleButtonInAudioPlayerViewTooltip =>
      "Show/hide playlists. Then select a playlist to display its current listened audio.";

  @override
  String get playlistCommentsDialogTitle => "Playlist Audio Comments";

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
      "Audio \"$rejectedImportedAudioFileNames\" NOT imported to local playlist \"$toPlaylistTitle\" {notCopiedOrMovedReason}.";

  @override
  String audioNotImportedToYoutubePlaylist(
    Object rejectedImportedAudioFileNames,
    Object toPlaylistTitle,
  ) =>
      "Audio \"$rejectedImportedAudioFileNames\" NOT imported to Youtube playlist \"$toPlaylistTitle\" {notCopiedOrMovedReason}.";

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

  @override
  String get dateFormat => "Select Date Format ...";

  @override
  String get dateFormatSelectionDialogTitle => "Select a date format";

  @override
  String get commented => "Commented";

  @override
  String get notCommented => "Not c.";

  @override
  String get deleteFilteredAudio => "Delete Filtered Audio";

  @override
  String deleteFilteredAudioConfirmationTitle(
    Object sortFilterParmsName,
    Object playlistTitle,
  ) =>
      "Delete audio filtered by \"$sortFilterParmsName\" parameters from playlist \"$playlistTitle\"";

  @override
  String deleteFilteredAudioConfirmation(
    Object deleteAudioNumber,
    Object deleteAudioTotalFileSize,
    Object deleteAudioTotalDuration,
  ) =>
      "Audio to delete number: $deleteAudioNumber Corresponding total file size: $deleteAudioTotalFileSize Corresponding total duration: $deleteAudioTotalDuration.";

  @override
  String deleteFilteredCommentedAudioWarningTitleTwo(
    Object sortFilterParmsName,
    Object playlistTitle,
  ) =>
      "WARNING: Delete COMMENTED and uncommented audio filtered by \"$sortFilterParmsName\" parms from playlist \"$playlistTitle\"";

  @override
  String deleteFilteredCommentedAudioWarning(
    Object deleteAudioNumber,
    Object deleteCommentedAudioNumber,
    Object deleteAudioTotalFileSize,
    Object deleteAudioTotalDuration,
  ) =>
      "Total audio to delete number: $deleteAudioNumber COMMENTED audio to delete number: $deleteCommentedAudioNumber Corresponding total file size: $deleteAudioTotalFileSize Corresponding total duration: $deleteAudioTotalDuration.";

  @override
  String get commentedAudioDeletionHelpTitle =>
      "How to define and use a sort filter parameter in order to avoid deleting commented audio";

  @override
  String get commentedAudioDeletionHelpContent =>
      "The description below will explain how to delete fully listened and uncommented audio.";

  @override
  String get commentedAudioDeletionOpenSFDialogHelpTitle =>
      "Open the Sort/Filter definition dialog";

  @override
  String get commentedAudioDeletionOpenSFDialogHelpContent =>
      "Click on the right download audio view menu icon and click on \"Sort/Filter Audio ...\"";

  @override
  String get commentedAudioDeletionCreateSFParmHelpTitle =>
      "Create a valid Sort/Filter parameters";

  @override
  String get commentedAudioDeletionCreateSFParmHelpContent =>
      "Enter a Sort/Filter parameters name in the Save as field (FullyListenedUncom for example).Then, uncheck the Partially listened, the Not listened and the Commented checkboxes.Finally, click on the Save button.";

  @override
  String get commentedAudioDeletionSolutionHelpTitle =>
      "The solution is to create a Sort/Filter parameters item which will select only fully played audio which are not commented";

  @override
  String get commentedAudioDeletionSolutionHelpContent =>
      "In the Sort/Filter definition dialog, the selection parameters are represented by checkboxes ...";

  @override
  String get commentedAudioDeletionSelectSFParmHelpTitle =>
      "Once you have saved the Sort/Filter parameters, this SF parms is applied to the playlist audio list";

  @override
  String get commentedAudioDeletionSelectSFParmHelpContent =>
      "If you click on the Playlists left button, you hide the list of playlists and you can see that your newly created SF parms is selected in the SF parms list dropdown menu. Note that if you select another playlist, you will be able to apply to it your created SF parms or another one.";

  @override
  String get commentedAudioDeletionApplyingNewSFParmHelpTitle =>
      "Finally, open the playlist menu and click on Delete Filtered Audio ...";

  @override
  String get commentedAudioDeletionApplyingNewSFParmHelpContent =>
      "This time, since a correct SF parms is applied, no warning is displayed for deleting the selected uncommented audio.";

  @override
  String get deleteFilteredCommentedAudioWarningTitleOne =>
      "WARNING: you are going to delete";

  @override
  String get filteredAudioActions => "Filtered Audio Actions ...";

  @override
  String get moveFilteredAudio => "Move Filtered Audio ...";

  @override
  String get copyFilteredAudio => "Copy Filtered Audio ...";

  @override
  String confirmMovedUnmovedAudioNumberFromYoutubeToYoutubePlaylist(
    Object sourcePlaylistTitle,
    Object targetPlaylistTitle,
    Object sortedFilterParmsName,
    Object movedAudioNumber,
    Object movedCommentedAudioNumber,
    Object unmovedAudioNumber,
  ) =>
      "From Youtube playlist \"$sourcePlaylistTitle\" to Youtube playlist \"$targetPlaylistTitle\" applying Sort/Filter parms \"$sortedFilterParmsName\", $movedAudioNumber audio(s) were moved and $unmovedAudioNumber audio(s) unmoved.";

  @override
  String confirmMovedUnmovedAudioNumberFromYoutubeToLocalPlaylist(
    Object sourcePlaylistTitle,
    Object targetPlaylistTitle,
    Object sortedFilterParmsName,
    Object movedAudioNumber,
    Object movedCommentedAudioNumber,
    Object unmovedAudioNumber,
  ) =>
      "From Youtube playlist \"$sourcePlaylistTitle\" to local playlist \"$targetPlaylistTitle\" applying Sort/Filter parms \"$sortedFilterParmsName\", $movedAudioNumber audio(s) were moved and $unmovedAudioNumber audio(s) unmoved.";

  @override
  String confirmMovedUnmovedAudioNumberFromLocalToYoutubePlaylist(
    Object sourcePlaylistTitle,
    Object targetPlaylistTitle,
    Object sortedFilterParmsName,
    Object movedAudioNumber,
    Object movedCommentedAudioNumber,
    Object unmovedAudioNumber,
  ) =>
      "From local playlist \"$sourcePlaylistTitle\" to Youtube playlist \"$targetPlaylistTitle\" applying Sort/Filter parms \"$sortedFilterParmsName\", $movedAudioNumber audio(s) were moved and $unmovedAudioNumber audio(s) unmoved.";

  @override
  String confirmMovedUnmovedAudioNumberFromLocalToLocalPlaylist(
    Object sourcePlaylistTitle,
    Object targetPlaylistTitle,
    Object sortedFilterParmsName,
    Object movedAudioNumber,
    Object movedCommentedAudioNumber,
    Object unmovedAudioNumber,
  ) =>
      "From local playlist \"$sourcePlaylistTitle\" to local playlist \"$targetPlaylistTitle\" applying Sort/Filter parms \"$sortedFilterParmsName\", $movedAudioNumber audio(s) were moved and $unmovedAudioNumber audio(s) unmoved.";

  @override
  String confirmCopiedNotCopiedAudioNumberFromYoutubeToYoutubePlaylist(
    Object sortedFilterParmsName,
    Object sourcePlaylistTitle,
    Object targetPlaylistTitle,
    Object copiedAudioNumber,
    Object copiedCommentedAudioNumber,
    Object notCopiedAudioNumber,
  ) =>
      "Applying Sort/Filter parms \"$sortedFilterParmsName\", from Youtube playlist \"$sourcePlaylistTitle\" to Youtube playlist \"$targetPlaylistTitle\", $copiedAudioNumber audio(s) were copied from which $copiedCommentedAudioNumber were commented, and $notCopiedAudioNumber audio(s) were not copied.";

  @override
  String confirmCopiedNotCopiedAudioNumberFromYoutubeToLocalPlaylist(
    Object sortedFilterParmsName,
    Object sourcePlaylistTitle,
    Object targetPlaylistTitle,
    Object copiedAudioNumber,
    Object copiedCommentedAudioNumber,
    Object notCopiedAudioNumber,
  ) =>
      "Applying Sort/Filter parms \"$sortedFilterParmsName\", from Youtube playlist \"$sourcePlaylistTitle\" to local playlist \"$targetPlaylistTitle\", $copiedAudioNumber audio(s) were copied from which $copiedCommentedAudioNumber were commented, and $notCopiedAudioNumber audio(s) were not copied.";

  @override
  String confirmCopiedNotCopiedAudioNumberFromLocalToYoutubePlaylist(
    Object sortedFilterParmsName,
    Object sourcePlaylistTitle,
    Object targetPlaylistTitle,
    Object copiedAudioNumber,
    Object copiedCommentedAudioNumber,
    Object notCopiedAudioNumber,
  ) =>
      "Applying Sort/Filter parms \"$sortedFilterParmsName\", from local playlist \"$sourcePlaylistTitle\" to Youtube playlist \"$targetPlaylistTitle\", $copiedAudioNumber audio(s) were copied from which $copiedCommentedAudioNumber were commented, and $notCopiedAudioNumber audio(s) were not copied.";

  @override
  String confirmCopiedNotCopiedAudioNumberFromLocalToLocalPlaylist(
    Object sortedFilterParmsName,
    Object sourcePlaylistTitle,
    Object targetPlaylistTitle,
    Object copiedAudioNumber,
    Object copiedCommentedAudioNumber,
    Object notCopiedAudioNumber,
  ) =>
      "Applying Sort/Filter parms \"$sortedFilterParmsName\", from local playlist \"$sourcePlaylistTitle\" to local playlist \"$targetPlaylistTitle\", $copiedAudioNumber audio(s) were copied from which $copiedCommentedAudioNumber were commented, and $notCopiedAudioNumber audio(s) were not copied.";

  @override
  String addYoutubePlaylistTitle(
    Object title,
    Object quality,
  ) =>
      "Youtube playlist \"$title\" of $quality quality added to the end of list of playlists.";

  @override
  String addLocalPlaylistTitle(
    Object title,
    Object quality,
  ) =>
      "Local playlist \"$title\" of $quality quality added to the end of list of playlists.";

  @override
  String defaultSFPNotApplyedToCopyAudioFromLocalToLocalPlaylistWarning(
    Object sortedFilterParmsName,
    Object sourcePlaylistTitle,
    Object targetPlaylistTitle,
  ) =>
      "Since \"$sortedFilterParmsName\" Sort/Filter parms is selected, no audio can be copied from local playlist \"$sourcePlaylistTitle\" to local playlist \"$targetPlaylistTitle\". SOLUTION: define a Sort/Filter parameters and apply it before selecting this operation ...";

  @override
  String defaultSFPNotApplyedToCopyAudioFromLocalToYoutubePlaylistWarning(
    Object sortedFilterParmsName,
    Object sourcePlaylistTitle,
    Object targetPlaylistTitle,
  ) =>
      "Since \"$sortedFilterParmsName\" Sort/Filter parms is selected, no audio can be copied from local playlist \"$sourcePlaylistTitle\" to Youtube playlist \"$targetPlaylistTitle\". SOLUTION: define a Sort/Filter parameters and apply it before selecting this operation ...";

  @override
  String defaultSFPNotApplyedToCopyAudioFromYoutubeToLocalPlaylistWarning(
    Object sortedFilterParmsName,
    Object sourcePlaylistTitle,
    Object targetPlaylistTitle,
  ) =>
      "Since \"$sortedFilterParmsName\" Sort/Filter parms is selected, no audio can be copied from Youtube playlist \"$sourcePlaylistTitle\" to local playlist \"$targetPlaylistTitle\". SOLUTION: define a Sort/Filter parameters and apply it before selecting this operation ...";

  @override
  String defaultSFPNotApplyedToCopyAudioFromYoutubeToYoutubePlaylistWarning(
    Object sortedFilterParmsName,
    Object sourcePlaylistTitle,
    Object targetPlaylistTitle,
  ) =>
      "Since \"$sortedFilterParmsName\" Sort/Filter parms is selected, no audio can be copied from Youtube playlist \"$sourcePlaylistTitle\" to Youtube playlist \"$targetPlaylistTitle\". SOLUTION: define a Sort/Filter parameters and apply it before selecting this operation ...";

  @override
  String defaultSFPNotApplyedToMoveAudioFromLocalToLocalPlaylistWarning(
    Object sortedFilterParmsName,
    Object sourcePlaylistTitle,
    Object targetPlaylistTitle,
  ) =>
      "Since \"$sortedFilterParmsName\" Sort/Filter parms is selected, no audio can be moved from local playlist \"$sourcePlaylistTitle\" to local playlist \"$targetPlaylistTitle\". SOLUTION: define a Sort/Filter parameters and apply it before selecting this operation ...";

  @override
  String defaultSFPNotApplyedToMoveAudioFromLocalToYoutubePlaylistWarning(
    Object sortedFilterParmsName,
    Object sourcePlaylistTitle,
    Object targetPlaylistTitle,
  ) =>
      "Since \"$sortedFilterParmsName\" Sort/Filter parms is selected, no audio can be moved from local playlist \"$sourcePlaylistTitle\" to Youtube playlist \"$targetPlaylistTitle\". SOLUTION: define a Sort/Filter parameters and apply it before selecting this operation ...";

  @override
  String defaultSFPNotApplyedToMoveAudioFromYoutubeToLocalPlaylistWarning(
    Object sortedFilterParmsName,
    Object sourcePlaylistTitle,
    Object targetPlaylistTitle,
  ) =>
      "Since \"$sortedFilterParmsName\" Sort/Filter parms is selected, no audio can be moved from Youtube playlist \"$sourcePlaylistTitle\" to local playlist \"$targetPlaylistTitle\". SOLUTION: define a Sort/Filter parameters and apply it before selecting this operation ...";

  @override
  String defaultSFPNotApplyedToMoveAudioFromYoutubeToYoutubePlaylistWarning(
    Object sortedFilterParmsName,
    Object sourcePlaylistTitle,
    Object targetPlaylistTitle,
  ) =>
      "Since \"$sortedFilterParmsName\" Sort/Filter parms is selected, no audio can be moved from Youtube playlist \"$sourcePlaylistTitle\" to Youtube playlist \"$targetPlaylistTitle\". SOLUTION: define a Sort/Filter parameters and apply it before selecting this operation ...";

  @override
  String get appBarMenuEnableNextAudioAutoPlay =>
      "Enable playing next audio automatically ...";

  @override
  String get batteryParameters => "Battery Parameters";

  @override
  String get disableBatteryOptimisation => "Disable battery optimisation ...";

  @override
  String get openBatteryOptimisationButton => "Display the battery settings";

  @override
  String deleteSortFilterParmsWarningTitle(
    Object sortFilterParmsName,
    Object playlistNumber,
  ) =>
      "WARNING: you are going to delete the Sort/Filter parms \"$sortFilterParmsName\" which is used in $playlistNumber playlist(s) listed below";

  @override
  String updatingSortFilterParmsWarningTitle(
    Object sortFilterParmsName,
  ) =>
      "WARNING: the sort/filter parameters \"$sortFilterParmsName\" were modified. Do you want to update the existing sort/filter parms by clicking on \"Confirm\", or to save it with a different name or cancel the Save operation, this by clicking on \"Cancel\" ?";

  @override
  String get presentOnlyInFirstTitle => "Present only in first";

  @override
  String get presentOnlyInSecondTitle => "Present only in second";

  @override
  String get ascendingShort => "asc";

  @override
  String get descendingShort => "desc";

  @override
  String get startAudioDownloadDateSortFilterTooltip =>
      "If only the start download date is set, all audio downloaded at or after the defined date will be listed.";

  @override
  String get endAudioDownloadDateSortFilterTooltip =>
      "If only the end download date is set, all audio downloaded at or before the defined date will be listed.";

  @override
  String get startVideoUploadDateSortFilterTooltip =>
      "If only the start upload date is set, all video uploaded at or after the defined date will be listed.";

  @override
  String get endVideoUploadDateSortFilterTooltip =>
      "If only the end upload date is set, all video uploaded at or before the defined date will be listed.";

  @override
  String get startAudioDurationSortFilterTooltip =>
      "If only the start duration range is set, all audio with duration equal or greater than the defined value will be listed.";

  @override
  String get endAudioDurationSortFilterTooltip =>
      "If only the end duration range is set, all audio with duration equal or greater than the defined value will be listed.";

  @override
  String get startAudioFileSizeSortFilterTooltip =>
      "If only the start file size range is set, all audio with size equal or greater than the defined value will be listed.";

  @override
  String get endAudioFileSizeSortFilterTooltip =>
      "If only the end file size range is set, all audio with size equal or greater than the defined value will be listed.";

  @override
  String get filterSentences => "Filter sentences:";

  @override
  String get valueInInitialVersionTitle => "In initial version";

  @override
  String get valueInModifiedVersionTitle => "In modified version";

  @override
  String get checked => "checked";

  @override
  String get unchecked => "unchecked";

  @override
  String get emptyDate => "empty";

  @override
  String get help => "Help ...";

  @override
  String get helpMainTitle => "Audio Learn Help";

  @override
  String get helpMainIntroduction =>
      "Consulting the Audio Player Introduction Help is necessary the first time you use the application.";

  @override
  String get helpAudioLearnIntroductionTitle => "Audio Learn Introduction";

  @override
  String get helpAudioLearnIntroductionSubTitle =>
      "Defining, adding and downloading a Youtube playlist";

  @override
  String get helpLocalPlaylistTitle => "Local Playlist";

  @override
  String get helpLocalPlaylistSubTitle => "Defining and using a local playlist";

  @override
  String get helpPlaylistMenuTitle => "Playlist Menu";

  @override
  String get helpPlaylistMenuSubTitle => "Playlist menu functionalities";

  @override
  String get helpAudioMenuTitle => "Audio Menu";

  @override
  String get helpAudioMenuSubTitle => "Audio menu functionalities";

  @override
  String get addPrivateYoutubePlaylist =>
      "Trying to add a private Youtube playlist is not possible since the audio of a private playlist can not be downloaded. To solve the problem, edit the playlist on Youtube and change its visibility from Private to Unlisted or to Public and then re-add it to the application.";

  @override
  String deletePlaylistDialogComment(
    Object audioNumber,
    Object audioCommentsNumber,
  ) =>
      "Deleting the playlist and its $audioNumber audio's, $audioCommentsNumber audio comments as well as its JSON file and its directory.";

  @override
  String get chapterAudioTitleLabel => "Chapter Audio title";

  @override
  String get addAudioPicture => "Add Audio Picture ...";

  @override
  String get removeAudioPicture => "Remove Audio Picture";

  @override
  String savedAppDataToZip(
    Object filePathName,
  ) =>
      "Saved playlist json files and application settings to \"$filePathName\".";

  @override
  String get appDataCouldNotBeSavedToZip =>
      "Playlist json files and application settings could not be saved to zip.";

  @override
  String get commentStartPositionTooltip => "Comment start position in audio";

  @override
  String get commentEndPositionTooltip => "Comment end position in audio";

  @override
  String get commentPositionTooltip =>
      "Emptying the position and clicking on Start checkbox will set the start comment position to 0:00.0. Clicking on End checkbox will set the end comment position to the audio total duration.";

  @override
  String get pictured => "Pictured";

  @override
  String get notPictured => "Unpic.";

  @override
  String get restorePlaylistAndCommentsFromZipMenu =>
      "Restore Playlists and Comments from Zip File";

  @override
  String get restorePlaylistAndCommentsFromZipTooltip =>
      "Restoring the playlists and their audio comments from a saved zip file. The zip file contains the playlists JSON files as well as the comments JSON files. The audio files are not included in it.";

  @override
  String get appDataCouldNotBeRestoredFromZip =>
      "Playlist and comment json files as well as application settings could not be restored from zip.";

  @override
  String deleteFilteredAudioFromPlaylistAsWellConfirmationTitle(
    Object sortFilterParmsName,
    Object playlistTitle,
  ) =>
      "Delete audio's filtered by \"$sortFilterParmsName\" parms from playlist \"$playlistTitle\" as well";

  @override
  String get deleteFilteredAudioFromPlaylistAsWell =>
      "Delete Filtered Audio from Playlist as well ...";

  @override
  String get redownloadFilteredAudio => "Redownload filtered Audio's";

  @override
  String get redownloadFilteredAudioTooltip =>
      "Filtered audio files are re-downloaded using their original file names.";

  @override
  String redownloadedAudioNumbersConfirmation(
    Object redownloadedAudioNumber,
    Object playlistTitle,
    Object notRedownloadedAudioNumber,
  ) =>
      "\"$redownloadedAudioNumber\" audio's were redownloaded to the playlist \"$playlistTitle\". \"$notRedownloadedAudioNumber\" audio's were not redownloaded since they are already present in the playlist directory.";

  @override
  String get redownloadDeletedAudio => "Redownload deleted Audio";

  @override
  String redownloadedAudioConfirmation(
    Object redownloadedAudioTitle,
    Object playlistTitle,
  ) =>
      "The audio\"$redownloadedAudioTitle\" was redownloaded to the playlist \"$playlistTitle\".";

  @override
  String restoredAppDataFromZip(
    Object playlistsNumber,
    Object commentsNumber,
    Object picturesNumber,
    Object filePathName,
  ) =>
      "Restored $playlistsNumber playlist, $commentsNumber comment and $picturesNumber picture json files as well as application settings from \"$filePathName\".";

  @override
  String get playable => "Playable";

  @override
  String get notPlayable => "Not pl.";

  @override
  String audioNotRedownloadedWarning(
    Object redownloadedAudioTitle,
    Object playlistTitle,
  ) =>
      "The audio \"$redownloadedAudioTitle\" was not redownloaded to the playlist \"$playlistTitle\".";

  @override
  String get isPlayableLabel => "Playable";

  @override
  String downloadAudioYoutubeError(
    Object videoTitle,
    Object exceptionMessage,
  ) =>
      "Error downloading audio of \"$videoTitle\" video from Youtube: \"$exceptionMessage\"";

  @override
  String downloadAudioYoutubeErrorExceptionMessageOnly(
    Object exceptionMessage,
  ) =>
      "Error downloading audio from Youtube: \"$exceptionMessage\"";

  @override
  String get clearPlaylistUrlOrSearchButtonTooltip =>
      "Clear Youtube link or sentence field.";

  @override
  String addCorrectedYoutubePlaylistTitle(
    Object originalTitle,
    Object quality,
    Object correctedTitle,
  ) =>
      "Youtube playlist \"$originalTitle\" of $quality quality added with corrected title \"$correctedTitle\" to the end of the playlist list.";

  @override
  String get setPlaylistAudioQuality => "Set Audio Quality ...";

  @override
  String get setPlaylistAudioQualityTooltip =>
      "The audio quality set will be applied to the next downloaded audio's. If the audio quality must be applied to the already download audio's, those audio's must be deleted from playlist as well so that they will be redownloaded in the changed audio quality.";

  @override
  String get setPlaylistAudioQualityDialogTitle => "Playlist Audio Quality";

  @override
  String get selectAudioQuality => "Select audio quality";

  @override
  String get sinceAbsentFromSourcePlaylist =>
      "since it is not present in the source playlist";

  @override
  String get sinceAlreadyPresentInTargetPlaylist =>
      "since it is already present in the destination playlist";

  @override
  String audioCopiedOrMovedFromPlaylistToPlaylist(
    Object audioTitle,
    Object yesOrNo,
    Object operationType,
    Object fromPlaylistType,
    Object fromPlaylistTitle,
    Object toPlaylistType,
    Object toPlaylistTitle,
    Object notCopiedOrMovedReason,
  ) =>
      "Audio \"$audioTitle\"$yesOrNo$operationType from $fromPlaylistType playlist \"$fromPlaylistTitle\" to $toPlaylistType playlist \"$toPlaylistTitle\"$notCopiedOrMovedReason";

  @override
  String get noOperation => " NOT ";

  @override
  String get yesOperation => "";

  @override
  String get localPlaylistType => "local";

  @override
  String get youtubePlaylistType => "Youtube";

  @override
  String get movedOperationType => "moved";

  @override
  String get copiedOperationType => "copied";

  @override
  String audioNotKeptInSourcePlaylist(
    Object audioTitle,
    Object fromPlaylistTitle,
  ) =>
      "IF THE DELETED AUDIO VIDEO \"$audioTitle\" REMAINS IN THE \"$fromPlaylistTitle\" YOUTUBE PLAYLIST, IT WILL BE DOWNLOADED AGAIN THE NEXT TIME YOU DOWNLOAD THE PLAYLIST !";

  @override
  String get noOperationMovedOperationType => "moved";

  @override
  String get noOperationCopiedOperationType => "copied";

  @override
  String savedPictureNumberMessage(Object pictureNumber,) =>
      "Saved also $pictureNumber picture jpg file(s) in same directory.";

  @override
  String restoredPictureNumberMessage(Object pictureNumber,) =>
      "Restored also $pictureNumber picture jpg file(s).";
}

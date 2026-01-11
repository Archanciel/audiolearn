import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/audio.dart';
import '../../models/comment.dart';
import '../../models/playlist.dart';
import '../../services/settings_data_service.dart';
import '../../utils/date_time_util.dart';
import '../../utils/duration_expansion.dart';
import '../../utils/ui_util.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../../viewmodels/comment_vm.dart';
import '../../viewmodels/date_format_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../../viewmodels/playlist_list_vm.dart';
import '../screen_mixin.dart';
import 'confirm_action_dialog.dart';
import 'comment_add_edit_dialog.dart';

/// This widget displays a dialog with the list of positionned
/// comment of the audio contained in the playlist.
///
/// When a comment is clicked, this opens a dialog to edit the
/// comment.
///
/// Adding a new positionned comment is only possible in the
/// CommentListAddDialog.
class PlaylistCommentListDialog extends StatefulWidget {
  final SettingsDataService settingsDataService;
  final Playlist currentPlaylist;

  const PlaylistCommentListDialog({
    super.key,
    required this.settingsDataService,
    required this.currentPlaylist,
  });

  @override
  State<PlaylistCommentListDialog> createState() =>
      _PlaylistCommentListDialogState();
}

class _PlaylistCommentListDialogState extends State<PlaylistCommentListDialog>
    with ScreenMixin {
  final FocusNode _focusNodeDialog = FocusNode();
  Comment? _playingComment;

  // Variables to manage the scrolling of the dialog
  final ScrollController _scrollController = ScrollController();
  int _previousCurrentCommentLinesNumber = 0;

  @override
  void dispose() {
    _focusNodeDialog.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProviderVM themeProviderVM =
        Provider.of<ThemeProviderVM>(context); // by default, listen is true
    final AudioPlayerVM audioPlayerVMlistenFalse = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );
    final bool isDarkTheme = themeProviderVM.currentTheme == AppTheme.dark;

    // Required so that clicking on Enter closes the dialog
    FocusScope.of(context).requestFocus(
      _focusNodeDialog,
    );

    final PlaylistListVM playlistListVMlistenFalse =
        Provider.of<PlaylistListVM>(
      context,
      listen: false,
    );
    final Playlist currentPlaylist = widget.currentPlaylist;
    final String audioSFparmsName = playlistListVMlistenFalse
        .getSelectedPlaylistAudioSortFilterParmsNameForView(
      audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      translatedAppliedSortFilterParmsName:
          AppLocalizations.of(context)!.sortFilterParametersAppliedName,
    );

    return KeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: _focusNodeDialog,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // executing the same code as in the 'Close'
            // TextButton onPressed callback
            Navigator.of(context).pop();
          }
        }
      },
      child: AlertDialog(
        title: Row(
          children: [
            Flexible(
              child: Text(
                (audioSFparmsName.isNotEmpty)
                    ? '${AppLocalizations.of(context)!.playlistCommentsDialogTitle} ($audioSFparmsName)'
                    : AppLocalizations.of(context)!.playlistCommentsDialogTitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                softWrap: true,
              ),
            ),
          ],
        ),
        actionsPadding: kDialogActionsPadding,
        content: Consumer<CommentVM>(
          builder: (context, commentVMlistenTrue, child) {
            // Map with the audio file name without extension as key
            final Map<String, List<Comment>> playlistAudioCommentsMap =
                commentVMlistenTrue.getPlaylistAudioComments(
              playlist: currentPlaylist,
            );

            // Obtaining the list of audio comment file names
            // corresponding to playlistAudioCommentsMap keys and
            // sorting them according to the playable audio order.

            final List<String> commentFileNameNoExtLst =
                playlistAudioCommentsMap.keys.toList();

            final List<String> sortedAudioFileNameNoExtLst =
                playlistListVMlistenFalse
                    .getSortedPlaylistAudioCommentFileNamesApplyingSortFilterParameters(
                        selectedPlaylist: currentPlaylist,
                        audioLearnAppViewType:
                            AudioLearnAppViewType.playlistDownloadView,
                        commentFileNameNoExtLst: commentFileNameNoExtLst,
                        audioSortFilterParametersName: audioSFparmsName);

            return SingleChildScrollView(
              controller: _scrollController,
              child: ListBody(
                key: const Key('playlistCommentsListKey'),
                children: (sortedAudioFileNameNoExtLst.isNotEmpty)
                    ? _buildPlaylistAudiosCommentsList(
                        themeProviderVM: themeProviderVM,
                        audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
                        currentPlaylist: currentPlaylist,
                        commentVMlistenTrue: commentVMlistenTrue,
                        playlistAudiosCommentsMap: playlistAudioCommentsMap,
                        sortedAudioFileNameNoExtLst:
                            sortedAudioFileNameNoExtLst,
                        isDarkTheme: isDarkTheme,
                      )
                    : [],
              ),
            );
          },
        ),
        actions: <Widget>[
          TextButton(
            key: const Key('playlistCommentListCloseDialogTextButton'),
            child: Text(
              AppLocalizations.of(context)!.closeTextButton,
              style: (isDarkTheme)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
            onPressed: () async {
              if (audioPlayerVMlistenFalse.isPlaying) {
                await audioPlayerVMlistenFalse.pause();
              }

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPlaylistAudiosCommentsList({
    required ThemeProviderVM themeProviderVM,
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required CommentVM commentVMlistenTrue,
    required Playlist currentPlaylist,
    required Map<String, List<Comment>> playlistAudiosCommentsMap,
    required List<String> sortedAudioFileNameNoExtLst,
    required bool isDarkTheme,
  }) {
    // Obtaining the current audio file name without the extension.
    // This will be used to drop down the playlist audio comments list
    // to the current audio comments.
    String currentAudioFileName = currentPlaylist
            .getCurrentOrLastlyPlayedAudioContainedInPlayableAudioLst()
            ?.audioFileName ??
        '';

    if (currentAudioFileName.isNotEmpty) {
      // removing the '.mp3' extension from the current audio file name
      currentAudioFileName = currentAudioFileName.substring(
        0,
        currentAudioFileName.length - 4,
      );
    }

    const TextStyle commentTitleTextStyle = TextStyle(
      fontSize: kAudioTitleFontSize,
      fontWeight: FontWeight.bold,
    );

    const TextStyle commentContentTextStyle = TextStyle(
      fontSize: kAudioTitleFontSize,
    );

    // List of widgets corresponding to the playlist audio comments
    List<Widget> widgetsLst = [];

    for (String audioFileNameNoExt in sortedAudioFileNameNoExtLst) {
      Audio audioRelatedToFileNameNoExt =
          currentPlaylist.getAudioByFileNameNoExt(
        audioFileNameNoExt: audioFileNameNoExt,
      )!;

      // List containing the audio title text color and the audio title
      // background color.
      List<Color?> audioStateColorsLst = UiUtil.generateAudioStateColors(
        audio: audioRelatedToFileNameNoExt,
        audioIndex: sortedAudioFileNameNoExtLst.indexOf(audioFileNameNoExt),
        currentAudioIndex:
            sortedAudioFileNameNoExtLst.indexOf(currentAudioFileName),
        isDarkTheme: isDarkTheme,
      );

      Color? audioTitleTextColor = audioStateColorsLst[0];
      Color? audioTitleBackgroundColor = audioStateColorsLst[1];

      // The commented audio title is equivalent to the audio file name
      // without the extension and without the date time elements.
      final String commentedAudioTitle =
          DateTimeUtil.removeDateTimeElementsFromFileName(
        audioFileNameNoExt,
      );

      final TextStyle commentedAudioTitleTextStyle = TextStyle(
        color: audioTitleTextColor,
        backgroundColor: audioTitleBackgroundColor,
        fontWeight: FontWeight.bold,
        fontSize: kCommentedAudioTitleFontSize,
      );

      // Adding the commented audio title to the widgets list
      widgetsLst.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            commentedAudioTitle,
            style: commentedAudioTitleTextStyle,
          ),
        ),
      );

      // Calculating the number of lines related to the comments
      // contained in the audioFileName
      List<Comment> audioCommentsLst =
          playlistAudiosCommentsMap[audioFileNameNoExt]!;
      int previousCurrentCommentLineNumber = 0;

      // Adding the number of lines related to the commented audio title
      previousCurrentCommentLineNumber +=
          (1 + // empty line after the commented audio title
              computeTextLineNumber(
                context: context,
                textStyle: commentedAudioTitleTextStyle,
                text: commentedAudioTitle,
              ));

      if (audioFileNameNoExt == currentAudioFileName) {
        _previousCurrentCommentLinesNumber = previousCurrentCommentLineNumber;
      }

      for (Comment comment in audioCommentsLst) {
        if (_previousCurrentCommentLinesNumber == 0) {
          // This means that the comments of the current audio have not
          // yet been reached. In this situation, the comments title and
          // content lines number must be added to the varisble
          // previousCurrentCommentLineNumber.

          // Adding the calculated lines number occupied by the comment
          // title
          previousCurrentCommentLineNumber +=
              (1 + // 2 dates + position line after the comment title
                  computeTextLineNumber(
                    context: context,
                    textStyle: commentTitleTextStyle,
                    text: comment.title,
                  ));

          // Adding the calculated lines number occupied by the comment
          // content
          previousCurrentCommentLineNumber += computeTextLineNumber(
            context: context,
            textStyle: commentContentTextStyle,
            text: comment.content,
          );
        }

        widgetsLst.add(
          GestureDetector(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: _buildCommentTitlePlusIconsAndCommentDatesAndPosition(
                    themeProviderVM: themeProviderVM,
                    audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
                    dateFormatVMlistenFalse: Provider.of<DateFormatVM>(
                      context,
                      listen: false,
                    ),
                    commentVMlistenTrue: commentVMlistenTrue,
                    currentPlaylist: currentPlaylist,
                    currentAudio: audioRelatedToFileNameNoExt,
                    comment: comment,
                    commentTitleTextStyle: commentTitleTextStyle,
                    isDarkTheme: isDarkTheme,
                  ),
                ),
                if (comment.content.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    // comment content Text
                    child: Text(
                      key: const Key('commentTextKey'),
                      comment.content,
                      style: commentContentTextStyle,
                    ),
                  ),
              ],
            ),
            onTap: () async {
              if (audioPlayerVMlistenFalse.isPlaying &&
                  _playingComment != comment) {
                // if the user clicks on a comment while another
                // comment is playing, the playing comment is paused.
                // Otherwise, the edited comment keeps playing.
                await audioPlayerVMlistenFalse.pause();
              }

              await _closeDialogAndOpenCommentAddEditDialog(
                context: context,
                audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
                currentAudio: audioRelatedToFileNameNoExt,
                comment: comment,
              );
            },
          ),
        );
      }
    }

    _scrollToCurrentAudioItem();

    return widgetsLst;
  }

  Widget _buildCommentTitlePlusIconsAndCommentDatesAndPosition({
    required ThemeProviderVM themeProviderVM,
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required DateFormatVM dateFormatVMlistenFalse,
    required CommentVM commentVMlistenTrue,
    required Playlist currentPlaylist,
    required Audio currentAudio,
    required Comment comment,
    required TextStyle commentTitleTextStyle,
    required bool isDarkTheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                // comment title Text
                child: Text(
                  key: const Key('commentTitleKey'),
                  comment.title,
                  style: commentTitleTextStyle,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: kSmallestButtonWidth,
                  child: IconButton(
                    // Play/Pause icon button
                    key: const Key('playPauseIconButton'),
                    onPressed: () async {
                      // this logic enables that when we
                      // click on the play button of a comment,
                      // if an other comment is playing, it is
                      // paused
                      (_playingComment != null &&
                              _playingComment == comment &&
                              audioPlayerVMlistenFalse.isPlaying)
                          ? await audioPlayerVMlistenFalse
                              .pause() // clicked on currently playing comment pause button
                          : await _playFromCommentPosition(
                              // clicked on other comment play button
                              audioPlayerVMlistenFalse:
                                  audioPlayerVMlistenFalse,
                              commentVMlistenTrue: commentVMlistenTrue,
                              currentPlaylist: currentPlaylist,
                              currentAudio: currentAudio,
                              comment: comment,
                            );
                    },
                    style: ButtonStyle(
                      // Highlight button when pressed
                      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                            horizontal: kSmallButtonInsidePadding, vertical: 0),
                      ),
                      overlayColor:
                          iconButtonTapModification, // Tap feedback color
                    ),
                    icon: ValueListenableBuilder<Duration>(
                      valueListenable:
                          audioPlayerVMlistenFalse.currentAudioPositionNotifier,
                      builder: (context, currentAudioPosition, child) {
                        // Check if the comment is playing and the position has been reached
                        if (_playingComment != null &&
                            _playingComment == comment &&
                            audioPlayerVMlistenFalse.currentAudio!
                                .isPlayingOrPausedWithPositionBetweenAudioStartAndEnd &&
                            (currentAudioPosition >=
                                    Duration(
                                        milliseconds: comment
                                                .commentEndPositionInTenthOfSeconds *
                                            100) ||
                                // This 'or' addition is necessary to enable
                                // replaying a comment whose end position
                                // is the same as the audio end position. For
                                // a reason I don't know, without this
                                // condition, re-playing such a comment on the
                                // Android smartphone does not work !
                                currentAudioPosition >=
                                    currentAudio.audioDuration -
                                        const Duration(milliseconds: 1400))) {
                          // You cannot await here, but you can trigger an
                          // action which will not block the widget tree
                          // rendering.
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) async {
                            await audioPlayerVMlistenFalse.pause();
                          });
                        }

                        // This logic avoids that when the user clicks on
                        // the play button of a comment, the play button
                        // of the other comment is updated to 'pause'.
                        return ValueListenableBuilder<bool>(
                          valueListenable: audioPlayerVMlistenFalse
                              .currentAudioPlayPauseNotifier,
                          builder: (context, isPlaying, child) {
                            return IconTheme(
                              data: (isDarkTheme
                                      ? ScreenMixin.themeDataDark
                                      : ScreenMixin.themeDataLight)
                                  .iconTheme,
                              child: Icon(
                                // Display pause if this comment is playing and the audio is playing;
                                // otherwise, display the play_arrow icon.
                                (_playingComment != null &&
                                        _playingComment == comment &&
                                        isPlaying)
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                            );
                          },
                        );
                      },
                    ),
                    iconSize: kSmallestButtonWidth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(), // Ensure the button
                    //                                      takes minimal space
                  ),
                ),
                SizedBox(
                  width: kSmallestButtonWidth,
                  child: IconButton(
                    // delete comment icon button
                    key: const Key('playlistDeleteCommentIconButton'),
                    onPressed: () async {
                      await _confirmDeleteComment(
                        audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
                        commentVMlistenTrue: commentVMlistenTrue,
                        currentAudio: currentAudio,
                        comment: comment,
                      );
                    },
                    style: ButtonStyle(
                      // Highlight button when pressed
                      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                            horizontal: kSmallButtonInsidePadding, vertical: 0),
                      ),
                      overlayColor:
                          iconButtonTapModification, // Tap feedback color
                    ),
                    icon: IconTheme(
                      // IconTheme usage is required otherwise when
                      // the CommentListAddDialog is opened from the
                      // AudioPlayerScreen left appbar menu, the icon
                      // color is not the one defined in the theme and
                      // so is different from the icon color set when
                      // opening the CommentListAddDialog from the
                      // AudioPlayerScreen inkwell button or the playlist
                      // Audio Comments menu item.
                      data: (isDarkTheme
                              ? ScreenMixin.themeDataDark
                              : ScreenMixin.themeDataLight)
                          .iconTheme,
                      child: const Icon(
                        Icons.clear,
                      ),
                    ),
                    iconSize: kSmallestButtonWidth - 5,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(), // Ensure the button
                    //                                      takes minimal space
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Tooltip(
                  message:
                      AppLocalizations.of(context)!.commentCreationDateTooltip,
                  child: Text(
                    // comment creation date Text. This date is
                    // displayed with 2 chars for the year in order
                    // reduce the used space. This is useful on a
                    // smartphone screen where space is limited.
                    key: const Key('creation_date_key'),
                    style: const TextStyle(fontSize: 13),
                    dateFormatVMlistenFalse
                        .formatDateYy(comment.creationDateTime),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                (comment.lastUpdateDateTime.day != comment.creationDateTime.day)
                    ? Tooltip(
                        message: AppLocalizations.of(context)!
                            .commentUpdateDateTooltip,
                        child: Text(
                          // comment update date Text. This date is
                          // displayed with 2 chars for the year in order
                          // reduce the used space. This is useful on a
                          // smartphone screen where space is limited.
                          key: const Key('last_update_date_key'),
                          style: const TextStyle(fontSize: 13),
                          dateFormatVMlistenFalse
                              .formatDateYy(comment.lastUpdateDateTime),
                        ),
                      )
                    : Container(),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Row(
              children: [
                Tooltip(
                  message:
                      AppLocalizations.of(context)!.commentStartPositionTooltip,
                  child: Text(
                    // comment start position Text
                    key: const Key('commentStartPositionKey'),
                    style: const TextStyle(fontSize: 13),
                    Duration(
                            milliseconds:
                                comment.commentStartPositionInTenthOfSeconds *
                                    100)
                        .HHmmssZeroHH(),
                  ),
                ),
                const SizedBox(width: 5),
                Tooltip(
                  message:
                      AppLocalizations.of(context)!.commentEndPositionTooltip,
                  child: Text(
                    // comment position Text
                    key: const Key('commentEndPositionKey'),
                    style: const TextStyle(fontSize: 13),
                    Duration(
                            milliseconds:
                                comment.commentEndPositionInTenthOfSeconds *
                                    100)
                        .HHmmssZeroHH(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// In order to avoid keyboard opening and closing continuously after
  /// opening the CommentAddEditDialog, the current dialog must be
  /// closed before opening the CommentAddEditDialog.
  Future<void> _closeDialogAndOpenCommentAddEditDialog({
    required BuildContext context,
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required Audio currentAudio,
    Comment? comment,
  }) async {
    Navigator.of(context).pop(); // closes the current dialog

    await audioPlayerVMlistenFalse.setCurrentAudio(
      audio: currentAudio,
    );

    showDialog<void>(
      context: context,
      barrierDismissible:
          false, // This line prevents the dialog from closing when
      //        tapping outside the dialog
      // instanciating CommentAddEditDialog without
      // passing a comment opens it in 'add' mode
      builder: (context) => CommentAddEditDialog(
        settingsDataService: widget.settingsDataService,
        callerDialog: CallerDialog.playlistCommentListAddDialog,
        commentableAudio: currentAudio,
        comment: comment,
      ),
    );
  }

  Future<void> _confirmDeleteComment({
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required CommentVM commentVMlistenTrue,
    required Audio currentAudio,
    required Comment comment,
  }) async {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmActionDialog(
          actionFunction: commentVMlistenTrue.deleteCommentFunction,
          actionFunctionArgs: [
            comment.id,
            currentAudio,
          ],
          dialogTitleOne:
              AppLocalizations.of(context)!.deleteCommentConfirnTitle,
          dialogContent: AppLocalizations.of(context)!
              .deleteCommentConfirnBody(comment.title),
        );
      },
    );

    if (audioPlayerVMlistenFalse.isPlaying) {
      await audioPlayerVMlistenFalse.pause();
    }
  }

  Future<void> _playFromCommentPosition({
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required CommentVM commentVMlistenTrue,
    required Playlist currentPlaylist,
    required Audio currentAudio,
    required Comment comment,
  }) async {
    // Fixes the bug of playing comments in playlist comment list
    // dialog on Windows and Android.
    if (audioPlayerVMlistenFalse.isPlaying) {
      await audioPlayerVMlistenFalse.pause();
    }

    _playingComment = comment;

    commentVMlistenTrue.addCommentPlayCommandToUndoPlayCommandLst(
      commentAudioCopy: currentAudio.copy(),
      previousAudioIndex: currentPlaylist.currentOrPastPlayableAudioIndex,
    );

    if (audioPlayerVMlistenFalse.currentAudio != currentAudio) {
      // Adding the test fixes the problem of playing audio comments
      // from the playlist comment list dialog.
      await audioPlayerVMlistenFalse.setCurrentAudio(
        audio: currentAudio,
      );
    }

    await audioPlayerVMlistenFalse.modifyAudioPlayerPosition(
      durationPosition: Duration(
          milliseconds: comment.commentStartPositionInTenthOfSeconds * 100),
      isUndoCommandToAdd: true,
    );

    await audioPlayerVMlistenFalse.playCurrentAudio(
      rewindAudioPositionBasedOnPauseDuration: false,
      // data used by the AudioPlayerVM Timer
      commentEndPositionInTenthOfSeconds:
          comment.commentEndPositionInTenthOfSeconds,
    );
  }

  void _scrollToCurrentAudioItem() {
    double offset = _previousCurrentCommentLinesNumber * 135.0;

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
      _scrollController.animateTo(
        offset,
        duration: kScrollDuration,
        curve: Curves.easeInOut,
      );
    } else {
      // The scroll controller isn't attached to any scroll views.
      // Schedule a callback to try again after the next frame.
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToCurrentAudioItem());
    }
  }
}

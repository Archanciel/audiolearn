import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/utils/date_time_util.dart';
import 'package:audiolearn/utils/duration_expansion.dart';
import 'package:audiolearn/viewmodels/playlist_list_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/comment.dart';
import '../../models/playlist.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../../viewmodels/comment_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../screen_mixin.dart';
import 'confirm_action_dialog_widget.dart';
import 'comment_add_edit_dialog_widget.dart';

/// This widget displays a dialog with the list of positionned
/// comment of the audio contained in the playlist.
///
/// When a comment is clicked, this opens a dialog to edit the
/// comment.
class PlaylistCommentListDialogWidget extends StatefulWidget {
  final Playlist currentPlaylist;

  const PlaylistCommentListDialogWidget({
    super.key,
    required this.currentPlaylist,
  });

  @override
  State<PlaylistCommentListDialogWidget> createState() =>
      _PlaylistCommentListDialogWidgetState();
}

class _PlaylistCommentListDialogWidgetState
    extends State<PlaylistCommentListDialogWidget> with ScreenMixin {
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
    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);

    // Required so that clicking on Enter closes the dialog
    FocusScope.of(context).requestFocus(
      _focusNodeDialog,
    );

    return KeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: _focusNodeDialog,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // executing the same code as in the 'Ok'
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
                AppLocalizations.of(context)!.playlistCommentsDialogTitle,
                maxLines: 2,
                softWrap: true,
              ),
            ),
          ],
        ),
        actionsPadding: kDialogActionsPadding,
        content: Consumer<CommentVM>(
          builder: (context, commentVM, child) {
            Map<String, List<Comment>> playlistAudiosCommentsMap =
                commentVM.getAllPlaylistComments(
              playlist: widget.currentPlaylist,
            );

            // Obtaining the list of audio file name playlistAudiosCommentsMap
            // keys and sorting them. Since the audio file names are formatted
            // as YYMMDD-HHMMSS-audio name YYMMDD, YYMMDD-HHMMSS being the
            // audio download date time and YYMMDD being the video upload date,
            // sorting the audio file names sorts them by the audio download
            // date time. So, the list starts with the first downloaded audio
            // and ends with the last downloaded audio.
            List<String> audioFileNamesLst =
                playlistAudiosCommentsMap.keys.toList();

            PlaylistListVM playlistListVM = Provider.of<PlaylistListVM>(
              context,
              listen: false,
            );

            List<String> sortedAudioFileNamesLst = playlistListVM
                .getPlaylistAudioFileNamesApplyingSortFilterParameters(
              selectedPlaylist: widget.currentPlaylist,
              audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
              commentFileNamesLst: audioFileNamesLst,
            );

            return SingleChildScrollView(
              controller: _scrollController,
              child: ListBody(
                key: const Key('playlistCommentsListKey'),
                children: (sortedAudioFileNamesLst.isNotEmpty)
                    ? _buildPlaylistAudiosCommentsList(
                        commentVM: commentVM,
                        playlistAudiosCommentsMap: playlistAudiosCommentsMap,
                        audioFileNamesLst: sortedAudioFileNamesLst,
                        isDarkTheme:
                            themeProviderVM.currentTheme == AppTheme.dark,
                      )
                    : [],
              ),
            );
          },
        ),
        actions: <Widget>[
          TextButton(
            key: const Key('closeDialogTextButton'),
            child: Text(
              AppLocalizations.of(context)!.closeTextButton,
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPlaylistAudiosCommentsList({
    required CommentVM commentVM,
    required Map<String, List<Comment>> playlistAudiosCommentsMap,
    required List<String> audioFileNamesLst,
    required bool isDarkTheme,
  }) {
    AudioPlayerVM audioPlayerVMlistenFalse = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );

    // Obtaining the current audio file name without the extension.
    // This will be used to drop down the playlist audio comments list
    // to the current audio comments.
    String currentAudioFileName = widget.currentPlaylist
            .getCurrentOrLastlyPlayedAudioContainedInPlayableAudioLst()
            ?.audioFileName ??
        '';

    currentAudioFileName = currentAudioFileName.substring(
      0,
      currentAudioFileName.length - 4,
    );

    const TextStyle commentTitleTextStyle = TextStyle(
      fontSize: kAudioTitleFontSize,
      fontWeight: FontWeight.bold,
    );

    const TextStyle commentContentTextStyle = TextStyle(
      fontSize: kAudioTitleFontSize,
    );

    // List of widgets corresponding to the playlist audio comments
    List<Widget> widgetsLst = [];

    Color? audioTitleTextColor;
    Color? audioTitleBackgroundColor;
    int previousCurrentCommentLineNumber = 0;

    // Defining the text style for the commented audio title
    for (String audioFileName in audioFileNamesLst) {
      if (audioFileName == currentAudioFileName) {
        audioTitleTextColor = Colors.white;
        audioTitleBackgroundColor = Colors.blue;
      } else {
        audioTitleTextColor = (isDarkTheme)
            ? kSliderThumbColorInDarkMode
            : kSliderThumbColorInLightMode;
        audioTitleBackgroundColor = null;
      }

      // The commented audio title is equivalent to the audio file name
      // without the extension and without the date time elements.
      final String commentedAudioTitle =
          DateTimeUtil.removeDateTimeElementsFromFileName(
        audioFileName,
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
          playlistAudiosCommentsMap[audioFileName]!;

      // Adding the number of lines related to the commented audio title
      previousCurrentCommentLineNumber +=
          (1 + // empty line after the commented audio title
              computeTextLineNumber(
                context: context,
                textStyle: commentedAudioTitleTextStyle,
                text: commentedAudioTitle,
              ));

      if (audioFileName == currentAudioFileName) {
        _previousCurrentCommentLinesNumber = previousCurrentCommentLineNumber;
      }

      for (Comment comment in audioCommentsLst) {
        if (_previousCurrentCommentLinesNumber == 0) {
          // This means that the comments of the current audio have not
          // yet been reached. In this situation, the comments title and
          // content lines number must be added to the varisble
          // previousCurrentCommentLineNumber.

          // Calculating the number of lines occupied by the comment title
          previousCurrentCommentLineNumber +=
              (1 + // 2 dates + position line after the comment title
                  computeTextLineNumber(
                    context: context,
                    textStyle: commentTitleTextStyle,
                    text: comment.title,
                  ));

          // Calculating the number of lines occupied by the comment
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
                    audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
                    commentTitleTextStyle: commentTitleTextStyle,
                    audioFileNameNoExt: audioFileName,
                    commentVM: commentVM,
                    comment: comment,
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
                audioFileNameNoExt: audioFileName,
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
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required TextStyle commentTitleTextStyle,
    required String audioFileNameNoExt,
    required CommentVM commentVM,
    required Comment comment,
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
                              audioPlayerVM: audioPlayerVMlistenFalse,
                              audioFileNameNoExt: audioFileNameNoExt,
                              comment: comment,
                            );
                    },
                    icon: Consumer<AudioPlayerVM>(
                      builder: (context, audioPlayerVMlistenTrue, child) {
                        // The code below ensures that the audio player is
                        // paused when the current comment end audio position
                        // is reached.
                        if (_playingComment != null &&
                            _playingComment == comment &&
                            audioPlayerVMlistenTrue.currentAudioPosition >=
                                Duration(
                                    milliseconds: comment
                                            .commentEndPositionInTenthOfSeconds *
                                        100)) {
                          audioPlayerVMlistenTrue.pause().then((_) {});
                        }

                        // this logic avoids that when the
                        // user clicks on the play button of a
                        // comment, the play button of the
                        // other comment are updated to 'pause'
                        return Icon((_playingComment != null &&
                                _playingComment == comment &&
                                audioPlayerVMlistenTrue.isPlaying)
                            ? Icons.pause
                            : Icons.play_arrow);
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
                    key: const Key('deleteCommentIconButton'),
                    onPressed: () async {
                      await _confirmDeleteComment(
                        audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
                        audioFileNameNoExt: audioFileNameNoExt,
                        commentVM: commentVM,
                        comment: comment,
                      );
                    },
                    icon: const Icon(
                      Icons.clear,
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
                    // comment creation date Text
                    key: const Key('creationDateTimeKey'),
                    style: const TextStyle(fontSize: 13),
                    frenchDateFormat.format(comment.creationDateTime),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                (comment.lastUpdateDateTime.day != comment.creationDateTime.day)
                    ? Tooltip(
                        message: AppLocalizations.of(context)!
                            .commentUpdateDateTooltip,
                        child: Text(
                          // comment update date Text
                          key: const Key('lastUpdateDateTimeKey'),
                          style: const TextStyle(fontSize: 13),
                          frenchDateFormat.format(comment.lastUpdateDateTime),
                        ),
                      )
                    : Container(),
              ],
            ),
            Row(
              children: [
                Tooltip(
                  message:
                      AppLocalizations.of(context)!.commentStartPositionTooltip,
                  child: Text(
                    // comment position Text
                    key: const Key('commentPositionKey'),
                    style: const TextStyle(fontSize: 13),
                    Duration(
                            milliseconds:
                                comment.commentStartPositionInTenthOfSeconds *
                                    100)
                        .HHmmssZeroHH(),
                  ),
                ),
                const SizedBox(width: 11),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// In order to avoid keyboard opening and closing continuously after
  /// opening the CommentAddEditDialogWidget, the current dialog must be
  /// closed before opening the CommentAddEditDialogWidget.
  Future<void> _closeDialogAndOpenCommentAddEditDialog({
    required BuildContext context,
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required String audioFileNameNoExt,
    Comment? comment,
  }) async {
    Navigator.of(context).pop(); // closes the current dialog

    await audioPlayerVMlistenFalse.setCurrentAudio(
        audio: widget.currentPlaylist.getAudioByFileNameNoExt(
      audioFileNameNoExt: audioFileNameNoExt,
    )!);

    showDialog<void>(
      context: context,
      barrierDismissible:
          false, // This line prevents the dialog from closing when
      //        tapping outside the dialog
      // instanciating CommentAddEditDialogWidget without
      // passing a comment opens it in 'add' mode
      builder: (context) => CommentAddEditDialogWidget(
        callerDialog: CallerDialog.playlistCommentListAddDialog,
        comment: comment,
      ),
    );
  }

  Future<void> _confirmDeleteComment({
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required String audioFileNameNoExt,
    required CommentVM commentVM,
    required Comment comment,
  }) async {
    Audio currentAudio = widget.currentPlaylist.getAudioByFileNameNoExt(
      audioFileNameNoExt: audioFileNameNoExt,
    )!;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmActionDialogWidget(
          actionFunction: commentVM.deleteCommentFunction,
          actionFunctionArgs: [
            comment.id,
            currentAudio,
          ],
          dialogTitle: AppLocalizations.of(context)!.deleteCommentConfirnTitle,
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
    required AudioPlayerVM audioPlayerVM,
    required Comment comment,
    required String audioFileNameNoExt,
  }) async {
    _playingComment = comment;

    await audioPlayerVM.setCurrentAudio(
      audio: widget.currentPlaylist.getAudioByFileNameNoExt(
        audioFileNameNoExt: audioFileNameNoExt,
      )!,
    );

    if (!audioPlayerVM.isPlaying) {
      // This fixes a problem when a playing comment was paused and
      // then the user clicked on the play button of an other comment.
      // In such a situation, the user had to click twice or three
      // times on the other comment play button to play it if the other
      // comment was positioned before the previously played comment.
      // If the other comment was positioned after the previously played
      // comment, then the user had to click only once on the play button
      // of the other comment to play it.
      await audioPlayerVM.playCurrentAudio(
        rewindAudioPositionBasedOnPauseDuration: false,
        isCommentPlaying: true,
      );
    }

    await audioPlayerVM.modifyAudioPlayerPluginPosition(
      Duration(
          milliseconds: comment.commentStartPositionInTenthOfSeconds * 100),
    );

    await audioPlayerVM.playCurrentAudio(
      rewindAudioPositionBasedOnPauseDuration: false,
      isCommentPlaying: true,
    );
  }

  void _scrollToCurrentAudioItem() {
    double offset = _previousCurrentCommentLinesNumber * 135.0;

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
      _scrollController.animateTo(
        offset,
        duration: const Duration(seconds: 1),
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

import 'package:audiolearn/utils/duration_expansion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/audio.dart';
import '../../models/comment.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../../viewmodels/comment_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../screen_mixin.dart';
import 'confirm_action_dialog.dart';
import 'comment_add_edit_dialog.dart';

/// This widget displays a dialog with the list of positionned
/// comment added to the current audio.
///
/// When a comment is clicked, this opens a dialog to edit the
/// comment.
///
/// Additionally, a button 'plus' is displayed to add a new
/// positionned comment.
class CommentListAddDialog extends StatefulWidget {
  final Audio currentAudio;

  const CommentListAddDialog({
    super.key,
    required this.currentAudio,
  });

  @override
  State<CommentListAddDialog> createState() => _CommentListAddDialogState();
}

class _CommentListAddDialogState extends State<CommentListAddDialog>
    with ScreenMixin {
  final FocusNode _focusNodeDialog = FocusNode();
  Comment? _playingComment;

  // Variables to manage the scrolling of the dialog
  final ScrollController _scrollController = ScrollController();
  int _audioCommentsLinesNumber = 0;

  @override
  void dispose() {
    _focusNodeDialog.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProviderVM themeProviderVM =
        Provider.of<ThemeProviderVM>(context);

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
            Text(
              AppLocalizations.of(context)!.commentsDialogTitle,
            ),
            const SizedBox(width: 15),
            Tooltip(
              message:
                  AppLocalizations.of(context)!.addPositionedCommentTooltip,
              child: IconButton(
                // add comment icon button
                key: const Key('addPositionedCommentIconButtonKey'),
                style: ButtonStyle(
                  // Highlight button when pressed
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(
                        horizontal: kSmallButtonInsidePadding, vertical: 0),
                  ),
                  overlayColor: iconButtonTapModification, // Tap feedback color
                ),
                icon: IconTheme(
                  data: (themeProviderVM.currentTheme == AppTheme.dark
                          ? ScreenMixin.themeDataDark
                          : ScreenMixin.themeDataLight)
                      .iconTheme,
                  child: const Icon(
                    Icons.add_circle_outline,
                    size: 40.0,
                  ),
                ),
                onPressed: () {
                  _closeDialogAndOpenCommentAddEditDialog(context: context);
                },
              ),
            ),
          ],
        ),
        actionsPadding: kDialogActionsPadding,
        content: Consumer<CommentVM>(
          builder: (context, commentVM, child) {
            return SingleChildScrollView(
              controller: _scrollController,
              child: ListBody(
                children: _buildAudioCommentsLst(
                  commentVM: commentVM,
                ),
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

  List<Widget> _buildAudioCommentsLst({
    required CommentVM commentVM,
  }) {
    AudioPlayerVM audioPlayerVMlistenFalse = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );

    List<Comment> commentsLst = commentVM.loadAudioComments(
      audio: widget.currentAudio,
    );

    const TextStyle commentTitleTextStyle = TextStyle(
      fontSize: kAudioTitleFontSize,
      fontWeight: FontWeight.bold,
    );

    const TextStyle commentContentTextStyle = TextStyle(
      fontSize: kAudioTitleFontSize,
    );

    // List of widgets corresponding to the audio comments
    List<Widget> widgetsLst = [];

    for (Comment comment in commentsLst) {
      // Calculating the number of lines occupied by the comment title
      _audioCommentsLinesNumber +=
          (1 + // 2 dates + position line after the comment title
              computeTextLineNumber(
                context: context,
                textStyle: commentTitleTextStyle,
                text: comment.title,
              ));

      // Calculating the number of lines occupied by the comment
      // content
      _audioCommentsLinesNumber += computeTextLineNumber(
        context: context,
        textStyle: commentContentTextStyle,
        text: comment.content,
      );

      widgetsLst.add(
        GestureDetector(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: _buildCommentTitlePlusIconsAndCommentDatesAndPosition(
                  audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
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

            _closeDialogAndOpenCommentAddEditDialog(
              context: context,
              comment: comment,
            );
          },
        ),
      );
    }

    _scrollToCurrentAudioItem();

    return widgetsLst;
  }

  Widget _buildCommentTitlePlusIconsAndCommentDatesAndPosition({
    required AudioPlayerVM audioPlayerVMlistenFalse,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
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
                        audioPlayerVM: audioPlayerVMlistenFalse,
                        commentVM: commentVM,
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
  /// opening the CommentAddEditDialog, the current dialog must be
  /// closed before opening the CommentAddEditDialog.
  void _closeDialogAndOpenCommentAddEditDialog({
    required BuildContext context,
    Comment? comment,
  }) {
    Navigator.of(context).pop(); // closes the current dialog
    showDialog<void>(
      context: context,
      barrierDismissible:
          false, // This line prevents the dialog from closing when
      //        tapping outside the dialog
      // instanciating CommentAddEditDialog without
      // passing a comment opens it in 'add' mode
      builder: (context) => CommentAddEditDialog(
        callerDialog: CallerDialog.commentListAddDialog,
        comment: comment,
      ),
    );
  }

  Future<void> _confirmDeleteComment({
    required AudioPlayerVM audioPlayerVM,
    required CommentVM commentVM,
    required Comment comment,
  }) async {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmActionDialog(
          actionFunction: commentVM.deleteCommentFunction,
          actionFunctionArgs: [
            comment.id,
            widget.currentAudio,
          ],
          dialogTitle: AppLocalizations.of(context)!.deleteCommentConfirnTitle,
          dialogContent: AppLocalizations.of(context)!
              .deleteCommentConfirnBody(comment.title),
        );
      },
    );

    if (audioPlayerVM.isPlaying) {
      await audioPlayerVM.pause();
    }
  }

  Future<void> _playFromCommentPosition({
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required Comment comment,
  }) async {
    _playingComment = comment;

    if (!audioPlayerVMlistenFalse.isPlaying) {
      // This fixes a problem when a playing comment was paused and
      // then the user clicked on the play button of an other comment.
      // In such a situation, the user had to click twice or three
      // times on the other comment play button to play it if the other
      // comment was positioned before the previously played comment.
      // If the other comment was positioned after the previously played
      // comment, then the user had to click only once on the play button
      // of the other comment to play it.
      await audioPlayerVMlistenFalse.playCurrentAudio(
        rewindAudioPositionBasedOnPauseDuration: false,
        isCommentPlaying: true,
      );
    }

    await audioPlayerVMlistenFalse.modifyAudioPlayerPluginPosition(
      durationPosition: Duration(
          milliseconds: comment.commentStartPositionInTenthOfSeconds * 100),
      addUndoCommand: true,
    );

    await audioPlayerVMlistenFalse.playCurrentAudio(
      rewindAudioPositionBasedOnPauseDuration: false,
      isCommentPlaying: true,
    );
  }

  void _scrollToCurrentAudioItem() {
    double offset = _audioCommentsLinesNumber * 135.0;

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

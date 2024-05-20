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
import 'action_confirm_dialog_widget.dart';
import 'comment_add_edit_dialog_widget.dart';

/// This widget displays a dialog with the list of positionned
/// comment added to the current audio.
///
/// When a comment is clicked, this opens a dialog to edit the
/// comment.
///
/// Additionally, a button 'plus' is displayed to add a new
/// positionned comment.
class CommentListAddDialogWidget extends StatefulWidget {
  final Audio currentAudio;

  const CommentListAddDialogWidget({
    super.key,
    required this.currentAudio,
  });

  @override
  State<CommentListAddDialogWidget> createState() =>
      _CommentListAddDialogWidgetState();
}

class _CommentListAddDialogWidgetState extends State<CommentListAddDialogWidget>
    with ScreenMixin {
  final FocusNode _focusNodeDialog = FocusNode();
  Comment? _playingComment;

  @override
  void dispose() {
    _focusNodeDialog.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);

    // Retrieve the screen width using MediaQuery
    double maxDropdownWidth =
        computeMaxDialogListItemWidth(context) - kSmallIconButtonWidth;

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
            List<Comment> commentsLst =
                commentVM.loadExistingCommentFileOrCreateEmptyCommentFile(
              commentedAudio: widget.currentAudio,
            );
            return SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  for (Comment comment in commentsLst) ...[
                    GestureDetector(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: _buildCommentTitlePlusIconsAndPosition(
                                maxDropdownWidth, comment, commentVM),
                          ),
                          (comment.content.isNotEmpty)
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  // comment content Text
                                  child: Text(
                                    key: const Key('commentTextKey'),
                                    comment.content,
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                      onTap: () async {
                        if (globalAudioPlayerVM.isPlaying &&
                            _playingComment != comment) {
                          // if the user clicks on a comment while another
                          // comment is playing, the playing comment is paused.
                          // Otherwise, the edited comment keeps playing.
                          await globalAudioPlayerVM.pause();
                        }

                        _closeDialogAndOpenCommentAddEditDialog(
                          context: context,
                          comment: comment,
                        );
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        actions: <Widget>[
          TextButton(
            key: const Key('closeButtonKey'),
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

  Widget _buildCommentTitlePlusIconsAndPosition(
    double maxDropdownWidth,
    Comment comment,
    CommentVM commentVM,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                width: maxDropdownWidth,
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
                    onPressed: () async {
                      // this logic enables that when we
                      // click on the play button of a comment,
                      // if an other comment is playing, it is
                      // paused
                      (_playingComment != null &&
                              _playingComment == comment &&
                              globalAudioPlayerVM.isPlaying)
                          ? await globalAudioPlayerVM.pause()
                          : await _playFromCommentPosition(
                              comment: comment,
                            );
                    },
                    icon: Consumer<AudioPlayerVM>(
                      builder: (context, globalAudioPlayerVM, child) {
                        // this logic avoids that when the
                        // user clicks on the play button of a
                        // comment, the play button of the
                        // other comment are updated to 'pause'
                        return Icon((_playingComment != null &&
                                _playingComment == comment &&
                                globalAudioPlayerVM.isPlaying)
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
                      await _confirmDeleteComment(commentVM, comment);
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
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              // comment position Text
              key: const Key('commentPositionKey'),
              style: TextStyle(fontSize: 13),
              Duration(seconds: comment.audioPositionSeconds).HHmmssZeroHH(),
            ),
            const SizedBox(width: 11),
          ],
        ),
      ],
    );
  }

  /// In order to avoid keyboard opening and closing continuously after
  /// opening the CommentAddEditDialogWidget, the current dialog must be
  /// closed before opening the CommentAddEditDialogWidget.
  void _closeDialogAndOpenCommentAddEditDialog({
    required BuildContext context,
    Comment? comment,
  }) {
    Navigator.of(context).pop();
    showDialog<void>(
      context: context,
      // instanciating CommentAddEditDialogWidget without
      // passing a comment opens it in 'add' mode
      builder: (context) => CommentAddEditDialogWidget(
        comment: comment,
      ),
    );
  }

  Future<void> _confirmDeleteComment(
    CommentVM commentVM,
    Comment comment,
  ) async {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ActionConfirmDialogWidget(
          actionFunction: commentVM.deleteCommentParmsNotNamed,
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

    if (globalAudioPlayerVM.isPlaying) {
      await globalAudioPlayerVM.pause();
    }
  }

  Future<void> _playFromCommentPosition({
    required Comment comment,
  }) async {
    _playingComment = comment;

    await globalAudioPlayerVM.modifyAudioPlayerPluginPosition(
      Duration(seconds: comment.audioPositionSeconds),
    );

    await globalAudioPlayerVM.playFromCurrentAudioFile(
      rewindAudioPositionBasedOnPauseDuration: false,
    );
  }
}

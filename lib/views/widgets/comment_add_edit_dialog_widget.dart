import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/comment.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../../viewmodels/comment_vm.dart';
import '../../views/screen_mixin.dart';
import '../../utils/duration_expansion.dart';

/// This widget displays a dialog to add or edit a comment.
/// The edit mode is activated when a comment is passed to the
/// widget constructor. Else, the widget is in add mode.
class CommentAddEditDialogWidget extends StatefulWidget {
  final Comment? comment;
  final bool isAddMode;

  const CommentAddEditDialogWidget({
    super.key,
    this.comment,
  }) : isAddMode = comment == null;

  @override
  State<CommentAddEditDialogWidget> createState() =>
      _CommentAddEditDialogWidgetState();
}

class _CommentAddEditDialogWidgetState extends State<CommentAddEditDialogWidget>
    with ScreenMixin {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final FocusNode _focusNodeDialog = FocusNode();
  final FocusNode _focusNodeCommentTitle = FocusNode();

  @override
  void initState() {
    super.initState();

    // Important to set the current comment audio position after the
    // build method has been executed since the commentVM notifies
    // listeners when the currentCommentAudioPosition is set.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CommentVM commentVM = Provider.of<CommentVM>(
        context,
        listen: false,
      );

      if (widget.comment != null) {
        titleController.text = widget.comment!.title;
        commentController.text = widget.comment!.content;
        commentVM.currentCommentAudioPosition =
            Duration(seconds: widget.comment!.audioPositionSeconds);
      } else {
        commentVM.currentCommentAudioPosition =
            globalAudioPlayerVM.currentAudioPosition;
      }
    });
  }

  @override
  void dispose() {
    _focusNodeDialog.dispose();
    _focusNodeCommentTitle.dispose();
    titleController.dispose();
    commentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(
      _focusNodeCommentTitle,
    );

    CommentVM commentVMlistenFalse = Provider.of<CommentVM>(
      context,
      listen: false,
    );

    return KeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: _focusNodeDialog,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // executing the same code as in the 'Save' TextButton
            // onPressed callback
            Navigator.of(context).pop();
          }
        }
      },
      child: AlertDialog(
        title: Text(AppLocalizations.of(context)!.commentDialogTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TextField for Title
              SizedBox(
                height: kDialogTextFieldHeight,
                child: TextField(
                  key: const Key('commentTitleTextField'),
                  controller: titleController,
                  style: kDialogTextFieldStyle,
                  decoration: getDialogTextFieldInputDecoration(
                    hintText: AppLocalizations.of(context)!.commentTitle,
                  ),
                  focusNode: _focusNodeCommentTitle,
                ),
              ),
              const SizedBox(height: 10),
              // Multiline TextField for Comments
              TextField(
                key: const Key('commentContentTextField'),
                controller: commentController,
                minLines: 2,
                maxLines: 3,
                decoration: getDialogTextFieldInputDecoration(
                  hintText: AppLocalizations.of(context)!.commentText,
                ),
              ),
              const SizedBox(height: 30),
              // Non-editable Text for Audio File Details
              // Audio Playback Controls
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    globalAudioPlayerVM.currentAudio?.validVideoTitle ?? '',
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        // Rewind 1 second button
                        icon: const Icon(Icons.fast_rewind),
                        onPressed: () async {
                          await modifyCommentPosition(
                            commentVMlistenFalse: commentVMlistenFalse,
                            secondChange: -1,
                          );
                        },
                        iconSize: kSmallestButtonWidth,
                      ),
                      Consumer<CommentVM>(
                        builder: (context, commentVM, child) {
                          return Text(
                            commentVM.currentCommentAudioPosition
                                .HHmmssZeroHH(),
                          );
                        },
                      ),
                      IconButton(
                        // Forward 1 second button
                        icon: Icon(Icons.fast_forward),
                        onPressed: () async {
                          await modifyCommentPosition(
                            commentVMlistenFalse: commentVMlistenFalse,
                            secondChange: 1,
                          );
                        },
                        iconSize: kSmallestButtonWidth,
                      ),
                      IconButton(
                        // Play/Pause button
                        onPressed: () async {
                          globalAudioPlayerVM.isPlaying
                              ? await globalAudioPlayerVM.pause()
                              : await _playFromCommentPosition(
                                  commentVMlistenFalse: commentVMlistenFalse,
                                );
                        },
                        icon: Consumer<AudioPlayerVM>(
                          builder: (context, globalAudioPlayerVM, child) {
                            return Icon(globalAudioPlayerVM.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow);
                          },
                        ),
                        iconSize: kUpDownButtonSize - 10,
                        constraints:
                            const BoxConstraints(), // Ensure the button
                        //                         takes minimal space
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('addOrUpdateCommentTextButton'),
            child: Text(
              widget.isAddMode
                  ? AppLocalizations.of(context)!.add
                  : AppLocalizations.of(context)!.update,
            ),
            onPressed: () async {
              if (widget.isAddMode) {
                commentVMlistenFalse.addComment(
                  comment: Comment(
                    title: titleController.text,
                    content: commentController.text,
                    audioPositionSeconds: commentVMlistenFalse
                        .currentCommentAudioPosition.inSeconds,
                  ),
                  commentedAudio: globalAudioPlayerVM.currentAudio!,
                );
              } else {
                Comment commentToModify = widget.comment!;

                commentToModify.title = titleController.text;
                commentToModify.content = commentController.text;
                commentToModify.audioPositionSeconds =
                    commentVMlistenFalse.currentCommentAudioPosition.inSeconds;

                commentVMlistenFalse.modifyComment(
                  modifiedComment: commentToModify,
                  commentedAudio: globalAudioPlayerVM.currentAudio!,
                );
              }

              await _closeDialog(context);
            },
          ),
          TextButton(
            key: const Key('cancelTextButton'),
            child: Text(AppLocalizations.of(context)!.cancelButton),
            onPressed: () async => await _closeDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _closeDialog(BuildContext context) async {
    if (globalAudioPlayerVM.isPlaying) {
      await globalAudioPlayerVM.pause();
    }

    Navigator.of(context).pop();
  }

  Future<void> _playFromCommentPosition({
    required CommentVM commentVMlistenFalse,
  }) async {
    await globalAudioPlayerVM.modifyAudioPlayerPluginPosition(
      commentVMlistenFalse.currentCommentAudioPosition,
    );

    await globalAudioPlayerVM.playFromCurrentAudioFile(
      rewindAudioPositionBasedOnPauseDuration: false,
    );
  }

  Future<void> modifyCommentPosition({
    required CommentVM commentVMlistenFalse,
    required int secondChange,
  }) async {
    commentVMlistenFalse.currentCommentAudioPosition =
        commentVMlistenFalse.currentCommentAudioPosition +
            Duration(seconds: secondChange);

    await globalAudioPlayerVM.modifyAudioPlayerPluginPosition(
      commentVMlistenFalse.currentCommentAudioPosition,
    );

    await globalAudioPlayerVM.playFromCurrentAudioFile(
      rewindAudioPositionBasedOnPauseDuration: false,
    );
  }
}
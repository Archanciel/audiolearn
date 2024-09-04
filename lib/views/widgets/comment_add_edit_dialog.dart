import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/comment.dart';
import '../../services/settings_data_service.dart';
import '../../utils/date_time_util.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../../viewmodels/comment_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../../views/screen_mixin.dart';
import '../../utils/duration_expansion.dart';
import 'comment_list_add_dialog.dart';
import 'playlist_comment_list_dialog.dart';
import 'set_value_to_target_dialog.dart';

enum CallerDialog {
  commentListAddDialog,
  playlistCommentListAddDialog,
}

/// This widget displays a dialog to add or edit a comment.
/// The edit mode is activated when a comment is passed to the
/// widget constructor. Else, the widget is in add mode.
class CommentAddEditDialog extends StatefulWidget {
  final CallerDialog callerDialog;
  final Comment? comment;
  final bool isAddMode;

  const CommentAddEditDialog({
    super.key,
    required this.callerDialog,
    this.comment,
  }) : isAddMode = comment == null;

  @override
  State<CommentAddEditDialog> createState() => _CommentAddEditDialogState();
}

class _CommentAddEditDialogState extends State<CommentAddEditDialog>
    with ScreenMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNodeCommentTitle = FocusNode();
  bool _commentStartPositionChangedInTenthOfSeconds = false;
  bool _commentEndPositionChangedInTenthOfSeconds = false;
  bool _playButtonWasClicked = true;
  bool _commentEndPositionIsModified = false;

  @override
  void initState() {
    super.initState();

    // Important to set the current comment audio position after the
    // build method has been executed since the commentVM notifies
    // listeners when the currentCommentAudioPosition is set.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioPlayerVM audioPlayerVM = Provider.of<AudioPlayerVM>(
        context,
        listen: false,
      );
      CommentVM commentVM = Provider.of<CommentVM>(
        context,
        listen: false,
      );

      if (widget.comment != null) {
        // here, we are editing a comment
        _titleController.text = widget.comment!.title;
        _commentController.text = widget.comment!.content;
        commentVM.currentCommentStartPosition = Duration(
            milliseconds:
                widget.comment!.commentStartPositionInTenthOfSeconds * 100);
        Duration commentEndPosition = Duration(
            milliseconds:
                widget.comment!.commentEndPositionInTenthOfSeconds * 100);
        commentVM.currentCommentEndPosition = commentEndPosition;
      } else {
        // here, we are creating a comment
        commentVM.currentCommentStartPosition =
            audioPlayerVM.currentAudioPosition;
        commentVM.currentCommentEndPosition =
            audioPlayerVM.currentAudioPosition;
      }
    });
  }

  @override
  void dispose() {
    _focusNodeCommentTitle.dispose();
    _titleController.dispose();
    _commentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(
      _focusNodeCommentTitle,
    );
    AudioPlayerVM audioPlayerVM = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );
    CommentVM commentVMlistenFalse = Provider.of<CommentVM>(
      context,
      listen: false,
    );

    // Since it is necessary that Enter can be used in comment text field
    // to add a new line, using KeyListener and FocusNode must be avoided.
    return AlertDialog(
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
                controller: _titleController,
                style: kDialogTextFieldBoldStyle,
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
              controller: _commentController,
              style: kDialogTextFieldStyle,
              minLines: 2,
              maxLines: 3,
              decoration: getDialogTextFieldInputDecoration(
                hintText: AppLocalizations.of(context)!.commentText,
              ),
            ),
            const SizedBox(height: 30),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Commented audio title
                Text(
                  audioPlayerVM.currentAudio?.validVideoTitle ?? '',
                  textAlign: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        _buildCommentStartPositionRow(
                          context: context,
                          audioPlayerVM: audioPlayerVM,
                          commentVMlistenFalse: commentVMlistenFalse,
                        ),
                        _buildCommentEndPositionRow(
                          context: context,
                          audioPlayerVM: audioPlayerVM,
                          commentVMlistenFalse: commentVMlistenFalse,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          // Play/Pause button
                          key: const Key('playPauseIconButton'),
                          onPressed: () async {
                            if (audioPlayerVM.isPlaying) {
                              await audioPlayerVM.pause();

                              // Modify the end audio position if the end
                              // audio position is before or equal to the
                              // current audio position.
                              //
                              // In the situation when a new comment is
                              // created, it is useful to set the end audio
                              // position as the current audio play position
                              // when the user clicks on the pause button after
                              // having left the application play the audio
                              // till the comment end position.
                              if (commentVMlistenFalse
                                      .currentCommentEndPosition <=
                                  commentVMlistenFalse
                                      .currentCommentStartPosition) {
                                commentVMlistenFalse.currentCommentEndPosition =
                                    audioPlayerVM.currentAudioPosition;
                              }
                            } else {
                              // comment is not playing
                              _playButtonWasClicked = true;
                              _commentEndPositionIsModified = false;

                              await _playFromCommentPosition(
                                  audioPlayerVM: audioPlayerVM,
                                  commentVMlistenFalse: commentVMlistenFalse);
                            }
                          },
                          style: ButtonStyle(
                            // Highlight button when pressed
                            padding:
                                WidgetStateProperty.all<EdgeInsetsGeometry>(
                              const EdgeInsets.symmetric(
                                  horizontal: kSmallButtonInsidePadding,
                                  vertical: 0),
                            ),
                            overlayColor:
                                iconButtonTapModification, // Tap feedback color
                          ),
                          icon: Consumer<AudioPlayerVM>(
                            // Setting the icon as Consumer of AudioPlayerVM
                            // enables the icon to change according to the
                            // audio player VM state.
                            //
                            // Additionally, the code below ensures that the
                            // audio player is paused when the current comment
                            // end audio position is reached.
                            builder: (context, audioPlayerVMlistenTrue, child) {
                              if (!_commentEndPositionIsModified) {
                                if (commentVMlistenFalse
                                        .currentCommentEndPosition >
                                    commentVMlistenFalse
                                        .currentCommentStartPosition) {
                                  // situation in which the current comment end
                                  // audio position was set
                                  if (audioPlayerVMlistenTrue
                                          .currentAudioPosition >=
                                      commentVMlistenFalse
                                          .currentCommentEndPosition) {
                                    // here, the audio player reached the
                                    // current comment end audio position
                                    if (_playButtonWasClicked) {
                                      // if the audio player was stopped after
                                      // reaching the current comment end audio,
                                      // the user must be able to play the audio
                                      // again from the current comment audio
                                      // start position
                                      _playButtonWasClicked = false;
                                    } else {
                                      audioPlayerVMlistenTrue.pause().then((_) {
                                        // enables the user to play the audio again
                                        // from the current comment audio start
                                        // position
                                        _playButtonWasClicked = true;
                                      });
                                    }
                                  }
                                }
                              } else {
                                if (commentVMlistenFalse
                                        .currentCommentEndPosition >
                                    commentVMlistenFalse
                                        .currentCommentStartPosition) {
                                  // situation in which the current comment end
                                  // audio position was set
                                  if (audioPlayerVMlistenTrue
                                          .currentAudioPosition >=
                                      commentVMlistenFalse
                                          .currentCommentEndPosition) {
                                    // here, the audio player reached the
                                    // current comment end audio position
                                    audioPlayerVMlistenTrue
                                        .pause()
                                        .then((value) => null);
                                  }
                                }
                              }

                              return Icon(audioPlayerVMlistenTrue.isPlaying
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
                _buildSetAudioPositionTextButton(
                  context: context,
                  commentVMlistenFalse: commentVMlistenFalse,
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
                  title: _titleController.text,
                  content: _commentController.text,
                  commentStartPositionInTenthOfSeconds: (commentVMlistenFalse
                              .currentCommentStartPosition.inMilliseconds /
                          100)
                      .round(),
                  commentEndPositionInTenthOfSeconds: (commentVMlistenFalse
                              .currentCommentEndPosition.inMilliseconds /
                          100)
                      .round(),
                ),
                audioToComment: audioPlayerVM.currentAudio!,
              );
            } else {
              Comment commentToModify = widget.comment!;

              commentToModify.title = _titleController.text;
              commentToModify.content = _commentController.text;
              commentToModify.commentStartPositionInTenthOfSeconds =
                  (commentVMlistenFalse
                              .currentCommentStartPosition.inMilliseconds /
                          100)
                      .round();
              commentToModify.commentEndPositionInTenthOfSeconds =
                  (commentVMlistenFalse
                              .currentCommentEndPosition.inMilliseconds /
                          100)
                      .round();

              commentVMlistenFalse.modifyComment(
                modifiedComment: commentToModify,
                commentedAudio: audioPlayerVM.currentAudio!,
              );
            }

            await _closeDialogAndReOpenCommentListAddDialog(
              context: context,
              audioPlayerVM: audioPlayerVM,
            );
          },
        ),
        TextButton(
          key: const Key('cancelTextButton'),
          child: Text(AppLocalizations.of(context)!.cancelButton),
          onPressed: () async =>
              await _closeDialogAndReOpenCommentListAddDialog(
            context: context,
            audioPlayerVM: audioPlayerVM,
          ),
        ),
      ],
    );
  }

  Row _buildCommentStartPositionRow({
    required BuildContext context,
    required AudioPlayerVM audioPlayerVM,
    required CommentVM commentVMlistenFalse,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
          height: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
          child: Tooltip(
            message:
                AppLocalizations.of(context)!.tenthOfSecondsCheckboxTooltip,
            child: Checkbox(
              key: const Key('commentStartTenthOfSecondsCheckbox'),
              value: _commentStartPositionChangedInTenthOfSeconds,
              onChanged: (bool? newValue) {
                setState(() {
                  _commentStartPositionChangedInTenthOfSeconds =
                      newValue ?? false;
                });
              },
            ),
          ),
        ),
        SizedBox(
          width: 50,
          child: IconButton(
            key: const Key('backwardCommentStartIconButton'),
            // Rewind 1 second button
            style: ButtonStyle(
              // Highlight button when pressed
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(
                    horizontal: kSmallButtonInsidePadding, vertical: 0),
              ),
              overlayColor: iconButtonTapModification, // Tap feedback color
            ),
            icon: const Icon(Icons.fast_rewind),
            onPressed: () async {
              await _modifyCommentStartPosition(
                audioPlayerVM: audioPlayerVM,
                commentVMlistenFalse: commentVMlistenFalse,
                millisecondsChange:
                    _commentStartPositionChangedInTenthOfSeconds ? -100 : -1000,
              );
            },
            iconSize: _commentStartPositionChangedInTenthOfSeconds
                ? kSmallestButtonWidth * 0.8
                : kSmallestButtonWidth,
          ),
        ),
        Consumer<CommentVM>(
          builder: (context, commentVM, child) {
            // Text for the current comment audio position
            return Text(
              key: const Key('commentStartPositionText'),
              _commentStartPositionChangedInTenthOfSeconds
                  // if the modify position duration change in tenth
                  // of seconds checkbox is checked, the audio
                  // position is displayed with a tenth of a second
                  // value after the seconds value
                  ? commentVM.currentCommentStartPosition
                      .HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true)
                  : commentVM.currentCommentStartPosition.HHmmssZeroHH(),
            );
          },
        ),
        SizedBox(
          width: 50,
          child: IconButton(
            // Forward 1 second button
            key: const Key('forwardCommentStartIconButton'),
            style: ButtonStyle(
              // Highlight button when pressed
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(
                    horizontal: kSmallButtonInsidePadding, vertical: 0),
              ),
              overlayColor: iconButtonTapModification, // Tap feedback color
            ),
            icon: const Icon(Icons.fast_forward),
            onPressed: () async {
              await _modifyCommentStartPosition(
                audioPlayerVM: audioPlayerVM,
                commentVMlistenFalse: commentVMlistenFalse,
                millisecondsChange:
                    _commentStartPositionChangedInTenthOfSeconds ? 100 : 1000,
              );
            },
            iconSize: _commentStartPositionChangedInTenthOfSeconds
                ? kSmallestButtonWidth * 0.8
                : kSmallestButtonWidth,
          ),
        ),
      ],
    );
  }

  Row _buildCommentEndPositionRow({
    required BuildContext context,
    required AudioPlayerVM audioPlayerVM,
    required CommentVM commentVMlistenFalse,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
          height: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
          child: Tooltip(
            message:
                AppLocalizations.of(context)!.tenthOfSecondsCheckboxTooltip,
            child: Checkbox(
              key: const Key('commentEndTenthOfSecondsCheckbox'),
              value: _commentEndPositionChangedInTenthOfSeconds,
              onChanged: (bool? newValue) {
                setState(() {
                  _commentEndPositionChangedInTenthOfSeconds =
                      newValue ?? false;
                });
              },
            ),
          ),
        ),
        SizedBox(
          width: 50,
          child: IconButton(
            key: const Key('backwardCommentEndIconButton'),
            // Rewind 1 second button
            style: ButtonStyle(
              // Highlight button when pressed
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(
                    horizontal: kSmallButtonInsidePadding, vertical: 0),
              ),
              overlayColor: iconButtonTapModification, // Tap feedback color
            ),
            icon: const Icon(Icons.fast_rewind),
            onPressed: () async {
              _commentEndPositionIsModified = true;
              await _modifyCommentEndPosition(
                audioPlayerVM: audioPlayerVM,
                commentVMlistenFalse: commentVMlistenFalse,
                millisecondsChange:
                    _commentEndPositionChangedInTenthOfSeconds ? -100 : -1000,
              );
            },
            iconSize: _commentEndPositionChangedInTenthOfSeconds
                ? kSmallestButtonWidth * 0.8
                : kSmallestButtonWidth,
          ),
        ),
        Consumer<CommentVM>(
          builder: (context, commentVM, child) {
            // Text for the current comment end audio position
            return Text(
              key: const Key('commentEndPositionText'),
              _commentEndPositionChangedInTenthOfSeconds
                  // if the modify position duration change in tenth
                  // of seconds checkbox is checked, the audio
                  // position is displayed with a tenth of a second
                  // value after the seconds value
                  ? commentVM.currentCommentEndPosition
                      .HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true)
                  : commentVM.currentCommentEndPosition.HHmmssZeroHH(),
            );
          },
        ),
        SizedBox(
          width: 50,
          child: IconButton(
            // Forward 1 second button
            key: const Key('forwardCommentEndIconButton'),
            style: ButtonStyle(
              // Highlight button when pressed
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(
                    horizontal: kSmallButtonInsidePadding, vertical: 0),
              ),
              overlayColor: iconButtonTapModification, // Tap feedback color
            ),
            icon: const Icon(Icons.fast_forward),
            onPressed: () async {
              _commentEndPositionIsModified = true;
              await _modifyCommentEndPosition(
                audioPlayerVM: audioPlayerVM,
                commentVMlistenFalse: commentVMlistenFalse,
                millisecondsChange:
                    _commentEndPositionChangedInTenthOfSeconds ? 100 : 1000,
              );
            },
            iconSize: _commentEndPositionChangedInTenthOfSeconds
                ? kSmallestButtonWidth * 0.8
                : kSmallestButtonWidth,
          ),
        ),
      ],
    );
  }

  /// The returned row contains the text button which opens a dialog
  /// to set the current audio position as the comment start or end
  /// position.
  Row _buildSetAudioPositionTextButton({
    required BuildContext context,
    required CommentVM commentVMlistenFalse,
  }) {
    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(
      context,
      listen: false,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Consumer<AudioPlayerVM>(
          builder: (context, audioPlayerVM, child) {
            String currentAudioPositionStr = audioPlayerVM.currentAudioPosition
                .HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true);
            return Tooltip(
              message: AppLocalizations.of(context)!
                  .updateCommentStartEndPositionTooltip,
              child: TextButton(
                key: const Key('selectCommentPositionTextButton'),
                style: ButtonStyle(
                  shape: getButtonRoundedShape(
                    currentTheme: themeProviderVM.currentTheme,
                    isButtonEnabled: true,
                    context: context,
                  ),
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(
                        horizontal: kSmallButtonInsidePadding, vertical: 0),
                  ),
                  overlayColor: textButtonTapModification, // Tap feedback color
                ),
                onPressed: () {
                  showDialog<List<String>>(
                    barrierDismissible:
                        false, // This line prevents the dialog from closing when
                    //            tapping outside the dialog
                    context: context,
                    builder: (BuildContext context) {
                      return SetValueToTargetDialog(
                        dialogTitle:
                            AppLocalizations.of(context)!.setCommentPosition,
                        dialogCommentStr: AppLocalizations.of(context)!
                            .commentPositionExplanation,
                        passedValueFieldLabel:
                            AppLocalizations.of(context)!.commentPosition,
                        passedValueStr: currentAudioPositionStr,
                        targetNamesLst: [
                          AppLocalizations.of(context)!.commentStartPosition,
                          AppLocalizations.of(context)!.commentEndPosition,
                        ],
                        validationFunction: validateEnteredValueFunction,
                        validationFunctionArgs: [
                          '0:00.0',
                          audioPlayerVM.currentAudioTotalDuration.HHmmssZeroHH(
                              addRemainingOneDigitTenthOfSecond: true),
                        ],
                      );
                    },
                  ).then((resultStringLst) {
                    if (resultStringLst == null) {
                      // the case if the Cancel button was pressed
                      return;
                    }

                    String positionStr = resultStringLst[0];
                    String checkboxIndexStr = resultStringLst[1];
                    Duration positionDuration = Duration(
                        milliseconds: DateTimeUtil.convertToTenthsOfSeconds(
                                timeString: positionStr) *
                            100);

                    if (checkboxIndexStr == '0') {
                      // the case if the Comment Start Position checkbox was
                      // checked
                      commentVMlistenFalse.currentCommentStartPosition =
                          positionDuration;
                    } else {
                      // the case if the Comment End Position checkbox was
                      // checked
                      commentVMlistenFalse.currentCommentEndPosition =
                          positionDuration;
                    }

                    // Updating the changed position display format to
                    // the format of the provided position
                    int pointPosition = positionStr.indexOf('.');

                    if (pointPosition != -1) {
                      // the case if the position is formatted with a tenth
                      // of a second value (e.g. 00:00:00.0)
                      if (positionStr.substring(
                              pointPosition + 1, positionStr.length) !=
                          '0') {
                        // in this situation, the changed position is
                        // displayed withwitha tenth of a second format
                        if (checkboxIndexStr == '0') {
                          _commentStartPositionChangedInTenthOfSeconds = true;
                        } else if (checkboxIndexStr == '1') {
                          _commentEndPositionChangedInTenthOfSeconds = true;
                        }
                      }
                    }
                  });
                },
                child: Text(
                  currentAudioPositionStr,
                  textAlign: TextAlign.center,
                  style: (themeProviderVM.currentTheme == AppTheme.dark)
                      ? kTextButtonStyleDarkMode
                      : kTextButtonStyleLightMode,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// This function validates the entered time value in the
  /// SetValuesToTargetDialog. In order to do this, it is passed
  /// as parameter to the dialog constructor.
  ///
  /// In SetValuesToTargetDialog._createResultList(), the entered
  /// time value is validated by calling this function this way:
  ///    bool isValid = Function.apply(
  ///                       widget.validationFunction,
  ///                       widget.validationFunctionArgs,
  ///                   );
  InvalidValueState validateEnteredValueFunction(
    String minDurationStr,
    String maxDurationStr,
    String enteredTimeStr,
  ) {
    int minDurationInTenthsOfSeconds =
        DateTimeUtil.convertToTenthsOfSeconds(timeString: minDurationStr);
    int maxDurationInTenthsOfSeconds =
        DateTimeUtil.convertToTenthsOfSeconds(timeString: maxDurationStr);
    int enteredTimeInTenthsOfSeconds =
        DateTimeUtil.convertToTenthsOfSeconds(timeString: enteredTimeStr);

    if (enteredTimeInTenthsOfSeconds > maxDurationInTenthsOfSeconds) {
      return InvalidValueState.tooBig;
    } else if (enteredTimeInTenthsOfSeconds < minDurationInTenthsOfSeconds) {
      return InvalidValueState.tooSmall;
    } else {
      // the case if the entered value is valid
      return InvalidValueState.none;
    }
  }

  /// Since before opening the CommentAddEditDialog its caller, the
  /// CommentListAddDialog or the PlaylistCommentListAddDialog,
  /// was closed, the caller dialog must be re-opened in order to display
  /// the updated list of comments.
  Future<void> _closeDialogAndReOpenCommentListAddDialog({
    required BuildContext context,
    required AudioPlayerVM audioPlayerVM,
  }) async {
    // Closing first the current CommentAddEditDialog dialog (... pop())
    // and then opening the CommentListAddDialog dialog before pausing
    // the audio without using await on pause method avoids that if the audio
    // is playing when we close the CommentAddEditDialog, the
    // CommentAddEditDialog is re-opened !
    Navigator.of(context).pop(); // close the current dialog

    showDialog<void>(
      context: context,
      barrierDismissible:
          false, // This line prevents the dialog from closing when
      //            tapping outside the dialog
      // passing the current audio to the dialog instead
      // of initializing a private _currentAudio variable
      // in the dialog avoid integr test problems
      builder: (context) {
        switch (widget.callerDialog) {
          case CallerDialog.commentListAddDialog:
            return CommentListAddDialog(
              currentAudio: audioPlayerVM.currentAudio!,
            );
          case CallerDialog.playlistCommentListAddDialog:
            return PlaylistCommentListDialog(
              currentPlaylist: audioPlayerVM.currentAudio!.enclosingPlaylist!,
            );
        }
      },
    );

    if (audioPlayerVM.isPlaying) {
      await audioPlayerVM.pause();
    }
  }

  Future<void> _playFromCommentPosition({
    required AudioPlayerVM audioPlayerVM,
    required CommentVM commentVMlistenFalse,
  }) async {
    await audioPlayerVM.modifyAudioPlayerPluginPosition(
      commentVMlistenFalse.currentCommentStartPosition,
    );

    await audioPlayerVM.playCurrentAudio(
      rewindAudioPositionBasedOnPauseDuration: false,
      isCommentPlaying: true,
    );
  }

  Future<void> _modifyCommentStartPosition({
    required AudioPlayerVM audioPlayerVM,
    required CommentVM commentVMlistenFalse,
    required int millisecondsChange,
  }) async {
    commentVMlistenFalse.currentCommentStartPosition =
        commentVMlistenFalse.currentCommentStartPosition +
            Duration(milliseconds: millisecondsChange);

    await audioPlayerVM.modifyAudioPlayerPluginPosition(
      commentVMlistenFalse.currentCommentStartPosition,
    );

    await audioPlayerVM.playCurrentAudio(
      rewindAudioPositionBasedOnPauseDuration: false,
      isCommentPlaying: true,
    );
  }

  Future<void> _modifyCommentEndPosition({
    required AudioPlayerVM audioPlayerVM,
    required CommentVM commentVMlistenFalse,
    required int millisecondsChange,
  }) async {
    commentVMlistenFalse.currentCommentEndPosition =
        commentVMlistenFalse.currentCommentEndPosition +
            Duration(milliseconds: millisecondsChange);

    await audioPlayerVM.modifyAudioPlayerPluginPosition(
        commentVMlistenFalse.currentCommentEndPosition -
            const Duration(milliseconds: 4000));

    await audioPlayerVM.playCurrentAudio(
      rewindAudioPositionBasedOnPauseDuration: false,
      isCommentPlaying: true,
    );
  }
}

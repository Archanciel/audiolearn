import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants.dart';
import '../../views/screen_mixin.dart';

class CommentAddDialogWidget extends StatefulWidget {
  const CommentAddDialogWidget({
    super.key,
  });

  @override
  State<CommentAddDialogWidget> createState() => _CommentAddDialogWidgetState();
}

class _CommentAddDialogWidgetState extends State<CommentAddDialogWidget>
    with ScreenMixin {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final FocusNode _focusNodeDialog = FocusNode();
  final FocusNode _focusNodePlaylistRootPath = FocusNode();

  @override
  void dispose() {
    _focusNodeDialog.dispose();
    _focusNodePlaylistRootPath.dispose();
    titleController.dispose();
    commentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(
      _focusNodePlaylistRootPath,
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
                  focusNode: _focusNodePlaylistRootPath,
                ),
              ),
              const SizedBox(height: 10),
              // Multiline TextField for Comments
              TextField(
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
                  const Text(
                    'Jancovici - débat avec Bernard Friot - Aix en Provence',
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.fast_rewind),
                        onPressed: () {
                          rewindOneSecondAndPlay();
                        },
                        iconSize: kSmallestButtonWidth,
                      ),
                      const Text('2:20:45'),
                      IconButton(
                        icon: Icon(Icons.fast_forward),
                        onPressed: () {
                          forwardOneSecondAndPlay();
                        },
                        iconSize: kSmallestButtonWidth,
                      ),
                      IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () {
                          playFromCommentPosition();
                        },
                        iconSize: kUpDownButtonSize - 10,
                        padding: EdgeInsets.all(0), // Remove extra padding
                        constraints:
                            BoxConstraints(), // Ensure the button takes minimal space
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
            onPressed: () {
              // Logique de confirmation (sauvegarder les commentaires, etc.)
              print('Titre: ${titleController.text}');
              print('Commentaire: ${commentController.text}');
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.add,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.cancelButton),
          ),
        ],
      ),
    );
  }

  void rewindOneSecondAndPlay() {
    print('Rewind 1 second');
  }

  void forwardOneSecondAndPlay() {
    print('Forward 1 second');
  }

  void playFromCommentPosition() {
    print('Play from comment position');
  }
}

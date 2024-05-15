import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/audio.dart';
import '../../models/comment.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/comment_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../screen_mixin.dart';
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
  const CommentListAddDialogWidget({
    super.key,
  });

  @override
  State<CommentListAddDialogWidget> createState() =>
      _CommentListAddDialogWidgetState();
}

class _CommentListAddDialogWidgetState extends State<CommentListAddDialogWidget>
    with ScreenMixin {
  final FocusNode _focusNodeDialog = FocusNode();
  late List<Comment> _commentsLst;

  @override
  void initState() {
    super.initState();

    CommentVM commentVM = Provider.of<CommentVM>(
      context,
      listen: false,
    );
    Audio currentAudio = globalAudioPlayerVM.currentAudio!;
    _commentsLst = commentVM.loadExistingCommentFileOrCreateEmptyCommentFile(
      commentedAudio: currentAudio,
    );
  }

  @override
  void dispose() {
    _focusNodeDialog.dispose();

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
            Text(
              AppLocalizations.of(context)!.commentsDialogTitle,
            ),
            const SizedBox(width: 15),
            Tooltip(
              message:
                  AppLocalizations.of(context)!.addPositionedCommentTooltip,
              child: IconButton(
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
                  showDialog<void>(
                    context: context,
                    // instanciating CommentAddEditDialogWidget without
                    // passing a comment opens it in 'add' mode
                    builder: (context) => const CommentAddEditDialogWidget(),
                  );
                },
              ),
            ),
          ],
        ),
        actionsPadding: kDialogActionsPadding,
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              for (Comment comment in _commentsLst) ...[
                GestureDetector(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                comment.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          comment.content,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      // instanciating CommentAddEditDialogWidget with
                      // passing a comment opens it in 'edit' mode
                      builder: (context) => CommentAddEditDialogWidget(
                        comment: comment,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
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
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/help_item.dart';
import '../../views/screen_mixin.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';
import 'help_dialog.dart';

enum ConfirmAction { cancel, confirm }

/// This dialog asks for confirmation before executing an action. The action is
/// passed as a function [actionFunction] with its argument values added to the
/// list [actionFunctionArgs] and executed on confirmation.
///
/// If [helpItemsLst] is passed to the dialog constructor, a help icon is
/// displayed in the dialog title. Clicking on the help icon opens a dialog
/// with displaying the help content contained in the help items.
class ConfirmActionDialog extends StatefulWidget {
  final Function actionFunction; // The action to execute on confirmation
  final List<dynamic> actionFunctionArgs; // Arguments for the action function
  final String dialogTitleOne; // Title of the dialog
  final String dialogTitleTwo; // Title of the dialog
  final String dialogContent; // Content of the dialog
  final Function? warningFunction; // The action to execute on confirmation
  final List<dynamic> warningFunctionArgs; // Arguments for the action function
  final List<HelpItem> helpItemsLst;

  final bool dialogTitleOneReducedFontSize;

  const ConfirmActionDialog({
    required this.actionFunction,
    required this.actionFunctionArgs,
    required this.dialogTitleOne,
    this.dialogTitleOneReducedFontSize = false,
    this.dialogTitleTwo = '',
    required this.dialogContent,
    this.warningFunction,
    this.warningFunctionArgs = const [],
    this.helpItemsLst = const [],
    super.key,
  });

  @override
  State<ConfirmActionDialog> createState() => _ConfirmActionDialogState();
}

class _ConfirmActionDialogState extends State<ConfirmActionDialog>
    with ScreenMixin {
  final FocusNode _focusNodeDialog = FocusNode();

  @override
  dispose() {
    _focusNodeDialog.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProviderVM themeProviderVM =
        Provider.of<ThemeProviderVM>(context); // by default, listen is true

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
            // executing the same code as in the 'Delete'
            // TextButton onPressed callback
            _applyConfirm(context);
          }
        }
      },
      child: AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    widget.dialogTitleOne,
                    style: (widget.dialogTitleOneReducedFontSize)
                        ? Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontSize: kConfirmActionDialogSmallerFontSize,
                            )
                        : Theme.of(context).textTheme.headlineSmall,
                    key: const Key('confirmDialogTitleOneKey'),
                  ),
                ),
                if (widget.helpItemsLst.isNotEmpty)
                  IconButton(
                    icon: IconTheme(
                      data: (themeProviderVM.currentTheme == AppTheme.dark
                              ? ScreenMixin.themeDataDark
                              : ScreenMixin.themeDataLight)
                          .iconTheme,
                      child: const Icon(
                        Icons.help_outline,
                        size: 40.0,
                      ),
                    ),
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) => HelpDialog(
                          helpItemsLst: widget.helpItemsLst,
                        ),
                      );
                    },
                  ),
              ],
            ),
            if (widget.dialogTitleTwo.isNotEmpty)
              Text(
                widget.dialogTitleTwo,
                key: const Key('confirmDialogTitleTwoKey'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height *
                0.5, // Limits height to 50% of screen
          ),
          child: SingleChildScrollView(
            child: Text(
              widget.dialogContent,
              key: const Key('confirmationDialogMessageKey'),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            key: const Key('confirmButton'),
            onPressed: () {
              _applyConfirm(context);
            },
            child: Text(AppLocalizations.of(context)!.confirmButton),
          ),
          TextButton(
            key: const Key('cancelButtonKey'),
            onPressed: () => Navigator.of(context).pop(ConfirmAction.cancel),
            child: Text(AppLocalizations.of(context)!.cancelButton),
          ),
        ],
      ),
    );
  }

  void _applyConfirm(BuildContext context) {
    // Execute the action function with arguments. This execution
    // returns the value returned by the action function.
    dynamic returnedResult = Function.apply(
      widget.actionFunction,
      widget.actionFunctionArgs,
    );

    if (widget.warningFunction != null) {
      // If the warning function was passed, execute it with
      // arguments
      Function.apply(widget.warningFunction!, widget.warningFunctionArgs);
    }

    Navigator.of(context).pop(returnedResult);
  }
}

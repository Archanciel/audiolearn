import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../views/screen_mixin.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';

enum ConfirmAction { cancel, confirm }

class ConfirmActionDialog extends StatefulWidget {
  final Function actionFunction; // The action to execute on confirmation
  final List<dynamic> actionFunctionArgs; // Arguments for the action function
  final String dialogTitle; // Title of the dialog
  final String dialogContent; // Content of the dialog
  final Function? warningFunction; // The action to execute on confirmation
  final List<dynamic> warningFunctionArgs; // Arguments for the action function

  const ConfirmActionDialog({
    required this.actionFunction,
    required this.actionFunctionArgs,
    required this.dialogTitle,
    required this.dialogContent,
    this.warningFunction,
    this.warningFunctionArgs = const [],
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
    final ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);

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
        title: Text(
          widget.dialogTitle,
          key: const Key('confirmDialogTitleKey'),
        ),
        content: Text(
          widget.dialogContent,
          key: const Key('confirmationDialogMessageKey'),
        ),
        actions: <Widget>[
          TextButton(
            key: const Key('confirmButton'),
            onPressed: () {
              _applyConfirm(context);
            },
            child: Text(
              AppLocalizations.of(context)!.confirmButton,
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
          ),
          TextButton(
            key: const Key('cancelButtonKey'),
            onPressed: () => Navigator.of(context)
                .pop(ConfirmAction.cancel), // Cancel the action
            child: Text(
              AppLocalizations.of(context)!.cancelButton,
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
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

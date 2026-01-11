import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/help_item.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../screen_mixin.dart';

/// This dialog is displayed when the user clicks on the help icon button
/// which is present in some dialogs.
class HelpDialog extends StatelessWidget with ScreenMixin {
  final List<HelpItem> helpItemsLst;
  final FocusNode focusNodeDialog = FocusNode();

  HelpDialog({
    super.key,
    required this.helpItemsLst,
  });

  @override
  Widget build(BuildContext context) {
    // Required so that clicking on Enter closes the dialog
    FocusScope.of(context).requestFocus(
      focusNodeDialog,
    );

    final ThemeProviderVM themeProviderVM =
        Provider.of<ThemeProviderVM>(context); // by default, listen is true

    int number = 1;

    return KeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: focusNodeDialog,
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
        title: Text(
          AppLocalizations.of(context)!.helpDialogTitle,
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
        actionsPadding: kDialogActionsPadding,
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              for (HelpItem helpItem in helpItemsLst) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          (helpItem.displayHelpItemNumber)
                              ? "${number++}. ${helpItem.helpTitle}"
                              : helpItem.helpTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(helpItem.helpContent),
                ),
              ],
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            key: const Key('audio_help_close_button_key'),
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

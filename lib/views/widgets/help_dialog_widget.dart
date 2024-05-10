import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/help_item.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../screen_mixin.dart';

class HelpDialogWidget extends StatelessWidget with ScreenMixin {
  final List<HelpItem> helpItemsLst;
  final FocusNode focusNodeDialog = FocusNode();

  HelpDialogWidget({
    super.key,
    required this.helpItemsLst,
  });

  @override
  Widget build(BuildContext context) {
    // Required so that clicking on Enter closes the dialog
    FocusScope.of(context).requestFocus(
      focusNodeDialog,
    );

    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);

    int number = 1;
    int helpItemsLstLength = helpItemsLst.length;

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
        title: Text(AppLocalizations.of(context)!.helpDialogTitle),
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
                          (helpItemsLstLength > 1)
                              ? "${number++}. ${helpItem.helpTitle}"
                              : "${helpItem.helpTitle}",
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
            key: const Key('audioInfoOkButtonKey'),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../views/screen_mixin.dart';
import '../../constants.dart';
import '../../models/audio.dart';
import '../../services/settings_data_service.dart';
import '../../utils/ui_util.dart';
import '../../viewmodels/audio_download_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';

class SetValueToTargetDialogWidget extends StatefulWidget {
  final String dialogTitle;
  final String dialogCommentStr;
  final String passedValueStr;
  final String passedValueFieldLabel;
  final List<String> targetNamesLst;
  final bool isTargetExclusive;
  final bool isPassedValueEditable;

  const SetValueToTargetDialogWidget({
    required this.dialogTitle,
    required this.dialogCommentStr,
    required this.passedValueFieldLabel,
    required this.passedValueStr,
    required this.targetNamesLst,
    this.isTargetExclusive = true,
    this.isPassedValueEditable = true,
    super.key,
  });

  @override
  State<SetValueToTargetDialogWidget> createState() =>
      _SetValueToTargetDialogWidgetState();
}

class _SetValueToTargetDialogWidgetState
    extends State<SetValueToTargetDialogWidget> with ScreenMixin {
  final TextEditingController _passedValueTextEditingController =
      TextEditingController();
  final FocusNode _focusNodeDialog = FocusNode();
  final FocusNode _focusNodePassedValueTextField = FocusNode();
  final List<bool> _isCheckboxChecked = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _passedValueTextEditingController.text = widget.passedValueStr;
      for (int i = 0; i < widget.targetNamesLst.length; i++) {
        _isCheckboxChecked.add(false);
      }
    });
  }

  @override
  void dispose() {
    _passedValueTextEditingController.dispose();
    _focusNodeDialog.dispose();
    _focusNodePassedValueTextField.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);

    FocusScope.of(context).requestFocus(
      _focusNodePassedValueTextField,
    );

    return KeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: _focusNodeDialog,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // executing the same code as in the 'Rename'
            // TextButton onPressed callback
            Navigator.of(context).pop();
          }
        }
      },
      child: AlertDialog(
        title: Text(
          key: const Key('setValueToTargetDialogTitleKey'),
          widget.dialogTitle,
        ),
        actionsPadding: kDialogActionsPadding,
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              createTitleCommentRowFunction(
                titleTextWidgetKey: const Key('setValueToTargetDialogKey'),
                context: context,
                commentStr: widget.dialogCommentStr,
              ),
              createEditableRowFunction(
                valueTextFieldWidgetKey: const Key('passedValueFieldTextField'),
                context: context,
                label: widget.passedValueFieldLabel,
                controller: _passedValueTextEditingController,
                textFieldFocusNode: _focusNodePassedValueTextField,
              ),
              _createCheckboxColumn(context),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('okButton'),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Ok',
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
          ),
          TextButton(
            key: const Key('cancelButton'),
            onPressed: () {
              Navigator.of(context).pop();
            },
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

  Column _createCheckboxColumn(BuildContext context) {
    List<Widget> checkBoxes = [];
    int i = 0;
    for (String targetName in widget.targetNamesLst) {
      checkBoxes.add(
          createCheckboxRowFunction(
            checkBoxWidgetKey: Key('checkbox${i}Key'),
            context: context,
            label: targetName,
            value: _isCheckboxChecked[i],
            onChangedFunction: (bool? value) {
              setState(() {
                _isCheckboxChecked[i++] = value ?? false;
              });
            },
          ),
      );
    }

    return Column(
      children: checkBoxes,
    );
  }
}

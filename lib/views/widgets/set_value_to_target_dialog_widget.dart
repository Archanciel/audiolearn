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

  // If isTargetExclusive is true, only one checkbox can be selected.
  // If isTargetExclusive is false, multiple checkboxes can be selected.
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

    for (int i = 0; i < widget.targetNamesLst.length; i++) {
      _isCheckboxChecked.add(false);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _passedValueTextEditingController.text = widget.passedValueStr;
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
      focusNode: _focusNodeDialog,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            createTitleCommentRowFunction(
              titleTextWidgetKey: const Key('setValueToTargetDialogKey'),
              context: context,
              commentStr: widget.dialogCommentStr,
            ),
            const SizedBox(height: 10),
            (widget.isPassedValueEditable)
                ? createEditableRowFunction(
                    valueTextFieldWidgetKey:
                        const Key('passedValueFieldTextField'),
                    context: context,
                    label: widget.passedValueFieldLabel,
                    controller: _passedValueTextEditingController,
                    textFieldFocusNode: _focusNodePassedValueTextField,
                  )
                : createInfoRowFunction(
                    context: context,
                    label: '',
                    value: widget.passedValueFieldLabel,
                  ),
            const SizedBox(height: 10),
            _createCheckboxList(context),
          ],
        ),
        actions: [
          TextButton(
            key: const Key('okButton'),
            onPressed: () {
              List<String> resultLst = [
                _passedValueTextEditingController.text,
              ];
              for (int i = 0; i < _isCheckboxChecked.length; i++) {
                if (_isCheckboxChecked[i]) {
                  resultLst.add(i.toString());
                }
              }
              Navigator.of(context).pop(resultLst);
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

  Widget _createCheckboxList(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(
        widget.targetNamesLst.length,
        (int index) {
          return createCheckboxRowFunction(
            checkBoxWidgetKey: Key('checkbox${index}Key'),
            context: context,
            label: widget.targetNamesLst[index],
            value: _isCheckboxChecked[index],
            onChangedFunction: (bool? value) {
              setState(() {
                if (value != null && value && widget.isTargetExclusive) {
                  for (int i = 0; i < _isCheckboxChecked.length; i++) {
                    _isCheckboxChecked[i] = false;
                  }
                }
                _isCheckboxChecked[index] = value ?? false;
              });
            },
          );
        },
      ),
    );
  }
}

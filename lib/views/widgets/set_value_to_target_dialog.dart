import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/warning_message_vm.dart';
import '../../views/screen_mixin.dart';
import '../../constants.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';

enum InvalidValueState {
  none,
  tooBig,
  tooSmall,
}

class SetValueToTargetDialog extends StatefulWidget {
  final String dialogTitle;
  final String dialogCommentStr;
  final String passedValueStr;
  final String passedValueFieldLabel;
  final List<String> targetNamesLst;

  // If isTargetExclusive is true, only one checkbox can be selected.
  // If isTargetExclusive is false, multiple checkboxes can be selected.
  final bool isTargetExclusive;

  final bool isPassedValueEditable;

  final Function
      validationFunction; // The action to execute to validate the entered value
  final List<dynamic>
      validationFunctionArgs; // Arguments for the validation function

  const SetValueToTargetDialog({
    super.key,
    required this.dialogTitle,
    required this.dialogCommentStr,
    required this.passedValueFieldLabel,
    required this.passedValueStr,
    required this.targetNamesLst,
    required this.validationFunction,
    required this.validationFunctionArgs,
    this.isTargetExclusive = true,
    this.isPassedValueEditable = true,
  });

  @override
  State<SetValueToTargetDialog> createState() => _SetValueToTargetDialogState();
}

class _SetValueToTargetDialogState extends State<SetValueToTargetDialog>
    with ScreenMixin {
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
    final ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);

    FocusScope.of(context).requestFocus(
      _focusNodePassedValueTextField,
    );

    return KeyboardListener(
      focusNode: _focusNodeDialog,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            List<String> resultLst = _createResultList();

            if (resultLst.isEmpty) {
              return;
            }

            Navigator.of(context).pop(resultLst);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
        ),
        actions: [
          TextButton(
            key: const Key('setValueToTargetOkButton'),
            onPressed: () {
              List<String> resultLst = _createResultList();

              if (resultLst.isEmpty) {
                return;
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
            key: const Key('setValueToTargetCancelButton'),
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

  /// Validates the entered value and the selected checkboxes and creates
  /// the list of the entered value and the selected checkbox(es).
  List<String> _createResultList() {
    String enteredStr = _passedValueTextEditingController.text;

    widget.validationFunctionArgs.add(enteredStr);

    // Example of applied validation function:
    // InvalidValueState validateEnteredValueFunction(
    //                      String minDurationStr,
    //                      String maxDurationStr,
    //                      String enteredTimeStr,
    //                   )
    //
    // Initially, the List<dynamic> widget.validationFunctionArgs contains
    // two element, the minimal an maximal acceptable duration. The third
    // element, the entered value, is added in the line above.
    InvalidValueState invalidValueState = Function.apply(
      widget.validationFunction,
      widget.validationFunctionArgs,
    );

    // Once the validation function has been applied, the entered value
    // must be removed from the list of arguments, otherwise, the next
    // time the validation function will be applied, it will fail.
    widget.validationFunctionArgs.removeLast();

    if (invalidValueState != InvalidValueState.none) {
      WarningMessageVM warningMessageVM = Provider.of<WarningMessageVM>(
        context,
        listen: false,
      );

      String minValueLimitStr = widget.validationFunctionArgs[0].toString();

      String maxValueLimitStr = widget.validationFunctionArgs[1].toString();

      switch (invalidValueState) {
        case InvalidValueState.tooBig:
          warningMessageVM.setInvalidValueWarning(
            invalidValueState: invalidValueState,
            maxOrMinValueLimitStr: maxValueLimitStr,
          );

          _passedValueTextEditingController.text = maxValueLimitStr;

          return [];
        case InvalidValueState.tooSmall:
          warningMessageVM.setInvalidValueWarning(
            invalidValueState: invalidValueState,
            maxOrMinValueLimitStr: minValueLimitStr,
          );

          _passedValueTextEditingController.text = minValueLimitStr;

          return [];
        default:
          break;
      }

      return [];
    }

    List<String> resultLst = [
      enteredStr,
    ];

    bool isAnyCheckboxChecked = false;

    for (int i = 0; i < _isCheckboxChecked.length; i++) {
      if (_isCheckboxChecked[i]) {
        resultLst.add(i.toString());
        isAnyCheckboxChecked = true;
      }
    }

    if (!isAnyCheckboxChecked) {
      WarningMessageVM warningMessageVM = Provider.of<WarningMessageVM>(
        context,
        listen: false,
      );

      warningMessageVM.setNoCheckboxSelected(
        addAtListToWarningMessage: !widget.isTargetExclusive,
      );

      // the dialog is not closed
      return [];
    }

    return resultLst;
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/help_item.dart';
import '../../viewmodels/warning_message_vm.dart';
import '../../views/screen_mixin.dart';
import '../../constants.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';
import 'help_dialog.dart';

enum InvalidValueState {
  none,
  tooBig,
  tooSmall,
}

/// A dialog that allows the user to enter a value and select one or more
/// checkboxes which define to which target the entered value will be set.
class SetValueToTargetDialog extends StatefulWidget {
  final String dialogTitle;
  final String dialogCommentStr;
  final String passedValueStr;
  final String passedValueFieldLabel;
  final String passedValueFieldTooltip;
  final List<String> targetNamesLst;
  final List<HelpItem> helpItemsLst;

  // If isTargetExclusive is true, only one checkbox can be selected.
  // If isTargetExclusive is false, multiple checkboxes can be selected.
  final bool isTargetExclusive;

  final int checkboxIndexSetToTrue; // The index of the checkbox set to true
  final bool isPassedValueEditable;

  final Function
      validationFunction; // The action to execute to validate the entered value
  final List<dynamic>
      validationFunctionArgs; // Arguments for the validation function
  final bool canUniqueCheckBoxBeUnchecked;

  /// If the [passedValueFieldLabel] and the [passedValueStr] are not passed and so
  /// remains both empty, the dialog will not display the passed value field.
  ///
  /// The [targetNamesLst] contains the names of the checkboxes that will be displayed.
  ///
  /// If the [isTargetExclusive] is set to true, only one checkbox can be selected.
  /// If the [isTargetExclusive] is set to false, multiple checkboxes can be selected.
  ///
  /// In order to pre-select a checkbox, the [checkboxIndexSetToTrue] must be set to the
  /// index of the checkbox that should be selected.
  ///
  /// If [helpItemsLst] is passed to the dialog constructor, a help icon is
  /// displayed in the dialog title. Clicking on the help icon opens a dialog
  /// witch displays the help content contained in the help items.
  const SetValueToTargetDialog({
    super.key,
    required this.dialogTitle,
    required this.dialogCommentStr,
    this.passedValueFieldLabel = '',
    this.passedValueFieldTooltip = '',
    this.passedValueStr = '',
    required this.targetNamesLst,
    required this.validationFunction,
    required this.validationFunctionArgs,
    this.isTargetExclusive = true,
    this.checkboxIndexSetToTrue = -1,
    this.isPassedValueEditable = true,
    this.canUniqueCheckBoxBeUnchecked = false,
    this.helpItemsLst = const [],
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
      if (i == widget.checkboxIndexSetToTrue) {
        _isCheckboxChecked.add(true);
      } else {
        _isCheckboxChecked.add(false);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _passedValueTextEditingController.text = widget.passedValueStr;
      
      // Ensure focus after dialog is fully built
      if (widget.passedValueFieldLabel.isNotEmpty &&
          widget.passedValueStr.isNotEmpty) {
        _focusNodePassedValueTextField.requestFocus();
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
    final ThemeProviderVM themeProviderVM =
        Provider.of<ThemeProviderVM>(context); // by default, listen is true

    // Immediate focus request during build
    FocusScope.of(context).requestFocus(
      _focusNodePassedValueTextField,
    );

    return KeyboardListener(
      focusNode: _focusNodeDialog,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            executeFinalOperation(context);
          }
        }
      },
      child: AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                key: const Key('setValueToTargetDialogTitleKey'),
                widget.dialogTitle,
                style: Theme.of(context).textTheme.headlineSmall,
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
              (widget.passedValueFieldLabel.isNotEmpty &&
                      widget.passedValueStr.isNotEmpty)
                  ? (widget.isPassedValueEditable)
                      ? createEditableRowFunction(
                          context: context,
                          valueTextFieldWidgetKey:
                              const Key('passedValueFieldTextField'),
                          label: widget.passedValueFieldLabel,
                          labelAndTextFieldTooltip:
                              widget.passedValueFieldTooltip,
                          controller: _passedValueTextEditingController,
                          textFieldFocusNode: _focusNodePassedValueTextField,
                        )
                      : createInfoRowFunction(
                          context: context,
                          label: '',
                          value: widget.passedValueFieldLabel,
                          addSizeBoxBeforeAndAfter: true,
                        )
                  : SizedBox.shrink(),
              _createCheckboxList(context),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('setValueToTargetOkButton'),
            onPressed: () {
              executeFinalOperation(context);
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

  void executeFinalOperation(BuildContext context) {
    List<String> resultLst = _createResultList();

    if (resultLst.isEmpty && !widget.canUniqueCheckBoxBeUnchecked) {
      return;
    }

    Navigator.of(context).pop(resultLst);
  }

  /// Validates the entered value and the selected checkboxes and creates
  /// the list of the entered value and the selected checkbox(es).
  List<String> _createResultList() {
    if (widget.passedValueFieldLabel.isEmpty && widget.passedValueStr.isEmpty) {
      // No passed value field, so no need to validate it
      return _isCheckboxChecked
          .asMap()
          .entries
          .where((entry) => entry.value)
          .map((entry) => entry.key.toString())
          .toList();
    }

    String enteredStr = _passedValueTextEditingController.text;
    String minValueLimitStr = widget.validationFunctionArgs[0].toString();
    String maxValueLimitStr;

    if (_isCheckboxChecked[0]) {
      maxValueLimitStr = widget.validationFunctionArgs[1].toString();
    } else {
      maxValueLimitStr = widget.validationFunctionArgs[2].toString();
    }

    // The code below simplifies setting the comment start position
    // to 0 or the comment end position to audio duration.
    if (enteredStr.isEmpty) {
      if (_isCheckboxChecked[0] == true) {
        enteredStr = minValueLimitStr;
      } else if (_isCheckboxChecked[1] == true) {
        enteredStr = maxValueLimitStr;
      } else {
        // Avoiding the empty string to avoid an exception
        enteredStr = '0';
      }
    }

    widget.validationFunctionArgs.add(enteredStr);
    widget.validationFunctionArgs.add(_isCheckboxChecked[0]);

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

    // Once the validation function has been applied, the 2 entered values
    // must be removed from the list of arguments, otherwise, the next
    // time the validation function will be applied, it will fail.
    widget.validationFunctionArgs.length -= 2;

    if (invalidValueState != InvalidValueState.none) {
      WarningMessageVM warningMessageVM = Provider.of<WarningMessageVM>(
        context,
        listen: false,
      );

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
            checkBoxWidgetKey: Key('checkbox_${index}_key'),
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

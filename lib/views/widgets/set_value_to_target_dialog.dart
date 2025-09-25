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
  positionTooBig,
  positionTooSmall,
  dateFormatInvalid,
  enteredDateEmpty,
}

/// A dialog that allows the user to enter a value and select one or more
/// checkboxes which define to which target the entered value will be set.
class SetValueToTargetDialog extends StatefulWidget {
  final String dialogTitle;
  final String dialogCommentStr;
  final String passedValueStr;
  final String passedValueFieldLabel;
  final String passedValueFieldTooltip;
  final List<String> checkboxLabelLst;
  final List<HelpItem> helpItemsLst;

  // If isTargetExclusive is true, only one checkbox can be selected.
  // If isTargetExclusive is false, multiple checkboxes can be selected.
  final bool isTargetExclusive;

  final int checkboxIndexSetToTrue; // The index of the checkbox set to true
  final bool isPassedValueEditable;

  final Function?
      validationFunction; // The action to execute to validate the entered value
  final List<dynamic>
      validationFunctionArgs; // Arguments for the validation function
  final bool canAllCheckBoxBeUnchecked;
  final bool isCursorAtStart; // If true, the cursor is at the start of the
  //                             TextField containing the passed value.
  final bool isValueStringUsed; // Indicates if the passed value field is used.
  //                               Is used to determine if clicking on Enter
  //                               should close the dialog or not.

  /// If the [passedValueFieldLabel] and the [passedValueStr] are not passed and so
  /// remains both empty, the dialog will not display the passed value field.
  ///
  /// The [checkboxLabelLst] contains the names of the checkboxes that will be displayed.
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
  SetValueToTargetDialog({
    super.key,
    required this.dialogTitle,
    required this.dialogCommentStr,
    this.passedValueFieldLabel = '',
    this.passedValueFieldTooltip = '',
    this.passedValueStr = '',
    required this.checkboxLabelLst,
    this.validationFunction,
    required this.validationFunctionArgs,
    this.isTargetExclusive = true,
    this.checkboxIndexSetToTrue = -1,
    this.isPassedValueEditable = true,
    this.canAllCheckBoxBeUnchecked = false,
    this.isCursorAtStart = false,
    this.helpItemsLst = const [],
  }) : isValueStringUsed =
            passedValueFieldLabel.isNotEmpty && passedValueStr.isNotEmpty;

  @override
  State<SetValueToTargetDialog> createState() => _SetValueToTargetDialogState();
}

class _SetValueToTargetDialogState extends State<SetValueToTargetDialog>
    with ScreenMixin {
  final TextEditingController _passedValueTextEditingController =
      TextEditingController();
  final FocusNode _focusNodeDialog = FocusNode();
  final FocusNode _focusNodePassedValueTextField = FocusNode();
  final List<bool> _checkboxesLst = [];
  InvalidValueState _invalidValueState = InvalidValueState.none;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < widget.checkboxLabelLst.length; i++) {
      if (i == widget.checkboxIndexSetToTrue) {
        _checkboxesLst.add(true);
      } else {
        _checkboxesLst.add(false);
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

    if (widget.isValueStringUsed) {
      // Immediate focus request during build
      FocusScope.of(context).requestFocus(
        _focusNodePassedValueTextField,
      );
    } else {
      // Required so that clicking on Enter closes the dialog
      FocusScope.of(context).requestFocus(
        _focusNodeDialog,
      );
    }

    return KeyboardListener(
      focusNode: _focusNodeDialog,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            _executeFinalOperation(context);
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
                          isCursorAtStart: widget.isCursorAtStart,
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
              _executeFinalOperation(context);
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

  void _executeFinalOperation(BuildContext context) {
    List<String> resultLst = _createResultList();

    if (resultLst.isEmpty && !widget.canAllCheckBoxBeUnchecked) {
      // The case if the user did not check any checkbox
      WarningMessageVM warningMessageVM = Provider.of<WarningMessageVM>(
        context,
        listen: false,
      );

      warningMessageVM.setNoCheckboxSelected(
        addAtListToWarningMessage: !widget.isTargetExclusive,
      );

      return; // the SetValueToTargetDialog is not closed
    } else if (widget.checkboxLabelLst.isNotEmpty &&
        resultLst.length == 1 &&
        resultLst[0] == "") { // [""] is returned in case of invalid value
        //                       detected in the _createResultList() method.
      // The case if the SetValueToTargetDialog has checkbox and
      // if the entered value was defined as invalid in the
      // _createResultList() method.
      //
      // The widget.checkboxLabelLst.isNotEmpty test is necessary,
      // otherwise, if the dialog has no checkbox, if the entered
      // value is invalid, no warning will be displayed. The case
      // in the functionality of defining a date with invalid format
      // when saving the audio MP3 to zip file.

      return; // the SetValueToTargetDialog is not closed
    } else if (_invalidValueState == InvalidValueState.dateFormatInvalid ||
        _invalidValueState == InvalidValueState.enteredDateEmpty) {
      // The case if the entered date format was defined as invalid
      // in the _createResultList() method or is empty.

      return; // the SetValueToTargetDialog is not closed
    }

    Navigator.of(context)
        .pop(resultLst); // the SetValueToTargetDialog is closed
  }

  /// Validates the entered value and the selected checkboxes and creates
  /// the list of the entered value and the selected checkbox(es).
  List<String> _createResultList() {
    if (widget.passedValueFieldLabel.isEmpty && widget.passedValueStr.isEmpty) {
      // No passed value field, so no need to validate it
      return _checkboxesLst
          .asMap()
          .entries
          .where((entry) => entry.value) // checkbox is checked
          .map((entry) => entry.key.toString())
          .toList();
    }

    String enteredStr = _passedValueTextEditingController.text;
    String minValueLimitStr = '';
    String maxValueLimitStr = '';

    if (widget.validationFunctionArgs.isNotEmpty) {
      minValueLimitStr = widget.validationFunctionArgs[0].toString();
      if (_checkboxesLst.isEmpty) {
        maxValueLimitStr = minValueLimitStr;
      } else if (_checkboxesLst[0]) {
        maxValueLimitStr = widget.validationFunctionArgs[1].toString();
      } else {
        maxValueLimitStr = widget.validationFunctionArgs[2].toString();
      }
    }

    // The code below simplifies setting the comment start position
    // to 0 or the comment end position to audio duration.
    if (enteredStr.isEmpty && _checkboxesLst.isNotEmpty) {
      if (_checkboxesLst[0] == true) {
        enteredStr = minValueLimitStr;
      } else if (_checkboxesLst[1] == true) {
        enteredStr = maxValueLimitStr;
      } else {
        // Avoiding the empty string to avoid an exception
        enteredStr = '0';
      }
    }

    widget.validationFunctionArgs.add(enteredStr);

    if (_checkboxesLst.isNotEmpty) {
      widget.validationFunctionArgs.add(_checkboxesLst[0]);
    }

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

    _invalidValueState = InvalidValueState.none;

    if (widget.validationFunction != null) {
      _invalidValueState = Function.apply(
        widget.validationFunction!,
        widget.validationFunctionArgs,
      );

      if (_checkboxesLst.isNotEmpty) {
        // Remove the last added elements:
        // once the validation function has been applied, the 2 entered values
        // (enteredStr and _checkboxesLst[0] state) must be removed from the
        // list of arguments, otherwise, the next time the validation function
        // will be applied, it will fail.
        widget.validationFunctionArgs.length -= 2;
      } else {
        // Remove the enteredStr.
        widget.validationFunctionArgs.length -= 1;
      }
    }

    if (_invalidValueState != InvalidValueState.none) {
      WarningMessageVM warningMessageVM = Provider.of<WarningMessageVM>(
        context,
        listen: false,
      );

      switch (_invalidValueState) {
        case InvalidValueState.positionTooBig:
          warningMessageVM.setInvalidValueWarning(
            invalidValueState: _invalidValueState,
            maxOrMinValueLimitStr: maxValueLimitStr,
          );

          _passedValueTextEditingController.text = maxValueLimitStr;

          return [""];
        case InvalidValueState.positionTooSmall:
          warningMessageVM.setInvalidValueWarning(
            invalidValueState: _invalidValueState,
            maxOrMinValueLimitStr: minValueLimitStr,
          );

          _passedValueTextEditingController.text = minValueLimitStr;

          return [""];
        case InvalidValueState.dateFormatInvalid:
          warningMessageVM.setError(
            errorType: ErrorType.dateFormatError,
            errorArgOne: enteredStr,
          );

          _passedValueTextEditingController.text = enteredStr;

          return [""];
        case InvalidValueState.enteredDateEmpty:
          warningMessageVM.setError(
            errorType: ErrorType.enteredDateEmpty,
            errorArgOne: enteredStr,
          );

          _passedValueTextEditingController.text = enteredStr;

          return [""];
        default:
          break;
      }

      return [];
    }

    List<String> resultLst = [
      enteredStr,
    ];

    bool isAnyCheckboxChecked = false;

    for (int i = 0; i < _checkboxesLst.length; i++) {
      if (_checkboxesLst[i]) {
        resultLst.add(i.toString());
        isAnyCheckboxChecked = true;
      }
    }

    if (widget.checkboxLabelLst.isNotEmpty && !isAnyCheckboxChecked) {
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
        widget.checkboxLabelLst.length,
        (int index) {
          return createCheckboxRowFunction(
            checkBoxLabelKey: Key('checkboxLabel_${index}_key'),
            checkBoxWidgetKey: Key('checkbox_${index}_key'),
            context: context,
            label: widget.checkboxLabelLst[index],
            value: _checkboxesLst[index],
            onChangedFunction: (bool? value) {
              setState(() {
                if (value != null && value && widget.isTargetExclusive) {
                  for (int i = 0; i < _checkboxesLst.length; i++) {
                    _checkboxesLst[i] = false;
                  }
                }
                _checkboxesLst[index] = value ?? false;
              });
            },
          );
        },
      ),
    );
  }
}

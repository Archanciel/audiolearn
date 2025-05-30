import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../views/screen_mixin.dart';
import '../../constants.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/date_format_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';

/// This dialog is used to select a date format applied in the entire application.
/// The selected date format is saved in the application settings. The proposed
/// date formats are 'dd/MM/yyyy', 'MM/dd/yyyy' and 'yyyy-MM-dd'.
class DateFormatSelectionDialog extends StatefulWidget {
  const DateFormatSelectionDialog({
    super.key,
  });

  @override
  _DateFormatSelectionDialogState createState() =>
      _DateFormatSelectionDialogState();
}

class _DateFormatSelectionDialogState extends State<DateFormatSelectionDialog>
    with ScreenMixin {
  int _selectedIndex = 0;
  final FocusNode _focusNodeDialog = FocusNode();

  List<String> _nowDateFormatList = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      DateFormatVM dateFormatVM = Provider.of<DateFormatVM>(
        context,
        listen: false,
      );

      _selectedIndex = DateFormatVM.dateFormatLst.indexOf(
        dateFormatVM.selectedDateFormat,
      );

      DateTime now = DateTime.now();

      // It makes sense to display the date format after the current
      // formatted date. This is useful if the current date day is
      // equal to the current date month (e.g. 01/01/2024 !.
      _nowDateFormatList = [
        '${DateFormat(DateFormatVM.dateFormatLst[0]).format(now)}\n(${DateFormatVM.dateFormatLowCaseLst[0]})',
        '${DateFormat(DateFormatVM.dateFormatLst[1]).format(now)}\n(${DateFormatVM.dateFormatLowCaseLst[1]})',
        '${DateFormat(DateFormatVM.dateFormatLst[2]).format(now)}\n(${DateFormatVM.dateFormatLowCaseLst[2]})',
      ];
    });
  }

  @override
  void dispose() {
    _focusNodeDialog.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProviderVM themeProvider =
        Provider.of<ThemeProviderVM>(context); // by default, listen is true
    final DateFormatVM dateFormatVMlistenFalse = Provider.of<DateFormatVM>(
      context,
      listen: false,
    );

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
            // executing the same code as in the 'Confirm' ElevatedButton
            // onPressed callback
            _handleConfirmButtonPressed(
              dateFormatVMlistenFalse: dateFormatVMlistenFalse,
            );
          }
        }
      },
      child: AlertDialog(
        title: Text(
          key: const Key('dateFormatSelectionDialogTitleKey'),
          AppLocalizations.of(context)!.dateFormatSelectionDialogTitle,
        ),
        actionsPadding: kDialogActionsPadding,
        content: SizedBox(
          width: double.maxFinite,
          height: 190.0,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Use minimum space
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _nowDateFormatList.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return RadioListTile<int>(
                      title: Text(_nowDateFormatList[index]),
                      value: index,
                      groupValue: _selectedIndex,
                      onChanged: (value) {
                        setState(() {
                          _selectedIndex = value ?? 0;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          // situation of downloading a single video audio. This solves a
          // bug and is tested by 'Verifying with partial download of single
          // video audio' integration test
          TextButton(
            key: const Key('confirmButton'),
            onPressed: () {
              _handleConfirmButtonPressed(
                dateFormatVMlistenFalse: dateFormatVMlistenFalse,
              );
            },
            child: Text(AppLocalizations.of(context)!.confirmButton,
                style: (themeProvider.currentTheme == AppTheme.dark)
                    ? kTextButtonStyleDarkMode
                    : kTextButtonStyleLightMode),
          ),
          TextButton(
            key: const Key('cancelButton'),
            onPressed: () {
              // Fixes bug which happened when downloading a single
              // video audio and clicking on the cancel button of
              // the single selection playlist dialog. Without
              // this fix, the confirm dialog was displayed although
              // the user clicked on the cancel button.
              Navigator.of(context).pop("cancel");
            },
            child: Text(AppLocalizations.of(context)!.cancelButton,
                style: (themeProvider.currentTheme == AppTheme.dark)
                    ? kTextButtonStyleDarkMode
                    : kTextButtonStyleLightMode),
          ),
        ],
      ),
    );
  }

  void _handleConfirmButtonPressed({
    required DateFormatVM dateFormatVMlistenFalse,
  }) {
    dateFormatVMlistenFalse.selectDateFormat(
      dateFormatIndex: _selectedIndex,
    );

    Navigator.of(context).pop();
    return;
  }
}

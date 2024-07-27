import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chatGPT_warning_message_vm.dart';

class WarningMessageDisplayWidget extends StatelessWidget {
  final BuildContext _context;
  final WarningMessageVM _warningMessageVM;

  WarningMessageDisplayWidget({
    required BuildContext parentContext,
    required WarningMessageVM warningMessageVM,
    super.key,
  })  : _context = parentContext,
        _warningMessageVM = warningMessageVM;

  @override
  Widget build(BuildContext context) {
    _warningMessageVM.addListener(() {
      _showNextDialog(context);
    });

    return const SizedBox.shrink();
  }

  void _showNextDialog(BuildContext context) {
    final message = _warningMessageVM.getNextMessage();
    if (message.isNotEmpty) {
      _displayDialog(context, message);
    }
  }

  void _displayDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
              _warningMessageVM.messageDisplayed();
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../constants.dart';

/// This widget extends SnackBar and accept the String snackBar
/// content as constructor parameter.
///
/// Using AudioLearnSnackBar
///
/// final AudioLearnSnackBar snackBar =
///   AudioLearnSnackBar(message: 'Download at music quality');
/// ScaffoldMessenger.of(context).showSnackBar(snackBar);
class AudioLearnSnackBar extends SnackBar {
  AudioLearnSnackBar({
    super.key,
    required String message,
  }) : super(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
      backgroundColor: kButtonColor,
          duration: const Duration(milliseconds: 1500),
        );
}

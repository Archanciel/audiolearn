import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../views/screen_mixin.dart';

/// When the AudioExtractorView screen is displayed, the
/// AppBarTitleForAudioExtractorView is set in the AppBar title:
/// parameter.
class AppBarTitleForAudioExtractorView extends StatelessWidget
    with ScreenMixin {
  AppBarTitleForAudioExtractorView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // changing the build code to imitate working
    // chatgpt_main_draggable.dart does not eliminate
    // the error !
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            AppLocalizations.of(context)!.appBarTitleAudioExtractor,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17),
          ),
        ),
      ],
    );
  }
}

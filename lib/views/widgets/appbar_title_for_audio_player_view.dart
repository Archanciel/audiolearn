import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// When the AudioPlayerView screen is displayed, the AppBarTitleForAudioPlayerView
/// is displayed in the AppBar title:
class AppBarTitleForAudioPlayerView extends StatelessWidget {
  const AppBarTitleForAudioPlayerView({
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
            AppLocalizations.of(context)!.appBarTitleAudioPlayer,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17),
          ),
        ),
      ],
    );
  }
}

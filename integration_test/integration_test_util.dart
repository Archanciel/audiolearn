import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class IntegrationTestUtil {
  static Finder validateInkWellButton({
    required WidgetTester tester,
    String? audioTitle,
    String? inkWellButtonKey,
    required IconData expectedIcon,
    required Color expectedIconColor,
    required Color expectedIconBackgroundColor,
  }) {
    final Finder audioListTileInkWellFinder;

    if (inkWellButtonKey != null) {
      audioListTileInkWellFinder = find.byKey(Key(inkWellButtonKey));
    } else {
      audioListTileInkWellFinder = findAudioItemInkWellWidget(
        audioTitle!,
      );
    }

    // Find the Icon within the InkWell
    final Finder iconFinder = find.descendant(
      of: audioListTileInkWellFinder,
      matching: find.byType(Icon),
    );
    Icon iconWidget = tester.widget<Icon>(iconFinder);

    // Assert Icon type
    expect(iconWidget.icon, equals(expectedIcon));

    // Assert Icon color
    expect(iconWidget.color, equals(expectedIconColor));

    // Find the CircleAvatar within the InkWell
    final Finder circleAvatarFinder = find.descendant(
      of: audioListTileInkWellFinder,
      matching: find.byType(CircleAvatar),
    );
    CircleAvatar circleAvatarWidget =
        tester.widget<CircleAvatar>(circleAvatarFinder);

    // Assert CircleAvatar background color
    expect(circleAvatarWidget.backgroundColor,
        equals(expectedIconBackgroundColor));

    return audioListTileInkWellFinder;
  }

  static Finder findAudioItemInkWellWidget(String audioTitle) {
    // First, get the downloaded Audio item ListTile Text
    // widget finder
    final Finder audioListTileTextWidgetFinder = find.text(audioTitle);

    // Then obtain the downloaded Audio item ListTile
    // widget enclosing the Text widget by finding its ancestor
    final Finder audioListTileWidgetFinder = find.ancestor(
      of: audioListTileTextWidgetFinder,
      matching: find.byType(ListTile),
    );

    // Now find the InkWell widget located in the downloaded
    // Audio item ListTile
    final Finder audioListTileInkWellFinder = find.descendant(
      of: audioListTileWidgetFinder,
      matching: find.byKey(const Key("play_pause_audio_item_inkwell")),
    );

    return audioListTileInkWellFinder;
  }
}

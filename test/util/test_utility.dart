import 'package:audiolearn/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestUtility {
  static String getTestName() {
    return 'testName';
  }

  static void verifyWidgetIsEnabled({
    required WidgetTester tester,
    required String widgetKeyStr,
  }) {
    // Find the widget by its key
    final Finder widgetFinder = find.byKey(Key(widgetKeyStr));

    if (widgetFinder.evaluate().isEmpty) {
      // The case if playlists are not displayed or if no playlist
      // is selected. In this case, the widget is not found since
      // in place of up down button a sort filter parameters dropdown
      // button is displayed
      return;
    }

    // Retrieve the widget as a generic Widget
    final Widget widget = tester.widget(widgetFinder);

    // Check if the widget is enabled based on its type
    if (widget is IconButton) {
      expect(widget.onPressed, isNotNull,
          reason: 'IconButton should be enabled');
    } else if (widget is TextButton) {
      expect(widget.onPressed, isNotNull,
          reason: 'TextButton should be enabled');
    } else if (widget is Checkbox) {
      // For Checkbox, you can check if onChanged is null
      expect(widget.onChanged, isNotNull, reason: 'Checkbox should be enabled');
    } else if (widget is PopupMenuButton) {
      // For PopupMenuButton, check the enabled property
      expect(widget.enabled, isTrue,
          reason: 'PopupMenuButton should be enabled');
    } else if (widget is PopupMenuItem) {
      // For PopupMenuButton, check the enabled property
      expect(widget.enabled, isTrue, reason: 'PopupMenuItem should be enabled');
    } else {
      fail(
          'The widget with key $widgetKeyStr is not a recognized type for this test');
    }
  }

  static void verifyWidgetIsDisabled({
    required WidgetTester tester,
    required String widgetKeyStr,
  }) {
    // Find the widget by its key
    final Finder widgetFinder = find.byKey(Key(widgetKeyStr));

    if (widgetFinder.evaluate().isEmpty) {
      // The case if playlists are not displayed or if no playlist
      // is selected. In this case, the widget is not found since
      // in place of up down button a sort filter parameters dropdown
      // button is displayed
      return;
    }

    // Retrieve the widget as a generic Widget
    final Widget widget = tester.widget(widgetFinder);

    // Check if the widget is disabled based on its type
    if (widget is IconButton) {
      expect(widget.onPressed, isNull, reason: 'IconButton should be disabled');
    } else if (widget is TextButton) {
      expect(widget.onPressed, isNull, reason: 'TextButton should be disabled');
    } else if (widget is Checkbox) {
      // For Checkbox, you can check if onChanged is null
      expect(widget.onChanged, isNull, reason: 'Checkbox should be disabled');
    } else if (widget is PopupMenuButton) {
      // For PopupMenuButton, check the enabled property
      expect(widget.enabled, isFalse,
          reason: 'PopupMenuButton should be disabled');
    } else if (widget is PopupMenuItem) {
      // For PopupMenuButton, check the enabled property
      expect(widget.enabled, isFalse,
          reason: 'PopupMenuItem should be disabled');
    } else {
      fail(
          'The widget with key $widgetKeyStr is not a recognized type for this test');
    }
  }

  static void verifyIconButtonColor({
    required WidgetTester tester,
    required String widgetKeyStr,
    required bool isIconButtonEnabled,
  }) {
    // Find the widget by its key
    final Finder widgetFinder = find.byKey(Key(widgetKeyStr));

    if (widgetFinder.evaluate().isEmpty) {
      // The case if playlists are not displayed or if no playlist
      // is selected. In this case, the widget is not found since
      // in place of up down button a sort filter parameters dropdown
      // button is displayed
      return;
    }

    // Retrieve the icon of the IconButton
    final Icon icon = (tester.widget(widgetFinder) as IconButton).icon as Icon;

    // Check if the icon color is correct based on the enabled status
    if (isIconButtonEnabled) {
      expect(icon.color, kDarkAndLightEnabledIconColor,
          reason: 'IconButton color should be enabled color');
    } else {
      expect(icon.color, kDarkAndLightDisabledIconColor,
          reason: 'IconButton color should be disabled color');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../services/settings_data_service.dart';
import '../viewmodels/audio_player_vm.dart';
import '../viewmodels/theme_provider_vm.dart';
import '../viewmodels/warning_message_vm.dart';
import 'widgets/warning_message_display_widget.dart';

enum MultipleIconType {
  iconOne,
  iconTwo,
  iconThree,
}

// This global variable is initialized when instanciating the
// unique AudioGlobalPlayerVM instance. The reason why this
// variable is global is that it is used in the
// onPageChangedFunction which is set to the PageView widget
// responsible for handling screen dragging. It would not be
// possible to pass the AudioGlobalPlayerVM instance to the
// PageView widget since the onPageChangedFunction must have
// only an int parameter.
late AudioPlayerVM globalAudioPlayerVM;

mixin ScreenMixin {
  /// Returns the TextButton border based on the [currentTheme]
  /// currently applyed as well as the [isButtonEnabled]
  /// parameter value.
  MaterialStateProperty<RoundedRectangleBorder> getButtonRoundedShape({
    required AppTheme currentTheme,
    bool isButtonEnabled = true,
    BuildContext? context,
  }) {
    MaterialStateProperty<RoundedRectangleBorder> buttonRoundedShape =
        MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kRoundedButtonBorderRadius),
      side: BorderSide(
          color: (isButtonEnabled)
              ? (currentTheme == AppTheme.dark)
                  ? kSliderThumbColorInDarkMode
                  : kSliderThumbColorInLightMode
              : getTextInactiveColor(context!)),
    ));

    return buttonRoundedShape;
  }

  /// Returns the Text widget inactive color so that the
  /// TextButton border color is the same as the TextButton
  /// Text color if the TextButton is inactive.
  Color getTextInactiveColor(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    // Retrieve a color for inactive/disabled text
    return themeData.disabledColor; // or themeData.hintColor
  }

  static const double CHECKBOX_WIDTH_HEIGHT = 20.0;
  static const int PLAYLIST_DOWNLOAD_VIEW_DRAGGABLE_INDEX = 0;
  static const int AUDIO_PLAYER_VIEW_DRAGGABLE_INDEX = 1;
  static const int MEDIA_PLAYER_VIEW_DRAGGABLE_INDEX = 2;

  static const double screenIconSizeLightTheme = 30.0;
  static const double screenIconSizeDarkTheme = 29.0;
  static const double dialogCheckboxSizeBoxHeight = 15.0;

  // When clicking on TextButton, the color of the button is
  // changed shortly to the color defined in the following
  // property.
  final MaterialStateProperty<Color> textButtonTapModification =
      MaterialStateProperty.all(Colors.grey.withOpacity(0.6));

  // Defining custom icon themes for light theme
  final IconThemeData activeScreenIconLightTheme = const IconThemeData(
    color: kSliderThumbColorInLightMode,
    size: screenIconSizeLightTheme,
  );
  final IconThemeData inactiveScreenIconLightTheme = const IconThemeData(
    color: Colors.grey,
    size: screenIconSizeLightTheme,
  );

  // Defining custom icon themes for dark theme
  final IconThemeData activeScreenIconDarkTheme = const IconThemeData(
    color: kSliderThumbColorInDarkMode,
    size: screenIconSizeDarkTheme,
  );
  final IconThemeData inactiveScreenIconDarkTheme = const IconThemeData(
    color: Colors.grey,
    size: screenIconSizeDarkTheme,
  );
  final kDialogActionsPadding = const EdgeInsets.all(0);

  static ThemeData themeDataDark = ThemeData.dark().copyWith(
    colorScheme: ThemeData.dark().colorScheme.copyWith(
          background: Colors.black,
          surface: Colors.black,
        ),
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    iconTheme: ThemeData.dark().iconTheme.copyWith(
          color: kDarkAndLightEnabledIconColor, // Set icon color in dark mode
        ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kButtonColor, // Set button color in dark mode
        foregroundColor: Colors.white, // Set button text color in dark mode
      ),
    ),
    // WARNING: The following code does not work: all TextButton are
    // replaced by ElevatedButton. This is a bug in Flutter.
    // textButtonTheme: TextButtonThemeData(
    //   style: TextButton.styleFrom(
    //     backgroundColor: kButtonColor, // Set button color in dark mode
    //     foregroundColor: Colors.white, // Set button text color in dark mode
    //   ),
    // ),
    textTheme: ThemeData.dark().textTheme.copyWith(
          bodyMedium: ThemeData.dark()
              .textTheme
              .bodyMedium!
              .copyWith(color: Colors.white),
          titleMedium: ThemeData.dark()
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.white),
        ),
    checkboxTheme: ThemeData.dark().checkboxTheme.copyWith(
          checkColor: MaterialStateProperty.all(
            Colors.white, // Set Checkbox fill color
          ),
          fillColor: MaterialStateProperty.all(
            kDarkAndLightEnabledIconColor, // Set Checkbox check color
          ),
        ),
    // determines the background color and border of
    // TextField
    inputDecorationTheme: const InputDecorationTheme(
      // fillColor: Colors.grey[900],
      fillColor: Colors.black,
      filled: true,
      border: OutlineInputBorder(),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.white,
      selectionColor: Colors.white.withOpacity(0.3),
      selectionHandleColor: Colors.white.withOpacity(0.5),
    ),
  );

  static ThemeData themeDataLight = ThemeData.light().copyWith(
    colorScheme: ThemeData.light().colorScheme.copyWith(
          background: Colors.white,
          surface: Colors.white,
        ),
    primaryColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    iconTheme: ThemeData.light().iconTheme.copyWith(
          color: kDarkAndLightEnabledIconColor, // Set icon color in light mode
        ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kButtonColor, // Set button color in light mode
        foregroundColor: Colors.white, // Set button text color in light mode
      ),
    ),
    // WARNING: The following code does not work: all TextButton are
    // replaced by ElevatedButton. This is a bug in Flutter.
    // textButtonTheme: TextButtonThemeData(
    //   style: TextButton.styleFrom(
    //     backgroundColor: kButtonColor, // Set button color in light mode
    //     foregroundColor: Colors.white, // Set button text color in light mode
    //   ),
    // ),
    textTheme: ThemeData.light().textTheme.copyWith(
          bodyMedium: ThemeData.light()
              .textTheme
              .bodyMedium!
              .copyWith(color: kButtonColor),
          titleMedium: ThemeData.light()
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.black),
        ),
    checkboxTheme: ThemeData.light().checkboxTheme.copyWith(
          checkColor: MaterialStateProperty.all(
            Colors.white, // Set Checkbox fill color
          ),
          fillColor: MaterialStateProperty.all(
            kDarkAndLightEnabledIconColor, // Set Checkbox check color
          ),
        ),
    // determines the background color and border of
    // TextField
    inputDecorationTheme: const InputDecorationTheme(
      // fillColor: Colors.grey[900],
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.black,
      selectionColor: Colors.grey.withOpacity(0.3),
      selectionHandleColor: Colors.grey.withOpacity(0.5),
    ),
    // is required so that the icon color of the
    // ListTile items are correct. In dark mode, this
    // is specification is not required, I don't know why.
    listTileTheme: ThemeData.light().listTileTheme.copyWith(
          iconColor:
              kDarkAndLightEnabledIconColor, // Set icon color in light mode
        ),
    // Add any other customizations for light mode
  );

  /// Returns the icon theme data based on the theme currently applyed
  /// and the [MultipleIconType] enum value passed as parameter.
  ///
  /// The IconThemeData is used to wrap the icon widget.
  ///
  /// Example for the icon button:
  ///
  /// IconButton(
  ///   onPressed: () {
  ///   },
  ///   icon: IconTheme(
  ///     data: getIconThemeData(
  ///             themeProviderVM: themeProvider,
  ///             iconType: MultipleIconType.iconTwo,
  ///           ),
  ///     child: const Icon(Icons.download_outline, size: 35),
  ///   ),
  /// ),
  IconThemeData getIconThemeData({
    required ThemeProviderVM themeProviderVM,
    required MultipleIconType iconType,
  }) {
    switch (iconType) {
      case MultipleIconType.iconOne:
        return themeProviderVM.currentTheme == AppTheme.dark
            ? activeScreenIconDarkTheme
            : activeScreenIconLightTheme;
      case MultipleIconType.iconTwo:
        return themeProviderVM.currentTheme == AppTheme.dark
            ? inactiveScreenIconDarkTheme
            : inactiveScreenIconLightTheme;
      default:
        ThemeData currentTheme = themeProviderVM.currentTheme == AppTheme.dark
            ? themeDataDark
            : themeDataLight;
        return currentTheme.iconTheme; // Default icon theme
    }
  }

  /// Lightens a color by a given percentage [0-1]
  static Color lighten(Color color, double amount) {
    assert(amount >= 0 && amount <= 1, 'Amount should be between 0 and 1');
    int r = color.red + ((255 - color.red) * amount).toInt();
    int g = color.green + ((255 - color.green) * amount).toInt();
    int b = color.blue + ((255 - color.blue) * amount).toInt();
    return Color.fromARGB(color.alpha, r, g, b);
  }

  Future<void> openUrlInExternalApp({
    required String url,
  }) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $kYoutubeUrl';
    }
  }

  InputDecoration getDialogTextFieldInputDecoration({
    String hintText = '',
  }) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
    );
  }

  /// Create a comment displayed under the title of the dialog.
  Widget createTitleCommentRowFunction({
    Key? titleTextWidgetKey, // key set to the Text widget displaying the title
    required BuildContext context,
    required String commentStr,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            child: Text(
              key: titleTextWidgetKey,
              commentStr,
              style: kDialogTextFieldStyle,
            ),
            onTap: () {
              Clipboard.setData(
                ClipboardData(text: commentStr),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget createInfoRowFunction({
    Key? valueTextWidgetKey, // key set to the Text widget displaying the value
    required BuildContext context,
    required String label,
    required String value,
    bool isTextBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTextBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              child: Text(
                key: valueTextWidgetKey,
                value,
                style: TextStyle(
                  fontWeight: isTextBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Create a row with a label which can be a translated screen to which
  /// a value is passed as argument. Example:
  /// label: AppLocalizations.of(context)!
  ///                  .saveSortFilterOptionsToPlaylist(widget.playlistTitle),
  /// "saveSortFilterOptionsToPlaylist": "To playlist \"{title}\"",
  Widget createLabelRowFunction({
    Key? valueTextWidgetKey, // key set to the Text widget displaying the value
    required BuildContext context,
    required String label,
    bool isTextBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isTextBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: label),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget createEditableRowFunction({
    Key? valueTextFieldWidgetKey, // key set to the TextField widget
    // containing the value
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    FocusNode? textFieldFocusNode,
  }) {
    // Set the cursor position at the start of the TextField
    controller.value = controller.value.copyWith(
      selection: const TextSelection.collapsed(offset: 0),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: kDialogLabelStyle,
            ),
          ),
          Expanded(
            child: TextField(
              key: valueTextFieldWidgetKey,
              controller: controller,
              decoration: getDialogTextFieldInputDecoration(),
              focusNode: textFieldFocusNode,
            ),
          ),
        ],
      ),
    );
  }

  Widget createCheckboxRowFunction({
    Key? checkBoxWidgetKey, // key set to the CheckBox widget
    required BuildContext context,
    required String label,
    String labelTooltip = '',
    required bool value,
    required ValueChanged<bool?> onChangedFunction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          labelTooltip.isNotEmpty
              ? Tooltip(
                  message: labelTooltip,
                  child: Text(label),
                )
              : Text(label),
          Checkbox(
            key: checkBoxWidgetKey,
            value: value,
            onChanged: onChangedFunction,
          )
        ],
      ),
    );
  }

  /// This consumer<WarningMessageVM> must be installed on every
  /// view, otherwise the warning message will not be displayed
  /// on the view in which it was created.
  Consumer<WarningMessageVM> buildWarningMessageVMConsumer({
    required BuildContext context,
    TextEditingController? urlController,
  }) {
    return Consumer<WarningMessageVM>(
      builder: (context, warningMessageVM, child) {
        // displays a warning message each time the
        // warningMessageVM calls notifyListners(), which
        // happens when an other view model sets a warning
        // message on the warningMessageVM
        return WarningMessageDisplayWidget(
          warningMessageVM: warningMessageVM,
          parentContext: context,
          urlController: urlController, // required only for 2 warning types ...
        );
      },
    );
  }
}

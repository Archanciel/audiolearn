import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screen_mixin.dart';
import '../constants.dart';
import '../services/settings_data_service.dart';
import '../viewmodels/theme_provider_vm.dart';

class AudioExtractorView extends StatefulWidget {
  const AudioExtractorView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AudioExtractorViewState createState() => _AudioExtractorViewState();
}

class _AudioExtractorViewState extends State<AudioExtractorView>
    with ScreenMixin {
  final TextEditingController _startPositionTextEditingController =
      TextEditingController(text: '0:00:09');
  final TextEditingController _currentPositionTextEditingController =
      TextEditingController(text: '0:00:16');
  final TextEditingController _endPositionTextEditingController =
      TextEditingController(text: '0:00:18');
  double _currentSliderValue = 0;

  @override
  void dispose() {
    _startPositionTextEditingController.dispose();
    _currentPositionTextEditingController.dispose();
    _endPositionTextEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildWarningMessageVMConsumer(
            context: context,
          ),
          _buildExtractPositionDataLayout(),
          _buildModifyExtractPositionButtonsRow(),
          _buildAudioSlider(),
          _buildPlayStopButtonsRow(),
        ],
      ),
    );
  }

  Widget _buildExtractPositionDataLayout() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildPositionLabelAndIconButton(
              iconData: Icons.remove_circle_outline,
              onPressedFunction: () {},
            ),
            _buildPositionLabelAndIconButton(
              iconData: Icons.add_circle_outline,
              onPressedFunction: () {},
            ),
            _buildPositionLabelAndField(
              label: 'Start',
              controller: _startPositionTextEditingController,
            ),
            // Current Position Widgets
            _buildPositionLabelAndField(
              label: 'Current',
              controller: _currentPositionTextEditingController,
            ),
            // End Position Widgets
            _buildPositionLabelAndField(
              label: 'End',
              controller: _endPositionTextEditingController,
            ),
            _buildPositionLabelAndIconButton(
              iconData: Icons.remove_circle_outline,
              onPressedFunction: () {},
            ),
            _buildPositionLabelAndIconButton(
              iconData: Icons.add_circle_outline,
              onPressedFunction: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPositionLabelAndIconButton({
    required IconData iconData,
    required void Function() onPressedFunction,
  }) {
    return Column(
      children: [
        const Text(
          '',
          textAlign: TextAlign.center,
        ),
        IconButton(
          // Button to decrease extraction start time
          visualDensity: VisualDensity.compact,
          icon: Icon(
            iconData,
          ),
          iconSize: 20,
          onPressed: onPressedFunction,
        ),
      ],
    );
  }

  Widget _buildPositionLabelAndField({
    required String label,
    required TextEditingController controller,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
          ),
          TextField(
            controller: controller,
            textAlign: TextAlign.center,
            style: kAudioExtractorExtractPositionStyle,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 3.0,
                horizontal: 3,
              ),
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.blue, width: 2.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModifyExtractPositionButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.skip_previous),
          iconSize: 20.0,
          onPressed: () {/* Rewind action */},
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.fast_rewind),
          iconSize: 20.0,
          onPressed: () {/* Rewind action */},
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.copyright),
          iconSize: 18.0,
          onPressed: () {/* Rewind action */},
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.arrow_left),
          iconSize: 28.0,
          onPressed: () {/* Play action */},
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.arrow_right),
          iconSize: 28.0,
          onPressed: () {/* Play action */},
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.copyright),
          iconSize: 18.0,
          onPressed: () {/* Rewind action */},
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.fast_forward),
          iconSize: 20.0,
          onPressed: () {/* Fast forward action */},
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.skip_next),
          iconSize: 20.0,
          onPressed: () {/* Rewind action */},
        ),
      ],
    );
  }

  Widget _buildAudioSlider() {
    return SliderTheme(
      data: const SliderThemeData(
        trackHeight: kSliderThickness,
        thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: 6.0), // Adjust the radius as you need
      ),
      child: Slider(
        value: _currentSliderValue,
        min: 0,
        max: 100,
        divisions: 100,
        label: _currentSliderValue.round().toString(),
        onChanged: (double value) {
          setState(() {
            _currentSliderValue = value;
          });
        },
      ),
    );
  }

  Widget _buildPlayStopButtonsRow() {
    ThemeProviderVM themeProviderVM =
        Provider.of<ThemeProviderVM>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          // sets the rounded TextButton size improving the distance
          // between the button text and its boarder
          width: kSmallestButtonWidth + 3,
          height: kNormalButtonHeight,
          child: TextButton(
            style: ButtonStyle(
              shape: getButtonRoundedShape(
                currentTheme: themeProviderVM.currentTheme,
              ),
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(
                    horizontal: kSmallButtonInsidePadding, vertical: 0),
              ),
              overlayColor: textButtonTapModification, // Tap feedback color
            ),
            onPressed: () {/* Play action */},
            child: Text(
              'Play',
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
          ),
        ),
        const SizedBox(
          width: kRowSmallWidthSeparator,
        ),
        SizedBox(
          // sets the rounded TextButton size improving the distance
          // between the button text and its boarder
          width: kSmallestButtonWidth + 3,
          height: kNormalButtonHeight,
          child: TextButton(
            style: ButtonStyle(
              shape: getButtonRoundedShape(
                currentTheme: themeProviderVM.currentTheme,
              ),
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(
                  horizontal: kSmallButtonInsidePadding,
                  vertical: 0,
                ),
              ),
              overlayColor: textButtonTapModification, // Tap feedback color
            ),
            onPressed: () {/* Stop action */},
            child: Text(
              'Stop',
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
          ),
        ),
      ],
    );
  }
}

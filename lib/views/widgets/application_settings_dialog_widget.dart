import 'dart:io';

import 'package:audiolearn/models/help_item.dart';
import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/playlist_list_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/warning_message_vm.dart';
import '../../views/screen_mixin.dart';
import '../../constants.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';
import 'audio_set_speed_dialog_widget.dart';

class ApplicationSettingsDialogWidget extends StatefulWidget {
  final SettingsDataService settingsDataService;

  const ApplicationSettingsDialogWidget({
    required this.settingsDataService,
    super.key,
  });

  @override
  State<ApplicationSettingsDialogWidget> createState() =>
      _ApplicationSettingsDialogWidgetState();
}

class _ApplicationSettingsDialogWidgetState
    extends State<ApplicationSettingsDialogWidget> with ScreenMixin {
  final TextEditingController _playlistRootpathTextEditingController =
      TextEditingController();
  late double _audioPlaySpeed;
  bool _applyAudioPlaySpeedToExistingPlaylists = false;
  bool _applyAudioPlaySpeedToAlreadyDownloadedAudios = false;
  final FocusNode _focusNodeDialog = FocusNode();
  final FocusNode _focusNodePlaylistRootPath = FocusNode();
  late final List<HelpItem> _helpItemsLst;

  @override
  void initState() {
    super.initState();

    _audioPlaySpeed = widget.settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.playSpeed) ??
        1.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playlistRootpathTextEditingController.text = widget.settingsDataService
              .get(
                  settingType: SettingType.dataLocation,
                  settingSubType: DataLocation.playlistRootPath) ??
          '';

      // Setting cursor at the end of the text. Does not work !
      _playlistRootpathTextEditingController.selection =
          TextSelection.fromPosition(
        TextPosition(
          offset: _playlistRootpathTextEditingController.text.length,
        ),
      );

      _helpItemsLst = [
        HelpItem(
          helpTitle: AppLocalizations.of(context)!.defaultApplicationHelpTitle,
          helpContent:
              AppLocalizations.of(context)!.defaultApplicationHelpContent,
        ),
        HelpItem(
          helpTitle:
              AppLocalizations.of(context)!.modifyingExistingPlaylistsHelpTitle,
          helpContent: AppLocalizations.of(context)!
              .modifyingExistingPlaylistsHelpContent,
        ),
        HelpItem(
          helpTitle:
              AppLocalizations.of(context)!.alreadyDownloadedAudiosHelpTitle,
          helpContent:
              AppLocalizations.of(context)!.alreadyDownloadedAudiosHelpContent,
        ),
        HelpItem(
          helpTitle:
              AppLocalizations.of(context)!.excludingFutureDownloadsHelpTitle,
          helpContent:
              AppLocalizations.of(context)!.excludingFutureDownloadsHelpContent,
        ),
      ];
    });
  }

  @override
  void dispose() {
    _focusNodeDialog.dispose();
    _focusNodePlaylistRootPath.dispose();
    _playlistRootpathTextEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);

    FocusScope.of(context).requestFocus(
      _focusNodePlaylistRootPath,
    );

    return KeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: _focusNodeDialog,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // executing the same code as in the 'Save' TextButton
            // onPressed callback
            _handleSaveButton(context);
            Navigator.of(context).pop();
          }
        }
      },
      child: AlertDialog(
        title: Text(
          key: const Key('appSettingsDialogTitleKey'),
          AppLocalizations.of(context)!.appSettingsDialogTitle,
        ),
        actionsPadding: kDialogActionsPadding,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!
                            .setAudioPlaySpeedDialogTitle,
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 37,
                        child: _buildSetAudioSpeedTextButton(context),
                      ),
                    ),
                  ],
                ),
              ),
              createEditableRowFunction(
                valueTextFieldWidgetKey: const Key('playlistRootpathTextField'),
                context: context,
                label: AppLocalizations.of(context)!.playlistRootpathLabel,
                controller: _playlistRootpathTextEditingController,
                textFieldFocusNode: _focusNodePlaylistRootPath,
                isCursorAtStart: false,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('saveButton'),
            onPressed: () {
              _handleSaveButton(context);
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.saveButton,
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
          ),
          TextButton(
            key: const Key('cancelButton'),
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

  void _handleSaveButton(BuildContext context) {
    if (_applyAudioPlaySpeedToExistingPlaylists ||
        _applyAudioPlaySpeedToAlreadyDownloadedAudios) {
      Provider.of<PlaylistListVM>(
        context,
        listen: false,
      ).updateExistingPlaylistsAndOrAudiosPlaySpeed(
        audioPlaySpeed: _audioPlaySpeed,
        applyAudioPlaySpeedToExistingPlaylists:
            _applyAudioPlaySpeedToExistingPlaylists,
        applyAudioPlaySpeedToAlreadyDownloadedAudios:
            _applyAudioPlaySpeedToAlreadyDownloadedAudios,
      );
    }

    _updateAndSaveSettings(context);
  }

  void _updateAndSaveSettings(BuildContext context) {
    widget.settingsDataService.set(
        settingType: SettingType.playlists,
        settingSubType: Playlists.playSpeed,
        value: _audioPlaySpeed);

    String playlistRootPath = _playlistRootpathTextEditingController.text;
    final Directory directory = Directory(playlistRootPath);

    if (!directory.existsSync()) {
      Provider.of<WarningMessageVM>(
        context,
        listen: false,
      ).setPlaylistInexistingRootPath(
        playlistInexistingRootPath: playlistRootPath,
      );
      return;
    }

    widget.settingsDataService.set(
        settingType: SettingType.dataLocation,
        settingSubType: DataLocation.playlistRootPath,
        value: playlistRootPath);

    widget.settingsDataService.saveSettings();

    Provider.of<AudioDownloadVM>(
      context,
      listen: false,
    ).playlistsRootPath = playlistRootPath;

    Provider.of<PlaylistListVM>(
      context,
      listen: false,
    ).updateSettingsAndPlaylistJsonFiles();
  }

  Widget _buildSetAudioSpeedTextButton(
    BuildContext context,
  ) {
    return Consumer<ThemeProviderVM>(
      builder: (context, themeProviderVM, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              // sets the rounded TextButton size improving the distance
              // between the button text and its boarder
              width: kNormalButtonWidth - 18.0,
              height: kNormalButtonHeight,
              child: Tooltip(
                message: AppLocalizations.of(context)!.setAudioPlaySpeedTooltip,
                child: TextButton(
                  key: const Key('setAudioSpeedTextButton'),
                  style: ButtonStyle(
                    shape: getButtonRoundedShape(
                        currentTheme: themeProviderVM.currentTheme),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                          horizontal: kSmallButtonInsidePadding, vertical: 0),
                    ),
                    overlayColor:
                        textButtonTapModification, // Tap feedback color
                  ),
                  onPressed: () {
                    showDialog<List<dynamic>>(
                      context: context,
                      builder: (BuildContext context) {
                        return AudioSetSpeedDialogWidget(
                          audioPlaySpeed: _audioPlaySpeed,
                          updateCurrentPlayAudioSpeed: false,
                          displayApplyToExistingPlaylistCheckbox: true,
                          displayApplyToAudioAlreadyDownloadedCheckbox: true,
                          helpItemsLst: _helpItemsLst,
                        );
                      },
                    ).then((value) {
                      // not null value is boolean
                      if (value != null) {
                        // value is null if clicking on Cancel or if the dialog
                        // is dismissed by clicking outside the dialog.

                        _audioPlaySpeed = value[0] as double;
                        _applyAudioPlaySpeedToExistingPlaylists = value[1];
                        _applyAudioPlaySpeedToAlreadyDownloadedAudios =
                            value[2];

                        setState(() {}); // required, otherwise the TextButton
                        // text in the application settings dialog is not
                        // updated
                      }
                    });
                  },
                  child: Tooltip(
                    message:
                        AppLocalizations.of(context)!.setAudioPlaySpeedTooltip,
                    child: Text(
                      '${_audioPlaySpeed.toStringAsFixed(2)}x',
                      textAlign: TextAlign.center,
                      style: (themeProviderVM.currentTheme == AppTheme.dark)
                          ? kTextButtonStyleDarkMode
                          : kTextButtonStyleLightMode,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

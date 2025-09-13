import 'dart:io';

import 'package:audiolearn/models/help_item.dart';
import 'package:audiolearn/viewmodels/playlist_list_vm.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/warning_message_vm.dart';
import '../../views/screen_mixin.dart';
import '../../constants.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';
import 'audio_set_speed_dialog.dart';
import 'confirm_action_dialog.dart';

class ApplicationSettingsDialog extends StatefulWidget {
  final SettingsDataService settingsDataService;

  const ApplicationSettingsDialog({
    required this.settingsDataService,
    super.key,
  });

  @override
  State<ApplicationSettingsDialog> createState() =>
      _ApplicationSettingsDialogState();
}

class _ApplicationSettingsDialogState extends State<ApplicationSettingsDialog>
    with ScreenMixin {
  late double _audioPlaySpeed;
  bool _applyAudioPlaySpeedToExistingPlaylists = false;
  bool _applyAudioPlaySpeedToAlreadyDownloadedAudios = false;
  late final List<HelpItem> _helpItemsLst;
  String _applicationDialogPlaylistRootPath = '';
  final TextEditingController _mp3ZipFileSizeLimitInMbController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    // Obtaining the default audio play speed from the settings data service
    _audioPlaySpeed = widget.settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.playSpeed) ??
        1.0;

    _applicationDialogPlaylistRootPath = widget.settingsDataService.get(
            settingType: SettingType.dataLocation,
            settingSubType: DataLocation.playlistRootPath) ??
        '';

    _mp3ZipFileSizeLimitInMbController.text = widget.settingsDataService
            .get(
              settingType: SettingType.playlists,
              settingSubType: Playlists.maxSavableAudioMp3FileSizeInMb,
            )
            ?.toString() ??
        kMp3ZipFileSizeLimitInMb.toString();

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    _mp3ZipFileSizeLimitInMbController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProviderVM themeProviderVMlistenFalse =
        Provider.of<ThemeProviderVM>(
      context,
      listen: false,
    ); // by default, listen is true

    return Theme(
      data: themeProviderVMlistenFalse.currentTheme == AppTheme.dark
          ? ScreenMixin.themeDataDark
          : ScreenMixin.themeDataLight,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.appSettingsDialogTitle,
          ),
        ),
        body: Column(
          children: [
            // Content at the top
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.playlistRootpathLabel,
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 37,
                            child: _buildOpenDirectoryIconButton(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        _applicationDialogPlaylistRootPath,
                        key: const Key('playlistsRootPathText'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: createFlexibleEditableRowFunction(
                            context: context,
                            valueTextFieldWidgetKey:
                                const Key('mp3ZipFileSizeLimitInMb'),
                            label: AppLocalizations.of(context)!
                                .mp3ZipFileSizeLimitInMbLabel,
                            labelAndTextFieldTooltip:
                                AppLocalizations.of(context)!
                                    .mp3ZipFileSizeLimitInMbTooltip,
                            controller: _mp3ZipFileSizeLimitInMbController,
                            labelFlexValue: 4,
                            editableFieldFlexValue: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Spacer to push buttons to the bottom
            const Spacer(),
            // Save and Cancel buttons at the bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    key: const Key('saveButton'),
                    onPressed: () async {
                      await _handleSaveButton(context);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.saveButton,
                      style: (themeProviderVMlistenFalse.currentTheme ==
                              AppTheme.dark)
                          ? kTextButtonStyleDarkMode
                          : kTextButtonStyleLightMode,
                    ),
                  ),
                  const SizedBox(width: 16), // Space between the buttons
                  TextButton(
                    key: const Key('cancelButton'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.cancelButton,
                      style: (themeProviderVMlistenFalse.currentTheme ==
                              AppTheme.dark)
                          ? kTextButtonStyleDarkMode
                          : kTextButtonStyleLightMode,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSaveButton(BuildContext context) async {
    PlaylistListVM playlistListVMlistenFalse = Provider.of<PlaylistListVM>(
      context,
      listen: false,
    );

    // This method modifies also the playlist default play speed in
    // the application settings file and saves the file.
    playlistListVMlistenFalse
        .updateExistingPlaylistsAndOrAlreadyDownloadedAudioPlaySpeed(
      audioPlaySpeed: _audioPlaySpeed,
      applyAudioPlaySpeedToExistingPlaylists:
          _applyAudioPlaySpeedToExistingPlaylists,
      applyAudioPlaySpeedToAlreadyDownloadedAudio:
          _applyAudioPlaySpeedToAlreadyDownloadedAudios,
    );

    double? value = double.tryParse(_mp3ZipFileSizeLimitInMbController.text);

    if (value != null) {
      widget.settingsDataService.set(
          settingType: SettingType.playlists,
          settingSubType: Playlists.maxSavableAudioMp3FileSizeInMb,
          value: value);

      widget.settingsDataService.saveSettings();
    }

    // Updating the playlist root path in the application settings if
    // the path was changed and saving the playlists title order list in
    // the previous root path.

    String settingsDataServicePlaylistRootPath = widget.settingsDataService.get(
      settingType: SettingType.dataLocation,
      settingSubType: DataLocation.playlistRootPath,
    );

    String lastComponent = path.basename(_applicationDialogPlaylistRootPath);

    if (lastComponent != kImposedPlaylistsSubDirName) {
      // If the modified playlist directory name is invalid (must be 'playlists'), a warning
      // is displayed and return is performed, so that the modified playlist dir is ignored.
      Provider.of<WarningMessageVM>(
        context,
        listen: false,
      ).signalInvalidPlaylistRootDirName(
        playlistInvalidRootPath: _applicationDialogPlaylistRootPath,
        playlistInvalidRootName: lastComponent,
      );

      return;
    }

    if (settingsDataServicePlaylistRootPath ==
            _applicationDialogPlaylistRootPath ||
        _applicationDialogPlaylistRootPath.isEmpty) {
      // The modified playlist root path is identical to the
      // previous one or is empty.
      return;
    }

    final Directory directory = Directory(_applicationDialogPlaylistRootPath);

    if (!directory.existsSync()) {
      // If the modified playlist root path does not exist, a warning
      // is displayed and return is performed.
      Provider.of<WarningMessageVM>(
        context,
        listen: false,
      ).setPlaylistInexistingRootPath(
        playlistInexistingRootPath: _applicationDialogPlaylistRootPath,
      );

      return;
    }

    String playlistTitleOrderPathFileName =
        "$_applicationDialogPlaylistRootPath${path.separator}$kOrderedPlaylistTitlesFileName";
    final File file = File(playlistTitleOrderPathFileName);

    if (file.existsSync()) {
      final result = await showDialog<ConfirmAction>(
        // Add await and type
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ConfirmActionDialog(
            actionFunction: () => ConfirmActionDialog.choosenConfirmAction, // Return ConfirmAction
            actionFunctionArgs: [],
            dialogTitleOne:
                AppLocalizations.of(context)!.restorePlaylistTitlesOrderTitle,
            dialogContent:
                AppLocalizations.of(context)!.restorePlaylistTitlesOrderMessage,
          );
        },
      );

      // Handle the result after dialog closes
      if (result == ConfirmAction.confirm) {
        playlistListVMlistenFalse
            .updatePlaylistRootPathAndSavePlaylistTitleOrder(
          actualPlaylistRootPath: settingsDataServicePlaylistRootPath,
          modifiedPlaylistRootPath: _applicationDialogPlaylistRootPath,
          playlistTitleOrderPathFileName: playlistTitleOrderPathFileName,
        );
      } else {
        // Cancel or null result
        playlistListVMlistenFalse
            .updatePlaylistRootPathAndSavePlaylistTitleOrder(
          actualPlaylistRootPath: settingsDataServicePlaylistRootPath,
          modifiedPlaylistRootPath: _applicationDialogPlaylistRootPath,
          playlistTitleOrderPathFileName: '', // empty string means do not restore the
          //                                     previously saved playlist title order
          //                                     since the Cancel button was clicked
        );
      }
      // If result == ConfirmAction.cancel or null, do nothing
    } else {
      playlistListVMlistenFalse.updatePlaylistRootPathAndSavePlaylistTitleOrder(
        actualPlaylistRootPath: settingsDataServicePlaylistRootPath,
        modifiedPlaylistRootPath: _applicationDialogPlaylistRootPath,
        playlistTitleOrderPathFileName: '', // empty string means do not restore the
        //                                     previously saved playlist title order
        //                                     which does not exist
      );
    }
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
              child: TextButton(
                key: const Key('setAudioSpeedTextButton'),
                style: ButtonStyle(
                  shape: getButtonRoundedShape(
                      currentTheme: themeProviderVM.currentTheme),
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(
                        horizontal: kSmallButtonInsidePadding, vertical: 0),
                  ),
                  overlayColor: textButtonTapModification, // Tap feedback color
                ),
                onPressed: () {
                  showDialog<List<dynamic>>(
                    context: context,
                    builder: (BuildContext context) {
                      return AudioSetSpeedDialog(
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
                      // value is null if clicking on Cancel

                      _audioPlaySpeed = value[0] as double;
                      _applyAudioPlaySpeedToExistingPlaylists = value[1];
                      _applyAudioPlaySpeedToAlreadyDownloadedAudios = value[2];

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
          ],
        );
      },
    );
  }

  Widget _buildOpenDirectoryIconButton(
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
              width: kNormalButtonWidth,
              height: kNormalButtonHeight,
              child: IconButton(
                iconSize: 30,
                key: const Key('openDirectoryIconButton'),
                style: ButtonStyle(
                  // Highlight button when pressed
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(
                        horizontal: kSmallButtonInsidePadding, vertical: 0),
                  ),
                  overlayColor: iconButtonTapModification, // Tap feedback color
                ),
                onPressed: () async {
                  String? selectedDir = await _filePickerSelectDirectory();

                  if (selectedDir != null) {
                    _applicationDialogPlaylistRootPath = selectedDir;
                  }

                  setState(() {}); // required, otherwise the TextButton
                },
                icon: Icon(
                  Icons.folder_open,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _filePickerSelectDirectory() async {
    // Pick a single directory
    String? directoryPath = await FilePicker.platform.getDirectoryPath(
      initialDirectory: widget.settingsDataService.get(
              settingType: SettingType.dataLocation,
              settingSubType: DataLocation.playlistRootPath) ??
          '',
    );

    // Return the selected directory path or null if no selection
    return directoryPath;
  }
}

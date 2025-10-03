import 'package:audiolearn/utils/duration_expansion.dart';
import 'package:audiolearn/views/widgets/set_value_to_target_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/help_item.dart';
import '../../models/playlist.dart';
import '../../constants.dart';
import '../../services/settings_data_service.dart';
import '../../utils/dir_util.dart';
import '../../utils/ui_util.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../../viewmodels/warning_message_vm.dart';
import '../screen_mixin.dart';
import 'help_dialog.dart';

// Used to determine the title of the warning dialog: 'WARNING' or 'CONFIRM'
enum WarningMode {
  warning,
  confirm,
}

/// This widget is used to display warning messages to the user.
/// It is created each time a warning message is set to the
/// [WarningMessageVM] class.
///
/// The warning messages are displayed as a dialog whose content
/// depends on the type of the warning message set to the
/// WarningMessageVM.
///
/// In case of multiple warnings, the WarningMessageDisplayWidget is
/// added as listener of [WarningMessageVM] whis this method:
/// _warningMessageVM.addListener(() {...}.
class WarningMessageDisplayDialog extends StatelessWidget with ScreenMixin {
  final BuildContext _context;
  final WarningMessageVM _warningMessageVM;
  final TextEditingController? _playlistUrlController;
  final ScrollController _scrollController = ScrollController();

  WarningMessageDisplayDialog({
    required BuildContext parentContext,
    required WarningMessageVM warningMessageVM,
    TextEditingController? urlController,
    super.key,
  })  : _context = parentContext,
        _warningMessageVM = warningMessageVM,
        _playlistUrlController = urlController;

  @override
  Widget build(BuildContext context) {
    final WarningMessageType warningMessageType =
        _warningMessageVM.warningMessageType;
    final ThemeProviderVM themeProviderVM =
        Provider.of<ThemeProviderVM>(context); // by default, listen is true

    switch (warningMessageType) {
      case WarningMessageType.errorMessage:
        ErrorType errorType = _warningMessageVM.errorType;

        switch (errorType) {
          case ErrorType.downloadAudioYoutubeError:
            String exceptionMessage = _warningMessageVM.errorArgOne;
            String videoTitle = _warningMessageVM.errorArgTwo;

            if (exceptionMessage.isNotEmpty && videoTitle.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _displayWarningDialog(
                  context: _context,
                  message:
                      AppLocalizations.of(context)!.downloadAudioYoutubeError(
                    videoTitle,
                    exceptionMessage,
                  ),
                  warningMessageVM: _warningMessageVM,
                  themeProviderVM: themeProviderVM,
                );
              });
            } else if (exceptionMessage.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _displayWarningDialog(
                  context: _context,
                  message: AppLocalizations.of(context)!
                      .downloadAudioYoutubeErrorExceptionMessageOnly(
                    exceptionMessage,
                  ),
                  warningMessageVM: _warningMessageVM,
                  themeProviderVM: themeProviderVM,
                );
              });
            }

            return const SizedBox.shrink();
          case ErrorType.downloadAudioYoutubeErrorDueToLiveVideoInPlaylist:
            String playlistTitle = _warningMessageVM.errorArgOne;
            String liveVideoString = _warningMessageVM.errorArgTwo;

            if (liveVideoString.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _displayWarningDialog(
                  context: _context,
                  message: AppLocalizations.of(context)!
                      .downloadAudioYoutubeErrorDueToLiveVideoInPlaylist(
                          playlistTitle, liveVideoString),
                  warningMessageVM: _warningMessageVM,
                  themeProviderVM: themeProviderVM,
                );
              });
            }

            return const SizedBox.shrink();
          case ErrorType.noInternet:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _displayWarningDialog(
                context: _context,
                message: AppLocalizations.of(context)!.noInternet,
                warningMessageVM: _warningMessageVM,
                themeProviderVM: themeProviderVM,
              );
            });

            return const SizedBox.shrink();
          case ErrorType.downloadAudioFileAlreadyOnAudioDirectory:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _displayWarningDialog(
                context: _context,
                message: AppLocalizations.of(context)!
                    .downloadAudioFileAlreadyOnAudioDirectory(
                  _warningMessageVM.errorArgOne,
                  _warningMessageVM.errorArgTwo,
                  _warningMessageVM.errorArgThree,
                ),
                warningMessageVM: _warningMessageVM,
                themeProviderVM: themeProviderVM,
              );
            });

            return const SizedBox.shrink();
          case ErrorType.errorInPlaylistJsonFile:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _displayWarningDialog(
                context: _context,
                message: AppLocalizations.of(context)!.errorInPlaylistJsonFile(
                  _warningMessageVM.errorArgOne,
                ),
                warningMessageVM: _warningMessageVM,
                themeProviderVM: themeProviderVM,
              );
            });

            return const SizedBox.shrink();
          case ErrorType.dateFormatError:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _displayWarningDialog(
                context: _context,
                message: AppLocalizations.of(context)!
                    .invalidDateFormatErrorMessage(
                        _warningMessageVM.errorArgOne),
                warningMessageVM: _warningMessageVM,
                themeProviderVM: themeProviderVM,
              );
            });

            return const SizedBox.shrink();
          case ErrorType.enteredDateEmpty:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _displayWarningDialog(
                context: _context,
                message: AppLocalizations.of(context)!
                    .emptyDateErrorMessage,
                warningMessageVM: _warningMessageVM,
                themeProviderVM: themeProviderVM,
              );
            });

            return const SizedBox.shrink();
          case ErrorType.insufficientStorageSpace:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _displayWarningDialog(
                context: _context,
                message: AppLocalizations.of(context)!.insufficientStorageSpace,
                warningMessageVM: _warningMessageVM,
                themeProviderVM: themeProviderVM,
              );
            });

            return const SizedBox.shrink();
          case ErrorType.pathError:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _displayWarningDialog(
                context: _context,
                message: AppLocalizations.of(context)!.pathError,
                warningMessageVM: _warningMessageVM,
                themeProviderVM: themeProviderVM,
              );
            });

            return const SizedBox.shrink();
          case ErrorType.androidStorageAccessError:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _displayWarningDialog(
                context: _context,
                message: AppLocalizations.of(context)!
                    .androidStorageAccessErrorMessage,
                warningMessageVM: _warningMessageVM,
                themeProviderVM: themeProviderVM,
              );
            });

            return const SizedBox.shrink();
          case ErrorType.androidZipFileCreationError:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _displayWarningDialog(
                context: _context,
                message:
                    AppLocalizations.of(context)!.androidZipFileCreationError(
                        _warningMessageVM.errorArgOne,
                        UiUtil.formatLargeSizeToKbOrMb(
                          context: context,
                          sizeInBytes: int.parse(_warningMessageVM.errorArgTwo),
                        )),
                warningMessageVM: _warningMessageVM,
                themeProviderVM: themeProviderVM,
              );
            });

            return const SizedBox.shrink();
          default:
            return const SizedBox.shrink();
        }
      case WarningMessageType.updatedPlaylistUrlTitle:
        String updatedPlayListTitle = _warningMessageVM.updatedPlaylistTitle;

        if (updatedPlayListTitle.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _displayWarningDialog(
                context: _context,
                message: AppLocalizations.of(context)!
                    .updatedPlaylistUrlTitle(updatedPlayListTitle),
                warningMessageVM: _warningMessageVM,
                themeProviderVM: themeProviderVM);
          });
        }

        return const SizedBox.shrink();
      case WarningMessageType.addPlaylistTitle:
        String addedPlayListTitle = _warningMessageVM.addedPlaylistTitle;
        PlaylistQuality playlistQuality =
            _warningMessageVM.addedPlaylistQuality;
        String playlistQualityStr;

        if (addedPlayListTitle.isNotEmpty) {
          if (playlistQuality == PlaylistQuality.voice) {
            playlistQualityStr =
                AppLocalizations.of(context)!.playlistQualityAudio;
          } else {
            playlistQualityStr =
                AppLocalizations.of(context)!.playlistQualityMusic;
          }

          String addedPlaylistMessage;

          if (_warningMessageVM.addedPlaylistType == PlaylistType.local) {
            addedPlaylistMessage = AppLocalizations.of(context)!
                .addLocalPlaylistTitle(addedPlayListTitle, playlistQualityStr);
          } else {
            // Youtube playlist is added
            addedPlaylistMessage = AppLocalizations.of(context)!
                .addYoutubePlaylistTitle(
                    addedPlayListTitle, playlistQualityStr);
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _displayWarningDialog(
                context: _context,
                message: addedPlaylistMessage,
                warningMessageVM: _warningMessageVM,
                themeProviderVM: themeProviderVM,
                warningMode: WarningMode.confirm);
          });
        }

        return const SizedBox.shrink();
      case WarningMessageType.privatePlaylistAddition:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
              context: _context,
              message: AppLocalizations.of(context)!.addPrivateYoutubePlaylist,
              warningMessageVM: _warningMessageVM,
              themeProviderVM: themeProviderVM);
        });

        return const SizedBox.shrink();
      case WarningMessageType.invalidValueWarning:
        String invalidValueWarningParmOne;

        if (_warningMessageVM.invalidValueState == InvalidValueState.positionTooBig) {
          invalidValueWarningParmOne =
              AppLocalizations.of(context)!.invalidValueTooBig;
        } else {
          invalidValueWarningParmOne =
              AppLocalizations.of(context)!.invalidValueTooSmall;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
              context: _context,
              message: AppLocalizations.of(context)!.setValueToTargetWarning(
                  invalidValueWarningParmOne, _warningMessageVM.valueLimitStr),
              warningMessageVM: _warningMessageVM,
              themeProviderVM: themeProviderVM);
        });

        return const SizedBox.shrink();
      case WarningMessageType.invalidPlaylistUrl:
        String playlistUrl = _warningMessageVM.invalidPlaylistUrl;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message:
                AppLocalizations.of(context)!.invalidPlaylistUrl(playlistUrl),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.invalidLocalPlaylistTitle:
        String playlistTitle = _warningMessageVM.invalidLocalPlaylistTitle;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .invalidLocalPlaylistTitle(playlistTitle),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.invalidYoutubePlaylistTitle:
        String playlistTitle = _warningMessageVM.invalidYoutubePlaylistTitle;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .invalidYoutubePlaylistTitle(playlistTitle),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.renameFileNameAlreadyUsed:
        String fileName = _warningMessageVM.renameFileNameAlreadyUsed;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .renameFileNameAlreadyUsed(fileName),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.correctedYoutubePlaylistTitle:
        String originalPlaylistTitle = _warningMessageVM.originalPlaylistTitle;
        String correctedPlaylistTitle =
            _warningMessageVM.correctedPlaylistTitle;
        PlaylistQuality playlistQuality =
            _warningMessageVM.addedPlaylistQuality;
        String playlistQualityStr;

        if (originalPlaylistTitle.isNotEmpty) {
          if (playlistQuality == PlaylistQuality.voice) {
            playlistQualityStr =
                AppLocalizations.of(context)!.playlistQualityAudio;
          } else {
            playlistQualityStr =
                AppLocalizations.of(context)!.playlistQualityMusic;
          }

          String addedPlaylistMessage;

          // Youtube playlist is added
          addedPlaylistMessage = AppLocalizations.of(context)!
              .addCorrectedYoutubePlaylistTitle(originalPlaylistTitle,
                  playlistQualityStr, correctedPlaylistTitle);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _displayWarningDialog(
                context: _context,
                message: addedPlaylistMessage,
                warningMessageVM: _warningMessageVM,
                themeProviderVM: themeProviderVM);
          });
        }

        return const SizedBox.shrink();
      case WarningMessageType.confirmYoutubeChannelModifications:
        int numberOfModifiedDownloadedAudio =
            _warningMessageVM.numberOfModifiedDownloadedAudio;
        int numberOfModifiedPlayableAudio =
            _warningMessageVM.numberOfModifiedPlayableAudio;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .confirmYoutubeChannelModifications(
              numberOfModifiedDownloadedAudio,
              numberOfModifiedPlayableAudio,
            ),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
            warningMode: WarningMode.confirm,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.renameFileNameInvalid:
        String fileName = _warningMessageVM.renameFileNameInvalid;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message:
                AppLocalizations.of(context)!.renameFileNameInvalid(fileName),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.renameAudioFileConfirm:
        String oldFileName = _warningMessageVM.oldFileName;
        String newFileName = _warningMessageVM.newFileName;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!.renameAudioFileConfirmation(
              newFileName,
              oldFileName,
            ),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
            warningMode: WarningMode.confirm,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.renameAudioAndCommentFileConfirm:
        String oldFileName = _warningMessageVM.oldFileName;
        String newFileName = _warningMessageVM.newFileName;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .renameAudioAndCommentFileConfirmation(
              newFileName,
              oldFileName,
            ),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
            warningMode: WarningMode.confirm,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.renameCommentFileNameAlreadyUsed:
        String fileName = _warningMessageVM.renameCommentFileNameAlreadyUsed;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .renameCommentFileNameAlreadyUsed(fileName),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.addRemoveSortFilterParmsToPlaylistConfirm:
        String playlistTitle = _warningMessageVM.playlistTitle;
        String sortFilterParmsName = _warningMessageVM.sortFilterParmsName;
        String forPlaylistDownloadViewMessagePart;
        String forAudioPlayerViewMessagePart;
        String forViewMessage = '';

        if ((_warningMessageVM.forPlaylistDownloadView)) {
          forPlaylistDownloadViewMessagePart =
              AppLocalizations.of(context)!.appBarTitleDownloadAudio;
          if ((_warningMessageVM.forAudioPlayerView)) {
            forAudioPlayerViewMessagePart =
                "\" ${AppLocalizations.of(context)!.and} \"${AppLocalizations.of(context)!.appBarTitleAudioPlayer}";
          } else {
            forAudioPlayerViewMessagePart = '';
          }

          forViewMessage = forPlaylistDownloadViewMessagePart +
              forAudioPlayerViewMessagePart;
        } else {
          if (_warningMessageVM.forAudioPlayerView) {
            forViewMessage =
                AppLocalizations.of(context)!.appBarTitleAudioPlayer;
          }
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          String confirmationMessage;

          if (_warningMessageVM.isSaveApplied) {
            confirmationMessage =
                AppLocalizations.of(context)!.saveSortFilterParmsConfirmation(
              sortFilterParmsName,
              playlistTitle,
              forViewMessage,
            );
          } else {
            confirmationMessage =
                AppLocalizations.of(context)!.removeSortFilterParmsConfirmation(
              sortFilterParmsName,
              playlistTitle,
              forViewMessage,
            );
          }

          _displayWarningDialog(
            context: _context,
            message: confirmationMessage,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
            warningMode: WarningMode.confirm,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.playlistWithUrlAlreadyInListOfPlaylists:
        String playlistUrl = _playlistUrlController?.text ?? '';
        String playlistTitle = _warningMessageVM.playlistAlreadyDownloadedTitle;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .playlistWithUrlAlreadyInListOfPlaylists(
                    playlistUrl, playlistTitle),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.localPlaylistWithTitleAlreadyInListOfPlaylists:
        String playlistTitle =
            _warningMessageVM.localPlaylistAlreadyCreatedTitle;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .localPlaylistWithTitleAlreadyInListOfPlaylists(playlistTitle),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.youtubePlaylistWithTitleAlreadyInListOfPlaylists:
        String playlistTitle =
            _warningMessageVM.localPlaylistAlreadyCreatedTitle;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .youtubePlaylistWithTitleAlreadyInListOfPlaylists(
                    playlistTitle),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.deleteAudioFromPlaylistAswellWarning:
        String playlistTitle =
            _warningMessageVM.deleteAudioFromPlaylistAswellTitle;
        String audioVideoTitle =
            _warningMessageVM.deleteAudioFromPlaylistAswellAudioVideoTitle;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .deleteAudioFromPlaylistAswellWarning(
              audioVideoTitle,
              playlistTitle,
            ),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.invalidSingleVideoUrl:
        String playlistUrl = _playlistUrlController?.text ?? '';

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .invalidSingleVideoUUrl(playlistUrl),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.updatedPlayableAudioLst:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!.updatedPlayableAudioLst(
              _warningMessageVM.removedPlayableAudioNumber,
              _warningMessageVM.updatedPlayableAudioLstPlaylistTitle,
            ),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.confirmMovedUnmovedAudioNumber:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          String confirmationMessage;

          if (_warningMessageVM.movedFromSourcePlaylistType ==
              PlaylistType.youtube) {
            if (_warningMessageVM.movedToTargetPlaylistType ==
                PlaylistType.youtube) {
              confirmationMessage = AppLocalizations.of(context)!
                  .confirmMovedUnmovedAudioNumberFromYoutubeToYoutubePlaylist(
                _warningMessageVM.audioMoveSourcePlaylistTitle,
                _warningMessageVM.audioMoveTargetPlaylistTitle,
                _warningMessageVM.appliedToMoveSortFilterParmsName,
                _warningMessageVM.movedAudioNumber,
                _warningMessageVM.movedCommentedAudioNumber,
                _warningMessageVM.unmovedAudioNumber,
              );
            } else {
              confirmationMessage = AppLocalizations.of(context)!
                  .confirmMovedUnmovedAudioNumberFromYoutubeToLocalPlaylist(
                _warningMessageVM.audioMoveSourcePlaylistTitle,
                _warningMessageVM.audioMoveTargetPlaylistTitle,
                _warningMessageVM.appliedToMoveSortFilterParmsName,
                _warningMessageVM.movedAudioNumber,
                _warningMessageVM.movedCommentedAudioNumber,
                _warningMessageVM.unmovedAudioNumber,
              );
            }
          } else {
            if (_warningMessageVM.movedToTargetPlaylistType ==
                PlaylistType.youtube) {
              confirmationMessage = AppLocalizations.of(context)!
                  .confirmMovedUnmovedAudioNumberFromLocalToYoutubePlaylist(
                _warningMessageVM.audioMoveSourcePlaylistTitle,
                _warningMessageVM.audioMoveTargetPlaylistTitle,
                _warningMessageVM.appliedToMoveSortFilterParmsName,
                _warningMessageVM.movedAudioNumber,
                _warningMessageVM.movedCommentedAudioNumber,
                _warningMessageVM.unmovedAudioNumber,
              );
            } else {
              confirmationMessage = AppLocalizations.of(context)!
                  .confirmMovedUnmovedAudioNumberFromLocalToLocalPlaylist(
                _warningMessageVM.audioMoveSourcePlaylistTitle,
                _warningMessageVM.audioMoveTargetPlaylistTitle,
                _warningMessageVM.appliedToMoveSortFilterParmsName,
                _warningMessageVM.movedAudioNumber,
                _warningMessageVM.movedCommentedAudioNumber,
                _warningMessageVM.unmovedAudioNumber,
              );
            }
          }

          _displayWarningDialog(
            context: _context,
            message: confirmationMessage,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
            warningMode: WarningMode.confirm,
          );
        });

        return const SizedBox.shrink();

      case WarningMessageType.notApplyingDefaultSFparmsToMoveWarning:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          String warningMessage;

          if (_warningMessageVM.movedFromSourcePlaylistType ==
              PlaylistType.youtube) {
            if (_warningMessageVM.movedToTargetPlaylistType ==
                PlaylistType.youtube) {
              warningMessage = AppLocalizations.of(context)!
                  .defaultSFPNotApplyedToMoveAudioFromYoutubeToYoutubePlaylistWarning(
                _warningMessageVM.audioMoveSourcePlaylistTitle,
                _warningMessageVM.audioMoveTargetPlaylistTitle,
                _warningMessageVM.appliedToMoveSortFilterParmsName,
              );
            } else {
              warningMessage = AppLocalizations.of(context)!
                  .defaultSFPNotApplyedToMoveAudioFromYoutubeToLocalPlaylistWarning(
                _warningMessageVM.audioMoveSourcePlaylistTitle,
                _warningMessageVM.audioMoveTargetPlaylistTitle,
                _warningMessageVM.appliedToMoveSortFilterParmsName,
              );
            }
          } else {
            if (_warningMessageVM.movedToTargetPlaylistType ==
                PlaylistType.youtube) {
              warningMessage = AppLocalizations.of(context)!
                  .defaultSFPNotApplyedToMoveAudioFromLocalToYoutubePlaylistWarning(
                _warningMessageVM.audioMoveSourcePlaylistTitle,
                _warningMessageVM.audioMoveTargetPlaylistTitle,
                _warningMessageVM.appliedToMoveSortFilterParmsName,
              );
            } else {
              warningMessage = AppLocalizations.of(context)!
                  .defaultSFPNotApplyedToMoveAudioFromLocalToLocalPlaylistWarning(
                _warningMessageVM.audioMoveSourcePlaylistTitle,
                _warningMessageVM.audioMoveTargetPlaylistTitle,
                _warningMessageVM.appliedToMoveSortFilterParmsName,
              );
            }
          }

          _displayWarningDialog(
            context: _context,
            message: warningMessage,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.notApplyingDefaultSFparmsToCopyWarning:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          String warningMessage;

          if (_warningMessageVM.copiedFromSourcePlaylistType ==
              PlaylistType.youtube) {
            if (_warningMessageVM.copiedToTargetPlaylistType ==
                PlaylistType.youtube) {
              warningMessage = AppLocalizations.of(context)!
                  .defaultSFPNotApplyedToCopyAudioFromYoutubeToYoutubePlaylistWarning(
                _warningMessageVM.audioCopySourcePlaylistTitle,
                _warningMessageVM.audioCopyTargetPlaylistTitle,
                _warningMessageVM.appliedToCopySortFilterParmsName,
              );
            } else {
              warningMessage = AppLocalizations.of(context)!
                  .defaultSFPNotApplyedToCopyAudioFromYoutubeToLocalPlaylistWarning(
                _warningMessageVM.audioCopySourcePlaylistTitle,
                _warningMessageVM.audioCopyTargetPlaylistTitle,
                _warningMessageVM.appliedToCopySortFilterParmsName,
              );
            }
          } else {
            if (_warningMessageVM.copiedToTargetPlaylistType ==
                PlaylistType.youtube) {
              warningMessage = AppLocalizations.of(context)!
                  .defaultSFPNotApplyedToCopyAudioFromLocalToYoutubePlaylistWarning(
                _warningMessageVM.audioCopySourcePlaylistTitle,
                _warningMessageVM.audioCopyTargetPlaylistTitle,
                _warningMessageVM.appliedToCopySortFilterParmsName,
              );
            } else {
              warningMessage = AppLocalizations.of(context)!
                  .defaultSFPNotApplyedToCopyAudioFromLocalToLocalPlaylistWarning(
                _warningMessageVM.audioCopySourcePlaylistTitle,
                _warningMessageVM.audioCopyTargetPlaylistTitle,
                _warningMessageVM.appliedToCopySortFilterParmsName,
              );
            }
          }

          _displayWarningDialog(
            context: _context,
            message: warningMessage,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.confirmCopiedNotCopiedAudioNumber:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          String confirmationMessage;

          if (_warningMessageVM.copiedFromSourcePlaylistType ==
              PlaylistType.youtube) {
            if (_warningMessageVM.copiedToTargetPlaylistType ==
                PlaylistType.youtube) {
              confirmationMessage = AppLocalizations.of(context)!
                  .confirmCopiedNotCopiedAudioNumberFromYoutubeToYoutubePlaylist(
                _warningMessageVM.audioCopySourcePlaylistTitle,
                _warningMessageVM.audioCopyTargetPlaylistTitle,
                _warningMessageVM.appliedToCopySortFilterParmsName,
                _warningMessageVM.copiedAudioNumber,
                _warningMessageVM.copiedCommentedAudioNumber,
                _warningMessageVM.notCopiedAudioNumber,
              );
            } else {
              confirmationMessage = AppLocalizations.of(context)!
                  .confirmCopiedNotCopiedAudioNumberFromYoutubeToLocalPlaylist(
                _warningMessageVM.audioCopySourcePlaylistTitle,
                _warningMessageVM.audioCopyTargetPlaylistTitle,
                _warningMessageVM.appliedToCopySortFilterParmsName,
                _warningMessageVM.copiedAudioNumber,
                _warningMessageVM.copiedCommentedAudioNumber,
                _warningMessageVM.notCopiedAudioNumber,
              );
            }
          } else {
            if (_warningMessageVM.copiedToTargetPlaylistType ==
                PlaylistType.youtube) {
              confirmationMessage = AppLocalizations.of(context)!
                  .confirmCopiedNotCopiedAudioNumberFromLocalToYoutubePlaylist(
                _warningMessageVM.audioCopySourcePlaylistTitle,
                _warningMessageVM.audioCopyTargetPlaylistTitle,
                _warningMessageVM.appliedToCopySortFilterParmsName,
                _warningMessageVM.copiedAudioNumber,
                _warningMessageVM.copiedCommentedAudioNumber,
                _warningMessageVM.notCopiedAudioNumber,
              );
            } else {
              confirmationMessage = AppLocalizations.of(context)!
                  .confirmCopiedNotCopiedAudioNumberFromLocalToLocalPlaylist(
                _warningMessageVM.audioCopySourcePlaylistTitle,
                _warningMessageVM.audioCopyTargetPlaylistTitle,
                _warningMessageVM.appliedToCopySortFilterParmsName,
                _warningMessageVM.copiedAudioNumber,
                _warningMessageVM.copiedCommentedAudioNumber,
                _warningMessageVM.notCopiedAudioNumber,
              );
            }
          }

          _displayWarningDialog(
            context: _context,
            message: confirmationMessage,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
            warningMode: WarningMode.confirm,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.rewindedPlayableAudioToStart:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!.rewindedPlayableAudioNumber(
              _warningMessageVM.rewindedPlayableAudioNumber,
            ),
            warningMessageVM: _warningMessageVM,
            warningMode: WarningMode.confirm,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.redownloadingAudioConfirmationOrWarning:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          int redownloadAudioNumber = _warningMessageVM.redownloadAudioNumber;
          _displayWarningDialog(
            context: _context,
            message: (redownloadAudioNumber == 1)
                ? AppLocalizations.of(context)!.redownloadedAudioConfirmation(
                    _warningMessageVM.playlistTitle,
                    _warningMessageVM.redownloadAudioTitle,
                  )
                : AppLocalizations.of(context)!.audioNotRedownloadedWarning(
                    _warningMessageVM.playlistTitle,
                    _warningMessageVM.redownloadAudioTitle,
                  ),
            warningMessageVM: _warningMessageVM,
            warningMode: (redownloadAudioNumber == 1)
                ? WarningMode.confirm
                : WarningMode.warning,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.notRedownloadAudioFilesInPlaylistDirectory:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .notRedownloadAudioFilesInPlaylistDirectory(
              _warningMessageVM.audioNumber,
              _warningMessageVM.targetPlaylistTitle,
            ),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.noSortFilterSaveAsName:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message:
                AppLocalizations.of(context)!.noSortFilterSaveAsNameWarning,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.deletedHistoricalSortFilterParameterNotExist:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .deletedSortFilterParameterNotExistWarning,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.historicalSortFilterParameterWasDeleted:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .historicalSortFilterParameterWasDeletedWarning,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.noCheckboxSelected:
        String translatedAtLeastStr = '';

        if (_warningMessageVM.addAtListToWarningMessage) {
          translatedAtLeastStr = AppLocalizations.of(context)!.atLeast;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .noCheckboxSelectedWarning(translatedAtLeastStr),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.playlistRootPathNotExist:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .playlistRootPathNotExistWarning(
                    _warningMessageVM.playlistInexistingRootPath),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.playlistInvalidRootPath:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .playlistInvalidRootPathWarning(
                    _warningMessageVM.playlistInvalidRootPath,
                    _warningMessageVM.playlistInvalidRootName),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.noSortFilterParameterWasModified:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .noSortFilterParameterWasModifiedWarning,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.noPlaylistSelectedForSingleVideoDownload:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .noPlaylistSelectedForSingleVideoDownloadWarning,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.videoTitleNotWrittenInOccidentalLetters:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .videoTitleNotWrittenInOccidentalLettersWarning,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.isNoPlaylistSelectedForAudioCopy:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .noPlaylistSelectedForAudioCopyWarning,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.isNoPlaylistSelectedForAudioMove:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .noPlaylistSelectedForAudioMoveWarning,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.tooManyPlaylistSelectedForSingleVideoDownload:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .tooManyPlaylistSelectedForSingleVideoDownloadWarning,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.audioCopiedOrMovedFromPlaylistToPlaylist:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          String notCopiedOrMovedReasonStr = '.';

          if (_warningMessageVM.copyOrMoveFileResult ==
              CopyOrMoveFileResult.sourceFileNotExist) {
            notCopiedOrMovedReasonStr =
                AppLocalizations.of(context)!.sinceAbsentFromSourcePlaylist;
          } else if (_warningMessageVM.copyOrMoveFileResult ==
              CopyOrMoveFileResult.targetFileAlreadyExists) {
            notCopiedOrMovedReasonStr = AppLocalizations.of(context)!
                .sinceAlreadyPresentInTargetPlaylist;
          } else if (_warningMessageVM.copyOrMoveFileResult ==
              CopyOrMoveFileResult.audioNotKeptInSourcePlaylist) {
            notCopiedOrMovedReasonStr =
                AppLocalizations.of(context)!.audioNotKeptInSourcePlaylist(
              _warningMessageVM.audioValidVideoTitle,
              _warningMessageVM.fromPlaylistTitle,
            );
          }

          bool wasOperationSuccessful =
              _warningMessageVM.wasOperationSuccessful;

          String yesOrNo;
          String operationType;

          if ((wasOperationSuccessful)) {
            yesOrNo = AppLocalizations.of(context)!.yesOperation;
            if ((_warningMessageVM.isAudioCopied)) {
              operationType = AppLocalizations.of(context)!.copiedOperationType;
            } else {
              operationType = AppLocalizations.of(context)!.movedOperationType;
            }
          } else {
            yesOrNo = AppLocalizations.of(context)!.noOperation;
            if ((_warningMessageVM.isAudioCopied)) {
              operationType =
                  AppLocalizations.of(context)!.noOperationCopiedOperationType;
            } else {
              operationType =
                  AppLocalizations.of(context)!.noOperationMovedOperationType;
            }
          }

          String fromPlaylistTypeStr =
              (_warningMessageVM.fromPlaylistType == PlaylistType.local)
                  ? AppLocalizations.of(context)!.localPlaylistType
                  : AppLocalizations.of(context)!.youtubePlaylistType;
          String toPlaylistTypeStr =
              (_warningMessageVM.toPlaylistType == PlaylistType.local)
                  ? AppLocalizations.of(context)!.localPlaylistType
                  : AppLocalizations.of(context)!.youtubePlaylistType;

          String audioCopiedOrMMovedFromToPlaylistMessage =
              AppLocalizations.of(context)!
                  .audioCopiedOrMovedFromPlaylistToPlaylist(
            _warningMessageVM.audioValidVideoTitle,
            yesOrNo,
            operationType,
            fromPlaylistTypeStr,
            _warningMessageVM.fromPlaylistTitle,
            _warningMessageVM.toPlaylistTitle,
            toPlaylistTypeStr,
            notCopiedOrMovedReasonStr,
          );

          _displayWarningDialog(
            context: _context,
            message: audioCopiedOrMMovedFromToPlaylistMessage,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
            warningMode: (wasOperationSuccessful)
                ? WarningMode.confirm
                : WarningMode.warning,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.savedUniquePlaylistOrAllPlaylistsAndAppDataToZip:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          String savedAppDataToZipMessage;

          if (_warningMessageVM.zipFilePathName != '') {
            if (_warningMessageVM.uniquePlaylistIsSaved) {
              savedAppDataToZipMessage =
                  AppLocalizations.of(context)!.savedUniquePlaylistToZip(
                _warningMessageVM.zipFilePathName,
              );

              if (_warningMessageVM.savedOrRestoredPictureJpgNumber > 0) {
                savedAppDataToZipMessage += AppLocalizations.of(context)!
                    .addedToZipPictureNumberMessage(
                  _warningMessageVM.savedOrRestoredPictureJpgNumber,
                );
              }
            } else {
              savedAppDataToZipMessage =
                  AppLocalizations.of(context)!.savedAppDataToZip(
                _warningMessageVM.zipFilePathName,
              );

              if (_warningMessageVM.savedOrRestoredPictureJpgNumber > 0) {
                if (_warningMessageVM.addPictureJpgFilesToZip) {
                  savedAppDataToZipMessage += AppLocalizations.of(context)!
                      .savedPictureNumberMessageToZip(
                    _warningMessageVM.savedOrRestoredPictureJpgNumber,
                  );
                } else {
                  savedAppDataToZipMessage +=
                      AppLocalizations.of(context)!.savedPictureNumberMessage(
                    _warningMessageVM.savedOrRestoredPictureJpgNumber,
                  );
                }
              }
            }

            _displayWarningDialog(
              context: _context,
              message: savedAppDataToZipMessage,
              warningMessageVM: _warningMessageVM,
              themeProviderVM: themeProviderVM,
              warningMode: WarningMode.confirm,
            );
          } else {
            savedAppDataToZipMessage =
                AppLocalizations.of(context)!.appDataCouldNotBeSavedToZip;

            _displayWarningDialog(
              context: _context,
              message: savedAppDataToZipMessage,
              warningMessageVM: _warningMessageVM,
              themeProviderVM: themeProviderVM,
            );
          }
        });

        return const SizedBox.shrink();
      case WarningMessageType.displayNewestAudioDownloadDateTime:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          String displayNewestAudioDownloadDateTimeMessage;

          displayNewestAudioDownloadDateTimeMessage =
              AppLocalizations.of(context)!.displayNewestAudioDownloadDateTime(
            _warningMessageVM.newestAudioDownloadDateTime,
          );

          _displayWarningDialog(
            context: _context,
            message: displayNewestAudioDownloadDateTimeMessage,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
            warningMode: WarningMode.confirm,
            warningDialogTitle: AppLocalizations.of(context)!
                .displayNewestAudioDownloadDateTimeTitle,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.savedUniquePlaylistOrAllPlaylistsAudioMp3ToZip:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          String savedAudioMp3ToZipMessage;
          String savedTotalAudioFileSizeStr = UiUtil.formatLargeSizeToKbOrMb(
            context: context,
            sizeInBytes: _warningMessageVM.savedTotalAudioFileSize,
          );
          String savedTotalAudioDurationStr =
              _warningMessageVM.savedTotalAudioDuration.HHmmss(
            addRemainingOneDigitTenthOfSecond: true,
          );
          String zipTooLargeFileInfo = '';

          final int lstLength =
              _warningMessageVM.excludedTooLargeAudioFilesLst.length;

          if (lstLength > 1) {
            zipTooLargeFileInfo =
                "\n\n${AppLocalizations.of(context)!.zipTooLargeFileInfoLabel}${_warningMessageVM.excludedTooLargeAudioFilesLst.join(' M${AppLocalizations.of(context)!.octetShort};\n')} M${AppLocalizations.of(context)!.octetShort}.";
          } else if (lstLength > 0) {
            zipTooLargeFileInfo =
                "\n\n${AppLocalizations.of(context)!.zipTooLargeOneFileInfoLabel}${_warningMessageVM.excludedTooLargeAudioFilesLst.first} M${AppLocalizations.of(context)!.octetShort}.";
          }

          if (_warningMessageVM.zipFilePathName != '') {
            if (_warningMessageVM.uniquePlaylistIsSaved) {
              savedAudioMp3ToZipMessage = AppLocalizations.of(context)!
                  .correctedSavedUniquePlaylistAudioMp3ToZip(
                      _warningMessageVM.fromAudioDownloadDateTime,
                      _warningMessageVM.savedAudioMp3Number,
                      savedTotalAudioFileSizeStr,
                      savedTotalAudioDurationStr,
                      _warningMessageVM.savingAudioToZipOperationDuration
                          .HHmmss(
                        addRemainingOneDigitTenthOfSecond: true,
                      ),
                      NumberFormat.decimalPattern().format(
                        _warningMessageVM.realNumberOfBytesSavedToZipPerSecond,
                      ),
                      _warningMessageVM.zipFilePathName,
                      _warningMessageVM.numberOfCreatedZipFiles,
                      zipTooLargeFileInfo);
            } else {
              savedAudioMp3ToZipMessage = AppLocalizations.of(context)!
                  .correctedSavedMultiplePlaylistsAudioMp3ToZip(
                      _warningMessageVM.fromAudioDownloadDateTime,
                      _warningMessageVM.savedAudioMp3Number,
                      savedTotalAudioFileSizeStr,
                      savedTotalAudioDurationStr,
                      _warningMessageVM.savingAudioToZipOperationDuration
                          .HHmmss(
                        addRemainingOneDigitTenthOfSecond: true,
                      ),
                      NumberFormat.decimalPattern().format(
                        _warningMessageVM.realNumberOfBytesSavedToZipPerSecond,
                      ),
                      _warningMessageVM.zipFilePathName,
                      _warningMessageVM.numberOfCreatedZipFiles,
                      zipTooLargeFileInfo);
            }

            _displayWarningDialog(
              context: _context,
              message: savedAudioMp3ToZipMessage,
              warningMessageVM: _warningMessageVM,
              themeProviderVM: themeProviderVM,
              warningMode: WarningMode.confirm,
            );
          } else {
            savedAudioMp3ToZipMessage =
                AppLocalizations.of(context)!.noAudioMp3WereSavedToZip(
              _warningMessageVM.fromAudioDownloadDateTime,
            );

            _displayWarningDialog(
              context: _context,
              message: savedAudioMp3ToZipMessage,
              warningMessageVM: _warningMessageVM,
              themeProviderVM: themeProviderVM,
            );
          }
        });

        return const SizedBox.shrink();
      case WarningMessageType.restoreAppDataFromZip:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          String restoredAppDataFromZipMessage;
          int deletedAudioAndMp3FilesNumber =
              _warningMessageVM.deletedAudioAndMp3FilesNumber;
          String deletedAudioAndMp3FilesMessage = '';
          int deletedExistingPlaylistsNumber =
              _warningMessageVM.deletedExistingPlaylistsNumber;

          if (deletedAudioAndMp3FilesNumber > 0) {
            deletedAudioAndMp3FilesMessage =
                AppLocalizations.of(context)!.deletedAudioAndMp3FilesMessage(
              deletedAudioAndMp3FilesNumber,
            );
          } else {
            deletedAudioAndMp3FilesMessage = '';
          }

          if (deletedExistingPlaylistsNumber > 0) {
            deletedAudioAndMp3FilesMessage +=
                AppLocalizations.of(context)!
                    .deletedExistingPlaylistsMessage(
              deletedExistingPlaylistsNumber,
            );
          }

          List<HelpItem> restoredAppDataFromZipHelpItemsLst = [
            HelpItem(
              helpTitle:
                  AppLocalizations.of(context)!.restoredElementsHelpTitle,
              helpContent:
                  AppLocalizations.of(context)!.restoredElementsHelpContent,
              displayHelpItemNumber: false,
            ),
          ];

          if (_warningMessageVM.zipFilePathName != '') {
            if (!_warningMessageVM.wasIndividualPlaylistRestored) {
              if (_warningMessageVM.newPlaylistsAddedAtEndOfPlaylistLst) {
                int playlistsNumber = _warningMessageVM.playlistsNumber;
                restoredAppDataFromZipMessage = AppLocalizations.of(context)!
                    .doRestoreMultiplePlaylistFromZip(
                  playlistsNumber,
                  _warningMessageVM.audioReferencesNumber,
                  _warningMessageVM.commentJsonFilesNumber,
                  _warningMessageVM.updatedCommentNumber,
                  _warningMessageVM.addedCommentNumber,
                  _warningMessageVM.pictureJsonFilesNumber,
                  _warningMessageVM.savedOrRestoredPictureJpgNumber,
                  deletedAudioAndMp3FilesMessage,
                  _warningMessageVM.zipFilePathName,
                  (playlistsNumber > 1)
                      ? AppLocalizations.of(context)!
                          .multiplePlaylistsAddedAtEndOfPlaylistLst
                      : AppLocalizations.of(context)!
                          .uniquePlaylistAddedAtEndOfPlaylistLst,
                );
              } else {
                restoredAppDataFromZipMessage = AppLocalizations.of(context)!
                    .doRestoreMultiplePlaylistFromZip(
                  _warningMessageVM.playlistsNumber,
                  _warningMessageVM.audioReferencesNumber,
                  _warningMessageVM.commentJsonFilesNumber,
                  _warningMessageVM.updatedCommentNumber,
                  _warningMessageVM.addedCommentNumber,
                  _warningMessageVM.pictureJsonFilesNumber,
                  _warningMessageVM.savedOrRestoredPictureJpgNumber,
                  deletedAudioAndMp3FilesMessage,
                  _warningMessageVM.zipFilePathName,
                  "",
                );
              }
            } else {
              // Individual playlist is restored
              if (_warningMessageVM.newPlaylistsAddedAtEndOfPlaylistLst) {
                restoredAppDataFromZipMessage = AppLocalizations.of(context)!
                    .doRestoreUniquePlaylistFromZip(
                  _warningMessageVM.playlistsNumber,
                  _warningMessageVM.audioReferencesNumber,
                  _warningMessageVM.commentJsonFilesNumber,
                  _warningMessageVM.updatedCommentNumber,
                  _warningMessageVM.addedCommentNumber,
                  _warningMessageVM.pictureJsonFilesNumber,
                  _warningMessageVM.savedOrRestoredPictureJpgNumber,
                  deletedAudioAndMp3FilesMessage,
                  _warningMessageVM.zipFilePathName,
                  AppLocalizations.of(context)!
                      .uniquePlaylistAddedAtEndOfPlaylistLst,
                );
              } else {
                restoredAppDataFromZipMessage = AppLocalizations.of(context)!
                    .doRestoreUniquePlaylistFromZip(
                  _warningMessageVM.playlistsNumber,
                  _warningMessageVM.audioReferencesNumber,
                  _warningMessageVM.commentJsonFilesNumber,
                  _warningMessageVM.updatedCommentNumber,
                  _warningMessageVM.addedCommentNumber,
                  _warningMessageVM.pictureJsonFilesNumber,
                  _warningMessageVM.savedOrRestoredPictureJpgNumber,
                  deletedAudioAndMp3FilesMessage,
                  _warningMessageVM.zipFilePathName,
                  "",
                );
              }
            }

            _displayWarningDialog(
              context: _context,
              message: restoredAppDataFromZipMessage,
              warningMessageVM: _warningMessageVM,
              themeProviderVM: themeProviderVM,
              warningMode: WarningMode.confirm,
              helpItemsLst: restoredAppDataFromZipHelpItemsLst,
            );
          } else {
            restoredAppDataFromZipMessage =
                AppLocalizations.of(context)!.appDataCouldNotBeRestoredFromZip;

            _displayWarningDialog(
              context: _context,
              message: restoredAppDataFromZipMessage,
              warningMessageVM: _warningMessageVM,
              themeProviderVM: themeProviderVM,
            );
          }
        });

        return const SizedBox.shrink();
      case WarningMessageType.mp3RestorationFromMp3Zip:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          String restoredAppDataFromZipMessage = '';
          String fromMp3ZipFileMessage = '';

          if (_warningMessageVM.wasIndividualPlaylistMp3ZipUsed) {
            fromMp3ZipFileMessage = AppLocalizations.of(context)!
                .fromMp3ZipFileUsedToRestoreUniquePlaylist(
              _warningMessageVM.zipFilePathName,
            );
          } else {
            fromMp3ZipFileMessage = AppLocalizations.of(context)!
                .fromMp3ZipFileUsedToRestoreMultiplePlaylists(
              _warningMessageVM.zipFilePathName,
            );
          }

          restoredAppDataFromZipMessage =
              AppLocalizations.of(context)!.confirmMp3RestorationFromMp3Zip(
            _warningMessageVM.restoredMp3Number,
            _warningMessageVM.playlistsNumber,
            fromMp3ZipFileMessage,
          );

          _displayWarningDialog(
            context: _context,
            message: restoredAppDataFromZipMessage,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
            warningMode: WarningMode.confirm,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.audioCreatedFromTextToSpeechOperation:
        final String convertedAudioFileName =
            _warningMessageVM.convertedAudioFileName;
        String audioImportedFromTextToSpeechToPlaylistMessage = '';
        String replacedOrAddedStr = '';

        if (_warningMessageVM.wasConvertedAudioAdded) {
          replacedOrAddedStr =
              AppLocalizations.of(context)!.addedTo;
        } else {
          replacedOrAddedStr = AppLocalizations.of(context)!.replacedIn;
        }

        if (convertedAudioFileName.isNotEmpty) {
          if (_warningMessageVM.targetPlaylistType == PlaylistType.local) {
            audioImportedFromTextToSpeechToPlaylistMessage =
                AppLocalizations.of(context)!
                    .audioImportedFromTextToSpeechToLocalPlaylist(
              convertedAudioFileName,
              replacedOrAddedStr,
              _warningMessageVM.targetPlaylistTitle,
            );
          } else {
            audioImportedFromTextToSpeechToPlaylistMessage =
                AppLocalizations.of(context)!
                    .audioImportedFromTextToSpeechToYoutubePlaylist(
              convertedAudioFileName,
              replacedOrAddedStr,
              _warningMessageVM.targetPlaylistTitle,
            );
          }
        }

        // return const SizedBox.shrink();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: audioImportedFromTextToSpeechToPlaylistMessage,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
            warningMode: WarningMode.confirm,
          );
        });

        return const SizedBox.shrink();
      default:
        // Add the WarningMessageDisplayWidget to the listeners of the
        // WarningMessageVM. When WarningMessageVM executes notifyListeners(),
        // the passed callback is executed, i.e. _handlePossiblyMultipleWarnings()
        _warningMessageVM.addListener(() {
          // In situations where multiple warnings may have to be displayed
          // the WarningMessageType is not added in the above switch statement
          // but is instead handled by this method.
          _handlePossiblyMultipleWarnings(
            context: context,
            warningMessageType: _warningMessageVM.warningMessageType,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
    }
  }

  /// This method is used in two situations:
  ///   1/ displaying a unique warning,
  ///   2/ displaying possibly multiple warnings.
  ///
  /// When called to display multiple warnings, the passed {warningMessageVM}
  /// is null.
  void _displayWarningDialog({
    required BuildContext context,
    required String message,
    WarningMessageVM? warningMessageVM,
    required ThemeProviderVM themeProviderVM,
    WarningMode warningMode = WarningMode.warning,
    List<HelpItem> helpItemsLst = const [],
    String warningDialogTitle = '',
  }) {
    // The focus node must be created here, otherwise displaying
    // the dialog will cause an error.
    final focusNodeDialog = FocusNode();
    String alertDialogTitle = '';

    if (warningDialogTitle.isNotEmpty) {
      alertDialogTitle = warningDialogTitle;
    } else {
      switch (warningMode) {
        case WarningMode.warning:
          alertDialogTitle = AppLocalizations.of(context)!.warningDialogTitle;
          break;
        case WarningMode.confirm:
          alertDialogTitle = AppLocalizations.of(context)!.confirmDialogTitle;
          break;
      }
    }

    showDialog<void>(
      context: context,
      barrierDismissible:
          false, // This line prevents the dialog from closing when
      //            tapping outside the dialog
      builder: (context) => KeyboardListener(
        // Using FocusNode to enable clicking on Enter to close
        // the dialog
        focusNode: focusNodeDialog,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.numpadEnter) {
              // executing the same code as in the 'Ok'
              // TextButton onPressed callback
              //
              // WARNING: Navigator.of(context).pop(); can not be located
              // once after the if statement because in this case calling
              // _displayWarningDialog to display possibly multiple warnings
              // will not work !
              if (warningMessageVM != null) {
                // _displayWarningDialog to display unique warning
                warningMessageVM.warningMessageType = WarningMessageType.none;
                Navigator.of(context).pop();
              } else {
                // _displayWarningDialog to display possibly multiple warnings
                Navigator.of(context).pop();
                _warningMessageVM.warningFromMultipleWarningsWasDisplayed();
              }
            }
          }
        },
        child: AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  key: const Key('warningDialogTitle'),
                  alertDialogTitle,
                ),
              ),
              if (helpItemsLst.isNotEmpty)
                IconButton(
                  icon: IconTheme(
                    data: (themeProviderVM.currentTheme == AppTheme.dark
                            ? ScreenMixin.themeDataDark
                            : ScreenMixin.themeDataLight)
                        .iconTheme,
                    child: const Icon(
                      Icons.help_outline,
                      size: 40.0,
                    ),
                  ),
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => HelpDialog(
                        helpItemsLst: helpItemsLst,
                      ),
                    );
                  },
                ),
            ],
          ),
          actionsPadding: kDialogActionsPadding,
          content: SingleChildScrollView(
            controller: _scrollController,
            child: Text(
              key: const Key('warningDialogMessage'),
              message,
              style: kDialogTextFieldStyle,
            ),
          ),
          actions: [
            TextButton(
              key: const Key('warningDialogOkButton'),
              child: Text(
                'Ok',
                style: (themeProviderVM.currentTheme == AppTheme.dark)
                    ? kTextButtonStyleDarkMode
                    : kTextButtonStyleLightMode,
              ),
              onPressed: () {
                // WARNING: Navigator.of(context).pop(); can not be located
                // once after the if statement because in this case calling
                // _displayWarningDialog to display possibly multiple warnings
                // will not work !
                if (warningMessageVM != null) {
                  // _displayWarningDialog to display unique warning
                  warningMessageVM.warningMessageType = WarningMessageType.none;
                  Navigator.of(context).pop();
                } else {
                  // _displayWarningDialog to display possibly multiple warnings
                  Navigator.of(context).pop();
                  _warningMessageVM.warningFromMultipleWarningsWasDisplayed();
                }
              },
            ),
          ],
        ),
      ),
    );

    // To automatically focus on the dialog when it appears. If commented,
    // clicking on Enter will not close the dialog.
    focusNodeDialog.requestFocus();

    _scrollToCurrentAudioItem();
  }

  void _handlePossiblyMultipleWarnings({
    required BuildContext context,
    required WarningMessageType warningMessageType,
    required ThemeProviderVM themeProviderVM,
  }) {
    switch (warningMessageType) {
      case WarningMessageType.audioNotImportedToPlaylist:
        final String notImportedAudioFileNames =
            _warningMessageVM.getNextWarningMessageElements();

        if (notImportedAudioFileNames.isNotEmpty) {
          String audioImportedFromToPlaylistMessage;

          if (_warningMessageVM.importedToPlaylistType == PlaylistType.local) {
            audioImportedFromToPlaylistMessage =
                AppLocalizations.of(context)!.audioNotImportedToLocalPlaylist(
              notImportedAudioFileNames,
              _warningMessageVM.importedToPlaylistTitle,
            );
          } else {
            audioImportedFromToPlaylistMessage =
                AppLocalizations.of(context)!.audioNotImportedToYoutubePlaylist(
              notImportedAudioFileNames,
              _warningMessageVM.importedToPlaylistTitle,
            );
          }

          _displayWarningDialog(
            context: context,
            message: audioImportedFromToPlaylistMessage,
            themeProviderVM: themeProviderVM,
            warningMode: WarningMode.warning,
          );
        }
        break;
      case WarningMessageType.audioImportedToPlaylist:
        final String importedAudioFileNames =
            _warningMessageVM.getNextWarningMessageElements();

        if (importedAudioFileNames.isNotEmpty) {
          String audioImportedFromToPlaylistMessage;

          if (_warningMessageVM.importedToPlaylistType == PlaylistType.local) {
            audioImportedFromToPlaylistMessage =
                AppLocalizations.of(context)!.audioImportedToLocalPlaylist(
              importedAudioFileNames,
              _warningMessageVM.importedToPlaylistTitle,
            );
          } else {
            audioImportedFromToPlaylistMessage =
                AppLocalizations.of(context)!.audioImportedToYoutubePlaylist(
              importedAudioFileNames,
              _warningMessageVM.importedToPlaylistTitle,
            );
          }

          _displayWarningDialog(
            context: context,
            message: audioImportedFromToPlaylistMessage,
            themeProviderVM: themeProviderVM,
            warningMode: WarningMode.confirm,
          );
        }
        break;
      default:
        break;
    }
  }

  void _scrollToCurrentAudioItem() {
    double offset = 20000; // A large number to scroll to the bottom of the list

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
      _scrollController.animateTo(
        offset,
        duration: kScrollDuration,
        curve: Curves.easeInOut,
      );
    } else {
      // The scroll controller isn't attached to any scroll views.
      // Schedule a callback to try again after the next frame.
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToCurrentAudioItem());
    }
  }
}

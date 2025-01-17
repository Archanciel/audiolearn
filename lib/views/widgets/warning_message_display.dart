import 'package:audiolearn/views/widgets/set_value_to_target_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/playlist.dart';
import '../../constants.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../../viewmodels/warning_message_vm.dart';
import '../screen_mixin.dart';

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

            if (exceptionMessage.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _displayWarningDialog(
                  context: _context,
                  message: AppLocalizations.of(context)!
                      .downloadAudioYoutubeError(exceptionMessage),
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
                  themeProviderVM: themeProviderVM);
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
                  themeProviderVM: themeProviderVM);
            });

            return const SizedBox.shrink();
          case ErrorType.errorInPlaylistJsonFile:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _displayWarningDialog(
                  context: _context,
                  message:
                      AppLocalizations.of(context)!.errorInPlaylistJsonFile(
                    _warningMessageVM.errorArgOne,
                  ),
                  warningMessageVM: _warningMessageVM,
                  themeProviderVM: themeProviderVM);
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

          String addPlaylistTitle;

          if (_warningMessageVM.addedPlaylistType == PlaylistType.local) {
            addPlaylistTitle = AppLocalizations.of(context)!
                .addLocalPlaylistTitle(addedPlayListTitle, playlistQualityStr);
          } else {
            // Youtube playlist is added
            addPlaylistTitle = AppLocalizations.of(context)!
                .addYoutubePlaylistTitle(
                    addedPlayListTitle, playlistQualityStr);
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _displayWarningDialog(
                context: _context,
                message: addPlaylistTitle,
                warningMessageVM: _warningMessageVM,
                themeProviderVM: themeProviderVM);
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

        if (_warningMessageVM.invalidValueState == InvalidValueState.tooBig) {
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
            if (_warningMessageVM.movedToTargetPlaylistType ==
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
      case WarningMessageType.audioNotMovedFromToPlaylist:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          String audioMovedFromToPlaylistMessage;

          if (_warningMessageVM.movedFromPlaylistType == PlaylistType.local) {
            if (_warningMessageVM.movedToPlaylistType == PlaylistType.local) {
              audioMovedFromToPlaylistMessage = AppLocalizations.of(context)!
                  .audioNotMovedFromLocalPlaylistToLocalPlaylist(
                _warningMessageVM.movedAudioValidVideoTitle,
                _warningMessageVM.movedFromPlaylistTitle,
                _warningMessageVM.movedToPlaylistTitle,
              );
            } else {
              audioMovedFromToPlaylistMessage = AppLocalizations.of(context)!
                  .audioNotMovedFromLocalPlaylistToYoutubePlaylist(
                _warningMessageVM.movedAudioValidVideoTitle,
                _warningMessageVM.movedFromPlaylistTitle,
                _warningMessageVM.movedToPlaylistTitle,
              );
            }
          } else {
            if (!_warningMessageVM.keepAudioDataInSourcePlaylist) {
              if (_warningMessageVM.movedToPlaylistType == PlaylistType.local) {
                audioMovedFromToPlaylistMessage = AppLocalizations.of(context)!
                    .audioNotMovedFromYoutubePlaylistToLocalPlaylist(
                  _warningMessageVM.movedAudioValidVideoTitle,
                  _warningMessageVM.movedFromPlaylistTitle,
                  _warningMessageVM.movedToPlaylistTitle,
                );
              } else {
                audioMovedFromToPlaylistMessage = AppLocalizations.of(context)!
                    .audioNotMovedFromYoutubePlaylistToYoutubePlaylist(
                  _warningMessageVM.movedAudioValidVideoTitle,
                  _warningMessageVM.movedFromPlaylistTitle,
                  _warningMessageVM.movedToPlaylistTitle,
                );
              }
            } else {
              if (_warningMessageVM.movedToPlaylistType == PlaylistType.local) {
                audioMovedFromToPlaylistMessage = AppLocalizations.of(context)!
                    .audioNotMovedFromYoutubePlaylistToLocalPlaylist(
                  _warningMessageVM.movedAudioValidVideoTitle,
                  _warningMessageVM.movedFromPlaylistTitle,
                  _warningMessageVM.movedToPlaylistTitle,
                );
              } else {
                audioMovedFromToPlaylistMessage = AppLocalizations.of(context)!
                    .audioNotMovedFromYoutubePlaylistToYoutubePlaylist(
                  _warningMessageVM.movedAudioValidVideoTitle,
                  _warningMessageVM.movedFromPlaylistTitle,
                  _warningMessageVM.movedToPlaylistTitle,
                );
              }
            }
          }
          _displayWarningDialog(
            context: _context,
            message: audioMovedFromToPlaylistMessage,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
            warningMode: WarningMode.warning,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.audioNotCopiedFromToPlaylist:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          String audioCopiedFromToPlaylistMessage;

          if (_warningMessageVM.copiedFromPlaylistType == PlaylistType.local) {
            if (_warningMessageVM.copiedToPlaylistType == PlaylistType.local) {
              audioCopiedFromToPlaylistMessage = AppLocalizations.of(context)!
                  .audioNotCopiedFromLocalPlaylistToLocalPlaylist(
                _warningMessageVM.copiedAudioValidVideoTitle,
                _warningMessageVM.copiedFromPlaylistTitle,
                _warningMessageVM.copiedToPlaylistTitle,
              );
            } else {
              audioCopiedFromToPlaylistMessage = AppLocalizations.of(context)!
                  .audioNotCopiedFromLocalPlaylistToYoutubePlaylist(
                _warningMessageVM.copiedAudioValidVideoTitle,
                _warningMessageVM.copiedFromPlaylistTitle,
                _warningMessageVM.copiedToPlaylistTitle,
              );
            }
          } else {
            if (_warningMessageVM.copiedToPlaylistType == PlaylistType.local) {
              audioCopiedFromToPlaylistMessage = AppLocalizations.of(context)!
                  .audioNotCopiedFromYoutubePlaylistToLocalPlaylist(
                _warningMessageVM.copiedAudioValidVideoTitle,
                _warningMessageVM.copiedFromPlaylistTitle,
                _warningMessageVM.copiedToPlaylistTitle,
              );
            } else {
              audioCopiedFromToPlaylistMessage = AppLocalizations.of(context)!
                  .audioNotCopiedFromYoutubePlaylistToYoutubePlaylist(
                _warningMessageVM.copiedAudioValidVideoTitle,
                _warningMessageVM.copiedFromPlaylistTitle,
                _warningMessageVM.copiedToPlaylistTitle,
              );
            }
          }
          _displayWarningDialog(
            context: _context,
            message: audioCopiedFromToPlaylistMessage,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
            warningMode: WarningMode.warning,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.audioMovedFromToPlaylist:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          String audioMovedFromToPlaylistMessage;

          if (_warningMessageVM.movedFromPlaylistType == PlaylistType.local) {
            if (_warningMessageVM.movedToPlaylistType == PlaylistType.local) {
              audioMovedFromToPlaylistMessage = AppLocalizations.of(context)!
                  .audioMovedFromLocalPlaylistToLocalPlaylist(
                _warningMessageVM.movedAudioValidVideoTitle,
                _warningMessageVM.movedFromPlaylistTitle,
                _warningMessageVM.movedToPlaylistTitle,
              );
            } else {
              audioMovedFromToPlaylistMessage = AppLocalizations.of(context)!
                  .audioMovedFromLocalPlaylistToYoutubePlaylist(
                _warningMessageVM.movedAudioValidVideoTitle,
                _warningMessageVM.movedFromPlaylistTitle,
                _warningMessageVM.movedToPlaylistTitle,
              );
            }
          } else {
            if (!_warningMessageVM.keepAudioDataInSourcePlaylist) {
              // Situation in which the user unchecked the checkbox
              // to keep the audio data in the source playlist
              if (_warningMessageVM.movedToPlaylistType == PlaylistType.local) {
                audioMovedFromToPlaylistMessage = AppLocalizations.of(context)!
                    .audioMovedFromYoutubePlaylistToLocalPlaylistPlaylistWarning(
                  _warningMessageVM.movedAudioValidVideoTitle,
                  _warningMessageVM.movedFromPlaylistTitle,
                  _warningMessageVM.movedToPlaylistTitle,
                );
              } else {
                audioMovedFromToPlaylistMessage = AppLocalizations.of(context)!
                    .audioMovedFromYoutubePlaylistToYoutubePlaylistPlaylistWarning(
                  _warningMessageVM.movedAudioValidVideoTitle,
                  _warningMessageVM.movedFromPlaylistTitle,
                  _warningMessageVM.movedToPlaylistTitle,
                );
              }
            } else {
              if (_warningMessageVM.movedToPlaylistType == PlaylistType.local) {
                audioMovedFromToPlaylistMessage = AppLocalizations.of(context)!
                    .audioMovedFromYoutubePlaylistToLocalPlaylist(
                  _warningMessageVM.movedAudioValidVideoTitle,
                  _warningMessageVM.movedFromPlaylistTitle,
                  _warningMessageVM.movedToPlaylistTitle,
                );
              } else {
                audioMovedFromToPlaylistMessage = AppLocalizations.of(context)!
                    .audioMovedFromYoutubePlaylistToYoutubePlaylist(
                  _warningMessageVM.movedAudioValidVideoTitle,
                  _warningMessageVM.movedFromPlaylistTitle,
                  _warningMessageVM.movedToPlaylistTitle,
                );
              }
            }
          }
          _displayWarningDialog(
            context: _context,
            message: audioMovedFromToPlaylistMessage,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
            warningMode: WarningMode.confirm,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.audioCopiedFromToPlaylist:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          String audioCopiedFromToPlaylistMessage;

          if (_warningMessageVM.copiedFromPlaylistType == PlaylistType.local) {
            if (_warningMessageVM.copiedToPlaylistType == PlaylistType.local) {
              audioCopiedFromToPlaylistMessage = AppLocalizations.of(context)!
                  .audioCopiedFromLocalPlaylistToLocalPlaylist(
                _warningMessageVM.copiedAudioValidVideoTitle,
                _warningMessageVM.copiedFromPlaylistTitle,
                _warningMessageVM.copiedToPlaylistTitle,
              );
            } else {
              audioCopiedFromToPlaylistMessage = AppLocalizations.of(context)!
                  .audioCopiedFromLocalPlaylistToYoutubePlaylist(
                _warningMessageVM.copiedAudioValidVideoTitle,
                _warningMessageVM.copiedFromPlaylistTitle,
                _warningMessageVM.copiedToPlaylistTitle,
              );
            }
          } else {
            if (_warningMessageVM.copiedToPlaylistType == PlaylistType.local) {
              audioCopiedFromToPlaylistMessage = AppLocalizations.of(context)!
                  .audioCopiedFromYoutubePlaylistToLocalPlaylist(
                _warningMessageVM.copiedAudioValidVideoTitle,
                _warningMessageVM.copiedFromPlaylistTitle,
                _warningMessageVM.copiedToPlaylistTitle,
              );
            } else {
              audioCopiedFromToPlaylistMessage = AppLocalizations.of(context)!
                  .audioCopiedFromYoutubePlaylistToYoutubePlaylist(
                _warningMessageVM.copiedAudioValidVideoTitle,
                _warningMessageVM.copiedFromPlaylistTitle,
                _warningMessageVM.copiedToPlaylistTitle,
              );
            }
          }
          _displayWarningDialog(
            context: _context,
            message: audioCopiedFromToPlaylistMessage,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
            warningMode: WarningMode.confirm,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.savedAppDataToZip:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          String savedAppDataToZipMessage;

          if (_warningMessageVM.zipFilePathName != '') {
            savedAppDataToZipMessage =
                AppLocalizations.of(context)!.savedAppDataToZip(
              _warningMessageVM.zipFilePathName,
            );

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
  }) {
    // The focus node must be created here, otherwise displaying
    // the dialog will cause an error.
    final focusNodeDialog = FocusNode();
    String alertDialogTitle = '';

    switch (warningMode) {
      case WarningMode.warning:
        alertDialogTitle = AppLocalizations.of(context)!.warningDialogTitle;
        break;
      case WarningMode.confirm:
        alertDialogTitle = AppLocalizations.of(context)!.confirmDialogTitle;
        break;
    }

    showDialog<void>(
      context: context,
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
          title: Text(
            key: const Key('warningDialogTitle'),
            alertDialogTitle,
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

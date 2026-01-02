import 'dart:io';

import 'package:audiolearn/constants.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import '../models/audio.dart';
import '../models/comment.dart';
import '../models/playlist.dart';
import '../services/json_data_service.dart';
import '../utils/date_time_util.dart';
import '../utils/dir_util.dart';
import 'playlist_list_vm.dart';

class CommentPlayCommand {
  Audio commentAudioCopy;
  int previousAudioIndex;

  CommentPlayCommand({
    required this.commentAudioCopy,
    required this.previousAudioIndex,
  });
}

/// This VM (View Model) class is part of the MVVM architecture.
///
/// This class manages the audio player obtained from the
class CommentVM extends ChangeNotifier {
  Duration _currentCommentStartPosition = Duration.zero;
  Duration get currentCommentStartPosition => _currentCommentStartPosition;
  set currentCommentStartPosition(Duration value) {
    _currentCommentStartPosition = value;
    notifyListeners();
  }

  Duration _currentCommentEndPosition = Duration.zero;
  Duration get currentCommentEndPosition => _currentCommentEndPosition;
  set currentCommentEndPosition(Duration value) {
    _currentCommentEndPosition = value;
    notifyListeners();
  }

  final List<CommentPlayCommand> _undoCommentPlayCommandLst = [];

  // Used to manage second line play/pause button in audio player
  // view. This button is not displayed if comment dialog was opened
  // and/or minimized.
  bool _wasCommentDialogOpened = false;
  bool get wasCommentDialogOpened => _wasCommentDialogOpened;
  set wasCommentDialogOpened(bool value) {
    _wasCommentDialogOpened = value;
    notifyListeners();
  }

  // **NEW**: Notifier to signal when the comment dialog should refresh
  // for a new audio. This will be used by comment dialogs to listen
  // for audio changes and automatically refresh their content.
  final ValueNotifier<Audio?> commentDialogRefreshNotifier =
      ValueNotifier<Audio?>(null);

  CommentVM();

  @override
  void dispose() {
    // **NEW**: Dispose the new notifier
    commentDialogRefreshNotifier.dispose();
    super.dispose();
  }

  /// **NEW**: Method to notify comment dialogs that they should refresh
  /// for a new audio. This is called when the audio automatically changes
  /// to the next audio.
  void notifyCommentDialogToRefresh(Audio newAudio) {
    commentDialogRefreshNotifier.value = newAudio;
  }

  /// If the comment file exists, the list of comments it contains is
  /// returned, else, an empty list is returned.
  List<Comment> loadAudioComments({
    required Audio audio,
  }) {
    return JsonDataService.loadListFromFile(
      jsonPathFileName: buildCommentFilePathName(
        playlistDownloadPath: audio.enclosingPlaylist!.downloadPath,
        audioFileName: audio.audioFileName,
      ),
      type: Comment,
    );
  }

  /// If the comment file exists, the list of comments it contains is
  /// returned, else, an empty list is returned.
  List<Comment> loadCommentsFromFile({
    required String commentFilePathName,
  }) {
    return JsonDataService.loadListFromFile(
      jsonPathFileName: commentFilePathName,
      type: Comment,
    );
  }

  Comment? getLastCommentOfAudio({
    required Audio audio,
  }) {
    List<Comment> commentLst = loadAudioComments(
      audio: audio,
    );

    if (commentLst.isNotEmpty) {
      commentLst.sort(
        (a, b) => b.lastUpdateDateTime.compareTo(a.lastUpdateDateTime),
      );

      return commentLst.first;
    }

    return null;
  }

  int getCommentNumber({
    required Audio audio,
  }) {
    return loadAudioComments(
      audio: audio,
    ).length;
  }

  void addComment({
    required Comment addedComment,
    required Audio audioToComment,
  }) {
    List<Comment> commentLst = loadAudioComments(
      audio: audioToComment,
    );

    String commentFilePathName = buildCommentFilePathName(
      playlistDownloadPath: audioToComment.enclosingPlaylist!.downloadPath,
      audioFileName: audioToComment.audioFileName,
    );

    if (commentLst.isEmpty) {
      // Create the comment dir so that the comment file can be created
      DirUtil.createDirIfNotExistSync(
        pathStr: DirUtil.getPathFromPathFileName(
          pathFileName: commentFilePathName,
        ),
      );
    }

    commentLst.add(addedComment);

    _sortAndSaveCommentLst(
      commentLst: commentLst,
      commentFilePathName: commentFilePathName,
    );

    notifyListeners();
  }

  /// Returns a string which is the combination of the path of the comment directory
  /// and the file name to the maybe not yet existing comment file.
  static String buildCommentFilePathName({
    required String playlistDownloadPath,
    required String audioFileName,
  }) {
    final String createdCommentFileName =
        audioFileName.replaceAll('.mp3', '.json');
    final String playlistCommentPath;

    if (playlistDownloadPath.contains('/')) {
      // run on Android
      playlistCommentPath = path.posix.join(
        playlistDownloadPath,
        kCommentDirName,
      );

      return path.posix.join(
        playlistCommentPath,
        createdCommentFileName,
      );
    } else {
      playlistCommentPath =
          "$playlistDownloadPath${path.separator}$kCommentDirName";

      return "$playlistCommentPath${path.separator}$createdCommentFileName";
    }
  }

  void _sortAndSaveCommentLst({
    required List<Comment> commentLst,
    required String commentFilePathName,
  }) {
    commentLst.sort(
      (a, b) => a.commentStartPositionInTenthOfSeconds
          .compareTo(b.commentStartPositionInTenthOfSeconds),
    );

    JsonDataService.saveListToFile(
      data: commentLst,
      jsonPathFileName: commentFilePathName,
    );
  }

  /// this method is uniquely used as a parameter for the application confirm
  /// dialog.
  void deleteCommentFunction(
    String commentId,
    Audio commentedAudio,
  ) {
    deleteComment(
      commentId: commentId,
      commentedAudio: commentedAudio,
    );
  }

  void deleteComment({
    required String commentId,
    required Audio commentedAudio,
  }) {
    List<Comment> commentLst = loadAudioComments(
      audio: commentedAudio,
    );

    commentLst.remove(
      commentLst.firstWhere(
        (element) => element.id == commentId,
      ),
    );

    if (commentLst.isEmpty) {
      // If the comment list is empty, delete the comment file
      // and the comment directory if it is empty.
      deleteAllAudioComments(
        commentedAudio: commentedAudio,
      );

      return;
    }

    JsonDataService.saveListToFile(
      data: commentLst,
      jsonPathFileName: buildCommentFilePathName(
        playlistDownloadPath: commentedAudio.enclosingPlaylist!.downloadPath,
        audioFileName: commentedAudio.audioFileName,
      ),
    );

    notifyListeners();
  }

  /// Deletes all comments of the passed audio.
  void deleteAllAudioComments({
    required Audio commentedAudio,
  }) {
    DirUtil.deleteFileIfExist(
      pathFileName: buildCommentFilePathName(
        playlistDownloadPath: commentedAudio.enclosingPlaylist!.downloadPath,
        audioFileName: commentedAudio.audioFileName,
      ),
    );

    // Delete the comment directory if it is empty
    String commentDirPath =
        "${commentedAudio.enclosingPlaylist!.downloadPath}${path.separator}$kCommentDirName";
    DirUtil.deleteDirIfEmpty(
      pathStr: commentDirPath,
    );

    notifyListeners();
  }

  /// This method is executed in order to combine the audio existing comments
  /// with the corresponding comments contained in the restore zip file. The
  /// method handles two cases:
  ///
  /// 1. If the update comment already exists in the audio comment json file,
  /// the corresponding existing comment is modified if the update comment
  /// last update date time is after the existing comment last update date time.
  ///
  /// 2. If the update comment does not exist in the audio comment json file, it
  /// is added to the audio comment file.
  ///
  /// The method returns a list containing two integers:
  /// - The first integer is the number of modified comments.
  /// - The second integer is the number of added comments.
  /// - The third integer is the number of added comment json file.
  List<int> updateAudioComments({
    required Audio commentedAudio,
    required List<Comment> updateCommentsLst,
  }) {
    int modifiedCommentNumber = 0;

    // This variable is incremented if a comment is added to an
    // audio which already has a comment file.
    int addedCommentNumber = 0;

    // This variable is incremented if a comment is added to an
    // audio which does not yet have a comment file.
    int addedCommentJsonFileNumber = 0;

    List<Comment> existingCommentsLst = loadAudioComments(
      audio: commentedAudio,
    );

    bool isInitialExistingCommentsLstEmpty = existingCommentsLst.isEmpty;

    for (Comment updatedComment in updateCommentsLst) {
      // Check if the comment already exists
      Comment? existingComment = existingCommentsLst.firstWhereOrNull(
        (element) => element.id == updatedComment.id,
      );

      if (existingComment != null) {
        // If the comment already exists, modify it if the update comment
        // last update date time is after the existing comment
        // last update date time.
        if (updatedComment.lastUpdateDateTime
            .isAfter(existingComment.lastUpdateDateTime)) {
          // If the update comment last update date time is after the existing
          // comment last update date time, modify the existing comment.
          existingComment.title = updatedComment.title;
          existingComment.content = updatedComment.content;
          existingComment.commentStartPositionInTenthOfSeconds =
              updatedComment.commentStartPositionInTenthOfSeconds;
          existingComment.commentEndPositionInTenthOfSeconds =
              updatedComment.commentEndPositionInTenthOfSeconds;
          existingComment.silenceDuration = updatedComment.silenceDuration;
          existingComment.fadeInDuration = updatedComment.fadeInDuration;
          existingComment.soundReductionPosition =
              updatedComment.soundReductionPosition;
          existingComment.soundReductionDuration =
              updatedComment.soundReductionDuration;
          existingComment.deleted = updatedComment.deleted;
          existingComment.lastUpdateDateTime =
              updatedComment.lastUpdateDateTime;
          modifiedCommentNumber++;
        } else {
          // If the update comment last update date time is before or equal to
          // the existing comment last update date time, skip the modification.
          continue;
        }
      } else if (existingCommentsLst.isEmpty) {
        // Comment added to an audio which did not yet have a comment file
        existingCommentsLst.add(updatedComment);
        addedCommentJsonFileNumber++;
      } else {
        // Comment added to an audio which already had a comment file
        existingCommentsLst.add(updatedComment);
        addedCommentNumber++;
      }
    }

    final String commentFilePathName = buildCommentFilePathName(
      playlistDownloadPath: commentedAudio.enclosingPlaylist!.downloadPath,
      audioFileName: commentedAudio.audioFileName,
    );

    if (isInitialExistingCommentsLstEmpty) {
      // Create the comment dir so that the comment file can be created
      DirUtil.createDirIfNotExistSync(
        pathStr: DirUtil.getPathFromPathFileName(
          pathFileName: commentFilePathName,
        ),
      );
    }

    _sortAndSaveCommentLst(
      commentLst: existingCommentsLst,
      commentFilePathName: commentFilePathName,
    );

    notifyListeners();

    return [
      modifiedCommentNumber,
      addedCommentNumber,
      addedCommentJsonFileNumber,
    ];
  }

  void modifyComment({
    required Comment modifiedComment,
    required Audio commentedAudio,
  }) {
    List<Comment> commentLst = loadAudioComments(
      audio: commentedAudio,
    );

    Comment oldComment = commentLst.firstWhere(
      (element) => element.id == modifiedComment.id,
    );

    oldComment.title = modifiedComment.title;
    oldComment.content = modifiedComment.content;
    oldComment.commentStartPositionInTenthOfSeconds =
        modifiedComment.commentStartPositionInTenthOfSeconds;
    oldComment.commentEndPositionInTenthOfSeconds =
        modifiedComment.commentEndPositionInTenthOfSeconds;

    // If the modified comment last update date time is null, it
    // means that the comment was modified by the user.
    oldComment.lastUpdateDateTime =
        DateTimeUtil.getDateTimeLimitedToSeconds(DateTime.now());

    _sortAndSaveCommentLst(
      commentLst: commentLst,
      commentFilePathName: buildCommentFilePathName(
        playlistDownloadPath: commentedAudio.enclosingPlaylist!.downloadPath,
        audioFileName: commentedAudio.audioFileName,
      ),
    );

    notifyListeners();
  }

  /// If the passed audio has a comment file, it is moved to the target playlist
  /// and true is returned. If the audio has no comment file, false is returned.
  bool moveAudioCommentFileToTargetPlaylist({
    required Audio audio,
    required String targetPlaylistPath,
  }) {
    String commentFilePathName = buildCommentFilePathName(
      playlistDownloadPath: audio.enclosingPlaylist!.downloadPath,
      audioFileName: audio.audioFileName,
    );

    String targetCommentDirPath =
        "$targetPlaylistPath${path.separator}$kCommentDirName";

    // Create the target comment directory if it does not exist
    DirUtil.createDirIfNotExistSync(
      pathStr: targetCommentDirPath,
    );

    if (File(commentFilePathName).existsSync()) {
      DirUtil.moveFileToDirectoryIfNotExistSync(
        sourceFilePathName: commentFilePathName,
        targetDirectoryPath: targetCommentDirPath,
      );

      return true;
    }

    return false;
  }

  /// If the passed audio has a comment file, it is copied to the target playlist
  /// and true is returned. If the audio has no comment file, false is returned.
  bool copyAudioCommentFileToTargetPlaylist({
    required Audio audio,
    required String targetPlaylistPath,
  }) {
    String commentFilePathName = buildCommentFilePathName(
      playlistDownloadPath: audio.enclosingPlaylist!.downloadPath,
      audioFileName: audio.audioFileName,
    );

    String targetCommentDirPath =
        "$targetPlaylistPath${path.separator}$kCommentDirName";

    // Create the target comment directory if it does not exist
    DirUtil.createDirIfNotExistSync(
      pathStr: targetCommentDirPath,
    );

    // Copy the comment file to the target playlist comment directory

    if (File(commentFilePathName).existsSync()) {
      DirUtil.copyFileToDirectorySync(
        sourceFilePathName: commentFilePathName,
        targetDirectoryPath: targetCommentDirPath,
        overwriteFileIfExist: false,
      );

      return true;
    }

    return false;
  }

  /// Returns all comments of all audio in the passed playlist. The
  /// comments are returned as a map with the audio file name without
  /// extension as key.
  Map<String, List<Comment>> getPlaylistAudioComments({
    required Playlist playlist,
  }) {
    String playlistPath = playlist.downloadPath;
    Map<String, List<Comment>> playlistAudiosCommentsMap = {};

    String commentPath = "$playlistPath${path.separator}$kCommentDirName";

    List<String> commentFileNamesLst = DirUtil.listFileNamesInDir(
      directoryPath: commentPath,
      fileExtension: 'json',
    );

    for (String commentFileName in commentFileNamesLst) {
      List<Comment> audioCommentsLst = JsonDataService.loadListFromFile(
        jsonPathFileName: "$commentPath${path.separator}$commentFileName",
        type: Comment,
      );

      // Remove the file extension from the comment file name. Since the
      // extension is ".json", the length of the file name is reduced by 5.
      playlistAudiosCommentsMap[commentFileName.substring(
          0, commentFileName.length - 5)] = audioCommentsLst;
    }

    return playlistAudiosCommentsMap;
  }

  int getPlaylistAudioCommentJsonFilesNumber({
    required Playlist playlist,
  }) {
    String playlistCommentPath =
        "${playlist.downloadPath}${path.separator}$kCommentDirName";

    return DirUtil.countFilesInDir(
      directoryPath: playlistCommentPath,
      fileExtension: 'json',
    );
  }

  int getPlaylistAudioCommentNumber({
    required Playlist playlist,
  }) {
    int commentNumber = 0;

    Map<String, List<Comment>> playlistAudiosCommentsMap =
        getPlaylistAudioComments(
      playlist: playlist,
    );

    for (List<Comment> audioComments in playlistAudiosCommentsMap.values) {
      commentNumber += audioComments.length;
    }

    return commentNumber;
  }

  /// Method called when te user clicks on play icon of a comment listed in
  /// the playlist comment list dialog. In this case, playing a comment from there
  /// usually changes the playlist current audio index and modifies the commented
  /// audio position. If the audio was fully played, it will be then partially
  /// played. Thanks to this method, it is possible to undo the changes made to
  /// the playlist current audio index as well as the commented audio position.
  /// This undo action is done by calling the undoAllRecordedCommentPlayCommands
  /// method coded below. This is done when the user closes the playlist comment
  /// list dialog.
  void addCommentPlayCommandToUndoPlayCommandLst({
    required Audio commentAudioCopy,
    required int previousAudioIndex,
  }) {
    CommentPlayCommand commentPlayCommand = CommentPlayCommand(
      commentAudioCopy: commentAudioCopy,
      previousAudioIndex: previousAudioIndex,
    );

    _undoCommentPlayCommandLst.add(commentPlayCommand);
  }

  /// This method is called when the user closes the playlist comment list dialog.
  /// It is used to undo all the changes made to the playlist current audio index
  /// as well as the position of the listened comments audio.
  void undoAllRecordedCommentPlayCommands({
    required PlaylistListVM playlistListVM,
  }) {
    if (_undoCommentPlayCommandLst.isNotEmpty) {
      for (int i = _undoCommentPlayCommandLst.length - 1; i >= 0; i--) {
        CommentPlayCommand commentPlayCommand = _undoCommentPlayCommandLst[i];

        playlistListVM.updateCurrentOrPastPlayableAudio(
          audioCopy: commentPlayCommand.commentAudioCopy,
          previousAudioIndex: commentPlayCommand.previousAudioIndex,
        );
      }

      _undoCommentPlayCommandLst.clear();
    }
  }
}

import 'dart:io';

import 'package:audiolearn/constants.dart';
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

  CommentVM();

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

  int getCommentNumber({
    required Audio audio,
  }) {
    return loadAudioComments(
      audio: audio,
    ).length;
  }

  void addComment({
    required Comment comment,
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

    commentLst.add(comment);

    _sortAndSaveCommentLst(
      commentLst: commentLst,
      commentFilePathName: commentFilePathName,
    );

    // Add comment to the database
    notifyListeners();
  }

  /// Returns a list of two strings. The first string is the path to the
  /// comment directory, and the second string is the path file name to the
  /// maybe not yet existing comment file.
  static String buildCommentFilePathName({
    required String playlistDownloadPath,
    required String audioFileName,
  }) {
    final String playlistCommentPath =
        "$playlistDownloadPath${path.separator}$kCommentDirName";

    final String createdCommentFileName =
        audioFileName.replaceAll('.mp3', '.json');

    return "$playlistCommentPath${path.separator}$createdCommentFileName";
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

    notifyListeners();
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

  void copyAudioCommentFileToTargetPlaylist({
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
    }
  }

  /// Returns all comments of all audio in the passed playlist. The
  /// comments are returned as a map with the audio file name without
  /// extension as the key.
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
  /// method coded below. This method is called when the user closes the playlist
  /// comment list dialog.
  void addUndoableCommentPlayCommand({
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

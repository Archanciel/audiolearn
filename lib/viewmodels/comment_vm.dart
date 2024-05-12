import 'dart:io';

import 'package:audiolearn/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import '../models/audio.dart';
import '../models/comment.dart';
import '../services/json_data_service.dart';
import '../utils/dir_util.dart';

/// This VM (View Model) class is part of the MVVM architecture.
///
/// This class manages the audio player obtained from the
class CommentVM extends ChangeNotifier {
  CommentVM();

  void addComment({
    required Comment comment,
    required Audio commentedAudio,
  }) {
    String playListDir = commentedAudio.enclosingPlaylist!.downloadPath;

    loadOrCreateCommentFile(
      playListDir: playListDir,
      audioFileName: commentedAudio.audioFileName,
    );
    ;
    // Add comment to the database
    notifyListeners();
  }

  Future<List<Comment>> loadOrCreateCommentFile({
    required String playListDir,
    required String audioFileName,
  }) async {
    String commentFileName = audioFileName.replaceAll('.mp3', '.json');
    String playlistCommentPath = "$playListDir${path.separator}$kCommentDirName";
    String commentFilePathName =
        "$playlistCommentPath${path.separator}$commentFileName";
    File commentFile = File(commentFilePathName);

    // Load the list from the file
    List<Comment> commentLst = [];

    if (commentFile.existsSync()) {
      // Load the comment file
      commentLst = JsonDataService.loadListFromFile(
        jsonPathFileName: commentFilePathName,
        type: Comment,
      );
    } else {
      // Create the comment file
      await DirUtil.createDirIfNotExist(
        pathStr: playlistCommentPath,
      );

      JsonDataService.saveListToFile(
        data: commentLst,
        jsonPathFileName: commentFilePathName,
      );
    }

    return commentLst;
  }
}

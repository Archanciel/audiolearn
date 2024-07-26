import 'dart:collection';

import 'package:flutter/material.dart';

import '../models/playlist.dart';

enum WarningMessageType {
  none,
  errorMessage,
  audioNotImportedToPlaylist,
}

class WarningMessageVM extends ChangeNotifier {
  WarningMessageType warningMessageType = WarningMessageType.none;

  final Queue<String> _messageQueue = Queue<String>();

  void addMessage(String message) {
    _messageQueue.add(message);
    notifyListeners();
  }

  String getNextMessage() {
    return _messageQueue.isNotEmpty ? _messageQueue.removeFirst() : '';
  }

  void setAudioNotImportedToPlaylistTitles({
    required String rejectedImportedAudioFileNames,
    required String importedToPlaylistTitle,
    required PlaylistType importedToPlaylistType,
  }) {
    addMessage('Audio not imported: $rejectedImportedAudioFileNames');
    notifyListeners();
  }
}

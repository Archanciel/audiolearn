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
  bool _isDisplaying = false;

  void addMessage(String message) {
    _messageQueue.add(message);
    if (!_isDisplaying) {
      _isDisplaying = true;
      _displayNextMessage();
    }
  }

  void _displayNextMessage() {
    if (_messageQueue.isNotEmpty) {
      notifyListeners();
    } else {
      _isDisplaying = false;
    }
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
  }

  void messageDisplayed() {
    _displayNextMessage();
  }
}

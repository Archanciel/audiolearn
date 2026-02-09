import 'comment.dart';

class MultiAudioComments {
  final Map<String, List<Comment>> audioCommentsMap;

  MultiAudioComments({
    required this.audioCommentsMap,
  });

  Map<String, dynamic> toJson() {
    return {
      'audioCommentsMap': audioCommentsMap.map(
        (audioFileName, comments) => MapEntry(
          audioFileName,
          comments.map((c) => c.toJson()).toList(),
        ),
      ),
    };
  }

  factory MultiAudioComments.fromJson(Map<String, dynamic> json) {
    final Map<String, List<Comment>> map = {};

    final audioCommentsMap = json['audioCommentsMap'] as Map<String, dynamic>;
    audioCommentsMap.forEach((audioFileName, commentsList) {
      final List<Comment> comments = (commentsList as List)
          .map((commentJson) => Comment.fromJson(commentJson))
          .toList();
      map[audioFileName] = comments;
    });

    return MultiAudioComments(audioCommentsMap: map);
  }
}

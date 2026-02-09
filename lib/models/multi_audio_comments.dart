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

    try {
      final audioCommentsMap =
          json['audioCommentsMap'] as Map<String, dynamic>?;

      if (audioCommentsMap == null) {
        throw Exception('Missing audioCommentsMap in JSON');
      }

      audioCommentsMap.forEach((audioFileName, commentsList) {
        if (commentsList is! List) {
          throw Exception('Invalid comments list for $audioFileName');
        }

        final List<Comment> comments = [];
        for (var commentJson in commentsList) {
          try {
            comments.add(Comment.fromJson(commentJson as Map<String, dynamic>));
          } catch (e) {
            print('Error parsing comment in $audioFileName: $e');
            // Skip this comment but continue with others
          }
        }

        if (comments.isNotEmpty) {
          map[audioFileName] = comments;
        }
      });

      return MultiAudioComments(audioCommentsMap: map);
    } catch (e) {
      print('Error in MultiAudioComments.fromJson: $e');
      rethrow;
    }
  }
}

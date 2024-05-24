import '../utils/date_time_util.dart';

class Comment {
  String id;
  String title;
  String content;
  int audioPositionInTenthOfSeconds;
  int commentEndAudioPositionInTenthOfSeconds;
  final DateTime creationDateTime;
  late DateTime lastUpdateDateTime;

  Comment({
    required this.title,
    required this.content,
    required this.audioPositionInTenthOfSeconds,
    this.commentEndAudioPositionInTenthOfSeconds = 0,
  })  : id = "${title}_${audioPositionInTenthOfSeconds.toString()}",
        creationDateTime =
            DateTimeUtil.getDateTimeLimitedToSeconds(DateTime.now()) {
    lastUpdateDateTime = creationDateTime;
  }

  /// This constructor requires all instance variables. It is used
  /// by the fromJson factory constructor.
  Comment.fullConstructor({
    required this.id,
    required this.title,
    required this.content,
    required this.audioPositionInTenthOfSeconds,
    required this.commentEndAudioPositionInTenthOfSeconds,
    required this.creationDateTime,
    required this.lastUpdateDateTime,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment.fullConstructor(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      audioPositionInTenthOfSeconds: json['audioPositionInTenthOfSeconds'],
      commentEndAudioPositionInTenthOfSeconds: json['commentEndAudioPositionInTenthOfSeconds'] ?? 0,
      creationDateTime: DateTime.parse(json['creationDateTime']),
      lastUpdateDateTime: DateTime.parse(json['lastUpdateDateTime']),
    );
  }

  // Method: converts an instance of Comment to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'audioPositionInTenthOfSeconds': audioPositionInTenthOfSeconds,
      'commentEndAudioPositionInTenthOfSeconds': commentEndAudioPositionInTenthOfSeconds,
      'creationDateTime': creationDateTime.toIso8601String(),
      'lastUpdateDateTime': lastUpdateDateTime.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Comment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

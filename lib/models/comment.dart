import '../utils/date_time_util.dart';

class Comment {
  String id;
  String title;
  String content;
  int audioPositionSeconds;
  final DateTime creationDateTime;
  late DateTime lastUpdateDateTime;

  Comment({
    required this.title,
    required this.content,
    required this.audioPositionSeconds,
  })  : id = "${title}_${audioPositionSeconds.toString()}",
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
    required this.audioPositionSeconds,
    required this.creationDateTime,
    required this.lastUpdateDateTime,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment.fullConstructor(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      audioPositionSeconds: json['audioPositionSeconds'],
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
      'audioPositionSeconds': audioPositionSeconds,
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

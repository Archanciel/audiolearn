import '../utils/date_time_util.dart';

class Comment {
  String id;
  String title;
  String content;
  int commentStartPositionInTenthOfSeconds;
  int commentEndPositionInTenthOfSeconds;
  late DateTime creationDateTime;
  late DateTime lastUpdateDateTime;

  Comment({
    required this.title,
    required this.content,
    required this.commentStartPositionInTenthOfSeconds,
    this.commentEndPositionInTenthOfSeconds = 0,
  })  : id = "${title}_${commentStartPositionInTenthOfSeconds.toString()}",
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
    required this.commentStartPositionInTenthOfSeconds,
    required this.commentEndPositionInTenthOfSeconds,
    required this.creationDateTime,
    required this.lastUpdateDateTime,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment.fullConstructor(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      commentStartPositionInTenthOfSeconds:
          json['commentStartPositionInTenthOfSeconds'] ?? 0,
      commentEndPositionInTenthOfSeconds:
          json['commentEndPositionInTenthOfSeconds'] ?? 0,
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
      'commentStartPositionInTenthOfSeconds': commentStartPositionInTenthOfSeconds,
      'commentEndPositionInTenthOfSeconds':
          commentEndPositionInTenthOfSeconds,
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

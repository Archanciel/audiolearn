class Comment {
  String playlistId;
  String audioFileName;
  String title;
  String content;
  int audioPositionSeconds;
  final DateTime creationDateTime;
  DateTime lastUpdateDateTime;

  Comment({
    required this.playlistId,
    required this.audioFileName,
    required this.title,
    required this.content,
    required this.audioPositionSeconds,
    required this.creationDateTime,
  }) : lastUpdateDateTime = creationDateTime;

  /// This constructor requires all instance variables. It is used
  /// by the fromJson factory constructor.
  Comment.fullConstructor({
    required this.playlistId,
    required this.audioFileName,
    required this.title,
    required this.content,
    required this.audioPositionSeconds,
    required this.creationDateTime,
    required this.lastUpdateDateTime,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment.fullConstructor(
      playlistId: json['playlistId'],
      audioFileName: json['audioFileName'],
      title: json['title'],
      content: json['content'],
      audioPositionSeconds: json['audioPositionSeconds'],
      creationDateTime: DateTime.parse(json['creationDateTime']),
      lastUpdateDateTime: DateTime.parse(json['lastUpdateDateTime']),
    );
  }

  // Method: converts an instance of Playlist to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'playlistId': playlistId,
      'audioFileName': audioFileName,
      'title': title,
      'content': content,
      'audioPositionSeconds': audioPositionSeconds,
      'creationDateTime': creationDateTime.toIso8601String(),
      'lastUpdateDateTime': lastUpdateDateTime.toIso8601String(),
    };
  }
}

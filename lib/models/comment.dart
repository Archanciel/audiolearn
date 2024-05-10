class Comment {
  String playlistId;
  String audioFileName;
  String title;
  String content;
  int audioPositionSeconds;
  final DateTime creationDateTime;
  DateTime? lastUpdateDateTime;

  Comment({
    required this.playlistId,
    required this.audioFileName,
    required this.title,
    required this.content,
    required this.audioPositionSeconds,
    required this.creationDateTime,
  });
}

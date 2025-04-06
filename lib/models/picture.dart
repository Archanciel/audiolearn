import '../utils/date_time_util.dart';

class Picture {
  String fileName;
  final DateTime additionToAudioDateTime;
  late DateTime lastDisplayDateTime;
  bool isDisplayable = true;

  Picture({
    required this.fileName,
  }) : additionToAudioDateTime =
            DateTimeUtil.getDateTimeLimitedToSeconds(DateTime.now()) {
    lastDisplayDateTime = additionToAudioDateTime;
  }

  /// This constructor requires all instance variables. It is used
  /// by the fromJson factory constructor.
  Picture.fullConstructor({
    required this.fileName,
    required this.additionToAudioDateTime,
    required this.lastDisplayDateTime,
    required this.isDisplayable,
  });

  factory Picture.fromJson(Map<String, dynamic> json) {
    return Picture.fullConstructor(
      fileName: json['fileName'],
      additionToAudioDateTime: DateTime.parse(json['additionToAudioDateTime']),
      lastDisplayDateTime: DateTime.parse(json['lastDisplayDateTime']),
      isDisplayable: json['isDisplayable'] ?? true,
    );
  }

  // Method: converts an instance of Comment to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'additionToAudioDateTime': additionToAudioDateTime.toIso8601String(),
      'lastDisplayDateTime': lastDisplayDateTime.toIso8601String(),
      'isDisplayable': isDisplayable,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Picture && other.additionToAudioDateTime == additionToAudioDateTime;
  }

  @override
  int get hashCode => additionToAudioDateTime.hashCode;
}

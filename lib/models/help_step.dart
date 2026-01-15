// lib/models/help_step.dart

class HelpStep {
  final int stepNumber;
  final String sectionId;
  final String imagePath;
  final String title;
  final String description;

  HelpStep({
    required this.stepNumber,
    required this.sectionId,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  factory HelpStep.fromJson(Map<String, dynamic> json) {
    return HelpStep(
      stepNumber: json['stepNumber'] as int,
      sectionId: json['sectionId'] as String,
      imagePath: json['imagePath'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'sectionId': sectionId,
      'imagePath': imagePath,
      'title': title,
      'description': description,
    };
  }
}

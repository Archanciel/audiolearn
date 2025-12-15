class ExtractMp3AudioFile {
  final String? path;
  final String? name;
  final double duration;

  ExtractMp3AudioFile({
    this.path,
    this.name,
    this.duration = 60.0, // Default duration
  });

  bool get isSelected => path != null && name != null;
}

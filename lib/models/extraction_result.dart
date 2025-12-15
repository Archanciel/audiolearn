enum ExtractionStatus {
  none,
  processing,
  success,
  error,
}

class ExtractionResult {
  final ExtractionStatus status;
  final String message;
  final String? outputPath;

  ExtractionResult({
    this.status = ExtractionStatus.none,
    this.message = '',
    this.outputPath,
  });

  factory ExtractionResult.initial() {
    return ExtractionResult(status: ExtractionStatus.none);
  }

  factory ExtractionResult.processing() {
    return ExtractionResult(
      status: ExtractionStatus.processing,
      message: 'Processing...',
    );
  }

  factory ExtractionResult.success(String outputPath) {
    return ExtractionResult(
      status: ExtractionStatus.success,
      message: 'Extracted MP3 saved to:\n\n$outputPath',
      outputPath: outputPath,
    );
  }

  factory ExtractionResult.error(String errorMessage) {
    return ExtractionResult(
      status: ExtractionStatus.error,
      message: 'Error: $errorMessage',
    );
  }

  bool get isProcessing => status == ExtractionStatus.processing;
  bool get isSuccess => status == ExtractionStatus.success;
  bool get isError => status == ExtractionStatus.error;
  bool get hasMessage => message.isNotEmpty;
}

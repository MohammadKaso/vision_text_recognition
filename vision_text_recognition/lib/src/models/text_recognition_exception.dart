/// Exception thrown when text recognition fails.
class TextRecognitionException implements Exception {
  final String code;
  final String message;
  final String? details;

  const TextRecognitionException({
    required this.code,
    required this.message,
    this.details,
  });

  factory TextRecognitionException.invalidImage([String? details]) {
    return TextRecognitionException(
      code: 'INVALID_IMAGE',
      message: 'The provided image data is invalid or corrupted',
      details: details,
    );
  }

  factory TextRecognitionException.unsupportedPlatform(String platform) {
    return TextRecognitionException(
      code: 'UNSUPPORTED_PLATFORM',
      message: 'Text recognition is not supported on $platform',
      details: platform,
    );
  }

  @override
  String toString() {
    return 'TextRecognitionException: $code - $message';
  }
}

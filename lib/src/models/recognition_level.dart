/// Defines the recognition level for text recognition accuracy.
///
/// Higher levels provide more accurate results but may take longer to process.
enum RecognitionLevel {
  /// Fast recognition with lower accuracy.
  /// Good for real-time processing where speed is prioritized over accuracy.
  fast,

  /// Accurate recognition with higher precision.
  /// Recommended for most use cases where quality is important.
  accurate,
}

/// Extension to convert RecognitionLevel to platform-specific values
extension RecognitionLevelExtension on RecognitionLevel {
  /// Converts to string representation for platform communication
  String get value {
    switch (this) {
      case RecognitionLevel.fast:
        return 'fast';
      case RecognitionLevel.accurate:
        return 'accurate';
    }
  }

  /// Creates RecognitionLevel from string value
  static RecognitionLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'fast':
        return RecognitionLevel.fast;
      case 'accurate':
        return RecognitionLevel.accurate;
      default:
        return RecognitionLevel.accurate; // Default fallback
    }
  }
}

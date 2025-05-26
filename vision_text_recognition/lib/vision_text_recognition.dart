import 'src/vision_text_recognition_platform_interface.dart';
import 'src/models/models.dart';

export 'src/models/models.dart';

/// A Flutter plugin for advanced text recognition using Apple Vision framework on iOS
/// and Google ML Kit on Android.
///
/// This plugin provides:
/// - High-accuracy text recognition
/// - Confidence scores for recognized text
/// - Precise bounding boxes for text elements
/// - Language detection and correction
/// - Support for various recognition levels
/// - Async processing with error handling
class VisionTextRecognition {
  static VisionTextRecognitionPlatform get _platform =>
      VisionTextRecognitionPlatform.instance;

  /// Recognizes text from image data with default settings.
  ///
  /// [imageData] - The image data as bytes (PNG, JPEG, etc.)
  ///
  /// Returns [TextRecognitionResult] containing recognized text and metadata.
  ///
  /// Example:
  /// ```dart
  /// final imageBytes = await file.readAsBytes();
  /// final result = await VisionTextRecognition.recognizeText(imageBytes);
  /// print('Recognized: ${result.fullText}');
  /// ```
  static Future<TextRecognitionResult> recognizeText(List<int> imageData) {
    return _platform.recognizeText(imageData);
  }

  /// Recognizes text from image data with custom configuration.
  ///
  /// [imageData] - The image data as bytes
  /// [config] - Configuration options for text recognition
  ///
  /// Returns [TextRecognitionResult] with detailed recognition data.
  ///
  /// Example:
  /// ```dart
  /// final config = TextRecognitionConfig(
  ///   recognitionLevel: RecognitionLevel.accurate,
  ///   usesLanguageCorrection: true,
  ///   minimumTextHeight: 0.02,
  /// );
  /// final result = await VisionTextRecognition.recognizeTextWithConfig(
  ///   imageBytes,
  ///   config
  /// );
  /// ```
  static Future<TextRecognitionResult> recognizeTextWithConfig(
    List<int> imageData,
    TextRecognitionConfig config,
  ) {
    return _platform.recognizeTextWithConfig(imageData, config);
  }

  /// Gets the current platform capabilities and version information.
  ///
  /// Returns [PlatformInfo] containing platform-specific details.
  ///
  /// Example:
  /// ```dart
  /// final info = await VisionTextRecognition.getPlatformInfo();
  /// print('Platform: ${info.platform}');
  /// print('Version: ${info.version}');
  /// print('Capabilities: ${info.capabilities}');
  /// ```
  static Future<PlatformInfo> getPlatformInfo() {
    return _platform.getPlatformInfo();
  }

  /// Checks if text recognition is available on the current platform.
  ///
  /// Returns true if text recognition is supported and available.
  ///
  /// Example:
  /// ```dart
  /// if (await VisionTextRecognition.isAvailable()) {
  ///   // Proceed with text recognition
  /// } else {
  ///   // Show fallback UI or error message
  /// }
  /// ```
  static Future<bool> isAvailable() {
    return _platform.isAvailable();
  }

  /// Gets a list of supported languages for text recognition.
  ///
  /// Returns a list of language codes that can be recognized.
  /// Note: This feature is platform-dependent and may not be available on all platforms.
  ///
  /// Example:
  /// ```dart
  /// final languages = await VisionTextRecognition.getSupportedLanguages();
  /// print('Supported languages: $languages');
  /// ```
  static Future<List<String>> getSupportedLanguages() {
    return _platform.getSupportedLanguages();
  }
}

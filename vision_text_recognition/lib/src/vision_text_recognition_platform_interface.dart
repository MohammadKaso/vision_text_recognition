import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'models/models.dart';
import 'vision_text_recognition_method_channel.dart';

/// The interface that implementations of vision_text_recognition must implement.
///
/// Platform implementations should extend this class rather than implement it directly.
/// This ensures that new methods can be added without breaking existing implementations.
abstract class VisionTextRecognitionPlatform extends PlatformInterface {
  /// Constructs a VisionTextRecognitionPlatform.
  VisionTextRecognitionPlatform() : super(token: _token);

  static final Object _token = Object();

  static VisionTextRecognitionPlatform _instance =
      MethodChannelVisionTextRecognition();

  /// The default instance of [VisionTextRecognitionPlatform] to use.
  ///
  /// Defaults to [MethodChannelVisionTextRecognition].
  static VisionTextRecognitionPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VisionTextRecognitionPlatform] when
  /// they register themselves.
  static set instance(VisionTextRecognitionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Recognizes text from image data with default settings.
  ///
  /// [imageData] should be the raw image bytes (PNG, JPEG, etc.)
  ///
  /// Returns a [TextRecognitionResult] containing the recognized text and metadata.
  Future<TextRecognitionResult> recognizeText(List<int> imageData) {
    throw UnimplementedError('recognizeText() has not been implemented.');
  }

  /// Recognizes text from image data with custom configuration.
  ///
  /// [imageData] should be the raw image bytes
  /// [config] contains the recognition settings and preferences
  ///
  /// Returns a [TextRecognitionResult] with detailed recognition data.
  Future<TextRecognitionResult> recognizeTextWithConfig(
    List<int> imageData,
    TextRecognitionConfig config,
  ) {
    throw UnimplementedError(
        'recognizeTextWithConfig() has not been implemented.');
  }

  /// Gets information about the current platform capabilities.
  ///
  /// Returns [PlatformInfo] containing platform-specific details.
  Future<PlatformInfo> getPlatformInfo() {
    throw UnimplementedError('getPlatformInfo() has not been implemented.');
  }

  /// Checks if text recognition is available on the current platform.
  ///
  /// Returns true if text recognition is supported and ready to use.
  Future<bool> isAvailable() {
    throw UnimplementedError('isAvailable() has not been implemented.');
  }

  /// Gets a list of supported languages for text recognition.
  ///
  /// Returns a list of ISO 639-1 language codes that can be recognized.
  /// May return an empty list if language information is not available.
  Future<List<String>> getSupportedLanguages() {
    throw UnimplementedError(
        'getSupportedLanguages() has not been implemented.');
  }
}

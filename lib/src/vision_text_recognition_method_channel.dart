import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'models/models.dart';
import 'vision_text_recognition_platform_interface.dart';

/// Helper function to safely convert Map<Object?, Object?> to Map<String, dynamic>
Map<String, dynamic> _safeMapConversion(Map<Object?, Object?> source) {
  final result = <String, dynamic>{};
  source.forEach((key, value) {
    if (key is String) {
      if (value is Map<Object?, Object?>) {
        result[key] = _safeMapConversion(value);
      } else if (value is List) {
        result[key] = value.map((item) {
          if (item is Map<Object?, Object?>) {
            return _safeMapConversion(item);
          }
          return item;
        }).toList();
      } else {
        result[key] = value;
      }
    }
  });
  return result;
}

/// An implementation of [VisionTextRecognitionPlatform] that uses method channels.
class MethodChannelVisionTextRecognition extends VisionTextRecognitionPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('vision_text_recognition');

  @override
  Future<TextRecognitionResult> recognizeText(List<int> imageData) async {
    try {
      final result = await methodChannel.invokeMethod<Map<Object?, Object?>>(
        'recognizeText',
        {'imageBytes': Uint8List.fromList(imageData)},
      );

      if (result == null) {
        return TextRecognitionResult.empty();
      }

      return TextRecognitionResult.fromMap(_safeMapConversion(result));
    } on PlatformException catch (e) {
      throw TextRecognitionException(
        code: e.code,
        message: e.message ?? 'Unknown error occurred',
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<TextRecognitionResult> recognizeTextWithConfig(
    List<int> imageData,
    TextRecognitionConfig config,
  ) async {
    try {
      final result = await methodChannel.invokeMethod<Map<Object?, Object?>>(
        'recognizeTextWithConfig',
        {
          'imageBytes': Uint8List.fromList(imageData),
          'config': config.toMap(),
        },
      );

      if (result == null) {
        return TextRecognitionResult.empty();
      }

      return TextRecognitionResult.fromMap(_safeMapConversion(result));
    } on PlatformException catch (e) {
      throw TextRecognitionException(
        code: e.code,
        message: e.message ?? 'Unknown error occurred',
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PlatformInfo> getPlatformInfo() async {
    try {
      final result = await methodChannel.invokeMethod<Map<Object?, Object?>>(
        'getPlatformInfo',
      );

      if (result == null) {
        throw const TextRecognitionException(
          code: 'NO_PLATFORM_INFO',
          message: 'Unable to retrieve platform information',
        );
      }

      return PlatformInfo.fromMap(_safeMapConversion(result));
    } on PlatformException catch (e) {
      throw TextRecognitionException(
        code: e.code,
        message: e.message ?? 'Unknown error occurred',
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } on PlatformException catch (e) {
      // If there's a platform exception, text recognition is likely not available
      debugPrint('Text recognition availability check failed: ${e.message}');
      return false;
    }
  }

  @override
  Future<List<String>> getSupportedLanguages() async {
    try {
      final result = await methodChannel.invokeMethod<List<Object?>>(
        'getSupportedLanguages',
      );

      if (result == null) {
        return [];
      }

      return result.map((lang) => lang.toString()).toList();
    } on PlatformException catch (e) {
      debugPrint('Failed to get supported languages: ${e.message}');
      return [];
    }
  }
}

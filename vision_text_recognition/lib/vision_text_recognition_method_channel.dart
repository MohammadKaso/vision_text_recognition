import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'vision_text_recognition_platform_interface.dart';

/// An implementation of [VisionTextRecognitionPlatform] that uses method channels.
class MethodChannelVisionTextRecognition extends VisionTextRecognitionPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('vision_text_recognition');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

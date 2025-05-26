import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'vision_text_recognition_method_channel.dart';

abstract class VisionTextRecognitionPlatform extends PlatformInterface {
  /// Constructs a VisionTextRecognitionPlatform.
  VisionTextRecognitionPlatform() : super(token: _token);

  static final Object _token = Object();

  static VisionTextRecognitionPlatform _instance = MethodChannelVisionTextRecognition();

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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

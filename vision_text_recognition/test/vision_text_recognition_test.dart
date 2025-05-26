import 'package:flutter_test/flutter_test.dart';
import 'package:vision_text_recognition/vision_text_recognition.dart';
import 'package:vision_text_recognition/src/vision_text_recognition_platform_interface.dart';
import 'package:vision_text_recognition/src/vision_text_recognition_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockVisionTextRecognitionPlatform
    with MockPlatformInterfaceMixin
    implements VisionTextRecognitionPlatform {
  @override
  Future<bool> isAvailable() => Future.value(true);

  @override
  Future<PlatformInfo> getPlatformInfo() => Future.value(
        const PlatformInfo(
          platform: 'test',
          platformVersion: '1.0',
          engine: 'mock',
          engineVersion: '1.0',
          capabilities: ['text_recognition'],
          supportsLanguageCorrection: true,
          supportsConfidenceScores: true,
          supportsBoundingBoxes: true,
          supportsLanguageDetection: true,
          supportedRecognitionLevels: ['accurate'],
        ),
      );

  @override
  Future<List<String>> getSupportedLanguages() => Future.value(['en']);

  @override
  Future<TextRecognitionResult> recognizeText(List<int> imageData) =>
      Future.value(TextRecognitionResult.empty());

  @override
  Future<TextRecognitionResult> recognizeTextWithConfig(
    List<int> imageData,
    TextRecognitionConfig config,
  ) =>
      Future.value(TextRecognitionResult.empty());
}

void main() {
  final VisionTextRecognitionPlatform initialPlatform =
      VisionTextRecognitionPlatform.instance;

  test('$MethodChannelVisionTextRecognition is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelVisionTextRecognition>());
  });

  test('isAvailable', () async {
    MockVisionTextRecognitionPlatform fakePlatform =
        MockVisionTextRecognitionPlatform();
    VisionTextRecognitionPlatform.instance = fakePlatform;

    expect(await VisionTextRecognition.isAvailable(), true);
  });

  test('getPlatformInfo', () async {
    MockVisionTextRecognitionPlatform fakePlatform =
        MockVisionTextRecognitionPlatform();
    VisionTextRecognitionPlatform.instance = fakePlatform;

    final info = await VisionTextRecognition.getPlatformInfo();
    expect(info.platform, 'test');
    expect(info.engine, 'mock');
  });

  test('getSupportedLanguages', () async {
    MockVisionTextRecognitionPlatform fakePlatform =
        MockVisionTextRecognitionPlatform();
    VisionTextRecognitionPlatform.instance = fakePlatform;

    final languages = await VisionTextRecognition.getSupportedLanguages();
    expect(languages, ['en']);
  });
}

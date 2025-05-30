import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vision_text_recognition/src/vision_text_recognition_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelVisionTextRecognition platform =
      MethodChannelVisionTextRecognition();
  const MethodChannel channel = MethodChannel('vision_text_recognition');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'isAvailable':
            return true;
          case 'getPlatformInfo':
            return {
              'platform': 'test',
              'platformVersion': '1.0',
              'engine': 'mock',
              'engineVersion': '1.0',
              'capabilities': ['text_recognition'],
              'supportsLanguageCorrection': true,
              'supportsConfidenceScores': true,
              'supportsBoundingBoxes': true,
              'supportsLanguageDetection': true,
              'supportedRecognitionLevels': ['accurate'],
            };
          case 'getSupportedLanguages':
            return ['en'];
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('isAvailable', () async {
    expect(await platform.isAvailable(), true);
  });

  test('getPlatformInfo', () async {
    final info = await platform.getPlatformInfo();
    expect(info.platform, 'test');
    expect(info.engine, 'mock');
  });

  test('getSupportedLanguages', () async {
    final languages = await platform.getSupportedLanguages();
    expect(languages, ['en']);
  });
}

# Vision Text Recognition

[![pub package](https://img.shields.io/pub/v/vision_text_recognition.svg)](https://pub.dev/packages/vision_text_recognition)
[![pub points](https://img.shields.io/pub/points/vision_text_recognition)](https://pub.dev/packages/vision_text_recognition/score)
[![pub popularity](https://img.shields.io/pub/popularity/vision_text_recognition)](https://pub.dev/packages/vision_text_recognition/score)

A comprehensive Flutter plugin for advanced text recognition using platform-specific engines:
- **iOS**: Apple Vision framework for high-accuracy OCR
- **Android**: Google ML Kit for reliable text detection

## Features

✨ **Cross-Platform Support**: Optimized implementations for both iOS and Android
📱 **High Accuracy**: Platform-specific engines ensure optimal recognition quality
⚡ **Performance Options**: Choose between speed and accuracy based on your needs
🎯 **Confidence Scores**: Get confidence ratings for recognized text elements
📍 **Bounding Boxes**: Precise positioning information for text blocks
🌍 **Language Support**: Multi-language text recognition and detection
⚙️ **Configurable**: Extensive customization options for different use cases
🔍 **Detailed Results**: Comprehensive metadata and statistics

## Platform-Specific Features

### iOS (Vision Framework)
- Language correction and detection
- Multiple recognition levels (fast/accurate)
- Minimum text height filtering
- Custom model revisions
- Advanced language preferences

### Android (ML Kit)
- Latin-based language support
- Standardized recognition quality
- Optimized for device performance
- Offline processing

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  vision_text_recognition: ^1.0.0
```

### Platform Setup

#### iOS
Minimum iOS version: **13.0**

The plugin automatically configures the Vision framework. No additional setup required.

#### Android
Minimum SDK version: **21**

The plugin automatically includes ML Kit dependencies. No additional setup required.

## Quick Start

```dart
import 'package:vision_text_recognition/vision_text_recognition.dart';

// Check if text recognition is available
bool isAvailable = await VisionTextRecognition.isAvailable();

if (isAvailable) {
  // Load your image as bytes
  List<int> imageBytes = await loadImageBytes();
  
  // Recognize text with default settings
  TextRecognitionResult result = await VisionTextRecognition.recognizeText(imageBytes);
  
  print('Recognized text: ${result.fullText}');
  print('Confidence: ${result.confidence}');
  print('Text blocks: ${result.textBlocks.length}');
}
```

## Advanced Usage

### Custom Configuration

```dart
// Create a custom configuration
final config = TextRecognitionConfig(
  recognitionLevel: RecognitionLevel.accurate,
  usesLanguageCorrection: true,
  automaticallyDetectsLanguage: true,
  minimumTextHeight: 0.02,
  preferredLanguages: ['en', 'es', 'fr'],
);

// Recognize text with custom settings
final result = await VisionTextRecognition.recognizeTextWithConfig(imageBytes, config);
```

### Predefined Configurations

```dart
// Speed-optimized configuration
final speedConfig = TextRecognitionConfig.speed();

// Accuracy-optimized configuration  
final accuracyConfig = TextRecognitionConfig.accuracy();

// Language-specific configuration
final languageConfig = TextRecognitionConfig.languages(['en', 'es']);
```

### Working with Results

```dart
final result = await VisionTextRecognition.recognizeText(imageBytes);

// Access full text
print('Full text: ${result.fullText}');

// Check overall confidence
if (result.isConfident()) {
  print('High confidence recognition');
}

// Process individual text blocks
for (final block in result.textBlocks) {
  print('Text: "${block.text}"');
  print('Confidence: ${(block.confidence * 100).toStringAsFixed(1)}%');
  print('Position: (${block.boundingBox.x}, ${block.boundingBox.y})');
  print('Size: ${block.boundingBox.width} x ${block.boundingBox.height}');
  
  if (block.language != null) {
    print('Language: ${block.language}');
  }
}

// Get confident text only
final confidentText = result.getConfidentText(0.8); // 80% threshold

// Find text blocks in specific region
final regionBlocks = result.getBlocksInRegion(0.0, 0.0, 0.5, 0.5); // Top-left quarter

// Get numeric blocks only
final numericBlocks = result.numericBlocks;

// Access detailed statistics
final stats = result.statistics;
print('Processing time: ${stats['processingTimeMs']}ms');
print('Average confidence: ${stats['averageConfidence']}');
```

### Platform Information

```dart
final platformInfo = await VisionTextRecognition.getPlatformInfo();

print('Platform: ${platformInfo.platform}');
print('Engine: ${platformInfo.engine}');
print('Capabilities: ${platformInfo.capabilities}');
print('Supports language correction: ${platformInfo.supportsLanguageCorrection}');

// Get supported languages
final languages = await VisionTextRecognition.getSupportedLanguages();
print('Supported languages: $languages');
```

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vision_text_recognition/vision_text_recognition.dart';

class TextRecognitionScreen extends StatefulWidget {
  @override
  _TextRecognitionScreenState createState() => _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  String _recognizedText = '';
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndRecognizeImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final imageBytes = await image.readAsBytes();
      
      // Use accurate configuration for best results
      final config = TextRecognitionConfig.accuracy();
      final result = await VisionTextRecognition.recognizeTextWithConfig(
        imageBytes, 
        config
      );

      setState(() {
        _recognizedText = result.fullText;
      });
    } catch (e) {
      setState(() {
        _recognizedText = 'Error: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Text Recognition')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isProcessing ? null : _pickAndRecognizeImage,
              child: Text('Select Image'),
            ),
            SizedBox(height: 20),
            if (_isProcessing)
              CircularProgressIndicator()
            else
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(_recognizedText),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

## API Reference

### Core Methods

#### `recognizeText(List<int> imageData)`
Recognizes text from image data using default settings.

**Parameters:**
- `imageData`: Image bytes (PNG, JPEG, etc.)

**Returns:** `Future<TextRecognitionResult>`

#### `recognizeTextWithConfig(List<int> imageData, TextRecognitionConfig config)`
Recognizes text with custom configuration.

**Parameters:**
- `imageData`: Image bytes
- `config`: Recognition configuration

**Returns:** `Future<TextRecognitionResult>`

#### `getPlatformInfo()`
Gets platform capabilities and version information.

**Returns:** `Future<PlatformInfo>`

#### `isAvailable()`
Checks if text recognition is available.

**Returns:** `Future<bool>`

#### `getSupportedLanguages()`
Gets list of supported language codes.

**Returns:** `Future<List<String>>`

### Models

#### `TextRecognitionResult`
Main result class containing recognized text and metadata.

**Properties:**
- `fullText`: Complete recognized text
- `textBlocks`: Individual text elements with positioning
- `confidence`: Overall confidence score (0.0 to 1.0)
- `processingTimeMs`: Processing time in milliseconds
- `detectedLanguage`: Primary detected language

**Methods:**
- `isConfident([threshold])`: Check if confidence meets threshold
- `getConfidentBlocks([threshold])`: Get blocks above confidence threshold
- `getConfidentText([threshold])`: Get text from confident blocks only
- `getBlocksInRegion(x, y, width, height)`: Get blocks in specific region

#### `TextBlock`
Individual text element with detailed information.

**Properties:**
- `text`: The recognized text
- `confidence`: Confidence score (0.0 to 1.0)
- `boundingBox`: Position and size information
- `language`: Detected language (if available)

#### `BoundingBox`
Positioning information for text elements.

**Properties:**
- `x`, `y`: Top-left coordinates (normalized 0.0-1.0)
- `width`, `height`: Dimensions (normalized 0.0-1.0)

**Methods:**
- `toAbsolute(imageWidth, imageHeight)`: Convert to absolute coordinates
- `contains(pointX, pointY)`: Check if point is inside box

#### `TextRecognitionConfig`
Configuration options for text recognition.

**Properties:**
- `recognitionLevel`: Speed vs accuracy trade-off
- `usesLanguageCorrection`: Enable language-based correction
- `preferredLanguages`: Preferred language codes
- `minimumTextHeight`: Minimum text size threshold
- `automaticallyDetectsLanguage`: Enable automatic language detection

## Error Handling

The plugin throws `TextRecognitionException` for various error conditions:

```dart
try {
  final result = await VisionTextRecognition.recognizeText(imageBytes);
} on TextRecognitionException catch (e) {
  switch (e.code) {
    case 'INVALID_IMAGE':
      print('Invalid image format');
      break;
    case 'UNSUPPORTED_PLATFORM':
      print('Platform not supported');
      break;
    case 'PROCESSING_FAILED':
      print('Recognition failed');
      break;
    default:
      print('Error: ${e.message}');
  }
}
```

## Performance Tips

1. **Choose the right configuration**: Use `RecognitionLevel.fast` for real-time processing, `RecognitionLevel.accurate` for best quality.

2. **Image preprocessing**: Ensure good image quality with proper lighting and contrast.

3. **Optimize image size**: Very large images may slow down processing without improving accuracy.

4. **Filter small text**: Use `minimumTextHeight` to ignore noise and very small text.

5. **Language hints**: Provide `preferredLanguages` when you know the expected languages.

## Platform Differences

| Feature | iOS (Vision) | Android (ML Kit) |
|---------|-------------|------------------|
| Confidence Scores | ✅ High precision | ✅ Estimated |
| Language Detection | ✅ Advanced | ❌ Not available |
| Language Correction | ✅ Available | ❌ Not available |
| Recognition Levels | ✅ Fast/Accurate | ✅ Standard |
| Offline Processing | ✅ Complete | ✅ Complete |
| Minimum OS Version | iOS 13.0+ | Android API 21+ |

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) and submit pull requests to our [GitHub repository](https://github.com/MohammadKaso/vision_text_recognition).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support


- 🐛 **Issues**: [GitHub Issues](https://github.com/MohammadKaso/vision_text_recognition/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/MohammadKaso/vision_text_recognition/discussions)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.


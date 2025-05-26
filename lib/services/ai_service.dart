import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:vision_text_recognition/vision_text_recognition.dart' as vtr;
import '../models/order.dart';

class AIService {
  static late SpeechToText _speechToText;

  static Future<void> initialize() async {
    _speechToText = SpeechToText();
    await _speechToText.initialize();
  }

  // 1. Simple image enhancement (placeholder)
  static Future<File> enhanceImageForOCR(File imageFile) async {
    // For now, return the original file
    // In a production app, you would implement proper image enhancement
    return imageFile;
  }

  // 2. OCR Text Recognition with Bounding Boxes using vision_text_recognition
  static Future<OCRResult> performOCR(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();

      // Use the new vision_text_recognition plugin
      final result = await vtr.VisionTextRecognition.recognizeText(imageBytes);

      List<TextBlock> blocks = [];
      Map<String, BoundingBox> boundingBoxes = {};

      for (final block in result.textBlocks) {
        final textBlock = TextBlock(
          text: block.text,
          confidence: block.confidence,
          boundingBox: BoundingBox(
            x: block.boundingBox.x,
            y: block.boundingBox.y,
            width: block.boundingBox.width,
            height: block.boundingBox.height,
          ),
        );

        blocks.add(textBlock);
        boundingBoxes[block.text] = textBlock.boundingBox;
      }

      return OCRResult(
        fullText: result.fullText,
        textBlocks: blocks,
        boundingBoxes: boundingBoxes,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Vision Text Recognition failed: $e');
      }
      // Fallback to basic OCR result
      return OCRResult(fullText: '', textBlocks: [], boundingBoxes: {});
    }
  }

  // Enhanced OCR with configuration
  static Future<OCRResult> performAdvancedOCR(
    File imageFile, {
    String recognitionLevel = 'accurate',
    bool usesLanguageCorrection = true,
    List<String>? preferredLanguages,
  }) async {
    try {
      final imageBytes = await imageFile.readAsBytes();

      final config = vtr.TextRecognitionConfig(
        recognitionLevel: vtr.RecognitionLevel.values.firstWhere(
          (level) => level.name == recognitionLevel,
          orElse: () => vtr.RecognitionLevel.accurate,
        ),
        usesLanguageCorrection: usesLanguageCorrection,
        preferredLanguages: preferredLanguages,
      );

      final result = await vtr.VisionTextRecognition.recognizeTextWithConfig(
        imageBytes,
        config,
      );

      List<TextBlock> blocks = [];
      Map<String, BoundingBox> boundingBoxes = {};

      for (final block in result.textBlocks) {
        final textBlock = TextBlock(
          text: block.text,
          confidence: block.confidence,
          boundingBox: BoundingBox(
            x: block.boundingBox.x,
            y: block.boundingBox.y,
            width: block.boundingBox.width,
            height: block.boundingBox.height,
          ),
        );

        blocks.add(textBlock);
        boundingBoxes[block.text] = textBlock.boundingBox;
      }

      return OCRResult(
        fullText: result.fullText,
        textBlocks: blocks,
        boundingBoxes: boundingBoxes,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Advanced Vision Text Recognition failed: $e');
      }
      // Fallback to basic OCR
      return performOCR(imageFile);
    }
  }

  // 3. Speech to Text
  static Future<String> speechToText({required String languageCode}) async {
    String recognizedText = '';

    if (await _speechToText.hasPermission) {
      await _speechToText.listen(
        onResult: (result) {
          recognizedText = result.recognizedWords;
        },
        localeId: languageCode,
      );
    }

    return recognizedText;
  }

  // 4. Simple image quality classification
  static Future<ImageQuality> classifyImageQuality(File imageFile) async {
    // Simplified quality check - in production, implement proper blur/brightness detection
    final fileSize = await imageFile.length();

    return ImageQuality(
      blurScore: 150.0, // Default score
      brightnessScore: 128.0, // Default score
      isBlurry: fileSize < 100000, // Simple heuristic based on file size
      isTooLight: false,
      isTooDark: false,
    );
  }

  // 5. Format Order using Simple Pattern Matching
  static Future<Order> formatToOrder({
    required String text,
    required OrderSource source,
    String? imagePath,
    String? audioPath,
  }) async {
    final items = _extractOrderItems(text);
    final customerInfo = _extractCustomerInfo(text);

    return Order(
      source: source,
      customerName: customerInfo['name'],
      customerContact: customerInfo['contact'],
      items: items,
      originalText: text,
      imagePath: imagePath,
      audioPath: audioPath,
    );
  }

  static List<OrderItem> _extractOrderItems(String text) {
    final List<OrderItem> items = [];

    // Simple regex patterns for extracting items
    final patterns = [
      RegExp(r'(\d+)\s*x?\s*([a-zA-Z\s]+)', caseSensitive: false),
      RegExp(r'([a-zA-Z\s]+)\s*x?\s*(\d+)', caseSensitive: false),
      RegExp(r'(\d+)\s+([a-zA-Z\s]+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        String? quantityStr;
        String? productName;

        // Try to determine which group is quantity and which is product
        if (int.tryParse(match.group(1)!) != null) {
          quantityStr = match.group(1);
          productName = match.group(2);
        } else if (int.tryParse(match.group(2)!) != null) {
          quantityStr = match.group(2);
          productName = match.group(1);
        }

        if (quantityStr != null && productName != null) {
          final quantity = int.tryParse(quantityStr) ?? 1;
          final cleanProductName = productName.trim();

          if (cleanProductName.isNotEmpty && cleanProductName.length > 2) {
            items.add(
              OrderItem(
                skuName: cleanProductName,
                quantity: quantity,
                confidence: 0.7,
              ),
            );
          }
        }
      }
    }

    return items;
  }

  static Map<String, String?> _extractCustomerInfo(String text) {
    String? name;
    String? contact;

    // Look for phone numbers
    final phonePattern = RegExp(r'[\+]?[1-9]?[0-9]{7,14}');
    final phoneMatch = phonePattern.firstMatch(text);
    if (phoneMatch != null) {
      contact = phoneMatch.group(0);
    }

    // Look for names
    final namePattern = RegExp(r'\b[A-Z][a-z]+\s+[A-Z][a-z]+\b');
    final nameMatch = namePattern.firstMatch(text);
    if (nameMatch != null) {
      name = nameMatch.group(0);
    }

    return {'name': name, 'contact': contact};
  }

  // Get platform information
  static Future<vtr.PlatformInfo> getPlatformInfo() async {
    return vtr.VisionTextRecognition.getPlatformInfo();
  }

  // Check if text recognition is available
  static Future<bool> isTextRecognitionAvailable() async {
    return vtr.VisionTextRecognition.isAvailable();
  }

  // Get supported languages
  static Future<List<String>> getSupportedLanguages() async {
    return vtr.VisionTextRecognition.getSupportedLanguages();
  }

  static void dispose() {
    // Vision text recognition plugin handles its own disposal
  }
}

class OCRResult {
  final String fullText;
  final List<TextBlock> textBlocks;
  final Map<String, BoundingBox> boundingBoxes;

  OCRResult({
    required this.fullText,
    required this.textBlocks,
    required this.boundingBoxes,
  });
}

class TextBlock {
  final String text;
  final double confidence;
  final BoundingBox boundingBox;

  TextBlock({
    required this.text,
    required this.confidence,
    required this.boundingBox,
  });
}

class ImageQuality {
  final double blurScore;
  final double brightnessScore;
  final bool isBlurry;
  final bool isTooLight;
  final bool isTooDark;

  ImageQuality({
    required this.blurScore,
    required this.brightnessScore,
    required this.isBlurry,
    required this.isTooLight,
    required this.isTooDark,
  });

  bool get needsEnhancement => isBlurry || isTooLight || isTooDark;
}

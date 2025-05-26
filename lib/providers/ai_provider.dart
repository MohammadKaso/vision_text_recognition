import 'dart:io';
import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../models/order.dart';

class AIProvider extends ChangeNotifier {
  bool _isProcessing = false;
  String? _errorMessage;
  OCRResult? _lastOCRResult;
  String? _lastSpeechResult;
  ImageQuality? _lastImageQuality;

  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  OCRResult? get lastOCRResult => _lastOCRResult;
  String? get lastSpeechResult => _lastSpeechResult;
  ImageQuality? get lastImageQuality => _lastImageQuality;

  Future<Order?> processImageToOrder(File imageFile) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Check image quality
      _lastImageQuality = await AIService.classifyImageQuality(imageFile);

      File processedImage = imageFile;

      // 2. Enhance image if needed
      if (_lastImageQuality!.needsEnhancement) {
        processedImage = await AIService.enhanceImageForOCR(imageFile);
      }

      // 3. Perform OCR
      _lastOCRResult = await AIService.performOCR(processedImage);

      // 4. Format to order
      if (_lastOCRResult!.fullText.isNotEmpty) {
        final order = await AIService.formatToOrder(
          text: _lastOCRResult!.fullText,
          source: OrderSource.image,
          imagePath: imageFile.path,
        );

        return order;
      }

      return null;
    } catch (e) {
      _errorMessage = 'Failed to process image: $e';
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<Order?> processAudioToOrder() async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Convert speech to text
      _lastSpeechResult = await AIService.speechToText(languageCode: 'en-US');

      // 2. Format to order
      if (_lastSpeechResult!.isNotEmpty) {
        final order = await AIService.formatToOrder(
          text: _lastSpeechResult!,
          source: OrderSource.voice,
        );

        return order;
      }

      return null;
    } catch (e) {
      _errorMessage = 'Failed to process audio: $e';
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<Order?> processTextToOrder(String text, OrderSource source) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await AIService.formatToOrder(text: text, source: source);

      return order;
    } catch (e) {
      _errorMessage = 'Failed to process text: $e';
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void clearResults() {
    _lastOCRResult = null;
    _lastSpeechResult = null;
    _lastImageQuality = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

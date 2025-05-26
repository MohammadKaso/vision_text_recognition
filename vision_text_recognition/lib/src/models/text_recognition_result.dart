import 'text_block.dart';

/// Result of text recognition containing all detected text and metadata.
///
/// Provides both the complete recognized text and individual text blocks
/// with their confidence scores and positioning information.
class TextRecognitionResult {
  /// The complete recognized text concatenated from all text blocks
  final String fullText;

  /// Individual text blocks with detailed metadata
  final List<TextBlock> textBlocks;

  /// Overall confidence score for the entire recognition (0.0 to 1.0)
  ///
  /// This is typically calculated as the average confidence of all text blocks.
  final double confidence;

  /// Processing time in milliseconds
  ///
  /// Time taken to complete the text recognition process.
  /// May be null if timing information is not available.
  final int? processingTimeMs;

  /// The primary detected language across all text blocks
  ///
  /// Uses ISO 639-1 language codes (e.g., 'en', 'es', 'fr').
  /// May be null if language detection is not confident or available.
  final String? detectedLanguage;

  /// Additional metadata about the recognition process
  ///
  /// May contain platform-specific information, debug data,
  /// or additional recognition statistics.
  final Map<String, dynamic>? metadata;

  /// Creates a text recognition result.
  const TextRecognitionResult({
    required this.fullText,
    required this.textBlocks,
    required this.confidence,
    this.processingTimeMs,
    this.detectedLanguage,
    this.metadata,
  });

  /// Creates an empty result (no text detected).
  factory TextRecognitionResult.empty() {
    return const TextRecognitionResult(
      fullText: '',
      textBlocks: [],
      confidence: 0.0,
    );
  }

  /// Creates a TextRecognitionResult from a map representation.
  factory TextRecognitionResult.fromMap(Map<String, dynamic> map) {
    final textBlocksList = map['textBlocks'] as List<dynamic>? ?? [];
    final textBlocks = textBlocksList
        .map((block) => TextBlock.fromMap(block as Map<String, dynamic>))
        .toList();

    return TextRecognitionResult(
      fullText: map['fullText'] as String? ?? '',
      textBlocks: textBlocks,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      processingTimeMs: map['processingTimeMs'] as int?,
      detectedLanguage: map['detectedLanguage'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts the result to a map representation.
  Map<String, dynamic> toMap() {
    return {
      'fullText': fullText,
      'textBlocks': textBlocks.map((block) => block.toMap()).toList(),
      'confidence': confidence,
      'processingTimeMs': processingTimeMs,
      'detectedLanguage': detectedLanguage,
      'metadata': metadata,
    };
  }

  /// Returns true if any text was detected.
  bool get hasText => fullText.isNotEmpty;

  /// Returns true if the recognition confidence is above the threshold.
  ///
  /// [threshold] defaults to 0.7 (70% confidence).
  bool isConfident([double threshold = 0.7]) {
    return confidence >= threshold;
  }

  /// Returns text blocks that meet the confidence threshold.
  ///
  /// [threshold] defaults to 0.7 (70% confidence).
  List<TextBlock> getConfidentBlocks([double threshold = 0.7]) {
    return textBlocks.where((block) => block.isConfident(threshold)).toList();
  }

  /// Returns text blocks sorted by their vertical position (top to bottom).
  List<TextBlock> get blocksSortedByPosition {
    final sorted = List<TextBlock>.from(textBlocks);
    sorted.sort((a, b) => a.boundingBox.y.compareTo(b.boundingBox.y));
    return sorted;
  }

  /// Returns text blocks that contain only numeric content.
  List<TextBlock> get numericBlocks {
    return textBlocks.where((block) => block.isNumeric).toList();
  }

  /// Returns the text with normalized whitespace from all confident blocks.
  ///
  /// [threshold] defaults to 0.7 (70% confidence).
  String getConfidentText([double threshold = 0.7]) {
    final confidentBlocks = getConfidentBlocks(threshold);
    return confidentBlocks
        .map((block) => block.normalizedText)
        .join(' ')
        .trim();
  }

  /// Returns text blocks that intersect with the specified region.
  ///
  /// [x], [y], [width], [height] define the region in normalized coordinates (0.0 to 1.0).
  List<TextBlock> getBlocksInRegion(
      double x, double y, double width, double height) {
    return textBlocks.where((block) {
      final box = block.boundingBox;
      return box.x < x + width &&
          box.x + box.width > x &&
          box.y < y + height &&
          box.y + box.height > y;
    }).toList();
  }

  /// Returns the total area covered by all text blocks.
  double get totalTextArea {
    return textBlocks.fold(0.0, (sum, block) => sum + block.area);
  }

  /// Returns recognition statistics as a map.
  Map<String, dynamic> get statistics {
    if (textBlocks.isEmpty) {
      return {
        'totalBlocks': 0,
        'averageConfidence': 0.0,
        'totalArea': 0.0,
        'processingTimeMs': processingTimeMs,
      };
    }

    return {
      'totalBlocks': textBlocks.length,
      'averageConfidence':
          textBlocks.map((block) => block.confidence).reduce((a, b) => a + b) /
              textBlocks.length,
      'minConfidence': textBlocks
          .map((block) => block.confidence)
          .reduce((a, b) => a < b ? a : b),
      'maxConfidence': textBlocks
          .map((block) => block.confidence)
          .reduce((a, b) => a > b ? a : b),
      'totalArea': totalTextArea,
      'processingTimeMs': processingTimeMs,
      'detectedLanguage': detectedLanguage,
    };
  }

  /// Returns a copy of this result with updated properties.
  TextRecognitionResult copyWith({
    String? fullText,
    List<TextBlock>? textBlocks,
    double? confidence,
    int? processingTimeMs,
    String? detectedLanguage,
    Map<String, dynamic>? metadata,
  }) {
    return TextRecognitionResult(
      fullText: fullText ?? this.fullText,
      textBlocks: textBlocks ?? this.textBlocks,
      confidence: confidence ?? this.confidence,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'TextRecognitionResult('
        'fullText: "$fullText", '
        'blocks: ${textBlocks.length}, '
        'confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextRecognitionResult &&
        other.fullText == fullText &&
        other.textBlocks.length == textBlocks.length &&
        other.confidence == confidence &&
        other.detectedLanguage == detectedLanguage;
  }

  @override
  int get hashCode {
    return Object.hash(
        fullText, textBlocks.length, confidence, detectedLanguage);
  }
}

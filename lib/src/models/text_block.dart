import 'bounding_box.dart';

/// Represents a recognized text block with its associated metadata.
///
/// Each text block contains the recognized text, confidence score,
/// bounding box information, and additional metadata.
class TextBlock {
  /// The recognized text content
  final String text;

  /// Confidence score for the recognition (0.0 to 1.0)
  ///
  /// Higher values indicate more confident recognition.
  final double confidence;

  /// The bounding box containing this text block
  final BoundingBox boundingBox;

  /// The detected language of the text (if available)
  ///
  /// Uses ISO 639-1 language codes (e.g., 'en', 'es', 'fr').
  /// May be null if language detection is not available or confident.
  final String? language;

  /// Additional metadata about the text block
  ///
  /// May contain platform-specific information or additional properties.
  final Map<String, dynamic>? metadata;

  /// Creates a text block with recognized text and metadata.
  const TextBlock({
    required this.text,
    required this.confidence,
    required this.boundingBox,
    this.language,
    this.metadata,
  });

  /// Creates a TextBlock from a map representation.
  factory TextBlock.fromMap(Map<String, dynamic> map) {
    return TextBlock(
      text: map['text'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      boundingBox:
          BoundingBox.fromMap(map['boundingBox'] as Map<String, dynamic>),
      language: map['language'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts the text block to a map representation.
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'confidence': confidence,
      'boundingBox': boundingBox.toMap(),
      'language': language,
      'metadata': metadata,
    };
  }

  /// Returns true if the confidence score is above the threshold.
  ///
  /// [threshold] defaults to 0.7 (70% confidence).
  bool isConfident([double threshold = 0.7]) {
    return confidence >= threshold;
  }

  /// Returns the text with normalized whitespace.
  ///
  /// Removes leading/trailing whitespace and normalizes internal whitespace.
  String get normalizedText {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Returns true if the text block contains only numbers.
  bool get isNumeric {
    return RegExp(r'^\d+(\.\d+)?$').hasMatch(normalizedText);
  }

  /// Returns true if the text block appears to be a single word.
  bool get isSingleWord {
    return !normalizedText.contains(' ');
  }

  /// Returns the estimated area covered by this text block.
  ///
  /// This is calculated as width × height of the bounding box.
  double get area {
    return boundingBox.width * boundingBox.height;
  }

  /// Returns a copy of this text block with updated properties.
  TextBlock copyWith({
    String? text,
    double? confidence,
    BoundingBox? boundingBox,
    String? language,
    Map<String, dynamic>? metadata,
  }) {
    return TextBlock(
      text: text ?? this.text,
      confidence: confidence ?? this.confidence,
      boundingBox: boundingBox ?? this.boundingBox,
      language: language ?? this.language,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'TextBlock(text: "$text", confidence: $confidence, language: $language)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextBlock &&
        other.text == text &&
        other.confidence == confidence &&
        other.boundingBox == boundingBox &&
        other.language == language;
  }

  @override
  int get hashCode {
    return Object.hash(text, confidence, boundingBox, language);
  }
}

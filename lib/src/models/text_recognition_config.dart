import 'recognition_level.dart';

/// Configuration options for text recognition.
///
/// Allows customization of recognition accuracy, language preferences,
/// and other platform-specific settings.
class TextRecognitionConfig {
  /// The recognition level determining accuracy vs speed trade-off
  final RecognitionLevel recognitionLevel;

  /// Whether to use language correction during recognition
  ///
  /// When enabled, the recognition engine will attempt to correct
  /// recognized text based on language models and dictionaries.
  final bool usesLanguageCorrection;

  /// Preferred languages for recognition (ISO 639-1 codes)
  ///
  /// If specified, the recognition engine will prioritize these languages.
  /// Example: ['en', 'es', 'fr'] for English, Spanish, and French.
  final List<String>? preferredLanguages;

  /// Minimum text height as a fraction of image height (0.0 to 1.0)
  ///
  /// Text smaller than this threshold may be ignored.
  /// Useful for filtering out very small text that might be noise.
  final double? minimumTextHeight;

  /// Maximum number of text candidates per observation
  ///
  /// Higher values may provide more alternatives but increase processing time.
  /// Platform-specific and may not be supported on all platforms.
  final int? maxCandidates;

  /// Custom revision for text recognition model
  ///
  /// Platform-specific setting for Vision framework.
  /// Allows selecting specific model revisions for recognition.
  final int? revision;

  /// Whether to automatically detect reading order
  ///
  /// When enabled, attempts to detect and organize text in reading order
  /// (left-to-right, right-to-left, top-to-bottom, etc.).
  final bool automaticallyDetectsLanguage;

  /// Additional platform-specific options
  ///
  /// Allows passing custom configuration options that are specific
  /// to the underlying platform (iOS Vision, Android ML Kit, etc.).
  final Map<String, dynamic>? platformOptions;

  /// Creates a text recognition configuration.
  const TextRecognitionConfig({
    this.recognitionLevel = RecognitionLevel.accurate,
    this.usesLanguageCorrection = true,
    this.preferredLanguages,
    this.minimumTextHeight,
    this.maxCandidates,
    this.revision,
    this.automaticallyDetectsLanguage = true,
    this.platformOptions,
  });

  /// Creates a configuration optimized for speed.
  ///
  /// Uses fast recognition level and minimal post-processing.
  factory TextRecognitionConfig.speed() {
    return const TextRecognitionConfig(
      recognitionLevel: RecognitionLevel.fast,
      usesLanguageCorrection: false,
      automaticallyDetectsLanguage: false,
    );
  }

  /// Creates a configuration optimized for accuracy.
  ///
  /// Uses accurate recognition level with language correction enabled.
  factory TextRecognitionConfig.accuracy() {
    return const TextRecognitionConfig(
      recognitionLevel: RecognitionLevel.accurate,
      usesLanguageCorrection: true,
      automaticallyDetectsLanguage: true,
    );
  }

  /// Creates a configuration for specific languages.
  ///
  /// [languages] should be ISO 639-1 language codes.
  factory TextRecognitionConfig.languages(List<String> languages) {
    return TextRecognitionConfig(
      recognitionLevel: RecognitionLevel.accurate,
      usesLanguageCorrection: true,
      preferredLanguages: languages,
      automaticallyDetectsLanguage: false,
    );
  }

  /// Converts the configuration to a map for platform communication.
  Map<String, dynamic> toMap() {
    return {
      'recognitionLevel': recognitionLevel.value,
      'usesLanguageCorrection': usesLanguageCorrection,
      'preferredLanguages': preferredLanguages,
      'minimumTextHeight': minimumTextHeight,
      'maxCandidates': maxCandidates,
      'revision': revision,
      'automaticallyDetectsLanguage': automaticallyDetectsLanguage,
      'platformOptions': platformOptions,
    };
  }

  /// Creates a TextRecognitionConfig from a map representation.
  factory TextRecognitionConfig.fromMap(Map<String, dynamic> map) {
    return TextRecognitionConfig(
      recognitionLevel: RecognitionLevelExtension.fromString(
        map['recognitionLevel'] as String? ?? 'accurate',
      ),
      usesLanguageCorrection: map['usesLanguageCorrection'] as bool? ?? true,
      preferredLanguages: (map['preferredLanguages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      minimumTextHeight: map['minimumTextHeight'] as double?,
      maxCandidates: map['maxCandidates'] as int?,
      revision: map['revision'] as int?,
      automaticallyDetectsLanguage:
          map['automaticallyDetectsLanguage'] as bool? ?? true,
      platformOptions: map['platformOptions'] as Map<String, dynamic>?,
    );
  }

  /// Returns a copy of this configuration with updated properties.
  TextRecognitionConfig copyWith({
    RecognitionLevel? recognitionLevel,
    bool? usesLanguageCorrection,
    List<String>? preferredLanguages,
    double? minimumTextHeight,
    int? maxCandidates,
    int? revision,
    bool? automaticallyDetectsLanguage,
    Map<String, dynamic>? platformOptions,
  }) {
    return TextRecognitionConfig(
      recognitionLevel: recognitionLevel ?? this.recognitionLevel,
      usesLanguageCorrection:
          usesLanguageCorrection ?? this.usesLanguageCorrection,
      preferredLanguages: preferredLanguages ?? this.preferredLanguages,
      minimumTextHeight: minimumTextHeight ?? this.minimumTextHeight,
      maxCandidates: maxCandidates ?? this.maxCandidates,
      revision: revision ?? this.revision,
      automaticallyDetectsLanguage:
          automaticallyDetectsLanguage ?? this.automaticallyDetectsLanguage,
      platformOptions: platformOptions ?? this.platformOptions,
    );
  }

  @override
  String toString() {
    return 'TextRecognitionConfig('
        'recognitionLevel: $recognitionLevel, '
        'usesLanguageCorrection: $usesLanguageCorrection, '
        'preferredLanguages: $preferredLanguages)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextRecognitionConfig &&
        other.recognitionLevel == recognitionLevel &&
        other.usesLanguageCorrection == usesLanguageCorrection &&
        other.preferredLanguages == preferredLanguages &&
        other.minimumTextHeight == minimumTextHeight &&
        other.maxCandidates == maxCandidates &&
        other.revision == revision &&
        other.automaticallyDetectsLanguage == automaticallyDetectsLanguage;
  }

  @override
  int get hashCode {
    return Object.hash(
      recognitionLevel,
      usesLanguageCorrection,
      preferredLanguages,
      minimumTextHeight,
      maxCandidates,
      revision,
      automaticallyDetectsLanguage,
    );
  }
}

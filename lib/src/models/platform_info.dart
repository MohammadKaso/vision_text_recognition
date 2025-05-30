/// Information about the current platform and its text recognition capabilities.
///
/// Provides details about the underlying recognition engine,
/// supported features, and platform-specific version information.
class PlatformInfo {
  /// The platform name ('iOS', 'Android', etc.)
  final String platform;

  /// The platform version (OS version)
  final String platformVersion;

  /// The recognition engine being used ('Vision', 'MLKit', etc.)
  final String engine;

  /// The version of the recognition engine
  final String engineVersion;

  /// List of capabilities supported by this platform
  final List<String> capabilities;

  /// Whether language correction is available
  final bool supportsLanguageCorrection;

  /// Whether confidence scores are available
  final bool supportsConfidenceScores;

  /// Whether bounding boxes are available
  final bool supportsBoundingBoxes;

  /// Whether language detection is available
  final bool supportsLanguageDetection;

  /// List of supported recognition levels
  final List<String> supportedRecognitionLevels;

  /// Additional platform-specific metadata
  final Map<String, dynamic>? metadata;

  /// Creates platform information.
  const PlatformInfo({
    required this.platform,
    required this.platformVersion,
    required this.engine,
    required this.engineVersion,
    required this.capabilities,
    required this.supportsLanguageCorrection,
    required this.supportsConfidenceScores,
    required this.supportsBoundingBoxes,
    required this.supportsLanguageDetection,
    required this.supportedRecognitionLevels,
    this.metadata,
  });

  /// Creates PlatformInfo from a map representation.
  factory PlatformInfo.fromMap(Map<String, dynamic> map) {
    return PlatformInfo(
      platform: map['platform'] as String,
      platformVersion: map['platformVersion'] as String,
      engine: map['engine'] as String,
      engineVersion: map['engineVersion'] as String,
      capabilities: (map['capabilities'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      supportsLanguageCorrection: map['supportsLanguageCorrection'] as bool,
      supportsConfidenceScores: map['supportsConfidenceScores'] as bool,
      supportsBoundingBoxes: map['supportsBoundingBoxes'] as bool,
      supportsLanguageDetection: map['supportsLanguageDetection'] as bool,
      supportedRecognitionLevels:
          (map['supportedRecognitionLevels'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts the platform info to a map representation.
  Map<String, dynamic> toMap() {
    return {
      'platform': platform,
      'platformVersion': platformVersion,
      'engine': engine,
      'engineVersion': engineVersion,
      'capabilities': capabilities,
      'supportsLanguageCorrection': supportsLanguageCorrection,
      'supportsConfidenceScores': supportsConfidenceScores,
      'supportsBoundingBoxes': supportsBoundingBoxes,
      'supportsLanguageDetection': supportsLanguageDetection,
      'supportedRecognitionLevels': supportedRecognitionLevels,
      'metadata': metadata,
    };
  }

  /// Returns true if the specified capability is supported.
  bool hasCapability(String capability) {
    return capabilities.contains(capability);
  }

  /// Returns true if the specified recognition level is supported.
  bool supportsRecognitionLevel(String level) {
    return supportedRecognitionLevels.contains(level);
  }

  /// Returns true if this platform supports all basic text recognition features.
  bool get isFullySupported {
    return supportsConfidenceScores &&
        supportsBoundingBoxes &&
        supportedRecognitionLevels.isNotEmpty;
  }

  /// Returns a human-readable description of the platform.
  String get description {
    return '$engine $engineVersion on $platform $platformVersion';
  }

  /// Returns a copy of this platform info with updated properties.
  PlatformInfo copyWith({
    String? platform,
    String? platformVersion,
    String? engine,
    String? engineVersion,
    List<String>? capabilities,
    bool? supportsLanguageCorrection,
    bool? supportsConfidenceScores,
    bool? supportsBoundingBoxes,
    bool? supportsLanguageDetection,
    List<String>? supportedRecognitionLevels,
    Map<String, dynamic>? metadata,
  }) {
    return PlatformInfo(
      platform: platform ?? this.platform,
      platformVersion: platformVersion ?? this.platformVersion,
      engine: engine ?? this.engine,
      engineVersion: engineVersion ?? this.engineVersion,
      capabilities: capabilities ?? this.capabilities,
      supportsLanguageCorrection:
          supportsLanguageCorrection ?? this.supportsLanguageCorrection,
      supportsConfidenceScores:
          supportsConfidenceScores ?? this.supportsConfidenceScores,
      supportsBoundingBoxes:
          supportsBoundingBoxes ?? this.supportsBoundingBoxes,
      supportsLanguageDetection:
          supportsLanguageDetection ?? this.supportsLanguageDetection,
      supportedRecognitionLevels:
          supportedRecognitionLevels ?? this.supportedRecognitionLevels,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'PlatformInfo($description, capabilities: ${capabilities.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlatformInfo &&
        other.platform == platform &&
        other.platformVersion == platformVersion &&
        other.engine == engine &&
        other.engineVersion == engineVersion;
  }

  @override
  int get hashCode {
    return Object.hash(platform, platformVersion, engine, engineVersion);
  }
}

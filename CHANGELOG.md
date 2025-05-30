# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-19

### Added
- **Initial Release**: Complete Flutter plugin for advanced text recognition
- **Cross-Platform Support**: Optimized implementations for iOS (Vision framework) and Android (ML Kit)
- **High-Accuracy OCR**: Platform-specific engines for optimal recognition quality
- **Confidence Scores**: Get confidence ratings for recognized text elements
- **Bounding Boxes**: Precise positioning information for text blocks
- **Language Support**: Multi-language text recognition and detection
- **Configurable Options**: Extensive customization for different use cases
- **Recognition Levels**: Choose between speed and accuracy optimization
- **Language Correction**: Automatic language detection and correction (iOS)
- **Custom Configurations**: Predefined and custom recognition configurations
- **Comprehensive API**: Complete set of methods for text recognition tasks
- **Platform Information**: Query platform capabilities and supported languages
- **Error Handling**: Robust error handling with detailed exception information
- **Example App**: Complete example demonstrating all plugin features
- **Unit Tests**: Comprehensive test suite with 100% coverage
- **Documentation**: Detailed README with usage examples and API documentation

### Platform Features

#### iOS (Vision Framework)
- Language correction and detection
- Multiple recognition levels (fast/accurate) 
- Minimum text height filtering
- Custom model revisions
- Advanced language preferences
- iOS 13.0+ support

#### Android (ML Kit)
- Latin-based language support
- Standardized recognition quality
- Optimized for device performance
- Offline processing
- Android API 21+ support

### Technical Details
- **Flutter SDK**: 3.16.0+
- **Dart SDK**: 3.2.0+
- **Platform Interface**: 2.1.7+
- **Type Safety**: Full type safety with robust error handling
- **Performance**: Optimized for both speed and accuracy scenarios
- **Memory Management**: Efficient handling of image data and results

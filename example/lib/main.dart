import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vision_text_recognition/vision_text_recognition.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vision Text Recognition Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Vision Text Recognition Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _recognitionResult = 'No text recognized yet';
  bool _isProcessing = false;
  PlatformInfo? _platformInfo;
  List<String> _supportedLanguages = [];
  TextRecognitionResult? _lastResult;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    try {
      final platformInfo = await VisionTextRecognition.getPlatformInfo();
      final supportedLanguages =
          await VisionTextRecognition.getSupportedLanguages();
      final isAvailable = await VisionTextRecognition.isAvailable();

      setState(() {
        _platformInfo = platformInfo;
        _supportedLanguages = supportedLanguages;
        _recognitionResult = isAvailable
            ? 'Text recognition is available. Select an image to get started.'
            : 'Text recognition is not available on this platform.';
      });
    } catch (e) {
      setState(() {
        _recognitionResult = 'Error initializing platform: $e';
      });
    }
  }

  Future<void> _pickAndRecognizeImage({bool useCustomConfig = false}) async {
    if (_isProcessing) return;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _isProcessing = true;
      _recognitionResult = 'Processing image...';
    });

    try {
      final imageBytes = await image.readAsBytes();

      TextRecognitionResult result;

      if (useCustomConfig) {
        // Use custom configuration for better accuracy
        final config = TextRecognitionConfig(
          recognitionLevel: RecognitionLevel.accurate,
          usesLanguageCorrection: true,
          automaticallyDetectsLanguage: true,
          minimumTextHeight: 0.01, // Minimum text height
        );
        result = await VisionTextRecognition.recognizeTextWithConfig(
          imageBytes,
          config,
        );
      } else {
        // Use default configuration
        result = await VisionTextRecognition.recognizeText(imageBytes);
      }

      setState(() {
        _lastResult = result;
        _recognitionResult = _formatResult(result);
      });
    } catch (e) {
      setState(() {
        _recognitionResult = 'Error: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _takePhotoAndRecognize() async {
    if (_isProcessing) return;

    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    setState(() {
      _isProcessing = true;
      _recognitionResult = 'Processing photo...';
    });

    try {
      final imageBytes = await photo.readAsBytes();

      // Use speed-optimized configuration for camera
      final config = TextRecognitionConfig.speed();
      final result = await VisionTextRecognition.recognizeTextWithConfig(
        imageBytes,
        config,
      );

      setState(() {
        _lastResult = result;
        _recognitionResult = _formatResult(result);
      });
    } catch (e) {
      setState(() {
        _recognitionResult = 'Error: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  String _formatResult(TextRecognitionResult result) {
    final buffer = StringBuffer();

    buffer.writeln('=== RECOGNITION RESULT ===');
    buffer.writeln('Full Text:');
    buffer.writeln(
      result.fullText.isEmpty ? '(No text detected)' : result.fullText,
    );
    buffer.writeln();

    buffer.writeln('Statistics:');
    buffer.writeln(
      '• Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%',
    );
    buffer.writeln('• Text Blocks: ${result.textBlocks.length}');
    if (result.processingTimeMs != null) {
      buffer.writeln('• Processing Time: ${result.processingTimeMs}ms');
    }
    if (result.detectedLanguage != null) {
      buffer.writeln('• Detected Language: ${result.detectedLanguage}');
    }
    buffer.writeln();

    if (result.textBlocks.isNotEmpty) {
      buffer.writeln('Individual Text Blocks:');
      for (int i = 0; i < result.textBlocks.length; i++) {
        final block = result.textBlocks[i];
        buffer.writeln(
          '${i + 1}. "${block.text}" (${(block.confidence * 100).toStringAsFixed(1)}%)',
        );
        buffer.writeln(
          '   Position: (${(block.boundingBox.x * 100).toStringAsFixed(1)}%, ${(block.boundingBox.y * 100).toStringAsFixed(1)}%)',
        );
        buffer.writeln(
          '   Size: ${(block.boundingBox.width * 100).toStringAsFixed(1)}% × ${(block.boundingBox.height * 100).toStringAsFixed(1)}%',
        );
        if (block.language != null) {
          buffer.writeln('   Language: ${block.language}');
        }
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  void _showPlatformInfo() {
    if (_platformInfo == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Platform Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Platform', _platformInfo!.platform),
              _buildInfoRow('Platform Version', _platformInfo!.platformVersion),
              _buildInfoRow('Engine', _platformInfo!.engine),
              _buildInfoRow('Engine Version', _platformInfo!.engineVersion),
              const SizedBox(height: 16),
              const Text(
                'Capabilities:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...(_platformInfo!.capabilities.map(
                (cap) => Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text('• $cap'),
                ),
              )),
              const SizedBox(height: 16),
              _buildInfoRow(
                'Language Correction',
                _platformInfo!.supportsLanguageCorrection ? 'Yes' : 'No',
              ),
              _buildInfoRow(
                'Confidence Scores',
                _platformInfo!.supportsConfidenceScores ? 'Yes' : 'No',
              ),
              _buildInfoRow(
                'Bounding Boxes',
                _platformInfo!.supportsBoundingBoxes ? 'Yes' : 'No',
              ),
              _buildInfoRow(
                'Language Detection',
                _platformInfo!.supportsLanguageDetection ? 'Yes' : 'No',
              ),
              const SizedBox(height: 16),
              const Text(
                'Recognition Levels:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...(_platformInfo!.supportedRecognitionLevels.map(
                (level) => Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text('• $level'),
                ),
              )),
              const SizedBox(height: 16),
              const Text(
                'Supported Languages:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...(_supportedLanguages.map(
                (lang) => Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text('• $lang'),
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _copyToClipboard() {
    if (_lastResult?.fullText.isNotEmpty == true) {
      Clipboard.setData(ClipboardData(text: _lastResult!.fullText));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Text copied to clipboard')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _showPlatformInfo,
            icon: const Icon(Icons.info),
            tooltip: 'Platform Info',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Select an image or take a photo to recognize text',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isProcessing
                                ? null
                                : () => _pickAndRecognizeImage(
                                    useCustomConfig: false,
                                  ),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery (Fast)'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isProcessing
                                ? null
                                : () => _pickAndRecognizeImage(
                                    useCustomConfig: true,
                                  ),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery (Accurate)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : _takePhotoAndRecognize,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take Photo'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Recognition Result',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (_lastResult?.fullText.isNotEmpty == true)
                            IconButton(
                              onPressed: _copyToClipboard,
                              icon: const Icon(Icons.copy),
                              tooltip: 'Copy text',
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _isProcessing
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 16),
                                      Text('Processing image...'),
                                    ],
                                  ),
                                )
                              : SelectableText(
                                  _recognitionResult,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

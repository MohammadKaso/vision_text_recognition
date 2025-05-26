import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class MediaProvider extends ChangeNotifier {
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isRecording = false;
  String? _recordingPath;
  File? _selectedImage;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isRecording => _isRecording;
  String? get recordingPath => _recordingPath;
  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Image handling
  Future<File?> pickImageFromCamera() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        return _selectedImage;
      }
      return null;
    } catch (e) {
      _errorMessage = 'Failed to take photo: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<File?> pickImageFromGallery() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        return _selectedImage;
      }
      return null;
    } catch (e) {
      _errorMessage = 'Failed to select image: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<File>?> pickMultipleImages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        return images.map((xFile) => File(xFile.path)).toList();
      }
      return null;
    } catch (e) {
      _errorMessage = 'Failed to select images: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Audio recording
  Future<bool> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'order_${DateTime.now().millisecondsSinceEpoch}.m4a';
        _recordingPath = '${directory.path}/$fileName';

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _recordingPath!,
        );

        _isRecording = true;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Microphone permission not granted';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to start recording: $e';
      notifyListeners();
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _isRecording = false;
      notifyListeners();

      if (path != null) {
        _recordingPath = path;
        return path;
      }
      return null;
    } catch (e) {
      _errorMessage = 'Failed to stop recording: $e';
      _isRecording = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> cancelRecording() async {
    try {
      await _audioRecorder.cancel();
      _isRecording = false;
      _recordingPath = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to cancel recording: $e';
      notifyListeners();
    }
  }

  // Cleanup
  void clearSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }

  void clearRecording() {
    _recordingPath = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearAll() {
    _selectedImage = null;
    _recordingPath = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }
}

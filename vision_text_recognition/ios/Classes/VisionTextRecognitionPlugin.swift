import Flutter
import UIKit
import Vision
import Foundation

public class VisionTextRecognitionPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "vision_text_recognition", binaryMessenger: registrar.messenger())
        let instance = VisionTextRecognitionPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "recognizeText":
            handleRecognizeText(call: call, result: result)
        case "recognizeTextWithConfig":
            handleRecognizeTextWithConfig(call: call, result: result)
        case "getPlatformInfo":
            handleGetPlatformInfo(result: result)
        case "isAvailable":
            handleIsAvailable(result: result)
        case "getSupportedLanguages":
            handleGetSupportedLanguages(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleRecognizeText(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let imageBytes = args["imageBytes"] as? FlutterStandardTypedData else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Image bytes not provided", details: nil))
            return
        }
        
        // Use default configuration
        let defaultConfig = TextRecognitionConfig()
        recognizeText(imageData: imageBytes.data, config: defaultConfig, result: result)
    }
    
    private func handleRecognizeTextWithConfig(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let imageBytes = args["imageBytes"] as? FlutterStandardTypedData,
              let configMap = args["config"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Image bytes or config not provided", details: nil))
            return
        }
        
        let config = TextRecognitionConfig.fromMap(configMap)
        recognizeText(imageData: imageBytes.data, config: config, result: result)
    }
    
    private func handleGetPlatformInfo(result: @escaping FlutterResult) {
        let platformInfo: [String: Any] = [
            "platform": "iOS",
            "platformVersion": UIDevice.current.systemVersion,
            "engine": "Vision",
            "engineVersion": "iOS \(UIDevice.current.systemVersion)",
            "capabilities": [
                "text_recognition",
                "confidence_scores",
                "bounding_boxes",
                "language_detection",
                "language_correction"
            ],
            "supportsLanguageCorrection": true,
            "supportsConfidenceScores": true,
            "supportsBoundingBoxes": true,
            "supportsLanguageDetection": true,
            "supportedRecognitionLevels": ["fast", "accurate"]
        ]
        
        result(platformInfo)
    }
    
    private func handleIsAvailable(result: @escaping FlutterResult) {
        if #available(iOS 13.0, *) {
            result(true)
        } else {
            result(false)
        }
    }
    
    private func handleGetSupportedLanguages(result: @escaping FlutterResult) {
        // Vision framework supports many languages, but exact list is not directly accessible
        // These are commonly supported languages
        let supportedLanguages = [
            "en", "es", "fr", "de", "it", "pt", "ru", "ja", "ko", "zh", "ar", "hi"
        ]
        result(supportedLanguages)
    }
    
    private func recognizeText(imageData: Data, config: TextRecognitionConfig, result: @escaping FlutterResult) {
        guard let image = UIImage(data: imageData),
              let cgImage = image.cgImage else {
            result(FlutterError(code: "INVALID_IMAGE", message: "Could not create image from data", details: nil))
            return
        }
        
        if #available(iOS 13.0, *) {
            let startTime = CFAbsoluteTimeGetCurrent()
            
            let request = VNRecognizeTextRequest { [weak self] (request, error) in
                if let error = error {
                    result(FlutterError(code: "VISION_ERROR", message: error.localizedDescription, details: nil))
                    return
                }
                
                let processingTime = Int((CFAbsoluteTimeGetCurrent() - startTime) * 1000)
                self?.processVisionResults(request: request, processingTime: processingTime, result: result)
            }
            
            // Configure the request based on config
            request.recognitionLevel = config.recognitionLevel == "fast" ? .fast : .accurate
            request.usesLanguageCorrection = config.usesLanguageCorrection
            
            // automaticallyDetectsLanguage is only available in iOS 16.0+
            if #available(iOS 16.0, *) {
                request.automaticallyDetectsLanguage = config.automaticallyDetectsLanguage
            }
            
            if let minimumTextHeight = config.minimumTextHeight {
                request.minimumTextHeight = Float(minimumTextHeight)
            }
            
            if let preferredLanguages = config.preferredLanguages, !preferredLanguages.isEmpty {
                request.recognitionLanguages = preferredLanguages
            }
            
            if let revision = config.revision {
                request.revision = revision
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    result(FlutterError(code: "VISION_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        } else {
            result(FlutterError(code: "UNSUPPORTED_VERSION", message: "Text recognition requires iOS 13.0 or later", details: nil))
        }
    }
    
    private func processVisionResults(request: VNRequest, processingTime: Int, result: @escaping FlutterResult) {
        if #available(iOS 13.0, *) {
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                result(FlutterError(code: "NO_RESULTS", message: "No text recognition results", details: nil))
                return
            }
            
            var fullText = ""
            var textBlocks: [[String: Any]] = []
            var confidenceSum: Double = 0.0
            var detectedLanguages: Set<String> = Set()
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                
                let text = topCandidate.string
                let confidence = Double(topCandidate.confidence)
                let boundingBox = observation.boundingBox
                
                // Convert Vision coordinates (normalized, origin bottom-left) to standard coordinates
                let convertedBounds: [String: Double] = [
                    "x": boundingBox.origin.x,
                    "y": 1.0 - boundingBox.origin.y - boundingBox.size.height,
                    "width": boundingBox.size.width,
                    "height": boundingBox.size.height
                ]
                
                var textBlockMetadata: [String: Any] = [:]
                
                // Try to detect language (basic heuristic)
                if let detectedLanguage = detectLanguage(text: text) {
                    detectedLanguages.insert(detectedLanguage)
                    textBlockMetadata["detectedLanguage"] = detectedLanguage
                }
                
                let textBlock: [String: Any] = [
                    "text": text,
                    "confidence": confidence,
                    "boundingBox": convertedBounds,
                    "metadata": textBlockMetadata
                ]
                
                textBlocks.append(textBlock)
                fullText += text + " "
                confidenceSum += confidence
            }
            
            let averageConfidence = textBlocks.isEmpty ? 0.0 : confidenceSum / Double(textBlocks.count)
            let primaryLanguage = detectedLanguages.first
            
            let resultData: [String: Any] = [
                "fullText": fullText.trimmingCharacters(in: .whitespacesAndNewlines),
                "textBlocks": textBlocks,
                "confidence": averageConfidence,
                "processingTimeMs": processingTime,
                "detectedLanguage": primaryLanguage as Any,
                "metadata": [
                    "totalBlocks": textBlocks.count,
                    "detectedLanguages": Array(detectedLanguages),
                    "platform": "iOS Vision"
                ]
            ]
            
            DispatchQueue.main.async {
                result(resultData)
            }
        } else {
            result(FlutterError(code: "UNSUPPORTED_VERSION", message: "Text recognition requires iOS 13.0 or later", details: nil))
        }
    }
    
    private func detectLanguage(text: String) -> String? {
        // Basic language detection heuristics
        let text = text.lowercased()
        
        // Check for common patterns
        if text.range(of: "[а-я]", options: .regularExpression) != nil {
            return "ru"
        } else if text.range(of: "[ñáéíóúü]", options: .regularExpression) != nil {
            return "es"
        } else if text.range(of: "[àâäéèêëïîôöùûüÿç]", options: .regularExpression) != nil {
            return "fr"
        } else if text.range(of: "[äöüß]", options: .regularExpression) != nil {
            return "de"
        } else if text.range(of: "[ひらがなカタカナ]", options: .regularExpression) != nil {
            return "ja"
        } else if text.range(of: "[一-龯]", options: .regularExpression) != nil {
            return "zh"
        } else if text.range(of: "[ا-ي]", options: .regularExpression) != nil {
            return "ar"
        } else if text.range(of: "[a-zA-Z]", options: .regularExpression) != nil {
            return "en"
        }
        
        return nil
    }
}

// MARK: - Configuration Helper

private struct TextRecognitionConfig {
    let recognitionLevel: String
    let usesLanguageCorrection: Bool
    let preferredLanguages: [String]?
    let minimumTextHeight: Double?
    let maxCandidates: Int?
    let revision: Int?
    let automaticallyDetectsLanguage: Bool
    
    init() {
        self.recognitionLevel = "accurate"
        self.usesLanguageCorrection = true
        self.preferredLanguages = nil
        self.minimumTextHeight = nil
        self.maxCandidates = nil
        self.revision = nil
        self.automaticallyDetectsLanguage = true
    }
    
    static func fromMap(_ map: [String: Any]) -> TextRecognitionConfig {
        return TextRecognitionConfig(
            recognitionLevel: map["recognitionLevel"] as? String ?? "accurate",
            usesLanguageCorrection: map["usesLanguageCorrection"] as? Bool ?? true,
            preferredLanguages: map["preferredLanguages"] as? [String],
            minimumTextHeight: map["minimumTextHeight"] as? Double,
            maxCandidates: map["maxCandidates"] as? Int,
            revision: map["revision"] as? Int,
            automaticallyDetectsLanguage: map["automaticallyDetectsLanguage"] as? Bool ?? true
        )
    }
}

extension TextRecognitionConfig {
    init(recognitionLevel: String, usesLanguageCorrection: Bool, preferredLanguages: [String]?, minimumTextHeight: Double?, maxCandidates: Int?, revision: Int?, automaticallyDetectsLanguage: Bool) {
        self.recognitionLevel = recognitionLevel
        self.usesLanguageCorrection = usesLanguageCorrection
        self.preferredLanguages = preferredLanguages
        self.minimumTextHeight = minimumTextHeight
        self.maxCandidates = maxCandidates
        self.revision = revision
        self.automaticallyDetectsLanguage = automaticallyDetectsLanguage
    }
}

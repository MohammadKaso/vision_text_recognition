import Flutter
import UIKit
import Vision

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Register our custom Vision OCR plugin
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let visionChannel = FlutterMethodChannel(name: "ios_vision_ocr",
                                           binaryMessenger: controller.binaryMessenger)
    
    visionChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      self.handleVisionMethodCall(call: call, result: result)
    })
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func handleVisionMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "recognizeText":
      guard let args = call.arguments as? [String: Any],
            let imageBytes = args["imageBytes"] as? FlutterStandardTypedData else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Image bytes not provided", details: nil))
        return
      }
      
      recognizeText(imageData: imageBytes.data, result: result)
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func recognizeText(imageData: Data, result: @escaping FlutterResult) {
    guard let image = UIImage(data: imageData),
          let cgImage = image.cgImage else {
      result(FlutterError(code: "INVALID_IMAGE", message: "Could not create image from data", details: nil))
      return
    }
    
    if #available(iOS 13.0, *) {
      let request = VNRecognizeTextRequest { [weak self] (request, error) in
        if let error = error {
          result(FlutterError(code: "VISION_ERROR", message: error.localizedDescription, details: nil))
          return
        }
        
        self?.processVisionResults(request: request, result: result)
      }
      
      // Configure for better accuracy
      request.recognitionLevel = .accurate
      request.usesLanguageCorrection = true
      
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
  
  private func processVisionResults(request: VNRequest, result: @escaping FlutterResult) {
    if #available(iOS 13.0, *) {
      guard let observations = request.results as? [VNRecognizedTextObservation] else {
        result(FlutterError(code: "NO_RESULTS", message: "No text recognition results", details: nil))
        return
      }
    
    var fullText = ""
    var textBlocks: [[String: Any]] = []
    
    for observation in observations {
      guard let topCandidate = observation.topCandidates(1).first else { continue }
      
      let text = topCandidate.string
      let confidence = topCandidate.confidence
      let boundingBox = observation.boundingBox
      
      // Convert Vision coordinates (normalized, origin bottom-left) to standard coordinates
      let convertedBounds = [
        "x": boundingBox.origin.x,
        "y": 1.0 - boundingBox.origin.y - boundingBox.size.height, // Flip Y coordinate
        "width": boundingBox.size.width,
        "height": boundingBox.size.height
      ]
      
      let textBlock: [String: Any] = [
        "text": text,
        "confidence": confidence,
        "boundingBox": convertedBounds
      ]
      
      textBlocks.append(textBlock)
      fullText += text + " "
    }
    
    let resultData: [String: Any] = [
      "fullText": fullText.trimmingCharacters(in: .whitespacesAndNewlines),
      "textBlocks": textBlocks
    ]
    
      DispatchQueue.main.async {
        result(resultData)
      }
    } else {
      result(FlutterError(code: "UNSUPPORTED_VERSION", message: "Text recognition requires iOS 13.0 or later", details: nil))
    }
  }
}

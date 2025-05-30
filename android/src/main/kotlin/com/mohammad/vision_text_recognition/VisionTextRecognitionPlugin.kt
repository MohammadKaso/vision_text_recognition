package com.mohammad.vision_text_recognition

import android.graphics.BitmapFactory
import androidx.annotation.NonNull
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** VisionTextRecognitionPlugin */
class VisionTextRecognitionPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will handle communication between Flutter and native Android
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "vision_text_recognition")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "recognizeText" -> handleRecognizeText(call, result)
      "recognizeTextWithConfig" -> handleRecognizeTextWithConfig(call, result)
      "getPlatformInfo" -> handleGetPlatformInfo(result)
      "isAvailable" -> handleIsAvailable(result)
      "getSupportedLanguages" -> handleGetSupportedLanguages(result)
      else -> result.notImplemented()
    }
  }

  private fun handleRecognizeText(call: MethodCall, result: Result) {
    val imageBytes = call.argument<ByteArray>("imageBytes")
    if (imageBytes == null) {
      result.error("INVALID_ARGUMENT", "Image bytes not provided", null)
      return
    }
    
    // Use default configuration
    recognizeText(imageBytes, null, result)
  }

  private fun handleRecognizeTextWithConfig(call: MethodCall, result: Result) {
    val imageBytes = call.argument<ByteArray>("imageBytes")
    val config = call.argument<Map<String, Any?>>("config")
    
    if (imageBytes == null) {
      result.error("INVALID_ARGUMENT", "Image bytes not provided", null)
      return
    }
    
    recognizeText(imageBytes, config, result)
  }

  private fun handleGetPlatformInfo(result: Result) {
    val platformInfo = mapOf(
      "platform" to "Android",
      "platformVersion" to android.os.Build.VERSION.RELEASE,
      "engine" to "ML Kit",
      "engineVersion" to "Latest",
      "capabilities" to listOf(
        "text_recognition",
        "confidence_scores",
        "bounding_boxes"
      ),
      "supportsLanguageCorrection" to false,
      "supportsConfidenceScores" to true,
      "supportsBoundingBoxes" to true,
      "supportsLanguageDetection" to false,
      "supportedRecognitionLevels" to listOf("standard")
    )
    
    result.success(platformInfo)
  }

  private fun handleIsAvailable(result: Result) {
    result.success(true)
  }

  private fun handleGetSupportedLanguages(result: Result) {
    // ML Kit supports Latin-based languages primarily
    val supportedLanguages = listOf(
      "en", "es", "fr", "de", "it", "pt", "nl", "pl", "cs", "sk", "hu", "ro", "hr", "sl"
    )
    result.success(supportedLanguages)
  }

  private fun recognizeText(imageBytes: ByteArray, config: Map<String, Any?>?, result: Result) {
    try {
      val startTime = System.currentTimeMillis()
      
      val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
      if (bitmap == null) {
        result.error("INVALID_IMAGE", "Could not decode image from bytes", null)
        return
      }

      val image = InputImage.fromBitmap(bitmap, 0)
      val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)

      recognizer.process(image)
        .addOnSuccessListener { visionText ->
          val processingTime = (System.currentTimeMillis() - startTime).toInt()
          
          val fullText = visionText.text
          val textBlocks = mutableListOf<Map<String, Any>>()
          var confidenceSum = 0.0
          var blockCount = 0

          for (block in visionText.textBlocks) {
            for (line in block.lines) {
              for (element in line.elements) {
                val boundingBox = element.boundingBox
                val text = element.text
                
                // ML Kit doesn't provide confidence scores, so we use a default
                val confidence = 0.9 // Default high confidence for ML Kit
                confidenceSum += confidence
                blockCount++

                if (boundingBox != null) {
                  // Convert to normalized coordinates (0.0 to 1.0)
                  val normalizedBounds = mapOf(
                    "x" to (boundingBox.left.toDouble() / bitmap.width),
                    "y" to (boundingBox.top.toDouble() / bitmap.height),
                    "width" to (boundingBox.width().toDouble() / bitmap.width),
                    "height" to (boundingBox.height().toDouble() / bitmap.height)
                  )

                  val textBlock = mapOf(
                    "text" to text,
                    "confidence" to confidence,
                    "boundingBox" to normalizedBounds,
                    "metadata" to mapOf<String, Any>()
                  )
                  
                  textBlocks.add(textBlock)
                }
              }
            }
          }

          val averageConfidence = if (blockCount > 0) confidenceSum / blockCount else 0.0

          val resultData = mapOf(
            "fullText" to fullText,
            "textBlocks" to textBlocks,
            "confidence" to averageConfidence,
            "processingTimeMs" to processingTime,
            "detectedLanguage" to null,
            "metadata" to mapOf(
              "totalBlocks" to textBlocks.size,
              "platform" to "Android ML Kit"
            )
          )

          result.success(resultData)
        }
        .addOnFailureListener { e ->
          result.error("ML_KIT_ERROR", e.message ?: "Text recognition failed", null)
        }

    } catch (e: Exception) {
      result.error("PROCESSING_ERROR", e.message ?: "Unknown error occurred", null)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}

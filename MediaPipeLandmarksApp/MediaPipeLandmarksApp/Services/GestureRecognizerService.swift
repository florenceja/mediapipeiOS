import UIKit
import MediaPipeTasksVision

protocol GestureRecognizerServiceDelegate: AnyObject {
    func gestureRecognizerService(_ service: GestureRecognizerService, didFinishRecognition result: GestureRecognizerResult?, imageSize: CGSize, error: Error?)
}

class GestureRecognizerService: NSObject {
    
    weak var delegate: GestureRecognizerServiceDelegate?
    private var gestureRecognizer: GestureRecognizer?
    private(set) var initializationErrorMessage: String?
    private var lastImageSize: CGSize = .zero
    private var lastTimestampMs = -1
    private let imageOrientation: UIImage.Orientation = .leftMirrored
    
    override init() {
        super.init()
        setupGestureRecognizer()
    }
    
    private func setupGestureRecognizer() {
        guard let modelPath = modelAssetPath() else {
            initializationErrorMessage = """
            缺少手势模型文件。请将 gesture_recognizer.task 放到 App target 资源中（推荐路径: MediaPipeLandmarksApp/Models）。
            """
            print("Error: \(initializationErrorMessage!)")
            return
        }
        
        let options = GestureRecognizerOptions()
        options.baseOptions.modelAssetPath = modelPath
        options.runningMode = .liveStream
        options.numHands = 2
        options.minHandDetectionConfidence = 0.5
        options.minHandPresenceConfidence = 0.5
        options.minTrackingConfidence = 0.5
        options.gestureRecognizerLiveStreamDelegate = self
        
        do {
            gestureRecognizer = try GestureRecognizer(options: options)
            initializationErrorMessage = nil
        } catch {
            initializationErrorMessage = "GestureRecognizer 初始化失败: \(error.localizedDescription)"
            print("Error initializing GestureRecognizer: \(error)")
        }
    }
    
    private func modelAssetPath() -> String? {
        let candidates = [
            ("gesture_recognizer", "task"),
            ("gesture_recognizer_v2", "task")
        ]
        
        for (name, ext) in candidates {
            if let path = Bundle.main.path(forResource: name, ofType: ext, inDirectory: "Models") {
                return path
            }
            if let path = Bundle.main.path(forResource: name, ofType: ext) {
                return path
            }
        }
        
        return nil
    }
    
    func recognizeAsync(sampleBuffer: CMSampleBuffer) {
        guard let gestureRecognizer = gestureRecognizer else { return }
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        lastImageSize = CGSize(width: CGFloat(width), height: CGFloat(height))
        
        var timestamp = Int(CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds * 1000)
        if timestamp <= lastTimestampMs {
            timestamp = lastTimestampMs + 1
        }
        lastTimestampMs = timestamp
        
        do {
            let mpImage = try MPImage(sampleBuffer: sampleBuffer, orientation: imageOrientation)
            try gestureRecognizer.recognizeAsync(image: mpImage, timestampInMilliseconds: timestamp)
        } catch {
            delegate?.gestureRecognizerService(self, didFinishRecognition: nil, imageSize: lastImageSize, error: error)
            print("Error recognizing gestures: \(error)")
        }
    }
}

extension GestureRecognizerService: GestureRecognizerLiveStreamDelegate {
    func gestureRecognizer(_ gestureRecognizer: GestureRecognizer, didFinishRecognition result: GestureRecognizerResult?, timestampInMilliseconds: Int, error: Error?) {
        delegate?.gestureRecognizerService(self, didFinishRecognition: result, imageSize: lastImageSize, error: error)
    }
}

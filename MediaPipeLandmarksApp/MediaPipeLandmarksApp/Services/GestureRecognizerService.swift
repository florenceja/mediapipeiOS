import UIKit
import MediaPipeTasksVision

protocol GestureRecognizerServiceDelegate: AnyObject {
    func gestureRecognizerService(_ service: GestureRecognizerService, didFinishRecognition result: GestureRecognizerResult?, imageSize: CGSize, error: Error?)
}

class GestureRecognizerService: NSObject {
    
    weak var delegate: GestureRecognizerServiceDelegate?
    private var gestureRecognizer: GestureRecognizer?
    private var lastImageSize: CGSize = .zero
    private var lastTimestampMs = -1
    private let imageOrientation: UIImage.Orientation = .leftMirrored
    
    override init() {
        super.init()
        setupGestureRecognizer()
    }
    
    private func setupGestureRecognizer() {
        guard let modelPath = Bundle.main.path(forResource: "gesture_recognizer", ofType: "task") else {
            print("Error: gesture_recognizer.task not found in bundle.")
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
        } catch {
            print("Error initializing GestureRecognizer: \(error)")
        }
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

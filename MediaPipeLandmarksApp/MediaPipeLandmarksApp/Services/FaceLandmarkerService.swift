import UIKit
import MediaPipeTasksVision

protocol FaceLandmarkerServiceDelegate: AnyObject {
    func faceLandmarkerService(_ service: FaceLandmarkerService, didFinishDetection result: FaceLandmarkerResult?, imageSize: CGSize, error: Error?)
}

class FaceLandmarkerService: NSObject {
    
    weak var delegate: FaceLandmarkerServiceDelegate?
    private var faceLandmarker: FaceLandmarker?
    
    override init() {
        super.init()
        setupFaceLandmarker()
    }
    
    private func setupFaceLandmarker() {
        guard let modelPath = Bundle.main.path(forResource: "face_landmarker", ofType: "task") else {
            print("Error: face_landmarker.task not found in bundle.")
            return
        }
        
        let options = FaceLandmarkerOptions()
        options.baseOptions.modelAssetPath = modelPath
        options.runningMode = .liveStream
        options.numFaces = 1
        options.minFaceDetectionConfidence = 0.5
        options.minFacePresenceConfidence = 0.5
        options.minTrackingConfidence = 0.5
        options.faceLandmarkerLiveStreamDelegate = self
        
        do {
            faceLandmarker = try FaceLandmarker(options: options)
        } catch {
            print("Error initializing FaceLandmarker: \(error)")
        }
    }
    
    private var lastImageSize: CGSize = .zero
    
    func detectAsync(sampleBuffer: CMSampleBuffer) {
        guard let faceLandmarker = faceLandmarker else { return }
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        lastImageSize = CGSize(width: CGFloat(width), height: CGFloat(height))
        
        let timestamp = Int(CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds * 1000)
        
        do {
            let mpImage = try MPImage(sampleBuffer: sampleBuffer)
            try faceLandmarker.detectAsync(image: mpImage, timestampInMilliseconds: timestamp)
        } catch {
            print("Error detecting face landmarks: \(error)")
        }
    }
}

extension FaceLandmarkerService: FaceLandmarkerLiveStreamDelegate {
    func faceLandmarker(_ faceLandmarker: FaceLandmarker, didFinishDetection result: FaceLandmarkerResult?, timestampInMilliseconds: Int, error: Error?) {
        delegate?.faceLandmarkerService(self, didFinishDetection: result, imageSize: lastImageSize, error: error)
    }
}

import UIKit
import MediaPipeTasksVision

protocol FaceLandmarkerServiceDelegate: AnyObject {
    func faceLandmarkerService(_ service: FaceLandmarkerService, didFinishDetection result: FaceLandmarkerResult?, imageSize: CGSize, error: Error?)
}

class FaceLandmarkerService: NSObject {
    
    weak var delegate: FaceLandmarkerServiceDelegate?
    private var faceLandmarker: FaceLandmarker?
    private(set) var initializationErrorMessage: String?
    private var lastImageSize: CGSize = .zero
    private var lastTimestampMs = -1
    private let imageOrientation: UIImage.Orientation = .leftMirrored
    
    override init() {
        super.init()
        setupFaceLandmarker()
    }
    
    private func setupFaceLandmarker() {
        guard let modelPath = modelAssetPath() else {
            initializationErrorMessage = """
            缺少人脸模型文件。请将 face_landmarker.task 放到 App target 资源中（推荐路径: MediaPipeLandmarksApp/Models）。
            """
            print("Error: \(initializationErrorMessage!)")
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
            initializationErrorMessage = nil
        } catch {
            initializationErrorMessage = "FaceLandmarker 初始化失败: \(error.localizedDescription)"
            print("Error initializing FaceLandmarker: \(error)")
        }
    }
    
    private func modelAssetPath() -> String? {
        let candidates = [
            ("face_landmarker", "task"),
            ("face_landmarker_v2_with_blendshapes", "task"),
            ("face_landmarker_v2", "task")
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
    
    func detectAsync(sampleBuffer: CMSampleBuffer) {
        guard let faceLandmarker = faceLandmarker else { return }
        
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
            try faceLandmarker.detectAsync(image: mpImage, timestampInMilliseconds: timestamp)
        } catch {
            delegate?.faceLandmarkerService(self, didFinishDetection: nil, imageSize: lastImageSize, error: error)
            print("Error detecting face landmarks: \(error)")
        }
    }
}

extension FaceLandmarkerService: FaceLandmarkerLiveStreamDelegate {
    func faceLandmarker(_ faceLandmarker: FaceLandmarker, didFinishDetection result: FaceLandmarkerResult?, timestampInMilliseconds: Int, error: Error?) {
        delegate?.faceLandmarkerService(self, didFinishDetection: result, imageSize: lastImageSize, error: error)
    }
}

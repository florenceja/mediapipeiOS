import UIKit
import AVFoundation
import MediaPipeTasksVision

class FaceDetectionViewController: UIViewController {
    
    private let cameraManager = CameraManager()
    private let faceLandmarkerService = FaceLandmarkerService()
    private let overlayView = FaceOverlayView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCamera()
        setupService()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraManager.startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraManager.stopSession()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        title = "Face Landmarks"
        
        cameraManager.previewLayer.frame = view.bounds
        view.layer.addSublayer(cameraManager.previewLayer)
        
        overlayView.frame = view.bounds
        view.addSubview(overlayView)
    }
    
    private func setupCamera() {
        cameraManager.delegate = self
        cameraManager.setupCamera()
    }
    
    private func setupService() {
        faceLandmarkerService.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraManager.previewLayer.frame = view.bounds
        overlayView.frame = view.bounds
    }
}

extension FaceDetectionViewController: CameraManagerDelegate {
    func cameraManager(_ manager: CameraManager, didOutput sampleBuffer: CMSampleBuffer) {
        faceLandmarkerService.detectAsync(sampleBuffer: sampleBuffer)
    }
}

extension FaceDetectionViewController: FaceLandmarkerServiceDelegate {
    func faceLandmarkerService(_ service: FaceLandmarkerService, didFinishDetection result: FaceLandmarkerResult?, imageSize: CGSize, error: Error?) {
        guard let result = result, error == nil else { return }
        
        DispatchQueue.main.async {
            self.overlayView.draw(landmarks: result.faceLandmarks, imageSize: imageSize)
        }
    }
}

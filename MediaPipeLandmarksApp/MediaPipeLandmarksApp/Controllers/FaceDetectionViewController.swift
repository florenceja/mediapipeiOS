import UIKit
import AVFoundation
import MediaPipeTasksVision

class FaceDetectionViewController: UIViewController {
    
    private let cameraManager = CameraManager()
    private let faceLandmarkerService = FaceLandmarkerService()
    private let overlayView = FaceOverlayView()
    private var hasShownSetupError = false
    private var pendingSetupErrorMessage: String?
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let message = pendingSetupErrorMessage {
            showSetupErrorIfNeeded(message: message)
            pendingSetupErrorMessage = nil
        }
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
        
        if let message = faceLandmarkerService.initializationErrorMessage {
            pendingSetupErrorMessage = message
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraManager.previewLayer.frame = view.bounds
        overlayView.frame = view.bounds
    }
    
    private func showSetupErrorIfNeeded(message: String) {
        guard !hasShownSetupError else { return }
        hasShownSetupError = true
        
        let alert = UIAlertController(
            title: "FaceLandmarker 未就绪",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        present(alert, animated: true)
    }
}

extension FaceDetectionViewController: CameraManagerDelegate {
    func cameraManager(_ manager: CameraManager, didOutput sampleBuffer: CMSampleBuffer) {
        faceLandmarkerService.detectAsync(sampleBuffer: sampleBuffer)
    }
}

extension FaceDetectionViewController: FaceLandmarkerServiceDelegate {
    func faceLandmarkerService(_ service: FaceLandmarkerService, didFinishDetection result: FaceLandmarkerResult?, imageSize: CGSize, error: Error?) {
        if let error = error {
            print("Face detection error: \(error)")
            return
        }
        guard let result = result else { return }
        
        DispatchQueue.main.async {
            self.overlayView.draw(landmarks: result.faceLandmarks, imageSize: imageSize)
        }
    }
}

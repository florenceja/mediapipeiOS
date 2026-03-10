import UIKit
import AVFoundation
import MediaPipeTasksVision

class HandGestureViewController: UIViewController {
    
    private let cameraManager = CameraManager()
    private let gestureRecognizerService = GestureRecognizerService()
    private let overlayView = HandOverlayView()
    
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
        title = "Hand Gestures"
        
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
        gestureRecognizerService.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraManager.previewLayer.frame = view.bounds
        overlayView.frame = view.bounds
    }
}

extension HandGestureViewController: CameraManagerDelegate {
    func cameraManager(_ manager: CameraManager, didOutput sampleBuffer: CMSampleBuffer) {
        gestureRecognizerService.recognizeAsync(sampleBuffer: sampleBuffer)
    }
}

extension HandGestureViewController: GestureRecognizerServiceDelegate {
    func gestureRecognizerService(_ service: GestureRecognizerService, didFinishRecognition result: GestureRecognizerResult?, imageSize: CGSize, error: Error?) {
        guard let result = result, error == nil else { return }
        
        DispatchQueue.main.async {
            self.overlayView.draw(landmarks: result.landmarks, gestures: result.gestures as! [Category] as! [[Category]], imageSize: imageSize)
        }
    }
}

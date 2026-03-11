import UIKit
import AVFoundation
import MediaPipeTasksVision

class FaceDetectionViewController: UIViewController {
    
    private let cameraManager = CameraManager()
    private let faceLandmarkerService = FaceLandmarkerService()
    private let overlayView = FaceOverlayView()
    private let topPanel = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let tipPanel = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
    private let statusDot = UIView()
    private let statusLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private var hasShownSetupError = false
    private var hasShownRuntimeError = false
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
        title = "Face Tracking"
        
        cameraManager.previewLayer.frame = view.bounds
        view.layer.addSublayer(cameraManager.previewLayer)
        
        overlayView.frame = view.bounds
        view.addSubview(overlayView)
        
        topPanel.layer.cornerRadius = 16
        topPanel.clipsToBounds = true
        topPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topPanel)
        
        statusDot.translatesAutoresizingMaskIntoConstraints = false
        statusDot.layer.cornerRadius = 5
        statusDot.backgroundColor = .systemOrange
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        statusLabel.textColor = .white
        statusLabel.text = "准备中..."
        
        let statusStack = UIStackView(arrangedSubviews: [statusDot, statusLabel])
        statusStack.axis = .horizontal
        statusStack.alignment = .center
        statusStack.spacing = 8
        statusStack.translatesAutoresizingMaskIntoConstraints = false
        topPanel.contentView.addSubview(statusStack)
        
        tipPanel.layer.cornerRadius = 16
        tipPanel.clipsToBounds = true
        tipPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tipPanel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.text = "Face Mesh"
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        subtitleLabel.numberOfLines = 2
        subtitleLabel.text = "请将面部完整置于画面中，并保持光线充足。"
        
        tipPanel.contentView.addSubview(titleLabel)
        tipPanel.contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            topPanel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            topPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topPanel.heightAnchor.constraint(equalToConstant: 48),
            
            statusStack.leadingAnchor.constraint(equalTo: topPanel.contentView.leadingAnchor, constant: 14),
            statusStack.trailingAnchor.constraint(lessThanOrEqualTo: topPanel.contentView.trailingAnchor, constant: -14),
            statusStack.centerYAnchor.constraint(equalTo: topPanel.contentView.centerYAnchor),
            statusDot.widthAnchor.constraint(equalToConstant: 10),
            statusDot.heightAnchor.constraint(equalToConstant: 10),
            
            tipPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tipPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tipPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: tipPanel.contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: tipPanel.contentView.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: tipPanel.contentView.trailingAnchor, constant: -14),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: tipPanel.contentView.leadingAnchor, constant: 14),
            subtitleLabel.trailingAnchor.constraint(equalTo: tipPanel.contentView.trailingAnchor, constant: -14),
            subtitleLabel.bottomAnchor.constraint(equalTo: tipPanel.contentView.bottomAnchor, constant: -12)
        ])
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
    
    private func updateStatus(text: String, color: UIColor) {
        statusLabel.text = text
        statusDot.backgroundColor = color
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
    
    private func showRuntimeErrorIfNeeded(message: String) {
        guard !hasShownRuntimeError else { return }
        hasShownRuntimeError = true
        
        let alert = UIAlertController(
            title: "人脸识别运行错误",
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
            DispatchQueue.main.async {
                self.showRuntimeErrorIfNeeded(message: error.localizedDescription)
                self.updateStatus(text: "识别异常", color: .systemRed)
            }
            return
        }
        guard let result = result else {
            DispatchQueue.main.async {
                self.updateStatus(text: "等待结果...", color: .systemOrange)
            }
            return
        }
        
        DispatchQueue.main.async {
            self.overlayView.draw(landmarks: result.faceLandmarks, imageSize: imageSize)
            if result.faceLandmarks.isEmpty {
                self.updateStatus(text: "未检测到人脸", color: .systemOrange)
            } else {
                self.updateStatus(text: "实时跟踪中", color: .systemGreen)
            }
        }
    }
}

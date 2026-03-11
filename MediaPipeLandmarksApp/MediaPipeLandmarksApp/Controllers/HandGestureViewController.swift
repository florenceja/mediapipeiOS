import UIKit
import AVFoundation
import MediaPipeTasksVision

class HandGestureViewController: UIViewController {
    
    private let cameraManager = CameraManager()
    private let gestureRecognizerService = GestureRecognizerService()
    private let overlayView = HandOverlayView()
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
        title = "Hand Gestures"
        
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
        titleLabel.text = "Gesture Guide"
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        subtitleLabel.numberOfLines = 2
        subtitleLabel.text = "手掌正对镜头，尽量与面部保持距离，避免遮挡。"
        
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
        gestureRecognizerService.delegate = self
        
        if let message = gestureRecognizerService.initializationErrorMessage {
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
    
    private func topGestureName(from gestures: [[ResultCategory]]) -> String? {
        guard let firstHand = gestures.first, !firstHand.isEmpty else { return nil }
        guard let best = firstHand.max(by: { $0.score < $1.score }) else { return nil }
        let name = [best.categoryName]
            .compactMap { $0 }
            .first(where: { !$0.isEmpty }) ?? "Unknown"
        return "\(name) \(Int(best.score * 100))%"
    }
    
    private func showSetupErrorIfNeeded(message: String) {
        guard !hasShownSetupError else { return }
        hasShownSetupError = true
        
        let alert = UIAlertController(
            title: "GestureRecognizer 未就绪",
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
            title: "手势识别运行错误",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        present(alert, animated: true)
    }
}

extension HandGestureViewController: CameraManagerDelegate {
    func cameraManager(_ manager: CameraManager, didOutput sampleBuffer: CMSampleBuffer) {
        gestureRecognizerService.recognizeAsync(sampleBuffer: sampleBuffer)
    }
}

extension HandGestureViewController: GestureRecognizerServiceDelegate {
    func gestureRecognizerService(_ service: GestureRecognizerService, didFinishRecognition result: GestureRecognizerResult?, imageSize: CGSize, error: Error?) {
        if let error = error {
            print("Gesture recognition error: \(error)")
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
            self.overlayView.draw(landmarks: result.landmarks, gestures: result.gestures, imageSize: imageSize)
            if result.landmarks.isEmpty {
                self.updateStatus(text: "未检测到手势", color: .systemOrange)
            } else if let gestureText = self.topGestureName(from: result.gestures) {
                self.updateStatus(text: gestureText, color: .systemGreen)
            } else {
                self.updateStatus(text: "检测到手部", color: .systemGreen)
            }
        }
    }
}

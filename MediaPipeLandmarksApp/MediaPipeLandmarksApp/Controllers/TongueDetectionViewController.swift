import UIKit
import ARKit

class TongueDetectionViewController: UIViewController {
    
    private let sceneView = ARSCNView(frame: .zero)
    private let topPanel = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let tipPanel = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
    private let statusDot = UIView()
    private let statusLabel = UILabel()
    private let tongueStateLabel = UILabel()
    private let tongueProgress = UIProgressView(progressViewStyle: .default)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private var hasShownUnsupportedAlert = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupARSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSessionIfSupported()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneView.frame = view.bounds
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        title = "Tongue Detection"
        
        sceneView.frame = view.bounds
        sceneView.automaticallyUpdatesLighting = true
        sceneView.session.delegate = self
        view.addSubview(sceneView)
        
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
        
        tongueStateLabel.translatesAutoresizingMaskIntoConstraints = false
        tongueStateLabel.font = .systemFont(ofSize: 14, weight: .bold)
        tongueStateLabel.textColor = .white
        tongueStateLabel.text = "舌头状态: 未检测"
        
        let statusStack = UIStackView(arrangedSubviews: [statusDot, statusLabel, tongueStateLabel])
        statusStack.axis = .horizontal
        statusStack.alignment = .center
        statusStack.spacing = 8
        statusStack.translatesAutoresizingMaskIntoConstraints = false
        topPanel.contentView.addSubview(statusStack)
        
        tongueProgress.translatesAutoresizingMaskIntoConstraints = false
        tongueProgress.progressTintColor = .systemBlue
        tongueProgress.trackTintColor = UIColor.white.withAlphaComponent(0.25)
        topPanel.contentView.addSubview(tongueProgress)
        
        tipPanel.layer.cornerRadius = 16
        tipPanel.clipsToBounds = true
        tipPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tipPanel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.text = "Tongue Out Guide"
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        subtitleLabel.numberOfLines = 2
        subtitleLabel.text = "请正对前置镜头，保持面部稳定，再轻微伸出舌头。"
        
        tipPanel.contentView.addSubview(titleLabel)
        tipPanel.contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            topPanel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            topPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topPanel.heightAnchor.constraint(equalToConstant: 78),
            
            statusStack.topAnchor.constraint(equalTo: topPanel.contentView.topAnchor, constant: 10),
            statusStack.leadingAnchor.constraint(equalTo: topPanel.contentView.leadingAnchor, constant: 14),
            statusStack.trailingAnchor.constraint(lessThanOrEqualTo: topPanel.contentView.trailingAnchor, constant: -14),
            statusDot.widthAnchor.constraint(equalToConstant: 10),
            statusDot.heightAnchor.constraint(equalToConstant: 10),
            
            tongueProgress.leadingAnchor.constraint(equalTo: topPanel.contentView.leadingAnchor, constant: 14),
            tongueProgress.trailingAnchor.constraint(equalTo: topPanel.contentView.trailingAnchor, constant: -14),
            tongueProgress.topAnchor.constraint(equalTo: statusStack.bottomAnchor, constant: 10),
            
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
    
    private func setupARSession() {
        guard ARFaceTrackingConfiguration.isSupported else {
            showUnsupportedAlertIfNeeded()
            updateStatus(text: "设备不支持舌头检测", color: .systemRed)
            return
        }
    }
    
    private func startSessionIfSupported() {
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isWorldTrackingEnabled = false
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        updateStatus(text: "请将脸部置于画面中", color: .systemOrange)
    }
    
    private func updateStatus(text: String, color: UIColor) {
        statusLabel.text = text
        statusDot.backgroundColor = color
    }
    
    private func showUnsupportedAlertIfNeeded() {
        guard !hasShownUnsupportedAlert else { return }
        hasShownUnsupportedAlert = true
        let alert = UIAlertController(
            title: "设备不支持",
            message: "舌头检测依赖 ARKit TrueDepth（ARFaceTrackingConfiguration）。当前设备不支持该能力。",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        present(alert, animated: true)
    }
}

extension TongueDetectionViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first(where: { $0 is ARFaceAnchor }) as? ARFaceAnchor else {
            DispatchQueue.main.async {
                self.tongueStateLabel.text = "舌头状态: 未检测"
                self.tongueProgress.progress = 0
                self.updateStatus(text: "未检测到面部", color: .systemOrange)
            }
            return
        }
        
        let tongueOutValue = (faceAnchor.blendShapes[.tongueOut] as? NSNumber)?.floatValue ?? 0
        let isTongueOut = tongueOutValue > 0.15
        
        DispatchQueue.main.async {
            self.tongueProgress.progress = tongueOutValue
            if isTongueOut {
                self.tongueStateLabel.text = "舌头状态: 已伸出"
                self.updateStatus(text: "检测成功", color: .systemGreen)
            } else {
                self.tongueStateLabel.text = "舌头状态: 未伸出"
                self.updateStatus(text: "实时检测中", color: .systemBlue)
            }
        }
    }
}

import UIKit

class MainViewController: UIViewController {
    
    private let subtitleLabel = UILabel()
    private let faceButton = UIButton(type: .system)
    private let handButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.06, green: 0.08, blue: 0.14, alpha: 1)
        title = "MediaPipe Studio"
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Choose a real-time AI mode"
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.78)
        
        configureCardButton(
            faceButton,
            title: "Face Landmarks",
            subtitle: "468-point face mesh in real time",
            symbolName: "face.smiling"
        )
        faceButton.addTarget(self, action: #selector(openFaceDetection), for: .touchUpInside)
        
        configureCardButton(
            handButton,
            title: "Hand Gestures",
            subtitle: "Track and classify hand gestures",
            symbolName: "hand.raised.fill"
        )
        handButton.addTarget(self, action: #selector(openHandGesture), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [faceButton, handButton])
        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(subtitleLabel)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10),
            
            faceButton.heightAnchor.constraint(equalToConstant: 92),
            handButton.heightAnchor.constraint(equalToConstant: 92)
        ])
    }
    
    private func configureCardButton(_ button: UIButton, title: String, subtitle: String, symbolName: String) {
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        config.image = UIImage(systemName: symbolName)
        config.imagePlacement = .leading
        config.imagePadding = 12
        config.title = title
        config.subtitle = subtitle
        config.baseForegroundColor = .white
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 19, weight: .bold)
            return outgoing
        }
        config.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 13, weight: .medium)
            return outgoing
        }
        
        button.configuration = config
        button.tintColor = UIColor.systemBlue
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        button.layer.cornerRadius = 18
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
    }
    
    @objc private func openFaceDetection() {
        let vc = FaceDetectionViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openHandGesture() {
        let vc = HandGestureViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "MediaPipe Landmarks"
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let faceButton = createButton(title: "Face Landmarks", action: #selector(openFaceDetection))
        let handButton = createButton(title: "Hand Gestures", action: #selector(openHandGesture))
        
        stackView.addArrangedSubview(faceButton)
        stackView.addArrangedSubview(handButton)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
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

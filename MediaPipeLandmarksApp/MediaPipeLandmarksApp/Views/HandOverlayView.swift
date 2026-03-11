import UIKit
import MediaPipeTasksVision

class HandOverlayView: UIView {
    
    // 手部骨架连接（MediaPipe 官方 21 点连接）
    private let handConnections: [(start: Int, end: Int)] = [
        (0, 1), (1, 2), (2, 3), (3, 4),   // 拇指
        (0, 5), (5, 6), (6, 7), (7, 8),   // 食指
        (0, 9), (9, 10), (10, 11), (11, 12), // 中指
        (0, 13), (13, 14), (14, 15), (15, 16), // 无名指
        (0, 17), (17, 18), (18, 19), (19, 20)  // 小指
    ]
    
    // 数据结构修正：单只手 = [NormalizedLandmark]，多只手 = [[NormalizedLandmark]]
    private var handLandmarks: [[NormalizedLandmark]] = []
    private var gestures: [[ResultCategory]] = []
    private var imageSize: CGSize = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func draw(landmarks: [[NormalizedLandmark]], gestures: [[ResultCategory]], imageSize: CGSize) {
        // 适配原接口：取第一只手的数据
        self.handLandmarks = landmarks
        self.gestures = gestures
        self.imageSize = imageSize
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard !handLandmarks.isEmpty, imageSize != .zero else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setStrokeColor(UIColor.systemCyan.cgColor)
        context.setLineWidth(2.0)
        context.setFillColor(UIColor.systemBlue.cgColor)
        
        for (handIndex, hand) in handLandmarks.enumerated() {
            // 绘制骨架连接
            for connection in handConnections {
                guard connection.start < hand.count, connection.end < hand.count else { continue }
                
                let startLandmark = hand[connection.start]
                let endLandmark = hand[connection.end]
                
                // ✅ 正确访问单个 NormalizedLandmark 的 x/y（通过属性）
                let startPoint = CoordinateTransformer.point(
                    from: CGPoint(x: CGFloat(startLandmark.x), y: CGFloat(startLandmark.y)),
                    imageSize: imageSize,
                    viewSize: bounds.size
                )
                let endPoint = CoordinateTransformer.point(
                    from: CGPoint(x: CGFloat(endLandmark.x), y: CGFloat(endLandmark.y)),
                    imageSize: imageSize,
                    viewSize: bounds.size
                )
                
                context.move(to: startPoint)
                context.addLine(to: endPoint)
            }
            context.strokePath()
            
            // 绘制关键点
            var minX: CGFloat = bounds.width
            var minY: CGFloat = bounds.height
            
            for landmark in hand {
                let point = CoordinateTransformer.point(
                    from: CGPoint(x: CGFloat(landmark.x), y: CGFloat(landmark.y)),
                    imageSize: imageSize,
                    viewSize: bounds.size
                )
                let rect = CGRect(x: point.x - 3, y: point.y - 3, width: 6, height: 6)
                context.fillEllipse(in: rect)
                
                minX = min(minX, point.x)
                minY = min(minY, point.y)
            }
            
            // Draw top gesture label for current hand.
            if handIndex < gestures.count {
                let gestureCategories = gestures[handIndex]
                if let topCategory = gestureCategories.max(by: {
                    $0.score < $1.score
                }) {
                    let text = [topCategory.categoryName, topCategory.displayName]
                        .compactMap { $0 }
                        .first(where: { !$0.isEmpty }) ?? "Unknown"
                    let scoreText = String(format: "%.0f%%", topCategory.score * 100)
                    let displayText = "\(text)  \(scoreText)"
                    
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.boldSystemFont(ofSize: 20),
                        .foregroundColor: UIColor.white
                    ]
                    
                    // ✅ 修复字符串尺寸计算
                    let textSize = (displayText as NSString).size(withAttributes: attributes)
                    let textRect = CGRect(
                        x: minX,
                        y: max(minY - textSize.height - 10, 0),
                        width: textSize.width,
                        height: textSize.height
                    )
                    let bgRect = textRect.insetBy(dx: -10, dy: -6)
                    context.setFillColor(UIColor.black.withAlphaComponent(0.55).cgColor)
                    let path = UIBezierPath(roundedRect: bgRect, cornerRadius: 10)
                    context.addPath(path.cgPath)
                    context.fillPath()
                    (displayText as NSString).draw(in: textRect, withAttributes: attributes)
                }
            }
        }
    }
}

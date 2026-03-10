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
    private var gestures: [[Category]] = []
    private var imageSize: CGSize = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func draw(landmarks: [[[NormalizedLandmark]]], gestures: [[[Category]]], imageSize: CGSize) {
        // 适配原接口：取第一只手的数据
        self.handLandmarks = landmarks.first ?? []
        self.gestures = gestures.first ?? []
        self.imageSize = imageSize
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard !handLandmarks.isEmpty, imageSize != .zero else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setStrokeColor(UIColor.blue.cgColor)
        context.setLineWidth(2.0)
        context.setFillColor(UIColor.orange.cgColor)
        
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
            
            // ✅ 绘制手势名称（适配 Category 为 OpaquePointer 的情况）
            if handIndex < gestures.count {
                let gestureCategories = gestures[handIndex]
                if let topCategory = gestureCategories.max(by: {
                    // 通过 KVC 安全获取 score（适配 OpaquePointer）
                    let score1 = $0.value(forKey: "score") as? Float ?? 0
                    let score2 = $1.value(forKey: "score") as? Float ?? 0
                    return score1 < score2
                }) {
                    // 通过 KVC 获取 categoryName/label（适配 OpaquePointer）
                    let categoryName = topCategory.value(forKey: "categoryName") as? String
                    let label = topCategory.value(forKey: "label") as? String
                    let text = categoryName ?? label ?? "Unknown"
                    
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.boldSystemFont(ofSize: 24),
                        .foregroundColor: UIColor.red
                    ]
                    
                    // ✅ 修复字符串尺寸计算
                    let textSize = (text as NSString).size(withAttributes: attributes)
                    let textRect = CGRect(
                        x: minX,
                        y: max(minY - textSize.height - 10, 0),
                        width: textSize.width,
                        height: textSize.height
                    )
                    (text as NSString).draw(in: textRect, withAttributes: attributes)
                }
            }
        }
    }
}
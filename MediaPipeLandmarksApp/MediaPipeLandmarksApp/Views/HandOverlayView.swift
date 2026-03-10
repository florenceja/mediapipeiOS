import UIKit
import MediaPipeTasksVision

class HandOverlayView: UIView {
    
    // 1. 定义手部关键点连接（MediaPipe 官方手部骨架连接）
    private let handConnections: [(start: Int, end: Int)] = [
        (0, 1), (1, 2), (2, 3), (3, 4),   // 拇指
        (0, 5), (5, 6), (6, 7), (7, 8),   // 食指
        (0, 9), (9, 10), (10, 11), (11, 12), // 中指
        (0, 13), (13, 14), (14, 15), (15, 16), // 无名指
        (0, 17), (17, 18), (18, 19), (19, 20)  // 小指
    ]
    
    private var handLandmarks: [[NormalizedLandmark]] = [] // 简化：单只手的关键点数组
    private var gestures: [Category] = [] // 简化：单只手的手势分类结果
    private var imageSize: CGSize = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 2. 简化数据传递接口（适配实际业务逻辑）
    func update(with landmarks: [[NormalizedLandmark]], gestures: [Category], imageSize: CGSize) {
        self.handLandmarks = landmarks
        self.gestures = gestures
        self.imageSize = imageSize
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // 3. 安全校验：关键点/图像尺寸为空时直接返回
        guard !handLandmarks.isEmpty, imageSize.width > 0, imageSize.height > 0 else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 4. 设置绘制样式
        context.setStrokeColor(UIColor.blue.cgColor)
        context.setLineWidth(2.0)
        context.setFillColor(UIColor.orange.cgColor)
        
        // 5. 绘制手部骨架连接
        for connection in handConnections {
            guard connection.start < handLandmarks.count, connection.end < handLandmarks.count else { continue }
            
            let startLandmark = handLandmarks[connection.start]
            let endLandmark = handLandmarks[connection.end]
            
            // 6. 正确转换 NormalizedLandmark 坐标（适配 MediaPipe API）
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
        
        // 7. 绘制手部关键点
        var minX: CGFloat = bounds.width
        var minY: CGFloat = bounds.height
        
        for landmark in handLandmarks {
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
        
        // 8. 绘制手势名称（修复 Category 字段 + 字符串绘制）
        if !gestures.isEmpty {
            // 取得分最高的手势分类
            let topCategory = gestures.max(by: { $0.score ?? 0 < $1.score ?? 0 })
            let gestureText = topCategory?.categoryName ?? topCategory?.label ?? "Unknown"
            
            // 9. 修复 Swift 字符串尺寸计算（桥接 NSString）
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.red
            ]
            
            let textSize = (gestureText as NSString).size(withAttributes: attributes)
            let textRect = CGRect(
                x: minX,
                y: max(minY - textSize.height - 10, 0), // 防止超出视图顶部
                width: textSize.width,
                height: textSize.height
            )
            
            (gestureText as NSString).draw(in: textRect, withAttributes: attributes)
        }
    }
}
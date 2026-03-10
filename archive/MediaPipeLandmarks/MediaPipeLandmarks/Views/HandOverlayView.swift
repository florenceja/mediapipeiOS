import UIKit
import MediaPipeTasksVision

class HandOverlayView: UIView {
    
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
    
    func draw(landmarks: [[NormalizedLandmark]], gestures: [[Category]], imageSize: CGSize) {
        self.handLandmarks = landmarks
        self.gestures = gestures
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
        
        for (index, hand) in handLandmarks.enumerated() {
            // Draw connections
            for connection in GestureRecognizer.handLandmarksConnections() {
                let start = hand[Int(connection.start)]
                let end = hand[Int(connection.end)]
                
                let startPoint = CoordinateTransformer.point(
                    from: CGPoint(x: CGFloat(start.x), y: CGFloat(start.y)),
                    imageSize: imageSize,
                    viewSize: bounds.size
                )
                
                let endPoint = CoordinateTransformer.point(
                    from: CGPoint(x: CGFloat(end.x), y: CGFloat(end.y)),
                    imageSize: imageSize,
                    viewSize: bounds.size
                )
                
                context.move(to: startPoint)
                context.addLine(to: endPoint)
            }
            context.strokePath()
            
            // Draw points
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
            
            // Draw gesture name
            if index < gestures.count, let firstGesture = gestures[index].first {
                let text = firstGesture.categoryName ?? "Unknown"
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 24),
                    .foregroundColor: UIColor.red
                ]
                
                let textSize = text.size(withAttributes: attributes)
                let textRect = CGRect(x: minX, y: minY - textSize.height - 10, width: textSize.width, height: textSize.height)
                
                text.draw(in: textRect, withAttributes: attributes)
            }
        }
    }
}

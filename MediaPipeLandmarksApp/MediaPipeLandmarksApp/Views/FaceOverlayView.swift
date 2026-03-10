import UIKit
import MediaPipeTasksVision

class FaceOverlayView: UIView {
    
    private var faceLandmarks: [[NormalizedLandmark]] = []
    private var imageSize: CGSize = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func draw(landmarks: [[NormalizedLandmark]], imageSize: CGSize) {
        self.faceLandmarks = landmarks
        self.imageSize = imageSize
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard !faceLandmarks.isEmpty, imageSize != .zero else { return }
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setStrokeColor(UIColor.green.cgColor)
        context.setLineWidth(1.0)
        context.setFillColor(UIColor.red.cgColor)
        
        for face in faceLandmarks {
            // Draw connections
            for connection in FaceLandmarker.faceLandmarksConnections() {
                let start = face[Int(connection.start)]
                let end = face[Int(connection.end)]
                
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
            for landmark in face {
                let point = CoordinateTransformer.point(
                    from: CGPoint(x: CGFloat(landmark.x), y: CGFloat(landmark.y)),
                    imageSize: imageSize,
                    viewSize: bounds.size
                )
                
                let rect = CGRect(x: point.x - 1, y: point.y - 1, width: 2, height: 2)
                context.fillEllipse(in: rect)
            }
        }
    }
}

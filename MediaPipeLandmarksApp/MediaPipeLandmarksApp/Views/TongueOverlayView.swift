import UIKit
import MediaPipeTasksVision

class TongueOverlayView: UIView {
    
    private var faceLandmarks: [[NormalizedLandmark]] = []
    private var imageSize: CGSize = .zero
    private var tongueScore: Float = 0
    private var hasTongueScore = false
    private let lowerInnerLipIndices = [78, 95, 88, 178, 87, 14, 317, 402, 318, 324, 308]
    private let tongueBlendshapeThreshold: Float = 0.35
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func draw(landmarks: [[NormalizedLandmark]], imageSize: CGSize, tongueScore: Float, hasTongueScore: Bool) {
        self.faceLandmarks = landmarks
        self.imageSize = imageSize
        self.tongueScore = tongueScore
        self.hasTongueScore = hasTongueScore
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard !faceLandmarks.isEmpty, imageSize != .zero else {
            return
        }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        for face in faceLandmarks {
            guard hasMouthAnchors(in: face) else { continue }
            drawMouthBaseline(in: context, face: face)
            
            let score = hasTongueScore ? tongueScore : 0
            if score >= tongueBlendshapeThreshold {
                drawTonguePoints(in: context, face: face, tongueScore: CGFloat(score))
            }
        }
    }
    
    private func transform(_ point: CGPoint) -> CGPoint {
        CoordinateTransformer.point(
            from: point,
            imageSize: imageSize,
            viewSize: bounds.size
        )
    }
    
    private func drawMouthBaseline(in context: CGContext, face: [NormalizedLandmark]) {
        let path = UIBezierPath()
        for (index, pointIndex) in lowerInnerLipIndices.enumerated() {
            guard pointIndex < face.count else { continue }
            let landmark = face[pointIndex]
            let point = transform(CGPoint(x: CGFloat(landmark.x), y: CGFloat(landmark.y)))
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
            context.setStrokeColor(UIColor.white.withAlphaComponent(0.86).cgColor)
            context.setLineWidth(2.5)
            context.strokeEllipse(in: CGRect(x: point.x - 1.8, y: point.y - 1.8, width: 3.6, height: 3.6))
        }
        path.close()
        UIColor.white.withAlphaComponent(0.86).setStroke()
        path.lineWidth = 2.5
        path.stroke()
    }
    
    private func drawTonguePoints(in context: CGContext, face: [NormalizedLandmark], tongueScore: CGFloat) {
        guard let upperLip = landmarkPoint(at: 13, in: face),
              let lowerLip = landmarkPoint(at: 14, in: face),
              let leftCorner = landmarkPoint(at: 78, in: face),
              let rightCorner = landmarkPoint(at: 308, in: face),
              let chin = landmarkPoint(at: 152, in: face) else {
            return
        }
        
        let mouthOpen = max(lowerLip.y - upperLip.y, 0)
        let mouthWidth = max(abs(rightCorner.x - leftCorner.x), 0.0001)
        let centerX = min(max((leftCorner.x + rightCorner.x) * 0.5, 0), 1)
        let baseY = min(max(lowerLip.y + mouthOpen * 0.06, 0), 1)
        let extension = min(max(0.9 + tongueScore * 1.6, 0.9), 2.5)
        let tipY = min(baseY + mouthOpen * extension, chin.y + mouthOpen * 0.85)
        let midY = min(max((baseY + tipY) * 0.57, 0), 1)
        
        let topHalfWidth = mouthWidth * 0.18
        let midHalfWidth = mouthWidth * 0.30
        let points = [
            CGPoint(x: min(max(centerX - topHalfWidth, 0), 1), y: baseY),
            CGPoint(x: min(max(centerX - midHalfWidth, 0), 1), y: midY),
            CGPoint(x: centerX, y: min(max(tipY, 0), 1)),
            CGPoint(x: min(max(centerX + midHalfWidth, 0), 1), y: midY),
            CGPoint(x: min(max(centerX + topHalfWidth, 0), 1), y: baseY)
        ]
        
        let transformed = points.map { transform($0) }
        let path = UIBezierPath()
        if let first = transformed.first {
            path.move(to: first)
            transformed.dropFirst().forEach { path.addLine(to: $0) }
            path.close()
        }
        
        UIColor.systemPink.withAlphaComponent(0.57).setFill()
        path.fill()
        UIColor.systemPink.withAlphaComponent(0.95).setStroke()
        path.lineWidth = 2.5
        path.stroke()
        
        context.setFillColor(UIColor(red: 1.0, green: 0.47, blue: 0.67, alpha: 1.0).cgColor)
        for point in transformed {
            context.fillEllipse(in: CGRect(x: point.x - 2.5, y: point.y - 2.5, width: 5, height: 5))
        }
    }
    
    private func hasMouthAnchors(in face: [NormalizedLandmark]) -> Bool {
        [13, 14, 78, 308, 152].allSatisfy { $0 < face.count }
    }
    
    private func landmarkPoint(at index: Int, in face: [NormalizedLandmark]) -> CGPoint? {
        guard index >= 0, index < face.count else { return nil }
        return CGPoint(x: CGFloat(face[index].x), y: CGFloat(face[index].y))
    }
}

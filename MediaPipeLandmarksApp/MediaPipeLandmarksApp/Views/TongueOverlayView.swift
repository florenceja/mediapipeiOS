import UIKit
import MediaPipeTasksVision

class TongueOverlayView: UIView {
    
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
        guard let face = faceLandmarks.first else { return }
        
        guard let leftMouth = landmarkPoint(at: 61, in: face),
              let rightMouth = landmarkPoint(at: 291, in: face),
              let upperInnerLip = landmarkPoint(at: 13, in: face),
              let lowerInnerLip = landmarkPoint(at: 14, in: face),
              let chin = landmarkPoint(at: 152, in: face) else {
            return
        }
        
        let mouthWidth = distance(leftMouth, rightMouth)
        let mouthOpen = distance(upperInnerLip, lowerInnerLip)
        guard mouthWidth > 0.0001 else { return }
        let openRatio = mouthOpen / mouthWidth
        guard openRatio > 0.06 else { return }
        
        let lipCenter = midpoint(upperInnerLip, lowerInnerLip)
        let down = normalizedVector(from: lipCenter, to: chin, fallback: CGPoint(x: 0, y: 1))
        let side = CGPoint(x: -down.y, y: down.x)
        
        let extensionFactor = clamp((openRatio - 0.06) / 0.20, min: 0, max: 1)
        let length = mouthWidth * (0.18 + 0.35 * extensionFactor)
        let halfWidth = mouthWidth * (0.16 + 0.08 * extensionFactor)
        
        let tongueBaseCenter = CGPoint(
            x: lipCenter.x + down.x * mouthWidth * 0.04,
            y: lipCenter.y + down.y * mouthWidth * 0.04
        )
        let tongueTip = CGPoint(
            x: tongueBaseCenter.x + down.x * length,
            y: tongueBaseCenter.y + down.y * length
        )
        let leftBase = CGPoint(
            x: tongueBaseCenter.x + side.x * halfWidth * 0.7,
            y: tongueBaseCenter.y + side.y * halfWidth * 0.7
        )
        let rightBase = CGPoint(
            x: tongueBaseCenter.x - side.x * halfWidth * 0.7,
            y: tongueBaseCenter.y - side.y * halfWidth * 0.7
        )
        let leftMid = CGPoint(
            x: tongueBaseCenter.x + side.x * halfWidth + down.x * length * 0.45,
            y: tongueBaseCenter.y + side.y * halfWidth + down.y * length * 0.45
        )
        let rightMid = CGPoint(
            x: tongueBaseCenter.x - side.x * halfWidth + down.x * length * 0.45,
            y: tongueBaseCenter.y - side.y * halfWidth + down.y * length * 0.45
        )
        
        let b = transform(tongueBaseCenter)
        let l0 = transform(leftBase)
        let l1 = transform(leftMid)
        let r1 = transform(rightMid)
        let r0 = transform(rightBase)
        let tip = transform(tongueTip)
        
        let path = UIBezierPath()
        path.move(to: l0)
        path.addQuadCurve(to: tip, controlPoint: l1)
        path.addQuadCurve(to: r0, controlPoint: r1)
        path.addQuadCurve(to: l0, controlPoint: b)
        path.close()
        
        context.setFillColor(UIColor.systemPink.withAlphaComponent(0.42).cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
        
        context.setStrokeColor(UIColor.systemPink.cgColor)
        context.setLineWidth(2)
        context.addPath(path.cgPath)
        context.strokePath()
        
        let featurePoints = [b, l1, tip, r1]
        context.setFillColor(UIColor.white.cgColor)
        for point in featurePoints {
            let p = CGRect(x: point.x - 2.5, y: point.y - 2.5, width: 5, height: 5)
            context.fillEllipse(in: p)
        }
    }
    
    private func landmarkPoint(at index: Int, in face: [NormalizedLandmark]) -> CGPoint? {
        guard index >= 0, index < face.count else { return nil }
        let landmark = face[index]
        return CGPoint(x: CGFloat(landmark.x), y: CGFloat(landmark.y))
    }
    
    private func transform(_ normalized: CGPoint) -> CGPoint {
        CoordinateTransformer.point(
            from: normalized,
            imageSize: imageSize,
            viewSize: bounds.size
        )
    }
    
    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        hypot(a.x - b.x, a.y - b.y)
    }
    
    private func midpoint(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
        CGPoint(x: (a.x + b.x) * 0.5, y: (a.y + b.y) * 0.5)
    }
    
    private func normalizedVector(from start: CGPoint, to end: CGPoint, fallback: CGPoint) -> CGPoint {
        let v = CGPoint(x: end.x - start.x, y: end.y - start.y)
        let len = hypot(v.x, v.y)
        guard len > 0.0001 else { return fallback }
        return CGPoint(x: v.x / len, y: v.y / len)
    }
    
    private func clamp(_ value: CGFloat, min minValue: CGFloat, max maxValue: CGFloat) -> CGFloat {
        Swift.max(minValue, Swift.min(maxValue, value))
    }
}

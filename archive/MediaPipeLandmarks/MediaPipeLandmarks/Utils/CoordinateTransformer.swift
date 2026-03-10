import UIKit

class CoordinateTransformer {
    
    static func offsetsAndScaleFactor(
        for imageSize: CGSize,
        in viewSize: CGSize,
        contentMode: UIView.ContentMode
    ) -> (xOffset: CGFloat, yOffset: CGFloat, scaleFactor: CGFloat) {
        
        let widthScale = viewSize.width / imageSize.width
        let heightScale = viewSize.height / imageSize.height
        
        var scaleFactor: CGFloat = 1.0
        
        switch contentMode {
        case .scaleAspectFill:
            scaleFactor = max(widthScale, heightScale)
        case .scaleAspectFit:
            scaleFactor = min(widthScale, heightScale)
        default:
            scaleFactor = 1.0
        }
        
        let scaledWidth = imageSize.width * scaleFactor
        let scaledHeight = imageSize.height * scaleFactor
        
        let xOffset = (viewSize.width - scaledWidth) / 2.0
        let yOffset = (viewSize.height - scaledHeight) / 2.0
        
        return (xOffset, yOffset, scaleFactor)
    }
    
    static func point(
        from normalizedPoint: CGPoint,
        imageSize: CGSize,
        viewSize: CGSize,
        contentMode: UIView.ContentMode = .scaleAspectFill,
        isMirrored: Bool = false
    ) -> CGPoint {
        
        let (xOffset, yOffset, scaleFactor) = offsetsAndScaleFactor(
            for: imageSize,
            in: viewSize,
            contentMode: contentMode
        )
        
        var x = normalizedPoint.x
        let y = normalizedPoint.y
        
        if isMirrored {
            x = 1.0 - x
        }
        
        let finalX = x * imageSize.width * scaleFactor + xOffset
        let finalY = y * imageSize.height * scaleFactor + yOffset
        
        return CGPoint(x: finalX, y: finalY)
    }
}

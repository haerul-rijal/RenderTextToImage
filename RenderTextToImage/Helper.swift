//
//  Helper.swift
//  RenderTextToImage
//
//  Created by haerul.rijal on 25/01/23.
//

import UIKit
import AVFoundation

extension UIColor {
    static var teal: UIColor { UIColor(red: 0.00, green: 0.42, blue: 0.46, alpha: 0.88) }
    static var grayBackground: UIColor { UIColor(red: 0.8667, green: 0.8667, blue: 0.8667, alpha: 1.0) }
    static var pink: UIColor { UIColor(red: 0.72, green: 0.00, blue: 0.00, alpha: 0.60) }
    static var lightGreen: UIColor { UIColor(red: 0.00, green: 0.55, blue: 0.01, alpha: 0.70) }
    static var lightBlue: UIColor { UIColor(red: 0.07, green: 0.45, blue: 0.87, alpha: 0.90) }
}

enum ImageType {
    case img4288x2848
    case img2048x1360
    case img1024x680
    case img256x170
    case img128x85
    case img24x16
    case custom
    
    var dimensions: String {
        switch self {
        case .img4288x2848:
            return "4288x2848"
        case .img2048x1360:
            return "2048x1360"
        case .img1024x680:
            return "1024x680"
        case .img256x170:
            return "256x170"
        case .img128x85:
            return "128x85"
        case .img24x16:
            return "24x16"
        default:
            return ""
        }
    }
    
    var image: UIImage? {
        switch self {
        case .img4288x2848:
            return UIImage(named: "IMG_001")
        case .img2048x1360:
            return UIImage(named: "IMG_002")
        case .img1024x680:
            return UIImage(named: "IMG_003")
        case .img256x170:
            return UIImage(named: "IMG_004")
        case .img128x85:
            return UIImage(named: "IMG_005")
        case .img24x16:
            return UIImage(named: "IMG_006")
        case .custom:
            return UIImage()
        }
    }
    
    var originalSize: CGSize {
        return image?.size ?? CGSize.zero
    }
}


extension CGSize {
    
    internal func cornerRadius(fraction: CGFloat) -> CGFloat {
        min(width, height) * fraction
    }
    
    func rectThatFits(in rect: CGRect) -> CGRect {
        AVMakeRect(aspectRatio: self, insideRect: rect)
    }
}

extension UIImage {
    internal func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        guard size.width > targetSize.width || size.height > targetSize.height,
              size.width != .zero, size.height != .zero else { return self }
        
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio.
        let scaledImageSize = CGSize(
            width: round(size.width * scaleFactor),
            height: round(size.height * scaleFactor)
        )
        
        /// Draw and return the resized `UIImage`.
        let format = UIGraphicsImageRendererFormat.preferred()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize, format: format)
        
        let scaledImage = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        
        return scaledImage
    }
}

extension UIEdgeInsets {
    
    public func percentageInsets(size: CGSize) -> UIEdgeInsets {
        let fraction = min(size.height, size.width)
        let top = self.top == 0 ? 0 : self.top/100 * fraction
        let bottom = self.bottom == 0 ? 0 : self.bottom/100 * fraction
        let left = self.left == 0 ? 0 : self.left/100 * fraction
        let right = self.right == 0 ? 0 : self.right/100 * fraction
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
}

//extension UIFont {
//    public func sizeOfString (string: String, constrainedToWidth width: CGFloat) -> CGSize {
//        let attributes = [NSAttributedString.Key.font:self]
//        let attString = NSAttributedString(string: string,attributes: attributes)
//        let framesetter = CTFramesetterCreateWithAttributedString(attString)
//        return CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0,length: 0), nil, CGSize(width: width, height: .greatestFiniteMagnitude), nil)
//    }
//}

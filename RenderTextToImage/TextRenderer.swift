//
//  TextRenderer.swift
//  RenderTextToImage
//
//  Created by haerul.rijal on 19/01/23.
//

import UIKit

public struct TextRenderer {
    // configs
    public struct TextImageType {
        public static let defaultConfig = TextImageType(
            variant: .fun,
            heightRatio: 1/6,
            position: .bottom,
            paddingPercentage: .init(top: 10, left: 20, bottom: 10, right: 20),
            alignment: .center,
            numberOfLines: 2
        )
        
        public enum Position {
            case left, right, bottom
        }
        public enum Variant {
            case normal
            case fun
            case fixedBold
            
            var font: UIFont {
                let defaultFonts = UIFont.systemFont(ofSize: UIFont.labelFontSize)
                switch self {
                case .normal:
                    return defaultFonts
                case .fun:
                    return UIFont(name: "MarkerFelt-Wide", size: UIFont.labelFontSize) ?? defaultFonts
                case .fixedBold:
                    return UIFont(name: "CourierNewPS-BoldMT", size: UIFont.labelFontSize) ?? defaultFonts
                }
            }
        }
        let variant: Variant
        let heightRatio: CGFloat
        let position: Position
        let paddingPercentage: UIEdgeInsets
        let alignment: NSTextAlignment
        let numberOfLines: Int
    }
    
    public static func flattenTextImage(text: String, configuration: TextImageType, with image: UIImage) -> UIImage? {
        let canvasSize = image.size
        let format = UIGraphicsImageRendererFormat.preferred()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: canvasSize, format: format)
        guard
            let textImage = createImageText(text: text, configuration: configuration, rect: CGRect(origin: .zero, size: canvasSize))
        else {
            return nil
        }
        
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: canvasSize))
            textImage.draw(in: CGRect(origin: .zero, size: canvasSize))
        }
    }

    public static func createImageText(text: String, configuration: TextImageType, rect: CGRect) -> UIImage? {
        defer { UIGraphicsEndImageContext() }
        let height = rect.size.height * configuration.heightRatio
        let originY = rect.size.height - height
        let boxRect = CGRect(x: 0, y: originY, width: rect.size.width, height: height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0)
        guard let _ = UIGraphicsGetCurrentContext() else { return nil }
        
        let path = UIBezierPath(roundedRect: boxRect, cornerRadius: boxRect.size.cornerRadius(fraction: 0.1))
        UIColor.black.set()
        path.fill()
        let textBoxRect = boxRect.inset(by: configuration.paddingPercentage.percentageInsets(size: boxRect.size))
        
        let cleanText = text
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\t", with: "")
        
        let label = UILabel(frame: CGRect(origin: .zero, size: textBoxRect.size))
        let optimalFontSize = fontSizeThatFits(inSize: textBoxRect.size, font: configuration.variant.font)
        label.numberOfLines = configuration.numberOfLines
        label.lineBreakMode = .byTruncatingTail
        label.font = configuration.variant.font.withSize(optimalFontSize)
        label.textAlignment = configuration.alignment
        label.textColor = .white
        label.text = cleanText
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.drawText(in: textBoxRect)
        
        //add mascott
        let symbolImage: UIImage?
        if #available(iOS 15.0, *) {
            var config = UIImage.SymbolConfiguration.preferringMulticolor()
            config = config.applying(UIImage.SymbolConfiguration(pointSize: textBoxRect.height, weight: .regular, scale: .large))
            symbolImage = UIImage(named: "TopedPlainSF4")?.applyingSymbolConfiguration( config )
        } else {
            //fallback
            let tintcolor = UIColor(red: 67/255, green: 160/255, blue: 71/255, alpha: 1)
            symbolImage = UIImage(named: "TopedPlainSF2")?.applyingSymbolConfiguration(
                UIImage.SymbolConfiguration(pointSize: optimalFontSize, weight: .regular, scale: .large)
            )?.withTintColor(tintcolor)
        }
        
        
        let mascottSize = CGSize(width: boxRect.height, height: boxRect.height)
        
        if let mascottImage = symbolImage?.scalePreservingAspectRatio(targetSize: mascottSize) {
            let mascottImageOriginX = rect.size.width - mascottImage.size.width - ((mascottImage.size.width/2))
            let mascottImageOriginY = originY - mascottImage.size.height - (mascottImage.size.height/2)
            mascottImage.draw(at: CGPoint(x: mascottImageOriginX, y: mascottImageOriginY))
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
        
    }
    
    private static func fontSizeThatFits(inSize size: CGSize, font: UIFont) -> CGFloat {
        let textSampling = "Sample"
        let minimumFontSize: CGFloat = 2
        let attributes = [NSAttributedString.Key.font: font]
        let attString = NSAttributedString(string: textSampling, attributes: attributes)
        let framesetter = CTFramesetterCreateWithAttributedString(attString)
        let baseSize: CGSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0,length: 0), nil, CGSize(width: size.width, height: .greatestFiniteMagnitude), nil)
       
        let pointSize: CGFloat = floor(size.height/baseSize.height * font.pointSize)
        return pointSize < minimumFontSize ? minimumFontSize : pointSize
    }
    
    // Other function

//    public static func createImageText2(text: String, configuration: TextImageType, rect: CGRect) -> UIImage? {
//        defer { UIGraphicsEndImageContext() }
//        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
//        guard let _ = UIGraphicsGetCurrentContext() else { return nil }
//        let height = rect.size.height * configuration.heightRatio
//        let originY = rect.size.height - height
//        let boxRect = CGRect(x: 0, y: originY, width: rect.size.width, height: height)
//        let path = UIBezierPath(roundedRect: boxRect, cornerRadius: boxRect.size.cornerRadius(fraction: 0.1))
//        UIColor.black.set()
//        path.fill()
//        let textBoxRect = boxRect.inset(by: configuration.paddingPercentage.percentageInsets(size: boxRect.size))
//        let cleanText = text
//            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//            .replacingOccurrences(of: "\n", with: "")
//            .replacingOccurrences(of: "\t", with: "")
//        let attributes = createTextAttributes(configuration: configuration, text: cleanText, withSize: textBoxRect.size)
//        let textImage = UIGraphicsImageRenderer(size: textBoxRect.size).image { _ in
//            text.draw(with: CGRect(origin: .zero, size: textBoxRect.size), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
//        }
//        textImage.draw(in: textBoxRect)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        return image
//
//    }
    
//    private static func createTextAttributes(configuration: TextImageType, text: String, withSize size: CGSize) -> [NSAttributedString.Key:Any] {
//        let initialFontSize = fontSizeThatFits(inSize: size, font: configuration.variant.font.withSize(size.height))
//        let numberOflines = configuration.numberOfLines > 0 ? configuration.numberOfLines : 1
//        var attributes: [NSAttributedString.Key:Any] = [:]
//        let rect = CGRect(origin: .zero, size: size)
//        for lineNumber in 1...numberOflines {
//            let fontSize = initialFontSize/CGFloat(lineNumber)
//            let paragraphStyle = NSMutableParagraphStyle()
//            paragraphStyle.alignment = configuration.alignment
//            paragraphStyle.lineBreakMode = .byWordWrapping
//            attributes = [
//                NSAttributedString.Key.font: configuration.variant.font.withSize(fontSize),
//                NSAttributedString.Key.foregroundColor: UIColor.white,
//                NSAttributedString.Key.paragraphStyle: paragraphStyle
//            ]
//            let attributedString = NSAttributedString(string: text, attributes: attributes)
//            if !isTextTruncated(attributedString: attributedString, rect: rect) {
//                return attributes
//            }
//        }
//        return attributes
//    }
//
//    private static func isTextTruncated(attributedString: NSAttributedString, rect: CGRect) -> Bool {
//        var truncatedTexts = [String]()
//        let ctl = CTLineCreateWithAttributedString(attributedString)
//        let token = CTLineCreateWithAttributedString(NSAttributedString(string: "\n"))
//        guard
//            let truncatedLine = CTLineCreateTruncatedLine(ctl, Double(rect.size.width), .end, token),
//            let ctRuns = CTLineGetGlyphRuns(truncatedLine) as? [CTRun]
//        else {
//            return false
//        }
//        for ctRun in ctRuns {
//            let range = CTRunGetStringRange(ctRun)
//            let attributedSubstring = attributedString.attributedSubstring(from: NSRange(location: range.location, length: range.length))
//            truncatedTexts.append(attributedSubstring.string)
//        }
//
//        print(truncatedTexts)
//
//        return ctRuns.count > 1
//    }
    
    
}

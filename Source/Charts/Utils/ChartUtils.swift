//
//  Utils.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif

extension FloatingPoint {
    func deg2rad() -> Self {
        return self * .pi / 180
    }
    
    func rad2deg() -> Self {
        return self * 180 / .pi
    }
}

public struct ChartUtils {
    private static var _defaultValueFormatter: ValueFormatter = ChartUtils.generateDefaultValueFormatter()
    
    internal static func roundToNextSignificant(number: Double) -> Double {
        if number.isInfinite || number.isNaN || number == 0 {
            return number
        }
        
        let d = ceil(log10(number < 0.0 ? -number : number))
        let pw = 1 - Int(d)
        let magnitude = pow(Double(10.0), Double(pw))
        let shifted = round(number * magnitude)
        return shifted / magnitude
    }
    
    internal static func decimals(_ number: Double) -> Int {
        if number.isNaN || number.isInfinite || number == 0.0 {
            return 0
        }
        
        let i = roundToNextSignificant(number: Double(number))
        
        if i.isInfinite || i.isNaN {
            return 0
        }
        
        return Int(ceil(-log10(i))) + 2
    }
    
    internal static func nextUp(_ number: Double) -> Double {
        if number.isInfinite || number.isNaN {
            return number
        }
        else {
            return number + .ulpOfOne
        }
    }
    
    /// Calculates the position around a center point, depending on the distance from the center, and the angle of the position around the center.
    internal static func getPosition(center: CGPoint, dist: CGFloat, angle: CGFloat) -> CGPoint {
        return CGPoint(
            x: center.x + dist * cos(angle.deg2rad()),
            y: center.y + dist * sin(angle.deg2rad())
        )
    }
    
    public static func drawImage(_ image: Image,
                                 x: CGFloat,
                                 y: CGFloat,
                                 size: CGSize,
                                 context: CGContext) {
        var drawOffset = CGPoint()
        drawOffset.x = x - (size.width / 2)
        drawOffset.y = y - (size.height / 2)
        
        NSUIGraphicsPushContext(context)
        
        if image.size.width != size.width && image.size.height != size.height {
            let key = "resized_\(size.width)_\(size.height)"
            
            // Try to take scaled image from cache of this image
            var scaledImage = objc_getAssociatedObject(image, key) as? Image
            if scaledImage == nil {
                // Scale the image
                NSUIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                
                image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
                
                scaledImage = NSUIGraphicsGetImageFromCurrentImageContext()
                NSUIGraphicsEndImageContext()
                
                // Put the scaled image in a cache owned by the original image
                objc_setAssociatedObject(image, key, scaledImage, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            scaledImage?.draw(in: CGRect(origin: drawOffset, size: size))
        }
        else {
            image.draw(in: CGRect(origin: drawOffset, size: size))
        }
        
        NSUIGraphicsPopContext()
    }
    
    public static func drawText(_ text: String,
                                at point: CGPoint,
                                align: NSTextAlignment,
                                attributes: [NSAttributedStringKey : AnyObject]?,
                                context: CGContext) {
        var point = point
        
        switch align {
        case .center:
            point.x -= text.size(withAttributes: attributes).width / 2.0
        case .right:
            point.x -= text.size(withAttributes: attributes).width
        default:
            break
        }
        
        NSUIGraphicsPushContext(context)
        
        (text as NSString).draw(at: point, withAttributes: attributes)
        
        NSUIGraphicsPopContext()
    }
    
    public static func drawText(_ text: String,
                                at point: CGPoint,
                                anchor: CGPoint,
                                angleRadians: CGFloat,
                                attributes: [NSAttributedStringKey : AnyObject]?,
                                context: CGContext) {
        var drawOffset = CGPoint()
        
        NSUIGraphicsPushContext(context)
        
        if angleRadians != 0.0 {
            let size = text.size(withAttributes: attributes)
            
            // Move the text drawing rect in a way that it always rotates around its center
            drawOffset.x = -size.width * 0.5
            drawOffset.y = -size.height * 0.5
            
            var translate = point
            
            // Move the "outer" rect relative to the anchor, assuming its centered
            if anchor.x != 0.5 || anchor.y != 0.5 {
                let rotatedSize = sizeOfRotatedRectangle(size, radians: angleRadians)
                
                translate.x -= rotatedSize.width * (anchor.x - 0.5)
                translate.y -= rotatedSize.height * (anchor.y - 0.5)
            }
            
            context.saveGState()
            context.translateBy(x: translate.x, y: translate.y)
            context.rotate(by: angleRadians)
            
            (text as NSString).draw(at: drawOffset, withAttributes: attributes)
            
            context.restoreGState()
        }
        else {
            if anchor.x != 0.0 || anchor.y != 0.0 {
                let size = text.size(withAttributes: attributes)
                
                drawOffset.x = -size.width * anchor.x
                drawOffset.y = -size.height * anchor.y
            }
            
            drawOffset.x += point.x
            drawOffset.y += point.y
            
            (text as NSString).draw(at: drawOffset, withAttributes: attributes)
        }
        
        NSUIGraphicsPopContext()
    }
    
    static func drawMultilineText(_ text: String,
                                  at point: CGPoint,
                                  anchor: CGPoint,
                                  angleRadians: CGFloat,
                                  knownTextSize: CGSize,
                                  constrainedToSize: CGSize,
                                  attributes: [NSAttributedStringKey : AnyObject]?,
                                  context: CGContext) {
        var rect = CGRect(origin: CGPoint(), size: knownTextSize)
        
        NSUIGraphicsPushContext(context)
        
        if angleRadians != 0.0 {
            // Move the text drawing rect in a way that it always rotates around its center
            rect.origin.x = -knownTextSize.width * 0.5
            rect.origin.y = -knownTextSize.height * 0.5
            
            var translate = point
            
            // Move the "outer" rect relative to the anchor, assuming its centered
            if anchor.x != 0.5 || anchor.y != 0.5 {
                let rotatedSize = sizeOfRotatedRectangle(knownTextSize, radians: angleRadians)
                
                translate.x -= rotatedSize.width * (anchor.x - 0.5)
                translate.y -= rotatedSize.height * (anchor.y - 0.5)
            }
            
            context.saveGState()
            context.translateBy(x: translate.x, y: translate.y)
            context.rotate(by: angleRadians)
            
            (text as NSString).draw(with: rect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            
            context.restoreGState()
        }
        else {
            if anchor.x != 0.0 || anchor.y != 0.0 {
                rect.origin.x = -knownTextSize.width * anchor.x
                rect.origin.y = -knownTextSize.height * anchor.y
            }
            
            rect.origin.x += point.x
            rect.origin.y += point.y
            
            (text as NSString).draw(with: rect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        }
        
        NSUIGraphicsPopContext()
    }
    
    internal static func drawMultilineText(_ text: String,
                                           at point: CGPoint,
                                           constrainedToSize: CGSize,
                                           anchor: CGPoint,
                                           angleRadians: CGFloat,
                                           attributes: [NSAttributedStringKey : AnyObject]?,
                                           context: CGContext) {
        let rect = text.boundingRect(with: constrainedToSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        drawMultilineText(text, at: point, anchor: anchor, angleRadians: angleRadians, knownTextSize: rect.size, constrainedToSize: constrainedToSize, attributes: attributes, context: context)
    }
    
    /// - returns: An angle between 0.0 < 360.0 (not less than zero, less than 360)
    internal static func normalizedAngleFromAngle(_ angle: CGFloat) -> CGFloat {
        var angle = angle
        
        while (angle < 0.0) {
            angle += 360.0
        }
        
        return angle.truncatingRemainder(dividingBy: 360.0)
    }
    
    private static func generateDefaultValueFormatter() -> ValueFormatter {
        let formatter = DefaultValueFormatter(decimals: 1)
        return formatter
    }
    
    /// - returns: The default value formatter used for all chart components that needs a default
    public static func defaultValueFormatter() -> ValueFormatter {
        return _defaultValueFormatter
    }
    
    internal static func sizeOfRotatedRectangle(_ rectangleSize: CGSize, degrees: CGFloat) -> CGSize {
        let radians = degrees.deg2rad()
        return sizeOfRotatedRectangle(rectangleWidth: rectangleSize.width, rectangleHeight: rectangleSize.height, radians: radians)
    }
    
    internal static func sizeOfRotatedRectangle(_ rectangleSize: CGSize, radians: CGFloat) -> CGSize {
        return sizeOfRotatedRectangle(rectangleWidth: rectangleSize.width, rectangleHeight: rectangleSize.height, radians: radians)
    }
    
    internal static func sizeOfRotatedRectangle(rectangleWidth: CGFloat, rectangleHeight: CGFloat, degrees: CGFloat) -> CGSize {
        let radians = degrees.deg2rad()
        return sizeOfRotatedRectangle(rectangleWidth: rectangleWidth, rectangleHeight: rectangleHeight, radians: radians)
    }
    
    internal static func sizeOfRotatedRectangle(rectangleWidth: CGFloat, rectangleHeight: CGFloat, radians: CGFloat) -> CGSize {
        return CGSize(
            width: abs(rectangleWidth * cos(radians)) + abs(rectangleHeight * sin(radians)),
            height: abs(rectangleWidth * sin(radians)) + abs(rectangleHeight * cos(radians))
        )
    }
}

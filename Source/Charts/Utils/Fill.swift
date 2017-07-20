//
//  Fill.swift
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

// TODO: - Reevaluate if we should keep `case: empty` or use optionality
public enum Fill {
    case empty
    case color(CGColor)
    case linearGradient(CGGradient, angle: CGFloat)
    case radialGradient(CGGradient,
    startOffsetPercent: CGPoint,
    startRadiusPercent: CGFloat,
    endOffsetPercent: CGPoint,
    endRadiusPercent: CGFloat)
    case image(CGImage)
    case tiledImage(CGImage)
    case layer(CGLayer)
    
    // MARK: Constructors
    public init(color: Color) {
        self = .color(color.cgColor)
    }
    
    public init(radialGradient: CGGradient) {
        self = .radialGradient(radialGradient,
                               startOffsetPercent: CGPoint(x: 0.0, y: 0.0),
                               startRadiusPercent: 0.0,
                               endOffsetPercent: CGPoint(x: 0.0, y: 0.0),
                               endRadiusPercent: 1.0)
    }
    
    public init(image: CGImage, tiled: Bool = false) {
        self = tiled ? .tiledImage(image) : .image(image)
    }
    
    public init(image: Image, tiled: Bool = false) {
        self.init(image: image.cgImage!, tiled: tiled)
    }
    
    // MARK: Drawing code
    
    /// Draws the provided path in filled mode with the provided area
    func fillPath(context: CGContext, rect: CGRect) {
        context.saveGState()
        
        switch self {
        case .empty:
            break

        case .color(let color):
            context.setFillColor(color)
            context.fillPath()
            
        case .image(let image):
            context.clip()
            context.draw(image, in: rect)
            
        case .tiledImage(let image):
            context.clip()
            context.draw(image, in: rect, byTiling: true)
            
        case .layer(let layer):
            context.clip()
            context.draw(layer, in: rect)
            
        case .linearGradient(let gradient, let angle):
            let radians = (360.0 - angle).deg2rad()
            let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
            let xAngleDelta = cos(radians) * rect.width / 2.0
            let yAngleDelta = sin(radians) * rect.height / 2.0
            let startPoint = CGPoint(
                x: centerPoint.x - xAngleDelta,
                y: centerPoint.y - yAngleDelta
            )
            let endPoint = CGPoint(
                x: centerPoint.x + xAngleDelta,
                y: centerPoint.y + yAngleDelta
            )
            
            context.clip()
            context.drawLinearGradient(gradient,
                start: startPoint,
                end: endPoint,
                options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
            )

        case .radialGradient(let gradient,
                             let startOffsetPercent, let startRadiusPercent,
                             let endOffsetPercent, let endRadiusPercent):
            let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
            let radius = max(rect.width, rect.height) / 2.0
            
            context.clip()
            context.drawRadialGradient(gradient,
                startCenter: CGPoint(
                    x: centerPoint.x + rect.width * startOffsetPercent.x,
                    y: centerPoint.y + rect.height * startOffsetPercent.y
                ),
                startRadius: radius * startRadiusPercent,
                endCenter: CGPoint(
                    x: centerPoint.x + rect.width * endOffsetPercent.x,
                    y: centerPoint.y + rect.height * endOffsetPercent.y
                ),
                endRadius: radius * endRadiusPercent,
                options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
            )
        }
        
        context.restoreGState()
    }
}

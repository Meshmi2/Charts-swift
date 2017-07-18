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
public struct Fill {
    public enum FillType {
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
    }
    
    // MARK: Properties
    let type: FillType //= .empty
    
    // MARK: Constructors
    public init(color: CGColor) {
        type = .color(color)
    }
    
    public init(color: Color) {
        self.init(color: color.cgColor)
    }
    
    public init(linearGradient: CGGradient, angle: CGFloat) {
        type = .linearGradient(linearGradient, angle: angle)
    }
    
    public init(
        radialGradient: CGGradient,
        startOffsetPercent: CGPoint,
        startRadiusPercent: CGFloat,
        endOffsetPercent: CGPoint,
        endRadiusPercent: CGFloat) {
        type = .radialGradient(radialGradient,
                               startOffsetPercent: startOffsetPercent,
                               startRadiusPercent: startRadiusPercent,
                               endOffsetPercent: endOffsetPercent,
                               endRadiusPercent: endRadiusPercent)
    }
    
    public init(radialGradient: CGGradient) {
        self.init(radialGradient: radialGradient,
                  startOffsetPercent: CGPoint(x: 0.0, y: 0.0),
                  startRadiusPercent: 0.0,
                  endOffsetPercent: CGPoint(x: 0.0, y: 0.0),
                  endRadiusPercent: 1.0)
    }
    
    public init(image: CGImage, tiled: Bool = false) {
        type = tiled ? .tiledImage(image) : .image(image)
    }
    
    public init(image: Image, tiled: Bool = false) {
        self.init(image: image.cgImage!, tiled: tiled)
    }
    
    public init(layer: CGLayer) {
        type = .layer(layer)
    }
    
    // MARK: Drawing code
    
    /// Draws the provided path in filled mode with the provided area
    func fillPath(context: CGContext, rect: CGRect) {
        context.saveGState()
        
        switch type {
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
            let radians = ChartUtils.Math.FDEG2RAD * (360.0 - angle)
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

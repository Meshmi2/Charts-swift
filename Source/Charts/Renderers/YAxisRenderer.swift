//
//  YAxisRenderer.swift
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

class YAxisRenderer: AxisRenderer {
    let viewPortHandler: ViewPortHandler

    /// base axis this axis renderer works with
    var axis: YAxis
    
    /// transformer to transform values to screen pixels and return
    var transformer: Transformer?

    init(viewPortHandler: ViewPortHandler, axis: YAxis, transformer: Transformer?) {
        self.viewPortHandler = viewPortHandler
        self.transformer = transformer
        self.axis = axis
    }
    
    /// draws the y-axis labels to the screen
    func renderAxisLabels(context: CGContext) {
        guard axis.isEnabled, axis.isDrawLabelsEnabled else { return }
        
        let xoffset = axis.xOffset
        let yoffset = axis.labelFont.lineHeight / 2.5 + axis.yOffset
        
        let dependency = axis.axisDependency
        let labelPosition = axis.labelPosition
        
        let xPos: CGFloat
        let textAlign: NSTextAlignment
        
        switch (dependency, labelPosition) {
        case (.left, .outsideChart):
            textAlign = .right
            xPos = viewPortHandler.offsetLeft - xoffset

        case (.left, .insideChart):
            textAlign = .left
            xPos = viewPortHandler.offsetLeft + xoffset

        case (.right, .outsideChart):
            textAlign = .left
            xPos = viewPortHandler.contentRight + xoffset

        case (.right, .insideChart):
            textAlign = .right
            xPos = viewPortHandler.contentRight - xoffset
        }
        
        drawYLabels(
            context: context,
            fixedPosition: xPos,
            positions: transformedPositions(),
            offset: yoffset - axis.labelFont.lineHeight,
            textAlign: textAlign)
    }
    
    func renderAxisLine(context: CGContext) {
        guard axis.isEnabled, axis.isDrawAxisLineEnabled else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        
        context.setStrokeColor(axis.axisLineColor.cgColor)
        context.setLineWidth(axis.axisLineWidth)
        if axis.axisLineDashLengths != nil {
            context.setLineDash(phase: axis.axisLineDashPhase, lengths: axis.axisLineDashLengths)
        }
        else {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        context.beginPath()
        switch axis.axisDependency {
        case .left:
            context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom))

        case .right:
            context.move(to: CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentBottom))
        }
        context.strokePath()
    }
    
    /// draws the y-labels on the specified x-position
    func drawYLabels(
        context: CGContext,
        fixedPosition: CGFloat,
        positions: [CGPoint],
        offset: CGFloat,
        textAlign: NSTextAlignment) {
        let labelFont = axis.labelFont
        let labelTextColor = axis.labelTextColor
        
        let from = axis.isDrawBottomYLabelEntryEnabled ? 0 : 1
        let to = axis.isDrawTopYLabelEntryEnabled ? axis.entryCount : (axis.entryCount - 1)
        
        for i in from..<to {
            let text = axis.getFormattedLabel(i)
            
            ChartUtils.drawText(text,
                                at: CGPoint(x: fixedPosition, y: positions[i].y + offset),
                                align: textAlign,
                                attributes: [.font: labelFont, .foregroundColor: labelTextColor],
                                context: context)
        }
    }
    
    func renderGridLines(context: CGContext) {
        guard axis.isEnabled else { return }
        
        if axis.isDrawGridLinesEnabled {
            let positions = transformedPositions()
            
            context.saveGState()
            defer { context.restoreGState() }
            
            context.clip(to: self.gridClippingRect)
            
            context.setShouldAntialias(axis.isGridAntialiasEnabled)
            context.setStrokeColor(axis.gridColor.cgColor)
            context.setLineWidth(axis.gridLineWidth)
            context.setLineCap(axis.gridLineCap)
            
            if axis.gridLineDashLengths != nil {
                context.setLineDash(phase: axis.gridLineDashPhase, lengths: axis.gridLineDashLengths)
            }
            else {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            // draw the grid
            positions.forEach { drawGridLine(at: $0, context: context) }
        }

        if axis.isDrawZeroLineEnabled {
            // draw zero line
            drawZeroLine(context: context)
        }
    }
    
    var gridClippingRect: CGRect {
        var contentRect = viewPortHandler.contentRect
        let dy = self.axis.gridLineWidth
        contentRect.origin.y -= dy / 2.0
        contentRect.size.height += dy
        return contentRect
    }
    
    func drawGridLine(at position: CGPoint, context: CGContext) {
        context.beginPath()
        context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: position.y))
        context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: position.y))
        context.strokePath()
    }
    
    func transformedPositions() -> [CGPoint] {
        guard let transformer = self.transformer else { return [] }
        
        var positions = axis.entries.map { CGPoint(x: 0, y: $0) }
        transformer.pointValuesToPixel(&positions)
        
        return positions
    }

    /// Draws the zero line at the specified position.
    func drawZeroLine(context: CGContext) {
        guard
            let transformer = self.transformer,
            let zeroLineColor = axis.zeroLineColor
            else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        
        var clippingRect = viewPortHandler.contentRect
        clippingRect.origin.y -= axis.zeroLineWidth / 2.0
        clippingRect.size.height += axis.zeroLineWidth
        context.clip(to: clippingRect)

        context.setStrokeColor(zeroLineColor.cgColor)
        context.setLineWidth(axis.zeroLineWidth)
        
        let pos = transformer.pixelForValues(x: 0.0, y: 0.0)
    
        if axis.zeroLineDashLengths != nil {
            context.setLineDash(phase: axis.zeroLineDashPhase, lengths: axis.zeroLineDashLengths!)
        }
        else {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: pos.y))
        context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: pos.y))
        context.drawPath(using: .stroke)
    }
    
    func renderLimitLines(context: CGContext) {
        guard let transformer = self.transformer else { return }
        
        let limitLines = axis.limitLines
        
        guard !limitLines.isEmpty else { return }
        
        context.saveGState()
        
        let trans = transformer.valueToPixelMatrix
        
        var position = CGPoint()
        
        for l in limitLines {
            guard l.isEnabled else { continue }
            
            context.saveGState()
            defer { context.restoreGState() }
            
            var clippingRect = viewPortHandler.contentRect
            clippingRect.origin.y -= l.lineWidth / 2.0
            clippingRect.size.height += l.lineWidth
            context.clip(to: clippingRect)
            
            position.x = 0.0
            position.y = CGFloat(l.limit)
            position = position.applying(trans)
            
            context.beginPath()
            context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: position.y))
            context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: position.y))
            
            context.setStrokeColor(l.lineColor.cgColor)
            context.setLineWidth(l.lineWidth)
            if l.lineDashLengths != nil {
                context.setLineDash(phase: l.lineDashPhase, lengths: l.lineDashLengths!)
            }
            else {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            context.strokePath()
            
            let label = l.label
            
            // if drawing the limit-value label is enabled
            guard l.drawLabelEnabled && !label.characters.isEmpty else { return }
            let labelLineHeight = l.valueFont.lineHeight
            
            let xOffset: CGFloat = 4.0 + l.xOffset
            let yOffset: CGFloat = l.lineWidth + labelLineHeight + l.yOffset
            
            switch l.labelPosition {
            case .rightTop:
                ChartUtils.drawText(label,
                                    at: CGPoint(x: viewPortHandler.contentRight - xOffset,
                                                y: position.y - yOffset),
                                    align: .right,
                                    attributes: [.font: l.valueFont,
                                                 .foregroundColor: l.valueTextColor],
                                    context: context)

            case .rightBottom:
                ChartUtils.drawText(label,
                                    at: CGPoint(x: viewPortHandler.contentRight - xOffset,
                                                y: position.y + yOffset - labelLineHeight),
                                    align: .right,
                                    attributes: [.font: l.valueFont,
                                                 .foregroundColor: l.valueTextColor],
                                    context: context)

            case .leftTop:
                ChartUtils.drawText(label,
                                    at: CGPoint(x: viewPortHandler.contentLeft + xOffset,
                                                y: position.y - yOffset),
                                    align: .left,
                                    attributes: [.font: l.valueFont,
                                                 .foregroundColor: l.valueTextColor],
                                    context: context)
                
            case .leftBottom:
                ChartUtils.drawText(label,
                                    at: CGPoint(x: viewPortHandler.contentLeft + xOffset,
                                                y: position.y + yOffset - labelLineHeight),
                                    align: .left,
                                    attributes: [.font: l.valueFont,
                                                 .foregroundColor: l.valueTextColor],
                                    context: context)
            }
        }
    }
}

//
//  XAxisRendererHorizontalBarChart.swift
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

class XAxisRendererHorizontalBarChart: XAxisRenderer {
    var chart: BarChartView
    
    public init(viewPortHandler: ViewPortHandler, axis: XAxis, transformer: Transformer?, chart: BarChartView) {
        self.chart = chart
        super.init(viewPortHandler: viewPortHandler, axis: axis, transformer: transformer)
    }
    
    public override func computeAxis(min: Double, max: Double, inverted: Bool) {
        var min = min, max = max
        
        if let transformer = self.transformer {
            // calculate the starting and entry point of the y-labels (depending on
            // zoom / contentrect bounds)
            if viewPortHandler.contentWidth > 10 && !viewPortHandler.isFullyZoomedOutX {
                let p1 = transformer.valueForTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom))
                let p2 = transformer.valueForTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
                
                if inverted {
                    min = Double(p2.y)
                    max = Double(p1.y)
                }
                else {
                    min = Double(p1.y)
                    max = Double(p2.y)
                }
            }
        }
        
        computeAxisValues(min: min, max: max)
    }
    
    public override func computeSize() {
        let longest = axis.getLongestLabel() as NSString
        
        let labelSize = longest.size(withAttributes: [NSAttributedStringKey.font: axis.labelFont])
        
        let labelWidth = floor(labelSize.width + axis.xOffset * 3.5)
        let labelHeight = labelSize.height
        
        let labelRotatedSize = ChartUtils.sizeOfRotatedRectangle(rectangleWidth: labelSize.width, rectangleHeight:  labelHeight, degrees: axis.labelRotationAngle)
        
        axis.labelWidth = labelWidth
        axis.labelHeight = labelHeight
        axis.labelRotatedWidth = round(labelRotatedSize.width + axis.xOffset * 3.5)
        axis.labelRotatedHeight = round(labelRotatedSize.height)
    }

    public override func renderAxisLabels(context: CGContext) {
        guard axis.isEnabled, axis.isDrawLabelsEnabled else { return }
        
        let xoffset = axis.xOffset
        
        switch axis.labelPosition {
        case .top:
            drawLabels(context: context, pos: viewPortHandler.contentRight + xoffset, anchor: CGPoint(x: 0.0, y: 0.5))
            
        case .topInside:
            drawLabels(context: context, pos: viewPortHandler.contentRight - xoffset, anchor: CGPoint(x: 1.0, y: 0.5))
            
        case .bottom:
            drawLabels(context: context, pos: viewPortHandler.contentLeft - xoffset, anchor: CGPoint(x: 1.0, y: 0.5))
            
        case .bottomInside:
            drawLabels(context: context, pos: viewPortHandler.contentLeft + xoffset, anchor: CGPoint(x: 0.0, y: 0.5))
            
        default: // BOTH SIDED
            drawLabels(context: context, pos: viewPortHandler.contentRight + xoffset, anchor: CGPoint(x: 0.0, y: 0.5))
            drawLabels(context: context, pos: viewPortHandler.contentLeft - xoffset, anchor: CGPoint(x: 1.0, y: 0.5))
        }
    }

    /// draws the x-labels on the specified y-position
    public override func drawLabels(context: CGContext, pos: CGFloat, anchor: CGPoint) {
        guard let transformer = self.transformer else { return }
        
        let labelFont = axis.labelFont
        let labelTextColor = axis.labelTextColor
        let labelRotationAngleRadians = axis.labelRotationAngle.deg2rad()
        
        let centeringEnabled = axis.isCenterAxisLabelsEnabled
        
        // pre allocate to save performance (dont allocate in loop)
        var position = CGPoint(x: 0.0, y: 0.0)
        
        for i in stride(from: 0, to: axis.entryCount, by: 1) {
            // only fill x values
            
            position.x = 0.0
            
            if centeringEnabled {
                position.y = CGFloat(axis.centeredEntries[i])
            }
            else {
                position.y = CGFloat(axis.entries[i])
            }
            
            transformer.pointValueToPixel(&position)
            
            if viewPortHandler.isInBoundsY(position.y) {
                if let label = axis.valueFormatter?.stringForValue(axis.entries[i], axis: axis) {
                    drawLabel(
                        context: context,
                        formattedLabel: label,
                        x: pos,
                        y: position.y,
                        attributes: [.font: labelFont,
                                     .foregroundColor: labelTextColor],
                        anchor: anchor,
                        angleRadians: labelRotationAngleRadians)
                }
            }
        }
    }
    
    public func drawLabel(
        context: CGContext,
        formattedLabel: String,
        x: CGFloat,
        y: CGFloat,
        attributes: [NSAttributedStringKey : AnyObject],
        anchor: CGPoint,
        angleRadians: CGFloat) {
        ChartUtils.drawText(formattedLabel,
                            at: CGPoint(x: x, y: y),
                            anchor: anchor,
                            angleRadians: angleRadians,
                            attributes: attributes,
                            context: context)
    }
    
    public override var gridClippingRect: CGRect {
        var contentRect = viewPortHandler.contentRect
        let dy = self.axis.gridLineWidth
        contentRect.origin.y -= dy / 2.0
        contentRect.size.height += dy
        return contentRect
    }
    
    private var _gridLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    public override func drawGridLine(context: CGContext, x: CGFloat, y: CGFloat) {
        if viewPortHandler.isInBoundsY(y) {
            context.beginPath()
            context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: y))
            context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: y))
            context.strokePath()
        }
    }
    
    public override func renderAxisLine(context: CGContext) {
        guard axis.isEnabled, axis.isDrawAxisLineEnabled else { return }
        
        context.saveGState()
        
        context.setStrokeColor(axis.axisLineColor.cgColor)
        context.setLineWidth(axis.axisLineWidth)
        if axis.axisLineDashLengths != nil {
            context.setLineDash(phase: axis.axisLineDashPhase, lengths: axis.axisLineDashLengths)
        }
        else {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        context.beginPath()
        
        switch axis.labelPosition {
        case .top, .topInside:
            context.move(to: CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentBottom))

        case .bottom, .bottomInside:
            context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom))
            
        case .bothSided:
            context.move(to: CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentBottom))
            context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom))
        }
        
        context.strokePath()
        context.restoreGState()
    }
    
    public override func renderLimitLines(context: CGContext) {
        guard let transformer = self.transformer else { return }
        
        var limitLines = axis.limitLines
        
        guard limitLines.count > 0 else { return }
        
        let trans = transformer.valueToPixelMatrix
        
        var position = CGPoint()
        
        for l in limitLines {
            if !l.isEnabled {
                continue
            }
            
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
            if l.drawLabelEnabled && label.characters.count > 0 {
                let labelLineHeight = l.valueFont.lineHeight
                
                let xOffset: CGFloat = 4.0 + l.xOffset
                let yOffset: CGFloat = l.lineWidth + labelLineHeight + l.yOffset
                
                if l.labelPosition == .rightTop {
                    ChartUtils.drawText(label,
                                        at: CGPoint(x: viewPortHandler.contentRight - xOffset,
                                                    y: position.y - yOffset),
                                        align: .right,
                                        attributes: [.font: l.valueFont, .foregroundColor: l.valueTextColor],
                                        context: context)
                }
                else if l.labelPosition == .rightBottom {
                    ChartUtils.drawText(label,
                                        at: CGPoint(x: viewPortHandler.contentRight - xOffset,
                                                    y: position.y + yOffset - labelLineHeight),
                                        align: .right,
                                        attributes: [.font: l.valueFont,
                                                     .foregroundColor: l.valueTextColor],
                                        context: context)
                }
                else if l.labelPosition == .leftTop {
                    ChartUtils.drawText(label,
                                        at: CGPoint(x: viewPortHandler.contentLeft + xOffset,
                                                    y: position.y - yOffset),
                                        align: .left,
                                        attributes: [.font: l.valueFont,
                                                     .foregroundColor: l.valueTextColor],
                                        context: context)
                }
                else {
                    ChartUtils.drawText(label,
                                        at: CGPoint(
                                            x: viewPortHandler.contentLeft + xOffset,
                                            y: position.y + yOffset - labelLineHeight),
                                        align: .left,
                                        attributes: [.font: l.valueFont,
                                                     .foregroundColor: l.valueTextColor],
                                        context: context)
                }
            }
        }
    }
}

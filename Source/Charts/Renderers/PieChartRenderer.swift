//
//  PieChartRenderer.swift
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


final class PieChartRenderer: DataRenderer {
    var viewPortHandler: ViewPortHandler
    
    var animator: Animator?
    
    weak var chart: PieChartView?
    
    public init(chart: PieChartView?, animator: Animator?, viewPortHandler: ViewPortHandler) {
        self.animator = animator
        self.viewPortHandler = viewPortHandler
        self.chart = chart
    }
    
    func initBuffers() { }
    
    func drawData(context: CGContext) {
        guard let chart = chart else { return }
        
        let pieData = chart.data
        
        if pieData != nil {
            for set in pieData!.dataSets as! [PieChartDataSet] {
                if set.isVisible && set.count > 0 {
                    drawDataSet(context: context, dataSet: set)
                }
            }
        }
    }
    
    func calculateMinimumRadiusForSpacedSlice(
        center: CGPoint,
        radius: CGFloat,
        angle: CGFloat,
        arcStartPointX: CGFloat,
        arcStartPointY: CGFloat,
        startAngle: CGFloat,
        sweepAngle: CGFloat) -> CGFloat {
        let angleMiddle = startAngle + sweepAngle / 2.0
        
        // Other point of the arc
        let arcEndPointX = center.x + radius * cos((startAngle + sweepAngle).deg2rad())
        let arcEndPointY = center.y + radius * sin((startAngle + sweepAngle).deg2rad())
        
        // Middle point on the arc
        let arcMidPointX = center.x + radius * cos(angleMiddle.deg2rad())
        let arcMidPointY = center.y + radius * sin(angleMiddle.deg2rad())
        
        // This is the base of the contained triangle
        let basePointsDistance = sqrt(
            pow(arcEndPointX - arcStartPointX, 2) +
                pow(arcEndPointY - arcStartPointY, 2))
        
        // After reducing space from both sides of the "slice",
        //   the angle of the contained triangle should stay the same.
        // So let's find out the height of that triangle.
        let containedTriangleHeight = (basePointsDistance / 2.0 *
            tan((180.0 - angle).deg2rad() / 2.0))
        
        // Now we subtract that from the radius
        var spacedRadius = radius - containedTriangleHeight
        
        // And now subtract the height of the arc that's between the triangle and the outer circle
        spacedRadius -= sqrt(
            pow(arcMidPointX - (arcEndPointX + arcStartPointX) / 2.0, 2) +
                pow(arcMidPointY - (arcEndPointY + arcStartPointY) / 2.0, 2))
        
        return spacedRadius
    }
    
    /// Calculates the sliceSpace to use based on visible values and their size compared to the set sliceSpace.
    func getSliceSpace(dataSet: PieChartDataSet) -> CGFloat {
        guard
            dataSet.automaticallyDisableSliceSpacing,
            let data = chart?.data as? PieChartData
            else { return dataSet.sliceSpace }
        
        let spaceSizeRatio = dataSet.sliceSpace / min(viewPortHandler.contentWidth, viewPortHandler.contentHeight)
        let minValueRatio = dataSet.yMin / data.yValueSum * 2.0
        
        let sliceSpace = spaceSizeRatio > CGFloat(minValueRatio)
            ? 0.0
            : dataSet.sliceSpace
        
        return sliceSpace
    }
    
    func drawDataSet(context: CGContext, dataSet: PieChartDataSet) {
        guard
            let chart = chart,
            let animator = animator
            else {return }
        
        var angle: CGFloat = 0.0
        let rotationAngle = chart.rotationAngle
        
        let phaseX = animator.phaseX
        let phaseY = animator.phaseY
        
        let entryCount = dataSet.count
        var drawAngles = chart.drawAngles
        let center = chart.centerCircleBox
        let radius = chart.radius
        let drawInnerArc = chart.isDrawHoleEnabled && !chart.isDrawSlicesUnderHoleEnabled
        let userInnerRadius = drawInnerArc ? radius * chart.holeRadiusPercent : 0.0
        
        var visibleAngleCount = 0
        for j in 0 ..< entryCount {
            let e = dataSet[j]
            if ((abs(e.y) > Double.ulpOfOne)) {
                visibleAngleCount += 1
            }
        }
        
        let sliceSpace = visibleAngleCount <= 1 ? 0.0 : getSliceSpace(dataSet: dataSet)
        
        context.saveGState()
        
        for j in 0 ..< entryCount {
            let sliceAngle = drawAngles[j]
            var innerRadius = userInnerRadius
            
            let e = dataSet[j]
            
            // draw only if the value is greater than zero
            if (abs(e.y) > Double.ulpOfOne) {
                if !chart.needsHighlight(index: j) {
                    let accountForSliceSpacing = sliceSpace > 0.0 && sliceAngle <= 180.0
                    
                    context.setFillColor(dataSet.color(atIndex: j).cgColor)
                    
                    let sliceSpaceAngleOuter = visibleAngleCount == 1 ?
                        0.0 :
                        sliceSpace / radius.deg2rad()
                    let startAngleOuter = rotationAngle + (angle + sliceSpaceAngleOuter / 2.0) * CGFloat(phaseY)
                    var sweepAngleOuter = (sliceAngle - sliceSpaceAngleOuter) * CGFloat(phaseY)
                    if sweepAngleOuter < 0.0 {
                        sweepAngleOuter = 0.0
                    }
                    
                    let arcStartPointX = center.x + radius * cos(startAngleOuter.deg2rad())
                    let arcStartPointY = center.y + radius * sin(startAngleOuter.deg2rad())
                    
                    let path = CGMutablePath()
                    
                    path.move(to: CGPoint(x: arcStartPointX,
                                          y: arcStartPointY))
                    
                    path.addRelativeArc(center: center, radius: radius, startAngle: startAngleOuter.deg2rad(), delta: sweepAngleOuter.deg2rad())
                    
                    if drawInnerArc &&
                        (innerRadius > 0.0 || accountForSliceSpacing) {
                        if accountForSliceSpacing {
                            var minSpacedRadius = calculateMinimumRadiusForSpacedSlice(
                                center: center,
                                radius: radius,
                                angle: sliceAngle * CGFloat(phaseY),
                                arcStartPointX: arcStartPointX,
                                arcStartPointY: arcStartPointY,
                                startAngle: startAngleOuter,
                                sweepAngle: sweepAngleOuter)
                            if minSpacedRadius < 0.0
                            {
                                minSpacedRadius = -minSpacedRadius
                            }
                            innerRadius = min(max(innerRadius, minSpacedRadius), radius)
                        }
                        
                        let sliceSpaceAngleInner = visibleAngleCount == 1 || innerRadius == 0.0 ?
                            0.0 :
                            sliceSpace / innerRadius.deg2rad()
                        let startAngleInner = rotationAngle + (angle + sliceSpaceAngleInner / 2.0) * CGFloat(phaseY)
                        var sweepAngleInner = (sliceAngle - sliceSpaceAngleInner) * CGFloat(phaseY)
                        if sweepAngleInner < 0.0 {
                            sweepAngleInner = 0.0
                        }
                        let endAngleInner = startAngleInner + sweepAngleInner
                        
                        path.addLine(to: CGPoint(x: center.x + innerRadius * cos(endAngleInner.deg2rad()),
                                                 y: center.y + innerRadius * sin(endAngleInner.deg2rad())))
                        
                        path.addRelativeArc(center: center, radius: innerRadius, startAngle: endAngleInner.deg2rad(), delta: -sweepAngleInner.deg2rad())
                    }
                    else {
                        if accountForSliceSpacing {
                            let angleMiddle = startAngleOuter + sweepAngleOuter / 2.0
                            
                            let sliceSpaceOffset =
                                calculateMinimumRadiusForSpacedSlice(center: center,
                                                                     radius: radius,
                                                                     angle: sliceAngle * CGFloat(phaseY),
                                                                     arcStartPointX: arcStartPointX,
                                                                     arcStartPointY: arcStartPointY,
                                                                     startAngle: startAngleOuter,
                                                                     sweepAngle: sweepAngleOuter)
                            
                            let arcEndPointX = center.x + sliceSpaceOffset * cos(angleMiddle.deg2rad())
                            let arcEndPointY = center.y + sliceSpaceOffset * sin(angleMiddle.deg2rad())
                            
                            path.addLine(to: CGPoint(x: arcEndPointX,
                                                     y: arcEndPointY))
                        }
                        else {
                            path.addLine(to: center)
                        }
                    }
                    
                    path.closeSubpath()
                    
                    context.beginPath()
                    context.addPath(path)
                    context.fillPath(using: .evenOdd)
                }
            }
            
            angle += sliceAngle * CGFloat(phaseX)
        }
        
        context.restoreGState()
    }
    
    func drawValues(context: CGContext) {
        guard
            let chart = chart,
            let data = chart.data,
            let animator = animator
            else { return }
        
        let center = chart.centerCircleBox
        
        // get whole the radius
        let radius = chart.radius
        let rotationAngle = chart.rotationAngle
        var drawAngles = chart.drawAngles
        var absoluteAngles = chart.absoluteAngles
        
        let phaseX = animator.phaseX
        let phaseY = animator.phaseY
        
        var labelRadiusOffset = radius / 10.0 * 3.0
        
        if chart.isDrawHoleEnabled {
            labelRadiusOffset = (radius - (radius * chart.holeRadiusPercent)) / 2.0
        }
        
        let labelRadius = radius - labelRadiusOffset
        
        var dataSets = data.dataSets
        
        let yValueSum = (data as! PieChartData).yValueSum
        
        let drawEntryLabels = chart.isDrawEntryLabelsEnabled
        let usePercentValuesEnabled = chart.usePercentValues
        let entryLabelColor = chart.entryLabelColor
        let entryLabelFont = chart.entryLabelFont
        
        var angle: CGFloat = 0.0
        var xIndex = 0
        
        context.saveGState()
        defer { context.restoreGState() }
        
        for i in 0 ..< dataSets.count {
            guard let dataSet = dataSets[i] as? PieChartDataSet else { continue }
            
            let drawValues = dataSet.isDrawValuesEnabled
            
            if !drawValues && !drawEntryLabels && !dataSet.isDrawIconsEnabled {
                continue
            }
            
            let iconsOffset = dataSet.iconsOffset
            
            let xValuePosition = dataSet.xValuePosition
            let yValuePosition = dataSet.yValuePosition
            
            let valueFont = dataSet.valueFont
            let entryLabelFont = dataSet.entryLabelFont
            let lineHeight = valueFont.lineHeight
            
            guard let formatter = dataSet.valueFormatter else { continue }
            
            for j in 0 ..< dataSet.count {
                let e = dataSet[j]
                let pe = e as? PieChartDataEntry
                
                if xIndex == 0 {
                    angle = 0.0
                }
                else {
                    angle = absoluteAngles[xIndex - 1] * CGFloat(phaseX)
                }
                
                let sliceAngle = drawAngles[xIndex]
                let sliceSpace = getSliceSpace(dataSet: dataSet)
                let sliceSpaceMiddleAngle = sliceSpace / labelRadius.deg2rad()
                
                // offset needed to center the drawn text in the slice
                let angleOffset = (sliceAngle - sliceSpaceMiddleAngle / 2.0) / 2.0
                
                angle = angle + angleOffset
                
                let transformedAngle = rotationAngle + angle * CGFloat(phaseY)
                
                let value = usePercentValuesEnabled ? e.y / yValueSum * 100.0 : e.y
                let valueText = formatter.stringForValue(
                    value,
                    entry: e,
                    dataSetIndex: i,
                    viewPortHandler: viewPortHandler)
                
                let sliceXBase = cos(transformedAngle.deg2rad())
                let sliceYBase = sin(transformedAngle.deg2rad())
                
                let drawXOutside = drawEntryLabels && xValuePosition == .outsideSlice
                let drawYOutside = drawValues && yValuePosition == .outsideSlice
                let drawXInside = drawEntryLabels && xValuePosition == .insideSlice
                let drawYInside = drawValues && yValuePosition == .insideSlice
                
                let valueTextColor = dataSet.valueTextColorAt(j)
                let entryLabelColor = dataSet.entryLabelColor
                
                if drawXOutside || drawYOutside {
                    let valueLineLength1 = dataSet.valueLinePart1Length
                    let valueLineLength2 = dataSet.valueLinePart2Length
                    let valueLinePart1OffsetPercentage = dataSet.valueLinePart1OffsetPercentage
                    
                    var pt2: CGPoint
                    var labelPoint: CGPoint
                    var align: NSTextAlignment
                    
                    var line1Radius: CGFloat
                    
                    if chart.isDrawHoleEnabled {
                        line1Radius = (radius - (radius * chart.holeRadiusPercent)) * valueLinePart1OffsetPercentage + (radius * chart.holeRadiusPercent)
                    }
                    else {
                        line1Radius = radius * valueLinePart1OffsetPercentage
                    }
                    
                    let polyline2Length = dataSet.valueLineVariableLength
                        ? labelRadius * valueLineLength2 * abs(sin(transformedAngle.deg2rad()))
                        : labelRadius * valueLineLength2
                    
                    let pt0 = CGPoint(
                        x: line1Radius * sliceXBase + center.x,
                        y: line1Radius * sliceYBase + center.y)
                    
                    let pt1 = CGPoint(
                        x: labelRadius * (1 + valueLineLength1) * sliceXBase + center.x,
                        y: labelRadius * (1 + valueLineLength1) * sliceYBase + center.y)
                    
                    if transformedAngle.truncatingRemainder(dividingBy: 360.0) >= 90.0 && transformedAngle.truncatingRemainder(dividingBy: 360.0) <= 270.0 {
                        pt2 = CGPoint(x: pt1.x - polyline2Length, y: pt1.y)
                        align = .right
                        labelPoint = CGPoint(x: pt2.x - 5, y: pt2.y - lineHeight)
                    }
                    else {
                        pt2 = CGPoint(x: pt1.x + polyline2Length, y: pt1.y)
                        align = .left
                        labelPoint = CGPoint(x: pt2.x + 5, y: pt2.y - lineHeight)
                    }
                    
                    if dataSet.valueLineColor != nil {
                        context.setStrokeColor(dataSet.valueLineColor!.cgColor)
                        context.setLineWidth(dataSet.valueLineWidth)
                        
                        context.move(to: CGPoint(x: pt0.x, y: pt0.y))
                        context.addLine(to: CGPoint(x: pt1.x, y: pt1.y))
                        context.addLine(to: CGPoint(x: pt2.x, y: pt2.y))
                        
                        context.drawPath(using: CGPathDrawingMode.stroke)
                    }
                    
                    if drawXOutside && drawYOutside {
                        ChartUtils.drawText(valueText,
                                            at: labelPoint,
                                            align: align,
                                            attributes: [.font: valueFont,
                                                         .foregroundColor: valueTextColor],
                                            context: context)
                        
                        if j < data.entryCount && pe?.label != nil {
                            ChartUtils.drawText(pe!.label!,
                                                at: CGPoint(x: labelPoint.x,
                                                            y: labelPoint.y + lineHeight),
                                                align: align,
                                                attributes: [.font: entryLabelFont ?? valueFont,
                                                             .foregroundColor: entryLabelColor ?? valueTextColor],
                                                context: context)
                        }
                    }
                    else if drawXOutside {
                        if j < data.entryCount && pe?.label != nil {
                            ChartUtils.drawText(pe!.label!,
                                                at: CGPoint(x: labelPoint.x,
                                                            y: labelPoint.y + lineHeight / 2.0),
                                                align: align,
                                                attributes: [.font: entryLabelFont ?? valueFont,
                                                             .foregroundColor: entryLabelColor ?? valueTextColor],
                                                context: context)
                        }
                    }
                    else if drawYOutside {
                        ChartUtils.drawText(valueText,
                                            at: CGPoint(x: labelPoint.x,
                                                        y: labelPoint.y + lineHeight / 2.0),
                                            align: align,
                                            attributes: [.font: valueFont,
                                                         .foregroundColor: valueTextColor],
                                            context: context)
                    }
                }
                
                if drawXInside || drawYInside {
                    // calculate the text position
                    let x = labelRadius * sliceXBase + center.x
                    let y = labelRadius * sliceYBase + center.y - lineHeight
                    
                    if drawXInside && drawYInside {
                        ChartUtils.drawText(valueText,
                                            at: CGPoint(x: x, y: y),
                                            align: .center,
                                            attributes: [.font: valueFont,
                                                         .foregroundColor: valueTextColor],
                                            context: context)
                        
                        if j < data.entryCount && pe?.label != nil {
                            ChartUtils.drawText(pe!.label!,
                                                at: CGPoint(x: x, y: y + lineHeight),
                                                align: .center,
                                                attributes: [
                                                    .font: entryLabelFont ?? valueFont,
                                                    .foregroundColor: entryLabelColor ?? valueTextColor],
                                                context: context)
                        }
                    }
                    else if drawXInside {
                        if j < data.entryCount && pe?.label != nil {
                            ChartUtils.drawText(pe!.label!,
                                                at: CGPoint(x: x, y: y + lineHeight / 2.0),
                                                align: .center,
                                                attributes: [
                                                    .font: entryLabelFont ?? valueFont,
                                                    .foregroundColor: entryLabelColor ?? valueTextColor],
                                                context: context)
                        }
                    }
                    else if drawYInside {
                        ChartUtils.drawText(valueText,
                                            at: CGPoint(x: x, y: y + lineHeight / 2.0),
                                            align: .center,
                                            attributes: [.font: valueFont,
                                                         .foregroundColor: valueTextColor],
                                            context: context)
                    }
                }
                
                if let icon = e.icon, dataSet.isDrawIconsEnabled {
                    // calculate the icon's position
                    
                    let x = (labelRadius + iconsOffset.y) * sliceXBase + center.x
                    var y = (labelRadius + iconsOffset.y) * sliceYBase + center.y
                    y += iconsOffset.x
                    
                    ChartUtils.drawImage(icon,
                                         x: x,
                                         y: y,
                                         size: icon.size,
                                         context: context)
                }
                
                xIndex += 1
            }
        }
    }
    
    func drawExtras(context: CGContext) {
        drawHole(context: context)
        drawCenterText(context: context)
    }
    
    /// draws the hole in the center of the chart and the transparent circle / hole
    private func drawHole(context: CGContext) {
        guard
            let chart = chart,
            let animator = animator
            else { return }
        
        if chart.isDrawHoleEnabled {
            context.saveGState()
            
            let radius = chart.radius
            let holeRadius = radius * chart.holeRadiusPercent
            let center = chart.centerCircleBox
            
            if let holeColor = chart.holeColor,
                holeColor != .clear {
                // draw the hole-circle
                context.setFillColor(chart.holeColor!.cgColor)
                context.fillEllipse(in: CGRect(x: center.x - holeRadius,
                                               y: center.y - holeRadius,
                                               width: holeRadius * 2.0,
                                               height: holeRadius * 2.0))
            }
            
            // only draw the circle if it can be seen (not covered by the hole)
            if let transparentCircleColor = chart.transparentCircleColor,
                transparentCircleColor != .clear &&
                    chart.transparentCircleRadiusPercent > chart.holeRadiusPercent {
                let alpha = animator.phaseX * animator.phaseY
                let secondHoleRadius = radius * chart.transparentCircleRadiusPercent
                
                // make transparent
                context.setAlpha(CGFloat(alpha))
                context.setFillColor(transparentCircleColor.cgColor)
                
                // draw the transparent-circle
                context.beginPath()
                context.addEllipse(in: CGRect(x: center.x - secondHoleRadius,
                                              y: center.y - secondHoleRadius,
                                              width: secondHoleRadius * 2.0,
                                              height: secondHoleRadius * 2.0))
                context.addEllipse(in: CGRect(x: center.x - holeRadius,
                                              y: center.y - holeRadius,
                                              width: holeRadius * 2.0,
                                              height: holeRadius * 2.0))
                context.fillPath(using: .evenOdd)
            }
            
            context.restoreGState()
        }
    }
    
    /// draws the description text in the center of the pie chart makes most sense when center-hole is enabled
    private func drawCenterText(context: CGContext) {
        guard
            let chart = chart,
            let centerAttributedText = chart.centerAttributedText
            else { return }
        
        if chart.isDrawCenterTextEnabled && centerAttributedText.length > 0 {
            let center = chart.centerCircleBox
            let offset = chart.centerTextOffset
            let innerRadius = chart.isDrawHoleEnabled && !chart.isDrawSlicesUnderHoleEnabled ? chart.radius * chart.holeRadiusPercent : chart.radius
            
            let x = center.x + offset.x
            let y = center.y + offset.y
            
            let holeRect = CGRect(
                x: x - innerRadius,
                y: y - innerRadius,
                width: innerRadius * 2.0,
                height: innerRadius * 2.0)
            var boundingRect = holeRect
            
            if chart.centerTextRadiusPercent > 0.0 {
                boundingRect = boundingRect.insetBy(dx: (boundingRect.width - boundingRect.width * chart.centerTextRadiusPercent) / 2.0, dy: (boundingRect.height - boundingRect.height * chart.centerTextRadiusPercent) / 2.0)
            }
            
            let textBounds = centerAttributedText.boundingRect(with: boundingRect.size, options: [.usesLineFragmentOrigin, .usesFontLeading, .truncatesLastVisibleLine], context: nil)
            
            var drawingRect = boundingRect
            drawingRect.origin.x += (boundingRect.size.width - textBounds.size.width) / 2.0
            drawingRect.origin.y += (boundingRect.size.height - textBounds.size.height) / 2.0
            drawingRect.size = textBounds.size
            
            context.saveGState()
            
            let clippingPath = CGPath(ellipseIn: holeRect, transform: nil)
            context.beginPath()
            context.addPath(clippingPath)
            context.clip()
            
            centerAttributedText.draw(with: drawingRect, options: [.usesLineFragmentOrigin, .usesFontLeading, .truncatesLastVisibleLine], context: nil)
            
            context.restoreGState()
        }
    }
    
    func drawHighlighted(context: CGContext, indices: [Highlight]) {
        guard
            let chart = chart,
            let data = chart.data,
            let animator = animator
            else { return }
        
        context.saveGState()
        
        let phaseX = animator.phaseX
        let phaseY = animator.phaseY
        
        var angle: CGFloat = 0.0
        let rotationAngle = chart.rotationAngle
        
        var drawAngles = chart.drawAngles
        var absoluteAngles = chart.absoluteAngles
        let center = chart.centerCircleBox
        let radius = chart.radius
        let drawInnerArc = chart.isDrawHoleEnabled && !chart.isDrawSlicesUnderHoleEnabled
        let userInnerRadius = drawInnerArc ? radius * chart.holeRadiusPercent : 0.0
        
        for i in 0 ..< indices.count {
            // get the index to highlight
            let index = Int(indices[i].x)
            if index >= drawAngles.count {
                continue
            }
            
            guard let set = data.getDataSetByIndex(indices[i].dataSetIndex) as? PieChartDataSet else { continue }
            
            if !set.isHighlightEnabled {
                continue
            }
            
            let entryCount = set.count
            var visibleAngleCount = 0
            for j in 0 ..< entryCount {
                let e = set[j]
                if ((abs(e.y) > Double.ulpOfOne)) {
                    visibleAngleCount += 1
                }
            }
            
            if index == 0 {
                angle = 0.0
            }
            else {
                angle = absoluteAngles[index - 1] * CGFloat(phaseX)
            }
            
            let sliceSpace = visibleAngleCount <= 1 ? 0.0 : set.sliceSpace
            
            let sliceAngle = drawAngles[index]
            var innerRadius = userInnerRadius
            
            let shift = set.selectionShift
            let highlightedRadius = radius + shift
            
            let accountForSliceSpacing = sliceSpace > 0.0 && sliceAngle <= 180.0
            
            context.setFillColor(set.color(atIndex: index).cgColor)
            
            let sliceSpaceAngleOuter = visibleAngleCount == 1 ?
                0.0 :
                sliceSpace / radius.deg2rad()
            
            let sliceSpaceAngleShifted = visibleAngleCount == 1 ?
                0.0 :
                sliceSpace / highlightedRadius.deg2rad()
            
            let startAngleOuter = rotationAngle + (angle + sliceSpaceAngleOuter / 2.0) * CGFloat(phaseY)
            var sweepAngleOuter = (sliceAngle - sliceSpaceAngleOuter) * CGFloat(phaseY)
            if sweepAngleOuter < 0.0 {
                sweepAngleOuter = 0.0
            }
            
            let startAngleShifted = rotationAngle + (angle + sliceSpaceAngleShifted / 2.0) * CGFloat(phaseY)
            var sweepAngleShifted = (sliceAngle - sliceSpaceAngleShifted) * CGFloat(phaseY)
            if sweepAngleShifted < 0.0 {
                sweepAngleShifted = 0.0
            }
            
            let path = CGMutablePath()
            
            path.move(to: CGPoint(x: center.x + highlightedRadius * cos(startAngleShifted.deg2rad()),
                                  y: center.y + highlightedRadius * sin(startAngleShifted.deg2rad())))
            
            path.addRelativeArc(center: center, radius: highlightedRadius, startAngle: startAngleShifted.deg2rad(),
                                delta: sweepAngleShifted.deg2rad())
            
            var sliceSpaceRadius: CGFloat = 0.0
            if accountForSliceSpacing {
                sliceSpaceRadius = calculateMinimumRadiusForSpacedSlice(
                    center: center,
                    radius: radius,
                    angle: sliceAngle * CGFloat(phaseY),
                    arcStartPointX: center.x + radius * cos(startAngleOuter.deg2rad()),
                    arcStartPointY: center.y + radius * sin(startAngleOuter.deg2rad()),
                    startAngle: startAngleOuter,
                    sweepAngle: sweepAngleOuter)
            }
            
            if drawInnerArc &&
                (innerRadius > 0.0 || accountForSliceSpacing) {
                if accountForSliceSpacing {
                    var minSpacedRadius = sliceSpaceRadius
                    if minSpacedRadius < 0.0 {
                        minSpacedRadius = -minSpacedRadius
                    }
                    innerRadius = min(max(innerRadius, minSpacedRadius), radius)
                }
                
                let sliceSpaceAngleInner = visibleAngleCount == 1 || innerRadius == 0.0 ?
                    0.0 :
                    sliceSpace / innerRadius.deg2rad()
                let startAngleInner = rotationAngle + (angle + sliceSpaceAngleInner / 2.0) * CGFloat(phaseY)
                var sweepAngleInner = (sliceAngle - sliceSpaceAngleInner) * CGFloat(phaseY)
                if sweepAngleInner < 0.0 {
                    sweepAngleInner = 0.0
                }
                let endAngleInner = startAngleInner + sweepAngleInner
                
                path.addLine(
                    to: CGPoint(x: center.x + innerRadius * cos(endAngleInner.deg2rad()),
                                y: center.y + innerRadius * sin(endAngleInner.deg2rad())))
                
                path.addRelativeArc(center: center, radius: innerRadius,
                                    startAngle: endAngleInner.deg2rad(),
                                    delta: -sweepAngleInner.deg2rad())
            }
            else {
                if accountForSliceSpacing {
                    let angleMiddle = startAngleOuter + sweepAngleOuter / 2.0
                    
                    let arcEndPointX = center.x + sliceSpaceRadius * cos(angleMiddle.deg2rad())
                    let arcEndPointY = center.y + sliceSpaceRadius * sin(angleMiddle.deg2rad())
                    
                    path.addLine(
                        to: CGPoint(
                            x: arcEndPointX,
                            y: arcEndPointY))
                }
                else {
                    path.addLine(to: center)
                }
            }
            
            path.closeSubpath()
            
            context.beginPath()
            context.addPath(path)
            context.fillPath(using: .evenOdd)
        }
        
        context.restoreGState()
    }
}

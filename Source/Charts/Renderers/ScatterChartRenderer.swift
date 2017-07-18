//
//  ScatterChartRenderer.swift
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

final class ScatterChartRenderer: LineScatterCandleRadarRenderer {
    var _xBounds: XBounds = XBounds()
    
    var viewPortHandler: ViewPortHandler
    
    var animator: Animator?
    
    weak var dataProvider: ScatterChartDataProvider?
    
    init(dataProvider: ScatterChartDataProvider?, animator: Animator?, viewPortHandler: ViewPortHandler) {
        self.animator = animator
        self.viewPortHandler = viewPortHandler
        
        self.dataProvider = dataProvider
    }
    
    func initBuffers() { }
    
    func drawData(context: CGContext) {
        guard let scatterData = dataProvider?.scatterData else { return }
        
        for set in scatterData.dataSets as! [ScatterChartDataSet] {
            if set.isVisible {
                drawDataSet(context: context, dataSet: set)
            }
        }
    }
    
    private var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    
    func drawDataSet(context: CGContext, dataSet: ScatterChartDataSet) {
        guard
            let dataProvider = dataProvider,
            let animator = animator
            else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        
        let entryCount = dataSet.count
        
        var point = CGPoint()
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        if let renderer = dataSet.shapeRenderer {
            context.saveGState()
            
            for j in 0 ..< Int(min(ceil(Double(entryCount) * animator.phaseX), Double(entryCount))) {
                let e = dataSet[j]
                
                point.x = CGFloat(e.x)
                point.y = CGFloat(e.y * phaseY)
                point = point.applying(valueToPixelMatrix)
                
                if !viewPortHandler.isInBoundsRight(point.x) {
                    break
                }
                
                if !viewPortHandler.isInBoundsLeft(point.x) ||
                    !viewPortHandler.isInBoundsY(point.y) {
                    continue
                }
                
                renderer.renderShape(context: context, dataSet: dataSet, point: point, color: dataSet.color(atIndex: j))
            }
            
            context.restoreGState()
        }
        else {
            print("There's no IShapeRenderer specified for ScatterDataSet", terminator: "\n")
        }
    }
    
    func drawValues(context: CGContext) {
        guard
            let dataProvider = dataProvider,
            let scatterData = dataProvider.scatterData,
            let animator = animator
            else { return }
        
        // if values are drawn
        if isDrawingValuesAllowed(dataProvider: dataProvider) {
            guard let dataSets = scatterData.dataSets as? [ScatterChartDataSet] else { return }
            
            let phaseY = animator.phaseY
            
            var pt = CGPoint()
            
            for i in 0 ..< scatterData.dataSetCount {
                let dataSet = dataSets[i]
                
                if !shouldDrawValues(forDataSet: dataSet) {
                    continue
                }
                
                let valueFont = dataSet.valueFont
                
                guard let formatter = dataSet.valueFormatter else { continue }
                
                let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
                let valueToPixelMatrix = trans.valueToPixelMatrix
                
                let iconsOffset = dataSet.iconsOffset
                
                let shapeSize = dataSet.scatterShapeSize
                let lineHeight = valueFont.lineHeight
                
                _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
                
                for j in stride(from: _xBounds.min, through: _xBounds.range + _xBounds.min, by: 1) {
                    let e = dataSet[j]
                    
                    pt.x = CGFloat(e.x)
                    pt.y = CGFloat(e.y * phaseY)
                    pt = pt.applying(valueToPixelMatrix)
                    
                    if (!viewPortHandler.isInBoundsRight(pt.x)) {
                        break
                    }
                    
                    // make sure the lines don't do shitty things outside bounds
                    if (!viewPortHandler.isInBoundsLeft(pt.x)
                        || !viewPortHandler.isInBoundsY(pt.y)) {
                        continue
                    }
                    
                    let text = formatter.stringForValue(
                        e.y,
                        entry: e,
                        dataSetIndex: i,
                        viewPortHandler: viewPortHandler)
                    
                    if dataSet.isDrawValuesEnabled {
                        ChartUtils.drawText(
                            context: context,
                            text: text,
                            point: CGPoint(
                                x: pt.x,
                                y: pt.y - shapeSize - lineHeight),
                            align: .center,
                            attributes: [.font: valueFont, .foregroundColor: dataSet.valueTextColorAt(j)]
                        )
                    }
                    
                    if let icon = e.icon, dataSet.isDrawIconsEnabled {
                        ChartUtils.drawImage(context: context,
                                             image: icon,
                                             x: pt.x + iconsOffset.x,
                                             y: pt.y + iconsOffset.y,
                                             size: icon.size)
                    }
                }
            }
        }
    }
    
    func drawExtras(context: CGContext) { }
    
    func drawHighlighted(context: CGContext, indices: [Highlight]) {
        guard
            let dataProvider = dataProvider,
            let scatterData = dataProvider.scatterData,
            let animator = animator
            else { return }
        
        context.saveGState()
        
        for high in indices {
            guard
                let set = scatterData.getDataSetByIndex(high.dataSetIndex) as? ScatterChartDataSet,
                set.isHighlightEnabled
                else { continue }
            
            guard let entry = set.entryForXValue(high.x, closestToY: high.y) else { continue }
            
            if !isInBoundsX(entry: entry, dataSet: set) { continue }
            
            context.setStrokeColor(set.highlightColor.cgColor)
            context.setLineWidth(set.highlightLineWidth)
            if set.highlightLineDashLengths != nil {
                context.setLineDash(phase: set.highlightLineDashPhase, lengths: set.highlightLineDashLengths!)
            }
            else {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            let x = entry.x // get the x-position
            let y = entry.y * Double(animator.phaseY)
            
            let trans = dataProvider.getTransformer(forAxis: set.axisDependency)
            
            let pt = trans.pixelForValues(x: x, y: y)
            
            high.setDraw(pt: pt)
            
            // draw the lines
            drawHighlightLines(context: context, point: pt, set: set)
        }
        
        context.restoreGState()
    }
}

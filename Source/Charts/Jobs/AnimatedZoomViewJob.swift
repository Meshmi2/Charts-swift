//
//  AnimatedZoomViewJob.swift
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

public class AnimatedZoomViewJob: AnimatedViewPortJob {
    var yAxis: YAxis?
    var xAxisRange: Double = 0.0
    var scaleX: CGFloat = 0.0
    var scaleY: CGFloat = 0.0
    var zoomOriginX: CGFloat = 0.0
    var zoomOriginY: CGFloat = 0.0
    var zoomCenterX: CGFloat = 0.0
    var zoomCenterY: CGFloat = 0.0

    public init(
        viewPortHandler: ViewPortHandler,
        transformer: Transformer,
        view: ChartViewBase,
        yAxis: YAxis,
        xAxisRange: Double,
        scaleX: CGFloat,
        scaleY: CGFloat,
        xOrigin: CGFloat,
        yOrigin: CGFloat,
        zoomCenterX: CGFloat,
        zoomCenterY: CGFloat,
        zoomOriginX: CGFloat,
        zoomOriginY: CGFloat,
        duration: TimeInterval,
        easingOption: ChartEasingOption) {
        super.init(viewPortHandler: viewPortHandler,
            xValue: 0.0,
            yValue: 0.0,
            transformer: transformer,
            view: view,
            xOrigin: xOrigin,
            yOrigin: yOrigin,
            duration: duration,
            easingOption: easingOption)
        
        self.yAxis = yAxis
        self.xAxisRange = xAxisRange
        self.scaleX = scaleX
        self.scaleY = scaleY
        self.zoomCenterX = zoomCenterX
        self.zoomCenterY = zoomCenterY
        self.zoomOriginX = zoomOriginX
        self.zoomOriginY = zoomOriginY
    }
    
    override func animationUpdate() {
        guard
            let viewPortHandler = viewPortHandler,
            let transformer = transformer,
            let view = view
            else { return }
        
        let scaleX = xOrigin + (self.scaleX - xOrigin) * phase
        let scaleY = yOrigin + (self.scaleY - yOrigin) * phase
        
        var matrix = viewPortHandler.setZoom(scaleX: scaleX, scaleY: scaleY)
        let _ = viewPortHandler.refresh(newMatrix: matrix, chart: view, invalidate: false)
        
        let valsInView = CGFloat(yAxis?.axisRange ?? 0.0) / viewPortHandler.scaleY
        let xsInView = CGFloat(xAxisRange) / viewPortHandler.scaleX
        
        var pt = CGPoint(
            x: zoomOriginX + ((zoomCenterX - xsInView / 2.0) - zoomOriginX) * phase,
            y: zoomOriginY + ((zoomCenterY + valsInView / 2.0) - zoomOriginY) * phase
        )
        
        transformer.pointValueToPixel(&pt)
        
        matrix = viewPortHandler.translate(pt: pt)
        let _ = viewPortHandler.refresh(newMatrix: matrix, chart: view, invalidate: true)
    }
    
    override func animationEnd() {
        (view as? BarLineChartViewBase)?.calculateOffsets()
        view?.setNeedsDisplay()
    }
}

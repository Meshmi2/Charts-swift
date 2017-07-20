//
//  ViewPortJob.swift
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

// This defines a viewport modification job, used for delaying or animating viewport changes
public class ViewPortJob {
    var point: CGPoint = .zero
    weak var viewPortHandler: ViewPortHandler?
    var xValue: Double = 0.0
    var yValue: Double = 0.0
    weak var transformer: Transformer?
    weak var view: ChartViewBase?
    
    init(viewPortHandler: ViewPortHandler,
         xValue: Double,
         yValue: Double,
         transformer: Transformer,
         view: ChartViewBase) {        
        self.viewPortHandler = viewPortHandler
        self.xValue = xValue
        self.yValue = yValue
        self.transformer = transformer
        self.view = view
    }
    
    public func doJob() {
        // Override this
    }
}

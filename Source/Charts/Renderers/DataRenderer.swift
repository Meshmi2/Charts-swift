//
//  DataRenderer.swift
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

protocol DataRenderer: Renderer {
    var viewPortHandler: ViewPortHandler { get }
    
    var animator: Animator? { get set }
    
//    init(animator: Animator?, viewPortHandler: ViewPortHandler)
//    {
//        self.viewPortHandler = viewPortHandler
//        self.animator = animator
//    }

    func drawData(context: CGContext)
    
    func drawValues(context: CGContext)

    func drawExtras(context: CGContext)
    
    /// Draws all highlight indicators for the values that are currently highlighted.
    ///
    /// - parameter indices: the highlighted values
    func drawHighlighted(context: CGContext, indices: [Highlight])
    
    /// An opportunity for initializing internal buffers used for rendering with a new size.
    /// Since this might do memory allocations, it should only be called if necessary.
    func initBuffers()
    
}
extension DataRenderer {
    func isDrawingValuesAllowed(dataProvider: ChartDataProvider?) -> Bool {
        guard let data = dataProvider?.data
            else { return false }
        
        return data.entryCount < Int(CGFloat(dataProvider?.maxVisibleCount ?? 0) * viewPortHandler.scaleX)
    }
}

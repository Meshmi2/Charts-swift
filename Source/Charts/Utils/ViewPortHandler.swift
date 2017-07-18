//
//  ViewPortHandler.swift
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

/// Class that contains information about the charts current viewport settings, including offsets, scale & translation levels, ...
public class ViewPortHandler {
    /// matrix used for touch events
    private(set) var touchMatrix: CGAffineTransform = .identity
    
    /// this rectangle defines the area in which graph values can be drawn
    private(set) var contentRect = CGRect()
    
    private(set) var chartWidth: CGFloat = 0
    private(set) var chartHeight: CGFloat = 0
    
    /// minimum scale value on the y-axis
    private(set) var minScaleY: CGFloat = 1
    
    /// maximum scale value on the y-axis
    private(set) var maxScaleY: CGFloat = .greatestFiniteMagnitude
    
    /// minimum scale value on the x-axis
    private(set) var minScaleX: CGFloat = 1
    
    /// maximum scale value on the x-axis
    private(set) var maxScaleX: CGFloat = .greatestFiniteMagnitude
    
    /// contains the current scale factor of the x-axis
    private(set) var scaleX: CGFloat = 1
    
    /// contains the current scale factor of the y-axis
    private(set) var scaleY: CGFloat = 1
    
    /// current translation (drag distance) on the x-axis
    private(set) var transX: CGFloat = 0
    
    /// current translation (drag distance) on the y-axis
    private(set) var transY: CGFloat = 0
    
    /// offset that allows the chart to be dragged over its bounds on the x-axis
    private(set) var transOffsetX: CGFloat = 0
    
    /// offset that allows the chart to be dragged over its bounds on the x-axis
    private(set) var transOffsetY: CGFloat = 0
    
    // TODO: Do we need this?
    public init() {}
    
    /// Constructor - don't forget calling setChartDimens(...)
    public init(width: CGFloat, height: CGFloat) {
        setChartDimens(width: width, height: height)
    }
    
    public func setChartDimens(width: CGFloat, height: CGFloat) {
        let offsetLeft = self.offsetLeft
        let offsetTop = self.offsetTop
        let offsetRight = self.offsetRight
        let offsetBottom = self.offsetBottom
        
        chartHeight = height
        chartWidth = width
        
        restrainViewPort(offsetLeft: offsetLeft, offsetTop: offsetTop, offsetRight: offsetRight, offsetBottom: offsetBottom)
    }
    
    public var hasChartDimens: Bool {
        if chartHeight > 0.0 && chartWidth > 0.0 {
            return true
        }
        else {
            return false
        }
    }

    public func restrainViewPort(offsetLeft: CGFloat, offsetTop: CGFloat, offsetRight: CGFloat, offsetBottom: CGFloat) {
        contentRect.origin.x = offsetLeft
        contentRect.origin.y = offsetTop
        contentRect.size.width = chartWidth - offsetLeft - offsetRight
        contentRect.size.height = chartHeight - offsetBottom - offsetTop
    }
    
    public var offsetLeft: CGFloat {
        return contentRect.origin.x
    }
    
    public var offsetRight: CGFloat {
        return chartWidth - contentRect.size.width - contentRect.origin.x
    }
    
    public var offsetTop: CGFloat {
        return contentRect.origin.y
    }
    
    public var offsetBottom: CGFloat {
        return chartHeight - contentRect.size.height - contentRect.origin.y
    }
    
    public var contentTop: CGFloat {
        return contentRect.origin.y
    }
    
    public var contentLeft: CGFloat {
        return contentRect.origin.x
    }
    
    public var contentRight: CGFloat {
        return contentRect.origin.x + contentRect.size.width
    }
    
    public var contentBottom: CGFloat {
        return contentRect.origin.y + contentRect.size.height
    }
    
    public var contentWidth: CGFloat {
        return contentRect.size.width
    }
    
    public var contentHeight: CGFloat {
        return contentRect.size.height
    }
    
    public var contentCenter: CGPoint {
        return CGPoint(x: contentRect.origin.x + contentRect.size.width / 2.0, y: contentRect.origin.y + contentRect.size.height / 2.0)
    }

    // MARK: - Scaling/Panning etc.
    
    /// Zooms by the specified zoom factors.
    public func zoom(scaleX: CGFloat, scaleY: CGFloat) -> CGAffineTransform {
        return touchMatrix.scaledBy(x: scaleX, y: scaleY)
    }
    
    /// Zooms around the specified center
    public func zoom(scaleX: CGFloat, scaleY: CGFloat, x: CGFloat, y: CGFloat) -> CGAffineTransform {
        let matrix = touchMatrix.translatedBy(x: x, y: y)
            .scaledBy(x: scaleX, y: scaleY)
            .translatedBy(x: -x, y: -y)
        return matrix
    }
    
    /// Zooms in by 1.4, x and y are the coordinates (in pixels) of the zoom center.
    public func zoomIn(x: CGFloat, y: CGFloat) -> CGAffineTransform {
        return zoom(scaleX: 1.4, scaleY: 1.4, x: x, y: y)
    }
    
    /// Zooms out by 0.7, x and y are the coordinates (in pixels) of the zoom center.
    public func zoomOut(x: CGFloat, y: CGFloat) -> CGAffineTransform {
        return zoom(scaleX: 0.7, scaleY: 0.7, x: x, y: y)
    }
    
    /// Zooms out to original size.
    public func resetZoom() -> CGAffineTransform {
        return zoom(scaleX: 1.0, scaleY: 1.0, x: 0.0, y: 0.0)
    }
    
    /// Sets the scale factor to the specified values.
    public func setZoom(scaleX: CGFloat, scaleY: CGFloat) -> CGAffineTransform {
        var matrix = touchMatrix
        matrix.a = scaleX
        matrix.d = scaleY
        return matrix
    }
    
    /// Sets the scale factor to the specified values. x and y is pivot.
    public func setZoom(scaleX: CGFloat, scaleY: CGFloat, x: CGFloat, y: CGFloat) -> CGAffineTransform {
        var matrix = touchMatrix
        matrix.a = 1.0
        matrix.d = 1.0
        matrix = matrix.translatedBy(x: x, y: y)
            .scaledBy(x: scaleX, y: scaleY)
            .translatedBy(x: -x, y: -y)
        return matrix
    }
    
    /// Resets all zooming and dragging and makes the chart fit exactly it's bounds.
    public func fitScreen() -> CGAffineTransform {
        minScaleX = 1.0
        minScaleY = 1.0

        return .identity
    }
    
    /// Translates to the specified point.
    public func translate(pt: CGPoint) -> CGAffineTransform {
        let translateX = pt.x - offsetLeft
        let translateY = pt.y - offsetTop
        
        let matrix = touchMatrix.concatenating(CGAffineTransform(translationX: -translateX, y: -translateY))
        
        return matrix
    }
    
    /// Centers the viewport around the specified position (x-index and y-value) in the chart.
    /// Centering the viewport outside the bounds of the chart is not possible.
    /// Makes most sense in combination with the setScaleMinima(...) method.
    public func centerViewPort(pt: CGPoint, chart: ChartViewBase) {
        let translateX = pt.x - offsetLeft
        let translateY = pt.y - offsetTop
        
        let matrix = touchMatrix.concatenating(CGAffineTransform(translationX: -translateX, y: -translateY))
        
        let _ = refresh(newMatrix: matrix, chart: chart, invalidate: true)
    }
    
    /// call this method to refresh the graph with a given matrix
    public func refresh(newMatrix: CGAffineTransform, chart: ChartViewBase, invalidate: Bool) -> CGAffineTransform {
        touchMatrix = newMatrix
        
        // make sure scale and translation are within their bounds
        limitTransAndScale(matrix: &touchMatrix, content: contentRect)
        
        chart.setNeedsDisplay()
        
        return touchMatrix
    }
    
    /// limits the maximum scale and X translation of the given matrix
    private func limitTransAndScale(matrix: inout CGAffineTransform, content: CGRect?) {
        // min scale-x is 1
        scaleX = min(max(minScaleX, matrix.a), maxScaleX)
        
        // min scale-y is 1
        scaleY = min(max(minScaleY,  matrix.d), maxScaleY)
        
        
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        
        if content != nil {
            width = content!.width
            height = content!.height
        }
        
        let maxTransX = -width * (scaleX - 1.0)
        transX = min(max(matrix.tx, maxTransX - transOffsetX), transOffsetX)
        
        let maxTransY = height * (scaleY - 1.0)
        transY = max(min(matrix.ty, maxTransY + transOffsetY), -transOffsetY)
        
        matrix.tx = transX
        matrix.a = scaleX
        matrix.ty = transY
        matrix.d = scaleY
    }
    
    /// Sets the minimum scale factor for the x-axis
    public func setMinimumScaleX(_ xScale: CGFloat) {
        var newValue = xScale
        
        if newValue < 1.0 {
            newValue = 1.0
        }
        
        minScaleX = newValue
        
        limitTransAndScale(matrix: &touchMatrix, content: contentRect)
    }
    
    /// Sets the maximum scale factor for the x-axis
    public func setMaximumScaleX(_ xScale: CGFloat) {
        var newValue = xScale
        
        if newValue == 0.0 {
            newValue = CGFloat.greatestFiniteMagnitude
        }
        
        maxScaleX = newValue
        
        limitTransAndScale(matrix: &touchMatrix, content: contentRect)
    }
    
    /// Sets the minimum and maximum scale factors for the x-axis
    public func setMinMaxScaleX(minScaleX: CGFloat, maxScaleX: CGFloat) {
        var newMin = minScaleX
        var newMax = minScaleY
        
        if newMin < 1.0 {
            newMin = 1.0
        }
        if newMax == 0.0 {
            newMax = .greatestFiniteMagnitude
        }
        
        self.minScaleX = newMin
        self.maxScaleX = maxScaleX
        
        limitTransAndScale(matrix: &touchMatrix, content: contentRect)
    }
    
    /// Sets the minimum scale factor for the y-axis
    public func setMinimumScaleY(_ yScale: CGFloat) {
        var newValue = yScale
        
        if newValue < 1.0 {
            newValue = 1.0
        }
        
        minScaleY = newValue
        
        limitTransAndScale(matrix: &touchMatrix, content: contentRect)
    }
    
    /// Sets the maximum scale factor for the y-axis
    public func setMaximumScaleY(_ yScale: CGFloat) {
        var newValue = yScale
        
        if newValue == 0.0 {
            newValue = .greatestFiniteMagnitude
        }
        
        maxScaleY = newValue
        
        limitTransAndScale(matrix: &touchMatrix, content: contentRect)
    }
    
    public func setMinMaxScaleY(minScaleY: CGFloat, maxScaleY: CGFloat) {
        var minScaleY = minScaleY, maxScaleY = maxScaleY
        
        if minScaleY < 1.0 {
            minScaleY = 1.0
        }
        
        if maxScaleY == 0.0 {
            maxScaleY = .greatestFiniteMagnitude
        }
        
        self.minScaleY = minScaleY
        self.maxScaleY = maxScaleY
        
        limitTransAndScale(matrix: &touchMatrix, content: contentRect)
    }
    
    // MARK: - Boundaries Check
    
    public func isInBoundsX(_ x: CGFloat) -> Bool {
        return isInBoundsLeft(x) && isInBoundsRight(x)
    }
    
    public func isInBoundsY(_ y: CGFloat) -> Bool {
        return isInBoundsTop(y) && isInBoundsBottom(y)
    }
    
    public func isInBounds(x: CGFloat, y: CGFloat) -> Bool {
        return isInBoundsX(x) && isInBoundsY(y)
    }
    
    public func isInBoundsLeft(_ x: CGFloat) -> Bool {
        return contentRect.origin.x <= x + 1.0
    }
    
    public func isInBoundsRight(_ x: CGFloat) -> Bool {
        let x = floor(x * 100.0) / 100.0
        return (contentRect.origin.x + contentRect.size.width) >= x - 1.0
    }
    
    public func isInBoundsTop(_ y: CGFloat) -> Bool {
        return contentRect.origin.y <= y
    }
    
    public func isInBoundsBottom(_ y: CGFloat) -> Bool {
        let normalizedY = floor(y * 100.0) / 100.0
        return (contentRect.origin.y + contentRect.size.height) >= normalizedY
    }
    
    /// if the chart is fully zoomed out, return true
    public var isFullyZoomedOut: Bool {
        return isFullyZoomedOutX && isFullyZoomedOutY
    }
    
    /// - returns: `true` if the chart is fully zoomed out on it's y-axis (vertical).
    public var isFullyZoomedOutY: Bool {
        return !(scaleY > minScaleY || minScaleY > 1.0)
    }
    
    /// - returns: `true` if the chart is fully zoomed out on it's x-axis (horizontal).
    public var isFullyZoomedOutX: Bool {
        return !(scaleX > minScaleX || minScaleX > 1.0)
    }
    
    /// Set an offset in pixels that allows the user to drag the chart over it's bounds on the x-axis.
    public func setDragOffsetX(_ offset: CGFloat) {
        transOffsetX = offset
    }
    
    /// Set an offset in pixels that allows the user to drag the chart over it's bounds on the y-axis.
    public func setDragOffsetY(_ offset: CGFloat) {
        transOffsetY = offset
    }
    
    /// - returns: `true` if both drag offsets (x and y) are zero or smaller.
    public var hasNoDragOffset: Bool {
        return transOffsetX <= 0.0 && transOffsetY <= 0.0
    }
    
    /// - returns: `true` if the chart is not yet fully zoomed out on the x-axis
    public var canZoomOutMoreX: Bool {
        return scaleX > minScaleX
    }
    
    /// - returns: `true` if the chart is not yet fully zoomed in on the x-axis
    public var canZoomInMoreX: Bool {
        return scaleX < maxScaleX
    }
    
    /// - returns: `true` if the chart is not yet fully zoomed out on the y-axis
    public var canZoomOutMoreY: Bool {
        return scaleY > minScaleY
    }
    
    /// - returns: `true` if the chart is not yet fully zoomed in on the y-axis
    public var canZoomInMoreY: Bool {
        return scaleY < maxScaleY
    }
}

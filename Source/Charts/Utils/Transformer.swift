//
//  Transformer.swift
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

/// Transformer class that contains all matrices and is responsible for transforming values into pixels on the screen and backwards.
public class Transformer {
    /// matrix to map the values to the screen pixels
    var _matrixValueToPx: CGAffineTransform = .identity

    /// matrix for handling the different offsets of the chart
    var _matrixOffset: CGAffineTransform = .identity

    let _viewPortHandler: ViewPortHandler

    init(viewPortHandler: ViewPortHandler) {
        _viewPortHandler = viewPortHandler
    }

    /// Prepares the matrix that transforms values to pixels. Calculates the scale factors from the charts size and offsets.
    public func prepareMatrixValuePx(chartXMin: Double, deltaX: CGFloat, deltaY: CGFloat, chartYMin: Double) {
        var scaleX = (_viewPortHandler.contentWidth / deltaX)
        var scaleY = (_viewPortHandler.contentHeight / deltaY)
        
        if .infinity ~= scaleX {
            scaleX = 0.0
        }
        if .infinity ~= scaleY {
            scaleY = 0.0
        }

        // setup all matrices
        _matrixValueToPx = CGAffineTransform.identity
            .scaledBy(x: scaleX, y: -scaleY)
            .translatedBy(x: CGFloat(-chartXMin), y: CGFloat(-chartYMin))
    }

    /// Prepares the matrix that contains all offsets.
    public func prepareMatrixOffset(inverted: Bool) {
        if !inverted {
            _matrixOffset = CGAffineTransform(translationX: _viewPortHandler.offsetLeft, y: _viewPortHandler.chartHeight - _viewPortHandler.offsetBottom)
        }
        else {
            _matrixOffset = CGAffineTransform(scaleX: 1.0, y: -1.0)
                .translatedBy(x: _viewPortHandler.offsetLeft, y: -_viewPortHandler.offsetTop)
        }
    }

    /// Transform an array of points with all matrices.
    // VERY IMPORTANT: Keep matrix order "value-touch-offset" when transforming.
    public func pointValuesToPixel(_ points: inout [CGPoint]) {
        let trans = valueToPixelMatrix
        for i in 0 ..< points.count {
            points[i] = points[i].applying(trans)
        }
    }
    
    public func pointValueToPixel(_ point: inout CGPoint) {
        point = point.applying(valueToPixelMatrix)
    }
    
    public func pixelForValues(x: Double, y: Double) -> CGPoint {
        return CGPoint(x: x, y: y).applying(valueToPixelMatrix)
    }
    
    /// Transform a rectangle with all matrices.
    public func rectValueToPixel(_ r: inout CGRect) {
        r = r.applying(valueToPixelMatrix)
    }
    
    /// Transform a rectangle with all matrices with potential animation phases.
    public func rectValueToPixel(_ r: inout CGRect, phaseY: Double) {
        // multiply the height of the rect with the phase
        let bottom = (r.origin.y + r.size.height)
            * CGFloat(phaseY)
        let top = r.origin.y * CGFloat(phaseY)
        r.size.height = bottom - top
        r.origin.y = top

        r = r.applying(valueToPixelMatrix)
    }
    
    /// Transform a rectangle with all matrices.
    public func rectValueToPixelHorizontal(_ r: inout CGRect) {
        r = r.applying(valueToPixelMatrix)
    }
    
    /// Transform a rectangle with all matrices with potential animation phases.
    public func rectValueToPixelHorizontal(_ r: inout CGRect, phaseY: Double) {
        // multiply the height of the rect with the phase
        let left = r.origin.x * CGFloat(phaseY)
        let right = (r.origin.x + r.size.width) * CGFloat(phaseY)
        r.size.width = right - left
        r.origin.x = left
        
        r = r.applying(valueToPixelMatrix)
    }

    /// transforms multiple rects with all matrices
    public func rectValuesToPixel(_ rects: inout [CGRect]) {
        let trans = valueToPixelMatrix
        
        for i in 0 ..< rects.count {
            rects[i] = rects[i].applying(trans)
        }
    }
    
    /// Transforms the given array of touch points (pixels) into values on the chart.
    public func pixelsToValues(_ pixels: inout [CGPoint]) {
        let trans = pixelToValueMatrix
        
        for i in 0 ..< pixels.count {
            pixels[i] = pixels[i].applying(trans)
        }
    }
    
    /// Transforms the given touch point (pixels) into a value on the chart.
    public func pixelToValues(_ pixel: inout CGPoint) {
        pixel = pixel.applying(pixelToValueMatrix)
    }
    
    /// - returns: The x and y values in the chart at the given touch point
    /// (encapsulated in a CGPoint). This method transforms pixel coordinates to
    /// coordinates / values in the chart.
    public func valueForTouchPoint(_ point: CGPoint) -> CGPoint {
        return point.applying(pixelToValueMatrix)
    }
    
    /// - returns: The x and y values in the chart at the given touch point
    /// (x/y). This method transforms pixel coordinates to
    /// coordinates / values in the chart.
    public func valueForTouchPoint(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: y).applying(pixelToValueMatrix)
    }
    
    public var valueToPixelMatrix: CGAffineTransform {
        return
            _matrixValueToPx.concatenating(_viewPortHandler.touchMatrix)
                .concatenating(_matrixOffset)
    }
    
    public var pixelToValueMatrix: CGAffineTransform {
        return valueToPixelMatrix.inverted()
    }
}

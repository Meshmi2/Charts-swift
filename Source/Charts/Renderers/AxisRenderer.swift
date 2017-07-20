//
//  AxisRenderer.swift
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

protocol AxisRenderer: Renderer {
    associatedtype Axis: AxisBase
    /// base axis this axis renderer works with
    var axis: Axis { get set }
    
    /// transformer to transform values to screen pixels and return
    var transformer: Transformer? { get set }

    /// Draws the axis labels on the specified context
    func renderAxisLabels(context: CGContext)
    
    /// Draws the grid lines belonging to the axis.
    func renderGridLines(context: CGContext)
    
    /// Draws the line that goes alongside the axis.
    func renderAxisLine(context: CGContext)
    
    /// Draws the LimitLines associated with this axis to the screen.
    func renderLimitLines(context: CGContext)
    
    /// Sets up the axis values. Computes the desired number of labels between the two given extremes.
    func computeAxisValues(min: Double, max: Double)
}

extension AxisRenderer {
    /// Computes the axis values.
    /// - parameter min: the minimum value in the data object for this axis
    /// - parameter max: the maximum value in the data object for this axis
    func computeAxis(min: Double, max: Double, inverted: Bool) {
        var min = min, max = max
        
        if let transformer = self.transformer {
            // calculate the starting and entry point of the y-labels (depending on zoom / contentrect bounds)
            if viewPortHandler.contentWidth > 10.0 && !viewPortHandler.isFullyZoomedOutY {
                let p1 = transformer.valueForTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
                let p2 = transformer.valueForTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom))
                
                if !inverted {
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
    
    /// Sets up the axis values. Computes the desired number of labels between the two given extremes.
    func computeAxisValues(min: Double, max: Double) {
        let yMin = min
        let yMax = max
        
        let labelCount = axis.labelCount
        let range = abs(yMax - yMin)
        
        if labelCount == 0 || range <= 0 || range.isInfinite {
            axis.entries = [Double]()
            axis.centeredEntries = [Double]()
            return
        }
        
        // Find out how much spacing (in y value space) between axis values
        let rawInterval = range / Double(labelCount)
        var interval = ChartUtils.roundToNextSignificant(number: Double(rawInterval))
        
        // If granularity is enabled, then do not allow the interval to go below specified granularity.
        // This is used to avoid repeated values when rounding values for display.
        if axis.isGranularityEnabled {
            interval = interval < axis.granularity ? axis.granularity : interval
        }
        
        // Normalize interval
        let intervalMagnitude = ChartUtils.roundToNextSignificant(number: pow(10.0, Double(Int(log10(interval)))))
        let intervalSigDigit = Int(interval / intervalMagnitude)
        if intervalSigDigit > 5 {
            // Use one order of magnitude higher, to avoid intervals like 0.9 or 90
            interval = floor(10.0 * Double(intervalMagnitude))
        }
        
        var n = axis.isCenterAxisLabelsEnabled ? 1 : 0
        
        // force label count
        if axis.isForceLabelsEnabled {
            interval = Double(range) / Double(labelCount - 1)
            
            // Ensure stops contains at least n elements.
            axis.entries.removeAll(keepingCapacity: true)
            axis.entries.reserveCapacity(labelCount)
            
            var v = yMin
            
            for _ in 0 ..< labelCount {
                axis.entries.append(v)
                v += interval
            }
            
            n = labelCount
        } else {
            // no forced count
        
            var first = interval == 0.0 ? 0.0 : ceil(yMin / interval) * interval
            
            if axis.isCenterAxisLabelsEnabled {
                first -= interval
            }
            
            let last = interval == 0.0 ? 0.0 : ChartUtils.nextUp(floor(yMax / interval) * interval)
            
            if interval != 0.0 && last != first {
                for _ in stride(from: first, through: last, by: interval) {
                    n += 1
                }
            }
            
            // Ensure stops contains at least n elements.
            axis.entries.removeAll(keepingCapacity: true)
            axis.entries.reserveCapacity(labelCount)
            
            var f = first
            var i = 0
            while i < n {
                if f == 0.0 {
                    // Fix for IEEE negative zero case (Where value == -0.0, and 0.0 == -0.0)
                    f = 0.0
                }
                
                axis.entries.append(Double(f))
                
                f += interval
                i += 1
            }
        }
        
        // set decimals
        if interval < 1 {
            axis.decimals = Int(ceil(-log10(interval)))
        }
        else {
            axis.decimals = 0
        }
        
        if axis.isCenterAxisLabelsEnabled {
            axis.centeredEntries.reserveCapacity(n)
            axis.centeredEntries.removeAll()
            
            let offset: Double = interval / 2.0
            
            for i in 0 ..< n {
                axis.centeredEntries.append(axis.entries[i] + offset)
            }
        }
    }
}
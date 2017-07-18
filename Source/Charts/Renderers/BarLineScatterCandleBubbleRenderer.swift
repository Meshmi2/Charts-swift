//
//  BarLineScatterCandleBubbleRenderer.swift
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

/// Class representing the bounds of the current viewport in terms of indices in the values array of a DataSet.
class XBounds {
    /// minimum visible entry index
    public var min: Int = 0
    
    /// maximum visible entry index
    public var max: Int = 0
    
    /// range of visible entry indices
        public var range: Int = 0
    
        public init() {
            
        }
    
        public init(chart: BarLineScatterCandleBubbleChartDataProvider,
                    dataSet: BarLineScatterCandleBubbleChartDataSet,
                    animator: Animator?) {
            self.set(chart: chart, dataSet: dataSet, animator: animator)
        }
    
        /// Calculates the minimum and maximum x values as well as the range between them.
        public func set(chart: BarLineScatterCandleBubbleChartDataProvider,
                      dataSet: BarLineScatterCandleBubbleChartDataSet,
                      animator: Animator?) {
            let phaseX = Swift.max(0.0, Swift.min(1.0, animator?.phaseX ?? 1.0))
            
            let low = chart.lowestVisibleX
            let high = chart.highestVisibleX
            
            let entryFrom = dataSet.entryForXValue(low, closestToY: Double.nan, rounding: .down)
            let entryTo = dataSet.entryForXValue(high, closestToY: Double.nan, rounding: .up)
            
            self.min = entryFrom == nil ? 0 : dataSet.entryIndex(entry: entryFrom!)
            self.max = entryTo == nil ? 0 : dataSet.entryIndex(entry: entryTo!)
            range = Int(Double(self.max - self.min) * phaseX)
        }
    }

protocol BarLineScatterCandleBubbleRenderer: DataRenderer {
    /// Reusable XBounds object
    var _xBounds: XBounds { get set }
}

extension BarLineScatterCandleBubbleRenderer {
    /// Checks if the provided entry object is in bounds for drawing considering the current animation phase.
    func isInBoundsX(entry e: ChartDataEntry, dataSet: BarLineScatterCandleBubbleChartDataSet) -> Bool {
        let entryIndex = dataSet.entryIndex(entry: e)
        
        if Double(entryIndex) >= Double(dataSet.count) * (animator?.phaseX ?? 1.0) {
            return false
        }
        else {
            return true
        }
    }
    
    /// Calculates and returns the x-bounds for the given DataSet in terms of index in their values array.
    /// This includes minimum and maximum visible x, as well as range.
    func xBounds(chart: BarLineScatterCandleBubbleChartDataProvider,
                          dataSet: BarLineScatterCandleBubbleChartDataSet,
                          animator: Animator?) -> XBounds {
        return XBounds(chart: chart, dataSet: dataSet, animator: animator)
    }
    
    /// - returns: `true` if the DataSet values should be drawn, `false` if not.
    func shouldDrawValues<T: IChartDataSet>(forDataSet set: T) -> Bool {
        return set.isVisible && (set.isDrawValuesEnabled || set.isDrawIconsEnabled)
    }
}

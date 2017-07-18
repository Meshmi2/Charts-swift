//
//  DefaultFillFormatter.swift
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

/// Default formatter that calculates the position of the filled line.
public struct DefaultFillFormatter: FillFormatter {
    public typealias Block = (
        _ dataSet: LineChartDataSet,
        _ dataProvider: LineChartDataProvider) -> CGFloat
    
    public var block: Block?
    
    public init() {}
    
    public init(block: @escaping Block) {
        self.block = block
    }
    
    public func getFillLinePosition(
        dataSet: LineChartDataSet,
        dataProvider: LineChartDataProvider) -> CGFloat {
        if block != nil {
            return block!(dataSet, dataProvider)
        }
        else {
            var fillMin = CGFloat(0.0)
            
            if dataSet.yMax > 0.0 && dataSet.yMin < 0.0 {
                fillMin = 0.0
            }
            else {
                if let data = dataProvider.data {
                    var max: Double, min: Double
                    
                    if data.yMax > 0.0 {
                        max = 0.0
                    }
                    else {
                        max = dataProvider.chartYMax
                    }
                    
                    if data.yMin < 0.0 {
                        min = 0.0
                    }
                    else {
                        min = dataProvider.chartYMin
                    }
                    
                    fillMin = CGFloat(dataSet.yMin >= 0.0 ? min : max)
                }
            }
            
            return fillMin
        }
    }
}

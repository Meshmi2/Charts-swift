//
//  ScatterChartData.swift
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

public class ScatterChartData: BarLineScatterCandleBubbleChartData {
    /// - returns: The maximum shape-size across all DataSets.
    public func getGreatestShapeSize() -> CGFloat {
        var max = CGFloat(0.0)
        
        for set in _dataSets {
            guard let scatterDataSet = set as? ScatterChartDataSet else {
                print("ScatterChartData: Found a DataSet which is not a ScatterChartDataSet", terminator: "\n")
                return max
            }
            let size = scatterDataSet.scatterShapeSize
            
            if size > max {
                max = size
            }
        }
        
        return max
    }
}

//
//  IndexAxisValueFormatter.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

/// This formatter is used for passing an array of x-axis labels, on whole x steps.
public struct IndexAxisValueFormatter: AxisValueFormatter {
    public var values: [String] = []
    
    public func stringForValue(_ value: Double, axis: AxisBase) -> String {
        let index = Int(value.rounded())
        
        if index < 0 || index >= values.endIndex || index != Int(value) {
            return ""
        }
        
        return values[index]
    }
}

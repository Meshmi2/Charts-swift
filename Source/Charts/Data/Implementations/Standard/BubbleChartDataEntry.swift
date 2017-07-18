//
//  BubbleDataEntry.swift
//  Charts
//
//  Bubble chart implementation: 
//    Copyright 2015 Pierre-Marc Airoldi
//    Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

public class BubbleChartDataEntry: ChartDataEntry {
    /// The size of the bubble.
    public var size = CGFloat(0.0)
    
    /// - parameter x: The index on the x-axis.
    /// - parameter y: The value on the y-axis.
    /// - parameter size: The size of the bubble.
    public init(x: Double, y: Double, size: CGFloat) {
        super.init(x: x, y: y)
        
        self.size = size
    }
    
    /// - parameter x: The index on the x-axis.
    /// - parameter y: The value on the y-axis.
    /// - parameter size: The size of the bubble.
    /// - parameter data: Spot for additional data this Entry represents.
    public init(x: Double, y: Double, size: CGFloat, data: Any?) {
        super.init(x: x, y: y, data: data)
        
        self.size = size
    }
    
    /// - parameter x: The index on the x-axis.
    /// - parameter y: The value on the y-axis.
    /// - parameter size: The size of the bubble.
    /// - parameter icon: icon image
    public init(x: Double, y: Double, size: CGFloat, icon: Image?) {
        super.init(x: x, y: y, icon: icon)
        
        self.size = size
    }
    
    /// - parameter x: The index on the x-axis.
    /// - parameter y: The value on the y-axis.
    /// - parameter size: The size of the bubble.
    /// - parameter icon: icon image
    /// - parameter data: Spot for additional data this Entry represents.
    public init(x: Double, y: Double, size: CGFloat, icon: Image?, data: Any?) {
        super.init(x: x, y: y, icon: icon, data: data)
        
        self.size = size
    }
}

//
//  ChartDataEntry.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

open class ChartDataEntry: ChartDataEntryBase
{
    /// the x value
    open var x = Double(0.0)
    
    /// An Entry represents one single entry in the chart.
    /// - parameter x: the x value
    /// - parameter y: the y value (the actual value of the entry)
    public init(x: Double, y: Double)
    {
        super.init(y: y)
        
        self.x = x
    }
    
    /// An Entry represents one single entry in the chart.
    /// - parameter x: the x value
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter data: Space for additional data this Entry represents.
    
    public init(x: Double, y: Double, data: Any?)
    {
        super.init(y: y)
        
        self.x = x
        
        self.data = data
    }
    
    /// An Entry represents one single entry in the chart.
    /// - parameter x: the x value
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter icon: icon image
    
    public init(x: Double, y: Double, icon: Image?)
    {
        super.init(y: y, icon: icon)
        
        self.x = x
    }
    
    /// An Entry represents one single entry in the chart.
    /// - parameter x: the x value
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter icon: icon image
    /// - parameter data: Space for additional data this Entry represents.
    
    public init(x: Double, y: Double, icon: Image?, data: Any?)
    {
        super.init(y: y, icon: icon, data: data)
        
        self.x = x
    }
    
    // MARK
    
    open override var description: String
    {
        return "ChartDataEntry, x: \(x), y \(y)"
    }
    
    // TODO: Move to extension when it can be overriden
    open static func ==(lhs: ChartDataEntry, rhs: ChartDataEntry) -> Bool
    {
        // TODO: Figure out how to equate these
//        if lhs.data !== rhs.data
//        {
//            return false
//        }
        
        if fabs(lhs.x - rhs.x) > Double.ulpOfOne
        {
            return false
        }
        
        if fabs(lhs.y - rhs.y) > Double.ulpOfOne
        {
            return false
        }
        
        return true
    }
}

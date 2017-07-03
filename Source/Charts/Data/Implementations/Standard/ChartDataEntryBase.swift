//
//  ChartDataEntryBase.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

open class ChartDataEntryBase
{
    /// the y value
     open var y = Double(0.0)
    
    /// optional spot for additional data this Entry represents
     open var data: Any?
    
    /// optional icon image
    open var icon: NSUIImage?
    
    /// An Entry represents one single entry in the chart.
    /// - parameter y: the y value (the actual value of the entry)
    public init(y: Double)
    {
        self.y = y
    }
    
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter data: Space for additional data this Entry represents.
    
    public init(y: Double, data: Any?)
    {
        self.y = y
        self.data = data
    }
    
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter icon: icon image
    
    public init(y: Double, icon: NSUIImage?)
    {
        self.y = y
        self.icon = icon
    }
    
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter icon: icon image
    /// - parameter data: Space for additional data this Entry represents.
    
    public init(y: Double, icon: NSUIImage?, data: Any?)
    {
        self.y = y
        self.icon = icon
        self.data = data
    }
    
    // TODO: Move to extension when it can be overriden
    open var description: String
    {
        return "ChartDataEntryBase, y \(y)"
    }
    
    // TODO: Move to extension when it can be overriden
    open static func ==(lhs: ChartDataEntryBase, rhs: ChartDataEntryBase) -> Bool
    {
        if lhs === rhs {
            return true
        }
        
        // TODO: Make this equatable somehow
//        if lhs.data !== rhs.data
//        {
//            return false
//        }
        
        if fabs(lhs.y - rhs.y) > Double.ulpOfOne
        {
            return false
        }
        
        return true
    }
}

extension ChartDataEntryBase: CustomStringConvertible {
}

extension ChartDataEntryBase: Equatable {
}

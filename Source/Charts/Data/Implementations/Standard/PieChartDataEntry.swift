//
//  PieChartDataEntry.swift
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

open class PieChartDataEntry: ChartDataEntry
{
    /// - parameter value: The value on the y-axis
    /// - parameter label: The label for the x-axis
    public convenience init(value: Double, label: String?)
    {
        self.init(value: value, label: label, icon: nil, data: nil)
    }
    
    /// - parameter value: The value on the y-axis
    /// - parameter label: The label for the x-axis
    /// - parameter data: Spot for additional data this Entry represents
    public convenience init(value: Double, label: String?, data: Any?)
    {
        self.init(value: value, label: label, icon: nil, data: data)
    }
    
    /// - parameter value: The value on the y-axis
    /// - parameter label: The label for the x-axis
    /// - parameter icon: icon image
    public convenience init(value: Double, label: String?, icon: Image?)
    {
        self.init(value: value, label: label, icon: icon, data: nil)
    }
    
    /// - parameter value: The value on the y-axis
    /// - parameter label: The label for the x-axis
    /// - parameter icon: icon image
    /// - parameter data: Spot for additional data this Entry represents
    public init(value: Double, label: String?, icon: Image?, data: Any?)
    {
        super.init(x: 0.0, y: value, icon: icon, data: data)
        
        self.label = label
    }
    
    /// - parameter value: The value on the y-axis
    public convenience init(value: Double)
    {
        self.init(value: value, label: nil, icon: nil, data: nil)
    }
    
    /// - parameter value: The value on the y-axis
    /// - parameter data: Spot for additional data this Entry represents
    public convenience init(value: Double, data: Any?)
    {
        self.init(value: value, label: nil, icon: nil, data: data)
    }
    
    /// - parameter value: The value on the y-axis
    /// - parameter icon: icon image
    public convenience init(value: Double, icon: Image?)
    {
        self.init(value: value, label: nil, icon: icon, data: nil)
    }
    
    /// - parameter value: The value on the y-axis
    /// - parameter icon: icon image
    /// - parameter data: Spot for additional data this Entry represents
    public convenience init(value: Double, icon: Image?, data: Any?)
    {
        self.init(value: value, label: nil, icon: icon, data: data)
    }
    
    // MARK: Data property accessors
    
    open var label: String?
    
    open var value: Double
    {
        get { return y }
        set { y = value }
    }
}

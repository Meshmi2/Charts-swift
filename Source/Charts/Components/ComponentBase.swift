//
//  ComponentBase.swift
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


/// This class encapsulates everything both Axis, Legend and LimitLines have in common
public class ComponentBase {
    /// flag that indicates if this component is enabled or not
    public var isEnabled = true
    
    /// The offset this component has on the x-axis
    /// **default**: 5.0
    public var xOffset = CGFloat(5.0)
    
    /// The offset this component has on the x-axis
    /// **default**: 5.0 (or 0.0 on ChartYAxis)
    public var yOffset = CGFloat(5.0)
}

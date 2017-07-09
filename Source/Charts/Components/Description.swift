//
//  Description.swift
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

public struct Description {
    public init()
    {
        #if os(tvOS)
            // 23 is the smallest recommended font size on the TV
            font = Font.systemFont(ofSize: 23)
        #elseif os(OSX)
            font = Font.systemFont(ofSize: Font.systemFontSize)
        #else
            font = Font.systemFont(ofSize: 8.0)
        #endif
    }
    
    /// The text to be shown as the description.
    public var text: String? = "Description Label"
    
    /// Custom position for the description text in pixels on the screen.
    public var position: CGPoint? = nil
    
    /// The text alignment of the description text. Default RIGHT.
    public var textAlign: NSTextAlignment = .right
    
    /// Font object used for drawing the description text.
    public var font: Font
    
    /// Text color used for drawing the description text
    public var textColor = Color.black
    
    /// flag that indicates if this component is enabled or not
    public var isEnabled = true
    
    /// The offset this component has on the x-axis
    /// **default**: 5.0
    public var xOffset = CGFloat(5.0)
    
    /// The offset this component has on the x-axis
    /// **default**: 5.0 (or 0.0 on ChartYAxis)
    public var yOffset = CGFloat(5.0)
}

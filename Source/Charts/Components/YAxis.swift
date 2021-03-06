//
//  YAxis.swift
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


/// Class representing the y-axis labels settings and its entries.
/// Be aware that not all features the YLabels class provides are suitable for the RadarChart.
/// Customizations that affect the value range of the axis need to be applied before setting data for the chart.
public class YAxis: AxisBase {
    public enum LabelPosition {
        case outsideChart
        case insideChart
    }
    
    ///  Enum that specifies the axis a DataSet should be plotted against, either Left or Right.
    public enum AxisDependency {
        case left
        case right
    }
    
    /// indicates if the bottom y-label entry is drawn or not
    public var isDrawBottomYLabelEntryEnabled = true
    
    /// indicates if the top y-label entry is drawn or not
    public var isDrawTopYLabelEntryEnabled = true

    /// flag that indicates if the axis is inverted or not
    public var isInverted = false
    
    /// flag that indicates if the zero-line should be drawn regardless of other grid lines
    public var isDrawZeroLineEnabled = false
    
    /// Color of the zero line
    public var zeroLineColor: Color? = .gray
    
    /// Width of the zero line
    public var zeroLineWidth: CGFloat = 1.0
    
    /// This is how much (in pixels) into the dash pattern are we starting from.
    public var zeroLineDashPhase: CGFloat = 0
    
    /// This is the actual dash pattern.
    /// I.e. [2, 3] will paint [--   --   ]
    /// [1, 3, 4, 2] will paint [-   ----  -   ----  ]
    public var zeroLineDashLengths: [CGFloat]?

    /// axis space from the largest value to the top in percent of the total axis range
    public var spaceTop: CGFloat = 0.1

    /// axis space from the smallest value to the bottom in percent of the total axis range
    public var spaceBottom: CGFloat = 0.1
    
    /// the position of the y-labels relative to the chart
    public var labelPosition: LabelPosition = .outsideChart
    
    /// the side this axis object represents
    private var _axisDependency: AxisDependency = .left
    
    /// the minimum width that the axis should take
    /// 
    /// **default**: 0.0
    public var minWidth: CGFloat = 0
    
    /// the maximum width that the axis can take.
    /// use Infinity for disabling the maximum.
    /// 
    /// **default**: CGFloat.infinity
    public var maxWidth: CGFloat = .infinity
    
    public override init() {
        super.init()
        
        self.yOffset = 0.0
    }
    
    public init(position: AxisDependency) {
        super.init()
        
        _axisDependency = position
        
        self.yOffset = 0.0
    }
    
    public var axisDependency: AxisDependency {
        return _axisDependency
    }
    
    public func requiredSize() -> CGSize {
        let label = getLongestLabel() as NSString
        var size = label.size(withAttributes: [NSAttributedStringKey.font: labelFont])
        size.width += xOffset * 2.0
        size.height += yOffset * 2.0
        size.width = max(minWidth, min(size.width, maxWidth > 0.0 ? maxWidth : size.width))
        return size
    }
    
    public func getRequiredHeightSpace() -> CGFloat {
        return requiredSize().height
    }
    
    /// - returns: `true` if this axis needs horizontal offset, `false` ifno offset is needed.
    public var needsOffset: Bool {
        return isEnabled
            && isDrawLabelsEnabled
            && labelPosition == .outsideChart
    }
        
    public override func calculate(min dataMin: Double, max dataMax: Double) {
        // if custom, use value as is, else use data value
        var min = isAxisMinCustom ? _axisMinimum : dataMin
        var max = isAxisMaxCustom ? _axisMaximum : dataMax
        
        // temporary range (before calculations)
        let range = abs(max - min)
        
        // in case all values are equal
        if range == 0.0 {
            max = max + 1.0
            min = min - 1.0
        }
        
        // bottom-space only effects non-custom min
        if !isAxisMinCustom {
            let bottomSpace = range * Double(spaceBottom)
            _axisMinimum = (min - bottomSpace)
        }
        
        // top-space only effects non-custom max
        if !isAxisMaxCustom {
            let topSpace = range * Double(spaceTop)
            _axisMaximum = (max + topSpace)
        }
        
        // calc actual range
        axisRange = abs(_axisMaximum - _axisMinimum)
    }
}

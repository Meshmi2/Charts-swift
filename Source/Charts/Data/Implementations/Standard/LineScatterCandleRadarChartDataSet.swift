//
//  LineScatterCandleRadarChartDataSet.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation


//public protocol ILineScatterCandleRadarChartDataSet: IBarLineScatterCandleBubbleChartDataSet
//{
//    // MARK: - Data functions and accessors
//
//    // MARK: - Styling functions and accessors
//
//
//    /// Enables / disables the horizontal highlight-indicator. If disabled, the indicator is not drawn.
//    /// - returns: `true` if horizontal highlight indicator lines are enabled (drawn)
//    var isHorizontalHighlightIndicatorEnabled: Bool { get }
//
//    /// Enables / disables the vertical highlight-indicator. If disabled, the indicator is not drawn.
//    /// - returns: `true` if vertical highlight indicator lines are enabled (drawn)
//    var isVerticalHighlightIndicatorEnabled: Bool { get }
//
//    /// Enables / disables both vertical and horizontal highlight-indicators.
//    /// :param: enabled
//    func setDrawHighlightIndicators(_ enabled: Bool)
//}

open class LineScatterCandleRadarChartDataSet: BarLineScatterCandleBubbleChartDataSet
{
    public required init(arrayLiteral elements: ChartDataEntry...) {
        super.init(values: elements)
    }
    
    public required init() {
        super.init()
    }
    
    public override init(values: [ChartDataEntry], label: String = "Data Set") {
        super.init(values: values, label: label)
    }
    
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// Enables / disables the horizontal highlight-indicator. If disabled, the indicator is not drawn.
    /// - returns: `true` if horizontal highlight indicator lines are enabled (drawn)
    open var isHorizontalHighlightIndicatorEnabled = true
    
    /// Enables / disables the vertical highlight-indicator. If disabled, the indicator is not drawn.
    /// - returns: `true` if vertical highlight indicator lines are enabled (drawn)
    open var isVerticalHighlightIndicatorEnabled = true
    
    /// Enables / disables both vertical and horizontal highlight-indicators.
    /// :param: enabled
    open func setDrawHighlightIndicators(_ enabled: Bool)
    {
        isHorizontalHighlightIndicatorEnabled = enabled
        isVerticalHighlightIndicatorEnabled = enabled
    }
}

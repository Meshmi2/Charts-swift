//
//  RadarChartDataSet.swift
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

//public protocol IRadarChartDataSet: ILineRadarChartDataSet
//{
//    // MARK: - Data functions and accessors
//
//    // MARK: - Styling functions and accessors
//
//    /// flag indicating whether highlight circle should be drawn or not
//    var isDrawHighlightCircleEnabled: Bool { get set }
//
//    var highlightCircleFillColor: Color? { get set }
//
//    /// The stroke color for highlight circle.
//    /// If `nil`, the color of the dataset is taken.
//    var highlightCircleStrokeColor: Color? { get set }
//
//    var highlightCircleStrokeAlpha: CGFloat { get set }
//
//    var highlightCircleInnerRadius: CGFloat { get set }
//
//    var highlightCircleOuterRadius: CGFloat { get set }
//
//    var highlightCircleStrokeWidth: CGFloat { get set }
//}


open class RadarChartDataSet: LineRadarChartDataSet
{
    fileprivate func initialize()
    {
        self.valueFont = Font.systemFont(ofSize: 13.0)
    }
    
    public required init()
    {
        super.init()
        initialize()
    }
    
    public required override init(values: [ChartDataEntry], label: String)
    {
        super.init(values: values, label: label)
        initialize()
    }
    
    public required init(arrayLiteral elements: ChartDataEntry...) {
        super.init(values: elements)
        initialize()
    }
    
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// flag indicating whether highlight circle should be drawn or not
    /// **default**: false
    /// - returns: `true` if highlight circle should be drawn, `false` ifnot
    open var isDrawHighlightCircleEnabled: Bool = false
        
    open var highlightCircleFillColor: Color? = Color.white
    
    /// The stroke color for highlight circle.
    /// If `nil`, the color of the dataset is taken.
    open var highlightCircleStrokeColor: Color?
    
    open var highlightCircleStrokeAlpha: CGFloat = 0.3
    
    open var highlightCircleInnerRadius: CGFloat = 3.0
    
    open var highlightCircleOuterRadius: CGFloat = 4.0
    
    open var highlightCircleStrokeWidth: CGFloat = 2.0
}

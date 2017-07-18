//
//  BarLineScatterCandleBubbleChartDataSet.swift
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

//public protocol IBarLineScatterCandleBubbleChartDataSet: IChartDataSet
//{
//    // MARK: - Data functions and accessors
//
//    // MARK: - Styling functions and accessors
//
//    var highlightColor: Color { get set }
//    var highlightLineWidth: CGFloat { get set }
//    var highlightLineDashPhase: CGFloat { get set }
//    var highlightLineDashLengths: [CGFloat]? { get set }
//}

public class BarLineScatterCandleBubbleChartDataSet: ChartDataSet {
    // MARK: - Data functions and accessors
    public required init(arrayLiteral elements: ChartDataEntry...) {
        super.init(values: elements)
    }
    
    public required init() {
        super.init()
    }
    
    public override init(values: [ChartDataEntry], label: String = "Data Set") {
        super.init(values: values, label: label)
    }
    
    // MARK: - Styling functions and accessors
    
    public var highlightColor = Color(red: 255.0/255.0, green: 187.0/255.0, blue: 115.0/255.0, alpha: 1.0)
    public var highlightLineWidth = CGFloat(0.5)
    public var highlightLineDashPhase = CGFloat(0.0)
    public var highlightLineDashLengths: [CGFloat]?
}

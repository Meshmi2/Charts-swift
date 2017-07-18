//
//  BubbleChartDataSet.swift
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

//public protocol IBubbleChartDataSet: IBarLineScatterCandleBubbleChartDataSet
//{
//    // MARK: - Data functions and accessors
//
//    var maxSize: CGFloat { get }
//    var isNormalizeSizeEnabled: Bool { get }
//
//    // MARK: - Styling functions and accessors
//
//    /// Sets/gets the width of the circle that surrounds the bubble when highlighted
//    var highlightCircleWidth: CGFloat { get set }
//}


public class BubbleChartDataSet: BarLineScatterCandleBubbleChartDataSet {
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
    
    var _maxSize = CGFloat(0.0)
    
    public var maxSize: CGFloat { return _maxSize }
    public var normalizeSizeEnabled: Bool = true
    public var isNormalizeSizeEnabled: Bool { return normalizeSizeEnabled }
    
    public func calcMinMax(entry e: ChartDataEntry) {
        guard let e = e as? BubbleChartDataEntry
            else { return }
        
        super.calcMinMax(entry: e)
        
        let size = e.size
        
        if size > _maxSize {
            _maxSize = size
        }
    }
    
    // MARK: - Styling functions and accessors
    
    /// Sets/gets the width of the circle that surrounds the bubble when highlighted
    public var highlightCircleWidth: CGFloat = 2.5
}

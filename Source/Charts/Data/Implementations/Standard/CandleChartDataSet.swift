//
//  CandleChartDataSet.swift
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

//public protocol ICandleChartDataSet: ILineScatterCandleRadarChartDataSet
//{
//    // MARK: - Data functions and accessors
//
//    // MARK: - Styling functions and accessors
//
//    /// the space that is left out on the left and right side of each candle,
//    /// **default**: 0.1 (10%), max 0.45, min 0.0
//    var barSpace: CGFloat { get set }
//
//    /// should the candle bars show?
//    /// when false, only "ticks" will show
//    ///
//    /// **default**: true
//    var showCandleBar: Bool { get set }
//
//    /// the width of the candle-shadow-line in pixels.
//    ///
//    /// **default**: 3.0
//    var shadowWidth: CGFloat { get set }
//
//    /// the color of the shadow line
//    var shadowColor: Color? { get set }
//
//    /// use candle color for the shadow
//    var shadowColorSameAsCandle: Bool { get set }
//
//    /// Is the shadow color same as the candle color?
//    var isShadowColorSameAsCandle: Bool { get }
//
//    /// color for open == close
//    var neutralColor: Color? { get set }
//
//    /// color for open > close
//    var increasingColor: Color? { get set }
//
//    /// color for open < close
//    var decreasingColor: Color? { get set }
//
//    /// Are increasing values drawn as filled?
//    var increasingFilled: Bool { get set }
//
//    /// Are increasing values drawn as filled?
//    var isIncreasingFilled: Bool { get }
//
//    /// Are decreasing values drawn as filled?
//    var decreasingFilled: Bool { get set }
//
//    /// Are decreasing values drawn as filled?
//    var isDecreasingFilled: Bool { get }
//}

public class CandleChartDataSet: LineScatterCandleRadarChartDataSet {
    
    public required init() {
        super.init()
    }
    
    public override init(values: [ChartDataEntry], label: String = "Data Set") {
        super.init(values: values, label: label)
    }
    
    public required init(arrayLiteral elements: ChartDataEntry...) {
        super.init(values: elements)
    }
    
    // MARK: - Data functions and accessors
    
    public func calcMinMax(entry e: ChartDataEntry) {
        guard let e = e as? CandleChartDataEntry
            else { return }
        
        if e.low < yMin {
            yMin = e.low
        }
        
        if e.high > yMax {
            yMax = e.high
        }
        
        calcMinMaxX(entry: e)
    }
    
    public func calcMinMaxY(entry e: ChartDataEntry) {
        guard let e = e as? CandleChartDataEntry
            else { return }
        
        if e.high < yMin {
            yMin = e.high
        }
        if e.high > yMax {
            yMax = e.high
        }
        
        if e.low < yMin {
            yMin = e.low
        }
        if e.low > yMax {
            yMax = e.low
        }
    }
    
    // MARK: - Styling functions and accessors
    
    /// the space between the candle entries
    ///
    /// **default**: 0.1 (10%)
    private var _barSpace = CGFloat(0.1)
    
    /// the space that is left out on the left and right side of each candle,
    /// **default**: 0.1 (10%), max 0.45, min 0.0
    public var barSpace: CGFloat {
        set {
            if newValue < 0.0 {
                _barSpace = 0.0
            }
            else if newValue > 0.45 {
                _barSpace = 0.45
            }
            else {
                _barSpace = newValue
            }
        }
        get {
            return _barSpace
        }
    }
    
    /// should the candle bars show?
    /// when false, only "ticks" will show
    ///
    /// **default**: true
    public var showCandleBar = true
    
    /// the width of the candle-shadow-line in pixels.
    ///
    /// **default**: 1.5
    public var shadowWidth = CGFloat(1.5)
    
    /// the color of the shadow line
    public var shadowColor: Color?
    
    /// use candle color for the shadow
    /// Is the shadow color same as the candle color?
    public var isShadowColorSameAsCandle = false
    
    /// color for open == close
    public var neutralColor: Color?
    
    /// color for open > close
    public var increasingColor: Color?
    
    /// color for open < close
    public var decreasingColor: Color?
    
    /// Are increasing values drawn as filled?
    /// increasing candlesticks are traditionally hollow
    /// Are increasing values drawn as filled?
    public var isIncreasingFilled = false
    
    /// Are decreasing values drawn as filled?
    /// descreasing candlesticks are traditionally filled
    /// Are decreasing values drawn as filled?
    public var isDecreasingFilled = true
}

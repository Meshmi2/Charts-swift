//
//  CombinedChartView.swift
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

/// This chart class allows the combination of lines, bars, scatter and candle data all displayed in one chart area.
public class CombinedChartView: BarLineChartViewBase, CombinedChartDataProvider {
    /// the fill-formatter used for determining the position of the fill-line
    var _fillFormatter: FillFormatter!
    
    /// enum that allows to specify the order in which the different data objects for the combined-chart are drawn
    public enum DrawOrder {
        case bar
        case bubble
        case line
        case candle
        case scatter
    }
    
    public override func initialize() {
        super.initialize()
        
        self.highlighter = CombinedHighlighter(chart: self, barDataProvider: self)
        
        // Old default behaviour
        self.isHighlightFullBarEnabled = true
        
        _fillFormatter = DefaultFillFormatter()
        
        renderer = CombinedChartRenderer(chart: self, animator: _animator, viewPortHandler: viewPortHandler)
    }
    
    public override var data: ChartData? {
        get {
            return super.data
        }
        set {
            super.data = newValue
            
            self.highlighter = CombinedHighlighter(chart: self, barDataProvider: self)
            
            (renderer as! CombinedChartRenderer?)!.createRenderers()
            renderer?.initBuffers()
        }
    }
    
    public var fillFormatter: FillFormatter {
        get {
            return _fillFormatter
        }
        set {
            _fillFormatter = newValue
            if _fillFormatter == nil {
                _fillFormatter = DefaultFillFormatter()
            }
        }
    }
    
    /// - returns: The Highlight object (contains x-index and DataSet index) of the selected value at the given touch point inside the CombinedChart.
    public override func getHighlightByTouchPoint(_ pt: CGPoint) -> Highlight? {
        if _data == nil {
            print("Can't select by touch. No data set.")
            return nil
        }
        
        guard let h = self.highlighter?.getHighlight(x: pt.x, y: pt.y)
            else { return nil }
        
        if !isHighlightFullBarEnabled { return h }
        
        // For isHighlightFullBarEnabled, remove stackIndex
        return Highlight(
            x: h.x, y: h.y,
            xPx: h.xPx, yPx: h.yPx,
            dataIndex: h.dataIndex,
            dataSetIndex: h.dataSetIndex,
            stackIndex: -1,
            axis: h.axis)
    }
    
    // MARK: - CombinedChartDataProvider
    
    public var combinedData: CombinedChartData? {
            return _data as? CombinedChartData
    }
    
    // MARK: - LineChartDataProvider
    
    public var lineData: LineChartData? {
        return combinedData?.lineData
    }
    
    // MARK: - BarChartDataProvider
    
    public var barData: BarChartData? {
        return combinedData?.barData
    }
    
    // MARK: - ScatterChartDataProvider
    
    public var scatterData: ScatterChartData? {
        return combinedData?.scatterData
    }
    
    // MARK: - CandleChartDataProvider
    
    public var candleData: CandleChartData? {
        return combinedData?.candleData
    }
    
    // MARK: - BubbleChartDataProvider
    
    public var bubbleData: BubbleChartData? {
        return combinedData?.bubbleData
    }
    
    // MARK: - Accessors
    
    /// if set to true, all values are drawn above their bars, instead of below their top
    /// - returns: `true` if drawing values above bars is enabled, `false` ifnot
    public var isDrawValueAboveBarEnabled: Bool {
        get { return (renderer as! CombinedChartRenderer!).isDrawValueAboveBarEnabled }
        set { (renderer as! CombinedChartRenderer!).isDrawValueAboveBarEnabled = newValue }
    }
    
    /// if set to true, a grey area is drawn behind each bar that indicates the maximum value
    /// - returns: `true` if drawing shadows (maxvalue) for each bar is enabled, `false` ifnot
    public var isDrawBarShadowEnabled: Bool {
        get { return (renderer as! CombinedChartRenderer!).isDrawBarShadowEnabled }
        set { (renderer as! CombinedChartRenderer!).isDrawBarShadowEnabled = newValue }
    }
    
    /// the order in which the provided data objects should be drawn.
    /// The earlier you place them in the provided array, the further they will be in the background. 
    /// e.g. if you provide [DrawOrder.Bar, DrawOrder.Line], the bars will be drawn behind the lines.
    public var drawOrder: [DrawOrder] {
        get {
            return (renderer as! CombinedChartRenderer!).drawOrder
        }
        set {
            (renderer as! CombinedChartRenderer!).drawOrder = newValue
        }
    }
    
    /// Set this to `true` to make the highlight operation full-bar oriented, `false` to make it highlight single values
    /// - returns: `true` the highlight is be full-bar oriented, `false` ifsingle-value
    public var isHighlightFullBarEnabled = false    
}

//
//  BarChartView.swift
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

/// Chart that draws bars.
public class BarChartView: BarLineChartViewBase, BarChartDataProvider {
    /// if set to true, all values are drawn above their bars, instead of below their top
    /// - returns: `true` if drawing values above bars is enabled, `false` ifnot
    public var isDrawValueAboveBarEnabled = true {
        didSet { setNeedsDisplay() }
    }

    /// if set to true, a grey area is drawn behind each bar that indicates the maximum value
    /// - returns: `true` if drawing shadows (maxvalue) for each bar is enabled, `false` ifnot
    public var isDrawBarShadowEnabled = false {
        didSet { setNeedsDisplay() }
    }
    
    override func initialize() {
        super.initialize()
        
        renderer = BarChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: viewPortHandler)
        
        self.highlighter = BarHighlighter(chart: self)
        
        self.xAxis.spaceMin = 0.5
        self.xAxis.spaceMax = 0.5
    }
    
    override func calcMinMax() {
        guard let data = self.data as? BarChartData else { return }
        
        if fitBars {
            _xAxis.calculate(
                min: data.xMin - data.barWidth / 2.0,
                max: data.xMax + data.barWidth / 2.0)
        } else {
            _xAxis.calculate(min: data.xMin, max: data.xMax)
        }
        
        // calculate axis range (min / max) according to provided data
        _leftAxis.calculate(min: data.getYMin(axis: .left),
                            max: data.getYMax(axis: .left))
        _rightAxis.calculate(min: data.getYMin(axis: .right),
                             max: data.getYMax(axis: .right))
    }
    
    /// - returns: The Highlight object (contains x-index and DataSet index) of the selected value at the given touch point inside the BarChart.
    public override func getHighlightByTouchPoint(_ pt: CGPoint) -> Highlight? {
        guard _data != nil else {
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
        
    /// - returns: The bounding box of the specified Entry in the specified DataSet. Returns null if the Entry could not be found in the charts data.
    public func getBarBounds(entry e: BarChartDataEntry) -> CGRect {
        guard let
            data = _data as? BarChartData,
            let set = data.getDataSetForEntry(e) as? BarChartDataSet
            else { return CGRect.null }
        
        let y = e.y
        let x = e.x
        
        let barWidth = data.barWidth
        
        let left = x - barWidth / 2.0
        let right = x + barWidth / 2.0
        let top = y >= 0.0 ? y : 0.0
        let bottom = y <= 0.0 ? y : 0.0
        
        var bounds = CGRect(x: left, y: top, width: right - left, height: bottom - top)
        
        getTransformer(forAxis: set.axisDependency).rectValueToPixel(&bounds)
        
        return bounds
    }
    
    /// Groups all BarDataSet objects this data object holds together by modifying the x-value of their entries.
    /// Previously set x-values of entries will be overwritten. Leaves space between bars and groups as specified by the parameters.
    /// Calls `notifyDataSetChanged()` afterwards.
    ///
    /// - parameter fromX: the starting point on the x-axis where the grouping should begin
    /// - parameter groupSpace: the space between groups of bars in values (not pixels) e.g. 0.8f for bar width 1f
    /// - parameter barSpace: the space between individual bars in values (not pixels) e.g. 0.1f for bar width 1f
    public func groupBars(fromX: Double, groupSpace: Double, barSpace: Double) {
        guard let barData = self.barData
            else {
            Swift.print("You need to set data for the chart before grouping bars.", terminator: "\n")
            return
        }
        
        barData.groupBars(fromX: fromX, groupSpace: groupSpace, barSpace: barSpace)
        notifyDataSetChanged()
    }
    
    /// Highlights the value at the given x-value in the given DataSet. Provide -1 as the dataSetIndex to undo all highlighting.
    /// - parameter x:
    /// - parameter dataSetIndex:
    /// - parameter stackIndex: the index inside the stack - only relevant for stacked entries
    public func highlightValue(x: Double, dataSetIndex: Int, stackIndex: Int) {
        highlightValue(Highlight(x: x, dataSetIndex: dataSetIndex, stackIndex: stackIndex))
    }

    // MARK: Accessors
    
    /// Adds half of the bar width to each side of the x-axis range in order to allow the bars of the barchart to be fully displayed.
    /// **default**: false
    public var fitBars = false
    
    /// Set this to `true` to make the highlight operation full-bar oriented, `false` to make it highlight single values (relevant only for stacked).
    /// If enabled, highlighting operations will highlight the whole bar, even if only a single stack entry was tapped.
    /// - returns: `true` the highlight is be full-bar oriented, `false` ifsingle-value
    public var isHighlightFullBarEnabled = false
    
    // MARK: - BarChartDataProvider
    
    public var barData: BarChartData? { return _data as? BarChartData }
}

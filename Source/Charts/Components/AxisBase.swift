//
//  AxisBase.swift
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

/// Base class for all axes
public class AxisBase: ComponentBase {
    public override init() {
        super.init()
    }
    
    /// Custom formatter that is used instead of the auto-formatter if set
    private var _axisValueFormatter: AxisValueFormatter?
    
    public var labelFont = Font.systemFont(ofSize: 10.0, weight: .light)
    public var labelTextColor = Color.black
    
    public var axisLineColor = Color.gray
    public var axisLineWidth = CGFloat(0.5)
    public var axisLineDashPhase = CGFloat(0.0)
    public var axisLineDashLengths: [CGFloat]!
    
    public var gridColor = Color.gray.withAlphaComponent(0.9)
    public var gridLineWidth = CGFloat(0.5)
    public var gridLineDashPhase = CGFloat(0.0)
    public var gridLineDashLengths: [CGFloat]!
    public var gridLineCap = CGLineCap.butt
    
    public var isDrawGridLinesEnabled = false
    public var isDrawAxisLineEnabled = true
    
    /// flag that indicates of the labels of this axis should be drawn or not
    public var isDrawLabelsEnabled = true
    
    private var _centerAxisLabelsEnabled = false

    /// Centers the axis labels instead of drawing them at their original position.
    /// This is useful especially for grouped BarChart.
    public var isCenterAxisLabelsEnabled: Bool {
        get { return _centerAxisLabelsEnabled && entryCount > 0 }
        set { _centerAxisLabelsEnabled = newValue }
    }
    
    /// array of limitlines that can be set for the axis
    private var _limitLines = [ChartLimitLine]()
    
    /// Are the LimitLines drawn behind the data or in front of the data?
    /// 
    /// **default**: false
    public var isDrawLimitLinesBehindDataEnabled = false

    /// the flag can be used to turn off the antialias for grid lines
    public var isGridAntialiasEnabled = true
    
    /// the actual array of entries
    public var entries = [Double]()
    
    /// axis label entries only used for centered labels
    public var centeredEntries = [Double]()
    
    /// the number of entries the legend contains
    public var entryCount: Int { return entries.count }
    
    /// the number of label entries the axis should have
    ///
    /// **default**: 6
    private var _labelCount = Int(6)
    
    /// the number of decimal digits to use (for the default formatter
    public var decimals: Int = 0
    
    /// When true, axis labels are controlled by the `granularity` property.
    /// When false, axis values could possibly be repeated.
    /// This could happen if two adjacent axis values are rounded to same value.
    /// If using granularity this could be avoided by having fewer axis values visible.
    /// The minimum interval between axis values.
    public var isGranularityEnabled = false
    
    private var _granularity = Double(1.0)
    
    /// The minimum interval between axis values.
    /// This can be used to avoid label duplicating when zooming in.
    ///
    /// **default**: 1.0
    public var granularity: Double {
        get {
            return _granularity
        }
        set {
            _granularity = newValue
            
            // set this to `true` if it was disabled, as it makes no sense to set this property with granularity disabled
            isGranularityEnabled = true
        }
    }
    
    public func getLongestLabel() -> String {
        var longest = ""
        
        for i in 0 ..< entries.count {
            let text = getFormattedLabel(i)
            
            if longest.characters.count < text.characters.count {
                longest = text
            }
        }
        
        return longest
    }
    
    /// - returns: The formatted label at the specified index. This will either use the auto-formatter or the custom formatter (if one is set).
    public func getFormattedLabel(_ index: Int) -> String {
        if index < 0 || index >= entries.count {
            return ""
        }
        
        return valueFormatter?.stringForValue(entries[index], axis: self) ?? ""
    }
    
    /// Sets the formatter to be used for formatting the axis labels.
    /// If no formatter is set, the chart will automatically determine a reasonable formatting (concerning decimals) for all the values that are drawn inside the chart.
    /// Use `nil` to use the formatter calculated by the chart.
    public var valueFormatter: AxisValueFormatter? {
        get {
            if _axisValueFormatter == nil ||
                (_axisValueFormatter is DefaultAxisValueFormatter &&
                    (_axisValueFormatter as! DefaultAxisValueFormatter).hasAutoDecimals &&
                    (_axisValueFormatter as! DefaultAxisValueFormatter).decimals != decimals) {
                _axisValueFormatter = DefaultAxisValueFormatter(decimals: decimals)
            }
            
            return _axisValueFormatter
        }
        set {
            _axisValueFormatter = newValue ?? DefaultAxisValueFormatter(decimals: decimals)
        }
    }
    
    /// Extra spacing for `axisMinimum` to be added to automatically calculated `axisMinimum`
    public var spaceMin: Double = 0.0
    
    /// Extra spacing for `axisMaximum` to be added to automatically calculated `axisMaximum`
    public var spaceMax: Double = 0.0
    
    /// Flag indicating that the axis-min value has been customized
    var _customAxisMin: Bool = false
    
    /// Flag indicating that the axis-max value has been customized
    var _customAxisMax: Bool = false
    
    /// Do not touch this directly, instead, use axisMinimum.
    /// This is automatically calculated to represent the real min value,
    /// and is used when calculating the effective minimum.
    var _axisMinimum = Double(0)
    
    /// Do not touch this directly, instead, use axisMaximum.
    /// This is automatically calculated to represent the real max value,
    /// and is used when calculating the effective maximum.
    var _axisMaximum = Double(0)
    
    /// the total range of values this axis covers
    public var axisRange = Double(0)
    
    /// the number of label entries the axis should have
    /// max = 25,
    /// min = 2,
    /// default = 6,
    /// be aware that this number is not fixed and can only be approximated
    public var labelCount: Int {
        get {
            return _labelCount
        }
        set {
            _labelCount = newValue
            
            if _labelCount > 25 {
                _labelCount = 25
            }
            if _labelCount < 2 {
                _labelCount = 2
            }
            
            isForceLabelsEnabled = false
        }
    }
    
    public func setLabelCount(_ count: Int, force: Bool) {
        self.labelCount = count
        isForceLabelsEnabled = force
    }
    
    /// - returns: `true` if focing the y-label count is enabled. Default: false
    
    /// if true, the set number of y-labels will be forced
    public var isForceLabelsEnabled = false
    
    /// Adds a new ChartLimitLine to this axis.
    public func addLimitLine(_ line: ChartLimitLine) {
        _limitLines.append(line)
    }
    
    /// Removes the specified ChartLimitLine from the axis.
    public func removeLimitLine(_ line: ChartLimitLine) {
        for i in 0 ..< _limitLines.count {
            if _limitLines[i] === line {
                _limitLines.remove(at: i)
                return
            }
        }
    }
    
    /// Removes all LimitLines from the axis.
    public func removeAllLimitLines() {
        _limitLines.removeAll(keepingCapacity: false)
    }
    
    /// - returns: The LimitLines of this axis.
    public var limitLines : [ChartLimitLine] {
        return _limitLines
    }
    
    // MARK: Custom axis ranges
    
    /// By calling this method, any custom minimum value that has been previously set is reseted, and the calculation is done automatically.
    public func resetCustomAxisMin() {
        _customAxisMin = false
    }
    
    public var isAxisMinCustom: Bool { return _customAxisMin }
    
    /// By calling this method, any custom maximum value that has been previously set is reseted, and the calculation is done automatically.
    public func resetCustomAxisMax() {
        _customAxisMax = false
    }
    
    public var isAxisMaxCustom: Bool { return _customAxisMax }
        
    /// The minimum value for this axis.
    /// If set, this value will not be calculated automatically depending on the provided data.
    /// Use `resetCustomAxisMin()` to undo this.
    public var axisMinimum: Double {
        get {
            return _axisMinimum
        }
        set {
            _customAxisMin = true
            _axisMinimum = newValue
            axisRange = abs(_axisMaximum - newValue)
        }
    }
    
    /// The maximum value for this axis.
    /// If set, this value will not be calculated automatically depending on the provided data.
    /// Use `resetCustomAxisMax()` to undo this.
    public var axisMaximum: Double {
        get {
            return _axisMaximum
        }
        set {
            _customAxisMax = true
            _axisMaximum = newValue
            axisRange = abs(newValue - _axisMinimum)
        }
    }
    
    /// Calculates the minimum, maximum and range values of the YAxis with the given minimum and maximum values from the chart data.
    /// - parameter dataMin: the y-min value according to chart data
    /// - parameter dataMax: the y-max value according to chart
    public func calculate(min dataMin: Double, max dataMax: Double) {
        // if custom, use value as is, else use data value
        var min = _customAxisMin ? _axisMinimum : (dataMin - spaceMin)
        var max = _customAxisMax ? _axisMaximum : (dataMax + spaceMax)
        
        // temporary range (before calculations)
        let range = abs(max - min)
        
        // in case all values are equal
        if range == 0.0 {
            max = max + 1.0
            min = min - 1.0
        }
        
        _axisMinimum = min
        _axisMaximum = max
        
        // actual range
        axisRange = abs(max - min)
    }
}

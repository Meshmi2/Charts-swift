//
//  ChartDataSet.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

/// The DataSet class represents one group or type of entries (Entry) in the Chart that belong together.
/// It is designed to logically separate different groups of values inside the Chart (e.g. the values for a specific line in the LineChart, or the values of a specific group of bars in the BarChart).
public class ChartDataSet: IChartDataSet {
    public typealias Element = ChartDataEntry
    
    // MARK: - Data functions and accessors
    public required init() {
        self.values = []
    }
    
    public init(values: [ChartDataEntry], label: String = "Data Set") {
        self.label = label
        self.values = values
        self.calcMinMax()
    }
    
    public required init(arrayLiteral elements: ChartDataEntry...) {
        values = elements
    }
    // MARK: - Data functions and accessors
    
    /// maximum y-value in the value array
    public var yMax: Double = -Double.greatestFiniteMagnitude
    
    /// minimum y-value in the value array
    public var yMin: Double = Double.greatestFiniteMagnitude
    
    /// maximum x-value in the value array
    public var xMax: Double = -Double.greatestFiniteMagnitude
    
    /// minimum x-value in the value array
    public var xMin: Double = Double.greatestFiniteMagnitude
    
    /// *
    /// - note: Calls `notifyDataSetChanged()` after setting a new value.
    /// the entries that this dataset represents / holds together
    public var values: [ChartDataEntry] {
        didSet{
            notifyDataSetChanged()
        }
    }
    
    /// Use this method to tell the data set that the underlying data has changed
    public func notifyDataSetChanged() {
        calcMinMax()
    }
    
    public func calcMinMax() {
        if self.isEmpty {
            return
        }
        
        yMax = -Double.greatestFiniteMagnitude
        yMin = Double.greatestFiniteMagnitude
        xMax = -Double.greatestFiniteMagnitude
        xMin = Double.greatestFiniteMagnitude
        
        for e in values {
            calcMinMax(entry: e)
        }
    }
    
    public func calcMinMaxY(fromX: Double, toX: Double) {
        if values.count == 0 {
            return
        }
        
        yMax = -Double.greatestFiniteMagnitude
        yMin = Double.greatestFiniteMagnitude
        
        let indexFrom = entryIndex(x: fromX, closestToY: Double.nan, rounding: .down)
        let indexTo = entryIndex(x: toX, closestToY: Double.nan, rounding: .up)
        
        if indexTo < indexFrom { return }
        
        for i in indexFrom...indexTo {
            // only recalculate y
            calcMinMaxY(entry: values[i])
        }
    }
    
    /// - returns: The first Entry object found at the given x-value with binary search.
    /// If the no Entry at the specified x-value is found, this method returns the Entry at the closest x-value according to the rounding.
    /// nil if no Entry object at that x-value.
    /// - parameter xValue: the x-value
    /// - parameter closestToY: If there are multiple y-values for the specified x-value,
    /// - parameter rounding: determine whether to round up/down/closest if there is no Entry matching the provided x-value
    public func entryForXValue(
        _ xValue: Double,
        closestToY yValue: Double,
        rounding: RoundingMode) -> ChartDataEntry? {
        let index = self.entryIndex(x: xValue, closestToY: yValue, rounding: rounding)
        if index > -1 {
            return values[index]
        }
        return nil
    }
    
    /// - returns: The first Entry object found at the given x-value with binary search.
    /// If the no Entry at the specified x-value is found, this method returns the Entry at the closest x-value.
    /// nil if no Entry object at that x-value.
    /// - parameter xValue: the x-value
    /// - parameter closestToY: If there are multiple y-values for the specified x-value,
    public func entryForXValue(
        _ xValue: Double,
        closestToY yValue: Double) -> ChartDataEntry? {
        return entryForXValue(xValue, closestToY: yValue, rounding: .closest)
    }
    
    /// - returns: All Entry objects found at the given xIndex with binary search.
    /// An empty array if no Entry object at that index.
    public func entriesForXValue(_ xValue: Double) -> [ChartDataEntry] {
        var entries = [ChartDataEntry]()
        
        var low = 0
        var high = values.count - 1
        
        while low <= high {
            var m = (high + low) / 2
            var entry = values[m]
            
            // if we have a match
            if xValue == entry.x {
                while m > 0 && values[m - 1].x == xValue {
                    m -= 1
                }
                
                high = values.count
                
                // loop over all "equal" entries
                while m < high {
                    entry = values[m]
                    if entry.x == xValue {
                        entries.append(entry)
                    }
                    else {
                        break
                    }
                    
                    m += 1
                }
                
                break
            }
            else {
                if xValue > entry.x {
                    low = m + 1
                }
                else {
                    high = m - 1
                }
            }
        }
        
        return entries
    }
    
    /// - returns: The array-index of the specified entry.
    /// If the no Entry at the specified x-value is found, this method returns the index of the Entry at the closest x-value according to the rounding.
    ///
    /// - parameter xValue: x-value of the entry to search for
    /// - parameter closestToY: If there are multiple y-values for the specified x-value,
    /// - parameter rounding: Rounding method if exact value was not found
    public func entryIndex(
        x xValue: Double,
        closestToY yValue: Double,
        rounding: RoundingMode) -> Int {
        var low = 0
        var high = values.count - 1
        var closest = high
        
        while low < high {
            let m = (low + high) / 2
            
            let d1 = values[m].x - xValue
            let d2 = values[m + 1].x - xValue
            let ad1 = abs(d1), ad2 = abs(d2)
            
            if ad2 < ad1 {
                // [m + 1] is closer to xValue
                // Search in an higher place
                low = m + 1
            }
            else if ad1 < ad2 {
                // [m] is closer to xValue
                // Search in a lower place
                high = m
            }
            else {
                // We have multiple sequential x-value with same distance
                
                if d1 >= 0.0 {
                    // Search in a lower place
                    high = m
                }
                else if d1 < 0.0 {
                    // Search in an higher place
                    low = m + 1
                }
            }
            
            closest = high
        }
        
        if closest != -1 {
            let closestXValue = values[closest].x
            
            if .up ~= rounding {
                // If rounding up, and found x-value is lower than specified x, and we can go upper...
                if closestXValue < xValue && closest < values.count - 1 {
                    closest += 1
                }
            }
            else if .down ~= rounding {
                // If rounding down, and found x-value is upper than specified x, and we can go lower...
                if closestXValue > xValue && closest > 0 {
                    closest -= 1
                }
            }
            
            // Search by closest to y-value
            if !yValue.isNaN {
                while closest > 0 && values[closest - 1].x == closestXValue {
                    closest -= 1
                }
                
                var closestYValue = values[closest].y
                var closestYIndex = closest
                
                while true {
                    closest += 1
                    if closest >= values.count { break }
                    
                    let value = values[closest]
                    
                    if value.x != closestXValue { break }
                    if abs(value.y - yValue) < abs(closestYValue - yValue) {
                        closestYValue = yValue
                        closestYIndex = closest
                    }
                }
                
                closest = closestYIndex
            }
        }
        
        return closest
    }
    
    /// - returns: The array-index of the specified entry
    ///
    /// - parameter e: the entry to search for
    public func entryIndex(entry e: ChartDataEntry) -> Int {
        for i in 0 ..< values.count {
            if values[i] === e {
                return i
            }
        }
        
        return -1
    }
    
    /// Adds an Entry to the DataSet dynamically.
    /// Entries are added to their appropriate index respective to it's x-index.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter e: the entry to add
    /// - returns: True
    public func addEntryOrdered(_ e: ChartDataEntry) -> Bool {
        calcMinMax(entry: e)
        
        if values.count > 0 && values.last!.x > e.x {
            var closestIndex = entryIndex(x: e.x, closestToY: e.y, rounding: .up)
            while values[closestIndex].x < e.x {
                closestIndex += 1
            }
            values.insert(e, at: closestIndex)
        }
        else {
            values.append(e)
        }
        
        return true
    }
    
    /// Removes an Entry from the DataSet dynamically.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter entry: the entry to remove
    /// - returns: `true` if the entry was removed successfully, else if the entry does not exist
    public func removeEntry(_ entry: ChartDataEntry) -> Bool {
        var removed = false
        
        for i in 0 ..< values.count {
            if values[i] === entry {
                values.remove(at: i)
                removed = true
                break
            }
        }
        
        if removed {
            calcMinMax()
        }
        
        return removed
    }
    
    @discardableResult public func removeEntry(x: Double) -> Bool {
        if let entry = entryForXValue(x, closestToY: Double.nan) {
            return removeEntry(entry)
        }
        return false
    }
    
    /// Checks if this DataSet contains the specified Entry.
    /// - returns: `true` if contains the entry, `false` ifnot.
    public func contains(_ e: ChartDataEntry) -> Bool {
        for entry in values {
            if entry == e {
                return true
            }
        }
        
        return false
    }
        
    // MARK: - Styling functions and accessors
    /// All the colors that are used for this DataSet.
    /// Colors are reused as soon as the number of Entries the DataSet represents is higher than the size of the colors array.
    public var colors = [Color(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0)]
    
    /// List representing all colors that are used for drawing the actual values for this DataSet
    public var valueColors = [Color.black]
    
    /// The label string that describes the DataSet.
    public var label: String? = "Data Set"
    
    /// The axis this DataSet should be plotted against.
    public var axisDependency = YAxis.AxisDependency.left
    
    /// - returns: The color at the given index of the DataSet's color array.
    /// This prevents out-of-bounds by performing a modulus on the color index, so colours will repeat themselves.
    public func color(atIndex index: Int) -> Color {
        var index = index
        if index < 0 {
            index = 0
        }
        return colors[index % colors.count]
    }
    
    /// Resets all colors of this DataSet and recreates the colors array.
    public func resetColors() {
        colors.removeAll(keepingCapacity: false)
    }
    
    /// Adds a new color to the colors array of the DataSet.
    /// - parameter color: the color to add
    public func addColor(_ color: Color) {
        colors.append(color)
    }
    
    /// Sets the one and **only** color that should be used for this DataSet.
    /// Internally, this recreates the colors array and adds the specified color.
    /// - parameter color: the color to set
    public func setColor(_ color: Color) {
        colors.removeAll(keepingCapacity: false)
        colors.append(color)
    }
    
    /// Sets colors to a single color a specific alpha value.
    /// - parameter color: the color to set
    /// - parameter alpha: alpha to apply to the set `color`
    public func setColor(_ color: Color, alpha: CGFloat) {
        setColor(color.withAlphaComponent(alpha))
    }
    
    /// Sets colors with a specific alpha value.
    /// - parameter colors: the colors to set
    /// - parameter alpha: alpha to apply to the set `colors`
    public func setColors(_ colors: [Color], alpha: CGFloat) {
        var colorsWithAlpha = colors
        
        for i in 0 ..< colorsWithAlpha.count {
            colorsWithAlpha[i] = colorsWithAlpha[i] .withAlphaComponent(alpha)
        }
        
        self.colors = colorsWithAlpha
    }
    
    /// Sets colors with a specific alpha value.
    /// - parameter colors: the colors to set
    /// - parameter alpha: alpha to apply to the set `colors`
    public func setColors(_ colors: [Color]) {
        self.colors = colors
    }
    
    /// if true, value highlighting is enabled
    /// - returns: `true` if value highlighting is enabled for this dataset
    public var isHighlightEnabled = true
    
    /// Custom formatter that is used instead of the auto-formatter if set
    var _valueFormatter: ValueFormatter?
    
    /// Custom formatter that is used instead of the auto-formatter if set
    public var valueFormatter: ValueFormatter? {
        get {
            if needsFormatter {
                return ChartUtils.defaultValueFormatter()
            }
            
            return _valueFormatter
        }
        set {
            if newValue == nil { return }
            
            _valueFormatter = newValue
        }
    }
    
    public var needsFormatter: Bool {
        return _valueFormatter == nil
    }
    
    /// Sets/get a single color for value text.
    /// Setting the color clears the colors array and adds a single color.
    /// Getting will return the first color in the array.
    public var valueTextColor: Color {
        get {
            return valueColors[0]
        }
        set {
            valueColors.removeAll(keepingCapacity: false)
            valueColors.append(newValue)
        }
    }
    
    /// - returns: The color at the specified index that is used for drawing the values inside the chart. Uses modulus internally.
    public func valueTextColorAt(_ index: Int) -> Color {
        var index = index
        if index < 0 {
            index = 0
        }
        return valueColors[index % valueColors.count]
    }
    
    /// the font for the value-text labels
    public var valueFont: Font = Font.systemFont(ofSize: 7.0)
    
    /// The form to draw for this dataset in the legend.
    public var form = Legend.Form.default
    
    /// The form size to draw for this dataset in the legend.
    ///
    /// Return `NaN` to use the default legend form size.
    public var formSize: CGFloat = CGFloat.nan
    
    /// The line width for drawing the form of this dataset in the legend
    ///
    /// Return `NaN` to use the default legend form line width.
    public var formLineWidth: CGFloat = CGFloat.nan
    
    /// Line dash configuration for legend shapes that consist of lines.
    ///
    /// This is how much (in pixels) into the dash pattern are we starting from.
    public var formLineDashPhase: CGFloat = 0.0
    
    /// Line dash configuration for legend shapes that consist of lines.
    ///
    /// This is the actual dash pattern.
    /// I.e. [2, 3] will paint [--   --   ]
    /// [1, 3, 4, 2] will paint [-   ----  -   ----  ]
    public var formLineDashLengths: [CGFloat]? = nil
    
    /// Set this to true to draw y-values on the chart.
    ///
    /// - note: For bar and line charts: if `maxVisibleCount` is reached, no values will be drawn even if this is enabled.
    /// - returns: `true` if y-value drawing is enabled, `false` ifnot
    public var isDrawValuesEnabled = true
    
    /// Set this to true to draw y-icons on the chart.
    ///
    /// - note: For bar and line charts: if `maxVisibleCount` is reached, no icons will be drawn even if this is enabled.
    /// Returns true if y-icon drawing is enabled, false if not
    public var isDrawIconsEnabled = true
    
    /// Offset of icons drawn on the chart.
    ///
    /// For all charts except Pie and Radar it will be ordinary (x offset, y offset).
    ///
    /// For Pie and Radar chart it will be (y offset, distance from center offset); so if you want icon to be rendered under value, you should increase X component of CGPoint, and if you want icon to be rendered closet to center, you should decrease height component of CGPoint.
    public var iconsOffset = CGPoint(x: 0, y: 0)
    
    /// Set the visibility of this DataSet. If not visible, the DataSet will not be drawn to the chart upon refreshing it.
    public var visible = true
    
    /// - returns: `true` if this DataSet is visible inside the chart, or `false` ifit is currently hidden.
    public var isVisible: Bool {
        return visible
    }
    
    // MARK: - CustomStringConvertible
    
    public var description: String {
        return String(format: "%@, label: %@, %i entries", arguments: [NSStringFromClass(type(of: self)), self.label ?? "", self.count])
    }
    
    public var debugDescription: String {
        var desc = description + ":"
        
        for i in 0 ..< self.count {
            desc += "\n" + self[i].description
        }
        
        return desc
    }
}

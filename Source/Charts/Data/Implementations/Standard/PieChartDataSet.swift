//
//  PieChartDataSet.swift
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

//#if !os(OSX)
//    import UIKit
//#endif
//
//
//public protocol IPieChartDataSet: IChartDataSet
//{
//    // MARK: - Styling functions and accessors
//
//    /// the space in pixels between the pie-slices
//    /// **default**: 0
//    /// **maximum**: 20
//    var sliceSpace: CGFloat { get set }
//
//    /// When enabled, slice spacing will be 0.0 when the smallest value is going to be smaller than the slice spacing itself.
//    var automaticallyDisableSliceSpacing: Bool { get set }
//
//    /// indicates the selection distance of a pie slice
//    var selectionShift: CGFloat { get set }
//
//    var xValuePosition: PieChartDataSet.ValuePosition { get set }
//    var yValuePosition: PieChartDataSet.ValuePosition { get set }
//
//    /// When valuePosition is OutsideSlice, indicates line color
//    var valueLineColor: Color? { get set }
//
//    /// When valuePosition is OutsideSlice, indicates line width
//    var valueLineWidth: CGFloat { get set }
//
//    /// When valuePosition is OutsideSlice, indicates offset as percentage out of the slice size
//    var valueLinePart1OffsetPercentage: CGFloat { get set }
//
//    /// When valuePosition is OutsideSlice, indicates length of first half of the line
//    var valueLinePart1Length: CGFloat { get set }
//
//    /// When valuePosition is OutsideSlice, indicates length of second half of the line
//    var valueLinePart2Length: CGFloat { get set }
//
//    /// When valuePosition is OutsideSlice, this allows variable line length
//    var valueLineVariableLength: Bool { get set }
//
//    /// the font for the slice-text labels
//    var entryLabelFont: Font? { get set }
//
//    /// the color for the slice-text labels
//    var entryLabelColor: Color? { get set }
//}

open class PieChartDataSet: ChartDataSet
{
    public enum ValuePosition
    {
        case insideSlice
        case outsideSlice
    }
    
    fileprivate func initialize()
    {
        self.valueTextColor = .white
        self.valueFont = .systemFont(ofSize: 13.0)
    }
    
    public required init()
    {
        super.init()
        initialize()
    }
    
    public override init(values: [ChartDataEntry], label: String = "Data Set")
    {
        super.init(values: values, label: label)
        initialize()
    }
    
    public required init(arrayLiteral elements: ChartDataEntry...) {
        super.init(values: elements)
        initialize()
    }
    
    internal func calcMinMax(entry e: ChartDataEntry)
    {
        calcMinMaxY(entry: e)
    }
    
    // MARK: - Styling functions and accessors
    
    fileprivate var _sliceSpace = CGFloat(0.0)
    
    /// the space in pixels between the pie-slices
    /// **default**: 0
    /// **maximum**: 20
    open var sliceSpace: CGFloat
    {
        get
        {
            return _sliceSpace
        }
        set
        {
            var space = newValue
            if space > 20.0
            {
                space = 20.0
            }
            if space < 0.0
            {
                space = 0.0
            }
            _sliceSpace = space
        }
    }

    /// When enabled, slice spacing will be 0.0 when the smallest value is going to be smaller than the slice spacing itself.
    open var automaticallyDisableSliceSpacing: Bool = false
    
    /// indicates the selection distance of a pie slice
    open var selectionShift = CGFloat(18.0)
    
    open var xValuePosition: ValuePosition = .insideSlice
    open var yValuePosition: ValuePosition = .insideSlice
    
    /// When valuePosition is OutsideSlice, indicates line color
    open var valueLineColor: Color? = Color.black
    
    /// When valuePosition is OutsideSlice, indicates line width
    open var valueLineWidth: CGFloat = 1.0
    
    /// When valuePosition is OutsideSlice, indicates offset as percentage out of the slice size
    open var valueLinePart1OffsetPercentage: CGFloat = 0.75
    
    /// When valuePosition is OutsideSlice, indicates length of first half of the line
    open var valueLinePart1Length: CGFloat = 0.3
    
    /// When valuePosition is OutsideSlice, indicates length of second half of the line
    open var valueLinePart2Length: CGFloat = 0.4
    
    /// When valuePosition is OutsideSlice, this allows variable line length
    open var valueLineVariableLength: Bool = true
    
    /// the font for the slice-text labels
    open var entryLabelFont: Font? = nil
    
    /// the color for the slice-text labels
    open var entryLabelColor: Color? = nil
}

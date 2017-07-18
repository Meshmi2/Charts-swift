//
//  Highlight.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

public class Highlight {
    /// the x-value of the highlighted value
    private var _x = Double.nan
    
    /// the y-value of the highlighted value
    private var _y = Double.nan
    
    /// the x-pixel of the highlight
    private var _xPx = CGFloat.nan
    
    /// the y-pixel of the highlight
    private var _yPx = CGFloat.nan
    
    /// the index of the data object - in case it refers to more than one
    public var dataIndex = Int(-1)
    
    /// the index of the dataset the highlighted value is in
    private var _dataSetIndex = Int(0)
    
    /// index which value of a stacked bar entry is highlighted
    /// 
    /// **default**: -1
    private var _stackIndex = Int(-1)
    
    /// the axis the highlighted value belongs to
    private var _axis: YAxis.AxisDependency = .left
    
    /// the x-position (pixels) on which this highlight object was last drawn
    public var drawX: CGFloat = 0.0
    
    /// the y-position (pixels) on which this highlight object was last drawn
    public var drawY: CGFloat = 0.0
    
    /// - parameter x: the x-value of the highlighted value
    /// - parameter y: the y-value of the highlighted value
    /// - parameter xPx: the x-pixel of the highlighted value
    /// - parameter yPx: the y-pixel of the highlighted value
    /// - parameter dataIndex: the index of the Data the highlighted value belongs to
    /// - parameter dataSetIndex: the index of the DataSet the highlighted value belongs to
    /// - parameter stackIndex: references which value of a stacked-bar entry has been selected
    /// - parameter axis: the axis the highlighted value belongs to
    public init(
        x: Double, y: Double,
        xPx: CGFloat, yPx: CGFloat,
        dataIndex: Int,
        dataSetIndex: Int,
        stackIndex: Int,
        axis: YAxis.AxisDependency) {
        _x = x
        _y = y
        _xPx = xPx
        _yPx = yPx
        self.dataIndex = dataIndex
        _dataSetIndex = dataSetIndex
        _stackIndex = stackIndex
        _axis = axis
    }
    
    /// - parameter x: the x-value of the highlighted value
    /// - parameter y: the y-value of the highlighted value
    /// - parameter xPx: the x-pixel of the highlighted value
    /// - parameter yPx: the y-pixel of the highlighted value
    /// - parameter dataSetIndex: the index of the DataSet the highlighted value belongs to
    /// - parameter stackIndex: references which value of a stacked-bar entry has been selected
    /// - parameter axis: the axis the highlighted value belongs to
    public convenience init(
        x: Double, y: Double,
        xPx: CGFloat, yPx: CGFloat,
        dataSetIndex: Int,
        stackIndex: Int,
        axis: YAxis.AxisDependency) {
        self.init(x: x, y: y, xPx: xPx, yPx: yPx,
                  dataIndex: 0,
                  dataSetIndex: dataSetIndex,
                  stackIndex: stackIndex,
                  axis: axis)
    }
    
    /// - parameter x: the x-value of the highlighted value
    /// - parameter y: the y-value of the highlighted value
    /// - parameter xPx: the x-pixel of the highlighted value
    /// - parameter yPx: the y-pixel of the highlighted value
    /// - parameter dataIndex: the index of the Data the highlighted value belongs to
    /// - parameter dataSetIndex: the index of the DataSet the highlighted value belongs to
    /// - parameter stackIndex: references which value of a stacked-bar entry has been selected
    /// - parameter axis: the axis the highlighted value belongs to
    public init(
        x: Double, y: Double,
        xPx: CGFloat, yPx: CGFloat,
        dataSetIndex: Int,
        axis: YAxis.AxisDependency) {
        _x = x
        _y = y
        _xPx = xPx
        _yPx = yPx
        _dataSetIndex = dataSetIndex
        _axis = axis
    }
    
    /// - parameter x: the x-value of the highlighted value
    /// - parameter y: the y-value of the highlighted value
    /// - parameter dataSetIndex: the index of the DataSet the highlighted value belongs to
    public init(x: Double, y: Double, dataSetIndex: Int) {
        _x = x
        _y = y
        _dataSetIndex = dataSetIndex
    }
    
    /// - parameter x: the x-value of the highlighted value
    /// - parameter dataSetIndex: the index of the DataSet the highlighted value belongs to
    /// - parameter stackIndex: references which value of a stacked-bar entry has been selected
    public convenience init(x: Double, dataSetIndex: Int, stackIndex: Int) {
        self.init(x: x, y: Double.nan, dataSetIndex: dataSetIndex)
        _stackIndex = stackIndex
    }
    
    public var x: Double { return _x }
    public var y: Double { return _y }
    public var xPx: CGFloat { return _xPx }
    public var yPx: CGFloat { return _yPx }
    public var dataSetIndex: Int { return _dataSetIndex }
    public var stackIndex: Int { return _stackIndex }
    public var axis: YAxis.AxisDependency { return _axis }
    
    public var isStacked: Bool { return _stackIndex >= 0 }
    
    /// Sets the x- and y-position (pixels) where this highlight was last drawn.
    public func setDraw(x: CGFloat, y: CGFloat) {
        self.drawX = x
        self.drawY = y
    }
    
    /// Sets the x- and y-position (pixels) where this highlight was last drawn.
    public func setDraw(pt: CGPoint) {
        self.drawX = pt.x
        self.drawY = pt.y
    }
    
    // MARK
    
    public var description: String {
        return "Highlight, x: \(_x), y: \(_y), dataIndex (combined charts): \(dataIndex), dataSetIndex: \(_dataSetIndex), stackIndex (only stacked barentry): \(_stackIndex)"
    }
    
}

extension Highlight: Equatable {
    open static func ==(lhs: Highlight, rhs: Highlight) -> Bool {
        return lhs._x == rhs._x
            && lhs._y == rhs._y
            && lhs.dataIndex == rhs.dataIndex
            && lhs._dataSetIndex == rhs._dataSetIndex
            && lhs._stackIndex == rhs._stackIndex
    }
}

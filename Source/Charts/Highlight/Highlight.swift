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
    public private(set) var x: Double = .nan
    
    /// the y-value of the highlighted value
    public private(set) var y: Double = .nan
    
    /// the x-pixel of the highlight
    public private(set) var xPx: CGFloat = .nan
    
    /// the y-pixel of the highlight
    public private(set) var yPx: CGFloat = .nan
    
    /// the index of the data object - in case it refers to more than one
    public var dataIndex = -1
    
    /// the index of the dataset the highlighted value is in
    public private(set) var dataSetIndex = 0
    
    /// index which value of a stacked bar entry is highlighted
    /// 
    /// **default**: -1
    public private(set) var stackIndex = -1
    
    /// the axis the highlighted value belongs to
    public private(set) var axis: YAxis.AxisDependency = .left
    
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
        self.x = x
        self.y = y
        self.xPx = xPx
        self.yPx = yPx
        self.dataIndex = dataIndex
        self.dataSetIndex = dataSetIndex
        self.stackIndex = stackIndex
        self.axis = axis
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
        self.x = x
        self.y = y
        self.xPx = xPx
        self.yPx = yPx
        self.dataSetIndex = dataSetIndex
        self.axis = axis
    }
    
    /// - parameter x: the x-value of the highlighted value
    /// - parameter y: the y-value of the highlighted value
    /// - parameter dataSetIndex: the index of the DataSet the highlighted value belongs to
    public init(x: Double, y: Double, dataSetIndex: Int) {
        self.x = x
        self.y = y
        self.dataSetIndex = dataSetIndex
    }
    
    /// - parameter x: the x-value of the highlighted value
    /// - parameter dataSetIndex: the index of the DataSet the highlighted value belongs to
    /// - parameter stackIndex: references which value of a stacked-bar entry has been selected
    public convenience init(x: Double, dataSetIndex: Int, stackIndex: Int) {
        self.init(x: x, y: Double.nan, dataSetIndex: dataSetIndex)
        self.stackIndex = stackIndex
    }
    
    public var isStacked: Bool { return stackIndex >= 0 }
    
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
}

extension Highlight: CustomStringConvertible {
    public var description: String {
        return "Highlight, x: \(x), y: \(y), dataIndex (combined charts): \(dataIndex), dataSetIndex: \(dataSetIndex), stackIndex (only stacked barentry): \(stackIndex)"
    }
}
extension Highlight: Equatable {
    public static func ==(lhs: Highlight, rhs: Highlight) -> Bool {
        return lhs.x == rhs.x
            && lhs.y == rhs.y
            && lhs.dataIndex == rhs.dataIndex
            && lhs.dataSetIndex == rhs.dataSetIndex
            && lhs.stackIndex == rhs.stackIndex
    }
}

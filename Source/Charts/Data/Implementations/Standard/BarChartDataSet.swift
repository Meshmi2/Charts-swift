//
//  BarChartDataSet.swift
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

//public protocol IBarChartDataSet: IBarLineScatterCandleBubbleChartDataSet
//{
//    // MARK: - Data functions and accessors
//
//    // MARK: - Styling functions and accessors
//
//    /// - returns: `true` if this DataSet is stacked (stacksize > 1) or not.
//    var isStacked: Bool { get }
//
//    /// - returns: The maximum number of bars that can be stacked upon another in this DataSet.
//    var stackSize: Int { get }
//
//    /// the color used for drawing the bar-shadows. The bar shadows is a surface behind the bar that indicates the maximum value
//    var barShadowColor: Color { get set }
//
//    /// the width used for drawing borders around the bars. If borderWidth == 0, no border will be drawn.
//    var barBorderWidth : CGFloat { get set }
//
//    /// the color drawing borders around the bars.
//    var barBorderColor: Color { get set }
//
//    /// the alpha value (transparency) that is used for drawing the highlight indicator bar. min = 0.0 (fully transparent), max = 1.0 (fully opaque)
//    var highlightAlpha: CGFloat { get set }
//
//    /// array of labels used to describe the different values of the stacked bars
//    var stackLabels: [String] { get set }
//}

open class BarChartDataSet: BarLineScatterCandleBubbleChartDataSet
{
    fileprivate func initialize()
    {
        self.highlightColor = Color.black
        
        self.calcStackSize(entries: values as! [BarChartDataEntry])
        self.calcEntryCountIncludingStacks(entries: values as! [BarChartDataEntry])
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
    
    // MARK: - Data functions and accessors
    
    /// the maximum number of bars that are stacked upon each other, this value
    /// is calculated from the Entries that are added to the DataSet
    fileprivate var _stackSize = 1
    
    /// the overall entry count, including counting each stack-value individually
    fileprivate var _entryCountStacks = 0
    
    /// Calculates the total number of entries this DataSet represents, including
    /// stacks. All values belonging to a stack are calculated separately.
    fileprivate func calcEntryCountIncludingStacks(entries: [BarChartDataEntry])
    {
        _entryCountStacks = 0
        
        for i in 0 ..< entries.count
        {
            if let vals = entries[i].yValues
            {
                _entryCountStacks += vals.count
            }
            else
            {
                _entryCountStacks += 1
            }
        }
    }
    
    /// calculates the maximum stacksize that occurs in the Entries array of this DataSet
    fileprivate func calcStackSize(entries: [BarChartDataEntry])
    {
        for i in 0 ..< entries.count
        {
            if let vals = entries[i].yValues
            {
                if vals.count > _stackSize
                {
                    _stackSize = vals.count
                }
            }
        }
    }
    
    open func calcMinMax(entry e: ChartDataEntry)
    {
        guard let e = e as? BarChartDataEntry
            else { return }
        
        if !e.y.isNaN
        {
            if e.yValues == nil
            {
                if e.y < yMin
                {
                    yMin = e.y
                }
                
                if e.y > yMax
                {
                    yMax = e.y
                }
            }
            else
            {
                if -e.negativeSum < yMin
                {
                    yMin = -e.negativeSum
                }
                
                if e.positiveSum > yMax
                {
                    yMax = e.positiveSum
                }
            }
            
            calcMinMaxX(entry: e)
        }
    }
    
    /// - returns: The maximum number of bars that can be stacked upon another in this DataSet.
    open var stackSize: Int
    {
        return _stackSize
    }
    
    /// - returns: `true` if this DataSet is stacked (stacksize > 1) or not.
    open var isStacked: Bool
    {
        return _stackSize > 1 ? true : false
    }
    
    /// - returns: The overall entry count, including counting each stack-value individually
    open var entryCountStacks: Int
    {
        return _entryCountStacks
    }
    
    /// array of labels used to describe the different values of the stacked bars
    open var stackLabels: [String] = ["Stack"]
    
    // MARK: - Styling functions and accessors
    
    /// the color used for drawing the bar-shadows. The bar shadows is a surface behind the bar that indicates the maximum value
    open var barShadowColor = Color(red: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 1.0)

    /// the width used for drawing borders around the bars. If borderWidth == 0, no border will be drawn.
    open var barBorderWidth : CGFloat = 0.0

    /// the color drawing borders around the bars.
    open var barBorderColor = Color.black

    /// the alpha value (transparency) that is used for drawing the highlight indicator bar. min = 0.0 (fully transparent), max = 1.0 (fully opaque)
    open var highlightAlpha = CGFloat(120.0 / 255.0)
}

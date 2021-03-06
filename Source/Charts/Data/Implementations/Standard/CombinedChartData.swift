//
//  CombinedChartData.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

public class CombinedChartData: BarLineScatterCandleBubbleChartData {
    private var _lineData: LineChartData!
    private var _barData: BarChartData!
    private var _scatterData: ScatterChartData!
    private var _candleData: CandleChartData!
    private var _bubbleData: BubbleChartData!
        
    public var lineData: LineChartData! {
        get {
            return _lineData
        }
        set {
            _lineData = newValue
            notifyDataChanged()
        }
    }
    
    public var barData: BarChartData! {
        get {
            return _barData
        }
        set {
            _barData = newValue
            notifyDataChanged()
        }
    }
    
    public var scatterData: ScatterChartData! {
        get {
            return _scatterData
        }
        set {
            _scatterData = newValue
            notifyDataChanged()
        }
    }
    
    public var candleData: CandleChartData! {
        get {
            return _candleData
        }
        set {
            _candleData = newValue
            notifyDataChanged()
        }
    }
    
    public var bubbleData: BubbleChartData! {
        get {
            return _bubbleData
        }
        set {
            _bubbleData = newValue
            notifyDataChanged()
        }
    }
    
    public override func calcMinMax() {
        _dataSets.removeAll()
        
        _yMax = -Double.greatestFiniteMagnitude
        _yMin = Double.greatestFiniteMagnitude
        _xMax = -Double.greatestFiniteMagnitude
        _xMin = Double.greatestFiniteMagnitude
        
        _leftAxisMax = -Double.greatestFiniteMagnitude
        _leftAxisMin = Double.greatestFiniteMagnitude
        _rightAxisMax = -Double.greatestFiniteMagnitude
        _rightAxisMin = Double.greatestFiniteMagnitude
        
        let allData = self.allData
        
        for data in allData {
            data.calcMinMax()
            
            let sets = data.dataSets
            _dataSets.append(contentsOf: sets)
            
            if data.yMax > _yMax {
                _yMax = data.yMax
            }
            
            if data.yMin < _yMin {
                _yMin = data.yMin
            }
            
            if data.xMax > _xMax {
                _xMax = data.xMax
            }
            
            if data.xMin < _xMin {
                _xMin = data.xMin
            }
            
            if data.yMax > _leftAxisMax {
                _leftAxisMax = data.yMax
            }
            
            if data.yMin < _leftAxisMin {
                _leftAxisMin = data.yMin
            }
            
            if data.yMax > _rightAxisMax {
                _rightAxisMax = data.yMax
            }
            
            if data.yMin < _rightAxisMin {
                _rightAxisMin = data.yMin
            }
        }
    }
    
    /// - returns: All data objects in row: line-bar-scatter-candle-bubble if not null.
    public var allData: [ChartData] {
        var data = [ChartData]()
        // TODO:
        if lineData != nil {
            data.append(lineData)
        }
        if barData != nil {
            data.append(barData)
        }
        if scatterData != nil {
            data.append(scatterData)
        }
        if candleData != nil {
            data.append(candleData)
        }
        if bubbleData != nil {
            data.append(bubbleData)
        }
        
        return data
    }
    
    public func dataByIndex(_ index: Int) -> ChartData {
        return allData[index]
    }
    
    public func dataIndex(_ data: ChartData) -> Int? {
        return allData.index(where: { $0 === data })
    }
    
    public override func removeDataSet(_ dataSet: ChartDataSet) -> Bool {
        let datas = allData
        
        var success = false
        
        for data in datas {
            success = data.removeDataSet(dataSet)
            
            if success {
                break
            }
        }
        
        return success
    }
    
    public override func removeDataSetByIndex(_ index: Int) -> Bool {
        print("removeDataSet(index) not supported for CombinedData", terminator: "\n")
        return false
    }
    
    public override func removeEntry(_ entry: ChartDataEntry, dataSetIndex: Int) -> Bool {
        print("removeEntry(entry, dataSetIndex) not supported for CombinedData", terminator: "\n")
        return false
    }
    
    public override func removeEntry(xValue: Double, dataSetIndex: Int) -> Bool {
        print("removeEntry(xValue, dataSetIndex) not supported for CombinedData", terminator: "\n")
        return false
    }
    
    public override func notifyDataChanged() {
        _lineData?.notifyDataChanged()
        _barData?.notifyDataChanged()
        _scatterData?.notifyDataChanged()
        _candleData?.notifyDataChanged()
        _bubbleData?.notifyDataChanged()
        
        super.notifyDataChanged() // recalculate everything
    }
    
    
    /// Get the Entry for a corresponding highlight object
    ///
    /// - parameter highlight:
    /// - returns: The entry that is highlighted
    public override func entryForHighlight(_ highlight: Highlight) -> ChartDataEntry? {
        let dataObjects = allData
        
        guard highlight.dataIndex < dataObjects.endIndex else { return nil }
        
        let data = dataObjects[highlight.dataIndex]
        
        guard highlight.dataSetIndex < data.dataSetCount else { return nil }
        
        // The value of the highlighted entry could be NaN - if we are not interested in highlighting a specific value.
        return data.getDataSetByIndex(highlight.dataSetIndex)
            .entriesForXValue(highlight.x)
            .first { $0.y == highlight.y || highlight.y.isNaN }
    }
}

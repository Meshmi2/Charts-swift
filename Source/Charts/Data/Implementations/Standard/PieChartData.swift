//
//  PieData.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

public class PieChartData: ChartData {
    var dataSet: PieChartDataSet? {
        get {
            return dataSets.first as? PieChartDataSet
        }
        set {
            if newValue != nil {
                dataSets = [newValue!]
            }
            else {
                dataSets = []
            }
        }
    }
    
    public override func getDataSetByIndex(_ index: Int) -> ChartDataSet? {
        if index != 0 {
            return nil
        }
        return super.getDataSetByIndex(index)
    }
    
    public override func getDataSetByLabel(_ label: String, ignorecase: Bool) -> ChartDataSet? {
        if dataSets.count == 0 || dataSets[0].label == nil {
            return nil
        }
        
        if ignorecase {
            if (label.caseInsensitiveCompare(dataSets[0].label!) == ComparisonResult.orderedSame) {
                return dataSets[0]
            }
        }
        else {
            if label == dataSets[0].label {
                return dataSets[0]
            }
        }
        return nil
    }
    
    public override func entryForHighlight(_ highlight: Highlight) -> ChartDataEntry? {
        return dataSet?[Int(highlight.x)]
    }
    
    public override func addDataSet(_ d: ChartDataSet) {   
        super.addDataSet(d)
    }
    
    /// Removes the DataSet at the given index in the DataSet array from the data object.
    /// Also recalculates all minimum and maximum values.
    ///
    /// - returns: `true` if a DataSet was removed, `false` ifno DataSet could be removed.
    public override func removeDataSetByIndex(_ index: Int) -> Bool {
        if index >= _dataSets.count || index < 0 {
            return false
        }
        
        return false
    }
    
    /// - returns: The total y-value sum across all DataSet objects the this object represents.
    public var yValueSum: Double {
        guard let dataSet = dataSet else { return 0.0 }
        
        var yValueSum: Double = 0.0
        
        for i in 0..<dataSet.count {
            let entry = dataSet[i]
            yValueSum += entry.y
        }
        
        return yValueSum
    }
}

//
//  DefaultValueFormatter.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

public class DefaultValueFormatter: ValueFormatter {
    public typealias Block = (
        _ value: Double,
        _ entry: ChartDataEntry,
        _ dataSetIndex: Int,
        _ viewPortHandler: ViewPortHandler?) -> String
    
    public var block: Block?
    
    public var hasAutoDecimals = false
    
    private var _formatter: NumberFormatter?
    public var formatter: NumberFormatter? {
        get { return _formatter }
        set {
            hasAutoDecimals = false
            _formatter = newValue
        }
    }
    
    private var _decimals: Int?
    public var decimals: Int? {
        get { return _decimals }
        set {
            _decimals = newValue
            
            if let digits = newValue {
                self.formatter?.minimumFractionDigits = digits
                self.formatter?.maximumFractionDigits = digits
                self.formatter?.usesGroupingSeparator = true
            }
        }
    }
    
    public init() {
        self.formatter = NumberFormatter()
        hasAutoDecimals = true
    }
    
    public init(formatter: NumberFormatter) {
        self.formatter = formatter
    }
    
    public init(decimals: Int) {
        self.formatter = NumberFormatter()
        self.formatter?.usesGroupingSeparator = true
        self.decimals = decimals
        hasAutoDecimals = true
    }
    
    public init(block: @escaping Block) {        
        self.block = block
    }
        
    public func stringForValue(_ value: Double,
                               entry: ChartDataEntry,
                               dataSetIndex: Int,
                               viewPortHandler: ViewPortHandler?) -> String {
        return block?(value, entry, dataSetIndex, viewPortHandler)
            ?? (formatter?.string(from: NSNumber(floatLiteral: value))
                ?? "")
    }
    
}

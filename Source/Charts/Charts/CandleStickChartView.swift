//
//  CandleStickChartView.swift
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

/// Financial chart type that draws candle-sticks.
public class CandleStickChartView: BarLineChartViewBase, CandleChartDataProvider {
    override func initialize() {
        super.initialize()
        
        renderer = CandleStickChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: viewPortHandler)
        
        self.xAxis.spaceMin = 0.5
        self.xAxis.spaceMax = 0.5
    }
    
    // MARK: - CandleChartDataProvider
    
    public var candleData: CandleChartData? {
        return _data as? CandleChartData
    }
}

//
//  LineRadarChartDataSet.swift
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

//public protocol ILineRadarChartDataSet: ILineScatterCandleRadarChartDataSet
//{
//    // MARK: - Data functions and accessors
//
//    // MARK: - Styling functions and accessors
//
//    /// The color that is used for filling the line surface area.
//    var fillColor: Color { get set }
//
//    /// - returns: The object that is used for filling the area below the line.
//    /// **default**: nil
//    var fill: Fill? { get set }
//
//    /// The alpha value that is used for filling the line surface.
//    /// **default**: 0.33
//    var fillAlpha: CGFloat { get set }
//
//    /// line width of the chart (min = 0.0, max = 10)
//    ///
//    /// **default**: 1
//    var lineWidth: CGFloat { get set }
//
//    /// Set to `true` if the DataSet should be drawn filled (surface), and not just as a line.
//    /// Disabling this will give great performance boost.
//    /// Please note that this method uses the path clipping for drawing the filled area (with images, gradients and layers).
//    /// - returns: `true` if filled drawing is enabled, `false` ifnot
//    var isDrawFilledEnabled: Bool { get set }
//}

public class LineRadarChartDataSet: LineScatterCandleRadarChartDataSet {
    public required init() {
        super.init()
    }
    public required init(arrayLiteral elements: ChartDataEntry...) {
        super.init(values: elements)
    }
    
    public override init(values: [ChartDataEntry], label: String = "Data Set") {
        super.init(values: values, label: label)
    }
    
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// The color that is used for filling the line surface area.
    private var _fillColor = Color(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    
    /// The color that is used for filling the line surface area.
    public var fillColor: Color {
        get { return _fillColor }
        set {
            _fillColor = newValue
            fill = nil
        }
    }
    
    /// The object that is used for filling the area below the line.
    /// **default**: nil
    public var fill: Fill?
    
    /// The alpha value that is used for filling the line surface,
    /// **default**: 0.33
    public var fillAlpha = CGFloat(0.33)
    
    private var _lineWidth = CGFloat(1.0)
    
    /// line width of the chart (min = 0.0, max = 10)
    ///
    /// **default**: 1
    public var lineWidth: CGFloat {
        get {
            return _lineWidth
        }
        set {
            if newValue < 0.0 {
                _lineWidth = 0.0
            }
            else if newValue > 10.0 {
                _lineWidth = 10.0
            }
            else {
                _lineWidth = newValue
            }
        }
    }
    
    /// Set to `true` if the DataSet should be drawn filled (surface), and not just as a line.
    /// Disabling this will give great performance boost.
    /// Please note that this method uses the path clipping for drawing the filled area (with images, gradients and layers).
    /// - returns: `true` if filled drawing is enabled, `false` ifnot
    public var isDrawFilledEnabled = false
}

//
//  LineChartDataSet.swift
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


//public protocol ILineChartDataSet: ILineRadarChartDataSet
//{
//    // MARK: - Data functions and accessors
//
//    // MARK: - Styling functions and accessors
//
//    /// The drawing mode for this line dataset
//    ///
//    /// **default**: Linear
//    var mode: LineChartDataSet.Mode { get set }
//
//    /// Intensity for cubic lines (min = 0.05, max = 1)
//    ///
//    /// **default**: 0.2
//    var cubicIntensity: CGFloat { get set }
//
//    /// The radius of the drawn circles.
//    var circleRadius: CGFloat { get set }
//
//    /// The hole radius of the drawn circles.
//    var circleHoleRadius: CGFloat { get set }
//
//    var circleColors: [Color] { get set }
//
//    /// - returns: The color at the given index of the DataSet's circle-color array.
//    /// Performs a IndexOutOfBounds check by modulus.
//    func getCircleColor(atIndex: Int) -> Color?
//
//    /// Sets the one and ONLY color that should be used for this DataSet.
//    /// Internally, this recreates the colors array and adds the specified color.
//    func setCircleColor(_ color: Color)
//
//    /// Resets the circle-colors array and creates a new one
//    func resetCircleColors(_ index: Int)
//
//    /// If true, drawing circles is enabled
//    /// - returns: `true` if drawing circles for this DataSet is enabled, `false` ifnot
//    var isDrawCirclesEnabled: Bool { get set }
//
//    /// The color of the inner circle (the circle-hole).
//    var circleHoleColor: Color? { get set }
//
//    /// `true` if drawing circles for this DataSet is enabled, `false` ifnot
//    /// - returns: `true` if drawing the circle-holes is enabled, `false` ifnot.
//    var isDrawCircleHoleEnabled: Bool { get set }
//
//    /// This is how much (in pixels) into the dash pattern are we starting from.
//    var lineDashPhase: CGFloat { get }
//
//    /// This is the actual dash pattern.
//    /// I.e. [2, 3] will paint [--   --   ]
//    /// [1, 3, 4, 2] will paint [-   ----  -   ----  ]
//    var lineDashLengths: [CGFloat]? { get set }
//
//    /// Line cap type, default is CGLineCap.Butt
//    var lineCapType: CGLineCap { get set }
//
//    /// Sets a custom IFillFormatter to the chart that handles the position of the filled-line for each DataSet. Set this to null to use the default logic.
//    var fillFormatter: FillFormatter? { get set }
//}

public class LineChartDataSet: LineRadarChartDataSet {
    public enum Mode {
        case linear
        case stepped
        case cubicBezier
        case horizontalBezier
    }
    
    private func initialize() {
        // default color
        circleColors = [Color(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0)]
    }
    
    public required init() {
        super.init()
        initialize()
    }
    
    public override init(values: [ChartDataEntry], label: String = "Data Set") {
        super.init(values: values, label: label)
        initialize()
    }
    
    public required init(arrayLiteral elements: ChartDataEntry...) {
        super.init(values: elements)
        initialize()
    }
    
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// The drawing mode for this line dataset
    ///
    /// **default**: Linear
    public var mode: Mode = Mode.linear
    
    private var _cubicIntensity = CGFloat(0.2)
    
    /// Intensity for cubic lines (min = 0.05, max = 1)
    ///
    /// **default**: 0.2
    public var cubicIntensity: CGFloat {
        get {
            return _cubicIntensity
        }
        set {
            _cubicIntensity = newValue
            if _cubicIntensity > 1.0 {
                _cubicIntensity = 1.0
            }
            if _cubicIntensity < 0.05 {
                _cubicIntensity = 0.05
            }
        }
    }
        
    /// The radius of the drawn circles.
    public var circleRadius = CGFloat(8.0)
    
    /// The hole radius of the drawn circles
    public var circleHoleRadius = CGFloat(4.0)
    
    public var circleColors = [Color]()
    
    /// - returns: The color at the given index of the DataSet's circle-color array.
    /// Performs a IndexOutOfBounds check by modulus.
    public func getCircleColor(atIndex index: Int) -> Color? {
        let size = circleColors.count
        let index = index % size
        if index >= size {
            return nil
        }
        return circleColors[index]
    }
    
    /// Sets the one and ONLY color that should be used for this DataSet.
    /// Internally, this recreates the colors array and adds the specified color.
    public func setCircleColor(_ color: Color) {
        circleColors.removeAll(keepingCapacity: false)
        circleColors.append(color)
    }
    
    public func setCircleColors(_ colors: Color...) {
        circleColors.removeAll(keepingCapacity: false)
        circleColors.append(contentsOf: colors)
    }
    
    /// Resets the circle-colors array and creates a new one
    public func resetCircleColors(_ index: Int) {
        circleColors.removeAll(keepingCapacity: false)
    }
    
    /// If true, drawing circles is enabled
    /// - returns: `true` if drawing circles for this DataSet is enabled, `false` ifnot
    public var isDrawCirclesEnabled = true
    
    /// The color of the inner circle (the circle-hole).
    public var circleHoleColor: Color? = Color.white
    
    /// `true` if drawing circles for this DataSet is enabled, `false` ifnot
    /// - returns: `true` if drawing the circle-holes is enabled, `false` ifnot.
    public var isDrawCircleHoleEnabled = true
    
    /// This is how much (in pixels) into the dash pattern are we starting from.
    public var lineDashPhase = CGFloat(0.0)
    
    /// This is the actual dash pattern.
    /// I.e. [2, 3] will paint [--   --   ]
    /// [1, 3, 4, 2] will paint [-   ----  -   ----  ]
    public var lineDashLengths: [CGFloat]?
    
    /// Line cap type, default is CGLineCap.Butt
    public var lineCapType = CGLineCap.butt
    
    /// formatter for customizing the position of the fill-line
    private var _fillFormatter: FillFormatter = DefaultFillFormatter()
    
    /// Sets a custom IFillFormatter to the chart that handles the position of the filled-line for each DataSet. Set this to null to use the default logic.
    public var fillFormatter: FillFormatter? {
        get {
            return _fillFormatter
        }
        set {
            if newValue == nil {
                _fillFormatter = DefaultFillFormatter()
            }
            else {
                _fillFormatter = newValue!
            }
        }
    }    
}

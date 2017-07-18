//
//  ChartLimitLine.swift
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


/// The limit line is an additional feature for all Line, Bar and ScatterCharts.
/// It allows the displaying of an additional line in the chart that marks a certain maximum / limit on the specified axis (x- or y-axis).
public class ChartLimitLine: ComponentBase {
    public enum LabelPosition: Int {
        case leftTop
        case leftBottom
        case rightTop
        case rightBottom
    }
    
    /// limit / maximum (the y-value or xIndex)
    public var limit = Double(0.0)
    
    private var _lineWidth = CGFloat(2.0)
    public var lineColor = Color(red: 237.0/255.0, green: 91.0/255.0, blue: 91.0/255.0, alpha: 1.0)
    public var lineDashPhase = CGFloat(0.0)
    public var lineDashLengths: [CGFloat]?
    
    public var valueTextColor = Color.black
    public var valueFont = Font.systemFont(ofSize: 13.0)
    
    public var drawLabelEnabled = true
    public var label = ""
    public var labelPosition = LabelPosition.rightTop
    
    public override init() {
        super.init()
    }
    
    public init(limit: Double) {
        super.init()
        self.limit = limit
    }
    
    public init(limit: Double, label: String) {
        super.init()
        self.limit = limit
        self.label = label
    }
    
    /// set the line width of the chart (min = 0.2, max = 12); default 2
    public var lineWidth: CGFloat {
        get { return _lineWidth }
        set {
            switch newValue {
            case ..<0.2: _lineWidth = 0.2
            case 12.0...: _lineWidth = 12.0
            default: _lineWidth = newValue
            }
        }
    }
}

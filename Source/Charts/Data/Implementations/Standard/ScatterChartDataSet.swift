//
//  ScatterChartDataSet.swift
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

//public protocol IScatterChartDataSet: ILineScatterCandleRadarChartDataSet
//{
//    // MARK: - Data functions and accessors
//
//    // MARK: - Styling functions and accessors
//
//    /// - returns: The size the scatter shape will have
//    var scatterShapeSize: CGFloat { get }
//
//    /// - returns: The radius of the hole in the shape (applies to Square, Circle and Triangle)
//    /// Set this to <= 0 to remove holes.
//    /// **default**: 0.0
//    var scatterShapeHoleRadius: CGFloat { get }
//
//    /// - returns: Color for the hole in the shape. Setting to `nil` will behave as transparent.
//    /// **default**: nil
//    var scatterShapeHoleColor: Color? { get }
//
//    /// - returns: The IShapeRenderer responsible for rendering this DataSet.
//    var shapeRenderer: ShapeRenderer? { get }
//}

open class ScatterChartDataSet: LineScatterCandleRadarChartDataSet
{
    public enum Shape {
        case square
        case circle
        case triangle
        case cross
        case x
        case chevronUp
        case chevronDown
    }
    
    public required init() {
        super.init()
    }
    
    public required init(arrayLiteral elements: ChartDataEntry...) {
        super.init(values: elements)
    }
    
    public override init(values: [ChartDataEntry], label: String) {
        super.init(values: values, label: label)
    }
    
    /// The size the scatter shape will have
    open var scatterShapeSize = CGFloat(10.0)
    
    /// The radius of the hole in the shape (applies to Square, Circle and Triangle)
    /// **default**: 0.0
    open var scatterShapeHoleRadius: CGFloat = 0.0
    
    /// Color for the hole in the shape. Setting to `nil` will behave as transparent.
    /// **default**: nil
    open var scatterShapeHoleColor: Color? = nil
    
    /// Sets the ScatterShape this DataSet should be drawn with.
    /// This will search for an available ShapeRenderer and set this renderer for the DataSet
    open func setScatterShape(_ shape: Shape)
    {
        self.shapeRenderer = ScatterChartDataSet.renderer(forShape: shape)
    }
    
    /// The IShapeRenderer responsible for rendering this DataSet.
    /// This can also be used to set a custom IShapeRenderer aside from the default ones.
    /// **default**: `SquareShapeRenderer`
    open var shapeRenderer: ShapeRenderer? = SquareShapeRenderer()
    
    open class func renderer(forShape shape: Shape) -> ShapeRenderer
    {
        switch shape
        {
        case .square: return SquareShapeRenderer()
        case .circle: return CircleShapeRenderer()
        case .triangle: return TriangleShapeRenderer()
        case .cross: return CrossShapeRenderer()
        case .x: return XShapeRenderer()
        case .chevronUp: return ChevronUpShapeRenderer()
        case .chevronDown: return ChevronDownShapeRenderer()
        }
    }
}

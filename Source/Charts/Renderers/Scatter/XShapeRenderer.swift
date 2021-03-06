//
//  XShapeRenderer.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//
import Foundation

struct XShapeRenderer : ShapeRenderer {
    func renderShape(
        context: CGContext,
        dataSet: ScatterChartDataSet,
        point: CGPoint,
        color: Color) {
        let shapeSize = dataSet.scatterShapeSize
        let shapeHalf = shapeSize / 2.0
        
        context.setLineWidth(1.0)
        context.setStrokeColor(color.cgColor)
        
        context.beginPath()
        context.move(to: CGPoint(x: point.x - shapeHalf, y: point.y - shapeHalf))
        context.addLine(to: CGPoint(x: point.x + shapeHalf, y: point.y + shapeHalf))
        context.move(to: CGPoint(x: point.x + shapeHalf, y: point.y - shapeHalf))
        context.addLine(to: CGPoint(x: point.x - shapeHalf, y: point.y + shapeHalf))
        context.strokePath()
    }
}

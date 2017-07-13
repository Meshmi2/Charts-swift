//
//  MultipleLinesChartViewController.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import UIKit
import Charts

class MultipleLinesChartViewController: DemoBaseViewController {

    @IBOutlet var chartView: LineChartView!
    @IBOutlet var sliderX: UISlider!
    @IBOutlet var sliderY: UISlider!
    @IBOutlet var sliderTextX: UITextField!
    @IBOutlet var sliderTextY: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Multiple Lines Chart"
        self.options = [Option(key: .toggleValues, label: "Toggle Values"),
                        Option(key: .toggleFilled, label: "Toggle Filled"),
                        Option(key: .toggleCircles, label: "ToggleCircles"),
                        Option(key: .toggleCubic, label: "Toggle Cubic"),
                        Option(key: .toggleStepped, label: "Toggle Stepped"),
                        Option(key: .toggleHighlight, label: "Toggle Highlight"),
                        Option(key: .animateX, label: "Animate X"),
                        Option(key: .animateY, label: "Animate Y"),
                        Option(key: .animateXY, label: "Animate XY"),
                        Option(key: .saveToGallery, label: "Save to Camera Roll"),
                        Option(key: .togglePinchZoom, label: "Toggle PinchZoom"),
                        Option(key: .toggleAutoScaleMinMax, label: "Toggle auto scale min/max"),
                        Option(key: .toggleData, label: "Toggle Data")
        ]

        chartView.delegate = self
        
        chartView.chartDescription?.isEnabled = false

        chartView.leftAxis.isEnabled = false
        chartView.rightAxis.isDrawAxisLineEnabled = false
        chartView.xAxis.isDrawAxisLineEnabled = false
        
        chartView.isDrawBordersEnabled = false
        chartView.setScaleEnabled(true)

        var l = chartView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .vertical
        l.drawInside = false
        chartView.legend = l
        
        sliderX.value = 20
        sliderY.value = 100
        slidersValueChanged(nil)
    }
    
    override func updateChartData() {
        if self.shouldHideData {
            chartView.data = nil
            return
        }
        
        self.setDataCount(Int(sliderX.value), range: UInt32(sliderY.value))
    }
    
    // TODO: Refine data creation
    func setDataCount(_ count: Int, range: UInt32) {
        let colors = ChartColorTemplates.vordiplom[0...2]
        
        let block: (Int) -> ChartDataEntry = { (i) -> ChartDataEntry in
            let val = Double(arc4random_uniform(range) + 3)
            return ChartDataEntry(x: Double(i), y: val)
        }
        let dataSets = (0..<3).map { i -> LineChartDataSet in
            let yVals = (0..<count).map(block)
            let set = LineChartDataSet(values: yVals, label: "DataSet \(i)")
            set.lineWidth = 2.5
            set.circleRadius = 4
            set.circleHoleRadius = 2
            let color = colors[i % colors.count]
            set.setColor(color)
            set.setCircleColor(color)
            
            return set
        }
        
        dataSets[0].lineDashLengths = [5, 5]
        dataSets[0].colors = ChartColorTemplates.vordiplom
        dataSets[0].circleColors = ChartColorTemplates.vordiplom
        
        let data = LineChartData(dataSets: dataSets)
        data.setValueFont(.systemFont(ofSize: 7, weight: .light))
        chartView.data = data
    }
    
    override func optionTapped(key: Option.Key) {
        switch key {
        case .toggleFilled:
            for set in chartView.data!.dataSets as! [LineChartDataSet] {
                set.isDrawFilledEnabled = !set.isDrawFilledEnabled
            }
            chartView.setNeedsDisplay()
            
        case .toggleCircles:
            for set in chartView.data!.dataSets as! [LineChartDataSet] {
                set.isDrawCirclesEnabled = !set.isDrawCirclesEnabled
            }
            chartView.setNeedsDisplay()
            
        case .toggleCubic:
            for set in chartView.data!.dataSets as! [LineChartDataSet] {
                set.mode = (set.mode == .cubicBezier) ? .linear : .cubicBezier
            }
            chartView.setNeedsDisplay()
            
        case .toggleStepped:
            for set in chartView.data!.dataSets as! [LineChartDataSet] {
                set.mode = (set.mode == .stepped) ? .linear : .stepped
            }
            chartView.setNeedsDisplay()
            
        default:
            super.handleOption(key: key, forChartView: chartView)
        }
    }

    @IBAction func slidersValueChanged(_ sender: Any?) {
        sliderTextX.text = "\(Int(sliderX.value))"
        sliderTextY.text = "\(Int(sliderY.value))"
        
        self.updateChartData()
    }
}

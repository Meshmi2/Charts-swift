//
//  HorizontalBarChartViewController.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import UIKit
import Charts

class HorizontalBarChartViewController: DemoBaseViewController {

    @IBOutlet var chartView: HorizontalBarChartView!
    @IBOutlet var sliderX: UISlider!
    @IBOutlet var sliderY: UISlider!
    @IBOutlet var sliderTextX: UITextField!
    @IBOutlet var sliderTextY: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Horizontal Bar Char"
        self.options = [Option(key: .toggleValues, label: "Toggle Values"),
                        Option(key: .toggleIcons, label: "Toggle Icons"),
                        Option(key: .toggleHighlight, label: "Toggle Highlight"),
                        Option(key: .animateX, label: "Animate X"),
                        Option(key: .animateY, label: "Animate Y"),
                        Option(key: .animateXY, label: "Animate XY"),
                        Option(key: .saveToGallery, label: "Save to Camera Roll"),
                        Option(key: .togglePinchZoom, label: "Toggle PinchZoom"),
                        Option(key: .toggleAutoScaleMinMax, label: "Toggle auto scale min/max"),
                        Option(key: .toggleData, label: "Toggle Data"),
                        Option(key: .toggleBarBorders, label: "Toggle Bar Borders")
        ]
        
        self.setup(barLineChartView: chartView)

        chartView.delegate = self
        
        chartView.isDrawBarShadowEnabled = false
        chartView.isDrawValueAboveBarEnabled = true
        
        chartView.maxVisibleCount = 60
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.isDrawAxisLineEnabled = true
        xAxis.granularity = 10
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.isDrawAxisLineEnabled = true
        leftAxis.isDrawGridLinesEnabled = true
        leftAxis.axisMinimum = 0

        let rightAxis = chartView.rightAxis
        rightAxis.isEnabled = true
        rightAxis.labelFont = .systemFont(ofSize: 10)
        rightAxis.isDrawAxisLineEnabled = true
        rightAxis.axisMinimum = 0

        var l = chartView.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .square
        l.formSize = 8
        l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        l.xEntrySpace = 4
        chartView.legend = l
        
        chartView.fitBars = true

        sliderX.value = 12
        sliderY.value = 50
        slidersValueChanged(nil)
        
        chartView.animate(yAxisDuration: 2.5)
    }
    
    override func updateChartData() {
        if self.shouldHideData {
            chartView.data = nil
            return
        }
        
        self.setDataCount(Int(sliderX.value) + 1, range: UInt32(sliderY.value))
    }
    
    func setDataCount(_ count: Int, range: UInt32) {
        let barWidth = 9.0
        let spaceForBar = 10.0
        
        let yVals = (0..<count).map { (i) -> BarChartDataEntry in
            let mult = range + 1
            let val = Double(arc4random_uniform(mult))
            return BarChartDataEntry(x: Double(i)*spaceForBar, y: val, icon: #imageLiteral(resourceName: "icon"))
        }
        
        let set1 = BarChartDataSet(values: yVals, label: "DataSet")
        set1.isDrawIconsEnabled = false
        
        let data = BarChartData(dataSet: set1)
        data.setValueFont(UIFont(name:"HelveticaNeue-Light", size:10)!)
        data.barWidth = barWidth
        
        chartView.data = data
    }

    override func optionTapped(key: Option.Key) {
        super.handleOption(key: key, forChartView: chartView)
    }
    
    // MARK: - Actions
    @IBAction func slidersValueChanged(_ sender: Any?) {
        sliderTextX.text = "\(Int(sliderX.value))"
        sliderTextY.text = "\(Int(sliderY.value))"
        
        self.updateChartData()
    }
}

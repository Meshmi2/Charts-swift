//
//  DemoBaseViewController.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-03.
//  Copyright © 2017 jc. All rights reserved.
//

import UIKit
import Charts

struct Option {
    let key: Key
    let label: String
    
    // TODO: Turn in to struct and move extensions into appropriate classes
    enum Key {
        case toggleValues
        case toggleIcons
        case toggleHighlight
        case animateX
        case animateY
        case animateXY
        case saveToGallery
        case togglePinchZoom
        case toggleAutoScaleMinMax
        case toggleData
        case toggleBarBorders
        // CandleChart
        case toggleShadowColorSameAsCandle
        // CombinedChart
        case toggleLineValues
        case toggleBarValues
        case removeDataSet
        // CubicLineSampleFillFormatter
        case toggleFilled
        case toggleCircles
        case toggleCubic
        case toggleHorizontalCubic
        case toggleStepped
    }
}

class DemoBaseViewController: UIViewController {
    private var optionsTableView: UITableView? = nil
    let parties = ["Party A", "Party B", "Party C", "Party D", "Party E", "Party F",
                   "Party G", "Party H", "Party I", "Party J", "Party K", "Party L",
                   "Party M", "Party N", "Party O", "Party P", "Party Q", "Party R",
                   "Party S", "Party T", "Party U", "Party V", "Party W", "Party X",
                   "Party Y", "Party Z"]
    
    @IBOutlet weak var optionsButton: UIButton!
    var options: [Option]!
    
    var shouldHideData: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initialize()
    }
    
    private func initialize() {
        self.edgesForExtendedLayout = []
    }
    
    func optionTapped(key: Option.Key) {}
    
    func handleOption(key: Option.Key, forChartView chartView: ChartViewBase) {
        switch key {
        case .toggleValues:
            for set in chartView.data!.dataSets {
                set.isDrawValuesEnabled = !set.isDrawValuesEnabled
            }
            chartView.setNeedsDisplay()
            
        case .toggleIcons:
            for set in chartView.data!.dataSets {
                set.isDrawIconsEnabled = !set.isDrawIconsEnabled
            }
            chartView.setNeedsDisplay()
            
        case .toggleHighlight:
            chartView.data!.highlightEnabled = !chartView.data!.isHighlightEnabled
            chartView.setNeedsDisplay()
            
        case .animateX:
            chartView.animate(xAxisDuration: 3)
            
        case .animateY:
            chartView.animate(yAxisDuration: 3)
            
        case .animateXY:
            chartView.animate(xAxisDuration: 3, yAxisDuration: 3)
            
        case .saveToGallery:
            UIImageWriteToSavedPhotosAlbum(chartView.getChartImage(transparent: false)!, nil, nil, nil)
            
        case .togglePinchZoom:
            let barLineChart = chartView as! BarLineChartViewBase
            barLineChart.isPinchZoomEnabled = !barLineChart.isPinchZoomEnabled
            chartView.setNeedsDisplay()
            
        case .toggleAutoScaleMinMax:
            let barLineChart = chartView as! BarLineChartViewBase
            barLineChart.autoScaleMinMaxEnabled = !barLineChart.isAutoScaleMinMaxEnabled
            chartView.notifyDataSetChanged()
            
        case .toggleData:
            shouldHideData = !shouldHideData
            updateChartData()
            
        case .toggleBarBorders:
            for set in chartView.data!.dataSets {
                if let set = set as? IBarChartDataSet {
                    set.barBorderWidth = set.barBorderWidth == 1.0 ? 0.0 : 1.0
                }
            }
            chartView.setNeedsDisplay()
        default:
            break
        }
    }
    
    @IBAction func optionsButtonTapped(_ sender: Any) {
        if let optionsTableView = self.optionsTableView {
            optionsTableView.removeFromSuperview()
            self.optionsTableView = nil
            return
        }
        
        let optionsTableView = UITableView()
        optionsTableView.backgroundColor = UIColor(white: 0, alpha: 0.9)
        optionsTableView.delegate = self
        optionsTableView.dataSource = self
        
        optionsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.optionsTableView = optionsTableView
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(NSLayoutConstraint(item: optionsTableView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 40))
        
        constraints.append(NSLayoutConstraint(item: optionsTableView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: sender as! UIView,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 0))
        
        constraints.append(NSLayoutConstraint(item: optionsTableView,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: sender,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 5))
        
        self.view.addSubview(optionsTableView)
        constraints.forEach { $0.isActive = true }
        
        let constraint = NSLayoutConstraint(item: optionsTableView,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .height,
                                            multiplier: 1,
                                            constant: 220)
        constraint.isActive = true
    }
    
    func updateChartData() {
        fatalError("updateChartData not overridden")
    }
    
    func setup(pieChartView chartView: PieChartView) {
        chartView.usePercentValuesEnabled = true
        chartView.drawSlicesUnderHoleEnabled = false
        chartView.holeRadiusPercent = 0.58
        chartView.transparentCircleRadiusPercent = 0.61
        chartView.chartDescription?.isEnabled = false
        chartView.setExtraOffsets(left: 5, top: 10, right: 5, bottom: 5)
        
        chartView.drawCenterTextEnabled = true
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let centerText = NSMutableAttributedString(string: "Charts\nby Daniel Cohen Gindi")
        centerText.setAttributes([.font : UIFont(name: "HelveticaNeue-Light", size: 13)!,
                                  .paragraphStyle : paragraphStyle], range: NSRange(location: 0, length: centerText.length))
        centerText.addAttributes([.font : UIFont(name: "HelveticaNeue-Light", size: 11)!,
                                  .foregroundColor : UIColor.gray], range: NSRange(location: 10, length: centerText.length - 10))
        centerText.addAttributes([.font : UIFont(name: "HelveticaNeue-Light", size: 11)!,
                                  .foregroundColor : UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)], range: NSRange(location: centerText.length - 19, length: 19))
        chartView.centerAttributedText = centerText;
        
        chartView.drawHoleEnabled = true
        chartView.rotationAngle = 0
        chartView.rotationEnabled = true
        chartView.highlightPerTapEnabled = true
        
        var l = chartView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .vertical
        l.drawInside = false
        l.xEntrySpace = 7
        l.yEntrySpace = 0
        l.yOffset = 0
        chartView.legend = l
    }
    
    func setup(radarChartView chartView: RadarChartView) {
        chartView.chartDescription?.isEnabled = false
    }
    
    func setup(barLineChartView chartView: BarLineChartViewBase) {
        chartView.chartDescription?.isEnabled = false
        
        chartView.isDrawGridBackgroundEnabled = false
        
        chartView.isDragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.isPinchZoomEnabled = false
        
        // ChartYAxis *leftAxis = chartView.leftAxis;
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        
        chartView.rightAxis.isEnabled = false
    }
}

extension DemoBaseViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if optionsTableView != nil
        {
            return 1
        }
        
        return 0
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if optionsTableView != nil
        {
            return options.count
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if optionsTableView != nil
        {
            return 40.0;
        }
        
        return 44.0;
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell?.backgroundView = nil
            cell?.backgroundColor = .clear
            cell?.textLabel?.textColor = .white
        }
        cell?.textLabel?.text = self.options[indexPath.row].label
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if optionsTableView != nil
        {
            tableView.deselectRow(at: indexPath, animated: true)
            
            optionsTableView?.removeFromSuperview()
            self.optionsTableView = nil
            
            self.optionTapped(key: self.options[indexPath.row].key)
        }
        
    }
}

extension DemoBaseViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        NSLog("chartValueSelected");
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        NSLog("chartValueNothingSelected");
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
    }
}

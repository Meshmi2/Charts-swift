//
//  ChartViewBase.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//
//  Based on https://github.com/PhilJay/MPAndroidChart/commit/c42b880

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif


public protocol ChartViewDelegate: class {
    /// Called when a value has been selected inside the chart.
    /// - parameter entry: The selected Entry.
    /// - parameter highlight: The corresponding highlight object that contains information about the highlighted position such as dataSetIndex etc.
     func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight)
    
    // Called when nothing has been selected or an "un-select" has been made.
     func chartValueNothingSelected(_ chartView: ChartViewBase)
    
    // Callbacks when the chart is scaled / zoomed via pinch zoom gesture.
     func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat)
    
    // Callbacks when the chart is moved / translated via drag gesture.
     func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat)
}

public class ChartViewBase: NSUIView, ChartDataProvider, AnimatorDelegate {
    // MARK: - Properties
    
    /// - returns: The object representing all x-labels, this method can be used to
    /// acquire the XAxis object and modify it (e.g. change the position of the
    /// labels)
    public var xAxis: XAxis {
        return _xAxis
    }
    
    /// The default IValueFormatter that has been determined by the chart considering the provided minimum and maximum values.
    var _defaultValueFormatter: ValueFormatter? = DefaultValueFormatter(decimals: 0)
    
    /// object that holds all data that was originally set for the chart, before it was modified or any filtering algorithms had been applied
    var _data: ChartData?

    /// Deceleration friction coefficient in [0 ; 1] interval, higher values indicate that speed will decrease slowly, for example if it set to 0, it will stop immediately.
    /// 1 is an invalid value, and will be converted to 0.999 automatically.
    private var _dragDecelerationFrictionCoef: CGFloat = 0.9
    
    /// if true, units are drawn next to the values in the chart
    var _drawUnitInChart = false
    
    /// The object representing the labels on the x-axis
    var _xAxis: XAxis!
    
    /// The `Description` object of the chart.
    /// This should have been called just "description", but
    public var chartDescription: Description?
        
    /// The legend object containing all data associated with the legend
    public var legend: Legend = Legend()
    
    /// delegate to receive chart events
    open weak var delegate: ChartViewDelegate?
    
    /// text that is displayed when the chart is empty
    public var noDataText = "No chart data available."
    
    /// Font to be used for the no data text.
    public var noDataFont: Font! = Font(name: "HelveticaNeue", size: 12.0)
    
    /// color of the no data text
    public var noDataTextColor: Color = Color.black
    
    var _legendRenderer: LegendRenderer!
    
    /// object responsible for rendering the data
    var renderer: DataRenderer?
    
    public var highlighter: Highlighter?
    
    /// object that manages the bounds and drawing constraints of the chart
    /// - returns: The ViewPortHandler of the chart that is responsible for the
    /// content area of the chart and its offsets and dimensions.
    let viewPortHandler: ViewPortHandler = ViewPortHandler()
    
    //FIXME: ----
    /// object responsible for animations
    var _animator: Animator = Animator()
    
    /// flag that indicates if offsets calculation has already been done or not
    private var _offsetsCalculated = false
    
    /// array of Highlight objects that reference the highlighted slices in the chart
    var _indicesToHighlight = [Highlight]()
    
    /// `true` if drawing the marker is enabled when tapping on values
    /// (use the `marker` property to specify a marker)
    /// - returns: `true` if drawing the marker is enabled when tapping on values
    /// (use the `marker` property to specify a marker)
    public var isDrawMarkersEnabled = true
    
    /// The marker that is displayed when a value is clicked on the chart
    public var marker: Marker?
    
    private var _interceptTouchEvents = false
    
    /// An extra offset to be appended to the viewport's top
    public var extraTopOffset: CGFloat = 0.0
    
    /// An extra offset to be appended to the viewport's right
    public var extraRightOffset: CGFloat = 0.0
    
    /// An extra offset to be appended to the viewport's bottom
    public var extraBottomOffset: CGFloat = 0.0
    
    /// An extra offset to be appended to the viewport's left
    public var extraLeftOffset: CGFloat = 0.0
    
    public func setExtraOffsets(left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat) {
        extraLeftOffset = left
        extraTopOffset = top
        extraRightOffset = right
        extraBottomOffset = bottom
    }
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "bounds")
        self.removeObserver(self, forKeyPath: "frame")
    }
    
    func initialize() {
        #if os(iOS)
            self.backgroundColor = Color.clear
        #endif

        _animator.delegate = self

        viewPortHandler.setChartDimens(width: bounds.size.width, height: bounds.size.height)
        
        chartDescription = Description()
        
        _legendRenderer = LegendRenderer(viewPortHandler: viewPortHandler, legend: legend)
        
        _xAxis = XAxis()
        
        self.addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
        self.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
    }
    
    // MARK: - ChartViewBase
    
    /// The data for the chart
    public var data: ChartData? {
        get {
            return _data
        }
        set {
            _data = newValue
            _offsetsCalculated = false
            
            if _data == nil {
                return
            }
            
            // calculate how many digits are needed
            setupDefaultFormatter(min: _data!.getYMin(), max: _data!.getYMax())
            
            for set in _data!.dataSets {
                if set.needsFormatter || set.valueFormatter === _defaultValueFormatter {
                    set.valueFormatter = _defaultValueFormatter
                }
            }
            
            // let the chart know there is new data
            notifyDataSetChanged()
        }
    }
    
    /// Clears the chart from all data (sets it to null) and refreshes it (by calling setNeedsDisplay()).
    public func clear() {
        _data = nil
        _offsetsCalculated = false
        _indicesToHighlight.removeAll()
        lastHighlighted = nil
    
        setNeedsDisplay()
    }
    
    /// Removes all DataSets (and thereby Entries) from the chart. Does not set the data object to nil. Also refreshes the chart by calling setNeedsDisplay().
    public func clearValues() {
        _data?.clearValues()
        setNeedsDisplay()
    }

    /// - returns: `true` if the chart is empty (meaning it's data object is either null or contains no entries).
    public func isEmpty() -> Bool {
        guard let data = _data else { return true }

        if data.entryCount <= 0 {
            return true
        }
        else {
            return false
        }
    }
    
    /// Lets the chart know its underlying data has changed and should perform all necessary recalculations.
    /// It is crucial that this method is called everytime data is changed dynamically. Not calling this method can lead to crashes or unexpected behaviour.
    public func notifyDataSetChanged() {
        fatalError("notifyDataSetChanged() cannot be called on ChartViewBase")
    }
    
    /// Calculates the offsets of the chart to the border depending on the position of an eventual legend or depending on the length of the y-axis and x-axis labels and their position
    func calculateOffsets() {
        fatalError("calculateOffsets() cannot be called on ChartViewBase")
    }
    
    /// calcualtes the y-min and y-max value and the y-delta and x-delta value
    func calcMinMax() {
        fatalError("calcMinMax() cannot be called on ChartViewBase")
    }
    
    /// calculates the required number of digits for the values that might be drawn in the chart (if enabled), and creates the default value formatter
    func setupDefaultFormatter(min: Double, max: Double) {
        // check if a custom formatter is set or not
        var reference = Double(0.0)
        
        if let data = _data , data.entryCount >= 2 {
            reference = fabs(max - min)
        }
        else {
            let absMin = fabs(min)
            let absMax = fabs(max)
            reference = absMin > absMax ? absMin : absMax
        }
        
    
        if _defaultValueFormatter is DefaultValueFormatter {
            // setup the formatter with a new number of digits
            let digits = ChartUtils.decimals(reference)
            
            (_defaultValueFormatter as? DefaultValueFormatter)?.decimals
             = digits
        }
    }
    
    public override func draw(_ rect: CGRect) {
        let optionalContext = NSUIGraphicsGetCurrentContext()
        guard let context = optionalContext else { return }
        
        let frame = self.bounds

        if _data == nil && noDataText.characters.count > 0 {
            context.saveGState()
            defer { context.restoreGState() }
            
            ChartUtils.drawMultilineText(noDataText,
                                         at: CGPoint(x: frame.width / 2,
                                                     y: frame.height / 2),
                                         constrainedToSize: self.bounds.size,
                                         anchor: CGPoint(x: 0.5, y: 0.5),
                                         angleRadians: 0,
                                         attributes: [.font: noDataFont,
                                                      .foregroundColor: noDataTextColor],
                                         context: context)
            
            return
        }
        
        if !_offsetsCalculated {
            calculateOffsets()
            _offsetsCalculated = true
        }
    }
    
    /// Draws the description text in the bottom right corner of the chart (per default)
    func drawDescription(context: CGContext) {
        // check if description should be drawn
        guard
            let description = chartDescription,
            description.isEnabled,
            let descriptionText = description.text,
            descriptionText.characters.count > 0
            else { return }
        
        var position = description.position

        // if no position specified, draw on default position
        if position == nil {
            let frame = self.bounds
            position = CGPoint(
                x: frame.width - viewPortHandler.offsetRight - description.xOffset,
                y: frame.height - viewPortHandler.offsetBottom - description.yOffset - description.font.lineHeight)
        }
        
        var attrs = [NSAttributedStringKey : AnyObject]()
        
        attrs[.font] = description.font
        attrs[.foregroundColor] = description.textColor
        
        ChartUtils.drawText(descriptionText,
                            at: position!,
                            align: description.textAlign,
                            attributes: attrs,
                            context: context)
    }
    
    // MARK: - Highlighting
    
    /// - returns: The array of currently highlighted values. This might an empty if nothing is highlighted.
    public var highlighted: [Highlight] {
        return _indicesToHighlight
    }
    
    /// Flag that indicates if highlighting per tap (touch) is enabled
    /// Set this to false to prevent values from being highlighted by tap gesture.
    /// Values can still be highlighted via drag or programmatically.
    /// **default**: true
    /// - returns: `true` if values can be highlighted via tap gesture, `false` ifnot.
    public var isHighlightPerTapEnabled = true
    
    /// Checks if the highlight array is null, has a length of zero or if the first object is null.
    /// - returns: `true` if there are values to highlight, `false` ifthere are no values to highlight.
    public func valuesToHighlight() -> Bool {
        return _indicesToHighlight.count > 0
    }

    /// Highlights the values at the given indices in the given DataSets. Provide
    /// null or an empty array to undo all highlighting. 
    /// This should be used to programmatically highlight values.
    /// This method *will not* call the delegate.
    public func highlightValues(_ highs: [Highlight]?) {
        // set the indices to highlight
        _indicesToHighlight = highs ?? [Highlight]()
        
        if _indicesToHighlight.isEmpty {
            self.lastHighlighted = nil
        }
        else {
            self.lastHighlighted = _indicesToHighlight[0]
        }

        // redraw the chart
        setNeedsDisplay()
    }
    
    /// Highlights any y-value at the given x-value in the given DataSet.
    /// Provide -1 as the dataSetIndex to undo all highlighting.
    /// This method will call the delegate.
    /// - parameter x: The x-value to highlight
    /// - parameter dataSetIndex: The dataset index to search in
    public func highlightValue(x: Double, dataSetIndex: Int) {
        highlightValue(x: x, dataSetIndex: dataSetIndex, callDelegate: true)
    }
    
    /// Highlights the value at the given x-value and y-value in the given DataSet.
    /// Provide -1 as the dataSetIndex to undo all highlighting.
    /// This method will call the delegate.
    /// - parameter x: The x-value to highlight
    /// - parameter y: The y-value to highlight. Supply `NaN` for "any"
    /// - parameter dataSetIndex: The dataset index to search in
    public func highlightValue(x: Double, y: Double, dataSetIndex: Int) {
        highlightValue(x: x, y: y, dataSetIndex: dataSetIndex, callDelegate: true)
    }
    
    /// Highlights any y-value at the given x-value in the given DataSet.
    /// Provide -1 as the dataSetIndex to undo all highlighting.
    /// - parameter x: The x-value to highlight
    /// - parameter dataSetIndex: The dataset index to search in
    /// - parameter callDelegate: Should the delegate be called for this change
    public func highlightValue(x: Double, dataSetIndex: Int, callDelegate: Bool) {
        highlightValue(x: x, y: Double.nan, dataSetIndex: dataSetIndex, callDelegate: callDelegate)
    }
    
    /// Highlights the value at the given x-value and y-value in the given DataSet.
    /// Provide -1 as the dataSetIndex to undo all highlighting.
    /// - parameter x: The x-value to highlight
    /// - parameter y: The y-value to highlight. Supply `NaN` for "any"
    /// - parameter dataSetIndex: The dataset index to search in
    /// - parameter callDelegate: Should the delegate be called for this change
    public func highlightValue(x: Double, y: Double, dataSetIndex: Int, callDelegate: Bool) {
        guard let data = _data else {
            Swift.print("Value not highlighted because data is nil")
            return
        }
        
        if dataSetIndex < 0 || dataSetIndex >= data.dataSetCount {
            highlightValue(nil, callDelegate: callDelegate)
        }
        else {
            highlightValue(Highlight(x: x, y: y, dataSetIndex: dataSetIndex), callDelegate: callDelegate)
        }
    }
    
    /// Highlights the values represented by the provided Highlight object
    /// This method *will not* call the delegate.
    /// - parameter highlight: contains information about which entry should be highlighted
    public func highlightValue(_ highlight: Highlight?) {
        highlightValue(highlight, callDelegate: false)
    }

    /// Highlights the value selected by touch gesture.
    public func highlightValue(_ highlight: Highlight?, callDelegate: Bool) {
        var entry: ChartDataEntry?
        var h = highlight
        
        if h == nil {
            _indicesToHighlight.removeAll(keepingCapacity: false)
        }
        else {
            // set the indices to highlight
            entry = _data?.entryForHighlight(h!)
            if entry == nil {
                h = nil
                _indicesToHighlight.removeAll(keepingCapacity: false)
            }
            else {
                _indicesToHighlight = [h!]
            }
        }
        
        if callDelegate, let delegate = delegate {
            if h == nil {
                delegate.chartValueNothingSelected(self)
            }
            else {
                // notify the listener
                delegate.chartValueSelected(self, entry: entry!, highlight: h!)
            }
        }
        
        // redraw the chart
        setNeedsDisplay()
    }
    
    /// - returns: The Highlight object (contains x-index and DataSet index) of the
    /// selected value at the given touch point inside the Line-, Scatter-, or
    /// CandleStick-Chart.
    public func getHighlightByTouchPoint(_ pt: CGPoint) -> Highlight? {
        guard _data != nil else {
            Swift.print("Can't select by touch. No data set.")
            return nil
        }
        
        return self.highlighter?.getHighlight(x: pt.x, y: pt.y)
    }

    /// The last value that was highlighted via touch.
    public var lastHighlighted: Highlight?
  
    // MARK: - Markers

    /// draws all MarkerViews on the highlighted positions
    func drawMarkers(context: CGContext) {
        // if there is no marker view or drawing marker is disabled
        guard
            let marker = marker
            , isDrawMarkersEnabled &&
                valuesToHighlight()
            else { return }
        
        for i in 0 ..< _indicesToHighlight.count {
            let highlight = _indicesToHighlight[i]
            
            guard let
                set = data?.getDataSetByIndex(highlight.dataSetIndex),
                let e = _data?.entryForHighlight(highlight)
                else { continue }
            
            let entryIndex = set.entryIndex(entry: e)
            if entryIndex > Int(Double(set.count) * _animator.phaseX) {
                continue
            }

            let pos = getMarkerPosition(highlight: highlight)

            // check bounds
            if !viewPortHandler.isInBounds(x: pos.x, y: pos.y) {
                continue
            }

            // callbacks to update the content
            marker.refreshContent(entry: e, highlight: highlight)
            
            // draw the marker
            marker.draw(context: context, point: pos)
        }
    }
    
    /// - returns: The actual position in pixels of the MarkerView for the given Entry in the given DataSet.
    public func getMarkerPosition(highlight: Highlight) -> CGPoint {
        return CGPoint(x: highlight.drawX, y: highlight.drawY)
    }
    
    // MARK: - Animation
    
    /// - returns: The animator responsible for animating chart values.
    var chartAnimator: Animator! {
        return _animator
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easingX: an easing function for the animation on the x axis
    /// - parameter easingY: an easing function for the animation on the y axis
    public func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easingX: ChartEasingOption, easingY: ChartEasingOption) {
        _animator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingOptionX: easingX, easingOptionY: easingY)
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easingOptionX: the easing function for the animation on the x axis
    /// - parameter easingOptionY: the easing function for the animation on the y axis
    public func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easingOptionX: ChartEasingOption, easingOptionY: ChartEasingOption) {
        _animator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingOptionX: easingOptionX, easingOptionY: easingOptionY)
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easingOption: the easing function for the animation
    public func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easingOption: ChartEasingOption) {
        _animator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingOption: easingOption)
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    public func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval) {
        _animator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration)
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter easingOption: the easing function for the animation
    public func animate(xAxisDuration: TimeInterval, easingOption: ChartEasingOption) {
        _animator.animate(xAxisDuration: xAxisDuration, easingOption: easingOption)
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    public func animate(xAxisDuration: TimeInterval) {
        _animator.animate(xAxisDuration: xAxisDuration)
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easingOption: the easing function for the animation
    public func animate(yAxisDuration: TimeInterval, easingOption: ChartEasingOption) {
        _animator.animate(yAxisDuration: yAxisDuration, easingOption: easingOption)
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter yAxisDuration: duration for animating the y axis
    public func animate(yAxisDuration: TimeInterval) {
        _animator.animate(yAxisDuration: yAxisDuration)
    }
    
    // MARK: - Accessors

    /// - returns: The current y-max value across all DataSets
    public var chartYMax: Double {
        return _data?.yMax ?? 0.0
    }

    /// - returns: The current y-min value across all DataSets
    public var chartYMin: Double {
        return _data?.yMin ?? 0.0
    }
    
    public var chartXMax: Double {
        return _xAxis._axisMaximum
    }
    
    public var chartXMin: Double {
        return _xAxis._axisMinimum
    }
    
    public var xRange: Double {
        return _xAxis.axisRange
    }
    
    /// *
    /// - note: (Equivalent of getCenter() in MPAndroidChart, as center is already a standard in iOS that returns the center point relative to superview, and MPAndroidChart returns relative to self)*
    /// - returns: The center point of the chart (the whole View) in pixels.
    public var midPoint: CGPoint {
        let bounds = self.bounds
        return CGPoint(x: bounds.origin.x + bounds.size.width / 2.0, y: bounds.origin.y + bounds.size.height / 2.0)
    }
    
    /// - returns: The center of the chart taking offsets under consideration. (returns the center of the content rectangle)
    public var centerOffsets: CGPoint {
        return viewPortHandler.contentCenter
    }
    
    /// - returns: The renderer object responsible for rendering / drawing the Legend.
    var legendRenderer: LegendRenderer! {
        return _legendRenderer
    }
    
    /// - returns: The rectangle that defines the borders of the chart-value surface (into which the actual values are drawn).
    public var contentRect: CGRect {
        return viewPortHandler.contentRect
    }
    
    /// - returns: The bitmap that represents the chart.
    public func getChartImage(transparent: Bool) -> Image? {
        NSUIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque || !transparent, NSUIMainScreen()?.nsuiScale ?? 1.0)
        
        guard let context = NSUIGraphicsGetCurrentContext()
            else { return nil }
        
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: bounds.size)
        
        if isOpaque || !transparent {
            // Background color may be partially transparent, we must fill with white if we want to output an opaque image
            context.setFillColor(Color.white.cgColor)
            context.fill(rect)
            
            if let backgroundColor = self.backgroundColor {
                context.setFillColor(backgroundColor.cgColor)
                context.fill(rect)
            }
        }
        
        nsuiLayer?.render(in: context)
        
        let image = NSUIGraphicsGetImageFromCurrentImageContext()
        
        NSUIGraphicsEndImageContext()
        
        return image
    }
    
    public enum ImageFormat {
        case jpeg
        case png
    }
    
    /// Saves the current chart state with the given name to the given path on
    /// the sdcard leaving the path empty "" will put the saved file directly on
    /// the SD card chart is saved as a PNG image, example:
    /// saveToPath("myfilename", "foldername1/foldername2")
    ///
    /// - parameter to: path to the image to save
    /// - parameter format: the format to save
    /// - parameter compressionQuality: compression quality for lossless formats (JPEG)
    ///
    /// - returns: `true` if the image was saved successfully
    public func save(to path: String, format: ImageFormat, compressionQuality: Double) -> Bool {
        guard let image = getChartImage(transparent: format != .jpeg)
            else { return false }
        
        var imageData: Data!
        switch format {
        case .png:
            imageData = NSUIImagePNGRepresentation(image)
            break
            
        case .jpeg:
            imageData = NSUIImageJPEGRepresentation(image, CGFloat(compressionQuality))
            break
        }
        
        do {
            try imageData.write(to: URL(fileURLWithPath: path), options: .atomic)
        }
        catch {
            return false
        }
        
        return true
    }
    
    var _viewportJobs = [ViewPortJob]()
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "bounds" || keyPath == "frame" {
            let bounds = self.bounds
            
            if (bounds.size.width != viewPortHandler.chartWidth ||
                bounds.size.height != viewPortHandler.chartHeight) {
                viewPortHandler.setChartDimens(width: bounds.size.width, height: bounds.size.height)
                
                // This may cause the chart view to mutate properties affecting the view port -- lets do this
                // before we try to run any pending jobs on the view port itself
                notifyDataSetChanged()

                // Finish any pending viewport changes
                while (!_viewportJobs.isEmpty) {
                    let job = _viewportJobs.remove(at: 0)
                    job.doJob()
                }
            }
        }
    }
    
    public func removeViewportJob(_ job: ViewPortJob) {
        if let index = _viewportJobs.index(where: { $0 === job }) {
            _viewportJobs.remove(at: index)
        }
    }
    
    public func clearAllViewportJobs() {
        _viewportJobs.removeAll(keepingCapacity: false)
    }
    
    public func addViewportJob(_ job: ViewPortJob) {
        if viewPortHandler.hasChartDimens {
            job.doJob()
        }
        else {
            _viewportJobs.append(job)
        }
    }
    
    /// If set to true, chart continues to scroll after touch up
    /// **default**: true
    /// - returns: `true` if chart continues to scroll after touch up, `false` ifnot.
    public var isDragDecelerationEnabled = true

    /// Deceleration friction coefficient in [0 ; 1] interval, higher values indicate that speed will decrease slowly, for example if it set to 0, it will stop immediately.
    /// 1 is an invalid value, and will be converted to 0.999 automatically.
    /// 
    /// **default**: true
    public var dragDecelerationFrictionCoef: CGFloat {
        get {
            return _dragDecelerationFrictionCoef
        }
        set {
            var val = newValue
            if val < 0.0 {
                val = 0.0
            }
            if val >= 1.0 {
                val = 0.999
            }
            
            _dragDecelerationFrictionCoef = val
        }
    }
    
    /// The maximum distance in screen pixels away from an entry causing it to highlight.
    /// **default**: 500.0
    public var maxHighlightDistance: CGFloat = 500.0
    
    /// the number of maximum visible drawn values on the chart only active when `drawValuesEnabled` is enabled
    public var maxVisibleCount: Int {
        return Int(INT_MAX)
    }
    
    // MARK: - AnimatorDelegate
    
    func animatorUpdated(_ chartAnimator: Animator) {
        setNeedsDisplay()
    }
    
    func animatorStopped(_ chartAnimator: Animator) {
        
    }
    
    // MARK: - Touches
    
    public override func nsuiTouchesBegan(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
        if !_interceptTouchEvents {
            super.nsuiTouchesBegan(touches, withEvent: event)
        }
    }
    
    public override func nsuiTouchesMoved(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
        if !_interceptTouchEvents {
            super.nsuiTouchesMoved(touches, withEvent: event)
        }
    }
    
    public override func nsuiTouchesEnded(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
        if !_interceptTouchEvents {
            super.nsuiTouchesEnded(touches, withEvent: event)
        }
    }
    
    public override func nsuiTouchesCancelled(_ touches: Set<NSUITouch>?, withEvent event: NSUIEvent?) {
        if !_interceptTouchEvents {
            super.nsuiTouchesCancelled(touches, withEvent: event)
        }
    }
}

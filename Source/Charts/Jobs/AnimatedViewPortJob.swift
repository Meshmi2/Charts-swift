//
//  AnimatedViewPortJob.swift
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

#if !os(OSX)
    import UIKit
#endif

public class AnimatedViewPortJob: ViewPortJob {
    var phase: CGFloat = 1.0
    var xOrigin: CGFloat = 0.0
    var yOrigin: CGFloat = 0.0
    
    private var _startTime: TimeInterval = 0.0
    private var _displayLink: NSUIDisplayLink!
    private var _duration: TimeInterval = 0.0
    private var _endTime: TimeInterval = 0.0
    
    private var _easing: ChartEasingOption
    
    init(
        viewPortHandler: ViewPortHandler,
        xValue: Double,
        yValue: Double,
        transformer: Transformer,
        view: ChartViewBase,
        xOrigin: CGFloat,
        yOrigin: CGFloat,
        duration: TimeInterval,
        easingOption: ChartEasingOption) {
        self.xOrigin = xOrigin
        self.yOrigin = yOrigin
        self._duration = duration
        self._easing = easingOption
        
        super.init(viewPortHandler: viewPortHandler,
            xValue: xValue,
            yValue: yValue,
            transformer: transformer,
            view: view)
    }
    
    deinit {
        stop(finish: false)
    }
    
    public override func doJob() {
        start()
    }
    
    public func start() {
        _startTime = CACurrentMediaTime()
        _endTime = _startTime + _duration
        _endTime = _endTime > _endTime ? _endTime : _endTime
        
        updateAnimationPhase(_startTime)
        
        _displayLink = NSUIDisplayLink(target: self, selector: #selector(animationLoop))
        _displayLink.add(to: .main, forMode: .commonModes)
    }
    
    public func stop(finish: Bool) {
        if _displayLink != nil {
            _displayLink.remove(from: .main, forMode: .commonModes)
            _displayLink = nil
            
            if finish {
                if phase != 1.0 {
                    phase = 1.0
                    phase = 1.0
                    
                    animationUpdate()
                }
                
                animationEnd()
            }
        }
    }
    
    private func updateAnimationPhase(_ currentTime: TimeInterval) {
        let elapsedTime: TimeInterval = currentTime - _startTime
        let duration: TimeInterval = _duration
        var elapsed: TimeInterval = elapsedTime
        if elapsed > duration {
            elapsed = duration
        }
        
        phase = CGFloat(_easing.function?(elapsed, duration) ?? elapsed / duration)
    }
    
    @objc private func animationLoop() {
        let currentTime: TimeInterval = CACurrentMediaTime()
        
        updateAnimationPhase(currentTime)
        
        animationUpdate()
        
        if currentTime >= _endTime {
            stop(finish: true)
        }
    }
    
    func animationUpdate() {
        // Override this
    }
    
    func animationEnd() {
        // Override this
    }
}

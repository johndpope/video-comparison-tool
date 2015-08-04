//
//  JMSRangeSlider.swift
//  JMSRangeSlider
//
//  Created by Matthieu Collé on 23/07/2015.
//  Copyright © 2015 JohnMcNeil Studio. All rights reserved.
//

import Cocoa
import QuartzCore

public enum JMSRangeSliderDirection: Int {
    
    case Horizontal = 1
    case Vertical
    
}

public enum JMSRangeSliderCellsSide: Int {
    
    case Top = 1
    case Bottom
    case Left
    case Right
    
}

public class JMSRangeSlider: NSControl {

    private var previousLocation: CGPoint = CGPoint()
    
    private let trackLayer: RangeSliderTrackLayer = RangeSliderTrackLayer()
    private let lowerCellLayer: RangeSliderCellLayer = RangeSliderCellLayer()
    private let upperCellLayer: RangeSliderCellLayer = RangeSliderCellLayer()
    
    // Slider Direction ( Horizontal / Vertical )
    public var direction: JMSRangeSliderDirection = JMSRangeSliderDirection.Horizontal {
        didSet {
            // Default values 
            // Left side when vertical position
            // Top side when horizontal position
            if direction == JMSRangeSliderDirection.Vertical {
                if cellsSide != JMSRangeSliderCellsSide.Left || cellsSide != JMSRangeSliderCellsSide.Right {
                    cellsSide = JMSRangeSliderCellsSide.Left
                }
            } else {
                if cellsSide != JMSRangeSliderCellsSide.Top || cellsSide != JMSRangeSliderCellsSide.Bottom {
                    cellsSide = JMSRangeSliderCellsSide.Top
                }
            }
            updateLayerFrames()
        }
    }
    
    // Cells side ( Top / Bottom / Left / Right )
    public var cellsSide: JMSRangeSliderCellsSide = JMSRangeSliderCellsSide.Top {
        didSet {
            updateLayerFrames()
        }
    }
    
    // Slider minimum value
    public var minValue: Double = 0.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    // Slider maximum value
    public var maxValue: Double = 1.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    // Slider lower value
    public var lowerValue: Double = 0.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    // Slider upper value
    public var upperValue: Double = 1.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    // Cell width
    public var cellWidth: CGFloat = 20.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    // Cell height
    public var cellHeight: CGFloat = 20.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    // Frame
    public override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    // Track thickness
    public var trackThickness: CGFloat = 10.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    // Track tint color
    public var trackTintColor: NSColor = NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }

    // Track highlight tint color
    public var trackHighlightTintColor: NSColor = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }

    // Cell tint color
    public var cellTintColor: NSColor = NSColor.whiteColor() {
        didSet {
            lowerCellLayer.setNeedsDisplay()
            upperCellLayer.setNeedsDisplay()
        }
    }

    // Corner radius
    public var cornerRadius: CGFloat = 1.0 {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    
    // INIT
    
    public convenience init() {
        self.init(frame: CGRectZero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.wantsLayer = true
        
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = (NSScreen.mainScreen()?.backingScaleFactor)!
        layer?.addSublayer(trackLayer)
        
        lowerCellLayer.rangeSlider = self
        lowerCellLayer.cellPosition = CellPosition.Lower
        lowerCellLayer.contentsScale = (NSScreen.mainScreen()?.backingScaleFactor)!
        layer?.addSublayer(lowerCellLayer)
        
        upperCellLayer.rangeSlider = self
        upperCellLayer.cellPosition = CellPosition.Upper
        upperCellLayer.contentsScale = (NSScreen.mainScreen()?.backingScaleFactor)!
        layer?.addSublayer(upperCellLayer)
        
        updateLayerFrames()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    // OVERRIDE
    
    public override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
    public override func mouseDown(evt: NSEvent) {
        let location = evt.locationInWindow
        previousLocation = convertPoint(location, fromView: nil)
        
        if lowerCellLayer.frame.contains(previousLocation) {
            lowerCellLayer.highlighted = true
        } else if upperCellLayer.frame.contains(previousLocation) {
            upperCellLayer.highlighted = true
        }
    }
    
    public override func mouseDragged(evt: NSEvent) {
        
        let location = evt.locationInWindow
        let pointInView = convertPoint(location, fromView: nil)

        // Get delta
        let deltaLocation = self.isVertical() ? Double(pointInView.y - previousLocation.y) : Double(pointInView.x - previousLocation.x)
        
        let deltaValue = (maxValue - minValue) * deltaLocation / (self.isVertical() ? Double(bounds.height - cellHeight) : Double(bounds.width - cellWidth))
        
        previousLocation = pointInView
        
        // Update values
        if lowerCellLayer.highlighted {
            lowerValue += deltaValue
            lowerValue = boundValue(lowerValue, toLowerValue: minValue, upperValue: upperValue)
        } else if upperCellLayer.highlighted {
            upperValue += deltaValue
            upperValue = boundValue(upperValue, toLowerValue: lowerValue, upperValue: maxValue)
        }
        
        updateLayerFrames()
        
        // Notify
        NSApp.sendAction(self.action, to: self.target, from: self)
        
    }
    
    public override func mouseUp(evt: NSEvent) {
        lowerCellLayer.highlighted = false
        upperCellLayer.highlighted = false
    }
    
    // Is Vertical slider ?
    public func isVertical() -> Bool {
        return self.direction == JMSRangeSliderDirection.Vertical
    }
    
    
    // PUBLIC
    
    // @function    updateLayerFrames
    //
    private func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let lowerCellCenter = CGFloat(positionForValue(lowerValue))
        let upperCellCenter = CGFloat(positionForValue(upperValue))
        
        // Is vertical ?
        if self.isVertical() {
            trackLayer.frame = CGRectMake(self.cellWidth, self.cellHeight, self.trackThickness, bounds.height - 2 * self.cellHeight)
            
            lowerCellLayer.frame = CGRect(x: 0, y: lowerCellCenter, width: cellWidth, height: cellHeight)
            upperCellLayer.frame = CGRect(x: 0, y: upperCellCenter + cellHeight, width: cellWidth, height: cellHeight)
            
            // If Cells on the right side
            if cellsSide == JMSRangeSliderCellsSide.Right {
                lowerCellLayer.frame.origin.x = trackLayer.frame.origin.x + trackLayer.frame.width
                upperCellLayer.frame.origin.x = trackLayer.frame.origin.x + trackLayer.frame.width
            }
            
        // Is Horizontal ?
        } else {
            trackLayer.frame = CGRectMake(self.cellWidth, self.cellHeight, bounds.width - 2 * cellWidth, self.trackThickness)
            
            let cellPosY: CGFloat = trackLayer.frame.origin.y + self.trackThickness
            
            lowerCellLayer.frame = CGRect(x: lowerCellCenter, y: cellPosY, width: cellWidth, height: cellHeight)
            upperCellLayer.frame = CGRect(x: upperCellCenter + cellWidth, y: cellPosY, width: cellWidth, height: cellHeight)
            
            if cellsSide == JMSRangeSliderCellsSide.Bottom {
                lowerCellLayer.frame.origin.y = self.trackLayer.frame.origin.y - self.cellHeight
                upperCellLayer.frame.origin.y = self.trackLayer.frame.origin.y - self.cellHeight
            }
        }
        
        trackLayer.setNeedsDisplay()
        lowerCellLayer.setNeedsDisplay()
        upperCellLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    
    // INTERNAL
    
    // @function    positionForValue
    //
    internal func positionForValue(value: Double) -> Double {
        if self.isVertical() {
            return Double(bounds.height - 2 * cellHeight) * (value - minValue) / (maxValue - minValue)
        } else {
            return Double(bounds.width - 2 * cellWidth) * (value - minValue) / (maxValue - minValue)
        }
    }
    
    
    // @function    boundValue
    //
    internal func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
}

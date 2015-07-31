//
//  SplitSlider.swift
//  JMS Video QC Tool
//
//  Created by Matthieu Collé on 22/07/2015.
//  Copyright © 2015 JohnMcNeil Studio. All rights reserved.
//

import Cocoa

enum SliderOrientation: Int {
    
    case Horizontal = 1
    case Vertical
    
}

protocol SplitSliderDelegate {
    
//    func updateSplitSlider(orientation: SliderOrientation, value: Float)
    
}

class SplitSlider: NSSlider {

    var delegate: SplitSliderDelegate?
    var orientation: SliderOrientation = .Horizontal
    
    // OVERRIDE
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.minValue = 0
        self.maxValue = 100
        self.floatValue = 50
        self.action = "scrubSplitSlider:"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // Scrub Split Slider Event
    func scrubSplitSlider(sender: NSSlider) {
        
        let evt : NSEvent = NSApplication.sharedApplication().currentEvent!
        
        switch evt.type {
            
        case NSEventType.LeftMouseDown:
            
            break
            
        case NSEventType.LeftMouseUp:
//            self.delegate?.updateSplitSlider(self.orientation, value: (self.cell?.floatValue)!)
            break
            
        case NSEventType.LeftMouseDragged:
//            self.delegate?.updateSplitSlider(self.orientation, value: (self.cell?.floatValue)!)
            break
            
        default:
            break
            
        }
        
    }
    
}

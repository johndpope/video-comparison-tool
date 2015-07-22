//
//  Timeline.swift
//  JMS Video QC Tool
//
//  Created by Matthieu Collé on 20/07/2015.
//  Copyright © 2015 JohnMcNeil Studio. All rights reserved.
//

import Cocoa

// Timeline protocol
protocol TimelineControllerDelegate {
    
    func pause()
    func play()
    func volume(volume: Float)
    func seek(time: Float64)
    
}

class Timeline: NSView {
    
    // Outlets
    @IBOutlet weak var pauseBtn: NSButton?
    @IBOutlet weak var muteBtn: NSButton?
    
    @IBOutlet weak var seekBar: NSSlider?
    @IBOutlet weak var totalTime: NSTextField?
    @IBOutlet weak var currentTime: NSTextField?
    
    var delegate: TimelineControllerDelegate?
    
    
    // GETTERS / SETTERS
    
    var seekBarMaxValue: Int64? {
        didSet {
            self.seekBar?.maxValue = Double(self.seekBarMaxValue!)
        }
    }
    
    // PRIVATE VARS
    private var _isPlaying: Bool = false
    private var _isMuted: Bool = false
    private var _volume: Float = 1.0
    

    // OVERRIDE

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.initElements()
        self.wantsLayer = true
    }
    
    
    override func makeBackingLayer() -> CALayer {
        self.layer = CALayer()
        return self.layer!
    }
    
    
    // PRIVATE FUNCTIONS
    
    // Init elements
    internal func initElements() {
        self.initSeekBar()
    }
    
    // Init seek bar
    internal func initSeekBar() {
        self.seekBar?.minValue = 0.0
        self.seekBar?.cell?.floatValue = 0.0
    }
    
    
    // PUBLIC FUNCTIONS 
    
    func setDuration(minutes: Int64, seconds: Int64) {
        self.totalTime?.stringValue = Utils.padZeros(minutes) + ":" + Utils.padZeros(seconds)
    }
    
    
    func setCurrentTime(minutes: Int64, seconds: Int64) {
        self.currentTime?.stringValue = Utils.padZeros(minutes) + ":" + Utils.padZeros(seconds)
    }
    
    func seek(time: Int64) {
        self.seekBar?.cell?.integerValue = Int(time)
    }
    
    
    // ACTIONS
    
    @IBAction func pause(sender: NSButton) {
        
        if _isPlaying {
            self.delegate?.pause()
        } else {
            self.delegate?.play()
        }
        
        pauseBtn?.title = _isPlaying ? "Play" : "Pause"
        _isPlaying = !_isPlaying
        
    }
    
    @IBAction func mute(sender: NSButton) {
        muteBtn?.title = _isMuted ? "Mute" : "Unmute"
        self.delegate?.volume(_isMuted ? 1.0 : 0.0)
        _isMuted = !_isMuted
    }
    
    @IBAction func scrub(sender: NSSlider) {
        let evt : NSEvent = NSApplication.sharedApplication().currentEvent!
        
        switch evt.type {
            
            // Mouse Up
            case NSEventType.LeftMouseUp:
                // Only play video if was playing when scrubbing happened
                if _isPlaying {
                    self.delegate?.play()
                }
                break
            
            // Mouse Down
            case NSEventType.LeftMouseDown:
                self.delegate?.seek(Float64((self.seekBar?.cell?.floatValue)!))
                self.delegate?.pause()
                break
            
            // Mouse Dragged
            case NSEventType.LeftMouseDragged:
                self.delegate?.seek(Float64((self.seekBar?.cell?.floatValue)!))
                break
         
            default:
                break
        }
        
    }
}

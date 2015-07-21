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
    func seek(frame: Float)
    
}

class Timeline: NSView {
    
    // Outlets
    @IBOutlet weak var pauseBtn: NSButton?
    @IBOutlet weak var muteBtn: NSButton?
    
    @IBOutlet weak var seekBar: NSSlider?
    @IBOutlet weak var totalTime: NSTextField?
    @IBOutlet weak var currentTime: NSTextField?
    
    
    var delegate: TimelineControllerDelegate?
    
    
    // private
    private var _isPlaying: Bool = true
    private var _isMuted: Bool = false
    private var _volume: Float = 1.0
    

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
    
    
    // Init elements
    internal func initElements() {
        
        NSLog("initElements")
        
    }
    
    // Init seek bar
    internal func initSeekBar() {
        
        NSLog("init seek bar")
        
        self.seekBar?.maxValue = 30.0
        self.seekBar?.minValue = 0.0
        self.seekBar?.cell?.floatValue = 25.0
        
    }
    
    
    
    func setDuration(minutes: Int64, seconds: Int64) {
        
        self.totalTime?.stringValue = Utils.padZeros(minutes) + ":" + Utils.padZeros(seconds)
        
    }
    
    
    func setCurrentTime(minutes: Int64, seconds: Int64) {
        
        self.currentTime?.stringValue = Utils.padZeros(minutes) + ":" + Utils.padZeros(seconds)
        
    }
    
    
    
    @IBAction func pause(sender: NSButton) {
        
        // Action pause
        if _isPlaying {
            
            _isPlaying = false
            pauseBtn?.title = "Play"
            self.delegate?.pause()
            
        } else {
            
            _isPlaying = true
            pauseBtn?.title = "Pause"
            self.delegate?.play()
            
        }
        
    }
    
    @IBAction func mute(sender: NSButton) {
        
        if _isMuted {
            
            _isMuted = false
            muteBtn?.title = "Mute"
            self.delegate?.volume(1.0)
            
        } else {
            
            _isMuted = true
            muteBtn?.title = "Unmute"
            self.delegate?.volume(0.0)
            
        }
        
    }
    
}

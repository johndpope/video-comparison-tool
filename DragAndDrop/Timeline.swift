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
    
    
    var seekBarMaxValue: Int64? {
        didSet {
            self.seekBar?.maxValue = Double(self.seekBarMaxValue!)
        }
    }
    
    // private
    private var _isPlaying: Bool = false
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
        
        self.initSeekBar()
        
    }
    
    // Init seek bar
    internal func initSeekBar() {
        
        self.seekBar?.minValue = 0.0
        self.seekBar?.cell?.floatValue = 0.0
        
    }
    
    
    
    func setDuration(minutes: Int64, seconds: Int64) {
        
        self.totalTime?.stringValue = Utils.padZeros(minutes) + ":" + Utils.padZeros(seconds)
        
    }
    
    
    func setCurrentTime(minutes: Int64, seconds: Int64) {
        
        self.currentTime?.stringValue = Utils.padZeros(minutes) + ":" + Utils.padZeros(seconds)
        
    }
    
    func seek(time: Int64) {
        
        self.seekBar?.cell?.integerValue = Int(time)
        
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
    
    @IBAction func seekTime(sender: AnyObject) {
        
        //let event: NSEvent = NSApplication.sharedApplication().currentEvent!
        self.delegate?.seek(Float64((self.seekBar?.cell?.floatValue)!))
    }
    
}

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

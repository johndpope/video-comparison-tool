//
//  Timeline.swift
//  JMS Video QC Tool
//
//  Created by Matthieu Collé on 20/07/2015.
//  Copyright © 2015 JohnMcNeil Studio. All rights reserved.
//

import Cocoa

class Timeline: NSView {
    
    
    @IBOutlet weak var pauseBtn: NSButton?
    
    
    // private
    private var _isPlaying: Bool = false
    

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
        
        NSLog("click action")
        
        // Action pause
        if _isPlaying {
            
            NSLog("Pause")
            
            _isPlaying = false
            
            pauseBtn?.title = "Play"
            
        } else {
            
            NSLog("Play")
            
            _isPlaying = true
            
            pauseBtn?.title = "Pause"
            
        }
        
        
    }
    
    
}

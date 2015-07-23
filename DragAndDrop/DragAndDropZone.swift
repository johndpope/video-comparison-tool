//
//  DragAndDropZone.swift
//  DragAndDrop
//
//  Created by Matthieu Collé on 14/07/2015.
//  Copyright © 2015 JohnMcNeil Studio. All rights reserved.
//

import Cocoa

class DragAndDropZone: NSView {

    @IBOutlet weak var textMessage: NSTextField!
    @IBOutlet weak var sideBySideComparisonButton: NSButton!
    @IBOutlet weak var sliderComparisonButton: NSButton!
    
    let fileTypes = ["mp4", "mov"]
    var fileTypeOk = false
    var droppedFilePath: String?
    var videosPaths: Array = [String]()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.registerForDraggedTypes([NSFilenamesPboardType])
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
    
    override func viewDidMoveToWindow() {
        showButtons(false)
    }
    
    
    private func showButtons(visible: Bool = true) {
        
        sideBySideComparisonButton.hidden = !visible
        sliderComparisonButton.hidden = !visible
        
    }
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        self.fileTypeOk = checkExtension(sender)
        return self.fileTypeOk ? NSDragOperation.Copy : NSDragOperation.None
    }
    
    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        return self.fileTypeOk ? NSDragOperation.Copy : NSDragOperation.None
    }
    
    override func draggingExited(sender: NSDraggingInfo?) {
        self.fileTypeOk = false
    }

    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        if let board = sender.draggingPasteboard().propertyListForType("NSFilenamesPboardType") as? NSArray {
            for strPath in board {
                videosPaths.append(strPath as! String)
            }
        }
        
        showButtons(true)
        
        // Notify controller
        NSNotificationCenter.defaultCenter().postNotificationName("loadQC", object: videosPaths)
        
        return true
    }
    
    override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    private func checkExtension(drag: NSDraggingInfo) -> Bool {
        if let board = drag.draggingPasteboard().propertyListForType("NSFilenamesPboardType") as? NSArray {
            for strPath in board {
                if let path = strPath as? String {
                    if let url:NSURL? = NSURL(fileURLWithPath: path) {
                        let suffix = url!.pathExtension!
                        for ext in self.fileTypes {
                            if ext.lowercaseString == suffix {
                                return true
                            }
                        }
                    }
                }
            }
        }
        return false
    }
    
}

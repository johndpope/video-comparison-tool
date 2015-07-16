//
//  DragAndDropZone.swift
//  DragAndDrop
//
//  Created by Matthieu Collé on 14/07/2015.
//  Copyright © 2015 JohnMcNeil Studio. All rights reserved.
//

import Cocoa

class DragAndDropZone: NSView {

    @IBOutlet var textMessage: NSTextField!
    
    var textMsg: NSTextField = NSTextField()
    
    var color: NSColor = NSColor.whiteColor()
    let fileTypes = ["mp4", "mov"]
    var fileTypeOk = false
    var droppedFilePath: String?
    let backgroundColor = NSColor.lightGrayColor()
    var videosPath: Array = [String]()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.registerForDraggedTypes([NSFilenamesPboardType])
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        drawBg()
        addPlaceholderMsg()
    }
    
    private func drawBg() {
        if self.fileTypeOk {
            let gradient = NSGradient(startingColor: NSColor.whiteColor(), endingColor: backgroundColor)
            gradient!.drawInRect(bounds, relativeCenterPosition:NSZeroPoint)
        } else {
            backgroundColor.set()
            NSBezierPath.fillRect(bounds)
        }
    }
    
    private func addPlaceholderMsg() {
        textMsg.frame = CGRectMake(self.bounds.width/2-100, self.bounds.height/2 - 10, 200, 20)
        textMsg.stringValue = "Drag & Drop videos here"
        textMsg.alignment = NSTextAlignment.Center
        textMsg.backgroundColor = NSColor(white: 1, alpha: 0)
        textMsg.font = NSFont(name: "Helvetica", size: 16)
        textMsg.editable = false
        textMsg.bordered = false
        self.addSubview(textMsg, positioned: NSWindowOrderingMode.Above, relativeTo: nil)
    }
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        self.fileTypeOk = checkExtension(sender)
        return self.fileTypeOk ? NSDragOperation.Copy : NSDragOperation.None
    }
    
    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        drawBg()
        return self.fileTypeOk ? NSDragOperation.Copy : NSDragOperation.None
    }
    
    override func draggingExited(sender: NSDraggingInfo?) {
        self.fileTypeOk = false
        drawBg()
    }

    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        if let board = sender.draggingPasteboard().propertyListForType("NSFilenamesPboardType") as? NSArray {
            if let videoPath = board[0] as? String {
                self.droppedFilePath = videoPath
                return true
            }
        }
        return false
    }
    
    override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    override func draggingEnded(sender: NSDraggingInfo?) {
        if self.fileTypeOk {
            
        }
    }
    
    private func checkExtension(drag: NSDraggingInfo) -> Bool {
        if let board = drag.draggingPasteboard().propertyListForType("NSFilenamesPboardType") as? NSArray {
            if let path = board[0] as? String {
                
                videosPath.append(path)
                
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
        return false
    }
    
}

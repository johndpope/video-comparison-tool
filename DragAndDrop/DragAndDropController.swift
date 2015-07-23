//
//  MasterViewController.swift
//  DragAndDrop
//
//  Created by Matthieu Collé on 16/07/2015.
//  Copyright © 2015 JohnMcNeil Studio. All rights reserved.
//

import Cocoa

class DragAndDropController: NSViewController {

    var dragAndDropZoneView: DragAndDropZone?
    
    var videos: Array<String> = []
    
    override func viewWillAppear() {
       
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loadQC:"), name: "loadQC", object: nil)
        
    }
    
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        
        let destVC = segue.destinationController as! SideBySideComparisonController
        destVC.videos = self.videos
        destVC.mode = segue.identifier == "SliderMode" ? QualityControlMode.Slider : QualityControlMode.SideBySide
        
        destVC.performSegueWithIdentifier("SideBySideComparison", sender: self)
        
    }
    
    
    func loadQC(notification: NSNotification) {
        
        self.videos = notification.object! as! Array<String>
        
    }
    
}

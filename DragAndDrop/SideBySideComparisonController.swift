//
//  MasterViewController.swift
//  DragAndDrop
//
//  Created by Matthieu Collé on 16/07/2015.
//  Copyright © 2015 JohnMcNeil Studio. All rights reserved.
//

import Cocoa

class SideBySideComparisonController: NSViewController {

    var videoPlayer1: VideoPlayer?
    var videoPlayer2: VideoPlayer?
    
    @IBOutlet weak var timeline: Timeline?
    
    var videos: Array = [String]()
    
    override func viewWillAppear() {
       
        self.initVideos()
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    func initVideos() {
        
        let videoWidth: CGFloat = self.view.frame.width / 2.0
        let videoHeight: CGFloat = self.view.frame.height
        
        let videoFrame: CGRect = CGRectMake(0.0, self.view.frame.height - videoHeight, videoWidth, videoHeight)
        let videoFrame2: CGRect = CGRectMake(videoWidth, self.view.frame.height - videoHeight, videoWidth, videoHeight)
        
        videoPlayer1 = VideoPlayer(frame: videoFrame)
        videoPlayer1!.frame = videoFrame
        videoPlayer1!.URL = NSURL.fileURLWithPath(self.videos[0])
        videoPlayer1!.videoTitle = self.videos[0]
        videoPlayer1!.videoIndex = 0
        videoPlayer1!.totalVideos = 2
        videoPlayer1!.endAction = VideoPlayerEndAction.Stop
        videoPlayer1!.play(nil)
        
        videoPlayer2 = VideoPlayer(frame: videoFrame2)
        videoPlayer2!.frame = videoFrame2
        videoPlayer2!.URL = NSURL.fileURLWithPath(self.videos[1])
        videoPlayer2!.videoTitle = self.videos[1]
        videoPlayer2!.videoIndex = 1
        videoPlayer2!.totalVideos = 2
        videoPlayer2!.endAction = VideoPlayerEndAction.Stop
        videoPlayer2!.play(nil)
        
        self.view.addSubview(self.videoPlayer1!)
        self.view.addSubview(self.videoPlayer2!)
        
    }
    
}

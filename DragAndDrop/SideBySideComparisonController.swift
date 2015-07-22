//
//  MasterViewController.swift
//  DragAndDrop
//
//  Created by Matthieu Collé on 16/07/2015.
//  Copyright © 2015 JohnMcNeil Studio. All rights reserved.
//

import Cocoa
import QuartzCore

class SideBySideComparisonController: NSViewController, TimelineControllerDelegate, VideoPlayerDelegate {

    var videoPlayer1: VideoPlayer?
    var videoPlayer2: VideoPlayer?
    
    @IBOutlet weak var timeline: Timeline?
    
    var videos: Array = [String]()
    
    
    private var displayLink: CVDisplayLink?
    
    
    override func viewWillAppear() {
       
        self.initTimeline()
        self.initVideos()
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    internal func initVideos() {
        
        let videoWidth: CGFloat = self.view.frame.width / 2.0
        let videoHeight: CGFloat = self.view.frame.height
        
        let videoFrame: CGRect = CGRectMake(0.0, self.view.frame.height - videoHeight, videoWidth, videoHeight)
        let videoFrame2: CGRect = CGRectMake(videoWidth, self.view.frame.height - videoHeight, videoWidth, videoHeight)
        
        videoPlayer1 = VideoPlayer(frame: videoFrame)
        videoPlayer1!.frame = videoFrame
        videoPlayer1!.URL = NSURL.fileURLWithPath(self.videos[0])
        videoPlayer1!.videoTitle = self.videos[0]
        videoPlayer1!.delegate = self
        videoPlayer1!.videoIndex = 0
        videoPlayer1!.totalVideos = 2
        videoPlayer1!.endAction = VideoPlayerEndAction.Stop
        videoPlayer1!.build()
        
        videoPlayer2 = VideoPlayer(frame: videoFrame2)
        videoPlayer2!.frame = videoFrame2
        videoPlayer2!.URL = NSURL.fileURLWithPath(self.videos[1])
        videoPlayer2!.videoTitle = self.videos[1]
        videoPlayer2!.delegate = self
        videoPlayer2!.videoIndex = 1
        videoPlayer2!.totalVideos = 2
        videoPlayer2!.endAction = VideoPlayerEndAction.Stop
        videoPlayer2!.build()
        
        self.view.addSubview(self.videoPlayer1!)
        self.view.addSubview(self.videoPlayer2!)
        
    }
    
    
    internal func initTimeline() {
     
        timeline?.delegate = self
        
    }
    
    
    // Timeline protocol
    func pause() {
        
        videoPlayer1?.pause(nil)
        videoPlayer2?.pause(nil)
        
    }
    
    func play() {
        
        videoPlayer1?.play(nil)
        videoPlayer2?.play(nil)
        
    }
    
    func volume(volume: Float) {
        
        videoPlayer1?.volume = volume
        videoPlayer2?.volume = volume
        
    }
    
    func seek(time: Float64) {
        
        videoPlayer1?.seek(time)
        videoPlayer2?.seek(time)
        
    }
    
    
    // Videos protocol
    
    // Video changed state
    func videoPlayer(videoPlayer: VideoPlayer, changedState: VideoPlayerState) {
        
        switch changedState {
            
        case .Loaded:
            self.timeline?.setDuration(videoPlayer.videoDurationReadable.minutes, seconds: videoPlayer.videoDurationReadable.seconds)
            self.timeline?.seekBarMaxValue = videoPlayer.videoDuration
            break
            
        case .Stopped:
            
            break
            
        case .Playing:
            
            self.timeline?.setCurrentTime(videoPlayer.currentTimeReadable.minutes, seconds: videoPlayer.currentTimeReadable.seconds)
            self.timeline?.seek(videoPlayer.currentTime)
            
            break
            
        default:
            break
            
        }
        
    }
    
    // Video Error
    func videoPlayer(videoPlayer: VideoPlayer, encounteredError: NSError) {
        NSLog("video error \(videoPlayer) :: \(encounteredError)")
    }
    
    
    
}

//
//  MasterViewController.swift
//  DragAndDrop
//
//  Created by Matthieu Collé on 16/07/2015.
//  Copyright © 2015 JohnMcNeil Studio. All rights reserved.
//

import Cocoa
import QuartzCore

enum QualityControlMode: Int {

    case SideBySide = 1
    case Slider
    
}

class SideBySideComparisonController: NSViewController, TimelineControllerDelegate, VideoPlayerDelegate, SplitSliderDelegate {

    @IBOutlet weak var timeline: Timeline?
    
    var splitSlider: SplitSlider?
    
    var videoPlayers: Array = [VideoPlayer]()
    var videos: Array = [String]()
    var mode: QualityControlMode = .Slider
    
    private var displayLink: CVDisplayLink?
    
    
    // OVERRIDE
    
    override func viewWillAppear() {
        self.initTimeline()
        self.initVideos()
        
        // split slider ?
        if mode == QualityControlMode.Slider {
            self.initSplitSlider()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func keyUp(evt: NSEvent) {
        if evt.keyCode == 49 {
            togglePlay()
        }
    }
    
    
    // PRIVATE FUNCTIONS
    
    // Init videos
    internal func initVideos() {
        
        // Slider ?
        let splitSliderHeight: CGFloat = mode == QualityControlMode.Slider ? 40 : 0
        
        let timelineHeight: CGFloat = timeline!.frame.height
        var videoWidth: CGFloat = self.view.frame.width
        let videoHeight: CGFloat = self.view.frame.height - timelineHeight - splitSliderHeight
        var video2Pos: (x: CGFloat, y: CGFloat) = (0.0, timelineHeight)
        
        if mode == QualityControlMode.SideBySide {
            videoWidth = self.view.frame.width / 2
            video2Pos.x = videoWidth
        }
        
        let videoFrame: CGRect = CGRectMake(0.0, video2Pos.y, videoWidth, videoHeight)
        let videoFrame2: CGRect = CGRectMake(video2Pos.x, video2Pos.y, videoWidth, videoHeight)
        
        for var idx: Int = 0; idx < 2; ++idx {
            
            let playerFrame: CGRect = idx == 0 ? videoFrame : videoFrame2
            let videoPlayer: VideoPlayer = VideoPlayer(frame: playerFrame)
            videoPlayer.frame = playerFrame
            videoPlayer.URL = NSURL.fileURLWithPath(self.videos[idx])
            videoPlayer.videoTitle = self.videos[0]
            videoPlayer.delegate = self
            videoPlayer.videoIndex = idx
            videoPlayer.totalVideos = 2
            videoPlayer.endAction = VideoPlayerEndAction.Stop
            videoPlayer.build(self.mode)
            
            self.view.addSubview(videoPlayer)
            
            videoPlayers.append(videoPlayer)
        }
        
    }
    
    // Init timeline
    internal func initTimeline() {
        timeline?.delegate = self
    }
    
    // Init split slider
    internal func initSplitSlider() {
        splitSlider = SplitSlider(frame: CGRectMake(0, self.view.frame.height - 30, self.view.frame.width, 20))
        splitSlider?.delegate = self
        self.view.addSubview(splitSlider!)
    }
    
    
    // Timeline Protocol
    
    func togglePlay() {
        if (timeline?.isPlaying != nil) {
            self.pause()
        } else {
            self.play()
        }
        
        timeline?.pause(nil)
    }
    
    func pause() {
        for videoPlayer: VideoPlayer in self.videoPlayers {
            videoPlayer.pause(nil)
        }
    }
    
    func play() {
        for videoPlayer: VideoPlayer in self.videoPlayers {
            videoPlayer.play(nil)
        }
    }
    
    func volume(volume: Float) {
        for videoPlayer: VideoPlayer in self.videoPlayers {
            videoPlayer.volume = volume
        }
    }
    
    func seek(time: Float64) {
        for videoPlayer: VideoPlayer in self.videoPlayers {
            videoPlayer.seek(time)
        }
    }
    
    
    // Videos Protocol
    
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
    
    // Split Slider Protocol
    func updateSplitSlider(value: Float) {
        for videoPlayer: VideoPlayer in self.videoPlayers {
            videoPlayer.updateMask(videoPlayer.videoIndex == 0 ? value : 100 - value)
        }
    }
    
    // Video Error
    func videoPlayer(videoPlayer: VideoPlayer, encounteredError: NSError) {
        NSLog("video error \(videoPlayer) :: \(encounteredError)")
    }
    
}

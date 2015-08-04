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

class SideBySideComparisonController: NSViewController, TimelineControllerDelegate, VideoPlayerDelegate {

    @IBOutlet weak var timeline: Timeline?
    
    var horizontalSplitSlider: JMSRangeSlider?
    var verticalSplitSlider: JMSRangeSlider?
    
    var videoPlayers: Array = [VideoPlayer]()
    var videos: Array = [String]()
    var mode: QualityControlMode = .Slider
    
    var splitHorizontalValue: Float = 50
    var splitVerticalValue: Float = 50
    
    private var displayLink: CVDisplayLink?
    
    
    // OVERRIDE
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewWillAppear() {
        self.initTimeline()
        
        // Init videos
        self.initVideos()
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
        let splitSliderHeight: CGFloat = mode == QualityControlMode.Slider ? 60 : 0
        
        let timelineHeight: CGFloat = timeline!.frame.height
        var videoWidth: CGFloat = self.view.frame.width
        let videoHeight: CGFloat = self.view.frame.height - timelineHeight - splitSliderHeight
        var video2Pos: (x: CGFloat, y: CGFloat) = (0.0, timelineHeight)
        
        if mode == QualityControlMode.SideBySide {
            videoWidth = self.view.frame.width / 2
            video2Pos.x = videoWidth
        }
        
        let videoFrame: CGRect = CGRectMake(0.0, video2Pos.y, videoWidth, videoHeight)
        
        for var idx: Int = 0; idx < 2; ++idx {
            
            let playerFrame: CGRect = videoFrame
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
    
    // Init split sliders
    internal func initSplitSliders() {
    
        let videoRect: CGRect = self.videoPlayers[0].videoRect
        
        let marginElements: CGFloat = 10
        var cellWidth: CGFloat = 20
        var cellHeight: CGFloat = 30
        let trackThickness: CGFloat = 10
        
        // Vertical split slider
        verticalSplitSlider = JMSRangeSlider()
        verticalSplitSlider?.layer?.backgroundColor = CGColorCreateGenericRGB(0, 0, 0, 1)
        verticalSplitSlider?.frame = CGRectMake(videoRect.origin.x - cellWidth, self.videoPlayers[0].frame.origin.y + self.videoPlayers[0].frame.height, videoRect.width + 2 * cellWidth, 2 * cellHeight + trackThickness)
        verticalSplitSlider?.cellWidth = cellWidth
        verticalSplitSlider?.cellHeight = cellHeight
        verticalSplitSlider?.trackThickness = trackThickness
        verticalSplitSlider?.maxValue = Double(videoRect.width)
        verticalSplitSlider?.lowerValue = 0
        verticalSplitSlider?.upperValue = Double(videoRect.width)
        verticalSplitSlider?.trackHighlightTintColor = NSColor(red: 0.4, green: 0.698, blue: 1.0, alpha: 1.0)
        verticalSplitSlider?.action = "updateRange:"
        verticalSplitSlider?.target = self
        
        // Horizontal split slider
        cellWidth = 30
        cellHeight = 20
        let horizontalSliderWidth: CGFloat = 2 * cellWidth + trackThickness
        horizontalSplitSlider = JMSRangeSlider()
        horizontalSplitSlider?.direction = JMSRangeSliderDirection.Vertical
        horizontalSplitSlider?.frame = CGRectMake(videoRect.origin.x - horizontalSliderWidth - marginElements, self.videoPlayers[0].frame.origin.y + videoRect.origin.y - cellHeight, horizontalSliderWidth, videoRect.height + 2 * cellHeight)
        horizontalSplitSlider?.cellWidth = cellWidth
        horizontalSplitSlider?.cellHeight = cellHeight
        horizontalSplitSlider?.trackThickness = trackThickness
        horizontalSplitSlider?.maxValue = Double(videoRect.height)
        horizontalSplitSlider?.lowerValue = 0
        horizontalSplitSlider?.upperValue = Double(videoRect.height)
        horizontalSplitSlider?.trackHighlightTintColor = NSColor(red: 0.4, green: 0.698, blue: 1.0, alpha: 1.0)
        horizontalSplitSlider?.action = "updateRange:"
        horizontalSplitSlider?.target = self
        
        self.view.addSubview(verticalSplitSlider!)
        self.view.addSubview(horizontalSplitSlider!)
        
        // Update range
        self.updateRange(nil)
    }
    
    
    // Update range
    func updateRange(sender: AnyObject!) {
        
        let maskWidth: CGFloat = CGFloat((verticalSplitSlider?.upperValue)! - (verticalSplitSlider?.lowerValue)!)
        let maskHeight: CGFloat = CGFloat((horizontalSplitSlider?.upperValue)! - (horizontalSplitSlider?.lowerValue)!)
        
        if let _videoPlayer: VideoPlayer = videoPlayers[1] {
            _videoPlayer.updateMask(CGRectMake(CGFloat((verticalSplitSlider?.lowerValue)!), CGFloat((horizontalSplitSlider?.lowerValue)!), maskWidth, maskHeight))
        }
        
    }
    
    // Timeline Protocol
    
    func togglePlay() {
        if (timeline?.isPlaying != nil) {
            self.pause()
        } else {
            self.play()
        }
        
        timeline?.togglePlay(nil)
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
            // Set up timeline
            self.timeline?.setDuration(videoPlayer.videoDurationReadable.minutes, seconds: videoPlayer.videoDurationReadable.seconds)
            self.timeline?.seekBarMaxValue = videoPlayer.videoDuration
            
            // Create split sliders if needed 
            if mode == QualityControlMode.Slider {
                self.initSplitSliders()
            }
            
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

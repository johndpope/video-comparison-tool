//
//  VideoPlayer.swift
//  AWEasyVideoPlayer
//
//  Created by Aaron Wojnowski on 2014-06-03.
//  Copyright (c) 2014 Aaron. All rights reserved.
//

import AVFoundation
import CoreMedia
import Foundation

protocol VideoPlayerDelegate {
    
    func videoPlayer(videoPlayer: VideoPlayer, changedState: VideoPlayerState)
    func videoPlayer(videoPlayer: VideoPlayer, encounteredError: NSError)
    
}

enum VideoPlayerEndAction: Int {
    
    case Stop = 1
    case Loop
    
}

enum VideoPlayerState: Int {
    
    case Stopped = 1
    case Loading, Loaded, Playing, Paused
    
}

class VideoPlayer: NSView {
    
    // - Getters & Setters
    
    // Public
    
    var delegate : VideoPlayerDelegate?
    
    var endAction : VideoPlayerEndAction = VideoPlayerEndAction.Stop
    var state : VideoPlayerState = VideoPlayerState.Stopped
    
    var URL : NSURL? {
        didSet {
            self._destroyPlayer()
        }
    }
    
    var videoTitle : String = ""
    var videoIndex : Int = 0
    var totalVideos : Int?
    
    var volume : Float {
        didSet {
            if (self._player != nil) {
                self._player!.volume = self.volume
            }
        }
    }
    
    var videoItem : AVPlayerItem {
        get {
            return (self._player?.currentItem!)!
        }
    }
    
    // Video duration
    var videoDurationReadable : (minutes: Int64, seconds: Int64) {
        get {
            let seconds : CGFloat = CGFloat(Int64(self.videoItem.duration.value) / Int64(self.videoItem.duration.timescale))
            let fullSeconds : Int64 = Int64(floor(seconds))
            return Utils.secondsToMinSec(fullSeconds)
        }
    }
    
    var videoDuration : Int64 {
        get {
            let centiSeconds : CGFloat = CGFloat(Int64(self.videoItem.duration.value) / Int64(self.videoItem.duration.timescale / 100))
            return Int64(floor(centiSeconds))
        }
    }
    
    // Video current time
    var currentTimeReadable : (minutes: Int64, seconds: Int64) {
        get {
            let centiSeconds : CGFloat = CGFloat(Int64(self.videoItem.currentTime().value) / Int64(self.videoItem.currentTime().timescale))
            let fullCentiSeconds : Int64 = Int64(floor(centiSeconds))
            return Utils.secondsToMinSec(fullCentiSeconds)
        }
    }
    
    var currentTime : Int64 {
        get {
            if Int64(self.videoItem.currentTime().value) == 0 {
                return 0
            }
            
            let centiSeconds : CGFloat = CGFloat(Int64(self.videoItem.currentTime().value) / Int64(self.videoItem.currentTime().timescale / 100))
            return Int64(floor(centiSeconds))
        }
    }
    
    // Private
    
    internal var _player : AVPlayer?
    internal var _playerLayer : AVPlayerLayer?
    internal var _isBufferEmpty : Bool = false
    internal var _isLoaded : Bool = false
    
    // - Initializing
    
    deinit {
        self._destroyPlayer()
    }
    
    override init(frame: NSRect) {

        self.volume = 1.0;
        
        super.init(frame: frame)
        
        self.wantsLayer = true
        self.canDrawSubviewsIntoLayer = true
        
        self.needsDisplay = true
        
    }
    
    // Want update layer so updateLayer is called instead of drawRect
    override var wantsUpdateLayer: Bool {
        
        return true
        
    }
    
    override func makeBackingLayer() -> CALayer {
        
        self.layer = CALayer()
        return self.layer!
        
    }
    
    override func updateLayer() {
        NSLog("updateLayer")
    }
    
    // - Layout
    
    override func viewWillDraw() {
        
        super.viewWillDraw()
        
    }
    
    override func drawRect(dirtyRect: NSRect) {
        
        if ((self._playerLayer) != nil) {
            self._playerLayer!.frame = dirtyRect
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // PUBLIC FUNCTIONS
    
    func build(mode: QualityControlMode = QualityControlMode.SideBySide) {
        self._setupPlayer()
        self._showVideoTitle()
        
        // If slider mode
        if mode == QualityControlMode.Slider {
            // Mask
            self.layer!.mask = CAShapeLayer()
            // Init mask frame
            self.updateMask(50)
        }
    }
    
    // Update mask ( for split slider )
    func updateMask(value: Float) {
        
        if let shapeLayer = self.layer?.mask as? CAShapeLayer {
            let percent: CGFloat = CGFloat(value) / 100
            let newWidth: CGFloat = percent * self.frame.width
            var maskX: CGFloat = 0
            
            if self.videoIndex == 1 {
               maskX = ((100 - CGFloat(value)) / 100) * self.frame.width
            }
            
            shapeLayer.path = CGPathCreateWithRect(CGRectMake(maskX, 0, newWidth, self.frame.height), nil)
        }
        
    }
    
    
    // PRIVATE FUNCTIONS
    
    // Setup Player
    internal func _setupPlayer() {
        
        if !(self.URL != nil) {
            return;
        }
        
        self._destroyPlayer()
        
        let playerItem : AVPlayerItem = AVPlayerItem(URL: self.URL!)
        
        let player : AVPlayer = AVPlayer(playerItem: playerItem)
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.Pause
        player.volume = self.volume
        self._player = player;
        
        let playerLayer : AVPlayerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRectMake(0, 0, self.frame.width, self.frame.height - 20)
        
        self.layer!.addSublayer(playerLayer)
        self._playerLayer = playerLayer
        
        self._addObservers()
        
    }
    
    // Destroy Player
    internal func _destroyPlayer() {
        
        self._removeObservers();
        
        self._player = nil
        
        self._playerLayer?.removeFromSuperlayer()
        self._playerLayer = nil
        
        self._setStateNotifyingDelegate(VideoPlayerState.Stopped)
        
    }
    
    // Show video title
    internal func _showVideoTitle() {
        
        let title : NSTextField = NSTextField()
        title.stringValue = self.videoTitle
        title.editable = false
        title.backgroundColor = NSColor(white: 1.0, alpha: 0.0)
        title.bordered = false
        title.textColor = NSColor.blackColor()
        title.alignment = NSTextAlignment.Center
        title.frame = CGRectMake(0, self.frame.height - 20, self.frame.width, 20)
        self.addSubview(title)
        
    }
    
    // Set State & tell delegate
    internal func _setStateNotifyingDelegate(state: VideoPlayerState) {
        
        self.state = state
        self.delegate?.videoPlayer(self, changedState: state)
        
    }
    
    
    // - Player Notifications
    
    func playerFailed(notification: NSNotification) {
        
        self._destroyPlayer();
        self.delegate?.videoPlayer(self, encounteredError: NSError(domain: "VideoPlayer", code: 1, userInfo: [NSLocalizedDescriptionKey : "An unknown error occured."]))
        
    }
    
    func playerPlayedToEnd(notification: NSNotification) {
        
        switch self.endAction {
            case .Loop:
                self._player?.currentItem?.seekToTime(kCMTimeZero)
                break
                
            case .Stop:

                break
        }
        
    }
    
    // - Observers
    
    internal func _addObservers() {
        
        let options = NSKeyValueObservingOptions([.New, .Old])
        self._player?.addObserver(self, forKeyPath: "rate", options: options, context: nil)
        
        self._player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: options, context: nil)
        self._player?.currentItem?.addObserver(self, forKeyPath: "status", options: options, context: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerFailed:"), name: AVPlayerItemFailedToPlayToEndTimeNotification, object: self._player?.currentItem)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerPlayedToEnd:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: self._player?.currentItem)
        
    }
    
    internal func _removeObservers() {
       
        self._player?.removeObserver(self, forKeyPath: "rate")
        
        self._player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        self._player?.currentItem?.removeObserver(self, forKeyPath: "status")
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        let obj = object as? NSObject
        if obj == self._player {
            
            if keyPath == "rate" {
                
                let rate = self._player?.rate
                if !self._isLoaded {
                    self._setStateNotifyingDelegate(VideoPlayerState.Loading)
                } else if rate == 1.0 {
                    self._setStateNotifyingDelegate(VideoPlayerState.Playing)
                } else if rate == 0.0 {
                    if self._isBufferEmpty {
                        self._setStateNotifyingDelegate(VideoPlayerState.Loading)
                    } else {
                        self._setStateNotifyingDelegate(VideoPlayerState.Paused)
                    }
                }
                
            }
            
        } else if obj == self._player?.currentItem {
            
            if keyPath == "status" {
                
                let status : AVPlayerItemStatus? = self._player?.currentItem?.status
                
                if status == AVPlayerItemStatus.Failed {
                    self._destroyPlayer()
                    self.delegate?.videoPlayer(self, encounteredError: NSError(domain: "VideoPlayer", code: 1, userInfo: [NSLocalizedDescriptionKey : "An unknown error occured."]))
                } else if status == AVPlayerItemStatus.ReadyToPlay {
                    self._isLoaded = true
                    
                    // Notify video loaded
                    self._setStateNotifyingDelegate(VideoPlayerState.Loaded)
                }
                
            } else if keyPath == "playbackBufferEmpty" {
                let empty : Bool? = self._player?.currentItem?.playbackBufferEmpty
                self._isBufferEmpty = empty != nil
            }
            
        }
    }
    
    
    // - Actions
    
    func play(sender: NSButton!) {
        
        switch self.state {
            
        case VideoPlayerState.Paused, VideoPlayerState.Loaded:
            
            // Play
            self._player?.play()
            
            // Add periodic time observer
            if self.videoIndex == 0 {
                let interval : CMTime = CMTimeMake(1, 100)
                self._player?.addPeriodicTimeObserverForInterval(interval, queue: nil, usingBlock: { (time: CMTime) -> Void in
                    
                    self.delegate?.videoPlayer(self, changedState: VideoPlayerState.Playing)
                    
                })
            }
            
        case VideoPlayerState.Stopped:
            
            self.build()
            
        default:
            break
            
        }
        
    }
    
    func pause(sender: NSButton!) {
        
        switch self.state {
            
        case VideoPlayerState.Playing, VideoPlayerState.Loading:
            
            self._player?.pause()
            self._setStateNotifyingDelegate(VideoPlayerState.Paused)

        default:
            break
            
        }
        
    }
    
    func stop() {
        if (self.state == VideoPlayerState.Stopped) {
            return
        }
        
        self._destroyPlayer()
    }
    
    func seek(time: Float64) {
        let cmtime : CMTime = CMTimeMake(Int64(time), 100)
        
        self._player?.seekToTime(cmtime)
    }
    
}
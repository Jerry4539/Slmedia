//
//  SLVideoPlayerView.swift
//  rpc
//
//  Created by => Jerry4539 on 2021 /3/1.
//  Copyright © 2021 Jerry4539 . All rights reserved.
//

import UIKit
import AVKit
public class SLVideoPlayerView: UIView {
    public func set(urlStr:String){
        let videoUrl:URL?
        if urlStr.hasPrefix("http://") || urlStr.hasPrefix("https://"){
            videoUrl = URL(string: urlStr)
        }else{
            videoUrl = URL(fileURLWithPath: urlStr)
        }
        if let videoUrl = videoUrl{
            set(url: videoUrl)
        }else{
            debugPrint("Enter:")
        }
    }
    
    public func set(url:URL){
        if self.player == nil{
            let playerItem = AVPlayerItem(url: url)
            self.addObserveWith(playerItem: playerItem)
            self.player = AVPlayer(playerItem: playerItem)
            self.playerLayer.player = player
           
            self.player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [weak self](time) in
               
                let current:TimeInterval = CMTimeGetSeconds(time)
                
                var total:Float64 = 0
                if let duration = self?.player?.currentItem?.duration{
                    total = CMTimeGetSeconds(duration)
                    if (total.isNaN) {
                        total = 0
                    }
                }
               
                if let playingProgressSlider = self?.bottomStateView.playingProgressSlider{
                    playingProgressSlider.minimumValue = 0
                    playingProgressSlider.maximumValue = Float(total)
                    // 滑动中,不去更新值
                    if self?.playingProgressSlider_isSliding == false{
                        playingProgressSlider.value = Float(current)
                    }
                }
                self?.bottomStateView.currentTimeLabel.text = current.sl_formatPlayTime()
                self?.bottomStateView.totalTimeLabel.text = total.sl_formatPlayTime()
            })
        }else{
            if let playerItem = self.player?.currentItem{
                self.removeObserveWith(playerItem: playerItem)
            }
            let playerItem = AVPlayerItem(url: url)
            self.addObserveWith(playerItem: playerItem)
            self.player?.replaceCurrentItem(with: playerItem)
        }
    }
    
    private var _fatherView:UIView?
    private var _customFrame:CGRect?
    private var playingProgressSlider_isSliding = false
   
    private var player:AVPlayer?
    private var playerLayer:AVPlayerLayer = {
        let playerLayer = AVPlayerLayer()
        playerLayer.videoGravity = .resizeAspectFill
        return playerLayer
    }()
   
    lazy var cacheProgressView:UIProgressView = {
        let cacheProgressView = UIProgressView()
        cacheProgressView.progressTintColor = UIColor.green
        return cacheProgressView
    }()
    lazy var bottomStateView:SLBottomStateView = {
        let bottomStateView = SLBottomStateView.initWithXib()
        return bottomStateView
    }()
    
    lazy var topStateView:SLTopStateView = {
        let topStateView = SLTopStateView.initWithXib()
        return topStateView
    }()
    
    
   
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        setupSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.black
        setupSubviews()
    }
    
    private func setupSubviews(){
        self.layer.addSublayer(playerLayer)
        
        self.addSubview(topStateView)
        topStateView.fullOrShrinkBtn.addTarget(self, action: #selector(self.fullOrShrinkBtnClicked(sender:)), for: .touchUpInside)
        
        self.addSubview(bottomStateView)
        bottomStateView.playOrPauseBtn.addTarget(self, action: #selector(self.playOrPauseBtnClicked(sender:)), for: .touchUpInside)
        bottomStateView.playingProgressSlider.addTarget(self, action: #selector(self.progressValueChange(slider:)), for: UIControlEvents.valueChanged)
        
        bottomStateView.playingProgressSlider.addTarget(self, action: #selector(self.progressTouchEnd(slider:)), for: UIControlEvents.touchUpInside)
        
        self.addSubview(cacheProgressView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayDidEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
       
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = self.bounds
        topStateView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 44)
        bottomStateView.frame = CGRect(x: 0, y: self.bounds.height - 44, width: self.bounds.width, height: 44)
        cacheProgressView.frame = CGRect(x: 0, y: self.bounds.height - 1, width: self.bounds.width, height: 1)
    }
    
    public func videoStart(){
        self.bottomStateView.playOrPauseBtn.setImage(SLImageLoad.load(name: "sl-pause"), for: .normal)
        self.player?.play()
       
        self.perform(#selector(self.playAfter2seconds), with: self, afterDelay: 2)
        //self.perform(#selector(self.playAfter2seconds), with: 2)
    }
    
    public func videoStop(){
        self.player?.pause()
        self.bottomStateView.playOrPauseBtn.setImage(SLImageLoad.load(name: "sl-play"), for: .normal)
        self.topStateView.alpha = 1
        self.bottomStateView.alpha = 1
    }
   
    @objc func fullOrShrinkBtnClicked(sender:UIButton){
        if let _ = _fatherView, let _ = _customFrame{
           originalscreen()
        }else{
           fullScreenWithDiection(direction: UIInterfaceOrientation.landscapeLeft)
        }
    }
    
    @objc func playOrPauseBtnClicked(sender:UIButton){
        if self.player?.rate == 0{// 说明此时暂停
            videoStart()
        }else if self.player?.rate == 1{// 说明此时正在播放
            videoStop()
        }
    }
    
    @objc func playAfter2seconds(){
        UIView.animate(withDuration: 1.2) {
            self.topStateView.alpha = 0
            self.bottomStateView.alpha = 0
        }
    }
    
    @objc func progressValueChange(slider:UISlider){
        playingProgressSlider_isSliding = true
        guard let playerItem = self.player?.currentItem else{ return }
        if playerItem.status != AVPlayerItemStatus.readyToPlay{ return }
        let sliderPercent = slider.value / slider.maximumValue
        let duration:TimeInterval = Float64(sliderPercent) * CMTimeGetSeconds(playerItem.duration)
        seekTime(player: self.player, time: Int64(duration))
    }
    
    @objc func progressTouchEnd(slider:UISlider){
        playingProgressSlider_isSliding = false
    }
    
    @objc func appDidEnterBackground(){
        self.videoStop()
    }
    
   
    @objc func moviePlayDidEnd(){
        self.bottomStateView.playOrPauseBtn.setImage(SLImageLoad.load(name: "sl-play"), for: .normal)
        self.topStateView.alpha = 1
        self.bottomStateView.alpha = 1
        seekTime(player: self.player, time: 1)
    }
    
    
    func addObserveWith(playerItem:AVPlayerItem){
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
        playerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    func removeObserveWith(playerItem:AVPlayerItem){
        playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
        playerItem.removeObserver(self, forKeyPath: "status")
    }
    
   
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let playerItem = object as? AVPlayerItem{
            if keyPath == "loadedTimeRanges"{
                if let loadedTime = self.availableDuration(with: playerItem){
                    let totalTime = CMTimeGetSeconds(playerItem.duration)
                    let progress = Float(loadedTime/totalTime)
                    self.cacheProgressView.progress = progress
                }
            }
            if keyPath == "status"{
                if playerItem.status == AVPlayerItemStatus.readyToPlay{
                    //CYTLog("ready to play")
                }else{
                    //CYTLog("failed")
                }
            }
        }
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if self.topStateView.alpha == 0{
            self.topStateView.alpha = 1
            self.bottomStateView.alpha = 1
        }else{
            self.topStateView.alpha = 0
            self.bottomStateView.alpha = 0
        }
    }
    
    
    deinit {
        if let playerItem = self.player?.currentItem{
            self.removeObserveWith(playerItem: playerItem)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
}


extension SLVideoPlayerView{
    
   
   
    func fullScreenWithDiection(direction:UIInterfaceOrientation){
        UIApplication.shared.setStatusBarHidden(true, with: .none)
        topStateView.fullOrShrinkBtn.setImage(SLImageLoad.load(name: "sl-shrinkscreen"), for: .normal)
        
        _fatherView = self.superview
       
        _customFrame = self.frame
        
        let keyWindow = UIApplication.shared.keyWindow
        keyWindow?.addSubview(self)
        let duration = UIApplication.shared.statusBarOrientationAnimationDuration
        if direction == UIInterfaceOrientation.landscapeLeft{
            UIView.animate(withDuration: duration, animations: {
                self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
            }, completion: { (finished) in

            })
        }else if direction == UIInterfaceOrientation.landscapeRight{
            UIView.animate(withDuration: duration, animations: {
                self.transform = CGAffineTransform(rotationAngle: -CGFloat(Double.pi/2))
            }, completion: { (finished) in
                
            })
        }
        if let keyWindow = keyWindow{
            self.frame = keyWindow.bounds
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    
    
    func originalscreen(){
        UIApplication.shared.setStatusBarHidden(false, with: .none)
        topStateView.fullOrShrinkBtn.setImage(SLImageLoad.load(name: "sl-fullscreen"), for: .normal)
        let duration = UIApplication.shared.statusBarOrientationAnimationDuration
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(rotationAngle: 0)
        }, completion: { (finished) in
            
        })
        self.frame = _customFrame!
        _fatherView?.addSubview(self)
        
        _fatherView = nil
        _customFrame = nil
    }
    
    
    func availableDuration(with playerItem:AVPlayerItem) -> TimeInterval?{
        let loadedTimeRanges = playerItem.loadedTimeRanges
        if let timeRange = loadedTimeRanges.first?.timeRangeValue{
            let startSeconds = CMTimeGetSeconds(timeRange.start)
            let durationSeconds = CMTimeGetSeconds(timeRange.duration)
            return startSeconds + durationSeconds
        }
        return nil
    }
    
    func seekTime(player:AVPlayer?, time:Int64){
        let seekTime = CMTimeMake(time, 1)
        player?.seek(to: seekTime) { (finished) in
            
        }
    }
}


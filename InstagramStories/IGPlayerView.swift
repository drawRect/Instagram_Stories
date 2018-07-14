//
//  IGPlayerView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 14/07/18.
//  Copyright © 2018 Dash. All rights reserved.
//

import UIKit

class IGPlayerView: UIView {
    
    lazy var player = VideoPlayer()
    
    lazy var playerView: UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: IGScreen.width, height: IGScreen.height))
        player.playerLayer.frame = v.frame
        v.layer.addSublayer(player.playerLayer)
        return v
    }()
    /*lazy var playPauseToggleBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: playerView.frame.maxY + 60, width:100, height: 60))
        btn.setTitle("Play/Pause", for: .normal)
        btn.addTarget(self, action: #selector(playPauseToggleBtn(sender:)), for: .touchUpInside)
        btn.center.x = playerView.center.x
        btn.isSelected = true
        btn.backgroundColor = .black
        return btn
    }()*/
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addUIElements()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*@objc func playPauseToggleBtn(sender: UIButton){
        sender.isSelected = !sender.isSelected
        sender.isSelected ? didTapPause() : didTapPlay()
    }*/
    private func addUIElements() {
        self.addSubview(playerView)
        //self.addSubview(playPauseToggleBtn)
    }
    public func startPlayer(withResource resource: VideoResource) {
        player.play(with: resource)
    }
    
    //Selectors
    /*func didTapPlay() {
        let videoURL = "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
        let playerResource = VideoResource(filePath: videoURL)
        player.play(with: playerResource)
    }
    func didTapPause() {
        player.pause()
    }
    func playVideo() {
//        self.addSubview(progressView)
//
//        // let interval = CMTimeMake(, 5)
//        let duration : CMTime = player.player.currentItem!.asset.duration
//        let durationTime = CMTimeGetSeconds(duration)
//        debugPrint(durationTime)
//
//        player.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/5.0, Int32(NSEC_PER_SEC)), queue: nil) {[weak self] time in
//            // let duration = CMTimeGetSeconds(playerLayer)
//            self?.progressView.progress = Float( (CMTimeGetSeconds(time) / durationTime))
//            debugPrint(self?.progressView.progress ?? 0.0)
//        }
    }*/
}

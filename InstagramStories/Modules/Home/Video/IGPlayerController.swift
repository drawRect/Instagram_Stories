//
//  IGPlayerController.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 7/5/18.
//  Copyright © 2018 Dash. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class IGPlayerController: UIViewController {

    lazy var player = VideoPlayer()

    lazy var playerView: UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 70, width: IGScreen.width, height: 300))
        player.playerLayer.frame = CGRect(x: 0, y: 0, width: v.frame.width, height: v.frame.height)
        v.layer.addSublayer(player.playerLayer)
        return v
    }()

    lazy var playPauseToggleBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: playerView.frame.maxY + 60, width:100, height: 60))
        btn.setTitle("Play/Pause", for: .normal)
        btn.addTarget(self, action: #selector(playPauseToggleBtn(sender:)), for: .touchUpInside)
        btn.center.x = playerView.center.x
        btn.isSelected = true
        btn.backgroundColor = .black
        return btn
    }()

    lazy var progressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: UIProgressViewStyle.bar)
        pv.frame = CGRect(x:0,y:playPauseToggleBtn.frame.origin.y + 200,width:400,height:10)
        pv.center.x = self.view.center.x
        pv.backgroundColor = .black
        return pv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Video Player"
        self.view.backgroundColor = .white
        addUIElements()
    }

    @objc func playPauseToggleBtn(sender: UIButton){
        sender.isSelected = !sender.isSelected
        sender.isSelected ? didTapPause() : didTapPlay()
    }

    //Selectors
    func didTapPlay() {
        let videoURL = "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
        let playerResource = VideoResource(filePath: videoURL)
        player.play(with: playerResource)
    }
    func didTapPause() {
        player.pause()
    }

    func addUIElements() {
        view.addSubview(playerView)
        view.addSubview(playPauseToggleBtn)
    }


    func payVideo() {
        self.view.addSubview(progressView)

        // let interval = CMTimeMake(, 5)
        let duration : CMTime = player.player.currentItem!.asset.duration
        let durationTime = CMTimeGetSeconds(duration)
        debugPrint(durationTime)

        player.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/5.0, Int32(NSEC_PER_SEC)), queue: nil) {[weak self] time in
            // let duration = CMTimeGetSeconds(playerLayer)
            self?.progressView.progress = Float( (CMTimeGetSeconds(time) / durationTime))
            debugPrint(self?.progressView.progress ?? 0.0)
        }
    }

}


extension IGPlayerController: IGPlayerObserver {
    func didCompletePlay(){
        //        let nextIndex = snapIndex+1
        //let nextSnap = stories[nextIndex]
        //videoURL ===> nextSnap.videoURL
        let videoURL = "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
        let playerResource = VideoResource.init(filePath: videoURL)
        player.play(with: playerResource)
    }
    func didTrack(progress:Float){}
}

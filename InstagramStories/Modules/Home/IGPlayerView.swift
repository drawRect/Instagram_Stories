//
//  IGPlayerView.swift
//  InstagramStories
//
//  Created by sudharsan s on 12/11/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import Foundation
/*
import UIKit
import AVFoundation

/*
 RoadMap: ViewController->Ask Manager to get back my Player(ie.AVPlayer) and then prepare the resource for the player(ie.URL) with IGPlayerResource struct, and then give it IGPlayerControls protocol, once you have given it should play.
 
 */

struct IGPlayerResource {
    let filePath:String
}

enum IGPlayerStatus {
    case unknown
    case playing
    case failed
    case paused
    case readyToPlay
}

//Move Implementation on ViewController or cell which ever the UIElement
protocol IGPlayerObserver:class {
    func didCompletePlay()
    func didTrack(progress:Float)
}

class IGPlayerManager {
    class func player()->IGPlayer {
        return IGPlayer()
    }
}

protocol IGPlayerControls:class{
    //This func should play as it is if player.playerItem is NIL, then if there is item(ie.AVPlayerItem) you should replace with current one.
    func play(with resource:IGPlayerResource)
    func pause()
    func stop()
    func playerState()->IGPlayerStatus
}

class IGPlayer:IGPlayerControls {
    
    public weak var playerObserverDelegate:IGPlayerObserver?
    
    var player:AVPlayer?
    var playerLayer:AVPlayerLayer?
    
    public func initializePlayer()->AVPlayerLayer {
        if player == nil {
            player = AVPlayer()
        }
        initializePlayerLayer(with: player!)
        return playerLayer!
    }
    
    private func initializePlayerLayer(with player:AVPlayer) {
        if playerLayer == nil {
            playerLayer = AVPlayerLayer(player: player)
        }
    }
    
    func play(with resource:IGPlayerResource) {
        let url = URL.init(string: resource.filePath)!
        let playerItem = AVPlayerItem.init(url: url)
        player?.replaceCurrentItem(with: playerItem)
        player?.play()
    }
    
    
    func pause() {
        //control the player
        player?.pause()
    }
    func stop() {
        //control the player
        //player?.stop()
    }
    func playerState()->IGPlayerStatus {
        /*case unknown
         case readyToPlay
         case failed */
        var status:IGPlayerStatus?
        switch player?.status {
        case .unknown?:
            break
        case .readyToPlay?:
            break
        case .failed?:
            break
        default:break
            
        }
        if status != nil {
            return status!}
        if player?.rate == 0.0 {
            status = IGPlayerStatus.paused
        }
        
        return status!
    }
    
}

class ViewController: UIViewController {
    
    private let player = IGPlayerManager.player()
    
    lazy var playerView:UIView = {
        let v = UIView.init(frame: CGRect(x: 0,y:70,width : UIScreen.main.bounds.width,height : 300))
        let video_layer = player.initializePlayer()
        video_layer.frame = CGRect(x: 0, y: 0, width: v.frame.width, height: v.frame.height)
        v.layer.addSublayer(video_layer)
        return v
    }()
    
    lazy var play_pauseButton : UIButton = {
        let btn = UIButton(frame: CGRect(x:0 , y:playerView.frame.maxY + 60, width:100, height: 60))
        btn.setTitle("Play/Pause", for: .normal)
        btn.addTarget(self, action: #selector(play_PauseButtonAction(sender:)), for: .touchUpInside)
        btn.center.x = playerView.center.x
        btn.isSelected = true
        btn.backgroundColor = .black
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Video Player"
        self.view.backgroundColor = .white
        addUIElements()
    }
    
    @objc func play_PauseButtonAction(sender: UIButton){
        sender.isSelected = !sender.isSelected
        sender.isSelected ? didTapPause() : didTapPlay()
    }
    
    //Selectors
    func didTapPlay() {
        let videoURL = "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
        let playerResource = IGPlayerResource.init(filePath: videoURL)
        player.play(with: playerResource)
    }
    func didTapPause() {
        player.pause()
    }
    
    func addUIElements() {
        self.view.addSubview(playerView)
        self.view.addSubview(play_pauseButton)
    }
    
    
    /*   func payVideo() {
     
     //player.play(with: playerResource)
     
     
     
     //        player.play(with: playerResource)
     //        let playerLayer = AVPlayerLayer(player: player)
     //        playerLayer.frame = videoPlayerUIView.bounds
     //        videoPlayerUIView.layer.addSublayer(playerLayer)
     //        player?.play()
     
     let progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.bar)
     progressView.frame = CGRect(x:0,y:play_pauseButton.frame.origin.y + 200,width:400,height:10)
     progressView.center.x = self.view.center.x
     
     progressView.backgroundColor = .black
     
     self.view.addSubview(progressView)
     
     // let interval = CMTimeMake(, 5)
     let duration : CMTime = (player?.currentItem!.asset.duration)!
     let durationTime = CMTimeGetSeconds(duration)
     
     print(durationTime)
     
     player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/5.0, Int32(NSEC_PER_SEC)), queue: nil) { time in
     // let duration = CMTimeGetSeconds(playerLayer)
     progressView.progress = Float( (CMTimeGetSeconds(time) / durationTime))
     print(progressView.progress)
     }
     
     }
     
     @objc func play_PauseButtonAction(sender: UIButton){
     sender.isSelected = !sender.isSelected
     sender.isSelected ? player?.pause() : player?.play()
     }*/
    
}


extension ViewController:IGPlayerObserver {
    func didCompletePlay(){
        //        let nextIndex = snapIndex+1
        //let nextSnap = stories[nextIndex]
        //videoURL ===> nextSnap.videoURL
        let videoURL = "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
        let playerResource = IGPlayerResource.init(filePath: videoURL)
        player.play(with: playerResource)
    }
    func didTrack(progress:Float){}
}
*/


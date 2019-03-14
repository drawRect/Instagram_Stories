//
//  IGPlayerView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 14/07/18.
//  Copyright © 2018 Dash. All rights reserved.
//

import UIKit
import AVKit

struct VideoResource {
    let filePath: String
}

enum PlayerStatus {
    case unknown
    case playing
    case failed
    case paused
    case readyToPlay
}

//Move Implementation on ViewController or cell which ever the UIElement
//CALL BACK
protocol IGPlayerObserver: class {
    func didStartPlaying()
    func didCompletePlay()
    func didTrack(progress: Float)
}

protocol PlayerControls: class {
    //This func should play as it is if player.playerItem is NIL, then if there is item(ie.AVPlayerItem) you should replace with current one.
    func play(with resource: VideoResource)
    func play()
    func pause()
    func stop()
    var playerStatus: PlayerStatus { get }
}

class IGPlayerView: UIView {
    
    //MARK:- iVars
    public weak var playerObserverDelegate: IGPlayerObserver?
    
    var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    var error: Error? {
        return player?.currentItem?.error
    }
    var activityIndicator: UIActivityIndicatorView

    //MARK:- Init methods
    override init(frame: CGRect) {
        activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.hidesWhenStopped = true
        super.init(frame: frame)
        //backgroundColor = UIColor.rgb(from: 0xEDF0F1)
        backgroundColor = .black
        activityIndicator.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        
        //why we are using bounds here means (x,y) should be (0,0). If we use init frame, then it will take scrollView's content offset x values.
        self.addSubview(activityIndicator)
        player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 100), queue: DispatchQueue.main) {
            [weak self] time in
            let timeString = String(format: "%02.2f", CMTimeGetSeconds(time))
            if let currentItem = self?.player?.currentItem {
                let totalTimeString =  String(format: "%02.2f", CMTimeGetSeconds(currentItem.asset.duration))
                if timeString == totalTimeString {
                    self?.playerObserverDelegate?.didCompletePlay()
                }
            }
            self?.playerObserverDelegate?.didTrack(progress: Float(timeString)!)
            
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var currentItem: AVPlayerItem? {
        return player?.currentItem
    }
    var currentTime: Float {
        return Float(self.player?.currentTime().value ?? 0)
    }
    
}

extension IGPlayerView: PlayerControls {
    
    func play(with resource: VideoResource) {
        //Removing observer before creating it.
        /* Adding removeObserver here.
         * If player not nil removeObserver will call otherwise it will not call.
         * If we add removeObserver without adding Observer, app will crash. We can avoid crash in this way.
         */
        //self.player?.removeObserver(self, forKeyPath: "status")
        self.player?.removeObserver(self, forKeyPath: "timeControlStatus")
        self.player?.removeObserver(self, forKeyPath: "rate")
        
        let url = URL(string: resource.filePath)!
        if let play = player {
            play.play()
        } else {
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer!.videoGravity = .resizeAspect
            playerLayer!.frame = self.bounds
            self.layer.addSublayer(playerLayer!)
            player!.play()
        }
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        // Add observer for AVPlayer status and AVPlayerItem status
        //self.player?.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
        if #available(iOS 10.0, *) {
            self.player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        } else {
            self.player?.addObserver(self, forKeyPath: "rate", options: [.old, .new], context: nil)
        }
    }
    func play() {
        player?.play()
    }
    func pause() {
        //control the player
        player?.pause()
    }
    func stop() {
        //control the player
        if let play = player {
            play.pause()
            player = nil
            self.playerLayer?.removeFromSuperlayer()
            //player got deallocated
        } else {
            //player was already deallocated
        }
    }
    var playerStatus: PlayerStatus {
        if let p = player {
            switch p.status {
            case .unknown: return .unknown
            case .readyToPlay: return .readyToPlay
            case .failed: return .failed
            }
        }
        return .unknown
    }
    
    // Observe If AVPlayerItem.status Changed to Fail
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if let player = object as? AVPlayer {
            /*if keyPath == "status" {
                if player.status == .readyToPlay {
                    self.player?.play()
                }
            } else*/ if keyPath == "timeControlStatus" {
                if #available(iOS 10.0, *) {
                    if player.timeControlStatus == .playing {
                        //Started Playing
                        activityIndicator.stopAnimating()
                        playerObserverDelegate?.didStartPlaying()
                    } else {
                        //
                    }
                }
            } else if keyPath == "rate" {
                if player.rate > 0 {
                    //
                } else {
                    //
                }
            }
        }
    }
}

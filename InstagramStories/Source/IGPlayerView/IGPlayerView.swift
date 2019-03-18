//
//  IGPlayerView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 14/07/18.
//  Copyright © 2018 DrawRect. All rights reserved.
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
    func didFailed(withError error: String, for url: URL?)
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
            if let time = Float(timeString) {
                self?.playerObserverDelegate?.didTrack(progress: time)
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        if let existingPlayer = player, existingPlayer.observationInfo != nil {
            existingPlayer.removeObserver(self, forKeyPath: "player.currentItem.status")
            existingPlayer.removeObserver(self, forKeyPath: "timeControlStatus")
        }
        debugPrint("Deinit called")
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
        
        guard let url = URL(string: resource.filePath) else {fatalError("Unable to form URL from resource")}
        if let existingPlayer = player {
            self.player = existingPlayer
            if existingPlayer.observationInfo != nil {
                existingPlayer.removeObserver(self, forKeyPath: "player.currentItem.status")
                existingPlayer.removeObserver(self, forKeyPath: "timeControlStatus")
            }
        } else {
            //player = AVPlayer(url: url)
            let asset = AVAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            player = AVPlayer(playerItem: item)
            playerLayer = AVPlayerLayer(player: player)
            if let pLayer = playerLayer {
                pLayer.videoGravity = .resizeAspect
                pLayer.frame = self.bounds
                self.layer.addSublayer(pLayer)
            }
        }
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        // Add observer for AVPlayer status and AVPlayerItem status
        self.player?.addObserver(self, forKeyPath: "player.currentItem.status", options: [.new, .initial], context: nil)
        self.player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)

        player?.play()
    }
    func play() {
        //We have used this long press gesture
        if let existingPlayer = player {
            existingPlayer.play()
        }
    }
    func pause() {
        //control the player
        if let existingPlayer = player {
            existingPlayer.pause()
        }
    }
    func stop() {
        //control the player
        if let existingPlayer = player {
            existingPlayer.pause()
            //Remove observer if observer presents before setting player to nil
            if existingPlayer.observationInfo != nil {
                existingPlayer.removeObserver(self, forKeyPath: "player.currentItem.status")
                existingPlayer.removeObserver(self, forKeyPath: "timeControlStatus")
            }
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
        guard let player = object as? AVPlayer else { fatalError("Player is nil") }
        if keyPath == "player.currentItem.status" {
            let newStatus: AVPlayerItem.Status
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber, let status = AVPlayerItem.Status(rawValue: newStatusAsNumber.intValue) {
                newStatus = status
            }
            else {
                newStatus = .unknown
            }
            if newStatus == .failed {
                activityIndicator.stopAnimating()
                if let item = player.currentItem, let error = item.error, let url = item.asset as? AVURLAsset {
                    playerObserverDelegate?.didFailed(withError: error.localizedDescription, for: url.url)
                } else {
                    playerObserverDelegate?.didFailed(withError: "Unknown error", for: nil)
                }
            }
        } else if keyPath == "timeControlStatus" {
            if player.timeControlStatus == .playing {
                //Started Playing
                activityIndicator.stopAnimating()
                playerObserverDelegate?.didStartPlaying()
            } else if player.timeControlStatus == .paused {
                // player paused
            } else {
                //
            }
        }
    }
}

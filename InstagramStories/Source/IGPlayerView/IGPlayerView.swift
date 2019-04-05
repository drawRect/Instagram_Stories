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

/*
 KVO context used to differentiate KVO callbacks for this class versus other
 classes in its class hierarchy.
 */
private var playerViewKVOContext = 0

class IGPlayerView: UIView {
    
    //MARK:- iVars
    public weak var playerObserverDelegate: IGPlayerObserver?
    private var timeObserverToken: AnyObject?
    private var playerItemStatusObserver: NSKeyValueObservation?
    
    var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerItem: AVPlayerItem? = nil {
        willSet {
            /// Remove any previous KVO observer.
            guard let playerItemStatusObserver = playerItemStatusObserver else { return }
            playerItemStatusObserver.invalidate()
        }
        didSet {
            player?.replaceCurrentItem(with: playerItem)
        }
    }
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
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        if let existingPlayer = player, existingPlayer.observationInfo != nil {
            removeObservers(for: existingPlayer)
        }
        debugPrint("Deinit called")
    }
    var currentItem: AVPlayerItem? {
        return player?.currentItem
    }
    var currentTime: Float {
        return Float(self.player?.currentTime().value ?? 0)
    }
    func removeObservers(for player: AVPlayer) {
        player.removeObserver(self, forKeyPath: "player.currentItem.status", context: &playerViewKVOContext)
        player.removeObserver(self, forKeyPath: "timeControlStatus", context: &playerViewKVOContext)
        cleanUpPlayerPeriodicTimeObserver()
    }
    func cleanUpPlayerPeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    func setupPlayerPeriodicTimeObserver() {
        // Only add the time observer if one hasn't been created yet.
        guard timeObserverToken == nil else { return }
        
        // Use a weak self variable to avoid a retain cycle in the block.
        timeObserverToken =
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
            } as AnyObject
    }
}

extension IGPlayerView: PlayerControls {
    
    func play(with resource: VideoResource) {
        
        guard let url = URL(string: resource.filePath) else {fatalError("Unable to form URL from resource")}
        if let existingPlayer = player {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.player = existingPlayer
                if existingPlayer.observationInfo != nil {
                    strongSelf.removeObservers(for: existingPlayer)
                }
            }
        } else {
            //player = AVPlayer(url: url)
            let asset = AVAsset(url: url)
            playerItem = AVPlayerItem(asset: asset)
            player = AVPlayer(playerItem: playerItem)
            playerLayer = AVPlayerLayer(player: player)
            setupPlayerPeriodicTimeObserver()
            if let pLayer = playerLayer {
                pLayer.videoGravity = .resizeAspect
                pLayer.frame = self.bounds
                self.layer.addSublayer(pLayer)
            }
        }
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        DispatchQueue.main.async { [weak self] in
            // Add observer for AVPlayer status and AVPlayerItem status
            guard let strongSelf = self else { return }
            strongSelf.player?.addObserver(strongSelf, forKeyPath: "player.currentItem.status", options: [.new, .initial], context: &playerViewKVOContext)
            strongSelf.player?.addObserver(strongSelf, forKeyPath: "timeControlStatus", options: [.new, .initial], context: &playerViewKVOContext)
        }
        player?.play()
    }
    func play() {
        //We have used this for long press gesture
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
            DispatchQueue.main.async {[weak self] in
                guard let strongSelf = self else { return }
                existingPlayer.pause()
                
                //Remove observer if observer presents before setting player to nil
                if existingPlayer.observationInfo != nil {
                    strongSelf.removeObservers(for: existingPlayer)
                }
                strongSelf.playerItem = nil
                strongSelf.player = nil
                strongSelf.playerLayer?.removeFromSuperlayer()
            }
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
        guard context == &playerViewKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if keyPath == "player.currentItem.status" {
            let newStatus: AVPlayerItem.Status
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber, let status = AVPlayerItem.Status(rawValue: newStatusAsNumber.intValue) {
                newStatus = status
            }
            else {
                newStatus = .unknown
            }
            if newStatus == .failed {
                self.activityIndicator.stopAnimating()
                if let item = player.currentItem, let error = item.error, let url = item.asset as? AVURLAsset {
                    self.playerObserverDelegate?.didFailed(withError: error.localizedDescription, for: url.url)
                } else {
                    self.playerObserverDelegate?.didFailed(withError: "Unknown error", for: nil)
                }
            }
        } else if keyPath == "timeControlStatus" {
            if player.timeControlStatus == .playing {
                //Started Playing
                self.activityIndicator.stopAnimating()
                self.playerObserverDelegate?.didStartPlaying()
            } else if player.timeControlStatus == .paused {
                // player paused
            } else {
                //
            }
        }
    }
}

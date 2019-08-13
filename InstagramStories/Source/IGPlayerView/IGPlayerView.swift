//
//  IGPlayerView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 14/07/18.
//  Copyright © 2018 DrawRect. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

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
    func play(with resource: VideoResource)
    func play()
    func pause()
    func stop()
    var playerStatus: PlayerStatus { get }
}

class IGPlayerView: UIView {
    
    //MARK: - Private Vars
    private var timeObserverToken: AnyObject?
    private var playerItemStatusObserver: NSKeyValueObservation?
    private var playerTimeControlStatusObserver: NSKeyValueObservation?
    private var playerLayer: AVPlayerLayer?
    private var playerItem: AVPlayerItem? = nil {
        willSet {
            // Remove any previous KVO observer.
            guard let playerItemStatusObserver = playerItemStatusObserver else { return }
            playerItemStatusObserver.invalidate()
        }
        didSet {
            player?.replaceCurrentItem(with: playerItem)
            playerItemStatusObserver = playerItem?.observe(\AVPlayerItem.status, options: [.new, .initial], changeHandler: { [weak self] (item, _) in
                guard let strongSelf = self else { return }
                if item.status == .failed {
                    strongSelf.activityIndicator.stopAnimating()
                    if let item = strongSelf.player?.currentItem, let error = item.error, let url = item.asset as? AVURLAsset {
                        strongSelf.playerObserverDelegate?.didFailed(withError: error.localizedDescription, for: url.url)
                    } else {
                        strongSelf.playerObserverDelegate?.didFailed(withError: "Unknown error", for: nil)
                    }
                }
            })
        }
    }
    
    //MARK: - iVars
    var player: AVPlayer? {
        willSet {
            // Remove any previous KVO observer.
            guard let playerTimeControlStatusObserver = playerTimeControlStatusObserver else { return }
            playerTimeControlStatusObserver.invalidate()
        }
        didSet {
            playerTimeControlStatusObserver = player?.observe(\AVPlayer.timeControlStatus, options: [.new, .initial], changeHandler: { [weak self] (player, _) in
                guard let strongSelf = self else { return }
                if player.timeControlStatus == .playing {
                    //Started Playing
                    strongSelf.activityIndicator.stopAnimating()
                    strongSelf.playerObserverDelegate?.didStartPlaying()
                } else if player.timeControlStatus == .paused {
                    // player paused
                } else {
                    //
                }
            })
        }
    }
    var error: Error? {
        return player?.currentItem?.error
    }
    var activityIndicator: UIActivityIndicatorView!
    
    var currentItem: AVPlayerItem? {
        return player?.currentItem
    }
    var currentTime: Float {
        return Float(self.player?.currentTime().value ?? 0)
    }
    
    //MARK: - Public Vars
    public weak var playerObserverDelegate: IGPlayerObserver?
    
    //MARK:- Init methods
    override init(frame: CGRect) {
        activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        super.init(frame: frame)
        setupActivityIndicator()
    }
    required init?(coder aDecoder: NSCoder) {
        activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    override func layoutSubviews() {
        playerLayer?.frame = self.bounds
    }
    deinit {
        if let existingPlayer = player, existingPlayer.observationInfo != nil {
            removeObservers()
        }
    }
    
    // MARK: - Internal methods
    func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        //backgroundColor = UIColor.rgb(from: 0xEDF0F1)
        backgroundColor = .black
        self.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.igCenterXAnchor.constraint(equalTo: self.igCenterXAnchor),
            activityIndicator.igCenterYAnchor.constraint(equalTo: self.igCenterYAnchor)
            ])
    }
    func startAnimating() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    func stopAnimating() {
        activityIndicator.startAnimating()
    }
    func removeObservers() {
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

// MARK: - Protocol | PlayerControls
extension IGPlayerView: PlayerControls {
    
    func play(with resource: VideoResource) {
        
        guard let url = URL(string: resource.filePath) else {fatalError("Unable to form URL from resource")}
        if let existingPlayer = player {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.player = existingPlayer
            }
        } else {
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
        startAnimating()
        player?.play()
    }
    func play() {
        //We have used this for long press gesture
        if let existingPlayer = player {
            existingPlayer.play()
        }
    }
    func pause() {
        if let existingPlayer = player {
            existingPlayer.pause()
        }
    }
    func stop() {
        if let existingPlayer = player {
            DispatchQueue.main.async {[weak self] in
                guard let strongSelf = self else { return }
                existingPlayer.pause()
                
                //Remove observer if observer presents before setting player to nil
                if existingPlayer.observationInfo != nil {
                    strongSelf.removeObservers()
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
            @unknown default:
                return .unknown
            }
        }
        return .unknown
    }
}

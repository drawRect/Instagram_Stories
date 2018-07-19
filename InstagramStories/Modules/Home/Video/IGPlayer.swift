import Foundation
import UIKit
import AVFoundation

/*
 RoadMap: ViewController->Prepare the resource for the player(ie.URL) with IGPlayerResource,
 and then give it via IGPlayerControls protocol, once you have given it should play.
 */

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
    func didCompletePlay()
    func didTrack(progress: Float)
}

protocol PlayerControls: class {
    //This func should play as it is if player.playerItem is NIL, then if there is item(ie.AVPlayerItem) you should replace with current one.
    func play(with resource: VideoResource)
    func pause()
    func stop()
    var playerStatus: PlayerStatus { get }
}

class VideoPlayer: NSObject, PlayerControls {
    public weak var playerObserverDelegate: IGPlayerObserver?
    
    lazy var player: AVPlayer = AVPlayer()
    lazy var playerLayer: AVPlayerLayer = AVPlayerLayer(player: player)
    var error: Error?
    
    func play(with resource: VideoResource) {
        let url = URL.init(string: resource.filePath)!
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        
        // Add observer for AVPlayer status and AVPlayerItem status
        self.player.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new, .initial], context: nil)
        self.player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status), options:[.new, .initial], context: nil)
        
        // Watch notifications
        let center = NotificationCenter.default
        center.addObserver(self, selector:#selector(newErrorLogEntry(_:)), name: .AVPlayerItemNewErrorLogEntry, object: player.currentItem)
        center.addObserver(self, selector:#selector(failedToPlayToEndTime(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: player.currentItem)
        
        /*if player.currentItem?.status == .failed || player.currentItem?.status == .unknown {
            if let e = self.error {
                return completion(false, e)
            }
        }else if player.currentItem?.status == .readyToPlay {
            return completion(true, nil)
        }*/
        
        player.play()
    }
    func pause() {
        //control the player
        player.pause()
    }
    func stop() {
        //control the player
        player.pause()
        NotificationCenter.default.removeObserver(self)
        player.replaceCurrentItem(with: nil)
    }
    var playerStatus: PlayerStatus {
        switch player.status {
        case .unknown: return .unknown
        case .readyToPlay: return .readyToPlay
        case .failed: return .failed
        }
    }
    
    // Observe If AVPlayerItem.status Changed to Fail
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if let player = object as? AVPlayer, keyPath == #keyPath(AVPlayer.currentItem.status) {
            let newStatus: AVPlayerItemStatus
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItemStatus(rawValue: newStatusAsNumber.intValue)!
            } else {
                newStatus = .unknown
            }
            if newStatus == .failed {
                error = player.currentItem?.error
                NSLog("Error: \(String(describing: player.currentItem?.error?.localizedDescription)), error: \(String(describing: player.currentItem?.error))")
            }
        }
    }
    
    // Getting error from Notification payload
    @objc func newErrorLogEntry(_ notification: Notification) {
        guard let object = notification.object, let playerItem = object as? AVPlayerItem else {
            return
        }
        guard let errorLog: AVPlayerItemErrorLog = playerItem.errorLog() else {
            return
        }
        NSLog("Error: \(errorLog)")
    }
    
    @objc func failedToPlayToEndTime(_ notification: Notification) {
        if let error = notification.userInfo!["AVPlayerItemFailedToPlayToEndTimeErrorKey"] as? Error {
            print("Error: \(error.localizedDescription), error: \(error)")
        }
    }

}

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

class VideoPlayer: PlayerControls {
    
    public weak var playerObserverDelegate: IGPlayerObserver?
    
    lazy var player: AVPlayer = AVPlayer()
    lazy var playerLayer: AVPlayerLayer = AVPlayerLayer(player: player)

    func play(with resource: VideoResource) {
        let url = URL.init(string: resource.filePath)!
        let playerItem = AVPlayerItem.init(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    
    func pause() {
        //control the player
        player.pause()
    }
    func stop() {
        //control the player
        //player?.stop()
    }
    var playerStatus: PlayerStatus {
        switch player.status {
        case .unknown: return .unknown
        case .readyToPlay: return .readyToPlay
        case .failed: return .failed
        }
        return player.rate == 0.0 ? .paused : .playing
    }

}

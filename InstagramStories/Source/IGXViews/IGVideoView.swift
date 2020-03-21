//
//  IGVideoView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 19/02/20.
//  Copyright © 2020 DrawRect. All rights reserved.
//

import UIKit

class IGVideoView: IGXView {
    // MARK: iVars
    lazy var videoView: IGPlayerView = IGPlayerView(frame: self.bounds)
    var playerView: IGPlayerView {
        return videoView
    }
    // MARK: Init methods
    override init(frame: CGRect, snap: IGSnap) {
        super.init(frame: frame, snap: snap)
        self.addSubview(videoView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: Internal methods
    /// start request this video using avplayer with contents of url
    @objc override func loadContent() {
        videoView.startAnimating()
        guard let savedURL = IGVideoCacheHelper.default.readVideo(fromUrl: snap.url) else {
            return IGVideoCacheHelper.default.writeVideo(fromUrl: snap.url) { (result) in
                switch result {
                case .success(let written):
                    guard written, let svURL = IGVideoCacheHelper.default.readVideo(fromUrl: self.snap.url) else {
                        return self.videoView.stopAnimating()
                    }
                    self.playVideo(using: svURL)
                case .failure(let error):
                    self.videoView.stopAnimating()
                    debugPrint("Error:\(error.localizedDescription)")
                    self.contentState = .isFailed
                }
            }
        }
        playVideo(using: savedURL)
    }
    func playVideo(using: URL) {
        let videoResource = VideoResource(filePath: using.absoluteString)
        self.videoView.play(with: videoResource)
    }
    func pauseVideo() {
        playerView.pause()
    }
    func resumeVideo() {
        playerView.play()
    }
    func stopVideo() {
        playerView.stop()
    }
}

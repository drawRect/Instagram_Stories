//
//  IGVideoView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 19/02/20.
//  Copyright © 2020 DrawRect. All rights reserved.
//

import UIKit

class IGVideoView: IGXView {
    //Add your Video related stuff here
    lazy var videoView: IGPlayerView = {
        let videoView = IGPlayerView(frame: self.bounds)
        return videoView
    }()
    override init(frame: CGRect, snap: IGSnap) {
        super.init(frame: frame, snap: snap)
        self.addSubview(videoView)
    }
    var playerView: IGPlayerView {
        return videoView
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc override func loadContent() {
        //start request this video using avplayer with contents of url
        videoView.startAnimating()
        IGVideoCacheManager.shared.getFile(for: snap.url) { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
                case .success(let url):
                    let videoResource = VideoResource(filePath: url.absoluteString)
                    strongSelf.videoView.play(with: videoResource)
                case .failure(let error):
                    strongSelf.videoView.stopAnimating()
                    debugPrint("Video error: \(error)")
            }
        }
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

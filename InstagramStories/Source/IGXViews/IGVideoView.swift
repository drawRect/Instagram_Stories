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
    // MARK: iVars
    lazy var videoView: IGPlayerView = {
        let videoView = IGPlayerView(frame: self.bounds)
        return videoView
    }()
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
                    strongSelf.contentState = .isFailed
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

//
//  IGStoryPreviewCellViewModel.swift
//  InstagramStories
//
//  Created by Ranjit on 28/09/20.
//  Copyright © 2020 DrawRect. All rights reserved.
//

import Foundation

class IGStoryPreviewCellViewModel {
    
    public var story: IGStory!
    public var direction = ScreenDirection.forward
    
    var enableScrollViewUserInteraction = Dynamic<Bool>()
    var startRequest = Dynamic<String>()
    var startPlayer = Dynamic<String>()
    var lastUpdated = Dynamic<String>()
    var showRetryButton = Dynamic<String>()
    var startProgressor = Dynamic<Bool>()
    var playVideo = Dynamic<VideoResource>()
    var stopAnimation = Dynamic<Bool>()
    var startSnapProgress = Dynamic<Int>()
    var stopPlayer = Dynamic<Bool>()
    var resetSnapProgressors = Dynamic<Int>()
    
    public var handpickedSnapIndex: Int = 0
    
    public var snapIndex: Int = 0 {
        didSet {
            moveSnapOnDirection()
        }
    }
    
    private(set) var snapViewTag = 8
    
    public var videoSnapIndex: Int = 0
    
    public var previousSnapIndex: Int {
        snapIndex - 1
    }
    
    public var snapIndexWithTag: Int {
        snapIndex + snapViewTag
    }
    
    func moveSnapOnDirection() {
        if snapIndex < story.snapsCount {
            #warning("why are we enabling the userInteraction of scrollview always here!. what is the catch?")
            enableScrollViewUserInteraction.value = true
            let snap = story.nonDeletedSnaps[snapIndex]
            lastUpdated.value = snap.lastUpdated
            if snap.kind == .image {
                startRequest.value = snap.url
            } else if snap.kind == .video {
                startPlayer.value = snap.url
            }
        } else {
            fatalError("snapIndex is out of bounds")
        }
    }
    
    func processImageResponse(urlString: String, result: IGResult<Bool, Error>) {
        switch result {
        case .success(_):
            let nonDeletedSnapUrl = story.nonDeletedSnaps[snapIndex].url
            //start progressor if handpickedSnapIndex matches with snapIndex
            #warning("urlString == nonDeletedSnapUrl this condtion why we have not enabled on Video request")
            #warning("if you have enabled it. then create one custom getter to get bool out of it")
            if handpickedSnapIndex == snapIndex && urlString == nonDeletedSnapUrl {
                self.startProgressor.value = true
            } else {
                debugPrint("could not start the progress because of snapindex mismatches")
            }
        case .failure(_):
            showRetryButton.value = urlString
        }
    }
    
    func requestVideo(urlString: String) {
        IGVideoCacheManager.shared.getFile(for: urlString) { [weak self] (result) in
            switch result {
            case .success(let videoURL):
                //start progressor if handpickedSnapIndex matches with snapIndex
                if self?.handpickedSnapIndex == self?.snapIndex {
                    let videoResource = VideoResource(filePath: videoURL.absoluteString)
                    self?.playVideo.value = videoResource
                }  else {
                    debugPrint("could not start the progress because of snapindex mismatches")
                }
            case .failure(let error):
                debugPrint("could not load the video. \(error)")
                self?.stopAnimation.value = true
            }
        }
    }
    
    func didEnterForeground() {
        let snap = story.nonDeletedSnaps[snapIndex]
        if snap.kind == .video {
            startPlayer.value = snap.url
        } else {
            startSnapProgress.value = snapIndex
        }
    }
    
    func didEnterBackground() {
        let snap = story.nonDeletedSnaps[snapIndex]
        if snap.kind == .video {
            stopPlayer.value = true
        }
        resetSnapProgressors.value = snapIndex
    }

}

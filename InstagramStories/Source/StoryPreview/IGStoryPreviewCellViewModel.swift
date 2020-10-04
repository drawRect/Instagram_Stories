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
    
    public var handpickedSnapIndex: Int = 0
    
    public var snapIndex: Int = 0 {
        didSet {
            print("snapIndex:\(snapIndex) and user.name:\(story.user.name)")
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
        print(#function)
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
        }
    }
    
}

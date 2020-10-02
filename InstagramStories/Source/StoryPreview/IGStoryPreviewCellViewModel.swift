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
    public var direction: SnapMovementDirectionState = .forward
    
    var updateScreenDirection = Dynamic<SnapMovementDirectionState>()
    
    public var handpickedSnapIndex: Int = 0
    
    public var snapIndex: Int = 0 {
        didSet {
            updateScreenDirection.value = direction
        }
    }
    
    private(set) var snapViewTag = 8
    
    public var videoSnapIndex: Int = 0
    
    public var previousSnapIndex: Int {
        snapIndex - 1
    }
    
    
    
}

//
//  IGStoryPreviewModel.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 18/03/18.
//  Copyright © 2018 DrawRect. All rights reserved.
//
import Foundation

#warning("First concentrate on StoryPreviewController then go for StoryPreviewCell")

/*
 Actions Performs on Preview Controller
 Test cases would have followed below functions
 
 1)Delete snap
 2)Show Action sheet
 3)Dismiss screen
 4)Long press action
 5)Right Tap to move on next story or snap
 6)Left Tap to move to previous story or snap
 7)Number of items in section
 8)CellForItemAt indexpath
 9)WilDisplayCell for item at indexpath
 10)DidEndDisplaying cell for item indexpath
 11)SizeForItem at indexpath
 12)ScrollViewWillBeginDragging
 13)ScrollViewDidEndDragging
 14)didCompletePreview
 15)moveToPreviousStory
 
 */

final class IGStoryPreviewModel {
    
    let stories: [IGStory]
    var handPickedStoryIndex: Int
    var handPickedSnapIndex: Int
    var nStoryIndex: Int = 0
    var currentIndexPath: IndexPath?
    var story_copy: IGStory?
    
    var moveStoryOnIndexPath = Dynamic<IndexPath>()
    var dismissScreen = Dynamic<Bool>()
        
    init(stories: [IGStory], handPickedStoryIndex: Int, handPickedSnapIndex: Int) {
        self.stories = stories
        self.handPickedStoryIndex = handPickedStoryIndex
        self.handPickedSnapIndex = handPickedSnapIndex
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        stories.count
    }
    func cellForItemAtIndexPath(_ indexPath: IndexPath) -> IGStory {
        assert(indexPath.item < stories.count,"index path is out of bounds")
        currentIndexPath = indexPath
        nStoryIndex = indexPath.item
        return stories[indexPath.item]
    }
}


extension IGStoryPreviewModel: StoryPreviewProtocol {
    #warning("can you merge didCompletePreview & moveToPreviousStory function in one. where it should carry forward the bool or enum, which should tell move forward or backward. then apply the logic")
    func didCompletePreview() {
        let n = handPickedStoryIndex+nStoryIndex+1
        if n < stories.count {
            //Move to next story
            story_copy = stories[nStoryIndex+handPickedStoryIndex]
            nStoryIndex += 1
            moveStoryOnIndexPath.value = IndexPath(row: nStoryIndex, section: 0)
        } else {
            self.dismissScreen.value = true
        }
    }
    func moveToPreviousStory() {
        let n = nStoryIndex+1
        if n > 1 && n <= stories.count {
            //Move to previous story
            story_copy = stories[nStoryIndex+handPickedStoryIndex]
            nStoryIndex -=  1
            moveStoryOnIndexPath.value = IndexPath(row: nStoryIndex, section: 0)
        } else {
            self.dismissScreen.value = true
        }
    }
    func didTapCloseButton() {
        self.dismissScreen.value = true
    }
}

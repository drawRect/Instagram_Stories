//
//  IGStoryPreviewModel.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 18/03/18.
//  Copyright © 2018 DrawRect. All rights reserved.
//

import Foundation

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

class IGStoryPreviewModel: NSObject {
    
    //MARK:- iVars
    let stories: [IGStory]
    let handPickedStoryIndex: Int //starts with(i)
    
    //MARK:- Init method
    init(stories: [IGStory], handPickedStoryIndex: Int) {
        self.stories = stories
        self.handPickedStoryIndex = handPickedStoryIndex
    }
    
    //MARK:- Functions
    func numberOfItemsInSection(_ section: Int) -> Int {
        stories.count
    }
    func cellForItemAtIndexPath(_ indexPath: IndexPath) -> IGStory? {
        assert(indexPath.item < stories.count,"Story index mis-match")
        return stories[indexPath.item]
    }
}

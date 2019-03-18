//
//  IGStoryPreviewModel.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 18/03/18.
//  Copyright © 2018 DrawRect. All rights reserved.
//

import Foundation

class IGStoryPreviewModel: NSObject {
    
    //MARK:- iVars
    var stories: IGStories?
    var handPickedStoryIndex: Int? //starts with(i)
    
    //MARK:- Init method
    init(_ stories: IGStories, _ handPickedStoryIndex: Int) {
        self.stories = stories
        self.handPickedStoryIndex = handPickedStoryIndex
    }
    
    //MARK:- Functions
    func numberOfItemsInSection(_ section: Int) -> Int {
        if let count = stories?.count {
            return count-handPickedStoryIndex!
        }
        return 0
    }
    func cellForItemAtIndexPath(_ indexPath: IndexPath) -> IGStory? {
        guard let handPickedIndex = handPickedStoryIndex, let count = stories?.count else {return nil}
        let counted = handPickedIndex+indexPath.item
        if counted < count {
            return stories?.stories[counted]
        }else {
            fatalError("Stories Index mis-matched :(")
        }
    }
}

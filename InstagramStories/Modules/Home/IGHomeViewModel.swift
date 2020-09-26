//
//  IGHomeViewModel.swift
//  InstagramStories
//
//  Created by  Boominadha Prakash on 01/11/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import Foundation

final class IGHomeViewModel {
    
    //MARK: - iVars
    var stories: IGStories
    var showAlertMsg = Dynamic<String>()
    var presentPreviewScreen = Dynamic<IGStoryPreviewController>()
    
    init(stories: IGStories) {
        self.stories = stories
    }
    
    internal let isClearCacheEnabled = true
    internal var isDeleteSnapEnabled = true
    
    //MARK: - Public functions
    
    var presentUserDetails: (String, String) {
        ("Your story",
         "https://avatars2.githubusercontent.com/u/32802714?s=200&v=4")
    }
    
    ///CollectionView numberOfItemsInSection Method
    public func numberOfItemsInSection(_ section: Int) -> Int {
        stories.otherStoriesCount + 1
    }
    
    ///CollectionView cellForItemAt Method
    public func cellForItemAt(indexPath: IndexPath) -> IGStory {
        stories.otherStories[indexPath.row-1]
    }
    
    ///CollectionView didSelectItem Method
    public func didSelectItemAt(indexPath: IndexPath) {
        if indexPath.row == 0 {
            isDeleteSnapEnabled = true
            if(isDeleteSnapEnabled) {
                guard let storiesCopy = try? self.stories.copy().myStory,
                      let story = storiesCopy.first,
                      !story.snaps.isEmpty else {
                    return self.showAlertMsg.value = "Redirect to Add Story screen"
                }
                self.presentPreviewScreen.value = getPreviewController(stories: storiesCopy, storyIndex: indexPath.row)
            } else {
                self.showAlertMsg.value = "Try to implement your own functionality for 'Your story'"
            }
        }else {
            isDeleteSnapEnabled = false
            if let storiesCopy = try? self.stories.copy().otherStories {
                self.presentPreviewScreen.value = getPreviewController(stories: storiesCopy, storyIndex: indexPath.row-1)
            }
        }
    }
    
    ///Clear Image & Video cache
    @objc public func clearImageCache() {
        IGCache.shared.removeAllObjects()
        IGStories.removeAllVideoFilesFromCache()
        self.showAlertMsg.value = "Images & Videos are deleted from cache"
    }
    
    private func getPreviewController(stories: [IGStory],
                                      storyIndex: Int) -> IGStoryPreviewController {
        IGStoryPreviewController(stories: stories,
                                 handPickedStoryIndex: storyIndex,
                                 handPickedSnapIndex: 0,
                                 isDeleteSnapEnabled: isDeleteSnapEnabled)
    }
    
}

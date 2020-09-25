//
//  IGHomeViewModel.swift
//  InstagramStories
//
//  Created by  Boominadha Prakash on 01/11/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import Foundation
import UIKit

public struct IGHomeViewModel {
    
    //MARK: - iVars
    var stories: IGStories
    var showAlertMsg = Dynamic<String>()
    var presentPreviewScreen = Dynamic<IGStoryPreviewController>()
    
    //MARK: - Public functions
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        stories.otherStoriesCount + 1
    }
    func cellForItemAt(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.register(IGAddStoryCell.self, indexPath: indexPath)
            cell.userDetails = ("Your story","https://avatars2.githubusercontent.com/u/32802714?s=200&v=4")
            return cell
        } else {
            let cell =  collectionView.register(IGStoryListCell.self, indexPath: indexPath)
            cell.story = stories.otherStories[indexPath.row-1]
            return cell
        }
    }
    
    func didSelectItemAt(indexPath: IndexPath) {
        if indexPath.row == 0 {
            isDeleteSnapEnabled = true
            if(isDeleteSnapEnabled) {
                if let stories_copy = try? self.stories.copy().myStory,
                   stories_copy.count > 0 && stories_copy[0].snaps.count > 0 {
                    let storyPreviewController = IGStoryPreviewController(stories: stories_copy, handPickedStoryIndex: indexPath.row, handPickedSnapIndex: 0)
                    self.presentPreviewScreen.value = storyPreviewController
                } else {
                    self.showAlertMsg.value = "Redirect to Add Story screen"
                }
            } else {
                self.showAlertMsg.value = "Try to implement your own functionality for 'Your story'"
            }
        }else {
            isDeleteSnapEnabled = false
            if let stories_copy = try? self.stories.copy().otherStories {
                let storyPreviewController = IGStoryPreviewController(stories: stories_copy, handPickedStoryIndex: indexPath.row-1, handPickedSnapIndex: 0)
                self.presentPreviewScreen.value = storyPreviewController
            }
        }
    }
    
    func sizeForItemAt(indexPath: IndexPath) -> CGSize {
        indexPath.row == 0 ? CGSize(width: 100, height: 100) : CGSize(width: 80, height: 100)
    }
}

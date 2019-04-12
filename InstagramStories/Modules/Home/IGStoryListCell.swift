//
//  IGStoryListCell.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

final class IGStoryListCell: StoryCell {

    var story: IGStory! {
        didSet {
            profileNameLabel.text = story.user.name
            profileImageView.imageView.setImage(url: story.user.picture)
            profileImageView.enableBorder()
        }
    }
    
}

extension IGStoryListCell {
   static var size: CGSize {
        return CGSize(width: 80, height: 100)
    }
}

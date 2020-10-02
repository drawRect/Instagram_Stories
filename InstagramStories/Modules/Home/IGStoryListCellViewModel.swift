//
//  IGStoryListCellViewModel.swift
//  InstagramStories
//
//  Created by Ranjit on 02/10/20.
//  Copyright © 2020 DrawRect. All rights reserved.
//

import Foundation

final class IGStoryListCellViewModel {
    var story: IGStory! {
        didSet {
            name.value = story.user.name
            picture.value = story.user.picture
        }
    }
    var name = Dynamic<String>()
    var picture = Dynamic<String>()
}

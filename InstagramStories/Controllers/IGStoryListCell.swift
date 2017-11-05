//
//  IGStoryListCell.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

final class IGStoryListCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = profileImageView.frame.width/2
            profileImageView.clipsToBounds = true
            profileImageView.layer.borderWidth = 3.0
            profileImageView.layer.borderColor = UIColor.white.cgColor
        }
    }
    @IBOutlet weak var profileNameLabel: UILabel!
    public var story:IGStory? {
        didSet {
            self.profileNameLabel.text = story?.user?.name
            if let picture = story?.user?.picture {
                self.profileImageView.setImage(url: picture)
            }
        }
    }
}

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
    
    override func addChildViews() {
        addSubview(profileImageView)
        addSubview(profileNameLabel)
    }
    
    override func installConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 68),
            profileImageView.heightAnchor.constraint(equalToConstant: 68),
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor)])

        NSLayoutConstraint.activate([
            profileNameLabel.leftAnchor.constraint(equalTo: leftAnchor),
            profileNameLabel.rightAnchor.constraint(equalTo: rightAnchor),
            profileNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 2),
            profileNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)])
        
        layoutIfNeeded()
    }
}

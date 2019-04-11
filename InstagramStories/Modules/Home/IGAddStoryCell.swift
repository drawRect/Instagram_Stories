//
//  IGAddStoryCell.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

final class IGAddStoryCell: StoryCell {

    let addImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "ic_Add"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 20/2
        iv.layer.borderWidth = 2.0
        iv.layer.borderColor = UIColor.white.cgColor
        iv.clipsToBounds = true
        return iv
    }()

    override func addChildViews() {
        addSubview(profileNameLabel)
        addSubview(profileImageView)
        addSubview(addImageView)

        profileNameLabel.alpha = 0.5
        profileNameLabel.text = "Your Story"
        profileImageView.imageView.setImage(url: "https://avatars2.githubusercontent.com/u/32802714?s=200&v=4")
        profileImageView.enableBorder(false)
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
        
        NSLayoutConstraint.activate([
            addImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -17),
            addImageView.widthAnchor.constraint(equalToConstant: 20),
            addImageView.heightAnchor.constraint(equalToConstant: 20),
            addImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25)])
        
        layoutIfNeeded()
    }
}

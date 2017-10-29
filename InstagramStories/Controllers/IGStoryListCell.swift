//
//  IGStoryListCell.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

final class IGStoryListCell: UICollectionViewCell {
    
    let profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect.zero
        imageView.layer.cornerRadius = imageView.frame.width/2
        imageView.clipsToBounds = true

        imageView.layer.borderWidth = 3.0
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let profileNameLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    func loadUIElements(){
        contentView.addSubview(profileImageView)
        contentView.addSubview(profileNameLabel)
    }
    
    func installLayoutConstraints(){
        profileImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true

        profileNameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        profileNameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        profileNameLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
        profileNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        profileNameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
       layoutIfNeeded()
    }

    override init(frame:CGRect)
    {
        super.init(frame:frame)
        loadUIElements()
        installLayoutConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public var story:IGStory? {
        didSet {
            self.profileNameLabel.text = story?.user?.name
            if let picture = story?.user?.picture {
                self.profileImageView.setImage(url: picture)
            }
        }
    }
}

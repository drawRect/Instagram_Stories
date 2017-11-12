//
//  IGStoryListCell.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

final class IGStoryListCell: UICollectionViewCell {
    
    override init(frame:CGRect)
    {
        super.init(frame:frame)
        loadUIElements()
        installLayoutConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        self.addSubview(profileImageView)
        self.addSubview(profileNameLabel)
    }
    
    public var story:IGStory? {
        didSet {
            self.profileNameLabel.text = story?.user?.name
            if let picture = story?.user?.picture {
                self.profileImageView.setImage(url: picture)
            }
        }
    }
    
    func installLayoutConstraints(){
        NSLayoutConstraint.activate([profileImageView.widthAnchor.constraint(equalToConstant: 60),
        profileImageView.heightAnchor.constraint(equalToConstant: 60),
        profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
        profileImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor)])
        
        NSLayoutConstraint.activate([profileNameLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
        profileNameLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
        profileNameLabel.heightAnchor.constraint(equalToConstant: 21),
        profileNameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
        profileNameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)])
        layoutIfNeeded()
    }
}

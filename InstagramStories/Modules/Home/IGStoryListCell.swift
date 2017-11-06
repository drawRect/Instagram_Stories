//
//  IGStoryListCell.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

final class IGStoryListCell: UICollectionViewCell {
    
    override init(frame:CGRect){
        super.init(frame:frame)
        createViews()
        installConstraints()
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
    
    func createViews(){
        addSubview(profileImageView)
        addSubview(profileNameLabel)
    }
    
    public var story:IGStory? {
        didSet {
            profileNameLabel.text = story?.user?.name
            if let picture = story?.user?.picture {
                profileImageView.setImage(url: picture)
            }
        }
    }
    //TODO:-Need some improvements
    //Missing Basic 8-8(top|bottom) space on Label
    func installConstraints(){
        profileImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        profileNameLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        profileNameLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        profileNameLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
        profileNameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileNameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        layoutIfNeeded()
    }
}

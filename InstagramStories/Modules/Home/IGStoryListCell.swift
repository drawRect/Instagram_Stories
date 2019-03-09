//
//  IGStoryListCell.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

final class IGStoryListCell: UICollectionViewCell {
    
    //MARK: - Public iVars
    public var story: IGStory? {
        didSet {
            self.profileNameLabel.text = story?.user.name
            if let picture = story?.user.picture {
                self.profileImageView.setImage(url: picture)
            }
        }
    }
    public var userDetails: (String,String)? {
        didSet {
            if let details = userDetails {
                self.profileNameLabel.text = details.0
                self.profileImageView.setImage(url: details.1)
            }
        }
    }
    
    //MARK: - Private iVars
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect.zero
        imageView.layer.cornerRadius = imageView.frame.width/2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2.0
        imageView.layer.borderColor = UIColor.init(red: 50/255, green: 199/255, blue: 242/255, alpha: 1.0).cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let profileNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = UIColor.init(red: 50/255, green: 199/255, blue: 242/255, alpha: 1.0)
        return label
    }()
    
    //MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadUIElements()
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Private functions
    private func loadUIElements() {
        self.addSubview(profileImageView)
        self.addSubview(profileNameLabel)
    }
    private func installLayoutConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            profileImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor)])
        
        NSLayoutConstraint.activate([
            profileNameLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
            profileNameLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            profileNameLabel.heightAnchor.constraint(equalToConstant: 21),
            profileNameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            profileNameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)])
        
        layoutIfNeeded()
    }
}

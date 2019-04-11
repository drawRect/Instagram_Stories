//
//  IGStoryListCell.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

final class IGStoryListCell: UICollectionViewCell {
    
    //MARK: - Public iVars
    public var story: IGStory? {
        didSet {
            self.profileNameLabel.text = story?.user.name
            if let picture = story?.user.picture {
                self.profileImageView.imageView.setImage(url: picture)
            }
        }
    }
    public var userDetails: (String,String)? {
        didSet {
            if let details = userDetails {
                self.profileNameLabel.text = details.0
                self.profileImageView.imageView.setImage(url: details.1)
            }
        }
    }
    
    //MARK: -  Private ivars
    private let profileImageView: IGRoundedView = {
        let roundedView = IGRoundedView()
        roundedView.translatesAutoresizingMaskIntoConstraints = false
        return roundedView
    }()
    
    private let profileNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    lazy var addImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "ic_Add")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
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
        addSubview(profileImageView)
        addSubview(profileNameLabel)
        addSubview(addImageView)
    }
    private func installLayoutConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 68),
            profileImageView.heightAnchor.constraint(equalToConstant: 68),
            profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            profileImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor)])

        NSLayoutConstraint.activate([
            profileNameLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
            profileNameLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            profileNameLabel.topAnchor.constraint(equalTo: self.profileImageView.bottomAnchor, constant: 2),
            profileNameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            profileNameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)])
        
        NSLayoutConstraint.activate([
            addImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -17),
            addImageView.widthAnchor.constraint(equalToConstant: 20),
            addImageView.heightAnchor.constraint(equalToConstant: 20),
            addImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)])
        
        layoutIfNeeded()
    }
}


extension IGStoryListCell {
    func applyCellForOthers(others: Bool = true) {
        if others == true {
            profileImageView.enableBorder()
            profileNameLabel.alpha = 1.0
            addImageView.isHidden = true
        }else {
            profileImageView.enableBorder(enabled: false)
            profileNameLabel.alpha = 0.5
            addImageView.isHidden = false
        }
    }
}


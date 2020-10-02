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
    public var viewModel = IGStoryListCellViewModel()
    
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
    
    //MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadUIElements()
        installLayoutConstraints()
        viewModelObservers()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func viewModelObservers() {
        self.viewModel.name.bind {
            if let name = $0 {
                self.profileNameLabel.text = name
            }
        }
        self.viewModel.picture.bind {
            if let picture = $0 {
                self.profileImageView.imageView.setImage(url: picture)
            }
        }
    }
    
    //MARK:- Private functions
    private func loadUIElements() {
        addSubview(profileImageView)
        addSubview(profileNameLabel)
    }
    private func installLayoutConstraints() {
        installProfileImageViewConstraints()
        installProfileNameConstraints()
        layoutIfNeeded()
    }
    
    private func installProfileImageViewConstraints() {
        let width = profileImageView.widthAnchor.constraint(equalToConstant: 68)
        let height = profileImageView.heightAnchor.constraint(equalToConstant: 68)
        let top = profileImageView.igTopAnchor.constraint(equalTo: self.igTopAnchor, constant: 8)
        let centerX = profileImageView.igCenterXAnchor.constraint(equalTo: self.igCenterXAnchor)
        NSLayoutConstraint.activate([width, height, top, centerX])
    }
    
    private func installProfileNameConstraints() {
        let left = profileNameLabel.igLeftAnchor.constraint(equalTo: self.igLeftAnchor)
        let right = profileNameLabel.igRightAnchor.constraint(equalTo: self.igRightAnchor)
        let top = profileNameLabel.igTopAnchor.constraint(equalTo: self.profileImageView.igBottomAnchor, constant: 2)
        let centerX = profileNameLabel.igCenterXAnchor.constraint(equalTo: self.igCenterXAnchor)
        let bottom = self.igBottomAnchor.constraint(equalTo: profileNameLabel.igBottomAnchor, constant: 8)
        NSLayoutConstraint.activate([left, right, top, centerX, bottom])
    }
}

//
//  StoryCell.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 4/12/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import Foundation
import UIKit

class StoryCell: UICollectionViewCell {
    
    let profileNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    let profileImageView: IGRoundedView = {
        let rv = IGRoundedView()
        rv.translatesAutoresizingMaskIntoConstraints = false
        return rv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addChildViews()
        installConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    func addChildViews() {
        addSubview(profileNameLabel)
        addSubview(profileImageView)
    }
    func installConstraints() {
        NSLayoutConstraint.activate(
            [
            profileImageView.widthAnchor.constraint(
                equalToConstant: 68
                ),
            profileImageView.heightAnchor.constraint(
                equalToConstant: 68
                ),
            profileImageView.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 8
                ),
            profileImageView.centerXAnchor.constraint(
                equalTo: centerXAnchor
                )
            ]
        )

        NSLayoutConstraint.activate(
            [
            profileNameLabel.leftAnchor.constraint(
                equalTo: leftAnchor
                ),
            profileNameLabel.rightAnchor.constraint(
                equalTo: rightAnchor
                ),
            profileNameLabel.topAnchor.constraint(
                equalTo: profileImageView.bottomAnchor,
                constant: 2
                ),
            profileNameLabel.centerXAnchor.constraint(
                equalTo: centerXAnchor
                ),
            profileNameLabel.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -8
                )
            ]
        )
    }

}

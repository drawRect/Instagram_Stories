//
//  IGAddStoryCell.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

final class IGAddStoryCell: UICollectionViewCell {

    override func layoutSubviews() {
        let addStoryLabel = UILabel()
        addStoryLabel.textColor = .black
        addStoryLabel.textAlignment = .center
        addStoryLabel.translatesAutoresizingMaskIntoConstraints = false
        addStoryLabel.text = "Add Story"
        addStoryLabel.font = UIFont(name: "Helvetica", size: 18.0)
        contentView.addSubview(addStoryLabel)
        
        //Setting the constraints
        addStoryLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        addStoryLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
    }
}

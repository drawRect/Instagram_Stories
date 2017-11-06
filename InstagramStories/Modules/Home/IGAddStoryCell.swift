//
//  IGAddStoryCell.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

final class IGAddStoryCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        createViews()
        installConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let addStoryLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Add Story"
        label.font = UIFont(name: "Helvetica", size: 18.0)
        return label
    }()
    
    private func createViews() {
        addSubview(addStoryLabel)
    }
    private func installConstraints() {
        addStoryLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        addStoryLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}

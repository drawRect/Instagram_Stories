//
//  IGAddStoryView.swift
//  InstagramStories
//
//  Created by Srikanth Vellore on 31/10/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

class IGAddStoryView: UIView {
    
    let addStoryLabel:UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Add Story"
        label.font = UIFont(name: "Helvetica", size: 18.0)
        return label
    }()
    
    private func loadUIElements() {
        self.addSubview(addStoryLabel)
    }
    private func installLayoutConstraints() {
        addStoryLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        addStoryLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadUIElements()
        installLayoutConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

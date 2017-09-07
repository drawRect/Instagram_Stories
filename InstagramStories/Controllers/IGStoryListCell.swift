//
//  IGStoryListCell.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

class IGStoryListCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            //TODO:Remove the hardcoded value
            profileImageView.layer.cornerRadius = 60/2
            profileImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var profileNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public class func reuseIdentifier()->String{
        return "IGStoryListCell"
    }
   
}

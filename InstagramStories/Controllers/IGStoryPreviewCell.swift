//
//  IGStoryPreviewCell.swift
//  InstagramStories
//
//  Created by Srikanth Vellore on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

class IGStoryPreviewCell: UICollectionViewCell {

    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var headerView: UIView!
    lazy var storyHeaderView:IGStoryPreviewHeaderView=IGStoryPreviewHeaderView.instanceFromNib()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.headerView.addSubview(storyHeaderView)
    }
    
    public class func reuseIdentifier()->String{
        return "IGStoryPreviewCell"
    }

}

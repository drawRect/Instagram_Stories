//
//  IGStoryPreviewCell.swift
//  InstagramStories
//
//  Created by Srikanth Vellore on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

class IGStoryPreviewCell: UICollectionViewCell {

    @IBOutlet weak var scrollview: UIScrollView!
    //@IBOutlet weak var imageview: UIImageView!
    var storyHeaderView:IGStoryPreviewHeaderView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        storyHeaderView = IGStoryPreviewHeaderView.instanceFromNib()
        storyHeaderView?.frame = CGRect(x:0,y:0,width:self.frame.width,height:80)
        self.contentView.addSubview(storyHeaderView!)
    }
    
    public class func reuseIdentifier()->String{
        return "IGStoryPreviewCell"
    }
    
    public func nextSnap(maxContentSize:CGFloat)
    {
        if (self.scrollview.contentOffset.x + self.frame.size.width) < maxContentSize
        {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 5.0, delay: 2, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    self.scrollview.contentOffset.x += self.frame.size.width
                }, completion: { (Bool) in
                    self.nextSnap(maxContentSize: maxContentSize)
                })
            }
        }
    }
}

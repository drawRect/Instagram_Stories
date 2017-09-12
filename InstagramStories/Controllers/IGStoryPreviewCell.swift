//
//  IGStoryPreviewCell.swift
//  InstagramStories
//
//  Created by Srikanth Vellore on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

protocol StoryPreviewProtocol {
    func didCompletePreview()
}

class IGStoryPreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var scrollview: UIScrollView!
    public var delegate:StoryPreviewProtocol?
    var storyHeaderView:IGStoryPreviewHeaderView?
    fileprivate var snapIndex:Int = 0 {
        didSet {
            if let snap = story?.snaps?[snapIndex] {
                if let picture = snap.mediaURL {
                    let iv = self.imageView(with: snapIndex)
                    startLoadContent(with: iv, picture: picture)
                }
            }
        }
    }
    
    public var story:IGStory? {
        didSet {
            self.storyHeaderView?.story = story
            self.storyHeaderView?.generateSnappers()
            if let picture = story?.user?.picture {
                self.storyHeaderView?.snaperImageView.setImage(url: picture)
            }
            snapIndex = 0
        }
    }
    
    func generateImageViews() {
        if let count = story?.snapsCount {
            for index in 0..<count {
                let x:CGFloat = CGFloat(index) * frame.size.width
                let iv = UIImageView(frame: CGRect(x:x, y:0, width:frame.size.width, height:frame.size.height))
                iv.tag = index
                scrollview.addSubview(iv)
            }
        }
    }
    
    public func startLoadContent(with imageView:UIImageView,picture:String) {
        imageView.setImage(url: picture, style: .squared, completion: { (result, error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                //Start the progress
                let pv = self.storyHeaderView?.progressView(with: self.snapIndex)
                pv?.delegate = self
                pv?.didBeginProgress()
            }
        })
    }
    
    public func imageView(with index:Int)->UIImageView {
        return scrollview.subviews.filter({v in v.tag == index}).first as! UIImageView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        storyHeaderView = IGStoryPreviewHeaderView.instanceFromNib()
        storyHeaderView?.frame = CGRect(x:0,y:0,width:self.frame.width,height:80)
        self.contentView.addSubview(storyHeaderView!)
    }
    
}

extension IGStoryPreviewCell:SnapProgresser {
    func didCompleteProgress() {
        let n = snapIndex + 1
        if let count = story?.snapsCount {
            if n < count {
                //Move to next story
                let x = n.toFloat() * frame.width
                let offset = CGPoint(x:x,y:0)
                scrollview.setContentOffset(offset, animated: false)
                snapIndex = n
            }else {
                self.delegate?.didCompletePreview()
            }
        }
    }
}

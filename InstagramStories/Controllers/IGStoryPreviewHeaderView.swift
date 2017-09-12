//
//  IGStoryPreviewHeaderView.swift
//  InstagramStories
//
//  Created by Srikanth Vellore on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

protocol SnapProgresser {
    func didCompleteProgress()
}
class IGSnapProgressView:UIProgressView {
    public var delegate:SnapProgresser?
}

extension IGSnapProgressView {
    func didBeginProgress() {
        if progress == 1.0 {
            self.delegate?.didCompleteProgress()
        }else {
            progress = progress+0.1
            didBeginProgress()
        }
    }
}

protocol StoryPreviewHeaderTapper {
    func didTapCloseButton()
}

class IGStoryPreviewHeaderView: UIView {
    public var delegate:StoryPreviewHeaderTapper?
    fileprivate var maxSnaps:Int = 30
    public var story:IGStory? {
        didSet {
            maxSnaps  = (story?.snaps?.count)! < maxSnaps ? (story?.snaps?.count)! : maxSnaps
        }
    }
    
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var snaperImageView: UIImageView! {
        didSet {
            snaperImageView.layer.cornerRadius = 40/2
            snaperImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var snaperNameLabel: UILabel!
    
    //MARK: - Selectors
    @IBAction func didTapClose(_ sender: Any) {
        self.delegate?.didTapCloseButton()
    }
    
    class func instanceFromNib() -> IGStoryPreviewHeaderView {
        let view =  Bundle.loadView(fromNib: "IGStoryPreviewHeaderView", withType: IGStoryPreviewHeaderView.self)
        return view
    }
    
    public func progressView(with index:Int)->IGSnapProgressView {
        return progressView.subviews.filter({v in v.tag == index}).first as! IGSnapProgressView
    }
    
    func generateSnappers(){
        let padding:CGFloat = 8 //GUI-Padding
        var pvX:CGFloat = padding
        let pvY:CGFloat = (self.progressView.frame.height/2)-5
        let pvWidth = (UIScreen.main.bounds.width - ((maxSnaps+1).toFloat() * padding))/maxSnaps.toFloat()
        let pvHeight:CGFloat = 5
        for i in 0..<maxSnaps{
            let pv = IGSnapProgressView.init(frame: CGRect(x:pvX,y:pvY,width:pvWidth,height:pvHeight))
            pv.progressTintColor = .red
            pv.progress = 0.0
            pv.tag = i
            progressView.addSubview(pv)
            pvX = pvX + pvWidth + padding
        }
        snaperNameLabel.text = story?.user?.name
    }
    
}


extension Int {
    func toFloat()->CGFloat {
        return CGFloat(self)
    }
}

//
//  IGStoryPreviewHeaderView.swift
//  InstagramStories
//
//  Created by Srikanth Vellore on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

protocol StoryPreviewHeaderTapper {
    func didTapCloseButton()
}

class IGStoryPreviewHeaderView: UIView {
    public var delegate:StoryPreviewHeaderTapper?
    fileprivate var maxSnaps:Int = 30
    public var story:IGStory? {
        didSet {
            maxSnaps  = (story?.snapsCount)! < maxSnaps ? (story?.snapsCount)! : maxSnaps
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
    
    //MARK: - Class functions
    class func instanceFromNib() -> IGStoryPreviewHeaderView {
        let view =  Bundle.loadView(fromNib: "IGStoryPreviewHeaderView", withType: IGStoryPreviewHeaderView.self)
        return view
    }
    
    //MARK: - Public functions
    public func progressView(with index:Int)->IGSnapProgressView {
        return progressView.subviews.filter({v in v.tag == index}).first as! IGSnapProgressView
    }
    public func generateSnappers(){
        let padding:CGFloat = 8 //GUI-Padding
        let pvHeight:CGFloat = 5
        var pvX:CGFloat = padding
        let pvY:CGFloat = (self.progressView.frame.height/2)-pvHeight //Height:5
        let pvWidth = (UIScreen.main.bounds.width - ((maxSnaps+1).toFloat() * padding))/maxSnaps.toFloat()
        
        for i in 0..<maxSnaps{
            let pv = IGSnapProgressView.init(frame: CGRect(x:pvX,y:pvY,width:pvWidth,height:pvHeight))
            pv.progressTintColor = UIColor.white
            pv.trackTintColor = UIColor.white.withAlphaComponent(0.2)
            pv.progress = 0.0
            pv.tag = i
            pv.layer.cornerRadius = pvHeight/2
            pv.layer.masksToBounds = true
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

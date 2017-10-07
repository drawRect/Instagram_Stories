//
//  IGStoryPreviewHeaderView.swift
//  InstagramStories
//
//  Created by Srikanth Vellore on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit
import SDWebImage

protocol StoryPreviewHeaderTapper:class {func didTapCloseButton()}

fileprivate let maxSnaps = 30

class IGStoryPreviewHeaderView: UIView {
    //MARK: - Overriden functions
    //Warning: If you use this following shadow one more time. Please create UIView+Additions(Extension)
    override func awakeFromNib() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
    }
    
    public weak var delegate:StoryPreviewHeaderTapper?
    fileprivate var snapsPerStory:Int = 0
    public var story:IGStory? {
        didSet {
            snapsPerStory  = (story?.snapsCount)! < maxSnaps ? (story?.snapsCount)! : maxSnaps
        }
    }
    
    @IBOutlet private weak var progressView: UIView!
    //Todo:Make Private scope
    @IBOutlet internal weak var snaperImageView: UIImageView! {
        didSet {
            snaperImageView.layer.cornerRadius = 40/2
            snaperImageView.clipsToBounds = true
        }
    }
    @IBOutlet private weak var snaperNameLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
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
        self.progressView.subviews.forEach { v in v.removeFromSuperview()}
        let padding:CGFloat = 8 //GUI-Padding
        let pvHeight:CGFloat = 5
        var pvX:CGFloat = padding
        let pvY:CGFloat = (self.progressView.frame.height/2)-pvHeight
        let pvWidth = (IGScreen.width - ((snapsPerStory+1).toFloat() * padding))/snapsPerStory.toFloat()
        for i in 0..<snapsPerStory{
            let pv = IGSnapProgressView.init(frame: CGRect(x:pvX,y:pvY,width:pvWidth,height:pvHeight))
            pv.progressTintColor = UIColor.white
            pv.trackTintColor = UIColor.white.withAlphaComponent(0.1)
            pv.progress = 0.0
            pv.tag = i
            pv.layer.cornerRadius = 1
            pv.layer.masksToBounds = true
            progressView.addSubview(pv)
            pvX = pvX + pvWidth + padding
        }
        snaperNameLabel.text = story?.user?.name
    }
    public func nullifyProgressors() {
        self.progressView.subviews.forEach { p in
            (p as! IGSnapProgressView).progress = 0.0
        }
    }
    
    public func cancelTimers(snapIndex:Int){
        self.progressView(with: snapIndex).stopTimer()
    }
}

extension Int {
    func toFloat()->CGFloat {
        return CGFloat(self)
    }
}

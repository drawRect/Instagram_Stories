//
//  IGStoryPreviewHeaderView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit
import SDWebImage

protocol StoryPreviewHeaderProtocol:class {func didTapCloseButton()}

fileprivate let maxSnaps = 30
//Identifiers
public let progressIndicatorViewTag = 88
public let progressViewTag = 99

final class IGStoryPreviewHeaderView: UIView {
    //MARK: - Overriden functions
    //Warning: If you use this following shadow one more time. Please create UIView+Additions(Extension)
    override func awakeFromNib() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
    }
    
    public weak var delegate:StoryPreviewHeaderProtocol?
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
    
    //MARK: - Public functions
    public func generateSnappers(){
        //clean up the garbage progress bars
        self.progressView.subviews.forEach { v in v.removeFromSuperview()}
        let padding:CGFloat = 8 //GUI-Padding
        let pvHeight:CGFloat = 3
        var pvX:CGFloat = padding
        let pvY:CGFloat = (self.progressView.frame.height/2)-pvHeight
        let pvWidth = (IGScreen.width - ((snapsPerStory+1).toFloat() * padding))/snapsPerStory.toFloat()
        for i in 0..<snapsPerStory{
            let pvIndicator = UIView.init(frame: CGRect(x:pvX,y:pvY,width:pvWidth,height:pvHeight))
            pvIndicator.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            pvIndicator.tag = i+progressIndicatorViewTag
            pvIndicator.layer.cornerRadius = 1
            pvIndicator.layer.masksToBounds = true
            progressView.addSubview(pvIndicator)
            let pv = IGSnapProgressView.init(frame: CGRect(x:pvX,y:pvY,width:0,height:pvHeight))
            pv.backgroundColor = UIColor.white
            pv.tag = i+progressViewTag
            pv.layer.cornerRadius = pvIndicator.layer.cornerRadius
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

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
    public func createSnapProgressors(){
        //clean up the garbage progress bars
        let progressors = progressView.subviews.filter({v in v is IGSnapProgressView}) as! [IGSnapProgressView]
        progressors.forEach({v in v.stop()})
        progressView.subviews.forEach { v in v.removeFromSuperview()}
        
        let padding:CGFloat = 8 //GUI-Padding
        let height:CGFloat = 3
        var x:CGFloat = padding
        let y:CGFloat = (self.progressView.frame.height/2)-height
        let width = (IGScreen.width - ((snapsPerStory+1).toFloat() * padding))/snapsPerStory.toFloat()
        for i in 0..<snapsPerStory{
            let pvIndicator = UIView.init(frame: CGRect(x: x, y: y, width: width, height: height))
            progressView.addSubview(applyProperties(pvIndicator, with: i+progressIndicatorViewTag,alpha:0.1))
            let pv = IGSnapProgressView.init(frame: CGRect(x: x, y: y, width: 0, height: height))
            progressView.addSubview(applyProperties(pv,with: i+progressViewTag))
            x = x + width + padding
        }
        snaperNameLabel.text = story?.user?.name
    }
    
   private func applyProperties<T:UIView>(_ view:T,with tag:Int,alpha:CGFloat = 1.0)->T {
        view.layer.cornerRadius = 1
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        view.tag = tag
        return view
    }
    
}

extension Int {
    func toFloat()->CGFloat {
        return CGFloat(self)
    }
}

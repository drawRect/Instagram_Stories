//
//  IGStoryPreviewHeaderView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

protocol StoryPreviewHeaderProtocol:class {func didTapCloseButton()}

fileprivate let maxSnaps = 30
//Identifiers
public let progressIndicatorViewTag = 88
public let progressViewTag = 99

final class IGStoryPreviewHeaderView: UIView {
    //MARK: - Overriden functions
    //Warning: If you use this following shadow one more time. Please create UIView+Additions(Extension)
    
    let progressView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let snaperImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    let detailView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let snaperNameLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let lastUpdatedLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let closeButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapClose(_:)), for: .touchUpInside)
        return button
    }()
    
    func loadUIElements(){
        self.addSubview(progressView)
        self.addSubview(snaperImageView)
        self.addSubview(detailView)
        detailView.addSubview(snaperNameLabel)
        detailView.addSubview(lastUpdatedLabel)
        self.addSubview(closeButton)
    }
    
    func installLayoutConstraints(){
        //Setting constraints for progressView
        progressView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        progressView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        progressView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        progressView.heightAnchor.constraint(equalToConstant: 10)
        
        //Setting constraints for snapperImageView
        snaperImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        snaperImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        snaperImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        snaperImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        snaperImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        //snaperImageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

        
        //Setting constraints for detailView
        detailView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        detailView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        detailView.leftAnchor.constraint(equalTo: snaperImageView.rightAnchor, constant: 10).isActive = true
        
        detailView.rightAnchor.constraint(equalTo: closeButton.leftAnchor, constant: 10).isActive = true
        
        //Setting constraints for closeButton
        closeButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        closeButton.leftAnchor.constraint(equalTo: detailView.rightAnchor, constant: 10).isActive = true
        closeButton.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        closeButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1).isActive = true
        
        
        //Setting constraints for snapperNameLabel
        snaperNameLabel.leftAnchor.constraint(equalTo: detailView.leftAnchor).isActive = true
        snaperNameLabel.rightAnchor.constraint(equalTo: lastUpdatedLabel.leftAnchor, constant: 10).isActive = true
        snaperNameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 10).isActive = true
        snaperNameLabel.centerYAnchor.constraint(equalTo: detailView.centerYAnchor).isActive = true
        
        //Setting constraints for lastUpdatedLabel
        lastUpdatedLabel.centerYAnchor.constraint(equalTo: detailView.centerYAnchor).isActive = true
        lastUpdatedLabel.leftAnchor.constraint(equalTo: snaperNameLabel.rightAnchor,constant:10).isActive = true
        
        layoutIfNeeded()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadUIElements()
        installLayoutConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /*override func awakeFromNib() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
    }*/
    
    public weak var delegate:StoryPreviewHeaderProtocol?
    fileprivate var snapsPerStory:Int = 0
    public var story:IGStory? {
        didSet {
            snapsPerStory  = (story?.snapsCount)! < maxSnaps ? (story?.snapsCount)! : maxSnaps
        }
    }
    //@IBOutlet private weak var progressView: UIView!
    //Todo:Make Private scope
    /*@IBOutlet internal weak var snaperImageView: UIImageView! {
        didSet {
            snaperImageView.layer.cornerRadius = snaperImageView.frame.height/2
            snaperImageView.clipsToBounds = true
            snaperImageView.layer.borderWidth = 1.0
            snaperImageView.layer.borderColor = UIColor.white.cgColor
        }
    }*/
    //@IBOutlet private weak var snaperNameLabel: UILabel!
    //@IBOutlet weak var lastUpdatedLabel: UILabel!
    
    //MARK: - Selectors
    @objc func didTapClose(_ sender: Any) {
        delegate?.didTapCloseButton()
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

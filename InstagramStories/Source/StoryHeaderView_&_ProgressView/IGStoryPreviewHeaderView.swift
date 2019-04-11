//
//  IGStoryPreviewHeaderView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

protocol StoryPreviewHeaderProtocol:class {func didTapCloseButton()}

fileprivate let maxSnaps = 30

//Identifiers
public let progressIndicatorViewTag = 88
public let progressViewTag = 99

final class IGStoryPreviewHeaderView: UIView {
    
    //MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        applyShadowOffset()
        loadUIElements()
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - iVars
    public weak var delegate:StoryPreviewHeaderProtocol?
    fileprivate var snapsPerStory:Int = 0
    public var story:IGStory? {
        didSet {
            snapsPerStory  = (story?.snapsCount)! < maxSnaps ? (story?.snapsCount)! : maxSnaps
        }
    }
    fileprivate var progressView:UIView?
    internal let snaperImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let detailView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let snaperNameLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    internal let lastUpdatedLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    private lazy var closeButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "ic_close"), for: .normal)
        button.addTarget(self, action: #selector(didTapClose(_:)), for: .touchUpInside)
        return button
    }()
    public var getProgressView: UIView {
        if let progressView = self.progressView {
            return progressView
        }
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        self.progressView = v
        self.addSubview(self.getProgressView)
        return v
    }
    
    //MARK: - Private functions
    private func loadUIElements(){
        backgroundColor = .clear
        addSubview(getProgressView)
        addSubview(snaperImageView)
        addSubview(detailView)
        detailView.addSubview(snaperNameLabel)
        detailView.addSubview(lastUpdatedLabel)
        addSubview(closeButton)
    }
    private func installLayoutConstraints(){
        //Setting constraints for progressView
        let pv = getProgressView
        NSLayoutConstraint.activate([
            pv.leftAnchor.constraint(equalTo: self.leftAnchor),
            pv.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            pv.rightAnchor.constraint(equalTo: self.rightAnchor),
            pv.heightAnchor.constraint(equalToConstant: 10)])
        
        //Setting constraints for snapperImageView
        NSLayoutConstraint.activate([
            snaperImageView.widthAnchor.constraint(equalToConstant: 40),
            snaperImageView.heightAnchor.constraint(equalToConstant: 40),
            snaperImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            snaperImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0.0)])
        
        //Setting constraints for detailView
        NSLayoutConstraint.activate([
            detailView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            detailView.heightAnchor.constraint(equalToConstant: 40),
            detailView.leftAnchor.constraint(equalTo: snaperImageView.rightAnchor, constant: 10),
            detailView.rightAnchor.constraint(equalTo: closeButton.leftAnchor, constant: 10)])
        
        //Setting constraints for closeButton
        NSLayoutConstraint.activate([
            closeButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            closeButton.rightAnchor.constraint(equalTo: self.rightAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 60),
            closeButton.heightAnchor.constraint(equalToConstant: self.frame.height)])
        
        //Setting constraints for snapperNameLabel
        NSLayoutConstraint.activate([
            snaperNameLabel.leftAnchor.constraint(equalTo: detailView.leftAnchor),
            lastUpdatedLabel.leftAnchor.constraint(equalTo: snaperNameLabel.rightAnchor, constant: 10.0),
            snaperNameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
            snaperNameLabel.centerYAnchor.constraint(equalTo: detailView.centerYAnchor)])
        
        //Setting constraints for lastUpdatedLabel
        NSLayoutConstraint.activate([lastUpdatedLabel.centerYAnchor.constraint(equalTo: detailView.centerYAnchor),
                                     lastUpdatedLabel.leftAnchor.constraint(equalTo: snaperNameLabel.rightAnchor, constant:10.0)])
        
        layoutIfNeeded()
    }
    private func applyShadowOffset() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
    }
    private func applyProperties<T:UIView>(_ view:T,with tag:Int,alpha:CGFloat = 1.0)->T {
        view.layer.cornerRadius = 1
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        view.tag = tag
        return view
    }
    
    //MARK: - Selectors
    @objc func didTapClose(_ sender: UIButton) {
        delegate?.didTapCloseButton()
    }
    
    //MARK: - Public functions
    public func clearTheProgressorSubviews() {
        getProgressView.subviews.forEach { v in
            v.subviews.forEach{v in (v as! IGSnapProgressView).stop()}
            v.removeFromSuperview()
        }
    }
    
    public func createSnapProgressors(){
        let padding:CGFloat = 8 //GUI-Padding
        let height:CGFloat = 3
        var x:CGFloat = padding
        let y:CGFloat = (self.getProgressView.frame.height/2)-height
        let width = (IGScreen.width - ((snapsPerStory+1).toFloat * padding))/snapsPerStory.toFloat
        for i in 0..<snapsPerStory{
            let pvIndicator = UIView.init(frame: CGRect(x: x, y: y, width: width, height: height))
            getProgressView.addSubview(applyProperties(pvIndicator, with: i+progressIndicatorViewTag,alpha:0.2))
            let pv = IGSnapProgressView.init(frame: CGRect(x: x, y: y, width: 0, height: height))
            getProgressView.addSubview(applyProperties(pv,with: i+progressViewTag))
            x = x + width + padding
        }
        snaperNameLabel.text = story?.user.name
    }
}

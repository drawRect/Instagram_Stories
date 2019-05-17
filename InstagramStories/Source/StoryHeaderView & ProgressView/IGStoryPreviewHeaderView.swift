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
            self.rightAnchor.constraint(equalTo: pv.rightAnchor),
            pv.heightAnchor.constraint(equalToConstant: 10)
            ])
        
        //Setting constraints for snapperImageView
        NSLayoutConstraint.activate([
            snaperImageView.widthAnchor.constraint(equalToConstant: 40),
            snaperImageView.heightAnchor.constraint(equalToConstant: 40),
            snaperImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            snaperImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            detailView.leftAnchor.constraint(equalTo: snaperImageView.rightAnchor, constant: 10)
            ])
        layoutIfNeeded() //To make snaperImageView round. Adding this to somewhere else will create constraint warnings.
        
        //Setting constraints for detailView
        NSLayoutConstraint.activate([
            detailView.leftAnchor.constraint(equalTo: snaperImageView.rightAnchor, constant: 10),
            detailView.centerYAnchor.constraint(equalTo: snaperImageView.centerYAnchor),
            detailView.heightAnchor.constraint(equalToConstant: 40),
            closeButton.leftAnchor.constraint(equalTo: detailView.rightAnchor, constant: 10)
            ])
        
        //Setting constraints for closeButton
        NSLayoutConstraint.activate([
            closeButton.leftAnchor.constraint(equalTo: detailView.rightAnchor, constant: 10),
            closeButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            closeButton.rightAnchor.constraint(equalTo: self.rightAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 60),
            closeButton.heightAnchor.constraint(equalToConstant: 80)
            ])
        
        //Setting constraints for snapperNameLabel
        NSLayoutConstraint.activate([
            snaperNameLabel.leftAnchor.constraint(equalTo: detailView.leftAnchor),
            lastUpdatedLabel.leftAnchor.constraint(equalTo: snaperNameLabel.rightAnchor, constant: 10.0),
            snaperNameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
            snaperNameLabel.centerYAnchor.constraint(equalTo: detailView.centerYAnchor)
            ])
        
        //Setting constraints for lastUpdatedLabel
        NSLayoutConstraint.activate([
            lastUpdatedLabel.centerYAnchor.constraint(equalTo: detailView.centerYAnchor),
            lastUpdatedLabel.leftAnchor.constraint(equalTo: snaperNameLabel.rightAnchor, constant:10.0)
            ])
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
        let padding: CGFloat = 8 //GUI-Padding
        let height: CGFloat = 3
        var pvIndicatorArray: [UIView] = []
        var pvArray: [IGSnapProgressView] = []

        for i in 0..<snapsPerStory{
            //let pvIndicator = UIView.init(frame: CGRect(x: x, y: y, width: width, height: height))
            let pvIndicator = UIView()
            pvIndicator.translatesAutoresizingMaskIntoConstraints = false
            getProgressView.addSubview(applyProperties(pvIndicator, with: i+progressIndicatorViewTag, alpha:0.2))
            pvIndicatorArray.append(pvIndicator)
            
            //let pv = IGSnapProgressView.init(frame: CGRect(x: x, y: y, width: 0, height: height))
            let pv = IGSnapProgressView()
            pv.translatesAutoresizingMaskIntoConstraints = false
            getProgressView.addSubview(applyProperties(pv, with: i+progressViewTag))
            pvArray.append(pv)
        }
        for index in 0..<pvIndicatorArray.count {
            let pvIndicator = pvIndicatorArray[index]
            if index == 0 {
                NSLayoutConstraint.activate([
                    pvIndicator.leadingAnchor.constraint(equalTo: self.getProgressView.leadingAnchor, constant: padding),
                    pvIndicator.centerYAnchor.constraint(equalTo: self.getProgressView.centerYAnchor),
                    pvIndicator.heightAnchor.constraint(equalToConstant: height)
                    ])
            }else {
                let prePVIndicator = pvIndicatorArray[index-1]
                NSLayoutConstraint.activate([
                    pvIndicator.leadingAnchor.constraint(equalTo: prePVIndicator.trailingAnchor, constant: padding),
                    pvIndicator.centerYAnchor.constraint(equalTo: prePVIndicator.centerYAnchor),
                    pvIndicator.heightAnchor.constraint(equalToConstant: height),
                    pvIndicator.widthAnchor.constraint(equalTo: prePVIndicator.widthAnchor, multiplier: 1.0)
                    ])
                if index == pvIndicatorArray.count-1 {
                    self.trailingAnchor.constraint(equalTo: pvIndicator.trailingAnchor, constant: padding).isActive = true
                }
            }
        }
        for index in 0..<pvArray.count {
            let pv = pvArray[index]
            if index == 0 {
                NSLayoutConstraint.activate([
                    pv.leadingAnchor.constraint(equalTo: self.getProgressView.leadingAnchor, constant: padding),
                    pv.centerYAnchor.constraint(equalTo: self.getProgressView.centerYAnchor),
                    pv.heightAnchor.constraint(equalToConstant: height),
                    pv.widthAnchor.constraint(equalToConstant: 0)
                    ])
            }else {
                let prePV = pvArray[index-1]
                let prePVIndicator = pvIndicatorArray[index-1]
                NSLayoutConstraint.activate([
                    pv.leadingAnchor.constraint(equalTo: prePVIndicator.trailingAnchor, constant: padding),
                    pv.centerYAnchor.constraint(equalTo: prePV.centerYAnchor),
                    pv.heightAnchor.constraint(equalToConstant: height),
                    pv.widthAnchor.constraint(equalToConstant: 0)
                    ])
                if index == pvArray.count-1 {
                    self.trailingAnchor.constraint(greaterThanOrEqualTo: pv.trailingAnchor, constant: padding).isActive = true
                }
            }
        }
        snaperNameLabel.text = story?.user.name
    }
}

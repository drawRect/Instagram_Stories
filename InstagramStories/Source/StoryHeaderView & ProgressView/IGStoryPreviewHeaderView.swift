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
        let padding:CGFloat = 8 //GUI-Padding
        let height:CGFloat = 3
//        var x:CGFloat = padding
//        let y:CGFloat = (self.getProgressView.frame.height/2)-height
//        let width = (IGScreen.width - ((snapsPerStory+1).toFloat * padding))/snapsPerStory.toFloat
        var constraintToDeactivateNextTime: [NSLayoutConstraint] = [NSLayoutConstraint]()
        for i in 0..<snapsPerStory{
            //let pvIndicator = UIView.init(frame: CGRect(x: x, y: y, width: width, height: height))
            let pvIndicator = UIView()
            pvIndicator.translatesAutoresizingMaskIntoConstraints = false
            getProgressView.addSubview(applyProperties(pvIndicator, with: i+progressIndicatorViewTag, alpha:0.2))
            let pvIndicatorLeftSecondItem = (i == 0)
                ? self.leftAnchor
                : self.getProgressView.subviews.filter({$0.tag == i-1+progressIndicatorViewTag}).last!.rightAnchor
            
            // Deactivate old constraints
            if !constraintToDeactivateNextTime.isEmpty {
                NSLayoutConstraint.deactivate(constraintToDeactivateNextTime)
                constraintToDeactivateNextTime.removeAll()
            }
            
            //Setting constraints for PVIndicator
            let pvILeftAnchor = pvIndicator.leftAnchor.constraint(equalTo: pvIndicatorLeftSecondItem, constant: padding)
            let pvICenterYAnchor = pvIndicator.centerYAnchor.constraint(equalTo: self.getProgressView.centerYAnchor)
            let pvIRightAnchor = self.rightAnchor.constraint(equalTo: pvIndicator.rightAnchor, constant: padding)
            pvIRightAnchor.priority = UILayoutPriority(rawValue: Float(900+i))
            let pvIHeightAnchor = pvIndicator.heightAnchor.constraint(equalToConstant: height)
            constraintToDeactivateNextTime.append(pvIRightAnchor)
            /*if i > 0 {
                let firstPVIndicator = self.getProgressView.subviews.filter({$0.tag == i-1+progressIndicatorViewTag}).first!
                NSLayoutConstraint.activate([
                    firstPVIndicator.widthAnchor.constraint(equalTo: pvIndicator.widthAnchor, multiplier: 1.0)
                    ])
            }*/
            NSLayoutConstraint.activate([pvILeftAnchor, pvICenterYAnchor, pvIRightAnchor, pvIHeightAnchor])
            
            //let pv = IGSnapProgressView.init(frame: CGRect(x: x, y: y, width: 0, height: height))
            let pv = IGSnapProgressView()
            pv.translatesAutoresizingMaskIntoConstraints = false
            getProgressView.addSubview(applyProperties(pv, with: i+progressViewTag))
            
            let pvLeftSecondItem = (i == 0)
                ? self.leftAnchor
                : self.getProgressView.subviews.filter({$0.tag == i-1+progressViewTag}).last!.rightAnchor
            
            //Setting constraints for PV
            let pvLeftAnchor = pv.leftAnchor.constraint(equalTo: pvLeftSecondItem, constant: padding)
            let pvCenterYAnchor = pv.centerYAnchor.constraint(equalTo: self.getProgressView.centerYAnchor)
            let pvRightAnchor = self.rightAnchor.constraint(equalTo: pv.rightAnchor, constant: padding)
            pvRightAnchor.priority = UILayoutPriority(rawValue: Float(900+i))
            let pvWidthAnchor = pv.widthAnchor.constraint(equalToConstant: 0)
            let pvHeightAnchor = pv.heightAnchor.constraint(equalToConstant: height)
            constraintToDeactivateNextTime.append(pvRightAnchor)
            /*if i > 0 {
                let firstPV = self.getProgressView.subviews.filter({$0.tag == i-1+progressIndicatorViewTag}).first!
                NSLayoutConstraint.activate([
                    firstPV.widthAnchor.constraint(equalTo: pv.widthAnchor, multiplier: 1.0)
                    ])
            }*/
            NSLayoutConstraint.activate([pvLeftAnchor, pvCenterYAnchor, pvRightAnchor, pvWidthAnchor, pvHeightAnchor])
            //x = x + width + padding
        }
        snaperNameLabel.text = story?.user.name
    }
}

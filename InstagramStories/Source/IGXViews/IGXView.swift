//
//  IGXView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 19/02/20.
//  Copyright © 2020 DrawRect. All rights reserved.
//

import UIKit

// Still finding the usage of these?
// Loader from ImageView+Extension and IGPlayerView move it here
protocol IGXMisc: class {
    func showLoader(color: UIColor)
    func hideLoader(color: UIColor)
}

extension IGXMisc where Self: IGXView {
    func showLoader(color: UIColor = .black) {
        backgroundColor = color
    }
    func hideLoader(color: UIColor = .clear) {
        backgroundColor = color
    }
}

/**
 This class can act as Person class
 ScrollView children should have Parent class of IGXView
 but the instance is based on the MIME Type whether it is a IGImageView or IGPlayerView
 */
class IGXView: UIView, IGXMisc {
    enum ContentState {
        case isLoading, isLoaded, isFailed
    }
    typealias ContentHandler = (_ success: Bool) -> Void
    // MARK: iVars
    var contentLoaded: ContentHandler?
    lazy var retryBtn: UIButton = {
        /// Todo: Use LayoutConstraints
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        btn.backgroundColor = .white
        btn.setImage(#imageLiteral(resourceName: "ic_retry"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isUserInteractionEnabled = true
        btn.addTarget(self, action: #selector(loadContent), for: .touchUpInside)
        return btn
    }()
    let snap: IGSnap
    var contentState: ContentState = .isLoading {
        didSet {
            switch contentState {
            case .isLoading:
                showLoader()
            case .isLoaded:
                hideLoader()
                //Implement remove retryButton code
                if contentLoaded != nil {
                    contentLoaded!(true)
                }
            case .isFailed:
                    hideLoader(color: UIColor.black.withAlphaComponent(0.2))//dimmed
                    addSubview(retryBtn)
                    NSLayoutConstraint.activate([
                        self.retryBtn.igCenterXAnchor.constraint(equalTo: self.igCenterXAnchor),
                        self.retryBtn.igCenterYAnchor.constraint(equalTo: self.igCenterYAnchor)
                    ])
            }
        }
    }
    // MARK: Init methods
    init(frame: CGRect, snap: IGSnap) {
        self.snap = snap
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: Internal methods
    @objc func loadContent() {
        //start request this image using sdwebimage using snap.url
        //start request this video using avplayer with contents of url
    }
}

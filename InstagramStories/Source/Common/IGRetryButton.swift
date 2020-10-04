//
//  IGRetryButton.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 15/07/18.
//  Copyright © 2018 DrawRect. All rights reserved.
//

import Foundation
import UIKit

protocol RetryBtnDelegate: class {
    func retryButtonTapped()
}

public class IGRetryLoaderButton: UIButton {
    var contentURL: String?
    weak var delegate: RetryBtnDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        self.setImage(#imageLiteral(resourceName: "ic_retry"), for: .normal)
        self.addTarget(self, action: #selector(didTapRetryBtn), for: .touchUpInside)
        self.tag = 100
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapRetryBtn() {
        delegate?.retryButtonTapped()
    }
}

#warning("why did we write one special function on UIView Extension to remove retry button, instead can you move this function to extension to IGRetryButton class")
extension UIView {
    func removeRetryButton() {
        self.subviews.forEach({v in
            if(v.tag == 100){v.removeFromSuperview()}
        })
    }
}

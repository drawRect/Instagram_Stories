//
//  IGImageView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 19/02/20.
//  Copyright © 2020 DrawRect. All rights reserved.
//

import UIKit

class IGImageView: IGXView {
    //Add your Image related stuff here
    lazy var imageview: UIImageView = {
        let imageview = UIImageView(frame: self.bounds)
        return imageview
    }()
    override init(frame: CGRect, snap: IGSnap) {
        super.init(frame: frame, snap: snap)
        self.addSubview(imageview)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc override func loadContent() {
        //start request this image using sdwebimage using snap.url
        self.contentState = .isLoading
        imageview.setImage(url: snap.url, style: .squared) {[weak self] (result) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                    case .success(_):
                        strongSelf.contentState = .isLoaded
                    case .failure(_):
                        strongSelf.contentState = .isFailed
                }
            }
        }
    }
}


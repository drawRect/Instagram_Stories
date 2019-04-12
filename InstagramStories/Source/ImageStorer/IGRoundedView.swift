//
//  IGRoundedView.swift
//  IGRoundedView
//
//  Created by Ranjith Kumar on 12/5/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import Foundation
import UIKit

//RV=RoundedView
fileprivate struct RVAttributes {
   static let borderWidth:CGFloat = 2.0
   static let size = CGSize(width:68,height:68)
}

class IGRoundedView: UIView {
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.borderWidth = RVAttributes.borderWidth
        iv.layer.borderColor = UIColor.white.cgColor
        return iv
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = IGTheme.redOrange
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = RVAttributes.borderWidth
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height/2
        imageView.frame = CGRect(x:1,y:1,width:(RVAttributes.size.width)-2,height:RVAttributes.size.height-2)
        imageView.layer.cornerRadius = imageView.frame.height/2
    }
}

extension IGRoundedView {
    func enableBorder() {
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 0
    }
}

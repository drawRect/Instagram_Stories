//
//  IGRoundedView.swift
//  IGRoundedView
//
//  Created by Ranjith Kumar on 12/5/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import Foundation
import UIKit

//@note:Recommended Size: CGSize(width:70,height:70)
struct Attributes {
   static let borderWidth:CGFloat = 2.0
   static let borderColor = UIColor.white
   static let backgroundColor = IGTheme.redOrange
   static let size = CGSize(width:68,height:68)
}

class IGRoundedView: UIView {
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.borderWidth = Attributes.borderWidth
        iv.layer.borderColor = Attributes.borderColor.cgColor
        iv.clipsToBounds = true
        return iv
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = Attributes.backgroundColor
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height/2
        imageView.frame = CGRect(x:1,y:1,width:(Attributes.size.width)-2,height:Attributes.size.height-2)
        imageView.layer.cornerRadius = imageView.frame.height/2
    }
}

extension IGRoundedView {
    func enableBorder(_ enabled: Bool = true) {
        if enabled {
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
        }else {
            layer.borderColor = Attributes.borderColor.cgColor
            layer.borderWidth = Attributes.borderWidth
        }
    }
}

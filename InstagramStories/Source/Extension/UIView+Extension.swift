//
//  UIView+Extension.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 08/03/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import UIKit

extension UIView {
    private var _safeAreaLayoutGuide: UILayoutGuide? {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide
        }
        return nil
    }
}

extension UIView {
    
    var igLeftAnchor: NSLayoutXAxisAnchor {
        return _safeAreaLayoutGuide?.leftAnchor ?? leftAnchor
    }
    
    var igRightAnchor: NSLayoutXAxisAnchor {
        return _safeAreaLayoutGuide?.rightAnchor ?? rightAnchor
    }
    
    var igTopAnchor: NSLayoutYAxisAnchor {
        return _safeAreaLayoutGuide?.topAnchor ?? topAnchor
    }
    
    var igBottomAnchor: NSLayoutYAxisAnchor {
        return _safeAreaLayoutGuide?.bottomAnchor ?? bottomAnchor
    }
    
    var igCenterXAnchor: NSLayoutXAxisAnchor {
        return _safeAreaLayoutGuide?.centerXAnchor ?? centerXAnchor
    }
    
    var igCenterYAnchor: NSLayoutYAxisAnchor {
        return _safeAreaLayoutGuide?.centerYAnchor ?? centerYAnchor
    }
    
    var igWidth: CGFloat {
        return _safeAreaLayoutGuide?.layoutFrame.width ?? frame.width
    }
    
    var igHeight: CGFloat {
        return _safeAreaLayoutGuide?.layoutFrame.height ?? frame.height
    }
    
}

//
//  UIView+Extension.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 08/03/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import UIKit

extension UIView {
    private var safeAreaLG: UILayoutGuide? {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide
        }
        return nil
    }
}

extension UIView {
    var igLeftAnchor: NSLayoutXAxisAnchor {
        return safeAreaLG?.leftAnchor ?? leftAnchor
    }
    var igRightAnchor: NSLayoutXAxisAnchor {
        return safeAreaLG?.rightAnchor ?? rightAnchor
    }
    var igTopAnchor: NSLayoutYAxisAnchor {
        return safeAreaLG?.topAnchor ?? topAnchor
    }
    var igBottomAnchor: NSLayoutYAxisAnchor {
        return safeAreaLG?.bottomAnchor ?? bottomAnchor
    }
    var igCenterXAnchor: NSLayoutXAxisAnchor {
        return safeAreaLG?.centerXAnchor ?? centerXAnchor
    }
    var igCenterYAnchor: NSLayoutYAxisAnchor {
        return safeAreaLG?.centerYAnchor ?? centerYAnchor
    }
    var igWidth: CGFloat {
        return safeAreaLG?.layoutFrame.width ?? frame.width
    }
    var igHeight: CGFloat {
        return safeAreaLG?.layoutFrame.height ?? frame.height
    }
}

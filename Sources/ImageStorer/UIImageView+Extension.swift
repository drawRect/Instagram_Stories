//
//  UIImageView+Extension.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 02/04/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {

    //Responsiblity: to holds the List of Activity Indicator for ImageView
    //DataSource: UI-Level
    struct ActivityIndicator {
        static var isEnabled = false
        static var style = _style
        static var view = _view
        
        static var _style: UIActivityIndicatorView.Style {
            if #available(iOS 13.0, *) {
                return .large
            }else {
                return .whiteLarge
            }
        }
        
        static var _view: UIActivityIndicatorView {
            if #available(iOS 13.0, *) {
                return UIActivityIndicatorView(style: .large)
            }else {
                return UIActivityIndicatorView(style: .whiteLarge)
            }
        }
    }
    
    //MARK: Public Vars
    public var isActivityEnabled: Bool {
        get {
            guard let value = objc_getAssociatedObject(self, &ActivityIndicator.isEnabled) as? Bool else {
                return false
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &ActivityIndicator.isEnabled, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var activityStyle: UIActivityIndicatorView.Style {
        get{
            guard let value = objc_getAssociatedObject(self, &ActivityIndicator.style) as? UIActivityIndicatorView.Style else {
                if #available(iOS 13.0, *) {
                    return .large
                }else {
                    return .whiteLarge
                }
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &ActivityIndicator.style, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var activityIndicator: UIActivityIndicatorView {
        get {
            guard let value = objc_getAssociatedObject(self, &ActivityIndicator.view) as? UIActivityIndicatorView else {
                if #available(iOS 13.0, *) {
                    return UIActivityIndicatorView(style: .large)
                }else {
                    return UIActivityIndicatorView(style: .whiteLarge)
                }
            }
            return value
        }
        set(newValue) {
            let activityView = newValue
            activityView.hidesWhenStopped = true
            objc_setAssociatedObject(self, &ActivityIndicator.view, activityView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    //MARK: - Private methods
    func showActivityIndicator() {
        if isActivityEnabled {
            var isActivityIndicatorFound = false
            DispatchQueue.main.async {
                self.backgroundColor = .black
                self.activityIndicator = UIActivityIndicatorView(style: self.activityStyle)
                self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
                if self.subviews.isEmpty {
                    isActivityIndicatorFound = false
                    self.addSubview(self.activityIndicator)
                    
                } else {
                    for view in self.subviews {
                        if !view.isKind(of: UIActivityIndicatorView.self) {
                            isActivityIndicatorFound = false
                            self.addSubview(self.activityIndicator)
                            break
                        } else {
                            isActivityIndicatorFound = true
                        }
                    }
                }
                if !isActivityIndicatorFound {
                    NSLayoutConstraint.activate([
                        self.activityIndicator.igCenterXAnchor.constraint(equalTo: self.igCenterXAnchor),
                        self.activityIndicator.igCenterYAnchor.constraint(equalTo: self.igCenterYAnchor)
                        ])
                }
                self.activityIndicator.startAnimating()
            }
        }
    }
    
    func hideActivityIndicator() {
        if isActivityEnabled {
            DispatchQueue.main.async {
                self.backgroundColor = UIColor.white
                self.subviews.forEach({ (view) in
                    if let av = view as? UIActivityIndicatorView {
                        av.stopAnimating()
                    }
                })
            }
        }
    }
}

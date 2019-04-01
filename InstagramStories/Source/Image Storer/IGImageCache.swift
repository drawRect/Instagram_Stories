//
//  ImageCache.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 01/04/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import Foundation
import UIKit

fileprivate let imageCache = NSCache<AnyObject, AnyObject>()
fileprivate typealias ImageDownloaderBlock = (UIImage?, Error?) -> Void

class IGImageCache {
    static let shared = IGImageCache()
    private init(){}
    func clearCache() {
        imageCache.removeAllObjects()
    }
}

enum ImageError: String, Error {
    case invalidImageURL = "Invalid ImageURL"
}

private protocol ImageStorer {
    func ig_setImage(urlString: String, completionBlock: ((_ image: UIImage?, _ error: Error?) -> Void)?)
    func ig_setImage(urlString: String, placeHolderImage: UIImage?, completionBlock: ((_ image: UIImage?, _ error: Error?) -> Void)?)
}

extension UIImageView: ImageStorer {
    struct ActivityIndicator {
        static var value = [String: Bool]()
        static var style = [String: UIActivityIndicatorView.Style]()
        static var view = [String: UIActivityIndicatorView]()
    }
    //MARK: Vars
    public var showActivityIndicator: Bool {
        get {
            return ActivityIndicator.value[self.debugDescription] ?? false
        }
        set(newValue) {
            ActivityIndicator.value[self.debugDescription] = newValue
        }
    }
    public var activityIndicatorStyle: UIActivityIndicatorView.Style {
        get{
            return ActivityIndicator.style[self.debugDescription] ?? .whiteLarge
        }
        set(newValue) {
            ActivityIndicator.style[self.debugDescription] = newValue
        }
    }
    public var activityIndicator: UIActivityIndicatorView {
        get {
            return ActivityIndicator.view[self.debugDescription] ?? UIActivityIndicatorView(style: self.activityIndicatorStyle)
        }
        set(newValue) {
            if ActivityIndicator.view[self.debugDescription] == nil {
                let activityView = newValue
                activityView.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
                activityView.hidesWhenStopped = true
                ActivityIndicator.view[self.debugDescription] = activityView
                self.addSubview(activityView)
                self.bringSubviewToFront(activityView)
                if self.backgroundColor == .white && activityView.tintColor == .white {
                    self.backgroundColor = .black
                }
                DispatchQueue.main.async {
                    activityView.startAnimating()
                }
            }else {
                let activityView = ActivityIndicator.view[self.debugDescription]
                self.bringSubviewToFront(activityView!)
                DispatchQueue.main.async {
                    activityView?.startAnimating()
                }
            }
        }
    }
    
    //MARK: - Private methods
    private func presentActivityIndicator() {
        if showActivityIndicator {
            activityIndicator = UIActivityIndicatorView(style: activityIndicatorStyle)
        }
    }
    private func dismissActivityIndicator() {
        if showActivityIndicator {
            DispatchQueue.main.async {
                let view = self.subviews.filter({($0 as? UIActivityIndicatorView) != nil}).first
                if let activityView = view as? UIActivityIndicatorView {
                    activityView.stopAnimating()
                }
            }
        }
    }
    private func downloadImage(urlString: String, completionBlock: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            dismissActivityIndicator()
            return completionBlock(nil, ImageError.invalidImageURL)
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let result = data, let imageToCache = UIImage(data: result) {
                imageCache.setObject(imageToCache, forKey: url.absoluteString as AnyObject)
                return completionBlock(imageToCache, nil)
            } else {
                return completionBlock(nil, error)
            }
            }.resume()
    }
    
    //MARK: - Public Methods
    public func ig_setImage(urlString: String, completionBlock: ((UIImage?, Error?) -> Void)?) {
        self.ig_setImage(urlString: urlString, placeHolderImage: nil, completionBlock: completionBlock)
    }
    
    public func ig_setImage(urlString: String, placeHolderImage: UIImage?, completionBlock: ((UIImage?, Error?) -> Void)?) {
        
        self.image = (placeHolderImage != nil) ? placeHolderImage! : nil
        presentActivityIndicator()
        
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.dismissActivityIndicator()
            DispatchQueue.main.async {
                self.image = cachedImage
            }
            if completionBlock != nil {
                return completionBlock!(self.image, nil)
            }
            return
        }else {
            downloadImage(urlString: urlString) {(image, error) in
                self.dismissActivityIndicator()
                DispatchQueue.main.async {
                    self.image = image
                }
                if completionBlock != nil {
                    return completionBlock!(image, error)
                }
                return
            }
        }
    }
}

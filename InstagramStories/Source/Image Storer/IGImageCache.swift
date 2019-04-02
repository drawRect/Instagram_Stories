//
//  ImageCache.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 01/04/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import Foundation
import UIKit

let ONE_HUNDRED_MEGABYTES = 1024 * 1024 * 100

class IGCache: NSCache <AnyObject,AnyObject> {
    static let shared = IGCache()
}

public typealias ImageRespone = (Result<UIImage, Error>) -> Void

public enum Result<V, E> {
    case success(V)
    case failure(E)
}
public enum ImageError: String, Error {
    case invalidImageURL = "Invalid Image URL"
}

private protocol ImageCache {
    func ig_setImage(urlString: String, completionBlock: ImageRespone?)
    func ig_setImage(urlString: String, placeHolderImage: UIImage?, completionBlock: ImageRespone?)
}

extension UIImageView: ImageCache {
    //MARK: - Public Methods
    public func ig_setImage(urlString: String, completionBlock: ImageRespone?) {
        self.ig_setImage(urlString: urlString, placeHolderImage: nil, completionBlock: completionBlock)
    }
    
    public func ig_setImage(urlString: String, placeHolderImage: UIImage?, completionBlock: ImageRespone?) {
        
        self.image = (placeHolderImage != nil) ? placeHolderImage! : nil
        self.showActivityIndicator()
        
        if let cachedImage = IGCache.shared.object(forKey: urlString as AnyObject) as? UIImage {
            self.hideActivityIndicator()
            DispatchQueue.main.async {
                self.image = cachedImage
            }
            guard let completion = completionBlock else { return }
            return completion(.success(cachedImage))
        }else {
            downloadImage(urlString: urlString) { [unowned self] (response) in
                self.hideActivityIndicator()
                switch response {
                case .success(let image):
                    DispatchQueue.main.async {
                        self.image = image
                    }
                    guard let completion = completionBlock else { return }
                    return completion(.success(image))
                case .failure(let error):
                    guard let completion = completionBlock else { return }
                    return completion(.failure(error))
                }
            }
        }
    }
}

extension UIImageView {
    struct ActivityIndicator {
        static var isEnabled: Bool = false
        static var style: UIActivityIndicatorView.Style = .whiteLarge
        static var view: UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    }
    //MARK: Vars
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
                return .whiteLarge
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
                return UIActivityIndicatorView(style: .whiteLarge)
            }
            return value
        }
        set(newValue) {
            let activityView = newValue
            activityView.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
            activityView.hidesWhenStopped = true
            objc_setAssociatedObject(self, &ActivityIndicator.view, activityView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    //MARK: - Private methods
    private func showActivityIndicator() {
        if isActivityEnabled {
            DispatchQueue.main.async {
                self.activityIndicator = UIActivityIndicatorView(style: self.activityStyle)
                if self.backgroundColor == .white || self.activityStyle == .white {
                    self.backgroundColor = .black
                }
                if !self.subviews.contains(self.activityIndicator) {
                    self.addSubview(self.activityIndicator)
                }
                self.activityIndicator.startAnimating()
            }
        }
    }
    private func hideActivityIndicator() {
        if isActivityEnabled {
            DispatchQueue.main.async {
                self.subviews.forEach({ (view) in
                    if let av = view as? UIActivityIndicatorView {
                        av.stopAnimating()
                    }
                })
            }
        }
    }
    private func downloadImage(urlString: String, completionBlock: @escaping ImageRespone) {
        guard let url = URL(string: urlString) else {
            hideActivityIndicator()
            return completionBlock(.failure(ImageError.invalidImageURL))
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let result = data, error == nil, let imageToCache = UIImage(data: result) {
                IGCache.shared.setObject(imageToCache, forKey: url.absoluteString as AnyObject)
                return completionBlock(.success(imageToCache))
            } else {
                return completionBlock(.failure(error!))
            }
            }.resume()
    }
}

//
//  IGImageRequestable.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 02/04/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import Foundation
import UIKit

public typealias ImageRequestHandler = (Result<Data, Error>) -> Void

protocol IGImageRequestable {
    func requestImage(
        urlString: String,
        placeHolderImage: UIImage?,
        completionBlock: ImageRequestHandler?)
}

extension IGImageRequestable where Self: UIImageView {
    func requestImage(urlString: String, placeHolderImage: UIImage? = nil, completionBlock: ImageRequestHandler?) {

        self.image = (placeHolderImage != nil) ? placeHolderImage! : nil
        self.showActivityIndicator()

        if let cachedImageRaw = IGCache.default.object(forKey: urlString as AnyObject) as? Data {
            self.hideActivityIndicator()
            guard let completion = completionBlock else { return }
            return completion(.success(cachedImageRaw))
        } else {
            IGURLSession.default.downloadImage(fromUrl: urlString) { [weak self] (response) in
                guard let strongSelf = self else { return }
                strongSelf.hideActivityIndicator()
                switch response {
                case .success(let imageRaw):
                    guard let completion = completionBlock else { return }
                    return completion(.success(imageRaw))
                case .failure(let error):
                    guard let completion = completionBlock else { return }
                    return completion(.failure(error))
                }
            }
        }
    }
}

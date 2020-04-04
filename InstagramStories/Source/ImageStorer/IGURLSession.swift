//
//  IGURLSession.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 02/04/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import Foundation
import UIKit

class IGURLSession: URLSession {
    static let `default` = IGURLSession()
    private(set) var dataTasks: [URLSessionDataTask] = []
}
extension IGURLSession {
    func cancelAllPendingTasks() {
        dataTasks.forEach({
            if $0.state != .completed {
                $0.cancel()
            }
        })
    }
    func downloadImage(fromUrl: String, completionBlock: @escaping ImageRequestHandler) {
        guard let url = URL(string: fromUrl) else {
            return completionBlock(.failure(IGImageLoadError.invalidImageURL))
        }
        dataTasks.append(IGURLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
            if let result = data, error == nil {
                completionBlock(.success(result))
            } else {
                completionBlock(.failure(error ?? IGImageLoadError.downloadError))
            }
        }))
        dataTasks.last?.resume()
    }
}

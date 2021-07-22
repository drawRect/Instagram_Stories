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

    func downloadImage(using urlString: String, andHeaders headers: [String: String], completionBlock: @escaping ImageResponse) {
        guard let url = URL(string: urlString) else {
            return completionBlock(.failure(IGError.invalidImageURL))
        }

        var request = URLRequest(url: url)
        headers.forEach { (key, value) in
            request.addValue(key, forHTTPHeaderField: value)
        }
        dataTasks.append(IGURLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let result = data, error == nil, let imageToCache = UIImage(data: result) {
                IGCache.shared.setObject(imageToCache, forKey: url.absoluteString as AnyObject)
                completionBlock(.success(imageToCache))
            } else {
                return completionBlock(.failure(error ?? IGError.downloadError))
            }
        }))
        dataTasks.last?.resume()
    }
}

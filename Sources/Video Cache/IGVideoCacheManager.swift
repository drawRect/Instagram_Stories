//
//  IGVideoCacheManager.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 26/07/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import Foundation

class IGVideoCacheManager {
    
    enum VideoError: Error, CustomStringConvertible {
        case downloadError
        case fileRetrieveError
        var description: String {
            switch self {
            case .downloadError:
                return "Can't download video"
            case .fileRetrieveError:
                return "File not found"
            }
        }
    }
    
    static let shared = IGVideoCacheManager()
    private init(){}
    typealias Response = Result<URL, Error>
    
    private let fileManager = FileManager.default
    private lazy var mainDirectoryUrl: URL? = {
        let documentsUrl = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        return documentsUrl
    }()
    
    func getFile(for stringUrl: String, completionHandler: @escaping (Response) -> Void) {
        
        guard let file = directoryFor(stringUrl: stringUrl) else {
            completionHandler(Result.failure(VideoError.fileRetrieveError))
            return
        }
        
        //return file path if already exists in cache directory
        guard !fileManager.fileExists(atPath: file.path) else {
            completionHandler(Result.success(file))
            return
        }
        
        DispatchQueue.global().async {
            if let videoData = NSData(contentsOf: URL(string: stringUrl)!) {
                videoData.write(to: file, atomically: true)
                
                DispatchQueue.main.async {
                    completionHandler(Result.success(file))
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(Result.failure(VideoError.downloadError))
                }
            }
        }
    }
    func clearCache(for urlString: String? = nil) {
        guard let cacheURL =  mainDirectoryUrl else { return }
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory( at: cacheURL, includingPropertiesForKeys: nil, options: [])
            if let string = urlString, let url = URL(string: string) {
                do {
                    try fileManager.removeItem(at: url)
                }
                catch let error as NSError {
                    debugPrint("Unable to remove the item: \(error)")
                }
            }else {
                for file in directoryContents {
                    do {
                        try fileManager.removeItem(at: file)
                    }
                    catch let error as NSError {
                        debugPrint("Unable to remove the item: \(error)")
                    }
                }
            }
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
        }
    }
    private func directoryFor(stringUrl: String) -> URL? {
        guard let fileURL = URL(string: stringUrl)?.lastPathComponent, let mainDirURL = self.mainDirectoryUrl else { return nil }
        let file = mainDirURL.appendingPathComponent(fileURL)
        return file
    }
}


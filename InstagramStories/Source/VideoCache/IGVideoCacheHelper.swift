//
//  IGVideoCacheManager.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 26/07/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import Foundation

/// This class helps to handle the snap video in locally.
/// like download the video from snap.url and drop it in cache directory and also retrives ondemand
final public class IGVideoCacheHelper {
    /// This `default` constant can holds the single instance of which ever class confirms
    static let `default` = IGVideoCacheHelper()
    private init() {}
    private lazy var cacheDirectoryURL: URL = {
        guard let dirURL = FileManager.default.urls(
            for: .cachesDirectory, in: .userDomainMask
        ).first else { fatalError("no cache directory") }
        return dirURL
    }()
    /**
     Call this function to get full path component from cache directory.
     - Parameters:
        - from: snap video url
        - returns: video url full path component
     */
    private func getDirPath(from: String) -> URL {
        if let fileURL = URL(string: from)?.lastPathComponent {
            return self.cacheDirectoryURL.appendingPathComponent(fileURL)
        } else {
            fatalError("no last path compoent at:\(from)")
        }
    }
}

extension IGVideoCacheHelper: VideoCacheTasks {
    public func writeVideo(fromUrl: String, handler: @escaping(VideoWriteHandler) -> Void) {
        do {
            if Thread.current == Thread.main {
                //Running on Main Thread
                //Then // Todo: DispatchQueue.global().async {
            } else {
                //Secondary Thread
            }
            guard let url = URL(string: fromUrl) else {
                return handler(.failure(IGVideoLoadError.downloadError))
            }
            let videoData = try Data(contentsOf: url)
            try videoData.write(to: getDirPath(from: fromUrl))
            handler(.success(true))
        } catch let error {
            handler(.failure(IGVideoLoadError.writeError(error.localizedDescription)))
        }
    }
    public func readVideo(fromUrl: String) -> URL? {
        let filePath = getDirPath(from: fromUrl)
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            return nil
        }
        return filePath
    }
    public func removeVideo(fromUrl: String, handler: @escaping(VideoRemoveHandler) -> Void) {
        do {
            guard let url = URL(string: fromUrl) else {
                return handler(.failure(IGVideoLoadError.error("Unable to convert URL:\(fromUrl)")))
            }
            try FileManager.default.removeItem(at: url)
            handler(.success(true))
        } catch let error {
            handler(.failure(IGVideoLoadError.error("Unable to remove the item:" + error.localizedDescription)))
        }
    }
    public func clearAll(handler: @escaping(VideoRemoveHandler) -> Void) {
        do {
            let fileNames = try FileManager.default.contentsOfDirectory(at: cacheDirectoryURL, includingPropertiesForKeys: [])
            try FileManager.default.contentsOfDirectory(
                at: cacheDirectoryURL,
                includingPropertiesForKeys: nil,
                options: []
            ).forEach({
                try FileManager.default.removeItem(at: $0)
            })
            handler(.success(true))
        } catch let error {
            handler(.failure(IGVideoLoadError.error("Unable to remove the item:" + error.localizedDescription)))
        }
    }
}

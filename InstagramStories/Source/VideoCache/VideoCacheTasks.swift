//
//  VideoCacheTasks.swift
//  InstagramStories
//
//  Created by Kumar, Ranjith B. (623-Extern) on 21/03/20.
//  Copyright © 2020 DrawRect. All rights reserved.
//

import Foundation

public typealias VideoReadHandler = Result<URL, Error>
public typealias VideoWriteHandler = Result<Bool, Error>
public typealias VideoRemoveHandler = Result<Bool, Error>

public protocol VideoCacheTasks: class {
    /**
     Call this function to get the Video from Cache Directory using Optional URL,
     if there is no URL means No video available on the directory
     - Parameters:
        - fromUrl: Video URL
        - Returns: optional URL file path url
     */
    func readVideo(fromUrl: String) -> URL?
    /**
    Call this function to write a video which we load it from snap.url into cached directory
    - Parameters:
        - fromUrl: Video URL
        - handler: Handler which returns write sucess or error
        - return: Void
    */
    func writeVideo(fromUrl: String, handler: @escaping(VideoWriteHandler) -> Void)
    /**
    Call this function to remove respective video from cache directory using video url
    - Parameters:
        - fromUrl: Video URL
        - handler: Handler which returns remove sucess or error
    */
    func removeVideo(fromUrl: String, handler: @escaping(VideoRemoveHandler) -> Void)
    /**
    Call this function to remove all videos which are stored in the cache directory
    - Parameters:
        - handler: Handler which returns remove all sucess or error
    */
    func clearAll(handler: @escaping(VideoRemoveHandler) -> Void)
}

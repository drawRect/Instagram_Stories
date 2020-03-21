//
//  IGVideoLoadError.swift
//  InstagramStories
//
//  Created by Kumar, Ranjith B. (623-Extern) on 21/03/20.
//  Copyright © 2020 DrawRect. All rights reserved.
//

/**
 This is an enumeration of the type of video error when we load it from 'cache dir' or 'remote'
 */
internal enum IGVideoLoadError: Error, CustomStringConvertible {
    /// It throws when we tries to download video using snap url and it fails
    case downloadError
    /// It throws when we tries to read it from cache directory snap url and it fails
    case retrieveError
    /// It throws when we tries to compute the file path component using snap url
    case pathError
    /// It throws when we tries to write it to the cache directory
    case writeError(_ desc: String)
    /// It throws when we face common errors with additional message
    case error(_ desc: String)
    var description: String {
        switch self {
        case .downloadError: return "Cannot download video"
        case .retrieveError: return "Video not found"
        case .pathError: return "Video path error"
        case .writeError: return "Video write error"
        case .error: return "Video Error"
        }
    }
}

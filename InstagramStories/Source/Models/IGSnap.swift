//
//  IGSnap.swift
//
//  Created by Ranjith Kumar on 9/28/17
//  Copyright (c) DrawRect. All rights reserved.
//

import Foundation

public enum MimeType: String {
    case image
    case video
    case unknown
}
public class IGSnap: Codable {
    public let internalIdentifier: String
    public let mimeType: String
    public let lastUpdated: String
    public let url: String
    public var kind: MimeType {
        switch mimeType {
        case MimeType.image.rawValue:
            return MimeType.image
        case MimeType.video.rawValue:
            return MimeType.video
        default:
            return MimeType.unknown
        }
    }
    enum CodingKeys: String, CodingKey {
        case internalIdentifier = "id"
        case mimeType = "mime_type"
        case lastUpdated = "last_updated"
        case url = "url"
    }
}

extension IGSnap {
    var ableToPlay: Bool {
        return universeResourceLocator != nil
    }
    //Throws -> can catch invalid url, Assets not found and something else
    var universeResourceLocator: URL? {
        return URL(string: url)
    }
}

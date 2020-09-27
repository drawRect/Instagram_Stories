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
    public let id: String
    public let mimeType: String
    public let lastUpdated: String
    public let url: String
    // Store the deleted snaps id in NSUserDefaults, so that when app get relaunch deleted snaps will not display.
    public var isDeleted: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: id)
        }
        get{
            return UserDefaults.standard.value(forKey: id) != nil
        }
    }
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
        case id = "id"
        case mimeType = "mime_type"
        case lastUpdated = "last_updated"
        case url = "url"
    }
}

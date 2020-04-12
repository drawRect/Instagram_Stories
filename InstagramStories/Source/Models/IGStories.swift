//
//  IGStories.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/8/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import Foundation

public class IGStories: Codable {
    //TODO: count should be computed property. Because if there is only one snap in story and that snap user deleted means, that story shouldn't be visible.
    public let otherStoriesCount: Int
    public let otherStories: [IGStory]
    public let myStory: [IGStory]
    
    enum CodingKeys: String, CodingKey {
        case otherStoriesCount = "other_stories_count"
        case otherStories = "other_stories"
        case myStory = "my_story"
    }
    func copy() throws -> IGStories {
        let data = try JSONEncoder().encode(self)
        let copy = try JSONDecoder().decode(IGStories.self, from: data)
        return copy
    }
}

extension IGStories {
    func removeCachedFile(for urlString: String) {
        IGVideoCacheManager.shared.getFile(for: urlString) { (result) in
            switch result {
            case .success(let url):
                IGVideoCacheManager.shared.clearCache(for: url.absoluteString)
            case .failure(let error):
                debugPrint("File read error: \(error)")
            }
        }
    }
    static func removeAllVideoFilesFromCache() {
        IGVideoCacheManager.shared.clearCache()
    }
}

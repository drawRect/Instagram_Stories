//
//  IGMockLoader.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 10/23/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import Foundation

enum MockLoaderError: Error, CustomStringConvertible {
    case invalidFileName(String)
    case invalidFileURL(URL)
    case invalidJSON(String)
    var description: String {
        switch self {
        case .invalidFileName(let name): return "\(name) FileName is incorrect"
        case .invalidFileURL(let url): return "\(url) FilePath is incorrect"
        case .invalidJSON(let name): return "\(name) has Invalid JSON"
        }
    }
}

struct IGMockLoader {
    //@Note:XCTestCase will go for differnt set of bundle
    static func loadMockFile(named fileName:String,bundle:Bundle = .main) throws -> IGStories {
        guard let url = bundle.url(forResource: fileName, withExtension: nil) else {throw MockLoaderError.invalidFileName(fileName)}
        do {
            let data = try Data.init(contentsOf: url)
            if let _ = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [String:Any] {
                let stories = try JSONDecoder().decode(IGStories.self, from: data)
                return stories
            }else {
                throw MockLoaderError.invalidFileURL(url)
            }
        }catch {
            throw MockLoaderError.invalidJSON(fileName)
        }
    }
    static func loadAPIResponse(response: [String: Any]) throws -> IGStories {
        let data = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
        do {
            let stories = try JSONDecoder().decode(IGStories.self, from: data)
            return stories
        } catch {
            throw MockLoaderError.invalidJSON("Input Response")
        }
    }
}

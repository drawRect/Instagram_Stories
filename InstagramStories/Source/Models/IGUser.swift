//
//  IGUser.swift
//
//  Created by Ranjith Kumar on 9/8/17
//  Copyright (c) DrawRect. All rights reserved.
//

import Foundation

public class IGUser: Codable {
    public let id: String
    public let name: String
    public let picture: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case picture = "picture"
    }
}

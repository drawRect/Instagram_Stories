//
//  IGCache.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 01/04/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import Foundation

private let oneHundredMegaBytes = 1024 * 1024 * 100

class IGCache: NSCache<AnyObject, AnyObject> {
    static let `default` = IGCache()
    private override init() {
        super.init()
        self.setMaximumLimit()
    }
}

extension IGCache {
    func setMaximumLimit(size: Int = oneHundredMegaBytes) {
        totalCostLimit = size
    }
}

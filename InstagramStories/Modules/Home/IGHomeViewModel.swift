//
//  IGHomeViewModel.swift
//  InstagramStories
//
//  Created by  Boominadha Prakash on 01/11/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import Foundation

struct IGHomeViewModel {
    
    var stories: IGStories?
    
    init() {
        do {
            stories = try IGMockLoader.loadMockFile(named: IGAssets.storiesJSON, bundle: .main)
        }catch let e as MockLoaderError {
            debugPrint(e.description)
        }catch {
            debugPrint("could not read Mock json file :(")
        }
    }
    
}

extension IGHomeViewModel {
    
    func numberOfItemsInSection(_ section:Int) -> Int {
        if let count = stories?.count {
            return count + 1 // Add Story cell
        }
        return 1
    }
    
    func cellForItemAt(indexPath:IndexPath) -> IGStory? {
        return stories?.stories[indexPath.row-1]
    }
    
}

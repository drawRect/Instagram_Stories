//
//  IGHomeController.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

final class IGHomeController: UIViewController {
    
    @IBOutlet weak private var storiesCollectionView: UICollectionView! {
        didSet {
            storiesCollectionView.delegate = self
            storiesCollectionView.dataSource = self
            storiesCollectionView.register(IGStoryListCell.nib(), forCellWithReuseIdentifier: IGStoryListCell.reuseIdentifier())
            storiesCollectionView.register(IGAddStoryCell.nib(), forCellWithReuseIdentifier: IGAddStoryCell.reuseIdentifier())
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    //Keep it Immutable! don't get Dirty :P
    let stories:IGStories? = {return IGHomeController.loadStubbedData()}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
    }
}

extension IGHomeController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = stories?.count {
            return count + 1 // Add Story cell
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGAddStoryCell.reuseIdentifier(),for: indexPath) as? IGAddStoryCell else { return UICollectionViewCell() }
            return cell
        }else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryListCell.reuseIdentifier(),for: indexPath) as? IGStoryListCell else { return UICollectionViewCell() }
            // Add Story cell
            cell.story = stories?.stories?[indexPath.row-1]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            //Add your own story
            //debugPrint("Need to implement!")
        }else{
            let storyPreviewScene = IGStoryPreviewController()
            storyPreviewScene.stories = stories
            storyPreviewScene.handPickedStoryIndex = indexPath.row-1
            present(storyPreviewScene, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return indexPath.row == 0 ? CGSize(width: 100, height: 100) : CGSize(width: 80, height: 100)
    }
}

extension IGHomeController {
    class func loadStubbedData()->IGStories? {
        guard let url = Bundle.main.url(forResource: "stories", withExtension: "json") else {return nil}
        guard let data = try? Data.init(contentsOf: url) else { return nil }
        do {
            if let wrapped = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [String:Any] {
                return IGStories.init(object: wrapped)
            }
        } catch {
            // Handle Error
            debugPrint(error)
        }
        return nil
    }
}

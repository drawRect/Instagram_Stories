//
//  IGHomeController.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

class IGHomeController: UIViewController {
    
    @IBOutlet weak var storiesCollectionView: UICollectionView! {
        didSet {
            storiesCollectionView.delegate = self
            storiesCollectionView.dataSource = self
            let storyListNib = UINib.init(nibName: IGStoryListCell.reuseIdentifier(), bundle: nil)
            storiesCollectionView.register(storyListNib, forCellWithReuseIdentifier: IGStoryListCell.reuseIdentifier())
            let addStoryNib = UINib.init(nibName: IGAddStoryCell.reuseIdentifier(), bundle: nil)
            storiesCollectionView.register(addStoryNib, forCellWithReuseIdentifier: IGAddStoryCell.reuseIdentifier())
        }
    }
    //Keep it Immutable! don't get Dirty :P
    let stories: IGStories = IGHomeController.loadStubbedData()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        self.automaticallyAdjustsScrollViewInsets = false
    }
}

extension IGHomeController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stories.count! + 1 // Add Story cell
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGAddStoryCell.reuseIdentifier(),for: indexPath) as! IGAddStoryCell
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryListCell.reuseIdentifier(),for: indexPath) as! IGStoryListCell
            // Add Story cell
            let story = stories.stories?[indexPath.row-1]
            cell.profileNameLabel.text = story?.user?.name
            cell.profileImageView.RK_setImage(urlString: story?.user?.picture ?? "")
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            //Add own story
        }else{
            let storyPreviewScene = IGStoryPreviewController()
            storyPreviewScene.stories = stories
            //reducing Coz,Add Story cell
            storyPreviewScene.storyIndex = indexPath.row-1
            self.present(storyPreviewScene, animated: true, completion: nil)
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
        let url = Bundle.main.url(forResource: "stories", withExtension: "json")
        let data = NSData(contentsOf: url!)
        do {
            let wrapped = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments) as! [String:Any]
            return IGStories.init(object: wrapped)
        } catch {
            // Handle Error
            debugPrint(error)
            return nil
        }
    }
}

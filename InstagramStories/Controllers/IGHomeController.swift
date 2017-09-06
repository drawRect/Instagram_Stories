//
//  IGHomeController.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

struct IGStory{
    
}

class IGHomeController: UIViewController {
    
    let imageArray:NSArray! = ["nature1.jpg","nature2.jpg","nature3.jpg"]

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
    let stories:[IGStory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        self.automaticallyAdjustsScrollViewInsets = false
    }
   
}

extension IGHomeController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10 + 1 // Add Story cell
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGAddStoryCell.reuseIdentifier(),for: indexPath) as! IGAddStoryCell
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryListCell.reuseIdentifier(),for: indexPath) as! IGStoryListCell
            cell.profileImageView.backgroundColor = UIColor.brown
            cell.profileNameLabel.text = "Story-\(indexPath.row+1)"
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0
        {
            //Add own story
        }
        else
        {
            let storyViewController = StoryViewController(nibName: "StoryViewController", bundle: nil) 
            storyViewController.imagearray = imageArray
            self.present(storyViewController, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return indexPath.row == 0 ? CGSize(width: 100, height: 100) : CGSize(width: 80, height: 100)
    }
}

//
//  StoryViewController.swift
//  InstagramStories
//
//  Created by Srikanth Vellore on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

class StoryViewController: UIViewController {

    public var imagearray:NSArray!
    
    @IBOutlet weak var collectionview: UICollectionView! {
        didSet {
        
            collectionview.delegate = self
            collectionview.dataSource = self
            let storyNib = UINib.init(nibName: StoryCollectionViewCell.reuseIdentifier(), bundle: nil)
            collectionview.register(storyNib, forCellWithReuseIdentifier: StoryCollectionViewCell.reuseIdentifier())
            
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.scrollDirection = .horizontal
            collectionview.collectionViewLayout = layout
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Story"
        self.automaticallyAdjustsScrollViewInsets = false
    }

}

extension StoryViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryCollectionViewCell.reuseIdentifier(), for: indexPath) as! StoryCollectionViewCell
        cell.imageview.image = UIImage(named:"\(imagearray.object(at: indexPath.row))")
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenwidth = UIScreen.main.bounds.size.width
        let screenheight = UIScreen.main.bounds.size.height
        return CGSize(width: screenwidth, height: screenheight)
    }
}

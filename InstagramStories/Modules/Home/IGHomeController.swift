//
//  IGHomeController.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

final class IGHomeController: UIViewController {
    
    //MARK: - iVars
    private var _view: IGHomeView{return view as! IGHomeView}
    private var viewModel: IGHomeViewModel = IGHomeViewModel()
    
    //MARK: - Overridden functions
    override func loadView() {
        super.loadView()
        view = IGHomeView.init(frame: UIScreen.main.bounds)
        _view.collectionView.delegate = self
        _view.collectionView.dataSource = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
    }
    override var navigationItem: UINavigationItem {
        let ni = UINavigationItem.init(title: "Home")
//        ni.rightBarButtonItem = UIBarButtonItem.init(title: "Del.CACHE", style: .done, target: self, action: #selector(clearImageCache))
//         ni.rightBarButtonItem?.tintColor = UIColor.init(red: 203.0/255, green: 69.0/255, blue: 168.0/255, alpha: 1.0)
        return ni
    }
    
    //MARK: - Private functions
    @objc private func clearImageCache() {
        IGImageCache.shared.clearCache()
    }
    private func showComingSoonAlert() {
        let alertController = UIAlertController.init(title: "Coming Soon...", message: nil, preferredStyle: .alert)
        present(alertController, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3){
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

//MARK: - Extension|UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
extension IGHomeController: UICollectionViewDelegate,UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryListCell.reuseIdentifier, for: indexPath) as? IGStoryListCell else { return UICollectionViewCell() }
            cell.userDetails = ("Add Story","https://avatars2.githubusercontent.com/u/32802714?s=200&v=4")
            return cell
        }else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryListCell.reuseIdentifier,for: indexPath) as? IGStoryListCell else { return UICollectionViewCell() }
            let story = viewModel.cellForItemAt(indexPath: indexPath)
            cell.story = story
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showComingSoonAlert()
        }else {
            DispatchQueue.main.async {
                if let stories = self.viewModel.getStories(), let stories_copy = try? stories.copy() {
                    let storyPreviewScene = IGStoryPreviewController.init(stories: stories_copy, handPickedStoryIndex:  indexPath.row-1)
                    self.present(storyPreviewScene, animated: true, completion: nil)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return indexPath.row == 0 ? CGSize(width: 100, height: 100) : CGSize(width: 80, height: 100)
    }
}

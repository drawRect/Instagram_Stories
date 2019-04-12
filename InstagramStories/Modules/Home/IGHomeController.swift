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
    private var _view: IGHomeView {return view as! IGHomeView}
    private lazy var viewModel: IGHomeViewModel = IGHomeViewModel()
    
    //MARK: - Overridden functions
    override func loadView() {
        view = IGHomeView(frame: UIScreen.main.bounds)
        _view.collectionView.delegate = self
        _view.collectionView.dataSource = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override var navigationItem: UINavigationItem {
        let navigationItem = UINavigationItem(title: "Instagram")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_trash"), style: .done, target: self, action: #selector(clearImageCache))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_camera"), style: .done, target: self, action: #selector(showComingSoonAlert))
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationItem.rightBarButtonItem?.tintColor = .black
        return navigationItem
    }
    
    //MARK: - Private functions
    @objc private func clearImageCache() {
        let alertController = UIAlertController(title: "Are you sure want to clear the Cache?", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Yes, Delete", style: .destructive) { _ in
            IGCache.shared.removeAllObjects()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        present(alertController, animated: true, completion: nil)
    }
    @objc private func showComingSoonAlert() {
        let alertController = UIAlertController(title: "Coming Soon...", message: nil, preferredStyle: .alert)
        present(alertController, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3){
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

extension IGHomeController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.isFirstRow {
            let cell: IGAddStoryCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            return cell
        }else {
            let cell: IGStoryListCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            guard let story = viewModel.cellForItemAt(indexPath: indexPath) else{fatalError("story not found at \(indexPath.item)")}
            cell.story = story
            return cell
        }
    }
    
}

extension IGHomeController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.isFirstRow {
            showComingSoonAlert()
        }else {
            if let stories = viewModel.stories,
                let stories_copy = try? stories.copy() {
                let storyPreviewScene = IGStoryPreviewController(stories: stories_copy, handPickedStoryIndex:  indexPath.row-1)
                present(storyPreviewScene, animated: true, completion: nil)
            }
        }
    }
    
}

extension IGHomeController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return indexPath.isFirstRow ? IGAddStoryCell.size : IGStoryListCell.size
    }
}


//
//  IGHomeController.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

private let isClearCacheEnabled = true

final class IGHomeController: UIViewController {
    // MARK: iVars
    private var _view: IGHomeView {
        return view as? IGHomeView ?? IGHomeView()
    }
    private var viewModel: IGHomeViewModel = IGHomeViewModel()
    // MARK: Overridden functions
    override func loadView() {
        super.loadView()
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
        let navigationItem = UINavigationItem()
        navigationItem.titleView = UIImageView(image: UIImage(named: "icInstaLogo"))
        if isClearCacheEnabled {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Clear Cache",
                style: .done,
                target: self,
                action: #selector(clearCache))
            navigationItem.rightBarButtonItem?.tintColor = UIColor(
                red: 203.0/255, green: 69.0/255, blue: 168.0/255, alpha: 1.0
            )
        }
        return navigationItem
    }
    // MARK: Private functions
    @objc private func clearCache() {
        IGVideoCacheHelper.default.clearAll { (result) in
            switch result {
            case .success(let isDone):
                if isDone {
                    self.showAlert(withMsg: "Images & Videos are deleted from cache")
                    IGCache.default.removeAllObjects()
                } else {
                    debugPrint("Error while clearing all datas")
                }
            case .failure(let error):
                debugPrint("Error while clearing all datas:\(error.localizedDescription)")
            }
        }
    }
    private func showAlert(withMsg: String) {
        let alertController = UIAlertController(title: withMsg, message: nil, preferredStyle: .alert)
        present(alertController, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// MARK: Extension|UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
extension IGHomeController: UICollectionViewDelegate, UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel.numberOfItemsInSection(section)
    }
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: IGAddStoryCell.reuseIdentifier,
                for: indexPath) as? IGAddStoryCell else { fatalError() }
            cell.userDetails = (
                "Your story",
                "https://randomuser.me/api/portraits/med/men/1.jpg"
            )
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: IGStoryListCell.reuseIdentifier,
                for: indexPath) as? IGStoryListCell else { fatalError() }
            let story = viewModel.cellForItemAt(indexPath: indexPath)
            cell.story = story
            return cell
        }
    }
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if indexPath.row == 0 {
            showAlert(withMsg: "Try to implement your own functionality for 'Your story'")
        } else {
            DispatchQueue.main.async {
                if let stories = self.viewModel.getStories(),
                    let storiesCopy = try? stories.copy() {
                    let storyPreviewScene = IGStoryPreviewController(
                        stories: storiesCopy,
                        handPickedStoryIndex: indexPath.row-1
                    )
                    self.present(storyPreviewScene, animated: true, completion: nil)
                }
            }
        }
    }
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return indexPath.row == 0 ? CGSize(width: 100, height: 100) : CGSize(width: 80, height: 100)
    }
}

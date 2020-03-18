//
//  IGAddStoryCell.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

final class IGAddStoryCell: UICollectionViewCell {
    // MARK: Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadUIElements()
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: iVars
    private let addStoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.alpha = 0.5
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    public var userDetails: (String, String)? {
        didSet {
            if let details = userDetails {
                addStoryLabel.text = details.0
                profileImageView.imageView.setImage(url: details.1, style: .rounded) { (result) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let image):
                            self.profileImageView.imageView.image = image
                        case .failure(let error):
                            debugPrint("image load erro:\(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    private let profileImageView: IGRoundedView = {
        let roundedView = IGRoundedView()
        roundedView.translatesAutoresizingMaskIntoConstraints = false
        roundedView.enableBorder(enabled: false)
        return roundedView
    }()
    lazy var addImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_Add")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20/2
        imageView.layer.borderWidth = 2.0
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.clipsToBounds = true
        return imageView
    }()
    // MARK: Private functions
    private func loadUIElements() {
        addSubview(addStoryLabel)
        addSubview(profileImageView)
        addSubview(addImageView)
    }
    private func installLayoutConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 68),
            profileImageView.heightAnchor.constraint(equalToConstant: 68),
            profileImageView.igTopAnchor.constraint(equalTo: self.igTopAnchor, constant: 8),
            profileImageView.igCenterXAnchor.constraint(equalTo: self.igCenterXAnchor),
            addStoryLabel.igTopAnchor.constraint(equalTo: self.profileImageView.igBottomAnchor, constant: 2)])
        NSLayoutConstraint.activate([
            addStoryLabel.igLeftAnchor.constraint(equalTo: self.igLeftAnchor),
            self.igRightAnchor.constraint(equalTo: addStoryLabel.igRightAnchor),
            addStoryLabel.igTopAnchor.constraint(equalTo: self.profileImageView.igBottomAnchor, constant: 2),
            addStoryLabel.igCenterXAnchor.constraint(equalTo: self.igCenterXAnchor),
            self.igBottomAnchor.constraint(equalTo: addStoryLabel.igBottomAnchor, constant: 8)])
        NSLayoutConstraint.activate([
            self.igRightAnchor.constraint(equalTo: addImageView.igRightAnchor, constant: 17),
            addImageView.widthAnchor.constraint(equalToConstant: 20),
            addImageView.heightAnchor.constraint(equalToConstant: 20),
            self.igBottomAnchor.constraint(equalTo: addImageView.igBottomAnchor, constant: 25)])
        layoutIfNeeded()
    }
}

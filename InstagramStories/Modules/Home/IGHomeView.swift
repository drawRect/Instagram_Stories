//
//  IGHomeView.swift
//  InstagramStories
//
//  Created by Srikanth Vellore on 01/11/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import Foundation
import UIKit

precedencegroup AppendingElements {
    associativity: left
}
infix operator ++: AppendingElements
func ++ <A,B>(x: A, f: (A) -> B) -> B {
    return f(x)
}
protocol Anchors {
    func leftAnchor(equalTo constraint: NSLayoutXAxisAnchor, constant: CGFloat) -> NSLayoutConstraint
    func rightAnchor(equalTo constraint: NSLayoutXAxisAnchor, constant: CGFloat) -> NSLayoutConstraint
    func topAnchor(equalTo constraint: NSLayoutYAxisAnchor, constant: CGFloat) -> NSLayoutConstraint
    func bottomAnchor(equalTo constraint: NSLayoutYAxisAnchor, constant: CGFloat) -> NSLayoutConstraint
}
extension Anchors where Self: UIView {
    func leftAnchor(equalTo constraint: NSLayoutXAxisAnchor, constant: CGFloat = 8) -> NSLayoutConstraint {
         self.leftAnchor.constraint(equalTo: constraint, constant: constant)
    }
    func rightAnchor(equalTo constraint: NSLayoutXAxisAnchor, constant: CGFloat = 8) -> NSLayoutConstraint {
        self.rightAnchor.constraint(equalTo: constraint, constant: constant)
    }
    func topAnchor(equalTo constraint: NSLayoutYAxisAnchor, constant: CGFloat = 8) -> NSLayoutConstraint {
        self.topAnchor.constraint(equalTo: constraint, constant: constant)
    }
    func bottomAnchor(equalTo constraint: NSLayoutYAxisAnchor, constant: CGFloat = 8) -> NSLayoutConstraint {
        self.bottomAnchor.constraint(equalTo: constraint, constant: constant)
    }
}
extension UIView: Anchors {}

class IGHomeView: UIView {
    
    //MARK: - iVars
    lazy var layout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 100, height: 100)
        return flowLayout
    }()
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(IGStoryListCell.self, forCellWithReuseIdentifier: IGStoryListCell.reuseIdentifier())
        cv.register(IGAddStoryCell.self, forCellWithReuseIdentifier: IGAddStoryCell.reuseIdentifier())
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    //MARK: - Overridden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.rgb(from: 0xEFEFF4)
        createUIElements()
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private functions
    private func createUIElements(){
        addSubview(collectionView)
    }
    private func installLayoutConstraints(){
        /*//New way
        var layoutConstraints: [NSLayoutConstraint] = {
            let lConstraint = [NSLayoutConstraint]()
        lConstraint
            ++ Array(collectionView.leftAnchor(equalTo: self.leftAnchor, constant: 8))
            ++ Array(collectionView.rightAnchor(equalTo: self.rightAnchor))
            return lConstraint
        }()*/
        
        //Old way
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 100)])
    }
}

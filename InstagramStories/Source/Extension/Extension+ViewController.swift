//
//  Extension+ViewController.swift
//  InstagramStories
//
//  Created by Ranjit on 26/09/20.
//  Copyright © 2020 DrawRect. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlert(withMsg: String) {
        let alertController = UIAlertController(title: withMsg, message: nil, preferredStyle: .alert)
        present(alertController, animated: true) {
            //FIXME:: What is the reason behind this delay??? 0.5
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
}


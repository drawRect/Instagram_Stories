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
    
    ///Presenting an alert and also enabling 0.5 sec to dismiss the alert
    func showAlert(withMsg: String) {
        let alertController = UIAlertController(title: withMsg, message: nil, preferredStyle: .alert)
        present(alertController, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
}


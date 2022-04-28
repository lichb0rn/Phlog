//
//  UIViewController+Extension.swift
//  phlog
//
//  Created by Miroslav Taleiko on 28.04.2022.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alertViewController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        alertViewController.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )
        
        self.present(alertViewController, animated: true)
    }
}

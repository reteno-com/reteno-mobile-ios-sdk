//
//  AlertPresentable.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 14.11.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit

protocol AlertPresentable {
    
    func presentAlert(with error: Error)
    func presentAlert(title: String, message: String?)
    
}

extension AlertPresentable where Self: UIViewController {
    
    func presentAlert(with error: Error) {
        let alert = UIAlertController(
            title: NSLocalizedString("common.error.title", comment: ""),
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.ok", comment: ""), style: .default))
        present(alert, animated: true)
    }
    
    func presentAlert(title: String, message: String?) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.ok", comment: ""), style: .default))
        present(alert, animated: true)
    }
    
}

//
//  KeyboardHandler.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 22.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit

class KeyboardHandlingViewController: NiblessViewController {
    var scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        observeKeyboard()
    }
    
    // MARK: Handle keyboard
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        let scrollView = self.scrollView
        if let info = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue {
            let keyboardFrame = view.convert(info.cgRectValue, from: nil)
            scrollView.contentInset.bottom = keyboardFrame.size.height + 20
        }
    }
    
    @objc
    func keyboardWillHide() {
        let scrollView = self.scrollView
        scrollView.contentInset = .zero
    }
    
    func observeKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
}

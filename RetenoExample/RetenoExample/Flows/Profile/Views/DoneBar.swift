//
//  DoneBar.swift
//  RetenoExample
//
//  Created by Serhii Prykhodko on 18.10.2022.
//

import UIKit

final class DoneBar: UIToolbar {
    
    private lazy var done: UIBarButtonItem = UIBarButtonItem(
        title: NSLocalizedString("createProfile_screen.doneButton", comment: ""),
        style: .done,
        target: self,
        action: #selector(doneButtonAction)
    )
    
    private weak var textField: UITextField?
    
    @objc func doneButtonAction() {
        textField?.resignFirstResponder()
    }
    
    init(textField: UITextField) {
        self.textField = textField
        
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 50.0))
        
        barStyle = .default
        items = [done]
        sizeToFit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

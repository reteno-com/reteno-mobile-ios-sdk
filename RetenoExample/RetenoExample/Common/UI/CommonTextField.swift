//
//  CommonTextField.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 10.01.2023.
//  Copyright © 2023 Yalantis. All rights reserved.
//

import UIKit
import SnapKit

final class CommonTextField: UITextField {
    
    init() {
        super.init(frame: .zero)
        
        snp.makeConstraints {
            $0.height.equalTo(30.0)
        }
        textAlignment = .center
        layer.cornerRadius = 8.0
        if #available(iOS 13.0, *) {
            backgroundColor = .systemGroupedBackground
        } else {
            backgroundColor = .groupTableViewBackground
        }
        autocapitalizationType = .none
        autocorrectionType = .no
        let doneBar = DoneBar(textField: self)
        inputAccessoryView = doneBar
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//
//  CommonButton.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 10.01.2023.
//  Copyright © 2023 Yalantis. All rights reserved.
//

import UIKit

final class CommonButton: UIButton {
    
    init() {
        super.init(frame: .zero)
        
        layer.cornerRadius = 8.0
        backgroundColor = .black
        setTitleColor(.white, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//
//  InformationAlert.swift
//  RetenoExample
//
//  Created by Serhii Prykhodko on 23.09.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit
import SnapKit

final class InformationAlert: UIView {
    
    private let label = UILabel()
    
    init(text: String) {
        super.init(frame: .zero)
        
        setupLayout(text: text)
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("unable to create InfromationAlert from NSCoder")
    }
    
}

// MARK: - Layout

private extension InformationAlert {
    
    func setupLayout(text: String) {
        backgroundColor = .lightGray
        addSubview(label)
        
        label.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12.0)
        }
        label.numberOfLines = 0
        label.text = text
    }
    
}

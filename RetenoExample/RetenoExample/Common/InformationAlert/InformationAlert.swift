//
//  InformationAlert.swift
//  RetenoExample
//
//  Created by Serhii Prykhodko on 23.09.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit
import SnapKit
import Reteno

extension LinkSource {
    
    var toBackground: InformationAlert.BackgroundType {
        switch self {
        case .inAppMessage: return .inApp
        case .pushNotification: return .push
        }
    }
}

final class InformationAlert: UIView {
    
    enum BackgroundType {
        case push
        case inApp
        
        var color: UIColor {
            switch self {
            case .inApp: return UIColor.cyan
            case .push: return UIColor.orange
            }
        }
        
    }
    
    private let label = UILabel()
    
    init(text: String, backgroundType: BackgroundType) {
        super.init(frame: .zero)
        
        backgroundColor = backgroundType.color
        setupLayout(text: text)
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("unable to create InfromationAlert from NSCoder")
    }
    
}

// MARK: - Layout

private extension InformationAlert {
    
    func setupLayout(text: String) {
        addSubview(label)
        
        label.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12.0)
        }
        label.numberOfLines = 0
        label.text = text
    }
    
}

//
//  Reusable.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 22.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit

final class ReusableViews {
    
    static func setupSeparatorView(stack: UIStackView, color: UIColor, viewHeight: Double) {
        let separatorView = UIView()
        separatorView.backgroundColor = color
        stack.addArrangedSubview(separatorView)
        separatorView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(viewHeight)
        }
    }
    
    static func setupSwitch(view: UIView, label: UILabel, switcher: UISwitch, labelText: String, switcherIsOn: Bool = false) -> UIView {
        let stack = UIStackView()
        view.addSubview(stack)
        stack.axis = .horizontal
        label.text = labelText
        
        stack.addArrangedSubview(label)
        label.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(20.0)
            $0.height.equalTo(30.0)
        }
        
        stack.addArrangedSubview(switcher)
        switcher.isOn = switcherIsOn
        switcher.snp.makeConstraints {
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20.0)
            $0.height.equalTo(30.0)
        }
        
        return stack
    }
    
}

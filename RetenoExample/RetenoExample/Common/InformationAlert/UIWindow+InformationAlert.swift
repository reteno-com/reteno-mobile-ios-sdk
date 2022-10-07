//
//  UIWindow+InformationAlert.swift
//  RetenoExample
//
//  Created by Serhii Prykhodko on 23.09.2022.
//

import UIKit
import SnapKit

extension UIWindow {
    
    func showInformationAlert(_ alert: InformationAlert) {
        addSubview(alert)
        
        alert.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(-alert.frame.height)
        }
        
        UIView.animate(withDuration: 0.5) {
            alert.snp.updateConstraints {
                $0.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            }
            alert.layoutIfNeeded()
        }
        
        let hideAnimation: () -> Void = { [weak alert] in
            guard let alert = alert else { return }
            
            alert.snp.updateConstraints {
                $0.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(-alert.frame.height)
            }
            alert.layoutIfNeeded()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            UIView.animate(withDuration: 0.5, animations: hideAnimation) { [weak alert] _ in
                alert?.removeFromSuperview()
            }
        }
    }
    
}

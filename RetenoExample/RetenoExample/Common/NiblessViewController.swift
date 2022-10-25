//
//  NiblessViewController.swift
//  RetenoExample
//
//  Created by Serhii Prykhodko on 06.10.2022.
//

import UIKit

class NiblessViewController: UIViewController {
    
    init() {
      super.init(nibName: nil, bundle: nil)
    }
      
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
      fatalError("Init is not implemented")
    }
    
}

//
//  ImageCell.swift
//  
//
//  Created by Anna Sahaidak on 01.11.2022.
//

import UIKit

final class ImageCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: public methods
    
    func apply(image: UIImage) {
        imageView.image = image
    }
    
    // MARK: Setup views
    
    private func setupViews() {
        imageView.contentMode = .scaleAspectFit
        imageView.layout(in: contentView)
    }
    
}

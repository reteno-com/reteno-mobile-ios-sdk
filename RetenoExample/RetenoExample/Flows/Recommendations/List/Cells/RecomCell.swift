//
//  RecomCell.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 11.11.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit
import Kingfisher

protocol RecomCellDelegate: AnyObject {
    
    func viewRecom(in cell: RecomCell)
    
}

final class RecomCell: UICollectionViewCell {
    
    struct Info {
        
        let name: String
        let description: String
        let imageURL: URL?
        let price: Float
        
    }
    
    weak var delegate: RecomCellDelegate?
    
    private let nameLabel = UILabel()
    private let imageView = UIImageView()
    private let descriptionLabel = UILabel()
    private let priceLabel = UILabel()
    private let containerView = UIView()
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.kf.cancelDownloadTask()
    }
    
    func apply(info: Info) {
        nameLabel.text = info.name
        descriptionLabel.attributedText = info.description.htmlToAttributedString()
        imageView.kf.setImage(with: info.imageURL)
        imageView.isHidden = info.imageURL == nil
        priceLabel.text = NSLocalizedString("recoms_screen.price_title", comment: "") + ": \(info.price)"
    }
    
    func handleClick() {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.containerView.alpha = 0.3
            },
            completion: { _ in
                self.containerView.alpha = 1.0
            }
        )
    }
    
    // MARK: Setup views
    
    private func setupViews() {
        if #available(iOS 13.0, *) {
            contentView.backgroundColor = .systemGroupedBackground
        } else {
            contentView.backgroundColor = .groupTableViewBackground
        }
        
        containerView.layer.cornerRadius = 8.0
        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16.0)
            $0.width.equalTo(UIScreen.main.bounds.width - 32.0)
        }
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6.0
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(6.0)
        }
        
        nameLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
        stackView.addArrangedSubview(nameLabel)
        
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints {
            $0.height.equalTo(imageView.snp.width).multipliedBy(1.5)
        }
        stackView.addArrangedSubview(imageView)
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 14.0)
        descriptionLabel.numberOfLines = 0
        stackView.addArrangedSubview(descriptionLabel)
        
        priceLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        stackView.addArrangedSubview(priceLabel)
        
        let viewButton = UIButton()
        viewButton.backgroundColor = .systemBlue
        viewButton.setTitle(NSLocalizedString("recoms_screen.view_button.title", comment: ""), for: .normal)
        viewButton.setTitleColor(.white, for: .normal)
        viewButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        viewButton.layer.cornerRadius = 8.0
        viewButton.addTarget(self, action: #selector(viewProductAction), for: .touchUpInside)
        viewButton.snp.makeConstraints {
            $0.height.equalTo(48.0)
        }
        stackView.addArrangedSubview(viewButton)
    }
    
    // MARK: Actions
    
    @objc
    private func viewProductAction(_ sender: UIButton) {
        delegate?.viewRecom(in: self)
    }
    
}

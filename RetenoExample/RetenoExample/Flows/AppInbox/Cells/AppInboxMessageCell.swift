//
//  AppInboxMessageCell.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 25.10.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit
import Kingfisher

protocol AppInboxMessageCellDelegate {
    
    func markAsOpened(cell: AppInboxMessageCell)
    
}

final class AppInboxMessageCell: UITableViewCell {
    
    struct MessageInfo {
        
        let title: String
        let content: String
        let date: Date?
        let imageURL: URL?
        let linkURL: URL?
        let isOpened: Bool
        
    }
    
    var delegate: AppInboxMessageCellDelegate?
    
    private let messageImageView = UIImageView()
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let dateLabel = UILabel()
    private let statusView = UIView()
    private let actionButton = UIButton()
    
    // MARK: Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        messageImageView.kf.cancelDownloadTask()
    }
    
    func apply(messageInfo: MessageInfo) {
        titleLabel.text = messageInfo.title
        contentLabel.text = messageInfo.content
        statusView.backgroundColor = messageInfo.isOpened ? .clear : .systemBlue
        dateLabel.text = messageInfo.date.flatMap { DateFormatter.baseDateFormatter.string(from: $0) }
        accessoryType = messageInfo.linkURL != nil ? .disclosureIndicator : .none
        actionButton.isHidden = messageInfo.isOpened
        messageImageView.kf.setImage(with: messageInfo.imageURL)
    }
    
    // MARK: Setup views
    
    private func setupViews() {
        messageImageView.contentMode = .scaleAspectFit
        contentView.addSubview(messageImageView)
        messageImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16.0)
            $0.width.height.equalTo(60.0)
        }
        
        titleLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16.0)
            $0.leading.equalTo(messageImageView.snp.trailing).offset(4.0)
        }
        
        statusView.layer.cornerRadius = 4.0
        contentView.addSubview(statusView)
        statusView.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8.0)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16.0)
            $0.width.height.equalTo(8.0)
        }
        
        dateLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .light)
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8.0)
            $0.leading.trailing.equalTo(titleLabel)
        }
        
        contentLabel.font = UIFont.systemFont(ofSize: 14.0)
        contentLabel.numberOfLines = 0
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(8.0)
            $0.leading.trailing.equalTo(titleLabel)
            $0.bottom.lessThanOrEqualToSuperview().offset(-16.0)
        }
        
        actionButton.setTitle(NSLocalizedString("inbox_screen.mark_button.title", comment: ""), for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 12.0, weight: .bold)
        actionButton.layer.cornerRadius = 6.0
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.backgroundColor = .systemBlue
        actionButton.addTarget(self, action: #selector(handleActionButton), for: .touchUpInside)
        contentView.addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(8.0)
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.height.equalTo(40.0)
            $0.bottom.equalToSuperview().offset(-16.0)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func handleActionButton(_ sender: UIButton) {
        delegate?.markAsOpened(cell: self)
    }

}

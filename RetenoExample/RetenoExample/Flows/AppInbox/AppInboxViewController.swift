//
//  AppInboxViewController.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 25.10.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit
import SnapKit

final class AppInboxViewController: NiblessViewController, AlertPresentable {
    
    private lazy var openAllItem: UIBarButtonItem = {
        let openAllButton = UIButton()
        openAllButton.setTitle(NSLocalizedString("inbox_screen.mark_all_button.title", comment: ""), for: .normal)
        openAllButton.setTitleColor(.systemBlue, for: .normal)
        openAllButton.addTarget(self, action: #selector(openAllAction), for: .touchUpInside)
        
        return UIBarButtonItem(customView: openAllButton)
    }()
    
    private let viewModel: AppInboxViewModel
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    
    // MARK: Lifecycle
    
    init(viewModel: AppInboxViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("inbox_screen.title", comment: "")
        setupLayout()
        loadMessages()
    }
    
    private func loadMessages() {
        viewModel.loadMessages { [weak self] result in
            guard let self = self else { return }
            
            self.refreshControl.endRefreshing()
            
            switch result {
            case .success:
                self.setPlaceholderHidden(isHidden: self.viewModel.messagesCount() > 0)
                self.navigationItem.rightBarButtonItem = self.viewModel.newMessagesCount() > 0 ? self.openAllItem : nil
                self.tableView.reloadData()
                
            case .failure(let error):
                self.presentAlert(with: error)
            }
        }
    }
    
    private func setPlaceholderHidden(isHidden: Bool) {
        if isHidden {
            tableView.backgroundView = nil
        } else {
            let imageView = UIImageView(image: UIImage(named: "empty_inbox"))
            let placeholderView = UIView()
            placeholderView.addSubview(imageView)
            imageView.snp.makeConstraints {
                $0.centerX.centerY.equalToSuperview()
                $0.width.equalTo(300.0)
                $0.height.equalTo(225.0)
            }
            tableView.backgroundView = placeholderView
        }
    }
    
    // MARK: Actions
    
    @objc
    private func handleRefreshAction(_ sender: Any) {
        loadMessages()
    }
    
    @objc
    private func openAllAction(_ sender: UIButton) {
        viewModel.markAllAsOpened { [weak self] result in
            switch result {
            case .success:
                self?.loadMessages()
                
            case .failure(let error):
                self?.presentAlert(with: error)
            }
        }
    }
    
}

// MARK: Setup layout

extension AppInboxViewController {
    
    private func setupLayout() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(AppInboxMessageCell.self, forCellReuseIdentifier: String(describing: AppInboxMessageCell.self))
        tableView.refreshControl = refreshControl
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        refreshControl.addTarget(self, action: #selector(handleRefreshAction), for: .valueChanged)
    }
    
}

extension AppInboxViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.messagesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AppInboxMessageCell.self), for: indexPath)
        let message = viewModel.message(at: indexPath.row)
        (cell as? AppInboxMessageCell)?.apply(
            messageInfo: AppInboxMessageCell.MessageInfo(
                title: message.title,
                content: message.content ?? "",
                date: message.createdDate,
                imageURL: message.imageURL,
                linkURL: message.linkURL,
                isOpened: !message.isNew
            )
        )
        (cell as? AppInboxMessageCell)?.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = viewModel.message(at: indexPath.row).linkURL else { return }
        
        UIApplication.shared.open(url)
    }
    
}

extension AppInboxViewController: AppInboxMessageCellDelegate {
    
    func markAsOpened(cell: AppInboxMessageCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        viewModel.markMessageAsOpened(at: indexPath.row) { [weak self] result in
            switch result {
            case .success:
                self?.loadMessages()
                
            case .failure(let error):
                self?.presentAlert(with: error)
            }
        }
    }
    
}

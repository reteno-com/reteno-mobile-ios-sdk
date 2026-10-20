//
//  AccountsListViewController.swift
//  RetenoExample
//
//  Copyright © 2026 Yalantis. All rights reserved.
//

import UIKit
import SnapKit

final class AccountsListViewController: NiblessViewController {
    
    private static let cellIdentifier = "AccountCell"
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let emptyLabel = UILabel()
    
    private let viewModel: AccountsListViewModel
    
    init(viewModel: AccountsListViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reload()
    }
    
    private func reload() {
        viewModel.reload()
        emptyLabel.isHidden = !viewModel.items.isEmpty
        tableView.reloadData()
    }
    
    @objc
    private func addAction() {
        viewModel.addAccount()
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension AccountsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        viewModel.items.isEmpty ? nil : NSLocalizedString("accounts_screen.footer", comment: "")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: Self.cellIdentifier)
        let item = viewModel.items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.textLabel?.font = .systemFont(ofSize: 16.0, weight: item.isActive ? .semibold : .regular)
        cell.detailTextLabel?.text = item.subtitle
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.accessoryType = item.isActive ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectAccount(at: indexPath.row)
        tableView.reloadData()
    }
    
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else { return }
        
        viewModel.deleteAccount(at: indexPath.row)
        reload()
    }
    
}

// MARK: - Layout

private extension AccountsListViewController {
    
    func setupLayout() {
        title = NSLocalizedString("accounts_screen.title", comment: "")
        view.backgroundColor = .systemGroupedBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addAction)
        )
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        tableView.dataSource = self
        tableView.delegate = self
        
        emptyLabel.text = NSLocalizedString("accounts_screen.empty", comment: "")
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        tableView.backgroundView = emptyLabel
    }
    
}

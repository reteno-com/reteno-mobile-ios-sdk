//
//  RecomsViewController.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 10.11.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit

final class RecomsViewController: NiblessViewController, AlertPresentable {
    
    private let viewModel: RecomsViewModel
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: CollectionViewLayout())
    
    // MARK: Lifecycle
    
    init(viewModel: RecomsViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("recoms_screen.title", comment: "")
        view.backgroundColor = .white
        setupLayout()
        setupNavigationBar()
        loadRecoms()
    }
    
    func loadRecoms(with settings: RecommendationsSettings = RecommendationsSettings.defaultSettings()) {
        viewModel.loadRecoms(with: settings) { [weak self] result in
            switch result {
            case .success:
                self?.collectionView.reloadData()
                
            case .failure(let error):
                self?.presentAlert(with: error)
            }
        }
    }
    
    // MARK: Actions
    
    @objc
    private func settingsAction(_ sender: UIButton) {
        viewModel.openSettings()
    }

}

// MARK: Setup layout

extension RecomsViewController {
    
    private func setupLayout() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(RecomCell.self, forCellWithReuseIdentifier: String(describing: RecomCell.self))
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = .systemGroupedBackground
        } else {
            collectionView.backgroundColor = .groupTableViewBackground
        }
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupNavigationBar() {
        let settingsButton = UIButton()
        settingsButton.setTitle(NSLocalizedString("recoms_screen.setting_button.title", comment: ""), for: .normal)
        settingsButton.setTitleColor(.systemBlue, for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsAction), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
    }
    
}

extension RecomsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.recomsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: RecomCell.self), for: indexPath)
        let recom = viewModel.recoms(at: indexPath.item)
        (cell as? RecomCell)?.apply(
            info: RecomCell.Info(
                name: recom.name,
                description: recom.description,
                imageURL: recom.imageUrl,
                price: recom.price
            )
        )
        (cell as? RecomCell)?.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.trackClickedRecom(at: indexPath.item)
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? RecomCell else { return }
        
        cell.handleClick()
    }
    
}

extension RecomsViewController: RecomCellDelegate {
    
    func viewRecom(in cell: RecomCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        viewModel.trackViewedRecom(at: indexPath.item)
    }
    
}

private class CollectionViewLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        
        scrollDirection = .vertical
        estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        minimumLineSpacing = 0.0
        minimumInteritemSpacing = 0.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

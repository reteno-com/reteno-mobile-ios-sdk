//
//  RetenoCarouselNotificationViewController.swift
//  
//
//  Created by Anna Sahaidak on 01.11.2022.
//

import UIKit
import UserNotifications
import UserNotificationsUI

open class RetenoCarouselNotificationViewController: UIViewController {
    
    private var isFirstLayout = true
    
    private var images: [UIImage] = []
    
    private var carouselTimer: Timer?
    
    private var currentImageIndex: Int {
        collectionView.indexPathsForVisibleItems.last?.row ?? 0
    }
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFlowLayout())
    
    // MARK: Lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let collectionViewSize = collectionView.frame.size
        
        guard isFirstLayout, collectionViewSize != .zero else { return }
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = collectionViewSize
        }
        isFirstLayout = false
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        carouselTimer?.invalidate()
        carouselTimer = nil
    }
    
    // MARK: Setup views
    
    private func setupViews() {
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: String(describing: ImageCell.self))
        
        collectionView.layout(in: view)
    }
    
    private func setupCarouselTimer() {
        carouselTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            
            var index = self.currentImageIndex
            if index == self.images.count - 1 {
                index = 0
            } else {
                index += 1
            }
            self.collectionView.isPagingEnabled = false
            self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
            self.collectionView.isPagingEnabled = true
        })
    }

}

extension RetenoCarouselNotificationViewController: UNNotificationContentExtension {
    
    public func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        
        guard RetenoNotificationsHelper.isRetenoPushNotification(content.userInfo) else { return }
        
        let attachments = content.attachments
        
        guard attachments.isNotEmpty else { return }
        
        images.removeAll()
        attachments.forEach {
            guard
                $0.url.startAccessingSecurityScopedResource(),
                let imageData = try? Data(contentsOf: $0.url),
                let image = UIImage(data: imageData)
            else {
                $0.url.stopAccessingSecurityScopedResource()
                return
            }

            images.append(image)
            $0.url.stopAccessingSecurityScopedResource()
        }
        collectionView.reloadData()
        setupCarouselTimer()
    }
    
}

extension RetenoCarouselNotificationViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCell.self), for: indexPath)
        (cell as? ImageCell)?.apply(image: images[indexPath.row])
        return cell
    }
    
}

private final class CollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        
        scrollDirection = .horizontal
        minimumInteritemSpacing = 8.0
        minimumLineSpacing = 0.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

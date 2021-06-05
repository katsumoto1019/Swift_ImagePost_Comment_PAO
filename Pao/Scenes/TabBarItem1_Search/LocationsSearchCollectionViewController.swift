//
//  LocationsSearchTableViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 28/09/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload


class LocationsSearchCollectionViewController: CollectionViewController<LocationSearchCollectionViewCell> {
    
    // MARK: - Internal properties
    
    override var cellsPerRow: Int { return 2 }
    override var cellSpacing: CGFloat { return 0 }
    
    // MARK: - Private properties

    typealias CellPayloadType = LocationSearchCollectionViewCell.PayloadType
    private var cells: [CellPayloadType]?
    private var firstLaunch = true
    private lazy var cacher = Cacher<String, [CellPayloadType]>(entryLifetime: 1 * 60 * 60) // 1 hour
    private let key = "LocationsSearch"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        collection.bufferSize = 30
        setupCollectionView()
        super.viewDidLoad()
        
        activityIndicatorView?.startAnimating()
        addSubViews()
        stopRefreshControll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstLaunch {
            firstLaunch = false
        } else {
            collection.loadData(true)
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupCellSize()
    }
    
    // MARK: - Internal methods
    
    func loadData() {
        guard collection.count <= 0 else { return }
        collection.loadData(true)
    }
    
    // MARK: - UICollectionViewDelegate implementation
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showLocation(for: collection[indexPath.row])
    }
    
    override func getPayloads(completionHandler: @escaping ([LocationSearchCollectionViewCell.PayloadType]?) -> Void) -> PayloadTask? {
        
        fetchData { cells in
            DispatchQueue.main.async {
                completionHandler(cells)
            }
        }
        
        return nil
    }
    
    // MARK: - Private methods
    
    private func setupCollectionView() {
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0)
    }
    
    private func setupCellSize() {
        let viewWidth = view.frame.size.width
        let cellWidth = (viewWidth - cellSpacing * CGFloat(cellsPerRow - 1)) / CGFloat(cellsPerRow)
        let cellHeight: CGFloat = 140 + 8 + 20 + 18 + 32
        
        guard let collectionViewFlowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return }
        collectionViewFlowLayout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        collectionViewFlowLayout.minimumLineSpacing = cellSpacing
        collectionViewFlowLayout.minimumInteritemSpacing = cellSpacing
    }
    
    private func addSubViews() {
        let headLabel = UILabel()
        headLabel.numberOfLines = 0
        headLabel.text = L10n.LocationsSearchCollectionViewController.title
        headLabel.translatesAutoresizingMaskIntoConstraints = false
        headLabel.font = UIFont.appHeavy.withSize(UIFont.sizes.large)
        styleLabel(label: headLabel)
        
        let subHeadingLabel = UILabel()
        subHeadingLabel.numberOfLines = 0
        subHeadingLabel.text = L10n.LocationsSearchCollectionViewController.subTitle
        subHeadingLabel.translatesAutoresizingMaskIntoConstraints = false
        subHeadingLabel.font = UIFont.appLight.withSize(UIFont.sizes.small)
        styleLabel(label: subHeadingLabel)
        
        let headerStackView = UIStackView()
        headerStackView.axis = .vertical
        headerStackView.frame = CGRect(x: 0, y: -60, width: collectionView.frame.width, height: 55)
        headerStackView.backgroundColor = UIColor.clear
        headerStackView.addArrangedSubview(headLabel)
        headerStackView.addArrangedSubview(subHeadingLabel)
        
        collectionView.addSubview(headerStackView)
    }
    
    private func styleLabel(label: UILabel) {
        label.textColor = ColorName.textWhite.color
        label.textAlignment = .center
    }
    
    private func stopRefreshControll() {
        refreshControl?.endRefreshing()
        refreshControl?.removeFromSuperview()
        refreshControl = nil
    }
    
    /// Show spots for specific location
    ///
    /// - Parameter location: Location to be displayed. If sent nil, then it will get current location
    private func showLocation(for location: Location?) {
        let viewController = LocationInteractionViewController(location: location)
        let navigationController = UINavigationController(rootViewController:  viewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    private func fetchData(completion: @escaping ([CellPayloadType]?) -> Void) {
        DispatchQueue.global(qos: .default).async {
            if let cells = self.cacher.getData(with: self.key) {
                self.cells = cells
                completion(self.cells)
            } else {
                self.fetchNetworkData(completion: completion)
            }
        }
    }
    
    private func fetchNetworkData(completion: @escaping ([CellPayloadType]?) -> Void) {
        App.transporter.get([CellPayloadType].self, for: type(of: self)) { [weak self] (cells) in
            guard let self = self else { return }
            self.cells = cells
            self.cacher.save(cells, key: self.key)
            completion(self.cells)
        }
    }
}

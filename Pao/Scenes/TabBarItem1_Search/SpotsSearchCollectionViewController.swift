//
//  SpotsSearchCollectionViewController.swift
//  Pao
//
//  Created by MACBOOK PRO on 09/09/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit
import Payload

class SpotsSearchCollectionViewController: CollectionViewController<SpotsSearchCollectionViewCell> {
    
    // MARK: - Internal properties
    
    override var cellsPerRow: Int { return 2 }
    override var cellSpacing: CGFloat { return 0 }
    
    // MARK: - Private properties
    
    private var firstLaunch = true
    private lazy var emptyView: UIView = {
        let noResultText = NSMutableAttributedString(string: L10n.SpotsSearchCollectionViewController.noResultText)
        noResultText.addAttribute(NSAttributedString.Key.font, value: UIFont.appNormal.withSize(18), range: NSRange(location: 0, length: 8))
        
        let label = UILabel()
        label.font = UIFont.app.withSize(UIFont.sizes.small)
        label.attributedText = noResultText
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = ColorName.textWhite.color
        
        let view = UIView()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.constraintToFit(inContainerView: view)
        view.isHidden = true
        return view
    }()
    private var spots: [Spot]?
    private lazy var cacher = Cacher<String, [Spot]>(entryLifetime: 1 * 60 * 60) // 1 hour
    private let key = "SpotsSearch"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorView?.startAnimating()
        collectionView.contentInset = UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0)
        
        addSubViews()
        
        refreshControl?.endRefreshing()
        refreshControl?.removeFromSuperview()
        refreshControl = nil
        
        collectionView.showsVerticalScrollIndicator = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstLaunch {
            firstLaunch = false
        } else {
            collection.loadData(true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupCellSize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
    }
    
    func loadData() {
        guard collection.count <= 0 else { return }        
        collection.loadData(true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var spots = [Spot]()
        for spot in collection {
            spots.append(spot)
        }
        
        let viewController = ManualSpotsViewController(spots: spots)
        viewController.title = L10n.Common.titleTopSpots
        viewController.scrolltoIndex = IndexPath(row: indexPath.row, section: 0)
        viewController.dataDidUpdate = { (updatedSpot: Spot) in
            self.cacher.removeFullData(forKey: self.key)
        }
        navigationController?.pushViewController(viewController, animated: true)
        
        //Amplitude swipe event
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewController.spotCollectionViewController.amplitudeEventSwipe =  .swipeTopSpotsFeed
            viewController.spotCollectionViewController.amplitudeEventGroup =  .search
        }
    }
    
    override func getPayloads(completionHandler: @escaping ([Spot]?) -> Void) -> PayloadTask? {
        
        fetchData { spots in
            DispatchQueue.main.async {
                completionHandler(spots)
            }            
        }
        
        return nil
    }
    
    // MARK: - Private methods
    
    private func addSubViews() {
        let headerStackView = UIStackView()
        headerStackView.axis = .vertical
        headerStackView.frame = CGRect(x: 0, y: -60, width: self.collectionView.frame.width, height: 55)
        headerStackView.backgroundColor = UIColor.clear
        
        let headLabel = UILabel()
        headLabel.numberOfLines = 0
        headLabel.text = L10n.SpotsSearchCollectionViewController.Header.title
        headLabel.translatesAutoresizingMaskIntoConstraints = false
        headerStackView.addArrangedSubview(headLabel)
        headLabel.font = UIFont.appHeavy.withSize(UIFont.sizes.large)
        styleLabel(label: headLabel)
        
        let subHeadingLabel = UILabel()
        subHeadingLabel.numberOfLines = 0
        subHeadingLabel.text = L10n.SpotsSearchCollectionViewController.Header.subTitle
        subHeadingLabel.translatesAutoresizingMaskIntoConstraints = false
        headerStackView.addArrangedSubview(subHeadingLabel)
        subHeadingLabel.font = UIFont.appLight.withSize(UIFont.sizes.small)
        styleLabel(label: subHeadingLabel)
        
        collectionView.addSubview(headerStackView)
    }
    
    private func styleLabel(label: UILabel) {
        label.textColor = ColorName.textWhite.color
        label.textAlignment = .center
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
    
    private func fetchData(completion: @escaping ([Spot]?) -> Void) {
        DispatchQueue.global(qos: .default).async {
            if let spots = self.cacher.getData(with: self.key) {
                self.spots = spots
                completion(self.spots)
            } else {
                self.fetchNetworkData(completion: completion)
            }
        }
    }
    
    private func fetchNetworkData(completion: @escaping ([Spot]?) -> Void) {
        App.transporter.get([Spot].self, for: type(of: self)) { [weak self] (spots) in
            guard let self = self else { return }
            self.spots = spots
            self.cacher.save(spots, key: self.key)
            completion(self.spots)
        }
    }
}

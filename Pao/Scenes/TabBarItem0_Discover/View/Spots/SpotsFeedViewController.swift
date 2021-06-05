//
//  SpotsFeedViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 25/05/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Firebase
import Payload


class SpotsFeedViewController: SpotsViewController {
    
    // MARK: - Internal properties
    
    var didGetSpotData: (() -> Void)?
    
    // MARK: - Private properties
    
    private var startingIndex = 0
    private var topupsCallback: ((_ indexPath: IndexPath) -> Void)?
    
    // MARK: - Lifecycle
    
    init() {
        super.init(nibName: String(describing: SpotsViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        startingIndex = UserDefaults.standard.integer(forKey: UserDefaultsKey.curatedFeedIndex.rawValue)
        
        super.viewDidLoad()
        
        spotCollectionViewController.disablePullToRefresh()
    }
    
    // MARK: - SpotsViewController implementation
    
    override func setCacheKey() {
        collection.cacheKey = "CuratedFeed"
    }
    
    override func cellWillDisplay(indexPath: IndexPath, cell: UICollectionViewCell) {
        super.cellWillDisplay(indexPath: indexPath, cell: cell)
        
        topupsCallback?(indexPath)
    }
    
    override func getPayloads(completionHandler: @escaping ([Spot]?) -> Void) -> PayloadTask? {
        let params = SpotsParams(skip: spotCollectionViewController.isReloading ? startingIndex : collection.count + startingIndex, take: collection.bufferSize)
        
        return App.transporter.get([Spot].self, for: type(of: self), queryParams: params) { [weak self] (spots) in
            guard let self = self else { return completionHandler(nil) }
            self.didGetSpotData?()
            completionHandler(spots)
        }
    }
}

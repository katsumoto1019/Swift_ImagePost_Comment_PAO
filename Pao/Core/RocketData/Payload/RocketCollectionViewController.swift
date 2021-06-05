//
//  RocketCollectionViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 24/04/19.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit
import Payload

import RocketData


class RocketCollectionViewController<T>: CollectionViewController<T> where T: UICollectionViewCell & Consignee, T.PayloadType: PaoModel {
    
    var rocketCollection = RocketCollection<T.PayloadType>()
    var screenName: String?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        if rocketCollection.cacheKey == nil {
            rocketCollection.cacheKey = UUID().uuidString
        }
        
        collection = rocketCollection
        
        collection.loaded.append { _ in
            self.refreshControl?.endRefreshing()
            self.activityIndicatorView?.stopAnimating()
        }
        
        super.viewDidLoad()
    }
}

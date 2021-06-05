//
//  CSCollectionViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 31/10/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import Payload

import NVActivityIndicatorView

class CollectionViewController<T>: PayloadCollectionViewController<T>, Searchable where T: UICollectionViewCell & Consignee, T.PayloadType: Codable {
    
    var isRefreshDisabled = false
    
    var searchString: String? {
        didSet {
            if oldValue == searchString || (oldValue == nil && searchString == "") { return }
            refresh()
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        if collection.courier == nil {
            collection.courier = getPayloads
        }
        
        activityIndicatorView = NVActivityIndicatorView(
            frame: CGRect(x: 0, y: 0, width: 40, height: 40),
            type: .circleStrokeSpin,
            color: ColorName.textGray.color,
            padding: 8
        )
        
        if isRefreshDisabled {
            refreshControl = nil
        } else {
            refreshControl = RefreshControl()
        }
        
        //HACK: followinf code snipt is to hide the double loader, https://stackoverflow.com/questions/19026351/ios-7-uirefreshcontrol-tintcolor-not-working-for-beginrefreshing
        if collectionView.contentOffset.y == 0 {
            let y = -(refreshControl?.frame.size.height ?? 0)
            collectionView.contentOffset = CGPoint(x: 0, y: y)
        }
        
        refreshControl?.beginRefreshing()
        
        collection.elementsChanged.append { [weak self] _ in
            guard let self = self else { return }
            self.collectionView.backgroundView?.isHidden = self.collection.count != 0
        }
        
        collection.loaded.append { _ in
            self.refreshControl?.endRefreshing()
            self.activityIndicatorView?.stopAnimating()
        }
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard refreshControl?.isRefreshing == true else { return }
        collectionView.backgroundView?.isHidden = true
    }
    
    func getPayloads(completionHandler: @escaping ([T.PayloadType]?) -> Void) -> PayloadTask? {
        let params = CollectionParams(skip: collection.count, take: collection.bufferSize, keyword: searchString)
        return App.transporter.get([T.PayloadType].self, queryParams: params, completionHandler: completionHandler)
    }
    
    // MARK: Utility
    
    func disablePullToRefresh() {
        isRefreshDisabled = true
        refreshControl?.endRefreshing()
        refreshControl = nil
    }
}

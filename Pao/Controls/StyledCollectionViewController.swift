//
//  StyledCollectionViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 4/16/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import CCBottomRefreshControl
import NVActivityIndicatorView

class StyledCollectionViewController: UICollectionViewController {
    
    var currentCellIndexPath: IndexPath? {
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = collectionView?.indexPathForItem(at: visiblePoint)
        return visibleIndexPath
    }
    
    var currentCellIndex: Int? {
        return currentCellIndexPath?.item
    }
    
    let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40), type: .circleStrokeSpin, color: .white, padding: 0)
    
    var emptyBackgorundView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.applyStyle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView?.backgroundView?.frame = collectionView!.bounds
        activityIndicator.center = collectionView!.center
        emptyBackgorundView?.center = collectionView!.center
    }
    
    func applyStyle() {
        collectionView?.backgroundColor = .clear
    }
    
    func setupBackgroundView() {
        let backgroundView = UIView()
        collectionView?.backgroundView = backgroundView
        backgroundView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func setupBottomRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        collectionView?.bottomRefreshControl = refreshControl
    }
    
    func setupEmptyBackgroundView() {
        if let emptyBackgorundView = emptyBackgorundView {
            collectionView?.backgroundView = emptyBackgorundView
        }
    }
}

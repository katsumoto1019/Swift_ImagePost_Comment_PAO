//
//  LocationSpotCollectionViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 12/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload

class LocationSpotCollectionViewController: SpotCollectionViewController {
    
    var delegate: SpotCollectionViewCellDelegate?
    
    override func viewDidLoad() {        
        super.viewDidLoad()
        
        isHorizontalPullToRefreshConfigured = true       
        
        disablePullToRefresh()
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let delegate = delegate {
            (cell as? SpotCollectionViewCell)?.delegate  = delegate
        }
    }
    
    func reloadingView() {
        self.collectionView.reloadData()
        if collection.count <= 0 {
            centerSpinnerView?.startAnimating()
        }
    }
}


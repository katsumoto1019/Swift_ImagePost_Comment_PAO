//
//  SpotsMapCollectionCollectionViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 08/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Firebase
import Payload

class MiniSpotCollectionViewController: CollectionViewController<MiniSpotCollectionViewCell> {
    var isRefreshing = false;
    
    let refreshOffset: CGFloat = -15;
    var spotDelegate: SpotCollectionViewCellDelegate? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        disablePullToRefresh();
        collectionView?.showsHorizontalScrollIndicator = false;
        
        self.view.backgroundColor = UIColor.clear;
        self.collectionView?.backgroundColor = UIColor.clear;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        let flowLayout = UICollectionViewFlowLayout();
        flowLayout.itemSize.width = UIScreen.main.bounds.width - 56;
        flowLayout.itemSize.height = self.view.bounds.height;
        flowLayout.scrollDirection = .horizontal;
        self.collectionView?.collectionViewLayout =  flowLayout;
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! MiniSpotCollectionViewCell).delegate = spotDelegate;
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name:.carouselSwipe, object: nil);
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.xPosition < refreshOffset) {
            if (isRefreshing) { return; }
            isRefreshing = true;
            //            delegate?.refresh();
        } else if (isRefreshing) {
            isRefreshing = false;
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collection[safe: indexPath.row] != nil {
            AmplitudeAnalytics.logEvent(.mapCarouselSpot, group: .search)
            
            spotDelegate?.didSelect(indexPath: indexPath);
        }
    }
}

extension MiniSpotCollectionViewController: SpotsProtocol {
    func scrollTo(indexPath: IndexPath?, animated: Bool = false) {
        if let indexPath = indexPath, collectionView?.numberOfItems(inSection: indexPath.section) ?? 0 > indexPath.item {
            collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated);
        }
    }
    
    func reloadData() {
        collectionView?.reloadData();
        
        // HACK: This fixes cell size issue after reloadData();
        collectionView?.performBatchUpdates({
            
        }, completion: { (result) in
            self.collectionView?.reloadData();
        })
    }
    
    func endRefreshing() {
        collectionView?.refreshControl?.endRefreshing();
    }
    
    func insertItems(at indexPaths: [IndexPath]) {
        collectionView?.insertItems(at: indexPaths);
        //        activityIndicator.stopAnimating();
    }
    
    func deleteItems(at indexPaths: [IndexPath]) {
        collectionView?.deleteItems(at: indexPaths);
    }
    
    func crashFix() {
        // CollectionView bug.
        // https://stackoverflow.com/a/46751421
        collectionView?.numberOfItems(inSection: 0);
    }
}

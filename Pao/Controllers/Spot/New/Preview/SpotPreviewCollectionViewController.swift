//
//  SpotCollectionViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 3/1/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Firebase
import Photos
import Payload


// TODO: Try inheriting from SpotCollectionViewController, simplify code.
class SpotPreviewCollectionViewController: SpotCollectionViewController {
    
    var phAssets = [PHAsset]();
    var spots = [Spot]();
    
    var cropDataList = [PHAsset:CropData]()
    
    var isLoaded = false;
    
    init() {
        super.init(collection: PayloadCollection<Spot>());
        collection.courier = getPayloads;
    }
    
    convenience init(spot: Spot, phAssets: [PHAsset],cropDataList: [PHAsset:CropData]) {
        self.init();
        
        self.spots = [spot];
        self.phAssets = phAssets;
        self.cropDataList = cropDataList;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .clear;
        hidesBottomBarWhenPushed = true;
        //registerCells();
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        if isLoaded {
            return;
        }
        isLoaded = true;
        
        view.layoutIfNeeded();
        
        self.collectionView?.reloadData();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func getPayloads(completionHandler: @escaping ([Spot]?) -> Void) -> PayloadTask? {
        self.collection.removeAll();
        completionHandler(spots);
        return nil;
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath);
        
        guard  let cell = cell as? SpotCollectionViewCell else {return;}
        
//        cell.actionContainerStackView.isUserInteractionEnabled = false
//        cell.actionContainerViewHeightConstraint.constant = 0
        
        if phAssets.count > 0 {
            cell.set(spot: spots.first!, phAssets: phAssets, cropDataList: cropDataList);
        }
    }
}

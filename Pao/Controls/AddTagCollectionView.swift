//
//  AddTagCollectionView.swift
//  Pao
//
//  Created by Exelia Technologies on 06/09/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import UIKit

class AddTagCollectionView: TagCollectionView {
    var plusButtonTouchedInside: (() -> Void)?;
    var isCurrentUser = true;
    
    override func registerCells() {
        super.registerCells();
        register(AddTagCollectionViewCell.self);
    }
}

extension AddTagCollectionView {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isCurrentUser ? (1 + tags.count) : tags.count;
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (isCurrentUser){
            if (indexPath.item == 0) {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddTagCollectionViewCell.reuseIdentifier, for: indexPath) as! AddTagCollectionViewCell;
                cell.set(plusButtonTouchedInside: plusButtonTouchedInside);
                return cell;
            }
            var indPath = indexPath;
            indPath.item = indexPath.item - 1;
            return super.collectionView(collectionView, cellForItemAt: indPath);
        }
        
        return super.collectionView(collectionView, cellForItemAt: indexPath);
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (isCurrentUser){
            if (indexPath.item == 0) {
                return CGSize.init(width: 40, height: 30);
            }
            var indPath = indexPath;
            indPath.row = indexPath.row - 1;
            return super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indPath);
        }
        
        return super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath);
    }
}

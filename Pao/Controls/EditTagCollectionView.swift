//
//  EditTagCollectionView.swift
//  Pao
//
//  Created by Exelia Technologies on 07/09/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import UIKit

class EditTagCollectionView: TagCollectionView {
    override func registerCells() {
        register(EditTagCollectionViewCell.self);
    }
}

extension EditTagCollectionView {
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditTagCollectionViewCell.reuseIdentifier, for: indexPath) as! EditTagCollectionViewCell;
        cell.set(tag: tags[indexPath.item] as! String, delete: { (tag) in self.remove(tag: tag); });
        return cell;
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard indexPath.row < tags.count else {
            return CGSize.init(width: 80, height: 34);
        }
        var size = super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath);
        size.width += 35; // 35: width of cross button
        return size;
    }
}

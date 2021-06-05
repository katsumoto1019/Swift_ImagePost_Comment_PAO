//
//  ImageCollectionViewController+reset.swift
//  Pao
//
//  Created by kant on 19.04.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit

extension ImageCollectionViewController {
    func reset() {
        if (collectionView?.indexPathsForVisibleItems[safe: 0]?.item ?? 0 > 0) {
            self.collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionView.ScrollPosition.top, animated: false)
        }
        self.pageControl.currentPage = 0
    }
}

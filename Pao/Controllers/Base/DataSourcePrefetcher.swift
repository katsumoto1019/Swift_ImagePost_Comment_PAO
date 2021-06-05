//
//  DataSourcePrefetcher.swift
//  Pao
//
//  Created by Parveen Khatkar on 26/10/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Kingfisher

class DataSourcePrefetcher: NSObject, UICollectionViewDataSourcePrefetching {
    var kingfisherTasks = [Int: DownloadTask]();
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        for indexPath in indexPaths {
//            let document = boardDocuments[indexPath.row];
//            let board = try! document.convert(Board.self);
//            if let url = board.spots?.first?.value.media?.first?.value.url {
//                let servingUrl = url.imageServingUrl(cropSize: Int(cellWidth * UIScreen.main.scale));
//                kingfisherTasks[indexPath.row] = KingfisherManager.shared.retrieveImage(with: servingUrl, options: nil, progressBlock: nil, completionHandler: nil);
//            }
//        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            kingfisherTasks[indexPath.row]?.cancel();
        }
    }
}

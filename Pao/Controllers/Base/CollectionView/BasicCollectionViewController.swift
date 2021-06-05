//
//  BasicCollectionViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/7/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class BasicCollectionViewController: StyledCollectionViewController {
    var cellsPerRow: Int { return 3; }
    var cellSpacing: CGFloat {return 3; }
    var cellWidth: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // TODO: Refactor this later to understand best way to update size on viewDidLayout
        setupCellSize();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        setupCellSize();
    }
    
    private func setupCellSize() {
        let viewWidth = view.frame.size.width;
        cellWidth = (viewWidth - cellSpacing * CGFloat(cellsPerRow - 1)) / CGFloat(cellsPerRow);
        collectionViewLayout.invalidateLayout();
    }
}

extension BasicCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellWidth);
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing;
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing;
    }
}

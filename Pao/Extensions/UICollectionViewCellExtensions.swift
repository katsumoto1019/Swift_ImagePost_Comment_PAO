//
//  UICollectionViewCellExtensions.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/7/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionViewCell {
    static var reuseIdentifier: String
    {
        let className = String(describing: self);
        return className;
    }
}

extension UICollectionView {
    func register(_ cellClass: UICollectionViewCell.Type) {
        let nib = UINib(nibName: cellClass.reuseIdentifier, bundle: nil);
        self.register(nib, forCellWithReuseIdentifier: cellClass.reuseIdentifier);
    }
}

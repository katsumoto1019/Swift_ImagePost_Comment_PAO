//
//  UITableViewExtensions.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/15/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

extension UITableViewCell {
    static var reuseIdentifier: String
    {
        let className = String(describing: self);
        return className;
    }
}

extension UITableView {
    func register(_ cellClass: UITableViewCell.Type) {
        let nib = UINib(nibName: cellClass.reuseIdentifier, bundle: nil);
        self.register(nib, forCellReuseIdentifier: cellClass.reuseIdentifier);
    }
    
    func indexPathExists(indexPath:IndexPath) -> Bool {
        if indexPath.section >= self.numberOfSections {
            return false
        }
        if indexPath.row >= self.numberOfRows(inSection: indexPath.section) {
            return false
        }
        return true
    }
}

//
//  SpotsDelegate.swift
//  Pao
//
//  Created by Parveen Khatkar on 4/13/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation

protocol SpotsProtocol {
    func scrollTo(indexPath: IndexPath?, animated: Bool);
    func reloadData();
    func endRefreshing();
    func insertItems(at indexPath: [IndexPath]);
    func deleteItems(at indexPath: [IndexPath]);
    func crashFix();
}

extension SpotsProtocol {
    func crashFix() { 
    }
}

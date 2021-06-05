//
//  SpotTableViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 3/14/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload

class SpotTableViewController: TableViewController<SpotTableViewCell> {
    
    var showUser = false;
    var showFavorites = false;
    
    // Fix Me - Used for TopSpotViewControlelr. It should not be declared explicitly
    var delegate: SpotCollectionViewCellDelegate?
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let parent = parent as? SpotCollectionViewCellDelegate {
            parent.didSelect(indexPath: indexPath);
        }
        // Fix Me - Used for Top SPot. It should be used as above block
        delegate?.didSelect(indexPath: indexPath);
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath);
        
        if let cell = cell as? SpotTableViewCell {
            if self.delegate != nil {
                cell.delegate = self.delegate;
            }else if let parent = parent as? SpotCollectionViewCellDelegate {
                cell.delegate  = parent;
            }
            if showFavorites {
                cell.setFavorites();
            }
        }
    }
    
    
    /*
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     return true;
     }
     
     override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
     let spot = collection[indexPath.item];
     
     let goAction = UITableViewRowAction(style: .default, title: "Go") { (tableViewRowAction, indexPath) in
     //            self.dataSource.showGo(spot: spot);
     self.delegate?.showGo(spot: spot);
     }
     
     let editAction = UITableViewRowAction(style: .default, title: "Edit") { (tableViewRowAction, indexPath) in
     //            self.dataSource.showEditOptions(spot: spot);
     self.delegate?.edit(spot: spot);
     }
     
     let saveAction = UITableViewRowAction(style: .default, title: "Save") { (tableViewRowAction, indexPath) in
     //            self.dataSource.save(spot: spot);
     }
     
     goAction.backgroundColor = UIColor.darkGray;
     editAction.backgroundColor = UIColor.gray;
     saveAction.backgroundColor = UIColor.gray;
     
     let isUserSpot = collection[indexPath.item].user?.id == DataContext.userUID;
     
     return [isUserSpot ? editAction : saveAction, goAction];
     }
     */
    override func willSet(cell: SpotTableViewCell) {
        super.willSet(cell: cell);
        
        cell.userImageView.isHidden = !showUser;
    }
}

extension SpotTableViewController: SpotsProtocol {
    func scrollTo(indexPath: IndexPath?, animated: Bool = false) {
        if let indexPath = indexPath, let tableView = tableView, tableView.numberOfRows(inSection: indexPath.section) > indexPath.item, tableView.indexPathExists(indexPath: indexPath) {
            tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.middle, animated: animated);
        }
    }
    
    func reloadData() {
        tableView.reloadData();
    }
    
    func endRefreshing() {
        tableView.refreshControl?.endRefreshing();
    }
    
    func insertItems(at indexPaths: [IndexPath]) {
        tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.automatic);
    }
    
    func deleteItems(at indexPaths: [IndexPath]) {
        tableView.deleteRows(at: indexPaths, with: UITableView.RowAnimation.automatic);
    }
}


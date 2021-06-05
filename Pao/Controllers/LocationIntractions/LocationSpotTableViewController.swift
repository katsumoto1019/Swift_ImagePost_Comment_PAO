//
//  LocationsSpotTableViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 13/12/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit

class LocationSpotTableViewController: SpotTableViewController {
    
    func reloadingView() {
        tableView.reloadData()
        
        guard collection.count == 0, refreshControl?.isRefreshing != true else { return }
        
            refreshControl?.beginRefreshing()
            let contentOffset = CGPoint(x: 0, y: -(refreshControl?.frame.height ?? 0))
            tableView.setContentOffset(contentOffset, animated: true)
        
          if refreshControl == nil || refreshControl?.isRefreshing != true {
              activityIndicatorView?.startAnimating()
          }
    }
}

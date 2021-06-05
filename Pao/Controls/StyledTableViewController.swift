//
//  StyledTableViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 4/26/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class StyledTableViewController: UITableViewController {
    
    var screenName = String.empty
    
    var emptyBackgorundView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.applyStyle();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        FirbaseAnalytics.trackScreen(name: screenName);
    }
    
    func applyStyle() {
        view.backgroundColor = ColorName.background.color
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        tableView?.backgroundView?.frame = tableView!.bounds;
        emptyBackgorundView?.center = tableView!.center;
    }
    
    func setupEmptyBackgroundView() {
        if let emptyBackgorundView = emptyBackgorundView {
            tableView?.backgroundView = emptyBackgorundView;
        }
    }
}

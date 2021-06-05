
//
//  RocketTableViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 24/01/19.
//  Copyright © 2019 Exelia. All rights reserved.
//

import Foundation
import Payload

import NVActivityIndicatorView
import RocketData

class RocketTableViewController<T>: PayloadTableViewController<T>, Searchable where T: UITableViewCell & Consignee, T.PayloadType: PaoModel {
    public var searchString: String? {
        didSet {
            if oldValue == searchString || (oldValue == nil && searchString == "") {return}
            refresh();
        }
    }
    
    var rocketCollection = RocketCollection<T.PayloadType>();
    
    var screenName: String?
    
    override func viewDidLoad() {
        collection = rocketCollection;
        
        if collection.courier == nil {
            collection.courier = getPayloads;
        }
        
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40), type: .circleStrokeSpin, color: ColorName.textGray.color, padding: 8);
        refreshControl = RefreshControl();
        refreshControl?.beginRefreshing();
        
        tableView.backgroundView?.isHidden = true;
        collection.elementsChanged.append {_ in 
            self.tableView.backgroundView?.isHidden = self.collection.count != 0;
        }
        
        collection.loaded.append {_ in
            self.refreshControl?.endRefreshing();
            self.activityIndicatorView?.stopAnimating();
        }
        
        super.viewDidLoad();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        if refreshControl?.isRefreshing == true {
            tableView.backgroundView?.isHidden = true;
        }
    }
    
    func getPayloads(completionHandler: @escaping ([T.PayloadType]?) -> Void) -> PayloadTask? {
        if collection.count > 0, let screenName = screenName, !screenName.isEmpty {
//            FirbaseAnalytics.trackEvent(category: .uiAction, action: .scrollMore, label: screenName);
        }
        
        let params = CollectionParams(skip: collection.count , take: collection.bufferSize, keyword: searchString);
        return App.transporter.get([T.PayloadType].self, queryParams: params, completionHandler: completionHandler);
    }
}

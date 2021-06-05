//
//  TableViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 31/10/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import Payload

import NVActivityIndicatorView

class TableViewController<T>: PayloadTableViewController<T>, Searchable where T: UITableViewCell & Consignee, T.PayloadType: Codable {
    public var searchString: String? {
        didSet {
            if oldValue == searchString || (oldValue == nil && searchString == "") {return}
            refresh();
        }
    }
    var screenName: String?

    override func viewDidLoad() {
        if collection.courier == nil {
            collection.courier = getPayloads;
        }
        
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40), type: .circleStrokeSpin, color: ColorName.textGray.color, padding: 8);
        refreshControl = RefreshControl();
        
        //HACK: followinf code snipt is to hide the double loader, https://stackoverflow.com/questions/19026351/ios-7-uirefreshcontrol-tintcolor-not-working-for-beginrefreshing
        if(self.tableView.contentOffset.y == 0) {
            self.tableView.contentOffset = CGPoint(x: 0, y: -(self.refreshControl?.frame.size.height ?? 0));
        }
        
        refreshControl?.beginRefreshing();
        
        tableView.backgroundView?.isHidden = true;
        collection.elementsChanged.append {_ in 
            self.tableView.backgroundView?.isHidden = self.collection.count != 0;
        }
        
        collection.loaded.append {_ in
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing();
                self.activityIndicatorView?.stopAnimating();
            }
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
        }
        
        let params = CollectionParams(skip: collection.count , take: collection.bufferSize, keyword: searchString);
        return App.transporter.get([T.PayloadType].self, queryParams: params, completionHandler: completionHandler);
    }
}

extension NVActivityIndicatorView: PayloadActivityIndicator {}

public protocol Searchable: class {
    var searchString: String? { get set };
}

extension UITableViewController {
    // MARK: Utility
    public func disablePullToRefresh() {
        refreshControl?.endRefreshing();
        refreshControl = nil;
    }
}

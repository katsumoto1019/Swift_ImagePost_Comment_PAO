//
//  CountriesTableViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 13/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload


class CountriesTableViewController: TableViewController<LocationSearchTableViewCell> {
    
    var userId: String?
    
    init(userId: String) {
        super.init();
        
        self.userId = userId;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func getPayloads(completionHandler: @escaping ([LocationSearchTableViewCell.PayloadType]?) -> Void) -> PayloadTask? {
        let params = UserParams(skip: collection.count, take: collection.bufferSize, userId: userId!);
        return App.transporter.get([LocationSearchTableViewCell.PayloadType].self, for: type(of: self), queryParams: params, completionHandler: completionHandler);
    }
}

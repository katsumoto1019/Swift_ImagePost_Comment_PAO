//
//  YourPeopleSpotsViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 08/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload


class YourPeopleSpotsViewController: TopSpotsViewController {
    
    override init(location: Location) {
        super.init(location: location);
        noResultText = L10n.YourPeopleSpotsViewController.noResultText;
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        spotTableViewController.showUser = true;
    }
    
    override func getPayloads(completionHandler: @escaping ([Spot]?) -> Void) -> PayloadTask? {
        if locationViewport == nil {
            return nil
        }
        if let type = location.type, !mapReloading {
            let params = LocationSpotsParams(skip: mapReloading ? 0 : collection.count, take: collection.bufferSize, long: location.coordinate!.longitude!, lat: location.coordinate!.latitude!, placeId: nil, following: false, radius: Int(searchRadius * 1.5), categories: categories,type: type, name: location.name, recent: true)
                   return App.transporter.get([Spot].self, queryParams: params, completionHandler: completionHandler);
               }
        
        let params = LocationSpotsParams(skip: mapReloading ? 0 : collection.count, take: collection.bufferSize, long: location.coordinate!.longitude!, lat: location.coordinate!.latitude!, placeId: nil, following: false, radius: Int(searchRadius * 1.5), categories: categories, name: location.name, recent: true);
            return App.transporter.get([Spot].self, queryParams: params, completionHandler: completionHandler);
    }
}

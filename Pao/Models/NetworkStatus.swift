//
//  NetworkStatus.swift
//  Pao
//
//  Created by Waseem Ahmed on 04/06/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import Foundation

class NetworkStatus: PaoModel {
    
    static let uniqueId = "uniqueIdentifier"
    
    var id: String? = uniqueId
    var available: Bool?
    
    init(status: Bool) {
        self.available = status;
        self.id = NetworkStatus.uniqueId
    }
}

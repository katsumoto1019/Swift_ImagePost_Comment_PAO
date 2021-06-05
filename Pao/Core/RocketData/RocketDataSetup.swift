//
//  RocketDataSetup.swift
//  Pao
//
//  Created by Parveen Khatkar on 23/01/19.
//  Copyright © 2019 Exelia. All rights reserved.
//


import Foundation
import RocketData

/**
 This file contains some useful setup you could do.
 See https://linkedin.github.io/RocketData/pages/040_setup.html for more information.
 */

extension DataModelManager {
    /**
     Singleton accessor for DataModelManager. See https://plivesey.github.io/RocketData/pages/040_setup.html
     */
    static var sharedInstance = DataModelManager(cacheDelegate: RocketDataCacheDelegate())
    
    static func resetSharedInstance() {
        DataModelManager.sharedInstance = DataModelManager(cacheDelegate: RocketDataCacheDelegate());
    }
}

extension DataProvider {
    convenience init() {
        self.init(dataModelManager: DataModelManager.sharedInstance)
    }
}

extension CollectionDataProvider {
    convenience init() {
        self.init(dataModelManager: DataModelManager.sharedInstance)
    }
}

extension DataProvider {
    func setCacheKey(_ key: String) {
        self.fetchDataFromCache(withCacheKey: key) { (spot, error) in
        }
    }
}

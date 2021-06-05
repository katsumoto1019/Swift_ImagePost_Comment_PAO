//
//  RocketDataCacheDelegate.swift
//  Pao
//
//  Created by Parveen Khatkar on 24/01/19.
//  Copyright © 2019 Exelia. All rights reserved.
//

import Foundation
import RocketData
import PINCache

class RocketDataCacheDelegate: CacheDelegate {

    fileprivate let cache = PINCache(name: "SampleAppCache");
    var data = [String: SimpleModel]();
    var collectionData = [String: [String]]();

    func modelForKey<T>(_ cacheKey: String?, context: Any?, completion: @escaping (T?, NSError?) -> ()) where T : SimpleModel {
        if let cacheKey = cacheKey, let model = data[cacheKey] {
            completion(model as? T, nil);
            return;
        }

        completion(nil, nil);
    }

    func setModel(_ model: SimpleModel, forKey cacheKey: String, context: Any?) {
        data[cacheKey] = model;
    }

    func collectionForKey<T>(_ cacheKey: String?, context: Any?, completion: @escaping ([T]?, NSError?) -> ()) where T : SimpleModel {
        if let cacheKey = cacheKey, let keyCollection = collectionData[cacheKey] {
            let collection = keyCollection.compactMap({data[$0]}) as? [T];
            completion(collection, nil);
            return;
        }

        completion(nil, nil);
    }

    func setCollection(_ collection: [SimpleModel], forKey cacheKey: String, context: Any?) {
        collection.forEach({
            setModel($0, forKey: $0.modelIdentifier!, context: nil)
        });
        
        collectionData[cacheKey] = collection.map({$0.modelIdentifier!});
    }

    func deleteModel(_ model: SimpleModel, forKey cacheKey: String?, context: Any?) {
        if let cacheKey = cacheKey {
            data.removeValue(forKey: cacheKey);
        }
    }
}

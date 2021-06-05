//
//  RocketCollection.swift
//  Pao
//
//  Created by Parveen Khatkar on 24/01/19.
//  Copyright © 2019 Exelia. All rights reserved.
//

import Foundation
import Payload
import RocketData

public class RocketCollection<T>: PayloadCollection<T>, CollectionDataProviderDelegate where T: SimpleModel {
    
    var cacheKey: String? {
        didSet {
            dataProvider.setData([], cacheKey: cacheKey)
        }
    }
    private var dataProvider = CollectionDataProvider<T>()
    
    public override var count: Int {
        return dataProvider.count
    }
    
    public override subscript(index: Index) -> T {
        get {
            return dataProvider[index]
        }
        set(newValue) {
        }
    }
    
    required init() {
        super.init()
        dataProvider.delegate = self
    }
    
    public override func index(after i: DataCollectionType.Index) -> DataCollectionType.Index {
        return dataProvider.data.index(after: i)
    }

    public override func append(contentsOf newElements: [Element]) {
        if dataProvider.count > 0 {
            dataProvider.append(newElements)
        } else {
            dataProvider.setData(newElements, cacheKey: dataProvider.cacheKey)
        }
    }
    
    public override func remove(at position: DataCollectionType.Index) -> T {
        let element = dataProvider[position]
        dataProvider.remove(at: position)
        return element
    }
    
    public override func removeAll(keepingCapacity keepCapacity: Bool = false) {
        dataProvider.setData([], cacheKey: dataProvider.cacheKey)
    }
    
    public override func insert(_ newElement: T, at i: DataCollectionType.Index) {
        dataProvider.insert([newElement], at: i)
    }
    
    public func firstIndex(where predicate: (T) throws -> Bool) rethrows -> PayloadCollection<T>.DataCollectionType.Index? {
        return try dataProvider.data.firstIndex(where: predicate)
    }
    
    public func collectionDataProviderHasUpdatedData<T>(_ dataProvider: CollectionDataProvider<T>, collectionChanges: CollectionChange, context: Any?) where T : SimpleModel {
        switch collectionChanges {
        case .changes(let changes):
            let collectionChanges = changes.map({
                switch $0 {
                case .delete(let index):
                    print("Delete: ", index)
                    return ElementChange.delete(index: index)
                case .insert(let index):
                    print("Insert: ", index)
                    return ElementChange.insert(index: index)
                case .update(let index):
                    print("Update: ", index)
                    return ElementChange.update(index: index)
                }
            }) as [ElementChange]
            print("CacheKey: \(String(describing: cacheKey))")
            elementsChanged.forEach{ $0(collectionChanges) }
            break
        default:
            elementsChanged.forEach{ $0(nil) }
        }
    }
}

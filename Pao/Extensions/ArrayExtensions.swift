//
//  ArrayExtensions.swift
//  Pao
//
//  Created by Exelia Technologies on 25/07/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation

extension Array {
    
    // Func that inserts a new element (1). Somewhere in the middle if the supplied condition is satisfied,
    // (2). At the end if the condition was never satisfied. Returns the index at which the object was inserted.
    mutating func insert(_ newElement: Element,_ shouldInsert: (_ elementLeft: Element?,_ elementRight: Element) -> Bool) -> Int {
        for elementIndex in 0..<count {
            let elementLeft = (elementIndex - 1 != -1) ? self[elementIndex - 1] : nil;
            let elementRight = self[elementIndex];
            
            if shouldInsert(elementLeft, elementRight) {
                insert(newElement, at: elementIndex);
                return elementIndex;
            }
        }
        
        append(newElement);
        return count - 1;
    }
    
    func duplicate<T: Codable>(type: T.Type) -> [T]? {
        let jsonEncoder = JSONEncoder()
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dataDecodingStrategy = .deferredToData
        
        guard let jsonData = try? jsonEncoder.encode(self as! Array<T>) else {
            return nil
        }
        
        return try? jsonDecoder.decode([T].self, from: jsonData)
    }
}

//
//  CollectionExtensions.swift
//  Pao
//
//  Created by Parveen Khatkar on 4/11/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation

extension MutableCollection {
    
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

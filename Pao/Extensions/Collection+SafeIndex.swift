//
//  Collection+SafeIndex.swift
//  Pao
//
//  Created by kant on 28.04.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

extension Collection {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

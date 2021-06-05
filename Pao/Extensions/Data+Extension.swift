//
//  Data+Extension.swift
//  Pao
//
//  Created by Rybolovleva Olga Viktorovna on 28.07.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import Foundation

extension Data {
    mutating func append(string: String) {
        if let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true) {
            append(data)
        }
    }
}

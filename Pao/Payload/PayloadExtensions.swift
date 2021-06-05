//
//  PayloadExtensions.swift
//  Pao
//
//  Created by Parveen Khatkar on 31/10/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Payload


extension URLSessionTask: PayloadTask {}

public struct CollectionParams: QueryParams {
    var skip: Int
    var take: Int
    var keyword: String?
}

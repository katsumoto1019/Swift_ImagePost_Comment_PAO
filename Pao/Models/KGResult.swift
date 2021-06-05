//
//  KGResult.swift
//  Pao
//
//  Created by Parveen Khatkar on 23/07/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation

class KGResult: Codable {
    var itemListElement: [KGItem]?
}

class KGItem: Codable{
    var result: KGItemResult?
}

class KGItemResult: Codable {
    var detailedDescription: KGDetailedDescription?
}

class KGDetailedDescription: Codable {
    var articleBody: String?
}

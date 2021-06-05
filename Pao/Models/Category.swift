//
//  Category.swift
//  Pao
//
//  Created by Parveen Khatkar on 4/24/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation

class Category: Codable {
    var firebaseId: String?
    var name: String?
    var subCategories: [SubCategory]?
    
    //local use Only
    var selected: Bool?
    
}




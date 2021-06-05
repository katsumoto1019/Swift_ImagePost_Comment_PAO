//
//  TagKeyword.swift
//  Pao
//
//  Created by Waseem Ahmed on 16/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//


/// Class used for taggable data keyword, extracted from input comment textview.
class TagKeyword {
    var keyword: String?
    var indexOffset: Int?
    
    init(keyword: String, indexOffset: Int) {
        self.keyword = keyword
        self.indexOffset = indexOffset
    }
}

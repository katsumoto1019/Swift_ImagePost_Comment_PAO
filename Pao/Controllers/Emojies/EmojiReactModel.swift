//
//  EmojiReactModel.swift
//  Pao
//
//  Created by Rybolovleva Olga Viktorovna on 13.08.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import Foundation

struct EmojiReactModel: Codable {
    var spotId: String
    var emojiId: Int
    
    init(spotId: String, emojiId: Int) {
        self.spotId = spotId
        self.emojiId = emojiId
    }
}

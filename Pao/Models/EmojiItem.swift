//
//  EmojiItem.swift
//  Pao
//
//  Created by Rybolovleva Olga Viktorovna on 05.09.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

class EmojiItem: Codable {

    var count: Int?
    var reactedBy: [User]?

    init() {
        self.count = 0
        self.reactedBy = []
    }

    func setReaction(id: String, selected: Bool) {
        guard let count = count, var reactedIds = reactedBy else {
            return
        }
        self.count = selected ? count + 1 : count - 1

        if selected, !reactedIds.contains(where: { $0.id == id }) {
            reactedIds.append(DataContext.cache.user)
        } else {
            reactedIds.removeAll(where: { $0.id == id })
        }
        self.reactedBy = reactedIds
    }
}

//
//  SpotRef.swift
//  Pao
//
//  Created by Parveen Khatkar on 4/24/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation

class SpotRef: Codable {
    var id: String?
    var timestamp: Date?
    var media: SpotMediaItem?
    var location: Location?
}

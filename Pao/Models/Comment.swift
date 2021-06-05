//
//  Comment.swift
//  Pao
//
//  Created by Parveen Khatkar on 11/10/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import Payload


class Comment: Codable {
    var id: String?
    var spotId: String?
    var message: String?
    var timestamp: Date?
    var user: User?
    var validUsernames: [String]?
    
    init(spotId: String, message: String) {
        self.spotId = spotId;
        self.message = message;
    }

    init(id:String?, spotId: String, message: String,user: User?, timestamp: Date?) {
        self.id = id;
        self.spotId = spotId;
        self.message = message;
        self.user = user;
        self.timestamp = timestamp;
    }
}

struct CommentsVars: PathVars {
    public var spotId: String;
    
    var vars: [Any] {
        return [spotId];
    }
}

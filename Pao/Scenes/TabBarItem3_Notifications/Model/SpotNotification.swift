//
//  SpotNotification.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/27/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation

class PlainNotification: Codable {
    var title: String?
}

class ChecklistNotification: Codable {
    var title: String?
    var isDone: Bool?
}

class SpotNotification: Codable {
    var spot: SpotRef?
    var user: SpotUser?
    var title: String?
    var description: String?
}

class LocationNotification: Codable {
    var spot: Spot?
    var user: SpotUser?
    var title: String?
    var description: String?
}

enum PushNotificationType: Int, Codable {
    case all = -1
    
    case plain = 0
    case save = 1
    case checkList = 2
    case comment = 3
    case follow = 4
    case followRequest = 5
    case verify = 6
    case spotcomment = 7
    case followRequestAccepted = 8
    case reactHeartEyes = 10
    case reactGem = 11
    case reactDroolingFace = 12
    case reactClap = 13
    case reactRoundPushpin = 14
    case location = 15
    
    case notLocation = -15
}

class PushNotification<T>: Codable where T: Codable {
    var id: String?
    var timestamp: Date?
    var type: PushNotificationType!
    var payload: T?
}

public struct NotificationParams: QueryParams {
    var skip: Int
    var take: Int
    var type: PushNotificationType
}

class ChecklistItem: Codable {
    init(id: Int) {
        self.id = id;
    }
    var id: Int?
}

enum ChecklistItemType: Int, Codable {
    case fiveSwipe = 0  //"Swipe through 5 spots on the World Feed",
    case follow = 1  //"Add someone to Your People",
    case upload = 2 // "Upload one of your favourite spots"
}

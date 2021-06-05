//
//  User.swift
//  Pao
//
//  Created by Parveen Khatkar on 4/24/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import Payload

import RocketData

class MyPeopleUser: PaoModel {
    var id: String?
    var name: String?
    var username: String?
    var coverImage: UserImage?
    var profileImage: UserImage?
    
    init(id: String? = nil) {
        self.id = id
    }

    init(user: User) {
        self.id = user.id
        self.name = user.name
        self.username = user.username
        self.coverImage = user.coverImage
        self.profileImage = user.profileImage
    }
}

class SpotUser: Codable {
    
    var id: String?
    var name: String?
    var username: String?
    var coverImage: UserImage?
    var profileImage: UserImage?
    
	init(id: String) {
		self.id = id
	}
}

// Users public data
class User: PaoModel {
    
    var id: String?
    var email: String?
    var name: String?
    var username: String?
    var bio: String?
    
    var coverImage: UserImage?
    var profileImage: UserImage?
    
    var followersCount: Int?
    var myPeopleCount: Int?
    
    var myPeople: [MyPeopleUser]?
    var followRequestsCount: Int?
    var citiesCount: Int?
    var countriesCount: Int?
    
    var profile: UserProfile?
    
    var savedSpotsCount: Int?
    var uploadedSpotsCount: Int?
    var commentsCount: Int?
    
    var isPrivate: Bool? {
        return settings?.isPublic == false
    }
    
    var isFollowedByViewer: Bool? = false
    var hasLocationNotifications: Bool? = false
    
    var settings: UserSettings?
    var createdOn: String?
    
    var permission: Permissions?
    
    var line1: String?
    var line2: String?
    var line3: String?
    
    func isEqual(to model: Model) -> Bool {
        return uploadedSpotsCount == nil && savedSpotsCount == nil;
    }

    init(id: String? = nil) {
		self.id = id
	}

	init(user: SpotUser) {
		self.id = user.id
		self.name = user.name
		self.username = user.username
		self.coverImage = user.coverImage
		self.profileImage = user.profileImage
	}
}

extension User {
    func duplicate() -> User? {
        let jsonEncoder = JSONEncoder()
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dataDecodingStrategy = .deferredToData;
        
        guard let jsonData = try? jsonEncoder.encode(self) else {
            return nil;
        }
        
        return try? jsonDecoder.decode(User.self, from: jsonData);
    }
}

class UserImage: Codable {
    var url: URL?
    var placeholderColor: String?
    var id: String?
}

class UserProfile: Codable {
    var hometown: String?
    var currentLocation: String?
    var nextStop: String?
    var interests: [String]?
}

class UserSettings: Codable {
    var isPublic: Bool? = true
    var isNotificationEnabled: Bool? = true
    
    init() {}
    
    convenience init(isPublic: Bool?, isNotificationEnabled: Bool?) {
        self.init();
        
        self.isPublic = isPublic;
        self.isNotificationEnabled = isNotificationEnabled;
    }
}

class Permissions: Codable {
    var personalData: Bool? = false
    var newsletter: Bool? = false
    
    init() {}
    
    convenience init(personalData: Bool?, newsletter: Bool?) {
        self.init();
        
        self.personalData = personalData;
        self.newsletter = newsletter;
    }
}

struct UserGMTParams: QueryParams {
    var gmt: String
}

struct UserParams: QueryParams {
    var skip: Int
    var take: Int
    var userId: String
}

struct UsersParams: QueryParams {
    var skip: Int
    var take: Int
    var keyword: String?
}

struct UserVars: PathVars {
    public var userId: String;
    
    var vars: [Any] {
        return [userId];
    }
}

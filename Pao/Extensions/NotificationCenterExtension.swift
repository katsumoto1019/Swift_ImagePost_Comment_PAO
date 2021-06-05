//
//  NotificationCenterExtension.swift
//  Pao
//
//  Created by Waseem Ahmed on 07/12/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

extension NotificationCenter  {

    static func spotSaved() {
        NotificationCenter.default.post(name: .saveBoardUpdate, object: nil);
        
        //HACK: Refreshes profile to update counter.
        DataContext.cache.loadUser();
    }
    
    static func followingPeople() {
        NotificationCenter.default.post(name: .followingPeopleUpdate, object: nil);
    }
    
    static func followRequest(indexPath: IndexPath) {
        let index:[String: IndexPath] = ["indexPath": indexPath]
        NotificationCenter.default.post(name: .followRequestUpdate, object: nil, userInfo: index);
    }
}


extension Notification.Name {
    static let carouselSwipe = Notification.Name("performedSwipeInCarousel")
    static let profileImageUpdate = Notification.Name("profileImageUpdate")
    static let coverImageUpdate = Notification.Name("coverImageUpdate")
    static let statusBarFrameUpdate = Notification.Name("statusBarFrameUpdate")
    
    static let saveBoardUpdate = Notification.Name("saveBoardUpdate")
    static let spotUpdate = Notification.Name("spotUpdate")

    static let followingPeopleUpdate = Notification.Name("followingPeopleUpdate")
    static let followRequestUpdate = Notification.Name("followRequestUpdate")

    static let initialDataLoaded = Notification.Name("initialDataLoaded")
    static let tokenLoaded = Notification.Name("tokenLoaded")
    static let userUpdate = Notification.Name("userUpdate")
    static let userUpdateError = Notification.Name("userFetchError")
    
    static let newNotifications = Notification.Name("newNotifications")
    static let newSpotUploaded = Notification.Name("newSpotUploaded")
    static let newSpotUplodingProgress = Notification.Name("newSpotUplodingProgress")
    
    static let tagRemoved = Notification.Name("tagRemoved")
    
    static let networkStuatusChanged = Notification.Name("networkStuatusChanged")

    static let playlistUpdateNotification = Notification.Name("playlistUpdateNotification")
}

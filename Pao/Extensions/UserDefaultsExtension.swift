//
//  UserDefaultsExtension.swift
//  Pao
//
//  Created by Waseem Ahmed on 26/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

extension UserDefaults {
    class func bool(key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    class func integer(key: String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    
    class func save(value: Any, forKey key: String) {
        UserDefaults.standard.set(value, forKey:key)
        UserDefaults.standard.synchronize()
    }

    class func getVersionSession() -> Int {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return UserDefaults.integer(key: "v\(appVersion)")
        } else {
            return 0
        }
    }
    
    class func reset() {
        UserDefaults.save(value: false, forKey: UserDefaultsKey.doneTutorialForSpots.rawValue)
        UserDefaults.save(value: false, forKey: UserDefaultsKey.doneTutorialForTabs.rawValue)
        UserDefaults.save(value: true, forKey: UserDefaultsKey.isNewUser.rawValue)
        UserDefaults.save(value: false, forKey: UserDefaultsKey.isSignedIn.rawValue)
        UserDefaults.save(value: true, forKey: UserDefaultsKey.showWorldTab.rawValue)
        UserDefaults.save(value: false, forKey: UserDefaultsKey.isSecondSession.rawValue)
        // the below must never be reset, because the sign in process resets all values after sign in
        // although i disagree with the reset post sign in, for now its safer to just keep isFirstRun as it was
        // which is now to change it when reset.
        //UserDefaults.save(value: false, forKey: UserDefaultsKey.isFirstRun.rawValue)
        UserDefaults.save(value: 0, forKey: UserDefaultsKey.curatedFeedIndex.rawValue)
        UserDefaults.save(value: 0, forKey: UserDefaultsKey.addEmojiCount.rawValue)
        UserDefaults.save(value: false, forKey: UserDefaultsKey.fiveSwipe.rawValue)
        UserDefaults.save(value: false, forKey: UserDefaultsKey.firstFollow.rawValue)
        UserDefaults.save(value: false, forKey: UserDefaultsKey.firstUpload.rawValue)
        UserDefaults.save(value: false, forKey: UserDefaultsKey.shouldShowPermission.rawValue)
        UserDefaults.save(value: false, forKey: UserDefaultsKey.sharabilityFeatureAlreadyPresented.rawValue)
        UserDefaults.save(value: false, forKey: UserDefaultsKey.emojiTipAlreadyPresented.rawValue)
        UserDefaults.save(value: false, forKey: UserDefaultsKey.hasLocationNotifications.rawValue)
        UserDefaults.save(value: "", forKey: UserDefaultsKey.deviceToken.rawValue)
        UserDefaults.save(value: "", forKey: UserDefaultsKey.deviceTokenUser.rawValue)
    }
}

enum UserDefaultsKey: String {
    
    case doneTutorialForSpots = "doneTutorialForSpots"
    case doneTutorialForSpotTip = "doneTutorialForSpotTip"
    case doneTutorialForSpotSaveAction = "doneTutorialForSpotSaveAction"    
    case doneTutorialForTabs = "doneTutorialForTabs"

    case notificationAlertShown = "notifictionAlertShown"
    case notificationAlertShownv2 = "notifictionAlertShownv2"

    case locationAlertAboutScreen = "locationAlertAboutScreen"
    case locationAlertSearchScreen = "locationAlertSearchScreen"
    
    case isNewUser = "isNewUser"
    case isSignedIn = "isSignedIn"
    case showWorldTab = "showWorldTab"
    case isFirstRun = "isFirstRun"
    case isSecondSession = "isSecondSession"
    case isShowPlaylistFeature = "isShowPlaylistFeature"
    case sharabilityFeatureAlreadyPresented = "sharabilityFeatureAlreadyPresented"
    case emojiTipAlreadyPresented = "emojiTipAlreadyPresented"
    
    case deviceToken = "deviceToken"
    case deviceTokenUser = "deviceTokenUser"
    
    case curatedFeedIndex = "curatedFeedIndex"
    case addEmojiCount = "addEmojiCount"
    
    //Push notification checklist for new User
    case fiveSwipe = "firstFiveSwipes"
    case firstFollow = "firstFollow"
    case firstUpload = "firstUpload"
    case shouldShowPermission = "shouldShowPermission"
    case cacheLoaded = "isCacheLoaded"
    case isSpotUploading = "isSpotUploading"
    
    case hasLocationNotifications = "hasLocationNotifications"
    case lastPeopleNotificationDate = "LastPeopleNotificationDate"
    case lastLocationNotificationDate = "LastLocationNotificationDate"

    static var doneTutorialSpotKeys: [UserDefaultsKey] {
        return [.doneTutorialForSpotTip, .doneTutorialForSpotSaveAction]
    }
}

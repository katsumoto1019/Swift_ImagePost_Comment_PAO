//
//  AmplitudeAnalytics.swift
//  Pao
//
//  Created by Waseem Ahmed on 29/01/2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import Foundation
import Amplitude_iOS
import FirebaseAuth

class AmplitudeAnalytics {
    public static func setUserId(userId: String?) {
        //Commented because this is being fired from server through backFill batch api.
        /*  dummySignupEvent() */
        
        Amplitude.instance()?.setUserId(userId)
        
        #if DEBUG
        print("AA UserId:\(userId ?? "nil")")
        #endif
    }
    
    public static func logEvent(_ event: EventName, group: EventGroup? = nil, properties: [String: Any]? = nil) {
        let eventName = group == nil ? event.rawValue : "\(group!.rawValue) - \(event.rawValue)"
        
        if let properties = properties {
            Amplitude.instance()?.logEvent(eventName, withEventProperties: properties)
        } else {
            Amplitude.instance()?.logEvent(eventName)
        }
        
        #if DEBUG
        print("AA eventName:\(eventName), properties: \(String(describing: properties))")
        #endif
    }
    
    public static func dummySignupEvent() {
        //Fire signUp event with registered date as timestamp.
        guard
            let registeredDate = Auth.auth().currentUser?.metadata.creationDate,
            Amplitude.instance()?.userId == nil else { return }
        
        let timestamp = Int64(registeredDate.timeIntervalSince1970 * 1000)
        
        Amplitude.instance()?.logEvent(
            "signUp",
            withEventProperties: nil,
            withGroups: nil,
            withLongLongTimestamp: timestamp,
            outOfSession: false
        )
    }
    
    public static func logOut() {
        Amplitude.instance()?.setUserId(nil)
        Amplitude.instance()?.regenerateDeviceId()
    }
}


//User properties
extension AmplitudeAnalytics {
    public static func setUserProperties(user: User?) {
        guard let user = user else { return }
        
        let identity = AMPIdentify()
        
        identity.set(UserProperty.followers.rawValue, value: NSNumber(value: user.followersCount ?? 0))
        identity.set(UserProperty.followings.rawValue, value: NSNumber(value: user.myPeopleCount ?? 0))
        identity.set(UserProperty.uploads.rawValue, value: NSNumber(value: user.uploadedSpotsCount ?? 0))
        identity.set(UserProperty.cities.rawValue, value: NSNumber(value: user.citiesCount ?? 0))
        identity.set(UserProperty.comments.rawValue, value: NSNumber(value: user.commentsCount ?? 0))
        identity.set(UserProperty.hasProfilePhoto.rawValue, value: NSNumber(booleanLiteral: user.profileImage?.url != nil))
        identity.set(UserProperty.hasBio.rawValue, value:  NSNumber(booleanLiteral: !(user.bio?.isEmpty ?? true)))
        identity.set(UserProperty.saves.rawValue, value:  NSNumber(value: user.savedSpotsCount ?? 0))
        
        Amplitude.instance()?.identify(identity)
        /**
         SignUp date will be set by  'setOnce'
         */
        /**
         
         */
    }
    
    public static func setUserProperty(property: UserProperty, value: NSObject) {
        let identity = AMPIdentify()
        identity.set(property.rawValue, value: value)
        Amplitude.instance()?.identify(identity)
        
        
        #if DEBUG
        print("AA setUserProperty:\(property.rawValue), value: \(String(describing: value))")
        #endif
    }
    
    public static func addUserValue(property: UserProperty, value: Int = 1) {
        let identity = AMPIdentify()
        identity.add(property.rawValue, value:  NSNumber(value: value))
        Amplitude.instance()?.identify(identity)
        
        #if DEBUG
        print("AA addUserValue:\(property.rawValue), value: \(String(describing: value))")
        #endif
    }
}

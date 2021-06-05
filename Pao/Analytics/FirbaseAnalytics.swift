//
//  Analytics.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/14/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import Firebase

class FirbaseAnalytics {
    
    static func setUserId(userId: String?) {
        
        Analytics.setUserID(userId)

        #if DEBUG
        print("FA UserId:\(userId ?? "nil")")
        #endif
    }
    
    static func logEvent(_ event: EventAction, parameters: [String: Any]? = nil) {
        Analytics.logEvent(event.rawValue, parameters: parameters)
        
        #if DEBUG
        print("FA Event : \(event.rawValue), params : \(String(describing: parameters))")
        #endif
    }
    
    static func logEvent(_ event: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(event, parameters: parameters)
        
        #if DEBUG
        print("FA Event : \(event), params : \(String(describing: parameters))")
        #endif
    }
    
    static func trackScreen(name: String, screenClass: String? = nil) {
        guard !name.isEmpty else { return }
        
        var className = screenClass
        
        if
            let names = screenClass?.components(separatedBy: "."),
            names.count > 0,
            let name = names.last {
            className = String(name)
        }
        
        Analytics.setScreenName(name, screenClass: className)
        
        #if DEBUG
        print("FA Screen : \(name)")
        #endif
    }
    
    static func trackScreen(name: ScreenNames, screenClass: String? = nil) {
        
        var className = screenClass
        
        if
            let names = screenClass?.components(separatedBy: "."),
            names.count > 0,
            let name = names.last {
            className = String(name)
        }
        
        Analytics.setScreenName(name.rawValue, screenClass: className)
        
        #if DEBUG
        print("FA Screen : \(name.rawValue)")
        #endif
    }
}

//
//  BundleExtensions.swift
//  Pao
//
//  Created by Parveen Khatkar on 09/06/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation

extension Bundle {
    var googleMapsAPIKey: String {
        return object(forInfoDictionaryKey: "GoogleMapsAPIKey") as! String
    }
    
    var googleAnalytics: String {
        return object(forInfoDictionaryKey: "GoogleAnalytics") as! String
    }
    
    var apiUrl: URL {
        return URL(string: object(forInfoDictionaryKey: "APIUrl") as! String)!;
    }
    
    var shareUrl: URL {
        return URL(string: object(forInfoDictionaryKey: "ShareUrl") as! String)!;
    }
    
    var version: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    var apiVersionCode: Int {
        return Bundle.main.object(forInfoDictionaryKey: "ApiVersionCode") as! Int
    }
    
    var amplitudeApiKey: String {
        return object(forInfoDictionaryKey: "Amplitude_API_KEY") as! String
    }
    
    var bugfenderKey: String? {
        return object(forInfoDictionaryKey: "Bugfender") as? String
    }
}

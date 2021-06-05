//
//  PlaceDetailsResponse.swift
//  Pao
//
//  Created by Exelia Technologies on 09/08/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation

class PlaceDetailsResponse: Decodable {
    var result: PlaceDetailsResult
    var status: String
    var html_attributions: [String]?
    enum CodingKeys: String, CodingKey {
        case result = "result"
        case status = "status"
        case html_attributions = "html_attributions"
    }
}

class PlaceDetailsResult: Decodable {
    var formattedAddress: String?
    var openingHours: PlaceDetailOpeningHours?
    var website: String?
    var formattedPhoneNumber: String?
    var addressComponents: [AddressComponent]?

    enum BusinessStatus: String, EnumDecodable {
        case operational = "OPERATIONAL"
        case closeTemporarily = "CLOSED_TEMPORARILY"
        case closedPermanently = "CLOSED_PERMANENTLY"
        case unkown
    }

    /// working places statuses: https://cloud.google.com/blog/products/maps-platform/temporary-closures-now-available-places-api
    var businessStatus: BusinessStatus?
    
    // QUES: Is there a way to get these string values from PlaceDetail enum? Strings shouldn't be duplicated.
    enum CodingKeys: String, CodingKey {
        case formattedAddress = "formatted_address"
        case openingHours = "opening_hours"
        case website
        case formattedPhoneNumber = "formatted_phone_number"
        case addressComponents = "address_components"
        case businessStatus = "business_status"
    }
}

class AddressComponent: Decodable {
    var longName: String
    var shortName: String
    var types: [String]

    enum CodingKeys: String, CodingKey {
        case longName = "long_name"
        case shortName = "short_name"
        case types = "types"
    }
}

class PlaceDetailOpeningHours: Decodable {
    var openNow: Bool!
    var weekdayText: [String]!
    
    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
        case weekdayText = "weekday_text"
    }
    
    func todayOpenHours() -> String? {
        /*
         1. get day of week
         2. search weekdays with today text
         3. split that by ':'
         4. return second part of splited text
         */
        
        if weekdayText.count == 7 {
            
            //IN Calender(), Sunday is 1 and Saturday is 7. But in the weekdayText, Monday is 1 and Sunday is 7.
            let today = Calendar.current.component(.weekday, from: Date())-1;
            let index = today == 0 ? 6 : today - 1;
            
            let startOfSentence = weekdayText[index].firstIndex(of: ":")!
            let dateString = weekdayText[index][startOfSentence...]
            return  dateString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines);
            
        }
        return nil
    }
}

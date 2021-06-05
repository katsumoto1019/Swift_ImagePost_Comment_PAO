//
//  PlaceDetail.swift
//  Pao
//
//  Created by Exelia Technologies on 09/08/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation

// REF: https://developers.google.com/places/web-service/details
public enum PlaceDetail: String {
    case addressComponent = "address_component";
    case adrAddress = "adr_address";
    case altId = "alt_id";
    case formattedAddress = "formatted_address";
    case geometry = "geometry";
    case icon = "icon";
    case id = "id";
    case name = "name";
    case permanentlyClosed = "permanently_closed";
    case businessStatus = "business_status";
    case photo = "photo";
    case placeId = "place_id";
    case plusCode = "plus_code";
    case scope = "scope";
    case type = "type";
    case url = "url";
    case utcOffset = "utc_offset";
    case vicinty = "vicinity";
    case formattedPhoneNumber = "formatted_phone_number";
    case internationalPhoneNumber = "international_phone_number";
    case openingHours = "opening_hours";
    case website = "website";
    case priceLevel = "price_level";
    case rating = "rating";
    case review = "review";
}

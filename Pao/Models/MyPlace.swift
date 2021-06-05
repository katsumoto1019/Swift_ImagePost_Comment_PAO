//
//  MyPlace.swift
//  Pao
//
//  Created by OmShanti on 23/10/20.
//  Copyright © 2020 Exelia. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftLocation

class MyPlace: Codable {
    var city: String?
    var countryCode: String?
    var countryName: String?
    var ip: String?
    var isp: String?
    var coordinates: Coordinate?
    var organization: String?
    var regionCode: String?
    var regionName: String?
    var timezone: String?
    var zipCode: String?
    
    init(place: IPPlace) {
        self.city = place.city
        self.countryCode = place.countryCode
        self.countryName = place.countryName
        self.ip = place.ip
        self.isp = place.isp
        if place.coordinates != nil {
            self.coordinates = Coordinate(latitude: place.coordinates!.latitude, longitude: place.coordinates!.longitude)
        }
        self.organization = place.organization
        self.regionCode = place.regionCode
        self.regionName = place.regionName
        self.timezone = place.timezone
        self.zipCode = place.zipCode
    }
}

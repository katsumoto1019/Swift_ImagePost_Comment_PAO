//
//  SpotAnnotation.swift
//  Pao
//
//  Created by Waseem Ahmed on 09/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import MapKit
//import Cluster
class SpotAnnotation:  NSObject, MKAnnotation {
    
    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
    @objc dynamic var coordinate: CLLocationCoordinate2D

    var spotId: String?
    
    var title: String?
    
    var imageName: String?
    
    var imageUrl: URL?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}

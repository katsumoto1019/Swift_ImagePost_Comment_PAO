//
//  SpotClusterAnnotation.swift
//  Pao
//
//  Created by Waseem Ahmed on 20/08/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit
import MapKit
//import Cluster

class SpotClusterAnnotation: MKClusterAnnotation {
    
    var spotId: String?
    
    var imageName: String?
    
    var imageUrl: URL?
    
    override init(memberAnnotations: [MKAnnotation]) {
        super.init(memberAnnotations: memberAnnotations);
    }
}

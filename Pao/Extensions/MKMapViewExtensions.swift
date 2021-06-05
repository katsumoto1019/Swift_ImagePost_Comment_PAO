//
//  MKMapViewWxtensions.swift
//  Pao DEV
//
//  Created by Waseem Ahmed on 14/06/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import Foundation
import MapKit

typealias Edges = (ne: CLLocationCoordinate2D, sw: CLLocationCoordinate2D)

extension MKMapView {
    func edgePoints() -> Edges {
        let nePoint = CGPoint(x: self.bounds.maxX, y: self.bounds.origin.y)
        let swPoint = CGPoint(x: self.bounds.minX, y: self.bounds.maxY)
        let neCoord = self.convert(nePoint, toCoordinateFrom: self)
        let swCoord = self.convert(swPoint, toCoordinateFrom: self)
        return Edges(ne: neCoord, sw: swCoord)
    }
    
    func setMapFocus(centerCoordinate: CLLocationCoordinate2D, radiusInMeters radius: CLLocationDistance) {
        let region: MKCoordinateRegion = MKCoordinateRegion.init(center: centerCoordinate, latitudinalMeters: radius, longitudinalMeters: radius)
        self.setRegion(region, animated: false)
    }
    
    
    /// when we call this function, we have already added the annotations to the map, and just want all of them to be displayed.
    func fitAll() {
        var zoomRect            = MKMapRect.null;
        for annotation in annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect       = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01);
            zoomRect            = zoomRect.union(pointRect);
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
    }
    
    /// we call this function and give it the annotations we want added to the map. we display the annotations if necessary
    func fitAll(in annotations: [MKAnnotation], andShow show: Bool) {
        var zoomRect:MKMapRect  = MKMapRect.null
        
        for annotation in annotations {
            let aPoint          = MKMapPoint(annotation.coordinate)
            let rect            = MKMapRect(x: aPoint.x, y: aPoint.y, width: 0.1, height: 0.1)
            
            if zoomRect.isNull {
                zoomRect = rect
            } else {
                zoomRect = zoomRect.union(rect)
            }
        }
        if(show) {
            addAnnotations(annotations)
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
    }
    
    
    var zoom: Double {
        // function returns current zoom of the map
        return log2(360.0 * Double(self.frame.size.width) / (self.region.span.longitudeDelta * 128.0))
        
        /* let zoomWidth = self.visibleMapRect.size.width
        return Double(log2(zoomWidth)) */
    }
 
    var radius:Double {
        return self.centerCoordinate.distance(inMetersTo: edgePoints().sw)
    }
}

extension CLLocationCoordinate2D {
    func distance(inMetersTo to:CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation).rounded(toPlaces: 1)
    }
    
    func distance(inKilometersTo to:CLLocationCoordinate2D) -> Double {
        let meters = distance(inMetersTo: to)
        return (meters / 1000.0).rounded(toPlaces: 1)
    }
}


extension MKMapView {
    func regionToMkCoordinateRegion(region: Region) -> MKCoordinateRegion {
        
        // MKCoordinate uses a centre and span around centre to define a region.
        // The recommendedViewport uses corner coordinates.
        // Convert corners to map coordinates and then calculate
        // span of the resulting rectangle in the Mercator projection
        // and convert it back to a coordinate region
        // For more details, see http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/LocationAwarenessPG/MapKit/MapKit.html#//apple_ref/doc/uid/TP40009497-CH3-SW5

        let southwestMapPoint = MKMapPoint(region.southwest!.clLocationCoordinate2D);
        let northeastMapPoint = MKMapPoint.init(region.northeast!.clLocationCoordinate2D)
        
        let northwestMapPoint = MKMapPoint.init(x: southwestMapPoint.x, y: northeastMapPoint.y);
        
        let mapRectWidth = northeastMapPoint.x - northwestMapPoint.x;
        let mapRectHeight = northwestMapPoint.y - southwestMapPoint.y;
        
        let mapRect = MKMapRect.init(x: southwestMapPoint.x, y: southwestMapPoint.y, width: mapRectWidth, height: mapRectHeight);
        return MKCoordinateRegion(mapRect);
    }

//    func zoomToViewport(viewport: Region) {
//        let regionForIncident = regionToMkCoordinateRegion(region: viewport)
//        let regionAdjustedForMap = self.regionThatFits(regionForIncident)
//        self.setRegion(regionAdjustedForMap, animated: true)
//    }
    
    func zoomToViewport(viewport: Region, edgePadding: UIEdgeInsets = UIEdgeInsets.zero ,animated: Bool) {
         var zoomRect:MKMapRect  = MKMapRect.null
         
         for coordinate in [viewport.southwest!.clLocationCoordinate2D, viewport.northeast!.clLocationCoordinate2D] {
             let aPoint = MKMapPoint(coordinate)
             let rect = MKMapRect(x: aPoint.x, y: aPoint.y, width: 0.1, height: 0.1)
             
             if zoomRect.isNull {
                 zoomRect = rect
             } else {
                 zoomRect = zoomRect.union(rect)
             }
         }

        setVisibleMapRect(zoomRect, edgePadding: edgePadding, animated: animated)
     }
}

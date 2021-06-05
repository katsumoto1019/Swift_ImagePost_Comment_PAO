//
//  FullScreenMapViewController.swift
//  Pao
//
//  Created by OmShanti on 08/12/20.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit
import MapKit

class FullScreenMapViewController: UIViewController {

    private var mapView: MKMapView!
    private var mapShadowLayer: CALayer?
    
    var location: Location?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMap()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mapShadowLayer?.removeFromSuperlayer()
        mapShadowLayer = mapView.addInnerShadow(radius: 10, opecity: 1.0, frame: CGRect.init(origin: CGPoint.zero, size: CGSize(width: self.view.bounds.width, height: mapView.bounds.height)))
    }
    
    func initMap() {
        mapView = MKMapView.init(frame: view.bounds)
        mapView.showsUserLocation = true
        view.addSubview(mapView)
        view.sendSubviewToBack(mapView)
        mapView.constraintToFit(inContainerView: view)
        
        mapView.delegate = self
        addMapAnnotation()
    }
    
    private func addMapAnnotation() {
        guard
            let latitude = location?.coordinate?.latitude,
            let longitude = location?.coordinate?.longitude else { return }
        
        let anotation = MKPointAnnotation()
        anotation.title = location?.city
        anotation.subtitle = location?.country
        anotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        mapView.delegate = self
        mapView.addAnnotation(anotation)
        mapView.centerCoordinate = anotation.coordinate
        mapView.zoomToLocation(Coordinate: anotation.coordinate)
    }
}

// MARK: - MapkitViewDelegate implementation

extension FullScreenMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "Annotation"
        
        guard annotation is MKPointAnnotation else { return nil }
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) else {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.canShowCallout = true
            return annotationView
        }
        
        annotationView.annotation = annotation
        return annotationView
    }
}

// MARK: - Mapkit extension for zoomimg function

fileprivate extension MKMapView {
    
    func zoomToLocation(Coordinate coordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        setRegion(region, animated: true)
    }
}

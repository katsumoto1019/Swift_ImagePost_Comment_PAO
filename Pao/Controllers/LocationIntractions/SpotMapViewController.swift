//
//  SpotMapViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 08/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import MapKit
import Payload
import NVActivityIndicatorView

class SpotMapViewController: BaseViewController {
    
    var mapView: MKMapView!
    
    @IBOutlet weak var scrollContainerView: UIView!
    
    var spotCollectionViewController: MiniSpotCollectionViewController!
    
    var delegate: SpotCollectionViewCellDelegate?
    
    var collection: PayloadCollection<Spot>!;
    
    var categories: String? //Search
    
    var parentController: TopSpotsViewController?
    
    /// Variables used for fetching data in chunks
    private var freshData = [Spot]()
    private var maxDataLimit = 1000
    private var payloadTask: PayloadTask?
    ///
    
    var locationViewport: Region? {
        didSet {
            if zoomLevel != 0.0, locationViewport != nil {
                DispatchQueue.main.sync {
                    self.mapView.zoomToViewport(viewport: locationViewport!, edgePadding: UIEdgeInsets(top: 50, left: 0, bottom: 100, right: 0),  animated: false)
                    /// Forcefully fetch freshData for viewport change
                    self.fetchNewData(viewportUpdated: true)
                    ///
                }
                
            }
        }
    }
    
    var isYourPeopleScreen: Bool {
        get{
            return type(of: parentController!) == YourPeopleSpotsViewController.self
        }
    }
    
    var refreshCallback: ((_ latitude: Double, _ longitude: Double, _ radius: Double) -> Void)?
    var location: Location!
    private var zoomLevel: Double = 0.0
    private var lastRadius: Double = 0.0;
    private var centerOfMap: CLLocationCoordinate2D?
    private var userInteractedMap = false;
    
    private var allAnnotations = [MKAnnotation]()
    
    private let softBufferSize = 100;
    //private var edgeReloaded: Edges?
    
    let centerSpinnerView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40), type: .circleStrokeSpin, color: ColorName.textGray.color, padding: 8);
    
    //Control maxZoom --//
    private let maxZoomLevel = 17
    private var previousZoomLevel: Int?
    private var currentZoomLevel: Int?  {
        willSet {
            self.previousZoomLevel = self.currentZoomLevel
        }
        didSet {
            // if we have crossed the max zoom level, request a refresh
            // so that all annotations are redrawn with clustering enabled/disabled
            guard let currentZoomLevel = self.currentZoomLevel,
                let previousZoomLevel = self.previousZoomLevel, currentZoomLevel != previousZoomLevel else { return }
            
            if (currentZoomLevel >= self.maxZoomLevel && previousZoomLevel < self.maxZoomLevel) ||
                (currentZoomLevel < self.maxZoomLevel && previousZoomLevel >= self.maxZoomLevel)  {
                // remove the annotations and re-add them, eg
                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)
                self.mapView.addAnnotations(annotations)
            }
        }
    }
    
    private var shouldCluster: Bool {
        if let zoomLevel = self.currentZoomLevel, zoomLevel >= maxZoomLevel {
            return false
        }
        return true
    }
    ///--///
    
    private var displayedAnnotations: [MKAnnotation]? {
        willSet {
            if let currentAnnotations = displayedAnnotations {
                mapView.removeAnnotations(currentAnnotations)
                spotCollectionViewController.reloadData()
            }
        }
        didSet {
            if let newAnnotations = displayedAnnotations {
                mapView.addAnnotations(newAnnotations)
                spotCollectionViewController.reloadData()
            }
        }
    }
    
    init(collection: PayloadCollection<Spot>, location: Location) {
        super.init(nibName: nil, bundle: nil);
        
        self.collection = collection;
        self.location = location;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMap();
        setupChildController();
        initSpinner();
        
        collection.loaded.append {_ in
            self.centerSpinnerView.stopAnimating();
        }
        
        collection.elementsChanged.append({_ in 
            self.updateMap();
        });
        
        if !collection.isLoading {
            self.showAnntations();
        }
        
        collection.isLoading ? centerSpinnerView.startAnimating() : centerSpinnerView.stopAnimating();
        
        //getLocationViewport()
    }
    
    func initMap() {
        mapView = MKMapView.init(frame: view.bounds);
        mapView.showsUserLocation = true;
        view.addSubview(mapView);
        view.sendSubviewToBack(mapView);
        mapView.constraintToFit(inContainerView: view);
        
        mapView.delegate = self;
        mapView.register(SpotAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(SpotAnnotation.self));
        mapView.register(SpotClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(SpotClusterAnnotation.self));
        
        // add pan gesture to detect when the map moves
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))
        panGesture.delegate = self
        mapView.addGestureRecognizer(panGesture)
        
        // add pan gesture to detect when the map moves
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.didPinchedMap(_:)))
        pinchGesture.delegate = self
        mapView.addGestureRecognizer(pinchGesture)
        
        if let viewport = locationViewport {
//            self.mapView.zoomToViewport(viewport: viewport, edgePadding: UIEdgeInsets(top: 50, left: 0, bottom: 100, right: 0),  animated: false)
            self.mapView.zoomToViewport(viewport: viewport, edgePadding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),  animated: false)

            /// Forcefully fetch freshData for viewport change
            self.fetchNewData(viewportUpdated: true)
            ///
        } else {
            mapView.setMapFocus(centerCoordinate: self.location.coordinate!.clLocationCoordinate2D!, radiusInMeters: (location.isCurrentLocation ?? false) ? 10000 : 10000)
        }
    }
    
    func setupChildController() {
        scrollContainerView.backgroundColor = UIColor.clear;
        scrollContainerView.clipsToBounds = true;
        
        spotCollectionViewController = MiniSpotCollectionViewController();
        spotCollectionViewController.spotDelegate = delegate;
        
        spotCollectionViewController.collection.isLoading = true;//As to avoid the miniSpotCollectionVC to reload.
        
        self.addChild(spotCollectionViewController);
        spotCollectionViewController.view.frame = scrollContainerView.bounds;
        scrollContainerView.addSubview(spotCollectionViewController.view);
        spotCollectionViewController.didMove(toParent: self);
    }
    
    func initSpinner() {
        view.addSubview(centerSpinnerView);
        centerSpinnerView.translatesAutoresizingMaskIntoConstraints = false;
        centerSpinnerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true;
        centerSpinnerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true;
    }
    
    func updateMap() {
        guard collection.count > 0 else {
            displayedAnnotations?.removeAll()
            allAnnotations.removeAll()
            return;
        }
        
        showAnntations();
    }
    
    func showAnntations() {
        
        //To relaod data once with lat/lng and radius paramter, after initialization
        if self.centerOfMap == nil {
            userInteractedMap = true;
            lastRadius = 0;
            //self.mapView.fitAll(in: allAnnotations, andShow: false);
            fetchNewData();
            return;
        }
        
        //set collection to mini-horizontal collectionView
        spotCollectionViewController.collection = self.collection;
        
        guard collection.count > 0 else { return; }
        
        allAnnotations.removeAll();
        
        collection.forEach { spot in
            if let coordinate = spot.location?.coordinate {
                let spotAnnotation = SpotAnnotation(coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude!, longitude: coordinate.longitude!));
                spotAnnotation.spotId = spot.id;
                if let media = spot.media?.values.sorted(by: {$0.index ?? 0 < $1.index ?? 0}).first {
                    spotAnnotation.imageUrl =  media.thumbnailUrl != nil ? media.thumbnailUrl : media.url;
                }
                allAnnotations.append(spotAnnotation);
            }
        }
        
        displayedAnnotations = allAnnotations;
    }
    
    func reloadView() {
        if collection.count <= 0  {
            displayedAnnotations?.removeAll()
            allAnnotations.removeAll()
            centerSpinnerView.startAnimating()
        }
    }
}


//MARK: download data in chunks
extension SpotMapViewController {
    func reloadingView() {
        if collection.count <= 0  {
            //stop loading freshData
            payloadTask?.cancel()
            
            displayedAnnotations?.removeAll()
            allAnnotations.removeAll()
            centerSpinnerView.startAnimating()
        }
    }
    
    func fetchFreshData(radius: Int, viewportUpdated: Bool = false) {
        
        //reloading indicators for all three views
        self.centerSpinnerView.startAnimating()
        parentController?.spotCollectionViewController.reloadingView()
        parentController?.spotTableViewController.reloadingView()
        parentController?.emptyView.isHidden = true
        ///
        
        let params = LocationSpotsParams(skip: freshData.count, take: softBufferSize, long: location.coordinate!.longitude!, lat: location.coordinate!.latitude!, placeId: nil, following: false, radius: radius, categories: categories, name: location.name, recent: isYourPeopleScreen)
        /*
         //Uncomment this to fetch data specific to the given location
         if viewportUpdated, let type = location.type {
         params = LocationSpotsParams(skip: freshData.count, take: softBufferSize, long: location.coordinate!.longitude!, lat: location.coordinate!.latitude!, placeId: nil, following: false, radius: radius, categories: categories,  type: type, name: location.name, recent: isYourPeopleScreen)
         }
         */
        payloadTask =  App.transporter.get([Spot].self, queryParams: params) { (spots) in
            //guard self.canLoadFreshData else { return }
            
            self.freshData.append(contentsOf: spots ?? [])
            if (spots?.count ?? 0) < self.softBufferSize || self.freshData.count >= self.maxDataLimit {
                //load
                self.collection.removeAll()
                self.collection.append(contentsOf: self.freshData)
                
                self.collection.elementsChanged.forEach({$0(nil)});
                self.collection.loaded.forEach({$0(true)});
            } else {
                self.fetchFreshData(radius: radius, viewportUpdated: viewportUpdated)
            }
        }
    }
}

//MARK: mapview delegates
extension SpotMapViewController: MKMapViewDelegate {
    
    /// - Tag: CreateAnnotationViews
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
            // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
            return nil
        }
        
        var annotationView: MKAnnotationView?
        
        if let annotation = annotation as? SpotClusterAnnotation {
            annotationView = setupSpotClusterAnnotationView(for: annotation, on: mapView);
        } else if let annotation = annotation as? SpotAnnotation {
            annotationView = setupSpotAnnotationView(for: annotation, on: mapView);
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        let spotClusterAnnotation = SpotClusterAnnotation(memberAnnotations: memberAnnotations);
        spotClusterAnnotation.title = "\(memberAnnotations.count)";
        if let spotAnnotation  = memberAnnotations.first as? SpotAnnotation {
            spotClusterAnnotation.imageUrl =  spotAnnotation.imageUrl;
            spotClusterAnnotation.spotId = spotAnnotation.spotId;
        }
        return spotClusterAnnotation;
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.currentZoomLevel = Int(mapView.zoom);
        fetchNewData()
    }
    
    private func setupSpotAnnotationView(for annotation: SpotAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: NSStringFromClass(SpotAnnotation.self), for: annotation) as! SpotAnnotationView;
        if self.shouldCluster {
            annotationView.clusteringIdentifier = "spots";
        } else {
            annotationView.clusteringIdentifier = nil
        }
        
        //        annotationView.onClickCallback =  { spotId in
        //            self.showSpot(spotId: spotId);
        //        }
        return annotationView;
    }
    
    private func setupSpotClusterAnnotationView(for annotation: SpotClusterAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: NSStringFromClass(SpotClusterAnnotation.self), for: annotation) as! SpotClusterAnnotationView;
        annotationView.annotation = annotation;
        //        annotationView.onClickCallback =  { spotId in
        //            self.showSpot(spotId: spotId);
        //        }
        return annotationView;
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        
        if let clusterAnnotation = annotation as? SpotClusterAnnotation {
            self.showSpot(spotId: clusterAnnotation.spotId)
            
        } else if let spotAnnotation = annotation as? SpotAnnotation {
            self.showSpot(spotId: spotAnnotation.spotId)
        }
    }
}

//MARK: track interactions with mapView
extension SpotMapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true;
    }
    
    @objc func didDragMap(_ sender: UIGestureRecognizer) {
        if sender.state == .ended {
            self.userInteractedMap = true
        }
    }
    
    @objc func didPinchedMap(_ sender: UIGestureRecognizer) {
        if sender.state == .ended {
            self.userInteractedMap = true
        }
    }
    
    private func fetchNewData(viewportUpdated: Bool = false) {
        
        //TODO: this threshold has to be fixed
        let distanceThreshold:Double = 50000
        
        //        let radius = self.mapView.radius
        let currentCenter = self.mapView.centerCoordinate;
        let distanceMoved = self.centerOfMap != nil ? self.centerOfMap!.distance(inMetersTo: currentCenter) : distanceThreshold;
        //let zoomChange = fabs(self.zoomLevel - self.mapView.zoom)
        let zoomChange = self.zoomLevel - self.mapView.zoom;
        
        var reloadOnZoomIn = false;
        if userInteractedMap, zoomChange < -0.5 {
            reloadOnZoomIn = (collection.bufferSize != softBufferSize || collection.count >= softBufferSize);
        }
        
        //Analytics
        if userInteractedMap, abs(zoomChange) > 0.5 {
            AmplitudeAnalytics.logEvent(.mapZoom, group: .search)
        }
        if userInteractedMap, abs(distanceMoved) > 10 {
            AmplitudeAnalytics.logEvent(.mapMove, group: .search)
        }
        ///
        
        if viewportUpdated || (userInteractedMap && (reloadOnZoomIn || zoomChange > 0.5 || distanceMoved >= (lastRadius / 2.0))) {
            
            FirbaseAnalytics.logEvent(.mapZoom)
            
            // if !collection.isLoading {
            collection.bufferSize = softBufferSize;
            self.refreshCallback?(currentCenter.latitude, currentCenter.longitude, self.mapView.radius)
            
            self.centerSpinnerView.startAnimating();
            
            self.zoomLevel = self.mapView.zoom;
            self.centerOfMap = self.mapView.centerCoordinate;
            self.lastRadius = self.mapView.radius;
            //}
            payloadTask?.cancel(); //canLoadFreshData = true
            freshData = []
            fetchFreshData(radius: Int(self.mapView.radius * 1.5), viewportUpdated: viewportUpdated)
        }
        
        self.userInteractedMap = false;
    }
}

extension SpotMapViewController {
    func showGo(spotId: String?) {
        FirbaseAnalytics.logEvent(.mapOpenSpot)
        
        if let spotId = spotId, let spot = collection.first(where: { (spot) -> Bool in
            return spot.id == spotId;
        }) {
            delegate?.showGo(spot: spot);
        }
    }
    
    func showSpot(spotId: String?) {
        FirbaseAnalytics.logEvent(.mapClickSpot)
        AmplitudeAnalytics.logEvent(.mapClickSpot, group: .search)

        if  let spotId = spotId, let spot = self.collection.first(where: {spotId == $0.id}), let row = self.collection.firstIndex(of: spot), row < collection.count {
            spotCollectionViewController.scrollTo(indexPath: IndexPath(row: row, section: 0));
        }
    }
}

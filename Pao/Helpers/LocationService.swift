//
//  LocationHelper.swift
//  Pao
//
//  Created by Waseem Ahmed on 31/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces

protocol LocationServiceDelegate {
    func currentLocation(location: CLLocation)
    func currentPlace(location: Location)
}

class LocationService: NSObject {
    
    private var locationManager: CLLocationManager?
    private var lastLocation: CLLocation?
    private var lastLocationTime:Date?
    var currentLocation: Location?
    
    var delegate: LocationServiceDelegate?
    
    private var locationUpdateBlock:((CLLocation?,NSError?)->Void)?
    private var placeUpdateBlock:((Location)->Void)?
    private var permissionBlock:((Bool)->Void)?
    
    static let shared: LocationService = {
        let instance = LocationService()
        return instance
    }()
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager();
        
        guard let manager = locationManager else {
            return;
        }
        
        manager.desiredAccuracy = kCLLocationAccuracyKilometer;
        manager.distanceFilter = CLLocationDistance(5000);
        manager.delegate = self;
    }
    
    func isEnabled() -> Bool {
        return (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse);
    }
    
    func isDenied() -> Bool {
        return CLLocationManager.authorizationStatus() == .denied;
    }
    
    func enableService(_ callback:@escaping (_ granted:Bool) -> Void) {
        self.permissionBlock = callback;
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager?.requestWhenInUseAuthorization();
        }
    }
    
    func updateCurrentPlace(_ callback:@escaping(_ location:Location) -> Void) {
        
        self.placeUpdateBlock = callback;
        
        if let location = self.currentLocation {
            placeUpdateBlock?(location);
        }
    }
    
    func startUpdating() {
        if isEnabled() {
            locationManager?.startUpdatingLocation();
        }else {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager?.requestWhenInUseAuthorization();
            }
        }
    }
    
    func stopUpdating() {
        locationManager?.stopUpdatingLocation();
    }
    
    // Private functions
    private func locationUpdated(currentLocation: CLLocation) {
        delegate?.currentLocation(location: currentLocation);
        locationUpdateBlock?(lastLocation, nil);
    }
    
    private func updateLocationDidFailWithError(error: NSError) {
        locationUpdateBlock?(nil, error);
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        self.lastLocation = location;
        self.lastLocationTime = Date();
        getCurrentPlace();
        locationUpdated(currentLocation: location);
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse,.authorizedAlways:
            self.permissionBlock?(true);
            startUpdating();
            break;
        case .denied:
            self.permissionBlock?(false);
            break;
        default:
            break;
        }
    }
}

// MARK: - GMSPlace details
extension LocationService {
    
    private func getCurrentPlace() {
        GMSPlacesClient().currentPlace { (placeLikelihoodList, error) in
            guard  error == nil else {
                if let location = self.currentLocation { self.delegate?.currentPlace(location: location); }
                return;
            }
            
            if let placeLikelihoodList = placeLikelihoodList, placeLikelihoodList.likelihoods.count > 0 {
                let likelihood = placeLikelihoodList.likelihoods.first!;
                let place = likelihood.place;
                
                let location = Location();
                let coordinate  = Coordinate();
                
                location.name = place.name;
                location.formattedAddress = place.formattedAddress;
                coordinate.longitude = place.coordinate.longitude;
                coordinate.latitude = place.coordinate.latitude;
                location.coordinate = coordinate;
                location.types = place.types?.map({(type:String) -> String in
                    return type.replacingOccurrences(of:"_", with: " ").capitalizingFirstLetter;
                })
                
                location.gmsAddress = place.addressComponents?.reduce([String: String](), { (result, gmsAddressComponent) -> [String: String] in
                    var result = result
                    
					if let type = gmsAddressComponent.types.first {
						result[type] = gmsAddressComponent.name
					}
					
                    return result
                })
                
                self.currentLocation = location;
                
                if location.gmsAddress == nil {
                    self.getPlaceInfo(placeId: place.placeID);
                    return;
                }
                
                self.delegate?.currentPlace(location: location);
                self.placeUpdateBlock?(location);
            }
        }
    }
    
    private func getPlaceInfo(placeId: String?) {
        guard let placeId = placeId else { return; }
        
        APIContext.shared.getPlaceDetails([.addressComponent], placeId: placeId, inLanguage: .english) { (data, urlResponse, error) in
            guard
                let placeDetails = try? data?.convert(PlaceDetailsResponse.self).result,
                let addressComponents = placeDetails.addressComponents,
                self.currentLocation != nil else { return }
            
            self.currentLocation?.gmsAddress = addressComponents.reduce([String: String](), { (result, gmsAddressComponent) -> [String: String] in
                var result = result;
                result[gmsAddressComponent.types.first!] = gmsAddressComponent.longName;
                return result;
            });
            
            self.delegate?.currentPlace(location: self.currentLocation!);
            self.placeUpdateBlock?(self.currentLocation!);
        }
    }
    
    func currentAddress() -> String? {
        guard let location = self.currentLocation else { return nil; }
        
        return location.cityFormatted;
    }
}

extension LocationService {
    func openSettings(parent: UIViewController) {
        let alert = PermissionAlertController(title: L10n.LocationsSearchTableViewController.PermissionAlert.title, subTitle: L10n.LocationService.youNeedToEnableLocation);
        alert.addButton(title: L10n.LocationService.openSettings, style: .normal) {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!);
        }
        alert.addButton(title: L10n.Common.notNow, style: .additional) {
        }
        alert.show(parent: parent);
        return;
    }
}

//
//  APIContext.swift
//  Pao
//
//  Created by Parveen Khatkar on 11/06/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import Firebase

class APIContext {
    static let shared = APIContext();
    
//    var spots = [Spot]();
//    
//    func loadSpots(for controllerType: AnyClass, reload: Bool = false, limit: Int, completionHandler: (() -> Void)?) {
//        App.transporter.get(for: controllerType, limit: limit, completionHandler: { (result: SpotsResult) in
//            if reload {
//                self.spots.removeAll();
//            }
//            completionHandler?();
//            self.spots.append(contentsOf: result.spots!);
//        })
//    }
}

extension APIContext {
    func saveSpot(spotId: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: { (token, error) in
            if let error = error {
                completionHandler(nil, nil, error);
                return;
            }
            
            let url = URL(string: String(format: "spot/%@/save", spotId), relativeTo: Bundle.main.apiUrl)!
            var request = URLRequest(url: url);
            request.addValue("Bearer \(token!)", forHTTPHeaderField: "Authorization");
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (responseData: Data?, response: URLResponse?, error: Error?) in
                DispatchQueue.main.async {
                    completionHandler(responseData, response, error);
                }
            })
            task.resume();
        })
    }
    
    func placeDescription(searchTerm: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let urlString =  String(format: "https://kgsearch.googleapis.com/v1/entities:search?query=%@&key=%@&limit=1&indent=True", searchTerm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!, Bundle.main.googleMapsAPIKey);
        let url = URL(string: urlString)!
        let request =  URLRequest(url: url);
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (responseData: Data?, response: URLResponse?, error: Error?) in
            DispatchQueue.main.async {
                completionHandler(responseData, response, error);
            }
        })
        task.resume();
    }
    
    // REF: https://developers.google.com/places/web-service/details
    func getPlaceDetails(_ placeDetails: [PlaceDetail], placeId: String, inLanguage: LanguageCode, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        if (placeDetails.count == 0) { return; }
        
        var fields = placeDetails.first!.rawValue;
        for placeDetailIndex in 1..<placeDetails.count {
            fields += "," + placeDetails[placeDetailIndex].rawValue;
        }
        
        let urlString = String(format: "https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&fields=%@&key=%@&language=%@", placeId, fields, Bundle.main.googleMapsAPIKey, inLanguage.rawValue);
        let url = URL(string: urlString)!;
        let request = URLRequest(url: url);
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                completionHandler(data, urlResponse, error);
            }
        }
        task.resume();
    }
    
    // REF: https://developers.google.com/maps/documentation/geocoding/intro
       func reverseGeocode(coordinate: Coordinate, inLanguage: LanguageCode, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
           
           let latlng = "\(coordinate.latitude!),\(coordinate.longitude!)"
           let resultTypes = "political|country|administrative_area_level_1|administrative_area_level_2|administrative_area_level_3|locality|sublocality"

           var urlString = String(format: "https://maps.googleapis.com/maps/api/geocode/json?latlng=%@&key=%@&language=%@", latlng, Bundle.main.googleMapsAPIKey, inLanguage.rawValue);
           
           urlString = urlString + "&result_type=\(resultTypes)"
           
           urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

           guard let url = URL(string: urlString) else { return }
           let request = URLRequest(url: url);
           let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
               DispatchQueue.main.async {
                   completionHandler(data, urlResponse, error);
               }
           }
           task.resume();
       }
    

    func adressDetails(name: String, inLanguage: LanguageCode, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
           
           var urlString = String(format: "https://maps.googleapis.com/maps/api/geocode/json?address=%@&key=%@&language=%@", name, Bundle.main.googleMapsAPIKey, inLanguage.rawValue);
                      
           urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

           guard let url = URL(string: urlString) else { return }
           let request = URLRequest(url: url);
           let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
               DispatchQueue.main.async {
                   completionHandler(data, urlResponse, error);
               }
           }
           task.resume();
       }
}

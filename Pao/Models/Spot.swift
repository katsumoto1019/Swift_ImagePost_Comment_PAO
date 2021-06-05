//
//  Spot.swift
//  Pao
//
//  Created by Parveen Khatkar on 3/1/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import MapKit
import Payload


public class Spot: PaoModel {
    
    // TODO: Inehrit from SpotRef
    var id: String? {
        didSet {
            if let identifier = id {
                emoji = EmojiDictionary(id: identifier)
            }
        }
    }
    var timestamp: Date?
    var media: SpotMediaDictionary?
    var thumbnail: SpotMediaItem?
    var user: SpotUser?
    
    var mediaCount: Int?
    var imagesCount: Int?
    var videosCount: Int?
    
    var description: String?
    
    var location: Location?
    
    var category: SpotCategory?
    
    //Updated
    var categories: [SpotCategory]?
    
    var saves: Int?
    var commentsCount: Int?

    var isMediaServed: Bool?
    
    var platform: Int? = Platform.iOS.rawValue;
    var feedIndex: Int?
    
    var isSavedByViewer: Bool?

    var isFavorite: Bool?
    var uploadStatus: Int? = SpotUploadStatus.uploaded.rawValue
    var emoji: EmojiDictionary?
    var savedBy: [User]?
    var firebaseId: String?
    
    var line1: String?
    var line2: String?
}

extension Spot {
    var isUserSpot: Bool {
        return user?.id == DataContext.cache.user?.id
    }
}

extension Spot: Equatable {
    public static func == (lhs: Spot, rhs: Spot) -> Bool {
        return lhs.id == rhs.id;
    }
}

class SpotCategory: Codable {
    var id: String?
    var idex: Int?
    var subCategories: SpotSubCategoriesDictionary?
}
typealias SpotSubCategoriesDictionary = [String: SpotSubCategory];

struct EmojiDictionary: Codable, PaoModel {

    var id: String?

    enum CodingKeys: Int, CodingKey {
        case dictionary
    }

    var dictionary: [Emoji: EmojiItem]?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            let entries = try container.decode([Int: EmojiItem].self)
            dictionary = Dictionary(uniqueKeysWithValues: entries.compactMap
                { key, value in (Emoji(rawValue: key), value) as? (Emoji, EmojiItem)})
        } catch DecodingError.typeMismatch {
        }
    }

    init(id: String) {
        self.id = id
        self.dictionary = [Emoji: EmojiItem]()
    }
}

struct ReactersAndSaversDictionary: PaoModel {
    var id: String?
    var emoji: EmojiDictionary?
    var savedBy: [User]
}

class SpotSubCategory: Codable {
    var id: String?
    var index: Int?
}

extension Spot {
    func duplicate() -> Spot? {
        let jsonEncoder = JSONEncoder()
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dataDecodingStrategy = .deferredToData;
        
        guard let jsonData = try? jsonEncoder.encode(self) else {
            return nil;
        }
        
        return try? jsonDecoder.decode(Spot.self, from: jsonData);
    }
    
    func getCategorySubCategoryNameList() -> ([String], [String]) {
        var categoryNames = [String]()
        var subCategoryNames = [String]()
        if let categories = DataContext.cache.categories, let spotCategories = self.categories {
            categoryNames = spotCategories.compactMap { (spotCat) -> Category? in
                let resCategory = categories.first ( where: { $0.firebaseId == spotCat.id } )
                let subCategory = spotCat.subCategories?.compactMap({ (arg0) -> SubCategory? in
                    let (key, _) = arg0
                    return resCategory?.subCategories?.first(where: { $0.firebaseId == key })
                }).compactMap { $0.name }
                if let subCats = subCategory {
                    subCategoryNames.append(contentsOf: subCats)
                }
                return resCategory
            }.compactMap { $0.name }
        }
        return (categoryNames, subCategoryNames)
    }
}

class SpotMediaItem: Codable {
    var id: String?
    var index: Int?
    var placeholderColor: String?
    var thumbnailUrl: URL?
    var url: URL?
    var type: Int?
}
typealias SpotMediaDictionary = [String: SpotMediaItem];

class Location: Codable {
    var about: String?
    var gmsAddress: [String: String]?
    var coordinate: Coordinate?
    var googlePlaceId: String?
    var name: String?
    var formattedAddress: String?
    var types: [String]?
    var cover: Cover?
    var type: String?
    
    //local use only
    var isCurrentLocation:Bool? = false
    var line1: String?
}

class Cover: Codable {
    var id: String?
    var placeholderColor: String?
    var url: URL?
}

extension Location {
    var streetNumber: String? {
        return gmsAddress?["street_number"];
    }
    
    var route:String? {
        return gmsAddress?["route"]
    }
    
    var city: String? {
        return gmsAddress?["locality"] ?? gmsAddress?["postal_town"] ?? gmsAddress?["administrative_area_level_3"] ?? gmsAddress?["administrative_area_level_2"];
    }
    
    var state: String? {
        return gmsAddress?["administrative_area_level_1"];
    }
    
    var country: String? {
        return gmsAddress?["country"];
    }
    
    var title: String? {
        return gmsAddress?.first?.value;
    }
    
    var neighborhood: String? {
        return gmsAddress?["neighborhood"];
    }
    
    var postalCode: String? {
        return gmsAddress?["postal_code"];
    }
    
    var pointOfInterest: String? {
        return gmsAddress?["point_of_interest"];
    }
    
    var cityFormatted: String? {
        let city = self.city == nil  ? gmsAddress?["administrative_area_level_2"]: self.city;
        
        var value = String(format: "%@ %@", city != nil ? city! + "," : "", country != nil ? country! : "");
        if let country = country, (country.caseInsensitiveCompare("United States") == .orderedSame) {
            value = String(format: "%@ %@", city != nil ? city! + "," : "", state != nil ? state! : "");
        }
        return value;
    }
    
    var typeFormatted: String? {
        guard let types = types, types.count > 0 else {return nil;}
        var type = types.first;
        if types.count == 2 {
            guard types.first?.caseInsensitiveCompare("natural_feature") == .orderedSame else {return nil;}
            type = "natural wonder";
        }
        
        if type!.caseInsensitiveCompare("establishment") == .orderedSame ||
            type!.caseInsensitiveCompare("point_of_interest") == .orderedSame {
            return nil;
        }
        
        type = type!.replacingOccurrences(of: "_", with: " ");
        type = type!.capitalized;
        
        return type;
    }
    
    func duplicate() -> Location? {
        let jsonEncoder = JSONEncoder()
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dataDecodingStrategy = .deferredToData;
        
        guard let jsonData = try? jsonEncoder.encode(self) else {
            return nil;
        }
        
        return try? jsonDecoder.decode(Location.self, from: jsonData);
    }
}

class Coordinate: Codable {
    var latitude: Double?
    var longitude: Double?
    
    convenience init(latitude: Double, longitude: Double) {
        self.init()
        
        self.latitude = latitude;
        self.longitude = longitude;
    }
}

extension Coordinate {
    var clLocationCoordinate2D: CLLocationCoordinate2D? {
        guard let latitude = latitude, let longitude = longitude else {
            return nil;
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude);
    }
}

class LocationSearch: Codable {
    var locations: [Location]?
    var related: [Location]?
}
///Reverse Geocode Models
class RevesrseGeocode: Codable {
    var results: [GeocodeLocation]
}
class GeocodeLocation: Codable {
    var formatted_address: String?
    var geometry: Geometry?
    var place_id: String?
    var types: [String]?
}

class Geometry: Codable {
    var bounds: Region?
    var location: LatLng?
    var location_type: String?
    var viewport: Region?
}

class Region: Codable {
    var northeast: LatLng?
    var southwest: LatLng?
    
    var radius:Double {
        return northeast!.clLocationCoordinate2D.distance(inMetersTo: southwest!.clLocationCoordinate2D)
    }
    var center: CLLocationCoordinate2D {
        var minLatitude: CLLocationDegrees = 90.0
        var maxLatitude: CLLocationDegrees = -90.0
        var minLongitude: CLLocationDegrees = 180.0
        var maxLongitude: CLLocationDegrees = -180.0

        for coordinate in [northeast!.clLocationCoordinate2D, southwest!.clLocationCoordinate2D] {
          let lat = Double(coordinate.latitude)
          let long = Double(coordinate.longitude)
          if lat < minLatitude {
            minLatitude = lat
          }
          if long < minLongitude {
            minLongitude = long
          }
          if lat > maxLatitude {
            maxLatitude = lat
          }
          if long > maxLongitude {
            maxLongitude = long
          }
        }

        let span = MKCoordinateSpan(latitudeDelta: maxLatitude - minLatitude, longitudeDelta: maxLongitude - minLongitude)
        let center = CLLocationCoordinate2DMake((maxLatitude - span.latitudeDelta / 2), (maxLongitude - span.longitudeDelta / 2))
        return center;
    }
}

class LatLng: Codable {
    var lat: Double?
    var lng: Double?

    var clLocationCoordinate2D: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(lat!, lng!)
        }
    }
}
///
enum Platform: Int {
    case iOS = 10
}

enum SpotAction: Int {
    case verify
    case unverify
    case save
    case unsave
    case favorite
    case unfavorite
	case reactEmoji
	case unreactEmoji
}

enum SpotUploadStatus: Int {
    case uploaded
    case uploading
    case preview
    case failed
}

class GoMediaItem: Codable {
    var profileImage: UserImage?
    var image: SpotMediaItem?
}

struct GoPhotosParams: QueryParams {
    var skip: Int
    var take: Int
}

struct GoPhotosVars: PathVars {
    var googlePlaceId: String
    
    var vars: [Any] {
        return [googlePlaceId];
    }
}

struct SpotsParams: QueryParams {
    var skip: Int
    var take: Int
}

struct LocationSpotsParams: QueryParams {
    var skip: Int
    var take: Int
    var long: Double?
    var lat: Double?
    var placeId: String?
    var following: Bool
    var radius: Int?
    var categories:String?
    var type: String?
    var name: String?
    var recent: Bool
}

struct BoardSpotsParams: QueryParams {
    var skip: Int
    var take: Int
    var userId: String
}

struct BoardSpotsVars: PathVars {
    var boardId: String
    
    var vars: [Any] {
        return [boardId];
    }
}

struct SpotVars: PathVars {
    public var spotId: String;
    
    var vars: [Any] {
        return [spotId];
    }
}


struct IdParam: QueryParams {
    public var id: String;
}

enum ComesFrom: String {
    case yourPeopleFeed = "your people feed"
    case locationSearch = "location search"
    case hiddenGems = "hidden gems"
    case playList = "play list"
    case featuredCity = "featured city"
    case otherProfile = "other profile"
    case ownProfile = "own profile"
    case topPaoSpots = "top pao spots"
}

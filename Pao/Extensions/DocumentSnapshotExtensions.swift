//
//  DocumentSnapshotExtensions.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/21/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Firebase

extension DocumentSnapshot {
    func convert<T>(_ type: T.Type) throws -> T where T: Decodable {
        let data = self.data()!.toData();
        let jsonDecoder = JSONDecoder();
        jsonDecoder.dateDecodingStrategy = .formatted(.iso8601);
        let object = try jsonDecoder.decode(type, from: data);
        return object;
    }
    
    func convert<T>() throws -> T where T: Decodable {
        let data = self.data()!.toData();
        let jsonDecoder = JSONDecoder();
        jsonDecoder.dateDecodingStrategy = .formatted(.iso8601);
        let object = try jsonDecoder.decode(T.self, from: data);
        return object;
    }
}

extension Data {
    func convert<T>(_ type: T.Type, formatter: DateFormatter = .iso8601) throws -> T where T: Decodable {
        let data = self;
        let jsonDecoder = JSONDecoder();
//        jsonDecoder.dateDecodingStrategy = .formatted(formatter);
        let object = try jsonDecoder.decode(type, from: data);
        return object;
    }
    
    func convert<T>(formatter: DateFormatter = .iso8601) throws -> T where T: Decodable {
        let data = self;
        let jsonDecoder = JSONDecoder();
        //        jsonDecoder.dateDecodingStrategy = .formatted(formatter);
        let object = try jsonDecoder.decode(T.self, from: data);
        return object;
    }
}

extension Encodable {
    func toDictionary() throws -> [String: Any] {
        let data = try self.toData();
        let dictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: Any];
        
        return patchDictionary(dictionary: dictionary);
    }
    
//    func toArray() throws -> [Any] {
//        let data = try self.toData();
//        let array = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [Any];
//        return array;
//    }
    
    func toData() throws -> Data {
        let jsonEncoder = JSONEncoder();
        jsonEncoder.dateEncodingStrategy = .formatted(.iso8601);
        let data = try jsonEncoder.encode(self);
        return data;
    }
    
    
    // HACK: Date must be Date and not String, patch for Firebase
    private func patchDictionary(dictionary: [String:Any]) -> [String:Any] {
        var dictionary = dictionary;
        dictionary.forEach { (key, value) in
            if (key.contains("timestamp")) {
                dictionary[key] = (value as! String).toDate();
            }
            else if let nestedDictionary = value as? [String:Any] {
                dictionary[key] = patchDictionary(dictionary: nestedDictionary);
            }
        }
        return dictionary;
    }
}

extension String {
    fileprivate func toDate() -> Date {
        return Formatter.iso8601.date(from: self)!;
    }
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return formatter
    }()
    
    static let firebaseFunctions: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
}

//
//  DictionaryExtensions.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/21/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation

extension Dictionary {
    func toData(prettyPrinted: Bool = false) -> Data {
        var dictionary = self as! [String:Any];
        dictionary = patchDictionary(dictionary: dictionary);
        return try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted);
    }
    
    // HACK: Firebase not returning Date as String, so we gotta do it.
    private func patchDictionary(dictionary: [String:Any])-> [String:Any]{
        var dictionary = dictionary;
        dictionary.forEach { (key, value) in
            if (key.contains("timestamp")) {
                dictionary[key] = String(describing: value);
            }
            else if let nestedDictionary = value as? [String:Any] {
                dictionary[key] = patchDictionary(dictionary: nestedDictionary);
            }
        }
        return dictionary;
    }
}

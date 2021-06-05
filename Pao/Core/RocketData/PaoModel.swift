//
//  PaoModel.swift
//  Pao
//
//  Created by Parveen Khatkar on 23/01/19.
//  Copyright © 2019 Exelia. All rights reserved.
//

import Foundation
import RocketData

protocol PaoModel: Model, Codable {
    var id: String? { get }
}

extension PaoModel {
    public var modelIdentifier: String? {
        // We prepend UserModel to ensure this is globally unique
        let string = String(describing: self).components(separatedBy: ".").last
        let idString = id ?? ""
        let uniqueId = (string ?? "") + ":" + idString
        return uniqueId
    }
    
    public func map(_ transform: (Model) -> Model?) -> Self? {
        // No child objects, so we can just return self
        return self
    }
    
    public func forEach(_ visit: (Model) -> Void) {
    }
    
    public func isEqual(to model: Model) -> Bool {
        return false
    }
    
    public static func modelIdentifier(withId id: String) -> String {
        let uniqueId = String(describing: self) + ":" + id
        return uniqueId
    }
}

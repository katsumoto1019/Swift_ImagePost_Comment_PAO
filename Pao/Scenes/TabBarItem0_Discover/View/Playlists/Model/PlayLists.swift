//
//  PlayLists.swift
//  Pao
//
//  Created by kant on 12.05.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

enum PlayLists: String {
    case unique = "unique"
    case outdoors = "outdoors"
    case treatYourself = "treat yourself"
    case artCulture = "art/culture"
    case eat = "eat"
    
    var swipeName: EventName {
        switch self {
        case .unique: return .uniqueSwipe
        case .outdoors: return .outdoorsSwipe
        case .treatYourself: return .treatYourselfSwipe
        case .artCulture: return .artCultureSwipe
        case .eat: return .eatSwipe
        }
    }
    
    var analyticName: EventName {
       switch self {
        case .unique: return .unique
        case .outdoors: return .outdoors
        case .treatYourself: return .treatYourself
        case .artCulture: return .artCulture
        case .eat: return .eat
        }
    }
    
    var screenName: ScreenNames {
       switch self {
        case .unique: return .unique
        case .outdoors: return .outdoors
        case .treatYourself: return .treatYourself
        case .artCulture: return .artCulture
        case .eat: return .eat
        }
    }
}

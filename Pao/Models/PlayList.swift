//
//  PlayList.swift
//  Pao
//
//  Created by MACBOOK PRO on 16/09/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import Payload


class PlayList: Codable {
    var name: String?
    var target: String?
    var playlistId: String?
    var subCategories: [String]?
    var subCategoriesLen: Int?
    var cover: LocationCover?
    var description: String?
    var start: String?
    var end: String?
    var order: Int?
    var week: Int?
    var year: Int?
    var line1: String?
}

class PlayListLocation: Codable {
    var name: String?
    var cover: LocationCover?
}

class LocationCover: Codable {
    var index: Int?
    var placeholderColor: String?
    var type: Int?
    var id: String?
    var url: String?
    var thumbnailUrl: String?
}

extension LocationCover {
    var urlFromString: URL? {
        if type == 0 {
            guard let url = url else { return nil }
            return URL(string: url)
        } else {
            guard let url = thumbnailUrl else { return nil }
            return URL(string: url)
        }
    }
}

struct PlayListParams: QueryParams {
    var target: String?
    var playlist: String?
    var location: String?
}

public struct playListSpotParams: QueryParams {
    var skip: Int
    var take: Int
    var playlistId: String?
    var schedule: Bool?
}

enum PlayListLayout: Int {
    case square = 0
    case circle = 1
}
enum PlayListStyle: Int {
    case spots = 0
    case lists = 1
    case locations = 2
    case people = 3
}

class PlayListSection: Codable {
    var title: String?
    var layout: PlayListLayout?
    var style: PlayListStyle?
    var items: [Any]?
    
    enum CodingKeys: String, CodingKey {
        case title
        case layout
        case style
        case items
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try? container.decode(String.self, forKey: .title)
        if let layoutValue = try? container.decode(Int.self, forKey: .layout) {
            self.layout = PlayListLayout(rawValue: layoutValue)
        }
        if let styleValue = try? container.decode(Int.self, forKey: .style) {
            self.style = PlayListStyle(rawValue: styleValue)
        }
        if style == PlayListStyle.spots {
            self.items = try? container.decode([Spot].self, forKey: .items)
        } else if style == PlayListStyle.lists {
            self.items = try? container.decode([PlayList].self, forKey: .items)
        } else if style == PlayListStyle.locations {
            self.items = try? container.decode([Location].self, forKey: .items)
        } else if style == PlayListStyle.people {
            self.items = try? container.decode([User].self, forKey: .items)
        }
    }

    func encode(to encoder: Encoder) throws {
        //
    }
    
    init(title: String) {
        self.title = title
    }
}

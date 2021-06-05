//
//  SavedSpotsMetadata.swift
//  Pao
//
//  Created by Parveen Khatkar on 4/17/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import Payload


// Board: collection of spots ref, grouped by city.
class Board: PaoModel {
    var id: String?
    var title: String?
    var nestingLevel: Int?
    var hasNestedBoards: Bool?
    var thumbnail: SpotMediaItem?
    var parentBoardId: String?
    var spotsCount: Int?
    var type: Int?
    var user: User?
    
    public var modelIdentifier: String? {
        // We prepend UserModel to ensure this is globally unique
        let string = String(describing: self).components(separatedBy: ".").last
        let idString = id ?? ""
        let uniqueId = (string ?? "") + ":" + idString
        let stringType = ":" + String(type ?? 0)
        let extra = stringType + ":" + (user?.id ?? "")
        return uniqueId + extra
    }
    
    //Local use only
    var isLocalBoard:Bool?
    init(isLocalBoard: Bool) {
        self.isLocalBoard = isLocalBoard
    }
}

struct BoardsParams: QueryParams {
    let skip: Int
    let take: Int
    let userId: String
    let keyword: String?
}

struct BoardsVars: PathVars {
    let boardId: String
    
    var vars: [Any] {
        return [boardId]
    }
}

struct BoardMediaItem: Codable {
    var file: Data?

    init(file: Data?) {
        self.file = file
    }
}

struct BoardMediaRequestItem: Decodable {

    var updatedBoard: UpdatedStatus?

    enum CodingKeys: String, CodingKey {
        case updatedBoard
    }
}

struct UpdatedStatus: Decodable {

    var modifiedCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case modifiedCount
    }
}

struct FidParams: QueryParams {
    var fid: String?
}

struct CoverListParams: QueryParams {
    let skip: Int
    let take: Int
    var fid: String?
}

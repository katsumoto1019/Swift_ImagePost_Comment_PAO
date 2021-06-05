//
//  NestedSaveBoardCollectionViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 19/11/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload


class NestedSaveBoardCollectionViewController: SaveBoardCollectionViewController {

    private var parentBoardId: String!
    
    init(userId: String, parentBoardId: String) {
        super.init(userId: userId);
        self.parentBoardId = parentBoardId;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func getPayloads(completionHandler: @escaping ([Board]?) -> Void) -> PayloadTask? {
        let params = BoardsParams(skip: collection.count, take: collection.bufferSize, userId: userId, keyword: searchString);
        let vars = BoardsVars(boardId: parentBoardId);
        return App.transporter.get([Board].self, for: type(of: self), pathVars: vars, queryParams: params, completionHandler: completionHandler);
    }
}

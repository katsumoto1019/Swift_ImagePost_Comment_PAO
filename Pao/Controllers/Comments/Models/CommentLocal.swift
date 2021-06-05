//
//  adfasd.swift
//  Pao
//
//  Created by Waseem Ahmed on 16/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

/// Class contains data of Comment before posting to server.
class CommentLocal: Comment {
    var localId: Int?;
    var failed: Bool = false;
    
    let failedMessage = L10n.CommentLocal.failedMessage;
    let postingMessage = L10n.CommentLocal.postingMessage;
    
    convenience init(localId: Int, message: String, spotId: String) {
        self.init(spotId: spotId, message: message);
        self.localId = localId;
    }
}

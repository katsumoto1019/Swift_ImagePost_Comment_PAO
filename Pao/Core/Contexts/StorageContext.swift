//
//  StorageContext.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/8/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import Firebase

class StorageContext {
    static var userSpots: StorageReference {
        return Storage.storage().reference().child("users").child(DataContext.userUID).child("spots");
    }
    
    static var userProfileImages: StorageReference {
        return Storage.storage().reference().child("users").child(DataContext.userUID).child("profileImages");
    }
    
    static var userCoverImages: StorageReference {
        return Storage.storage().reference().child("users").child(DataContext.userUID).child("coverImages");
    }
    
    static func boardCoverImage(boardId:String) -> StorageReference {
        return Storage.storage().reference().child("users/\(DataContext.userUID)/boards/\(boardId)/media/thumbnail");
    }
}

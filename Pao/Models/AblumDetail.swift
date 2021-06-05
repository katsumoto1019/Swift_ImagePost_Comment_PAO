//
//  ablumDetails.swift
//  Pao
//
//  Created by MACBOOK PRO on 26/06/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import Foundation
import Photos

class AlbumDetail {
    var id: String?
    
    var albumName: String?
    var imagesCount: Int?
    var includeVideos: Bool = true
        
    var phAsset: PHAsset?
}

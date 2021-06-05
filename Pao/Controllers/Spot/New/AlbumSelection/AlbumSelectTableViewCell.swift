//
//  AlbumSelectTableViewCell.swift
//  Pao
//
//  Created by MACBOOK PRO on 26/06/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit
import Payload

import Photos

class AlbumSelectTableViewCell: UITableViewCell, Consignee {
    @IBOutlet weak var albumCoverImage: UIImageView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var photosCountTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        applyStyle()
    }
    
    func applyStyle() {
        self.backgroundColor = ColorName.background.color
        albumTitleLabel.textColor = .white
        photosCountTitle.textColor = .white
    }
    
    func set(_ selectedAlbum: AlbumDetail) {
        albumTitleLabel.text = selectedAlbum.albumName;
        photosCountTitle.text = String(selectedAlbum.imagesCount ?? 0);
        getAssetThumbnail(albumCoverImage: albumCoverImage, phAsset: selectedAlbum.phAsset);
    }
    
    func getAssetThumbnail(albumCoverImage: UIImageView, phAsset: PHAsset?) {
        guard let phAsset = phAsset else {
           albumCoverImage.image = UIImage.init(named: "albumCover")
            return;
        }
        
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true //allow access to iCloud photos
        option.isSynchronous = false
        option.deliveryMode = .opportunistic
        manager.requestImage(for: phAsset, targetSize: CGSize(width: 200.0, height: 200.0), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            if (result == nil) {
                return;
            } else {
                albumCoverImage.image = result;
            }
        });
    }
}

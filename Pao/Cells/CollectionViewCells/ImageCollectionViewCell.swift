//
//  ImageCollectionViewCell.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/7/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Photos
import Payload

class ImageCollectionViewCell: UICollectionViewCell, Consignee {
    
    @IBOutlet public weak var thumbnailImageView: CarouselPickerImageView!
    
    func set(_ url: URL) {
        thumbnailImageView.kf.indicatorType = .activity;
        thumbnailImageView.kf.setImage(with: url);
        
        thumbnailImageView.isUserInteractionEnabled = false;
    }
    
    func set(phAsset: PHAsset) {
        thumbnailImageView.isUserInteractionEnabled = true;
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .opportunistic //was changed to fix blurry previews
        requestOptions.resizeMode = .fast //this is the candidate fix for the blurry uploads PPL-280
        requestOptions.version = .current //asking for the current brings the edited version, but original brings unedited
        requestOptions.isNetworkAccessAllowed = true //was also needed to help blurry previews (was otherwise black)
        
        let imageSize = PHImageManagerMaximumSize // Got actual size of image
        // resize only for uploads, we don't care if the preview downscales from something larger [EG]
        //if phAsset.pixelWidth > 2048 || phAsset.pixelHeight > 2048 { // limits the max size
        //    imageSize = CGSize(width: 2048, height: 2048);
        //}
        PHImageManager.default().requestImage(for: phAsset, targetSize: imageSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, error) in
            if let error = error {
                print(error)
            }
            guard let image = image else {
                return
            }
            DispatchQueue.main.async {
                self.thumbnailImageView.image = image
            }
        })
    }
    
    func set(spotImage: SpotMediaItem) {
        thumbnailImageView.kf.indicatorType = .none;
        let size = CGSize(width: frame.width * UIScreen.main.scale, height: frame.height * UIScreen.main.scale);
         let servingUrl = spotImage.url?.imageServingUrl(cropSize: size);
        thumbnailImageView.kf.setImage(with: servingUrl, options: [.transition(.fade(0.1))]);
        if let hex = spotImage.placeholderColor {
            backgroundColor = UIColor(hex: hex);
        }
    }
}

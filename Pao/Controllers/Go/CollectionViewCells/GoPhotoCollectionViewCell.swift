//
//  GoPhotoCollectionViewCell.swift
//  Pao
//
//  Created by Waseem Ahmed on 03/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload

class GoPhotoCollectionViewCell: UICollectionViewCell, Consignee {
    
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    
    var delegate: GoPhotoCollectionDelegate?
    
    var spot: Spot?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userImageView.makeCornerRound()
        locationImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapHandler(_ :))))
        userImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapHandler(_ :))))
        locationImageView.isUserInteractionEnabled = true;
        userImageView.isUserInteractionEnabled = true;
    }
    
    @objc func tapHandler(_ tapGesture: UITapGestureRecognizer) {
        if tapGesture.view == locationImageView {
            
            if let spot = spot {
                FirbaseAnalytics.logEvent(.goPageViewSpot)
                let (category, subCategory) = spot.getCategorySubCategoryNameList()
                let postId = spot.id ?? ""
                let properties = ["post ID": postId, "category": category, "subcategory": subCategory] as [String : Any]
                AmplitudeAnalytics.logEvent(.goClickSpot, group: .spot, properties: properties)
                
                delegate?.showSpot(spot: spot)
            }
            
        } else if tapGesture.view == userImageView {
            
            FirbaseAnalytics.logEvent(.clickProfileIcon)
            
            if let user = spot?.user, let delegate = delegate {
                delegate.showProfile(user: User(user: user))
            }
        }
    }

    func set(_ spot: Spot) {
        self.spot = spot;
        if let media = spot.media?.values.sorted(by: {$0.index ?? 0 < $1.index ?? 0}).first {
            locationImageView.kf.indicatorType = .none;
            let size = CGSize(width: frame.width * UIScreen.main.scale, height: frame.height * UIScreen.main.scale);
            let url = media.type == 0 ? media.url : media.thumbnailUrl;
            let servingUrl = url?.imageServingUrl(cropSize: size)
            locationImageView.kf.setImage(with: servingUrl, options: [.transition(.fade(0.1))]);
            if let hex = media.placeholderColor {
                locationImageView.backgroundColor = UIColor(hex: hex);
            }
        }
        
        if let profileImageUrl = spot.user?.profileImage?.url {
            userImageView.kf.indicatorType = .activity;
            userImageView.kf.setImage(with: profileImageUrl);
        } else {
            userImageView.image = Asset.Assets.Icons.user.image
        }
    }
}

protocol GoPhotoCollectionDelegate: class {
    func showProfile(user: User?);
    func showSpot(spot: Spot?);
}

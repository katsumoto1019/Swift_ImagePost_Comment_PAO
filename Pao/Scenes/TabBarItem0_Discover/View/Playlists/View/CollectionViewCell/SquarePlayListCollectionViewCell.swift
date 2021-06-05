//
//  SquarePlayListCollectionViewCell.swift
//  Pao
//
//  Created by OmShanti on 26/02/21.
//  Copyright © 2021 Exelia. All rights reserved.
//

import UIKit
import Payload

class SquarePlayListCollectionViewCell: UICollectionViewCell, Consignee {
    
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var spotLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    
    var spot: Spot?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userImageView.makeCornerRound()
        spotLabel.font = UIFont.appMedium.withSize(UIFont.sizes.tiny+1)
        cityStateLabel.font = UIFont.appLight.withSize(UIFont.sizes.tiny)
    }
    
    func set(_ spot: Spot) {
        self.spot = spot
        if let media = spot.media?.values.sorted(by: {$0.index ?? 0 < $1.index ?? 0}).first {
            locationImageView.kf.indicatorType = .none
            let size = CGSize(width: frame.width * UIScreen.main.scale, height: frame.height * UIScreen.main.scale)
            let url = media.type == 0 ? media.url : media.thumbnailUrl;
            let servingUrl = url?.imageServingUrl(cropSize: size)
            locationImageView.kf.setImage(with: servingUrl, options: [.transition(.fade(0.1))])
            if let hex = media.placeholderColor {
                locationImageView.backgroundColor = UIColor(hex: hex)
            }
        }
        
        if let profileImageUrl = spot.user?.profileImage?.url {
            userImageView.kf.indicatorType = .activity
            userImageView.kf.setImage(with: profileImageUrl)
        } else {
            userImageView.image = Asset.Assets.Icons.user.image
        }
        spotLabel.text = spot.line1
        cityStateLabel.text = spot.line2
    }
}

//
//  SpotMapCollectionViewCell.swift
//  Pao
//
//  Created by Waseem Ahmed on 08/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Firebase
import Photos
import Payload


class MiniSpotCollectionViewCell: BaseCollectionViewCell, Consignee {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var attributeLabel: UILabel!
    
    weak var delegate: SpotCollectionViewCellDelegate?
    var spot: Spot!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        applyStyle();
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showProfile));
        userImageView.addGestureRecognizer(tapGestureRecognizer);
        userImageView.isUserInteractionEnabled = true;
    }

    func applyStyle() {
        backgroundColor = ColorName.background.color
        userImageView.makeCornerRound();
        thumbnailImageView.contentMode = .scaleAspectFill;
        thumbnailImageView.clipsToBounds = true;


        titleLabel.font = UIFont.appNormal.withSize(UIFont.sizes.normal);
        titleLabel.textColor = ColorName.accent.color
        
        subTitleLabel.set(fontSize: UIFont.sizes.small);
        attributeLabel.textColor = UIColor.lightText;
    }
    
    func set(_ spot: Spot) {
        self.spot = spot;
        if let media = spot.media?.values.sorted(by: {$0.index ?? 0 < $1.index ?? 0}).first {
            let url = media.type == 0 ? media.url : media.thumbnailUrl;
             thumbnailImageView.kf.setImage(with: url);
        }
        
        if let url = spot.user?.profileImage?.url {
             userImageView.kf.setImage(with: url);
        }
        
        titleLabel.text = spot.location?.name;
        subTitleLabel.text = spot.location?.cityFormatted;
        attributeLabel.text = spot.location?.typeFormatted;
    }
    
    @objc func showProfile() {
        FirbaseAnalytics.logEvent(.clickProfileIcon)
        if let user = spot.user {
            delegate?.showProfile(user: User(user: user));
        }
    }
}

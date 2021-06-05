//
//  SpotSearchTableViewCell.swift
//  Pao
//
//  Created by Parveen Khatkar on 28/09/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload

class SpotSearchTableViewCell: UITableViewCell, Consignee {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        descriptionLabel.textColor = ColorName.textGray.color
        titleLabel.set(fontSize: UIFont.sizes.small);
    }
    
    override func layoutSubviews() {
        thumbnailImage.layer.cornerRadius = thumbnailImage.frame.width / 2;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(_ spot: Spot) {
//        titleLabel.text = spot.location?.name?.capitalized;
        titleLabel.text = spot.location?.name;
        subTitleLabel.text = spot.location?.cityFormatted;
        descriptionLabel.text = spot.location?.typeFormatted;
        
        var thumbnailURL:URL!;
        
        for (_ , mediaItem) in spot.media! {
            if let url = mediaItem.type == 0 ? mediaItem.url : mediaItem.thumbnailUrl {
                if (mediaItem.index == 0) {
                    thumbnailURL = url;
                    break;
                }
            }
        }
        
        if let thumbnailURL = thumbnailURL {
            thumbnailImage.kf.setImage(with: thumbnailURL);
        } else {
            thumbnailImage.image = Asset.Assets.Icons.user.image
            thumbnailImage.backgroundColor = UIColor.clear;
        }
    }
}

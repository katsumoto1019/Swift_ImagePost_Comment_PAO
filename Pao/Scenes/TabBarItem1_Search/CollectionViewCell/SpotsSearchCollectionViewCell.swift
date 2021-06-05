//
//  SpotsSearchCollectionViewCell.swift
//  Pao
//
//  Created by MACBOOK PRO on 09/09/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit
import Payload

class SpotsSearchCollectionViewCell: UICollectionViewCell, Consignee {
    
    // MARK: - Outlets
    
    @IBOutlet private var thumbnailImage: UIImageView!
    @IBOutlet private var thumbnailContainerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subTitleLabel: UILabel!
    
    // MARK: - Private properties
    
    private var spot: Spot!
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        thumbnailImage.layer.cornerRadius = thumbnailImage.frame.width / 2
        thumbnailContainerView.layer.cornerRadius = thumbnailImage.layer.cornerRadius
        
        applyStyle()
    }
    
    // MARK: - Internal methods
    
    func set(_ spot: Spot) {
        self.spot = spot
        
        titleLabel.text = spot.location?.cityFormatted?.capitalized
        subTitleLabel.text = spot.user?.name
        
        if let thumbnailURL = spot.thumbnail?.url {
            thumbnailImage.kf.setImage(with: thumbnailURL)
        } else {
            thumbnailImage.image = Asset.Assets.Icons.user.image
            thumbnailImage.backgroundColor = UIColor.clear
        }
        
        layoutIfNeeded()
    }
    
    // MARK: - Private methods
    
    private func applyStyle() {
        titleLabel.font = UIFont.appNormal.withSize(UIFont.sizes.small)
        thumbnailContainerView.addShadow(offset: .zero, color: .black, radius: 5, opacity: 1)
    }
}

//
//  PlayListCollectionViewCell.swift
//  Pao
//
//  Created by MACBOOK PRO on 17/09/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit
import Payload

class PlayListCollectionViewCell: UICollectionViewCell, Consignee {
    
    // MARK: - Outlets
    
    @IBOutlet var thumbnailImage: UIImageView!
    @IBOutlet private var labelName: UILabel!
    @IBOutlet private var containerView: UIView!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = containerView.frame.width / 2
        containerView.layer.cornerRadius = radius
        thumbnailImage.layer.cornerRadius = radius
    }
    
    // MARK: - Internal methods

    func set(_ playlist: PlayList) {
        labelName.text = playlist.name?.uppercased()
        
        if let thumbnailURL = playlist.cover?.urlFromString {
            thumbnailImage.kf.setImage(with: thumbnailURL)
        } else {
            thumbnailImage.image = Asset.Assets.Backgrounds.defaultCoverPhoto.image
            thumbnailImage.backgroundColor = .clear
        }
        layoutIfNeeded()
    }
    
    // MARK: - Private methods
    
    private func applyStyle() {
        labelName.textColor = .white
        labelName.font = UIFont.appMedium.withSize(UIFont.sizes.normal)
        thumbnailImage.alpha = 0.7
        
        containerView.addShadow(offset: .zero, color: .black, radius: 5, opacity: 1)
    }
}

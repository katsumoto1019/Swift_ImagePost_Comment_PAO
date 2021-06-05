//
//  CirclePlayListCollectionViewCell.swift
//  Pao
//
//  Created by OmShanti on 26/02/21.
//  Copyright © 2021 Exelia. All rights reserved.
//

import UIKit
import Payload

class CirclePlayListCollectionViewCell: UICollectionViewCell, Consignee {
    
    // MARK: - Outlets
    
    @IBOutlet var thumbnailImage: UIImageView!
    @IBOutlet private var labelName: UILabel!
    @IBOutlet private var containerView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userHiddenGemsLabel: UILabel!
    @IBOutlet weak var userCityLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
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
        shadowView.layer.cornerRadius = radius
    }
    
    // MARK: - Internal methods

    func set(_ playlist: PlayList) {
        userNameLabel.text = ""
        userHiddenGemsLabel.text = ""
        userCityLabel.text = ""
        labelName.text = playlist.line1
        labelName.numberOfLines = 3
        labelName.font = UIFont.appMedium.withSize(UIFont.sizes.verySmall)
        shadowView.isHidden = false
        
        if let placeholderColor = playlist.cover?.placeholderColor {
            thumbnailImage.backgroundColor = UIColor(hex: placeholderColor)
        }
        if let thumbnailURL = playlist.cover?.urlFromString {
            thumbnailImage.kf.setImage(with: thumbnailURL)
        } else {
            thumbnailImage.image = Asset.Assets.Backgrounds.defaultCoverPhoto.image
            thumbnailImage.backgroundColor = .clear
        }
        layoutIfNeeded()
    }
    
    func setLocation(_ location: Location) {
        userNameLabel.text = ""
        userHiddenGemsLabel.text = ""
        userCityLabel.text = ""
        labelName.numberOfLines = 1
        labelName.font = UIFont.appMedium.withSize(UIFont.sizes.normal)
        shadowView.isHidden = false
        
        if let locationName = location.line1 {
            labelName.text = locationName.uppercased()
        }
        
        if let placeholderColor = location.cover?.placeholderColor {
            thumbnailImage.backgroundColor = UIColor(hex: placeholderColor)
        }
        
        if let locationImageUrl = location.cover?.url {
            thumbnailImage.kf.setImage(with: locationImageUrl)
        }
        
        layoutIfNeeded()
    }
    
    func setUser(_ user: User) {
        labelName.text = ""
        labelName.numberOfLines = 1
        labelName.font = UIFont.appMedium.withSize(UIFont.sizes.normal)
        shadowView.isHidden = true
        
        userNameLabel.text = user.line1
        userHiddenGemsLabel.text = user.line2
        userCityLabel.text = user.line3

        if let placeholderColor = user.profileImage?.placeholderColor {
            thumbnailImage.backgroundColor = UIColor(hex: placeholderColor)
        }

        if let profileImageUrl = user.profileImage?.url {
            thumbnailImage.kf.setImage(with: profileImageUrl)
        } else {
            thumbnailImage.image = Asset.Assets.Icons.user.image
            thumbnailImage.backgroundColor = UIColor.clear
        }

        layoutIfNeeded()
    }
    
    // MARK: - Private methods
    
    private func applyStyle() {
        labelName.textColor = .white
        labelName.font = UIFont.appMedium.withSize(UIFont.sizes.normal)
        thumbnailImage.alpha = 0.7
        userNameLabel.textColor = .white
        userNameLabel.font = UIFont.appMedium.withSize(UIFont.sizes.verySmall)
        userHiddenGemsLabel.textColor = .white
        userHiddenGemsLabel.font = UIFont.appMedium.withSize(UIFont.sizes.tiny)
        userCityLabel.textColor = .white
        userCityLabel.font = UIFont.appMedium.withSize(UIFont.sizes.tiny)
        
        containerView.addShadow(offset: .zero, color: .black, radius: 5, opacity: 1)
    }
}

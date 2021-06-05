//
//  PeopleSearchCollectionViewCell.swift
//  Pao
//
//  Created by Parveen Khatkar on 21/08/19.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit
import Payload

class PeopleSearchCollectionViewCell: UICollectionViewCell, Consignee {
    
    // MARK: - Outlets
    
    @IBOutlet private var thumbnailImage: UIImageView!
    @IBOutlet private var thumbnailContainerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subTitleLabel: UILabel!
    
    // MARK: - Private properties
    
    private var user: User!
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        thumbnailImage.layer.cornerRadius = thumbnailImage.frame.width / 2
        thumbnailContainerView.layer.cornerRadius = thumbnailImage.layer.cornerRadius
        
        applyStyle()
    }
    
    // MARK: - Internal methods
    
    func set(_ user: User) {
        self.user = user
        
        titleLabel.text = user.name
        subTitleLabel.text = String(format: "%d \(L10n.Common.labelUploads.lowercased())", user.uploadedSpotsCount ?? "")
        
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
        titleLabel.font = UIFont.appNormal.withSize(UIFont.sizes.small)
        thumbnailContainerView.addShadow(offset: .zero, color: .black, radius: 5, opacity: 1)
    }
}

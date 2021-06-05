//
//  LocationSearchCollectionViewCell.swift
//  Pao
//
//  Created by Parveen Khatkar on 27/08/19.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit
import Payload

class LocationSearchCollectionViewCell: UICollectionViewCell, Consignee {
    
    // MARK: - Outlets
    
    @IBOutlet private var thumbnailContainerView: UIView!
    @IBOutlet private var thumbnailImage: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    
    // MARK: - Private properties
    
    private var location: Location!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyles()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = thumbnailContainerView.frame.width / 2
        thumbnailContainerView.layer.cornerRadius = radius
        thumbnailImage.layer.cornerRadius = radius
    }
    
    // MARK: - Internal methods
    
    func set(_ location: Location) {
        self.location = location
        
        if let locationNames = location.name?.components(separatedBy: ",").first {
            titleLabel.text = locationNames.uppercased()
        }
        
        if let placeholderColor = location.cover?.placeholderColor {
            thumbnailImage.backgroundColor = UIColor(hex: placeholderColor)
        }
        
        if let locationImageUrl = location.cover?.url {
            thumbnailImage.kf.setImage(with: locationImageUrl)
        }
        
        layoutIfNeeded()
    }
    
    // MARK: - Private methods
    
    private func applyStyles() {
        titleLabel.font = UIFont.appMedium.withSize(UIFont.sizes.normal)
        thumbnailImage.alpha = 0.75
        thumbnailContainerView.backgroundColor = ColorName.background.color
        thumbnailContainerView.addShadow(offset: .zero, color: .black, radius: 5, opacity: 1)
    }
}

//
//  LocationSearchTableViewCell.swift
//  Pao
//
//  Created by Parveen Khatkar on 28/09/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload

class LocationSearchTableViewCell: UITableViewCell, Consignee {
    
    // MARK: - Outlets
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var widthIconConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightIconConstraint: NSLayoutConstraint!
    
    // MARK: - Internal methods
    
    func set(_ location: Location) {
        titleLabel.text = location.name;
    }
    
    func set(_ location: Location, isPinIcon: Bool) {
        titleLabel.text = location.name
        
        if isPinIcon {
            iconImageView.image = Asset.Assets.Icons.locationPin.image
            iconImageView.backgroundColor = UIColor.clear
            
            widthIconConstraint.constant = 7
            heightIconConstraint.constant = 17
            iconImageView.layer.cornerRadius = 0            
        } else {
            
            if let placeholderColor = location.cover?.placeholderColor {
                iconImageView.backgroundColor = UIColor(hex: placeholderColor);
            }
            
            if let coverUrl = location.cover?.url {
                iconImageView.kf.setImage(with: coverUrl)
            } else {
//                iconImageView.image = Asset.Icons.locationPin.image
            }
            
            widthIconConstraint.constant = 55
            heightIconConstraint.constant = 55
            iconImageView.makeCornerRound(cornerRadius: widthIconConstraint.constant / 2)
        }
    }
}

//
//  NotificationViewCell.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/27/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class UserViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    // MARK: - Internal methods
    
    func set(user: User) {
        profileImageView.isUserInteractionEnabled = false;
        if let profileImageUrl = user.profileImage?.url {
            profileImageView.kf.setImage(with: profileImageUrl);
        } else {
            profileImageView.image = Asset.Assets.Icons.user.image
        }
        
        titleLabel.text = user.name;
        subTitleLabel.text = user.username;
    }
}

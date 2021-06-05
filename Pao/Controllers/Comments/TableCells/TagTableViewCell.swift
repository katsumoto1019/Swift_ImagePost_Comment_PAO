//
//  TagTableViewCell.swift
//  Pao
//
//  Created by Waseem Ahmed on 08/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class TagTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        applyStyles();
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func applyStyles() {
        
        backgroundColor = ColorName.background.color
        selectionStyle = .none;

        profileImageView.makeCornerRound();
        
        titleLabel.textColor = UIColor.white;
        titleLabel.set(fontSize: UIFont.sizes.small);
        
        subTitleLabel.textColor = ColorName.placeholder.color
        subTitleLabel.set(fontSize: UIFont.sizes.small);
    }
    
    func set(user: User) {
        titleLabel.text = user.username;
        subTitleLabel.text = user.name;
        
        if let profileImageUrl = user.profileImage?.url {
            profileImageView.kf.setImage(with: profileImageUrl);
        } else {
            profileImageView.image = Asset.Assets.Icons.user.image
        }
    }
}

//
//  PeopleSearchTableViewCell.swift
//  Pao
//
//  Created by Parveen Khatkar on 28/09/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload


class PeopleSearchTableViewCell: UITableViewCell, Consignee {
    
    @IBOutlet weak var thumbnailImage: ProfileImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var actionButton: RoundCornerButton!
    
    public var isPeopleSearch:Bool = false;
    
    private var user: User!
    
    var followCallback:((_ action: FollowAction) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        applyStyle()
        
        thumbnailImage.isUserInteractionEnabled = false
    }
    
    func applyStyle() {
        actionButton.layer.borderColor = ColorName.textWhite.color.cgColor
        actionButton.layer.borderWidth = 0.5
        actionButton.titleLabel?.set(fontSize: UIFont.sizes.verySmall)
        
        titleLabel.textColor = .white
        subTitleLabel.textColor = ColorName.textLightGray.color
        
        titleLabel.font = UIFont.appNormal.withSize(UIFont.sizes.small)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func set(_ user: User) {
        self.user = user
        
        titleLabel.text = user.name
        if (isPeopleSearch) {
            subTitleLabel.text = String(format: "%d \(L10n.Common.labelUploads.lowercased())", user.uploadedSpotsCount ?? "") } else {
            subTitleLabel.text = String(format: "@%@", user.username ?? "")
        }
        
        if let placeholderColor = user.profileImage?.placeholderColor {
            thumbnailImage.backgroundColor = UIColor(hex: placeholderColor)
        }
        
        if let profileImageUrl = user.profileImage?.url {
            thumbnailImage.kf.setImage(with: profileImageUrl)
        } else {
            thumbnailImage.image = Asset.Assets.Icons.user.image
            thumbnailImage.backgroundColor = UIColor.clear
        }
        
        // TODO: Change to following status
        actionButton.isSelected = DataContext.cache.isSelectedInMyPeople(userId: user.id)
        
        actionButton.backgroundColor = ColorName.buttonAccent.color
        actionButton.layer.borderWidth = 0
        
        if (DataContext.cache.isSelectedInMyPeople(userId: user.id)) {
            actionButton.backgroundColor = .clear
            actionButton.layer.borderWidth = 0.5
        }
        
        actionButton.isHidden = user.id == DataContext.cache.user.id
    }

    @IBAction func action(_ sender: UIButton) {
        let action: FollowAction = sender.isSelected ? .unfollow : .follow;
        sender.isSelected = !sender.isSelected;
        
        FirbaseAnalytics.logEvent(.addTopPaoUser, parameters: ["value": action == .follow ? 1 : 0])
        followCallback?(action)
        
        let userObject = User(id: self.user.id)
        
        App.transporter.post(userObject, to: action) { (success) in
            if success == true {
                AmplitudeAnalytics.addUserValue(property: .followings, value: sender.isSelected ? 1 : -1)

                self.user.isFollowedByViewer =  sender.isSelected
                if sender.isSelected {
                    DataContext.cache.addToMyPeople(userObj: self.user)
                } else {
                    DataContext.cache.removeFromMyPeople(userObj: self.user)
                }
                NotificationCenter.followingPeople()
            } else {
                sender.isSelected = !sender.isSelected
            }
            
            sender.backgroundColor = ColorName.buttonAccent.color
            sender.layer.borderWidth = 0
            
            if (sender.isSelected == true) {
                sender.backgroundColor = .clear
                sender.layer.borderWidth = 0.5
            }
        }
    }
}

enum FollowAction: Int {
    case follow
    case unfollow
    case accept
    case reject
}

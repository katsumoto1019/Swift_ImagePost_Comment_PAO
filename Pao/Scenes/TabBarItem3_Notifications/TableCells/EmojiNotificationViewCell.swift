//
//  EmojiNotificationViewCell.swift
//  Pao
//
//  Created by OmShanti on 31/08/20.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit
import Payload

class EmojiNotificationViewCell: UserViewCell, Consignee {
    @IBOutlet weak var thumbnailImageView: UIImageView!
  
    weak var delegate: UIViewController?
    private var notification: PushNotification<SpotNotification>? = nil
    @IBOutlet weak var thumbnailImageHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.isUserInteractionEnabled = false
        let profileTapGestureRecongizer = UITapGestureRecognizer(target: self, action: #selector(showProfile))
        contentView.addGestureRecognizer(profileTapGestureRecongizer)
        
        profileImageView.isUserInteractionEnabled = false
        
        let thumbnailTapGestureRecongizer = UITapGestureRecognizer(target: self, action: #selector(showSpot))
        thumbnailImageView.addGestureRecognizer(thumbnailTapGestureRecongizer)
        thumbnailImageView.isUserInteractionEnabled = true
        
        // override UIAppearance so it doesn't reset text style.
        titleLabel.font = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func set(_ notification: PushNotification<SpotNotification>) {
        self.notification = notification
        
        if let profileImageURL = notification.payload?.user?.profileImage?.url {
            profileImageView.kf.setImage(with: profileImageURL)
        } else {
            profileImageView.image = Asset.Assets.Icons.user.image
        }
        
        if let thumbnailUrl = notification.payload?.spot?.media?.url {
            thumbnailImageView.kf.setImage(with: thumbnailUrl)
            thumbnailImageView.isHidden = false
            thumbnailImageHeightConstraint.constant = 65
        } else {
            thumbnailImageView.isHidden = true
            thumbnailImageHeightConstraint.constant = 0
        }
        
        var titleString = ""
        switch notification.type! {
        case .reactHeartEyes:
            titleString = "\n\(L10n.EmojiNotificationViewCell.reacted): \(Emoji.heart_eyes.code)"
            break
        case .reactGem:
            titleString = "\n\(L10n.EmojiNotificationViewCell.reacted): \(Emoji.gem.code)"
            break
        case .reactDroolingFace:
            titleString = "\n\(L10n.EmojiNotificationViewCell.reacted): \(Emoji.drooling_face.code)"
            break
        case .reactClap:
            titleString = "\n\(L10n.EmojiNotificationViewCell.reacted): \(Emoji.clap.code)"
            break
        case .reactRoundPushpin:
            titleString = "\n\(L10n.EmojiNotificationViewCell.reacted): \(Emoji.round_pushpin.code)"
            break
        default:
            break
        }
        
        let formattedString = NSMutableAttributedString()
        formattedString.bold(notification.payload?.user?.name ?? "").normal(" " + titleString)
        titleLabel.attributedText = formattedString
        
        subTitleLabel.text = notification.timestamp?.timeElapsedString(suffix: "", isShort: true)
    }
    
    @objc func showProfile() {
        FirbaseAnalytics.logEvent(.notifyToProfile)
        AmplitudeAnalytics.logEvent(.notifyToProfile, group: .notifications)
        if let user = notification?.payload?.user {
            if let navController = delegate?.navigationController {
                navController.setNavigationBarHiddenWithCustomAnimation(true, animated: true)
                let viewController = UserProfileViewController(user: User(user: user))
                viewController.isNavigationBarHiddenOnParent = navController.navigationBar.isHidden
                navController.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @objc func showSpot() {
        if let spotId = notification?.payload?.spot?.id {
            FirbaseAnalytics.logEvent(.notifyToSpot)
            AmplitudeAnalytics.logEvent(.notifyToSpot, group: .notifications)

            let manualSpotsViewController = ManualSpotsViewController.init(spotId: spotId)
            manualSpotsViewController.title = notification?.payload?.spot?.location?.name
            manualSpotsViewController.showCommentsOnLoad = notification!.type! == .comment || notification!.type! == .spotcomment
            delegate?.navigationController?.pushViewController(manualSpotsViewController, animated: true)
        }
    }
}
